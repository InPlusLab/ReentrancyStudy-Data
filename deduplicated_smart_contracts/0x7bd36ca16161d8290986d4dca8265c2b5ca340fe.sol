/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

// File: contracts/ignored_contracts/Ownable.sol

pragma solidity ^0.4.24;

contract Ownable {

  address public owner_;

  event TransferApproved(address indexed _previousOwner, address indexed _newOwner);
  event TransferRequested(address indexed _currentOwner, address indexed _requestedOwner);
  event RequestRevoked(address indexed _currentOwner, address indexed _requestOwner);

  mapping(bytes32 => bool) public requesters_; // keccak256 hashes of requester addresses

  modifier onlyOwner() {
    require(msg.sender == owner_);
    _;
  }

  modifier hasNotRequested() {
    require(!requesters_[keccak256(abi.encodePacked(msg.sender))],
      "Ownership request already active.");
    _;
  }

  modifier hasRequested(address _newOwner) {
    require(requesters_[keccak256(abi.encodePacked(_newOwner))], 
      "Owner request has not been sent.");
    _;
  }

  function requestOwnership() public hasNotRequested {
    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    requesters_[hashedAddress] = true;
    emit TransferRequested(owner_, msg.sender);
  }

  function revokeOwnershipRequest() public hasRequested(msg.sender) {
    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    requesters_[hashedAddress] = false;
    emit RequestRevoked(owner_, msg.sender);
  }

  function approveOwnershipTransfer(address _newOwner) public onlyOwner hasRequested(_newOwner) {
    owner_ = _newOwner;
    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    requesters_[hashedAddress] = false;
  }

}

// File: contracts/SafeMath32.sol

pragma solidity ^0.4.24;

library SafeMath32 {

  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }

    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn¡¯t hold
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/AraProxy.sol

pragma solidity ^0.4.24;

/**
 * @title AraProxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract AraProxy {

  bytes32 private constant registryPosition_ = keccak256("io.ara.proxy.registry");
  bytes32 private constant implementationPosition_ = keccak256("io.ara.proxy.implementation");

  modifier restricted() {
    bytes32 registryPosition = registryPosition_;
    address registryAddress;
    assembly {
      registryAddress := sload(registryPosition)
    }
    require(
      msg.sender == registryAddress,
      "Only the AraRegistry can upgrade this proxy."
    );
    _;
  }

  /**
  * @dev the constructor sets the AraRegistry address
  */
  constructor(address _registryAddress, address _implementationAddress) public {
    bytes32 registryPosition = registryPosition_;
    bytes32 implementationPosition = implementationPosition_;
    assembly {
      sstore(registryPosition, _registryAddress)
      sstore(implementationPosition, _implementationAddress)
    }
  }

  function setImplementation(address _newImplementation) public restricted {
    require(_newImplementation != address(0));
    bytes32 implementationPosition = implementationPosition_;
    assembly {
      sstore(implementationPosition, _newImplementation)
    }
  }

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable public {
    bytes32 implementationPosition = implementationPosition_;
    address _impl;
    assembly {
      _impl := sload(implementationPosition)
    }

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}

// File: contracts/ignored_contracts/Registry.sol

pragma solidity ^0.4.24;


