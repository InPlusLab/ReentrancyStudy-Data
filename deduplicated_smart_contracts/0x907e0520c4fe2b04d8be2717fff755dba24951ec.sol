/**

 *Submitted for verification at Etherscan.io on 2019-01-25

*/



pragma solidity ^0.5.2;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}

pragma solidity ^0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

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

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}

pragma solidity ^0.5.2;







/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using SafeMath for uint256;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));

        require(token.approve(spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        require(token.approve(spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);

        require(token.approve(spender, newAllowance));

    }

}

pragma solidity ^0.5.2;



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

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

    address payable private _wallet;



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

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    /**

     * @param rate Number of token units a buyer gets per wei

     * @dev The rate is the conversion between wei and the smallest and indivisible

     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token

     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.

     * @param wallet Address where collected funds will be forwarded to

     * @param token Address of the token being sold

     */

    constructor (uint256 rate, address payable wallet, IERC20 token) public {

        require(rate > 0);

        require(wallet != address(0));

        require(address(token) != address(0));



        _rate = rate;

        _wallet = wallet;

        _token = token;

    }



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

    function token() public view returns (IERC20) {

        return _token;

    }



    /**

     * @return the address where funds are collected.

     */

    function wallet() public view returns (address payable) {

        return _wallet;

    }



    /**

     * @return the number of token units a buyer gets per wei.

     */

    function rate() public view returns (uint256) {

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

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);



        _updatePurchasingState(beneficiary, weiAmount);



        _forwardFunds();

        _postValidatePurchase(beneficiary, weiAmount);

    }



    /**

     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.

     * Use `super` in contracts that inherit from Crowdsale to extend their validations.

     * Example from CappedCrowdsale.sol's _preValidatePurchase method:

     *     super._preValidatePurchase(beneficiary, weiAmount);

     *     require(weiRaised().add(weiAmount) <= cap);

     * @param beneficiary Address performing the token purchase

     * @param weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0));

        require(weiAmount != 0);

    }



    /**

     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid

     * conditions are not met.

     * @param beneficiary Address performing the token purchase

     * @param weiAmount Value in wei involved in the purchase

     */

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        // solhint-disable-previous-line no-empty-blocks

    }



    /**

     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends

     * its tokens.

     * @param beneficiary Address performing the token purchase

     * @param tokenAmount Number of tokens to be emitted

     */

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.safeTransfer(beneficiary, tokenAmount);

    }



    /**

     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send

     * tokens.

     * @param beneficiary Address receiving the tokens

     * @param tokenAmount Number of tokens to be purchased

     */

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _deliverTokens(beneficiary, tokenAmount);

    }



    /**

     * @dev Override for extensions that require an internal state to check for validity (current user contributions,

     * etc.)

     * @param beneficiary Address receiving the tokens

     * @param weiAmount Value in wei involved in the purchase

     */

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        // solhint-disable-previous-line no-empty-blocks

    }



    /**

     * @dev Override to extend the way in which ether is converted to tokens.

     * @param weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified _weiAmount

     */

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.mul(_rate);

    }



    /**

     * @dev Determines how ETH is stored/forwarded on purchases.

     */

    function _forwardFunds() internal {

        _wallet.transfer(msg.value);

    }

}