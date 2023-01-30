pragma solidity >=0.4.22 <0.7.0;

import './erc20interface.sol';

contract ERC20 is ERC20Interface {

    string public  name;
    string public  symbol;
    uint8 public constant decimals = 18;
    uint public totalSupply;
    uint public initialSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(string memory _name, string memory _symbol) public {
       name = _name;
       symbol = _symbol;
       initialSupply = 5000000000;
       totalSupply = initialSupply ** uint256(decimals);
       _balances[msg.sender] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }

  function transfer(address _to, uint256 _value)  public returns (bool success) {
      require(_to != address(0));
      require(_balances[msg.sender] >= _value);
      require(_balances[ _to] + _value >= _balances[ _to]);


      _balances[msg.sender] -= _value;
      _balances[_to] += _value;

      emit Transfer(msg.sender, _to, _value);

      return true;
  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      require(_to != address(0));
      require(allowed[_from][msg.sender] >= _value);
      require(_balances[_from] >= _value);
      require(_balances[ _to] + _value >= _balances[ _to]);

      _balances[_from] -= _value;
      _balances[_to] += _value;

      allowed[_from][msg.sender] -= _value;

      emit Transfer(msg.sender, _to, _value);
      return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;

      emit Approval(msg.sender, _spender, _value);
      return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

}
