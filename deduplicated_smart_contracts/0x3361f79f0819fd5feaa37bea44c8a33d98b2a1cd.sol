/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity >=0.4.11 <0.5.0;

/**
 * @title NMRSafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library NMRSafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


 /* WARNING: This implementation is outdated and insecure */
 /// @title Shareable
 /// @notice Multisig contract to manage access control
contract Shareable {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint yetNeeded;
    uint ownersDone;
    uint index;
  }


  // FIELDS

  // the number of owners that must confirm the same operation before it is run.
  uint public required;

  // list of owners
  address[256] owners;
  uint constant c_maxOwners = 250;
  // index on the list of owners to allow reverse lookup
  mapping(address => uint) ownerIndex;
  // the ongoing operations.
  mapping(bytes32 => PendingState) pendings;
  bytes32[] pendingsIndex;


  // EVENTS

  // this contract only has six types of events: it can accept a confirmation, in which case
  // we record owner and operation (hash) alongside it.
  event Confirmation(address owner, bytes32 operation);
  event Revoke(address owner, bytes32 operation);


  // MODIFIERS

  address thisContract = this;

  // simple single-sig function modifier.
  modifier onlyOwner {
    if (isOwner(msg.sender))
      _;
  }

  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier onlyManyOwners(bytes32 _operation) {
    if (confirmAndCheck(_operation))
      _;
  }


  // CONSTRUCTOR

  // constructor is given number of sigs required to do protected "onlymanyowners" transactions
  // as well as the selection of addresses capable of confirming them.
  function Shareable(address[] _owners, uint _required) {
    owners[1] = msg.sender;
    ownerIndex[msg.sender] = 1;
    for (uint i = 0; i < _owners.length; ++i) {
      owners[2 + i] = _owners[i];
      ownerIndex[_owners[i]] = 2 + i;
    }
    if (required > owners.length) throw;
    required = _required;
  }


  // new multisig is given number of sigs required to do protected "onlymanyowners" transactions
  // as well as the selection of addresses capable of confirming them.
  // take all new owners as an array
  /*
  
   WARNING: This function contains a security vulnerability. 
   
   This method does not clear the `owners` array and the `ownerIndex` mapping before updating the owner addresses.
   If the new array of owner addresses is shorter than the existing array of owner addresses, some of the existing owners will retain ownership.
   
   The fix implemented in NumeraireDelegateV2 successfully mitigates this bug by allowing new owners to remove the old owners from the `ownerIndex` mapping using a special transaction.
   Note that the old owners are not be removed from the `owners` array and that if the special transaction is incorectly crafted, it may result in fatal error to the multisig functionality.
   
   */
  function changeShareable(address[] _owners, uint _required) onlyManyOwners(sha3(msg.data)) {
    for (uint i = 0; i < _owners.length; ++i) {
      owners[1 + i] = _owners[i];
      ownerIndex[_owners[i]] = 1 + i;
    }
    if (required > owners.length) throw;
    required = _required;
  }

  // METHODS

  // Revokes a prior confirmation of the given operation
  function revoke(bytes32 _operation) external {
    uint index = ownerIndex[msg.sender];
    // make sure they're an owner
    if (index == 0) return;
    uint ownerIndexBit = 2**index;
    var pending = pendings[_operation];
    if (pending.ownersDone & ownerIndexBit > 0) {
      pending.yetNeeded++;
      pending.ownersDone -= ownerIndexBit;
      Revoke(msg.sender, _operation);
    }
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function getOwner(uint ownerIndex) external constant returns (address) {
    return address(owners[ownerIndex + 1]);
  }

  function isOwner(address _addr) constant returns (bool) {
    return ownerIndex[_addr] > 0;
  }

  function hasConfirmed(bytes32 _operation, address _owner) constant returns (bool) {
    var pending = pendings[_operation];
    uint index = ownerIndex[_owner];

    // make sure they're an owner
    if (index == 0) return false;

    // determine the bit to set for this owner.
    uint ownerIndexBit = 2**index;
    return !(pending.ownersDone & ownerIndexBit == 0);
  }

  // INTERNAL METHODS

  function confirmAndCheck(bytes32 _operation) internal returns (bool) {
    // determine what index the present sender is:
    uint index = ownerIndex[msg.sender];
    // make sure they're an owner
    if (index == 0) return;

    var pending = pendings[_operation];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (pending.yetNeeded == 0) {
      // reset count of confirmations needed.
      pending.yetNeeded = required;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      pending.ownersDone = 0;
      pending.index = pendingsIndex.length++;
      pendingsIndex[pending.index] = _operation;
    }
    // determine the bit to set for this owner.
    uint ownerIndexBit = 2**index;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (pending.ownersDone & ownerIndexBit == 0) {
      Confirmation(msg.sender, _operation);
      // ok - check if count is enough to go ahead.
      if (pending.yetNeeded <= 1) {
        // enough confirmations: reset and run interior.
        delete pendingsIndex[pendings[_operation].index];
        delete pendings[_operation];
        return true;
      }
      else
        {
          // not enough: record that this owner in particular confirmed.
          pending.yetNeeded--;
          pending.ownersDone |= ownerIndexBit;
        }
    }
  }

  function clearPending() internal {
    uint length = pendingsIndex.length;
    for (uint i = 0; i < length; ++i)
    if (pendingsIndex[i] != 0)
      delete pendings[pendingsIndex[i]];
    delete pendingsIndex;
  }
}



