/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

/**************************************************************************
 *            ____        _                              
 *           / ___|      | |     __ _  _   _   ___  _ __ 
 *          | |    _____ | |    / _` || | | | / _ \| '__|
 *          | |___|_____|| |___| (_| || |_| ||  __/| |   
 *           \____|      |_____|\__,_| \__, | \___||_|   
 *                                     |___/             
 * 
 **************************************************************************
 *
 *  The MIT License (MIT)
 * SPDX-License-Identifier: MIT
 *
 * Copyright (c) 2016-2020 Cyril Lapinte
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 **************************************************************************
 *
 * Flatten Contract: UserRegistry
 *
 * Git Commit:
 * https://github.com/c-layer/contracts/commit/9993912325afde36151b04d0247ac9ea9ffa2a93
 *
 **************************************************************************/


// File: @c-layer/common/contracts/operable/Ownable.sol

pragma solidity ^0.6.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * @dev functions, this simplifies the implementation of "user permissions".
 *
 *
 * Error messages
 *   OW01: Message sender is not the owner
 *   OW02: New owner must be valid
*/
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "OW01");
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), "OW02");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: @c-layer/common/contracts/operable/Operable.sol

pragma solidity ^0.6.0;



/**
 * @title Operable
 * @dev The Operable contract enable the restrictions of operations to a set of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 * OP01: Message sender must be an operator
 * OP02: Address must be an operator
 * OP03: Address must not be an operator
 */
contract Operable is Ownable {

  mapping (address => bool) private operators_;

  /**
   * @dev Throws if called by any account other than the operator
   */
  modifier onlyOperator {
    require(operators_[msg.sender], "OP01");
    _;
  }

  /**
   * @dev constructor
   */
  constructor() public {
    defineOperator("Owner", msg.sender);
  }

  /**
   * @dev isOperator
   * @param _address operator address
   */
  function isOperator(address _address) public view returns (bool) {
    return operators_[_address];
  }

  /**
   * @dev removeOperator
   * @param _address operator address
   */
  function removeOperator(address _address) public onlyOwner {
    require(operators_[_address], "OP02");
    operators_[_address] = false;
    emit OperatorRemoved(_address);
  }

  /**
   * @dev defineOperator
   * @param _role operator role
   * @param _address operator address
   */
  function defineOperator(string memory _role, address _address)
    public onlyOwner
  {
    require(!operators_[_address], "OP03");
    operators_[_address] = true;
    emit OperatorDefined(_role, _address);
  }

  event OperatorRemoved(address address_);
  event OperatorDefined(
    string role,
    address address_
  );
}

// File: contracts/interface/IUserRegistry.sol

pragma solidity ^0.6.0;


/**
 * @title IUserRegistry
 * @dev IUserRegistry interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 **/
