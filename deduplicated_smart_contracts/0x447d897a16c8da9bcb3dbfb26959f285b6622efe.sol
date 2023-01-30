/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



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



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  int256 constant INT256_MIN = int256((uint256(1) << 255));



  /**

  * @dev Multiplies two unsigned integers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Multiplies two signed integers, throws on overflow.

  */

  function mul(int256 a, int256 b) internal pure returns (int256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert((a != -1 || b != INT256_MIN) && c / a == b);

  }



  /**

  * @dev Integer division of two unsigned integers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Integer division of two signed integers, truncating the quotient.

  */

  function div(int256 a, int256 b) internal pure returns (int256) {

    // assert(b != 0); // Solidity automatically throws when dividing by 0

    // Overflow only happens when the smallest negative int is multiplied by -1.

    assert(a != INT256_MIN || b != -1);

    return a / b;

  }



  /**

  * @dev Subtracts two unsigned integers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Subtracts two signed integers, throws on overflow.

  */

  function sub(int256 a, int256 b) internal pure returns (int256 c) {

    c = a - b;

    assert((b >= 0 && c <= a) || (b < 0 && c > a));

  }



  /**

  * @dev Adds two unsigned integers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }



  /**

  * @dev Adds two signed integers, throws on overflow.

  */

  function add(int256 a, int256 b) internal pure returns (int256 c) {

    c = a + b;

    assert((b >= 0 && c >= a) || (b < 0 && c < a));

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



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



// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol



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

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



// File: @gnosis.pm/util-contracts/contracts/Proxy.sol



/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.

/// @author Alan Lu - <[email protected]>

contract Proxied {

    address public masterCopy;

}



/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.

/// @author Stefan George - <[email protected]>

contract Proxy is Proxied {

    /// @dev Constructor function sets address of master copy contract.

    /// @param _masterCopy Master copy address.

    constructor(address _masterCopy)

        public

    {

        require(_masterCopy != 0);

        masterCopy = _masterCopy;

    }



    /// @dev Fallback function forwards all transactions and returns all received return data.

    function ()

        external

        payable

    {

        address _masterCopy = masterCopy;

        assembly {

            calldatacopy(0, 0, calldatasize())

            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch success

            case 0 { revert(0, returndatasize()) }

            default { return(0, returndatasize()) }

        }

    }

}



// File: contracts/Tokens/OutcomeToken.sol



contract OutcomeTokenProxy is Proxy {

    /*

     *  Storage

     */



    // HACK: Lining up storage with StandardToken and OutcomeToken

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    mapping (address => mapping (address => uint256)) internal allowed;



    address internal eventContract;



    /*

     *  Public functions

     */

    /// @dev Constructor sets events contract address

    constructor(address proxied)

        public

        Proxy(proxied)

    {

        eventContract = msg.sender;

    }

}



/// @title Outcome token contract - Issuing and revoking outcome tokens

/// @author Stefan George - <[email protected]>

contract OutcomeToken is Proxied, StandardToken {

    using SafeMath for *;



    /*

     *  Events

     */

    event Issuance(address indexed owner, uint amount);

    event Revocation(address indexed owner, uint amount);



    /*

     *  Storage

     */

    address public eventContract;



    /*

     *  Modifiers

     */

    modifier isEventContract () {

        // Only event contract is allowed to proceed

        require(msg.sender == eventContract);

        _;

    }



    /*

     *  Public functions

     */

    /// @dev Events contract issues new tokens for address. Returns success

    /// @param _for Address of receiver

    /// @param outcomeTokenCount Number of tokens to issue

    function issue(address _for, uint outcomeTokenCount)

        public

        isEventContract

    {

        balances[_for] = balances[_for].add(outcomeTokenCount);

        totalSupply_ = totalSupply_.add(outcomeTokenCount);

        emit Issuance(_for, outcomeTokenCount);

    }



    /// @dev Events contract revokes tokens for address. Returns success

    /// @param _for Address of token holder

    /// @param outcomeTokenCount Number of tokens to revoke

    function revoke(address _for, uint outcomeTokenCount)

        public

        isEventContract

    {

        balances[_for] = balances[_for].sub(outcomeTokenCount);

        totalSupply_ = totalSupply_.sub(outcomeTokenCount);

        emit Revocation(_for, outcomeTokenCount);

    }

}



// File: contracts/Oracles/Oracle.sol



/// @title Abstract oracle contract - Functions to be implemented by oracles

contract Oracle {



    function isOutcomeSet() public view returns (bool);

    function getOutcome() public view returns (int);

}



// File: contracts/Events/Event.sol



contract EventData {



    /*

     *  Events

     */

    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);

    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);

    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);

    event OutcomeAssignment(int outcome);

    event WinningsRedemption(address indexed receiver, uint winnings);



    /*

     *  Storage

     */

    ERC20 public collateralToken;

    Oracle public oracle;

    bool public isOutcomeSet;

    int public outcome;

    OutcomeToken[] public outcomeTokens;

}



/// @title Event contract - Provide basic functionality required by different event types

/// @author Stefan George - <[email protected]>

