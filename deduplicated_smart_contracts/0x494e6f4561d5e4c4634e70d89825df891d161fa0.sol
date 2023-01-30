pragma solidity ^0.5.0;

import "./SafeMath.sol";

contract KonradToken {

	using SafeMath for uint256;

// Public variables of the token
uint32 public decimals = 18;
string public name = "Konrad Token";
string public symbol = "KDX";
uint256 public totalSupply= 1000000000 *(10**uint256(decimals)); 

mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;

address public admin;
bool transferPaused = true;
mapping(address => bool) public blacklist;
mapping(address => bool) public whitelist;

event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Approval(address indexed _owner, address indexed _spender, uint256 value);


constructor() public {
	balanceOf[msg.sender] = totalSupply;
	admin = msg.sender;
	emit Transfer(address(0),msg.sender,totalSupply);
}

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */

  function transfer(address _to, uint256 _value) transferable public returns (bool){

  	require(_to != address(0));
  	require(_value <= balanceOf[msg.sender]);
  	balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
  	balanceOf[_to] = balanceOf[_to].add(_value);
  	emit Transfer(msg.sender, _to, _value);
  	return true;
  }


/**
* Transfer tokens from other address
*
* Send `_value` tokens to `_to` on behalf of `_from`
*
* @param _from The address of the sender
* @param _to The address of the recipient
* @param _value the amount to send
*/

function transferFrom(address _from, address _to, uint256 _value) transferable public returns (bool) {
	
  	require(_to != address(0));
	require(_value <= balanceOf[_from]);
	require(_value <= allowance[_from][msg.sender]);
	allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
	balanceOf[_from] = balanceOf[_from].sub(_value);
	balanceOf[_to] = balanceOf[_to].add(_value);
	emit Transfer(_from, _to, _value);
	return true;
}

/**
* Set allowance for other address
*
* Allows `_spender` to spend no more than `_value` tokens on your behalf
*
* @param _spender The address authorized to spend
* @param _value the max amount they can spend
6
*/
function approve(address _spender, uint256 _value) public returns (bool) {
	require(!blacklist[_spender] && !blacklist[msg.sender]);
	allowance[msg.sender][_spender] = _value;
	emit Approval(msg.sender, _spender, _value);
	return true;

}

function burn(uint256 _value) public returns (bool) {
	require(!blacklist[msg.sender]);
	require(balanceOf[msg.sender] >= _value);
	balanceOf[msg.sender] =balanceOf[msg.sender].sub(_value);
	totalSupply = totalSupply.sub(_value);
	emit Burn(msg.sender, _value);
	return true;
}


/**
* @dev Ban address
*
* @param addr ban addr
*/
function addToBlacklist(address addr) public {
	require(msg.sender == admin);
	blacklist[addr] = true;
}
/**
* @dev Enable address
*
* @param addr enable addr
*/
function removeFromBlacklist(address addr) public {
	require(msg.sender == admin);
	blacklist[addr] = false;
}

function addToWhitelist(address addr) public {
	require(msg.sender == admin);
	whitelist[addr] = true;
}
function removeFromWhitelist(address addr) public {
	require(msg.sender == admin);
	whitelist[addr] = false;
}


// The modifier checks if the address can send tokens 
modifier transferable(){
	require(!transferPaused || whitelist[msg.sender] || msg.sender == admin);
	require(!blacklist[msg.sender]);
	_;
}

// Unpause token transfer
function unpauseTransfer() public {
	require(msg.sender == admin);
	transferPaused = false;
}

// transfer ownership of the contract
function transferOwnership(address newOwner) public {
	require(msg.sender == admin);
	admin = newOwner;
} 

}