abstract contract IUserRegistry {

  enum KeyCode {
    KYC_LIMIT_KEY,
    RECEPTION_LIMIT_KEY,
    EMISSION_LIMIT_KEY
  }

  event UserRegistered(uint256 indexed userId, address address_, uint256 validUntilTime);
  event AddressAttached(uint256 indexed userId, address address_);
  event AddressDetached(uint256 indexed userId, address address_);
  event UserSuspended(uint256 indexed userId);
  event UserRestored(uint256 indexed userId);
  event UserValidity(uint256 indexed userId, uint256 validUntilTime);
  event UserExtendedKey(uint256 indexed userId, uint256 key, uint256 value);
  event UserExtendedKeys(uint256 indexed userId, uint256[] values);
  event ExtendedKeysDefinition(uint256[] keys);

  function registerManyUsersExternal(address[] calldata _addresses, uint256 _validUntilTime)
    virtual external returns (bool);
  function registerManyUsersFullExternal(
    address[] calldata _addresses,
    uint256 _validUntilTime,
    uint256[] calldata _values) virtual external returns (bool);
  function attachManyAddressesExternal(uint256[] calldata _userIds, address[] calldata _addresses)
    virtual external returns (bool);
  function detachManyAddressesExternal(address[] calldata _addresses)
    virtual external returns (bool);
  function suspendManyUsersExternal(uint256[] calldata _userIds) virtual external returns (bool);
  function restoreManyUsersExternal(uint256[] calldata _userIds) virtual external returns (bool);
  function updateManyUsersExternal(
    uint256[] calldata _userIds,
    uint256 _validUntilTime,
    bool _suspended) virtual external returns (bool);
  function updateManyUsersExtendedExternal(
    uint256[] calldata _userIds,
    uint256 _key, uint256 _value) virtual external returns (bool);
  function updateManyUsersAllExtendedExternal(
    uint256[] calldata _userIds,
    uint256[] calldata _values) virtual external returns (bool);
  function updateManyUsersFullExternal(
    uint256[] calldata _userIds,
    uint256 _validUntilTime,
    bool _suspended,
    uint256[] calldata _values) virtual external returns (bool);

  function name() virtual public view returns (string memory);
  function currency() virtual public view returns (bytes32);

  function userCount() virtual public view returns (uint256);
  function userId(address _address) virtual public view returns (uint256);
  function validUserId(address _address) virtual public view returns (uint256);
  function validUser(address _address, uint256[] memory _keys)
    virtual public view returns (uint256, uint256[] memory);
  function validity(uint256 _userId) virtual public view returns (uint256, bool);

  function extendedKeys() virtual public view returns (uint256[] memory);
  function extended(uint256 _userId, uint256 _key)
    virtual public view returns (uint256);
  function manyExtended(uint256 _userId, uint256[] memory _key)
    virtual public view returns (uint256[] memory);

  function isAddressValid(address _address) virtual public view returns (bool);
  function isValid(uint256 _userId) virtual public view returns (bool);

  function defineExtendedKeys(uint256[] memory _extendedKeys) virtual public returns (bool);

  function registerUser(address _address, uint256 _validUntilTime)
    virtual public returns (bool);
  function registerUserFull(
    address _address,
    uint256 _validUntilTime,
    uint256[] memory _values) virtual public returns (bool);

  function attachAddress(uint256 _userId, address _address) virtual public returns (bool);
  function detachAddress(address _address) virtual public returns (bool);
  function detachSelf() virtual public returns (bool);
  function detachSelfAddress(address _address) virtual public returns (bool);
  function suspendUser(uint256 _userId) virtual public returns (bool);
  function restoreUser(uint256 _userId) virtual public returns (bool);
  function updateUser(uint256 _userId, uint256 _validUntilTime, bool _suspended)
    virtual public returns (bool);
  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    virtual public returns (bool);
  function updateUserAllExtended(uint256 _userId, uint256[] memory _values)
    virtual public returns (bool);
  function updateUserFull(
    uint256 _userId,
    uint256 _validUntilTime,
    bool _suspended,
    uint256[] memory _values) virtual public returns (bool);
}

// File: contracts/UserRegistry.sol

pragma solidity ^0.6.0;




