/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

// File: contracts/interfaces/SyscoinSuperblocksI.sol

pragma solidity ^0.5.13;

interface SyscoinSuperblocksI {

    // @dev - Superblock status
    enum Status { Uninitialized, New, InBattle, SemiApproved, Approved, Invalid }
    struct SuperblockInfo {
        bytes32 blocksMerkleRoot;
        uint timestamp;
        uint mtpTimestamp;
        bytes32 lastHash;
        bytes32 parentId;
        address submitter;
        uint32 lastBits;
        uint32 height;
        Status status;
    }
    function propose(
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address submitter
    ) external returns (uint, bytes32);

    function getSuperblock(bytes32 superblockHash) external view returns (
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        Status _status,
        uint32 _height
    );

    function relayTx(
        bytes calldata _txBytes,
        uint _txIndex,
        uint[] calldata _txSiblings,
        bytes calldata _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] calldata _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) external returns (uint);

    function confirm(bytes32 _superblockHash, address _validator) external returns (uint);
    function challenge(bytes32 _superblockHash, address _challenger) external returns (uint);
    function semiApprove(bytes32 _superblockHash, address _validator) external returns (uint);
    function invalidate(bytes32 _superblockHash, address _validator) external returns (uint);
    function getBestSuperblock() external view returns (bytes32);
    function getChainHeight() external view returns (uint);
    function getSuperblockHeight(bytes32 superblockHash) external view returns (uint32);
    function getSuperblockParentId(bytes32 _superblockHash) external view returns (bytes32);
    function getSuperblockStatus(bytes32 _superblockHash) external view returns (Status);
    function getSuperblockAt(uint _height) external view returns (bytes32);
    function getSuperblockTimestamp(bytes32 _superblockHash) external view returns (uint);
    function getSuperblockMedianTimestamp(bytes32 _superblockHash) external view returns (uint);

    function relayAssetTx(
        bytes calldata _txBytes,
        uint _txIndex,
        uint[] calldata _txSiblings,
        bytes calldata _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] calldata _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) external returns (uint);
}

// File: contracts/interfaces/SyscoinClaimManagerI.sol

pragma solidity ^0.5.13;


interface SyscoinClaimManagerI {
    function bondDeposit(bytes32 superblockHash, address account, uint amount) external returns (uint);
    function getDeposit(address account) external view returns (uint);
    function checkClaimFinished(bytes32 superblockHash) external returns (bool);
    function sessionDecided(bytes32 superblockHash, address winner, address loser) external;
}

// File: contracts/interfaces/SyscoinBattleManagerI.sol

pragma solidity ^0.5.13;

