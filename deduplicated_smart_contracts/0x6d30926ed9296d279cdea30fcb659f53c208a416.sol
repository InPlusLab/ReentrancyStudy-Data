/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract IZrxExchange {

    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see IZrxExchange.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    function getOrderInfo(Order memory order)
        public
        view
        returns (OrderInfo memory orderInfo);

    function getOrdersInfo(Order[] memory orders)
        public
        view
        returns (OrderInfo[] memory ordersInfo);

    function fillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (FillResults memory fillResults);
}

contract IERC20NonView {
    // Methods are not view to avoid throw on proxy tokens with delegatecall inside
    function balanceOf(address user) public returns(uint256);
    function allowance(address from, address to) public returns(uint256);
}

contract ZrxMarketOrder {

    using SafeMath for uint256;

    function marketSellOrders(
        address makerAsset,
        address zrxExchange,
        address zrxTokenProxy,
        uint256 takerAssetFillAmount,
        IZrxExchange.Order[] calldata orders,
        bytes[] calldata signatures
    )
        external
        returns (IZrxExchange.FillResults memory totalFillResults)
    {
        for (uint i = 0; i < orders.length; i++) {

            // Stop execution if the entire amount of takerAsset has been sold
            if (totalFillResults.takerAssetFilledAmount >= takerAssetFillAmount) {
                break;
            }

            // Calculate the remaining amount of takerAsset to sell
            uint256 remainingTakerAmount = takerAssetFillAmount.sub(totalFillResults.takerAssetFilledAmount);

            IZrxExchange.OrderInfo memory orderInfo = IZrxExchange(zrxExchange).getOrderInfo(orders[i]);
            uint256 orderRemainingTakerAmount = orders[i].takerAssetAmount.sub(orderInfo.orderTakerAssetFilledAmount);

            // Check available balance and allowance and update orderRemainingTakerAmount
            {
                uint256 balance = IERC20NonView(makerAsset).balanceOf(orders[i].makerAddress);
                uint256 allowance = IERC20NonView(makerAsset).allowance(orders[i].makerAddress, zrxTokenProxy);
                uint256 availableMakerAmount = (allowance < balance) ? allowance : balance;
                uint256 availableTakerAmount = availableMakerAmount.mul(orders[i].takerAssetAmount).div(orders[i].makerAssetAmount);

                if (availableTakerAmount < orderRemainingTakerAmount) {
                    orderRemainingTakerAmount = availableTakerAmount;
                }
            }

            uint256 takerAmount = (orderRemainingTakerAmount < remainingTakerAmount) ? orderRemainingTakerAmount : remainingTakerAmount;

            IZrxExchange.FillResults memory fillResults = IZrxExchange(zrxExchange).fillOrder(
                orders[i],
                takerAmount,
                signatures[i]
            );

            remainingTakerAmount = remainingTakerAmount.sub(fillResults.takerAssetFilledAmount);
        }

        return totalFillResults;
    }

    function addFillResults(
        IZrxExchange.FillResults memory totalFillResults,
        IZrxExchange.FillResults memory singleFillResults
    )
        internal
        pure
    {
        totalFillResults.makerAssetFilledAmount = totalFillResults.makerAssetFilledAmount.add(singleFillResults.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = totalFillResults.takerAssetFilledAmount.add(singleFillResults.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = totalFillResults.makerFeePaid.add(singleFillResults.makerFeePaid);
        totalFillResults.takerFeePaid = totalFillResults.takerFeePaid.add(singleFillResults.takerFeePaid);
    }
}