/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

// File: @laborx/solidity-shared-contracts/contracts/ERC20Interface.sol

/**
* Copyright 2017每2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.23;


/// @title Defines an interface for EIP20 token smart contract
contract ERC20Interface {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    string public symbol;

    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256 supply);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}

// File: @laborx/solidity-shared-contracts/contracts/ERC223ReceivingInterface.sol

/**
* Copyright 2017每2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.18;


/// @title Contract that will work with ERC223 tokens.
interface ERC223ReceivingInterface {

	/// @notice Standard ERC223 function that will handle incoming token transfers.
	/// @param _from  Token sender address.
	/// @param _value Amount of tokens.
	/// @param _data  Transaction metadata.
    function tokenFallback(address _from, uint _value, bytes _data) external;
}

// File: @laborx/solidity-shared-contracts/contracts/Owned.sol

/**
* Copyright 2017每2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.23;



/// @title Owned contract with safe ownership pass.
///
/// Note: all the non constant functions return false instead of throwing in case if state change
/// didn't happen yet.
contract Owned {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public contractOwner;
    address public pendingContractOwner;

    modifier onlyContractOwner {
        if (msg.sender == contractOwner) {
            _;
        }
    }

    constructor()
    public
    {
        contractOwner = msg.sender;
    }

    /// @notice Prepares ownership pass.
    /// Can only be called by current owner.
    /// @param _to address of the next owner.
    /// @return success.
    function changeContractOwnership(address _to)
    public
    onlyContractOwner
    returns (bool)
    {
        if (_to == 0x0) {
            return false;
        }
        pendingContractOwner = _to;
        return true;
    }

    /// @notice Finalize ownership pass.
    /// Can only be called by pending owner.
    /// @return success.
    function claimContractOwnership()
    public
    returns (bool)
    {
        if (msg.sender != pendingContractOwner) {
            return false;
        }

        emit OwnershipTransferred(contractOwner, pendingContractOwner);
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner)
    public
    onlyContractOwner
    returns (bool)
    {
        if (newOwner == 0x0) {
            return false;
        }

        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
        delete pendingContractOwner;
        return true;
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @dev Backward compatibility only.
    /// @param newOwner The address to transfer ownership to.
    function transferContractOwnership(address newOwner)
    public
    returns (bool)
    {
        return transferOwnership(newOwner);
    }

    /// @notice Withdraw given tokens from contract to owner.
    /// This method is only allowed for contact owner.
    function withdrawTokens(address[] tokens)
    public
    onlyContractOwner
    {
        address _contractOwner = contractOwner;
        for (uint i = 0; i < tokens.length; i++) {
            ERC20Interface token = ERC20Interface(tokens[i]);
            uint balance = token.balanceOf(this);
            if (balance > 0) {
                token.transfer(_contractOwner, balance);
            }
        }
    }

    /// @notice Withdraw ether from contract to owner.
    /// This method is only allowed for contact owner.
    function withdrawEther()
    public
    onlyContractOwner
    {
        uint balance = address(this).balance;
        if (balance > 0)  {
            contractOwner.transfer(balance);
        }
    }

    /// @notice Transfers ether to another address.
    /// Allowed only for contract owners.
    /// @param _to recepient address
    /// @param _value wei to transfer; must be less or equal to total balance on the contract
    function transferEther(address _to, uint256 _value)
    public
    onlyContractOwner
    {
        require(_to != 0x0, "INVALID_ETHER_RECEPIENT_ADDRESS");
        if (_value > address(this).balance) {
            revert("INVALID_VALUE_TO_TRANSFER_ETHER");
        }

        _to.transfer(_value);
    }
}

// File: @laborx/solidity-storage-contracts/contracts/Storage.sol

/**
 * Copyright 2017每2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.23;



contract Manager {
    function isAllowed(address _actor, bytes32 _role) public view returns (bool);
    function hasAccess(address _actor) public view returns (bool);
}


contract Storage is Owned {
    struct Crate {
        mapping(bytes32 => uint) uints;
        mapping(bytes32 => address) addresses;
        mapping(bytes32 => bool) bools;
        mapping(bytes32 => int) ints;
        mapping(bytes32 => uint8) uint8s;
        mapping(bytes32 => bytes32) bytes32s;
        mapping(bytes32 => AddressUInt8) addressUInt8s;
        mapping(bytes32 => string) strings;
        mapping(bytes32 => bytes) bytesSequences;
    }

    struct AddressUInt8 {
        address _address;
        uint8 _uint8;
    }

    mapping(bytes32 => Crate) internal crates;
    Manager public manager;

    modifier onlyAllowed(bytes32 _role) {
        if (!(msg.sender == address(this) || manager.isAllowed(msg.sender, _role))) {
            revert("STORAGE_FAILED_TO_ACCESS_PROTECTED_FUNCTION");
        }
        _;
    }

    function setManager(Manager _manager)
    external
    onlyContractOwner
    returns (bool)
    {
        manager = _manager;
        return true;
    }

    function setUInt(bytes32 _crate, bytes32 _key, uint _value)
    public
    onlyAllowed(_crate)
    {
        _setUInt(_crate, _key, _value);
    }

    function _setUInt(bytes32 _crate, bytes32 _key, uint _value)
    internal
    {
        crates[_crate].uints[_key] = _value;
    }


    function getUInt(bytes32 _crate, bytes32 _key)
    public
    view
    returns (uint)
    {
        return crates[_crate].uints[_key];
    }

    function setAddress(bytes32 _crate, bytes32 _key, address _value)
    public
    onlyAllowed(_crate)
    {
        _setAddress(_crate, _key, _value);
    }

    function _setAddress(bytes32 _crate, bytes32 _key, address _value)
    internal
    {
        crates[_crate].addresses[_key] = _value;
    }

    function getAddress(bytes32 _crate, bytes32 _key)
    public
    view
    returns (address)
    {
        return crates[_crate].addresses[_key];
    }

    function setBool(bytes32 _crate, bytes32 _key, bool _value)
    public
    onlyAllowed(_crate)
    {
        _setBool(_crate, _key, _value);
    }

    function _setBool(bytes32 _crate, bytes32 _key, bool _value)
    internal
    {
        crates[_crate].bools[_key] = _value;
    }

    function getBool(bytes32 _crate, bytes32 _key)
    public
    view
    returns (bool)
    {
        return crates[_crate].bools[_key];
    }

    function setInt(bytes32 _crate, bytes32 _key, int _value)
    public
    onlyAllowed(_crate)
    {
        _setInt(_crate, _key, _value);
    }

    function _setInt(bytes32 _crate, bytes32 _key, int _value)
    internal
    {
        crates[_crate].ints[_key] = _value;
    }

    function getInt(bytes32 _crate, bytes32 _key)
    public
    view
    returns (int)
    {
        return crates[_crate].ints[_key];
    }

    function setUInt8(bytes32 _crate, bytes32 _key, uint8 _value)
    public
    onlyAllowed(_crate)
    {
        _setUInt8(_crate, _key, _value);
    }

    function _setUInt8(bytes32 _crate, bytes32 _key, uint8 _value)
    internal
    {
        crates[_crate].uint8s[_key] = _value;
    }

    function getUInt8(bytes32 _crate, bytes32 _key)
    public
    view
    returns (uint8)
    {
        return crates[_crate].uint8s[_key];
    }

    function setBytes32(bytes32 _crate, bytes32 _key, bytes32 _value)
    public
    onlyAllowed(_crate)
    {
        _setBytes32(_crate, _key, _value);
    }

    function _setBytes32(bytes32 _crate, bytes32 _key, bytes32 _value)
    internal
    {
        crates[_crate].bytes32s[_key] = _value;
    }

    function getBytes32(bytes32 _crate, bytes32 _key)
    public
    view
    returns (bytes32)
    {
        return crates[_crate].bytes32s[_key];
    }

    function setAddressUInt8(
        bytes32 _crate,
        bytes32 _key,
        address _value,
        uint8 _value2
    )
    public
    onlyAllowed(_crate)
    {
        _setAddressUInt8(_crate, _key, _value, _value2);
    }

    function _setAddressUInt8(
        bytes32 _crate,
        bytes32 _key,
        address _value,
        uint8 _value2
    )
    internal
    {
        crates[_crate].addressUInt8s[_key] = AddressUInt8(_value, _value2);
    }

    function getAddressUInt8(bytes32 _crate, bytes32 _key)
    public
    view
    returns (address, uint8)
    {
        return (crates[_crate].addressUInt8s[_key]._address, crates[_crate].addressUInt8s[_key]._uint8);
    }

    function setString(bytes32 _crate, bytes32 _key, string _value)
    public
    onlyAllowed(_crate)
    {
        _setString(_crate, _key, _value);
    }

    function _setString(bytes32 _crate, bytes32 _key, string _value)
    internal
    {
        crates[_crate].strings[_key] = _value;
    }

    function getString(bytes32 _crate, bytes32 _key)
    public
    view
    returns (string)
    {
        return crates[_crate].strings[_key];
    }

    function setBytesSequence(bytes32 _crate, bytes32 _key, bytes _value)
    public
    onlyAllowed(_crate)
    {
        _setBytesSequence(_crate, _key, _value);
    }

    function _setBytesSequence(bytes32 _crate, bytes32 _key, bytes _value)
    internal
    {
        crates[_crate].bytesSequences[_key] = _value;
    }

    function getBytesSequence(bytes32 _crate, bytes32 _key)
    public
    view
    returns (bytes)
    {
        return crates[_crate].bytesSequences[_key];
    }
}

// File: @laborx/solidity-storage-contracts/contracts/StorageInterface.sol

/**
 * Copyright 2017每2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.23;



library StorageInterface {
    struct Config {
        Storage store;
        bytes32 crate;
    }

    struct UInt {
        bytes32 id;
    }

    struct UInt8 {
        bytes32 id;
    }

    struct Int {
        bytes32 id;
    }

    struct Address {
        bytes32 id;
    }

    struct Bool {
        bytes32 id;
    }

    struct Bytes32 {
        bytes32 id;
    }

    struct String {
        bytes32 id;
    }

    struct BytesSequence {
        bytes32 id;
    }

    struct Mapping {
        bytes32 id;
    }

    struct StringMapping {
        String id;
    }

    struct BytesSequenceMapping {
        BytesSequence id;
    }

    struct UIntBoolMapping {
        Bool innerMapping;
    }

    struct UIntUIntMapping {
        Mapping innerMapping;
    }

    struct UIntBytes32Mapping {
        Mapping innerMapping;
    }

    struct UIntAddressMapping {
        Mapping innerMapping;
    }

    struct UIntEnumMapping {
        Mapping innerMapping;
    }

    struct AddressBoolMapping {
        Mapping innerMapping;
    }

    struct AddressUInt8Mapping {
        bytes32 id;
    }

    struct AddressUIntMapping {
        Mapping innerMapping;
    }

    struct AddressBytes32Mapping {
        Mapping innerMapping;
    }

    struct AddressAddressMapping {
        Mapping innerMapping;
    }

    struct Bytes32UIntMapping {
        Mapping innerMapping;
    }

    struct Bytes32UInt8Mapping {
        UInt8 innerMapping;
    }

    struct Bytes32BoolMapping {
        Bool innerMapping;
    }

    struct Bytes32Bytes32Mapping {
        Mapping innerMapping;
    }

    struct Bytes32AddressMapping {
        Mapping innerMapping;
    }

    struct Bytes32UIntBoolMapping {
        Bool innerMapping;
    }

    struct AddressAddressUInt8Mapping {
        Mapping innerMapping;
    }

    struct AddressAddressUIntMapping {
        Mapping innerMapping;
    }

    struct AddressUIntUIntMapping {
        Mapping innerMapping;
    }

    struct AddressUIntUInt8Mapping {
        Mapping innerMapping;
    }

    struct AddressBytes32Bytes32Mapping {
        Mapping innerMapping;
    }

    struct AddressBytes4BoolMapping {
        Mapping innerMapping;
    }

    struct AddressBytes4Bytes32Mapping {
        Mapping innerMapping;
    }

    struct UIntAddressUIntMapping {
        Mapping innerMapping;
    }

    struct UIntAddressAddressMapping {
        Mapping innerMapping;
    }

    struct UIntAddressBoolMapping {
        Mapping innerMapping;
    }

    struct UIntUIntAddressMapping {
        Mapping innerMapping;
    }

    struct UIntUIntBytes32Mapping {
        Mapping innerMapping;
    }

    struct UIntUIntUIntMapping {
        Mapping innerMapping;
    }

    struct Bytes32UIntUIntMapping {
        Mapping innerMapping;
    }

    struct AddressUIntUIntUIntMapping {
        Mapping innerMapping;
    }

    struct AddressUIntStructAddressUInt8Mapping {
        AddressUInt8Mapping innerMapping;
    }

    struct AddressUIntUIntStructAddressUInt8Mapping {
        AddressUInt8Mapping innerMapping;
    }

    struct AddressUIntUIntUIntStructAddressUInt8Mapping {
        AddressUInt8Mapping innerMapping;
    }

    struct AddressUIntUIntUIntUIntStructAddressUInt8Mapping {
        AddressUInt8Mapping innerMapping;
    }

    struct AddressUIntAddressUInt8Mapping {
        Mapping innerMapping;
    }

    struct AddressUIntUIntAddressUInt8Mapping {
        Mapping innerMapping;
    }

    struct AddressUIntUIntUIntAddressUInt8Mapping {
        Mapping innerMapping;
    }

    struct UIntAddressAddressBoolMapping {
        Bool innerMapping;
    }

    struct UIntUIntUIntBytes32Mapping {
        Mapping innerMapping;
    }

    struct Bytes32UIntUIntUIntMapping {
        Mapping innerMapping;
    }

    bytes32 constant SET_IDENTIFIER = "set";

    struct Set {
        UInt count;
        Mapping indexes;
        Mapping values;
    }

    struct AddressesSet {
        Set innerSet;
    }

    struct CounterSet {
        Set innerSet;
    }

    bytes32 constant ORDERED_SET_IDENTIFIER = "ordered_set";

    struct OrderedSet {
        UInt count;
        Bytes32 first;
        Bytes32 last;
        Mapping nextValues;
        Mapping previousValues;
    }

    struct OrderedUIntSet {
        OrderedSet innerSet;
    }

    struct OrderedAddressesSet {
        OrderedSet innerSet;
    }

    struct Bytes32SetMapping {
        Set innerMapping;
    }

    struct AddressesSetMapping {
        Bytes32SetMapping innerMapping;
    }

    struct UIntSetMapping {
        Bytes32SetMapping innerMapping;
    }

    struct Bytes32OrderedSetMapping {
        OrderedSet innerMapping;
    }

    struct UIntOrderedSetMapping {
        Bytes32OrderedSetMapping innerMapping;
    }

    struct AddressOrderedSetMapping {
        Bytes32OrderedSetMapping innerMapping;
    }

    // Can't use modifier due to a Solidity bug.
    function sanityCheck(bytes32 _currentId, bytes32 _newId) internal pure {
        if (_currentId != 0 || _newId == 0) {
            revert();
        }
    }

    function init(Config storage self, Storage _store, bytes32 _crate) internal {
        self.store = _store;
        self.crate = _crate;
    }

    function init(UInt8 storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(UInt storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(Int storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(Address storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(Bool storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(Bytes32 storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(String storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(BytesSequence storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(Mapping storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(StringMapping storage self, bytes32 _id) internal {
        init(self.id, _id);
    }

    function init(BytesSequenceMapping storage self, bytes32 _id) internal {
        init(self.id, _id);
    }

    function init(UIntAddressMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntEnumMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntBoolMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntBytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressAddressUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressBytes32Bytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntAddressUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntAddressBoolMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntUIntAddressMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntAddressAddressMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntUIntBytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntUIntUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntAddressAddressBoolMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntUIntUIntBytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32UIntUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32UIntUIntUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressBoolMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUInt8Mapping storage self, bytes32 _id) internal {
        sanityCheck(self.id, _id);
        self.id = _id;
    }

    function init(AddressUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressBytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressAddressMapping  storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressBytes4BoolMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressBytes4Bytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntUIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntStructAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntStructAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntUIntStructAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntUIntUIntStructAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressUIntUIntUIntAddressUInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32UIntMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32UInt8Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32BoolMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32Bytes32Mapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32AddressMapping  storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32UIntBoolMapping  storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Set storage self, bytes32 _id) internal {
        init(self.count, keccak256(abi.encodePacked(_id, "count")));
        init(self.indexes, keccak256(abi.encodePacked(_id, "indexes")));
        init(self.values, keccak256(abi.encodePacked(_id, "values")));
    }

    function init(AddressesSet storage self, bytes32 _id) internal {
        init(self.innerSet, _id);
    }

    function init(CounterSet storage self, bytes32 _id) internal {
        init(self.innerSet, _id);
    }

    function init(OrderedSet storage self, bytes32 _id) internal {
        init(self.count, keccak256(abi.encodePacked(_id, "uint/count")));
        init(self.first, keccak256(abi.encodePacked(_id, "uint/first")));
        init(self.last, keccak256(abi.encodePacked(_id, "uint/last")));
        init(self.nextValues, keccak256(abi.encodePacked(_id, "uint/next")));
        init(self.previousValues, keccak256(abi.encodePacked(_id, "uint/prev")));
    }

    function init(OrderedUIntSet storage self, bytes32 _id) internal {
        init(self.innerSet, _id);
    }

    function init(OrderedAddressesSet storage self, bytes32 _id) internal {
        init(self.innerSet, _id);
    }

    function init(Bytes32SetMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressesSetMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntSetMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(Bytes32OrderedSetMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(UIntOrderedSetMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    function init(AddressOrderedSetMapping storage self, bytes32 _id) internal {
        init(self.innerMapping, _id);
    }

    /** `set` operation */

    function set(Config storage self, UInt storage item, uint _value) internal {
        self.store.setUInt(self.crate, item.id, _value);
    }

    function set(Config storage self, UInt storage item, bytes32 _salt, uint _value) internal {
        self.store.setUInt(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, UInt8 storage item, uint8 _value) internal {
        self.store.setUInt8(self.crate, item.id, _value);
    }

    function set(Config storage self, UInt8 storage item, bytes32 _salt, uint8 _value) internal {
        self.store.setUInt8(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, Int storage item, int _value) internal {
        self.store.setInt(self.crate, item.id, _value);
    }

    function set(Config storage self, Int storage item, bytes32 _salt, int _value) internal {
        self.store.setInt(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, Address storage item, address _value) internal {
        self.store.setAddress(self.crate, item.id, _value);
    }

    function set(Config storage self, Address storage item, bytes32 _salt, address _value) internal {
        self.store.setAddress(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, Bool storage item, bool _value) internal {
        self.store.setBool(self.crate, item.id, _value);
    }

    function set(Config storage self, Bool storage item, bytes32 _salt, bool _value) internal {
        self.store.setBool(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, Bytes32 storage item, bytes32 _value) internal {
        self.store.setBytes32(self.crate, item.id, _value);
    }

    function set(Config storage self, Bytes32 storage item, bytes32 _salt, bytes32 _value) internal {
        self.store.setBytes32(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, String storage item, string _value) internal {
        self.store.setString(self.crate, item.id, _value);
    }

    function set(Config storage self, String storage item, bytes32 _salt, string _value) internal {
        self.store.setString(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, BytesSequence storage item,  bytes _value) internal {
        self.store.setBytesSequence(self.crate, item.id, _value);
    }

    function set(Config storage self, BytesSequence storage item, bytes32 _salt, bytes _value) internal {
        self.store.setBytesSequence(self.crate, keccak256(abi.encodePacked(item.id, _salt)), _value);
    }

    function set(Config storage self, Mapping storage item, uint _key, uint _value) internal {
        self.store.setUInt(self.crate, keccak256(abi.encodePacked(item.id, _key)), _value);
    }

    function set(Config storage self, Mapping storage item, bytes32 _key, bytes32 _value) internal {
        self.store.setBytes32(self.crate, keccak256(abi.encodePacked(item.id, _key)), _value);
    }

    function set(Config storage self, StringMapping storage item, bytes32 _key, string _value) internal {
        set(self, item.id, _key, _value);
    }

    function set(Config storage self, BytesSequenceMapping storage item, bytes32 _key, bytes _value) internal {
        set(self, item.id, _key, _value);
    }

    function set(Config storage self, AddressUInt8Mapping storage item, bytes32 _key, address _value1, uint8 _value2) internal {
        self.store.setAddressUInt8(self.crate, keccak256(abi.encodePacked(item.id, _key)), _value1, _value2);
    }

    function set(Config storage self, Mapping storage item, bytes32 _key, bytes32 _key2, bytes32 _value) internal {
        set(self, item, keccak256(abi.encodePacked(_key, _key2)), _value);
    }

    function set(Config storage self, Mapping storage item, bytes32 _key, bytes32 _key2, bytes32 _key3, bytes32 _value) internal {
        set(self, item, keccak256(abi.encodePacked(_key, _key2, _key3)), _value);
    }

    function set(Config storage self, Bool storage item, bytes32 _key, bytes32 _key2, bytes32 _key3, bool _value) internal {
        set(self, item, keccak256(abi.encodePacked(_key, _key2, _key3)), _value);
    }

    function set(Config storage self, UIntAddressMapping storage item, uint _key, address _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_value));
    }

    function set(Config storage self, UIntUIntMapping storage item, uint _key, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_value));
    }

    function set(Config storage self, UIntBoolMapping storage item, uint _key, bool _value) internal {
        set(self, item.innerMapping, bytes32(_key), _value);
    }

    function set(Config storage self, UIntEnumMapping storage item, uint _key, uint8 _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_value));
    }

    function set(Config storage self, UIntBytes32Mapping storage item, uint _key, bytes32 _value) internal {
        set(self, item.innerMapping, bytes32(_key), _value);
    }

    function set(Config storage self, Bytes32UIntMapping storage item, bytes32 _key, uint _value) internal {
        set(self, item.innerMapping, _key, bytes32(_value));
    }

    function set(Config storage self, Bytes32UInt8Mapping storage item, bytes32 _key, uint8 _value) internal {
        set(self, item.innerMapping, _key, _value);
    }

    function set(Config storage self, Bytes32BoolMapping storage item, bytes32 _key, bool _value) internal {
        set(self, item.innerMapping, _key, _value);
    }

    function set(Config storage self, Bytes32Bytes32Mapping storage item, bytes32 _key, bytes32 _value) internal {
        set(self, item.innerMapping, _key, _value);
    }

    function set(Config storage self, Bytes32AddressMapping storage item, bytes32 _key, address _value) internal {
        set(self, item.innerMapping, _key, bytes32(_value));
    }

    function set(Config storage self, Bytes32UIntBoolMapping storage item, bytes32 _key, uint _key2, bool _value) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2)), _value);
    }

    function set(Config storage self, AddressUIntMapping storage item, address _key, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_value));
    }

    function set(Config storage self, AddressBoolMapping storage item, address _key, bool _value) internal {
        set(self, item.innerMapping, bytes32(_key), toBytes32(_value));
    }

    function set(Config storage self, AddressBytes32Mapping storage item, address _key, bytes32 _value) internal {
        set(self, item.innerMapping, bytes32(_key), _value);
    }

    function set(Config storage self, AddressAddressMapping storage item, address _key, address _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_value));
    }

    function set(Config storage self, AddressAddressUIntMapping storage item, address _key, address _key2, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, AddressUIntUIntMapping storage item, address _key, uint _key2, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, AddressAddressUInt8Mapping storage item, address _key, address _key2, uint8 _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, AddressUIntUInt8Mapping storage item, address _key, uint _key2, uint8 _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, AddressBytes32Bytes32Mapping storage item, address _key, bytes32 _key2, bytes32 _value) internal {
        set(self, item.innerMapping, bytes32(_key), _key2, _value);
    }

    function set(Config storage self, UIntAddressUIntMapping storage item, uint _key, address _key2, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, UIntAddressBoolMapping storage item, uint _key, address _key2, bool _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), toBytes32(_value));
    }

    function set(Config storage self, UIntAddressAddressMapping storage item, uint _key, address _key2, address _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, UIntUIntAddressMapping storage item, uint _key, uint _key2, address _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, UIntUIntBytes32Mapping storage item, uint _key, uint _key2, bytes32 _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), _value);
    }

    function set(Config storage self, UIntUIntUIntMapping storage item, uint _key, uint _key2, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, UIntAddressAddressBoolMapping storage item, uint _key, address _key2, address _key3, bool _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_key3), _value);
    }

    function set(Config storage self, UIntUIntUIntBytes32Mapping storage item, uint _key, uint _key2,  uint _key3, bytes32 _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_key3), _value);
    }

    function set(Config storage self, Bytes32UIntUIntMapping storage item, bytes32 _key, uint _key2, uint _value) internal {
        set(self, item.innerMapping, _key, bytes32(_key2), bytes32(_value));
    }

    function set(Config storage self, Bytes32UIntUIntUIntMapping storage item, bytes32 _key, uint _key2,  uint _key3, uint _value) internal {
        set(self, item.innerMapping, _key, bytes32(_key2), bytes32(_key3), bytes32(_value));
    }

    function set(Config storage self, AddressUIntUIntUIntMapping storage item, address _key, uint _key2,  uint _key3, uint _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_key3), bytes32(_value));
    }

    function set(Config storage self, AddressUIntStructAddressUInt8Mapping storage item, address _key, uint _key2, address _value, uint8 _value2) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2)), _value, _value2);
    }

    function set(Config storage self, AddressUIntUIntStructAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3, address _value, uint8 _value2) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3)), _value, _value2);
    }

    function set(Config storage self, AddressUIntUIntUIntStructAddressUInt8Mapping storage item, address _key, uint _key2,  uint _key3, uint _key4, address _value, uint8 _value2) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4)), _value, _value2);
    }

    function set(Config storage self, AddressUIntUIntUIntUIntStructAddressUInt8Mapping storage item, address _key, uint _key2,  uint _key3, uint _key4, uint _key5, address _value, uint8 _value2) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4, _key5)), _value, _value2);
    }

    function set(Config storage self, AddressUIntAddressUInt8Mapping storage item, address _key, uint _key2, address _key3, uint8 _value) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3)), bytes32(_value));
    }

    function set(Config storage self, AddressUIntUIntAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3, address _key4, uint8 _value) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4)), bytes32(_value));
    }

    function set(Config storage self, AddressUIntUIntUIntAddressUInt8Mapping storage item, address _key, uint _key2,  uint _key3, uint _key4, address _key5, uint8 _value) internal {
        set(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4, _key5)), bytes32(_value));
    }

    function set(Config storage self, AddressBytes4BoolMapping storage item, address _key, bytes4 _key2, bool _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), toBytes32(_value));
    }

    function set(Config storage self, AddressBytes4Bytes32Mapping storage item, address _key, bytes4 _key2, bytes32 _value) internal {
        set(self, item.innerMapping, bytes32(_key), bytes32(_key2), _value);
    }


    /** `add` operation */

    function add(Config storage self, Set storage item, bytes32 _value) internal {
        add(self, item, SET_IDENTIFIER, _value);
    }

    function add(Config storage self, Set storage item, bytes32 _salt, bytes32 _value) private {
        if (includes(self, item, _salt, _value)) {
            return;
        }
        uint newCount = count(self, item, _salt) + 1;
        set(self, item.values, _salt, bytes32(newCount), _value);
        set(self, item.indexes, _salt, _value, bytes32(newCount));
        set(self, item.count, _salt, newCount);
    }

    function add(Config storage self, AddressesSet storage item, address _value) internal {
        add(self, item.innerSet, bytes32(_value));
    }

    function add(Config storage self, CounterSet storage item) internal {
        add(self, item.innerSet, bytes32(count(self, item) + 1));
    }

    function add(Config storage self, OrderedSet storage item, bytes32 _value) internal {
        add(self, item, ORDERED_SET_IDENTIFIER, _value);
    }

    function add(Config storage self, OrderedSet storage item, bytes32 _salt, bytes32 _value) private {
        if (_value == 0x0) { revert(); }

        if (includes(self, item, _salt, _value)) { return; }

        if (count(self, item, _salt) == 0x0) {
            set(self, item.first, _salt, _value);
        }

        if (get(self, item.last, _salt) != 0x0) {
            _setOrderedSetLink(self, item.nextValues, _salt, get(self, item.last, _salt), _value);
            _setOrderedSetLink(self, item.previousValues, _salt, _value, get(self, item.last, _salt));
        }

        _setOrderedSetLink(self, item.nextValues, _salt,  _value, 0x0);
        set(self, item.last, _salt, _value);
        set(self, item.count, _salt, get(self, item.count, _salt) + 1);
    }

    function add(Config storage self, Bytes32SetMapping storage item, bytes32 _key, bytes32 _value) internal {
        add(self, item.innerMapping, _key, _value);
    }

    function add(Config storage self, AddressesSetMapping storage item, bytes32 _key, address _value) internal {
        add(self, item.innerMapping, _key, bytes32(_value));
    }

    function add(Config storage self, UIntSetMapping storage item, bytes32 _key, uint _value) internal {
        add(self, item.innerMapping, _key, bytes32(_value));
    }

    function add(Config storage self, Bytes32OrderedSetMapping storage item, bytes32 _key, bytes32 _value) internal {
        add(self, item.innerMapping, _key, _value);
    }

    function add(Config storage self, UIntOrderedSetMapping storage item, bytes32 _key, uint _value) internal {
        add(self, item.innerMapping, _key, bytes32(_value));
    }

    function add(Config storage self, AddressOrderedSetMapping storage item, bytes32 _key, address _value) internal {
        add(self, item.innerMapping, _key, bytes32(_value));
    }

    function add(Config storage self, OrderedUIntSet storage item, uint _value) internal {
        add(self, item.innerSet, bytes32(_value));
    }

    function add(Config storage self, OrderedAddressesSet storage item, address _value) internal {
        add(self, item.innerSet, bytes32(_value));
    }

    function set(Config storage self, Set storage item, bytes32 _oldValue, bytes32 _newValue) internal {
        set(self, item, SET_IDENTIFIER, _oldValue, _newValue);
    }

    function set(Config storage self, Set storage item, bytes32 _salt, bytes32 _oldValue, bytes32 _newValue) private {
        if (!includes(self, item, _salt, _oldValue)) {
            return;
        }
        uint index = uint(get(self, item.indexes, _salt, _oldValue));
        set(self, item.values, _salt, bytes32(index), _newValue);
        set(self, item.indexes, _salt, _newValue, bytes32(index));
        set(self, item.indexes, _salt, _oldValue, bytes32(0));
    }

    function set(Config storage self, AddressesSet storage item, address _oldValue, address _newValue) internal {
        set(self, item.innerSet, bytes32(_oldValue), bytes32(_newValue));
    }

    /** `remove` operation */

    function remove(Config storage self, Set storage item, bytes32 _value) internal {
        remove(self, item, SET_IDENTIFIER, _value);
    }

    function remove(Config storage self, Set storage item, bytes32 _salt, bytes32 _value) private {
        if (!includes(self, item, _salt, _value)) {
            return;
        }
        uint lastIndex = count(self, item, _salt);
        bytes32 lastValue = get(self, item.values, _salt, bytes32(lastIndex));
        uint index = uint(get(self, item.indexes, _salt, _value));
        if (index < lastIndex) {
            set(self, item.indexes, _salt, lastValue, bytes32(index));
            set(self, item.values, _salt, bytes32(index), lastValue);
        }
        set(self, item.indexes, _salt, _value, bytes32(0));
        set(self, item.values, _salt, bytes32(lastIndex), bytes32(0));
        set(self, item.count, _salt, lastIndex - 1);
    }

    function remove(Config storage self, AddressesSet storage item, address _value) internal {
        remove(self, item.innerSet, bytes32(_value));
    }

    function remove(Config storage self, CounterSet storage item, uint _value) internal {
        remove(self, item.innerSet, bytes32(_value));
    }

    function remove(Config storage self, OrderedSet storage item, bytes32 _value) internal {
        remove(self, item, ORDERED_SET_IDENTIFIER, _value);
    }

    function remove(Config storage self, OrderedSet storage item, bytes32 _salt, bytes32 _value) private {
        if (!includes(self, item, _salt, _value)) { return; }

        _setOrderedSetLink(self, item.nextValues, _salt, get(self, item.previousValues, _salt, _value), get(self, item.nextValues, _salt, _value));
        _setOrderedSetLink(self, item.previousValues, _salt, get(self, item.nextValues, _salt, _value), get(self, item.previousValues, _salt, _value));

        if (_value == get(self, item.first, _salt)) {
            set(self, item.first, _salt, get(self, item.nextValues, _salt, _value));
        }

        if (_value == get(self, item.last, _salt)) {
            set(self, item.last, _salt, get(self, item.previousValues, _salt, _value));
        }

        _deleteOrderedSetLink(self, item.nextValues, _salt, _value);
        _deleteOrderedSetLink(self, item.previousValues, _salt, _value);

        set(self, item.count, _salt, get(self, item.count, _salt) - 1);
    }

    function remove(Config storage self, OrderedUIntSet storage item, uint _value) internal {
        remove(self, item.innerSet, bytes32(_value));
    }

    function remove(Config storage self, OrderedAddressesSet storage item, address _value) internal {
        remove(self, item.innerSet, bytes32(_value));
    }

    function remove(Config storage self, Bytes32SetMapping storage item, bytes32 _key, bytes32 _value) internal {
        remove(self, item.innerMapping, _key, _value);
    }

    function remove(Config storage self, AddressesSetMapping storage item, bytes32 _key, address _value) internal {
        remove(self, item.innerMapping, _key, bytes32(_value));
    }

    function remove(Config storage self, UIntSetMapping storage item, bytes32 _key, uint _value) internal {
        remove(self, item.innerMapping, _key, bytes32(_value));
    }

    function remove(Config storage self, Bytes32OrderedSetMapping storage item, bytes32 _key, bytes32 _value) internal {
        remove(self, item.innerMapping, _key, _value);
    }

    function remove(Config storage self, UIntOrderedSetMapping storage item, bytes32 _key, uint _value) internal {
        remove(self, item.innerMapping, _key, bytes32(_value));
    }

    function remove(Config storage self, AddressOrderedSetMapping storage item, bytes32 _key, address _value) internal {
        remove(self, item.innerMapping, _key, bytes32(_value));
    }

    /** 'copy` operation */

    function copy(Config storage self, Set storage source, Set storage dest) internal {
        uint _destCount = count(self, dest);
        bytes32[] memory _toRemoveFromDest = new bytes32[](_destCount);
        uint _idx;
        uint _pointer = 0;
        for (_idx = 0; _idx < _destCount; ++_idx) {
            bytes32 _destValue = get(self, dest, _idx);
            if (!includes(self, source, _destValue)) {
                _toRemoveFromDest[_pointer++] = _destValue;
            }
        }

        uint _sourceCount = count(self, source);
        for (_idx = 0; _idx < _sourceCount; ++_idx) {
            add(self, dest, get(self, source, _idx));
        }

        for (_idx = 0; _idx < _pointer; ++_idx) {
            remove(self, dest, _toRemoveFromDest[_idx]);
        }
    }

    function copy(Config storage self, AddressesSet storage source, AddressesSet storage dest) internal {
        copy(self, source.innerSet, dest.innerSet);
    }

    function copy(Config storage self, CounterSet storage source, CounterSet storage dest) internal {
        copy(self, source.innerSet, dest.innerSet);
    }

    /** `get` operation */

    function get(Config storage self, UInt storage item) internal view returns (uint) {
        return self.store.getUInt(self.crate, item.id);
    }

    function get(Config storage self, UInt storage item, bytes32 salt) internal view returns (uint) {
        return self.store.getUInt(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, UInt8 storage item) internal view returns (uint8) {
        return self.store.getUInt8(self.crate, item.id);
    }

    function get(Config storage self, UInt8 storage item, bytes32 salt) internal view returns (uint8) {
        return self.store.getUInt8(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, Int storage item) internal view returns (int) {
        return self.store.getInt(self.crate, item.id);
    }

    function get(Config storage self, Int storage item, bytes32 salt) internal view returns (int) {
        return self.store.getInt(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, Address storage item) internal view returns (address) {
        return self.store.getAddress(self.crate, item.id);
    }

    function get(Config storage self, Address storage item, bytes32 salt) internal view returns (address) {
        return self.store.getAddress(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, Bool storage item) internal view returns (bool) {
        return self.store.getBool(self.crate, item.id);
    }

    function get(Config storage self, Bool storage item, bytes32 salt) internal view returns (bool) {
        return self.store.getBool(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, Bytes32 storage item) internal view returns (bytes32) {
        return self.store.getBytes32(self.crate, item.id);
    }

    function get(Config storage self, Bytes32 storage item, bytes32 salt) internal view returns (bytes32) {
        return self.store.getBytes32(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, String storage item) internal view returns (string) {
        return self.store.getString(self.crate, item.id);
    }

    function get(Config storage self, String storage item, bytes32 salt) internal view returns (string) {
        return self.store.getString(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, BytesSequence storage item) internal view returns (bytes) {
        return self.store.getBytesSequence(self.crate, item.id);
    }

    function get(Config storage self, BytesSequence storage item, bytes32 salt) internal view returns (bytes) {
        return self.store.getBytesSequence(self.crate, keccak256(abi.encodePacked(item.id, salt)));
    }

    function get(Config storage self, Mapping storage item, uint _key) internal view returns (uint) {
        return self.store.getUInt(self.crate, keccak256(abi.encodePacked(item.id, _key)));
    }

    function get(Config storage self, Mapping storage item, bytes32 _key) internal view returns (bytes32) {
        return self.store.getBytes32(self.crate, keccak256(abi.encodePacked(item.id, _key)));
    }

    function get(Config storage self, StringMapping storage item, bytes32 _key) internal view returns (string) {
        return get(self, item.id, _key);
    }

    function get(Config storage self, BytesSequenceMapping storage item, bytes32 _key) internal view returns (bytes) {
        return get(self, item.id, _key);
    }

    function get(Config storage self, AddressUInt8Mapping storage item, bytes32 _key) internal view returns (address, uint8) {
        return self.store.getAddressUInt8(self.crate, keccak256(abi.encodePacked(item.id, _key)));
    }

    function get(Config storage self, Mapping storage item, bytes32 _key, bytes32 _key2) internal view returns (bytes32) {
        return get(self, item, keccak256(abi.encodePacked(_key, _key2)));
    }

    function get(Config storage self, Mapping storage item, bytes32 _key, bytes32 _key2, bytes32 _key3) internal view returns (bytes32) {
        return get(self, item, keccak256(abi.encodePacked(_key, _key2, _key3)));
    }

    function get(Config storage self, Bool storage item, bytes32 _key, bytes32 _key2, bytes32 _key3) internal view returns (bool) {
        return get(self, item, keccak256(abi.encodePacked(_key, _key2, _key3)));
    }

    function get(Config storage self, UIntBoolMapping storage item, uint _key) internal view returns (bool) {
        return get(self, item.innerMapping, bytes32(_key));
    }

    function get(Config storage self, UIntEnumMapping storage item, uint _key) internal view returns (uint8) {
        return uint8(get(self, item.innerMapping, bytes32(_key)));
    }

    function get(Config storage self, UIntUIntMapping storage item, uint _key) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key)));
    }

    function get(Config storage self, UIntAddressMapping storage item, uint _key) internal view returns (address) {
        return address(get(self, item.innerMapping, bytes32(_key)));
    }

    function get(Config storage self, Bytes32UIntMapping storage item, bytes32 _key) internal view returns (uint) {
        return uint(get(self, item.innerMapping, _key));
    }

    function get(Config storage self, Bytes32AddressMapping storage item, bytes32 _key) internal view returns (address) {
        return address(get(self, item.innerMapping, _key));
    }

    function get(Config storage self, Bytes32UInt8Mapping storage item, bytes32 _key) internal view returns (uint8) {
        return get(self, item.innerMapping, _key);
    }

    function get(Config storage self, Bytes32BoolMapping storage item, bytes32 _key) internal view returns (bool) {
        return get(self, item.innerMapping, _key);
    }

    function get(Config storage self, Bytes32Bytes32Mapping storage item, bytes32 _key) internal view returns (bytes32) {
        return get(self, item.innerMapping, _key);
    }

    function get(Config storage self, Bytes32UIntBoolMapping storage item, bytes32 _key, uint _key2) internal view returns (bool) {
        return get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2)));
    }

    function get(Config storage self, UIntBytes32Mapping storage item, uint _key) internal view returns (bytes32) {
        return get(self, item.innerMapping, bytes32(_key));
    }

    function get(Config storage self, AddressUIntMapping storage item, address _key) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key)));
    }

    function get(Config storage self, AddressBoolMapping storage item, address _key) internal view returns (bool) {
        return toBool(get(self, item.innerMapping, bytes32(_key)));
    }

    function get(Config storage self, AddressAddressMapping storage item, address _key) internal view returns (address) {
        return address(get(self, item.innerMapping, bytes32(_key)));
    }

    function get(Config storage self, AddressBytes32Mapping storage item, address _key) internal view returns (bytes32) {
        return get(self, item.innerMapping, bytes32(_key));
    }

    function get(Config storage self, UIntUIntBytes32Mapping storage item, uint _key, uint _key2) internal view returns (bytes32) {
        return get(self, item.innerMapping, bytes32(_key), bytes32(_key2));
    }

    function get(Config storage self, UIntUIntAddressMapping storage item, uint _key, uint _key2) internal view returns (address) {
        return address(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, UIntUIntUIntMapping storage item, uint _key, uint _key2) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, Bytes32UIntUIntMapping storage item, bytes32 _key, uint _key2) internal view returns (uint) {
        return uint(get(self, item.innerMapping, _key, bytes32(_key2)));
    }

    function get(Config storage self, Bytes32UIntUIntUIntMapping storage item, bytes32 _key, uint _key2, uint _key3) internal view returns (uint) {
        return uint(get(self, item.innerMapping, _key, bytes32(_key2), bytes32(_key3)));
    }

    function get(Config storage self, AddressAddressUIntMapping storage item, address _key, address _key2) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, AddressAddressUInt8Mapping storage item, address _key, address _key2) internal view returns (uint8) {
        return uint8(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, AddressUIntUIntMapping storage item, address _key, uint _key2) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, AddressUIntUInt8Mapping storage item, address _key, uint _key2) internal view returns (uint) {
        return uint8(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, AddressBytes32Bytes32Mapping storage item, address _key, bytes32 _key2) internal view returns (bytes32) {
        return get(self, item.innerMapping, bytes32(_key), _key2);
    }

    function get(Config storage self, AddressBytes4BoolMapping storage item, address _key, bytes4 _key2) internal view returns (bool) {
        return toBool(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, AddressBytes4Bytes32Mapping storage item, address _key, bytes4 _key2) internal view returns (bytes32) {
        return get(self, item.innerMapping, bytes32(_key), bytes32(_key2));
    }

    function get(Config storage self, UIntAddressUIntMapping storage item, uint _key, address _key2) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, UIntAddressBoolMapping storage item, uint _key, address _key2) internal view returns (bool) {
        return toBool(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, UIntAddressAddressMapping storage item, uint _key, address _key2) internal view returns (address) {
        return address(get(self, item.innerMapping, bytes32(_key), bytes32(_key2)));
    }

    function get(Config storage self, UIntAddressAddressBoolMapping storage item, uint _key, address _key2, address _key3) internal view returns (bool) {
        return get(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_key3));
    }

    function get(Config storage self, UIntUIntUIntBytes32Mapping storage item, uint _key, uint _key2, uint _key3) internal view returns (bytes32) {
        return get(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_key3));
    }

    function get(Config storage self, AddressUIntUIntUIntMapping storage item, address _key, uint _key2, uint _key3) internal view returns (uint) {
        return uint(get(self, item.innerMapping, bytes32(_key), bytes32(_key2), bytes32(_key3)));
    }

    function get(Config storage self, AddressUIntStructAddressUInt8Mapping storage item, address _key, uint _key2) internal view returns (address, uint8) {
        return get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2)));
    }

    function get(Config storage self, AddressUIntUIntStructAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3) internal view returns (address, uint8) {
        return get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3)));
    }

    function get(Config storage self, AddressUIntUIntUIntStructAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3, uint _key4) internal view returns (address, uint8) {
        return get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4)));
    }

    function get(Config storage self, AddressUIntUIntUIntUIntStructAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3, uint _key4, uint _key5) internal view returns (address, uint8) {
        return get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4, _key5)));
    }

    function get(Config storage self, AddressUIntAddressUInt8Mapping storage item, address _key, uint _key2, address _key3) internal view returns (uint8) {
        return uint8(get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3))));
    }

    function get(Config storage self, AddressUIntUIntAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3, address _key4) internal view returns (uint8) {
        return uint8(get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4))));
    }

    function get(Config storage self, AddressUIntUIntUIntAddressUInt8Mapping storage item, address _key, uint _key2, uint _key3, uint _key4, address _key5) internal view returns (uint8) {
        return uint8(get(self, item.innerMapping, keccak256(abi.encodePacked(_key, _key2, _key3, _key4, _key5))));
    }

    /** `includes` operation */

    function includes(Config storage self, Set storage item, bytes32 _value) internal view returns (bool) {
        return includes(self, item, SET_IDENTIFIER, _value);
    }

    function includes(Config storage self, Set storage item, bytes32 _salt, bytes32 _value) internal view returns (bool) {
        return get(self, item.indexes, _salt, _value) != 0;
    }

    function includes(Config storage self, AddressesSet storage item, address _value) internal view returns (bool) {
        return includes(self, item.innerSet, bytes32(_value));
    }

    function includes(Config storage self, CounterSet storage item, uint _value) internal view returns (bool) {
        return includes(self, item.innerSet, bytes32(_value));
    }

    function includes(Config storage self, OrderedSet storage item, bytes32 _value) internal view returns (bool) {
        return includes(self, item, ORDERED_SET_IDENTIFIER, _value);
    }

    function includes(Config storage self, OrderedSet storage item, bytes32 _salt, bytes32 _value) private view returns (bool) {
        return _value != 0x0 && (get(self, item.nextValues, _salt, _value) != 0x0 || get(self, item.last, _salt) == _value);
    }

    function includes(Config storage self, OrderedUIntSet storage item, uint _value) internal view returns (bool) {
        return includes(self, item.innerSet, bytes32(_value));
    }

    function includes(Config storage self, OrderedAddressesSet storage item, address _value) internal view returns (bool) {
        return includes(self, item.innerSet, bytes32(_value));
    }

    function includes(Config storage self, Bytes32SetMapping storage item, bytes32 _key, bytes32 _value) internal view returns (bool) {
        return includes(self, item.innerMapping, _key, _value);
    }

    function includes(Config storage self, AddressesSetMapping storage item, bytes32 _key, address _value) internal view returns (bool) {
        return includes(self, item.innerMapping, _key, bytes32(_value));
    }

    function includes(Config storage self, UIntSetMapping storage item, bytes32 _key, uint _value) internal view returns (bool) {
        return includes(self, item.innerMapping, _key, bytes32(_value));
    }

    function includes(Config storage self, Bytes32OrderedSetMapping storage item, bytes32 _key, bytes32 _value) internal view returns (bool) {
        return includes(self, item.innerMapping, _key, _value);
    }

    function includes(Config storage self, UIntOrderedSetMapping storage item, bytes32 _key, uint _value) internal view returns (bool) {
        return includes(self, item.innerMapping, _key, bytes32(_value));
    }

    function includes(Config storage self, AddressOrderedSetMapping storage item, bytes32 _key, address _value) internal view returns (bool) {
        return includes(self, item.innerMapping, _key, bytes32(_value));
    }

    function getIndex(Config storage self, Set storage item, bytes32 _value) internal view returns (uint) {
        return getIndex(self, item, SET_IDENTIFIER, _value);
    }

    function getIndex(Config storage self, Set storage item, bytes32 _salt, bytes32 _value) private view returns (uint) {
        return uint(get(self, item.indexes, _salt, _value));
    }

    function getIndex(Config storage self, AddressesSet storage item, address _value) internal view returns (uint) {
        return getIndex(self, item.innerSet, bytes32(_value));
    }

    function getIndex(Config storage self, CounterSet storage item, uint _value) internal view returns (uint) {
        return getIndex(self, item.innerSet, bytes32(_value));
    }

    function getIndex(Config storage self, Bytes32SetMapping storage item, bytes32 _key, bytes32 _value) internal view returns (uint) {
        return getIndex(self, item.innerMapping, _key, _value);
    }

    function getIndex(Config storage self, AddressesSetMapping storage item, bytes32 _key, address _value) internal view returns (uint) {
        return getIndex(self, item.innerMapping, _key, bytes32(_value));
    }

    function getIndex(Config storage self, UIntSetMapping storage item, bytes32 _key, uint _value) internal view returns (uint) {
        return getIndex(self, item.innerMapping, _key, bytes32(_value));
    }

    /** `count` operation */

    function count(Config storage self, Set storage item) internal view returns (uint) {
        return count(self, item, SET_IDENTIFIER);
    }

    function count(Config storage self, Set storage item, bytes32 _salt) internal view returns (uint) {
        return get(self, item.count, _salt);
    }

    function count(Config storage self, AddressesSet storage item) internal view returns (uint) {
        return count(self, item.innerSet);
    }

    function count(Config storage self, CounterSet storage item) internal view returns (uint) {
        return count(self, item.innerSet);
    }

    function count(Config storage self, OrderedSet storage item) internal view returns (uint) {
        return count(self, item, ORDERED_SET_IDENTIFIER);
    }

    function count(Config storage self, OrderedSet storage item, bytes32 _salt) private view returns (uint) {
        return get(self, item.count, _salt);
    }

    function count(Config storage self, OrderedUIntSet storage item) internal view returns (uint) {
        return count(self, item.innerSet);
    }

    function count(Config storage self, OrderedAddressesSet storage item) internal view returns (uint) {
        return count(self, item.innerSet);
    }

    function count(Config storage self, Bytes32SetMapping storage item, bytes32 _key) internal view returns (uint) {
        return count(self, item.innerMapping, _key);
    }

    function count(Config storage self, AddressesSetMapping storage item, bytes32 _key) internal view returns (uint) {
        return count(self, item.innerMapping, _key);
    }

    function count(Config storage self, UIntSetMapping storage item, bytes32 _key) internal view returns (uint) {
        return count(self, item.innerMapping, _key);
    }

    function count(Config storage self, Bytes32OrderedSetMapping storage item, bytes32 _key) internal view returns (uint) {
        return count(self, item.innerMapping, _key);
    }

    function count(Config storage self, UIntOrderedSetMapping storage item, bytes32 _key) internal view returns (uint) {
        return count(self, item.innerMapping, _key);
    }

    function count(Config storage self, AddressOrderedSetMapping storage item, bytes32 _key) internal view returns (uint) {
        return count(self, item.innerMapping, _key);
    }

    function get(Config storage self, Set storage item) internal view returns (bytes32[] result) {
        result = get(self, item, SET_IDENTIFIER);
    }

    function get(Config storage self, Set storage item, bytes32 _salt) private view returns (bytes32[] result) {
        uint valuesCount = count(self, item, _salt);
        result = new bytes32[](valuesCount);
        for (uint i = 0; i < valuesCount; i++) {
            result[i] = get(self, item, _salt, i);
        }
    }

    function get(Config storage self, AddressesSet storage item) internal view returns (address[]) {
        return toAddresses(get(self, item.innerSet));
    }

    function get(Config storage self, CounterSet storage item) internal view returns (uint[]) {
        return toUInt(get(self, item.innerSet));
    }

    function get(Config storage self, Bytes32SetMapping storage item, bytes32 _key) internal view returns (bytes32[]) {
        return get(self, item.innerMapping, _key);
    }

    function get(Config storage self, AddressesSetMapping storage item, bytes32 _key) internal view returns (address[]) {
        return toAddresses(get(self, item.innerMapping, _key));
    }

    function get(Config storage self, UIntSetMapping storage item, bytes32 _key) internal view returns (uint[]) {
        return toUInt(get(self, item.innerMapping, _key));
    }

    function get(Config storage self, Set storage item, uint _index) internal view returns (bytes32) {
        return get(self, item, SET_IDENTIFIER, _index);
    }

    function get(Config storage self, Set storage item, bytes32 _salt, uint _index) private view returns (bytes32) {
        return get(self, item.values, _salt, bytes32(_index+1));
    }

    function get(Config storage self, AddressesSet storage item, uint _index) internal view returns (address) {
        return address(get(self, item.innerSet, _index));
    }

    function get(Config storage self, CounterSet storage item, uint _index) internal view returns (uint) {
        return uint(get(self, item.innerSet, _index));
    }

    function get(Config storage self, Bytes32SetMapping storage item, bytes32 _key, uint _index) internal view returns (bytes32) {
        return get(self, item.innerMapping, _key, _index);
    }

    function get(Config storage self, AddressesSetMapping storage item, bytes32 _key, uint _index) internal view returns (address) {
        return address(get(self, item.innerMapping, _key, _index));
    }

    function get(Config storage self, UIntSetMapping storage item, bytes32 _key, uint _index) internal view returns (uint) {
        return uint(get(self, item.innerMapping, _key, _index));
    }

    function getNextValue(Config storage self, OrderedSet storage item, bytes32 _value) internal view returns (bytes32) {
        return getNextValue(self, item, ORDERED_SET_IDENTIFIER, _value);
    }

    function getNextValue(Config storage self, OrderedSet storage item, bytes32 _salt, bytes32 _value) private view returns (bytes32) {
        return get(self, item.nextValues, _salt, _value);
    }

    function getNextValue(Config storage self, OrderedUIntSet storage item, uint _value) internal view returns (uint) {
        return uint(getNextValue(self, item.innerSet, bytes32(_value)));
    }

    function getNextValue(Config storage self, OrderedAddressesSet storage item, address _value) internal view returns (address) {
        return address(getNextValue(self, item.innerSet, bytes32(_value)));
    }

    function getPreviousValue(Config storage self, OrderedSet storage item, bytes32 _value) internal view returns (bytes32) {
        return getPreviousValue(self, item, ORDERED_SET_IDENTIFIER, _value);
    }

    function getPreviousValue(Config storage self, OrderedSet storage item, bytes32 _salt, bytes32 _value) private view returns (bytes32) {
        return get(self, item.previousValues, _salt, _value);
    }

    function getPreviousValue(Config storage self, OrderedUIntSet storage item, uint _value) internal view returns (uint) {
        return uint(getPreviousValue(self, item.innerSet, bytes32(_value)));
    }

    function getPreviousValue(Config storage self, OrderedAddressesSet storage item, address _value) internal view returns (address) {
        return address(getPreviousValue(self, item.innerSet, bytes32(_value)));
    }

    function toBool(bytes32 self) internal pure returns (bool) {
        return self != bytes32(0);
    }

    function toBytes32(bool self) internal pure returns (bytes32) {
        return bytes32(self ? 1 : 0);
    }

    function toAddresses(bytes32[] memory self) internal pure returns (address[]) {
        address[] memory result = new address[](self.length);
        for (uint i = 0; i < self.length; i++) {
            result[i] = address(self[i]);
        }
        return result;
    }

    function toUInt(bytes32[] memory self) internal pure returns (uint[]) {
        uint[] memory result = new uint[](self.length);
        for (uint i = 0; i < self.length; i++) {
            result[i] = uint(self[i]);
        }
        return result;
    }

    function _setOrderedSetLink(Config storage self, Mapping storage link, bytes32 _salt, bytes32 from, bytes32 to) private {
        if (from != 0x0) {
            set(self, link, _salt, from, to);
        }
    }

    function _deleteOrderedSetLink(Config storage self, Mapping storage link, bytes32 _salt, bytes32 from) private {
        if (from != 0x0) {
            set(self, link, _salt, from, 0x0);
        }
    }

    /** @title Structure to incapsulate and organize iteration through different kinds of collections */
    struct Iterator {
        uint limit;
        uint valuesLeft;
        bytes32 currentValue;
        bytes32 anchorKey;
    }

    function listIterator(Config storage self, OrderedSet storage item, bytes32 anchorKey, bytes32 startValue, uint limit) internal view returns (Iterator) {
        if (startValue == 0x0) {
            return listIterator(self, item, anchorKey, limit);
        }

        return createIterator(anchorKey, startValue, limit);
    }

    function listIterator(Config storage self, OrderedUIntSet storage item, bytes32 anchorKey, uint startValue, uint limit) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, anchorKey, bytes32(startValue), limit);
    }

    function listIterator(Config storage self, OrderedAddressesSet storage item, bytes32 anchorKey, address startValue, uint limit) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, anchorKey, bytes32(startValue), limit);
    }

    function listIterator(Config storage self, OrderedSet storage item, uint limit) internal view returns (Iterator) {
        return listIterator(self, item, ORDERED_SET_IDENTIFIER, limit);
    }

    function listIterator(Config storage self, OrderedSet storage item, bytes32 anchorKey, uint limit) internal view returns (Iterator) {
        return createIterator(anchorKey, get(self, item.first, anchorKey), limit);
    }

    function listIterator(Config storage self, OrderedUIntSet storage item, uint limit) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, limit);
    }

    function listIterator(Config storage self, OrderedUIntSet storage item, bytes32 anchorKey, uint limit) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, anchorKey, limit);
    }

    function listIterator(Config storage self, OrderedAddressesSet storage item, uint limit) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, limit);
    }

    function listIterator(Config storage self, OrderedAddressesSet storage item, uint limit, bytes32 anchorKey) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, anchorKey, limit);
    }

    function listIterator(Config storage self, OrderedSet storage item) internal view returns (Iterator) {
        return listIterator(self, item, ORDERED_SET_IDENTIFIER);
    }

    function listIterator(Config storage self, OrderedSet storage item, bytes32 anchorKey) internal view returns (Iterator) {
        return listIterator(self, item, anchorKey, get(self, item.count, anchorKey));
    }

    function listIterator(Config storage self, OrderedUIntSet storage item) internal view returns (Iterator) {
        return listIterator(self, item.innerSet);
    }

    function listIterator(Config storage self, OrderedUIntSet storage item, bytes32 anchorKey) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, anchorKey);
    }

    function listIterator(Config storage self, OrderedAddressesSet storage item) internal view returns (Iterator) {
        return listIterator(self, item.innerSet);
    }

    function listIterator(Config storage self, OrderedAddressesSet storage item, bytes32 anchorKey) internal view returns (Iterator) {
        return listIterator(self, item.innerSet, anchorKey);
    }

    function listIterator(Config storage self, Bytes32OrderedSetMapping storage item, bytes32 _key) internal view returns (Iterator) {
        return listIterator(self, item.innerMapping, _key);
    }

    function listIterator(Config storage self, UIntOrderedSetMapping storage item, bytes32 _key) internal view returns (Iterator) {
        return listIterator(self, item.innerMapping, _key);
    }

    function listIterator(Config storage self, AddressOrderedSetMapping storage item, bytes32 _key) internal view returns (Iterator) {
        return listIterator(self, item.innerMapping, _key);
    }

    function createIterator(bytes32 anchorKey, bytes32 startValue, uint limit) internal pure returns (Iterator) {
        return Iterator({
            currentValue: startValue,
            limit: limit,
            valuesLeft: limit,
            anchorKey: anchorKey
        });
    }

    function getNextWithIterator(Config storage self, OrderedSet storage item, Iterator iterator) internal view returns (bytes32 _nextValue) {
        if (!canGetNextWithIterator(self, item, iterator)) { revert(); }

        _nextValue = iterator.currentValue;

        iterator.currentValue = getNextValue(self, item, iterator.anchorKey, iterator.currentValue);
        iterator.valuesLeft -= 1;
    }

    function getNextWithIterator(Config storage self, OrderedUIntSet storage item, Iterator iterator) internal view returns (uint _nextValue) {
        return uint(getNextWithIterator(self, item.innerSet, iterator));
    }

    function getNextWithIterator(Config storage self, OrderedAddressesSet storage item, Iterator iterator) internal view returns (address _nextValue) {
        return address(getNextWithIterator(self, item.innerSet, iterator));
    }

    function getNextWithIterator(Config storage self, Bytes32OrderedSetMapping storage item, Iterator iterator) internal view returns (bytes32 _nextValue) {
        return getNextWithIterator(self, item.innerMapping, iterator);
    }

    function getNextWithIterator(Config storage self, UIntOrderedSetMapping storage item, Iterator iterator) internal view returns (uint _nextValue) {
        return uint(getNextWithIterator(self, item.innerMapping, iterator));
    }

    function getNextWithIterator(Config storage self, AddressOrderedSetMapping storage item, Iterator iterator) internal view returns (address _nextValue) {
        return address(getNextWithIterator(self, item.innerMapping, iterator));
    }

    function canGetNextWithIterator(Config storage self, OrderedSet storage item, Iterator iterator) internal view returns (bool) {
        if (iterator.valuesLeft == 0 || !includes(self, item, iterator.anchorKey, iterator.currentValue)) {
            return false;
        }

        return true;
    }

    function canGetNextWithIterator(Config storage self, OrderedUIntSet storage item, Iterator iterator) internal view returns (bool) {
        return canGetNextWithIterator(self, item.innerSet, iterator);
    }

    function canGetNextWithIterator(Config storage self, OrderedAddressesSet storage item, Iterator iterator) internal view returns (bool) {
        return canGetNextWithIterator(self, item.innerSet, iterator);
    }

    function canGetNextWithIterator(Config storage self, Bytes32OrderedSetMapping storage item, Iterator iterator) internal view returns (bool) {
        return canGetNextWithIterator(self, item.innerMapping, iterator);
    }

    function canGetNextWithIterator(Config storage self, UIntOrderedSetMapping storage item, Iterator iterator) internal view returns (bool) {
        return canGetNextWithIterator(self, item.innerMapping, iterator);
    }

    function canGetNextWithIterator(Config storage self, AddressOrderedSetMapping storage item, Iterator iterator) internal view returns (bool) {
        return canGetNextWithIterator(self, item.innerMapping, iterator);
    }

    function count(Iterator iterator) internal pure returns (uint) {
        return iterator.valuesLeft;
    }
}

