/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



pragma solidity ^0.4.24;





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



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.4.24;





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



// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol



pragma solidity ^0.4.24;









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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.4.24;







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



// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol



pragma solidity ^0.4.24;









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



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



pragma solidity ^0.4.24;





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



// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



pragma solidity ^0.4.24;







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



// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol



pragma solidity ^0.4.24;









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



// File: contracts/JemToken.sol



pragma solidity ^0.4.24;









interface TokenRecipient {

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; 

}



contract JEMToken is StandardToken, Ownable, PausableToken {



    using SafeMath for uint256;



    struct LockupInfo {

        uint256 releaseTime;

        uint256 termOfRound;

        uint256 unlockAmountPerRound;        

        uint256 lockupBalance;

    }



    string public name;

    string public symbol;

    uint8 constant public decimals =18;

    uint256 internal initialSupply;

    uint256 internal totalSupply_;



    mapping(address => uint256) internal balances;

    mapping(address => bool) internal locks;

    mapping(address => bool) public frozen;

    mapping(address => mapping(address => uint256)) internal allowed;

    mapping(address => LockupInfo[]) internal lockupInfo;



    event Lock(address indexed holder, uint256 value);

    event Unlock(address indexed holder, uint256 value);

    event Burn(address indexed owner, uint256 value);

    event Mint(uint256 value);

    event Freeze(address indexed holder);

    event Unfreeze(address indexed holder);



    modifier notFrozen(address _holder) {

        require(!frozen[_holder]);

        _;

    }



    constructor() public {

        name = "JEM";

        symbol = "JEM";

        initialSupply = 500000000; // 500,000,000 개

        totalSupply_ = initialSupply * 10 ** uint(decimals);

        balances[owner] = totalSupply_;

        emit Transfer(address(0), owner, totalSupply_);

    }



    // contract address로 송금했을 때 호출

    function () public payable {

        revert();

    }



    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    function transfer(address _to, uint256 _value) public whenNotPaused notFrozen(msg.sender) returns (bool) {

        if (locks[msg.sender]) {

            autoUnlock(msg.sender);            

        }

        require(_to != address(0));

        require(_value <= balances[msg.sender]);

        



        // SafeMath.sub will throw if there is not enough balance.

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    function balanceOf(address _holder) public view returns (uint256 balance) {

        uint256 lockedBalance = 0;

        if(locks[_holder]) {

            for(uint256 idx = 0; idx < lockupInfo[_holder].length ; idx++ ) {

                lockedBalance = lockedBalance.add(lockupInfo[_holder][idx].lockupBalance);

            }

        }

        return balances[_holder] + lockedBalance;

    }



    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notFrozen(_from)returns (bool) {

        if (locks[_from]) {

            autoUnlock(_from);            

        }

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);

        



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        require(isContract(_spender));

        TokenRecipient spender = TokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        allowed[msg.sender][spender] = (allowed[msg.sender][spender].add(addedValue));

        

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;

    }



    function decreaseAllowance( address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        allowed[msg.sender][spender] = (allowed[msg.sender][spender].sub(subtractedValue));



        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;

    }



    function allowance(address _holder, address _spender) public view returns (uint256) {

        return allowed[_holder][_spender];

    }



    function lock(address _holder, uint256 _amount, uint256 _releaseStart, uint256 _termOfRound, uint256 _releaseRate) public onlyOwner returns (bool) {

        require(balances[_holder] >= _amount);

        if(_termOfRound==0 ) {

            _termOfRound = 1;

        }

        balances[_holder] = balances[_holder].sub(_amount);

        lockupInfo[_holder].push(

            LockupInfo(_releaseStart, _termOfRound, _amount.div(100).mul(_releaseRate), _amount)

        );



        locks[_holder] = true;



        emit Lock(_holder, _amount);



        return true;

    }



    function unlock(address _holder, uint256 _idx) public onlyOwner returns (bool) {

        require(locks[_holder]);

        require(_idx < lockupInfo[_holder].length);

        LockupInfo storage lockupinfo = lockupInfo[_holder][_idx];

        uint256 releaseAmount = lockupinfo.lockupBalance;



        delete lockupInfo[_holder][_idx];

        lockupInfo[_holder][_idx] = lockupInfo[_holder][lockupInfo[_holder].length.sub(1)];

        lockupInfo[_holder].length -=1;

        if(lockupInfo[_holder].length == 0) {

            locks[_holder] = false;

        }



        emit Unlock(_holder, releaseAmount);

        balances[_holder] = balances[_holder].add(releaseAmount);



        return true;

    }



    function freezeAccount(address _holder) public onlyOwner returns (bool) {

        require(!frozen[_holder]);

        frozen[_holder] = true;

        emit Freeze(_holder);

        return true;

    }



    function unfreezeAccount(address _holder) public onlyOwner returns (bool) {

        require(frozen[_holder]);

        frozen[_holder] = false;

        emit Unfreeze(_holder);

        return true;

    }



    function getNowTime() public view returns(uint256) {

        return now;

    }



    function showLockState(address _holder, uint256 _idx) public view returns (bool, uint256, uint256, uint256, uint256, uint256) {

        if(locks[_holder]) {

            return (

                locks[_holder], 

                lockupInfo[_holder].length, 

                lockupInfo[_holder][_idx].lockupBalance, 

                lockupInfo[_holder][_idx].releaseTime, 

                lockupInfo[_holder][_idx].termOfRound, 

                lockupInfo[_holder][_idx].unlockAmountPerRound

            );

        } else {

            return (

                locks[_holder], 

                lockupInfo[_holder].length, 

                0,0,0,0

            );



        }        

    }

    

    function distribute(address _to, uint256 _value) public onlyOwner returns (bool) {

        require(_to != address(0));

        require(_value <= balances[owner]);



        balances[owner] = balances[owner].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(owner, _to, _value);

        return true;

    }



    function distributeWithLockup(address _to, uint256 _value, uint256 _releaseStart, uint256 _termOfRound, uint256 _releaseRate) public onlyOwner returns (bool) {

        distribute(_to, _value);

        lock(_to, _value, _releaseStart, _termOfRound, _releaseRate);

        return true;

    }



    function claimToken(ERC20 token, address _to, uint256 _value) public onlyOwner returns (bool) {

        token.transfer(_to, _value);

        return true;

    }



    function burn(uint256 _value) public onlyOwner returns (bool success) {

        require(_value <= balances[msg.sender]);

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        totalSupply_ = totalSupply_.sub(_value);

        emit Burn(burner, _value);

        return true;

    }



    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {

        totalSupply_ = totalSupply_.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Transfer(address(0), _to, _amount);

        return true;

    }



    function isContract(address addr) internal view returns (bool) {

        uint size;

        assembly{size := extcodesize(addr)}

        return size > 0;

    }



    function autoUnlock(address _holder) internal returns (bool) {



        for(uint256 idx =0; idx < lockupInfo[_holder].length ; idx++ ) {

            if(locks[_holder]==false) {

                return true;

            }

            if (lockupInfo[_holder][idx].releaseTime <= now) {

                if( releaseTimeLock(_holder, idx) ) {

                    idx -=1;

                }

            }

        }

        return true;

    }



    function releaseTimeLock(address _holder, uint256 _idx) internal returns(bool) {

        require(locks[_holder]);

        require(_idx < lockupInfo[_holder].length);



        LockupInfo storage info = lockupInfo[_holder][_idx];

        uint256 releaseAmount = info.unlockAmountPerRound;

        uint256 sinceFrom = now.sub(info.releaseTime);

        uint256 sinceRound = sinceFrom.div(info.termOfRound);

        releaseAmount = releaseAmount.add( sinceRound.mul(info.unlockAmountPerRound) );



        if(releaseAmount >= info.lockupBalance) {            

            releaseAmount = info.lockupBalance;



            delete lockupInfo[_holder][_idx];

            lockupInfo[_holder][_idx] = lockupInfo[_holder][lockupInfo[_holder].length.sub(1)];

            lockupInfo[_holder].length -=1;



            if(lockupInfo[_holder].length == 0) {

                locks[_holder] = false;

            }

            emit Unlock(_holder, releaseAmount);

            balances[_holder] = balances[_holder].add(releaseAmount);

            return true;

        } else {

            lockupInfo[_holder][_idx].releaseTime = lockupInfo[_holder][_idx].releaseTime.add( sinceRound.add(1).mul(info.termOfRound) );

            lockupInfo[_holder][_idx].lockupBalance = lockupInfo[_holder][_idx].lockupBalance.sub(releaseAmount);

            emit Unlock(_holder, releaseAmount);

            balances[_holder] = balances[_holder].add(releaseAmount);

            return false;

        }

    }





}