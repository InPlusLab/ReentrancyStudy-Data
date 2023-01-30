/**

 *Submitted for verification at Etherscan.io on 2019-03-12

*/



pragma solidity 0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(

    ERC20Basic _token,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transfer(_to, _value));

  }



  function safeTransferFrom(

    ERC20 _token,

    address _from,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transferFrom(_from, _to, _value));

  }



  function safeApprove(

    ERC20 _token,

    address _spender,

    uint256 _value

  )

    internal

  {

    require(_token.approve(_spender, _value));

  }

}



// File: zos-lib/contracts/Initializable.sol



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



    bool wasInitializing = initializing;

    initializing = true;

    initialized = true;



    _;



    initializing = wasInitializing;

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



// File: openzeppelin-eth/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable is Initializable {

  address private _owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function initialize(address sender) public initializer {

    _owner = sender;

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

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

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);

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



  uint256[50] private ______gap;

}



// File: openzeppelin-eth/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

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

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



// File: contracts/library/OperationStore.sol



library OperationStore {



    /**

     * @notice Stores historical integer data

     * @param _history History of stored int data in format time1, value1, time2, value2, time3...

     * @param _value Value to be stored

     */

    function storeInt(uint256[] storage _history, uint256 _value) internal {

        _history.push(block.timestamp);

        _history.push(_value);

    }



    /**

     * @notice Returns integer value for specified time

     * @param _history History of stored int data in format time1, value1, time2, value2, time3...

     * @param _timestamp Time for which we get value

     */

    function getInt(uint256[] memory _history, uint256 _timestamp) internal pure returns (uint256) {

        uint256 index = findIndex(_history, _timestamp, 2);

        if (index > 0) {

            return _history[index - 1];

        }

        return 0;

    }



    /**

     * @notice Stores historical boolean data

     * @param _history History of stored boolean data in format: new record each times value changed (time1, time2...)

     * @param _value Value to be stored

     */

    function storeBool(uint256[] storage _history, bool _value) internal {

        bool current = (_history.length % 2 == 1);

        if (current != _value) {

            _history.push(block.timestamp);

        }

    }



    /**

     * @notice Returns boolean value for specified time

     * @param _history History of stored boolean data in format: new record each times value changed (time1, time2...)

     * @param _timestamp Time for which we get value

     */

    function getBool(uint256[] memory _history, uint256 _timestamp) internal pure returns (bool) {

        return findIndex(_history, _timestamp, 1) % 2 == 1;

    }



    /**

     * @notice Stores historical timestamp data

     * @param _history History of stored timestamp data in format: time1, time2, time3...

     * @param _value Value to be stored

     */

    function storeTimestamp(uint256[] storage _history, uint256 _value) internal {

        _history.push(_value);

    }



    /**

     * @notice Returns last timestamp value for specified time

     * @param _history History of stored timestamp data in format: time1, time2, time3...

     * @param _timestamp Time for which we get value

     */

    function getTimestamp(uint256[] memory _history, uint256 _timestamp) internal pure returns (uint256) {

        uint256 index = findIndex(_history, _timestamp, 1);

        if (index > 0) {

            return _history[index - 1];

        }

        return 0;

    }



    /**

     * @notice Searches for index of timestamp with specified step

     * @dev History elements is sorted so binary search is used.

     * @param _history History of stored timestamp data in format: time1, time2, time3...

     * @param _timestamp Time for which we get value

     * @param _step Step used for binary search. For bool & timestamp steps is 1, for uint step is 2

     */

    function findIndex(uint256[] memory _history, uint256 _timestamp, uint256 _step) internal pure returns (uint256) {

        if (_history.length == 0) {

            return 0;

        }

        uint256 low = 0;

        uint256 high = _history.length - _step;



        while (low <= high) {

            uint256 mid = ((low + high) >> _step) << (_step - 1);

            uint256 midVal = _history[mid];

            if (midVal < _timestamp) {

                low = mid + _step;

            } else if (midVal > _timestamp) {

                if (mid == 0) {

                    return 0;

                    // min key

                }

                high = mid - _step;

            } else {

                // take the last one if there are many same items

                uint256 result = mid + _step;

                while (result < _history.length && _history[result] == _timestamp) {

                    result = result + _step;

                }

                // key found

                return result;

            }

        }

        // key not found

        return low;

    }



}



// File: zos-lib/contracts/upgradeability/Proxy.sol



/**

 * @title Proxy

 * @dev Implements delegation of calls to other contracts, with proper

 * forwarding of return values and bubbling of failures.

 * It defines a fallback function that delegates all calls to the address

 * returned by the abstract _implementation() internal function.

 */

