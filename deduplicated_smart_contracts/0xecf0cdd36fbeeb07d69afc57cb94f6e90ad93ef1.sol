/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

/**
 *Submitted for verification at Etherscan.io on 2019-05-28
*/

pragma solidity ^0.4.26;


        /**
         * @title SafeMath
         * @dev Unsigned math operations with safety checks that revert on error
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
                require(c / a == b);  
                return c;
        }

        /**
         * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
         */
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
                // Solidity only automatically asserts when dividing by 0
                require(b > 0);
                uint256 c = a / b;
                // assert(a == b * c + a % b); // There is no case in which this doesn't hold

                return c;
        }

        /**
         * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
         */
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
                require(b <= a);
                uint256 c = a - b;

                return c;
        }

        /**
         * @dev Adds two unsigned integers, reverts on overflow.
         */
        function add(uint256 a, uint256 b) internal pure returns (uint256) {
                uint256 c = a + b;
                require(c >= a);

                return c;
        }

        /**
         * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
         * reverts when dividing by zero.
         */
        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
                require(b != 0);
                return a % b;
        }
}


contract ERC20 {
      function totalSupply() public view returns (uint256);
      function balanceOf(address _who) public view returns (uint256);
      function transfer(address _to, uint256 _value) public returns (bool);
      function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
      function allowance(address _owner, address _spender) public view returns (uint256);
      function approve(address _spender, uint256 _value) public returns (bool);

      event Transfer(address indexed from, address indexed to, uint256 value);
      event Approval(address indexed owner, address indexed spender, uint256 value);

}


contract StandardToken is ERC20 {
        using SafeMath for uint256;

        uint256 public totalSupply;
        mapping(address => uint256) internal balances;
        mapping(address => mapping (address => uint256)) internal allowed;

        modifier validDestination( address _to )
        {
                require(_to != address(0x0), "Invalid address.");
                require(_to != address(this), "Invalid address.");
                _;
        }

        function totalSupply() public view returns (uint256) {
                return totalSupply;
        }

        function balanceOf(address _owner) public view returns (uint256) {
                return balances[_owner];
        }

        function transfer(address _to, uint256 _value)
                public
                validDestination(_to)
                returns (bool)
        {
                balances[msg.sender] = balances[msg.sender].sub(_value);
                balances[_to] = balances[_to].add(_value);
                emit Transfer(msg.sender, _to, _value);
                return true;
        }

        function transferFrom(address _from, address _to, uint256 _value)
                public
                validDestination(_to)
                returns (bool)
        {
                require(_value <= allowed[_from][msg.sender],"Exceed allowed.");

                balances[_from] = balances[_from].sub(_value);
                balances[_to] = balances[_to].add(_value);

                approve(msg.sender, allowed[_from][msg.sender].sub(_value));

                emit Transfer(_from, _to, _value);
                return true;
        }

        function burn(uint _value) public returns (bool)
        {
                balances[msg.sender] = balances[msg.sender].sub(_value);
                totalSupply = totalSupply.sub(_value);
                emit Transfer(msg.sender, address(0x0), _value);
                return true;
        }

        function burnFrom(address _from, uint256 _value) public validDestination(_from) returns (bool)
        {
                balances[_from] = balances[_from].sub(_value);
                totalSupply = totalSupply.sub(_value);
                emit Transfer(_from, address(0x0), _value);

                approve(msg.sender, allowed[_from][msg.sender].sub(_value));

                return true;
        }

        function approve(address _spender, uint256 _value) public validDestination(_spender) returns (bool) {
                require(_value <= 3 * 10 ** 11 * 10 ** 12);

                allowed[msg.sender][_spender] = _value;
                emit Approval(msg.sender, _spender, _value);
                return true;
        }

        function allowance(address _owner, address _spender) public view returns (uint256)
        {
                return allowed[_owner][_spender];
        }
}


contract Ownable {
        address public owner;

        event OwnershipTransferred(
                address indexed previousOwner,
                address indexed newOwner
        );

        constructor() public {
                owner = msg.sender;
        }

        modifier onlyOwner() {
                require(msg.sender == owner);
                _;
        }

        function transferOwnership(address _newOwner) public onlyOwner {
                require(_newOwner != address(0x0));
                emit OwnershipTransferred(owner, _newOwner);
                owner = _newOwner;
        }

}


contract Pausable is Ownable {
        event Pause();
        event Unpause();

        bool public paused = false;

        modifier whenNotPaused() {
                require(!paused);
                _;
        }

        modifier whenPaused() {
                require(paused);
                _;
        }

        function pause() public onlyOwner whenNotPaused {
                paused = true;
                emit Pause();
        }

        function unpause() public onlyOwner whenPaused {
                paused = false;
                emit Unpause();
        }
}


contract Freezable is Ownable {
        mapping (address => bool) public frozenAccount;

        event Freeze(address indexed target, bool frozen);
        event Unfreeze(address indexed target, bool frozen);

        modifier isNotFrozen(address _target) {
                require(!frozenAccount[_target]);
                _;
        }

        modifier isFrozen(address _target) {
                require(frozenAccount[_target]);
                _;
        }

        function freeze(address _target) public onlyOwner isNotFrozen(_target) {
                require(_target != address(0x0));

                frozenAccount[_target] = true;
                emit Freeze(_target, true);
        }

        function unfreeze(address _target) public onlyOwner isFrozen(_target) {
                require(_target != address(0x0));

                frozenAccount[_target] = false;
                emit Unfreeze(_target, false);
        }
}

        /**
         * @title Pausable token
         * @dev StandardToken modified with pausable transfers.
         **/
