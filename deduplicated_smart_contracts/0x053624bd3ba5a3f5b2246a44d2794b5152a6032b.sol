/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity ^0.5.13;


/// @title Spawn
/// @author 0age (@0age) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @notice This contract provides creation code that is used by Spawner in order
/// to initialize and deploy eip-1167 minimal proxies for a given logic contract.
contract Spawn {
  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    // delegatecall into the logic contract to perform initialization.
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      // pass along failure message from delegatecall and revert.
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    // place eip-1167 runtime code in memory.
    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d73),
      logicContract,
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    // return eip-1167 code to write it to spawned contract runtime.
    assembly {
      return(add(0x20, runtimeCode), 45) // eip-1167 runtime code, length
    }
  }
}

/// @title Spawner
/// @author 0age (@0age) and Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @notice This contract spawns and initializes eip-1167 minimal proxies that
/// point to existing logic contracts. The logic contracts need to have an
/// initializer function that should only callable when no contract exists at
/// their current address (i.e. it is being `DELEGATECALL`ed from a constructor).
contract Spawner {
  
  /// @notice Internal function for spawning an eip-1167 minimal proxy using `CREATE2`.
  /// @param creator address The address of the account creating the proxy.
  /// @param logicContract address The address of the logic contract.
  /// @param initializationCalldata bytes The calldata that will be supplied to
  /// the `DELEGATECALL` from the spawned contract to the logic contract during
  /// contract creation.
  /// @return The address of the newly-spawned contract.
  function _spawn(
    address creator,
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {

    // get instance code and hash

    bytes memory initCode;
    bytes32 initCodeHash;
    (initCode, initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    // get valid create2 target

    (address target, bytes32 safeSalt) = _getNextNonceTargetWithInitCodeHash(creator, initCodeHash);

    // spawn create2 instance and validate

    return _executeSpawnCreate2(initCode, safeSalt, target);
  }

  /// @notice Internal function for spawning an eip-1167 minimal proxy using `CREATE2`.
  /// @param creator address The address of the account creating the proxy.
  /// @param logicContract address The address of the logic contract.
  /// @param initializationCalldata bytes The calldata that will be supplied to
  /// the `DELEGATECALL` from the spawned contract to the logic contract during
  /// contract creation.
  /// @param salt bytes32 A user defined salt.
  /// @return The address of the newly-spawned contract.
  function _spawnSalty(
    address creator,
    address logicContract,
    bytes memory initializationCalldata,
    bytes32 salt
  ) internal returns (address spawnedContract) {

    // get instance code and hash

    bytes memory initCode;
    bytes32 initCodeHash;
    (initCode, initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    // get valid create2 target

    (address target, bytes32 safeSalt, bool validity) = _getSaltyTargetWithInitCodeHash(creator, initCodeHash, salt);
    require(validity, "contract already deployed with supplied salt");

    // spawn create2 instance and validate

    return _executeSpawnCreate2(initCode, safeSalt, target);
  }

  /// @notice Private function for spawning an eip-1167 minimal proxy using `CREATE2`.
  /// Reverts with appropriate error string if deployment is unsuccessful.
  /// @param initCode bytes The spawner code and initialization calldata.
  /// @param safeSalt bytes32 A valid salt hashed with creator address.
  /// @param target address The expected address of the proxy.
  /// @return The address of the newly-spawned contract.
  function _executeSpawnCreate2(bytes memory initCode, bytes32 safeSalt, address target) private returns (address spawnedContract) {
    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      spawnedContract := create2(             // call `CREATE2` w/ 4 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size,                         // pass in init code's length.
        safeSalt                              // pass in the salt value.
      )

      // pass along failure message from failed contract deployment and revert.
      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    // validate spawned instance matches target
    require(spawnedContract == target, "attempted deployment to unexpected address");

    // explicit return
    return spawnedContract;
  }

  /// @notice Internal view function for finding the expected address of the standard
  /// eip-1167 minimal proxy created using `CREATE2` with a given logic contract,
  /// salt, and initialization calldata payload.
  /// @param creator address The address of the account creating the proxy.
  /// @param logicContract address The address of the logic contract.
  /// @param initializationCalldata bytes The calldata that will be supplied to
  /// the `DELEGATECALL` from the spawned contract to the logic contract during
  /// contract creation.
  /// @param salt bytes32 A user defined salt.
  /// @return target address The address of the newly-spawned contract.
  /// @return validity bool True if the `target` is available.
  function _getSaltyTarget(
    address creator,
    address logicContract,
    bytes memory initializationCalldata,
    bytes32 salt
  ) internal view returns (address target, bool validity) {

    // get initialization code

    bytes32 initCodeHash;
    ( , initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    // get valid target

    (target, , validity) = _getSaltyTargetWithInitCodeHash(creator, initCodeHash, salt);

    // explicit return
    return (target, validity);
  }

  /// @notice Internal view function for finding the expected address of the standard
  /// eip-1167 minimal proxy created using `CREATE2` with a given initCodeHash, and salt.
  /// @param creator address The address of the account creating the proxy.
  /// @param initCodeHash bytes32 The hash of initCode.
  /// @param salt bytes32 A user defined salt.
  /// @return target address The address of the newly-spawned contract.
  /// @return safeSalt bytes32 A safe salt. Must include the msg.sender address for front-running protection.
  /// @return validity bool True if the `target` is available.
  function _getSaltyTargetWithInitCodeHash(
    address creator,
    bytes32 initCodeHash,
    bytes32 salt
  ) private view returns (address target, bytes32 safeSalt, bool validity) {
    // get safeSalt from input
    safeSalt = keccak256(abi.encodePacked(creator, salt));

    // get expected target
    target = _computeTargetWithCodeHash(initCodeHash, safeSalt);

    // get target validity
    validity = _getTargetValidity(target);

    // explicit return
    return (target, safeSalt, validity);
  }

  /// @notice Internal view function for finding the expected address of the standard
  /// eip-1167 minimal proxy created using `CREATE2` with a given logic contract,
  /// nonce, and initialization calldata payload.
  /// @param creator address The address of the account creating the proxy.
  /// @param logicContract address The address of the logic contract.
  /// @param initializationCalldata bytes The calldata that will be supplied to
  /// the `DELEGATECALL` from the spawned contract to the logic contract during
  /// contract creation.
  /// @return target address The address of the newly-spawned contract.
  function _getNextNonceTarget(
    address creator,
    address logicContract,
    bytes memory initializationCalldata
  ) internal view returns (address target) {

    // get initialization code

    bytes32 initCodeHash;
    ( , initCodeHash) = _getInitCodeAndHash(logicContract, initializationCalldata);

    // get valid target

    (target, ) = _getNextNonceTargetWithInitCodeHash(creator, initCodeHash);

    // explicit return
    return target;
  }

  /// @notice Internal view function for finding the expected address of the standard
  /// eip-1167 minimal proxy created using `CREATE2` with a given initCodeHash, and nonce.
  /// @param creator address The address of the account creating the proxy.
  /// @param initCodeHash bytes32 The hash of initCode.
  /// @return target address The address of the newly-spawned contract.
  /// @return safeSalt bytes32 A safe salt. Must include the msg.sender address for front-running protection.
  function _getNextNonceTargetWithInitCodeHash(
    address creator,
    bytes32 initCodeHash
  ) private view returns (address target, bytes32 safeSalt) {
    // set the initial nonce to be provided when constructing the salt.
    uint256 nonce = 0;

    while (true) {
      // get safeSalt from nonce
      safeSalt = keccak256(abi.encodePacked(creator, nonce));

      // get expected target
      target = _computeTargetWithCodeHash(initCodeHash, safeSalt);

      // validate no contract already deployed to the target address.
      // exit the loop if no contract is deployed to the target address.
      // otherwise, increment the nonce and derive a new salt.
      if (_getTargetValidity(target))
        break;
      else
        nonce++;
    }
    
    // explicit return
    return (target, safeSalt);
  }

  /// @notice Private pure function for obtaining the initCode and the initCodeHash of `logicContract` and `initializationCalldata`.
  /// @param logicContract address The address of the logic contract.
  /// @param initializationCalldata bytes The calldata that will be supplied to
  /// the `DELEGATECALL` from the spawned contract to the logic contract during
  /// contract creation.
  /// @return initCode bytes The spawner code and initialization calldata.
  /// @return initCodeHash bytes32 The hash of initCode.
  function _getInitCodeAndHash(
    address logicContract,
    bytes memory initializationCalldata
  ) private pure returns (bytes memory initCode, bytes32 initCodeHash) {
    // place creation code and constructor args of contract to spawn in memory.
    initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    // get the keccak256 hash of the init code for address derivation.
    initCodeHash = keccak256(initCode);

    // explicit return
    return (initCode, initCodeHash);
  }
  
  /// @notice Private view function for finding the expected address of the standard
  /// eip-1167 minimal proxy created using `CREATE2` with a given logic contract,
  /// salt, and initialization calldata payload.
  /// @param initCodeHash bytes32 The hash of initCode.
  /// @param safeSalt bytes32 A safe salt. Must include the msg.sender address for front-running protection.
  /// @return The address of the proxy contract with the given parameters.
  function _computeTargetWithCodeHash(
    bytes32 initCodeHash,
    bytes32 safeSalt
  ) private view returns (address target) {
    return address(    // derive the target deployment address.
      uint160(                   // downcast to match the address type.
        uint256(                 // cast to uint to truncate upper digits.
          keccak256(             // compute CREATE2 hash using 4 inputs.
            abi.encodePacked(    // pack all inputs to the hash together.
              bytes1(0xff),      // pass in the control character.
              address(this),     // pass in the address of this contract.
              safeSalt,          // pass in the safeSalt from above.
              initCodeHash       // pass in hash of contract creation code.
            )
          )
        )
      )
    );
  }

  /// @notice Private view function to validate if the `target` address is an available deployment address.
  /// @param target address The address to validate.
  /// @return validity bool True if the `target` is available.
  function _getTargetValidity(address target) private view returns (bool validity) {
    // validate no contract already deployed to the target address.
    uint256 codeSize;
    assembly { codeSize := extcodesize(target) }
    return codeSize == 0;
  }
}



/// @title iRegistry
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
interface iRegistry {

    enum FactoryStatus { Unregistered, Registered, Retired }

    event FactoryAdded(address owner, address factory, uint256 factoryID, bytes extraData);
    event FactoryRetired(address owner, address factory, uint256 factoryID);
    event InstanceRegistered(address instance, uint256 instanceIndex, address indexed creator, address indexed factory, uint256 indexed factoryID);

    // factory state functions

    function addFactory(address factory, bytes calldata extraData ) external;
    function retireFactory(address factory) external;

    // factory view functions

    function getFactoryCount() external view returns (uint256 count);
    function getFactoryStatus(address factory) external view returns (FactoryStatus status);
    function getFactoryID(address factory) external view returns (uint16 factoryID);
    function getFactoryData(address factory) external view returns (bytes memory extraData);
    function getFactoryAddress(uint16 factoryID) external view returns (address factory);
    function getFactory(address factory) external view returns (FactoryStatus state, uint16 factoryID, bytes memory extraData);
    function getFactories() external view returns (address[] memory factories);
    function getPaginatedFactories(uint256 startIndex, uint256 endIndex) external view returns (address[] memory factories);

    // instance state functions

    function register(address instance, address creator, uint80 extraData) external;

    // instance view functions

    function getInstanceType() external view returns (bytes4 instanceType);
    function getInstanceCount() external view returns (uint256 count);
    function getInstance(uint256 index) external view returns (address instance);
    function getInstances() external view returns (address[] memory instances);
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
}


/// @title iFactory
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
interface iFactory {

    event InstanceCreated(address indexed instance, address indexed creator, bytes callData);

    function create(bytes calldata callData) external returns (address instance);
    function createSalty(bytes calldata callData, bytes32 salt) external returns (address instance);
    function getInitSelector() external view returns (bytes4 initSelector);
    function getInstanceRegistry() external view returns (address instanceRegistry);
    function getTemplate() external view returns (address template);
    function getSaltyInstance(address creator, bytes calldata callData, bytes32 salt) external view returns (address instance, bool validity);
    function getNextNonceInstance(address creator, bytes calldata callData) external view returns (address instance);

    function getInstanceCreator(address instance) external view returns (address creator);
    function getInstanceType() external view returns (bytes4 instanceType);
    function getInstanceCount() external view returns (uint256 count);
    function getInstance(uint256 index) external view returns (address instance);
    function getInstances() external view returns (address[] memory instances);
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



/// @title EventMetadata
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract EventMetadata {

    event MetadataSet(bytes metadata);

    // state functions

    function _setMetadata(bytes memory metadata) internal {
        emit MetadataSet(metadata);
    }
}



/// @title Operated
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract Operated {

    address private _operator;

    event OperatorUpdated(address operator);

    // state functions

    function _setOperator(address operator) internal {

        // can only be called when operator is null
        require(_operator == address(0), "operator already set");

        // cannot set to address 0
        require(operator != address(0), "cannot set operator to address 0");

        // set operator in storage
        _operator = operator;

        // emit event
        emit OperatorUpdated(operator);
    }

    function _transferOperator(address operator) internal {

        // requires existing operator
        require(_operator != address(0), "only when operator set");

        // cannot set to address 0
        require(operator != address(0), "cannot set operator to address 0");

        // set operator in storage
        _operator = operator;

        // emit event
        emit OperatorUpdated(operator);
    }

    function _renounceOperator() internal {

        // requires existing operator
        require(_operator != address(0), "only when operator set");

        // set operator in storage
        _operator = address(0);

        // emit event
        emit OperatorUpdated(address(0));
    }

    // view functions

    function getOperator() public view returns (address operator) {
        return _operator;
    }

    function isOperator(address caller) internal view returns (bool ok) {
        return caller == _operator;
    }

}



/// @title Template
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract Template {

    address private _factory;

    // modifiers

    modifier initializeTemplate() {
        // set factory
        _factory = msg.sender;

        // only allow function to be `DELEGATECALL`ed from within a constructor.
        uint32 codeSize;
        assembly { codeSize := extcodesize(address) }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    // view functions

    function getCreator() public view returns (address creator) {
        // iFactory(...) would revert if _factory address is not actually a factory contract
        return iFactory(_factory).getInstanceCreator(address(this));
    }

    function isCreator(address caller) internal view returns (bool ok) {
        return (caller == getCreator());
    }

    function getFactory() public view returns (address factory) {
        return _factory;
    }

}



/// @title Deadline
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Deadline.png
contract Deadline {

    using SafeMath for uint256;

    uint256 private _deadline;

    event DeadlineSet(uint256 deadline);

    // state functions

    function _setDeadline(uint256 deadline) internal {
        _deadline = deadline;
        emit DeadlineSet(deadline);
    }

    // view functions

    function getDeadline() public view returns (uint256 deadline) {
        return _deadline;
    }

    // timeRemaining will default to 0 if _setDeadline is not called
    // if the now exceeds deadline, just return 0 as the timeRemaining
    function getTimeRemaining() public view returns (uint256 time) {
        if (_deadline > now)
            return _deadline.sub(now);
        else
            return 0;
    }

    enum DeadlineStatus { isNull, isSet, isOver }
    /// Return the status of the deadline state machine
    /// - isNull: the deadline has not been set
    /// - isSet: the deadline is set, but has not passed
    /// - isOver: the deadline has passed
    function getDeadlineStatus() public view returns (DeadlineStatus status) {
        if (_deadline == 0)
            return DeadlineStatus.isNull;
        if (_deadline > now)
            return DeadlineStatus.isSet;
        else
            return DeadlineStatus.isOver;
    }

    function isNull() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isNull;
    }

    function isSet() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isSet;
    }

    function isOver() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isOver;
    }

}


/* @title DecimalMath
 * @dev taken from https://github.com/PolymathNetwork/polymath-core
 * @dev Apache v2 License
 */
library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant e18 = uint256(10) ** uint256(18);

    /**
     * @notice This function multiplies two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of multiplication represented as (decimal * 10**DECIMALS)
     */
    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), (e18) / 2) / (e18);
    }

    /**
     * @notice This function divides two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of division represented as (decimal * 10**DECIMALS)
     */
    function div(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, (e18)), y / 2) / y;
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




