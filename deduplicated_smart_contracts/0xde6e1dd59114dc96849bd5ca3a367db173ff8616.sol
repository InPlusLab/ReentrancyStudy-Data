/**

 *Submitted for verification at Etherscan.io on 2019-04-15

*/



pragma solidity 0.5.6;



/**

 * Utility library of inline functions on addresses

 */

library Address {

    /**

     * Returns whether the target address is a contract

     * @dev This function will return false if invoked during the constructor of a contract,

     * as the code is not actually created until after the constructor finishes.

     * @param account address of the account to check

     * @return whether the target address is a contract

     */

    function isContract(address account) internal view returns (bool) {

        uint256 size;

        // XXX Currently there is no better way to check if there is a contract in an address

        // than to check the size of the code at that address.

        // See https://ethereum.stackexchange.com/a/14016/36603

        // for more details about how this works.

        // TODO Check this again before the Serenity release, because all addresses will be

        // contracts then.

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

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

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using SafeMath for uint256;

    using Address for address;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require((value == 0) || (token.allowance(address(this), spender) == 0));

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must equal true).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves.



        // A Solidity high level call has three parts:

        //  1. The target address is checked to verify it contains contract code

        //  2. The call itself is made, and success asserted

        //  3. The return value is decoded, which in turn checks the size of the returned data.



        require(address(token).isContract());



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = address(token).call(data);

        require(success);



        if (returndata.length > 0) { // Return data is optional

            require(abi.decode(returndata, (bool)));

        }

    }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     * @notice Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transferOwnership(address newOwner) external;



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://eips.ethereum.org/EIPS/eip-20

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

     * @return A uint256 representing the amount owned by the passed address.

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

     * @dev Transfer token to a specified address

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

        _approve(msg.sender, spender, value);

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

        _transfer(from, to, value);

        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));

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

     * @dev Approve an address to spend another addresses' tokens.

     * @param owner The address that owns the tokens.

     * @param spender The address that will spend the tokens.

     * @param value The number of tokens that can be spent.

     */

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));

        require(owner != address(0));



        _allowed[owner][spender] = value;

        emit Approval(owner, spender, value);

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

        _burn(account, value);

        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));

    }

}



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

     * @param from address The account whose tokens will be burned.

     * @param value uint256 The amount of token to be burned.

     */

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);

    }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

    event Paused(address account);

    event Unpaused(address account);



    bool private _paused;



    constructor () internal {

        _paused = false;

    }



    /**

     * @return true if the contract is paused, false otherwise.

     */

    function paused() public view returns (bool) {

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

    function pause() public onlyOwner whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyOwner whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}



/**

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 */

contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

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



/**

 * @title FreezableToken

 */

contract ERC20Freezable is ERC20, Ownable {

    mapping(address => bool) public frozenAccounts;

    event FrozenFunds(address target, bool frozen);



    function freezeAccount(address target) public onlyOwner {

        frozenAccounts[target] = true;

        emit FrozenFunds(target, true);

    }



    function unFreezeAccount(address target) public onlyOwner {

        frozenAccounts[target] = false;

        emit FrozenFunds(target, false);

    }



    function frozen(address _target) view public returns(bool) {

        return frozenAccounts[_target];

    }



    // @dev Limit token transfer if _sender is frozen.

    modifier canTransfer(address _sender) {

        require(!frozenAccounts[_sender]);

        _;

    }



    function transfer(address _to, uint256 _value) public canTransfer(msg.sender) returns(bool success) {

        // Call StandardToken.transfer()

        return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from) returns(bool success) {

        // Call StandardToken.transferForm()

        return super.transferFrom(_from, _to, _value);

    }

}



/**

 * @title AirSaveTravelToken

 */

contract AirSaveTravelTokens is ERC20Freezable, ERC20Pausable, ERC20Burnable {

    string private constant _name = "AirSaveTravel Tokens";

    string private constant _symbol = "ASTC";

    uint8 private constant _decimals = 18;



    /**

     * @dev AirSaveTravelToken constructor method

     */

    constructor () public {

        //sending 35 mln  tokens to the main wallet

        //the number of tokens is fixed and cannot be minted in future

        _mint(msg.sender, 35000000 * 1 ether);

    }



    /**

     * @return the name of the token.

     */

    function name() public pure returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public pure returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public pure returns (uint8) {

        return _decimals;

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



    // 1 ETH = 750 ASTC

    uint256 private _rate = 750;



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



    constructor () public {

        _wallet = msg.sender;

        _token = IERC20(new AirSaveTravelTokens());

        _token.safeTransfer(_wallet, 29750000000 * 1 finney); //29,75 mln tokens to owner

        _token.transferOwnership(_wallet);

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



        require(_token.balanceOf(address(this)) >= tokens, "buyTokens:the contract has not enough token balance for purchasing");



        // update state

        _weiRaised = _weiRaised.add(weiAmount);



        _processPurchase(beneficiary, tokens);

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);



        _forwardFunds();

    }



    function changeWallet(address payable newWallet) external {

        require(newWallet != address(0), "changeWallet: invalid wallet address");

        require(msg.sender == _wallet, "changeWallet: only current wallet can change it");



        _wallet = newWallet;

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



/**

 * @title WhitelistCrowdsale

 * @dev Crowdsale in which only whitelisted users can contribute.

 */

contract WhitelistCrowdsale is WhitelistedRole, Crowdsale {

    /**

     * @dev Extend parent behavior requiring beneficiary to be whitelisted. Note that no

     * restriction is imposed on the account sending the transaction.

     * @param _beneficiary Token beneficiary

     * @param _weiAmount Amount of wei contributed

     */

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {

        require(isWhitelisted(_beneficiary));

        super._preValidatePurchase(_beneficiary, _weiAmount);

    }

}