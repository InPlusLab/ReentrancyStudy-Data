// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
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
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./Upgradeable.sol";
import "./Address.sol";


/**
* @notice ERC897 - ERC DelegateProxy
*/
interface ERCProxy {
    function proxyType() external pure returns (uint256);
    function implementation() external view returns (address);
}


/**
* @notice Proxying requests to other contracts.
* Client should use ABI of real contract and address of this contract
*/
contract Dispatcher is Upgradeable, ERCProxy {
    using Address for address;

    event Upgraded(address indexed from, address indexed to, address owner);
    event RolledBack(address indexed from, address indexed to, address owner);

    /**
    * @dev Set upgrading status before and after operations
    */
    modifier upgrading()
    {
        isUpgrade = UPGRADE_TRUE;
        _;
        isUpgrade = UPGRADE_FALSE;
    }

    /**
    * @param _target Target contract address
    */
    constructor(address _target) upgrading {
        require(_target.isContract());
        // Checks that target contract inherits Dispatcher state
        verifyState(_target);
        // `verifyState` must work with its contract
        verifyUpgradeableState(_target, _target);
        target = _target;
        finishUpgrade();
        emit Upgraded(address(0), _target, msg.sender);
    }

    //------------------------ERC897------------------------
    /**
     * @notice ERC897, whether it is a forwarding (1) or an upgradeable (2) proxy
     */
    function proxyType() external pure override returns (uint256) {
        return 2;
    }

    /**
     * @notice ERC897, gets the address of the implementation where every call will be delegated
     */
    function implementation() external view override returns (address) {
        return target;
    }
    //------------------------------------------------------------

    /**
    * @notice Verify new contract storage and upgrade target
    * @param _target New target contract address
    */
    function upgrade(address _target) public onlyOwner upgrading {
        require(_target.isContract());
        // Checks that target contract has "correct" (as much as possible) state layout
        verifyState(_target);
        //`verifyState` must work with its contract
        verifyUpgradeableState(_target, _target);
        if (target.isContract()) {
            verifyUpgradeableState(target, _target);
        }
        previousTarget = target;
        target = _target;
        finishUpgrade();
        emit Upgraded(previousTarget, _target, msg.sender);
    }

    /**
    * @notice Rollback to previous target
    * @dev Test storage carefully before upgrade again after rollback
    */
    function rollback() public onlyOwner upgrading {
        require(previousTarget.isContract());
        emit RolledBack(target, previousTarget, msg.sender);
        // should be always true because layout previousTarget -> target was already checked
        // but `verifyState` is not 100% accurate so check again
        verifyState(previousTarget);
        if (target.isContract()) {
            verifyUpgradeableState(previousTarget, target);
        }
        target = previousTarget;
        previousTarget = address(0);
        finishUpgrade();
    }

    /**
    * @dev Call verifyState method for Upgradeable contract
    */
    function verifyUpgradeableState(address _from, address _to) private {
        (bool callSuccess,) = _from.delegatecall(abi.encodeWithSelector(this.verifyState.selector, _to));
        require(callSuccess);
    }

    /**
    * @dev Call finishUpgrade method from the Upgradeable contract
    */
    function finishUpgrade() private {
        (bool callSuccess,) = target.delegatecall(abi.encodeWithSelector(this.finishUpgrade.selector, target));
        require(callSuccess);
    }

    function verifyState(address _testTarget) public override onlyWhileUpgrading {
        //checks equivalence accessing state through new contract and current storage
        require(address(uint160(delegateGet(_testTarget, this.owner.selector))) == owner());
        require(address(uint160(delegateGet(_testTarget, this.target.selector))) == target);
        require(address(uint160(delegateGet(_testTarget, this.previousTarget.selector))) == previousTarget);
        require(uint8(delegateGet(_testTarget, this.isUpgrade.selector)) == isUpgrade);
    }

    /**
    * @dev Override function using empty code because no reason to call this function in Dispatcher
    */
    function finishUpgrade(address) public override {}

    /**
    * @dev Receive function sends empty request to the target contract
    */
    receive() external payable {
        assert(target.isContract());
        // execute receive function from target contract using storage of the dispatcher
        (bool callSuccess,) = target.delegatecall("");
        if (!callSuccess) {
            revert();
        }
    }

    /**
    * @dev Fallback function sends all requests to the target contract
    */
    fallback() external payable {
        assert(target.isContract());
        // execute requested function from target contract using storage of the dispatcher
        (bool callSuccess,) = target.delegatecall(msg.data);
        if (callSuccess) {
            // copy result of the request to the return data
            // we can use the second return value from `delegatecall` (bytes memory)
            // but it will consume a little more gas
            assembly {
                returndatacopy(0x0, 0x0, returndatasize())
                return(0x0, returndatasize())
            }
        } else {
            revert();
        }
    }

}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./Ownable.sol";


