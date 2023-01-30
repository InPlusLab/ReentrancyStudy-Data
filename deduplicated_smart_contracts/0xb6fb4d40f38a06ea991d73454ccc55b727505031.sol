/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.4.26;

// ----------------------------------------------------------------------------
// 'SAMPLE' token contract
//
// Symbol	  : ohyoungjoo
// Name		: model_ohyoungjoo
// Total supply: 100,000,000.000000000000000000
// Decimals	: 18
//
// Enjoy.
//
// (c) STAR BIT. 2019. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
	function add(uint a, uint b) internal pure returns (uint c) {
		c = a + b;
		require(c >= a);
	}
	function sub(uint a, uint b) internal pure returns (uint c) {
		require(b <= a);
		c = a - b;
	}
	function mul(uint a, uint b) internal pure returns (uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}
	function div(uint a, uint b) internal pure returns (uint c) {
		require(b > 0);
		c = a / b;
	}
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
	function totalSupply() public view returns (uint);
	function balanceOf(address tokenOwner) public view returns (uint balance);
	function allowance(address tokenOwner, address spender) public view returns (uint remaining);
	function transfer(address to, uint tokens) public returns (bool success);
	function approve(address spender, uint tokens) public returns (bool success);
	function transferFrom(address from, address to, uint tokens) public returns (bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from Foresting (FORE)
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
	function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
	address public owner;

	constructor(address admin) public {
		owner = admin;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	function isOwner() public view returns (bool is_owner) {
	    return msg.sender == owner;
	}
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract SAMPLE is ERC20Interface, Owned {
	using SafeMath for uint;

	string public symbol;
	string public name;
	uint8 public decimals;
	uint _totalSupply;
	bool _stopTrade;

	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;

	event Burn(address indexed burner, uint256 value);

	// ------------------------------------------------------------------------
	// Constructor
	// ------------------------------------------------------------------------
	constructor(address admin) Owned(admin) public {
		symbol = "ohyoungjoo";
		name = "model_ohyoungjoo";
		decimals = 18;
		_totalSupply = 100000000 * 10**uint(decimals);
		_stopTrade = false;
		balances[owner] = _totalSupply;
		emit Transfer(address(0), owner, _totalSupply);
	}


	// ------------------------------------------------------------------------
	// Total supply
	// ------------------------------------------------------------------------
	function totalSupply() public view returns (uint) {
		return _totalSupply.sub(balances[address(0)]);
	}


	// ------------------------------------------------------------------------
	// Stop Trade
	// ------------------------------------------------------------------------
	function stopTrade() public onlyOwner {
		require(_stopTrade != true);
		_stopTrade = true;
	}


	// ------------------------------------------------------------------------
	// Start Trade
	// ------------------------------------------------------------------------
	function startTrade() public onlyOwner {
		require(_stopTrade == true);
		_stopTrade = false;
	}


	// ------------------------------------------------------------------------
	// Get the token balance for account `tokenOwner`
	// ------------------------------------------------------------------------
	function balanceOf(address tokenOwner) public view returns (uint balance) {
		return balances[tokenOwner];
	}


	// ------------------------------------------------------------------------
	// Transfer the balance from token owner's account to `to` account
	// - Owner's account must have sufficient balance to transfer
	// - 0 value transfers are allowed
	// ------------------------------------------------------------------------
	function transfer(address to, uint tokens) public returns (bool success) {
		require(_stopTrade != true || isOwner());
		require(to > address(0));

		balances[msg.sender] = balances[msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);
		emit Transfer(msg.sender, to, tokens);
		return true;
	}


	// ------------------------------------------------------------------------
	// Token owner can approve for `spender` to transferFrom(...) `tokens`
	// from the token owner's account
	//
	// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
	// recommends that there are no checks for the approval double-spend attack
	// as this should be implemented in user interfaces
	// ------------------------------------------------------------------------
	function approve(address spender, uint tokens) public returns (bool success) {
		require(_stopTrade != true);
		require(msg.sender != spender);

		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}


	// ------------------------------------------------------------------------
	// Transfer `tokens` from the `from` account to the `to` account
	//
	// The calling account must already have sufficient tokens approve(...)-d
	// for spending from the `from` account and
	// - From account must have sufficient balance to transfer
	// - Spender must have sufficient allowance to transfer
	// - 0 value transfers are allowed
	// ------------------------------------------------------------------------
	function transferFrom(address from, address to, uint tokens) public returns (bool success) {
		require(_stopTrade != true);
		require(from > address(0));
		require(to > address(0));

		balances[from] = balances[from].sub(tokens);
		if(from != to && from != msg.sender) {
			allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		}
		balances[to] = balances[to].add(tokens);
		emit Transfer(from, to, tokens);
		return true;
	}


	// ------------------------------------------------------------------------
	// Returns the amount of tokens approved by the owner that can be
	// transferred to the spender's account
	// ------------------------------------------------------------------------
	function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
		require(_stopTrade != true);

		return allowed[tokenOwner][spender];
	}


	// ------------------------------------------------------------------------
	// Token owner can approve for `spender` to transferFrom(...) `tokens`
	// from the token owner's account. The `spender` contract function
	// `receiveApproval(...)` is then executed
	// ------------------------------------------------------------------------
	function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
		require(_stopTrade != true);
		require(msg.sender != spender);

		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
		return true;
	}


	// ------------------------------------------------------------------------
	// Don't accept ETH
	// ------------------------------------------------------------------------
	function () external payable {
		revert();
	}


	// ------------------------------------------------------------------------
	// Owner can transfer out any accidentally sent ERC20 tokens
	// ------------------------------------------------------------------------
	function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
		return ERC20Interface(tokenAddress).transfer(owner, tokens);
	}


	// ------------------------------------------------------------------------
	// Burns a specific amount of tokens.
	// ------------------------------------------------------------------------
	function burn(uint256 tokens) public {
		require(tokens <= balances[msg.sender]);
		require(tokens <= _totalSupply);

		balances[msg.sender] = balances[msg.sender].sub(tokens);
		_totalSupply = _totalSupply.sub(tokens);
		emit Burn(msg.sender, tokens);
	}
}