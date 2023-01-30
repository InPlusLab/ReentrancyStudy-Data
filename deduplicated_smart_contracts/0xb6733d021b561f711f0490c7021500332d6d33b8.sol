/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        assert(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a);

        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
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
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
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
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}


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

/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* https://github.com/ethereum/EIPs/issues/20
* Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
contract StandardToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 totalSupply_;

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
        return balances[_owner];
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
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
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
	//防止事务顺序依赖攻击，从A改为B，要先改为0，再改为B，以避免被转走A+B
        require(_value==0 || allowed[msg.sender][_spender]==0);

        allowed[msg.sender][_spender] = _value;
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
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
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
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
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
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


/**
* @title Pausable token
* @dev StandardToken modified with pausable transfers.
**/
contract PausableERC20Token is StandardToken, Pausable {

    function transfer(
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}


/**
* @title Burnable Pausable Token
* @dev Pausable Token that can be irreversibly burned (destroyed).
*/
contract BurnablePausableERC20Token is PausableERC20Token {

    mapping (address => mapping (address => uint256)) internal allowedBurn;

    event Burn(address indexed burner, uint256 value);

    event ApprovalBurn(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function allowanceBurn(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowedBurn[_owner][_spender];
    }

    function approveBurn(address _spender, uint256 _value) public returns (bool) {
        allowedBurn[msg.sender][_spender] = _value;
        emit ApprovalBurn(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(
        uint256 _value
    ) 
        public
        whenNotPaused
    {
        _burn(msg.sender, _value);
    }

    /**
    * @dev Burns a specific amount of tokens from the target address and decrements allowance
    * @param _from address The address which you want to send tokens from
    * @param _value uint256 The amount of token to be burned
    */
    function burnFrom(
        address _from, 
        uint256 _value
    ) 
        public 
        whenNotPaused
    {
        require(_value <= allowedBurn[_from][msg.sender]);
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        allowedBurn[_from][msg.sender] = allowedBurn[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }

    function _burn(
        address _who, 
        uint256 _value
    ) 
        internal 
        whenNotPaused
    {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    function increaseBurnApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {
        allowedBurn[msg.sender][_spender] = (
        allowedBurn[msg.sender][_spender].add(_addedValue));
        emit ApprovalBurn(msg.sender, _spender, allowedBurn[msg.sender][_spender]);
        return true;
    }

    function decreaseBurnApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowedBurn[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowedBurn[msg.sender][_spender] = 0;
        } else {
            allowedBurn[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit ApprovalBurn(msg.sender, _spender, allowedBurn[msg.sender][_spender]);
        return true;
    }
}

contract FreezableBurnablePausableERC20Token is BurnablePausableERC20Token {
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);

    function freezeAccount(
        address target,
        bool freeze
    )
        public
        onlyOwner
    {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function transfer(
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        require(!frozenAccount[msg.sender], "Sender account freezed");
        require(!frozenAccount[_to], "Receiver account freezed");

        return super.transfer(_to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        require(!frozenAccount[msg.sender], "Sender account freezed");
        require(!frozenAccount[_from], "From account freezed");
        require(!frozenAccount[_to], "Receiver account freezed");

        return super.transferFrom(_from, _to, _value);
    }

    function burn(
        uint256 _value
    ) 
        public
        whenNotPaused
    {
        require(!frozenAccount[msg.sender], "Sender account freezed");

        return super.burn(_value);
    }

    function burnFrom(
        address _from, 
        uint256 _value
    ) 
        public 
        whenNotPaused
    {
        require(!frozenAccount[msg.sender], "Sender account freezed");
        require(!frozenAccount[_from], "From account freezed");

        return super.burnFrom(_from, _value);
    }
}


/**
* @title Lockable, Freezable, Burnable, Pausable, ERC20
* @dev Token that can be locked, and will be released in steps.
*/
contract LockableFreezableBurnablePausableERC20Token is FreezableBurnablePausableERC20Token {
    struct LockAtt {
    uint256 initLockAmount;    //初始锁仓金额
    uint256 lockAmount;        //剩余锁仓金额
    uint256 startLockTime;     //开始锁仓的时间
    uint256 cliff;             //初次释放之前的锁定时长
    uint256 interval;          //两次释放之前的间隔
    uint256 releaseCount;      //总释放次数
    bool revocable;            //是否可回收
    address revocAddress;      //回收地址
    }
    mapping (address => LockAtt) public lockAtts;

    event RefreshedLockStatus(address _account);
    //刷新锁仓状态
    function refreshLockStatus(address _account) public whenNotPaused returns (bool)
    { 
        if(lockAtts[_account].lockAmount <= 0)
            return false;

        require(lockAtts[_account].interval > 0, "Interval error");

        uint256 initlockamount = lockAtts[_account].initLockAmount;
        uint256 startlocktime = lockAtts[_account].startLockTime;
        uint256 cliff = lockAtts[_account].cliff;
        uint256 interval = lockAtts[_account].interval;
        uint256 releasecount = lockAtts[_account].releaseCount;

        uint256 releaseamount = 0;
	if(block.timestamp < startlocktime + cliff)
	    return false;

        uint256 exceedtime = block.timestamp-startlocktime-cliff;
        if(exceedtime >= 0)
        {
            releaseamount = (exceedtime/interval+1)*initlockamount/releasecount;
            uint256 lockamount = initlockamount - releaseamount;
            if(lockamount<0)
                lockamount=0;
            if(lockamount>initlockamount)
                lockamount=initlockamount;
            lockAtts[_account].lockAmount = lockamount;
        }

        emit RefreshedLockStatus(_account);
        return true;
    }

    event LockTransfered(address _from, address _to, uint256 _value, uint256 _cliff, uint256 _interval, uint _releaseCount);
    //锁仓转账
    function lockTransfer(address _to, uint256 _value, uint256 _cliff, uint256 _interval, uint _releaseCount) 
    public whenNotPaused returns (bool)
    {
        require(!frozenAccount[msg.sender], "Sender account freezed");
        require(!frozenAccount[_to], "Receiver account freezed");
        require(balances[_to] == 0, "Revceiver not a new account");    //新地址才可以接受锁仓转入
        require(_cliff>0, "Cliff error"); 
        require(_interval>0, "Interval error"); 
        require(_releaseCount>0, "Release count error"); 

        refreshLockStatus(msg.sender);
        uint256 balance = balances[msg.sender];
        uint256 lockbalance = lockAtts[msg.sender].lockAmount;
        require(_value <= balance && _value <= balance.sub(lockbalance), "Unlocked balance insufficient");
        require(_to != address(0));

        LockAtt memory lockatt = LockAtt(_value, _value, block.timestamp, _cliff, _interval, _releaseCount, false, msg.sender);
        lockAtts[_to] = lockatt;    //设置接收地址的锁仓参数

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit LockTransfered(msg.sender, _to, _value, _cliff, _interval, _releaseCount);
        return true; 
    } 

    event SetRevocable(bool _revocable);
    //同意收回
    function setRevocable(bool _revocable) public whenNotPaused 
    {
        require(!frozenAccount[msg.sender], "Account freezed");

        lockAtts[msg.sender].revocable = _revocable;
        emit SetRevocable(_revocable);
    }

    event Revoced(address _account);
    //收回
    function revoc(address _account) public whenNotPaused returns (uint256)
    {
        require(!frozenAccount[msg.sender], "Account freezed");
        require(!frozenAccount[_account], "Sender account freezed");
        require(lockAtts[_account].revocable, "Account not revocable");        //该账户是否可回收
        require(lockAtts[_account].revocAddress == msg.sender, "No permission to revoc");    //回收地址是否为sender
        refreshLockStatus(_account);
        uint256 balance = balances[_account];
        uint256 lockbalance = lockAtts[_account].lockAmount;
        require(balance >= balance.sub(lockbalance), "Unlocked balance insufficient");
    
        //转账
        balances[msg.sender] = balances[msg.sender].add(lockbalance);
        balances[_account] = balances[_account].sub(lockbalance); 

	//被回收账户的锁仓状态要清0，否则已释放的部分也无法操作
        lockAtts[_account].lockAmount = 0;
        lockAtts[_account].initLockAmount = 0;


        emit Revoced(_account);
        return lockbalance;
    }

    //重写普通转账、销毁等函数，判断锁定金额

    function transfer(
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    { 
        refreshLockStatus(msg.sender);
        uint256 balance = balances[msg.sender];
        uint256 lockbalance = lockAtts[msg.sender].lockAmount;
        require(_value <= balance && _value <= balance.sub(lockbalance), "Unlocked balance insufficient");

        return super.transfer(_to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    { 
        refreshLockStatus(_from);
        uint256 balance = balances[_from];
        uint256 lockbalance = lockAtts[_from].lockAmount;
        require(_value <= balance && _value <= balance.sub(lockbalance), "Unlocked balance insufficient");

        return super.transferFrom(_from, _to, _value);
    }

    function burn(
        uint256 _value
    ) 
        public
        whenNotPaused
    {  
        refreshLockStatus(msg.sender);
        uint256 balance = balances[msg.sender];
        uint256 lockbalance = lockAtts[msg.sender].lockAmount;
        require(_value <= balance && _value <= balance.sub(lockbalance), "Unlocked balance insufficient");

        return super.burn(_value);
    }

    function burnFrom(
        address _from, 
        uint256 _value
    ) 
        public 
        whenNotPaused
    {  
        refreshLockStatus(_from);
        uint256 balance = balances[_from];
        uint256 lockbalance = lockAtts[_from].lockAmount;
        require(_value <= balance && _value <= balance.sub(lockbalance), "Unlocked balance insufficient");

        return super.burnFrom(_from, _value);
    }

 
}


/**
* @title GESC
* @dev Token that is ERC20 compatible, Pausable, Burnable, Ownable, Lockable with SafeMath.
*/
contract GESC is LockableFreezableBurnablePausableERC20Token {

    /** Token Setting: You are free to change any of these
    * @param name string The name of your token (can be not unique)
    * @param symbol string The symbol of your token (can be not unique, can be more than three characters)
    * @param decimals uint8 The accuracy decimals of your token (conventionally be 18)
    * Read this to choose decimals: https://ethereum.stackexchange.com/questions/38704/why-most-erc-20-tokens-have-18-decimals
    * @param INITIAL_SUPPLY uint256 The total supply of your token. Example default to be "10000". Change as you wish.
    **/
    string public constant name = "Global Estate Coin";
    string public constant symbol = "GESC";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(decimals));

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    * Literally put all the issued money in your pocket
    */
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }
}