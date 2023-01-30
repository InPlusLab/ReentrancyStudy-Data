/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity 0.5.9;

// File: contracts/FrozenToken.sol

/**
 * Source Code first verified at https://etherscan.io on Wednesday, October 11, 2017
 (UTC) */

//! FrozenToken ECR20-compliant token contract
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.5.0;

// Owned contract.
contract Owned {
	modifier only_owner { require (msg.sender == owner, "Only owner"); _; }

	event NewOwner(address indexed old, address indexed current);

	function setOwner(address _new) public only_owner { emit NewOwner(owner, _new); owner = _new; }

	address public owner;
}

// FrozenToken, a bit like an ECR20 token (though not - as it doesn't
// implement most of the API).
// All token balances are generally non-transferable.
// All "tokens" belong to the owner (who is uniquely liquid) at construction.
// Liquid accounts can make other accounts liquid and send their tokens
// to other axccounts.
contract FrozenToken is Owned {
	event Transfer(address indexed from, address indexed to, uint256 value);

	// this is as basic as can be, only the associated balance & allowances
	struct Account {
		uint balance;
		bool liquid;
	}

	// constructor sets the parameters of execution, _totalSupply is all units
	constructor(uint _totalSupply, address _owner)
        public
		when_non_zero(_totalSupply)
	{
		totalSupply = _totalSupply;
		owner = _owner;
		accounts[_owner].balance = totalSupply;
		accounts[_owner].liquid = true;
	}

	// balance of a specific address
	function balanceOf(address _who) public view returns (uint256) {
		return accounts[_who].balance;
	}

	// make an account liquid: only liquid accounts can do this.
	function makeLiquid(address _to)
		public
		when_liquid(msg.sender)
		returns(bool)
	{
		accounts[_to].liquid = true;
		return true;
	}

	// transfer
	function transfer(address _to, uint256 _value)
		public
		when_owns(msg.sender, _value)
		when_liquid(msg.sender)
		returns(bool)
	{
		emit Transfer(msg.sender, _to, _value);
		accounts[msg.sender].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	// no default function, simple contract only, entry-level users
	function() external {
		assert(false);
	}

	// the balance should be available
	modifier when_owns(address _owner, uint _amount) {
		require (accounts[_owner].balance >= _amount);
		_;
	}

	modifier when_liquid(address who) {
		require (accounts[who].liquid);
		_;
	}

	// a value should be > 0
	modifier when_non_zero(uint _value) {
		require (_value > 0);
		_;
	}

	// Available token supply
	uint public totalSupply;

	// Storage and mapping of all balances & allowances
	mapping (address => Account) accounts;

	// Conventional metadata.
	string public constant name = "DOT Allocation Indicator";
	string public constant symbol = "DOT";
	uint8 public constant decimals = 3;
}

// File: contracts/Claims.sol

/// @author Web3 Foundation
/// @title  Claims
///         Allows allocations to be claimed to Polkadot public keys.
contract Claims is Owned {

    struct Claim {
        uint    index;          // Index for short address.
        bytes32 pubKey;         // Ed25519/SR25519 public key.
        bool    hasIndex;       // Has the index been set?
        uint    vested;         // Amount of allocation that is vested.
    }

    // The address of the allocation indicator contract.
    FrozenToken public allocationIndicator; // 0xb59f67A8BfF5d8Cd03f6AC17265c550Ed8F33907

    // The next index to be assigned.
    uint public nextIndex;

    // Maps allocations to `Claim` data.
    mapping (address => Claim) public claims;

    // Addresses that already claimed so we can easily grab them from state.
    address[] public claimed;

    // Amended keys, old address => new address. New address is allowed to claim for old address.
    mapping (address => address) public amended;

    // Event for when an allocation address amendment is made.
    event Amended(address indexed original, address indexed amendedTo);
    // Event for when an allocation is claimed to a Polkadot address.
    event Claimed(address indexed eth, bytes32 indexed dot, uint indexed idx);
    // Event for when an index is assigned to an allocation.
    event IndexAssigned(address indexed eth, uint indexed idx);
    // Event for when vesting is set on an allocation.
    event Vested(address indexed eth, uint amount);

    constructor(address _owner, address _allocations) public {
        require(_owner != address(0x0), "Must provide an owner address");
        require(_allocations != address(0x0), "Must provide an allocations address");

        owner = _owner;
        allocationIndicator = FrozenToken(_allocations);
    }

    /// Allows owner to manually amend allocations to a new address that can claim.
    /// @dev The given arrays must be same length and index must map directly.
    /// @param _origs An array of original (allocation) addresses.
    /// @param _amends An array of the new addresses which can claim those allocations.
    function amend(address[] calldata _origs, address[] calldata _amends)
        external
        only_owner
    {
        require(
            _origs.length == _amends.length,
            "Must submit arrays of equal length."
        );

        for (uint i = 0; i < _amends.length; i++) {
            require(!hasClaimed(_origs[i]), "Address has already claimed");
            amended[_origs[i]] = _amends[i];
            emit Amended(_origs[i], _amends[i]);
        }
    }

    /// Allows owner to manually toggle vesting onto allocations.
    /// @param _eths The addresses for which to set vesting.
    /// @param _vestingAmts The amounts that the accounts are vested.
    function setVesting(address[] calldata _eths, uint[] calldata _vestingAmts)
        external
        only_owner
    {
        require(_eths.length == _vestingAmts.length, "Must submit arrays of equal length");

        for (uint i = 0; i < _eths.length; i++) {
            Claim storage claimData = claims[_eths[i]];
            require(!hasClaimed(_eths[i]), "Account must not be claimed");
            require(claimData.vested == 0, "Account must not be vested already");
            require(_vestingAmts[i] != 0, "Vesting amount must be greater than zero");
            claimData.vested = _vestingAmts[i];
            emit Vested(_eths[i], _vestingAmts[i]);
        }
    }

    /// Allows anyone to assign a batch of indices onto unassigned and unclaimed allocations.
    /// @dev This function is safe because all the necessary checks are made on `assignNextIndex`.
    /// @param _eths An array of all€ocation addresses to assign indices for.
    /// @return bool True is successful.
    function assignIndices(address[] calldata _eths)
        external
    {
        for (uint i = 0; i < _eths.length; i++) {
            require(assignNextIndex(_eths[i]), "Assigning the next index failed");
        }
    }

    /// Claims an allocation associated with an `_eth` address to a `_pubKey` public key.
    /// @dev Can only be called by the `_eth` address or the amended address for the allocation.
    /// @param _eth The allocation address to claim.
    /// @param _pubKey The Polkadot public key to claim.
    /// @return True if successful.
    function claim(address _eth, bytes32 _pubKey)
        external
        has_allocation(_eth)
        not_claimed(_eth)
    {
        require(_pubKey != bytes32(0), "Failed to provide an Ed25519 or SR25519 public key");
        
        if (amended[_eth] != address(0x0)) {
            require(amended[_eth] == msg.sender, "Address is amended and sender is not the amendment");
        } else {
            require(_eth == msg.sender, "Sender is not the allocation address");
        }

        if (claims[_eth].index == 0 && !claims[_eth].hasIndex) {
            require(assignNextIndex(_eth), "Assigning the next index failed");
        }

        claims[_eth].pubKey = _pubKey;
        claimed.push(_eth);

        emit Claimed(_eth, _pubKey, claims[_eth].index);
    }

    /// Get the length of `claimed`.
    /// @return uint The number of accounts that have claimed.
    function claimedLength()
        external view returns (uint)
    {   
        return claimed.length;
    }

    /// Get whether an allocation has been claimed.
    /// @return bool True if claimed.
    function hasClaimed(address _eth)
        has_allocation(_eth)
        public view returns (bool)
    {
        return claims[_eth].pubKey != bytes32(0);
    }

    /// Assings an index to an allocation address.
    /// @dev Public function.
    /// @param _eth The allocation address.
    function assignNextIndex(address _eth)
        has_allocation(_eth)
        not_claimed(_eth)
        internal returns (bool)
    {
        require(claims[_eth].index == 0, "Cannot reassign an index.");
        require(!claims[_eth].hasIndex, "Address has already been assigned an index");
        uint idx = nextIndex;
        nextIndex++;
        claims[_eth].index = idx;
        claims[_eth].hasIndex = true;
        emit IndexAssigned(_eth, idx);
        return true;
    }

    /// @dev Requires that `_eth` address has DOT allocation.
    modifier has_allocation(address _eth) {
        uint bal = allocationIndicator.balanceOf(_eth);
        require(
            bal > 0,
            "Ethereum address has no DOT allocation"
        );
        _;
    }

    /// @dev Requires that `_eth` address has not claimed.
    modifier not_claimed(address _eth) {
        require(
            claims[_eth].pubKey == bytes32(0),
            "Account has already claimed."
        );
        _;
    }
}