// File: @laborx/solidity-storage-contracts/contracts/StorageAdapter.sol

/**
 * Copyright 2017每2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.23;



contract StorageAdapter {

    using StorageInterface for *;

    StorageInterface.Config internal store;

    constructor(Storage _store, bytes32 _crate) public {
        store.init(_store, _crate);
    }
}

// File: contracts/common/Object.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned {
    /**
    *  Common result code. Means everything is fine.
    */
    uint constant OK = 1;
}

// File: @laborx/solidity-eventshistory-contracts/contracts/EventsHistorySourceAdapter.sol

/**
* Copyright 2017每2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.21;


/**
 * @title EventsHistory Source Adapter.
 */
contract EventsHistorySourceAdapter {

    // It is address of MultiEventsHistory caller assuming we are inside of delegate call.
    function _self()
    internal
    view
    returns (address)
    {
        return msg.sender;
    }
}

// File: contracts/escrow/erc20/ERC20ManagerEmitter.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


/// @title ERC20 Manager emitter contract
///
/// Contains all the original event emitting function definitions and events.
/// In case of new events needed later, additional emitters can be developed.
/// All the functions is meant to be called using delegatecall.
contract ERC20ManagerEmitter is EventsHistorySourceAdapter {
    
    event LogAddToken (
        address indexed self,
        address token,
        bytes32 name,
        bytes32 symbol,
        bytes32 url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    );

    event LogTokenChange (
        address indexed self,
        address oldToken,
        address token,
        bytes32 name,
        bytes32 symbol,
        bytes32 url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    );

    event LogRemoveToken (
        address indexed self,
        address token,
        bytes32 name,
        bytes32 symbol,
        bytes32 url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    );

    event Error(address indexed self, uint errorCode);

    function _emitLogAddToken (
        address token,
        bytes32 name,
        bytes32 symbol,
        bytes32 url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    ) internal {
        emit LogAddToken(_self(), token, name, symbol, url, decimals, ipfsHash, swarmHash);
    }

    function _emitLogTokenChange (
        address oldToken,
        address token,
        bytes32 name,
        bytes32 symbol,
        bytes32 url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    ) internal {
        emit LogTokenChange(_self(), oldToken, token, name, symbol, url, decimals, ipfsHash, swarmHash);
    }

    function _emitLogRemoveToken (
        address token,
        bytes32 name,
        bytes32 symbol,
        bytes32 url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    ) internal {
        emit LogRemoveToken(_self(), token, name, symbol, url, decimals, ipfsHash, swarmHash);
    }

    function _emitError(uint error) internal returns (uint) {
        emit Error(_self(), error);
        return error;
    }
}

