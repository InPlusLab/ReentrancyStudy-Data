/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

//  Current version of NEU Staking Token has an automated deflationary mechanism where 12% of 
//  each transaction is burned instantly. Mechanism enables NEU token to have an innate value-
//  creating nature where the total supply decreases until 2% of initial supply is left.  

//  Currently on preparation part of the contract will have the following functions:

//  Function-1: On the upcoming version of the NEU Staking Token burn rate will drop to 6% per 
//  transaction and another 6% of each realized transaction will be distributed among the NEU stakers. 
//  This allows NEU Staking Token to have a deflationary feature while rewarding the stakers.

//  Function-2: 1 of each 10 transactions on the network will be picked randomly where 20% of the 
//  transaction is either a burned or minted. Similar apps will be developed on top of the contract. 
//  New token contract with aforementioned functions will be released and the initial liquidity will
//  be locked.

//  Neu Staking Token Smart Contract
//  Contract Creator  : 0x8cdF50a7DdCD7b35caA2d05B133e1311CAeaecf1
//  Token Symbol      : NEU
//  Token Name        : NEU Staking
//  Total supply: 250000000
//  Decimals    : 12

pragma solidity ^0.5.13;

interface Callable {
	function tokenCallback(address _from, uint256 _tokens, bytes calldata _data) external returns (bool);
}

