/**
 *Submitted for verification at Etherscan.io on 2019-12-03
*/

pragma solidity ^0.4.17;

contract MokaNetwork {
    string public name ="Moka Network";
    string public symbol ="MOKA";
    uint8 public decimals = 18; // 1.003 -> 3
    uint256 public totalSupply = 8000000000;
    
    mapping(address=>uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function() public payable {
        balances[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
    }

}