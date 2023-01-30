/**
 *Submitted for verification at Etherscan.io on 2020-12-13
*/

/*
	CorionX sender contract
	corionXSender.sol
	v0.0.1
	Author: Andor 'iFA' Rajci - https://www.fusionsolutions.io
*/
pragma solidity 0.4.26;
/* Imports */

/* Libraries */

/* Contracts */
contract ERC20Interface {
	function transfer(address _to, uint256 _value) public returns (bool) {}
	function balanceOf(address _owner) public view returns (uint256) {}
}
contract CorionXLocker {
	/* Libraries */
	
	/* Structures */
	
	/* Variables */
	ERC20Interface public constant CORIONX = ERC20Interface(0x26a604DFFE3ddaB3BEE816097F81d3C4a2A4CF97);
	address        public          owner;
	
	/* Connstructor */
	constructor(address _owner) {
		require( _owner != 0x00 );
		owner = _owner;
	}
	
	/* Modifiers */
	modifier forOwner { require( msg.sender == owner ); _; }
	
	/* Fallback */
	
	/* Externals */
	function replaceOwner(address _owner) forOwner external returns(bool)  {
		owner = _owner;
		return true;
	}
	function send(address[] addresses, uint256[] amounts) forOwner external {
	    require( addresses.length == amounts.length && addresses.length > 0 );
	    for ( uint256 i=0 ; i < addresses.length ; i++ ) {
	        require( CORIONX.transfer(addresses[i], amounts[i]) );
	    }
	}
	
	/* Constants */
	function balanceOf() constant returns (uint256) {
		return CORIONX.balanceOf(address(this));
	}
	
	/* Internals */
	
	/* Privates */
	
	/* Events */
}