/// @title Deposit
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Deposit.png
contract Deposit {

    using SafeMath for uint256;

    mapping (address => uint256) private _deposit;

    event DepositIncreased(address user, uint256 amount, uint256 newDeposit);
    event DepositDecreased(address user, uint256 amount, uint256 newDeposit);

    function _increaseDeposit(address user, uint256 amountToAdd) internal returns (uint256 newDeposit) {
        // calculate new deposit amount
        newDeposit = _deposit[user].add(amountToAdd);

        // set new stake to storage
        _deposit[user] = newDeposit;

        // emit event
        emit DepositIncreased(user, amountToAdd, newDeposit);

        // return
        return newDeposit;
    }

    function _decreaseDeposit(address user, uint256 amountToRemove) internal returns (uint256 newDeposit) {
        // get current deposit
        uint256 currentDeposit = _deposit[user];

        // check if sufficient deposit
        require(currentDeposit >= amountToRemove, "insufficient deposit to remove");

        // calculate new deposit amount
        newDeposit = currentDeposit.sub(amountToRemove);

        // set new stake to storage
        _deposit[user] = newDeposit;

        // emit event
        emit DepositDecreased(user, amountToRemove, newDeposit);

        // return
        return newDeposit;
    }

    function _clearDeposit(address user) internal returns (uint256 amountRemoved) {
        // get current deposit
        uint256 currentDeposit = _deposit[user];

        // remove deposit
        _decreaseDeposit(user, currentDeposit);

        // return
        return currentDeposit;
    }

    // view functions

    function getDeposit(address user) public view returns (uint256 deposit) {
        return _deposit[user];
    }

}