// File: contracts/escrow/erc20/ERC20Manager.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;






contract ERC20TokenVerifier {
    function verify(address token) public view returns (bool);
}

/// @title ERC20Manager
///
/// @notice ERC20Manager contract which keeps track of all ERC20-based tokens
/// registered in a system.
contract ERC20Manager is ERC20ManagerEmitter, StorageAdapter, Object {

    uint constant ERROR_ERCMANAGER_INVALID_INVOCATION = 13000;
    uint constant ERROR_ERCMANAGER_TOKEN_SYMBOL_NOT_EXISTS = 13002;
    uint constant ERROR_ERCMANAGER_TOKEN_NOT_EXISTS = 13003;
    uint constant ERROR_ERCMANAGER_TOKEN_SYMBOL_ALREADY_EXISTS = 13004;
    uint constant ERROR_ERCMANAGER_TOKEN_ALREADY_EXISTS = 13005;
    uint constant ERROR_ERCMANAGER_TOKEN_UNCHANGED = 13006;

    StorageInterface.AddressesSet tokenAddresses;
    StorageInterface.Bytes32AddressMapping tokenBySymbol;
    StorageInterface.AddressBytes32Mapping name;
    StorageInterface.AddressBytes32Mapping symbol;
    StorageInterface.AddressBytes32Mapping url;
    StorageInterface.AddressBytes32Mapping ipfsHash;
    StorageInterface.AddressBytes32Mapping swarmHash;
    StorageInterface.AddressUIntMapping decimals;
    StorageInterface.Address tokenVerifier;

    constructor(address _storage, bytes32 _crate) public StorageAdapter(Storage(_storage), _crate) {
        tokenAddresses.init("tokenAddresses");
        tokenBySymbol.init("tokeBySymbol");
        name.init("name");
        symbol.init("symbol");
        url.init("url");
        ipfsHash.init("ipfsHash");
        swarmHash.init("swarmHash");
        decimals.init("decimals");
        tokenVerifier.init("tokenVerifier");
    }

    /// @notice Set ERC20 token verifier
    function setTokenVerifier(address _tokenVerifier) public onlyContractOwner {
        store.set(tokenVerifier, _tokenVerifier);
    }

    /// @notice Allows trusted account/constract to add a new token to the registry.
    /// @param _token Address of new token.
    /// @param _name Name of new token.
    /// @param _symbol Symbol for new token.
    /// @param _url Token's project URL.
    /// @param _decimals Number of decimals, divisibility of new token.
    /// @param _ipfsHash IPFS hash of token icon.
    /// @param _swarmHash Swarm hash of token icon.
    function addToken(
        address _token,
        bytes32 _name,
        bytes32 _symbol,
        bytes32 _url,
        uint8 _decimals,
        bytes32 _ipfsHash,
        bytes32 _swarmHash
    ) public returns (uint) {
        if (isTokenExists(_token)) {
            return _emitError(ERROR_ERCMANAGER_TOKEN_ALREADY_EXISTS);
        }

        if (isTokenSymbolExists(_symbol)) {
            return _emitError(ERROR_ERCMANAGER_TOKEN_SYMBOL_ALREADY_EXISTS);
        }

        if (!isTokenValid(_token)) {
            return _emitError(ERROR_ERCMANAGER_INVALID_INVOCATION);
        }

        store.add(tokenAddresses, _token);
        store.set(tokenBySymbol, _symbol, _token);
        store.set(name, _token, _name);
        store.set(symbol, _token, _symbol);
        store.set(url, _token, _url);
        store.set(decimals, _token, _decimals);
        store.set(ipfsHash, _token, _ipfsHash);
        store.set(swarmHash, _token, _swarmHash);

        _emitLogAddToken(_token, _name, _symbol, _url, _decimals, _ipfsHash, _swarmHash);
        return OK;
    }

    /// @notice Allows owner to alter a token
    /// @param _token Address of old token.
    /// @param _newToken Address of new token.
    /// @param _name Name of new token.
    /// @param _symbol Symbol for new token.
    /// @param _url Token's project URL.
    /// @param _decimals Number of decimals, divisibility of new token.
    /// @param _ipfsHash IPFS hash of token icon.
    /// @param _swarmHash Swarm hash of token icon.
    function setToken(
        address _token,
        address _newToken,
        bytes32 _name,
        bytes32 _symbol,
        bytes32 _url,
        uint8 _decimals,
        bytes32 _ipfsHash,
        bytes32 _swarmHash
    ) public onlyContractOwner returns (uint) {
        if (!isTokenExists(_token)) {
            return _emitError(ERROR_ERCMANAGER_TOKEN_NOT_EXISTS);
        }

        if (!isTokenValid(_newToken)) {
            return _emitError(ERROR_ERCMANAGER_INVALID_INVOCATION);
        }

        bool changed;
        if (_symbol != store.get(symbol, _token)) {
            if (store.get(tokenBySymbol, _symbol) == 0x0) {
                store.set(tokenBySymbol, store.get(symbol, _token), 0x0);

                if (_token != _newToken) {
                    store.set(tokenBySymbol, _symbol, _newToken);
                    store.set(symbol, _newToken, _symbol);
                } else {
                    store.set(tokenBySymbol,_symbol, _token);
                    store.set(symbol, _token, _symbol);
                }
                changed = true;
            } else {
                return _emitError(ERROR_ERCMANAGER_TOKEN_UNCHANGED);
            }
        }

        if (_token != _newToken) {
            ERC20Interface(_newToken).totalSupply();
            store.set(tokenAddresses, _token, _newToken);

            if(!changed) {
                store.set(tokenBySymbol, _symbol, _newToken);
                store.set(symbol, _newToken, _symbol);
            }
            store.set(name, _newToken, _name);
            store.set(url, _newToken, _url);
            store.set(decimals, _newToken, _decimals);
            store.set(ipfsHash, _newToken, _ipfsHash);
            store.set(swarmHash, _newToken, _swarmHash);
            _token = _newToken;
            changed = true;
        }

        if (store.get(name, _token) != _name) {
            store.set(name, _token, _name);
            changed = true;
        }

        if (store.get(decimals, _token) != _decimals) {
            store.set(decimals, _token, _decimals);
            changed = true;
        }

        if (store.get(url, _token) != _url) {
            store.set(url, _token, _url);
            changed = true;
        }

        if (store.get(ipfsHash, _token) != _ipfsHash) {
            store.set(ipfsHash, _token, _ipfsHash);
            changed = true;
        }

        if (store.get(swarmHash, _token) != _swarmHash) {
            store.set(swarmHash, _token, _swarmHash);
            changed = true;
        }

        if (changed) {
            _emitLogTokenChange(_token, _newToken, _name, _symbol, _url, _decimals, _ipfsHash, _swarmHash);
            return OK;
        }

        return _emitError(ERROR_ERCMANAGER_TOKEN_UNCHANGED);
    }

    /// @notice Allows CBE to remove an existing token from the registry.
    /// @param _token Address of existing token.
    function removeTokenByAddress(address _token) public onlyContractOwner returns (uint) {
        if (!isTokenExists(_token)) {
            return _emitError(ERROR_ERCMANAGER_TOKEN_NOT_EXISTS);
        }

        return removeToken(_token);
    }

    /// @notice Allows CBE to remove an existing token from the registry.
    /// @param _symbol Symbol of existing token.
    function removeTokenBySymbol(bytes32 _symbol) public onlyContractOwner returns (uint) {
        if (!isTokenSymbolExists(_symbol)) {
            return _emitError(ERROR_ERCMANAGER_TOKEN_SYMBOL_NOT_EXISTS);
        }

        return removeToken(store.get(tokenBySymbol,_symbol));
    }

    /// @notice Returns token's address by given id
    function getAddressById(uint _id) public  view returns (address) {
        return store.get(tokenAddresses, _id);
    }

    /// @notice Provides a registered token's address when given the token symbol.
    /// @param _symbol Symbol of registered token.
    /// @return Token's address.
    function getTokenAddressBySymbol(bytes32 _symbol) public view returns (address tokenAddress) {
        return store.get(tokenBySymbol, _symbol);
    }

    /// @notice Provides a registered token's metadata, looked up by address.
    /// @param _token Address of registered token.
    /// @return Token metadata.
    function getTokenMetaData(address _token) public view returns (
        address _tokenAddress,
        bytes32 _name,
        bytes32 _symbol,
        bytes32 _url,
        uint8 _decimals,
        bytes32 _ipfsHash,
        bytes32 _swarmHash
    ) {
        if (!isTokenExists(_token)) {
            return;
        }

        _name = store.get(name, _token);
        _symbol = store.get(symbol, _token);
        _url = store.get(url, _token);
        _decimals = uint8(store.get(decimals, _token));
        _ipfsHash = store.get(ipfsHash, _token);
        _swarmHash = store.get(swarmHash, _token);

        return (_token, _name, _symbol, _url, _decimals, _ipfsHash, _swarmHash);
    }

    /// @notice Returns count of registred ERC20 tokens
    /// @return token count
    function tokensCount() public view returns (uint) {
        return store.count(tokenAddresses);
    }

    /// @notice Returns an array containing all token addresses.
    /// @return Array of token addresses.
    function getTokenAddresses() public view returns (address[] _tokenAddresses) {
        _tokenAddresses = new address[](tokensCount());
        for (uint _tokenIdx = 0; _tokenIdx < _tokenAddresses.length; ++_tokenIdx) {
            _tokenAddresses[_tokenIdx] = getAddressById(_tokenIdx);
        }
    }

    /// @notice Provides details of a given tokens
    function getTokens(address[] _addresses) public view returns (
        address[] _tokensAddresses,
        bytes32[] _names,
        bytes32[] _symbols,
        bytes32[] _urls,
        uint8[] _decimalsArr,
        bytes32[] _ipfsHashes,
        bytes32[] _swarmHashes
    ) {
        if (_addresses.length == 0) {
            _addresses = getTokenAddresses();
        }
        _tokensAddresses = _addresses;
        _names = new bytes32[](_addresses.length);
        _symbols = new bytes32[](_addresses.length);
        _urls = new bytes32[](_addresses.length);
        _decimalsArr = new uint8[](_addresses.length);
        _ipfsHashes = new bytes32[](_addresses.length);
        _swarmHashes = new bytes32[](_addresses.length);

        for (uint i = 0; i < _addresses.length; i++) {
            _names[i] = store.get(name, _addresses[i]);
            _symbols[i] = store.get(symbol, _addresses[i]);
            _urls[i] = store.get(url, _addresses[i]);
            _decimalsArr[i] = uint8(store.get(decimals, _addresses[i]));
            _ipfsHashes[i] = store.get(ipfsHash, _addresses[i]);
            _swarmHashes[i] = store.get(swarmHash, _addresses[i]);
        }

        return (_tokensAddresses, _names, _symbols, _urls, _decimalsArr, _ipfsHashes, _swarmHashes);
    }

    /// @notice Provides a registered token's metadata, looked up by symbol.
    /// @param _symbol Symbol of registered token.
    /// @return Token metadata.
    function getTokenBySymbol(bytes32 _smbl) public view returns (
        address _tokenAddress,
        bytes32 _name,
        bytes32 _symbol,
        bytes32 _url,
        uint8 _decimals,
        bytes32 _ipfsHash,
        bytes32 _swarmHash
    ) {
        if (!isTokenSymbolExists(_smbl)) {
            return;
        }

        address _token = store.get(tokenBySymbol, _smbl);
        return getTokenMetaData(_token);
    }

    /// @notice Tells whether a given token exists or not
    function isTokenExists(address _token) public view returns (bool) {
        return store.includes(tokenAddresses, _token);
    }

    /// @notice Tells whether a given token exists or not
    function isTokenSymbolExists(bytes32 _symbol) public view returns (bool) {
        return (store.get(tokenBySymbol, _symbol) != address(0));
    }

    /// @notice Tells whether a given token valid or not
    function isTokenValid(address _token) public view returns (bool) {
        if (store.get(tokenVerifier) != 0x0) {
            ERC20TokenVerifier verifier = ERC20TokenVerifier(store.get(tokenVerifier));
            return verifier.verify(_token);
        }

        return true;
    }

    /// @notice Allows owner to remove an existing token from the registry.
    /// @param _token Address of existing token.
    function removeToken(address _token) internal returns (uint) {
        _emitLogRemoveToken(
            _token,
            store.get(name, _token),
            store.get(symbol, _token),
            store.get(url, _token),
            uint8(store.get(decimals, _token)),
            store.get(ipfsHash, _token),
            store.get(swarmHash, _token)
        );

        store.set(tokenBySymbol, store.get(symbol,_token), address(0));

        store.remove(tokenAddresses, _token);
        // TODO: ahiatsevich clean up url, decimals, ipfsHash, swarmHash

        return OK;
    }
}