contract Registry {
  address public owner_;
  mapping (bytes32 => address) private proxies_; // contentId (unhashed) => proxy
  mapping (bytes32 => address) private proxyOwners_; // contentId (unhashed) => owner
  mapping (string => address) private versions_; // version => implementation
  mapping (address => string) public proxyImpls_; // proxy => version
  string public latestVersion_;

  event ProxyDeployed(address indexed _owner, bytes32 indexed _contentId, address _address);
  event ProxyUpgraded(bytes32 indexed _contentId, string indexed _version);
  event StandardAdded(string indexed _version, address _address);

  function init(bytes _data) public {
    require(owner_ == address(0), 'Registry has already been initialized.');

    uint256 btsptr;
    address ownerAddr;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
    }
    owner_ = ownerAddr;
  }

  modifier restricted() {
    require (
      msg.sender == owner_,
      "Sender not authorized."
    );
    _;
  }

  modifier onlyProxyOwner(bytes32 _contentId) {
    require(
      proxyOwners_[_contentId] == msg.sender,
      "Sender not authorized."
    );
    _;
  }

  function getProxyAddress(bytes32 _contentId) public view returns (address) {
    return proxies_[_contentId];
  }

  function getProxyOwner(bytes32 _contentId) public view returns (address) {
    return proxyOwners_[_contentId];
  }

  function getImplementation(string _version) public view returns (address) {
    return versions_[_version];
  }

  function getProxyVersion(bytes32 _contentId) public view returns (string) {
    return proxyImpls_[getProxyAddress(_contentId)];
  }
  
  /**
   * @dev AFS Proxy Factory
   * @param _contentId The unhashed methodless content DID
   * @param _version The implementation version to use with this Proxy
   * @param _data AFS initialization data
   * @return address of the newly deployed Proxy
   */
  function createAFS(bytes32 _contentId, string _version, bytes _data) public {
    require(proxies_[_contentId] == address(0), "Proxy already exists for this content.");
    require(versions_[_version] != address(0), "Version does not exist.");
    AraProxy proxy = new AraProxy(address(this), versions_[_version]);
    proxies_[_contentId] = proxy;
    proxyOwners_[_contentId] = msg.sender;
    upgradeProxyAndCall(_contentId, _version, _data);
    emit ProxyDeployed(msg.sender, _contentId, address(proxy));
  }

  /**
   * @dev Upgrades proxy implementation version
   * @param _contentId The unhashed methodless content DID
   * @param _version The implementation version to upgrade this Proxy to
   */
  function upgradeProxy(bytes32 _contentId, string _version) public onlyProxyOwner(_contentId) {
    require(versions_[_version] != address(0), "Version does not exist.");
    AraProxy proxy = AraProxy(proxies_[_contentId]);
    proxy.setImplementation(versions_[_version]);
    proxyImpls_[proxies_[_contentId]] = _version;
    emit ProxyUpgraded(_contentId, _version);
  }

  /**
   * @dev Upgrades proxy implementation version with initialization
   * @param _contentId The unhashed methodless content DID
   * @param _version The implementation version to upgrade this Proxy to
   * @param _data AFS initialization data
   */
  function upgradeProxyAndCall(bytes32 _contentId, string _version, bytes _data) public onlyProxyOwner(_contentId) {
    require(versions_[_version] != address(0), "Version does not exist.");
    require(keccak256(abi.encodePacked(proxyImpls_[proxy])) != keccak256(abi.encodePacked(_version)), "Proxy is already on this version.");
    AraProxy proxy = AraProxy(proxies_[_contentId]);
    proxy.setImplementation(versions_[_version]);
    proxyImpls_[proxy] = _version;
    require(address(proxy).call(abi.encodeWithSignature("init(bytes)", _data)), "Init failed.");
    emit ProxyUpgraded(_contentId, _version);
  }

  /**
   * @dev Adds a new AFS implementation standard
   * @param _version The implementation version name
   * @param _address The address of the new AFS implementation
   */
  function addStandardVersion(string _version, address _address) public restricted {
    require(versions_[_version] == address(0), "Version already exists.");
    versions_[_version] = _address;
    latestVersion_ = _version;
    emit StandardAdded(_version, _address);
  }
}

// File: contracts/ignored_contracts/Library.sol

pragma solidity ^0.4.24;



contract Library {
  using SafeMath32 for uint32;

  address public owner_;
  mapping (bytes32 => Lib) private libraries_; // hashed methodless owner did => library
  Registry registry_;

  struct Lib {
    uint32 size;
    mapping (uint32 => bytes32) content; // index => contentId (unhashed)
  }

  event AddedToLib(bytes32 indexed _identity, bytes32 indexed _contentId);

  function init(bytes _data) public {
    require(owner_ == address(0), 'Library has already been initialized.');

    uint256 btsptr;
    address ownerAddr;
    address registryAddr;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
      btsptr := add(_data, 64)
      registryAddr := mload(btsptr)
    }
    owner_ = ownerAddr;
    registry_ = Registry(registryAddr);
  }

  modifier restricted() {
    require (msg.sender == owner_, "Sender not authorized.");
     _;
  }

  modifier fromProxy(bytes32 _contentId) {
    require (msg.sender == registry_.getProxyAddress(_contentId), "Proxy not authorized.");
     _;
  }

  function getLibrarySize(bytes32 _identity) public view returns (uint32 size) {
    return libraries_[_identity].size;
  }

  function getLibraryItem(bytes32 _identity, uint32 _index) public view returns (bytes32 contentId) {
    require (_index < libraries_[_identity].size, "Index does not exist.");
    return libraries_[_identity].content[_index];
  }

  function addLibraryItem(bytes32 _identity, bytes32 _contentId) public fromProxy(_contentId) {
    uint32 libSize = libraries_[_identity].size;
    assert (libraries_[_identity].content[libSize] == bytes32(0));
    libraries_[_identity].content[libSize] = _contentId;
    libraries_[_identity].size++;
    emit AddedToLib(_identity, _contentId);
  }
}

