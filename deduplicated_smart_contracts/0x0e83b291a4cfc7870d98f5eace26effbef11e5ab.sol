pragma solidity ^0.5.8;

import "./SafeMath.sol";
import "./Ownable.sol";

contract BaseToken is Ownable
{
    using SafeMath for uint256;

    // MARK: strings for error message.
    string constant public ERROR_APPROVED_BALANCE_NOT_ENOUGH = 'Reason: Approved balance is not enough.';
    string constant public ERROR_BALANCE_NOT_ENOUGH          = 'Reason: Balance is not enough.';
    string constant public ERROR_LOCKED                      = 'Reason: Locked';
    string constant public ERROR_ADDRESS_NOT_VALID           = 'Reason: Address is not valid.';
    string constant public ERROR_ADDRESS_IS_SAME             = 'Reason: Address is same.';
    string constant public ERROR_VALUE_NOT_VALID             = 'Reason: Value must be greater than 0.';
    string constant public ERROR_NO_LOCKUP                   = 'Reason: There is no lockup.';
    string constant public ERROR_DATE_TIME_NOT_VALID         = 'Reason: Datetime must grater or equals than zero.';

    // MARK: for token information.
    uint256 constant public E18                  = 1000000000000000000;
    uint256 constant public decimals             = 18;
    uint256 public totalSupply;

    struct Lock {
        uint256 amount;
        uint256 expiresAt;
    }

    mapping (address => uint256) public balances;
    mapping (address => mapping ( address => uint256 )) public approvals;
    mapping (address => Lock[]) public lockup;


    // MARK: events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Locked(address _who, uint256 _amount, uint256 _time);
    event Unlocked(address _who);
    event Burn(address indexed from, uint256 indexed value);

    constructor() public
    {
        balances[msg.sender] = totalSupply;
    }

    // MARK: functions for view data
    function balanceOf(address _who) view public returns (uint256)
    {
        return balances[_who];
    }

    function lockedBalanceOf(address _who) view public returns (uint256)
    {
        require(_who != address(0), ERROR_ADDRESS_NOT_VALID);

        uint256 lockedBalance = 0;
        if(lockup[_who].length > 0)
        {
            Lock[] storage locks = lockup[_who];

            uint256 length = locks.length;
            for (uint i = 0; i < length; i++)
            {
                if (now < locks[i].expiresAt)
                {
                    lockedBalance = lockedBalance.add(locks[i].amount);
                }
            }
        }

        return lockedBalance;
    }

    function allowance(address _owner, address _spender) view external returns (uint256)
    {
        return approvals[_owner][_spender];
    }

    // true: _who can transfer token
    // false: _who can't transfer token
    function isLocked(address _who, uint256 _value) view public returns(bool)
    {
        uint256 lockedBalance = lockedBalanceOf(_who);
        uint256 balance = balanceOf(_who);

        if(lockedBalance <= 0)
        {
            return false;
        }
        else
        {
            return !(balance > lockedBalance && balance.sub(lockedBalance) >= _value);
        }
    }

    // MARK: functions for token transfer
    // For holder registration, the first transaction by each address will probably consume about 2.5 times more gas.
    function transfer(address _to, uint256 _value) external onlyWhenNotStopped returns (bool)
    {
        require(_to != address(0));
        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(!isLocked(msg.sender, _value), ERROR_LOCKED);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external onlyWhenNotStopped returns (bool)
    {
        require(_from != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_to != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);
        require(balances[_from] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(approvals[_from][msg.sender] >= _value, ERROR_APPROVED_BALANCE_NOT_ENOUGH);
        require(!isLocked(_from, _value), ERROR_LOCKED);

        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferWithLock(address _to, uint256 _value, uint256 _time) onlyOwner external returns (bool)
    {
        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);

        lock(_to, _value, _time);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // MARK: utils for transfer authentication
    function approve(address _spender, uint256 _value) external onlyWhenNotStopped returns (bool)
    {
        require(_spender != address(0), ERROR_VALUE_NOT_VALID);
        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(msg.sender != _spender, ERROR_ADDRESS_IS_SAME);

        approvals[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // MARK: utils for amount of token
    // Lock up token until specific date time.
    function lock(address _who, uint256 _value, uint256 _dateTime) onlyOwner public
    {
        require(_who != address (0), ERROR_VALUE_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);

        lockup[_who].push(Lock(_value, _dateTime));
        emit Locked(_who, _value, _dateTime);
    }

    function unlock(address _who) onlyOwner external
    {
        require(lockup[_who].length > 0, ERROR_NO_LOCKUP);
        delete lockup[_who];
        emit Unlocked(_who);
    }

    function burn(uint256 _value) external
    {
        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(_value > 0, ERROR_VALUE_NOT_VALID);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
    }

    // destruct for only after token upgrade
    function close() onlyOwner public
    {
        selfdestruct(msg.sender);
    }
}