/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

/**
* https://tornado.cash
*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

// File: contracts/interfaces/IVerifier.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IVerifier {
  function verifyProof(bytes calldata proof, uint256[4] calldata input) external view returns (bool);

  function verifyProof(bytes calldata proof, uint256[7] calldata input) external view returns (bool);

  function verifyProof(bytes calldata proof, uint256[12] calldata input) external view returns (bool);
}

// File: contracts/interfaces/IRewardSwap.sol



pragma solidity ^0.6.0;

interface IRewardSwap {
  function swap(address recipient, uint256 amount) external returns (uint256);

  function setPoolWeight(uint256 newWeight) external;
}

// File: torn-token/contracts/ENS.sol



pragma solidity ^0.6.0;

interface ENS {
  function resolver(bytes32 node) external view returns (Resolver);
}

interface Resolver {
  function addr(bytes32 node) external view returns (address);
}

contract EnsResolve {
  function resolve(bytes32 node) public view virtual returns (address) {
    ENS Registry = ENS(
      getChainId() == 1 ? 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e : 0x8595bFb0D940DfEDC98943FA8a907091203f25EE
    );
    return Registry.resolver(node).addr(node);
  }

  function bulkResolve(bytes32[] memory domains) public view returns (address[] memory result) {
    result = new address[](domains.length);
    for (uint256 i = 0; i < domains.length; i++) {
      result[i] = resolve(domains[i]);
    }
  }

  function getChainId() internal pure returns (uint256) {
    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    return chainId;
  }
}

// File: @openzeppelin/contracts/GSN/Context.sol



pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/interfaces/IHasher.sol



pragma solidity ^0.6.0;

interface IHasher {
  function poseidon(bytes32[2] calldata inputs) external pure returns (bytes32);

  function poseidon(bytes32[3] calldata inputs) external pure returns (bytes32);
}

// File: contracts/utils/MerkleTreeWithHistory.sol



pragma solidity ^0.6.0;


contract MerkleTreeWithHistory {
  uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
  uint256 public constant ZERO_VALUE = 21663839004416932945382355908790599225266501822907911457504978515578255421292; // = keccak256("tornado") % FIELD_SIZE

  uint32 public immutable levels;
  IHasher public hasher; // todo immutable

  bytes32[] public filledSubtrees;
  bytes32[] public zeros;
  uint32 public currentRootIndex = 0;
  uint32 public nextIndex = 0;
  uint32 public constant ROOT_HISTORY_SIZE = 10;
  bytes32[ROOT_HISTORY_SIZE] public roots;

  constructor(uint32 _treeLevels, IHasher _hasher) public {
    require(_treeLevels > 0, "_treeLevels should be greater than zero");
    require(_treeLevels < 32, "_treeLevels should be less than 32");
    levels = _treeLevels;
    hasher = _hasher;

    bytes32 currentZero = bytes32(ZERO_VALUE);
    zeros.push(currentZero);
    filledSubtrees.push(currentZero);

    for (uint32 i = 1; i < _treeLevels; i++) {
      currentZero = hashLeftRight(currentZero, currentZero);
      zeros.push(currentZero);
      filledSubtrees.push(currentZero);
    }

    filledSubtrees.push(hashLeftRight(currentZero, currentZero));
    roots[0] = filledSubtrees[_treeLevels];
  }

  /**
    @dev Hash 2 tree leaves, returns poseidon(_left, _right)
  */
  function hashLeftRight(bytes32 _left, bytes32 _right) public view returns (bytes32) {
    return hasher.poseidon([_left, _right]);
  }

  function _insert(bytes32 _leaf) internal returns (uint32 index) {
    uint32 currentIndex = nextIndex;
    require(currentIndex != uint32(2)**levels, "Merkle tree is full. No more leaves can be added");
    nextIndex = currentIndex + 1;
    bytes32 currentLevelHash = _leaf;
    bytes32 left;
    bytes32 right;

    for (uint32 i = 0; i < levels; i++) {
      if (currentIndex % 2 == 0) {
        left = currentLevelHash;
        right = zeros[i];
        filledSubtrees[i] = currentLevelHash;
      } else {
        left = filledSubtrees[i];
        right = currentLevelHash;
      }

      currentLevelHash = hashLeftRight(left, right);
      currentIndex /= 2;
    }

    currentRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_SIZE;
    roots[currentRootIndex] = currentLevelHash;
    return nextIndex - 1;
  }

  function _bulkInsert(bytes32[] memory _leaves) internal {
    uint32 insertIndex = nextIndex;
    require(insertIndex + _leaves.length <= uint32(2)**levels, "Merkle doesn't have enough capacity to add specified leaves");

    bytes32[] memory subtrees = new bytes32[](levels);
    bool[] memory modifiedSubtrees = new bool[](levels);
    for (uint32 j = 0; j < _leaves.length - 1; j++) {
      uint256 index = insertIndex + j;
      bytes32 currentLevelHash = _leaves[j];

      for (uint32 i = 0; ; i++) {
        if (index % 2 == 0) {
          modifiedSubtrees[i] = true;
          subtrees[i] = currentLevelHash;
          break;
        }

        if(subtrees[i] == bytes32(0)) {
          subtrees[i] = filledSubtrees[i];
        }
        currentLevelHash = hashLeftRight(subtrees[i], currentLevelHash);
        index /= 2;
      }
    }

    for (uint32 i = 0; i < levels; i++) {
      // using local map to save on gas on writes if elements were not modified
      if (modifiedSubtrees[i]) {
        filledSubtrees[i] = subtrees[i];
      }
    }

    nextIndex = uint32(insertIndex + _leaves.length - 1);
    _insert(_leaves[_leaves.length - 1]);
  }

  /**
    @dev Whether the root is present in the root history
  */
  function isKnownRoot(bytes32 _root) public view returns (bool) {
    if (_root == 0) {
      return false;
    }
    uint32 i = currentRootIndex;
    do {
      if (_root == roots[i]) {
        return true;
      }
      if (i == 0) {
        i = ROOT_HISTORY_SIZE;
      }
      i--;
    } while (i != currentRootIndex);
    return false;
  }

  /**
    @dev Returns the last root
  */
  function getLastRoot() public view returns (bytes32) {
    return roots[currentRootIndex];
  }
}

