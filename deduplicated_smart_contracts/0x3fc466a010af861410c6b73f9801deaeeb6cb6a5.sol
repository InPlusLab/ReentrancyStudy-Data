/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

pragma solidity >=0.4.21;

contract ERC20Interface {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint public totalSupply;
 // function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  function decreaseSupply(uint value, address from) public;
  function safeSub(uint a, uint b) internal returns (uint);
    
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract ERC20 is ERC20Interface {
    
  constructor(uint256 initialSupply) public{
    name="c4";
    symbol="c4";
    decimals=4;
    totalSupply=initialSupply * 10 ** uint256(decimals);
    balanceOf[msg.sender] = totalSupply;
  }
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) internal allowed;

//   function balanceOf(address _owner) public view returns (uint256 balance){
//     return balances[_owner];
//   }
  function transfer(address _to, uint256 _value) public returns (bool success){
    require(_to != address(0));
    require(balanceOf[msg.sender] >= _value);
    require(balanceOf[_to]+_value >= balanceOf[_to]);
    require(_value>=100);
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += (_value*99/100);
    decreaseSupply(_value/100,msg.sender);
    emit Transfer(msg.sender, _to, _value*99/100);
    success= true;
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
    require(_to != address(0));
    require(balanceOf[_from] >= _value);
    require(allowed[_from][msg.sender] >= _value);
    require(balanceOf[_to] + _value >= balanceOf[_to]);
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(_from, _to, _value);
    success= true;
  }
  function approve(address _spender, uint256 _value) public returns (bool success){
    allowed[msg.sender][_spender]= _value;
    emit Approval(msg.sender, _spender, _value);
    success= true;
  }
  function allowance(address _owner, address _spender) public view returns (uint256 remaining){
    return allowed[_owner][_spender];
  }
  function decreaseSupply(uint value, address from) public {
    totalSupply = safeSub(totalSupply, value);
   emit Transfer(from, address(0), value);
  }

function safeSub(uint a, uint b) internal returns (uint) {
    require(a >= b);
    return a - b;
}
}