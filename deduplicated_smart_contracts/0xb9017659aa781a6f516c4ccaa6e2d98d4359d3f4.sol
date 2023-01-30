/**

 *Submitted for verification at Etherscan.io on 2019-04-27

*/



pragma solidity ^0.4.24;



contract TandaPayDemo {

    

    uint public tandaBalance;

    address secretary;

    mapping(address=>bool) public policyholders;

    

    constructor() {

        secretary =  msg.sender;

    }

    

    function() payable { payPremium(); }

    

    function payPremium()

        public payable returns (bool)

    {

        require(msg.value >= .0001 ether);

        if(!policyholders[msg.sender]){

            policyholders[msg.sender] = true;

        }

        tandaBalance += msg.value;

        return true;

    }

    

    function sendClaim(address claimant, uint claimAmount) {

        require(msg.sender == secretary);

        require(claimAmount <= tandaBalance);

        require(policyholders[claimant]);

        claimant.transfer(claimAmount);

    }

    

}