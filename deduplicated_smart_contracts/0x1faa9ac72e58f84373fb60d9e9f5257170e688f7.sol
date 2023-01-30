/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity 0.5.12;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
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

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgValue() internal view returns (uint256) {
        return msg.value;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must equal true).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title EternalStorage
 * @dev Store the all information about  users and orders
 */
contract EternalStorage is Ownable {
    // Count of users who is or was active
    uint256 internal _usersCount;

    // Count of deposits
    uint256 internal _depositsCount;

    // Count of swaps
    uint256 internal _swapsCount;

    // The id for ETH asset is 0x0 address
    // the rest assets should have their token contract address
    address internal _ethAssetIdentificator = address(0);

    // Order details which is available by JAVA long number
    struct OrderDetails {
        // does the order has been deposited
        bool created;
        // the 0x0 for Ethereum and ERC contract address for tokens
        address asset;
        // tokens/eth amount
        uint256 amount;
        // the status (deposited/withdrawn)
        bool withdrawn;
        // creation timestamp
        uint256 initTimestamp;
    }

    // Each user has his own state and details
    struct User {
        // user exist validation bool
        bool exist;
        // contract order index
        uint256 index;
        // contract index (0, 1, 2 ...) => exchange order number (JAVA long number)
        mapping(uint256 => uint256) orderIdByIndex;
        // JAVA long number => order details
        mapping(uint256 => OrderDetails) orders;
    }

    // the body of each swap
    struct Swap {
        uint256 initTimestamp;
        uint256 refundTimestamp;
        bytes32 secretHash;
        bytes32 secret;
        address initiator;
        address recipient;
        address asset;
        uint256 amount;
        uint256 orderId;
        State state;
    }

    // struct of swap Initiator
    struct Initiator {
        // contract order index
        uint256 index;
        // length of filled swaps
        uint256 filledSwaps;
        // index (0, 1, 2 ...) => swap hash
        mapping(uint256 => bytes32) swaps;
    }

    // min/max life limits for swap order
    // can be changed only by the contract owner
    struct SwapTimeLimits {
        uint256 min;
        uint256 max;
    }

    // ETH wallet => Assets => value
    mapping(address => User) internal _users;

    // Id => Address of user
    mapping(uint256 => address) internal _usersById;

    // Id => Swap secret hash
    mapping(uint256 => bytes32) internal _swapsById;

    // Id => Order id
    mapping(uint256 => uint256) internal _depositsById;

    // mapping of swaps based on secret hash and swap info
    mapping(bytes32 => Swap) internal _swaps;

    // the swaps data by initiator address
    mapping(address => Initiator) internal _initiators;

    // swaps' state
    enum State { Empty, Filled, Redeemed, Refunded }

    // users can swap ETH and ERC tokens
    enum SwapType { ETH, Token }

    // By default, the contract has limits for swap orders lifetime
    // The swap order can be active from 10 minutes until 6 months
    SwapTimeLimits internal _swapTimeLimits = SwapTimeLimits(10 minutes, 180 days);

    // -----------------------------------------
    // ADMIN METHODS
    // -----------------------------------------

    /**
     *  @dev The owner can change time limits for swap lifetime
     *  Amounts should be written in MINUTES
     */
    function changeSwapLifetimeLimits(
        uint256 newMin,
        uint256 newMax
    ) external onlyOwner {
        require(newMin != 0, "changeSwapLifetimeLimits: newMin and newMax should be bigger then 0");
        require(newMax >= newMin, "changeSwapLifetimeLimits: the newMax should be bigger then newMax");

        _swapTimeLimits = SwapTimeLimits(newMin * 1 minutes, newMax * 1 minutes);
    }
}

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy is EternalStorage {
	/**
	 * @dev Fallback function.
	 * Implemented entirely in `_fallback`.
	 */
	function () payable external {
		_fallback();
	}

	/**
	 * @dev fallback implementation.
	 * Extracted to enable manual triggering.
	 */
	function _fallback() internal {
		_willFallback();
		_delegate(_implementation());
	}

	/**
	 * @dev Function that is run as the first thing in the fallback function.
	 * Can be redefined in derived contracts to add functionality.
	 * Redefinitions must call super._willFallback().
	 */
	function _willFallback() internal {}

	/**
	 * @dev Delegates execution to an implementation contract.
	 * This is a low level function that doesn't return to its internal call site.
	 * It will return to the external caller whatever the implementation returns.
	 * @param implementation Address to delegate.
	 */
	function _delegate(address implementation) internal {
		assembly {
			// Copy msg.data. We take full control of memory in this inline assembly
			// block because it will not return to Solidity code. We overwrite the
			// Solidity scratch pad at memory position 0.
			calldatacopy(0, 0, calldatasize)

			// Call the implementation.
			// out and outsize are 0 because we don't know the size yet.
			let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

			// Copy the returned data.
			returndatacopy(0, 0, returndatasize)

			switch result
			// delegatecall returns 0 on error.
			case 0 { revert(0, returndatasize) }
			default { return(0, returndatasize) }
		}
  	}

	/**
	 * @return The Address of the implementation.
	 */
	function _implementation() internal view returns (address);
}

