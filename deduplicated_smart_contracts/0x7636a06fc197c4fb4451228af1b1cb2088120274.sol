/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

pragma solidity ^0.5.10;
contract Trusti {
    string data = "trusti.id";
    
    function getStore() public view returns (string memory) {
        return data;
    }
    
    function setStore(string memory _value) public {
        data = _value;
    }
}