// File: contracts/escrow/EscrowBaseInterface.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


interface EscrowBaseInterface {

	function hasCurrencySupport(bytes32 _symbol) public view returns (bool);

	function getServiceFeeInfo() external view returns (address, uint16, uint);
	function setServiceFee(uint16 _feeValue) external returns (uint);
	function setServiceFeeAddress(address _feeReceiver) external returns (uint);

	/// @notice Gets balance locked on escrow.
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @return currency symbol
    /// @return currence balance on escrow
    function getBalanceOf(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer
    ) external view returns (bytes32, uint);

	/// @notice Creates an escrow record for provided symbol "`_symbol`"
	/// @dev Escrow is reusable so the same tradeRecordId could be reused after an escrow
	///		with the same identifier is resolved.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _symbol symbol of payment currency
	/// @param _value amount to initially deposit to escrow; could be 0
	/// @param _transferImmediatelyToBuyerAmount amount to transfer immediately to a buyer
	/// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
	/// @return result code of an operation
	function createEscrow(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		bytes32 _symbol,
		uint _value,
		uint _transferImmediatelyToBuyerAmount,
		uint8 _feeStatus
	) external payable returns (uint);

	/// @notice Deposits to an escrow provided amount `_value`
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _value amount to deposit
	/// @param _transferImmediatelyToBuyerAmount amount to transfer immediately to a buyer
	/// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
	/// @return result code of an operation
	function deposit(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _value,
		uint _transferImmediatelyToBuyerAmount, // transfers _transferImmediatelyToBuyerAmount directly to _buyer.
		uint8 _feeStatus
	) external payable returns (uint);

