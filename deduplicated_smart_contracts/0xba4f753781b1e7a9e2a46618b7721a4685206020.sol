// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Ownable.sol";

contract EmergencyRecipient is Ownable {

    constructor(address _owner) Ownable(_owner) {
    }

    function sendToken(IERC20 token, address recipient, uint256 amount) external onlyOwner {
        token.transfer(recipient, amount);
    }

    function sendETH(address payable recipient, uint256 amount) external onlyOwner {
        recipient.transfer(amount);
    }

    receive() payable external {
    }
}