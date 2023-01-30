/**

 *Submitted for verification at Etherscan.io on 2018-09-13

*/



pragma solidity 0.4.24;

contract CoinbaseTest {

    address owner;

    

    constructor() public {

        owner = msg.sender;

    }

    

    function () public payable {

    }

    

    function withdraw() public {

        require(msg.sender == owner);

        msg.sender.transfer(this.balance);

    }



}