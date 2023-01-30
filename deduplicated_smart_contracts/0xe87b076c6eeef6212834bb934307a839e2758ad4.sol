/**

 *Submitted for verification at Etherscan.io on 2018-09-05

*/



pragma solidity ^0.4.22;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

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

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

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

  function transfer(address _to, uint256 _value) returns (bool) {

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

  function balanceOf(address _owner) constant returns (uint256 balance) {

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



  mapping (address => mapping (address => uint256)) allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amout of tokens to be transfered

   */

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    var _allowance = allowed[_from][msg.sender];



    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met

    // require (_value <= _allowance);



    balances[_to] = balances[_to].add(_value);

    balances[_from] = balances[_from].sub(_value);

    allowed[_from][msg.sender] = _allowance.sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) returns (bool) {



    // To change the approve amount you first have to reduce the addresses`

    //  allowance to zero by calling `approve(_spender, 0)` if it is not

    //  already 0 to mitigate the race condition described here:

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));



    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifing the amount of tokens still avaible for the spender.

   */

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }



}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() {

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

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }



}



contract DBXTTest4 is Ownable,StandardToken {

    using SafeMath for uint256;



    string public name = "DBXTTest4";

    string public symbol = "DBXTTest4";

    uint256 public decimals = 18;

    uint256 public INITIAL_SUPPLY = 100000 * 1 ether;



    

    address public beneficiary;



    uint256 public priceETH;

    uint256 public priceDT;



    uint256 public weiRaised = 0;

    uint256 public investorCount = 0;



    uint public startTime;

    uint public endTime;



    bool public crowdsaleFinished = false;



    event Burn(address indexed from, uint256 value);

    event GoalReached(uint amountRaised);

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);



    modifier onlyAfter(uint time) {

        require(now > time);

        _;

    }



    modifier onlyBefore(uint time) {

        require(now < time);

        _;

    }



    constructor (

        address _beneficiary,

        uint256 _priceETH,

        uint256 _priceDT,

        uint _startTime,

        uint _duration) public {

        totalSupply = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

        beneficiary = _beneficiary;

        priceETH = _priceETH;

        priceDT = _priceDT;



        startTime = _startTime;

        endTime = _startTime + _duration * 1 weeks;

    }



    function () payable {

        require(msg.value >= 0.01 * 1 ether);

        doPurchase(msg.sender, msg.value);

    }



    function withdraw(uint256 _value) onlyOwner {

        beneficiary.transfer(_value);

    }



    function finishCrowdsale() onlyOwner {

        transfer(beneficiary, balanceOf(this));

        crowdsaleFinished = true;

    }



    function doPurchase(address _sender, uint256 _value) private onlyAfter(startTime) onlyBefore(endTime) {

        

        require(!crowdsaleFinished);



        uint256 dtCount = _value.mul(priceDT).div(priceETH);



        require(balanceOf(this) >= dtCount);



        if (balanceOf(_sender) == 0) investorCount++;



        transfer(_sender, dtCount);



        weiRaised = weiRaised.add(_value);



        emit NewContribution(_sender, dtCount, _value);



        if (balanceOf(this) == 0) {

            emit GoalReached(weiRaised);

        }

    }



    function burn(uint256 _value) returns (bool success) {

        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);

        return true;

  }

}