contract Proxy {

  /**

   * @dev Fallback function.

   * Implemented entirely in `_fallback`.

   */

  function () payable external {

    _fallback();

  }



  /**

   * @return The Address of the implementation.

   */

  function _implementation() internal view returns (address);



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

   * @dev Function that is run as the first thing in the fallback function.

   * Can be redefined in derived contracts to add functionality.

   * Redefinitions must call super._willFallback().

   */

  function _willFallback() internal {

  }



  /**

   * @dev fallback implementation.

   * Extracted to enable manual triggering.

   */

  function _fallback() internal {

    _willFallback();

    _delegate(_implementation());

  }

}



// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */

library AddressUtils {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   * as the code is not actually created until after the constructor finishes.

   * @param _addr address to check

   * @return whether the target address is a contract

   */

  function isContract(address _addr) internal view returns (bool) {

    uint256 size;

    // XXX Currently there is no better way to check if there is a contract in an address

    // than to check the size of the code at that address.

    // See https://ethereum.stackexchange.com/a/14016/36603

    // for more details about how this works.

    // TODO Check this again before the Serenity release, because all addresses will be

    // contracts then.

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(_addr) }

    return size > 0;

  }



}



// File: zos-lib/contracts/upgradeability/UpgradeabilityProxy.sol



/**

 * @title UpgradeabilityProxy

 * @dev This contract implements a proxy that allows to change the

 * implementation address to which it will delegate.

 * Such a change is called an implementation upgrade.

 */

contract UpgradeabilityProxy is Proxy {

  /**

   * @dev Emitted when the implementation is upgraded.

   * @param implementation Address of the new implementation.

   */

  event Upgraded(address indexed implementation);



  /**

   * @dev Storage slot with the address of the current implementation.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is

   * validated in the constructor.

   */

  bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;



  /**

   * @dev Contract constructor.

   * @param _implementation Address of the initial implementation.

   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.

   * It should include the signature and the parameters of the function to be called, as described in

   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.

   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.

   */

  constructor(address _implementation, bytes _data) public payable {

    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));

    _setImplementation(_implementation);

    if(_data.length > 0) {

      require(_implementation.delegatecall(_data));

    }

  }



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

   */

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);

    emit Upgraded(newImplementation);

  }



  /**

   * @dev Sets the implementation address of the proxy.

   * @param newImplementation Address of the new implementation.

   */

  function _setImplementation(address newImplementation) private {

    require(AddressUtils.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");



    bytes32 slot = IMPLEMENTATION_SLOT;



    assembly {

      sstore(slot, newImplementation)

    }

  }

}



// File: zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol



/**

 * @title AdminUpgradeabilityProxy

 * @dev This contract combines an upgradeability proxy with an authorization

 * mechanism for administrative tasks.

 * All external functions in this contract must be guarded by the

 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity

 * feature proposal that would enable this to be done automatically.

 */

