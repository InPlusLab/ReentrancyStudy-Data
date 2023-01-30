pragma solidity ^0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


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
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
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
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

/**
 * admin manager
 */
contract AdminManager {
    event ChangeOwner(address _oldOwner, address _newOwner);
    event SetAdmin(address _address, bool _isAdmin);
    //constract's owner
    address public owner;
    //constract's admins. permission less than owner
    mapping(address=>bool) public admins;

    /**
     * constructor
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * modifier for some action only owner can do
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * modifier for some action only admin or owner can do
     */
    modifier onlyAdmins() {
        require(msg.sender == owner || admins[msg.sender]);
        _;
    }

    /**
     * change this constract's owner
     */
    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit ChangeOwner(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * add or delete admin
     */
    function setAdmin(address _address, bool _isAdmin) public onlyOwner {
        emit SetAdmin(_address, _isAdmin);
        if(!_isAdmin){
            delete admins[_address];
        }else{
            admins[_address] = true;
        }
    }
}

/**
 * pausable token 
 */
contract PausableToken is StandardToken, AdminManager {
    event SetPause(bool isPause);
    bool public paused = true;

    /**
     * modifier for pause constract. not contains admin and owner
     */
    modifier whenNotPaused() {
        if(paused) {
            require(msg.sender == owner || admins[msg.sender]);
        }
        _;
    }

    /**
     * @dev called by the owner to set new pause flags
     * pausedPublic can't be false while pausedOwnerAdmin is true
     */
    function setPause(bool _isPause) onlyAdmins public {
        require(paused != _isPause);
        paused = _isPause;
        emit SetPause(_isPause);
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

/**
 * lockadble token
 */
contract LockableToken is PausableToken {

    /**
     * lock data struct
     */
    struct LockData {
        uint256 balance;
        uint256 releaseTimeS;
    }

    event SetLock(address _address, uint256 _lockValue, uint256 _releaseTimeS);

    mapping (address => LockData) public locks;

    /**
     * if active balance is not enought. deny transaction
     */
    modifier whenNotLocked(address _from, uint256 _value) {
        require( activeBalanceOf(_from) >= _value );
        _;
    }

    /**
     * active balance of address
     */
    function activeBalanceOf(address _owner) public view returns (uint256) {
        if( uint256(now) < locks[_owner].releaseTimeS ) {
            return balances[_owner].sub(locks[_owner].balance);
        }
        return balances[_owner];
    }
    
    /**
     * lock one address
     * one address only be locked at the same time. 
     * because the gas reson, so not support multi lock of one address
     * 
     * @param _lockValue     how many tokens locked
     * @param _releaseTimeS  the lock release unix time 
     */
    function setLock(address _address, uint256 _lockValue, uint256 _releaseTimeS) onlyAdmins public {
        require( uint256(now) > locks[_address].releaseTimeS );
        locks[_address].balance = _lockValue;
        locks[_address].releaseTimeS = _releaseTimeS;
        emit SetLock(_address, _lockValue, _releaseTimeS);
    }

    function transfer(address _to, uint256 _value) public whenNotLocked(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotLocked(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}


contract EnjoyGameToken is LockableToken {
    event Burn(address indexed _burner, uint256 _value);

    string  public  constant name = "EnjoyGameToken";
    string  public  constant symbol = "EGT";
    uint8   public  constant decimals = 6;

    /**
     * constructor 
     */
    constructor() public {
        //set totalSupply
        totalSupply = 10**16;
        //init balances
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0x0), msg.sender, totalSupply);   
    }

    /**
     * transfer and lock this value
     * only called by admins (limit when setLock)
     */
    function transferAndLock(address _to, uint256 _value, uint256 _releaseTimeS) public returns (bool) {
        //at first, try lock address
        setLock(_to,_value,_releaseTimeS);

        if( !transfer(_to, _value) ){
            //revert with lock
            revert();
        }
        return true;
    }
}