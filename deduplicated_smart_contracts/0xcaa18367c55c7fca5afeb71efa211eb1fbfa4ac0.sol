/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity ^0.4.25;





contract BonusBank {

    address public owner;

    uint public limit;

    modifier isOwner() {

        require(msg.sender == owner);

        _;

    }



    

    event Deposit(address indexed from, uint value);



   

    function limitvalue(uint _limit) public {

        require(_limit > 0);



        owner = msg.sender;

        limit = _limit ;

    }



   

    function deposit() public payable {

        Deposit(msg.sender, msg.value);

    }



    function canDistribution() public constant returns (bool) {

        return this.balance >= limit;

    }

    

    function getCurrentBalance() constant returns (uint) {

        return this.balance;

    }

    

    function distribution() public isOwner {

        require(canDistribution());



        owner.transfer(this.balance);

    }



   

}