/// @title iNMR
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract iNMR {

    // ERC20
    function totalSupply() external returns (uint256);
    function balanceOf(address _owner) external returns (uint256);
    function allowance(address _owner, address _spender) external returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool ok);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool ok);
    function approve(address _spender, uint256 _value) external returns (bool ok);
    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);

    /// @dev Behavior has changed to match OpenZeppelin's `ERC20Burnable.burn(uint256 amount)`
    /// @dev Destoys `amount` tokens from `msg.sender`, reducing the total supply.
    ///
    /// Emits a `Transfer` event with `to` set to the zero address.
    /// Requirements:
    /// - `account` must have at least `amount` tokens.
    function mint(uint256 _value) external returns (bool ok);

    /// @dev Behavior has changed to match OpenZeppelin's `ERC20Burnable.burnFrom(address account, uint256 amount)`
    /// @dev Destoys `amount` tokens from `account`.`amount` is then deducted
    /// from the caller's allowance.
    ///
    /// Emits an `Approval` event indicating the updated allowance.
    /// Emits a `Transfer` event with `to` set to the zero address.
    ///
    /// Requirements:
    /// - `account` must have at least `amount` tokens.
    /// - `account` must have approved `msg.sender` with allowance of at least `amount` tokens.
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);
}





