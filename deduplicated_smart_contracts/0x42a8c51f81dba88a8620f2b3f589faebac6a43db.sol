/**

 *Submitted for verification at Etherscan.io on 2019-03-14

*/



pragma solidity ^0.5.0;



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



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

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

    function allowance(address owner, address spender) public view returns (uint256) {

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

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

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

        require(account != address(0));



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

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

        emit Approval(account, msg.sender, _allowed[account][msg.sender]);

    }

}





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

    constructor (address tokenWallet) public {

        require(tokenWallet != address(0));

        _tokenWallet = tokenWallet;

    }



    /**

     * @return the address of the wallet that will hold the tokens.

     */

    function tokenWallet() public view returns (address) {

        return _tokenWallet;

    }



    /**

     * @dev Checks the amount of tokens left in the allowance.

     * @return Amount of tokens left in the allowance

     */

    function remainingTokens() public view returns (uint256) {

        return Math.min(token().balanceOf(_tokenWallet), token().allowance(_tokenWallet, address(this)));

    }



    /**

     * @dev Overrides parent behavior by transferring tokens from wallet.

     * @param beneficiary Token purchaser

     * @param tokenAmount Amount of tokens purchased

     */

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        token().safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);

    }

}



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

    constructor (uint256 openingTime, uint256 closingTime) public {

        // solhint-disable-next-line not-rely-on-time

        require(openingTime >= block.timestamp);

        require(closingTime > openingTime);



        _openingTime = openingTime;

        _closingTime = closingTime;

    }



    /**

     * @return the crowdsale opening time.

     */

    function openingTime() public view returns (uint256) {

        return _openingTime;

    }



    /**

     * @return the crowdsale closing time.

     */

    function closingTime() public view returns (uint256) {

        return _closingTime;

    }



    /**

     * @return true if the crowdsale is open, false otherwise.

     */

    function isOpen() public view returns (bool) {

        // solhint-disable-next-line not-rely-on-time

        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

    }



    /**

     * @dev Checks whether the period in which the crowdsale is open has already elapsed.

     * @return Whether crowdsale period has elapsed

     */

    function hasClosed() public view returns (bool) {

        // solhint-disable-next-line not-rely-on-time

        return block.timestamp > _closingTime;

    }



    /**

     * @dev Extend parent behavior requiring to be within contributing period

     * @param beneficiary Token purchaser

     * @param weiAmount Amount of wei contributed

     */

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {

        super._preValidatePurchase(beneficiary, weiAmount);

    }

}





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

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));

        return role.bearer[account];

    }

}





/**

 * @title WhitelistAdminRole

 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.

 */

contract WhitelistAdminRole {

    using Roles for Roles.Role;



    event WhitelistAdminAdded(address indexed account);

    event WhitelistAdminRemoved(address indexed account);



    Roles.Role private _whitelistAdmins;



    constructor () internal {

        _addWhitelistAdmin(msg.sender);

    }



    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(msg.sender));

        _;

    }



    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);

    }



    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);

    }



    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(msg.sender);

    }



    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);

        emit WhitelistAdminAdded(account);

    }



    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);

        emit WhitelistAdminRemoved(account);

    }

}





/**

 * @title WhitelistedRole

 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a

 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove

 * it), and not Whitelisteds themselves.

 */

contract WhitelistedRole is WhitelistAdminRole {

    using Roles for Roles.Role;



    event WhitelistedAdded(address indexed account);

    event WhitelistedRemoved(address indexed account);



    Roles.Role private _whitelisteds;



    modifier onlyWhitelisted() {

        require(isWhitelisted(msg.sender));

        _;

    }



    function isWhitelisted(address account) public view returns (bool) {

        return _whitelisteds.has(account);

    }



    function addWhitelisted(address account) public onlyWhitelistAdmin {

        _addWhitelisted(account);

    }



    function removeWhitelisted(address account) public onlyWhitelistAdmin {

        _removeWhitelisted(account);

    }



    function renounceWhitelisted() public {

        _removeWhitelisted(msg.sender);

    }



    function _addWhitelisted(address account) internal {

        _whitelisteds.add(account);

        emit WhitelistedAdded(account);

    }



    function _removeWhitelisted(address account) internal {

        _whitelisteds.remove(account);

        emit WhitelistedRemoved(account);

    }

}