	/// @notice Transfers `_value` from escrow to buyer `_buyer`
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller shoud sign hash of (message, escrow address, msg.sig, _value, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _value amount to withdraw from escrow
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _sellerSignature signature produced by seller
	/// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
	/// @return result code of an operation
	function releaseBuyerPayment(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _value,
		uint _expireAtBlock,
		uint _salt,
		bytes _sellerSignature,
		uint8 _feeStatus
	) external returns (uint);

	/// @notice Transfers `_value` from escrow to seller `_seller`
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Buyer shoud sign hash of (message, escrow address, msg.sig, _value, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _value amount to withdraw from escrow
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _buyerSignature signature produced by buyer
	/// @return result code of an operation
	function sendSellerPayback(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _value,
		uint _expireAtBlock,
		uint _salt,
		bytes _buyerSignature
	) external returns (uint);

	/// @notice Transfers `_value` from escrow to seller `_seller` and buyer `_buyer`
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _sellerValue, _buyerValue, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _sellerValue amount to withdraw from escrow to the seller
	/// @param _buyerValue amount to withdraw from escrow to the buyer
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _signatures concatenated signatures produced by seller and buyer
	/// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
	/// @return result code of an operation
	function releaseNegotiatedPayment(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _sellerValue,
		uint _buyerValue,
		uint _expireAtBlock,
		uint _salt,
		bytes _signatures,
		uint8 _feeStatus
	) external returns (uint);

	/// @notice Starts a dispute process between seller `_seller` and buyer `_buyer`.
	/// 	Could start only if an arbiter was specified.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _signature signature of an initiator
	/// @return result code of an operation
	function initiateDispute(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _expireAtBlock,
		uint _salt,
		bytes _signature
	) external returns (uint);

	/// @notice Cancels an initiated dispute process
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _signature signature of an initiator
	/// @return result code of an operation
	function cancelDispute(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _expireAtBlock,
		uint _salt,
		bytes _signature
	) external returns (uint);

	/// @notice Transfers disputed value from escrow to the seller `_seller` and the buyer `_buyer` according
	/// 	to provided buyer value `_buyerValue`. The value of escrow - _buyerValue will be transferred to the seller.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Arbiter should sign hash of (message, escrow address, msg.sig, _buyerValue, _expireAtBlock) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _buyerValue value that will be transferred to the buyer
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _arbiterSignature signature of an arbiter
	/// @return result code of an operation
	function releaseDisputedPayment(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		uint _buyerValue,
		uint _expireAtBlock,
		bytes _arbiterSignature
	) external returns (uint);

	/// @notice Deletes escrow record when it is no more needed.
    ///     Escrow should be empty to be deleted.
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    function deleteEscrow(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer
    ) external returns (uint);

	function getArbiter(bytes32 _tradeRecordId, address _seller, address _buyer) external view returns (address);

	/// @notice Sets a new arbiter `_arbiter`. His address should be approved by both parties.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _arbiter, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _bothSignatures signatures of seller and buyer
	function setArbiter(
		bytes32 _tradeRecordId,
		address _seller,
		address _buyer,
		address _arbiter,
		uint _expireAtBlock,
		uint _salt,
		bytes _bothSignatures
	) external returns (uint);

	/// @notice Performs transfer of a currency `_symbol`
	///		from a `msg.sender` to service fee recepient
	/// @param _symbol target currency symbol
	/// @param _from holder address of the `_symbol`
	/// @param _amount amount to retransfer
	/// @return result code of an operation
	function retranslateToFeeRecipient(bytes32 _symbol, address _from, uint _amount) external payable returns (uint);
}

// File: contracts/common/Signatures.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


library Signatures {

    bytes constant internal SIGNATURE_PREFIX = "\x19Ethereum Signed Message:\n32";
    uint constant internal SIGNATURE_LENGTH = 65;

    function getSignerFromSignature(bytes32 _message, bytes _signature)
    public
    pure
    returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_signature.length != SIGNATURE_LENGTH) {
            return 0;
        }

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := and(mload(add(_signature, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(
            keccak256(abi.encodePacked(SIGNATURE_PREFIX, _message)),
            v,
            r,
            s
        );
    }

    /// @notice Get signers from signatures byte array.
    /// @param _message message hash
    /// @param _signatures signatures
    /// @return addresses of signers
    function getSignersFromSignatures(bytes32 _message, bytes _signatures)
    public
    pure
    returns (address[] memory _addresses)
    {
        require(validSignaturesLength(_signatures), "SIGNATURES_SHOULD_HAVE_CORRECT_LENGTH");
        _addresses = new address[](numSignatures(_signatures));
        for (uint i = 0; i < _addresses.length; i++) {
            _addresses[i] = getSignerFromSignature(_message, signatureAt(_signatures, i));
        }
    }

    function numSignatures(bytes _signatures)
    private
    pure
    returns (uint256)
    {
        return _signatures.length / SIGNATURE_LENGTH;
    }

    function validSignaturesLength(bytes _signatures)
    internal
    pure
    returns (bool)
    {
        return (_signatures.length % SIGNATURE_LENGTH) == 0;
    }

    function signatureAt(bytes _signatures, uint position)
    private
    pure
    returns (bytes)
    {
        return slice(_signatures, position * SIGNATURE_LENGTH, SIGNATURE_LENGTH);
    }

    function bytesToBytes4(bytes memory source)
    private
    pure
    returns (bytes4 output) {
        if (source.length == 0) {
            return 0x0;
        }
        assembly {
            output := mload(add(source, 4))
        }
    }

    function slice(bytes _bytes, uint _start, uint _length)
    private
    pure
    returns (bytes)
    {
        require(_bytes.length >= (_start + _length), "SIGNATURES_SLICE_SIZE_SHOULD_NOT_OVERTAKE_BYTES_LENGTH");

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

}

// File: contracts/common/access/Context.sol

pragma solidity ^0.4.25;

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

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/common/access/Roles.sol

pragma solidity ^0.4.25;

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

// File: contracts/common/access/roles/WhitelistAdminRole.sol

pragma solidity ^0.4.25;



/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Context {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: contracts/common/access/roles/WhitelistedRole.sol

pragma solidity ^0.4.25;




/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is Context, WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(_msgSender()), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(_msgSender());
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

// File: contracts/common/Relayed.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;




contract Relayed is Object, WhitelistedRole {

    uint private whitelistedCount;

    event RelayTransferred(address indexed previousRelay, address indexed newRelay);

    /// @dev Throws if called by any account other than the relay.
    modifier onlyRelay() {
        require(!isActivatedRelay() || isWhitelisted(msg.sender), "RELAY_ONLY");
        _;
    }

    function isActivatedRelay() public view returns (bool) {
        return whitelistedCount != 0;
    }

    function _addWhitelisted(address account) internal {
        super._addWhitelisted(account);
        whitelistedCount = whitelistedCount + 1;
    }

    function _removeWhitelisted(address account) internal {
        super._removeWhitelisted(account);
        whitelistedCount = whitelistedCount - 1;
    }
}

// File: contracts/escrow/EscrowBase.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


contract EscrowBase {

    mapping(bytes32 => bool) internal _saltWithEscrow2flagMapping;

    /// @notice Gets balance locked on escrow.
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @return currency symbol
    /// @return currence balance on escrow
    function getBalanceOf(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer
    )
    external
    view
    returns (bytes32, uint)
    {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        return (_getEscrowSymbol(_escrowHash), _getEscrowValue(_escrowHash));
    }

    /// @notice  Hashes the values and returns the escrow hash.
    /// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
    /// @return returns escrow hash
    function _getEscrowHash(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer
    )
    internal
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_tradeRecordId, _seller, _buyer));
    }

    function _getEncodedSaltWithEscrowHash(uint _salt, bytes32 _escrowHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_salt, _escrowHash));
    }

