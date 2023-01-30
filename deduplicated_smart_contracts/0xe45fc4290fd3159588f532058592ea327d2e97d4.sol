/**

 *Submitted for verification at Etherscan.io on 2018-12-22

*/



pragma solidity ^0.4.24;



// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



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



// File: zeppelin-solidity/contracts/math/SafeMath.sol



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



// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol



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



// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol



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



// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol



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



// File: zeppelin-solidity/contracts/ownership/Ownable.sol



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



// File: contracts/TokenLockUp.sol



contract TokenLockUp is StandardToken, Ownable {

  using SafeMath for uint256;



  struct LockUp {

    uint256 startTime;

    uint256 endTime;

    uint256 lockamount;

  }



  string public name;

  string public symbol;

  uint public decimals;



  mapping (address => LockUp[]) addressLock;



  event Lock(address indexed from, address indexed to, uint256 amount, uint256 startTime, uint256 endTime);



  constructor (uint _initialSupply, string _name, string _symbol, uint _decimals) public {

    require(_initialSupply >= 0);

    require(_decimals >= 0);



    totalSupply_ = _initialSupply;

    balances[msg.sender] = _initialSupply;

    owner = msg.sender;

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

    emit Transfer(address(0), msg.sender, _initialSupply);

  }



  modifier checkLock (uint _amount) {

    require(_amount >= 0);



    // mapping��ȡ��

    LockUp[] storage lockData = addressLock[msg.sender];



    uint256 lockAmountNow;

    for (uint256 i = 0; i < lockData.length; i++) {

      LockUp memory temp = lockData[i];



      // ��å����g�ڤ����Υ�å������ĥ�å��ǩ`����ȡ�ä���

      if (block.timestamp >= temp.startTime && block.timestamp < temp.endTime) {

        lockAmountNow = lockAmountNow.add(temp.lockamount);

      }

    }



    // �F�ڕr�g��LOCK UP���g���ж�

    if (lockAmountNow == 0) {

      // ���g�� => �������ȱ��^

      require(balances[msg.sender] >= _amount);

    } else {

      // ���g�� => ������ - LOCK UP�� �ȱ��^

      require(balances[msg.sender].sub(lockAmountNow) >= _amount);

    }

    _;

  }



  function lockUp(address _to, uint256 _amount, uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) {

    require(_to != address(0));

    require(_amount >= 0);

    require(_endTime >= 0);

    require(_startTime < _endTime);



    LockUp memory temp;

    temp.lockamount = _amount;

    temp.startTime = block.timestamp.add(_startTime);

    temp.endTime = block.timestamp.add(_endTime);

    addressLock[_to].push(temp);

    emit Lock(msg.sender, _to, _amount, temp.startTime, temp.endTime);

    return true;

  }



  function lockBatch(address[] _addresses, uint256[] _amounts, uint256[] _startTimes, uint256[] _endTimes) public onlyOwner returns (bool) {

    require(_addresses.length == _amounts.length && _amounts.length == _startTimes.length && _startTimes.length == _endTimes.length);

    for (uint256 i = 0; i < _amounts.length; i++) {

      lockUp(_addresses[i], _amounts[i], _startTimes[i], _endTimes[i]);

    }

    return true;

  }



  function getLockTime(address _to) public view returns (uint256, uint256) {

    // mapping��ȡ��

    LockUp[] storage lockData = addressLock[_to];



    uint256 lockAmountNow;

    uint256 lockLimit;

    for (uint256 i = 0; i < lockData.length; i++) {

      LockUp memory temp = lockData[i];



      // ��å����g�ڤ����Υ�å������ĥ�å��ǩ`����ȡ�ä���

      if (block.timestamp >= temp.startTime && block.timestamp < temp.endTime) {

        lockAmountNow = lockAmountNow.add(temp.lockamount);

        if (lockLimit == 0 || lockLimit > temp.endTime) {

          lockLimit = temp.endTime;

        }

      }

    }

    return (lockAmountNow, lockLimit);

  }



  function deleteLockTime(address _to) public onlyOwner returns (bool) {

    require(_to != address(0));

    

    delete addressLock[_to];

    return true;

  }



  function transfer(address _to, uint256 _value) public checkLock(_value) returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  function transferBatch(address[] _addresses, uint256[] _amounts) public onlyOwner returns (bool) {

    require(_addresses.length == _amounts.length);

    uint256 sum;

    for (uint256 i = 0; i < _amounts.length; i++) {

      sum = sum + _amounts[i];

    }

    require(sum <= balances[msg.sender]);

    for (uint256 j = 0; j < _amounts.length; j++) {

      transfer(_addresses[j], _amounts[j]);

    }

    return true;

  }



  function transferWithLock(address _to, uint256 _value, uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);



    lockUp(_to, _value, _startTime, _endTime);

    return true;

  }



  function transferWithLockBatch(address[] _addresses, uint256[] _amounts, uint256[] _startTimes, uint256[] _endTimes) public onlyOwner returns (bool) {

    require(_addresses.length == _amounts.length && _amounts.length == _startTimes.length && _startTimes.length == _endTimes.length);

    uint256 sum;

    for (uint256 i = 0; i < _amounts.length; i++) {

      sum = sum + _amounts[i];

    }

    require(sum <= balances[msg.sender]);

    for (uint256 j = 0; j < _amounts.length; j++) {

      transferWithLock(_addresses[j], _amounts[j], _startTimes[j], _endTimes[j]);

    }

    return true;

  }



  /*** Mintable ***/

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;



  modifier canMint() {

    require(!mintingFinished);

    _;

  }



  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {

    require(_to != address(0));



    totalSupply_ = totalSupply_.add(_amount);

    balances[_to] = balances[_to].add(_amount);

    emit Mint(_to, _amount);

    emit Transfer(address(0), _to, _amount);

    return true;

  }



  function finishMinting() public onlyOwner canMint returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }



  /*** Burnable ***/

  event Burn(address indexed burner, uint256 value);



  function burn(uint256 _value) public {

    _burn(msg.sender, _value);

  }



  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);



    balances[_who] = balances[_who].sub(_value);

    totalSupply_ = totalSupply_.sub(_value);

    emit Burn(_who, _value);

    emit Transfer(_who, address(0), _value);

  }

}