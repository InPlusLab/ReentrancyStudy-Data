/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// File: contracts/upgradeability/EternalStorage.sol

pragma solidity 0.4.24;

/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;


    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    //mapping(bytes32 => bytes[]) internal bytesArrayStorage;
    mapping(bytes32 => bool[]) internal boolArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;
    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
}

// File: contracts/upgradeable_contracts/EternalOwnable.sol

pragma solidity 0.4.24;


/**
 * @title EternalOwnable
 * @dev This contract has an owner address providing basic authorization control
 */
contract EternalOwnable is EternalStorage {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event EternalOwnershipTransferred(address previousOwner, address newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function setOwner(address newOwner) internal {
        emit EternalOwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}

// File: contracts/interfaces/IBridgeValidators.sol

pragma solidity 0.4.24;

interface IBridgeValidators {
    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner) external returns(bool);
    function isValidator(address _validator) external view returns(bool);
    function requiredSignatures() external view returns(uint256);
    function owner() external view returns(address);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;

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

// File: contracts/upgradeable_contracts/BridgeValidators.sol

pragma solidity 0.4.24;






contract BridgeValidators is IBridgeValidators, EternalStorage, EternalOwnable {
    using SafeMath for uint256;

    event ValidatorAdded (address indexed validator);
    event ValidatorRemoved (address indexed validator);
    event RequiredSignaturesChanged (uint256 requiredSignatures);

    bytes32 internal constant REQUIRED_SIGNATURES = keccak256(abi.encodePacked("requiredSignatures"));
    
    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner)
      external returns(bool)
    {
        require(!isInitialized());
        require(_owner != address(0));
        setOwner(_owner);
        require(_requiredSignatures != 0);
        require(_initialValidators.length >= _requiredSignatures);
        for (uint256 i = 0; i < _initialValidators.length; i++) {
            require(_initialValidators[i] != address(0));
            assert(validators(_initialValidators[i]) != true);
            setValidatorCount(validatorCount().add(1));
            setValidator(_initialValidators[i], true);
            emit ValidatorAdded(_initialValidators[i]);
        }
        uintStorage[REQUIRED_SIGNATURES] = _requiredSignatures;
        uintStorage[keccak256("deployedAtBlock")] = block.number;
        setInitialize(true);
        emit RequiredSignaturesChanged(_requiredSignatures);
        return isInitialized();
    }

    function addValidator(address _validator) external onlyOwner {
        require(_validator != address(0));
        require(!isValidator(_validator));
        setValidatorCount(validatorCount().add(1));
        setValidator(_validator, true);
        emit ValidatorAdded(_validator);
    }

    function removeValidator(address _validator) external onlyOwner {
        require(validatorCount() > requiredSignatures());
        require(isValidator(_validator));
        setValidator(_validator, false);
        setValidatorCount(validatorCount().sub(1));
        emit ValidatorRemoved(_validator);
    }

    function setRequiredSignatures(uint256 _requiredSignatures) external onlyOwner {
        require(validatorCount() >= _requiredSignatures);
        require(_requiredSignatures != 0);
        uintStorage[REQUIRED_SIGNATURES] = _requiredSignatures;
        emit RequiredSignaturesChanged(_requiredSignatures);
    }

    function getBridgeValidatorsInterfacesVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {
        return (2, 0, 0);
    }

    function requiredSignatures() public view returns(uint256) {
        return uintStorage[REQUIRED_SIGNATURES];
    }

    function validatorCount() public view returns(uint256) {
        return uintStorage[keccak256(abi.encodePacked("validatorCount"))];
    }

    function validators(address _validator) public view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked("validators", _validator))];
    }

    function isValidator(address _validator) public view returns(bool) {
        return validators(_validator) == true;
    }

    function isInitialized() public view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked("isInitialized"))];
    }

    function deployedAtBlock() public view returns(uint256) {
        return uintStorage[keccak256("deployedAtBlock")];
    }

    function setValidatorCount(uint256 _validatorCount) private {
        uintStorage[keccak256(abi.encodePacked("validatorCount"))] = _validatorCount;
    }

    function setValidator(address _validator, bool _status) private {
        boolStorage[keccak256(abi.encodePacked("validators", _validator))] = _status;
    }

    function setInitialize(bool _status) private {
        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;
    }
}