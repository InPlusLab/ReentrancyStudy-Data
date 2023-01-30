/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

// FIREDATE - Starcrossed lovers meet here

pragma solidity ^0.4.11;

contract Token {
/* This is a slight change to the ERC20 base standard.
function totalSupply() constant returns (uint256 supply);
is replaced with:
uint256 public totalSupply;
This automatically creates a getter function for the totalSupply.
This is moved to the base contract since public getter functions are not
currently recognised as an implementation of the matching abstract
function by the compiler.
*/
/// total amount of tokens
uint256 public totalSupply;

/// @param _owner The address from which the balance will be retrieved
/// @return The balance
function balanceOf(address _owner) public constant returns (uint256 balance);

/// @notice send '_value' token to '_to' from 'msg.sender'
/// @param _to The address of the recipient
/// @param _value The amount of token to be transferred
/// @return Whether the transfer was successful or not
function transfer(address _to, uint256 _value) public returns (bool success);

/// @notice send '_value' token to '_to' from '_from' on the condition it is approved by '_from'
/// @param _from The address of the sender
/// @param _to The address of the recipient
/// @param _value The amount of token to be transferred
/// @return Whether the transfer was successful or not
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

/// @notice 'msg.sender' approves '_spender' to spend '_value' tokens
/// @param _spender The address of the account able to transfer the tokens
/// @param _value The amount of tokens to be approved for transfer
/// @return Whether the approval was successful or not
function approve(address _spender, uint256 _value) public returns (bool success);

/// @param _owner The address of the account owning tokens
/// @param _spender The address of the account able to transfer the tokens
/// @return Amount of remaining tokens allowed to spent
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract SafeMath {

/* function assert(bool assertion) internal { */
/*   if (!assertion) { */
/*     revert(); */
/*   } */
/* }      // assert no longer needed once solidity is on 0.4.10 */

function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
uint256 z = x + y;
assert((z >= x) && (z >= y));
return z;
}

function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
assert(x >= y);
uint256 z = x - y;
return z;
}

function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
uint256 z = x * y;
assert((x == 0)||(z/x == y));
return z;
}

}

contract StandardToken is Token {

function transfer(address _to, uint256 _value) public returns (bool success) {
//Default assumes totalSupply can't be over max (2^256 - 1).
//If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
//Replace the if with this one instead.
//if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}

function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
//same as above. Replace this line with the following if you want to protect against wrapping uints.
//if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
} else { return false; }
}

function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}

function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}

function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}

mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}

contract FIREDATE is StandardToken, SafeMath {

// metadata
string public constant name = "FIREDATE";
string public constant symbol = "🔥"; // FIRE emoji
uint256 public constant decimals = 0; // Whole tokens only
string public version = "1.0";

// important addresses
address public depositAddress;      // deposit address for ETH for ICO owner

// crowdsale params
bool public isFinalized;            // true when ICO finalized and successful
uint256 public targetEth;           // target ETH to raise
uint256 public fundingStartBlock;   // when to start allowing funding
uint256 public fundingEndBlock;     // when to stop allowing funding

// events
event CreateFiredate(string _name);
event Contribute(address _sender, uint256 _value);
event FinalizeSale(address _sender);
event RefundContribution(address _sender, uint256 _value);
event ClaimTokens(address _sender, uint256 _value);

// calculated values
mapping (address => uint256) contributions;    // ETH contributed per address
uint256 contributed;      // total ETH contributed

// constructor
function Firedate() public{
isFinalized = false;
totalSupply = 21040868;
targetEth = 888 * 1000000000000000000; // Raising 888 ETHER
depositAddress = 0x509613c84672B7cef3c0838243134b5B02Df0365;
fundingStartBlock = 8848888;
fundingEndBlock = 8888888;
// log
emit CreateFiredate(name);}

/// Accepts ETH from a contributor
function contribute() payable external {
if (block.number < fundingStartBlock) revert();    // not yet begun?
if (block.number > fundingEndBlock) revert();      // already ended?
if (msg.value == 0) revert();                  // no ETH sent in?

// Add to contributions
contributions[msg.sender] += msg.value;
contributed += msg.value;

// log
emit Contribute(msg.sender, msg.value);  // logs contribution
}

/// Finalizes the funding and sends the ETH to deposit address
function finalizeFunding() external {
if (isFinalized) revert();                       // already succeeded?
if (msg.sender != depositAddress) revert();      // wrong sender?
if (block.number <= fundingEndBlock) revert();   // not yet finished?
if (contributed < targetEth) revert();             // not enough raised?

isFinalized = true;

// send to deposit address
if (!depositAddress.send(targetEth)) revert();

// log
emit FinalizeSale(msg.sender);
}

/// Allows contributors to claim their tokens and/or a refund. If funding failed then they get back all their Ether, otherwise they get back any excess Ether
function claimTokensAndRefund() external {
if (0 == contributions[msg.sender]) revert();    // must have previously contributed
if (block.number < fundingEndBlock) revert();    // not yet done?

// if not enough funding
if (contributed < targetEth) {
// refund my full contribution
if (!msg.sender.send(contributions[msg.sender])) revert();
emit RefundContribution(msg.sender, contributions[msg.sender]);
} else {
// calculate how many tokens I get
balances[msg.sender] = safeMult(totalSupply, contributions[msg.sender]) / contributed;
// refund excess ETH
if (!msg.sender.send(contributions[msg.sender] - (safeMult(targetEth, contributions[msg.sender]) / contributed))) revert();
emit ClaimTokens(msg.sender, balances[msg.sender]);
}

contributions[msg.sender] = 0;
}
}