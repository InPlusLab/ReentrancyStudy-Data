/**

 *Submitted for verification at Etherscan.io on 2019-02-26

*/



pragma solidity ^0.4.24;



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



// File: openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol



/**

 * @title FinalizableCrowdsale

 * @dev Extension of Crowdsale with a one-off finalization action, where one

 * can do extra work after finishing.

 */

contract FinalizableCrowdsale is TimedCrowdsale {

    using SafeMath for uint256;



    bool private _finalized;



    event CrowdsaleFinalized();



    constructor() internal {

        _finalized = false;

    }



    /**

     * @return true if the crowdsale is finalized, false otherwise.

     */

    function finalized() public view returns (bool) {

        return _finalized;

    }



    /**

     * @dev Must be called after crowdsale ends, to do some extra finalization

     * work. Calls the contract's finalization function.

     */

    function finalize() public {

        require(!_finalized);

        require(hasClosed());



        _finalized = true;



        _finalization();

        emit CrowdsaleFinalized();

    }



    /**

     * @dev Can be overridden to add finalization logic. The overriding function

     * should call super._finalization() to ensure the chain of finalization is

     * executed entirely.

     */

    function _finalization() internal {

    }

}



// File: openzeppelin-solidity/contracts/ownership/Secondary.sol



/**

 * @title Secondary

 * @dev A Secondary contract can only be used by its primary account (the one that created it)

 */

contract Secondary {

    address private _primary;



    event PrimaryTransferred(

        address recipient

    );



    /**

     * @dev Sets the primary account to the one that is creating the Secondary contract.

     */

    constructor() internal {

        _primary = msg.sender;

        emit PrimaryTransferred(_primary);

    }



    /**

     * @dev Reverts if called from any account other than the primary.

     */

    modifier onlyPrimary() {

        require(msg.sender == _primary);

        _;

    }



    /**

     * @return the address of the primary.

     */

    function primary() public view returns (address) {

        return _primary;

    }



    /**

     * @dev Transfers contract to a new primary.

     * @param recipient The address of new primary.

     */

    function transferPrimary(address recipient) public onlyPrimary {

        require(recipient != address(0));

        _primary = recipient;

        emit PrimaryTransferred(_primary);

    }

}



// File: openzeppelin-solidity/contracts/payment/escrow/Escrow.sol



/**

 * @title Escrow

 * @dev Base escrow contract, holds funds designated for a payee until they

 * withdraw them.

 * @dev Intended usage: This contract (and derived escrow contracts) should be a

 * standalone contract, that only interacts with the contract that instantiated

 * it. That way, it is guaranteed that all Ether will be handled according to

 * the Escrow rules, and there is no need to check for payable functions or

 * transfers in the inheritance tree. The contract that uses the escrow as its

 * payment method should be its primary, and provide public methods redirecting

 * to the escrow's deposit and withdraw.

 */

contract Escrow is Secondary {

    using SafeMath for uint256;



    event Deposited(address indexed payee, uint256 weiAmount);

    event Withdrawn(address indexed payee, uint256 weiAmount);



    mapping(address => uint256) private _deposits;



    function depositsOf(address payee) public view returns (uint256) {

        return _deposits[payee];

    }



    /**

    * @dev Stores the sent amount as credit to be withdrawn.

    * @param payee The destination address of the funds.

    */

    function deposit(address payee) public onlyPrimary payable {

        uint256 amount = msg.value;

        _deposits[payee] = _deposits[payee].add(amount);



        emit Deposited(payee, amount);

    }



    /**

    * @dev Withdraw accumulated balance for a payee.

    * @param payee The address whose funds will be withdrawn and transferred to.

    */

    function withdraw(address payee) public onlyPrimary {

        uint256 payment = _deposits[payee];



        _deposits[payee] = 0;



        payee.transfer(payment);



        emit Withdrawn(payee, payment);

    }

}



// File: openzeppelin-solidity/contracts/payment/escrow/ConditionalEscrow.sol



/**

 * @title ConditionalEscrow

 * @dev Base abstract escrow to only allow withdrawal if a condition is met.

 * @dev Intended usage: See Escrow.sol. Same usage guidelines apply here.

 */

contract ConditionalEscrow is Escrow {

    /**

    * @dev Returns whether an address is allowed to withdraw their funds. To be

    * implemented by derived contracts.

    * @param payee The destination address of the funds.

    */

    function withdrawalAllowed(address payee) public view returns (bool);



    function withdraw(address payee) public {

        require(withdrawalAllowed(payee));

        super.withdraw(payee);

    }

}



// File: openzeppelin-solidity/contracts/payment/escrow/RefundEscrow.sol