// File: contracts/ignored_contracts/ERC20.sol

pragma solidity ^0.4.24;

/**
 * NOTE: This contract will be removed once openzeppelin-solidity releases this code as an official release.
 */

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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

// File: contracts/ignored_contracts/StandardToken.sol

pragma solidity ^0.4.24;

/**
 * NOTE: This contract will be removed once openzeppelin-solidity releases this code as an official release.
 * -Charles 
 */



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private balances_;

  mapping (address => mapping (address => uint256)) private allowed_;

  uint256 private totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances_[_owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed_[_owner][_spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances_[msg.sender]);
    require(_to != address(0));

    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed_[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances_[_from]);
    require(_value <= allowed_[_from][msg.sender]);
    require(_to != address(0));

    balances_[_from] = balances_[_from].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed_[msg.sender][_spender] = (
      allowed_[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed_[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed_[msg.sender][_spender] = 0;
    } else {
      allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _account The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
  function _mint(address _account, uint256 _amount) internal {
    require(_account != 0);
    totalSupply_ = totalSupply_.add(_amount);
    balances_[_account] = balances_[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burn(address _account, uint256 _amount) internal {
    require(_account != 0);
    require(_amount <= balances_[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances_[_account] = balances_[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal _burn function.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burnFrom(address _account, uint256 _amount) internal {
    require(_amount <= allowed_[_account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed_[_account][msg.sender] = allowed_[_account][msg.sender].sub(
      _amount);
    _burn(_account, _amount);
  }
}

// File: contracts/ignored_contracts/AraToken.sol

pragma solidity ^0.4.24;


contract AraToken is StandardToken {

  // metadata
  bool    private initialized;
  string  public constant name = "Ara Token";
  string  public constant symbol = "ARA";
  uint256 public constant decimals = 18;
  string  public version = "1.0";


  mapping (address => uint256) private deposits_;

  event Deposit(address indexed from, uint256 value, uint256 total);
  event Withdraw(address indexed to, uint256 value, uint256 total);

  function init(bytes _data) public {
    require(!initialized, 'Ara Token has already been initialized.');
    initialized = true;
    
    uint256 btsptr;
    address ownerAddr;
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
    }
    _mint(ownerAddr, formatDecimals(1000000000)); // 1,000,000,000
  }

  function formatDecimals(uint256 _value) internal pure returns (uint256) {
    return _value * 10 ** decimals;
  }

  function amountDeposited(address _owner) public view returns (uint256) {
    return deposits_[_owner];
  }

  function deposit(uint256 _value) external returns (bool) {
    require(_value <= balanceOf(msg.sender));

    deposits_[msg.sender] = deposits_[msg.sender].add(_value);
    emit Deposit(msg.sender, _value, deposits_[msg.sender]);
    return true;
  }

  function withdraw(uint256 _value) external returns (bool) {
    require(_value <= deposits_[msg.sender]);

    deposits_[msg.sender] = deposits_[msg.sender].sub(_value);
    emit Withdraw(msg.sender, _value, deposits_[msg.sender]);
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(balanceOf(msg.sender) - _value >= deposits_[msg.sender]);
    return super.transfer(_to, _value);
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require(balanceOf(msg.sender) - _value >= deposits_[msg.sender]);
    return super.approve(_spender, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(balanceOf(_from) - _value >= deposits_[_from]);
    return super.transferFrom(_from, _to, _value);
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    require(balanceOf(msg.sender) - (_addedValue + allowance(msg.sender, _spender)) >= deposits_[msg.sender]);
    return super.increaseApproval(_spender, _addedValue);
  }
}

// File: installed_contracts/bytes/contracts/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Nick Johnson <arachnid@notdot.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */

pragma solidity ^0.4.19;


library BytesLib {
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes) {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add 
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes_slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes_slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(bytes _bytes, uint _start, uint _length) internal  pure returns (bytes) {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint(bytes _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes _bytes, uint _start) internal  pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes_slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

// File: contracts/ignored_contracts/AFS.sol

pragma solidity ^0.4.24;







contract AFS is Ownable {
  using SafeMath for uint256;
  using BytesLib for bytes;

  string   public version_ = "2";

  AraToken public token_;
  Library  public lib_;

  bytes32  public did_;
  bool     public listed_;
  uint256  public price_;

  uint256  public depositRequirement_;

  mapping(bytes32 => Job)     public jobs_; // jobId => job { budget, sender }
  mapping(bytes32 => uint256) public rewards_;    // farmer => rewards
  mapping(bytes32 => bool)    public purchasers_; // keccak256 hashes of buyer addresses
  mapping(uint8 => mapping (uint256 => bytes))   public metadata_;

  struct Job {
    address sender;
    uint256 budget;
  }

  event Commit(bytes32 _did);
  event Unlisted(bytes32 _did);
  event PriceSet(uint256 _price);
  event BudgetSubmitted(address indexed _sender, bytes32 indexed _jobId, uint256 _budget);
  event RewardsAllocated(address indexed _farmer, bytes32 indexed _jobId, uint256 _allocated, uint256 _remaining);
  event InsufficientDeposit(address indexed _farmer);
  event Purchased(bytes32 indexed _purchaser, uint256 _price);
  event Redeemed(address indexed _sender, uint256 _amount);

  uint8 constant mtBufferSize_ = 40;
  uint8 constant msBufferSize_ = 64;

  modifier onlyBy(address _account)
  {
    require(
      msg.sender == _account,
      "Sender not authorized."
    );
    _;
  }

  modifier purchaseRequired()
  {
    require(
      purchasers_[keccak256(abi.encodePacked(msg.sender))],
      "Content was never purchased."
    );
    _;
  }

  modifier budgetSubmitted(bytes32 _jobId)
  {
    require(
      jobs_[_jobId].sender == msg.sender && jobs_[_jobId].budget > 0,
      "Job is invalid."
    );
    _;
  }

  function init(bytes _data) public {
    require(owner_ == address(0), 'This AFS standard has already been initialized.');
  
    uint256 btsptr;
    address ownerAddr;
    address tokenAddr;
    address libAddr;
    bytes32 did;
    /* solium-disable-next-line security/no-inline-assembly */
    assembly {
      btsptr := add(_data, 32)
      ownerAddr := mload(btsptr)
      btsptr := add(_data, 64)
      tokenAddr := mload(btsptr)
      btsptr := add(_data, 96)
      libAddr := mload(btsptr)
      btsptr := add(_data, 128)
      did := mload(btsptr)
    }
    owner_    = ownerAddr;
    token_    = AraToken(tokenAddr);
    lib_      = Library(libAddr);
    did_      = did;
    listed_   = true;
    price_    = 0;
    depositRequirement_  = 100 * 10 ** token_.decimals();
  }

  function setPrice(uint256 _price) external onlyBy(owner_) {
    price_ = _price;
    emit PriceSet(price_);
  }

  function submitBudget(bytes32 _jobId, uint256 _budget) public purchaseRequired {
    uint256 allowance = token_.allowance(msg.sender, address(this));
    require(_jobId != bytes32(0) && _budget > 0 && allowance >= _budget
      && (jobs_[_jobId].sender == address(0) || jobs_[_jobId].sender == msg.sender), "Job submission invalid.");

    if (token_.transferFrom(msg.sender, address(this), _budget)) {
      jobs_[_jobId].budget = jobs_[_jobId].budget.add(_budget);
      jobs_[_jobId].sender = msg.sender;
      assert(jobs_[_jobId].budget <= token_.balanceOf(address(this)));
      emit BudgetSubmitted(msg.sender, _jobId, _budget);
    }
  }

  function allocateRewards(bytes32 _jobId, address[] _farmers, uint256[] _rewards) public budgetSubmitted(_jobId) {
    require(_farmers.length > 0, "Must allocate to at least one farmer.");
    require(_farmers.length == _rewards.length, "Unequal number of farmers and rewards.");
    uint256 totalRewards = 0;
    for (uint256 i = 0; i < _rewards.length; i++) {
      address farmer = _farmers[i];
      require(farmer != msg.sender, "Cannot allocate rewards to job creator.");
      require(farmer == owner_ || purchasers_[keccak256(abi.encodePacked(farmer))] || token_.amountDeposited(farmer) >= depositRequirement_, "Farmer must be a purchaser of this AFS or have sufficient token deposit.");
      totalRewards = totalRewards.add(_rewards[i]);
    }
    require(totalRewards <= jobs_[_jobId].budget, "Insufficient budget.");
    for (uint256 j = 0; j < _farmers.length; j++) {
      assert(jobs_[_jobId].budget >= _rewards[j]);
      bytes32 hashedFarmer = keccak256(abi.encodePacked(_farmers[j]));
      rewards_[hashedFarmer] = rewards_[hashedFarmer].add(_rewards[j]);
      jobs_[_jobId].budget = jobs_[_jobId].budget.sub(_rewards[j]);
      emit RewardsAllocated(_farmers[j], _jobId, _rewards[j], jobs_[_jobId].budget);
    }
  }

  function redeemBalance() public {
    if (msg.sender == owner_ || token_.amountDeposited(msg.sender) >= depositRequirement_ || purchasers_[keccak256(abi.encodePacked(msg.sender))]) {
      bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
      require(rewards_[hashedAddress] > 0, "No balance to redeem.");
      if (token_.transfer(msg.sender, rewards_[hashedAddress])) {
        emit Redeemed(msg.sender, rewards_[hashedAddress]);
        rewards_[hashedAddress] = 0;
      }
    } else {
      emit InsufficientDeposit(msg.sender);
    }
  }

  function getRewardsBalance(address _farmer) public view returns (uint256) {
    return rewards_[keccak256(abi.encodePacked(_farmer))];
  }

  function getBudget(bytes32 _jobId) public view returns (uint256) {
    return jobs_[_jobId].budget;
  }

  /**
   * @dev Purchases this AFS and adds it to _purchaser's library. 
   *      If _download is true, deposits any remaining allowance 
   *      as rewards for this purchase
   * @param _purchaser The hashed methodless did of the purchaser
   * @param _jobId The jobId of the download, or 0x00000000000000000000000000000000 if N/A
   * @param _budget The reward budget for jobId, or 0 if N/A
   */
  function purchase(bytes32 _purchaser, bytes32 _jobId, uint256 _budget) external {
    require(listed_, "Content is not listed for purchase.");
    uint256 allowance = token_.allowance(msg.sender, address(this));
    bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
    require (!purchasers_[hashedAddress] && allowance >= price_.add(_budget), "Unable to purchase.");

    if (token_.transferFrom(msg.sender, owner_, price_)) {
      purchasers_[hashedAddress] = true;
      lib_.addLibraryItem(_purchaser, did_);
      emit Purchased(_purchaser, price_);

      if (_jobId != bytes32(0) && _budget > 0) {
        submitBudget(_jobId, _budget);
      }
    }
  }

  function append(uint256[] _mtOffsets, uint256[] _msOffsets, bytes _mtBuffer, 
    bytes _msBuffer) external onlyBy(owner_) {
    
    require(listed_, "AFS is unlisted.");
    
    uint256 maxOffsetLength = _mtOffsets.length > _msOffsets.length 
      ? _mtOffsets.length 
      : _msOffsets.length;

    for (uint i = 0; i < maxOffsetLength; i++) {
      // metadata/tree
      if (i <= _mtOffsets.length - 1) {
        metadata_[0][_mtOffsets[i]] = _mtBuffer.slice(i * mtBufferSize_, mtBufferSize_);
      }

      // metadata/signatures
      if (i <= _msOffsets.length - 1) {
        metadata_[1][_msOffsets[i]] = _msBuffer.slice(i * msBufferSize_, msBufferSize_);
      }
    }

    emit Commit(did_);
  }

  function write(uint256[] _mtOffsets, uint256[] _msOffsets, bytes _mtBuffer, 
    bytes _msBuffer) public onlyBy(owner_) {

    require(listed_, "AFS is unlisted.");

    uint256 maxOffsetLength = _mtOffsets.length > _msOffsets.length 
      ? _mtOffsets.length 
      : _msOffsets.length;

    // add headers
    metadata_[0][0] = _mtBuffer.slice(0, 32);
    metadata_[1][0] = _msBuffer.slice(0, 32);

    for (uint i = 1; i < maxOffsetLength; i++) {
      // metadata/tree
      if (i <= _mtOffsets.length - 1) {
        metadata_[0][_mtOffsets[i]] = _mtBuffer.slice(_mtOffsets[i], mtBufferSize_);
      }
      
      // metadata/signatures
      if (i <= _msOffsets.length - 1) {
        metadata_[1][_msOffsets[i]] = _msBuffer.slice(_msOffsets[i], msBufferSize_);
      }
    }

    emit Commit(did_);
  }

  function read(uint8 _file, uint256 _offset) public view returns (bytes buffer) {
    if (!listed_) {
      return ""; // empty bytes
    }
    return metadata_[_file][_offset];
  }

  function hasBuffer(uint8 _file, uint256 _offset, bytes _buffer) public view returns (bool exists) {
    return metadata_[_file][_offset].equal(_buffer);
  }

  function unlist() public onlyBy(owner_) returns (bool success) {
    listed_ = false;
    emit Unlisted(did_);
    return true;
  }
}