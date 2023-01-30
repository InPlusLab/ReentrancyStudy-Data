/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

/*
	CorionX token locker contract
	corionLocker.sol
	v0.3.0
	Author: Andor 'iFA' Rajci - https://www.fusionsolutions.io
*/
pragma solidity 0.4.26;
/* Imports */

/* Libraries */
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if ( a == 0 || b == 0 ) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
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

/* Contracts */
contract ERC20Interface {
	function transfer(address _to, uint256 _value) public returns (bool) {}
	function balanceOf(address _owner) public view returns (uint256) {}
}
contract CorionLocker {
	/* Libraries */
	using SafeMath for uint256;
	
	/* Structures */
	
	/* Variables */
	ERC20Interface public constant CORION      = ERC20Interface(0x26a604DFFE3ddaB3BEE816097F81d3C4a2A4CF97);
	uint8                 constant BLOCK_DELAY = 14;
	uint32         public constant PART_DELAY  = uint32( uint256(60).mul(60).mul(24).mul(365).div(4).div(BLOCK_DELAY) );
	address        public          owner;
	string         public          name;
	uint256        public          totalAmount;
	uint256        public          amountPaid;
	uint256        public          partAmount;
	uint32         public          startBlock;
	uint8          public          parts;
	
	/* Connstructor */
	constructor(address _owner, uint8 _parts, string _name) {
		require( _owner != 0x00 && _parts != 0 );
		owner = _owner;
		name = _name;
		parts = _parts;
	}
	
	/* Modifiers */
	modifier forOwner { require(msg.sender == owner); _; }
	modifier beforeInitialization { require( startBlock == 0); _; }
	modifier afterInitialization { require( startBlock > 0); _; }
	
	/* Fallback */
	
	/* Externals */
	function init(uint8 _shiftParts) forOwner beforeInitialization external {
		startBlock = uint32(block.number);
		if ( _shiftParts > 0 ) {
			startBlock += PART_DELAY * _shiftParts;
		}
		totalAmount = CORION.balanceOf(address(this));
		partAmount = totalAmount.div( uint256(parts) );
		require( totalAmount > 0 );
	}
	function withdraw() forOwner afterInitialization external {
		uint256 payAmount = this.calculateAmount();
		require( payAmount > 0 );
		bool success = CORION.transfer(owner, payAmount);
		require( success );
		emit Paid(payAmount);
		amountPaid = amountPaid.add(payAmount);
	}
	
	/* Constants */
	function calculateAmount() constant returns (uint256 amount) {
		amount = _calculateAmount();
		if ( amount == 0 || amount == amountPaid ) {
			return 0;
		}
		return amount.sub(amountPaid);
	}
	
	/* Internals */
	function _calculateAmount() internal view returns (uint256 amount) {
		if ( startBlock == 0 || startBlock >= block.number) {
			return 0;
		}
		uint256 partsToPay = uint256((block.number - startBlock) / PART_DELAY);
		if ( partsToPay == 0 ) {
			return 0;
		}
		else if ( partsToPay >= parts ) {
			return totalAmount;
		}
		return partsToPay.mul(partAmount);
	}
	
	/* Privates */
	
	/* Events */
	event Paid(uint256 amount);
}