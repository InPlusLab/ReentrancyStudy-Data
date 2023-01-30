pragma solidity ^0.5.0;

import "./interfaces.sol";

contract Storage
{
    constructor() public {}

    event LogSender(address _sender);

    mapping(address => mapping(bytes32 => uint256)) public uint256s;
    mapping(address => mapping(bytes32 => address)) public addresses;
    mapping(address => mapping(bytes32 => string)) public strings;
    mapping(address => mapping(bytes32 => bool)) public bools;
    mapping(address => mapping(bytes32 => bytes1)) public bytes1s;

    function getSender()
        public
        view
        returns(address)
    {
        return msg.sender;
    }

    function setUint256(bytes32 _key, uint256 _value)
        public
    {
        uint256s[msg.sender][_key] = _value;
    }

    function setAddress(bytes32 _key, address _value)
        public
    {
        addresses[msg.sender][_key] = _value;
    }

    function setString(bytes32 _key, string memory _value)
        public
    {
        strings[msg.sender][_key] = _value;
    }

    function setBool(bytes32 _key, bool _value)
        public
    {
        bools[msg.sender][_key] = _value;
        emit LogSender(msg.sender);
    }

    function setByte(bytes32 _key, byte _value)
        public
    {
        bytes1s[msg.sender][_key] = _value;
    }

    function getUint256(bytes32 _key)
        public
        view
        returns(uint256)
    {
        return uint256s[msg.sender][_key];
    }

    function getAddress(bytes32 _key)
        public
        view
        returns(address)
    {
        return addresses[msg.sender][_key];
    }

    function getString(bytes32 _key)
        public
        view
        returns(string memory)
    {
        return strings[msg.sender][_key];
    }

    function getBool(bytes32 _key)
        public
        view
        returns(bool)
    {
        return bools[msg.sender][_key];
    }

    function getBytes1(bytes32 _key)
        public
        view
        returns(bytes1)
    {
        return bytes1s[msg.sender][_key];
    }

    // Encoding functions
    function enc(string memory _inputString)
        public
        pure
        returns (bytes32 _encodedString)
    {
        return keccak256(abi.encode(_inputString));
    }

    function encMap(address _address, string memory _member)
        public
        pure
        returns(bytes32)
    {
        return keccak256(abi.encode(_address, _member));
    }

    // Signer state
    function setSignerState(
            address parentFactory,
            ISigner.AccessState accessState,
            address owner,
            address roundTable,
            address vault,
            uint256 callNonce)
        public
    {
        setAddress("parentFactory", parentFactory);
        setUint256("accessState", uint256(accessState));
        setAddress("owner", owner);
        setAddress("roundTable", roundTable);
        setAddress("vault", vault);
        setUint256("callNonce", callNonce);
    }

    function getSignerState()
        public
        view
        returns(
            address parentFactory,
            ISigner.AccessState accessState,
            address owner,
            address roundTable,
            address vault,
            uint256 callNonce)
    {
        return (
            getAddress("parentFactory"),
            ISigner.AccessState(getUint256("accessState")),
            getAddress("owner"),
            getAddress("roundTable"),
            getAddress("vault"),
            getUint256("callNonce"));
    }

    // Vault related state
    function getLimit(address _tokenAddress)
        public
        view
        returns(
            uint256 _max,
            uint256 _spent,
            uint256 _startDateUtc,
            uint256 _windowSeconds,
            uint256 _lastLimitWindow,
            IVault.LimitState _state)
    {
        return (
            getUint256(encMap(_tokenAddress,"Limit.max")),
            getUint256(encMap(_tokenAddress,"Limit.spent")),
            getUint256(encMap(_tokenAddress,"Limit.startDateUtc")),
            getUint256(encMap(_tokenAddress,"Limit.windowSeconds")),
            getUint256(encMap(_tokenAddress,"Limit.lastLimitWindow")),
            IVault.LimitState(getUint256(encMap(_tokenAddress,"Limit.state"))));
    }

    function setLimit(
            address _tokenAddress,
            uint256 _max,
            uint256 _spent,
            uint256 _startDateUtc,
            uint256 _windowSeconds,
            uint256 _lastLimitWindow,
            IVault.LimitState _state)
        public
    {
        setUint256(encMap(_tokenAddress,"Limit.max"), _max);
        setUint256(encMap(_tokenAddress,"Limit.spent"), _spent);
        setUint256(encMap(_tokenAddress,"Limit.startDateUtc"), _startDateUtc);
        setUint256(encMap(_tokenAddress,"Limit.windowSeconds"), _windowSeconds);
        setUint256(encMap(_tokenAddress,"Limit.lastLimitWindow"), _lastLimitWindow);
        setUint256(encMap(_tokenAddress,"Limit.state"), uint256(_state));
    }

    function getChangeLimitProposal(address _tokenAddress)
        public
        view
        returns(
            uint256 _executionDate,
            uint256 _max,
            uint256 _startDateUtc,
            uint256 _windowSeconds)
    {
        return (
            getUint256(encMap(_tokenAddress,"ChangeLimitProposal.executionDate")),
            getUint256(encMap(_tokenAddress,"ChangeLimitProposal.max")),
            getUint256(encMap(_tokenAddress,"ChangeLimitProposal.startDateUtc")),
            getUint256(encMap(_tokenAddress,"ChangeLimitProposal.windowSeconds")));
    }

    function setChangeLimitProposal(
            address _tokenAddress,
            uint256 _executionDate,
            uint256 _max,
            uint256 _startDateUtc,
            uint256 _windowSeconds)
        public
    {
        setUint256(encMap(_tokenAddress,"ChangeLimitProposal.executionDate"), _executionDate);
        setUint256(encMap(_tokenAddress,"ChangeLimitProposal.max"), _max);
        setUint256(encMap(_tokenAddress,"ChangeLimitProposal.startDateUtc"), _startDateUtc);
        setUint256(encMap(_tokenAddress,"ChangeLimitProposal.windowSeconds"), _windowSeconds);
    }

    function setUpgradeProposal(
            uint256 _executionDate,
            address _implementation,
            uint256 _dateProposed,
            address _owner,
            bool _isExecuted)
        public
    {
        setUint256(enc("UpgradeProposal.executionDate"), _executionDate);
        setAddress(enc("UpgradeProposal.implementation"), _implementation);
        setUint256(enc("UpgradeProposal.dateProposed"), _dateProposed);
        setAddress(enc("UpgradeProposal.owner"), _owner);
        setBool(enc("UpgradeProposal.isExecuted"), _isExecuted);
    }

    function getUpgradeProposal()
        public
        view
        returns (
            uint256 _executionDate,
            address _implementation,
            uint256 _dateProposed,
            address _owner,
            bool _isExecuted)
    {
        _executionDate = getUint256(enc("UpgradeProposal.executionDate"));
        _implementation = getAddress(enc("UpgradeProposal.implementation"));
        _dateProposed = getUint256(enc("UpgradeProposal.dateProposed"));
        _owner = getAddress(enc("UpgradeProposal.owner"));
        _isExecuted = getBool(enc("UpgradeProposal.isExecuted"));
    }
}