/**
* @notice Base contract for upgradeable contract
* @dev Inherited contract should implement verifyState(address) method by checking storage variables
* (see verifyState(address) in Dispatcher). Also contract should implement finishUpgrade(address)
* if it is using constructor parameters by coping this parameters to the dispatcher storage
*/
abstract contract Upgradeable is Ownable {

    event StateVerified(address indexed testTarget, address sender);
    event UpgradeFinished(address indexed target, address sender);

    /**
    * @dev Contracts at the target must reserve the same location in storage for this address as in Dispatcher
    * Stored data actually lives in the Dispatcher
    * However the storage layout is specified here in the implementing contracts
    */
    address public target;

    /**
    * @dev Previous contract address (if available). Used for rollback
    */
    address public previousTarget;

    /**
    * @dev Upgrade status. Explicit `uint8` type is used instead of `bool` to save gas by excluding 0 value
    */
    uint8 public isUpgrade;

    /**
    * @dev Guarantees that next slot will be separated from the previous
    */
    uint256 stubSlot;

    /**
    * @dev Constants for `isUpgrade` field
    */
    uint8 constant UPGRADE_FALSE = 1;
    uint8 constant UPGRADE_TRUE = 2;

    /**
    * @dev Checks that function executed while upgrading
    * Recommended to add to `verifyState` and `finishUpgrade` methods
    */
    modifier onlyWhileUpgrading()
    {
        require(isUpgrade == UPGRADE_TRUE);
        _;
    }

    /**
    * @dev Method for verifying storage state.
    * Should check that new target contract returns right storage value
    */
    function verifyState(address _testTarget) public virtual onlyWhileUpgrading {
        emit StateVerified(_testTarget, msg.sender);
    }

    /**
    * @dev Copy values from the new target to the current storage
    * @param _target New target contract address
    */
    function finishUpgrade(address _target) public virtual onlyWhileUpgrading {
        emit UpgradeFinished(_target, msg.sender);
    }

    /**
    * @dev Base method to get data
    * @param _target Target to call
    * @param _selector Method selector
    * @param _numberOfArguments Number of used arguments
    * @param _argument1 First method argument
    * @param _argument2 Second method argument
    * @return memoryAddress Address in memory where the data is located
    */
    function delegateGetData(
        address _target,
        bytes4 _selector,
        uint8 _numberOfArguments,
        bytes32 _argument1,
        bytes32 _argument2
    )
        internal returns (bytes32 memoryAddress)
    {
        assembly {
            memoryAddress := mload(0x40)
            mstore(memoryAddress, _selector)
            if gt(_numberOfArguments, 0) {
                mstore(add(memoryAddress, 0x04), _argument1)
            }
            if gt(_numberOfArguments, 1) {
                mstore(add(memoryAddress, 0x24), _argument2)
            }
            switch delegatecall(gas(), _target, memoryAddress, add(0x04, mul(0x20, _numberOfArguments)), 0, 0)
                case 0 {
                    revert(memoryAddress, 0)
                }
                default {
                    returndatacopy(memoryAddress, 0x0, returndatasize())
                }
        }
    }

    /**
    * @dev Call "getter" without parameters.
    * Result should not exceed 32 bytes
    */
    function delegateGet(address _target, bytes4 _selector)
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 0, 0, 0);
        assembly {
            result := mload(memoryAddress)
        }
    }

    /**
    * @dev Call "getter" with one parameter.
    * Result should not exceed 32 bytes
    */
    function delegateGet(address _target, bytes4 _selector, bytes32 _argument)
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 1, _argument, 0);
        assembly {
            result := mload(memoryAddress)
        }
    }

    /**
    * @dev Call "getter" with two parameters.
    * Result should not exceed 32 bytes
    */
    function delegateGet(
        address _target,
        bytes4 _selector,
        bytes32 _argument1,
        bytes32 _argument2
    )
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 2, _argument1, _argument2);
        assembly {
            result := mload(memoryAddress)
        }
    }
}