/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract BaseUpgradeabilityProxy is Proxy {
	using Address for address;

	/**
	 * @dev The version of current(active) logic contract
	 */
    string internal _version;

	/**
	 * @dev Storage slot with the address of the current implementation.
	 * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is
	 * validated in the constructor.
	 */
	bytes32 internal constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

	/**
	 * @dev Emitted when the implementation is upgraded.
	 * @param implementation Address of the new implementation.
	 */
	event Upgraded(address indexed implementation);

	/**
	 * @dev Returns the current implementation.
	 * @return Address of the current implementation
	 */
	function _implementation() internal view returns (address impl) {
		bytes32 slot = IMPLEMENTATION_SLOT;
		assembly {
		    impl := sload(slot)
		}
	}

	/**
	 * @dev Upgrades the proxy to a new implementation.
	 * @param newImplementation Address of the new implementation.
	 * @param newVersion of proxied contract.
	 */
	function _upgradeTo(address newImplementation, string memory newVersion) internal {
		_setImplementation(newImplementation, newVersion);

		emit Upgraded(newImplementation);
	}

	/**
	 * @dev Sets the implementation address of the proxy.
	 * @param newImplementation Address of the new implementation.
	 * @param newVersion of proxied contract.
	 */
	function _setImplementation(address newImplementation, string memory newVersion) internal {
		require(newImplementation.isContract(), "Cannot set a proxy implementation to a non-contract address");

 		_version = newVersion;

		bytes32 slot = IMPLEMENTATION_SLOT;

		assembly {
		    sstore(slot, newImplementation)
		}
	}
}

/**
 * @title UpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
 * implementation and init data.
 */
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
	/**
	 * @dev Contract constructor.
	 * @param _logic Address of the initial implementation.
	 */
	constructor(address _logic) public payable {
		assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
		_setImplementation(_logic, '1.0.0');
	}
}

