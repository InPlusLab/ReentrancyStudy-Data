/**
 *Submitted for verification at Etherscan.io on 2019-07-27
*/

pragma solidity ^ 0.5 .1;

interface tokenRecipient {
	function receiveApproval(address from, uint256 value, address token, bytes calldata extraData) external;
}


contract ERC20Token {
	string private _name;

	function name() public view returns(string memory) {
		return _name;
	}
	string private _symbol;

	function symbol() public view returns(string memory) {
		return _symbol;
	}
	uint8 private _decimals = 18;

	function decimals() public view returns(uint8) {
		return _decimals;
	}
	// 18 decimals is the strongly suggested default, avoid changing it
	uint256 public _totalSupply;

	function totalSupply() public view returns(uint256) {
		return _totalSupply;
	}
	//账户与代币数量的映射
	// This creates an array with all balances
	mapping(address => uint256) public _balanceOf;

	function balanceOf(address _owner) public view returns(uint256 balance) {
		return _balanceOf[_owner];
	}

	//授权
	mapping(address => mapping(address => uint256)) public _allowance;

	//定义事件 转账事件
	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);
	//定义事件 授权事件
	// This generates a public event on the blockchain that will notify clients
	event Approval(address indexed owner, address indexed spender, uint256 value);
	//定义事件 
	// This notifies clients about the amount burnt
	event Burn(address indexed from, uint256 value);

	/**
	 * Constructor function
	 *
	 * Initializes contract with initial supply tokens to the creator of the contract
	 */
	constructor(
		uint256 initialSupply,
		string memory tokenName,
		string memory tokenSymbol
	) public {
		_totalSupply = initialSupply * 10 ** uint256(_decimals); // Update total supply with the decimal amount
		//一开始，代币都在合约拥有者手里
		_balanceOf[msg.sender] = _totalSupply; // Give the creator all initial tokens
		_name = tokenName; // Set the name for display purposes
		_symbol = tokenSymbol; // Set the symbol for display purposes
	}

	//内部方法
	function _transfer(address from, address to, uint value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(to != address(0x0)); //断言，不能给一个空地址转代币
		// Check if the sender has enough
		require(_balanceOf[from] >= value); //转出者必须拥有的代币数量必须大于等于转出的数量
		// Check for overflows
		require(_balanceOf[to] + value >= _balanceOf[to]); //这里的技巧在于考虑到了数据的溢出
		// Save this for an assertion in the future
		uint previousBalances = _balanceOf[from] + _balanceOf[to]; //转出者和转入者的总量
		// Subtract from the sender
		_balanceOf[from] -= value; //转出
		// Add the same to the recipient
		_balanceOf[to] += value; //转入
		//提交事件
		emit Transfer(from, to, value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(_balanceOf[from] + _balanceOf[to] == previousBalances); //他们之间转账以后总量肯定是不变的
	}


	//公开方法
	function transfer(address to, uint256 value) public returns(bool success) {
		_transfer(msg.sender, to, value);
		return true;
	}


	function transferFrom(address from, address to, uint256 value) public returns(bool success) {
		//不能超额转账
		require(value <= _allowance[from][msg.sender]); // Check allowance
		//减去授权的额度
		_allowance[from][msg.sender] -= value;
		//转账
		_transfer(from, to, value);
		return true;
	}


	function approve(address spender, uint256 value) public
	returns(bool success) {
		//授权额度，至于它有没有这么额度，它不管，因为转账的时候会有数量判断，这里不用关心
		_allowance[msg.sender][spender] = value;
		//提交授权事件
		emit Approval(msg.sender, spender, value);
		return true;
	}

	function approveAndCall(address spender, uint256 value, bytes memory extraData) public returns(bool success) {
		tokenRecipient _spender = tokenRecipient(spender);
		if (approve(spender, value)) {
			_spender.receiveApproval(msg.sender, value, address(this), extraData);
			return true;
		}
	}

	function burn(uint256 value) public returns(bool success) {
		require(_balanceOf[msg.sender] >= value); // Check if the sender has enough
		_balanceOf[msg.sender] -= value; // Subtract from the sender
		_totalSupply -= value; // Updates totalSupply
		//提交事件
		emit Burn(msg.sender, value);
		return true;
	}

	function burnFrom(address from, uint256 value) public returns(bool success) {
		require(_balanceOf[from] >= value); // Check if the targeted balance is enough
		require(value <= _allowance[from][msg.sender]); // Check allowance
		_balanceOf[from] -= value; // Subtract from the targeted balance
		_allowance[from][msg.sender] -= value; // Subtract from the sender's allowance
		_totalSupply -= value; // Update totalSupply
		//提交事件
		emit Burn(from, value);
		return true;
	}

}