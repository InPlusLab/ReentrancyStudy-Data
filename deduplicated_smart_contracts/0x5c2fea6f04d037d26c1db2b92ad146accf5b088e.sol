/**

 *Submitted for verification at Etherscan.io on 2018-12-01

*/



pragma solidity ^0.4.25;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

  function totalSupply() external view returns (uint256);



  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender)

    external view returns (uint256);



  function transfer(address to, uint256 value) external returns (bool);



  function approve(address spender, uint256 value)

    external returns (bool);



  function transferFrom(address from, address to, uint256 value)

    external returns (bool);



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



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {



  using SafeMath for uint256;



  function safeTransfer(

    IERC20 token,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(

    IERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    // safeApprove should only be called when setting an initial allowance,

    // or when resetting it to zero. To increase and decrease it, use

    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

    require((value == 0) || (token.allowance(msg.sender, spender) == 0));

    require(token.approve(spender, value));

  }



  function safeIncreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).add(value);

    require(token.approve(spender, newAllowance));

  }



  function safeDecreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value);

    require(token.approve(spender, newAllowance));

  }

}



// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev counter to allow mutex lock with only one SSTORE operation

  uint256 private _guardCounter;



  constructor() internal {

    // The counter starts at one to prevent changing it from zero to a non-zero

    // value, which is a more expensive operation.

    _guardCounter = 1;

  }



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * Calling a `nonReentrant` function from another `nonReentrant`

   * function is not supported. It is possible to prevent this from happening

   * by making the `nonReentrant` function external, and make it call a

   * `private` function that does the actual work.

   */

  modifier nonReentrant() {

    _guardCounter += 1;

    uint256 localCounter = _guardCounter;

    _;

    require(localCounter == _guardCounter);

  }



}



// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol



/**

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropriate to concatenate

 * behavior.

 */

