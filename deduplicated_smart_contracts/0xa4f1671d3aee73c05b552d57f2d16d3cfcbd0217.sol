/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

// SPDX-License-Identifier: MIT

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

// File: contracts/Owned.sol



pragma solidity 0.6.12;


// Requried one small change in openzeppelin version of ownable, so imported
// source code here. Notice line 26 for change.

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
    /**
     * @dev Changed _owner from 'private' to 'internal'
     */
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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

/**
 * @dev Contract module extends Ownable and provide a way for safe transfer ownership.
 * New owner has to call acceptOwnership in order to complete ownership trasnfer.
 */
contract Owned is Ownable {
    address private _newOwner;

    /**
     * @dev Initiate transfer ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner. Current owner will still be owner until
     * new owner accept ownership.
     * @param newOwner new owner address
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _newOwner = newOwner;
    }

    /**
     * @dev Allows new owner to accept ownership of the contract.
     */
    function acceptOwnership() public {
        require(msg.sender == _newOwner, "Caller is not the new owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

// File: contracts/interfaces/vesper/IVesperPool.sol



pragma solidity 0.6.12;


interface IVesperPool is IERC20 {
    function approveToken() external;

    function deposit() external payable;

    function deposit(uint256) external;

    function multiTransfer(uint256[] memory) external returns (bool);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function rebalance() external;

    function resetApproval() external;

    function sweepErc20(address) external;

    function withdraw(uint256) external;

    function withdrawETH(uint256) external;

    function withdrawByStrategy(uint256) external;

    function feeCollector() external view returns (address);

    function getPricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);
}

// File: contracts/interfaces/vesper/IStrategy.sol



pragma solidity 0.6.12;

interface IStrategy {
    function rebalance() external;

    function deposit(uint256 amount) external;

    function beforeWithdraw() external;

    function withdraw(uint256 amount) external;

    function withdrawAll() external;

    function isUpgradable() external view returns (bool);

    function isReservedToken(address _token) external view returns (bool);

    function token() external view returns (address);

    function pool() external view returns (address);

    function totalLocked() external view returns (uint256);

    //Lifecycle functions
    function pause() external;

    function unpause() external;
}

// File: contracts/interfaces/vesper/IPoolRewards.sol



pragma solidity 0.6.12;

interface IPoolRewards {
    function notifyRewardAmount(uint256) external;

    function claimReward(address) external;

    function updateReward(address) external;

    function rewardForDuration() external view returns (uint256);

    function claimable(address) external view returns (uint256);

    function pool() external view returns (address);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);
}

// File: sol-address-list/contracts/interfaces/IAddressList.sol



pragma solidity ^0.6.6;

interface IAddressList {
    event AddressUpdated(address indexed a, address indexed sender);
    event AddressRemoved(address indexed a, address indexed sender);

    function add(address a) external returns (bool);

    function addValue(address a, uint256 v) external returns (bool);

    function addMulti(address[] calldata addrs) external returns (uint256);

    function addValueMulti(address[] calldata addrs, uint256[] calldata values) external returns (uint256);

    function remove(address a) external returns (bool);

    function removeMulti(address[] calldata addrs) external returns (uint256);

    function get(address a) external view returns (uint256);

    function contains(address a) external view returns (bool);

    function at(uint256 index) external view returns (address, uint256);

    function length() external view returns (uint256);
}

// File: sol-address-list/contracts/interfaces/IAddressListFactory.sol



pragma solidity ^0.6.6;

interface IAddressListFactory {
    event ListCreated(address indexed _sender, address indexed _newList);

    function ours(address a) external view returns (bool);

    function listCount() external view returns (uint256);

    function listAt(uint256 idx) external view returns (address);

    function createList() external returns (address listaddr);
}

// File: contracts/Controller.sol



pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;









contract Controller is Owned {
    using SafeMath for uint256;

    // Pool specific params
    mapping(address => uint256) public withdrawFee;
    mapping(address => uint256) public interestFee;
    mapping(address => address) public feeCollector;
    mapping(address => uint256) public rebalanceFriction;
    mapping(address => address) public strategy;
    mapping(address => address) public poolRewards;
    uint16 public aaveReferralCode;
    address public founderVault;
    uint256 public founderFee = 5e16;
    address public treasuryPool;
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IAddressList public immutable pools;

    constructor() public {
        IAddressListFactory addressFactory =
            IAddressListFactory(0xD57b41649f822C51a73C44Ba0B3da4A880aF0029);
        pools = IAddressList(addressFactory.createList());
    }

    modifier validPool(address pool) {
        require(pools.contains(pool), "Not a valid pool");
        _;
    }

    /**
     * @dev Add new pool in vesper system
     * @param _pool Address of new pool
     */
    function addPool(address _pool) external onlyOwner {
        require(_pool != address(0), "invalid-pool");
        IERC20 pool = IERC20(_pool);
        require(pool.totalSupply() == 0, "Zero supply required");
        pools.add(_pool);
    }

    /**
     * @dev Remove pool from vesper system
     * @param _pool Address of pool to be removed
     */
    function removePool(address _pool) external onlyOwner {
        IERC20 pool = IERC20(_pool);
        require(pool.totalSupply() == 0, "Zero supply required");
        pools.remove(_pool);
    }

    /**
     * @dev Execute transaction in given target contract
     * @param target Address of target contract
     * @param value Ether amount to transfer
     * @param signature Signature of function in target contract
     * @param data Encoded data for function call
     */
    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) external payable onlyOwner returns (bytes memory) {
        return _executeTransaction(target, value, signature, data);
    }

    /// @dev Execute multiple transactions.
    function executeTransactions(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas
    ) external payable onlyOwner {
        require(targets.length != 0, "Must provide actions");
        require(
            targets.length == values.length &&
                targets.length == signatures.length &&
                targets.length == calldatas.length,
            "Transaction data mismatch"
        );

        for (uint256 i = 0; i < targets.length; i++) {
            _executeTransaction(targets[i], values[i], signatures[i], calldatas[i]);
        }
    }

    function updateAaveReferralCode(uint16 referralCode) external onlyOwner {
        aaveReferralCode = referralCode;
    }

    function updateFeeCollector(address _pool, address _collector)
        external
        onlyOwner
        validPool(_pool)
    {
        require(_collector != address(0), "invalid-collector");
        require(feeCollector[_pool] != _collector, "same-collector");
        feeCollector[_pool] = _collector;
    }

    function updateFounderVault(address _founderVault) external onlyOwner {
        founderVault = _founderVault;
    }

    function updateFounderFee(uint256 _founderFee) external onlyOwner {
        require(founderFee != _founderFee, "same-founderFee");
        require(_founderFee <= 1e18, "founderFee-above-100%");
        founderFee = _founderFee;
    }

    function updateInterestFee(address _pool, uint256 _interestFee) external onlyOwner {
        require(_interestFee <= 1e18, "Fee limit reached");
        require(feeCollector[_pool] != address(0), "FeeCollector not set");
        interestFee[_pool] = _interestFee;
    }

    function updateStrategy(address _pool, address _newStrategy)
        external
        onlyOwner
        validPool(_pool)
    {
        require(_newStrategy != address(0), "invalid-strategy-address");
        address currentStrategy = strategy[_pool];
        require(currentStrategy != _newStrategy, "same-pool-strategy");
        require(IStrategy(_newStrategy).pool() == _pool, "wrong-pool");
        IVesperPool vpool = IVesperPool(_pool);
        if (currentStrategy != address(0)) {
            require(IStrategy(currentStrategy).isUpgradable(), "strategy-is-not-upgradable");
            vpool.resetApproval();
        }
        strategy[_pool] = _newStrategy;
        vpool.approveToken();
    }

    function updateRebalanceFriction(address _pool, uint256 _f)
        external
        onlyOwner
        validPool(_pool)
    {
        require(rebalanceFriction[_pool] != _f, "same-friction");
        rebalanceFriction[_pool] = _f;
    }

    function updatePoolRewards(address _pool, address _poolRewards)
        external
        onlyOwner
        validPool(_pool)
    {
        require(IPoolRewards(_poolRewards).pool() == _pool, "wrong-pool");
        poolRewards[_pool] = _poolRewards;
    }

    function updateTreasuryPool(address _pool) external onlyOwner validPool(_pool) {
        treasuryPool = _pool;
    }

    function updateUniswapRouter(address _uniswapRouter) external onlyOwner {
        uniswapRouter = _uniswapRouter;
    }

    function updateWithdrawFee(address _pool, uint256 _newWithdrawFee)
        external
        onlyOwner
        validPool(_pool)
    {
        require(_newWithdrawFee <= 1e18, "withdraw-fee-limit-reached");
        require(withdrawFee[_pool] != _newWithdrawFee, "same-withdraw-fee");
        require(feeCollector[_pool] != address(0), "FeeCollector-not-set");
        withdrawFee[_pool] = _newWithdrawFee;
    }

    function isPool(address _pool) external view returns (bool) {
        return pools.contains(_pool);
    }

    function _executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) internal onlyOwner returns (bytes memory) {
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Transaction execution reverted.");
        return returnData;
    }
}