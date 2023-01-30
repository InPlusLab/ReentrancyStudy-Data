/**

 *Submitted for verification at Etherscan.io on 2019-02-19

*/



/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */





pragma solidity ^0.4.25;



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





/**

 * Safe unsigned safe math.

 */

library SafeMathLib {



  function times(uint a, uint b) public pure returns (uint) {

    uint c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function minus(uint a, uint b) public pure returns (uint) {

    assert(b <= a);

    return a - b;

  }



  function plus(uint a, uint b) public pure returns (uint) {

    uint c = a + b;

    assert(c>=a);

    return c;

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

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

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



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



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

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

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

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }

}





contract Recoverable is Ownable {



  /// @dev Empty constructor (for now)

  constructor() public {

  }



  /// @dev This will be invoked by the owner, when owner wants to rescue tokens

  /// @param token Token which will we rescue to the owner from the contract

  function recoverTokens(ERC20Basic token) onlyOwner public {

    token.transfer(owner, tokensToBeReturned(token));

  }



  /// @dev Interface function, can be overwritten by the superclass

  /// @param token Token which balance we will check and return

  /// @return The amount of tokens (in smallest denominator) the contract owns

  function tokensToBeReturned(ERC20Basic token) public returns (uint) {

    return token.balanceOf(this);

  }

}





/**

 * Standard EIP-20 token with an interface marker.

 *

 * @notice Interface marker is used by crowdsale contracts to validate that addresses point a good token contract.

 *

 */

contract StandardTokenExt is StandardToken, Recoverable {



  /* Interface declaration */

  function isToken() public pure returns (bool weAre) {

    return true;

  }

}



/**

 * Hold tokens for a group investor of investors until the unlock date.

 *

 * After the unlock date the investor can claim their tokens.

 *

 * Steps

 *

 * - Prepare a spreadsheet for token allocation

 * - Deploy this contract, with the sum to tokens to be distributed, from the owner account

 * - Call setInvestor for all investors from the owner account using a local script and CSV input

 * - Move tokensToBeAllocated in this contract using StandardToken.transfer()

 * - Call lock from the owner account

 * - Wait until the freeze period is over

 * - After the freeze time is over investors can call claim() from their address to get their tokens

 *

 */

contract SaleVault is Ownable, Recoverable {

  using SafeMathLib for uint;



  /** How many investors we have now */

  uint public investorCount;



  /** Sum from the spreadsheet how much tokens we should get on the contract. If the sum does not match at the time of the lock the vault is faulty and must be recreated.*/

  uint public tokensToBeAllocated;



  /** How many tokens investors have claimed so far */

  uint public totalClaimed;



  /** How many tokens our internal book keeping tells us to have at the time of lock() when all investor data has been loaded */

  uint public tokensAllocatedTotal;



  /** How much we have allocated to the investors invested */

  mapping(address => uint) public balances;



  /** How many tokens investors have claimed */

  mapping(address => uint) public claimed;



  /** When our claim freeze is over (UNIX timestamp) */

  uint public freezeEndsAt;



  /** When this vault was locked (UNIX timestamp) */

  uint public lockedAt;



  /** We can also define our own token, which will override the ICO one ***/

  StandardTokenExt public token;



  /** What is our current state.

   *

   * Loading: Investor data is being loaded and contract not yet locked

   * Holding: Holding tokens for investors

   * Distributing: Freeze time is over, investors can claim their tokens

   */

  enum State{Unknown, Loading, Holding, Distributing}



  /** We allocated tokens for investor */

  event Allocated(address investor, uint value);



  /** We distributed tokens to an investor */

  event Distributed(address investors, uint count);



  event Locked();



  /**

   * Create presale contract where lock up period is given days

   *

   * @param _freezeEndsAt UNIX timestamp when the vault unlocks

   * @param _token Token contract address we are distributing

   * @param _tokensToBeAllocated Total number of tokens this vault will hold - including decimal multiplication

   * @param _owner The address owner

   */

  constructor(

    uint _freezeEndsAt,

    StandardTokenExt _token,

    uint _tokensToBeAllocated,

    address _owner

  ) public {

    require(_token.isToken());

    require(_freezeEndsAt != 0);

    require(_tokensToBeAllocated != 0);



    owner = _owner;

    token = _token;



    if (_freezeEndsAt < now) {

      freezeEndsAt = now;

    } else {

      freezeEndsAt = _freezeEndsAt;

    }

    tokensToBeAllocated = _tokensToBeAllocated;

  }



  /// @dev Add a presale participating allocation

  function setInvestor(address investor, uint amount) public onlyOwner {

    require(lockedAt == 0);

    require(amount > 0);

    require(balances[investor] == 0);



    balances[investor] = amount;



    investorCount++;



    tokensAllocatedTotal += amount;



    emit Allocated(investor, amount);

  }



  /// @dev Lock the vault

  ///      - All balances have been loaded in correctly

  ///      - Tokens are transferred on this vault correctly

  ///      - Checks are in place to prevent creating a vault that is locked with incorrect token balances.

  function lock() public onlyOwner {

    require(lockedAt == 0);

    require(tokensAllocatedTotal <= tokensToBeAllocated);

    require(token.balanceOf(address(this)) >= tokensToBeAllocated);



    lockedAt = now;



    emit Locked();

  }



  /// @dev In the case locking failed, then allow the owner to reclaim the tokens on the contract.

  function recoverFailedLock() public onlyOwner {

    require(lockedAt == 0);



    // Transfer all tokens on this contract back to the owner

    token.transfer(owner, token.balanceOf(address(this)));

  }



  /// @dev Get the current balance of tokens in the vault

  /// @return uint How many tokens there are currently in vault

  function getBalance() public constant returns (uint howManyTokensCurrentlyInVault) {

    return token.balanceOf(address(this));

  }



  /// @dev Check how many tokens "investor" can claim

  /// @param investor Address of the investor

  /// @return uint How many tokens the investor can claim now

  function getCurrentlyClaimableAmount(address investor) public constant returns (uint claimableAmount) {

    uint maxTokensLeft = balances[investor] - claimed[investor];



    if (now < freezeEndsAt) {

      return 0;

    }



    return maxTokensLeft;

  }



  /// @dev Claim N bought tokens to the investor as the msg sender

  function claim() public {

    require(lockedAt != 0);

    require(block.timestamp > freezeEndsAt);

    require(balances[msg.sender] > 0);



    address investor = msg.sender;



    uint amount = getCurrentlyClaimableAmount(investor);

    require (amount > 0);



    claimed[investor] += amount;



    totalClaimed += amount;



    token.transfer(investor, amount);



    emit Distributed(investor, amount);

  }



  /// @dev This function is prototyped in Recoverable contract

  function tokensToBeReturned(ERC20Basic tokenToClaim) public returns (uint) {

    if (address(tokenToClaim) == address(token)) {

      return getBalance().minus(tokensAllocatedTotal);

    } else {

      return tokenToClaim.balanceOf(this);

    }

  }



  /// @dev Resolve the contract umambigious state

  function getState() public constant returns(State) {

    if(lockedAt == 0) {

      return State.Loading;

    } else if(now > freezeEndsAt) {

      return State.Distributing;

    } else {

      return State.Holding;

    }

  }



}