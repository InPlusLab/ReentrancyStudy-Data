/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.10;

contract test {
    int _multiplier;
    
    event Set(
        int indexed newmult);
    
    constructor (int multiplier) public {
        _multiplier = multiplier;
    }

    function multiply(int val) public view returns (int d) {
        return val * _multiplier;
    } 
    
    function setnew(int multiplier) public {
        _multiplier = multiplier;
        emit Set(_multiplier);
    }
}