// @dev - Manages a battle session between superblock submitter and challenger
interface SyscoinBattleManagerI {
    // @dev - Start a battle session
    function beginBattleSession(bytes32 superblockHash, address submitter, address challenger)
        external;
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/SyscoinDepositsManager.sol

pragma solidity ^0.5.13;


contract SyscoinDepositsManager {

    using SafeMath for uint;

    mapping(address => uint) public deposits;

    event DepositMade(address who, uint amount);
    event DepositWithdrawn(address who, uint amount);

    // @dev 每 fallback to calling makeDeposit when ether is sent directly to contract.
    function() external payable {
        makeDeposit();
    }

    // @dev 每 returns an account's deposit
    // @param who 每 the account's address.
    // @return 每 the account's deposit.
    function getDeposit(address who) external view returns (uint) {
        return deposits[who];
    }

    // @dev 每 allows a user to deposit eth.
    // @return 每 sender's updated deposit amount.
    function makeDeposit() public payable returns (uint) {
        increaseDeposit(msg.sender, msg.value);
        return deposits[msg.sender];
    }

    // @dev 每 increases an account's deposit.
    // @return 每 the given user's updated deposit amount.
    function increaseDeposit(address who, uint amount) private {
        deposits[who] = deposits[who].add(amount);
        emit DepositMade(who, amount);
    }

    // @dev 每 allows a user to withdraw eth from their deposit.
    // @param amount 每 how much eth to withdraw
    // @return 每 sender's updated deposit amount.
    function withdrawDeposit(uint amount) external returns (uint) {
        require(deposits[msg.sender] >= amount && amount > 0);

        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        // stop using .transfer() because of gas issue after ethereum upgrade
        msg.sender.call.value(amount)("");
        emit DepositWithdrawn(msg.sender, amount);
        return deposits[msg.sender];
    }
}

// File: contracts/SyscoinErrorCodes.sol

pragma solidity ^0.5.13;

// @dev - SyscoinSuperblocks error codes
contract SyscoinErrorCodes {
    // Error codes
    uint constant ERR_INVALID_HEADER = 10050;
    uint constant ERR_COINBASE_INDEX = 10060; // coinbase tx index within Bitcoin merkle isn't 0
    uint constant ERR_NOT_MERGE_MINED = 10070; // trying to check AuxPoW on a block that wasn't merge mined
    uint constant ERR_FOUND_TWICE = 10080; // 0xfabe6d6d found twice
    uint constant ERR_NO_MERGE_HEADER = 10090; // 0xfabe6d6d not found
    uint constant ERR_CHAIN_MERKLE = 10110;
    uint constant ERR_PARENT_MERKLE = 10120;
    uint constant ERR_PROOF_OF_WORK = 10130;
    uint constant ERR_INVALID_HEADER_HASH = 10140;
    uint constant ERR_PROOF_OF_WORK_AUXPOW = 10150;
    uint constant ERR_PARSE_TX_OUTPUT_LENGTH = 10160;


    uint constant ERR_SUPERBLOCK_OK = 0;
    uint constant ERR_SUPERBLOCK_MISSING_BLOCKS = 1;
    uint constant ERR_SUPERBLOCK_BAD_STATUS = 50020;
    uint constant ERR_SUPERBLOCK_BAD_SYSCOIN_STATUS = 50025;
    uint constant ERR_SUPERBLOCK_TIMEOUT = 50026;
    uint constant ERR_SUPERBLOCK_NO_TIMEOUT = 50030;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP = 50035;
    uint constant ERR_SUPERBLOCK_INVALID_TIMESTAMP = 50036;
    uint constant ERR_SUPERBLOCK_INVALID_MERKLE = 50038;

    // The error codes "ERR_SUPERBLOCK_BAD_PARENT_*" corresponds to ERR_SUPERBLOCK_BAD_PARENT + superblock.status
    uint constant ERR_SUPERBLOCK_BAD_PARENT = 50040;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_UNINITIALIZED = 50040;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_NEW = 50041;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_INBATTLE = 50042;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_INVALID = 50045;

    uint constant ERR_SUPERBLOCK_OWN_CHALLENGE = 50055;
    uint constant ERR_SUPERBLOCK_BAD_PREV_TIMESTAMP = 50056;
    uint constant ERR_SUPERBLOCK_BITS_SUPERBLOCK = 50057;
    uint constant ERR_SUPERBLOCK_BITS_PREVBLOCK = 50058;
    uint constant ERR_SUPERBLOCK_HASH_SUPERBLOCK = 50059;
    uint constant ERR_SUPERBLOCK_HASH_PREVBLOCK = 50060;
    uint constant ERR_SUPERBLOCK_HASH_PREVSUPERBLOCK = 50061;
    uint constant ERR_SUPERBLOCK_MAX_INPROGRESS = 50062;
    uint constant ERR_SUPERBLOCK_BITS_LASTBLOCK = 50064;
    uint constant ERR_SUPERBLOCK_MIN_DEPOSIT = 50065;
    uint constant ERR_SUPERBLOCK_BITS_INTERIM_PREVBLOCK = 50066;
    uint constant ERR_SUPERBLOCK_HASH_INTERIM_PREVBLOCK = 50067;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP_AVERAGE = 50068;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP_MTP = 50069;

    uint constant ERR_SUPERBLOCK_NOT_CLAIMMANAGER = 50070;
    uint constant ERR_SUPERBLOCK_MISMATCH_TIMESTAMP_MTP = 50071;
    uint constant ERR_SUPERBLOCK_TOOSMALL_TIMESTAMP_MTP = 50072;

    uint constant ERR_SUPERBLOCK_BAD_CLAIM = 50080;
    uint constant ERR_SUPERBLOCK_VERIFICATION_PENDING = 50090;
    uint constant ERR_SUPERBLOCK_CLAIM_DECIDED = 50100;
    uint constant ERR_SUPERBLOCK_CHALLENGE_EXISTS = 50110;

    uint constant ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK = 50120;
    uint constant ERR_SUPERBLOCK_BAD_BITS = 50130;
    uint constant ERR_SUPERBLOCK_MISSING_CONFIRMATIONS = 50140;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK = 50150;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK_STATUS = 50160;
    uint constant ERR_SUPERBLOCK_BAD_BLOCKHEIGHT = 50170;
    uint constant ERR_SUPERBLOCK_BAD_PREVBLOCK = 50190;
    uint constant ERR_SUPERBLOCK_CLAIM_ALREADY_DEFENDED = 50200;
    uint constant ERR_SUPERBLOCK_BAD_MISMATCH = 50210;
    uint constant ERR_SUPERBLOCK_INTERIMBLOCK_MISSING = 50220;
    uint constant ERR_SUPERBLOCK_BAD_INTERIM_PREVHASH = 50230;
    uint constant ERR_SUPERBLOCK_BAD_INTERIM_BLOCKINDEX = 50240;


    // error codes for verifyTx
    uint constant ERR_BAD_FEE = 20010;
    uint constant ERR_CONFIRMATIONS = 20020;
    uint constant ERR_CHAIN = 20030;
    uint constant ERR_SUPERBLOCK = 20040;
    uint constant ERR_MERKLE_ROOT = 20050;
    uint constant ERR_TX_64BYTE = 20060;
    uint constant ERR_SUPERBLOCK_MERKLE_ROOT = 20070;
    // error codes for relayTx
    uint constant ERR_RELAY_VERIFY = 30010;
    uint constant ERR_CANCEL_TRANSFER_VERIFY = 30020;
    uint constant public minProposalDeposit = 3000000000000000000;
}

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/SyscoinClaimManager.sol

pragma solidity ^0.5.13;








// @dev - Manager of superblock claims
//
// Manages superblocks proposal and challenges
contract SyscoinClaimManager is Initializable, SyscoinDepositsManager, SyscoinErrorCodes {

    using SafeMath for uint;

    uint constant MAX_FUTURE_BLOCK_TIME_SYSCOIN = 7200;
    uint constant MAX_FUTURE_BLOCK_TIME_ETHEREUM = 15;
    struct SuperblockClaim {
        bytes32 superblockHash;                       // Superblock Id
        address submitter;                           // Superblock submitter
        address challenger;                         // Superblock challenger
        uint createdAt;                             // Superblock creation time

        mapping (address => uint) bondedDeposits;   // Deposit associated to submitter+challenger

        uint challengeTimeout;                      // Claim timeout

        bool verificationOngoing;                   // Challenge session has started

        bool decided;                               // If the claim was decided
        bool invalid;                               // If superblock is invalid
        bool challengeDefended;                     // has this challenge been defended already, not allowed to re-defend
    }

    // Active superblock claims
    mapping (bytes32 => SuperblockClaim) public claims;

    // Superblocks contract
    SyscoinSuperblocksI public trustedSuperblocks;

    // Battle manager contract
    SyscoinBattleManagerI public trustedSyscoinBattleManager;

    // Confirmations required to confirm semi approved superblocks
    uint public superblockConfirmations;

    uint public superblockDelay;    // Delay required to submit superblocks (in seconds)
    uint public superblockTimeout;  // Timeout for action (in seconds)
    uint public inProcessCounter;   // how many in progress superblocks do we have? should be below 10 for 10 max commitments of deposits
    event DepositBonded(bytes32 superblockHash, address account, uint amount);
    event DepositUnbonded(bytes32 superblockHash, address account, uint amount);
    event SuperblockClaimCreated(bytes32 superblockHash, address submitter, uint processCounter);
    event SuperblockClaimChallenged(bytes32 superblockHash, address challenger);
    event SuperblockBattleDecided(bytes32 superblockHash, address winner, address loser);
    event SuperblockClaimSuccessful(bytes32 superblockHash, address submitter, uint processCounter);
    event SuperblockClaimPending(bytes32 superblockHash, address submitter);
    event SuperblockClaimFailed(bytes32 superblockHash, address challenger, uint processCounter);
    event VerificationGameStarted(bytes32 superblockHash, address submitter, address challenger);

    event ErrorClaim(bytes32 superblockHash, uint err);

    modifier onlyBattleManager() {
        require(msg.sender == address(trustedSyscoinBattleManager));
        _;
    }

    modifier onlyMeOrBattleManager() {
        require(msg.sender == address(trustedSyscoinBattleManager) || msg.sender == address(this));
        _;
    }
    
    // @dev 每 Sets up the contract managing superblock challenges
    // @param _superblocks Contract that manages superblocks
    // @param _battleManager Contract that manages battles
    // @param _superblockDelay Delay to accept a superblock submission (in seconds)
    // @param _superblockTimeout Time to wait for challenges (in seconds)
    // @param _superblockConfirmations Confirmations required to confirm semi approved superblocks
    function init(
        SyscoinSuperblocksI _superblocks,
        SyscoinBattleManagerI _syscoinBattleManager,
        uint _superblockDelay,
        uint _superblockTimeout,
        uint _superblockConfirmations
    ) public initializer {
        trustedSuperblocks = _superblocks;
        trustedSyscoinBattleManager = _syscoinBattleManager;
        superblockDelay = _superblockDelay;
        superblockTimeout = _superblockTimeout;
        superblockConfirmations = _superblockConfirmations;
        inProcessCounter = 0;
    }

    // @dev 每 locks up part of a user's deposit into a claim.
    // @param superblockHash 每 claim id.
    // @param account 每 user's address.
    // @param amount 每 amount of deposit to lock up.
    // @return 每 user's deposit bonded for the claim.
    function bondDeposit(bytes32 superblockHash, address account, uint amount) external onlyMeOrBattleManager returns (uint) {
        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim)) {
            return ERR_SUPERBLOCK_BAD_CLAIM;
        }