/// @title Factory
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @notice The factory contract implements a standard interface for creating EIP-1167 clones of a given template contract.
///         The create functions accept abi-encoded calldata used to initialize the spawned templates.
contract Factory is Spawner, iFactory {

    address[] private _instances;
    mapping (address => address) private _instanceCreator;

    /* NOTE: The following items can be hardcoded as constant to save ~200 gas/create */
    address private _templateContract;
    bytes4 private _initSelector;
    address private _instanceRegistry;
    bytes4 private _instanceType;

    event InstanceCreated(address indexed instance, address indexed creator, bytes callData);

    /// @notice Constructior
    /// @param instanceRegistry address of the registry where all clones are registered.
    /// @param templateContract address of the template used for making clones.
    /// @param instanceType bytes4 identifier for the type of the factory. This must match the type of the registry.
    /// @param initSelector bytes4 selector for the template initialize function.
    function _initialize(address instanceRegistry, address templateContract, bytes4 instanceType, bytes4 initSelector) internal {
        // set instance registry
        _instanceRegistry = instanceRegistry;
        // set logic contract
        _templateContract = templateContract;
        // set initSelector
        _initSelector = initSelector;
        // validate correct instance registry
        require(instanceType == iRegistry(instanceRegistry).getInstanceType(), 'incorrect instance type');
        // set instanceType
        _instanceType = instanceType;
    }

    // IFactory methods

    /// @notice Create clone of the template using a nonce.
    ///         The nonce is unique for clones with the same initialization calldata.
    ///         The nonce can be used to determine the address of the clone before creation.
    ///         The callData must be prepended by the function selector of the template's initialize function and include all parameters.
    /// @param callData bytes blob of abi-encoded calldata used to initialize the template.
    /// @return instance address of the clone that was created.
    function create(bytes memory callData) public returns (address instance) {
        // deploy new contract: initialize it & write minimal proxy to runtime.
        instance = Spawner._spawn(msg.sender, getTemplate(), callData);

        _createHelper(instance, callData);

        return instance;
    }

    /// @notice Create clone of the template using a salt.
    ///         The salt must be unique for clones with the same initialization calldata.
    ///         The salt can be used to determine the address of the clone before creation.
    ///         The callData must be prepended by the function selector of the template's initialize function and include all parameters.
    /// @param callData bytes blob of abi-encoded calldata used to initialize the template.
    /// @return instance address of the clone that was created.
    function createSalty(bytes memory callData, bytes32 salt) public returns (address instance) {
        // deploy new contract: initialize it & write minimal proxy to runtime.
        instance = Spawner._spawnSalty(msg.sender, getTemplate(), callData, salt);

        _createHelper(instance, callData);

        return instance;
    }

    function _createHelper(address instance, bytes memory callData) private {
        // add the instance to the array
        _instances.push(instance);
        // set instance creator
        _instanceCreator[instance] = msg.sender;
        // add the instance to the instance registry
        iRegistry(getInstanceRegistry()).register(instance, msg.sender, uint80(0));
        // emit event
        emit InstanceCreated(instance, msg.sender, callData);
    }

    /// @notice Get the address of an instance for a given salt
    function getSaltyInstance(
        address creator,
        bytes memory callData,
        bytes32 salt
    ) public view returns (address instance, bool validity) {
        return Spawner._getSaltyTarget(creator, getTemplate(), callData, salt);
    }

    function getNextNonceInstance(
        address creator,
        bytes memory callData
    ) public view returns (address target) {
        return Spawner._getNextNonceTarget(creator, getTemplate(), callData);
    }

    function getInstanceCreator(address instance) public view returns (address creator) {
        return _instanceCreator[instance];
    }

    function getInstanceType() public view returns (bytes4 instanceType) {
        return _instanceType;
    }

    function getInitSelector() public view returns (bytes4 initSelector) {
        return _initSelector;
    }

    function getInstanceRegistry() public view returns (address instanceRegistry) {
        return _instanceRegistry;
    }

    function getTemplate() public view returns (address template) {
        return _templateContract;
    }

    function getInstanceCount() public view returns (uint256 count) {
        return _instances.length;
    }

    function getInstance(uint256 index) public view returns (address instance) {
        require(index < _instances.length, "index out of range");
        return _instances[index];
    }

    function getInstances() public view returns (address[] memory instances) {
        return _instances;
    }

    // Note: startIndex is inclusive, endIndex exclusive
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) public view returns (address[] memory instances) {
        require(startIndex < endIndex, "startIndex must be less than endIndex");
        require(endIndex <= _instances.length, "end index out of range");

        // initialize fixed size memory array
        address[] memory range = new address[](endIndex - startIndex);

        // Populate array with addresses in range
        for (uint256 i = startIndex; i < endIndex; i++) {
            range[i - startIndex] = _instances[i];
        }

        // return array of addresses
        return range;
    }

}