/**

 * @title RefundEscrow

 * @dev Escrow that holds funds for a beneficiary, deposited from multiple

 * parties.

 * @dev Intended usage: See Escrow.sol. Same usage guidelines apply here.

 * @dev The primary account (that is, the contract that instantiates this

 * contract) may deposit, close the deposit period, and allow for either

 * withdrawal by the beneficiary, or refunds to the depositors. All interactions

 * with RefundEscrow will be made through the primary contract. See the

 * RefundableCrowdsale contract for an example of RefundEscrow’s use.

 */

contract RefundEscrow is ConditionalEscrow {

    enum State { Active, Refunding, Closed }



    event RefundsClosed();

    event RefundsEnabled();



    State private _state;

    address private _beneficiary;



    /**

     * @dev Constructor.

     * @param beneficiary The beneficiary of the deposits.

     */

    constructor(address beneficiary) public {

        require(beneficiary != address(0));

        _beneficiary = beneficiary;

        _state = State.Active;

    }



    /**

     * @return the current state of the escrow.

     */

    function state() public view returns (State) {

        return _state;

    }



    /**

     * @return the beneficiary of the escrow.

     */

    function beneficiary() public view returns (address) {

        return _beneficiary;

    }



    /**

     * @dev Stores funds that may later be refunded.

     * @param refundee The address funds will be sent to if a refund occurs.

     */

    function deposit(address refundee) public payable {

        require(_state == State.Active);

        super.deposit(refundee);

    }



    /**

     * @dev Allows for the beneficiary to withdraw their funds, rejecting

     * further deposits.

     */

    function close() public onlyPrimary {

        require(_state == State.Active);

        _state = State.Closed;

        emit RefundsClosed();

    }



    /**

     * @dev Allows for refunds to take place, rejecting further deposits.

     */

    function enableRefunds() public onlyPrimary {

        require(_state == State.Active);

        _state = State.Refunding;

        emit RefundsEnabled();

    }



    /**

     * @dev Withdraws the beneficiary's funds.

     */

    function beneficiaryWithdraw() public {

        require(_state == State.Closed);

        _beneficiary.transfer(address(this).balance);

    }



    /**

     * @dev Returns whether refundees can withdraw their deposits (be refunded).

     */

    function withdrawalAllowed(address payee) public view returns (bool) {

        return _state == State.Refunding;

    }

}



// File: openzeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol



/**

 * @title RefundableCrowdsale

 * @dev Extension of Crowdsale contract that adds a funding goal, and

 * the possibility of users getting a refund if goal is not met.

 * WARNING: note that if you allow tokens to be traded before the goal

 * is met, then an attack is possible in which the attacker purchases

 * tokens from the crowdsale and when they sees that the goal is

 * unlikely to be met, they sell their tokens (possibly at a discount).

 * The attacker will be refunded when the crowdsale is finalized, and

 * the users that purchased from them will be left with worthless

 * tokens. There are many possible ways to avoid this, like making the

 * the crowdsale inherit from PostDeliveryCrowdsale, or imposing

 * restrictions on token trading until the crowdsale is finalized.

 * This is being discussed in

 * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/877

 * This contract will be updated when we agree on a general solution

 * for this problem.

 */

contract RefundableCrowdsale is FinalizableCrowdsale {

    using SafeMath for uint256;



    // minimum amount of funds to be raised in weis

    uint256 private _goal;



    // refund escrow used to hold funds while crowdsale is running

    RefundEscrow private _escrow;



    /**

     * @dev Constructor, creates RefundEscrow.

     * @param goal Funding goal

     */

    constructor(uint256 goal) internal {

        require(goal > 0);

        _escrow = new RefundEscrow(wallet());

        _goal = goal;

    }



    /**

     * @return minimum amount of funds to be raised in wei.

     */

    function goal() public view returns(uint256) {

        return _goal;

    }



    /**

     * @dev Investors can claim refunds here if crowdsale is unsuccessful

     * @param beneficiary Whose refund will be claimed.

     */

    function claimRefund(address beneficiary) public {

        require(finalized());

        require(!goalReached());



        _escrow.withdraw(beneficiary);

    }



    /**

     * @dev Checks whether funding goal was reached.

     * @return Whether funding goal was reached

     */

    function goalReached() public view returns (bool) {

        return weiRaised() >= _goal;

    }



    /**

     * @dev escrow finalization task, called when finalize() is called

     */

    function _finalization() internal {

        if (goalReached()) {

            _escrow.close();

            _escrow.beneficiaryWithdraw();

        } else {

            _escrow.enableRefunds();

        }



        super._finalization();

    }



    /**

     * @dev Overrides Crowdsale fund forwarding, sending funds to escrow.

     */

    function _forwardFunds() internal {

        _escrow.deposit.value(msg.value)(msg.sender);

    }



}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(

        address owner,

        address spender

    )

    public

    view

    returns (uint256)

    {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(

        address from,

        address to,

        uint256 value

    )

    public

    returns (bool)

    {

        require(value <= _allowed[from][msg.sender]);



        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(

        address spender,

        uint256 addedValue

    )

    public

    returns (bool)

    {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(

        address spender,

        uint256 subtractedValue

    )

    public

    returns (bool)

    {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(value <= _balances[from]);

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != 0);

        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != 0);

        require(value <= _balances[account]);



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        require(value <= _allowed[account][msg.sender]);



        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

        // this function needs to emit an event with the updated approval.

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

            value);

        _burn(account, value);

    }

}