contract KicksCrowdsale is Crowdsale, TimedCrowdsale, AllowanceCrowdsale, WhitelistedRole {



    using SafeMath for uint256;



    uint256 private _rate;



    uint256 private _kickCap = 33333333333333333333333333; // $50M

    uint256 private _kickMinPay = 100 ether;

    uint256 private _kickPurchased = 0;



    uint256 private _bonus20capBoundary = 800000000000000000000000; // $1.2M

    uint256 private _bonus10capBoundary = 1533333333333333333333333; // $2.3M



    address private _manualSeller;

    address private _rateSetter;

    address private _whitelistAdmin;



    bool private _KYC = false;



    event Bonus(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event ChangeRate(uint256 rate);



    constructor(

        uint256 rate, // eth to kick rate

        ERC20 token, // the kick token address

        address payable wallet, // accumulation eth address

        address tokenWallet, // kick storage address

        address manualSeller, // can sell tokens

        address rateSetter, // can change eth rate

        uint256 openingTime,

        uint256 closingTime

    )

    Crowdsale(rate, wallet, token)

    AllowanceCrowdsale(tokenWallet)

    TimedCrowdsale(openingTime, closingTime)

    public

    {

        _rate = rate;

        _manualSeller = manualSeller;

        _rateSetter = rateSetter;

        _whitelistAdmin = msg.sender;

    }





    /**

     * Base crowdsale override

     */

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        if (_KYC) {

            require(isWhitelisted(beneficiary), 'Only whitelisted');

        }

        uint256 kickAmount = weiAmount.mul(_rate);

        require(kickAmount >= _kickMinPay, 'Min purchase 100 kick');

        require(_kickPurchased.add(kickAmount) <= _kickCap, 'Cap has been reached');

        super._preValidatePurchase(beneficiary, weiAmount);

    }



    function calcBonus(uint256 tokenAmount) internal view returns (uint256) {

        uint256 bonus = 0;

        if (_kickPurchased.add(tokenAmount) <= _bonus20capBoundary) {

            bonus = tokenAmount.mul(20).div(100);

        } else if (_kickPurchased.add(tokenAmount) <= _bonus10capBoundary) {

            bonus = tokenAmount.mul(10).div(100);

        }

        return bonus;

    }



    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        uint256 tokenAmount = weiAmount.mul(_rate);

        return tokenAmount.add(calcBonus(tokenAmount));

    }



    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        uint256 tokenAmount = weiAmount.mul(_rate);

        uint256 bonus = calcBonus(tokenAmount);

        if (bonus != 0) {

            emit Bonus(msg.sender, beneficiary, weiAmount, bonus);

            tokenAmount = tokenAmount.add(bonus);

        }

        _kickPurchased = _kickPurchased.add(tokenAmount);

    }





    /**

     * Manual sell

     */

    function manualSell(address beneficiary, uint256 weiAmount) public onlyWhileOpen {

        require(msg.sender == _manualSeller);

        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        _processPurchase(beneficiary, tokens);

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _postValidatePurchase(beneficiary, weiAmount);

    }





    /**

     * Change eth rate

     */

    function setRate(uint256 rate) public {

        require(msg.sender == _rateSetter);

        _rate = rate;

        emit ChangeRate(rate);

    }



    /**

     * Change KYC status

     */

    function onKYC() public {

        require(msg.sender == _whitelistAdmin);

        require(!_KYC);

        _KYC = true;

    }



    function offKYC() public {

        require(msg.sender == _whitelistAdmin);

        require(_KYC);

        _KYC = false;

    }





    /**

     * Getters

     */

    function rate() public view returns (uint256) {

        return _rate;

    }



    function kickCap() public view returns (uint256) {

        return _kickCap;

    }



    function kickMinPay() public view returns (uint256) {

        return _kickMinPay;

    }



    function kickPurchased() public view returns (uint256) {

        return _kickPurchased;

    }



    function bonus20capBoundary() public view returns (uint256) {

        return _bonus20capBoundary;

    }



    function bonus10capBoundary() public view returns (uint256) {

        return _bonus10capBoundary;

    }



    function KYC() public view returns (bool) {

        return _KYC;

    }

}