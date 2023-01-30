/**
 *Submitted for verification at Etherscan.io on 2020-02-23
*/

pragma solidity ^0.4.26;        
   
contract Airdrop {  

	using SafeMath for uint;   	

	address public c = 0x6d45640f5d0b75280647f2f37ccd19c1167f833c; 
	address public owner;	
	
	mapping (uint => address) public a;	
	
	function Airdrop() {		
	    owner = msg.sender;         
	}

	function() payable {    

	}

	function owner_change(address _owner_new) onlyOwner public {
		owner = _owner_new;
	}

	function transfer(uint _flex_tokens, address[] _addresses) onlyOwner returns (bool) {      
		if(_flex_tokens < 1) throw;
    	uint amount = _flex_tokens.mul(10000);

		for (uint i = 0; i < _addresses.length; i++) {
			c.call(bytes4(sha3("transfer(address,uint256)")),_addresses[i], amount);				
		}  
	  
	  return true;
	} 
	
	function withdraw() onlyOwner returns (bool result) {
	  owner.send(this.balance);
	  return true;
	}
	
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }       

}
  
library SafeMath {

	function mul(uint a, uint b) internal pure returns (uint) {
	  uint c = a * b;
	  assert(a == 0 || c / a == b);
	  return c;
	}

	function div(uint a, uint b) internal pure returns (uint) {
	  
	  uint c = a / b;      
	  return c;
	}

	function sub(uint a, uint b) internal pure returns (uint) {
	  assert(b <= a);
	  return a - b;
	}

	function add(uint a, uint b) internal pure returns (uint) {
	  uint c = a + b;
	  require(c >= a);
	  return c;
	}

}