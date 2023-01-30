/**

 *Submitted for verification at Etherscan.io on 2018-12-06

*/



pragma solidity ^0.4.23;





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

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

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

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropiate to concatenate

 * behavior.

 */

contract Crowdsale {

    using SafeMath for uint256;



    // The token being sold

    ERC20 public token;



    // Address where funds are collected

    address public wallet;



    // How many token units a buyer gets per wei.

    // The rate is the conversion between wei and the smallest and indivisible token unit.

    // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK

    // 1 wei will give you 1 unit, or 0.001 TOK.

    uint256 public rate;



    // Amount of wei raised

    uint256 public weiRaised;



    /**

     * Event for token purchase logging

     * @param purchaser who paid for the tokens

     * @param beneficiary who got the tokens

     * @param value weis paid for purchase

     * @param amount amount of tokens purchased

     */

    event TokenPurchase(

        address indexed purchaser,

        address indexed beneficiary,

        uint256 value,

        uint256 amount

    );



    /**

     * @param _rate Number of token units a buyer gets per wei

     * @param _wallet Address where collected funds will be forwarded to

     * @param _token Address of the token being sold

     */

    constructor(uint256 _rate, address _wallet, ERC20 _token) public {

        require(_rate > 0);

        require(_wallet != address(0));

        require(_token != address(0));



        rate = _rate;

        wallet = _wallet;

        token = _token;

    }



    // -----------------------------------------

    // Crowdsale external interface

    // -----------------------------------------



    /**

     * @dev fallback function ***DO NOT OVERRIDE***

     */

    function() external payable {

        buyTokens(msg.sender);

    }



    /**

     * @dev low level token purchase ***DO NOT OVERRIDE***

     * @param _beneficiary Address performing the token purchase

     */

    function buyTokens(address _beneficiary) public payable {



        uint256 weiAmount = msg.value;

        _preValidatePurchase(_beneficiary, weiAmount);



        // calculate token amount to be created

        uint256 tokens = _getTokenAmount(weiAmount);



        // update state

        weiRaised = weiRaised.add(weiAmount);



        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(

            msg.sender,

            _beneficiary,

            weiAmount,

            tokens

        );



        _processBonusStateSave(_beneficiary, weiAmount);



        _forwardFunds();

    }



    // -----------------------------------------

    // Internal interface (extensible)

    // -----------------------------------------



    /**

     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

     * @param _beneficiary Address performing the token purchase

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(

        address _beneficiary,

        uint256 _weiAmount

    )

    internal

    {

        require(_beneficiary != address(0));

        require(_weiAmount != 0);

    }



    /**

     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

     * @param _beneficiary Address performing the token purchase

     * @param _tokenAmount Number of tokens to be emitted

     */

    function _deliverTokens(

        address _beneficiary,

        uint256 _tokenAmount

    )

    internal

    {

        token.transfer(_beneficiary, _tokenAmount);

    }



    /**

     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

     * @param _beneficiary Address receiving the tokens

     * @param _tokenAmount Number of tokens to be purchased

     */

    function _processPurchase(

        address _beneficiary,

        uint256 _tokenAmount

    )

    internal

    {

        _deliverTokens(_beneficiary, _tokenAmount);

    }



    /**

     * @dev Override to extend the way in which ether is converted to tokens.

     * @param _weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified _weiAmount

     */

    function _getTokenAmount(uint256 _weiAmount)

    internal view returns (uint256)

    {

        return _weiAmount.mul(rate);

    }



    function _processBonusStateSave(

        address _beneficiary,

        uint256 _weiAmount

    )

    internal

    {

    }



    /**

     * @dev Determines how ETH is stored/forwarded on purchases.

     */

    function _forwardFunds() internal {

        wallet.transfer(msg.value);

    }

}





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

        require(token.transfer(to, value));

    }



    function safeTransferFrom(

        ERC20 token,

        address from,

        address to,

        uint256 value

    )

    internal

    {

        require(token.transferFrom(from, to, value));

    }



    function safeApprove(ERC20 token, address spender, uint256 value) internal {

        require(token.approve(spender, value));

    }

}





/**

 * @title AllowanceCrowdsale

 * @dev Extension of Crowdsale where tokens are held by a wallet, which approves an allowance to the crowdsale.

 */

contract AllowanceCrowdsale is Crowdsale {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;



    address public tokenWallet;



    /**

     * @dev Constructor, takes token wallet address.

     * @param _tokenWallet Address holding the tokens, which has approved allowance to the crowdsale

     */

    constructor(address _tokenWallet) public {

        require(_tokenWallet != address(0));

        tokenWallet = _tokenWallet;

    }



    /**

     * @dev Checks the amount of tokens left in the allowance.

     * @return Amount of tokens left in the allowance

     */

    function remainingTokens() public view returns (uint256) {

        return token.allowance(tokenWallet, this);

    }



    /**

     * @dev Overrides parent behavior by transferring tokens from wallet.

     * @param _beneficiary Token purchaser

     * @param _tokenAmount Amount of tokens purchased

     */

    function _deliverTokens(

        address _beneficiary,

        uint256 _tokenAmount

    )

    internal

    {

        token.safeTransferFrom(tokenWallet, _beneficiary, _tokenAmount);

    }

}