contract NEU {

	uint256 constant private Constant = 2**64;
	uint256 constant private Total_NEU = 25e19; // 250.000.000 Initial Supply
	uint256 constant private Burn_Ratio = 12;   // 12% burn rate for each transaction
	uint256 constant private Burn_Threshold = 2;     
	uint256 constant private Freeze_Size = 1e20; 
	
	string constant public name = "NEU Staking";
	string constant public symbol = "NEU";
	uint8 constant public decimals = 12;

	struct User {
		bool whitelisted;
		uint256 balance;
		uint256 frozen;
		mapping(address => uint256) allowance;
		int256 scaledPayout;
	}

	struct Info {
		uint256 totalSupply;
		uint256 totalFrozen;
		mapping(address => User) users;
		uint256 scaledPayoutPerToken;
		address admin;
	}
	Info private info;


	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	event Whitelist(address indexed user, bool status);
	event Freeze(address indexed owner, uint256 tokens);
	event Unfreeze(address indexed owner, uint256 tokens);
	event Collect(address indexed owner, uint256 tokens);
	event Burn(uint256 tokens);


	constructor() public {
		info.admin = msg.sender;
		info.totalSupply = Total_NEU;
		info.users[msg.sender].balance = Total_NEU;
		emit Transfer(address(0x0), msg.sender, Total_NEU);
		whitelist(msg.sender, true);
	}

	function freeze(uint256 _tokens) external {
		_freeze(_tokens);
	}

	function unfreeze(uint256 _tokens) external {
		_unfreeze(_tokens);
	}

	function collect() external returns (uint256) {
		uint256 _dividends = dividendsOf(msg.sender);
		require(_dividends >= 0);
		info.users[msg.sender].scaledPayout += int256(_dividends * Constant);
		info.users[msg.sender].balance += _dividends;
		emit Transfer(address(this), msg.sender, _dividends);
		emit Collect(msg.sender, _dividends);
		return _dividends;
	}

	function burn(uint256 _tokens) external {
		require(balanceOf(msg.sender) >= _tokens);
		info.users[msg.sender].balance -= _tokens;
		uint256 _burnedAmount = _tokens;
		if (info.totalFrozen > 0) {
			_burnedAmount /= 2;
			info.scaledPayoutPerToken += _burnedAmount * Constant / info.totalFrozen;
			emit Transfer(msg.sender, address(this), _burnedAmount);
		}
		info.totalSupply -= _burnedAmount;
		emit Transfer(msg.sender, address(0x0), _burnedAmount);
		emit Burn(_burnedAmount);
	}

	function distribute(uint256 _tokens) external {
		require(info.totalFrozen > 0);
		require(balanceOf(msg.sender) >= _tokens);
		info.users[msg.sender].balance -= _tokens;
		info.scaledPayoutPerToken += _tokens * Constant / info.totalFrozen;
		emit Transfer(msg.sender, address(this), _tokens);
	}

	function transfer(address _to, uint256 _tokens) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		return true;
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		_transfer(_from, _to, _tokens);
		return true;
	}

	function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {
		uint256 _transferred = _transfer(msg.sender, _to, _tokens);
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Callable(_to).tokenCallback(msg.sender, _transferred, _data));
		}
		return true;
	}

	function bulkTransfer(address[] calldata _receivers, uint256[] calldata _amounts) external {
		require(_receivers.length == _amounts.length);
		for (uint256 i = 0; i < _receivers.length; i++) {
			_transfer(msg.sender, _receivers[i], _amounts[i]);
		}
	}

	function whitelist(address _user, bool _status) public {
		require(msg.sender == info.admin);
		info.users[_user].whitelisted = _status;
		emit Whitelist(_user, _status);
	}


	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}

	function totalFrozen() public view returns (uint256) {
		return info.totalFrozen;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance - frozenOf(_user);
	}

	function frozenOf(address _user) public view returns (uint256) {
		return info.users[_user].frozen;
	}

	function dividendsOf(address _user) public view returns (uint256) {
		return uint256(int256(info.scaledPayoutPerToken * info.users[_user].frozen) - info.users[_user].scaledPayout) / Constant;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function isWhitelisted(address _user) public view returns (bool) {
		return info.users[_user].whitelisted;
	}

	function allInfoFor(address _user) public view returns (uint256 totalTokenSupply, uint256 totalTokensFrozen, uint256 userBalance, uint256 userFrozen, uint256 userDividends) {
		return (totalSupply(), totalFrozen(), balanceOf(_user), frozenOf(_user), dividendsOf(_user));
	}


	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {
		require(balanceOf(_from) >= _tokens);
		info.users[_from].balance -= _tokens;
		uint256 _burnedAmount = _tokens * Burn_Ratio / 100;
		if (totalSupply() - _burnedAmount < Total_NEU * Burn_Threshold / 100 || isWhitelisted(_from)) {
			_burnedAmount = 0;
		}
		uint256 _transferred = _tokens - _burnedAmount;
		info.users[_to].balance += _transferred;
		emit Transfer(_from, _to, _transferred);
		if (_burnedAmount > 0) {
			if (info.totalFrozen > 0) {
				_burnedAmount /= 2;
				info.scaledPayoutPerToken += _burnedAmount * Constant / info.totalFrozen;
				emit Transfer(_from, address(this), _burnedAmount);
			}
			info.totalSupply -= _burnedAmount;
			emit Transfer(_from, address(0x0), _burnedAmount);
			emit Burn(_burnedAmount);
		}
		return _transferred;
	}

	function _freeze(uint256 _amount) internal {
		require(balanceOf(msg.sender) >= _amount);
		require(frozenOf(msg.sender) + _amount >= Freeze_Size);
		info.totalFrozen += _amount;
		info.users[msg.sender].frozen += _amount;
		info.users[msg.sender].scaledPayout += int256(_amount * info.scaledPayoutPerToken);
		emit Transfer(msg.sender, address(this), _amount);
		emit Freeze(msg.sender, _amount);
	}

	function _unfreeze(uint256 _amount) internal {
		require(frozenOf(msg.sender) >= _amount);
		uint256 _burnedAmount = _amount * Burn_Ratio / 100;
		info.scaledPayoutPerToken += _burnedAmount * Constant / info.totalFrozen;
		info.totalFrozen -= _amount;
		info.users[msg.sender].balance -= _burnedAmount;
		info.users[msg.sender].frozen -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount * info.scaledPayoutPerToken);
		emit Transfer(address(this), msg.sender, _amount - _burnedAmount);
		emit Unfreeze(msg.sender, _amount);
	}
}