/**
 * @title UserRegistry
 * @dev UserRegistry contract
 * Configure and manage users
 * Extended may be used externaly to store data within a user context
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 * UR01: UserId is invalid
 * UR02: WalletOwner is already known
 * UR03: Users length does not match with addresses
 * UR04: WalletOwner is unknown
 * UR05: Sender is not the wallet owner
 * UR06: User is already suspended
 * UR07: User is not suspended
 * UR08: Extended keys must exists for values
*/
contract UserRegistry is IUserRegistry, Operable {

  struct User {
    uint256 validUntilTime;
    bool suspended;
    mapping(uint256 => uint256) extended;
  }

  uint256[] internal extendedKeys_ = [ 0, 1, 2 ];
  mapping(uint256 => User) internal users;
  mapping(address => uint256) internal walletOwners;
  uint256 internal userCount_;

  string internal name_;
  bytes32 internal currency_;

  /**
   * @dev contructor
   **/
  constructor(
    string memory _name,
    bytes32 _currency,
    address[] memory _addresses,
    uint256 _validUntilTime) public
  {
    name_ = _name;
    currency_ = _currency;
    for (uint256 i = 0; i < _addresses.length; i++) {
      registerUserPrivate(_addresses[i], _validUntilTime);
    }
  }

  /**
   * @dev register many users
   */
  function registerManyUsersExternal(address[] calldata _addresses, uint256 _validUntilTime)
    override external onlyOperator returns (bool)
  {
    for (uint256 i = 0; i < _addresses.length; i++) {
      registerUserPrivate(_addresses[i], _validUntilTime);
    }
    return true;
  }

  /**
   * @dev register many users
   */
  function registerManyUsersFullExternal(
    address[] calldata _addresses,
    uint256 _validUntilTime,
    uint256[] calldata _values) override external onlyOperator returns (bool)
  {
    require(_values.length <= extendedKeys_.length, "UR08");
    for (uint256 i = 0; i < _addresses.length; i++) {
      registerUserPrivate(_addresses[i], _validUntilTime);
      updateUserExtendedPrivate(userCount_, _values);
    }
    return true;
  }

  /**
   * @dev attach many addresses to many users
   */
  function attachManyAddressesExternal(
    uint256[] calldata _userIds,
    address[] calldata _addresses)
    override external onlyOperator returns (bool)
  {
    require(_addresses.length == _userIds.length, "UR03");
    for (uint256 i = 0; i < _addresses.length; i++) {
      attachAddress(_userIds[i], _addresses[i]);
    }
    return true;
  }

  /**
   * @dev detach many addresses association between addresses and their respective users
   */
  function detachManyAddressesExternal(address[] calldata _addresses)
    override external onlyOperator returns (bool)
  {
    for (uint256 i = 0; i < _addresses.length; i++) {
      detachAddressPrivate(_addresses[i]);
    }
    return true;
  }

  /**
   * @dev suspend many users
   */
  function suspendManyUsersExternal(uint256[] calldata _userIds)
    override external onlyOperator returns (bool)
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      suspendUser(_userIds[i]);
    }
    return true;
  }

  /**
   * @dev restore many users
   */
  function restoreManyUsersExternal(uint256[] calldata _userIds)
    override external onlyOperator returns (bool)
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      restoreUser(_userIds[i]);
    }
    return true;
  }

  /**
   * @dev update many users
   */
  function updateManyUsersExternal(
    uint256[] calldata _userIds,
    uint256 _validUntilTime,
    bool _suspended) override external onlyOperator returns (bool)
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUser(_userIds[i], _validUntilTime, _suspended);
    }
    return true;
  }

  /**
   * @dev update many user extended informations
   */
  function updateManyUsersExtendedExternal(
    uint256[] calldata _userIds,
    uint256 _key, uint256 _value) override external onlyOperator returns (bool)
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUserExtended(_userIds[i], _key, _value);
    }
    return true;
  }

  /**
   * @dev update many user all extended informations
   */
  function updateManyUsersAllExtendedExternal(
    uint256[] calldata _userIds,
    uint256[] calldata _values) override external onlyOperator returns (bool)
  {
    require(_values.length <= extendedKeys_.length, "UR08");
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUserExtendedPrivate(_userIds[i], _values);
    }
    return true;
  }

  /**
   * @dev update many users full
   */
  function updateManyUsersFullExternal(
    uint256[] calldata _userIds,
    uint256 _validUntilTime,
    bool _suspended,
    uint256[] calldata _values) override external onlyOperator returns (bool)
  {
    require(_values.length <= extendedKeys_.length, "UR08");
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUser(_userIds[i], _validUntilTime, _suspended);
      updateUserExtendedPrivate(_userIds[i], _values);
    }
    return true;
  }

  /**
   * @dev user registry name
   */
  function name() override public view returns (string memory) {
    return name_;
  }

  /**
   * @dev user registry currency
   */
  function currency() override public view returns (bytes32) {
    return currency_;
  }

  /**
   * @dev number of user registered
   */
  function userCount() override public view returns (uint256) {
    return userCount_;
  }

  /**
   * @dev the userId associated to the provided address
   */
  function userId(address _address) override public view returns (uint256) {
    return walletOwners[_address];
  }

  /**
   * @dev the userId associated to the provided address if the user is valid
   */
  function validUserId(address _address) override public view returns (uint256) {
    uint256 addressUserId = walletOwners[_address];
    if (isValidPrivate(users[addressUserId])) {
      return addressUserId;
    }
    return 0;
  }

  /**
   * @dev the user associated to the provided address if the user is valid
   */
  function validUser(address _address, uint256[] memory _keys)
    override public view returns (uint256, uint256[] memory)
  {
    uint256 addressUserId = walletOwners[_address];
    if (isValidPrivate(users[addressUserId])) {
      uint256[] memory values = new uint256[](_keys.length);
      for (uint256 i=0; i < _keys.length; i++) {
        values[i] = users[addressUserId].extended[_keys[i]];
      }
      return (addressUserId, values);
    }
    return (0, new uint256[](0));
  }

  /**
   * @dev returns the time at which user validity ends
   */
  function validity(uint256 _userId)
    override public view returns (uint256, bool) {
    User memory user = users[_userId];
    return (user.validUntilTime, user.suspended);
  }

  /**
   * @dev extended keys
   */
  function extendedKeys() override public view returns (uint256[] memory) {
    return extendedKeys_;
  }

  /**
   * @dev access to extended user data
   */
  function extended(uint256 _userId, uint256 _key)
    override public view returns (uint256)
  {
    return users[_userId].extended[_key];
  }

  /**
   * @dev access to extended user data
   */
  function manyExtended(uint256 _userId, uint256[] memory _keys)
    override public view returns (uint256[] memory values)
  {
    values = new uint256[](_keys.length);
    for (uint256 i=0; i < _keys.length; i++) {
      values[i] = users[_userId].extended[_keys[i]];
    }
  }

  /**
   * @dev validity of the current user
   */
  function isAddressValid(address _address) override public view returns (bool) {
    return isValidPrivate(users[walletOwners[_address]]);
  }

  /**
   * @dev validity of the current user
   */
  function isValid(uint256 _userId) override public view returns (bool) {
    return isValidPrivate(users[_userId]);
  }

  /**
   * @dev define extended keys
   */
  function defineExtendedKeys(uint256[] memory _extendedKeys)
    override public onlyOperator returns (bool)
  {
    extendedKeys_ = _extendedKeys;
    emit ExtendedKeysDefinition(_extendedKeys);
    return true;
  }

  /**
   * @dev register a user
   */
  function registerUser(address _address, uint256 _validUntilTime)
    override public onlyOperator returns (bool)
  {
    registerUserPrivate(_address, _validUntilTime);
    return true;
  }

  /**
   * @dev register a user full
   */
  function registerUserFull(
    address _address,
    uint256 _validUntilTime,
    uint256[] memory _values) override public onlyOperator returns (bool)
  {
    require(_values.length <= extendedKeys_.length, "UR08");
    registerUserPrivate(_address, _validUntilTime);
    updateUserExtendedPrivate(userCount_, _values);
    return true;
  }

  /**
   * @dev attach an address with a user
   */
  function attachAddress(uint256 _userId, address _address)
    override public onlyOperator returns (bool)
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    require(walletOwners[_address] == 0, "UR02");
    walletOwners[_address] = _userId;

    emit AddressAttached(_userId, _address);
    return true;
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachAddress(address _address)
    override public onlyOperator returns (bool)
  {
    detachAddressPrivate(_address);
    return true;
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachSelf() override public returns (bool) {
    detachAddressPrivate(msg.sender);
    return true;
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachSelfAddress(address _address)
    override public returns (bool)
  {
    require(
      walletOwners[_address] == walletOwners[msg.sender],
      "UR05");
    detachAddressPrivate(_address);
    return true;
  }

  /**
   * @dev suspend a user
   */
  function suspendUser(uint256 _userId)
    override public onlyOperator returns (bool)
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    require(!users[_userId].suspended, "UR06");
    users[_userId].suspended = true;
    emit UserSuspended(_userId);
    return true;
  }

  /**
   * @dev restore a user
   */
  function restoreUser(uint256 _userId)
    override public onlyOperator returns (bool)
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    require(users[_userId].suspended, "UR07");
    users[_userId].suspended = false;
    emit UserRestored(_userId);
    return true;
  }

  /**
   * @dev update a user
   */
  function updateUser(
    uint256 _userId,
    uint256 _validUntilTime,
    bool _suspended) override public onlyOperator returns (bool)
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    if (users[_userId].validUntilTime != _validUntilTime) {
      users[_userId].validUntilTime = _validUntilTime;
      emit UserValidity(_userId, _validUntilTime);
    }

    if (users[_userId].suspended != _suspended) {
      users[_userId].suspended = _suspended;
      if (_suspended) {
        emit UserSuspended(_userId);
      } else {
        emit UserRestored(_userId);
      }
    }
    return true;
  }

  /**
   * @dev update user extended information
   */
  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    override public onlyOperator returns (bool)
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    users[_userId].extended[_key] = _value;
    emit UserExtendedKey(_userId, _key, _value);
    return true;
  }

  /**
   * @dev update user all extended information
   */
  function updateUserAllExtended(
    uint256 _userId,
    uint256[] memory _values) override public onlyOperator returns (bool)
  {
    require(_values.length <= extendedKeys_.length, "UR08");
    updateUserExtendedPrivate(_userId, _values);
    return true;
  }

  /**
   * @dev update a user full
   */
  function updateUserFull(
    uint256 _userId,
    uint256 _validUntilTime,
    bool _suspended,
    uint256[] memory _values) override public onlyOperator returns (bool)
  {
    require(_values.length <= extendedKeys_.length, "UR08");
    updateUser(_userId, _validUntilTime, _suspended);
    updateUserExtendedPrivate(_userId, _values);
    return true;
  }

  /**
   * @dev register a user private
   */
  function registerUserPrivate(address _address, uint256 _validUntilTime)
    private
  {
    require(walletOwners[_address] == 0, "UR03");
    users[++userCount_] = User(_validUntilTime, false);
    walletOwners[_address] = userCount_;

    emit UserRegistered(userCount_, _address, _validUntilTime);
  }

  /**
   * @dev update user extended private
   */
  function updateUserExtendedPrivate(uint256 _userId, uint256[] memory _values)
    private
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    for (uint256 i = 0; i < _values.length; i++) {
      users[_userId].extended[extendedKeys_[i]] = _values[i];
    }
    emit UserExtendedKeys(_userId, _values);
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachAddressPrivate(address _address) private {
    uint256 addressUserId = walletOwners[_address];
    require(addressUserId != 0, "UR04");
    emit AddressDetached(addressUserId, _address);
    delete walletOwners[_address];
  }

  /**
   * @dev validity of the current user
   */
  function isValidPrivate(User storage user) private view returns (bool) {
    // solhint-disable-next-line not-rely-on-time
    return !user.suspended && user.validUntilTime > now;
  }
}