/// @title Countdown
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Countdown.png
contract Countdown is Deadline {

    using SafeMath for uint256;

    uint256 private _length;

    event LengthSet(uint256 length);

    // state functions

    function _setLength(uint256 length) internal {
        _length = length;
        emit LengthSet(length);
    }

    function _start() internal returns (uint256 deadline) {
        deadline = _length.add(now);
        Deadline._setDeadline(deadline);
        return deadline;
    }

    // view functions

    function getLength() public view returns (uint256 length) {
        return _length;
    }

    enum CountdownStatus { isNull, isSet, isActive, isOver }
    /// Return the status of the state machine
    /// - isNull: the length has not been set
    /// - isSet: the length is set, but the countdown is not started
    /// - isActive: the countdown has started but not yet ended
    /// - isOver: the countdown has completed
    function getCountdownStatus() public view returns (CountdownStatus status) {
        if (_length == 0)
            return CountdownStatus.isNull;
        if (Deadline.getDeadlineStatus() == DeadlineStatus.isNull)
            return CountdownStatus.isSet;
        if (Deadline.getDeadlineStatus() != DeadlineStatus.isOver)
            return CountdownStatus.isActive;
        else
            return CountdownStatus.isOver;
    }

    function isNull() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isNull;
    }

    function isSet() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isSet;
    }

    function isActive() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isActive;
    }

    function isOver() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isOver;
    }

}


/// @title BurnNMR
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @notice Allows for calling NMR burn functions using regular openzeppelin ERC20Burnable interface and revert on failure.
contract BurnNMR {

    // address of the token
    address private constant _Token = address(0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671);

    /// @notice Burns a specific amount of NMR from this contract.
    /// @param value uint256 The amount of NMR (18 decimals) to be burned.
    function _burn(uint256 value) internal {
        require(iNMR(_Token).mint(value), "nmr burn failed");
    }

    /// @dev Burns a specific amount of NMR from the target address and decrements allowance.
    /// @param from address The account whose tokens will be burned.
    /// @param value uint256 The amount of NMR (18 decimals) to be burned.
    function _burnFrom(address from, uint256 value) internal {
        require(iNMR(_Token).numeraiTransfer(from, value), "nmr burnFrom failed");
    }

    /// @notice Get the NMR token address.
    /// @return token address The NMR token address.
    function getToken() public pure returns (address token) {
        token = _Token;
    }

}