/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
	/**
	 * @dev Emitted when the administration has been transferred.
	 * @param previousAdmin Address of the previous admin.
	 * @param newAdmin Address of the new admin.
	 */
	event AdminChanged(address previousAdmin, address newAdmin);

	/**
	 * @dev Storage slot with the admin of the contract.
	 * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
	 * validated in the constructor.
	 */
  	bytes32 internal constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  	/**
	 * @dev Modifier to check whether the `msg.sender` is the admin.
	 * If it is, it will run the function. Otherwise, it will delegate the call
	 * to the implementation.
	 */
	modifier ifAdmin() {
		if (msg.sender == _admin()) {
		    _;
		} else {
		    _fallback();
		}
	}

	/**
	 * @return The address of the proxy admin.
	 */
	function admin() external view returns (address) {
		return _admin();
	}

	/**
	 * @return The version of logic contract
	 */
	function version() external view returns (string memory) {
		return _version;
	}

	/**
	 * @return The address of the implementation.
	 */
	function implementation() external view returns (address) {
		return _implementation();
	}

	/**
	 * @dev Changes the admin of the proxy.
	 * Only the current admin can call this function.
	 * @param newAdmin Address to transfer proxy administration to.
	 */
	function changeAdmin(address newAdmin) external ifAdmin {
		require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
		emit AdminChanged(_admin(), newAdmin);
		_setAdmin(newAdmin);
	}

	/**
	 * @dev Upgrade the backing implementation of the proxy.
	 * Only the admin can call this function.
	 * @param newImplementation Address of the new implementation.
	 * @param newVersion of proxied contract.
	 */
	function upgradeTo(address newImplementation, string calldata newVersion) external ifAdmin {
		_upgradeTo(newImplementation, newVersion);
	}

	/**
	 * @dev Upgrade the backing implementation of the proxy and call a function
	 * on the new implementation.
	 * This is useful to initialize the proxied contract.
	 * @param newImplementation Address of the new implementation.
	 * @param newVersion of proxied contract.
	 * @param data Data to send as msg.data in the low level call.
	 * It should include the signature and the parameters of the function to be called, as described in
	 * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
	 */
	function upgradeToAndCall(address newImplementation, string calldata newVersion, bytes calldata data) payable external ifAdmin {
		_upgradeTo(newImplementation, newVersion);
		(bool success,) = newImplementation.delegatecall(data);
		require(success);
	}

	/**
	 * @return The admin slot.
	 */
	function _admin() internal view returns (address adm) {
		bytes32 slot = ADMIN_SLOT;
		assembly {
    		adm := sload(slot)
		}
	}

	/**
	 * @dev Sets the address of the proxy admin.
	 * @param newAdmin Address of the new proxy admin.
	 */
	function _setAdmin(address newAdmin) internal {
		bytes32 slot = ADMIN_SLOT;

		assembly {
			sstore(slot, newAdmin)
		}
	}

	/**
	 * @dev Only fall back when the sender is not the admin.
	 */
	function _willFallback() internal {
		require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
		super._willFallback();
	}
}

/**
 * @title AdminUpgradeabilityProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with a constructor for
 * initializing the implementation, admin, and init data.
 */
contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
	/**
	 * Contract constructor.
	 * @param _logic address of the initial implementation.
	 * @param _admin Address of the proxy administrator.
	 */
	constructor(address _logic, address _admin) UpgradeabilityProxy(_logic) public payable {
		assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
		_setAdmin(_admin);
	}
}

/**
 * @title AssetsValue
 * @dev The contract which hold all tokens and ETH as a assets
 * Also should be responsible for the balance increasing/decreasing and validation
 */