/// @title Safe
/// @notice Utility functions for safe data manipulations
contract Safe {

    /// @dev Add two numbers without overflow
    /// @param a Uint number
    /// @param b Uint number
    /// @return result
    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    /// @dev Substract two numbers without underflow
    /// @param a Uint number
    /// @param b Uint number
    /// @return result
    function safeSubtract(uint a, uint b) internal returns (uint) {
        uint c = a - b;
        assert(b <= a && c <= a);
        return c;
    }

    /// @dev Multiply two numbers without overflow
    /// @param a Uint number
    /// @param b Uint number
    /// @return result
    function safeMultiply(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || (c / a) == b);
        return c;
    }

    /// @dev Convert uint256 to uint128 without concatenating
    /// @param a Uint number
    /// @return result
    function shrink128(uint a) internal returns (uint128) {
        assert(a < 0x100000000000000000000000000000000);
        return uint128(a);
    }

    /// @dev Prevent short address attack
    /// @param numWords Uint length of calldata in bytes32 words
    modifier onlyPayloadSize(uint numWords) {
        assert(msg.data.length == numWords * 32 + 4);
        _;
    }

    /// @dev Fallback function to allow ETH to be received
    function () payable { }
}



/// @title StoppableShareable
/// @notice Extend the Shareable multisig with ability to pause desired functions
contract StoppableShareable is Shareable {
  bool public stopped;
  bool public stoppable = true;

  modifier stopInEmergency { if (!stopped) _; }
  modifier onlyInEmergency { if (stopped) _; }

  function StoppableShareable(address[] _owners, uint _required) Shareable(_owners, _required) {
  }

  /// @notice Trigger paused state
  /// @dev Can only be called by an owner
  function emergencyStop() external onlyOwner {
    assert(stoppable);
    stopped = true;
  }

  /// @notice Return to unpaused state
  /// @dev Can only be called by the multisig
  function release() external onlyManyOwners(sha3(msg.data)) {
    assert(stoppable);
    stopped = false;
  }

  /// @notice Disable ability to pause the contract
  /// @dev Can only be called by the multisig
  function disableStopping() external onlyManyOwners(sha3(msg.data)) {
    stoppable = false;
  }
}