    function _getEscrowExists(bytes32 _escrowHash) internal view returns (bool);

    function _getEscrowDisputed(bytes32 _escrowHash) internal view returns (bool);

    function _getEscrowSymbol(bytes32 _escrowHash) internal view returns (bytes32);

    function _getEscrowValue(bytes32 _escrowHash) internal view returns (uint);

    function _getEscrowArbiter(bytes32 _escrowHash) internal view returns (address);
}

// File: contracts/escrow/DisputedEmitter.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


contract DisputedEmitter {
    event DisputeRequested(bytes32 indexed tradeHash, address arbiter);
    event DisputeCanceled(bytes32 indexed tradeHash);
    event ArbiterTransferred(bytes32 indexed tradeHash, address arbiter);

    function _emitDisputeRequested(bytes32 _tradeHash, address _arbiter) internal {
        emit DisputeRequested(_tradeHash, _arbiter);
    }

    function _emitDisputeCanceled(bytes32 _tradeHash) internal {
        emit DisputeCanceled(_tradeHash);
    }

    function _emitArbiterTransferred(bytes32 _tradeHash, address _arbiter) internal {
        emit ArbiterTransferred(_tradeHash, _arbiter);
    }
}

// File: contracts/escrow/Disputed.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;





contract Disputed is
    Relayed,
    EscrowBase,
    DisputedEmitter
{
    mapping(bytes32 => address) internal _disputeInitiators;

    /// @notice Starts a dispute process between seller `_seller` and buyer `_buyer`.
	/// 	Could start only if an arbiter was specified.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _signature signature of an initiator
	/// @return result code of an operation
    function initiateDispute(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    external
    onlyRelay
    returns (uint)
    {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        bytes32 _encodedSaltWithEscrow = _getEncodedSaltWithEscrowHash(_salt, _escrowHash);
        require(_getEscrowExists(_escrowHash), "DISPUTED_ESCROW_SHOULD_EXIST");
        require(!_getEscrowDisputed(_escrowHash), "DISPUTED_ESCROW_SHOULD_NOT_BE_DISPUTED");
        address _arbiter = _getEscrowArbiter(_escrowHash);
        require(_arbiter != address(0), "DISPUTED_ARBITER_SHOULD_NOT_BE_EMPTY");
        require(!_saltWithEscrow2flagMapping[_encodedSaltWithEscrow], "DISPUTED_SUCH_SALT_SHOULD_NOT_EXIST");
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _expireAtBlock,
            _salt
        );
        address _signer = Signatures.getSignerFromSignature(keccak256(_message), _signature);
        require(_signer == _seller || _signer == _buyer, "DISPUTED_SIGNER_SHOULD_BE_BUYER_OR_SELLER");
        require(block.number < _expireAtBlock, "DISPUTED_TX_SHOULD_NOT_BE_EXPIRED");

        _saltWithEscrow2flagMapping[_encodedSaltWithEscrow] = true;
        _disputeInitiators[_escrowHash] = _signer;
        _setEscrowDisputed(_escrowHash, true);
        _emitDisputeRequested(_escrowHash, _arbiter);

        return OK;
    }

    /// @notice Cancels an initiated dispute process
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _signature signature of an initiator
	/// @return result code of an operation
    function cancelDispute(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    external
    onlyRelay
    returns (uint)
    {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        bytes32 _encodedSaltWithEscrow = _getEncodedSaltWithEscrowHash(_salt, _escrowHash);
        require(_getEscrowExists(_escrowHash), "DISPUTED_ESCROW_SHOULD_EXIST");
        require(_getEscrowDisputed(_escrowHash), "DISPUTED_ESCROW_SHOULD_BE_DISPUTED");
        require(!_saltWithEscrow2flagMapping[_encodedSaltWithEscrow], "DISPUTED_SUCH_SALT_SHOULD_NOT_EXIST");
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _expireAtBlock,
            _salt
        );
        address _signer = Signatures.getSignerFromSignature(keccak256(_message), _signature);
        require(_signer == _disputeInitiators[_escrowHash], "DISPUTED_SIGNER_SHOULD_BE_DISPUTE_INITIATOR");
        require(block.number < _expireAtBlock, "DISPUTED_TX_SHOULD_NOT_BE_EXPIRED");

        _saltWithEscrow2flagMapping[_encodedSaltWithEscrow] = true;
        _setEscrowDisputed(_escrowHash, false);
        delete _disputeInitiators[_escrowHash];
        _emitDisputeCanceled(_escrowHash);

        return OK;
    }

    /// @notice Transfers disputed value from escrow to the seller `_seller` and the buyer `_buyer` according
	/// 	to provided buyer value `_buyerValue`. The value of escrow - _buyerValue will be transferred to the seller.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Arbiter should sign hash of (message, escrow address, msg.sig, _buyerValue, _expireAtBlock) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _buyerValue value that will be transferred to the buyer
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _arbiterSignature signature of an arbiter
	/// @return result code of an operation
    function releaseDisputedPayment(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _buyerValue,
        uint _expireAtBlock,
        bytes _arbiterSignature
        ) external returns (uint);

    function getArbiter(bytes32 _tradeRecordId, address _seller, address _buyer) external view returns (address) {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        return _getEscrowArbiter(_escrowHash);
    }

    /// @notice Sets a new arbiter `_arbiter`. His address should be approved by both parties.
	/// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
	/// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _arbiter, _expireAtBlock, _salt) data
	/// @param _tradeRecordId identifier of escrow record
	/// @param _seller who will mainly deposit to escrow
	/// @param _buyer who will eventually is going to receive payment
	/// @param _expireAtBlock expiry block after which transaction will be invalid
	/// @param _salt random bytes to identify signed data
	/// @param _bothSignatures signatures of seller and buyer
    function setArbiter(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        address _arbiter,
        uint _expireAtBlock,
        uint _salt,
        bytes _bothSignatures
    )
    external
    onlyRelay
    returns (uint)
    {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        bytes32 _encodedSaltWithEscrow = _getEncodedSaltWithEscrowHash(_salt, _escrowHash);
        require(_getEscrowExists(_escrowHash), "DISPUTED_ESCROW_SHOULD_EXIST");
        require(!_saltWithEscrow2flagMapping[_encodedSaltWithEscrow], "DISPUTED_SUCH_SALT_SHOULD_NOT_EXIST");
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _arbiter,
            _expireAtBlock,
            _salt
        );
        address[] memory _signers = Signatures.getSignersFromSignatures(keccak256(_message), _bothSignatures);
        require(
            _signers.length == 2 &&
            (
                (_signers[0] == _seller && _signers[1] == _buyer) ||
                (_signers[0] == _buyer && _signers[1] == _seller)
            ),
            "DISPUTED_SIGNERS_SHOULD_BE_BUYER_AND_SELLER");
        require(block.number < _expireAtBlock, "DISPUTED_TX_SHOULD_NOT_BE_EXPIRED");

        _saltWithEscrow2flagMapping[_encodedSaltWithEscrow] = true;
        _setEscrowArbiter(_escrowHash, _arbiter);
        _emitArbiterTransferred(_escrowHash, _arbiter);

        return OK;
    }

    function _setEscrowDisputed(bytes32 _escrowHash, bool _disputeStatus) internal;

    function _setEscrowArbiter(bytes32 _escrowHash, address _arbiter) internal;
}

