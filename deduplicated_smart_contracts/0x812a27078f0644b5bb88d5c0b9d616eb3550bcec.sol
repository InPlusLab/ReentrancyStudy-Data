/**
 *Submitted for verification at Etherscan.io on 2020-04-05
*/

pragma solidity ^0.5.7;

contract ERC20 {
   //core ERC20 functions
  function allowance(address _owner, address _spender) public view returns (uint remaining);
  function approve(address _spender, uint _value)  public returns (bool success);
  function balanceOf(address _owner) public view returns (uint balance);
  function totalSupply() public view returns (uint);
  function transfer(address _to, uint _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);
// logging events
  event Approval(address indexed _owner, address indexed _spender, uint _value);
  event Transfer(address indexed _from, address indexed _to, uint  _value);
}

contract Transfer  {
    ERC20 public token;
    uint public balance = 0;
    address public owner;
    constructor (address _tokenAddress) public {
        owner = msg.sender;
        token = ERC20(_tokenAddress);
    }

    function() payable external {
        balance += msg.value;
    }

    function transferETH(address payable _to, uint256 _value) public onlyOwner returns (bool){
        _to.transfer(_value);
        return true;
    }

    function transferEth2Many(address payable[] memory _receivers, uint[] memory _values) public onlyOwner returns (bool) {
        require(_receivers.length == _values.length && _receivers.length >= 1);
        for (uint j = 0; j < _receivers.length; j++) {
            _receivers[j].transfer(_values[j]);
        }
        return true;
    }

    function totalSupply() public view returns (uint) {
        return token.totalSupply();
    }

    function balanceOf(address who) public view returns (uint) {
        return token.balanceOf(who);
    }

    function allowance(address _owner, address _spender) public view returns (uint){
        return token.allowance(_owner, _spender);
    }

    function approve(address _spender, uint _value) public returns (bool success){
        return token.approve(_spender, _value);
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        return token.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        return token.transferFrom(_from, _to, _value);
    }

    function TransferOne2Many(address[] memory _receivers, uint[] memory _values) public onlyOwner returns (bool) {
        require(_receivers.length == _values.length && _receivers.length >= 1);
        for (uint j = 0; j < _receivers.length; j++) {
            token.transfer(_receivers[j], _values[j]);
        }
        return true;
    }

    function TransferFromOne2Many(address _from, address[] memory _receivers, uint[] memory _values) public onlyOwner returns (bool) {
        require(_receivers.length == _values.length && _receivers.length >= 1);
        for (uint j = 0; j < _receivers.length; j++) {
            token.transferFrom(_from, _receivers[j], _values[j]);
        }
        return true;
    }
    
    function TransferFromMany2one(address[] memory _froms, address _receiver, uint[] memory _values) public onlyOwner returns (bool) {
        require(_froms.length == _values.length && _froms.length >= 1);
        for (uint j = 0; j < _froms.length; j++) {
            token.transferFrom(_froms[j], _receiver, _values[j]);
        }
        return true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}