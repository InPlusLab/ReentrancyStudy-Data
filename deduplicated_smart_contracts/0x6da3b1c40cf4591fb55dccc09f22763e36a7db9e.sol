pragma solidity >=0.4.21 <0.6.0;

import "./SafeMath.sol";
import './Ownable.sol';

/**
* @title TokenStorage
*/
contract TokenStorage  is Ownable{
    using SafeMath for uint256;

    //    mapping (address => bool) internal _allowedAccess;

    // Access Modifier for Storage contract
    address internal _registryContract;

    constructor() public {
        _owner = msg.sender;
        _totalSupply = 1000000000 * 10 ** 18;
        _balances[_owner] = _totalSupply;
    }

    function setProxyContractAndVersionOneDeligatee(address registryContract) onlyOwner public{
        require(registryContract != address(0), "InvalidAddress: invalid address passed for proxy contract");
        _registryContract = registryContract;
    }

    function getRegistryContract() view public returns(address){
        return _registryContract;
    }

    //    function addDeligateContract(address upgradedDeligatee) public{
    //        require(msg.sender == _registryContract, "AccessDenied: only registry contract allowed access");
    //        _allowedAccess[upgradedDeligatee] = true;
    //    }

    modifier onlyAllowedAccess() {
        require(msg.sender == _registryContract, "AccessDenied: This address is not allowed to access the storage");
        _;
    }

    // Allowances with its Getter and Setter
    mapping (address => mapping (address => uint256)) internal _allowances;

    function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyAllowedAccess {
        _allowances[_tokenHolder][_spender] = _value;
    }

    function getAllowance(address _tokenHolder, address _spender) public view onlyAllowedAccess returns(uint256){
        return _allowances[_tokenHolder][_spender];
    }


    // Balances with its Getter and Setter
    mapping (address => uint256) internal _balances;
    function addBalance(address _addr, uint256 _value) public onlyAllowedAccess {
        _balances[_addr] = _balances[_addr].add(_value);
    }

    function subBalance(address _addr, uint256 _value) public onlyAllowedAccess {
        _balances[_addr] = _balances[_addr].sub(_value);
    }

    function setBalance(address _addr, uint256 _value) public onlyAllowedAccess {
        _balances[_addr] = _value;
    }

    function getBalance(address _addr) public view onlyAllowedAccess returns(uint256){
        return _balances[_addr];
    }

    // Total Supply with Getter and Setter
    uint256 internal _totalSupply = 0;

    function addTotalSupply(uint256 _value) public onlyAllowedAccess {
        _totalSupply = _totalSupply.add(_value);
    }

    function subTotalSupply(uint256 _value) public onlyAllowedAccess {
        _totalSupply = _totalSupply.sub(_value);
    }

    function setTotalSupply(uint256 _value) public onlyAllowedAccess {
        _totalSupply = _value;
    }

    function getTotalSupply() public view onlyAllowedAccess returns(uint256) {
        return(_totalSupply);
    }


    // Locking Storage
    /**
    * @dev Reasons why a user's tokens have been locked
    */
    mapping(address => bytes32[]) internal lockReason;

    /**
     * @dev locked token structure
     */
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    /**
     * @dev Holds number & validity of tokens locked for a given reason for
     *      a specified address
     */
    mapping(address => mapping(bytes32 => lockToken)) internal locked;


    // Lock Access Functions
    function getLockedTokenAmount(address _of, bytes32 _reason) public view onlyAllowedAccess returns (uint256 amount){
        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    function getLockedTokensAtTime(address _of, bytes32 _reason, uint256 _time) public view onlyAllowedAccess returns(uint256 amount){
        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

    function getTotalLockedTokens(address _of) public view onlyAllowedAccess returns(uint256 amount){
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(getLockedTokenAmount(_of, lockReason[_of][i]));
        }
    }

    function extendTokenLock(address _of, bytes32 _reason, uint256 _time) public onlyAllowedAccess returns(uint256 amount, uint256 validity){

        locked[_of][_reason].validity = locked[_of][_reason].validity.add(_time);
        amount = locked[_of][_reason].amount;
        validity = locked[_of][_reason].validity;
    }

    function increaseLockAmount(address _of, bytes32 _reason, uint256 _amount) public onlyAllowedAccess returns(uint256 amount, uint256 validity){
        locked[_of][_reason].amount = locked[_of][_reason].amount.add(_amount);
        amount = locked[_of][_reason].amount;
        validity = locked[_of][_reason].validity;
    }

    function getUnlockable(address _of, bytes32 _reason) public view onlyAllowedAccess returns(uint256 amount){
        if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    function addLockedToken(address _of, bytes32 _reason, uint256 _amount, uint256 _validity) public onlyAllowedAccess {
        locked[_of][_reason] = lockToken(_amount, _validity, false);
    }

    function addLockReason(address _of, bytes32 _reason) public onlyAllowedAccess {
        lockReason[_of].push(_reason);
    }

    function getNumberOfLockReasons(address _of) public view onlyAllowedAccess returns(uint256 number){
        number = lockReason[_of].length;
    }

    function getLockReason(address _of, uint256 _i) public view onlyAllowedAccess returns(bytes32 reason){
        reason = lockReason[_of][_i];
    }

    function setClaimed(address _of, bytes32 _reason) public onlyAllowedAccess{
        locked[_of][_reason].claimed = true;
    }

    function caller(address _of) public view  onlyAllowedAccess returns(uint){
        return getTotalLockedTokens(_of);
    }
}