// File: contracts/escrow/FeeApplicable.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


contract FeeApplicable is Object {

    uint constant MAX_FEE = 100; // 100 = 1%
    uint constant FEE_PRECISION = 10000; // Fee calculation: value * (fee / FEE_PRECISION)

    address private _serviceFeeAddress;
    uint16 private _serviceFee;

    modifier onlyFeeAdmin {
        require(_isFeeAdmin(msg.sender), "AF_IC"); // AF_IC == applicable fee invalid caller
        _;
    }

    function getServiceFeeInfo() public view returns (address, uint16, uint) {
        return (_serviceFeeAddress, _serviceFee, FEE_PRECISION);
    }

    function setServiceFee(uint16 _feeValue) external onlyFeeAdmin returns (uint) {
        require(_feeValue <= MAX_FEE, "AF_IV"); // AF_IV == applicable fee invalid fee value
        _serviceFee = _feeValue;
    }

    function setServiceFeeAddress(address _feeReceiver) external onlyFeeAdmin returns (uint) {
        _serviceFeeAddress = _feeReceiver;
    }

    function _isFeeAdmin(address _account) internal view returns (bool);
}

// File: contracts/escrow/EscrowEmitter.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


contract EscrowEmitter {
    event Created(bytes32 indexed tradeHash, bytes32 symbol, uint value);
    event Deposited(bytes32 indexed tradeHash, bytes32 symbol, uint value);
    event ReleasedPayment(bytes32 indexed tradeHash, bytes32 symbol, uint value);
    event Payback(bytes32 indexed tradeHash, bytes32 symbol, uint value);

    function _emitCreated(bytes32 _tradeHash, bytes32 _symbol, uint _value) internal {
        emit Created(_tradeHash, _symbol, _value);
    }

    function _emitDeposited(bytes32 _tradeHash, bytes32 _symbol, uint _value) internal {
        emit Deposited(_tradeHash, _symbol, _value);
    }

    function _emitReleasedPayment(bytes32 _tradeHash, bytes32 _symbol, uint _value) internal {
        emit ReleasedPayment(_tradeHash, _symbol, _value);
    }

    function _emitPayback(bytes32 _tradeHash, bytes32 _symbol, uint _value) internal {
        emit Payback(_tradeHash, _symbol, _value);
    }
}

// File: contracts/libs/Bits.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


library Bits {

    uint constant internal ONE = uint(1);
    uint constant internal ONES = uint(~0);

    // Sets the bit at the given 'index' in 'self' to '1'.
    // Returns the modified value.
    function setBit(uint self, uint8 index) internal pure returns (uint) {
        return self | ONE << index;
    }

    // Sets the bit at the given 'index' in 'self' to '0'.
    // Returns the modified value.
    function clearBit(uint self, uint8 index) internal pure returns (uint) {
        return self & ~(ONE << index);
    }

    // Sets the bit at the given 'index' in 'self' to:
    //  '1' - if the bit is '0'
    //  '0' - if the bit is '1'
    // Returns the modified value.
    function toggleBit(uint self, uint8 index) internal pure returns (uint) {
        return self ^ ONE << index;
    }

    // Get the value of the bit at the given 'index' in 'self'.
    function bit(uint self, uint8 index) internal pure returns (uint8) {
        return uint8(self >> index & 1);
    }

    // Check if the bit at the given 'index' in 'self' is set.
    // Returns:
    //  'true' - if the value of the bit is '1'
    //  'false' - if the value of the bit is '0'
    function bitSet(uint self, uint8 index) internal pure returns (bool) {
        return self >> index & 1 == 1;
    }

    // Checks if the bit at the given 'index' in 'self' is equal to the corresponding
    // bit in 'other'.
    // Returns:
    //  'true' - if both bits are '0' or both bits are '1'
    //  'false' - otherwise
    function bitEqual(uint self, uint other, uint8 index) internal pure returns (bool) {
        return (self ^ other) >> index & 1 == 0;
    }

    // Get the bitwise NOT of the bit at the given 'index' in 'self'.
    function bitNot(uint self, uint8 index) internal pure returns (uint8) {
        return uint8(1 - (self >> index & 1));
    }

    // Computes the bitwise AND of the bit at the given 'index' in 'self', and the
    // corresponding bit in 'other', and returns the value.
    function bitAnd(uint self, uint other, uint8 index) internal pure returns (uint8) {
        return uint8((self & other) >> index & 1);
    }

    // Computes the bitwise OR of the bit at the given 'index' in 'self', and the
    // corresponding bit in 'other', and returns the value.
    function bitOr(uint self, uint other, uint8 index) internal pure returns (uint8) {
        return uint8((self | other) >> index & 1);
    }

    // Computes the bitwise XOR of the bit at the given 'index' in 'self', and the
    // corresponding bit in 'other', and returns the value.
    function bitXor(uint self, uint other, uint8 index) internal pure returns (uint8) {
        return uint8((self ^ other) >> index & 1);
    }

    // Gets 'numBits' consecutive bits from 'self', starting from the bit at 'startIndex'.
    // Returns the bits as a 'uint'.
    // Requires that:
    //  - '0 < numBits <= 256'
    //  - 'startIndex < 256'
    //  - 'numBits + startIndex <= 256'
    function bits(uint self, uint8 startIndex, uint16 numBits) internal pure returns (uint) {
        require(0 < numBits && startIndex < 256 && startIndex + numBits <= 256);
        return self >> startIndex & ONES >> 256 - numBits;
    }

    // Computes the index of the highest bit set in 'self'.
    // Returns the highest bit set as an 'uint8'.
    // Requires that 'self != 0'.
    function highestBitSet(uint self) internal pure returns (uint8 highest) {
        require(self != 0);
        uint val = self;
        for (uint8 i = 128; i >= 1; i >>= 1) {
            if (val & (ONE << i) - 1 << i != 0) {
                highest += i;
                val >>= i;
            }
        }
    }

    // Computes the index of the lowest bit set in 'self'.
    // Returns the lowest bit set as an 'uint8'.
    // Requires that 'self != 0'.
    function lowestBitSet(uint self) internal pure returns (uint8 lowest) {
        require(self != 0);
        uint val = self;
        for (uint8 i = 128; i >= 1; i >>= 1) {
            if (val & (ONE << i) - 1 == 0) {
                lowest += i;
                val >>= i;
            }
        }
    }

}

// File: contracts/common/FeeConstants.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;



contract FeeConstants {

    using Bits for uint8;

    uint8 constant SELLER_FLAG_BIT_IDX = 0;
    uint8 constant BUYER_FLAG_BIT_IDX = 1;

    function _getSellerFeeFlag() internal pure returns (uint8 _feeStatus) {
        return uint8(_feeStatus.setBit(SELLER_FLAG_BIT_IDX));
    }

    function _getBuyerFeeFlag() internal pure returns (uint8 _feeStatus) {
        return uint8(_feeStatus.setBit(BUYER_FLAG_BIT_IDX));
    }

    function _getAllFeeFlag() internal pure returns (uint8 _feeStatus) {
        return uint8(uint8(_feeStatus
            .setBit(SELLER_FLAG_BIT_IDX))
            .setBit(BUYER_FLAG_BIT_IDX));
    }

    function _getNoFeeFlag() internal pure returns (uint8 _feeStatus) {
        return 0;
    }

    function _isFeeFlagAppliedFor(uint8 _feeStatus, uint8 _userBit) internal pure returns (bool) {
        return _feeStatus.bitSet(_userBit);
    }
}

// File: contracts/libs/SafeMath.sol