contract AssetsValue is EternalStorage {
    // using safe math calculation
    using SafeMath for uint256;

    // for being secure during transactions between users and contract gonna use SafeERC20 lib
    using SafeERC20 for IERC20;

    modifier orderIdNotExist(
        uint256 orderId,
        address user
    ) {
        require(_getOrderDetails(orderId, user).created == false, "orderIdNotExist: user already deposit this orderId");
        _;
    }

    // Events
    event AssetDeposited(uint256 orderId, address indexed user, address indexed asset, uint256 amount);
    event AssetWithdrawal(uint256 orderId, address indexed user, address indexed asset, uint256 amount);

    // -----------------------------------------
    // FALLBACK
    // -----------------------------------------

    function () external payable {
        // reverts all fallback & payable transactions
        revert("Fallback methods should be reverted");
    }

    // -----------------------------------------
    // EXTERNAL
    // -----------------------------------------

    function deposit(
        uint256 orderId
    ) public orderIdNotExist(orderId, _msgSender()) payable {
        require(_msgValue() != 0, "deposit: user needs to transfer ETH for calling this method");

        _deposit(orderId, _msgSender(), _ethAssetIdentificator, _msgValue());
    }

    function deposit(
        uint256 orderId,
        uint256 amount,
        address token
    ) public orderIdNotExist(orderId, _msgSender()) {
        require(token != address(0), "deposit: invalid token address");
        require(amount != 0, "deposit: user needs to fill transferable tokens amount for calling this method");

        IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
        _deposit(orderId, _msgSender(), token, amount);
    }

    function withdraw(
        uint256 orderId
    ) external {
        // validation of the user existion
        require(_doesUserExist(_msgSender()) == true, "withdraw: the user is not active");

        _withdraw(orderId);
    }


    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function doesUserExist(
        address user
    ) external view returns (bool) {
        return _doesUserExist(user);
    }

    function getUserActiveDeposits(
        address user,
        uint256 cursor,
        uint256 howMany
    ) public view returns (
        uint256[] memory orderIds,
        uint256[] memory amounts,
        uint256[] memory initTimestamps,
        uint256 newCursor
    ) {
        // amount of deposits which user has been done
        uint256 depositsLength = _users[user].index;
        uint256 activeOrdersLength = 0;

        // calculate lenght of necesseary array
        for (uint256 i = 0; i < depositsLength; i++){
            uint256 orderId = _users[user].orderIdByIndex[i];
            if (_users[user].orders[orderId].withdrawn == false) {
                activeOrdersLength++;
            }
        }

        uint256 length = howMany;
        if (length > activeOrdersLength - cursor) {
            length = activeOrdersLength - cursor;
        }

        // create new arrays with necesseary array lengths
        orderIds = new uint256[](length);
        amounts = new uint256[](length);
        initTimestamps = new uint256[](length);

        uint256 j = 0;
        for (uint256 i = 0; i < depositsLength; i++){
            if (j == length) {
                break;
            } else {
                uint256 orderId = _users[user].orderIdByIndex[cursor + i];
                if (_users[user].orders[orderId].withdrawn == false) {
                    orderIds[j] = orderId;
                    amounts[j] = _users[user].orders[orderId].amount;
                    initTimestamps[j] = _users[user].orders[orderId].initTimestamp;

                    j++;
                }
            }
        }

        return (
            orderIds,
            amounts,
            initTimestamps,
            cursor + length
        );
    }

    function getUserFilledDeposits(
        address user,
        uint256 cursor,
        uint256 howMany
    ) external view returns (
        uint256[] memory orderIds,
        uint256[] memory amounts,
        uint256[] memory initTimestamps,
        uint256 newCursor
    ) {
        // amount of deposits which user has been done
        uint256 depositsLength = _users[user].index;

        uint256 length = howMany;
        if (length > depositsLength - cursor) {
            length = depositsLength - cursor;
        }

        // init empty arrays which should been returned
        orderIds = new uint256[](length);
        amounts = new uint256[](length);
        initTimestamps = new uint256[](length);

        uint256 j = 0;
        for (uint256 i = 0; i < length; i++){
            uint256 orderId = _users[user].orderIdByIndex[cursor + i];
            orderIds[j] = orderId;
            amounts[j] = _users[user].orders[orderId].amount;
            initTimestamps[j] = _users[user].orders[orderId].initTimestamp;

            j++;
        }

        return (
            orderIds,
            amounts,
            initTimestamps,
            cursor + length
        );
    }

    function getUserDepositIndex(
        address user
    ) external view returns (
        uint256
    ) {
        return _users[user].index;
    }

    function getOrderDetails(
        uint256 orderId,
        address user
    ) external view returns (
        bool created,
        address asset,
        uint256 amount,
        bool withdrawn,
        uint256 initTimestamp
    ) {
        OrderDetails memory order = _getOrderDetails(orderId, user);
        return (
            order.created,
            order.asset,
            order.amount,
            order.withdrawn,
            order.initTimestamp
        );
    }

    function getUserById(
        uint256 userId
    ) external view returns (
        address user
    ) {
        return _usersById[userId];
    }

    function getUsersList(
        uint256 cursor,
        uint256 howMany
    ) external view returns (
        address[] memory users,
        uint256 newCursor
    ) {
        uint256 length = howMany;
        if (length > _usersCount - cursor) {
            length = _usersCount - cursor;
        }

        users = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            users[i] = _usersById[cursor + i];
        }

        return (users, cursor + length);
    }

    function getUsersCount() external view returns (uint256 count) {
        return _usersCount;
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    function _deposit(
        uint256 orderId,
        address sender,
        address asset,
        uint256 amount
    ) internal {
        _activateIfUserIsNew(sender);
        _depositOrderBalance(orderId, sender, asset, amount);

        // Increase user deposits count
        _users[sender].index += 1;

        // Update deposits mapping and count
        _depositsById[_depositsCount] = orderId;
        _depositsCount++;

        emit AssetDeposited(orderId, sender, asset, amount);
    }

    function _withdraw(
        uint256 orderId
    ) internal {
        // storing the order information (asset and amount)
        OrderDetails memory order = _getOrderDetails(orderId, _msgSender());
        address asset = order.asset;
        uint256 amount = order.amount;

        // validations before withdrawal
        require(amount != 0, "withdraw: order has no positive value");
        require(order.withdrawn == false, "withdraw: this order Id has been already withdrawn or waiting for the swap");

        _withdrawOrderBalance(orderId, _msgSender());

        if (asset == _ethAssetIdentificator) {
            _msgSender().transfer(amount);
        } else {
            IERC20(asset).safeTransfer(_msgSender(), amount);
        }

        emit AssetWithdrawal(orderId, _msgSender(), asset, amount);
    }

    function _activateIfUserIsNew(
        address user
    ) internal returns (bool) {
        if (_doesUserExist(user) == false) {
            _users[user].exist = true;
            _usersById[_usersCount] = user;
            _usersCount++;
        }
        return true;
    }

    function _depositOrderBalance(
        uint256 orderId,
        address user,
        address asset,
        uint256 amount
    ) internal returns (bool) {
        _users[user].orderIdByIndex[_users[user].index] = orderId;
        _users[user].orders[orderId] = OrderDetails(true, asset, amount, false, block.timestamp);
        return true;
    }

    function _reopenExistingOrder(
        uint256 orderId,
        address user
    ) internal returns (bool) {
        _users[user].orders[orderId].withdrawn = false;
        _users[user].orders[orderId].initTimestamp = block.timestamp;
        return true;
    }

    function _withdrawOrderBalance(
        uint256 orderId,
        address user
    ) internal returns (bool) {
        _users[user].orders[orderId].withdrawn = true;
        return true;
    }

    function _doesUserExist(
        address user
    ) internal view returns (bool) {
        return _users[user].exist;
    }

    function _getOrderDetails(
        uint256 orderId,
        address user
    ) internal view returns (OrderDetails memory order) {
        return _users[user].orders[orderId];
    }

}

