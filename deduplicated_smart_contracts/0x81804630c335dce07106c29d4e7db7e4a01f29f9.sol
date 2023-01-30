/**
 *Submitted for verification at Etherscan.io on 2019-08-31
*/

pragma solidity >=0.4.22 <0.6.0;
contract Lobster {

    address private owner;
    string private flag;
    
    constructor () public {
        owner = msg.sender;
    }
    
    function getFlag() public view returns (string memory) {
        require(msg.sender == owner);
        return flag;
    }
    
}