/**
* Copyright 2017每2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.25;


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b, "SAFE_MATH_MUL");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SAFE_MATH_SUB");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SAFE_MATH_ADD");
        return c;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }
}

// File: contracts/libs/PercentCalculator.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;



library PercentCalculator {

    using SafeMath for uint;

    function getPercent(
        uint _value,
        uint _percent,
        uint _precision
    )
    internal
    pure
    returns (uint)
    {
        return _value.mul(_percent).div(_precision);
    }

    function getValueWithPercent(
        uint _value,
        uint _percent,
        uint _precision
    )
    internal
    pure
    returns (uint)
    {
        return _value.add(getPercent(_value, _percent, _precision));
    }

    function getFullValueFromPercentedValue(
        uint _value,
        uint _percent,
        uint _precision
    )
    internal
    pure
    returns (uint)
    {
        return _value.mul(_precision).div(_percent);
    }
}

// File: contracts/escrow/EscrowERC20.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;













contract EscrowERC20 is
    EscrowBaseInterface,
    Disputed,
    FeeApplicable,
    EscrowEmitter,
    FeeConstants,
    ERC223ReceivingInterface
{
    using SafeMath for uint;

    ERC20Manager public erc20Manager;

    mapping(bytes32 => Escrow) private escrows;
    mapping(address => uint) private token2accumulatedFeeMapping;

    struct Escrow {
        bool exists;
        bool disputed;
        bytes32 symbol;
        uint value;
        address arbiter;
    }

    constructor(address _erc20Manager) public {
        erc20Manager = ERC20Manager(_erc20Manager);
    }

    function() external payable {
        revert("ESCROW_ERC20_DOES_NOT_SUPPORT_ETH");
    }

    /// @dev Standard ERC223 function that will handle incoming token transfers.
    function tokenFallback(address /* _from */, uint /* _value */, bytes /* _data */) external {
        require(erc20Manager.isTokenExists(msg.sender), "ESCROW_ERC20_CURRENCY_SHOULD_BE_SUPPORTED");
    }

    function getFeeBalance(address[] _tokens) public view returns (uint[] _balances) {
        _balances = new uint[](_tokens.length);

        for (uint _tokenIdx = 0; _tokenIdx < _tokens.length; _tokenIdx++) {
            _balances[_tokenIdx] = token2accumulatedFeeMapping[_tokens[_tokenIdx]];
        }
    }

    /// @notice Creates an escrow record for provided symbol "`_symbol`"
    /// @dev Escrow is reusable so the same tradeRecordId could be reused after an escrow
    ///		with the same identifier is resolved.
    /// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @param _symbol symbol of payment currency
    /// @param _value amount to initially deposit to escrow; could be 0
    /// @param _transferImmediatelyToBuyerAmount amount to transfer immediately to a buyer
    /// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
    /// @return result code of an operation
    function createEscrow(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        bytes32 _symbol,
        uint _value,
        uint _transferImmediatelyToBuyerAmount,
        uint8 _feeStatus
    ) external payable onlyRelay returns (uint) {
        require(msg.value == 0, "ESCROW_ERC20_DOES_NOT_SUPPORT_ETH");
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        require(!_escrow.exists, "ESCROW_ERC20_ESCROW_SHOULD_NOT_EXIST");
        require(hasCurrencySupport(_symbol), "ESCROW_ERC20_CURRENCY_SHOULD_BE_SUPPORTED");

        uint _valueWithoutFee = _value;
        if (_value > 0) {
            ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_symbol));
            require(_token.allowance(_seller, address(this)) >= _value && _value >= _transferImmediatelyToBuyerAmount, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");
            _token.transferFrom(_seller, address(this), _value);

            _valueWithoutFee = _takeDepositFee(_token, _value, _feeStatus);
            if (_transferImmediatelyToBuyerAmount > 0) {
                //send upfront to buyer
                _valueWithoutFee = _valueWithoutFee.sub(_transferImmediatelyToBuyerAmount);
                uint _transferImmediatelyToBuyerAmountWithoutFee = _takeWithdrawalFee(_token, _transferImmediatelyToBuyerAmount, _feeStatus);
                _token.transfer(_buyer, _transferImmediatelyToBuyerAmountWithoutFee);
            }
        }
        escrows[_escrowHash] = Escrow(true, false, _symbol, _valueWithoutFee, address(0));
        _emitCreated(_escrowHash, _symbol, _valueWithoutFee);

        return OK;
    }

    /// @notice Deposits to an escrow provided amount `_value`
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @param _value amount to deposit
    /// @param _transferImmediatelyToBuyerAmount amount to transfer immediately to a buyer
    /// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
    /// @return result code of an operation
    function deposit(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _value,
        uint _transferImmediatelyToBuyerAmount, // transfers _transferImmediatelyToBuyerAmount directly to _buyer.
        uint8 _feeStatus
    ) external payable onlyRelay returns (uint) {
        require(msg.value == 0, "ESCROW_ERC20_DOES_NOT_SUPPORT_ETH");
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        require(_escrow.exists, "ESCROW_ERC20_ESCROW_SHOULD_EXIST");
        require(!_escrow.disputed, "ESCROW_ERC20_ESCROW_SHOULD_NOT_BE_DISPUTED");

        ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_escrow.symbol));
        require(_value > 0 && _token.allowance(_seller, address(this)) >= _value &&
            _value >= _transferImmediatelyToBuyerAmount, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");
        _token.transferFrom(_seller, address(this), _value);

        uint _valueWithoutFee = _takeDepositFee(_token, _value, _feeStatus);
        if (_transferImmediatelyToBuyerAmount > 0) {
            //send upfront to buyer
            _valueWithoutFee = _valueWithoutFee.sub(_transferImmediatelyToBuyerAmount);
            uint _transferImmediatelyToBuyerAmountWithoutFee = _takeWithdrawalFee(_token, _transferImmediatelyToBuyerAmount, _feeStatus);
            _token.transfer(_buyer, _transferImmediatelyToBuyerAmountWithoutFee);
        }
        _escrow.value = _escrow.value.add(_valueWithoutFee);
        _emitDeposited(_escrowHash, _escrow.symbol, _valueWithoutFee);

        return OK;
    }

    /// @notice Transfers `_value` from escrow to buyer `_buyer`
    /// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
    /// @dev Seller shoud sign hash of (message, escrow address, msg.sig, _value, _expireAtBlock, _salt) data
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @param _value amount to withdraw from escrow
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _salt random bytes to identify signed data
    /// @param _sellerSignature signature produced by seller
    /// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
    /// @return result code of an operation
    function releaseBuyerPayment(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _sellerSignature,
        uint8 _feeStatus
    ) external onlyRelay returns (uint) {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        bytes32 _encodedSaltWithEscrow = _getEncodedSaltWithEscrowHash(_salt, _escrowHash);
        require(_escrow.exists, "ESCROW_ERC20_ESCROW_SHOULD_EXIST");
        require(!_escrow.disputed, "ESCROW_ERC20_ESCROW_SHOULD_NOT_BE_DISPUTED");
        require(!_saltWithEscrow2flagMapping[_encodedSaltWithEscrow], "ESCROW_ERC20_SUCH_SALT_SHOULD_NOT_EXIST");
        _assertSeller(_escrowHash, _seller, _value, _expireAtBlock, _salt, _sellerSignature);
        require(block.number < _expireAtBlock, "ESCROW_ERC20_TX_SHOULD_NOT_BE_EXPIRED");
        require(_escrow.value >= _value && _value > 0, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");

        _saltWithEscrow2flagMapping[_encodedSaltWithEscrow] = true;
        _escrow.value = _escrow.value.sub(_value);
        ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_escrow.symbol));
        uint _valueWithoutFee = _takeWithdrawalFee(_token, _value, _feeStatus);
        _token.transfer(_buyer, _valueWithoutFee);
        _emitReleasedPayment(_escrowHash, _escrow.symbol, _valueWithoutFee);

        return OK;
    }

    function _assertSeller(
        bytes32 _escrowHash,
        address _seller,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _sellerSignature
    )
    private
    view
    {
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _value,
            _expireAtBlock,
            _salt
        );
        address _signer = Signatures.getSignerFromSignature(keccak256(_message), _sellerSignature);
        require(_signer == _seller, "ESCROW_ERC20_SIGNER_SHOULD_BE_SELLER");
    }

    /// @notice Transfers `_value` from escrow to seller `_seller`
    /// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
    /// @dev Buyer shoud sign hash of (message, escrow address, msg.sig, _value, _expireAtBlock, _salt) data
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @param _value amount to withdraw from escrow
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _salt random bytes to identify signed data
    /// @param _buyerSignature signature produced by buyer
    /// @return result code of an operation
    function sendSellerPayback(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _buyerSignature
    ) external onlyRelay returns (uint) {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        bytes32 _encodedSaltWithEscrow = _getEncodedSaltWithEscrowHash(_salt, _escrowHash);
        require(_escrow.exists, "ESCROW_ERC20_ESCROW_SHOULD_EXIST");
        require(!_escrow.disputed, "ESCROW_ERC20_ESCROW_SHOULD_NOT_BE_DISPUTED");
        require(!_saltWithEscrow2flagMapping[_encodedSaltWithEscrow], "ESCROW_ERC20_SUCH_SALT_SHOULD_NOT_EXIST");
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _value,
            _expireAtBlock,
            _salt
        );
        address _signer = Signatures.getSignerFromSignature(keccak256(_message), _buyerSignature);
        require(_signer == _buyer, "ESCROW_ERC20_SIGNER_SHOULD_BE_BUYER");
        require(block.number < _expireAtBlock, "ESCROW_ERC20_TX_SHOULD_NOT_BE_EXPIRED");
        require(_escrow.value >= _value && _value > 0, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");

        _saltWithEscrow2flagMapping[_encodedSaltWithEscrow] = true;
        _escrow.value = _escrow.value.sub(_value);
        ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_escrow.symbol));
        _token.transfer(_seller, _value);
        _emitPayback(_escrowHash, _escrow.symbol, _value);

        return OK;
    }

    /// @notice Transfers `_value` from escrow to seller `_seller` and buyer `_buyer`
    /// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
    /// @dev Seller and buyer shoud sign hash of (message, escrow address, msg.sig, _sellerValue, _buyerValue, _expireAtBlock, _salt) data
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @param _sellerValue amount to withdraw from escrow to the seller
    /// @param _buyerValue amount to withdraw from escrow to the buyer
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _salt random bytes to identify signed data
    /// @param _signatures concatenated signatures produced by seller and buyer
    /// @param _feeStatus fee condition (1st bit - seller, 2nd - buyer)
    /// @return result code of an operation
    function releaseNegotiatedPayment(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _sellerValue,
        uint _buyerValue,
        uint _expireAtBlock,
        uint _salt,
        bytes _signatures,
        uint8 _feeStatus
    ) external onlyRelay returns (uint) {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        require(_escrow.exists, "ESCROW_ERC20_ESCROW_SHOULD_EXIST");
        require(!_escrow.disputed, "ESCROW_ERC20_ESCROW_SHOULD_NOT_BE_DISPUTED");
        require(!_saltWithEscrow2flagMapping[_getEncodedSaltWithEscrowHash(_salt, _escrowHash)], "ESCROW_ERC20_SUCH_SALT_SHOULD_NOT_EXIST");
        _assertSellerAndBuyer(_escrowHash, _seller, _buyer, _sellerValue, _buyerValue, _expireAtBlock, _salt, _signatures);
        require(block.number < _expireAtBlock, "ESCROW_ERC20_TX_SHOULD_NOT_BE_EXPIRED");
        require(_escrow.value >= _sellerValue.add(_buyerValue) && _sellerValue.add(_buyerValue) > 0, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");

        _saltWithEscrow2flagMapping[_getEncodedSaltWithEscrowHash(_salt, _escrowHash)] = true;
        _escrow.value = _escrow.value.sub(_sellerValue.add(_buyerValue));
        ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_escrow.symbol));
        _token.transfer(_seller, _sellerValue);
        uint _buyerValueWithoutFee = _takeWithdrawalFee(_token, _buyerValue, _feeStatus);
        _token.transfer(_buyer, _buyerValueWithoutFee);
        _emitPayback(_escrowHash, _escrow.symbol, _sellerValue);
        _emitReleasedPayment(_escrowHash, _escrow.symbol, _buyerValueWithoutFee);

        return OK;
    }

    function _assertSellerAndBuyer(
        bytes32 _escrowHash,
        address _seller,
        address _buyer,
        uint _sellerValue,
        uint _buyerValue,
        uint _expireAtBlock,
        uint _salt,
        bytes _signatures
    )
    private
    view
    {
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _sellerValue,
            _buyerValue,
            _expireAtBlock,
            _salt
        );
        address[] memory _signers = Signatures.getSignersFromSignatures(keccak256(_message), _signatures);
        require(_signers.length == 2 && ((_signers[0] == _seller && _signers[1] == _buyer) ||
            (_signers[0] == _buyer && _signers[1] == _seller)), "ESCROW_ERC20_SIGNERS_SHOULD_BE_BUYER_AND_SELLER");
    }

    /// @notice Transfers disputed value from escrow to the seller `_seller` and the buyer `_buyer` according
    /// 	to provided buyer value `_buyerValue`. The value of escrow - _buyerValue will be transferred to the seller.
    /// @dev Escrow is identified by a message = keccak256(_tradeRecordId, _seller, _buyer)
    /// @dev Arbiter should sign hash of (message, escrow address, msg.sig, _buyerValue, _expireAtBlock) data
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    /// @param _buyerValue value that will be transferred to the buyer
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _arbiterSignature signature of an arbiter
    /// @return result code of an operation
    function releaseDisputedPayment(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer,
        uint _buyerValue,
        uint _expireAtBlock,
        bytes _arbiterSignature
    )
    external
    onlyRelay
    returns (uint)
    {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        require(_escrow.exists, "ESCROW_ERC20_ESCROW_SHOULD_EXIST");
        require(_escrow.disputed, "ESCROW_ERC20_ESCROW_SHOULD_BE_DISPUTED");
        bytes memory _message = abi.encodePacked(
            _escrowHash,
            address(this),
            msg.sig,
            _buyerValue,
            _expireAtBlock
        );
        address _signer = Signatures.getSignerFromSignature(keccak256(_message), _arbiterSignature);
        require(_signer == _escrow.arbiter, "ESCROW_ERC20_SIGNER_SHOULD_BE_ARBITER");
        require(block.number < _expireAtBlock, "ESCROW_ERC20_TX_SHOULD_NOT_BE_EXPIRED");
        require(_buyerValue <= _escrow.value, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");

        ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_escrow.symbol));
        if (_buyerValue < _escrow.value) {
            uint _sellerValue = _escrow.value.sub(_buyerValue);
            _token.transfer(_seller, _sellerValue);
            _emitPayback(_escrowHash, _escrow.symbol, _sellerValue);
        }
        uint _buyerValueWithoutFee = _takeWithdrawalFee(_token, _buyerValue);
        _token.transfer(_buyer, _buyerValueWithoutFee);

        _deleteEscrow(_escrowHash);
        delete _disputeInitiators[_escrowHash];
        _emitReleasedPayment(_escrowHash, _escrow.symbol, _buyerValueWithoutFee);
        _emitDisputeCanceled(_escrowHash);

        return OK;
    }

    /// @notice Deletes escrow record when it is no more needed.
    ///     Escrow should be empty to be deleted.
    /// @param _tradeRecordId identifier of escrow record
    /// @param _seller who will mainly deposit to escrow
    /// @param _buyer who will eventually is going to receive payment
    function deleteEscrow(
        bytes32 _tradeRecordId,
        address _seller,
        address _buyer
    ) external returns (uint) {
        bytes32 _escrowHash = _getEscrowHash(_tradeRecordId, _seller, _buyer);
        Escrow storage _escrow = escrows[_escrowHash];
        if (_escrow.exists && _escrow.value == 0) {
            _deleteEscrow(_escrowHash);
        }

        return OK;
    }

    function _deleteEscrow(bytes32 _escrowHash) private {
        delete escrows[_escrowHash];
    }

    /// @notice Charges a service fee for deposits to escrow contract.
    /// @param _value value from which the commission is taken
    /// @param _feeStatus activate state fee: 1 - active, 0 - not active. 1st bit - seller, 2nd bit - buyer
    /// @return result value without service fee
    function _takeDepositFee(address _token, uint _value, uint8 _feeStatus) private returns (uint _valueToDeposit) {
        _valueToDeposit = _value;
        bool _isActivatedRelay = isActivatedRelay();
        (, uint16 _serviceFeeValue, uint _feePrecision) = getServiceFeeInfo();
        if (_serviceFeeValue > 0 && (!_isActivatedRelay || (_isActivatedRelay && _isFeeFlagAppliedFor(_feeStatus, SELLER_FLAG_BIT_IDX)))) {
            _valueToDeposit = PercentCalculator.getFullValueFromPercentedValue(_value, _feePrecision.add(_serviceFeeValue), _feePrecision);
            uint _feeValue = _value.sub(_valueToDeposit);
            token2accumulatedFeeMapping[_token] = token2accumulatedFeeMapping[_token].add(_feeValue);
        }
    }

    /// @notice Charges a service fee for withdrawal payments from escrow contract.
    /// @param _token erc20 token address
    /// @param _value value from which the commission is taken
    /// @param _feeStatus activate state fee: 1 - active, 0 - not active. 1st bit - seller, 2nd bit - buyer
    /// @return result value without service fee
    function _takeWithdrawalFee(address _token, uint _value, uint8 _feeStatus) private returns (uint) {
        bool _isActivatedRelay = isActivatedRelay();
        if (!_isActivatedRelay || (_isActivatedRelay && _isFeeFlagAppliedFor(_feeStatus, BUYER_FLAG_BIT_IDX))) {
            return _takeWithdrawalFee(_token, _value);
        }
        return _value;
    }

    function _takeWithdrawalFee(address _token, uint _value) private returns (uint) {
        (, uint16 _serviceFeeValue, uint _feePrecision) = getServiceFeeInfo();
        if (_serviceFeeValue > 0) {
            uint _feeValue = PercentCalculator.getPercent(_value, _serviceFeeValue, _feePrecision);
            _value = _value.sub(_feeValue);
            token2accumulatedFeeMapping[_token] = token2accumulatedFeeMapping[_token].add(_feeValue);
        }
        return _value;
    }

    function withdrawFeeForTokens(address[] _tokens) public onlyContractOwner {
        (address _feeDestinationAddress,,) = getServiceFeeInfo();
        require(_feeDestinationAddress != address(0), "ESCROW_ERC20_INVALID_SERVICE_FEE_ADDRESS");

        for (uint _tokenIdx = 0; _tokenIdx < _tokens.length; _tokenIdx++) {
            address _token = _tokens[_tokenIdx];
            uint _accumulatedFee = token2accumulatedFeeMapping[_token];
            token2accumulatedFeeMapping[_token] = 0;
            if (_accumulatedFee > 0) {
                require(ERC20Interface(_token).transfer(_feeDestinationAddress, _accumulatedFee), "ESCROW_ERC20_FAILED_TRANSFER");
            }
        }
    }

	function retranslateToFeeRecipient(bytes32 _symbol, address _from, uint _amount) external payable returns (uint) {
        require(hasCurrencySupport(_symbol), "ESCROW_ERC20_CURRENCY_SHOULD_BE_SUPPORTED");
        ERC20Interface _token = ERC20Interface(erc20Manager.getTokenAddressBySymbol(_symbol));
        require(_amount > 0 && _token.allowance(_from, address(this)) >= _amount, "ESCROW_ERC20_VALUE_SHOULD_BE_CORRECT");
        require(_token.transferFrom(_from, address(this), _amount), "ESCROW_ERC20_FAILED_TRANSFER");

        token2accumulatedFeeMapping[_token] = token2accumulatedFeeMapping[_token].add(_amount);

        return OK;
    }

    /// @notice Transfer accumulated service fee to the serviceFeeAddress
    function withdrawFee(address _token) public onlyContractOwner {
        address[] memory _tokens = new address[](1);
        _tokens[0] = _token;
        withdrawFeeForTokens(_tokens);
    }

    function hasCurrencySupport(bytes32 _symbol) public view returns (bool) {
        return erc20Manager.isTokenSymbolExists(_symbol);
    }

    function _isFeeAdmin(address _account) internal view returns (bool) {
        return contractOwner == _account;
    }

    function _getEscrowExists(bytes32 _escrowHash) internal view returns (bool) {
        Escrow storage _escrow = escrows[_escrowHash];
        return _escrow.exists;
    }

    function _getEscrowDisputed(bytes32 _escrowHash) internal view returns (bool) {
        Escrow storage _escrow = escrows[_escrowHash];
        return _escrow.disputed;
    }

    function _getEscrowSymbol(bytes32 _escrowHash) internal view returns (bytes32) {
        Escrow storage _escrow = escrows[_escrowHash];
        return _escrow.symbol;
    }

    function _getEscrowValue(bytes32 _escrowHash) internal view returns (uint) {
        Escrow storage _escrow = escrows[_escrowHash];
        return _escrow.value;
    }

    function _getEscrowArbiter(bytes32 _escrowHash) internal view returns (address) {
        Escrow storage _escrow = escrows[_escrowHash];
        return _escrow.arbiter;
    }

    function _setEscrowDisputed(bytes32 _escrowHash, bool _disputeStatus) internal {
        Escrow storage _escrow = escrows[_escrowHash];
        _escrow.disputed = _disputeStatus;
    }

    function _setEscrowArbiter(bytes32 _escrowHash, address _arbiter) internal {
        Escrow storage _escrow = escrows[_escrowHash];
        _escrow.arbiter = _arbiter;
    }
}