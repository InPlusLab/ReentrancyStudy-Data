/**

 *Submitted for verification at Etherscan.io on 2018-11-04

*/



pragma solidity ^0.4.25;



contract Charity{

    

    address public owner;

    uint256 public totalAmountDonated;

    

    constructor() public {

        owner = msg.sender;

    }

    

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);



    return c;

}

    

    function donate()payable public {

        require(msg.value > 0 ,"Please Donate at least one wei");

       owner.transfer(msg.value);

    totalAmountDonated = add(totalAmountDonated,msg.value);

    }

    

    function() payable public {

        donate();

    }

}