/**

 * @title TimedCrowdsale

 * @dev Crowdsale accepting contributions only within a time frame.

 */

contract TimedCrowdsale is Crowdsale {

    using SafeMath for uint256;



    uint256 public openingTime;



    /**

     * @dev Reverts if not in crowdsale time range.

     */

    modifier onlyWhileOpen {

        // solium-disable-next-line security/no-block-members

        require(isOpen());

        _;

    }



    /**

     * @dev Constructor, takes crowdsale opening and closing times.

     * @param _openingTime Crowdsale opening time

     */

    constructor(uint256 _openingTime) public {

        // solium-disable-next-line security/no-block-members

        require(_openingTime >= block.timestamp);



        openingTime = _openingTime;

    }



    /**

     * @return true if the crowdsale is open, false otherwise.

     */

    function isOpen() public view returns (bool) {

        // solium-disable-next-line security/no-block-members

        return block.timestamp >= openingTime;

    }



    /**

     * @dev Extend parent behavior requiring to be within contributing period

     * @param _beneficiary Token purchaser

     * @param _weiAmount Amount of wei contributed

     */

    function _preValidatePurchase(

        address _beneficiary,

        uint256 _weiAmount

    )

    internal

    onlyWhileOpen

    {

        super._preValidatePurchase(_beneficiary, _weiAmount);

    }



}





/**

 * @title CappedCrowdsale

 * @dev Crowdsale with a limit for total contributions.

 */

contract CappedCrowdsale is Crowdsale {

    using SafeMath for uint256;



    uint256 public cap;



    /**

     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

     * @param _cap Max amount of wei to be contributed

     */

    constructor(uint256 _cap) public {

        require(_cap > 0);

        cap = _cap;

    }



    /**

     * @dev Checks whether the cap has been reached.

     * @return Whether the cap was reached

     */

    function capReached() public view returns (bool) {

        return weiRaised >= cap;

    }



    /**

     * @dev Extend parent behavior requiring purchase to respect the funding cap.

     * @param _beneficiary Token purchaser

     * @param _weiAmount Amount of wei contributed

     */

    function _preValidatePurchase(

        address _beneficiary,

        uint256 _weiAmount

    )

    internal

    {

        super._preValidatePurchase(_beneficiary, _weiAmount);

        require(weiRaised.add(_weiAmount) <= cap);

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





contract TecoIco is Crowdsale, AllowanceCrowdsale, TimedCrowdsale, CappedCrowdsale, Ownable {

    using SafeMath for uint256;



    uint256 public bonusPercent;



    mapping(address => uint256) bonuses;



    constructor(uint256 _rate, address _wallet, ERC20 _token, address _tokenWallet, uint256 _openingTime, uint256 _cap)

    Crowdsale(_rate, _wallet, _token)

    AllowanceCrowdsale(_tokenWallet)

    TimedCrowdsale(_openingTime)

    CappedCrowdsale(_cap)

    public

    {

        require(_rate > 0);

        require(_wallet != address(0));

        require(_token != address(0));



        rate = _rate;

        wallet = _wallet;

        token = _token;

    }



    function setRate(uint256 _rate)

    public

    onlyOwner

    {

        rate = _rate;

    }



    function setBonusPercent(uint256 _bonusPercent)

    public

    onlyOwner

    {

        bonusPercent = _bonusPercent;

    }



    function getBonusTokenAmount(uint256 _weiAmount)

    public

    view

    returns (uint256)

    {

        if (bonusPercent > 0) {

            return _weiAmount.mul(rate).mul(bonusPercent).div(100);

        }

        return 0;

    }



    function _getTokenAmount(uint256 _weiAmount)

    internal

    view

    returns (uint256)

    {

        if (bonusPercent > 0) {

            return _weiAmount.mul(rate).mul(100 + bonusPercent).div(100);

        }

        return _weiAmount.mul(rate);

    }



    function _processBonusStateSave(

        address _beneficiary,

        uint256 _weiAmount

    )

    internal

    {

        bonuses[_beneficiary] = bonuses[_beneficiary].add(getBonusTokenAmount(_weiAmount));

        super._processBonusStateSave(_beneficiary, _weiAmount);

    }



    function bonusOf(address _owner) public view returns (uint256) {

        return bonuses[_owner];

    }

}