/// @title NumeraireShared
/// @notice Token and tournament storage layout
contract NumeraireShared is Safe {

    address public numerai = this;

    // Cap the total supply and the weekly supply
    uint256 public supply_cap = 21000000e18; // 21 million
    uint256 public weekly_disbursement = 96153846153846153846153;

    uint256 public initial_disbursement;
    uint256 public deploy_time;

    uint256 public total_minted;

    // ERC20 requires totalSupply, balanceOf, and allowance
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping (uint => Tournament) public tournaments;  // tournamentID

    struct Tournament {
        uint256 creationTime;
        uint256[] roundIDs;
        mapping (uint256 => Round) rounds;  // roundID
    } 

    struct Round {
        uint256 creationTime;
        uint256 endTime;
        uint256 resolutionTime;
        mapping (address => mapping (bytes32 => Stake)) stakes;  // address of staker
    }

    // The order is important here because of its packing characteristics.
    // Particularly, `amount` and `confidence` are in the *same* word, so
    // Solidity can update both at the same time (if the optimizer can figure
    // out that you're updating both).  This makes `stake()` cheap.
    struct Stake {
        uint128 amount; // Once the stake is resolved, this becomes 0
        uint128 confidence;
        bool successful;
        bool resolved;
    }

    // Generates a public event on the blockchain to notify clients
    event Mint(uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed staker, bytes32 tag, uint256 totalAmountStaked, uint256 confidence, uint256 indexed tournamentID, uint256 indexed roundID);
    event RoundCreated(uint256 indexed tournamentID, uint256 indexed roundID, uint256 endTime, uint256 resolutionTime);
    event TournamentCreated(uint256 indexed tournamentID);
    event StakeDestroyed(uint256 indexed tournamentID, uint256 indexed roundID, address indexed stakerAddress, bytes32 tag);
    event StakeReleased(uint256 indexed tournamentID, uint256 indexed roundID, address indexed stakerAddress, bytes32 tag, uint256 etherReward);

    /// @notice Get the amount of NMR which can be minted
    /// @return uint256 Amount of NMR in wei
    function getMintable() constant returns (uint256) {
        return
            safeSubtract(
                safeAdd(initial_disbursement,
                    safeMultiply(weekly_disbursement,
                        safeSubtract(block.timestamp, deploy_time))
                    / 1 weeks),
                total_minted);
    }
}





