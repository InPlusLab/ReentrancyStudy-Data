/**

 *Submitted for verification at Etherscan.io on 2018-12-06

*/



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



contract Enlist {

  struct Record {

    address investor;

    bytes32 _type;

  }



  Record[] records;



  function setRecord (

    address _investor,

    bytes32 _type

  ) internal {

    records.push(Record(_investor, _type));

  }



  function getRecordCount () constant

  public

  returns (uint) {

    return records.length;

  }



  function getRecord (uint index) view

  public

  returns (address, bytes32) {

    return (

      records[index].investor,

      records[index]._type

    );

  }

}





/* CONSTANTS:

 *    20

 */

contract JinVestingRule {

  struct Rule {

    bytes32 name;

    bytes32 cliffStr;

    uint256 cliff;

    uint256 baseRatio; /* First Month release */

    uint256 incrRatio; /* Second Month release */

  }



  uint public period;

  uint public ruleCount;

  Rule[20+1] public rules;

  mapping(bytes32 => uint) ruleNumbering;



  constructor () public {

    uint j = 0;

    /* skip index j==0 */

    rules[++j] = Rule('PRESALE1' , '2018-12-01', 1543622400,  20, 10); /* Prvaite Salse Peroiod 1 */

    rules[++j] = Rule('PRESALE2' , '2019-02-01', 1548979200,  20, 10); /* Prvaite Salse Peroiod 2 */

    rules[++j] = Rule('PRESALE3' , '2019-04-01', 1554076800,  20, 10); /* Prvaite Salse Peroiod 3 */

    rules[++j] = Rule('PRESALE4' , '2019-06-01', 1559347200,  20, 10); /* Prvaite Salse Peroiod 4 */

    rules[++j] = Rule('PRESALE5' , '2019-08-01', 1564617600,  20, 10); /* Prvaite Salse Peroiod 5 */

    rules[++j] = Rule('CROWDSALE', '2019-09-01', 1567296000, 100,  0); /* Public Sale */

    rules[++j] = Rule('STARTUP'  , '2020-01-01', 1577836800,  10, 10); /* StartUp Team */

    rules[++j] = Rule('TECHTEAM' , '2019-09-01', 1567296000,  10, 10); /* Technology Team */

    ruleCount = j;

    for (uint i = 1; i <= ruleCount; i++) {

      ruleNumbering[rules[i].name] = i;

    }

    period = 30 days;

  }



 modifier validateRuleName(bytes32 key) {

   require(ruleNumbering[key] != 0);

   _;

 }



 modifier validateRuleIndex(uint i) {

   require(1 <= i && i <= ruleCount);

   _;

 }



  function getRule (bytes32 key)

  public view

  validateRuleName(key)

  returns (

    string str_name,

    string str_cliffStr,

    uint256 cliff,

    uint256 baseRatio,

    uint256 incrRatio

  ) {

    return (

      bytes32ToString(rules[ruleNumbering[key]].name),

      bytes32ToString(rules[ruleNumbering[key]].cliffStr),

      rules[ruleNumbering[key]].cliff,

      rules[ruleNumbering[key]].baseRatio,

      rules[ruleNumbering[key]].incrRatio

    );

  }



  function getRuleIndexByName (bytes32 key)

  public view

  validateRuleName(key)

  returns (uint) {

    return ruleNumbering[key];

  }



  /* ref

   * https://ethereum.stackexchange.com/questions/29295/how-to-convert-a-bytes-to-string-in-solidity?rq=1

   */

  function bytes32ToString(bytes32 x)

  public pure

  returns (string) {

    bytes memory bytesString = new bytes(32);

    uint charCount = 0;

    for (uint j = 0; j < 32; j++) {

      byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));

      if (char != 0) {

        bytesString[charCount] = char;

        charCount++;

      }

    }

    bytes memory bytesStringTrimmed = new bytes(charCount);

    for (j = 0; j < charCount; j++) {

      bytesStringTrimmed[j] = bytesString[j];

    }

    return string(bytesStringTrimmed);

  }



}







/**

 * @title Math

 * @dev Assorted math operations

 */

library Math {

  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {

    return _a >= _b ? _a : _b;

  }



  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {

    return _a < _b ? _a : _b;

  }



  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a >= _b ? _a : _b;

  }



  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a < _b ? _a : _b;

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









