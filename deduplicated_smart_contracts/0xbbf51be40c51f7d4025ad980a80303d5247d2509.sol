/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

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
contract Context {
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

// File: @openzeppelin/contracts/access/Roles.sol

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

// File: 0.5-contracts/normal_deployment/racing/RacingAdmins.sol

pragma solidity ^0.5.8;



contract RacingAdmins is Context {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _admins;

    constructor () internal {
        _addAdmin(_msgSender());
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAdmin(address account) public onlyAdmin {
        _removeAdmin(account);
    }

    function _addAdmin(address account) internal {
        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }
}

// File: 0.5-contracts/normal_deployment/racing/RacingFeeReceiver.sol

pragma solidity ^0.5.8;


contract RacingFeeReceiver is RacingAdmins {
    address payable private _feeWallet;

    event FeeWalletTransferred(address indexed previousFeeWallet, address indexed newFeeWallet);

    /**
     * @dev Returns the address of the current fee receiver.
     */
    function feeWallet() public view returns (address payable) {
        return _feeWallet;
    }

    /**
     * @dev Throws if called by any account other than the fee receiver wallet.
     */
    modifier onlyFeeWallet() {
        require(isFeeWallet(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current fee receiver wallet.
     */
    function isFeeWallet() public view returns (bool) {
        return _msgSender() == _feeWallet;
    }

    /**
     * @dev Leaves the contract without fee receiver wallet.
     *
     * NOTE: Renouncing will leave the contract without an fee receiver wallet.
     * It means that fee will be transferred to the zero address.
     */
    function renounceFeeWallet() public onlyAdmin {
        emit FeeWalletTransferred(_feeWallet, address(0));
        _feeWallet = address(0);
    }

    /**
     * @dev Transfers address of the fee receiver to a new address (`newFeeWallet`).
     * Can only be called by admins.
     */
    function transferFeeWalletOwnership(address payable newFeeWallet) public onlyAdmin {
        _transferFeeWalletOwnership(newFeeWallet);
    }

    /**
     * @dev Transfers address of the fee receiver to a new address (`newFeeWallet`).
     */
    function _transferFeeWalletOwnership(address payable newFeeWallet) internal {
        require(newFeeWallet != address(0), "Ownable: new owner is the zero address");
        emit FeeWalletTransferred(_feeWallet, newFeeWallet);
        _feeWallet = newFeeWallet;
    }
}

// File: 0.5-contracts/normal_deployment/racing/RacingStorage.sol

pragma solidity ^0.5.8;



contract RacingStorage is RacingFeeReceiver, ReentrancyGuard {
    // --
    // Permanent Storage Variables
    // --

    mapping(bytes32 => Race) public Races; // The race mapping structure.
    mapping(uint256 => address) public Owner_Horse; // Owner of the Horse ID.
    mapping(uint256 => uint256) public Horse_Active_Races; // Number of races the horse is registered for.
    mapping(bytes32 => bool) public ID_Saved; // Returns whether or not the race ID is present on storage already.
    mapping(uint256 => uint256) public Position_To_Payment; // Returns the percentage of the payment depending on horse's position in a race.
    mapping(address => bool) public Is_Authorized; // Returns whether an address is authorized or not.
    mapping(bytes32 => string) public Cancelled_Races; // Returns a cancelled race and its reason to be cancelled.
    mapping(bytes32 => bool) public Has_Zed_Claimed; // Returns whether or not winnings for a race have been claimed for Zed.

    address BB; // Blockchain Brain
    address Core; // Core contract.

    struct Race {
        string Track_Name; // Name of the track or event.
        bytes32 Race_ID; // Key provided for Race ID.
        uint256 Length; // Length of the track (m).
        uint256 Horses_Registered; // Current number of horses registered.
        uint256 Unix_Start; // Timestamp the race starts.
        uint256 Entrance_Fee; // Entrance fee for a particular race (10^18).
        uint256 Prize_Pool; // Total bets in the prize pool (10^18).
        uint256 Horses_Allowed; // Total number of horses allowed for a race.
        uint256[] Horses; // List of Horse IDs on Race.
        State Race_State; // Current state of the race.
        mapping(uint256 => Horse) Lineup; // Mapping of the Horse ID => Horse struct.
        mapping(uint256 => uint256) Gate_To_ID; // Mapping of the Gate # => Horse ID.
        mapping(uint256 => bool) Is_Gate_Taken; // Whether or not a gate number has been taken.
    }

    struct Horse {
        uint256 Gate; // Gate this horse is currently at.
        uint256 Total_Bet; // Total amount bet on this horse.
        uint256 Final_Position; // Final position of the horse (1 to Horses allowed in race).
        mapping(address => uint256) Bet_Placed; // Amount a specific address bet on this horse.
        mapping(address => bool) Bet_Claimed; // Whether or not that specific address claimed their bet.
    }

    enum State {Null, Registration, Betting, Final, Fail_Safe}
}

// File: 0.5-contracts/normal_deployment/racing/proxy/Proxy.sol

pragma solidity ^0.5.8;


/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy is RacingStorage {
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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: 0.5-contracts/normal_deployment/racing/proxy/BaseUpgradeabilityProxy.sol

pragma solidity ^0.5.8;




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
	function _upgradeProxyTo(address newImplementation, string memory newVersion) internal {
		_setProxyImplementation(newImplementation, newVersion);

		emit Upgraded(newImplementation);
	}

	/**
	 * @dev Sets the implementation address of the proxy.
	 * @param newImplementation Address of the new implementation.
	 * @param newVersion of proxied contract.
	 */
	function _setProxyImplementation(address newImplementation, string memory newVersion) internal {
		require(newImplementation.isContract(), "Cannot set a proxy implementation to a non-contract address");

 		_version = newVersion;

		bytes32 slot = IMPLEMENTATION_SLOT;

		assembly {
		    sstore(slot, newImplementation)
		}
	}
}

// File: 0.5-contracts/normal_deployment/racing/proxy/UpgradeabilityProxy.sol

pragma solidity ^0.5.8;


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
		_setProxyImplementation(_logic, "1.0.0");
	}
}

// File: 0.5-contracts/normal_deployment/racing/proxy/BaseAdminUpgradeabilityProxy.sol

pragma solidity ^0.5.8;


/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifProxyAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
	/**
	 * @dev Emitted when the administration has been transferred.
	 * @param previousAdmin Address of the previous admin.
	 * @param newProxyAdmin Address of the new admin.
	 */
	event ProxyAdminChanged(address previousAdmin, address newProxyAdmin);

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
	modifier ifProxyAdmin() {
		if (msg.sender == _proxyAdmin()) {
		    _;
		} else {
		    _fallback();
		}
	}

	/**
	 * @return The address of the proxy admin.
	 */
	function proxyAdmin() external view returns (address) {
		return _proxyAdmin();
	}

	/**
	 * @return The version of logic contract
	 */
	function proxyVersion() external view returns (string memory) {
		return _version;
	}

	/**
	 * @return The address of the implementation.
	 */
	function proxyImplementation() external view returns (address) {
		return _implementation();
	}

	/**
	 * @dev Changes the admin of the proxy.
	 * Only the current admin can call this function.
	 * @param newProxyAdmin Address to transfer proxy administration to.
	 */
	function changeProxyAdmin(address newProxyAdmin) external ifProxyAdmin {
		require(newProxyAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
		emit ProxyAdminChanged(_proxyAdmin(), newProxyAdmin);
		_setProxyAdmin(newProxyAdmin);
	}

	/**
	 * @dev Upgrade the backing implementation of the proxy.
	 * Only the admin can call this function.
	 * @param newImplementation Address of the new implementation.
	 * @param newVersion of proxied contract.
	 */
	function upgradeProxyTo(address newImplementation, string calldata newVersion) external ifProxyAdmin {
		_upgradeProxyTo(newImplementation, newVersion);
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
	function upgradeProxyToAndCall(address newImplementation, string calldata newVersion, bytes calldata data) payable external ifProxyAdmin {
		_upgradeProxyTo(newImplementation, newVersion);
		(bool success,) = newImplementation.delegatecall(data);
		require(success);
	}

	/**
	 * @return The admin slot.
	 */
	function _proxyAdmin() internal view returns (address adm) {
		bytes32 slot = ADMIN_SLOT;
		assembly {
    		adm := sload(slot)
		}
	}

	/**
	 * @dev Sets the address of the proxy admin.
	 * @param newProxyAdmin Address of the new proxy admin.
	 */
	function _setProxyAdmin(address newProxyAdmin) internal {
		bytes32 slot = ADMIN_SLOT;

		assembly {
			sstore(slot, newProxyAdmin)
		}
	}

	/**
	 * @dev Only fall back when the sender is not the admin.
	 */
	function _willFallback() internal {
		require(msg.sender != _proxyAdmin(), "Cannot call fallback function from the proxy admin");
		super._willFallback();
	}
}

// File: 0.5-contracts/normal_deployment/racing/RacingProxy.sol

pragma solidity ^0.5.8;



/**
 * @title RacingProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with a constructor for
 * initializing the implementation, admin, and init data.
 */
contract RacingProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
	/**
	 * Contract constructor.
	 * @param _logic address of the initial implementation.
	 * @param _admin Address of the proxy administrator.
	 */
	constructor(address _logic, address _admin) UpgradeabilityProxy(_logic) public payable {
		assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
		_setProxyAdmin(_admin);
	}
}