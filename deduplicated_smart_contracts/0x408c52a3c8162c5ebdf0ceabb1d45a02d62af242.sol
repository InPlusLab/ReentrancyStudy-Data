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

// File: contracts/common/initializable/InitializableOwned.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;




contract InitializableOwned is Owned {

	function _initOwned(address _owner) internal {
		require(_owner != 0x0);
		require(contractOwner == 0x0);
		contractOwner = _owner;
	}
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

// File: contracts/common/initializable/InitializableStorageAdapter.sol

/**
* Copyright 2017每2019, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.25;




contract InitializableStorageAdapter is StorageAdapter {

    function _initStorageAdapter(Storage _storage, bytes32 _crate) internal {
        require(address(store.store) == 0x0);
        store.init(_storage, _crate);
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

// File: contracts/workflow/WorkflowBase.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


interface WorkflowBase {

    /// @param _contractHost smart contract address that will be requested for payments
    function registerContract(bytes32 _contractId, address _contractHost) external returns (uint);
    function addWorkflowData(
        bytes32 _contractId,
        address _contractHost,
        bytes _data
        ) external returns (uint _budget, uint _upfront);

    function precalculateWorkflowData(
        bytes32 _contractId,
        address _contractHost,
        bytes _data
        ) external view returns (uint _budget, uint _upfront);

    /// @notice Gets upfront amount from tasks that have not been finished (completed) yet
    /// @param _contractId contract identifier
    /// @param _contractHost contract smart contract address
    function getUnspentUpfrontAmount(bytes32 _contractId, address _contractHost) external view returns (uint);
}


interface WorkflowContractBlacklistable {
    function isAllowedContractHost(address _contractHost) external view returns (bool);
    function addContractHost(address _contractHost) external returns (uint);
    function removeContractHost(address _contractHost) external returns (uint);
}


interface WorkflowCheckpointBase {
    /// @notice Gets numbers of how much employer will pay for a task `_taskId` in contract `_contractId` at `_contract`
    /// @param _contractId contract ID
    /// @param _contract address of a smart contract
    /// @param _taskId task ID to confirm to
    /// @param _skippedPenalties penalty IDs that will be skipped during payment calculations
    /// @return _totalValue how much task costs
    /// @return _paymentValue how much should be paid immediately
    /// @return _depositValue how much should be additionally deposited
    function getTaskCompletionReward(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId,
        uint32[] _skippedPenalties
    )
    public
    view
    returns (
        uint _totalValue,
        uint _paymentValue,
        uint _depositValue,
        uint _paidValue
    );

    /// @dev Gets task details.
    /// @return
    /// @return _values[0] budget amount
    /// @return _values[1] paid amount
    /// @return _values[2] upfront amount
    /// @return _values[3] withdraw fee amount of paid amount
    function getTaskDetails(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId
    )
    external
    view
    returns (uint[] _values);

    function getTaskCompletionRewardWithoutPenalties(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId
    )
    public
    view
    returns (
        uint _totalValue,
        uint _paymentValue,
        uint _depositValue,
        uint _paidValue
    );

    /// @notice Gets numbers of how much should be additionally deposited to the assignee received `_value`
    /// @param _contractId contract ID
    /// @param _contract address of a smart contract
    /// @param _value how much should be paid immediately
    /// @return _paymentValue how much should be paid immediately
    /// @return _depositValue how much should be additionally deposited
    function getTaskSinglePaymentReward(
        bytes32 _contractId,
        address _contract,
        uint _value
    )
    public
    view
    returns (uint _paymentValue, uint _depositValue);

    function startTask(bytes32 _contractId, address _contract,  uint32 _taskId) external returns (uint);
    function pauseTask(bytes32 _contractId, address _contract, uint32 _taskId) external returns (uint);
    function resumeTask(bytes32 _contractId, address _contract, uint32 _taskId) external returns (uint);

    /// @notice Prepaid expense to the assignee for task `_taskId` in context of contract `_contractId`.
    ///     Assignee's penalties will not be applied to payment value.
    ///     Employer should provide signature for releasing buyer's value from 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _contractId contract ID
    /// @param _contract address of a smart contract
    /// @param _taskId task ID for payment
    /// @param _expireAtBlock bound with signature. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _salt bound with signature. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _signature signature for releasing blocked amount. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @return result code of an operation
    function payPartialTaskExpenses(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external payable returns (uint);

    /// @notice Confirms task `_taskId` completion in context of contract `_contractId` and frees
    ///     budget to be send to the assignee.
    ///     Assignee's penalties will not be applied to the final paycheck.
    ///     Employer should provide signature for releasing buyer's value from 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _contractId contract ID
    /// @param _contract address of a smart contract
    /// @param _taskId task ID to confirm to
    /// @param _expireAtBlock bound with signature. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _salt bound with signature. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _signature signature for releasing blocked amount. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @return result code of an operation
    function completeTaskAndPay(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external payable returns (uint);

    function completeTask(bytes32 _contractId, address _contract, uint32 _taskId) external returns (uint);

    /// @notice Confirms task `_taskId` completion in context of contract `_contractId` and frees
    ///     budget to be send to the assignee.
    ///     Assignee's penalties could be skipped and they will not be applied to the final paycheck.
    ///     Employer should provide signature for releasing buyer's value from 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _contractId contract ID
    /// @param _contract address of a smart contract
    /// @param _taskId task ID to confirm to
    /// @param _skippedPenalties penalty IDs that will be skipped during payment calculations
    /// @param _expireAtBlock bound with signature. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _salt bound with signature. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @param _signature signature for releasing blocked amount. See 'EscrowBaseInterface#releaseBuyerPayment'
    /// @return result code of an operation
    function confirmTaskCompletion(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId,
        uint32[] _skippedPenalties,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external payable returns (uint);

    function declineTaskAndSendToRework(
        bytes32 _contractId,
        address _contract,
        uint32 _taskId,
        string _reason
        ) external returns (uint);
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

// File: contracts/libs/DataParser.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;




/// @title Provides functions to parse and copy input data stream for LX Contract module.
library DataParser {

    using SafeMath for uint;

    // constant uint CONTRACT_DATA_STRUCT_LENGTH = 232;
    // constant uint TASK_DATA_STRUCT_LENGTH = 102;
    // constant uint PENALTY_DATA_STRUCT_LENGTH = 74;
    // constant uint TERMINATION_DATA_STRUCT_LENGTH = 70;

    /** @dev DATA_STRUCTURE_TYPE {
            CONTRACT = 1,
            TASK = 2,
            PENALTY = 3,
            TERMINATION = 4
        }
    */
    /// @dev CONTRACT_TYPE { JOB = 1, DISPUTE = 2 }
    /// @dev PAYMENT_TIMELINE { PAY_BY_TASK = 1, PAY_BY_PROJECT = 2 }
    /// @dev PAYMENT_VALUE_TYPE { CURRENCY = 1; PERCENT = 2 }
    /// @dev PENALTY_APPLICATION_TYPE { MISS_DEADLINE = 1, LATE_PAYMENT = 2 }
    /// @dev TERMINATION_PARTY { TERMINATION_EMPLOYER = 1, TERMINATION_ASSIGNEE = 2 }

    enum ContractType { INVALID, JOB, DISPUTE }
    enum PaymentValueType { INVALID, CURRENCY, PERCENT }
    enum PaymentTimeline { INVALID, PAY_BY_TASK, PAY_BY_PROJECT }
    enum TerminationParty { INVALID, TERMINATION_EMPLOYER, TERMINATION_ASSIGNEE }
    enum PenaltyApplicationType { INVALID, MISS_DEADLINE, LATE_PAYMENT }

    enum DataStructureType {
        INVALID,
        CONTRACT,
        TASK,
        PENALTY,
        TERMINATION
    }

    /// @dev Contract data structure
    struct ContractData {
        /// @dev CONTRACT_TYPE type
        uint8 contractType;
        bytes32 documentHash;
        /// @dev for dispute contracts
        bytes32 linkedContractId;
        address employer;
        address assignee;
        address arbiter;
        address participant;
        /// @dev timestamp
        uint256 beginDate;
        bytes32 paymentCurrencySymbol;
        address paymentCurrencyAddress; // @deprecated
        bool lockFullBudget;
        /// @dev PAYMENT_TIMELINE type
        uint8 paymentTimeline;
        bool refundUpfrontOnTermination;
        bool allowDynamicTasks;
    }

    /// @dev Task data structure
    struct TaskData {
        uint32 id;
        bool isUpfront;
        /// @dev PAYMENT_VALUE_TYPE type
        uint8 upfrontValueType;
        /// @dev interpretation is based on valueType
        uint256 upfrontValue;
        /// @dev total amount to pay
        uint256 budget;
        /// @dev timestamp
        uint256 deadline;
    }

    struct TaskPenaltyData {
        uint32 id;
        /// @dev penalized task id
        uint32 taskId;
        /// @dev PENALTY_APPLICATION_TYPE type
        uint8 applicationType;
        /// @dev PAYMENT_VALUE_TYPE type
        uint8 valueType;
        /// @dev interpretation is based on valueType
        uint256 value;
        /// @dev reserved for future purposes
        bytes32 reserved1;
    }

    struct TerminationData {
        uint32 id;
        /// @dev TERMINATION_PARTY
        uint8 initiatorType;
        /// @dev TERMINATION_PARTY
        uint8 payToType;
        bytes32 description;
        /// @dev PAYMENT_VALUE_TYPE type
        uint8 valueType;
        /// @dev interpretation is based on valueType
        uint256 value;
    }

    function _getRawLengthForDataStructure(uint8 _dataStructureType) internal pure returns (uint _length) {
        assembly {
            switch _dataStructureType
            case 1 { _length := 233 } // CONTRACT_DATA_STRUCT_LENGTH
            case 2 { _length := 102 } // TASK_DATA_STRUCT_LENGTH
            case 3 { _length := 74 } // PENALTY_DATA_STRUCT_LENGTH
            case 4 { _length := 71 } // TERMINATION_DATA_STRUCT_LENGTH
            default { revert(0,0) }
        }
    }

    function _getFieldsNumberForDataStructure(uint8 _dataStructureType) private pure returns (uint _fields) {
        assembly {
            switch _dataStructureType
            case 1 { _fields := 14 } // CONTRACT_DATA_STRUCT_LENGTH
            case 2 { _fields := 6 } // TASK_DATA_STRUCT_LENGTH
            case 3 { _fields := 6 } // PENALTY_DATA_STRUCT_LENGTH
            case 4 { _fields := 6 } // TERMINATION_DATA_STRUCT_LENGTH
            default { revert(0,0) }
        }
    }

    function _countRawInputStructures(bytes memory _inputData, uint8 _dataStructureType) private pure returns (uint _counter) {
        uint _pointerOffset;
        while (_pointerOffset < _inputData.length) {
            uint8 header;
            assembly {
                let pointer := add(_inputData, add(_pointerOffset, 0x1))
                header := and(mload(pointer), 0xff)
                if eq(header, _dataStructureType) {
                    _counter := add(_counter, 1)
                }
            }

            _pointerOffset += _getRawLengthForDataStructure(header) + 1;
        }
    }

    /// @dev Copies data from `_input` by length of `_cutLength` and pastes into
    ///     `_output` with offset `_outputPointer`
    function _cutDataFromInput(
        bytes memory _input,
        uint _cutLength,
        bytes memory _output,
        uint _outputPointer
    )
    private
    pure
    {
        assembly {
            let dataPointer := add(_output, _outputPointer)
            let end := add(dataPointer, _cutLength)

            for {
                let cc := _input
            } lt(dataPointer, end) {
                dataPointer := add(dataPointer, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(dataPointer, mload(cc))
            }
        }
    }

    /// @dev Allocates bytes array for keeping a struct data by providing number of struct items
    ///     and number of fields in a struct.
    ///     Reserves prefix memory slots for future struct casting.
    function _allocUnpackedMemoryBytesArray(uint _structCount, uint _structFieldsNumber) private pure returns (bytes memory _arr) {
        assembly {
            _arr := add(mload(0x40), mul(_structCount, 0x20)) // prepend new memory area with _structCount more empty slots (for structure item references)
            let _length := mul(mul(_structFieldsNumber, 0x20), _structCount)
            mstore(_arr, _length)

            mstore(0x40, add(_arr, add(_length, 0x20)))
        }
    }

    /// @dev Allocates bytes array for keeping data
    function _allocMemoryBytesArray(uint _structCount, uint _structDataLength) private pure returns (bytes memory _arr) {
        assembly {
            _arr := mload(0x40)
            let _length := mul(_structDataLength, _structCount)
            mstore(_arr, _length)

            mstore(0x40, add(_arr, add(_length, 0x20)))
        }
    }

    /// @dev Transforms provided array to have struct-like array presentation.
    ///     Should provide array with preserved memory slots.
    function _castMemoryArrayToStructureArray(
        bytes memory _arr,
        uint _structFieldsNumber
    )
    private
    pure
    returns (
        bytes memory _castedArr
    ) {
        /**
         * Transform raw bytes array into array of structures.
         * It should have the following structure:
         * - first byte: number of structures
         * - n-bytes (n - number of structures): references into memory to structures' items ()
         * - n+m-bytes: data
         */
        assembly {
            let _structLength := mul(_structFieldsNumber, 0x20)
            let _structuresCount := div(mload(_arr), _structLength)
            _castedArr := sub(_arr, mul(_structuresCount, 0x20)) // set offset in opposite way to expand memory with structures' refs
            mstore(_castedArr, _structuresCount)

            let _writePointer := add(_castedArr, 0x20)
            for { let _offsetIdx := 0 } lt(_offsetIdx, _structuresCount) { _offsetIdx := add(_offsetIdx, 1) } {
                mstore(_writePointer, add(_arr, add(0x20, mul(_offsetIdx, _structLength))))
                _writePointer := add(_writePointer, 0x20)
            }
        }
    }

    function cutCleanArrayFromRawInput(bytes memory _inputData, uint8 _dataStructureType)
    internal
    pure
    returns (
        bytes memory _packedData
    ) {
        uint _dataLength = _getRawLengthForDataStructure(_dataStructureType);
        uint _structuresCount = _countRawInputStructures(_inputData, _dataStructureType);
        _packedData = _allocMemoryBytesArray(_structuresCount, _dataLength);

        bytes memory _offsetInputData;
        uint _counter;
        uint _pointerOffset;
        while ((_pointerOffset < _inputData.length) && (_counter < _structuresCount)) {
            uint8 header;
            assembly {
                let pointer := add(_inputData, add(_pointerOffset, 0x1))
                header := and(mload(pointer), 0xff)
                if eq(header, _dataStructureType) {
                    _offsetInputData := add(pointer, 0x20)
                }
            }

            if (header == _dataStructureType) {
                _cutDataFromInput(_offsetInputData, _dataLength, _packedData, 0x20 + _counter * _dataLength);
                _counter += 1;
            }
            _pointerOffset += _getRawLengthForDataStructure(header) + 1; // +1 for DATA_STRUCTURE_TYPE header byte
        }
    }

    function unpackRawInputIntoMemoryArray(
        bytes memory _inputData,
        uint8 _dataStructureType,
        function (bytes memory, bytes memory) internal pure _unpack
    )
    internal
    pure
    returns (
        bytes memory _unpackedData
    ) {
        uint _fieldsNumber = _getFieldsNumberForDataStructure(_dataStructureType);
        uint _structCount = _countRawInputStructures(_inputData, _dataStructureType);
        _unpackedData = _allocUnpackedMemoryBytesArray(_structCount, _fieldsNumber);

        bytes memory _offsetInputData;
        bytes memory _unpackDataPointer;
        uint _pointerOffset;
        uint _structCounter;
        while ((_pointerOffset < _inputData.length) && (_structCounter < _structCount)) {
            uint8 header;
            assembly {
                // read the first byte - DATA_STRUCTURE_TYPE
                let pointer := add(_inputData, add(_pointerOffset, 0x1))
                header := and(mload(pointer), 0xff)
                if eq(header, _dataStructureType) {
                    _offsetInputData := pointer
                    _unpackDataPointer := add(_unpackedData, add(0x20, mul(mul(_structCounter, _fieldsNumber), 0x20)))
                    _structCounter := add(_structCounter, 1)
                }
            }

            if (header == _dataStructureType) {
                _unpack(_offsetInputData, _unpackDataPointer);
            }

            _pointerOffset += _getRawLengthForDataStructure(header) + 1;
        }
    }

    function unpackCleanArrayIntoMemoryArray(
        bytes memory _inputData,
        uint8 _dataStructureType,
        function (bytes memory, bytes memory) internal pure _unpack
    ) internal pure returns (bytes memory _unpackedData) {
        uint _dataStructureLength = _getRawLengthForDataStructure(_dataStructureType);
        require(_inputData.length % _dataStructureLength == 0, "PARSER_INVALID_DATA_PADDING");

        bytes memory _offsetInputPointer;
        bytes memory _offsetOutputPointer;
        uint _fieldsNumber = _getFieldsNumberForDataStructure(_dataStructureType);
        uint _unpackedDataItemLength = _fieldsNumber * 32;

        _unpackedData = _allocUnpackedMemoryBytesArray(_inputData.length / _dataStructureLength, _fieldsNumber);
        assembly {
            _offsetOutputPointer := add(_unpackedData, 0x20)
        }
        for (uint _inputOffset = 0; _inputOffset < _inputData.length; _inputOffset += _dataStructureLength) {
            assembly {
                _offsetInputPointer := add(_inputData, _inputOffset)
            }

            _unpack(_offsetInputPointer, _offsetOutputPointer);

            assembly {
                _offsetOutputPointer := add(_offsetOutputPointer, _unpackedDataItemLength)
            }
        }
    }

    function _unpackContractIntoMemory(bytes memory _inputData, bytes memory _unpackedData) private pure {
        assembly {
            mstore(_unpackedData, and(mload(add(_inputData, 0x1)), 0xff)) // 1 byte
            mstore(add(_unpackedData, 0x20), and(mload(add(_inputData, 0x21)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_unpackedData, 0x40), and(mload(add(_inputData, 0x41)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_unpackedData, 0x60), and(mload(add(_inputData, 0x55)), 0xffffffffffffffffffffffffffffffffffffffff)) // 20 bytes
            mstore(add(_unpackedData, 0x80), and(mload(add(_inputData, 0x69)), 0xffffffffffffffffffffffffffffffffffffffff)) // 20 bytes
            mstore(add(_unpackedData, 0xa0), and(mload(add(_inputData, 0x7d)), 0xffffffffffffffffffffffffffffffffffffffff)) // 20 bytes
            mstore(add(_unpackedData, 0xc0), and(mload(add(_inputData, 0x91)), 0xffffffffffffffffffffffffffffffffffffffff)) // 20 bytes
            mstore(add(_unpackedData, 0xe0), and(mload(add(_inputData, 0xb1)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_unpackedData, 0x100), and(mload(add(_inputData, 0xd1)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_unpackedData, 0x120), and(mload(add(_inputData, 0xe5)), 0xffffffffffffffffffffffffffffffffffffffff)) // 20 bytes
            mstore(add(_unpackedData, 0x140), and(mload(add(_inputData, 0xe6)), 0xff)) // 1 byte
            mstore(add(_unpackedData, 0x160), and(mload(add(_inputData, 0xe7)), 0xff)) // 1 byte
            mstore(add(_unpackedData, 0x180), and(mload(add(_inputData, 0xe8)), 0xff)) // 1 byte
            mstore(add(_unpackedData, 0x1a0), and(mload(add(_inputData, 0xe9)), 0xff)) // 1 byte
        }
    }

    function _unpackTaskIntoMemory(bytes memory _inputData, bytes memory _taskData) private pure {
        assembly {
            mstore(_taskData, and(mload(add(_inputData, 0x4)), 0xffffffff)) // 4 byte
            mstore(add(_taskData, 0x20), and(mload(add(_inputData, 0x5)), 0xff)) // 1 byte
            mstore(add(_taskData, 0x40), and(mload(add(_inputData, 0x6)), 0xff)) // 1 byte
            mstore(add(_taskData, 0x60), and(mload(add(_inputData, 0x26)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_taskData, 0x80), and(mload(add(_inputData, 0x46)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_taskData, 0xa0), and(mload(add(_inputData, 0x66)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
        }
    }

    function _unpackTaskPenaltyIntoMemory(bytes memory _inputData, bytes memory _penaltyData) private pure {
        assembly {
            mstore(_penaltyData, and(mload(add(_inputData, 0x4)), 0xffffffff)) // 4 byte
            mstore(add(_penaltyData, 0x20), and(mload(add(_inputData, 0x8)), 0xffffffff)) // 4 byte
            mstore(add(_penaltyData, 0x40), and(mload(add(_inputData, 0x9)), 0xff)) // 1 byte
            mstore(add(_penaltyData, 0x60), and(mload(add(_inputData, 0xa)), 0xff)) // 1 byte
            mstore(add(_penaltyData, 0x80), and(mload(add(_inputData, 0x2a)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_penaltyData, 0xa0), and(mload(add(_inputData, 0x4a)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
        }
    }

    function _unpackTerminationIntoMemory(bytes memory _inputData, bytes memory _terminationData) private pure {
        assembly {
            mstore(_terminationData, and(mload(add(_inputData, 0x4)), 0xffffffff)) // 4 byte
            mstore(add(_terminationData, 0x20), and(mload(add(_inputData, 0x5)), 0xff)) // 1 byte
            mstore(add(_terminationData, 0x40), and(mload(add(_inputData, 0x6)), 0xff)) // 1 byte
            mstore(add(_terminationData, 0x60), and(mload(add(_inputData, 0x26)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
            mstore(add(_terminationData, 0x80), and(mload(add(_inputData, 0x27)), 0xff)) // 1 byte
            mstore(add(_terminationData, 0xa0), and(mload(add(_inputData, 0x47)), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) // 32 bytes
        }
    }

    /** RAW INPUT PARSING */

    function parseContractDataRawInput(bytes memory _inputData)
    internal
    pure
    returns (
        ContractData memory _entity
    ) {
        bytes memory _data = unpackRawInputIntoMemoryArray(_inputData, 1, _unpackContractIntoMemory); // DATA_STRUCTURE_TYPE = CONTRACT

        assembly {
            _entity := add(_data, 0x20)
        }
    }

    function parseTaskDataRawInput(bytes memory _inputData)
    internal
    pure
    returns (
        TaskData[] memory _entities
    ) {
        bytes memory _data = unpackRawInputIntoMemoryArray(_inputData, 2, _unpackTaskIntoMemory); // DATA_STRUCTURE_TYPE = TASK
        uint _fieldsNumber = _getFieldsNumberForDataStructure(2);
        bytes memory _structures = _castMemoryArrayToStructureArray(_data, _fieldsNumber);

        assembly {
            _entities := _structures
        }
    }

    function parseTaskPenaltyDataRawInput(bytes memory _inputData)
    internal
    pure
    returns (
        TaskPenaltyData[] memory _entities
    ) {
        bytes memory _data = unpackRawInputIntoMemoryArray(_inputData, 3, _unpackTaskPenaltyIntoMemory); // DATA_STRUCTURE_TYPE = PENALTY
        uint _fieldsNumber = _getFieldsNumberForDataStructure(3);
        bytes memory _structures = _castMemoryArrayToStructureArray(_data, _fieldsNumber);

        assembly {
            _entities := _structures
        }
    }

    function parseTerminationDataRawInput(bytes memory _inputData)
    internal
    pure
    returns (
        TerminationData[] memory _entities
    ) {
        bytes memory _data = unpackRawInputIntoMemoryArray(_inputData, 4, _unpackTerminationIntoMemory); // DATA_STRUCTURE_TYPE = TERMINATION
        uint _fieldsNumber = _getFieldsNumberForDataStructure(4);
        bytes memory _structures = _castMemoryArrayToStructureArray(_data, _fieldsNumber);

        assembly {
            _entities := _structures
        }
    }

    /** CLEAN INPUT PARSING */

    function parseContractDataCleanInput(bytes memory _inputData)
    internal
    pure
    returns (
        ContractData memory _entity
    ) {
        bytes memory _data = unpackCleanArrayIntoMemoryArray(_inputData, 1, _unpackContractIntoMemory); // DATA_STRUCTURE_TYPE = CONTRACT

        assembly {
            _entity := add(_data, 0x20)
        }
    }

    function parseTaskDataCleanInput(bytes memory _inputData)
    internal
    pure
    returns (
        TaskData[] memory _entities
    ) {
        bytes memory _data = unpackCleanArrayIntoMemoryArray(_inputData, 2, _unpackTaskIntoMemory); // DATA_STRUCTURE_TYPE = TASK
        uint _fieldsNumber = _getFieldsNumberForDataStructure(2);
        bytes memory _structures = _castMemoryArrayToStructureArray(_data, _fieldsNumber);

        assembly {
            _entities := _structures
        }
    }

    function parseTaskPenaltyDataCleanInput(bytes memory _inputData)
    internal
    pure
    returns (
        TaskPenaltyData[] memory _entities
    ) {
        bytes memory _data = unpackCleanArrayIntoMemoryArray(_inputData, 3, _unpackTaskPenaltyIntoMemory); // DATA_STRUCTURE_TYPE = PENALTY
        uint _fieldsNumber = _getFieldsNumberForDataStructure(3);
        bytes memory _structures = _castMemoryArrayToStructureArray(_data, _fieldsNumber);

        assembly {
            _entities := _structures
        }
    }

    function parseTerminationDataCleanInput(bytes memory _inputData)
    internal
    pure
    returns (
        TerminationData[] memory _entities
    ) {
        bytes memory _data = unpackCleanArrayIntoMemoryArray(_inputData, 4, _unpackTerminationIntoMemory); // DATA_STRUCTURE_TYPE = TERMINATION
        uint _fieldsNumber = _getFieldsNumberForDataStructure(4);
        bytes memory _structures = _castMemoryArrayToStructureArray(_data, _fieldsNumber);

        assembly {
            _entities := _structures
        }
    }

    /** ASSERTIONS */

    function assertContractData(ContractData memory _contract) internal view {
        require(
            _contract.contractType == uint8(ContractType.JOB) ||
            _contract.contractType == uint8(ContractType.DISPUTE)
        );
        require(_contract.documentHash != bytes32(0));
        require(_contract.employer != 0x0);
        require(_contract.assignee != 0x0);
        require(_contract.assignee != _contract.employer);
        require(_contract.arbiter != _contract.assignee && _contract.arbiter != _contract.employer); // still allow _contract.arbiter to be 0x0
        require(_contract.beginDate > block.timestamp);
        require(_contract.paymentCurrencySymbol != bytes32(0)); // TODO: check if escrow supports this symbol
        require(
            _contract.paymentTimeline == uint8(PaymentTimeline.PAY_BY_TASK) ||
            _contract.paymentTimeline == uint8(PaymentTimeline.PAY_BY_PROJECT)
        );

        if (_contract.contractType == 2) {
            assertDisputeContractData(_contract);
        }
    }

    function assertDisputeContractData(ContractData memory _contract) internal pure {
        require(_contract.contractType == uint8(ContractType.DISPUTE));
        require(_contract.linkedContractId != 0); // TODO: check linked contract for existance; check it is started, not under_dispute
        require(_contract.participant != 0x0);
        require(
            _contract.participant != _contract.employer &&
            _contract.participant != _contract.assignee &&
            _contract.participant != _contract.arbiter
        );
    }

    function assertDisputeContractWithLinkedContract(
        ContractData memory _linkedContract,
        ContractData memory _disputeContract
    )
    internal
    pure
    {
        require(_disputeContract.arbiter == 0x0, "PARSER_DISPUTE_SHOULD_NOT_PROVIDE_ARBITER");
        require(_linkedContract.arbiter == _disputeContract.assignee, "PARSER_ARBITER_SHOULD_BE_ASSIGNEE_IN_DISPUTE");
        require(
            _linkedContract.assignee == _disputeContract.employer ||
            _linkedContract.assignee == _disputeContract.participant,
            "PARSER_ASSIGNEE_SHOULD_BE_EMPLOYER_OR_PARTICIPANT_IN_DISPUTE"
        );
        require(
            _linkedContract.employer == _disputeContract.employer ||
            _linkedContract.employer == _disputeContract.participant,
            "PARSER_EMPLOYER_SHOULD_BE_EMPLOYER_OR_PARTICIPANT_IN_DISPUTE"
        );
    }

    function assertTaskPenalty(TaskPenaltyData memory _penalty) internal pure {
        require(
            _penalty.applicationType == uint8(PenaltyApplicationType.MISS_DEADLINE),/*  ||
            _penalty.applicationType == uint8(DataParser.PenaltyApplicationType.LATE_PAYMENT) */
            "PARSER_PENALTY_INVALID_APPLICATION_TYPE"
        );
    }

    /** SEARCH */

    function getTerminationResultValue(
        TerminationData memory _terminationInfo,
        uint _baseBudget,
        uint _precision
    )
    internal
    pure
    returns (uint _fullTerminationAmount)
    {
        if (_terminationInfo.valueType == uint(PaymentValueType.CURRENCY)) {
            _fullTerminationAmount = _terminationInfo.value;
        } else if (_terminationInfo.valueType == uint(PaymentValueType.PERCENT)) {
            require(_terminationInfo.value <= _precision, "PARSER_INVALID_TERMINATION_PERCENT_VALUE");
            _fullTerminationAmount = PercentCalculator.getPercent(_baseBudget, _terminationInfo.value, _precision);
        } else {
            revert("PARSER_INVALID_TERMINATION_PAYMENT_VALUE_TYPE");
        }
    }

    function getTaskPenaltyResultValue(
        TaskPenaltyData memory _penalty,
        uint _baseBudget,
        uint _precision
    )
    internal
    pure
    returns (uint _penaltyValue)
    {
        if (_penalty.valueType == uint(PaymentValueType.CURRENCY)) {
            _penaltyValue = _penalty.value;
        } else if (_penalty.valueType == uint(PaymentValueType.PERCENT)) {
            require(_penalty.value <= _precision, "PARSER_INVALID_TASK_PENALTY_PERCENT_VALUE");
            _penaltyValue = PercentCalculator.getPercent(_baseBudget, _penalty.value, _precision);
        } else {
            revert("PARSER_INVALID_TASK_PENALTY_PAYMENT_VALUE_TYPE");
        }
    }

    function getTaskUpfrontResultValue(
        TaskData memory _task,
        uint _precision
    )
    internal
    pure
    returns (uint _upfrontValue)
    {
        if (_task.upfrontValueType == uint(PaymentValueType.CURRENCY)) {
            require(_task.upfrontValue <= _task.budget, "PARSER_INVALID_TASK_UPFRONT_CURRENCY_VALUE");
            _upfrontValue = _task.upfrontValue;
        } else if (_task.upfrontValueType == uint(PaymentValueType.PERCENT)) {
            require(_task.upfrontValue <= _precision, "PARSER_INVALID_TASK_UPFRONT_PERCENT_VALUE");
            _upfrontValue = PercentCalculator.getPercent(_task.budget, _task.upfrontValue, _precision);
        } else {
            revert("PARSER_INVALID_TASK_UPFRONT_PAYMENT_VALUE_TYPE");
        }
    }

    function getTerminationById(
        uint _terminationId,
        bytes memory _clearData
    )
    internal
    pure
    returns (TerminationData memory)
    {
        TerminationData[] memory _terminations = parseTerminationDataCleanInput(_clearData);

        for (uint _idx = 0; _idx < _terminations.length; ++_idx) {
            if (_terminations[_idx].id == _terminationId) {
                return _terminations[_idx];
            }
        }
    }

    function getTerminationParty(ContractData memory _contractInfo, address _account) internal pure returns (TerminationParty) {
        if (_account == _contractInfo.employer) {
            return TerminationParty.TERMINATION_EMPLOYER;
        } else if (_account == _contractInfo.assignee) {
            return TerminationParty.TERMINATION_ASSIGNEE;
        }

        revert("PARSER_INVALID_INITIATOR_PARTY_ACCOUNT");
    }

    function getOppositeTerminationParty(TerminationParty _terminationParty) internal pure returns (TerminationParty) {
        if (_terminationParty == TerminationParty.TERMINATION_EMPLOYER) {
            return TerminationParty.TERMINATION_ASSIGNEE;
        } else if (_terminationParty == TerminationParty.TERMINATION_ASSIGNEE) {
            return TerminationParty.TERMINATION_EMPLOYER;
        }

        revert("PARSER_UNHANDLED_INITIATOR_PARTY");
    }
}

// File: contracts/labor-contract/LaborContractCore.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;








contract LaborContractCore is
    InitializableStorageAdapter,
    FeeConstants
{
    StorageInterface.Bytes32AddressMapping internal escrowStorage;
    StorageInterface.Bytes32AddressMapping internal workflowStorage;

    /// @dev keccak(contractId, signer address) => boolean
    StorageInterface.Bytes32BoolMapping internal signsStorage;
    /// @dev keccak(contractId, signer address) => salt (from #sign)
    StorageInterface.Bytes32UIntMapping internal signsSaltStorage;
    /// @dev keccak(contractId, signer address) => signature (from #sign)
    StorageInterface.BytesSequenceMapping internal signsSignatureStorage;
    /// @dev contractId => set of salts
    StorageInterface.UIntSetMapping internal signsInvalidatedSaltsStorage;

    // StorageInterface.Bytes32Bytes32Mapping internal baseContractStorage;
    // StorageInterface.Bytes32SetMapping internal linkedContractsStorage;

    StorageInterface.Bytes32UInt8Mapping internal contractStateStorage;
    StorageInterface.Bytes32Bytes32Mapping internal contractDocumentHashStorage;
    StorageInterface.BytesSequenceMapping internal contractInfoStorage;
    StorageInterface.BytesSequenceMapping internal terminationsStorage;

    StorageInterface.BytesSequenceMapping internal proposedTasksStorage;
    StorageInterface.Bytes32Bytes32Mapping internal proposedDocumentHashStorage;

    /// @dev proposition to store ID of termination with the highest termination budget
    /// contractId => max locked termination value
    StorageInterface.Bytes32UIntMapping internal terminationLockedBalanceStorage;

    /// @dev contractId => upfront balance
    StorageInterface.Bytes32UIntMapping internal budgetUpfrontPaymentAmountStorage;
    // StorageInterface.Bytes32UIntMapping internal totalLockBudgetAmountStorage;
    StorageInterface.Bytes32UIntMapping internal totalBudgetAmountStorage;
    /// @dev contractId => sum of total completed (of future) payments
    StorageInterface.Bytes32UIntMapping internal completedPaymentsBalanceStorage;
    /// @dev contractId => sum of total completed and transferred payments
    StorageInterface.Bytes32UIntMapping internal transferredPaymentsBalanceStorage;

    StorageInterface.Bytes32UIntMapping internal terminationRequestIdStorage;
    StorageInterface.StringMapping internal terminationReasonStorage;

    StorageInterface.Address internal terminatableStorage;
    StorageInterface.Address internal disputableStorage;
    StorageInterface.Address internal signableStorage;
    StorageInterface.Address internal completableStorage;
    StorageInterface.Address internal tasksProposableStorage;


    function _initCore() internal {
        escrowStorage.init("escrow");
        workflowStorage.init("workflow");
        signsStorage.init("signs");
        signsSaltStorage.init("signsSalt");
        signsSignatureStorage.init("signsSignature");
        signsInvalidatedSaltsStorage.init("signsInvalidatedSalts");
        // baseContractStorage.init("baseContract");
        // linkedContractsStorage.init("linkedContracts");
        contractStateStorage.init("contractState");
        contractDocumentHashStorage.init("contractDocumentHash");
        contractInfoStorage.init("contractInfo");
        terminationsStorage.init("terminations");
        proposedTasksStorage.init("proposedTasks");
        proposedDocumentHashStorage.init("proposedDocumentHash");
        terminationLockedBalanceStorage.init("terminationLockedBalance");
        budgetUpfrontPaymentAmountStorage.init("budgetUpfrontPaymentAmount");
        // totalLockBudgetAmountStorage.init("totalLockBudgetAmount");
        totalBudgetAmountStorage.init("totalBudgetAmount");
        terminationRequestIdStorage.init("terminationRequestId");
        terminationReasonStorage.init("terminationReason");
        completedPaymentsBalanceStorage.init("completedPaymentsBalance");
        transferredPaymentsBalanceStorage.init("transferredPaymentsBalance");
        terminatableStorage.init("terminatable");
        disputableStorage.init("disputable");
        signableStorage.init("signable");
        completableStorage.init("completable");
        tasksProposableStorage.init("tasksProposable");
    }
}


contract LaborContractEventEmitter {

    event ContractCreated(bytes32 indexed contractId, bytes32 documentHash);
    event ContractSigned(bytes32 indexed contractId, bytes32 documentHash, address signer, uint expireAtBlock, uint salt);
    event ContractSignRevoked(bytes32 indexed contractId, address signer);
    event ContractStarted(bytes32 indexed contractId, uint _depositValue);
    event ContractTasksProposed(bytes32 indexed contractId, bytes32 documentHash);
    event ContractTasksAccepted(bytes32 indexed contractId, bytes32 documentHash);
    event ContractDisputeResolved(bytes32 indexed contractId);
    event ContractTerminationRequested(bytes32 indexed contractId, uint terminationId, address initiator, string comment);
    event ContractTerminationRequestCancelled(bytes32 indexed contractId, uint terminationId);
    event ContractTerminated(bytes32 indexed contractId, uint terminationId);
    event ContractStateTransitioned(bytes32 indexed contractId, uint8 indexed previousState, uint8 indexed currentState);
    event ContractOperationLogged(bytes32 indexed contractId, string indexed operationAction);
    event ContractWithdrawOperationLogged(bytes32 indexed contractId, string indexed operationAction, uint depositValue, uint paymentAmount);
}


contract LaborContractAbstract is
    LaborContractCore,
    LaborContractEventEmitter
{
    using SafeMath for uint;

    enum State { NOT_INITIALIZED, CREATED, SIGNED, STARTED, TERMINATION_REQUESTED, TERMINATED, UNDER_DISPUTE, COMPLETED }

    uint constant internal OK = 1;
    uint constant internal TERMINATION_PERCENT_PRECISION = 10000;

    modifier onlyInState(bytes32 _contractId, State _state) {
        require(_getContractState(_contractId) == _state, "C_S");
        _;
    }

    function getEscrow(bytes32 _contractId) public view returns (EscrowBaseInterface) {
        return EscrowBaseInterface(store.get(escrowStorage, _contractId));
    }

    function getWorkflow(bytes32 _contractId) public view returns (WorkflowBase) {
        return WorkflowBase(store.get(workflowStorage, _contractId));
    }

    function getServiceSurchargePercent(bytes32 _contractId) public view returns (uint _percent, uint _precision) {
        (, _percent, _precision) = getEscrow(_contractId).getServiceFeeInfo();
    }

    function version() public pure returns (string);

    /** INTERNAL */

    function _setContractStateTo(bytes32 _contractId, State _newState) internal {
        require(_newState != State.NOT_INITIALIZED, "C_NI");

        State _currentState = _getContractState(_contractId);
        if (_currentState == _newState) {
            return;
        }

        store.set(contractStateStorage, _contractId, uint8(_newState));

        emit ContractStateTransitioned(_contractId, uint8(_currentState), uint8(_newState));
    }

    function _getContractState(bytes32 _contractId) internal view returns (State) {
        return State(store.get(contractStateStorage, _contractId));
    }

    function _getContractDocumentHash(
        bytes32 _contractId,
        DataParser.ContractData memory _contractInfo
    )
    internal
    view
    returns (bytes32 _documentHash)
    {
        _documentHash = store.get(contractDocumentHashStorage, _contractId);
        if (_documentHash == bytes32(0)) {
            _documentHash = _contractInfo.documentHash;
        }
    }

    function _getContractInfoBytes(bytes32 _contractId) internal view returns (bytes memory _data) {
        return store.get(contractInfoStorage, _contractId);
    }

    function _getTerminationsInfoBytes(bytes32 _contractId) internal view returns (bytes memory _data) {
        return store.get(terminationsStorage, _contractId);
    }

    function _getContractAccumulatedPaymentAmount(bytes32 _contractId) internal view returns (uint) {
        return store.get(completedPaymentsBalanceStorage, _contractId);
    }

    function _getContractTransferredPaymentAmount(bytes32 _contractId) internal view returns (uint) {
        return store.get(transferredPaymentsBalanceStorage, _contractId);
    }

    function _getContractTotalBudgetAmount(bytes32 _contractId) internal view returns (uint) {
        return store.get(totalBudgetAmountStorage, _contractId);
    }

    function _getContractLockedTerminationAmount(bytes32 _contractId) internal view returns (uint) {
        return store.get(terminationLockedBalanceStorage, _contractId);
    }

    function _getLeftToPayAmount(bytes32 _contractId) internal view returns (uint) {
        return _getContractAccumulatedPaymentAmount(_contractId).sub(_getContractTransferredPaymentAmount(_contractId));
    }

    function _incrementTransferredBalance(bytes32 _contractId, uint _value) internal {
        store.set(transferredPaymentsBalanceStorage, _contractId, _getContractTransferredPaymentAmount(_contractId).add(_value));
    }

    function _decrementTransferredBalance(bytes32 _contractId, uint _value) internal {
        store.set(transferredPaymentsBalanceStorage, _contractId, _getContractTransferredPaymentAmount(_contractId).sub(_value));
    }

    function _incrementLockedTerminationAmount(bytes32 _contractId, uint _value) internal {
        store.set(terminationLockedBalanceStorage, _contractId, _getContractLockedTerminationAmount(_contractId).add(_value));

    }

    function _incrementUpfrontPaymentAmount(bytes32 _contractId, uint _value) internal {
        if (_value > 0) {
            uint _currentUpfrontPaymentAmount = store.get(budgetUpfrontPaymentAmountStorage, _contractId);
            store.set(budgetUpfrontPaymentAmountStorage, _contractId, _currentUpfrontPaymentAmount.add(_value));
        }
    }

    function _decrementLockedTerminationAmount(bytes32 _contractId, uint _value) internal {
        store.set(terminationLockedBalanceStorage, _contractId, _getContractLockedTerminationAmount(_contractId).sub(_value));
    }

    function _incrementCompletedPaymentValue(bytes32 _contractId, uint _value) internal {
        uint _completedPaymentsBalance = _getContractAccumulatedPaymentAmount(_contractId);
        store.set(completedPaymentsBalanceStorage, _contractId, _completedPaymentsBalance.add(_value));
    }

    function _decrementCompletedPaymentValue(bytes32 _contractId, uint _value) internal {
        uint _completedPaymentsBalance = _getContractAccumulatedPaymentAmount(_contractId);
        store.set(completedPaymentsBalanceStorage, _contractId, _completedPaymentsBalance.sub(_value));
    }
}

// File: contracts/labor-contract/LaborContractBase.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;




interface LaborContractBaseInitializable {

    function initLaborContract(
        address _owner,
        address _storage,
        bytes32 _crate
        ) external;

    function setExtensionContracts(
        address _signable,
        address _terminatable,
        address _disputable,
        address _completable,
        address _tasksProposable
    ) external;
}


interface LaborContractBaseGeneralizable {
    function getPaymentRequirements(bytes32 _contractId) external view returns (bool _lockFullBudget, uint8 _paymentTimeline);
    function getContractParties(bytes32 _contractId) external view returns (address _employer, address _assignee);
    function getContractState(bytes32 _contractId) external view returns (uint8 _state);
}


interface LaborContractBase {

    /// @notice Registers contract by an assignee that was negotiated by both parties and now is ready
    ///		for the next step - financial relationships. Then signs registered contract.
    /// If job contract is taking place then `_signature` should be based on arbiter setting
    ///     (see EscrowBaseInterface#setArbiter).
    /// If dispute contract is taking place then `_expireAtBlock`, `_salt`, `_signature` should skipped.
    /// @param _workflow workflow smart contract address that could be used for time tracking; workflow specific
    /// @param _escrow escrow smart contract for locking contract budget
    /// @param _data initialization data for a contract
    /// @param _expireAtBlock signature's expiration block
    /// @param _salt signature's unique identifier
    /// @param _signature signature of signed data
    /// @return result code of an operation
    function createContractAndSign(
        bytes32 _contractId,
        EscrowBaseInterface _escrow,
        WorkflowBase _workflow,
        bytes _data,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external returns (uint);
}


interface LaborContractBaseOperationable {

    /// @notice Callback function that is supposed to be called from associated workflow.
    ///     Should be called on key operations that do not require any payment during execution.
    /// @param _contractId contract identifier
    /// @param _operationCode code of performed operation
    function onOperation(bytes32 _contractId, string _operationCode) external;

    /// @notice Callback function that is supposed to be called from associated workflow.
    ///     Should be called on payable operations, for example, task completion confirmation.
    /// @param _contractId contract identifier
    /// @param _operationCode code of performed operation
    /// @param _depositValue value to deposit (if needed, should include surchange percent)
    /// @param _value value to be withdrawn from escrow
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _salt random bytes to identify signed data
    /// @param _signature signature provided by employer
    function onWithdrawOperation(
        bytes32 _contractId,
        string _operationCode,
        uint _depositValue,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external payable;
}


interface LaborContractBaseSignable {

    /// @notice Calculates how much is needed to start a contract.
    /// @param _contractId contract identifier
    function getLockingDepositBalance(bytes32 _contractId) external view returns (uint);

    /// @dev Calculates how much is needed to start a contract.
    /// @return
    /// @return _values[0] tasks budget
    /// @return _values[1] deposit fee amount
    /// @return _values[2] locked termination amount
    /// @return _values[3] initial (upfront) payment amount
    /// @return _values[4] upfront withdraw fee amount
    function getLockingContractDetails(bytes32 _contractId) external view returns (uint[] _values);

    /// @notice Signs registered contract by an assignee. This operation precedes any other
    ///     sign methods of other parties.
    /// If job contract is taking place then `_signature` should be based on arbiter setting
    ///     (see EscrowBaseInterface#setArbiter).
    /// If dispute contract is taking place then `_expireAtBlock`, `_salt`, `_signature` should skipped.
    /// @param _contractId contract identifier
    /// @param _documentHash hash of a document on which parties have an agreement
    /// @param _expireAtBlock signature's expiration block
    /// @param _salt signature's unique identifier
    /// @param _signature signature of signed data
    /// @return result code of an operation
    function sign(
        bytes32 _contractId,
        bytes32 _documentHash,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    ) external returns (uint);

    /// @notice Allows an assignee to revoke her sign when the contract `_contractId` has not started yet.
    /// @return result code of an operation
    function revokeSign(bytes32 _contractId) external returns (uint);

    /// @notice Signs contract and deposits to it, so it becomes ready for work.
    ///     Should be done as the latest sign among all signs because it locks currency
    /// If job contract is taking place then `_signature` should be based on artibter setting
    ///     (see EscrowBaseInterface#setArbiter).
    /// If dispute contract is taking place then `_signature` should be based on initiating escrow dispute
    ///     (see EscrowBaseInterface#initiateDispute).
    /// @param _contractId contract identifier
    /// @param _documentHash hash of a document on which parties have an agreement
    /// @param _value amount of deposited currency
    /// @param _expireAtBlock signature's expiration block (the same as it was in assignee's sign)
    /// @param _salt signature's unique identifier (the same as it was in assignee's sign)
    /// @param _signature signature of signed data (signed data should be the same as it was in assignee's sign)
    /// @return result code of an operation
    function signAndDeposit(
        bytes32 _contractId,
        bytes32 _documentHash,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external payable returns (uint);
}


interface LaborContractBaseCompletable {

    /// @notice Calculates how much is needed to complete a contract
    ///     (in cases when payment is performed after all tasks and no escrow locked balance exists).
    /// @param _contractId contract identifier
    /// @return _depositValue how much should be deposited by employer to resolve contract completion
    /// @return _employerPaybackValue how much an employer gets back
    /// @return _assigneeResolveValue how much an assignee will be paid
    function getCompletionContractDepositBalance(
        bytes32 _contractId
    )
    external
    view
    returns (
        uint _depositValue,
        uint _employerPaybackValue,
        uint _assigneeResolveValue
    );

    /// @dev Calculates how much is needed to complete a contract.
    /// @return
    /// @return _values[0] already completed and paid amount
    /// @return _values[1] completed but not paid (means it will be paid eventually)
    /// @return _values[2] unpaid (left) tasks budget amount (not completed)
    /// @return _values[3] escrow current balance
    /// @return _values[4] need to deposit amount
    /// @return _values[5] deposit fee value
    /// @return _values[6] returned amount to employer
    /// @return _values[7] paid amount to assignee
    /// @return _values[8] locked termination amount
    /// @return _values[9] withdraw fee amount
    function getCompletionContractDetails(bytes32 _contractId) external view returns (uint[] _values);

    /// @notice Completes the contract and resolves debts for both parties.
    ///     No actions with contract will be available after that.
    ///     Signature should present data for releasing termination escrow to the assignee and
    ///     termination remainder + budget escrow to the employer. Escrow balance should be empty
    ///     after execution - escrow will be flushed after that.
    ///     See EscrowBaseInterface#releaseNegotiatedPayment for more details.
    /// @param _contractId contract identifier
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _salt random bytes to identify signed data
    /// @param _signatures concatenated signatures produced by employer and assignee
    /// @return result code of an operation
    function completeContract(
        bytes32 _contractId,
        uint _expireAtBlock,
        uint _salt,
        bytes _signatures
        ) external payable returns (uint);
}


interface LaborContractBaseTerminatable {

    /// @notice Gets details about depositing amount that is required to initiate termination process.
    /// @param _contractId contract identifier
    /// @param _terminationId termination identifier
    /// @return amount that is required to deposit by termination initiator
    function getTerminationInitiateDepositDetails(bytes32 _contractId, uint _terminationId) external view returns (uint);

    /// @notice Gets details about depositing amount that is required to cancel termination process.
    /// @param _contractId contract identifier
    /// @param _terminationId termination identifier
    /// @return amount that is required to deposit by termination confirmator
    function getTerminationCancelDepositDetails(bytes32 _contractId, uint _terminationId) external view returns (uint);

    /// @notice Gets details about depositing amount that is required to confirm termination process.
    /// @param _contractId contract identifier
    /// @param _terminationId termination identifier
    /// @return amount that is required to deposit by termination confirmator
    function getTerminationConfirmDepositDetails(bytes32 _contractId, uint _terminationId) external view returns (uint);

    /// @notice Calculates requested termination conditions for the contract `_contractId`.
    /// @param _contractId contract identifier
    /// @param _terminationId termination condition identifier
    /// @return _employerValue amount that will return back to the employer
    /// @return _assigneeValue amount that will go to the assignee
    function getTerminationPaymentAmounts(
        bytes32 _contractId,
        uint _terminationId
    )
    external
    view
    returns (uint _employerValue, uint _assigneeValue);

    /// @dev Calculates requested termination conditions for the contract `_contractId`.
    /// @param _contractId contract identifier
    /// @param _terminationId termination condition identifier
    /// @return _values[0] termination amount
    /// @return _values[1] employer's amount
    /// @return _values[2] assignee's amount
    /// @return _values[3] initiator type
    /// @return _values[4] receiver type
    /// @return _values[5] unspent upfront amount that would be returned to an employer
    /// @return _values[6] need to deposit amount on termination initiation
    /// @return _values[7] need to deposit amount on termination confirmation
    /// @return _values[8] need to pay for tasks in case if they are competed but not paid
    /// @return _values[9] withdraw assignee fee amount
    function getTerminationContractDetails(bytes32 _contractId, uint _terminationId) external view returns (uint[] _values);

    /// @notice Starts termination negotiations by any party (employer or assignee)
    ///     Is not applicable for disputes.
    /// @param _contractId contract identifier
    /// @param _terminationId termination identifier; type of termination condition should
    ///     be assosiated with the initiator
    /// @param _value value to deposit, duplicated as a parameter to secure from unintended deposits
    /// @param _comment additional comments about termination reason or other notes
    /// @return result code of an operation
    function initiateTermination(
        bytes32 _contractId,
        uint32 _terminationId,
        uint _value,
        string _comment
        ) external payable returns (uint);

    /// @notice Cancels termination request that has not confirmed yet.
    ///     Should be called by the termination initiator
    ///     Is not applicable for disputes.
    /// @param _contractId contract identifier
    /// @return result code of an operation
    function cancelTerminationRequest(bytes32 _contractId) external returns (uint);

    /// @notice Cancels termination request that has not confirmed yet.
    ///     Should be called by the termination initiator.
    ///     Is not applicable for disputes.
    ///
    ///     If a deposit was made during termination initiation stage and
    ///     'getTerminationCancelDepositDetails()' returns non-zero result then the opposite
    ///     party should sign that amount for withdrawal and pass to termination's
    ///     initiator.
    ///     When initiator is an assignee then an employer should sign a message for
    ///     EscrowBaseInterface#releaseBuyerPayment method.
    ///     When initiator is an employer then an assignee should sign a message for
    ///     EscrowBaseInterface#sendSellerPayback method.
    ///     Otherwise expireAtBlock, salt and signature should be skipped.
    /// @param _contractId contract identifier
    /// @param _expireAtBlock contract identifier
    /// @param _salt contract identifier
    /// @param _signature contract identifier
    /// @return result code of an operation
    function cancelTerminationRequestWithApproval(
        bytes32 _contractId,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
        ) external returns (uint);

    /// @notice Performs confirmation of requested termination and terminates contract.
    ///     Is not applicable for disputes.
    ///     Should be signed by both parties that means they are both aware and agreed on conditions.
    ///     Signature should present data for releasing termination escrow to the assignee and
    ///     termination remainder + budget escrow to the employer. Escrow balance should be empty
    ///     after execution - escrow will be flushed after that.
    ///     See EscrowBaseInterface#releaseNegotiatedPayment for more details.
    /// @param _contractId contract identifier
    /// @param _value value to deposit, duplicated as a parameter to secure from unintended withdrawals
    /// @param _expireAtBlock expiry block after which transaction will be invalid. Should be the same for
    ///     tasks payment and for negotiated payment.
    /// @param _tasksSalt tasks random bytes to identify signed data
    ///     Skip when no payment is required.
    /// @param _tasksSignature signature of EscrowBaseInterface#releaseBuyerPayment message
    ///     Skip when no payment is required.
    /// @param _salt random bytes to identify signed data
    /// @param _signatures concatenated signatures produced by employer and assignee
    /// @return result code of an operation
    function confirmTermination(
        bytes32 _contractId,
        uint _value,
        uint _expireAtBlock,
        uint _tasksSalt,
        bytes _tasksSignature,
        uint _salt,
        bytes _signatures
        ) external payable returns (uint);
}


interface LaborContractBaseDisputable {

    /// @notice Gets details about contract resolvement by an arbiter.
    /// @param _contractId contract identifier
    /// @param _assigneeValue value that will go to an assignee
    /// @return _values[0] employer's amount
    /// @return _values[1] withdraw fee amount (for assignee)
    function getResolvingContractDetails(bytes32 _contractId, uint _assigneeValue) external view returns (uint[] _values);

    /// @notice Resolves the dispute in contract (if such exists).
    ///     Sends provided percent `_assigneePercent` to the underlying
    ///     contract assignee, the remainder - to contract employer.
    ///     No actions with contract will be available after that.
    ///     Signature should present data for releasing full escrow balance and split
    ///     it amont parties in a dispute. Escrow balance should be empty
    ///     after execution - escrow will be flushed after that.
    ///     See EscrowBaseInterface#releaseDisputedPayment for more details.
    /// @param _contractId contract identifier
    /// @param _assigneeValue part of the escrow balance that will go to the assignee
    ///     of disputed contract
    /// @param _expireAtBlock expiry block after which transaction will be invalid
    /// @param _signature signature provided by dispute assignee (base contract's arbiter)
    /// @return result code of an operation
    function resolveContract(
        bytes32 _contractId,
        uint _assigneeValue,
        uint _expireAtBlock,
        bytes _signature
        ) external returns (uint);
}


interface LaborContractBaseTasksProposable {

    /// @notice Gets details about proposed tasks for contract `_contractId`.
    /// @param _contractId contract identifier
    /// @return _values[0] proposed tasks budget
    /// @return _values[1] amount needed to be deposited
    /// @return _values[2] employer's fee amount included into deposit
    /// @return _values[3] termination amount needed to be locked additionally
    /// @return _values[4] upfront amount
    /// @return _values[5] assignee's fee amount that will be taken fron upfront amount
    function getContractProposedTasksDetails(bytes32 _contractId) external view returns (uint[] _values);

    /// @notice Puts new tasks of a contract `_contractId` to an approval state for an employer.
    ///     Should be called by an assignee.
    /// @param _contractId contract identifier
    /// @param _updatedDocumentHash document hash of the updated contract
    /// @param _data tasks and task penalty that are going to be added
    /// @return result code of an operation
    function proposeTasks(
        bytes32 _contractId,
        bytes32 _updatedDocumentHash,
        bytes _data
        ) external returns (uint);

    /// @notice Accepts proposed tasks for a contract `_contractId`
    ///     and adds tasks to a contract's workflow.
    ///     Should be called by an employer.
    /// @param _contractId contract identifier
    /// @param _updatedDocumentHash document hash of the updated contract
    /// @param _value value to be deposited for provided tasks
    /// @return result code of an operation
    function acceptProposedTasksAndDeposit(
        bytes32 _contractId,
        bytes32 _updatedDocumentHash,
        uint _value
        ) external payable returns (uint);
}

// File: contracts/labor-contract/LaborLib.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;





library LaborLib {

	using SafeMath for uint;

	function _calculateContractTermination(
        DataParser.ContractData memory /* _contractInfo */,
        DataParser.TerminationData memory _terminationInfo,
        uint _totalBudget,
        uint _escrowBalance,
        uint _leftToTransferAmount,
		uint _precision
    )
    internal
    pure
    returns (
        uint _employerValue,
        uint _assigneeValue
    ) {
        uint _fullTerminationAmount = DataParser.getTerminationResultValue(
            _terminationInfo,
            _totalBudget,
            _precision
        );

        if (_terminationInfo.payToType == uint8(DataParser.TerminationParty.TERMINATION_ASSIGNEE)) {
            _assigneeValue = _assigneeValue.add(_fullTerminationAmount);
        } else if (_terminationInfo.payToType == uint8(DataParser.TerminationParty.TERMINATION_EMPLOYER)) {
            _employerValue = _employerValue.add(_fullTerminationAmount);
        } else {
            revert("C_TPT"); // Invalid Termination payTo
        }

        _assigneeValue = _assigneeValue.add(_leftToTransferAmount);

        uint _reminder = _escrowBalance.sub(_fullTerminationAmount).sub(_leftToTransferAmount);
        _employerValue = _employerValue.add(_reminder);

        require(_escrowBalance >= _fullTerminationAmount.add(_leftToTransferAmount), "C_TA"); // Invalid Termination amount
    }

	function _calculateContractInitiateTerminationExcessFare(
        DataParser.ContractData memory _contractInfo,
        DataParser.TerminationData memory _terminationInfo,
        DataParser.TerminationParty _forParty,
        uint _accumulatedBalance,
        uint _escrowBalance,
        uint _totalBudget,
        uint _upfrontRefund,
		uint _precision
    )
    internal
    pure
    returns (
        uint _fare,
        uint _fareToEscrow,
        uint _terminationAmount
    ) {
        if (
            uint8(_forParty) == _terminationInfo.initiatorType &&
            _terminationInfo.initiatorType == uint8(DataParser.TerminationParty.TERMINATION_ASSIGNEE)
        ) {
            _terminationAmount = _calculateContractTerminationAssigneeRepay(_terminationInfo, _totalBudget, _precision);
            _fare = _fare
                .add(_upfrontRefund)
                .add(_terminationAmount);
            _fareToEscrow = _fare;
            return;
        }

        if (
            uint8(_forParty) == _terminationInfo.initiatorType &&
            _terminationInfo.initiatorType == uint8(DataParser.TerminationParty.TERMINATION_EMPLOYER) &&
            _contractInfo.paymentTimeline == uint8(DataParser.PaymentTimeline.PAY_BY_PROJECT)
        ) {
            _fare = _calculateExcessFareForProjectTimeline(_escrowBalance, _accumulatedBalance);
            _fareToEscrow = _fare;
        }
    }

	function _calculateContractCancelTerminationExcessFare(
        DataParser.ContractData memory /* _contractInfo */,
        DataParser.TerminationData memory _terminationInfo,
        DataParser.TerminationParty _forParty,
        uint /* _accumulatedBalance */,
        uint /* _escrowBalance */,
        uint _totalBudget,
        uint _upfrontRefund,
		uint _precision
    )
    internal
    pure
    returns (
        uint _fare,
        uint _fareToEscrow,
        uint _terminationAmount
    ) {
        if (
            uint8(_forParty) == _terminationInfo.initiatorType &&
            _terminationInfo.initiatorType == uint8(DataParser.TerminationParty.TERMINATION_ASSIGNEE)
        ) {
            _terminationAmount = _calculateContractTerminationAssigneeRepay(_terminationInfo, _totalBudget, _precision);
            _fare = _fare
                .add(_upfrontRefund)
                .add(_terminationAmount);
            _fareToEscrow = _fare;
        }
    }

    function _calculateContractConfirmTerminationExcessFare(
        DataParser.ContractData memory _contractInfo,
        DataParser.TerminationData memory _terminationInfo,
        DataParser.TerminationParty _forParty,
        uint _accumulatedBalance,
        uint _escrowBalance,
        uint _totalBudget,
        uint _upfrontRefund,
		uint _precision
    )
    internal
    pure
    returns (
        uint _fare,
        uint _fareToEscrow,
        uint _terminationAmount
    ) {
        // NOTE: means that confirmation is performed by an employer
        if (
            uint8(_forParty) != _terminationInfo.initiatorType &&
            _terminationInfo.initiatorType == uint8(DataParser.TerminationParty.TERMINATION_ASSIGNEE) &&
            _contractInfo.paymentTimeline == uint8(DataParser.PaymentTimeline.PAY_BY_PROJECT)
        ) {
            _fare = _calculateExcessFareForProjectTimeline(_escrowBalance, _accumulatedBalance);
            _fareToEscrow = _fare;
            return;
        }

        // NOTE: means that confirmation is performed by an assignee
        if (
            uint8(_forParty) != _terminationInfo.initiatorType &&
            _terminationInfo.initiatorType == uint8(DataParser.TerminationParty.TERMINATION_EMPLOYER)
        ) {
            _terminationAmount = _calculateContractTerminationAssigneeRepay(_terminationInfo, _totalBudget, _precision);
            _fare = _fare
                .add(_upfrontRefund)
                .add(_terminationAmount);
            _fareToEscrow = _fare;
        }
    }

    function _calculateExcessFareForProjectTimeline(
        uint _escrowBalance,
        uint _accumulatedBalance
    )
    internal
    pure
    returns (uint _depositValue)
    {
        if (_accumulatedBalance > _escrowBalance) {
            _depositValue = _accumulatedBalance.sub(_escrowBalance);
        }
    }

    function _calculateContractTerminationAssigneeRepay(
        DataParser.TerminationData memory _terminationInfo,
        uint _totalBudget,
		uint _precision
    )
    internal
    pure
    returns (uint)
    {
        if (_terminationInfo.payToType == uint8(DataParser.TerminationParty.TERMINATION_EMPLOYER)) {
            uint _terminationValue = DataParser.getTerminationResultValue(
                _terminationInfo,
                _totalBudget,
                _precision
            );
            return _terminationValue;
        }
    }


    function _calculateContractCompletion(
        DataParser.ContractData memory _contractInfo,
        uint _escrowBalance,
        uint _accumulatedBalance
    )
    internal
    pure
    returns (
        uint _depositValue,
        uint _employerValue,
        uint _assigneeValue
    ) {
        if (_contractInfo.paymentTimeline == uint8(DataParser.PaymentTimeline.PAY_BY_TASK)) {
            _employerValue = _escrowBalance;

            assert(_escrowBalance == _employerValue.add(_assigneeValue));
            return;
        } else if (_contractInfo.paymentTimeline == uint8(DataParser.PaymentTimeline.PAY_BY_PROJECT)) {
            if (_accumulatedBalance > _escrowBalance) {
                _depositValue = _accumulatedBalance.sub(_escrowBalance);
            }

            if (_escrowBalance > _accumulatedBalance) {
                _employerValue = _escrowBalance.sub(_accumulatedBalance);
            }

            _assigneeValue = _accumulatedBalance;

            assert(_escrowBalance.add(_depositValue) == _employerValue.add(_assigneeValue));
            return;
        }

        revert("C_PI");
    }


    function _calculateContractSignDepositAmount(
        DataParser.ContractData memory _contractInfo,
        uint _totalBudget,
        uint _upfrontAmount,
        uint _terminationLockedAmount,
        uint16 _feeValue,
        uint _feePrecision
    )
    internal
    pure
    returns (
        uint _requiredDepositAmount,
        uint _initialTransferAmount,
        uint _serviceFee
    ) {
        uint _totalBudgetFee = PercentCalculator.getPercent(_totalBudget, _feeValue, _feePrecision);
        _serviceFee = _serviceFee.add(_totalBudgetFee);

        _initialTransferAmount = _initialTransferAmount.add(_upfrontAmount);
        _requiredDepositAmount = _requiredDepositAmount.add(_terminationLockedAmount);

        if (_contractInfo.lockFullBudget) {
            _requiredDepositAmount = _requiredDepositAmount.add(_totalBudget);
        }
        else {
            _requiredDepositAmount = _requiredDepositAmount.add(_initialTransferAmount);
        }

        _requiredDepositAmount = _requiredDepositAmount.add(_serviceFee);

        assert(_requiredDepositAmount.sub(_serviceFee) >= _initialTransferAmount);
    }

    function _findMaxTerminationValue(
        DataParser.TerminationData[] memory _terminations,
        uint _totalBudget,
        uint _precision
    )
    internal
    pure
    returns (uint _maxTerminationAmount)
    {
        for (uint _terminationIndex = 0; _terminationIndex < _terminations.length; ++_terminationIndex) {
            DataParser.TerminationData memory _termination = _terminations[_terminationIndex];
            if (_termination.payToType != uint8(DataParser.TerminationParty.TERMINATION_ASSIGNEE)) {
                continue;
            }

            uint _fullTerminationAmount = DataParser.getTerminationResultValue(_termination, _totalBudget, _precision);

            if (_maxTerminationAmount < _fullTerminationAmount) {
                _maxTerminationAmount = _fullTerminationAmount;
            }
        }
    }
}

// File: contracts/labor-contract/LaborContractCreatable.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;





contract LaborContractCreatable is LaborContractAbstract {

    function createContract(
        bytes32 _contractId,
        EscrowBaseInterface _escrow,
        WorkflowBase _workflow,
        bytes _data
    )
    internal
    onlyInState(_contractId, State.NOT_INITIALIZED)
    returns (DataParser.ContractData memory _contractInfo)
    {
        require(address(_escrow) != 0x0, "C_IA");
        require(address(_workflow) != 0x0, "C_IA");
        require(
            _data.length >= DataParser._getRawLengthForDataStructure(uint8(DataParser.DataStructureType.CONTRACT)) + 1 + DataParser._getRawLengthForDataStructure(uint8(DataParser.DataStructureType.TASK)) + 1,
            "C_II"
        ); // DATA_STRUCTURE_TYPE == CONTRACT

        store.set(escrowStorage, _contractId, address(_escrow));
        store.set(workflowStorage, _contractId, address(_workflow));

        /**
          1. Handle contract data
         */
        _contractInfo = _handleContract(_contractId, _data);

        /**
         2. Register provided workflow for created contract
         */
        require(OK == _workflow.registerContract(_contractId, address(this)), "C_RC");
        store.set(workflowStorage, _contractId, _workflow);

        /**
          3. Handle provided tasks: find out upfront payment and full contract budget
         */
        (uint _totalContractBudget, uint _upfrontBudget) = _workflow.addWorkflowData(_contractId, address(this), _data);
        require(_totalContractBudget > 0, "C_B");

        store.set(totalBudgetAmountStorage, _contractId, _totalContractBudget);
        _incrementUpfrontPaymentAmount(_contractId, _upfrontBudget);

        /**
          4. Handle termination conditions: find maximum termination amont
         */
        uint _terminationValueToLock = _handleTermination(_contractId, _totalContractBudget, _data);
        if (_terminationValueToLock > 0) {
            _incrementLockedTerminationAmount(_contractId, _terminationValueToLock);
        }

        /**
          5. Final step: mark created contract as 'CREATED'
         */
        _setContractStateTo(_contractId, State.CREATED);

        emit ContractCreated(_contractId, _contractInfo.documentHash);
    }

    function _handleContract(bytes32 _contractId, bytes memory _data) private returns (DataParser.ContractData memory _contract) {
        _contract = DataParser.parseContractDataRawInput(_data);
        _assertParsedContract(_contract);

        bytes memory _dataToSave = DataParser.cutCleanArrayFromRawInput(
            _data,
            uint8(DataParser.DataStructureType.CONTRACT)
        ); /// @dev see DATA_STRUCTURE_TYPE
        store.set(contractInfoStorage, _contractId, _dataToSave);
    }

    function _assertParsedContract(DataParser.ContractData memory _contract) private view {
        DataParser.assertContractData(_contract);

        if (_contract.contractType == uint8(DataParser.ContractType.DISPUTE)) {
            DataParser.ContractData memory _underlyingContractInfo = DataParser.parseContractDataCleanInput(_getContractInfoBytes(_contract.linkedContractId));
            DataParser.assertDisputeContractWithLinkedContract(_underlyingContractInfo, _contract);
            _assertUnderlyingContractStateForDispute(_contract.linkedContractId);
        }
    }

    function _assertUnderlyingContractStateForDispute(bytes32 _contractId) private view {
        State _contractState = _getContractState(_contractId);
        require(
            _contractState == State.STARTED ||
            _contractState == State.TERMINATION_REQUESTED,
            "C_IS"
        );
    }

    function _handleTermination(bytes32 _contractId, uint _totalBudget, bytes memory _data) private returns (uint _maxTerminationAmount) {
        DataParser.TerminationData[] memory _terminations = DataParser.parseTerminationDataRawInput(_data);

        _maxTerminationAmount = LaborLib._findMaxTerminationValue(_terminations, _totalBudget, TERMINATION_PERCENT_PRECISION);

        if (_terminations.length > 0) {
            store.set(
                terminationsStorage,
                _contractId,
                DataParser.cutCleanArrayFromRawInput(_data, uint8(DataParser.DataStructureType.TERMINATION))
            ); /// @dev see DATA_STRUCTURE_TYPE
        }
    }
}

// File: contracts/libs/BytesLib.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
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

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {
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

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {
        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {
        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {
        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {
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

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
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

// File: contracts/labor-contract/LaborContractSignable.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;













/// @title Part of LaborContract functionality that provides signing implementation.
/// @dev Should be used as a library extension
contract LaborContractSignable is
    LaborContractBaseSignable,
    InitializableOwned,
    LaborContractAbstract,
    LaborContractCreatable
{

    /// @dev Indices for contract signable (locked) details values

    uint constant internal CONTRACT_SIGNABLE_DETAILS_TASKS_BUDGET = 0;
    uint constant internal CONTRACT_SIGNABLE_DETAILS_DEPOSIT_FEE_AMOUNT = 1;
    uint constant internal CONTRACT_SIGNABLE_DETAILS_TERMINATION_AMOUNT = 2;
    uint constant internal CONTRACT_SIGNABLE_DETAILS_UPFRONT_AMOUNT = 3;
    uint constant internal CONTRACT_SIGNABLE_DETAILS_WITHDRAW_FEE_AMOUNT = 4;
    uint constant internal CONTRACT_SIGNABLE_DETAILS_LENGTH = 5;


    constructor() StorageAdapter(Storage(0x0), "") public {
        // NOTE: don't need to initialize anything
    }

    function version() public pure returns (string) {
        return "0.1.0";
    }

    function getLockingDepositBalance(
        bytes32 _contractId
    )
    external
    view
    returns (uint _requiredDepositValue)
    {
        DataParser.ContractData memory _contractInfo = DataParser.parseContractDataCleanInput(_getContractInfoBytes(_contractId));
        (_requiredDepositValue,,) = _getSignDepositAmount(_contractId, _contractInfo);
    }

    function getLockingContractDetails(bytes32 _contractId) external view returns (uint[] _values) {
        _values = new uint[](CONTRACT_SIGNABLE_DETAILS_LENGTH);

        uint _tasksBudget = _getContractTotalBudgetAmount(_contractId);
        _values[CONTRACT_SIGNABLE_DETAILS_TASKS_BUDGET] = _tasksBudget;
        _values[CONTRACT_SIGNABLE_DETAILS_TERMINATION_AMOUNT] = _getContractLockedTerminationAmount(_contractId);

        EscrowBaseInterface _escrow = getEscrow(_contractId);
        (, uint16 _feeValue, uint _feePrecision) = _escrow.getServiceFeeInfo();
        _values[CONTRACT_SIGNABLE_DETAILS_DEPOSIT_FEE_AMOUNT] = PercentCalculator.getPercent(_tasksBudget, _feeValue, _feePrecision);
        _values[CONTRACT_SIGNABLE_DETAILS_UPFRONT_AMOUNT] = store.get(budgetUpfrontPaymentAmountStorage, _contractId);
        _values[CONTRACT_SIGNABLE_DETAILS_WITHDRAW_FEE_AMOUNT] = PercentCalculator.getPercent(
            _values[CONTRACT_SIGNABLE_DETAILS_UPFRONT_AMOUNT],
            _feeValue,
            _feePrecision
        );

    }

    function createContractAndSign(
        bytes32 _contractId,
        EscrowBaseInterface _escrow,
        WorkflowBase _workflow,
        bytes _data,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    external
    onlyInState(_contractId, State.NOT_INITIALIZED)
    returns (uint)
    {
        DataParser.ContractData memory _contractInfo = createContract(_contractId, _escrow, _workflow, _data);
        _sign(_contractInfo, _contractId, _expireAtBlock, _salt, _signature);

        return OK;
    }

    function sign(
        bytes32 _contractId,
        bytes32 _documentHash,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    external
    onlyInState(_contractId, State.CREATED)
    returns (uint)
    {
        DataParser.ContractData memory _contractInfo = DataParser.parseContractDataCleanInput(_getContractInfoBytes(_contractId));
        require(_documentHash == _contractInfo.documentHash, "C_H");
        _sign(_contractInfo, _contractId, _expireAtBlock, _salt, _signature);

        return OK;
    }

    function _sign(
        DataParser.ContractData memory _contractInfo,
        bytes32 _contractId,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    ) private {
        require(msg.sender == _contractInfo.assignee, "C_IC");

        _saveSignSignature(_contractId, _contractInfo, _salt, _signature);
        _setContractStateTo(_contractId, State.SIGNED);

        emit ContractSigned(_contractId, _contractInfo.documentHash, msg.sender, _expireAtBlock, _salt);
    }

    function revokeSign(
        bytes32 _contractId
    )
    external
    onlyInState(_contractId, State.SIGNED)
    returns (uint)
    {
        require(_isContractSigned(_contractId, msg.sender), "C_SGN");

        _revokeSignSignature(_contractId);
        _setContractStateTo(_contractId, State.CREATED);

        emit ContractSignRevoked(_contractId, msg.sender);
        return OK;
    }

    function signAndDeposit(
        bytes32 _contractId,
        bytes32 _documentHash,
        uint _value,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    external
    payable
    onlyInState(_contractId, State.SIGNED)
    returns (uint)
    {
        DataParser.ContractData memory _contractInfo = DataParser.parseContractDataCleanInput(_getContractInfoBytes(_contractId));
        require(_documentHash == _contractInfo.documentHash, "C_H");
        require(msg.sender == _contractInfo.employer, "C_IC");

        (uint _requiredDepositAmount, uint _initialTransferAmount, uint _serviceFee) = _getSignDepositAmount(_contractId, _contractInfo);
        require(_value == _requiredDepositAmount, "C_A");

        // TODO: version 2: cache escrow address

        _makeInitialDepositToEscrow(_contractId, _value, _initialTransferAmount, _serviceFee, _contractInfo);

        if (_contractInfo.contractType == uint8(DataParser.ContractType.JOB)) {
            _setDisputeArbiterToEscrow(_contractId, _contractInfo, _expireAtBlock, _salt, _signature);
            _cleanInvalidatedSalts(_contractId);
        } else if (_contractInfo.contractType == uint8(DataParser.ContractType.DISPUTE)) {
            _initiateDisputeToEscrow(_contractInfo.linkedContractId, _expireAtBlock, _salt, _signature);
            _setContractStateTo(_contractInfo.linkedContractId, State.UNDER_DISPUTE);
        }

        _setContractStateTo(_contractId, State.STARTED);

        emit ContractStarted(_contractId, _value);
        return OK;
    }

    /** PRIVATE */

    function _saveSignSignature(
        bytes32 _contractId,
        DataParser.ContractData memory _contractInfo,
        uint _salt,
        bytes _signature
    )
    private
    {
        bytes32 _key = keccak256(abi.encodePacked(_contractId, msg.sender));

        if (
            _contractInfo.contractType == uint8(DataParser.ContractType.JOB) &&
            _contractInfo.arbiter != 0x0
        ) {
            require(_salt != 0, "C_SS");
            require(Signatures.validSignaturesLength(_signature), "C_SS");
            require(
                !store.includes(signsInvalidatedSaltsStorage, _contractId, _salt),
                "C_SS"
            );

            store.set(signsSaltStorage, _key, _salt);
            store.set(signsSignatureStorage, _key, _signature);
        }

        store.set(signsStorage, _key, true);
    }

    function _revokeSignSignature(bytes32 _contractId) private {
        bytes32 _key = keccak256(abi.encodePacked(_contractId, msg.sender));
        uint _signSalt = store.get(signsSaltStorage, _key);

        store.set(signsStorage, _key, false);

        if (_signSalt != 0) {
            store.add(signsInvalidatedSaltsStorage, _contractId, _signSalt);
            store.set(signsSaltStorage, _key, 0);
            store.set(signsSignatureStorage, _key, new bytes(0));
        }
    }

    function _cleanInvalidatedSalts(bytes32 _contractId) private {
        uint _length = store.count(signsInvalidatedSaltsStorage, _contractId);

        for (uint _idx = 0; _idx < _length; ++_idx) {
            uint _valueToRemove = store.get(signsInvalidatedSaltsStorage, _contractId, _idx);
            store.remove(signsInvalidatedSaltsStorage, _contractId, _valueToRemove);
        }
    }

    /** ESCROW */

    function _makeInitialDepositToEscrow(
        bytes32 _contractId,
        uint _value,
        uint _initialTransferAmount,
        uint _serviceFee,
        DataParser.ContractData memory _contractInfo
    )
    private
    {
        uint _terminationDepositBalance = _getContractLockedTerminationAmount(_contractId);
        uint _depositAmount = _value.sub(_terminationDepositBalance).sub(_serviceFee);
        EscrowBaseInterface _escrow = getEscrow(_contractId);

        /**
            1. For contract budget we take fee from deposit value and transfer back upfront payment
         */
        require(
            OK == _escrow.createEscrow.value(SafeMath.min(_depositAmount, msg.value))
            (
                _contractId,
                _contractInfo.employer,
                _contractInfo.assignee,
                _contractInfo.paymentCurrencySymbol,
                _depositAmount,
                _initialTransferAmount,
                _getBuyerFeeFlag()
            ),
            "C_CE"
        );

        _incrementCompletedPaymentValue(_contractId, _initialTransferAmount);
        _incrementTransferredBalance(_contractId, _initialTransferAmount);

        /**
            2. For termination budget we take no deposit fee
         */
        if (_terminationDepositBalance > 0) {
            require(
                OK == _escrow.deposit.value(SafeMath.min(_terminationDepositBalance, msg.value))
                (
                    _contractId,
                    _contractInfo.employer,
                    _contractInfo.assignee,
                    _terminationDepositBalance,
                    0,
                    _getNoFeeFlag()
                ),
                "C_DE"
            );
            // _decrementLockedTerminationAmount(_contractId, _terminationDepositBalance);
        }

        /**
            3. Transfer service fee directly to fee recepient
         */
        require(
            OK == _escrow.retranslateToFeeRecipient.value(SafeMath.min(_serviceFee, msg.value))
            (
                _contractInfo.paymentCurrencySymbol,
                _contractInfo.employer,
                _serviceFee
            ),
            "C_FE"
        );
    }

    function _setDisputeArbiterToEscrow(
        bytes32 _contractId,
        DataParser.ContractData memory _contractInfo,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    private
    {
        if (_contractInfo.arbiter == 0x0) {
            return;
        }

        bytes memory _assigneeSignature = _getSignSignature(_contractId, _contractInfo.assignee);
        bytes memory _signatures = BytesLib.concat(_signature, _assigneeSignature);
        require(
            OK == getEscrow(_contractId).setArbiter(
                _contractId,
                _contractInfo.employer,
                _contractInfo.assignee,
                _contractInfo.arbiter,
                _expireAtBlock,
                _salt,
                _signatures
            ),
            "C_SA"
        );
    }

    function _initiateDisputeToEscrow(
        bytes32 _contractId,
        uint _expireAtBlock,
        uint _salt,
        bytes _signature
    )
    private
    {
        DataParser.ContractData memory _contractInfo = DataParser.parseContractDataCleanInput(_getContractInfoBytes(_contractId));

        if (_contractInfo.arbiter != 0x0) {
            require(
                OK == getEscrow(_contractId).initiateDispute(
                    _contractId,
                    _contractInfo.employer,
                    _contractInfo.assignee,
                    _expireAtBlock,
                    _salt,
                    _signature
                ),
                "C_IDE"
            );
        }
    }

    /** CALCULATIONS */

    /// @dev Makes calculation about initial deposit values.
    ///  Deposited value includes full contract budget service fee
    ///  independently from either 'lockFullBudget' is true or false.
    function _getSignDepositAmount(
        bytes32 _contractId,
        DataParser.ContractData memory _contractInfo
    )
    private
    view
    returns (
        uint _requiredDepositAmount,
        uint _initialTransferAmount,
        uint _serviceFee
    ) {
        EscrowBaseInterface _escrow = getEscrow(_contractId);
        (, uint16 _feeValue, uint _feePrecision) = _escrow.getServiceFeeInfo();

        return LaborLib._calculateContractSignDepositAmount(
            _contractInfo,
            _getContractTotalBudgetAmount(_contractId),
            store.get(budgetUpfrontPaymentAmountStorage, _contractId),
            _getContractLockedTerminationAmount(_contractId),
            _feeValue,
            _feePrecision
        );
    }

    /** PRIVATE GETTERS */

    function _getSignSignature(
        bytes32 _contractId,
        address _signer
    )
    private
    view
    returns (bytes memory _signature)
    {
        bytes32 _key = keccak256(abi.encodePacked(_contractId, _signer));
        _signature = store.get(signsSignatureStorage, _key);
    }

    function _isContractSigned(bytes32 _contractId, address _signer) private view returns (bool) {
        return store.get(signsStorage, keccak256(abi.encodePacked(_contractId, _signer)));
    }
}