        if (deposits[account] < amount) {
            return ERR_SUPERBLOCK_MIN_DEPOSIT;
        }

        deposits[account] = deposits[account].sub(amount);
        claim.bondedDeposits[account] = claim.bondedDeposits[account].add(amount);
        emit DepositBonded(superblockHash, account, amount);

        return ERR_SUPERBLOCK_OK;
    }

    // @dev 每 accessor for a claim's bonded deposits.
    // @param superblockHash 每 claim id.
    // @param account 每 user's address.
    // @return 每 user's deposit bonded for the claim.
    function getBondedDeposit(bytes32 superblockHash, address account) external view returns (uint) {
        SuperblockClaim storage claim = claims[superblockHash];
        require(claimExists(claim));
        return claim.bondedDeposits[account];
    }

    // @dev 每 unlocks a user's bonded deposits from a claim.
    // @param superblockHash 每 claim id.
    // @param account 每 user's address.
    // @return 每 user's deposit which was unbonded from the claim.
    function unbondDeposit(bytes32 superblockHash, address account) public returns (uint, uint) {
        SuperblockClaim storage claim = claims[superblockHash];
        if (!claimExists(claim)) {
            return (ERR_SUPERBLOCK_BAD_CLAIM, 0);
        }
        if (!claim.decided) {
            return (ERR_SUPERBLOCK_BAD_STATUS, 0);
        }

        uint bondedDeposit = claim.bondedDeposits[account];

        delete claim.bondedDeposits[account];
        deposits[account] = deposits[account].add(bondedDeposit);

        emit DepositUnbonded(superblockHash, account, bondedDeposit);

        return (ERR_SUPERBLOCK_OK, bondedDeposit);
    }

    // @dev 每 Propose a new superblock.
    //
    // @param _blocksMerkleRoot Root of the merkle tree of blocks contained in a superblock
    // @param _timestamp Timestamp of the last block in the superblock
    // @param _mtpTimestamp Median Timestamp of the last block in the superblock
    // @param _lastHash Hash of the last block in the superblock
    // @param _lastBits Difficulty bits of the last block in the superblock bits
    // @param _parentHash Id of the parent superblock
    // @return Error code and superblockHash
    function proposeSuperblock(
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentHash
    ) external returns (uint, bytes32) {
        require(address(trustedSuperblocks) != address(0));
        
        if (inProcessCounter >= 10){
            emit ErrorClaim(0, ERR_SUPERBLOCK_MAX_INPROGRESS);
            return (ERR_SUPERBLOCK_MAX_INPROGRESS, 0);            
        }
        if (deposits[msg.sender] < minProposalDeposit) {
            emit ErrorClaim(0, ERR_SUPERBLOCK_MIN_DEPOSIT);
            return (ERR_SUPERBLOCK_MIN_DEPOSIT, 0);
        }

        if (_mtpTimestamp + superblockDelay > block.timestamp) {
            emit ErrorClaim(0, ERR_SUPERBLOCK_BAD_TIMESTAMP_MTP);
            return (ERR_SUPERBLOCK_BAD_TIMESTAMP_MTP, 0);
        }

        if (block.timestamp + MAX_FUTURE_BLOCK_TIME_SYSCOIN + MAX_FUTURE_BLOCK_TIME_ETHEREUM <= _timestamp) {
            emit ErrorClaim(0, ERR_SUPERBLOCK_BAD_TIMESTAMP);
            return (ERR_SUPERBLOCK_BAD_TIMESTAMP, 0);
        }

        uint err;
        bytes32 superblockHash;
        (err, superblockHash) = trustedSuperblocks.propose(_blocksMerkleRoot, _timestamp, _mtpTimestamp, _lastHash, _lastBits, _parentHash, msg.sender);
        if (err != 0) {
            emit ErrorClaim(superblockHash, err);
            return (err, superblockHash);
        }


        SuperblockClaim storage claim = claims[superblockHash];
        // allow to propose an existing claim only if its invalid and decided and its a different submitter or not on the tip
        // those are the ones that may actually be stuck and need to be proposed again,
        // but we want to ensure its not the same submitter submitting the same thing
        if (claimExists(claim)) {
            require(claim.invalid == true && claim.decided == true && claim.submitter != msg.sender);
        }

        claim.superblockHash = superblockHash;
        claim.submitter = msg.sender;
        claim.challenger = address(0);
        claim.decided = false;
        claim.invalid = false;
        claim.verificationOngoing = false;
        claim.createdAt = block.timestamp;
        claim.challengeTimeout = block.timestamp + superblockTimeout;
        claim.challengeDefended = false;
        err = this.bondDeposit(superblockHash, msg.sender, minProposalDeposit);
        require(err == ERR_SUPERBLOCK_OK);
        inProcessCounter++;
        emit SuperblockClaimCreated(superblockHash, msg.sender, inProcessCounter);
        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    // @dev 每 challenge a superblock claim.
    // @param superblockHash 每 Id of the superblock to challenge.
    // @return - Error code and claim Id
    function challengeSuperblock(bytes32 superblockHash) external returns (uint, bytes32) {
        require(address(trustedSuperblocks) != address(0));

        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim)) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return (ERR_SUPERBLOCK_BAD_CLAIM, superblockHash);
        }
        if(claim.challengeDefended == true){
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CLAIM_ALREADY_DEFENDED);
            return (ERR_SUPERBLOCK_CLAIM_ALREADY_DEFENDED, superblockHash);           
        }
        if (claim.decided || claim.invalid) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CLAIM_DECIDED);
            return (ERR_SUPERBLOCK_CLAIM_DECIDED, superblockHash);
        }
        if (claim.verificationOngoing) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CHALLENGE_EXISTS);
            return (ERR_SUPERBLOCK_CHALLENGE_EXISTS, superblockHash);
        }
        if (deposits[msg.sender] < minProposalDeposit) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_MIN_DEPOSIT);
            return (ERR_SUPERBLOCK_MIN_DEPOSIT, superblockHash);
        }
    
        uint err = trustedSuperblocks.challenge(superblockHash, msg.sender);
        if (err != 0) {
            emit ErrorClaim(superblockHash, err);
            return (err, 0);
        }

        err = this.bondDeposit(superblockHash, msg.sender, minProposalDeposit);
        require(err == ERR_SUPERBLOCK_OK);

        claim.challengeTimeout = block.timestamp + superblockTimeout;
        claim.challenger = msg.sender;
        emit SuperblockClaimChallenged(superblockHash, msg.sender);

        trustedSyscoinBattleManager.beginBattleSession(superblockHash, claim.submitter,
            claim.challenger);

        emit VerificationGameStarted(superblockHash, claim.submitter,
            claim.challenger);

        claim.verificationOngoing = true;
        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    // @dev 每 confirm semi approved superblock.
    //
    // A semi approved superblock can be confirmed if it has several descendant
    // superblocks that are also semi-approved.
    // If none of the descendants were challenged they will also be confirmed.
    //
    // @param superblockHash 每 the claim ID.
    // @param descendantId - claim ID descendants
    function confirmClaim(bytes32 superblockHash, bytes32 descendantId) external returns (bool) {
        uint numSuperblocks = 0;
        bool confirmDescendants = true;
        bytes32 id = descendantId;
        SuperblockClaim storage claim = claims[id];
        while (id != superblockHash) {
            if (!claimExists(claim) || claim.invalid) {
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
                return false;
            }
            if (trustedSuperblocks.getSuperblockStatus(id) != SyscoinSuperblocksI.Status.SemiApproved) {
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
                return false;
            }
            if (confirmDescendants && claim.challenger != address(0)) {
                confirmDescendants = false;
            }
            id = trustedSuperblocks.getSuperblockParentId(id);
            claim = claims[id];
            numSuperblocks += 1;
        }

        if (numSuperblocks < superblockConfirmations) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_MISSING_CONFIRMATIONS);
            return false;
        }
        if (trustedSuperblocks.getSuperblockStatus(id) != SyscoinSuperblocksI.Status.SemiApproved) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return false;
        }

        uint err = trustedSuperblocks.confirm(superblockHash, msg.sender);
        if (err != ERR_SUPERBLOCK_OK) {
            emit ErrorClaim(superblockHash, err);
            return false;
        }
        doPaySubmitter(superblockHash, claim);

        if (confirmDescendants) {
            bytes32[] memory descendants = new bytes32[](numSuperblocks);
            id = descendantId;
            uint idx = 0;
            while (id != superblockHash) {
                descendants[idx] = id;
                id = trustedSuperblocks.getSuperblockParentId(id);
                idx += 1;
            }
            while (idx > 0) {
                idx -= 1;
                id = descendants[idx];
                claim = claims[id];
                err = trustedSuperblocks.confirm(id, msg.sender);
                require(err == ERR_SUPERBLOCK_OK);
                doPaySubmitter(id, claim);
                inProcessCounter--;
                emit SuperblockClaimSuccessful(id, claim.submitter, inProcessCounter);
            }
        }
        inProcessCounter--;
        emit SuperblockClaimSuccessful(superblockHash, claim.submitter, inProcessCounter);
        return true;
    }

    // @dev 每 Reject a semi approved superblock.
    //
    // Superblocks that are not in the main chain can be marked as
    // invalid.
    //
    // @param superblockHash 每 the claim ID.
    function rejectClaim(bytes32 superblockHash) external returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];
        if (!claimExists(claim)) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return false;
        }

        uint height = trustedSuperblocks.getSuperblockHeight(superblockHash);

        if (height > trustedSuperblocks.getChainHeight()) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_BLOCKHEIGHT);
            return false;
        }

        SyscoinSuperblocksI.Status status = trustedSuperblocks.getSuperblockStatus(superblockHash);

        if (status != SyscoinSuperblocksI.Status.SemiApproved) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return false;
        }

        if (!claim.decided) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CLAIM_DECIDED);
            return false;
        }

        uint err = trustedSuperblocks.invalidate(superblockHash, claim.submitter);
        require(err == ERR_SUPERBLOCK_OK);
        doPayChallenger(superblockHash, claim);
        claim.invalid = true;
        inProcessCounter--;
        emit SuperblockClaimFailed(superblockHash, claim.challenger, inProcessCounter);
        return true;
    }

    // @dev 每 check whether a claim has successfully withstood all challenges.
    // If successful without challenges, it will mark the superblock as confirmed.
    // If successful with at least one challenge, it will mark the superblock as semi-approved.
    // If verification failed, it will mark the superblock as invalid.
    //
    // @param superblockHash 每 claim ID.
    function checkClaimFinished(bytes32 superblockHash) external returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim) || claim.decided) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return false;
        }

        // check that there is no ongoing verification game.
        if (claim.verificationOngoing) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_VERIFICATION_PENDING);
            return false;
        }

        // an invalid superblock can be rejected immediately
        if (claim.invalid) {
            // The superblock is invalid, submitter abandoned
            // or superblock data is inconsistent
            claim.decided = true;
            uint err = trustedSuperblocks.invalidate(superblockHash, claim.submitter);
            require(err == ERR_SUPERBLOCK_OK);
            doPayChallenger(superblockHash, claim);
            inProcessCounter--;
            emit SuperblockClaimFailed(superblockHash, claim.challenger, inProcessCounter);
            return false;
        }

        // check that the claim has exceeded the claim's specific challenge timeout.
        if (block.timestamp <= claim.challengeTimeout) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_NO_TIMEOUT);
            return false;
        }

        claim.decided = true;

        bool confirmImmediately = false;
        // No challenger and parent approved; confirm immediately
        if (claim.challenger == address(0)) {
            bytes32 parentId = trustedSuperblocks.getSuperblockParentId(superblockHash);
            SyscoinSuperblocksI.Status status = trustedSuperblocks.getSuperblockStatus(parentId);
            if (status == SyscoinSuperblocksI.Status.Approved) {
                confirmImmediately = true;
            }
        }

        if (confirmImmediately) {
            uint err = trustedSuperblocks.confirm(superblockHash, msg.sender);
            require(err == ERR_SUPERBLOCK_OK);
            address submitter = claim.submitter;
            unbondDeposit(superblockHash, submitter);
            inProcessCounter--;
            emit SuperblockClaimSuccessful(superblockHash, submitter, inProcessCounter);
        } else {
            uint err = trustedSuperblocks.semiApprove(superblockHash, msg.sender);
            require(err == ERR_SUPERBLOCK_OK);
            emit SuperblockClaimPending(superblockHash, claim.submitter);
        }
        return true;
    }


    // @dev 每 called when a battle session has ended.
    //
    // @param superblockHash - claim Id
    // @param winner 每 winner of verification game.
    // @param loser 每 loser of verification game.
    function sessionDecided(bytes32 superblockHash, address winner, address loser) external onlyBattleManager {
        SuperblockClaim storage claim = claims[superblockHash];

        require(claimExists(claim));

        claim.verificationOngoing = false;
        address submitter = claim.submitter;

        if (submitter == loser) {
            claim.invalid = true;
        } else if (submitter == winner) {
            claim.challengeDefended = true;
        }
        else{
            revert();
        }
        emit SuperblockBattleDecided(superblockHash, winner, loser);
    }

    // @dev - Pay challenger 2 eth and 0.7 to previous submitters, leave 0.3 effectively unspendable
    function doPayChallenger(bytes32 superblockHash, SuperblockClaim storage claim) private {
        address challenger = claim.challenger;
        address submitter = claim.submitter;

        if (challenger != address(0) && submitter != address(0)) {
            uint reward = claim.bondedDeposits[submitter];
            reward -= 1000000000000000000; // 1 ether
            claim.bondedDeposits[challenger] = claim.bondedDeposits[challenger].add(reward);
            unbondDeposit(superblockHash, challenger);
            delete claim.bondedDeposits[submitter];
            // distribute 0.7 eth to last 7 approved superblock submitters (0.1 each)
            uint numPaid = 0;
            address prevSubmitter;
            SyscoinSuperblocksI.Status status;
            while (numPaid < 7) {
                (,,,,,superblockHash,prevSubmitter,status,) = trustedSuperblocks.getSuperblock(superblockHash);
                if(superblockHash == 0x0)
                    break;
                if (status != SyscoinSuperblocksI.Status.Approved) {
                    continue;
                }
                deposits[prevSubmitter] = deposits[prevSubmitter].add(100000000000000000); // 0.1 ether
                numPaid++;
            } 
        }
    }

    // @dev - Pay submitter with challenger deposit
    function doPaySubmitter(bytes32 superblockHash, SuperblockClaim storage claim) private {
        address challenger = claim.challenger;
        address submitter = claim.submitter;
        if (challenger != address(0)) {
            uint reward = claim.bondedDeposits[challenger];
            claim.bondedDeposits[submitter] = claim.bondedDeposits[submitter].add(reward);
            delete claim.bondedDeposits[challenger];
        }
        if (submitter != address(0)) {
            unbondDeposit(superblockHash, submitter);
        }
    }

    // @dev - Check if a superblock can be semi approved by calling checkClaimFinished
    function getInBattleAndSemiApprovable(bytes32 superblockHash) external view returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];
        return (trustedSuperblocks.getSuperblockStatus(superblockHash) == SyscoinSuperblocksI.Status.InBattle &&
            !claim.invalid && !claim.verificationOngoing && block.timestamp > claim.challengeTimeout
            && claim.challenger != address(0));
    }

    // @dev 每 Check if a claim exists
    function claimExists(SuperblockClaim storage claim) private view returns (bool) {
        return (claim.submitter != address(0));
    }

    // @dev - Return a given superblock's submitter
    function getClaimSubmitter(bytes32 superblockHash) external view returns (address) {
        return claims[superblockHash].submitter;
    }

    // @dev - Return superblock submission timestamp
    function getNewSuperblockEventTimestamp(bytes32 superblockHash) external view returns (uint) {
        return claims[superblockHash].createdAt;
    }

    // @dev - Return whether or not a claim has already been made
    function getClaimExists(bytes32 superblockHash) external view returns (bool) {
        return claimExists(claims[superblockHash]);
    }

    // @dev - Return claim status
    function getClaimDecided(bytes32 superblockHash) external view returns (bool) {
        return claims[superblockHash].decided;
    }

    // @dev - Check if a claim is invalid
    function getClaimInvalid(bytes32 superblockHash) external view returns (bool) {
        return claims[superblockHash].invalid;
    }


    function getClaimChallenger(bytes32 superblockHash) external view returns (address) {
        SuperblockClaim storage claim = claims[superblockHash];
        return claim.challenger;
    }
}