/// @title UpgradeDelegate
/// @notice Delegate contract used to execute final token upgrade
/// @dev This contract could optionally hardcode the address of the multisig
/// wallet before deployment - it is currently supplied as a function argument.
/// @dev Deployed at address
/// @dev Set in tx
/// @dev Retired in tx
contract UpgradeDelegate is StoppableShareable, NumeraireShared {

    address public delegateContract;
    bool public contractUpgradable;
    address[] public previousDelegates;

    string public standard;

    string public name;
    string public symbol;
    uint256 public decimals;

    event DelegateChanged(address oldAddress, address newAddress);

    using NMRSafeMath for uint256;

    // set the address of the tournament contract as a constant.
    address private constant _TOURNAMENT = address(
        0x9DCe896DdC20BA883600176678cbEe2B8BA188A9
    );

    /// @dev Constructor called on deployment to initialize the delegate
    ///      contract multisig (even though it is an implementation contract,
    ///      just in case) and to confirm that the deployment address of the
    ///      contract matches the expected deployment address.
    /// @param _owners Array of owner address to control multisig
    /// @param _num_required Uint number of owners required for multisig transaction
    constructor(address[] _owners, uint256 _num_required) public StoppableShareable(_owners, _num_required) {
        require(
            address(this) == address(0x3361F79f0819fD5feaA37bea44C8a33d98b2A1cd),
            "incorrect deployment address - check submitting account & nonce."
        );
    }

    /// @dev Used to execute the token upgrade. The new tournament must first be
    //       initialized. Can only be called by the dedicated deployment address.
    /// @dev Executes the following steps:
    ///   1) Burn any NMR at the token contract's address and the null address.
    ///   2) Mint the remaining NMR supply to the designated multisig.
    ///   3) Transfer the remaining ETH balance to the designated multisig.
    ///   4) Clear the stake data, round data, and tournament data of tournament 0
    ///   5) Set new totalSupply and supply_cap values to 11 million NMR
    ///   6) Designate new delegate contract as NumeraireDelegateV3
    ///   7) Permanently disable freezing
    ///   8) Clear all existing owners
    function numeraiTransfer(address multiSig, uint256) public returns (bool ok) {
        // only the deployment address can call this function
        require(msg.sender == address(0x249e479b571Fea3DE01F186cF22383a79b21ca7F));

        // define the delegate address using the expected hardcoded address
        address delegateV3 = address(0x29F709e42C95C604BA76E73316d325077f8eB7b2);

        // zero out the NMR balance of the token contract and adjust totalSupply
        _burn(address(this), balanceOf[address(this)]);

        // zero out the NMR balance of the null address and adjust totalSupply
        _burn(address(0), balanceOf[address(0)]);

        // clear tournament 0 stakes (should cause totalSupply == sum(balances))
        uint8[87] memory roundIds = [
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000006),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000007),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000008),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000009),
            uint8(0x000000000000000000000000000000000000000000000000000000000000000b),
            uint8(0x000000000000000000000000000000000000000000000000000000000000000c),
            uint8(0x000000000000000000000000000000000000000000000000000000000000000d),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000011),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000012),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000013),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000014),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000015),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000016),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000017),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000018),
            uint8(0x000000000000000000000000000000000000000000000000000000000000000e),
            uint8(0x000000000000000000000000000000000000000000000000000000000000000f),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000010),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000019),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001a),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001b),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001c),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001d),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000036),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x000000000000000000000000000000000000000000000000000000000000000a),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000002),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000003),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000004),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000011),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000012),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000013),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001e),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001f),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000020),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000021),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000022),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000023),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000024),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000025),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000014),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000015),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000016),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000017),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000018),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000019),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001a),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001b),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001c),
            uint8(0x000000000000000000000000000000000000000000000000000000000000001d),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000026),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000027),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000028),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000029),
            uint8(0x000000000000000000000000000000000000000000000000000000000000002a),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000035),
            uint8(0x000000000000000000000000000000000000000000000000000000000000002b),
            uint8(0x000000000000000000000000000000000000000000000000000000000000002c),
            uint8(0x000000000000000000000000000000000000000000000000000000000000002d),
            uint8(0x000000000000000000000000000000000000000000000000000000000000002e),
            uint8(0x000000000000000000000000000000000000000000000000000000000000002f),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000030),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000031),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000032),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000033),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000034),
            uint8(0x0000000000000000000000000000000000000000000000000000000000000005)
        ];
        address[87] memory stakers = [
            address(0x00000000000000000000000000000000000000000000000000000000000007e0),
            address(0x0000000000000000000000000000000000000000000000000000000000004c4c),
            address(0x00000000000000000000000000000000000000000000000000000000000007e0),
            address(0x00000000000000000000000000000000000000000000000000000000000007e0),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab4),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab4),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab4),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab9),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab9),
            address(0x0000000000000000000000000000000000000000000000000000000000004c4c),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab6),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab6),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab6),
            address(0x0000000000000000000000000000000000000000000000000000000000004c4c),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab9),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x000000000000000000000000000000000000000000000000000000000001cb71),
            address(0x0000000000000000000000004b3a0d73454b74172fe61b5a3eac2f34c0675546),
            address(0x0000000000000000000000004b3a0d73454b74172fe61b5a3eac2f34c0675546),
            address(0x0000000000000000000000004b3a0d73454b74172fe61b5a3eac2f34c0675546),
            address(0x00000000000000000000000000000000000000000000000000000000000010f2),
            address(0x0000000000000000000000000000000000000000000000000000000000005164),
            address(0x0000000000000000000000000000000000000000000000000000000000005164),
            address(0x0000000000000000000000000000000000000000000000000000000000005164),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab5),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab5),
            address(0x0000000000000000000000000000000000000000000000000000000000004ab5),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001f909),
            address(0x000000000000000000000000000000000000000000000000000000000001ee9d)
        ];
        bytes32[87] memory tags = [
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x616e736f6e616900000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x626c757500000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        ];

        uint256 totalStakeAmount;
        for (uint256 i = 0; i < roundIds.length; i++) {
            uint256 roundID = uint256(roundIds[i]);
            uint256 stakeAmount = uint256(tournaments[0].rounds[roundID].stakes[stakers[i]][tags[i]].amount);
            totalStakeAmount = totalStakeAmount.add(stakeAmount);
            delete tournaments[0].rounds[roundID].stakes[stakers[i]][tags[i]];
        }

        // clear tournament 0 stakes
        totalSupply = totalSupply.sub(totalStakeAmount);

        // clear tournament 0 rounds
        for (uint256 j = 1; j <= 54; j++) {
            delete tournaments[0].rounds[j];
        }

        // clear tournament 0
        delete tournaments[0];

        // premine the difference between 11 million and totalSupply to multisig
        /* NOTE: Must be the final balance manipulation */
        supply_cap = 11e24;
        _mint(multiSig);
        totalSupply = supply_cap;

        // Set minting variables
        initial_disbursement = 11e24;
        weekly_disbursement = 0;
        total_minted = 11e24;

        // Set delegateV3
        previousDelegates.push(delegateContract);
        emit DelegateChanged(delegateContract, delegateV3);
        delegateContract = delegateV3;

        // Unfreeze and disable freezing
        stopped = false;
        stoppable = false;

        // Clear ownership - BE SURE THAT ownerIndex IS CLEARED PROPERLY!
        clearPending();
        for (uint256 z = 0; z < owners.length; z++) {
            if (owners[z] != address(0)) {
                delete ownerIndex[owners[z]];
                delete owners[z];
            }
        }
        delete ownerIndex[address(0)]; // just in case...

        // Double check all previous owners have been cleared
        address[28] memory previousOwners = [
            address(0x9608010323ed882a38ede9211d7691102b4f0ba0),
            address(0xb4207031bb146e90cab72230e0030823e02b923b),
            address(0x0387f0f731b518590433cd0b37e5b3eb9d3aef98),
            address(0x8ad69ae99804935d56704162e3f6a6f442d2ed4a),
            address(0x16e7115f6595668ca34f0cae8e76196274c14ff7),
            address(0xdc6997b078c709327649443d0765bcaa8e37aa6c),
            address(0x257988b95ee87c30844abec7736ff8a7d0be2eb1),
            address(0x70153f8f89f6869037fba270233409844f1f2e2e),
            address(0xae0338fefd533129694345659da36c4fe144e350),
            address(0x444ab8ad5c74f82fada4765f4a4e595109903f11),
            address(0x54479be2ca140163031efec1b7608b9759ec897a),
            address(0x193b78eb3668982f17862181d083ff2e2a4dcc39),
            address(0x6833b2469e80ef0c72aa784e27b2666ab43568f5),
            address(0x1d68938194004722b814f00003d3eca19357344a),
            address(0x54479be2ca140163031efec1b7608b9759ec897a),
            address(0x9608010323ed882a38ede9211d7691102b4f0ba0),
            address(0x638141cfe7c64fe9a22400e7d9f682d5f7b3a99b),
            address(0x769c72349aa599e7f63102cd3e4576fd8f306697),
            address(0xe6a2be73d9f8eb7a56f27276e748b05f7d6d7500),
            address(0x707ad29e43f053d267854478642e278e78243666),
            address(0x193b78eb3668982f17862181d083ff2e2a4dcc39),
            address(0x6833b2469e80ef0c72aa784e27b2666ab43568f5),
            address(0x1d68938194004722b814f00003d3eca19357344a),
            address(0x22926dd58213ab6601addfa9083b3d01b9e20fe8),
            address(0x769c72349aa599e7f63102cd3e4576fd8f306697),
            address(0xe6a2be73d9f8eb7a56f27276e748b05f7d6d7500),
            address(0x638141cfe7c64fe9a22400e7d9f682d5f7b3a99b),
            address(0x707ad29e43f053d267854478642e278e78243666)
        ];
        for (uint256 y = 0; y < previousOwners.length; y++) {
            delete ownerIndex[previousOwners[y]];
        }

        // transfer all ETH on the token contract to multisig
        multiSig.transfer(address(this).balance);

        return true;
    }

    /// @dev Used for clearing active round data from the old tournament
    ///      contract. Can only be called by the new tournament address.
    function createRound(uint256 _tournamentID, uint256 _numRounds, uint256, uint256) public returns (bool ok) {
        // only the tournament can call this function.
        require(msg.sender == _TOURNAMENT);

        // validate number of rounds wont underflow
        require(_numRounds <= tournaments[_tournamentID].roundIDs.length);

        // iterate over each round and delete it.
        for (uint256 i = 1; i <= _numRounds; i++) {

            // get new array length reference
            uint256 newLength = tournaments[_tournamentID].roundIDs.length;

            // determine the last round ID.
            uint256 roundID = tournaments[_tournamentID].roundIDs[newLength - 1];

            // delete the round.
            delete tournaments[_tournamentID].rounds[roundID];

            // reduce the roundIDs array.
            tournaments[_tournamentID].roundIDs.length--;

        }

        return true;
    }

    /// @dev Used for clearing active stakes from the old tournament contract.
    ///      Can only be called by the new tournament address.
    function destroyStake(address _staker, bytes32 _tag, uint256 _tournamentID, uint256 _roundID) public returns (bool ok) {
        // only the tournament can call this function.
        require(msg.sender == _TOURNAMENT);
        delete tournaments[_tournamentID].rounds[_roundID].stakes[_staker][_tag];
        return true;
    }

    /// @dev Used to credit new tournament with active stake balances once
    ///      intialization is completed and before performing the upgrade.
    ///      Can only be called by the new tournament address.
    function withdraw(address, address, uint256 _stakeAmt) public returns (bool ok) {
        // only the tournament can call this function.
        require(msg.sender == _TOURNAMENT);
        // prevent from being called twice
        require(balanceOf[_TOURNAMENT] < _stakeAmt);
        balanceOf[_TOURNAMENT] = balanceOf[_TOURNAMENT].add(_stakeAmt);
        return true;
    }

    /// @dev Disabled function no longer used
    function mint(uint256) public pure returns (bool) {
        revert();
    }

    /// @dev Disabled function no longer used
    function releaseStake(address, bytes32, uint256, uint256, uint256, bool) public pure returns (bool) {
        revert();
    }

    /// @dev Disabled function no longer used
    function stake(uint256, bytes32, uint256, uint256, uint256) public pure returns (bool) {
        revert();
    }

    /// @dev Disabled function no longer used
    function stakeOnBehalf(address, uint256, bytes32, uint256, uint256, uint256) public pure returns (bool) {
        revert();
    }

    /// @dev Disabled function no longer used
    function createTournament(uint256) public pure returns (bool) {
        revert();
    }

    ////////////////////////
    // Internal Functions //
    ////////////////////////

    function _burn(address _account, uint256 _value) internal {
        totalSupply = totalSupply.sub(_value);
        balanceOf[_account] = balanceOf[_account].sub(_value);
        emit Transfer(_account, address(0), _value);
    }

    function _mint(address multiSig) internal {
        uint256 mintAmount = supply_cap.sub(totalSupply);
        balanceOf[multiSig] = balanceOf[multiSig].add(mintAmount);
        emit Transfer(address(0), multiSig, mintAmount);
    }
}