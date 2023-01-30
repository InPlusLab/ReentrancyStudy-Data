/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.25;



interface IERC20 {

    function balanceOf(address who) external view returns(uint256);

    function transfer(address to, uint256 amount) external returns(bool);

}


// <yes> Reentrancy
contract AntiFrontRunning {

    function sell(IERC20 token, uint256 minAmount) public payable {

        require(token.call.value(msg.value)(), "sell failed");



        uint256 balance = token.balanceOf(this);

        require(balance >= minAmount, "Price too bad");

        token.transfer(msg.sender, balance);

    }

}