/**
 * @title CrossBlockchainSwap
 * @dev Fully autonomous cross-blockchain swapping smart contract
 */
contract CrossBlockchainSwap is AssetsValue {
    // -----------------------------------------
    // EVENTS
    // -----------------------------------------

    event Initiated(
        uint256 indexed orderId,
        bytes32 indexed secretHash,
        address indexed initiator,
        address recipient,
        uint256 initTimestamp,
        uint256 refundTimestamp,
        address asset,
        uint256 amount
    );

    event Redeemed(
        bytes32 secretHash,
        uint256 redeemTimestamp,
        bytes32 secret,
        address indexed redeemer
    );

    event Refunded(
        uint256 orderId,
        bytes32 secretHash,
        uint256 refundTime,
        address indexed refunder
    );

    // -----------------------------------------
    // MODIFIERS
    // -----------------------------------------

    modifier swapIsNotInitiated(bytes32 secretHash) {
        require(_swaps[secretHash].state == State.Empty, "swapIsNotInitiated: this secret hash was already used, please use another one");
        _;
    }

    modifier swapIsRedeemable(bytes32 secret) {
        bool isRedeemable = _isRedeemable(secret);
        require(isRedeemable, "swapIsRedeemable: the redeem is not available");
        _;
    }

    modifier swapIsRefundable(bytes32 secretHash, address refunder) {
        bool isRefundable = _isRefundable(secretHash, refunder);
        require(isRefundable, "swapIsRefundable: refund is not available");
        _;
    }

    // -----------------------------------------
    // EXTERNAL
    // -----------------------------------------

    /**
     *  @dev If user wants to swap ERC token, before initiating the swap between that
     *  initiator need to call approve method from his tokens' smart contract,
     *  approving to it to spend the value1 amount of tokens
     *  @param secretHash the encoded secret which they discussed at offline (SHA256)
     *  @param refundTimestamp the period when the swap should be active
     *  it should be written in MINUTES
     */
    function initiate(
        uint256 orderId,
        bytes32 secretHash,
        address recipient,
        uint256 refundTimestamp
    ) public swapIsNotInitiated(secretHash) {
        require(recipient != address(0), "initiate: invalid recipient address");

        // validation that refund Timestamp more than exchange min limit and less then max limit
        _validateRefundTimestamp(refundTimestamp * 1 minutes);

        OrderDetails memory order = _getOrderDetails(orderId, _msgSender());

        // validation of the deposited order existing and non-zero amount
        require(order.created == true, "initiate: this order Id has not been created and deposited yet");
        require(order.withdrawn == false, "initiate: this order deposit has been withdrawn");
        require(order.amount != 0, "initiate: this order Id has been withdrawn, finished or waiting for the redeem");

        // withdrawing the balance of this orderId from sender deposites
        _withdrawOrderBalance(orderId, _msgSender());

        // swap asset details
        _swaps[secretHash].asset = order.asset;
        _swaps[secretHash].amount = order.amount;

        // swap status
        _swaps[secretHash].state = State.Filled;

        // swap clients
        _swaps[secretHash].initiator = _msgSender();
        _swaps[secretHash].recipient = recipient;
        _swaps[secretHash].secretHash = secretHash;
        _swaps[secretHash].orderId = orderId;

        // swap timestapms
        _swaps[secretHash].initTimestamp = block.timestamp;
        _swaps[secretHash].refundTimestamp = block.timestamp + (refundTimestamp * 1 minutes);

        // updating the initiator state
        Initiator storage initiator = _initiators[_msgSender()];
        initiator.swaps[initiator.index] = secretHash;
        initiator.index++;
        initiator.filledSwaps++;

        // Update deposits mapping and count
        _swapsById[_swapsCount] = secretHash;
        _swapsCount++;

        emit Initiated(
            orderId,
            secretHash,
            _msgSender(),
            recipient,
            block.timestamp,
            refundTimestamp,
            order.asset,
            order.amount
        );
    }

    /**
     *  @dev The participant of swap, who has the secret word and the secret hash can call this method
     *  and receive assets from contract.
     *  @param secret which both sides discussed before initialization
     */
    function redeem(
        bytes32 secret
    ) external swapIsRedeemable(secret) {
        // storing the secret hash generated from secret
        bytes32 secretHash = _hashTheSecret(secret);

        // closing the state of this swap order
        _swaps[secretHash].state = State.Redeemed;

        // storing the recipient address
        address recipient = _swaps[secretHash].recipient;

        if (_getSwapAssetType(secretHash) == SwapType.ETH) {
            // converting recipient address to payable address
            address payable payableReceiver = address(uint160(recipient));
            // transfer ETH to recipient wallet
            payableReceiver.transfer(_swaps[secretHash].amount);
        } else {
            // transfer tokens to recipient address
            IERC20(_swaps[secretHash].asset).safeTransfer(recipient, _swaps[secretHash].amount);
        }

        // saving the secret
        _swaps[secretHash].secret = secret;

        // decrease the filled swaps amount
        _initiators[_swaps[secretHash].initiator].filledSwaps--;

        emit Redeemed (
            secretHash,
            block.timestamp,
            secret,
            recipient
        );
    }

    /**
     *  @dev The initiator can get back his tokens until refundTimestamp comes,
     *  after that both sides cannot do anything with this swap
     *  @param secretHash the encoded secret which they discussed at offline (SHA256)
     */
    function refund(
        bytes32 secretHash
    ) public swapIsRefundable(secretHash, _msgSender()) {
        _swaps[secretHash].state = State.Refunded;
        _reopenExistingOrder(_swaps[secretHash].orderId,_msgSender());

        // decrease the filled swapss amount
        _initiators[_msgSender()].filledSwaps--;

        emit Refunded(
            _swaps[secretHash].orderId,
            secretHash,
            block.timestamp,
            _msgSender()
        );
    }

    /**
     *  @dev The method do 2 actions and optimize the processes
     *  It call refund and withdraw
     *  @param secretHash the encoded secret which they discussed at offline (SHA256)
     */
    function refundAndWithdraw(
        bytes32 secretHash
    ) external {
        refund(secretHash);
        uint256 orderId = _swaps[secretHash].orderId;
        _withdraw(orderId);
    }

    /**
     *  @dev The method do the same think as refundAndWithdraw, but for all expired swaps
     *  The caller should be able to refund and withdraw all own swaps and deposits
     */
    function refundAndWithdrawAll() external {
        uint256 filledSwaps = _initiators[_msgSender()].filledSwaps;

        for (uint256 i = 0; i < filledSwaps; i++) {
            bytes32 secretHash = _swaps[_initiators[_msgSender()].swaps[i]].secretHash;
            if (_isRefundable(secretHash, _msgSender())) {
                uint256 orderId = _swaps[_initiators[_msgSender()].swaps[i]].orderId;
                refund(secretHash);
                _withdraw(orderId);
            }
        }
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    /**
     *  @dev Method returns all atomic swaps for specified user with optional state filter.
     *  @param initiator the address of user
     *  @param state of required swap, represented as a Enum type with 4 options (0 - 3)
     *  @return orderIds array of order ids with required state
     */
    function getUserSwapsByState(
        address initiator,
        State state,
        uint256 cursor,
        uint256 howMany
    ) public view returns (
        uint256[] memory orderIds,
        uint256 newCursor
    ) {
        uint256 swapsLength = _initiators[initiator].index;
        uint256 filteredOrdersLength = 0;

        // calculate lenght of necesseary array
        for (uint256 i = 0; i < swapsLength; i++){
            Swap memory swap = _swaps[_initiators[initiator].swaps[i]];
            if (swap.state == state) {
                filteredOrdersLength++;
            }
        }

        uint256 length = howMany;
        if (length > filteredOrdersLength - cursor) {
            length = filteredOrdersLength - cursor;
        }

        // create new array with necesseary array lengths
        orderIds = new uint256[](length);

        // filter orderIds by requirement
        uint256 j = 0;
        for (uint256 i = 0; i < swapsLength; i++){
            if (j == length) {
                break;
            } else {
                Swap memory swap = _swaps[_initiators[initiator].swaps[cursor + i]];
                if (swap.state == state) {
                    orderIds[j] = swap.orderId;

                    j++;
                }
            }
        }

        return (
            orderIds,
            cursor + length
        );
    }

    /**
     *  @dev Get user filled swaps count
     *  @return uint256 count
     */
    function getUserFilledOrdersCount(
        address user
    ) external view returns (
        uint256 count
    ) {
        return _initiators[user].filledSwaps;
    }

    /**
     *  @dev Get filled swaps order ids and amounts
     *  @return uint256[] of order ids
     *  @return uint256[] of amounts
     *  @return uint256[] of creation id's
     */
    function getUserFilledOrders(
        address user,
        uint256 cursor,
        uint256 howMany
    ) external view returns (
        uint256[] memory orderIds,
        uint256[] memory amounts,
        uint256[] memory initTimestamps,
        uint256 newCursor
    ) {
        uint256 filledSwaps = _initiators[user].filledSwaps;

        uint256 length = howMany;
        if (length > filledSwaps - cursor) {
            length = filledSwaps - cursor;
        }

        orderIds = new uint256[](length);
        amounts = new uint256[](length);
        initTimestamps = new uint256[](length);

        uint256 j = 0;
        for(uint256 i = 0; i <= _initiators[user].index; i++){
            if (j == length) {
                break;
            } else {
                Swap memory swap = _swaps[_initiators[user].swaps[cursor + i]];
                if (swap.state == State.Filled) {
                    amounts[j] = swap.amount;
                    orderIds[j] = swap.orderId;
                    initTimestamps[j] = swap.initTimestamp;

                    j++;
                }
            }
        }

        return (
            orderIds,
            amounts,
            initTimestamps,
            cursor + length
        );
    }

    /**
     *  @dev Identification of the swap type with assets and value fields
     *  @param secretHash the encoded secret which they discussed at offline (SHA256)
     *  @return tp (type) of swap
     */
    function getSwapAssetType(
        bytes32 secretHash
    ) public view returns (SwapType tp) {
        return _getSwapAssetType(secretHash);
    }

    /**
     *  @dev Check the secret hash for existence, it can be used in UI for form validation
     *  @param secretHash the encoded secret which they discussed at offline (SHA256)
     *  @return state of this swap
     */
    function getSwapData(
        bytes32 _secretHash
    ) external view returns (
        uint256 initTimestamp,
        uint256 refundTimestamp,
        bytes32 secretHash,
        bytes32 secret,
        address initiator,
        address recipient,
        address asset,
        uint256 amount,
        State state
    ) {
        Swap memory swap = _swaps[_secretHash];
        return (
            swap.initTimestamp,
            swap.refundTimestamp,
            swap.secretHash,
            swap.secret,
            swap.initiator,
            swap.recipient,
            swap.asset,
            swap.amount,
            swap.state
        );
    }

    /**
     *  @dev Method check and return array of orderIds, which can being refunded by provided user
     *  @param user address of user
     *  @return array of uint256 orderIds
     */
    function getExpiredSwaps(
        address user
    ) public view returns (
        uint256[] memory orderIds,
        bytes32[] memory secretHashes
    ) {
        uint256 swapsLength = _initiators[user].index;
        uint256 expiredSwapsLength = 0;

        // calculate lenght of refund timestamps array
        for (uint256 i = 0; i < swapsLength; i++){
            bytes32 secretHash = _initiators[user].swaps[i];
            Swap memory swap = _swaps[secretHash];
            if (block.timestamp >= swap.refundTimestamp && swap.state == State.Filled) {
                expiredSwapsLength++;
            }
        }

        // create new array with necesseary array lengths
        orderIds = new uint256[](expiredSwapsLength);
        secretHashes = new bytes32[](expiredSwapsLength);

        // filter orderIds by refund timestamp
        uint256 j = 0;
        for (uint256 i = 0; i < swapsLength; i++){
            bytes32 secretHash = _initiators[user].swaps[i];
            Swap memory swap = _swaps[secretHash];
            if (block.timestamp >= swap.refundTimestamp && swap.state == State.Filled) {
                orderIds[j] = swap.orderId;
                secretHashes[j] = secretHash;
                j++;
            }
        }

        return (
            orderIds,
            secretHashes
        );
    }

    /**
     *  @dev To avoid issues between solidity hashing algorithm and the algorithm which will be used in the platform
     *  we gonna use the same hashing algorithm which uses the smart contract
     *  this is only the getter method without interaction from the blockchain, so it is safe
     *  @return secret hash of bytes32 secret
     */
    function getHashOfSecret(
        bytes32 secret
    ) external pure returns (bytes32) {
        return _hashTheSecret(secret);
    }

    /**
     *  @dev Get limits of a lifetime for swap in minutes
     *  @return min lifetime
     *  @return max lifetime
     */
    function getSwapLifetimeLimits() public view returns (
        uint256 min,
        uint256 max
    ) {
        return (
            _swapTimeLimits.min,
            _swapTimeLimits.max
        );
    }

    /**
     *  @dev Get the count of initiated swaps
     */
    function getSwapsCount() external view returns (
        uint256 swapsCount
    ) {
        return _swapsCount;
    }

    /**
     *  @dev Get the secretHash by provided id
     */
    function getSwapsSecretHashById(
        uint256 swapId
    ) external view returns (
        bytes32 secretHash
    ) {
        return _swapsById[swapId];
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    /**
     *  @dev Validating the period time of swap
     * It should be equal/bigger than 10 minutes and equal/less than 180 days
     */
    function _validateRefundTimestamp(
        uint256 refundTimestamp
    ) private view {
        require(refundTimestamp >= _swapTimeLimits.min, "_validateRefundTimestamp: the timestamp should be bigger than min swap lifetime");
        require(_swapTimeLimits.max >= refundTimestamp, "_validateRefundTimestamp: the timestamp should be smaller than max swap lifetime");
    }

    function _isRefundable(
        bytes32 secretHash,
        address refunder
    ) internal view returns (bool) {
        bool isFilled = _swaps[secretHash].state == State.Filled;
        bool isCallerInitiator = _swaps[secretHash].initiator == refunder;
        uint256 refundTimestamp = _swaps[secretHash].refundTimestamp;
        bool isTimeReached = block.timestamp >= refundTimestamp;

        return isFilled && isCallerInitiator && isTimeReached;
    }

    function _isRedeemable(
        bytes32 secret
    ) internal view returns (bool) {
        bytes32 secretHash = _hashTheSecret(secret);
        bool isSwapFilled = _swaps[secretHash].state == State.Filled;
        uint256 refundTimestamp = _swaps[secretHash].refundTimestamp;
        bool isSwapActive = refundTimestamp > block.timestamp;

        return isSwapFilled && isSwapActive;
    }

    function _hashTheSecret(
        bytes32 secret
    ) private pure returns (bytes32) {
        return sha256(abi.encodePacked(secret));
    }

    function _getSwapAssetType(
        bytes32 secretHash
    ) private view returns (SwapType tp) {
        if (_swaps[secretHash].asset == _ethAssetIdentificator) {
            return SwapType.ETH;
        } else {
            return SwapType.Token;
        }
    }
}