/// @title Staking
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Staking.png
contract Staking is Deposit, BurnNMR {

    using SafeMath for uint256;

    event StakeAdded(address staker, address funder, uint256 amount);
    event StakeTaken(address staker, address recipient, uint256 amount);
    event StakeBurned(address staker, uint256 amount);

    function _addStake(address staker, address funder, uint256 amountToAdd) internal {
        // update deposit
        Deposit._increaseDeposit(staker, amountToAdd);

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transferFrom(funder, address(this), amountToAdd), "token transfer failed");

        // emit event
        emit StakeAdded(staker, funder, amountToAdd);
    }

    function _takeStake(address staker, address recipient, uint256 amountToTake) internal returns (uint256 newStake) {
        // update deposit
        uint256 newDeposit = Deposit._decreaseDeposit(staker, amountToTake);

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transfer(recipient, amountToTake), "token transfer failed");

        // emit event
        emit StakeTaken(staker, recipient, amountToTake);

        // return
        return newDeposit;
    }

    function _takeFullStake(address staker, address recipient) internal returns (uint256 amountTaken) {
        // get deposit
        uint256 currentDeposit = Deposit.getDeposit(staker);

        // take full stake
        _takeStake(staker, recipient, currentDeposit);

        // return
        return currentDeposit;
    }

    function _burnStake(address staker, uint256 amountToBurn) internal returns (uint256 newStake) {
        // update deposit
        uint256 newDeposit = Deposit._decreaseDeposit(staker, amountToBurn);

        // burn the stake amount
        BurnNMR._burn(amountToBurn);

        // emit event
        emit StakeBurned(staker, amountToBurn);

        // return
        return newDeposit;
    }

    function _burnFullStake(address staker) internal returns (uint256 amountBurned) {
        // get deposit
        uint256 currentDeposit = Deposit.getDeposit(staker);

        // burn full stake
        _burnStake(staker, currentDeposit);

        // return
        return currentDeposit;
    }

    // view functions

    function getStake(address staker) public view returns (uint256 stake) {
        return Deposit.getDeposit(staker);
    }

}




