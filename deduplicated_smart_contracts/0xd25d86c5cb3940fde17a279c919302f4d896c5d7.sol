/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

pragma solidity ^0.5.16;

contract ERC20Basic {

    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);

    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    function setTotalSupply(uint256 _value) public returns (uint totalSupply);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract MyERC20 is ERC20Basic {

    string public  name;
    string public  symbol;
    uint8 public constant decimals = 18;
    uint public totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) public {
       name = _name;
       symbol = _symbol;
       totalSupply = setTotalSupply(_initialSupply);
       _balances[msg.sender] = totalSupply;
    }

    function setTotalSupply(uint256 _value) public returns (uint total) {
        return _value * 10 ** uint256(decimals);
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
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

    function transfer(address _to, uint256 _value)  public returns (bool success) {
        require(_to != address(0));
        require(_balances[msg.sender] >= _value);
        require(_balances[ _to] + _value >= _balances[ _to]);
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
    }

}