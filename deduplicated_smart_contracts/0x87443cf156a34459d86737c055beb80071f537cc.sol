/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;





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



/// @title Abstract oracle contract - Functions to be implemented by oracles

contract Oracle {



    function isOutcomeSet() public view returns (bool);

    function getOutcome() public view returns (int);

}





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





/// @title Abstract market maker contract - Functions to be implemented by market maker contracts

contract MarketMaker {



    /*

     *  Public functions

     */

    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);

    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);

    function calcNetCost(Market market, int[] outcomeTokenAmounts) public view returns (int);

    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex) public view returns (uint);

}





contract MarketData {

    /*

     *  Events

     */

    event MarketFunding(uint funding);

    event MarketClosing();

    event FeeWithdrawal(uint fees);

    event OutcomeTokenPurchase(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenCost, uint marketFees);

    event OutcomeTokenSale(address indexed seller, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenProfit, uint marketFees);

    event OutcomeTokenShortSale(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint cost);

    event OutcomeTokenTrade(address indexed transactor, int[] outcomeTokenAmounts, int outcomeTokenNetCost, uint marketFees);



    /*

     *  Storage

     */

    address public creator;

    uint public createdAtBlock;

    Event public eventContract;

    MarketMaker public marketMaker;

    uint24 public fee;

    uint public funding;

    int[] public netOutcomeTokensSold;

    Stages public stage;



    enum Stages {

        MarketCreated,

        MarketFunded,

        MarketClosed

    }

}



/// @title Abstract market contract - Functions to be implemented by market contracts

contract Market is MarketData {

    /*

     *  Public functions

     */

    function fund(uint _funding) public;

    function close() public;

    function withdrawFees() public returns (uint);

    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost) public returns (uint);

    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);

    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);

    function trade(int[] outcomeTokenAmounts, int costLimit) public returns (int);

    function calcMarketFee(uint outcomeTokenCost) public view returns (uint);

}





contract StandardMarketData {

    /*

     *  Constants

     */

    uint24 public constant FEE_RANGE = 1000000; // 100%

}



contract StandardMarketProxy is Proxy, MarketData, StandardMarketData {

    constructor(address proxy, address _creator, Event _eventContract, MarketMaker _marketMaker, uint24 _fee)

        Proxy(proxy)

        public

    {

        // Validate inputs

        require(address(_eventContract) != 0 && address(_marketMaker) != 0 && _fee < FEE_RANGE);

        creator = _creator;

        createdAtBlock = block.number;

        eventContract = _eventContract;

        netOutcomeTokensSold = new int[](eventContract.getOutcomeCount());

        fee = _fee;

        marketMaker = _marketMaker;

        stage = Stages.MarketCreated;

    }

}



/// @title Standard market contract - Backed implementation of standard markets

/// @author Stefan George - <[email protected]>