/// @title Griefing
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Griefing.png
contract Griefing is Staking {

    enum RatioType { NaN, Inf, Dec }

    mapping (address => GriefRatio) private _griefRatio;
    struct GriefRatio {
        uint256 ratio;
        RatioType ratioType;
   }

    event RatioSet(address staker, uint256 ratio, RatioType ratioType);
    event Griefed(address punisher, address staker, uint256 punishment, uint256 cost, bytes message);

    uint256 internal constant e18 = uint256(10) ** uint256(18);

    // state functions

    /// @notice Set the grief ratio and type for a given staker
    /// @param staker Address of the staker
    /// @param ratio Uint256 number (18 decimals)
    ///              NOTE: ratio must be 0 if ratioType is Inf or NaN
    /// @param ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    function _setRatio(address staker, uint256 ratio, RatioType ratioType) internal {
        if (ratioType == RatioType.NaN || ratioType == RatioType.Inf) {
            require(ratio == 0, "ratio must be 0 when ratioType is NaN or Inf");
        }

        // set data in storage
        _griefRatio[staker].ratio = ratio;
        _griefRatio[staker].ratioType = ratioType;

        // emit event
        emit RatioSet(staker, ratio, ratioType);
    }

    /// @notice Punish a stake through griefing
    ///         NOTE: the cost of the punishment is taken form the account of the punisher. This therefore requires appropriate ERC-20 token approval.
    /// @param punisher Address of the punisher
    /// @param staker Address of the staker
    /// @param punishment Amount of NMR (18 decimals) to punish
    /// @param message Bytes reason string for the punishment
    /// @return cost Amount of NMR (18 decimals) to pay
    function _grief(
        address punisher,
        address staker,
        uint256 punishment,
        bytes memory message
    ) internal returns (uint256 cost) {
        // get grief data from storage
        uint256 ratio = _griefRatio[staker].ratio;
        RatioType ratioType = _griefRatio[staker].ratioType;

        require(ratioType != RatioType.NaN, "no punishment allowed");

        // calculate cost
        // getCost also acts as a guard when _setRatio is not called before
        cost = getCost(ratio, punishment, ratioType);

        // burn the cost from the punisher's balance
        BurnNMR._burnFrom(punisher, cost);

        // burn the punishment from the target's stake
        Staking._burnStake(staker, punishment);

        // emit event
        emit Griefed(punisher, staker, punishment, cost, message);

        // return
        return cost;
    }

    // view functions

    /// @notice Get the ratio of a staker
    /// @param staker Address of the staker
    /// @return ratio Uint256 number (18 decimals)
    /// @return ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    function getRatio(address staker) public view returns (uint256 ratio, RatioType ratioType) {
        // get stake data from storage
        return (_griefRatio[staker].ratio, _griefRatio[staker].ratioType);
    }

    // pure functions

    /// @notice Get exact cost for a given punishment and ratio
    /// @param ratio Uint256 number (18 decimals)
    /// @param punishment Amount of NMR (18 decimals) to punish
    /// @param ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    /// @return cost Amount of NMR (18 decimals) to pay
    function getCost(uint256 ratio, uint256 punishment, RatioType ratioType) public pure returns(uint256 cost) {
        if (ratioType == RatioType.Dec) {
            return DecimalMath.mul(SafeMath.mul(punishment, e18), ratio) / e18;
        }
        if (ratioType == RatioType.Inf)
            return 0;
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

    /// @notice Get approximate punishment for a given cost and ratio.
    ///         The punishment is an approximate value due to quantization / rounding.
    /// @param ratio Uint256 number (18 decimals)
    /// @param cost Amount of NMR (18 decimals) to pay
    /// @param ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    /// @return punishment Approximate amount of NMR (18 decimals) to punish
    function getPunishment(uint256 ratio, uint256 cost, RatioType ratioType) public pure returns(uint256 punishment) {
        if (ratioType == RatioType.Dec) {
            return DecimalMath.div(SafeMath.mul(cost, e18), ratio) / e18;
        }
        if (ratioType == RatioType.Inf)
            revert("ratioType cannot be RatioType.Inf");
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

}







/// @title CountdownGriefing
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/agreements/CountdownGriefing.png
/// @notice This agreement template allows a staker to grant permission to a counterparty to punish, reward, or release their stake until the countdown is completed.
///         A new instance is initialized by the factory using the `initData` received. See the `initialize()` function for details on initialization parameters.
///         Notable features:
///             - The staker can increase the stake at any time before the end of the countdown.
///             - The counterparty can increase, release, or punish the stake at any time before the end of the countdown.
///             - The agreement can be terminated by the staker by starting the countdown. Once the countdown completes the staker can retrieve their remaining stake.
///             - Punishments use griefing which requires the counterparty to pay an appropriate amount based on the desired punishment and a predetermined ratio.
///             - An operator can optionally be defined to grant full permissions to a trusted external address or contract.
contract CountdownGriefing is Countdown, Griefing, EventMetadata, Operated, Template {

    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address staker;
        address counterparty;
    }

    event Initialized(address operator, address staker, address counterparty, uint256 ratio, Griefing.RatioType ratioType, uint256 countdownLength, bytes metadata);

    /// @notice Constructor used to initialize the agreement parameters.
    ///         All parameters are passed as ABI-encoded calldata to the factory. This calldata must include the function selector.
    /// @dev Access Control: only factory
    ///      State Machine: before all
    /// @param operator address of the operator that overrides access control. Optional parameter. Passing the address(0) will disable operator functionality.
    /// @param staker address of the staker who owns the stake. Required parameter. This address is the only one able to retrieve the stake and cannot be changed.
    /// @param counterparty address of the counterparty who has the right to reward, release, and punish the stake. Required parameter. This address cannot be changed.
    /// @param ratio uint256 number (18 decimals) used to determine punishment cost. Required parameter. See Griefing module for details on valid input.
    /// @param ratioType Griefing.RatioType number used to determine punishment cost. Required parameter. See Griefing module for details on valid input.
    /// @param countdownLength uint256 amount of time (in seconds) the counterparty has to punish or reward before the agreement ends. Required parameter.
    /// @param metadata bytes data (any format) to emit as event on initialization. Optional parameter.
    function initialize(
        address operator,
        address staker,
        address counterparty,
        uint256 ratio,
        Griefing.RatioType ratioType,
        uint256 countdownLength,
        bytes memory metadata
    ) public initializeTemplate() {
        // set storage values
        _data.staker = staker;
        _data.counterparty = counterparty;

        // set operator
        if (operator != address(0)) {
            Operated._setOperator(operator);
        }

        // set griefing ratio
        Griefing._setRatio(staker, ratio, ratioType);

        // set countdown length
        Countdown._setLength(countdownLength);

        // set metadata
        if (metadata.length != 0) {
            EventMetadata._setMetadata(metadata);
        }

        // log initialization params
        emit Initialized(operator, staker, counterparty, ratio, ratioType, countdownLength, metadata);
    }

    // state functions

    /// @notice Emit metadata event
    /// @dev Access Control: operator
    ///      State Machine: always
    /// @param metadata bytes data (any format) to emit as event
    function setMetadata(bytes memory metadata) public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // update metadata
        EventMetadata._setMetadata(metadata);
    }

    /// @notice Called by the staker to increase the stake
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: staker OR operator
    ///      State Machine: before isTerminated()
    /// @param amountToAdd uint256 amount of NMR (18 decimals) to be added to the stake
    function increaseStake(uint256 amountToAdd) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // require agreement is not ended
        require(!isTerminated(), "agreement ended");

        // add stake
        Staking._addStake(_data.staker, msg.sender, amountToAdd);
    }

    /// @notice Called by the counterparty to increase the stake
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: before isTerminated()
    /// @param amountToAdd uint256 amount of NMR (18 decimals) to be added to the stake
    function reward(uint256 amountToAdd) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // require agreement is not ended
        require(!isTerminated(), "agreement ended");

        // add stake
        Staking._addStake(_data.staker, msg.sender, amountToAdd);
    }

    /// @notice Called by the counterparty to punish the stake
    ///          - burns the punishment from the stake and a proportional amount from the counterparty balance
    ///          - the cost of the punishment is calculated with the `Griefing.getCost()` function using the predetermined griefing ratio
    ///          - tokens (ERC-20) are burned from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: before isTerminated()
    /// @param punishment uint256 amount of NMR (18 decimals) to be burned from the stake
    /// @param message bytes data (any format) to emit as event giving reason for the punishment
    /// @return cost uint256 amount of NMR (18 decimals) it cost to perform punishment
    function punish(uint256 punishment, bytes memory message) public returns (uint256 cost) {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // require agreement is not ended
        require(!isTerminated(), "agreement ended");

        // execute griefing
        return Griefing._grief(msg.sender, _data.staker, punishment, message);
    }

    /// @notice Called by the counterparty to release the stake to the staker
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: anytime
    /// @param amountToRelease uint256 amount of NMR (18 decimals) to be released from the stake
    function releaseStake(uint256 amountToRelease) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // release stake back to the staker
        Staking._takeStake(_data.staker, _data.staker, amountToRelease);
    }

    /// @notice Called by the staker to begin countdown to finalize the agreement
    /// @dev Access Control: staker OR operator
    ///      State Machine: before Countdown.isActive()
    /// @return deadline uint256 timestamp (Unix seconds) at which the agreement will be finalized
    function startCountdown() public returns (uint256 deadline) {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // require countdown is not started
        require(isInitialized(), "deadline already set");

        // start countdown
        return Countdown._start();
    }

    /// @notice Called by the staker to retrieve the remaining stake once the agreement has ended
    /// @dev Access Control: staker OR operator
    ///      State Machine: after Countdown.isOver()
    /// @param recipient address of the account where to send the stake
    /// @return amount uint256 amount of NMR (18 decimals) retrieved
    function retrieveStake(address recipient) public returns (uint256 amount) {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // require deadline is passed
        require(isTerminated(), "deadline not passed");

        // retrieve stake
        return Staking._takeFullStake(_data.staker, recipient);
    }

    /// @notice Called by the operator to transfer control to new operator
    /// @dev Access Control: operator
    ///      State Machine: anytime
    /// @param operator address of the new operator
    function transferOperator(address operator) public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // transfer operator
        Operated._transferOperator(operator);
    }

    /// @notice Called by the operator to renounce control
    /// @dev Access Control: operator
    ///      State Machine: anytime
    function renounceOperator() public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // renounce operator
        Operated._renounceOperator();
    }

    // view functions

    /// @notice Get the address of the staker (if set)
    /// @return staker address of the staker
    function getStaker() public view returns (address staker) {
        return _data.staker;
    }

    /// @notice Validate if the address matches the stored staker address
    /// @param caller address to validate
    /// @return validity bool true if matching address
    function isStaker(address caller) internal view returns (bool validity) {
        return caller == getStaker();
    }

    /// @notice Get the address of the counterparty (if set)
    /// @return counterparty address of counterparty account
    function getCounterparty() public view returns (address counterparty) {
        return _data.counterparty;
    }

    /// @notice Validate if the address matches the stored counterparty address
    /// @param caller address to validate
    /// @return validity bool true if matching address
    function isCounterparty(address caller) internal view returns (bool validity) {
        return caller == getCounterparty();
    }

    /// @notice Get the current stake of the agreement
    /// @return stake uint256 amount of NMR (18 decimals) staked
    function getCurrentStake() public view returns (uint256 stake) {
        return Staking.getStake(_data.staker);
    }

    /// @notice Validate if the current stake is greater than 0
    /// @return validity bool true if non-zero stake
    function isStaked() public view returns (bool validity) {
        return getCurrentStake() > 0;
    }

    enum AgreementStatus { isInitialized, isInCountdown, isTerminated }
    /// @notice Get the status of the state machine
    /// @return status AgreementStatus from the following states:
    ///          - isInitialized: initialized but no deposits made
    ///          - isInCountdown: staker has triggered countdown to termination
    ///          - isTerminated: griefing agreement is over, staker can retrieve stake
    function getAgreementStatus() public view returns (AgreementStatus status) {
        if (Countdown.isOver()) {
            return AgreementStatus.isTerminated;
        } else if (Countdown.isActive()) {
            return AgreementStatus.isInCountdown;
        } else {
            return AgreementStatus.isInitialized;
        }
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isInitialized state
    /// @return validity bool true if correct state
    function isInitialized() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isInitialized;
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isInCountdown state
    /// @return validity bool true if correct state
    function isInCountdown() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isInCountdown;
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isTerminated state
    /// @return validity bool true if correct state
    function isTerminated() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isTerminated;
    }
}




/// @title CountdownGriefing_Factory
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @notice This factory is used to deploy instances of the template contract.
///         New instances can be created with the following functions:
///             `function create(bytes calldata initData) external returns (address instance);`
///             `function createSalty(bytes calldata initData, bytes32 salt) external returns (address instance);`
///         The `initData` parameter is ABI encoded calldata to use on the initialize function of the instance after creation.
///         The optional `salt` parameter can be used to deterministically generate the instance address instead of using a nonce.
///         See documentation of the template for additional details on initialization parameters.
///         The template contract address can be optained with the following function:
///             `function getTemplate() external view returns (address template);`
contract CountdownGriefing_Factory is Factory {

    constructor(address instanceRegistry, address templateContract) public {
        CountdownGriefing template;

        // set instance type
        bytes4 instanceType = bytes4(keccak256(bytes('Agreement')));
        // set initSelector
        bytes4 initSelector = template.initialize.selector;
        // initialize factory params
        Factory._initialize(instanceRegistry, templateContract, instanceType, initSelector);
    }

}