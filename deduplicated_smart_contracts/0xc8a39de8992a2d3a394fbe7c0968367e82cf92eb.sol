/**
 *Submitted for verification at Etherscan.io on 2020-07-28
*/

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

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

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


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
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.5.0;


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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;




contract PauserRole is Initializable, Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {
        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;




/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Initializable, Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    function initialize(address sender) public initializer {
        PauserRole.initialize(sender);

        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/ITraderPaired.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;

interface ITraderPaired {

    /// @dev Invest
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _token token address
    /// @param _amount amount to invest
    /// @return investment id
    function invest(address _traderAddress, address _investorAddress, address _token, uint256 _amount) 
        external
        returns (uint256);

    /// @dev Trader/Investor stops an investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _from initiator address
    /// @param _investmentId investment id
    function stop(address _traderAddress, address _investorAddress, address _from, uint256 _investmentId) 
        external;

    /// @dev Investor requests to exit an investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    function requestExitInvestor(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value) 
        external;
    
    /// @dev Trader requests to exit an investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    /// @param _amount transaction amount
    function requestExitTrader(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value, uint256 _amount) 
        external;

    /// @dev Approve exit of investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _token token address
    /// @param _amount transaction amount
    function approveExit(address _traderAddress, address _investorAddress, uint256 _investmentId, address _token, uint256 _amount) 
        external
        returns (uint256[3] memory);

    /// @dev Reject exit of investment
    /// @param _traderAddress trader address
    /// @param _investmentId investment id
    /// @param _value proposed investment value
    /// @param _from initiator address
    function rejectExit(address _traderAddress, uint256 _investmentId, uint256 _value, address _from)
        external;
}

// File: contracts/IPairedInvestments.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;

interface IPairedInvestments {

    /// @dev New investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _token token address
    /// @param _amount amount to invest
    /// @return investment id and start date
    function invest(address _traderAddress, address _investorAddress, address _token, uint256 _amount) 
        external 
        returns(uint256, uint256);

    /// @dev Stop investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @return end date
    function stop(address _traderAddress, address _investorAddress, uint256 _investmentId) 
        external 
        returns (uint256);

    /// @dev Investor requests investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    function requestExitInvestor(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value) 
        external;

    /// @dev Trader requests investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    /// @param _amount transaction amount
    function requestExitTrader(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value, uint256 _amount) 
        external;

    /// @dev Approve investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _amount transaction amount
    /// @return array with: trader payout, investor payout, fee payout, original investment amount
    function approveExit(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _amount) 
        external  
        returns (uint256[4] memory);

    /// @dev Reject an exit request
    /// @param _traderAddress trader address
    /// @param _investmentId investment id
    /// @param _value proposed investment value
    function rejectExit(address _traderAddress, uint256 _investmentId, uint256 _value) 
        external;


    /// @dev Calculate investment profits and fees
    /// @param _value investment value
    /// @param _amount original investment amount
    /// @param _traderFeePercent trader fee percent
    /// @param _investorFeePercent investor fee percent
    /// @param _investorProfitPercent investor profit percent
    /// @return array with: trader fee, investor fee, trader profit, investor profit
    function calculateProfitsAndFees(
		uint256 _value,
		uint256 _amount,
		uint256 _traderFeePercent,
		uint256 _investorFeePercent,
		uint256 _investorProfitPercent
	) 
        external 
        pure 
        returns (uint256, uint256, uint256, uint256);
}

// File: contracts/IFactory.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;

interface IFactory {

    function isInstantiation(address _instantiation)
    	external
    	view
    	returns (bool);

    function getInstantiations(address creator)
        external
        view
        returns (address[] memory);
}

// File: contracts/IMultiSigFundWalletFactory.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;


interface IMultiSigFundWalletFactory {

    /// @dev Create a new multisig wallet
    /// @param _fund Fund address
    /// @param _investor Investor address
    /// @param _admin Wallet admin address
    /// @return new wallet address
    function create(address _fund, address _investor, address _admin)
        external
        returns (address);
}

// File: contracts/IMultiSigFundWallet.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;

interface IMultiSigFundWallet {

	/// @dev get trader status
    function traders(address _trader)
        external
        view
        returns (bool);
}

// File: contracts/TraderPaired.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;











contract TraderPaired is Initializable, Ownable, Pausable, ITraderPaired {
	using SafeMath for uint256;

    /*
     *  Constants
     */
    address constant ETHER = address(0); // allows storage of ether in blank address in token mapping
    address public feeAccount; // account that will receive fees

    /*
     *  Storage
     */
    mapping(address => _Trader) public traders;
    mapping(address => _Investor) public investors;

    address public multiSigFundWalletFactory;
    address public pairedInvestments;

    mapping(address => bool) public tokens;

    mapping(address => mapping(uint256 => uint256)) public traderInvestments;
    mapping(address => mapping(uint256 => uint256)) public investorInvestments;
    mapping(address => mapping(address => _Allocation)) public allocations;

    mapping(uint256 => address) public traderAddresses;
    mapping(uint256 => address) public investorAddresses;

    uint256 public traderCount;
    uint256 public investorCount;

    /*
     *  Events
     */
    event Trader(address indexed user, uint256 traderId, uint256 date);
    event Investor(address indexed user, uint256 investorId, uint256 date);
    event Investment(address indexed wallet, address indexed investor, uint256 date);
    event Allocate(address indexed trader, address indexed token, uint256 total, uint256 invested, uint256 date);
    event Invest(uint256 id, address indexed wallet, address indexed trader, address indexed investor, address token, uint256 amount, uint256 allocationInvested, uint256 allocationTotal, uint256 date);
    event Stop(uint256 id, address indexed wallet, address indexed trader, address indexed investor, address from, uint256 date);
    event RequestExit(uint256 id, address indexed wallet, address indexed trader, address indexed investor, address from, uint256 value, uint256 date);
    event ApproveExit(uint256 id, address indexed wallet, address indexed trader, address indexed investor, uint256 allocationInvested, uint256 allocationTotal, uint256 date);
    event RejectExit(uint256 id, address indexed wallet, address indexed trader, uint256 value, address from, uint256 date);

    /*
     *  Structs
     */
    struct _Trader {
        address user;
        uint256 investmentCount;
    }

    struct _Allocation {
        uint256 total;
        uint256 invested;
    }

    struct _Investor {
        address user;
        uint256 investmentCount;
    }

    /*
     *  Modifiers
     */
    modifier isTrader(address trader) {
        require(trader != address(0) && traders[trader].user == trader);
        _;
    }

    modifier isInvestor(address investor) {
        require(investor != address(0) && investors[investor].user == investor);
        _;
    }

    modifier notInvested(address trader, address investor) {
        require(!isInvested(trader, investor));
        _;
    }

    modifier onlyWallet {
        require(IFactory(multiSigFundWalletFactory).isInstantiation(msg.sender));
        _;
    }

    /// @dev Initialize
    /// @param _feeAccount fee account
    function initialize(address _feeAccount) 
        public 
        initializer 
    {
        Ownable.initialize(msg.sender);
        Pausable.initialize(msg.sender);
        feeAccount = _feeAccount;
    }

    /// @dev set MultiSigFundWalletFactory
    /// @param _factory contract address
    function setMultiSigFundWalletFactory(address _factory) 
        public 
        onlyOwner 
    {
        multiSigFundWalletFactory = _factory;
    }

    /// @dev set PairedInvestments
    /// @param _pairedInvestments contract address
    function setPairedInvestments(address _pairedInvestments) 
        public 
        onlyOwner 
    {
        pairedInvestments = _pairedInvestments;
    }

    /// @dev reverts if ether is sent directly
    function () external {
        revert();
    }

    /// @dev activate/deactivate token
    /// @param _token token address
    /// @param _valid active or not
    function setToken(address _token, bool _valid) 
        external 
        onlyOwner 
    {
        tokens[_token] = _valid;
    }

    /// @dev Join as trader
    function joinAsTrader() 
        external 
        whenNotPaused 
    {
        require(traders[msg.sender].user == address(0));
        require(investors[msg.sender].user == address(0));

        traders[msg.sender] = _Trader({
            user: msg.sender, 
            investmentCount: 0
        });

        traderCount = traderCount.add(1);
        traderAddresses[traderCount] = msg.sender;

        emit Trader(msg.sender, traderCount, now);
    }

    /// @dev Join as investor
    function joinAsInvestor() 
        external 
        whenNotPaused 
    {
        require(traders[msg.sender].user == address(0));
        require(investors[msg.sender].user == address(0));

        investors[msg.sender] = _Investor({
            user: msg.sender,
            investmentCount: 0
        });

        investorCount = investorCount.add(1);
        investorAddresses[investorCount] = msg.sender;

        emit Investor(msg.sender, investorCount, now);
    }

    /// @dev Allocate amount of tokens
    /// @param _token token address
    /// @param _amount amount to allocate
    function allocate(address _token, uint256 _amount) 
        external 
        whenNotPaused 
    {
        require(tokens[_token]);
        _Trader memory _trader = traders[msg.sender];
        require(_trader.user == msg.sender);

        allocations[msg.sender][_token].total = _amount;

        emit Allocate(msg.sender, _token, _amount, allocations[msg.sender][_token].invested, now);
    }

    /// @dev Checks if investor is invested with trader
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @return invested
    function isInvested(address _traderAddress, address _investorAddress) 
        internal
        view
        returns (bool) 
    {
        address[] memory wallets = IFactory(multiSigFundWalletFactory).getInstantiations(_investorAddress);
        
        for(uint256 i = 0; i < wallets.length; i++) {
            if (IMultiSigFundWallet(wallets[i]).traders(_traderAddress)) {
                return true;
            }
        }

        return false;
    }

    /// @dev Checks if investor has a wallet
    /// @param _investorAddress investor address
    /// @return has wallet
    function hasWallet(address _investorAddress) 
        internal
        view
        returns (bool) 
    {
        return IFactory(multiSigFundWalletFactory).isInstantiation(_investorAddress);
    }

    /// @dev Create new investment wallet
    function createInvestment() 
        external
        whenNotPaused
        isInvestor(msg.sender)
    {
        require(!hasWallet(msg.sender));
        address wallet = IMultiSigFundWalletFactory(multiSigFundWalletFactory).create(address(this), msg.sender, feeAccount);
        emit Investment(wallet, msg.sender, now);
    }

    /// @dev Invest
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _token token address
    /// @param _amount amount to invest
    /// @return investment id
    function invest(address _traderAddress, address _investorAddress, address _token, uint256 _amount) 
        public 
        whenNotPaused 
        onlyWallet 
        returns (uint256 investmentCount)
    {
        require(tokens[_token]);
        _Investor storage _investor = investors[_investorAddress];
        require(_investor.user == _investorAddress);

        _Trader storage _trader = traders[_traderAddress];
        require(_trader.user == _traderAddress);

        _Allocation storage allocation = allocations[_trader.user][_token];

        // falls within trader allocations
        require(allocation.total - allocation.invested >= _amount);
        allocation.invested = allocation.invested.add(_amount);

        uint256 starttime;
        (investmentCount, starttime) = IPairedInvestments(pairedInvestments).invest(
            _traderAddress, 
            _investorAddress, 
            _token, 
            _amount
        );

        _trader.investmentCount = _trader.investmentCount.add(1);
        traderInvestments[_trader.user][_trader.investmentCount] = investmentCount;

        _investor.investmentCount = _investor.investmentCount.add(1);
        investorInvestments[_investor.user][_investor.investmentCount] = investmentCount;

        emit Invest(
            investmentCount,
            msg.sender,
            _traderAddress,
            _investorAddress,
            _token,
            _amount,
            allocation.invested,
            allocation.total,
            starttime
        );
    }

    /// @dev Trader/Investor stops an investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _from initiator address
    /// @param _investmentId investment id
    function stop(address _traderAddress, address _investorAddress, address _from, uint256 _investmentId) 
        public 
        whenNotPaused 
        onlyWallet 
    {
        _Trader memory _trader = traders[_traderAddress];
        require(_trader.user == _traderAddress);

        uint256 stoptime = IPairedInvestments(pairedInvestments).stop(
            _traderAddress, 
            _investorAddress, 
            _investmentId);

        emit Stop(
            _investmentId,
            msg.sender,
            _traderAddress,
            _investorAddress,
            _from,
            stoptime
        );
    }

    /// @dev Investor requests to exit an investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    function requestExitInvestor(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value) 
        public 
        whenNotPaused 
        onlyWallet 
    {
        _Trader memory _trader = traders[_traderAddress];
        require(_trader.user == _traderAddress);

        IPairedInvestments(pairedInvestments).requestExitInvestor(
            _traderAddress, 
            _investorAddress, 
            _investmentId, 
            _value);

        emit RequestExit(
            _investmentId,
            msg.sender,
            _traderAddress,
            _investorAddress,
            _investorAddress,
            _value,
            now
        );
    }
    
    /// @dev Trader requests to exit an investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    /// @param _amount transaction amount
    function requestExitTrader(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value, uint256 _amount) 
        public 
        whenNotPaused 
        onlyWallet 
    {
        _Trader memory _trader = traders[_traderAddress];
        require(_trader.user == _traderAddress);

        IPairedInvestments(pairedInvestments).requestExitTrader(
            _traderAddress, 
            _investorAddress, 
            _investmentId, 
            _value,
            _amount);

        emit RequestExit(
            _investmentId,
            msg.sender,
            _traderAddress,
            _investorAddress,
            _traderAddress,
            _value,
            now
        );
    }

    /// @dev Approve exit of investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _token token address
    /// @param _amount transaction amount
    function approveExit(address _traderAddress, address _investorAddress, uint256 _investmentId, address _token, uint256 _amount) 
        public 
        whenNotPaused
        onlyWallet
        returns (uint256[3] memory payouts)
    {
        _Trader memory _trader = traders[_traderAddress];
        _Investor memory _investor = investors[_investorAddress];
        require(_trader.user == _traderAddress);
        require(_investor.user == _investorAddress);

        uint256[4] memory _result = IPairedInvestments(pairedInvestments).approveExit(
            _traderAddress,
            _investorAddress, 
            _investmentId, 
            _amount);

        _Allocation storage allocation = allocations[_traderAddress][_token];

        allocation.invested = allocation.invested.sub(_result[3]);
        
        payouts[0] = _result[0];
        payouts[1] = _result[1];
        payouts[2] = _result[2];

        emit ApproveExit(
            _investmentId,
            msg.sender,
            _traderAddress,
            _investorAddress,
            allocation.invested,
            allocation.total,
            now
        );
    }

    /// @dev Reject exit of investment
    /// @param _traderAddress trader address
    /// @param _investmentId investment id
    /// @param _value proposed investment value
    /// @param _from initiator address
    function rejectExit(address _traderAddress, uint256 _investmentId, uint256 _value, address _from)
        public 
        whenNotPaused
        onlyWallet
    {
        IPairedInvestments(pairedInvestments).rejectExit(
            _traderAddress,
            _investmentId,
            _value
        );

        emit RejectExit(
            _investmentId,
            msg.sender,
            _traderAddress,
            _value,
            _from,
            now
        );
    }


}