contract Crowdsale is ReentrancyGuard {

  using SafeMath for uint256;

  using SafeERC20 for IERC20;



  // The token being sold

  IERC20 private _token;



  // Address where funds are collected

  address private _wallet;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 private _rate;



  // Amount of wei raised

  uint256 private _weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokensPurchased(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param rate Number of token units a buyer gets per wei

   * @dev The rate is the conversion between wei and the smallest and indivisible

   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token

   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.

   * @param wallet Address where collected funds will be forwarded to

   * @param token Address of the token being sold

   */

  constructor(uint256 rate, address wallet, IERC20 token) internal {

    require(rate > 0);

    require(wallet != address(0));

    require(token != address(0));



    _rate = rate;

    _wallet = wallet;

    _token = token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   * Note that other contracts will transfer fund with a base gas stipend

   * of 2300, which is not enough to call buyTokens. Consider calling

   * buyTokens directly when purchasing tokens from a contract.

   */

  function () external payable {

    buyTokens(msg.sender);

  }



  /**

   * @return the token being sold.

   */

  function token() public view returns(IERC20) {

    return _token;

  }



  /**

   * @return the address where funds are collected.

   */

  function wallet() public view returns(address) {

    return _wallet;

  }



  /**

   * @return the number of token units a buyer gets per wei.

   */

  function rate() public view returns(uint256) {

    return _rate;

  }



  /**

   * @return the amount of wei raised.

   */

  function weiRaised() public view returns (uint256) {

    return _weiRaised;

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * This function has a non-reentrancy guard, so it shouldn't be called by

   * another `nonReentrant` function.

   * @param beneficiary Recipient of the token purchase

   */

  function buyTokens(address beneficiary) public nonReentrant payable {



    uint256 weiAmount = msg.value;

    _preValidatePurchase(beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    _weiRaised = _weiRaised.add(weiAmount);



    _processPurchase(beneficiary, tokens);

    emit TokensPurchased(

      msg.sender,

      beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(beneficiary, weiAmount);



    _forwardFunds();

    _postValidatePurchase(beneficiary, weiAmount);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.

   * Example from CappedCrowdsale.sol's _preValidatePurchase method:

   *   super._preValidatePurchase(beneficiary, weiAmount);

   *   require(weiRaised().add(weiAmount) <= cap);

   * @param beneficiary Address performing the token purchase

   * @param weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    require(beneficiary != address(0));

    require(weiAmount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param beneficiary Address performing the token purchase

   * @param weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    // optional override

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param beneficiary Address performing the token purchase

   * @param tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    _token.safeTransfer(beneficiary, tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.

   * @param beneficiary Address receiving the tokens

   * @param tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    _deliverTokens(beneficiary, tokenAmount);

  }



  /**

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param beneficiary Address receiving the tokens

   * @param weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address beneficiary,

    uint256 weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 weiAmount)

    internal view returns (uint256)

  {

    return weiAmount.mul(_rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    _wallet.transfer(msg.value);

  }

}



// File: openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol



/**

 * @title TimedCrowdsale

 * @dev Crowdsale accepting contributions only within a time frame.

 */

contract TimedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 private _openingTime;

  uint256 private _closingTime;



  /**

   * @dev Reverts if not in crowdsale time range.

   */

  modifier onlyWhileOpen {

    require(isOpen());

    _;

  }



  /**

   * @dev Constructor, takes crowdsale opening and closing times.

   * @param openingTime Crowdsale opening time

   * @param closingTime Crowdsale closing time

   */

  constructor(uint256 openingTime, uint256 closingTime) internal {

    // solium-disable-next-line security/no-block-members

    require(openingTime >= block.timestamp);

    require(closingTime > openingTime);



    _openingTime = openingTime;

    _closingTime = closingTime;

  }



  /**

   * @return the crowdsale opening time.

   */

  function openingTime() public view returns(uint256) {

    return _openingTime;

  }



  /**

   * @return the crowdsale closing time.

   */

  function closingTime() public view returns(uint256) {

    return _closingTime;

  }



  /**

   * @return true if the crowdsale is open, false otherwise.

   */

  function isOpen() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

  }



  /**

   * @dev Checks whether the period in which the crowdsale is open has already elapsed.

   * @return Whether crowdsale period has elapsed

   */

  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > _closingTime;

  }



  /**

   * @dev Extend parent behavior requiring to be within contributing period

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    onlyWhileOpen

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

  }



}



// File: openzeppelin-solidity/contracts/math/Math.sol



/**

 * @title Math

 * @dev Assorted math operations

 */

library Math {

  /**

  * @dev Returns the largest of two numbers.

  */

  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;

  }



  /**

  * @dev Returns the smallest of two numbers.

  */

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;

  }



  /**

  * @dev Calculates the average of two numbers. Since these are integers,

  * averages of an even and odd number cannot be represented, and will be

  * rounded down.

  */

  function average(uint256 a, uint256 b) internal pure returns (uint256) {

    // (a + b) / 2 can overflow, so we distribute

    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

  }

}



// File: openzeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol



/**

 * @title AllowanceCrowdsale

 * @dev Extension of Crowdsale where tokens are held by a wallet, which approves an allowance to the crowdsale.

 */

contract AllowanceCrowdsale is Crowdsale {

  using SafeMath for uint256;

  using SafeERC20 for IERC20;



  address private _tokenWallet;



  /**

   * @dev Constructor, takes token wallet address.

   * @param tokenWallet Address holding the tokens, which has approved allowance to the crowdsale

   */

  constructor(address tokenWallet) internal {

    require(tokenWallet != address(0));

    _tokenWallet = tokenWallet;

  }



  /**

   * @return the address of the wallet that will hold the tokens.

   */

  function tokenWallet() public view returns(address) {

    return _tokenWallet;

  }



  /**

   * @dev Checks the amount of tokens left in the allowance.

   * @return Amount of tokens left in the allowance

   */

  function remainingTokens() public view returns (uint256) {

    return Math.min(

      token().balanceOf(_tokenWallet),

      token().allowance(_tokenWallet, this)

    );

  }



  /**

   * @dev Overrides parent behavior by transferring tokens from wallet.

   * @param beneficiary Token purchaser

   * @param tokenAmount Amount of tokens purchased

   */

  function _deliverTokens(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    token().safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);

  }

}



// File: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol



/**

 * @title CappedCrowdsale

 * @dev Crowdsale with a limit for total contributions.

 */

contract CappedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 private _cap;



  /**

   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

   * @param cap Max amount of wei to be contributed

   */

  constructor(uint256 cap) internal {

    require(cap > 0);

    _cap = cap;

  }



  /**

   * @return the cap of the crowdsale.

   */

  function cap() public view returns(uint256) {

    return _cap;

  }



  /**

   * @dev Checks whether the cap has been reached.

   * @return Whether the cap was reached

   */

  function capReached() public view returns (bool) {

    return weiRaised() >= _cap;

  }



  /**

   * @dev Extend parent behavior requiring purchase to respect the funding cap.

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

    require(weiRaised().add(weiAmount) <= _cap);

  }



}



// File: contracts/BitherCrowdsale.sol



/**

 * @title BitherCrowdsale

 * @dev BitherCrowdsale contract uses multiple openzeppelin base contracts and adds some custom behaviour.

 *      The openzeppelin base contracts have been audited and are widely used by the community. They can

 *      be trusted to have almost zero security vulnerabilities and therefore do not need to be tested.

 *      The BitherCrowdale enables the purchasing of 2 tokens, the BitherToken (BTR) and BitherStockToken

 *      (BSK) at rates determined by the current block time. It specifies a cap of Ether that can be contributed

 *      and a length of time the crowdsale lasts. It requires the crowdsale contract address be given

 *      an allowance of 33000000 BTR and 21000000 BSK enabling it to distribute the purchased tokens. These

 *      values are determined by the cap of 300000 ETH and the phased distribution rates.

 */

contract BitherCrowdsale is AllowanceCrowdsale, TimedCrowdsale, CappedCrowdsale {



    uint256 constant private CAP_IN_WEI = 300000 ether;



    uint256 constant private BTR_PRIVATE_SALE_RATE = 110;

    uint256 constant private BTR_PRESALE_RATE_DAY_1 = 110;

    uint256 constant private BTR_PRESALE_RATE_DAY_2_TO_5 = 109;

    uint256 constant private BTR_PRESALE_RATE_DAY_6_TO_9 = 108;

    uint256 constant private BTR_PRESALE_RATE_DAY_10_TO_13 = 107;



    uint256 constant private BTR_CROWDSALE_RATE_DAY_1_FIRST_2_HOURS = 110;

    uint256 constant private BTR_CROWDSALE_RATE_DAY_1_TO_7 = 106;

    uint256 constant private BTR_CROWDSALE_RATE_DAY_8_TO_14 = 104;

    uint256 constant private BTR_CROWDSALE_RATE_DAY_15_TO_21 = 102;

    uint256 constant private BTR_CROWDSALE_RATE_DAY_22_TO_28 = 100;



    uint256 constant private BSK_PRIVATE_SALE_RATE = 70;

    uint256 constant private BSK_PRESALE_RATE_FIRST_2_HOURS = 70;

    uint256 constant private BSK_PRESALE_RATE_DAY_1 = 68;

    uint256 constant private BSK_PRESALE_RATE_DAY_2_TO_5 = 66;

    uint256 constant private BSK_PRESALE_RATE_DAY_6_TO_9 = 64;

    uint256 constant private BSK_PRESALE_RATE_DAY_10_TO_13 = 62;



    uint256 constant private BSK_CROWDSALE_RATE_DAY_1_TO_7 = 60;

    uint256 constant private BSK_CROWDSALE_RATE_DAY_8_TO_14 = 57;

    uint256 constant private BSK_CROWDSALE_RATE_DAY_15_TO_21 = 54;

    uint256 constant private BSK_CROWDSALE_RATE_DAY_22_TO_28 = 50;



    IERC20 private _bitherStockToken;

    uint256 private _privateSaleClosingTime; // Thursday, 24 January 2019 14:00:00 (1548338400)

    uint256 private _presaleOpeningTime; // Saturday, 26 January 2019 14:00:00 (1548511200)

    uint256 private _crowdsaleOpeningTime; // Saturday, 16 February 2019 14:00:00 (1550325600)

    uint256 private _crowdsaleClosingTime; // Saturday, 16 March 2019 14:00:00 (1552744800)



    /**

     * Event for BSK token purchase logging

     * @param purchaser Who paid for the tokens

     * @param beneficiary Who got the tokens

     * @param value Wei paid for purchase

     * @param amount Amount of tokens purchased

     */

    event BitherStockTokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    /**

     * @dev Constructor, calls the inherited classes constructors, stores bitherStockToken and determines crowdsale times

     * @param bitherToken The BitherToken address, must be an ERC20 contract

     * @param bitherStockToken The BitherStockToken, must be an ERC20 contract

     * @param bitherTokensOwner Address holding the tokens, which has approved allowance to the crowdsale

     * @param etherBenefactor Address that will receive the deposited Ether

     * @param preSaleOpeningTime The presale opening time, in seconds, all other times are determined using this to reduce risk of error

     */

    constructor(IERC20 bitherToken, IERC20 bitherStockToken, address bitherTokensOwner, address etherBenefactor, uint256 preSaleOpeningTime)

        Crowdsale(BTR_PRIVATE_SALE_RATE, etherBenefactor, bitherToken)

        AllowanceCrowdsale(bitherTokensOwner)

        TimedCrowdsale(now, preSaleOpeningTime + 7 weeks)

        CappedCrowdsale(CAP_IN_WEI)

        public

    {

        _bitherStockToken = bitherStockToken;



        _privateSaleClosingTime = preSaleOpeningTime - 2 days;

        _presaleOpeningTime = preSaleOpeningTime;

        _crowdsaleOpeningTime = preSaleOpeningTime + 3 weeks;

        _crowdsaleClosingTime = _crowdsaleOpeningTime + 4 weeks;

    }



    /**

     * @dev Overrides function in the Crowdsale contract to revert contributions less then

     *      69 Eth during the first period and less than 0.1 Eth during the rest of the crowdsale

     * @param beneficiary Address performing the token purchase

     * @param weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        super._preValidatePurchase(beneficiary, weiAmount);



        if (now < _privateSaleClosingTime) {

            require(weiAmount >= 69 ether, "Not enough Eth. Contributions must be 69 Eth minimum during the private sale");

        } else {

            require(weiAmount >= 100 finney, "Not enough Eth. Contributions must be 0.1 Eth minimum during the presale and crowdsale");

        }



        if (now > _privateSaleClosingTime && now < _presaleOpeningTime) {

            revert("Private sale has ended and the presale is yet to begin");

        } else if (now > _presaleOpeningTime + 13 days && now < _crowdsaleOpeningTime) {

            revert("Presale has ended and the crowdsale is yet to begin");

        }

    }



    /**

     * @dev Overrides function in the Crowdsale contract to enable a custom phased distribution

     * @param weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified weiAmount

     */

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {



        if (now < _privateSaleClosingTime) {

            return weiAmount.mul(BTR_PRIVATE_SALE_RATE);



        } else if (now < _presaleOpeningTime + 1 days) {

            return weiAmount.mul(BTR_PRESALE_RATE_DAY_1);

        } else if (now < _presaleOpeningTime + 5 days) {

            return weiAmount.mul(BTR_PRESALE_RATE_DAY_2_TO_5);

        } else if (now < _presaleOpeningTime + 9 days) {

            return weiAmount.mul(BTR_PRESALE_RATE_DAY_6_TO_9);

        } else if (now < _presaleOpeningTime + 13 days) {

            return weiAmount.mul(BTR_PRESALE_RATE_DAY_10_TO_13);



        } else if (now < _crowdsaleOpeningTime + 2 hours) {

            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_1_FIRST_2_HOURS);

        } else if (now < _crowdsaleOpeningTime + 1 weeks) {

            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_1_TO_7);

        } else if (now < _crowdsaleOpeningTime + 2 weeks) {

            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_8_TO_14);

        } else if (now < _crowdsaleOpeningTime + 3 weeks) {

            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_15_TO_21);

        } else if (now <= closingTime()) {

            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_22_TO_28);

        }

    }



    /**

     * @dev Overrides function in AllowanceCrowdsale contract (therefore also overrides function

     *      in Crowdsale contract) to add functionality for distribution of a second token, BSK.

     * @param beneficiary Token purchaser

     * @param tokenAmount Amount of tokens purchased

     */

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        super._deliverTokens(beneficiary, tokenAmount);



        uint256 weiAmount = msg.value;

        uint256 bskTokenAmount = getBskTokenAmount(weiAmount);



        _bitherStockToken.safeTransferFrom(tokenWallet(), beneficiary, bskTokenAmount);



        emit BitherStockTokensPurchased(msg.sender, beneficiary, weiAmount, bskTokenAmount);

    }



    /**

     * @dev Determines distribution of BSK depending on the time of the transaction

     * @param weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified weiAmount

     */

    function getBskTokenAmount(uint256 weiAmount) private view returns (uint256) {



        if (now < _privateSaleClosingTime) {

            return weiAmount.mul(BSK_PRIVATE_SALE_RATE);



        } else if (now < _presaleOpeningTime + 2 hours) {

            return weiAmount.mul(BSK_PRESALE_RATE_FIRST_2_HOURS);

        } else if (now < _presaleOpeningTime + 1 days) {

            return weiAmount.mul(BSK_PRESALE_RATE_DAY_1);

        } else if (now < _presaleOpeningTime + 5 days) {

            return weiAmount.mul(BSK_PRESALE_RATE_DAY_2_TO_5);

        } else if (now < _presaleOpeningTime + 9 days) {

            return weiAmount.mul(BSK_PRESALE_RATE_DAY_6_TO_9);

        } else if (now < _presaleOpeningTime + 13 days) {

            return weiAmount.mul(BSK_PRESALE_RATE_DAY_10_TO_13);



        } else if (now < _crowdsaleOpeningTime + 1 weeks) {

            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_1_TO_7);

        } else if (now < _crowdsaleOpeningTime + 2 weeks) {

            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_8_TO_14);

        } else if (now < _crowdsaleOpeningTime + 3 weeks) {

            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_15_TO_21);

        } else if (now <= closingTime()) {

            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_22_TO_28);

        }

    }

}