pragma solidity ^0.5.7;


import "./Ownable.sol";
import "./SafeMath.sol";
import "./IManagement.sol";
import "./CoinExchangeRates.sol";
import "./Constants.sol";

contract Management is CoinExchangeRates{

    uint256 private feeValueInPercentage_;

    mapping(address => mapping(uint256 => bool)) private permissions_;

    mapping(uint256 => address) public contractRegistry;

    event PermissionsSet(address subject, uint256 permission, bool value);
    event ContractRegistered(uint256 key, address target);
    event FeeUpdated(uint256 valueInPercentage);

    constructor(uint256 _blobCoinPrice, uint256 _feeInPercentage)
    public
    CoinExchangeRates(_blobCoinPrice)
    {
        feeValueInPercentage_ = _feeInPercentage;
        permissions_[msg.sender][CAN_EXCHANGE_COINS] = true;
        permissions_[msg.sender][CAN_REGISTER_COINS] = true;
        permissions_[msg.sender][CAN_MINT_COINS] = true;
        permissions_[msg.sender][CAN_BURN_COINS] = true;
        permissions_[msg.sender][CAN_LOCK_COINS] = true;
    }

    function setPermission(
        address _address,
        uint256 _permission,
        bool _value
    )
    public
    onlyOwner
    {
        require(
            PERMITTED_COINS != _permission,
            ERROR_ACCESS_DENIED
        );
        permissions_[_address][_permission] = _value;
        emit PermissionsSet(_address, _permission, _value);
    }

    function setPermissionsForCoins(
        address _address,
        bool _value,
        uint256 _decimals
    )
    public
    onlyOwner
    {
        permissions_[_address][PERMITTED_COINS] = _value;
        internalSetPermissionsForCoins(_address, _value, _decimals);
        emit PermissionsSet(_address, PERMITTED_COINS, _value);
    }

    function registerContract(uint256 _key, address _target) public onlyOwner {
        contractRegistry[_key] = _target;
        emit ContractRegistered(_key, _target);
    }

    function setFeePercentage(
        uint256 _valueInPercentage
    )
    public
    onlyOwner
    {
        require(_valueInPercentage <= PERCENTS_ABS_MAX, ERROR_WRONG_AMOUNT);
        feeValueInPercentage_ = _valueInPercentage;
        emit FeeUpdated(_valueInPercentage);
    }

    function getFeePercentage()
    public
    view
    returns (uint256)
    {
        return feeValueInPercentage_;
    }

    function coinsHolder()
    public
    view
    returns (address)
    {
        if (contractRegistry[COIN_HOLDER] != address(0)) {
            return contractRegistry[COIN_HOLDER];
        }
        return owner();
    }

    function permissions(address _subject, uint256 _permissionBit)
    public
    view
    returns (bool)
    {
        return permissions_[_subject][_permissionBit];
    }
}