contract AdminUpgradeabilityProxy is UpgradeabilityProxy {

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

  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;



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

   * Contract constructor.

   * It sets the `msg.sender` as the proxy administrator.

   * @param _implementation address of the initial implementation.

   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.

   * It should include the signature and the parameters of the function to be called, as described in

   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.

   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.

   */

  constructor(address _implementation, bytes _data) UpgradeabilityProxy(_implementation, _data) public payable {

    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));



    _setAdmin(msg.sender);

  }



  /**

   * @return The address of the proxy admin.

   */

  function admin() external view ifAdmin returns (address) {

    return _admin();

  }



  /**

   * @return The address of the implementation.

   */

  function implementation() external view ifAdmin returns (address) {

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

   */

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);

  }



  /**

   * @dev Upgrade the backing implementation of the proxy and call a function

   * on the new implementation.

   * This is useful to initialize the proxied contract.

   * @param newImplementation Address of the new implementation.

   * @param data Data to send as msg.data in the low level call.

   * It should include the signature and the parameters of the function to be called, as described in

   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.

   */

  function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {

    _upgradeTo(newImplementation);

    require(newImplementation.delegatecall(data));

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



// File: contracts/upgradeability/OwnedUpgradeabilityProxy.sol



/**

 * @title OwnedUpgradeabilityProxy

 * @notice This contract combines an upgradeability proxy with an authorization

 * mechanism for administrative tasks.

 * All external functions in this contract must be guarded by the

 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity

 * feature proposal that would enable this to be done automatically.

 */

contract OwnedUpgradeabilityProxy is AdminUpgradeabilityProxy {



    /**

     * Contract constructor.

     * It sets the `msg.sender` as the proxy administrator.

     * @param _implementation address of the initial implementation.

     */

    constructor(address _implementation) AdminUpgradeabilityProxy(_implementation, "") public {

    }



    /**

     * @notice Only fall back when the sender is not the admin.

     */

    function _willFallback() internal {

    }

}



// File: contracts/library/Conversions.sol



library Conversions {



    /**

     * @notice Converts bytes20 to string

     */

    function bytes20ToString(bytes20 _input) internal pure returns (string) {

        bytes memory bytesString = new bytes(20);

        uint256 charCount = 0;

        for (uint256 index = 0; index < 20; index++) {

            byte char = byte(bytes20(uint256(_input) * 2 ** (8 * index)));

            if (char != 0) {

                bytesString[charCount] = char;

                charCount++;

            }

        }

        bytes memory bytesStringTrimmed = new bytes(charCount);

        for (index = 0; index < charCount; index++) {

            bytesStringTrimmed[index] = bytesString[index];

        }

        return string(bytesStringTrimmed);

    }



}



// File: contracts/governance/GovernanceReference.sol



/**

* @title Governance reference to be used in other contracts

*/

interface GovernanceReference {



    /**

    * @notice Make a proposal to add/remove specified delegate to the blacklist

    */

    function submitBlacklistProposal(bytes32 _id, address _delegate, bool _blacklisted) external;



    /**

    * @notice Make a proposal to add/remove specified delegate to the blacklist

    */

    function submitActivateProposal(bytes32 _id) external;



    /**

    * @notice Vote in favor or against blacklist proposal with the specified identifier

    */

    function vote(bytes32 _id, bool _inFavor) external;



    /**

    * @notice Finalize voting and apply proposed changes if success.

    * This method will fail if voting period is not over.

    */

    function finalizeVoting(bytes32 _id) external;



    /**

    * @notice Checks if delegate is known by governance (was created by governance)

    */

    function isDelegateKnown(address _delegate) external view returns (bool);



    /**

    * @notice Unregisters delegate

    */

    function unregisterDelegate() external;



}



// File: contracts/governance/DelegateReference.sol



/**

* @title Delegate reference to be used in other contracts

*/

interface DelegateReference {

    /**

    * @notice Stake specified amount of tokens to the delegate to participate in coin distribution

    */

    function stake(uint256 _amount) external;



    /**

    * @notice Unstake specified amount of tokens from the delegate

    */

    function unstake(uint256 _amount) external;



    /**

    * @notice Return number of tokens staked by the specified staker

    */

    function stakeOf(address _staker) external view returns (uint256);



    /**

    * @notice Sets Aerum address for delegate & calling staker

    */

    function setAerumAddress(address _aerum) external;

}



// File: contracts/governance/Delegate.sol



/**

 * @title Ethereum-based contract for delegate

 */

contract Delegate is DelegateReference, Initializable, Ownable {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;

    using OperationStore for uint256[];

    using Conversions for bytes20;



    /** AER token **/

    ERC20 public token;



    /** Governance address **/

    GovernanceReference public governance;



    /** Aerum address used for coin distribution **/

    address public aerum;



    /** Description name of the delegate **/

    bytes20 public name;



    /** Stake per user address in the delegate **/

    mapping(address => uint256) public stakes;



    /** Aerum address per ethereum address in the delegate **/

    mapping(address => address) public stakerAerumAddress;



    /** Number of staked tokens locked to participate in coin distribution **/

    uint256 public lockedStake;



    uint256[] stakeHistory;

    uint256[] keepAliveHistory;

    uint256[] blacklistHistory;

    uint256[] activationHistory;



    event AerumAddressUpdated(address aerum);

    event KeepAlive(uint256 timestamp);

    event BlacklistUpdated(bool blocked);

    event IsActiveUpdated(bool active);



    event Staked(address indexed staker, uint256 amount);

    event Unstaked(address indexed staker, uint256 amount);

    event StakeLocked(uint256 amount);



    /** Check if the sender is a valid delegate **/

    modifier onlyGovernance {

        require(msg.sender == address(governance));

        _;

    }



    /** Check if the sender is a valid delegate or owner **/

    modifier onlyOwnerOrGovernance {

        require((msg.sender == address(governance)) || (msg.sender == owner()));

        _;

    }



    /** Check if delegate is approved **/

    modifier onlyForApprovedDelegate() {

        require(activationHistory.getBool(block.timestamp));

        _;

    }



    /**

    * @notice Delegate initializer

    * @dev This init is called by governance when created

    * @param _owner Delegate owner address

    * @param _token XRM token address

    * @param _name Delegate name

    * @param _aerum Delegate Aerum address

    */

    function init(address _owner, ERC20 _token, bytes20 _name, address _aerum) initializer public {

        Ownable.initialize(_owner);

        token = _token;

        name = _name;

        aerum = _aerum;

        governance = GovernanceReference(msg.sender);

    }



    /**

    * @notice Returns delegate name as string

    */

    function getName() public view returns (string) {

        return name.bytes20ToString();

    }



    /**

    * @notice Notify governance contract this delegate is still alive

    */

    function keepAlive() external onlyOwner {

        keepAliveHistory.storeTimestamp(block.timestamp);

        emit KeepAlive(block.timestamp);

    }



    /**

    * @notice Timestamp of the last keep alive message before the given timestamp

    * @param _timestamp Time for which we would like to check last keep alive call

    */

    function getKeepAliveTimestamp(uint256 _timestamp) public view returns (uint256) {

        return keepAliveHistory.getTimestamp(_timestamp);

    }



    /**

    * @notice Sets Aerum address for specific staker

    * @param _aerum Aerum address

    */

    function setAerumAddress(address _aerum) external {

        require(stakes[msg.sender] > 0);

        stakerAerumAddress[msg.sender] = _aerum;

        emit AerumAddressUpdated(_aerum);

    }



    /**

    * @notice Returns Aerum address for specific staker

    * @param _staker Staker address

    */

    function getAerumAddress(address _staker) external view returns (address) {

        return stakerAerumAddress[_staker];

    }



    /**

    * @notice Change delegate status in the blacklist

    * @param _blocked Is delegate blacklisted or not

    */

    function updateBlacklist(bool _blocked) external onlyGovernance {

        blacklistHistory.storeBool(_blocked);

        emit BlacklistUpdated(_blocked);

    }



    /**

    * @notice Whether this delegate was blacklisted at the given timestamp

    * @param _timestamp Time for which we would like to check blacklisted

    */

    function isBlacklisted(uint256 _timestamp) public view returns (bool) {

        return blacklistHistory.getBool(_timestamp);

    }



    /**

    * @notice Change delegate activations status

    * @param _active Is delegate active or not

    */

    function setActive(bool _active) external onlyGovernance {

        activationHistory.storeBool(_active);

        emit IsActiveUpdated(_active);

    }



    /**

    * @notice Whether this delegate was activated at the given timestamp

    * @param _timestamp Time for which we would like to check activation status

    */

    function isActive(uint256 _timestamp) external view returns (bool) {

        return activationHistory.getBool(_timestamp);

    }



    /**

    * @notice Deactivate delegate and return bond back

    */

    function deactivate() external onlyOwner {

        governance.unregisterDelegate();

    }



    /**

    * @notice Stake specified amount of tokens to the delegate to participate in coin distribution

    * @param _amount Amount to stake

    */

    function stake(uint256 _amount) external onlyForApprovedDelegate() {

        address staker = msg.sender;

        token.safeTransferFrom(staker, this, _amount);

        stakes[staker] = stakes[staker].add(_amount);

        emit Staked(staker, _amount);

    }



    /**

    * @notice Unstake specified amount of tokens from the delegate

    * @param _amount Amount to unstake

    */

    function unstake(uint256 _amount) external {

        address staker = msg.sender;

        require(stakes[staker] >= _amount);

        require(token.balanceOf(this).sub(_amount) >= lockedStake);

        token.safeTransfer(staker, _amount);

        stakes[staker] = stakes[staker].sub(_amount);

        emit Unstaked(staker, _amount);

    }



    /**

    * @notice Return number of tokens staked by the specified staker

    * @param _staker Staker address

    */

    function stakeOf(address _staker) external view returns (uint256) {

        return stakes[_staker];

    }



    /**

    * @notice Lock specified number of tokens in the Governance contract

    * @param _amount Amount to lock

    */

    function lockStake(uint256 _amount) external onlyOwnerOrGovernance {

        require(token.balanceOf(this) >= _amount);

        stakeHistory.storeInt(_amount);

        lockedStake = _amount;

        emit StakeLocked(_amount);

    }



    /**

    * @notice Delegate stake at the given timestamp

    * @param _timestamp Time for which we would like to check stake

    */

    function getStake(uint256 _timestamp) public view returns (uint256) {

        return stakeHistory.getInt(_timestamp);

    }



    /**

    * @notice Make a proposal to add/remove specified delegate to the blacklist

    * @param _id Proposal / voting id. Should be unique

    * @param _delegate Delegate which is affected by proposal

    * @param _blacklisted Blacklist or undo blacklist delegate

    */

    function submitBlacklistProposal(bytes32 _id, address _delegate, bool _blacklisted) external onlyOwner {

        governance.submitBlacklistProposal(_id, _delegate, _blacklisted);

    }



    /**

    * @notice Make a proposal to activate delegate. Can only be done delegate owner

    * @param _id Proposal / voting id

    */

    function submitActivateProposal(bytes32 _id) external onlyOwner {

        governance.submitActivateProposal(_id);

    }



    /**

    * @notice Vote in favor or against blacklist proposal with the specified identifier

    * @param _id Proposal / voting id

    * @param _inFavor Support or do not support proposal

    */

    function vote(bytes32 _id, bool _inFavor) external onlyOwner {

        governance.vote(_id, _inFavor);

    }



    /**

    * @notice Finalize voting and apply proposed changes if success.

    * This method will fail if voting period is not over.

    * @param _id Proposal / voting id

    */

    function finalizeVoting(bytes32 _id) external {

        governance.finalizeVoting(_id);

    }



}



// File: contracts\governance\Governance.sol



/**

 * @title Ethereum-based governance contract

 */

contract Governance is GovernanceReference, Initializable, Ownable {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;

    using OperationStore for uint256[];



    /** Period when delegates can vote from proposal submission. Hardcoded to week */

    uint256 constant votingPeriod = 60 * 60 * 24 * 7;

    /** Number of Aerum blocks when composers are updated */

    uint256 constant delegatesUpdateAerumBlocksPeriod = 1000;

    /** Bond required for delegate to be registered. Should be set to 100k */

    uint256 public delegateBond;



    /** User used to upgrade governance or delegate contracts. Owner by default */

    address public upgradeAdmin;

    /** User which can approve delegates on initial phase. Owner by default */

    address public delegateApprover;

    /** Is delegate approver renounced. If yes we won't be able to set it again */

    bool public delegateApproverRenounced;



    /** XRM token */

    ERC20 public token;



    /** List of all delegates */

    address[] public delegates;

    /** Mapping of all known delegates. It's used to quickly check if it's known delegate */

    mapping(address => bool) public knownDelegates;

    /** List of bonds known by delegate */

    mapping(address => uint256) public bonds;



    /** Min stake required to be valid delegate. We should keep full history for consensus */

    uint256[] public minBalance;

    /** Keep alive duration in which delegate should call keep alive method to be valid. We should keep full history for consensus */

    uint256[] public keepAliveDuration;

    /** Composers count. We should keep full history for consensus */

    uint256[] public composersCount;



    enum VotingCategory { BLACKLIST, ACTIVATE }



    struct Voting {

        bytes32 id;

        VotingCategory category;

        uint256 timestamp;

        address delegate;

        bool proposal;

        mapping(address => bool) votes;

        address[] voters;

    }



    /** List of active votings */

    mapping(bytes32 => Voting) public votings;



    event UpgradeAdminUpdated(address admin);

    event DelegateApproverUpdated(address admin);

    event DelegateApproverRenounced();



    event MinBalanceUpdated(uint256 balance);

    event KeepAliveDurationUpdated(uint256 duration);

    event ComposersCountUpdated(uint256 count);

    event BlacklistUpdated(address indexed delegate, bool blocked);



    event DelegateCreated(address indexed delegate, address indexed owner);

    event DelegateApproved(address indexed delegate);

    event DelegateUnregistered(address indexed delegate);

    event BondSent(address indexed delegate, uint256 amount);

    event StakeLocked(address indexed delegate, uint256 amount);



    event ProposalSubmitted(bytes32 indexed id, address indexed author, address indexed delegate, VotingCategory category, bool proposal);

    event Vote(bytes32 indexed id, address indexed voter, bool inFavor);

    event VotingFinalized(bytes32 indexed id, bool voted, bool supported);



    /** Check if delegate is known **/

    modifier onlyOwnerOrDelegateApprover() {

        require((owner() == msg.sender) || (delegateApprover == msg.sender));

        _;

    }



    /** Check if delegate is known **/

    modifier onlyKnownDelegate(address delegate) {

        require(knownDelegates[delegate]);

        _;

    }



    /** Check if the sender is a valid delegate **/

    modifier onlyValidDelegate {

        require(isDelegateValid(msg.sender, block.timestamp));

        _;

    }



    /** Check if delegate approver active **/

    modifier onlyWhenDelegateApproverActive {

        require(!delegateApproverRenounced);

        _;

    }



    /**

    * @notice Governance initializer

    * @param _owner Governance owner address

    * @param _token XRM token address

    * @param _minBalance Min stake balance required for delegate to be valid

    * @param _keepAliveDuration Max keep alive duration when delegate should sent keep alive to be valid

    * @param _delegatesLimit Max delegates / composers limit at one point of time

    * @param _delegateBond Delegate bond to be sent to create new delegate

    */

    function init(

        address _owner, address _token,

        uint256 _minBalance, uint256 _keepAliveDuration, uint256 _delegatesLimit,

        uint256 _delegateBond

    ) initializer public {

        require(_owner != address(0));

        require(_token != address(0));



        Ownable.initialize(_owner);

        token = ERC20(_token);



        delegateBond = _delegateBond;

        delegateApprover = _owner;

        upgradeAdmin = _owner;



        minBalance.storeInt(_minBalance);

        keepAliveDuration.storeInt(_keepAliveDuration);

        composersCount.storeInt(_delegatesLimit);

    }



    /**

    * @notice Set admin who can upgrade delegate contracts

    * @param _admin New upgradeability admin

    */

    function setUpgradeAdmin(address _admin) external onlyOwner {

        upgradeAdmin = _admin;

        emit UpgradeAdminUpdated(_admin);

    }



    /**

    * @notice Set user who can approve delegates

    * @param _admin New delegate approver

    */

    function setDelegateApprover(address _admin) external onlyOwner onlyWhenDelegateApproverActive {

        delegateApprover = _admin;

        emit DelegateApproverUpdated(_admin);

    }



    /**

    * @notice Set user who can approve delegates

    */

    function renouncedDelegateApprover() external onlyOwner {

        delegateApproverRenounced = true;

        delegateApprover = address(0);

        emit DelegateApproverRenounced();

    }



    /**

    * @notice Set up minimum delegate balance necessary to participate in staking

    * @param _balance Minimum delegate balance

    */

    function setMinBalance(uint256 _balance) external onlyOwner {

        minBalance.storeInt(_balance);

        emit MinBalanceUpdated(_balance);

    }



    /**

    * @notice Set up duration between keep alive message and current time to consider delegate active

    * @param _duration Keep alive duration

    */

    function setKeepAliveDuration(uint256 _duration) external onlyOwner {

        keepAliveDuration.storeInt(_duration);

        emit KeepAliveDurationUpdated(_duration);

    }



    /**

    * @notice Set up limit of delegates / composers

    * @param _count Delegates / composers count

    */

    function setComposersCount(uint256 _count) external onlyOwner {

        composersCount.storeInt(_count);

        emit ComposersCountUpdated(_count);

    }



    /**

    * @notice Change delegate status in the blacklist

    * @param _delegate Delegate to be updated

    * @param _blocked Is delegate blocked or not

    */

    function updateBlacklist(address _delegate, bool _blocked) external onlyOwner onlyKnownDelegate(_delegate) {

        Delegate(_delegate).updateBlacklist(_blocked);

        emit BlacklistUpdated(_delegate, _blocked);

    }



    /**

    * @notice Get min balance for timestamp

    * @param _timestamp Time for which delegate is blocked or not

    */

    function getMinBalance(uint256 _timestamp) external view returns (uint256) {

        return minBalance.getInt(_timestamp);

    }



    /**

    * @notice Get keep alive duration for timestamp

    * @param _timestamp Time for which keep alive duration is returned

    */

    function getKeepAliveDuration(uint256 _timestamp) external view returns (uint256) {

        return keepAliveDuration.getInt(_timestamp);

    }



    /**

    * @notice Get delegates limit for timestamp

    * @param _timestamp Time for which composers count is returned

    */

    function getComposersCount(uint256 _timestamp) external view returns (uint256) {

        return composersCount.getInt(_timestamp);

    }



    /**

    * @notice locks delegate stake by owner

    * @param _delegate Delegate to lock stake

    * @param _amount Stake amount to lock

    */

    function lockStake(address _delegate, uint256 _amount) external onlyOwner onlyKnownDelegate(_delegate) {

        Delegate(_delegate).lockStake(_amount);

        emit StakeLocked(_delegate, _amount);

    }



    /**

    * @notice Create new delegate contract, get bond and transfer ownership to a caller

    * @param _name Delegate name

    * @param _aerum Delegate Aerum address

    */

    function createDelegate(bytes20 _name, address _aerum) external returns (address) {

        token.safeTransferFrom(msg.sender, address(this), delegateBond);



        Delegate impl = new Delegate();

        OwnedUpgradeabilityProxy proxy = new OwnedUpgradeabilityProxy(impl);

        proxy.changeAdmin(upgradeAdmin);

        Delegate wrapper = Delegate(proxy);

        wrapper.init(msg.sender, token, _name, _aerum);



        address proxyAddr = address(wrapper);

        knownDelegates[proxyAddr] = true;

        bonds[proxyAddr] = delegateBond;



        emit DelegateCreated(proxyAddr, msg.sender);



        return proxyAddr;

    }



    /**

    * @notice Register specified delegate by delegate approver

    * @param _delegate Delegate to be approved

    */

    function approveDelegate(address _delegate) external onlyOwnerOrDelegateApprover onlyKnownDelegate(_delegate) {

        approveDelegateInternal(_delegate);

    }



    /**

    * @notice Register specified delegate (by delegate approver or voting)

    * @param _delegate Delegate to be approved

    */

    function approveDelegateInternal(address _delegate) internal {

        require(bonds[_delegate] >= delegateBond);



        Delegate(_delegate).setActive(true);



        emit DelegateApproved(_delegate);



        for (uint256 index = 0; index < delegates.length; index++) {

            if (delegates[index] == _delegate) {

                // delegate already registered

                return;

            }

        }

        delegates.push(_delegate);

    }



    /**

    * @notice Unregister specified delegate. Can only be called by delegate itself

    */

    function unregisterDelegate() external onlyKnownDelegate(msg.sender) {

        address delegateAddr = msg.sender;

        Delegate delegate = Delegate(delegateAddr);

        require(delegate.isActive(block.timestamp));



        uint256 bond = bonds[delegateAddr];

        bonds[delegateAddr] = 0;

        token.safeTransfer(delegate.owner(), bond);

        delegate.setActive(false);



        emit DelegateUnregistered(delegateAddr);

    }



    /**

    * @notice Send bond for specified delegate, should be used when unregistered delegate wants to be registered again

    * @param _delegate Delegate which will receive bond

    * @param _amount Bond amount

    */

    function sendBond(address _delegate, uint256 _amount) external onlyKnownDelegate(_delegate) {

        token.safeTransferFrom(msg.sender, address(this), _amount);

        bonds[_delegate] = bonds[_delegate].add(_amount);

        emit BondSent(_delegate, _amount);

    }



    /**

    * @notice Whether specified delegate is known by governance, created by governance

    * @param _delegate Delegate address to check

    */

    function isDelegateKnown(address _delegate) public view returns (bool) {

        return knownDelegates[_delegate];

    }



    /**

    * @notice List of composers for the specified block number and timestamp. This method is used by AerumGo

    * @param _blockNum Aerum block number. Used for delegates list shifting

    * @param _timestamp Time at which composers list is requested

    */

    function getComposers(uint256 _blockNum, uint256 _timestamp) external view returns (address[]) {

        (address[] memory candidates,) = getValidDelegates(_timestamp);

        uint256 candidatesLength = candidates.length;



        uint256 limit = composersCount.getInt(_timestamp);

        if (candidatesLength < limit) {

            limit = candidatesLength;

        }



        address[] memory composers = new address[](limit);



        if (candidatesLength == 0) {

            return composers;

        }



        uint256 first = _blockNum.div(delegatesUpdateAerumBlocksPeriod) % candidatesLength;

        for (uint256 index = 0; index < limit; index++) {

            composers[index] = candidates[(first + index) % candidatesLength];

        }



        return composers;

    }



    /**

    * @notice List of all active delegates addresses

    */

    function getDelegates() public view returns (address[]) {

        return delegates;

    }



    /**

    * @notice Returns number of active delegates

    */

    function getDelegateCount() public view returns (uint256) {

        return delegates.length;

    }



    /**

    * @notice List of valid delegates which might be composers and their names

    * @param _timestamp Time at which delegates list is requested

    */

    function getValidDelegates(uint256 _timestamp) public view returns (address[], bytes20[]) {

        address[] memory array = new address[](delegates.length);

        uint16 length = 0;

        for (uint256 i = 0; i < delegates.length; i++) {

            if (isDelegateValid(delegates[i], _timestamp)) {

                array[length] = delegates[i];

                length++;

            }

        }

        address[] memory addresses = new address[](length);

        bytes20[] memory names = new bytes20[](length);

        for (uint256 j = 0; j < length; j++) {

            Delegate delegate = Delegate(array[j]);

            addresses[j] = delegate.aerum();

            names[j] = delegate.name();

        }

        return (addresses, names);

    }



    /**

    * @notice Returns valid delegates count

    */

    function getValidDelegateCount() public view returns (uint256) {

        (address[] memory validDelegates,) = getValidDelegates(block.timestamp);

        return validDelegates.length;

    }



    /**

    * @notice Whether specified delegate can be a composer

    * @param _delegate Delegate address to validate

    * @param _timestamp Time at which check is requested

    */

    function isDelegateValid(address _delegate, uint256 _timestamp) public view returns (bool) {

        if (!knownDelegates[_delegate]) {

            // Delegate not owned by this contract

            return false;

        }

        Delegate proxy = Delegate(_delegate);

        // Delegate has not been activated

        if (!proxy.isActive(_timestamp)) {

            return false;

        }

        // Delegate has not been blacklisted

        if (proxy.isBlacklisted(_timestamp)) {

            return false;

        }

        // Delegate has enough minimal stake to participate in consensus

        uint256 stake = proxy.getStake(_timestamp);

        if (stake < minBalance.getInt(_timestamp)) {

            return false;

        }

        // Delegate has produced a keep-alive message in last 24h

        uint256 lastKeepAlive = proxy.getKeepAliveTimestamp(_timestamp);

        return lastKeepAlive.add(keepAliveDuration.getInt(_timestamp)) >= block.timestamp;

    }



    /**

    * @notice Make a proposal to approved calling delegate

    * @param _id Voting id

    */

    function submitActivateProposal(bytes32 _id) external onlyKnownDelegate(msg.sender) {

        address delegate = msg.sender;

        require(!Delegate(delegate).isActive(block.timestamp));



        submitProposal(_id, delegate, VotingCategory.ACTIVATE, true);

    }



    /**

    * @notice Make a proposal to add/remove specified delegate to the blacklist

    * @param _id Voting id

    * @param _delegate Delegate affected by voting

    * @param _proposal Should be blacklisted on un blacklisted

    */

    function submitBlacklistProposal(bytes32 _id, address _delegate, bool _proposal) external onlyValidDelegate {

        submitProposal(_id, _delegate, VotingCategory.BLACKLIST, _proposal);

    }



    /**

    * @notice Make generic proposal

    * @param _id Voting id

    * @param _delegate Delegate affected by voting

    * @param _category Voting category: activate or blacklist

    * @param _proposal Should be blacklisted on un blacklisted

    */

    function submitProposal(bytes32 _id, address _delegate, VotingCategory _category, bool _proposal) internal {

        // make sure voting is unique

        require(votings[_id].id != _id);



        Voting memory voting = Voting({

            id : _id,

            category : _category,

            timestamp : block.timestamp,

            delegate : _delegate,

            proposal : _proposal,

            voters : new address[](0)

        });



        votings[_id] = voting;



        emit ProposalSubmitted(_id, msg.sender, _delegate, _category, _proposal);

    }



    /**

    * @notice Vote in favor or against proposal with the specified identifier

    * @param _id Voting id

    * @param _inFavor Support proposal or not

    */

    function vote(bytes32 _id, bool _inFavor) external onlyValidDelegate {

        Voting storage voting = votings[_id];

        // have specified blacklist voting

        require(voting.id == _id);

        // voting is still active

        require(voting.timestamp.add(votingPeriod) > block.timestamp);



        address voter = msg.sender;

        for (uint256 index = 0; index < voting.voters.length; index++) {

            if (voting.voters[index] == voter) {

                // delegate already voted

                return;

            }

        }



        voting.voters.push(voter);

        voting.votes[voter] = _inFavor;



        emit Vote(_id, voter, _inFavor);

    }



    /**

    * @notice Finalize voting and apply proposed changes if success.

    * This method will fail if voting period is not over.

    * @param _id Voting id

    */

    function finalizeVoting(bytes32 _id) external {

        bool voted;

        bool supported;

        Voting storage voting = votings[_id];

        // have specified blacklist voting

        require(voting.id == _id);

        // voting period if finished

        require(voting.timestamp.add(votingPeriod) <= block.timestamp);



        uint256 requiredVotesNumber = getValidDelegateCount() * 3 / 10;

        if (voting.voters.length >= requiredVotesNumber) {

            voted = true;

            uint256 proponents = 0;

            for (uint256 index = 0; index < voting.voters.length; index++) {

                if (voting.votes[voting.voters[index]]) {

                    proponents++;

                }

            }

            if (proponents * 2 > voting.voters.length) {

                supported = true;

                if (voting.category == VotingCategory.BLACKLIST) {

                    Delegate(voting.delegate).updateBlacklist(voting.proposal);

                }

                // NOTE: It's always true for activate

                if (voting.category == VotingCategory.ACTIVATE) {

                    approveDelegateInternal(voting.delegate);

                }

            }

        }



        delete votings[_id];



        emit VotingFinalized(_id, voted, supported);

    }



    /**

    * @notice Returns voting details by id

    * @param _id Voting id

    */

    function getVotingDetails(bytes32 _id) external view returns (bytes32, uint256, address, VotingCategory, bool, address[], bool[]) {

        Voting storage voting = votings[_id];

        address[] storage voters = voting.voters;



        bool[] memory votes = new bool[] (voters.length);

        for (uint256 index = 0; index < voters.length; index++) {

            votes[index] = voting.votes[voters[index]];

        }



        return (voting.id, voting.timestamp, voting.delegate, voting.category, voting.proposal, voters, votes);

    }



}