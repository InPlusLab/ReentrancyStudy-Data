/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

pragma solidity ^0.4.25;
contract javaComssion {
    uint256 value;
    function multipleOutputs (address address1, address address2, uint256 amt1, uint256 amt2) public payable {
       
        address1.transfer(amt1);
        address2.transfer(amt2);
       
    }
   
}