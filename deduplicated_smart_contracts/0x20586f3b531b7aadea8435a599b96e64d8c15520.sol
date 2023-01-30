/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

pragma solidity ^0.4.26;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);
	
	function allowance(address _owner, address _spender) external view returns (uint256);
	
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
	
    function approve(address _spender, uint256 _value) external returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	
}

contract StandardToken is IERC20 {
    using SafeMath for uint256;

	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowed;

	uint256 private _totalSupply;
	string private _name;
	string private _symbol;
	uint8 private _decimals = 18;
	
	 constructor(
        uint256 totalSupply,
        string name,
        string symbol,
        uint8 decimals
    )  public {
        _totalSupply = totalSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _totalSupply;
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
	
	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}
	
	function name() public view returns (string) {
		return _name;
	}
	
	function symbol() public view returns (string) {
		return _symbol;
	}
	
	function decimals() public view returns (uint8) {
		return _decimals;
	}
	
	function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }
	
	function allowance(address _owner, address _spender) public view returns (uint256) {
		return _allowed[_owner][_spender];
	}
	
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= _balances[msg.sender]);

		_balances[msg.sender] = _balances[msg.sender].sub(_value);
		_balances[_to] = _balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}
  
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= _balances[_from]);
		require(_value <= _allowed[_from][msg.sender]);

		_balances[_from] = _balances[_from].sub(_value);
		_balances[_to] = _balances[_to].add(_value);
		_allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		require(_spender != address(0));
		_allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
		require(_spender != address(0));
		_allowed[msg.sender][_spender] = _allowed[msg.sender][_spender].add(_addedValue);
		emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
		require(_spender != address(0));
		_allowed[msg.sender][_spender] = _allowed[msg.sender][_spender].sub(_subtractedValue);
		emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
		return true;
	}

}