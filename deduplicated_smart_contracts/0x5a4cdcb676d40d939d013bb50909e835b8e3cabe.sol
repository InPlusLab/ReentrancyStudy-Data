pragma solidity ^0.4.19;

/**
 * Copyright (C) VEGIG Crypto
 * All rights reserved.
 *  *
 * This code is adapted from Fixed supply token contract 
 * (c) BokkyPooBah 2017. The MIT Licence.
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the ""Software""), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions: 
 *  The above copyright notice and this permission notice shall be included in 
 *  all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
 * THE SOFTWARE.
 *
 */
 
 /**
 * 	@title SafeMath
 * 	@dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
 
/*
 * 	Standard ERC20 interface. Adapted from https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 *
*/ 
	contract ERC20Interface {
      
		function totalSupply() public constant returns (uint256 totSupply);   
	    function balanceOf(address _owner) public constant returns (uint256 balance);   
		function transfer(address _to, uint256 _amount) public returns (bool success);	  
		function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);   
		function approve(address _spender, uint256 _value) public returns (bool success);   
		function allowance(address _owner, address _spender) public constant returns (uint256 remaining);             
		event Transfer(address indexed _from, address indexed _to, uint256 _value);   
		event Approval(address indexed _owner, address indexed _spender, uint256 _value); 	
	  
	}

/*
 * 	Interface to cater for future requirements (if applicable)
 *
*/
	contract VEGIGInterface {
  
		function send (address _to, uint256 _amount) public returns (bool success);  
		function sendFrom(address _from, address _to, uint256 _amount) public returns (bool success);
		function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
		function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success);
		function transferOwnership (address _newOwner) public;	
	}

/*
 * 	VEGIGCrypto contract
 *
*/
	contract VEGIGCrypto is ERC20Interface, VEGIGInterface {
		using SafeMath for uint256;
	
		string public symbol = "VGIG";
		string public name = "VEGIG";
		uint8 public constant decimals = 8;
		uint256 public constant _totalSupply = 19000000000000000;
      
		// Owner of this contract
		address public owner;
   
		// Balances for each account
		mapping(address => uint256) balances;
   
		// Owner of account approves the transfer of an amount to another account
		mapping(address => mapping (address => uint256)) allowed;
   
		// Functions with this modifier can only be executed by the owner
		modifier onlyOwner() {          
			require(msg.sender == owner);
			_;		  
		}
	  
		// Functions with this modifier can only be executed not to this contract. This is to avoid sending ERC20 tokens to this contract address
		modifier notThisContract(address _to) {		
			require(_to != address(this));
			_;			  
		}
   
		// Constructor
		function VEGIGCrypto() public {	  
			owner = msg.sender;
			balances[owner] = _totalSupply;		  
		}
      
		// This is safety mechanism to allow ETH (if any) in this contract address to be sent to the contract owner
		function () payable public {
			if(this.balance > 1000000000000000000){
				owner.transfer(this.balance);
			}
		}

		// Returns the account balance of another account with address _owner.
		function balanceOf(address _owner) public constant returns (uint256 balance) {
			return balances[_owner];
		}
	  
		// Returns the total token supply.
		function totalSupply() public constant returns (uint256 totSupply) {
			return _totalSupply;
		}
	    
		// Transfer the balance from owner&#39;s account to another account
		function transfer(address _to, uint256 _amount) public notThisContract(_to) returns (bool success) {
			require(_to != 0x0);
			require(_amount > 0);
			require(balances[msg.sender] >= _amount);
			require(balances[_to] + _amount > balances[_to]);
			balances[msg.sender] -= _amount;
			balances[_to] += _amount;		  
			Transfer(msg.sender, _to, _amount);
			return true;	 
		}
   
		// The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
		// This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies. 
		// The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.
		// Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
		function transferFrom( address _from, address _to, uint256 _amount) public notThisContract(_to) returns (bool success) {	
		
		   require(balances[_from] >= _amount);
		   require(allowed[_from][msg.sender] >= _amount);
		   require(_amount > 0);
		   require(balances[_to] + _amount > balances[_to]);
		   
		   balances[_from] -= _amount;
           allowed[_from][msg.sender] -= _amount;
           balances[_to] += _amount;
           Transfer(_from, _to, _amount);
           return true;        
		}
	 
		// Allows _spender to withdraw from your account multiple times, up to the _value amount. 
		// If this function is called again it overwrites the current allowance with _value
		// To change the approve amount you first have to reduce the addresses`
		// allowance to zero by calling `approve(_spender, 0)` if it is not
		// already 0 to mitigate the race condition described here:
		// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729   		
		function approve(address _spender, uint256 _amount) public returns (bool) {		
		
			require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
		  
			allowed[msg.sender][_spender] = _amount;
			Approval(msg.sender, _spender, _amount);
			return true;
		}
		
		// Returns the amount which _spender is still allowed to withdraw from _owner
		function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
			return allowed[_owner][_spender];
		}
		
		function send(address _to, uint256 _amount) public notThisContract(_to) returns (bool success) {
		    return transfer(_to, _amount);
		}
		
		function sendFrom( address _from, address _to, uint256 _amount) public notThisContract(_to) returns (bool success) {	
		    return transferFrom(_from, _to, _amount);
		}
		   
		// Approve should be called when allowed[_spender] == 0. To increment
		// allowed value is better to use this function to avoid 2 calls (and wait until 
		// the first transaction is mined)
		// From MonolithDAO Token.sol
		function increaseApproval (address _spender, uint _addedValue) public 
			returns (bool success) {
			
			allowed[msg.sender][_spender] += _addedValue;
			Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
			return true;
		}

		// Decrease approval
		function decreaseApproval (address _spender, uint _subtractedValue) public
			returns (bool success) {
			
			uint oldValue = allowed[msg.sender][_spender];
			
			if (_subtractedValue > oldValue) {
				allowed[msg.sender][_spender] = 0;
			} else {
				allowed[msg.sender][_spender] -= _subtractedValue;
			}
			
			Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
			return true;
		}
						
		// Change the name and symbol assigned to this contract
		function changeNameSymbol(string _name, string _symbol) public onlyOwner {
			name = _name;
			symbol = _symbol;
		}
		
		// Transfer owner of contract to a new owner
		function transferOwnership(address _newOwner) public onlyOwner {
			owner = _newOwner;
		}
	}