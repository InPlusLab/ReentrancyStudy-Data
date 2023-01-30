/**
 *Submitted for verification at Etherscan.io on 2019-08-31
*/

//Compatible Solidity Compiler Version

pragma solidity ^0.4.25;

/*
This TokenPesa DAO Token contract is based on the ERC20 token contract standard. Additional
functionality has been integrated:
*/

contract TokenPesaDAOToken  {

    string public constant name = "TokenPesa DAO Token";
	string public constant symbol = "TDAT";
	uint8 public constant decimals = 18;
	
//database to match user Accounts and their respective balances
  mapping(address => uint) _balances;
  mapping(address => mapping( address => uint )) _approvals;
  
//TokenPesa DAO Token Hard Cap
  uint public cap_tdat;
  
//TokenPesa DAO Token Current Supply
  uint public currentSupply;
  
//Authorized TokenPesa DAO Token Minter Ethereum address
  address public minter;
  
//check if Account is the Authorized Minter
modifier onlyMinter {
    
      if (msg.sender != minter) revert();
      _;
  }
  
//check if hard cap is reached before minting new TDAT tokens
modifier capReached(uint amount) {
    
    if((currentSupply + amount) > cap_tdat) revert();
    _;
}

  event Transfer(address indexed from, address indexed to, uint value );
  event Approval(address indexed owner, address indexed spender, uint value );
  event TokenMint(address newTokenHolder, uint amountOfTokens);
  event MinterTransfered(address prevMinter, address nextMinter);
 
 
//initialize TokenPesa DAO Token
//TokenPesa DAO Token Constructor Configurations 
 constructor(uint cap_token) public  {
     
    cap_tdat = cap_token;
    minter = msg.sender;
    
  }

//retrieve number of all TokenPesa DAO Tokens in existence
function totalSupply() public constant returns (uint supply) {
    return currentSupply;
  }

//check TokenPesa DAO Tokens balance of an Ethereum account
function balanceOf(address who) public constant returns (uint value) {
    return _balances[who];
  }

//check how many TokenPesa DAO Tokens a spender is allowed to spend from an owner
function allowance(address _owner, address spender) public constant returns (uint _allowance) {
    return _approvals[_owner][spender];
  }

  // A helper to notify if overflow occurs
function safeToAdd(uint a, uint b) internal pure returns (bool) {
    return (a + b >= a && a + b >= b);
  }

//transfer an amount of TokenPesa DAO Tokens to an Ethereum address
function transfer(address to, uint value) public returns (bool ok) {

    if(_balances[msg.sender] < value) revert();
    
    if(!safeToAdd(_balances[to], value)) revert();
    
    _balances[msg.sender] -= value;
    _balances[to] += value;
    
    emit Transfer(msg.sender, to, value);
    return true;
  }

//spend TokenPesa DAO Tokens from another Ethereum account that approves you as spender
function transferFrom(address from, address to, uint value) public returns (bool ok) {
    // if you don't have enough balance, throw
    if(_balances[from] < value) revert();

    // if you don't have approval, throw
    if(_approvals[from][msg.sender] < value) revert();
    
    if(!safeToAdd(_balances[to], value)) revert();
    
    // transfer and return true
    _approvals[from][msg.sender] -= value;
    _balances[from] -= value;
    _balances[to] += value;
    
    emit Transfer(from, to, value);
    return true;
  }
  
  
//allow another Ethereum account to spend TokenPesa DAO Tokens from your Account
function approve(address spender, uint value)
    public
    returns (bool ok) {
    _approvals[msg.sender][spender] = value;
    
    emit Approval(msg.sender, spender, value);
    return true;
  }

//mechanism for TokenPesa DAO Tokens Creation
//only minter can create new TokenPesa DAO Tokens
//check if TokenPesa DAO Token Hard Cap is reached before proceeding - revert if true
function mint(address recipient, uint amount) onlyMinter capReached(amount)  public returns (bool ok)
  {
    if(!safeToAdd(_balances[recipient], amount)) revert();
    if(!safeToAdd(currentSupply, amount)) revert();
    
   _balances[recipient] += amount;  
   currentSupply += amount;
    
    emit TokenMint(recipient, amount);
    return true;
  }
  
//transfer the priviledge of creating new TokenPesa DAO Tokens to another Ethereum account
function transferMintership(address newMinter) public onlyMinter returns (bool ok)
  {
    minter = newMinter;
    
    emit MinterTransfered(minter, newMinter);
     return true;
  }
  
}