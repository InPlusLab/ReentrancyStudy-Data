pragma solidity ^0.5.8;

import "./Swap.sol";
import "./ERC20Interface.sol";

contract ERC20Swap is Swap {
    enum OrderState { HasFundingBalance, Claimed, Refunded }

    struct SwapOrder {
        address user;
        address tokenContractAddress;
        bytes32 paymentHash;
        bytes32 preimage;
        uint onchainAmount;
        uint refundBlockHeight;
        OrderState state;
        bool exist;
    }

    mapping(bytes16 => SwapOrder) orders;

    event OrderFundingReceived(
        bytes16 orderUUID,
        uint onchainAmount,
        bytes32 paymentHash,
        uint refundBlockHeight,
        address tokenContractAddress
    );
    event OrderClaimed(bytes16 orderUUID);
    event OrderRefunded(bytes16 orderUUID);

    /**
     * Allow the sender to fund a swap in one or more transactions.
     */
    function fund(bytes16 orderUUID, bytes32 paymentHash, address tokenContractAddress, uint tokenAmount) external {
        SwapOrder storage order = orders[orderUUID];

        if (!order.exist) {
            order.user = msg.sender;
            order.tokenContractAddress = tokenContractAddress;
            order.exist = true;
            order.paymentHash = paymentHash;
            order.refundBlockHeight = block.number + refundDelay;
            order.state = OrderState.HasFundingBalance;
            order.onchainAmount = 0;
        } else {
            require(order.state == OrderState.HasFundingBalance, "Order already claimed or refunded.");
        }

        // one token type per order
        require(order.tokenContractAddress == tokenContractAddress, "Incorrect token.");
        // fund token to this contract
        require(ERC20Interface(tokenContractAddress).transferFrom(msg.sender, address(this), tokenAmount), "Unable to transfer token.");

        order.onchainAmount += tokenAmount;

        emit OrderFundingReceived(
            orderUUID,
            order.onchainAmount,
            order.paymentHash,
            order.refundBlockHeight,
            order.tokenContractAddress
        );
    }

    /**
     * Allow the recipient to claim the funds once they know the preimage of the hashlock.
     * Anyone can claim but tokens only send to owner.
     */
    function claim(bytes16 orderUUID, address tokenContractAddress, bytes32 preimage) external {
        SwapOrder storage order = orders[orderUUID];

        require(order.exist == true, "Order does not exist.");
        require(order.state == OrderState.HasFundingBalance, "Order cannot be claimed.");
        require(sha256(abi.encodePacked(preimage)) == order.paymentHash, "Incorrect payment preimage.");
        require(block.number <= order.refundBlockHeight, "Too late to claim.");

        order.preimage = preimage;
        // transfer token to owner
        ERC20Interface(tokenContractAddress).transfer(owner, order.onchainAmount);
        order.state = OrderState.Claimed;

        emit OrderClaimed(orderUUID);
    }

    /**
     * Refund the sent token amount back to the funder if the timelock has expired.
     */
    function refund(bytes16 orderUUID, address tokenContractAddress) external {
        SwapOrder storage order = orders[orderUUID];

        require(order.exist == true, "Order does not exist.");
        require(order.state == OrderState.HasFundingBalance, "Order cannot be refunded.");
        require(block.number > order.refundBlockHeight, "Too early to refund.");

        // transfer token to recepient
        ERC20Interface(tokenContractAddress).transfer(order.user, order.onchainAmount);
        order.state = OrderState.Refunded;

        emit OrderRefunded(orderUUID);
    }
}
