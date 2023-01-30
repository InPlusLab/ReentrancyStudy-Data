/**
 *Submitted for verification at Etherscan.io on 2019-10-17
*/

pragma solidity  ^0.5.12;

contract MyTokenPublic{
    
    mapping (address => uint256) public banlanceOf;
    
    constructor (uint256 initialSupply)  public {
        banlanceOf[msg.sender] = initialSupply;
    }
    
    function transfer(address _to,uint256 _value) public {
        
        require(banlanceOf[msg.sender] >= _value);
        
        require(banlanceOf[_to] + _value >= banlanceOf[_to]);
        
        banlanceOf[msg.sender] -= _value;
        
        banlanceOf[_to] += _value;
    }
}