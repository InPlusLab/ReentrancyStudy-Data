pragma solidity 0.6.6;

import "./IERC20.sol";
import "./SafeERC20.sol";
import "./Withdrawable.sol";

contract DistributeRewards is Withdrawable {
    using SafeERC20 for IERC20;

    constructor(address _admin) public Withdrawable(_admin) {}

    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    receive() external payable {}

    function distribute(
        address payable winner,
        IERC20 token,
        uint256 amount
    ) public onlyOperator {
        require(winner != address(0), "winner cannot be zero address");
        require(address(token) != address(0), "token cannot be zero address");
        require(amount > 0, "amount is 0");

        if (token == ETH_TOKEN_ADDRESS) {
            require(address(this).balance >= amount, "eth amount required > balance");
            (bool success, ) = winner.call{value: amount}("");
            require(success, "send to winner failed");
        } else {
            require(token.balanceOf(address(this)) >= amount, "token amount required > balance");
            token.safeTransfer(winner, amount);
        }
    }

    function distributeToMany(
        address[] memory winners,
        IERC20 token,
        uint256 amount
    ) public onlyOperator {
        for (uint256 i = 0; i < winners.length; i++) {
            distribute(payable(winners[i]), token, amount);
        }
    }
}