contract StandardMarket is Proxied, Market, StandardMarketData {

    using SafeMath for *;



    /*

     *  Modifiers

     */

    modifier isCreator() {

        // Only creator is allowed to proceed

        require(msg.sender == creator);

        _;

    }



    modifier atStage(Stages _stage) {

        // Contract has to be in given stage

        require(stage == _stage);

        _;

    }



    /*

     *  Public functions

     */

    /// @dev Allows to fund the market with collateral tokens converting them into outcome tokens

    /// @param _funding Funding amount

    function fund(uint _funding)

        public

        isCreator

        atStage(Stages.MarketCreated)

    {

        // Request collateral tokens and allow event contract to transfer them to buy all outcomes

        require(   eventContract.collateralToken().transferFrom(msg.sender, this, _funding)

                && eventContract.collateralToken().approve(eventContract, _funding));

        eventContract.buyAllOutcomes(_funding);

        funding = _funding;

        stage = Stages.MarketFunded;

        emit MarketFunding(funding);

    }



    /// @dev Allows market creator to close the markets by transferring all remaining outcome tokens to the creator

    function close()

        public

        isCreator

        atStage(Stages.MarketFunded)

    {

        uint8 outcomeCount = eventContract.getOutcomeCount();

        for (uint8 i = 0; i < outcomeCount; i++)

            require(eventContract.outcomeTokens(i).transfer(creator, eventContract.outcomeTokens(i).balanceOf(this)));

        stage = Stages.MarketClosed;

        emit MarketClosing();

    }



    /// @dev Allows market creator to withdraw fees generated by trades

    /// @return Fee amount

    function withdrawFees()

        public

        isCreator

        returns (uint fees)

    {

        fees = eventContract.collateralToken().balanceOf(this);

        // Transfer fees

        require(eventContract.collateralToken().transfer(creator, fees));

        emit FeeWithdrawal(fees);

    }



    /// @dev Allows to buy outcome tokens from market maker

    /// @param outcomeTokenIndex Index of the outcome token to buy

    /// @param outcomeTokenCount Amount of outcome tokens to buy

    /// @param maxCost The maximum cost in collateral tokens to pay for outcome tokens

    /// @return Cost in collateral tokens

    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost)

        public

        atStage(Stages.MarketFunded)

        returns (uint cost)

    {

        require(int(outcomeTokenCount) >= 0 && int(maxCost) > 0);

        uint8 outcomeCount = eventContract.getOutcomeCount();

        require(outcomeTokenIndex >= 0 && outcomeTokenIndex < outcomeCount);

        int[] memory outcomeTokenAmounts = new int[](outcomeCount);

        outcomeTokenAmounts[outcomeTokenIndex] = int(outcomeTokenCount);

        (int netCost, int outcomeTokenNetCost, uint fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, int(maxCost));

        require(netCost >= 0 && outcomeTokenNetCost >= 0);

        cost = uint(netCost);

        emit OutcomeTokenPurchase(msg.sender, outcomeTokenIndex, outcomeTokenCount, uint(outcomeTokenNetCost), fees);

    }



    /// @dev Allows to sell outcome tokens to market maker

    /// @param outcomeTokenIndex Index of the outcome token to sell

    /// @param outcomeTokenCount Amount of outcome tokens to sell

    /// @param minProfit The minimum profit in collateral tokens to earn for outcome tokens

    /// @return Profit in collateral tokens

    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)

        public

        atStage(Stages.MarketFunded)

        returns (uint profit)

    {

        require(-int(outcomeTokenCount) <= 0 && -int(minProfit) < 0);

        uint8 outcomeCount = eventContract.getOutcomeCount();

        require(outcomeTokenIndex >= 0 && outcomeTokenIndex < outcomeCount);

        int[] memory outcomeTokenAmounts = new int[](outcomeCount);

        outcomeTokenAmounts[outcomeTokenIndex] = -int(outcomeTokenCount);

        (int netCost, int outcomeTokenNetCost, uint fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, -int(minProfit));

        require(netCost <= 0 && outcomeTokenNetCost <= 0);

        profit = uint(-netCost);

        emit OutcomeTokenSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, uint(-outcomeTokenNetCost), fees);

    }



    /// @dev Buys all outcomes, then sells all shares of selected outcome which were bought, keeping

    ///      shares of all other outcome tokens.

    /// @param outcomeTokenIndex Index of the outcome token to short sell

    /// @param outcomeTokenCount Amount of outcome tokens to short sell

    /// @param minProfit The minimum profit in collateral tokens to earn for short sold outcome tokens

    /// @return Cost to short sell outcome in collateral tokens

    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)

        public

        returns (uint cost)

    {

        // Buy all outcomes

        require(   eventContract.collateralToken().transferFrom(msg.sender, this, outcomeTokenCount)

                && eventContract.collateralToken().approve(eventContract, outcomeTokenCount));

        eventContract.buyAllOutcomes(outcomeTokenCount);

        // Short sell selected outcome

        eventContract.outcomeTokens(outcomeTokenIndex).approve(this, outcomeTokenCount);

        uint profit = this.sell(outcomeTokenIndex, outcomeTokenCount, minProfit);

        cost = outcomeTokenCount - profit;

        // Transfer outcome tokens to buyer

        uint8 outcomeCount = eventContract.getOutcomeCount();

        for (uint8 i = 0; i < outcomeCount; i++)

            if (i != outcomeTokenIndex)

                require(eventContract.outcomeTokens(i).transfer(msg.sender, outcomeTokenCount));

        // Send change back to buyer

        require(eventContract.collateralToken().transfer(msg.sender, profit));

        emit OutcomeTokenShortSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, cost);

    }



    /// @dev Allows to trade outcome tokens and collateral with the market maker

    /// @param outcomeTokenAmounts Amounts of each outcome token to buy or sell. If positive, will buy this amount of outcome token from the market. If negative, will sell this amount back to the market instead.

    /// @param collateralLimit If positive, this is the limit for the amount of collateral tokens which will be sent to the market to conduct the trade. If negative, this is the minimum amount of collateral tokens which will be received from the market for the trade. If zero, there is no limit.

    /// @return If positive, the amount of collateral sent to the market. If negative, the amount of collateral received from the market. If zero, no collateral was sent or received.

    function trade(int[] outcomeTokenAmounts, int collateralLimit)

        public

        atStage(Stages.MarketFunded)

        returns (int netCost)

    {

        uint8 outcomeCount = eventContract.getOutcomeCount();

        require(outcomeTokenAmounts.length == outcomeCount);



        int outcomeTokenNetCost;

        uint fees;

        (netCost, outcomeTokenNetCost, fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, collateralLimit);



        emit OutcomeTokenTrade(msg.sender, outcomeTokenAmounts, outcomeTokenNetCost, fees);

    }



    function tradeImpl(uint8 outcomeCount, int[] outcomeTokenAmounts, int collateralLimit)

        private

        returns (int netCost, int outcomeTokenNetCost, uint fees)

    {

        // Calculate net cost for executing trade

        outcomeTokenNetCost = marketMaker.calcNetCost(this, outcomeTokenAmounts);

        if(outcomeTokenNetCost < 0)

            fees = calcMarketFee(uint(-outcomeTokenNetCost));

        else

            fees = calcMarketFee(uint(outcomeTokenNetCost));



        require(int(fees) >= 0);

        netCost = outcomeTokenNetCost.add(int(fees));



        require(

            (collateralLimit != 0 && netCost <= collateralLimit) ||

            collateralLimit == 0

        );



        if(outcomeTokenNetCost > 0) {

            require(

                eventContract.collateralToken().transferFrom(msg.sender, this, uint(netCost)) &&

                eventContract.collateralToken().approve(eventContract, uint(outcomeTokenNetCost))

            );



            eventContract.buyAllOutcomes(uint(outcomeTokenNetCost));

        }



        for (uint8 i = 0; i < outcomeCount; i++) {

            if(outcomeTokenAmounts[i] != 0) {

                if(outcomeTokenAmounts[i] < 0) {

                    require(eventContract.outcomeTokens(i).transferFrom(msg.sender, this, uint(-outcomeTokenAmounts[i])));

                } else {

                    require(eventContract.outcomeTokens(i).transfer(msg.sender, uint(outcomeTokenAmounts[i])));

                }



                netOutcomeTokensSold[i] = netOutcomeTokensSold[i].add(outcomeTokenAmounts[i]);

            }

        }



        if(outcomeTokenNetCost < 0) {

            // This is safe since

            // 0x8000000000000000000000000000000000000000000000000000000000000000 ==

            // uint(-int(-0x8000000000000000000000000000000000000000000000000000000000000000))

            eventContract.sellAllOutcomes(uint(-outcomeTokenNetCost));

            if(netCost < 0) {

                require(eventContract.collateralToken().transfer(msg.sender, uint(-netCost)));

            }

        }

    }



    /// @dev Calculates fee to be paid to market maker

    /// @param outcomeTokenCost Cost for buying outcome tokens

    /// @return Fee for trade

    function calcMarketFee(uint outcomeTokenCost)

        public

        view

        returns (uint)

    {

        return outcomeTokenCost * fee / FEE_RANGE;

    }

}





/// @title Market factory contract - Allows to create market contracts

/// @author Stefan George - <[email protected]>

contract StandardMarketFactory {



    /*

     *  Events

     */

    event StandardMarketCreation(address indexed creator, Market market, Event eventContract, MarketMaker marketMaker, uint24 fee);



    /*

     *  Storage

     */

    StandardMarket public standardMarketMasterCopy;



    /*

     *  Public functions

     */

    constructor(StandardMarket _standardMarketMasterCopy) public {

        standardMarketMasterCopy = _standardMarketMasterCopy;

    }



    /// @dev Creates a new market contract

    /// @param eventContract Event contract

    /// @param marketMaker Market maker contract

    /// @param fee Market fee

    /// @return Market contract

    function createMarket(Event eventContract, MarketMaker marketMaker, uint24 fee)

        public

        returns (StandardMarket market)

    {

        market = StandardMarket(new StandardMarketProxy(standardMarketMasterCopy, msg.sender, eventContract, marketMaker, fee));

        emit StandardMarketCreation(msg.sender, market, eventContract, marketMaker, fee);

    }

}