/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

pragma solidity ^0.5.7;

interface IERC20 {
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract TransferLogic {
    /**
     * @dev get ethereum address
     */
    function getAddressETH() public pure returns (address eth) {
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    /**
     * @dev Deposit ERC20 from user
     * @dev user must approve token transfer first
     */
    function deposit(address erc20, uint256 amount) external payable {
        if (erc20 != getAddressETH()) {
            IERC20(erc20).transferFrom(msg.sender, address(this), amount);
        }
    }

    /**
     * @dev Withdraw ETH/ERC20 to user
     */
    function withdraw(
        address erc20,
        address receiver,
        uint256 amount
    ) external {
        uint256 realAmt;

        if (erc20 == getAddressETH()) {
            realAmt = amount == 0 ? address(this).balance : amount;
            address(uint160(receiver)).transfer(realAmt);
        } else {
            realAmt = amount == 0
                ? IERC20(erc20).balanceOf(address(this))
                : amount;
            IERC20(erc20).transfer(receiver, realAmt);
        }
    }
}