// File: contracts/utils/OwnableMerkleTree.sol



pragma solidity ^0.6.0;



contract OwnableMerkleTree is Ownable, MerkleTreeWithHistory {
  constructor(uint32 _treeLevels, IHasher _hasher) public MerkleTreeWithHistory(_treeLevels, _hasher) {}

  function insert(bytes32 _leaf) external onlyOwner returns (uint32 index) {
    return _insert(_leaf);
  }

  function bulkInsert(bytes32[] calldata _leaves) external onlyOwner {
    _bulkInsert(_leaves);
  }
}

// File: contracts/interfaces/ITornadoTrees.sol



pragma solidity ^0.6.0;

interface ITornadoTrees {
  function registerDeposit(address instance, bytes32 commitment) external;

  function registerWithdrawal(address instance, bytes32 nullifier) external;
}

// File: contracts/TornadoTrees.sol



pragma solidity ^0.6.0;





contract TornadoTrees is ITornadoTrees, EnsResolve {
  OwnableMerkleTree public immutable depositTree;
  OwnableMerkleTree public immutable withdrawalTree;
  IHasher public immutable hasher;
  address public immutable tornadoProxy;

  bytes32[] public deposits;
  uint256 public lastProcessedDepositLeaf;

  bytes32[] public withdrawals;
  uint256 public lastProcessedWithdrawalLeaf;

  event DepositData(address instance, bytes32 indexed hash, uint256 block, uint256 index);
  event WithdrawalData(address instance, bytes32 indexed hash, uint256 block, uint256 index);

  struct TreeLeaf {
    address instance;
    bytes32 hash;
    uint256 block;
  }

  modifier onlyTornadoProxy {
    require(msg.sender == tornadoProxy, "Not authorized");
    _;
  }

  constructor(
    bytes32 _tornadoProxy,
    bytes32 _hasher2,
    bytes32 _hasher3,
    uint32 _levels
  ) public {
    tornadoProxy = resolve(_tornadoProxy);
    hasher = IHasher(resolve(_hasher3));
    depositTree = new OwnableMerkleTree(_levels, IHasher(resolve(_hasher2)));
    withdrawalTree = new OwnableMerkleTree(_levels, IHasher(resolve(_hasher2)));
  }

  function registerDeposit(address _instance, bytes32 _commitment) external override onlyTornadoProxy {
    deposits.push(keccak256(abi.encode(_instance, _commitment, blockNumber())));
  }

  function registerWithdrawal(address _instance, bytes32 _nullifier) external override onlyTornadoProxy {
    withdrawals.push(keccak256(abi.encode(_instance, _nullifier, blockNumber())));
  }

  function updateRoots(TreeLeaf[] calldata _deposits, TreeLeaf[] calldata _withdrawals) external {
    if (_deposits.length > 0) updateDepositTree(_deposits);
    if (_withdrawals.length > 0) updateWithdrawalTree(_withdrawals);
  }

  function updateDepositTree(TreeLeaf[] calldata _deposits) public {
    bytes32[] memory leaves = new bytes32[](_deposits.length);
    uint256 offset = lastProcessedDepositLeaf;

    for (uint256 i = 0; i < _deposits.length; i++) {
      TreeLeaf memory deposit = _deposits[i];
      bytes32 leafHash = keccak256(abi.encode(deposit.instance, deposit.hash, deposit.block));
      require(deposits[offset + i] == leafHash, "Incorrect deposit");

      leaves[i] = hasher.poseidon([bytes32(uint256(deposit.instance)), deposit.hash, bytes32(deposit.block)]);
      delete deposits[offset + i];

      emit DepositData(deposit.instance, deposit.hash, deposit.block, offset + i);
    }

    lastProcessedDepositLeaf = offset + _deposits.length;
    depositTree.bulkInsert(leaves);
  }

  function updateWithdrawalTree(TreeLeaf[] calldata _withdrawals) public {
    bytes32[] memory leaves = new bytes32[](_withdrawals.length);
    uint256 offset = lastProcessedWithdrawalLeaf;

    for (uint256 i = 0; i < _withdrawals.length; i++) {
      TreeLeaf memory withdrawal = _withdrawals[i];
      bytes32 leafHash = keccak256(abi.encode(withdrawal.instance, withdrawal.hash, withdrawal.block));
      require(withdrawals[offset + i] == leafHash, "Incorrect withdrawal");

      leaves[i] = hasher.poseidon([bytes32(uint256(withdrawal.instance)), withdrawal.hash, bytes32(withdrawal.block)]);
      delete withdrawals[offset + i];

      emit WithdrawalData(withdrawal.instance, withdrawal.hash, withdrawal.block, offset + i);
    }

    lastProcessedWithdrawalLeaf = offset + _withdrawals.length;
    withdrawalTree.bulkInsert(leaves);
  }

  function validateRoots(bytes32 _depositRoot, bytes32 _withdrawalRoot) public view {
    require(depositTree.isKnownRoot(_depositRoot), "Incorrect deposit tree root");
    require(withdrawalTree.isKnownRoot(_withdrawalRoot), "Incorrect withdrawal tree root");
  }

  function depositRoot() external view returns (bytes32) {
    return depositTree.getLastRoot();
  }

  function withdrawalRoot() external view returns (bytes32) {
    return withdrawalTree.getLastRoot();
  }

  function getRegisteredDeposits() external view returns (bytes32[] memory _deposits) {
    uint256 count = deposits.length - lastProcessedDepositLeaf;
    _deposits = new bytes32[](count);
    for (uint256 i = 0; i < count; i++) {
      _deposits[i] = deposits[lastProcessedDepositLeaf + i];
    }
  }

  function getRegisteredWithdrawals() external view returns (bytes32[] memory _withdrawals) {
    uint256 count = withdrawals.length - lastProcessedWithdrawalLeaf;
    _withdrawals = new bytes32[](count);
    for (uint256 i = 0; i < count; i++) {
      _withdrawals[i] = withdrawals[lastProcessedWithdrawalLeaf + i];
    }
  }

  function blockNumber() public view virtual returns (uint256) {
    return block.number;
  }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity ^0.6.0;

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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/Miner.sol



pragma solidity ^0.6.0;







contract Miner is EnsResolve {
  using SafeMath for uint256;

  IVerifier public rewardVerifier;
  IVerifier public withdrawVerifier;
  IVerifier public treeUpdateVerifier;
  IRewardSwap public immutable rewardSwap;
  address public immutable governance;
  TornadoTrees public tornadoTrees;

  mapping(bytes32 => bool) public accountNullifiers;
  mapping(bytes32 => bool) public rewardNullifiers;
  mapping(address => uint256) public rates;

  uint256 public accountCount;
  uint256 public constant ACCOUNT_ROOT_HISTORY_SIZE = 100;
  bytes32[ACCOUNT_ROOT_HISTORY_SIZE] public accountRoots;

  event NewAccount(bytes32 commitment, bytes32 nullifier, bytes encryptedAccount, uint256 index);
  event RateChanged(address instance, uint256 value);
  event VerifiersUpdated(address reward, address withdraw, address treeUpdate);

  struct TreeUpdateArgs {
    bytes32 oldRoot;
    bytes32 newRoot;
    bytes32 leaf;
    uint256 pathIndices;
  }

  struct AccountUpdate {
    bytes32 inputRoot;
    bytes32 inputNullifierHash;
    bytes32 outputRoot;
    uint256 outputPathIndices;
    bytes32 outputCommitment;
  }

  struct RewardExtData {
    address relayer;
    bytes encryptedAccount;
  }

  struct RewardArgs {
    uint256 rate;
    uint256 fee;
    address instance;
    bytes32 rewardNullifier;
    bytes32 extDataHash;
    bytes32 depositRoot;
    bytes32 withdrawalRoot;
    RewardExtData extData;
    AccountUpdate account;
  }

  struct WithdrawExtData {
    uint256 fee;
    address recipient;
    address relayer;
    bytes encryptedAccount;
  }

  struct WithdrawArgs {
    uint256 amount;
    bytes32 extDataHash;
    WithdrawExtData extData;
    AccountUpdate account;
  }

  struct Rate {
    bytes32 instance;
    uint256 value;
  }

  modifier onlyGovernance() {
    require(msg.sender == governance, "Only governance can perform this action");
    _;
  }

  constructor(
    bytes32 _rewardSwap,
    bytes32 _governance,
    bytes32 _tornadoTrees,
    bytes32[3] memory _verifiers,
    bytes32 _accountRoot,
    Rate[] memory _rates
  ) public {
    rewardSwap = IRewardSwap(resolve(_rewardSwap));
    governance = resolve(_governance);
    tornadoTrees = TornadoTrees(resolve(_tornadoTrees));

    // insert empty tree root without incrementing accountCount counter
    accountRoots[0] = _accountRoot;

    _setRates(_rates);
    // prettier-ignore
    _setVerifiers([
      IVerifier(resolve(_verifiers[0])),
      IVerifier(resolve(_verifiers[1])),
      IVerifier(resolve(_verifiers[2]))
    ]);
  }

  function reward(bytes memory _proof, RewardArgs memory _args) public {
    reward(_proof, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function batchReward(bytes[] calldata _rewardArgs) external {
    for (uint256 i = 0; i < _rewardArgs.length; i++) {
      (bytes memory proof, RewardArgs memory args) = abi.decode(_rewardArgs[i], (bytes, RewardArgs));
      reward(proof, args);
    }
  }

  function reward(
    bytes memory _proof,
    RewardArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public {
    validateAccountUpdate(_args.account, _treeUpdateProof, _treeUpdateArgs);
    tornadoTrees.validateRoots(_args.depositRoot, _args.withdrawalRoot);
    require(_args.extDataHash == keccak248(abi.encode(_args.extData)), "Incorrect external data hash");
    require(_args.fee < 2**248, "Fee value out of range");
    require(_args.rate == rates[_args.instance] && _args.rate > 0, "Invalid reward rate");
    require(!rewardNullifiers[_args.rewardNullifier], "Reward has been already spent");
    require(
      rewardVerifier.verifyProof(
        _proof,
        [
          uint256(_args.rate),
          uint256(_args.fee),
          uint256(_args.instance),
          uint256(_args.rewardNullifier),
          uint256(_args.extDataHash),
          uint256(_args.account.inputRoot),
          uint256(_args.account.inputNullifierHash),
          uint256(_args.account.outputRoot),
          uint256(_args.account.outputPathIndices),
          uint256(_args.account.outputCommitment),
          uint256(_args.depositRoot),
          uint256(_args.withdrawalRoot)
        ]
      ),
      "Invalid reward proof"
    );

    accountNullifiers[_args.account.inputNullifierHash] = true;
    rewardNullifiers[_args.rewardNullifier] = true;
    insertAccountRoot(_args.account.inputRoot == getLastAccountRoot() ? _args.account.outputRoot : _treeUpdateArgs.newRoot);
    if (_args.fee > 0) {
      rewardSwap.swap(_args.extData.relayer, _args.fee);
    }

    emit NewAccount(
      _args.account.outputCommitment,
      _args.account.inputNullifierHash,
      _args.extData.encryptedAccount,
      accountCount - 1
    );
  }

  function withdraw(bytes memory _proof, WithdrawArgs memory _args) public {
    withdraw(_proof, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function withdraw(
    bytes memory _proof,
    WithdrawArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public {
    validateAccountUpdate(_args.account, _treeUpdateProof, _treeUpdateArgs);
    require(_args.extDataHash == keccak248(abi.encode(_args.extData)), "Incorrect external data hash");
    require(_args.amount < 2**248, "Amount value out of range");
    require(
      withdrawVerifier.verifyProof(
        _proof,
        [
          uint256(_args.amount),
          uint256(_args.extDataHash),
          uint256(_args.account.inputRoot),
          uint256(_args.account.inputNullifierHash),
          uint256(_args.account.outputRoot),
          uint256(_args.account.outputPathIndices),
          uint256(_args.account.outputCommitment)
        ]
      ),
      "Invalid withdrawal proof"
    );

    insertAccountRoot(_args.account.inputRoot == getLastAccountRoot() ? _args.account.outputRoot : _treeUpdateArgs.newRoot);
    accountNullifiers[_args.account.inputNullifierHash] = true;
    // allow submitting noop withdrawals (amount == 0)
    uint256 amount = _args.amount.sub(_args.extData.fee, "Amount should be greater than fee");
    if (amount > 0) {
      rewardSwap.swap(_args.extData.recipient, amount);
    }
    // Note. The relayer swap rate always will be worse than estimated
    if (_args.extData.fee > 0) {
      rewardSwap.swap(_args.extData.relayer, _args.extData.fee);
    }

    emit NewAccount(
      _args.account.outputCommitment,
      _args.account.inputNullifierHash,
      _args.extData.encryptedAccount,
      accountCount - 1
    );
  }

  function setRates(Rate[] memory _rates) external onlyGovernance {
    _setRates(_rates);
  }

  function setVerifiers(IVerifier[3] calldata _verifiers) external onlyGovernance {
    _setVerifiers(_verifiers);
  }

  function setTornadoTreesContract(TornadoTrees _tornadoTrees) external onlyGovernance {
    tornadoTrees = _tornadoTrees;
  }

  function setPoolWeight(uint256 _newWeight) external onlyGovernance {
    rewardSwap.setPoolWeight(_newWeight);
  }

  // ------VIEW-------

  /**
    @dev Whether the root is present in the root history
    */
  function isKnownAccountRoot(bytes32 _root, uint256 _index) public view returns (bool) {
    return _root != 0 && accountRoots[_index % ACCOUNT_ROOT_HISTORY_SIZE] == _root;
  }

  /**
    @dev Returns the last root
    */
  function getLastAccountRoot() public view returns (bytes32) {
    return accountRoots[accountCount % ACCOUNT_ROOT_HISTORY_SIZE];
  }

  // -----INTERNAL-------

  function keccak248(bytes memory _data) internal pure returns (bytes32) {
    return keccak256(_data) & 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  }

  function validateTreeUpdate(
    bytes memory _proof,
    TreeUpdateArgs memory _args,
    bytes32 _commitment
  ) internal view {
    require(_proof.length > 0, "Outdated account merkle root");
    require(_args.oldRoot == getLastAccountRoot(), "Outdated tree update merkle root");
    require(_args.leaf == _commitment, "Incorrect commitment inserted");
    require(_args.pathIndices == accountCount, "Incorrect account insert index");
    require(
      treeUpdateVerifier.verifyProof(
        _proof,
        [uint256(_args.oldRoot), uint256(_args.newRoot), uint256(_args.leaf), uint256(_args.pathIndices)]
      ),
      "Invalid tree update proof"
    );
  }

  function validateAccountUpdate(
    AccountUpdate memory _account,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) internal view {
    require(!accountNullifiers[_account.inputNullifierHash], "Outdated account state");
    if (_account.inputRoot != getLastAccountRoot()) {
      // _account.outputPathIndices (= last tree leaf index) is always equal to root index in the history mapping
      // because we always generate a new root for each new leaf
      require(isKnownAccountRoot(_account.inputRoot, _account.outputPathIndices), "Invalid account root");
      validateTreeUpdate(_treeUpdateProof, _treeUpdateArgs, _account.outputCommitment);
    } else {
      require(_account.outputPathIndices == accountCount, "Incorrect account insert index");
    }
  }

  function insertAccountRoot(bytes32 _root) internal {
    accountRoots[++accountCount % ACCOUNT_ROOT_HISTORY_SIZE] = _root;
  }

  function _setRates(Rate[] memory _rates) internal {
    for (uint256 i = 0; i < _rates.length; i++) {
      require(_rates[i].value < 2**128, "Incorrect rate");
      address instance = resolve(_rates[i].instance);
      rates[instance] = _rates[i].value;
      emit RateChanged(instance, _rates[i].value);
    }
  }

  function _setVerifiers(IVerifier[3] memory _verifiers) internal {
    rewardVerifier = _verifiers[0];
    withdrawVerifier = _verifiers[1];
    treeUpdateVerifier = _verifiers[2];
    emit VerifiersUpdated(address(_verifiers[0]), address(_verifiers[1]), address(_verifiers[2]));
  }
}