contract Event is EventData {



    /*

     *  Public functions

     */

    /// @dev Buys equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1

    /// @param collateralTokenCount Number of collateral tokens

    function buyAllOutcomes(uint collateralTokenCount)

        public

    {

        // Transfer collateral tokens to events contract

        require(collateralToken.transferFrom(msg.sender, this, collateralTokenCount));

        // Issue new outcome tokens to sender

        for (uint8 i = 0; i < outcomeTokens.length; i++)

            outcomeTokens[i].issue(msg.sender, collateralTokenCount);

        emit OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);

    }



    /// @dev Sells equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1

    /// @param outcomeTokenCount Number of outcome tokens

    function sellAllOutcomes(uint outcomeTokenCount)

        public

    {

        // Revoke sender's outcome tokens of all outcomes

        for (uint8 i = 0; i < outcomeTokens.length; i++)

            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);

        // Transfer collateral tokens to sender

        require(collateralToken.transfer(msg.sender, outcomeTokenCount));

        emit OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);

    }



    /// @dev Sets winning event outcome

    function setOutcome()

        public

    {

        // Winning outcome is not set yet in event contract but in oracle contract

        require(!isOutcomeSet && oracle.isOutcomeSet());

        // Set winning outcome

        outcome = oracle.getOutcome();

        isOutcomeSet = true;

        emit OutcomeAssignment(outcome);

    }



    /// @dev Returns outcome count

    /// @return Outcome count

    function getOutcomeCount()

        public

        view

        returns (uint8)

    {

        return uint8(outcomeTokens.length);

    }



    /// @dev Returns outcome tokens array

    /// @return Outcome tokens

    function getOutcomeTokens()

        public

        view

        returns (OutcomeToken[])

    {

        return outcomeTokens;

    }



    /// @dev Returns the amount of outcome tokens held by owner

    /// @return Outcome token distribution

    function getOutcomeTokenDistribution(address owner)

        public

        view

        returns (uint[] outcomeTokenDistribution)

    {

        outcomeTokenDistribution = new uint[](outcomeTokens.length);

        for (uint8 i = 0; i < outcomeTokenDistribution.length; i++)

            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);

    }



    /// @dev Calculates and returns event hash

    /// @return Event hash

    function getEventHash() public view returns (bytes32);



    /// @dev Exchanges sender's winning outcome tokens for collateral tokens

    /// @return Sender's winnings

    function redeemWinnings() public returns (uint);

}



// File: contracts/Events/ScalarEvent.sol



contract ScalarEventData {



    /*

     *  Constants

     */

    uint8 public constant SHORT = 0;

    uint8 public constant LONG = 1;

    uint24 public constant OUTCOME_RANGE = 1000000;



    /*

     *  Storage

     */

    int public lowerBound;

    int public upperBound;

}



contract ScalarEventProxy is Proxy, EventData, ScalarEventData {



    /// @dev Contract constructor validates and sets basic event properties

    /// @param _collateralToken Tokens used as collateral in exchange for outcome tokens

    /// @param _oracle Oracle contract used to resolve the event

    /// @param _lowerBound Lower bound for event outcome

    /// @param _upperBound Lower bound for event outcome

    constructor(

        address proxied,

        address outcomeTokenMasterCopy,

        ERC20 _collateralToken,

        Oracle _oracle,

        int _lowerBound,

        int _upperBound

    )

        Proxy(proxied)

        public

    {

        // Validate input

        require(address(_collateralToken) != 0 && address(_oracle) != 0);

        collateralToken = _collateralToken;

        oracle = _oracle;

        // Create an outcome token for each outcome

        for (uint8 i = 0; i < 2; i++) {

            OutcomeToken outcomeToken = OutcomeToken(new OutcomeTokenProxy(outcomeTokenMasterCopy));

            outcomeTokens.push(outcomeToken);

            emit OutcomeTokenCreation(outcomeToken, i);

        }



        // Validate bounds

        require(_upperBound > _lowerBound);

        lowerBound = _lowerBound;

        upperBound = _upperBound;

    }

}



/// @title Scalar event contract - Scalar events resolve to a number within a range

/// @author Stefan George - <[email protected]>

contract ScalarEvent is Proxied, Event, ScalarEventData {

    using SafeMath for *;



    /*

     *  Public functions

     */

    /// @dev Exchanges sender's winning outcome tokens for collateral tokens

    /// @return Sender's winnings

    function redeemWinnings()

        public

        returns (uint winnings)

    {

        // Winning outcome has to be set

        require(isOutcomeSet);

        // Calculate winnings

        uint24 convertedWinningOutcome;

        // Outcome is lower than defined lower bound

        if (outcome < lowerBound)

            convertedWinningOutcome = 0;

        // Outcome is higher than defined upper bound

        else if (outcome > upperBound)

            convertedWinningOutcome = OUTCOME_RANGE;

        // Map outcome to outcome range

        else

            convertedWinningOutcome = uint24(OUTCOME_RANGE * (outcome - lowerBound) / (upperBound - lowerBound));

        uint factorShort = OUTCOME_RANGE - convertedWinningOutcome;

        uint factorLong = OUTCOME_RANGE - factorShort;

        uint shortOutcomeTokenCount = outcomeTokens[SHORT].balanceOf(msg.sender);

        uint longOutcomeTokenCount = outcomeTokens[LONG].balanceOf(msg.sender);

        winnings = shortOutcomeTokenCount.mul(factorShort).add(longOutcomeTokenCount.mul(factorLong)) / OUTCOME_RANGE;

        // Revoke all outcome tokens

        outcomeTokens[SHORT].revoke(msg.sender, shortOutcomeTokenCount);

        outcomeTokens[LONG].revoke(msg.sender, longOutcomeTokenCount);

        // Payout winnings to sender

        require(collateralToken.transfer(msg.sender, winnings));

        emit WinningsRedemption(msg.sender, winnings);

    }



    /// @dev Calculates and returns event hash

    /// @return Event hash

    function getEventHash()

        public

        view

        returns (bytes32)

    {

        return keccak256(abi.encodePacked(collateralToken, oracle, lowerBound, upperBound));

    }

}