// File: openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

    struct Role {

        mapping (address => bool) bearer;

    }



    /**

     * @dev give an account access to this role

     */

    function add(Role storage role, address account) internal {

        require(account != address(0));

        require(!has(role, account));



        role.bearer[account] = true;

    }



    /**

     * @dev remove an account's access to this role

     */

    function remove(Role storage role, address account) internal {

        require(account != address(0));

        require(has(role, account));



        role.bearer[account] = false;

    }



    /**

     * @dev check if an account has this role

     * @return bool

     */

    function has(Role storage role, address account)

    internal

    view

    returns (bool)

    {

        require(account != address(0));

        return role.bearer[account];

    }

}



// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol



contract MinterRole {

    using Roles for Roles.Role;



    event MinterAdded(address indexed account);

    event MinterRemoved(address indexed account);



    Roles.Role private minters;



    constructor() internal {

        _addMinter(msg.sender);

    }



    modifier onlyMinter() {

        require(isMinter(msg.sender));

        _;

    }



    function isMinter(address account) public view returns (bool) {

        return minters.has(account);

    }



    function addMinter(address account) public onlyMinter {

        _addMinter(account);

    }



    function renounceMinter() public {

        _removeMinter(msg.sender);

    }



    function _addMinter(address account) internal {

        minters.add(account);

        emit MinterAdded(account);

    }



    function _removeMinter(address account) internal {

        minters.remove(account);

        emit MinterRemoved(account);

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol



/**

 * @title ERC20Mintable

 * @dev ERC20 minting logic

 */

contract ERC20Mintable is ERC20, MinterRole {

    /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(

        address to,

        uint256 value

    )

    public

    onlyMinter

    returns (bool)

    {

        _mint(to, value);

        return true;

    }

}



// File: openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol



/**

 * @title MintedCrowdsale

 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.

 * Token ownership should be transferred to MintedCrowdsale for minting.

 */

contract MintedCrowdsale is Crowdsale {

    constructor() internal {}



    /**

     * @dev Overrides delivery by minting tokens upon purchase.

     * @param beneficiary Token purchaser

     * @param tokenAmount Number of tokens to be minted

     */

    function _deliverTokens(

        address beneficiary,

        uint256 tokenAmount

    )

    internal

    {

        // Potentially dangerous assumption about the type of the token.

        require(

            ERC20Mintable(address(token())).mint(beneficiary, tokenAmount));

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol



/**

 * @title Capped token

 * @dev Mintable token with a token cap.

 */

contract ERC20Capped is ERC20Mintable {



    uint256 private _cap;



    constructor(uint256 cap)

    public

    {

        require(cap > 0);

        _cap = cap;

    }



    /**

     * @return the cap for the token minting.

     */

    function cap() public view returns(uint256) {

        return _cap;

    }



    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap);

        super._mint(account, value);

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract ERC20Burnable is ERC20 {



    /**

     * @dev Burns a specific amount of tokens.

     * @param value The amount of token to be burned.

     */

    function burn(uint256 value) public {

        _burn(msg.sender, value);

    }



    /**

     * @dev Burns a specific amount of tokens from the target address and decrements allowance

     * @param from address The address which you want to send tokens from

     * @param value uint256 The amount of token to be burned

     */

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor(string name, string symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns(string) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns(string) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns(uint8) {

        return _decimals;

    }

}



// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol



contract PauserRole {

    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private pausers;



    constructor() internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender));

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        _addPauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        pausers.remove(account);

        emit PauserRemoved(account);

    }

}



// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);



    bool private _paused;



    constructor() internal {

        _paused = false;

    }



    /**

     * @return true if the contract is paused, false otherwise.

     */

    function paused() public view returns(bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(_paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() public onlyPauser whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}



// File: contracts\Zion.sol



contract Zion is ERC20Mintable, ERC20Detailed,  Pausable {



    // define initial coin supply here

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals()));



    /**

     * @dev Constructor that gives msg.sender all of existing tokens.

     */

    constructor () public ERC20Detailed("Zion", "ZION", 18) {

        _mint(msg.sender, INITIAL_SUPPLY);

    }



    /**

     * @dev Burns a specific amount of tokens.

     * @param value The amount of token to be burned.

     */

    function burn(uint256 value) public {

        _burn(msg.sender, value);

    }



    /**

     * @dev Burns a specific amount of tokens from the target address and decrements allowance

     * @param from address The address which you want to send tokens from

     * @param value uint256 The amount of token to be burned

     */

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);

    }



    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from,address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);

    }



    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);

    }



    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);

    }



    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);

    }



}