/**

 * @title DetailedERC20 token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract DetailedERC20 is ERC20 {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }

}











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











contract JinToken is

  StandardToken,

  DetailedERC20,

  Ownable,

  JinVestingRule,

  Enlist {

  using SafeMath for uint;

  using Math for uint;



  uint public INITIAL_SUPPLY;



  mapping (address => mapping (bytes32 => uint)) private lockedAmount;

  mapping (address => mapping (bytes32 => uint)) private alreadyClaim;



  // How many token units a buyer gets per microether.

  // The rate is the conversion between

  //    microeather and

  //    the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with 5 decimals called KIM

  // 1 microether will give you 1 unit, or 0.00001 KIM.

  uint public rate;  // Crowdsale



  constructor (

    string _name,     // "jinyitong"

    string _symbol,   // "JIN", "KIN", "BGC"

    uint8 _decimals,  // 5

    address _startup,

    address _angelfund,

    address _techteam

  )

  DetailedERC20(

    _name,

    _symbol,

    _decimals

  )

  JinVestingRule()

  public {

    rate = 30;

    INITIAL_SUPPLY = 3.14e8;                 // initital supply 314,000,000 BGC

    totalSupply_ = INITIAL_SUPPLY.mul(10 ** uint(decimals)); // BasicToken

    balances[msg.sender] = totalSupply_;                     // BasicToken



    /* initial transferToLock */

    uint jins = 0;



    jins = totalSupply_.div(100).mul(20);

    _transferToLock(_startup, jins, 'STARTUP');



    jins = totalSupply_.div(100).mul(15);

    transfer(_angelfund, jins); // _transferToLock(_angelfund, jins, 'ANGELFUND');



    jins = totalSupply_.div(100).mul(5);

    _transferToLock(_techteam, jins, 'TECHTEAM');

  }



  event TransferToLock (

    address indexed to,

    uint value,

    string lockingType,

    uint totalLocked

  );



  event DoubleClaim (

    address indexed user,

    bytes32 _type,

    address sender

  );



  modifier onlyOwner() {

    require(msg.sender == owner); // Ownable

    _;

  }



  /* Crowdsale */

  function ()

  external

  payable {



    address user = msg.sender;

    uint jins = _getTokenAmount(msg.value);



    require(jins >= 0);



    _transferToLock(user, jins, 'CROWDSALE');

  }



  function _getTokenAmount(uint weiAmount) internal view returns (uint) {

    uint _microAmount = weiAmount.div(10 ** 12);

    return _microAmount.mul(rate);

  }



  function setCrowdsaleRate(uint _rate) public onlyOwner() returns (bool) {

    rate = _rate;

    return true;

  }



  function transferToLock (

    address user,

    uint amount,

    bytes32 _type

  ) public

  onlyOwner()

  validateRuleName(_type)

  returns (bool) {

    _transferToLock(user, amount, _type);

    return true;

  }



  function _transferToLock (

    address _to,

    uint _value,

    bytes32 _type

  ) internal

  returns (bool) {

    address _from = owner;



    require(_value > 0);

    require(_value <= balances[_from]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    lockedAmount[_to][_type] = lockedAmount[_to][_type].add(_value);



    emit TransferToLock(_to, _value, bytes32ToString(_type), lockedAmount[_to][_type]);



    setRecord(_to, _type);



    return true;

  }



  function claimToken (

    address user,

    bytes32 _type

  ) public

  validateRuleName(_type)

  returns (bool) {

    require(lockedAmount[user][_type] > 0);

    uint approved = approvedRatio(_type);

    uint availableToClaim =

      lockedAmount[user][_type].mul(approved).div(100);

    uint amountToClaim = availableToClaim.sub(alreadyClaim[user][_type]);



    if (amountToClaim > 0) {

      balances[user] = balances[user].add(amountToClaim);

      alreadyClaim[user][_type] = availableToClaim;

    } else if (amountToClaim == 0) {

      emit DoubleClaim(

        user,

        _type,

        msg.sender

      );

    } else {

    }



    return true;

  }



  function approvedRatio (

    bytes32 _type

  ) internal view returns (uint) {

      uint _now = getTime();

      uint cliff = rules[ruleNumbering[_type]].cliff;



      require(_now >= cliff);



      uint baseRatio = rules[ruleNumbering[_type]].baseRatio;

      uint incrRatio = rules[ruleNumbering[_type]].incrRatio;



      return Math.min256(

        100,

        _now

        .sub( cliff )

        .div( period ) // a month

        .mul( incrRatio )

        .add( baseRatio )

      );

  }



  function getLockedAvailable (

    address user,

    bytes32 _type

  ) public view

  validateRuleName(_type)

  returns (uint) {

    uint record;



    record = lockedAmount[user][_type].sub(alreadyClaim[user][_type]);



    return record;

  }



  function getTime () public view returns (uint) {

    return block.timestamp; // now

  }

}