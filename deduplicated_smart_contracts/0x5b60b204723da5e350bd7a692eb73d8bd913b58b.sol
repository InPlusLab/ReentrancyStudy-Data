/**
 *Submitted for verification at Etherscan.io on 2020-03-31
*/

pragma solidity ^0.4.25;
contract tocpkToken {
    
    string public name = "test one coin pbank";
    string public symbol = "tocpk";
    uint8 public decimals = 19;

    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function tocpkToken() public{
        balanceOf[msg.sender] = 200000000 * 10 ** uint256(decimals);
    }


    function transfer(address _to, uint256 _value) public{
      
        if (balanceOf[msg.sender] < _value) require(balanceOf[msg.sender] < _value);
        if (balanceOf[_to] + _value < balanceOf[_to]) require(balanceOf[msg.sender] < _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
    }
}