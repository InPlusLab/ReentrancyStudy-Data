/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.4.24;



// File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: node_modules/zeppelin-solidity/contracts/token/ERC20/BasicToken.sol



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) internal balances;



  uint256 internal totalSupply_;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

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

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



// File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/issues/20

 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

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

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

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



// File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol



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



// File: node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol



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



// File: node_modules/zeppelin-solidity/contracts/token/ERC20/PausableToken.sol



/**

 * @title Pausable token

 * @dev StandardToken modified with pausable transfers.

 **/

contract PausableToken is StandardToken, Pausable {



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



// File: contracts\Minebee.sol



//solium-disable linebreak-style

pragma solidity ^0.4.24;





contract Minebee is PausableToken {



    //token spec

    string public constant name = "MineBee"; // solium-disable-line uppercase

    string public constant symbol = "MB"; // solium-disable-line uppercase

    uint8 public constant decimals = 18; // solium-disable-line uppercase



    uint256 public constant INITIAL_SUPPLY = 5000000000 * (10 ** uint256(decimals));



    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

    }



    //freezable

    event Frozen(address target);

    event Unfrozen(address target);



    mapping(address => bool) internal freezes;



    modifier whenNotFrozen() {

        require(!freezes[msg.sender], "Sender account is locked.");

        _;

    }



    function freeze(address _target) public onlyOwner {

        freezes[_target] = true;

        emit Frozen(_target);

    }



    function unfreeze(address _target) public onlyOwner {

        freezes[_target] = false;

        emit Unfrozen(_target);

    }



    function isFrozen(address _target) public view returns (bool) {

        return freezes[_target];

    }



    function transfer(

        address _to,

        uint256 _value

    )

      public

      whenNotFrozen

      returns (bool)

    {

        releaseLock(msg.sender);

        return super.transfer(_to, _value);

    }



    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

      public

      returns (bool)

    {

        require(!freezes[_from], "From account is locked.");

        releaseLock(_from);

        return super.transferFrom(_from, _to, _value);

    }



    //mintable

    event Mint(address indexed to, uint256 amount);



    function mint(

        address _to,

        uint256 _amount

    )

      public

      onlyOwner

      returns (bool)

    {

        totalSupply_ = totalSupply_.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);

        emit Transfer(address(0), _to, _amount);

        return true;

    }



    //burnable

    event Burn(address indexed burner, uint256 value);



    function burn(address _who, uint256 _value) public onlyOwner {

        _burn(_who, _value);

    }



    function _burn(address _who, uint256 _value) internal {

        require(_value <= balances[_who], "Balance is too small.");



        balances[_who] = balances[_who].sub(_value);

        totalSupply_ = totalSupply_.sub(_value);

        emit Burn(_who, _value);

        emit Transfer(_who, address(0), _value);

    }



    //lockable

    struct LockInfo {

        uint256 releaseTime;

        uint256 balance;

    }

    mapping(address => LockInfo[]) internal lockInfo;



    event Lock(address indexed holder, uint256 value, uint256 releaseTime);

    event Unlock(address indexed holder, uint256 value);



    function balanceOf(address _holder) public view returns (uint256 balance) {

        uint256 lockedBalance = 0;

        for(uint256 i = 0; i < lockInfo[_holder].length ; i++ ) {

            lockedBalance = lockedBalance.add(lockInfo[_holder][i].balance);

        }

        return balances[_holder].add(lockedBalance);

    }



    function releaseLock(address _holder) internal {



        for(uint256 i = 0; i < lockInfo[_holder].length ; i++ ) {

            if (lockInfo[_holder][i].releaseTime <= now) {



                balances[_holder] = balances[_holder].add(lockInfo[_holder][i].balance);

                emit Unlock(_holder, lockInfo[_holder][i].balance);

                lockInfo[_holder][i].balance = 0;



                if (i != lockInfo[_holder].length - 1) {

                    lockInfo[_holder][i] = lockInfo[_holder][lockInfo[_holder].length - 1];

                    i--;

                }

                lockInfo[_holder].length--;



            }

        }

    }

    function lockCount(address _holder) public view returns (uint256) {

        return lockInfo[_holder].length;

    }

    function lockState(address _holder, uint256 _idx) public view returns (uint256, uint256) {

        return (lockInfo[_holder][_idx].releaseTime, lockInfo[_holder][_idx].balance);

    }



    function lock(address _holder, uint256 _amount, uint256 _releaseTime) public onlyOwner {

        require(balances[_holder] >= _amount, "Balance is too small.");

        balances[_holder] = balances[_holder].sub(_amount);

        lockInfo[_holder].push(

            LockInfo(_releaseTime, _amount)

        );

        emit Lock(_holder, _amount, _releaseTime);

    }



    function lockAfter(address _holder, uint256 _amount, uint256 _afterTime) public onlyOwner {

        require(balances[_holder] >= _amount, "Balance is too small.");

        balances[_holder] = balances[_holder].sub(_amount);

        lockInfo[_holder].push(

            LockInfo(now + _afterTime, _amount)

        );

        emit Lock(_holder, _amount, now + _afterTime);

    }



    function unlock(address _holder, uint256 i) public onlyOwner {

        require(i < lockInfo[_holder].length, "No lock information.");



        balances[_holder] = balances[_holder].add(lockInfo[_holder][i].balance);

        emit Unlock(_holder, lockInfo[_holder][i].balance);

        lockInfo[_holder][i].balance = 0;



        if (i != lockInfo[_holder].length - 1) {

            lockInfo[_holder][i] = lockInfo[_holder][lockInfo[_holder].length - 1];

        }

        lockInfo[_holder].length--;

    }



    function transferWithLock(address _to, uint256 _value, uint256 _releaseTime) public onlyOwner returns (bool) {

        require(_to != address(0), "wrong address");

        require(_value <= balances[owner], "Not enough balance");



        balances[owner] = balances[owner].sub(_value);

        lockInfo[_to].push(

            LockInfo(_releaseTime, _value)

        );

        emit Transfer(owner, _to, _value);

        emit Lock(_to, _value, _releaseTime);



        return true;

    }



    function transferWithLockAfter(address _to, uint256 _value, uint256 _afterTime) public onlyOwner returns (bool) {

        require(_to != address(0), "wrong address");

        require(_value <= balances[owner], "Not enough balance");



        balances[owner] = balances[owner].sub(_value);

        lockInfo[_to].push(

            LockInfo(now + _afterTime, _value)

        );

        emit Transfer(owner, _to, _value);

        emit Lock(_to, _value, now + _afterTime);



        return true;

    }



    function currentTime() public view returns (uint256) {

        return now;

    }



    function afterTime(uint256 _value) public view returns (uint256) {

        return now + _value;

    }

}