contract PausableToken is StandardToken, Pausable, Freezable {

        function transfer(address _to, uint256 _value)
                public
                whenNotPaused
                isNotFrozen(msg.sender)
                isNotFrozen(_to)
                returns (bool)
        {
                return super.transfer(_to, _value);
        }

        function transferFrom(address _from, address _to, uint256 _value)
                public
                whenNotPaused
                isNotFrozen(_from)
                isNotFrozen(_to)
                returns (bool)
        {
                return super.transferFrom(_from, _to, _value);
        }

        function burn(uint256 _value)
                public
                whenNotPaused
                isNotFrozen(msg.sender)
                returns (bool)
        {
                return super.burn(_value);
        }

        function burnFrom(address _to, uint256 _value)
                public
                whenNotPaused
                isNotFrozen(_to)
                returns (bool)
        {
                return super.burnFrom(_to, _value);
        }

        function approve(
                address _spender,
                uint256 _value
        )
                public
                whenNotPaused
                isNotFrozen(msg.sender)
                isNotFrozen(_spender)
                returns (bool)
        {
                return super.approve(_spender, _value);
        }

}

contract TimeLockable is Ownable {
        using SafeMath for uint256;

        uint256 private constant SECOND_IN_DAY = 86400;

        mapping (address => uint256) internal lockedBaseQuantity;

        event LockAccount(address indexed target, uint256 value);


        function setTimeLockAccount(address _target, uint256 _value)
                internal
                onlyOwner
                returns (bool)
        {
                require(_target != address(0));
                require(_value != 0);
                lockedBaseQuantity[_target] = lockedBaseQuantity[_target].add(_value);

                emit LockAccount(_target, _value);
                return true;
        }

        function lockedNow(address _target) internal view returns ( uint256 ) {
                if (lockedBaseQuantity[_target] == 0) return 0;
                return _getLockedRate(now) * lockedBaseQuantity[_target] / 100;
        }

        function _getLockedRate(uint256 _timeNow) private pure returns(uint256 lockedRate) {


                if (_timeNow >= 1615334400) {           // 2021-03-10
                        return 0;
                } else if (_timeNow >= 1612915200) {    // 2021-02-10
                        return 10;
                } else if (_timeNow >= 1610236800) {    // 2021-01-10
                        return 20;
                } else if (_timeNow >= 1607558400) {    // 2020-12-10
                        return 30;
                } else if (_timeNow >= 1604966400) {    // 2020-11-10
                        return 40;
                } else if (_timeNow >= 1602288000) {    // 2020-10-10
                        return 45;
                } else if (_timeNow >= 1599696000) {    // 2020-09-10
                        return 50;
                } else if (_timeNow >= 1597017600) {    // 2020-08-10
                        return 55;
                } else if (_timeNow >= 1594339200) {    // 2020-07-10
                        return 60;
                } else if (_timeNow >= 1591747200) {    // 2020-06-10
                        return 65;
                } else if (_timeNow >= 1589068800) {    // 2020-05-10
                        return 70;
                } else if (_timeNow >= 1586476800) {    // 2020-04-10
                        return 75;
                } else if (_timeNow >= 1583798400) {    // 2020-03-10
                        return 80;
                } else if (_timeNow >= 1581292800) {    // 2020-02-10
                        return 85;
                } else if (_timeNow >= 1578614400) {    // 2020-01-10
                        return 90;
                } else if (_timeNow >= 1575936000) {    // 2019-12-10
                        return 95;
                } else {    // before 2019-12-10
                        return 100;
                }
        }
}

        /**
         * @title DKHAN Token
         * @dev time lock(sequential unlock), puase, burn, freeze added.
         **/
contract DKHAN is PausableToken, TimeLockable  {
        using SafeMath for uint256;

        string  public  name;
        string  public  symbol;
        uint256 public  constant decimals = 12;
        uint256 public  totalSupply;

        constructor(
                uint256 initialSupply,
                string memory tokenName,
                string memory tokenSymbol
        )
                public
        {
                totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
                balances[msg.sender] = totalSupply;                     // Give the creator all initial tokens
                name = tokenName;                                       // Set the name for display purposes
                symbol = tokenSymbol;                                   // Set the symbol for display purposes
        }

        modifier canTransper(address _from, uint256 _value) {
                require(_value <= balances[_from], "Exceed balance");
                require(_value <= balanceAvailable(_from), "Exceed unlocked balance");
                _;
        }

        function balanceAvailable(address _from) public view returns ( uint256 ) {
                return balances[_from].sub(lockedNow(_from));
        }

        function lockedInfo(address _from) public view returns ( uint256 _lockedNow, uint256 _lockedAtFirst ) {
                return (lockedNow(_from), lockedBaseQuantity[_from]);
        }

        function lockAndTransfer(address _to, uint256 _value)
                public
                onlyOwner
                returns (bool)
        {
                setTimeLockAccount(_to, _value);
                return super.transfer(_to, _value);
        }

        function transfer(address _to, uint _value)
                public
                canTransper(msg.sender, _value)
                returns (bool)
        {
                return super.transfer(_to, _value);
        }

        function transferFrom(address _from, address _to, uint _value)
                public
                canTransper(_from, _value)
                returns (bool)
        {
                return super.transferFrom(_from, _to, _value);
        }

        function burn(uint _value)                              // Cannot burn locked amount
                public
                canTransper(msg.sender, _value)
                returns (bool)
        {
                return super.burn(_value);
        }

        function burnFrom(address _from, uint256 _value)        // Cannot burn locked amount
                public
                canTransper(_from, _value)
                returns (bool)
        {
                return super.burnFrom(_from, _value);
        }

}