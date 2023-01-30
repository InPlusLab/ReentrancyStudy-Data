/**

 *Submitted for verification at Etherscan.io on 2019-01-18

*/



pragma solidity ^0.5.0;



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



    function mint(address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

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

 * @title MinterRole

 * @dev Only some specific address can mint new tokens

 */

contract MinterRole {

    using Roles for Roles.Role;



    event MinterAdded(address indexed account);



    Roles.Role private _minters;



    constructor () internal {

        _addMinter(msg.sender);

    }



    modifier onlyMinter() {

        require(isMinter(msg.sender));

        _;

    }



    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);

    }



    function _addMinter(address account) private {

        _minters.add(account);

        emit MinterAdded(account);

    }

}



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

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);

        return true;

    }

}



/**

 * @title ZOM Token smart contract

 */

contract ZOMToken is ERC20Mintable, ERC20Burnable {

    string private constant _name = "ZOM";

    string private constant _symbol = "ZOM";

    uint8 private constant _decimals = 18;

    uint256 private constant _initialSupply = 50000000 * 1 ether; // 50,000,000.00 ZOM



    constructor () public {

        _mint(msg.sender, initialSupply());

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



    /**

     * @return the number of initial supply tokens.

     */

    function initialSupply() public pure returns (uint256) {

        return _initialSupply;

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

 * @title Reward

 * @author Ararat Tonoyan <[email protected]>

 * @dev The contract store the owner addresses, who can receive an reward

 * tokens from ZOMToken smart contract once in 30 days 1 and 3 percent annually.

 */

contract Reward is ReentrancyGuard {

    using SafeMath for uint256;



    uint8 private constant _smallProcent = 1;

    uint8 private constant _bigProcent = 3;

    uint256 private constant _rewardDelay = 30 days;

    uint256 private constant _firstGroupTokensLimit = 50000 * 1 ether; // 50,000.00 ZOM

    uint256 private _contractCreationDate;



    struct Holder {

        uint256 lastWithdrawDate;

        uint256 amountOfWithdraws;

    }



    IERC20 private _token;



    mapping(address => Holder) private _rewardTimeStamp;



    event NewTokensMinted(address indexed receiver, uint256 amount);



    modifier onlyHolder {

        uint256 balanceOfHolder = _getTokenBalance(msg.sender);

        require(balanceOfHolder > 0, "onlyHolder: the sender has no ZOM tokens");

        _;

    }



    // -----------------------------------------

    // CONSTRUCTOR

    // -----------------------------------------



    constructor() public {

        address zom = address(new ZOMToken());

        _token = IERC20(zom);

        _contractCreationDate = block.timestamp;

        _token.transfer(msg.sender, _token.totalSupply());

    }



    // -----------------------------------------

    // EXTERNAL

    // -----------------------------------------



    function withdrawRewardTokens() external onlyHolder nonReentrant {

        address holder = msg.sender;

        uint256 lastWithdrawDate = _getLastWithdrawDate(holder);

        uint256 howDelaysAvailable = (block.timestamp.sub(lastWithdrawDate)).div(_rewardDelay);



        require(howDelaysAvailable > 0, "withdrawRewardTokens: the holder can not withdraw tokens yet!");



        uint256 tokensAmount = _calculateRewardTokens(holder);



        // updating the last withdraw timestamp

        uint256 timeAfterLastDelay = block.timestamp.sub(lastWithdrawDate) % _rewardDelay;

        _rewardTimeStamp[holder].lastWithdrawDate = block.timestamp.sub(timeAfterLastDelay);



        // transfering the tokens

        _mint(holder, tokensAmount);



        emit NewTokensMinted(holder, tokensAmount);

    }





    // -----------------------------------------

    // GETTERS

    // -----------------------------------------



    function getHolderData(address holder) external view returns (uint256, uint256, uint256) {

        return (

            _getTokenBalance(holder),

            _rewardTimeStamp[holder].lastWithdrawDate,

            _rewardTimeStamp[holder].amountOfWithdraws

        );

    }



    function getAvailableRewardTokens(address holder) external view returns (uint256) {

        return _calculateRewardTokens(holder);

    }



    function token() external view returns (address) {

        return address(_token);

    }



    function creationDate() external view returns (uint256) {

        return _contractCreationDate;

    }



    // -----------------------------------------

    // INTERNAL

    // -----------------------------------------



    function _mint(address holder, uint256 amount) private {

        require(_token.mint(holder, amount),"_mint: the issue happens during tokens minting");

        _rewardTimeStamp[holder].amountOfWithdraws = _rewardTimeStamp[holder].amountOfWithdraws.add(1);

    }



    function _calculateRewardTokens(address holder) private view returns (uint256) {

        uint256 lastWithdrawDate = _getLastWithdrawDate(holder);

        uint256 howDelaysAvailable = (block.timestamp.sub(lastWithdrawDate)).div(_rewardDelay);

        uint256 currentBalance = _getTokenBalance(holder);

        uint8 procent = currentBalance >= _firstGroupTokensLimit ? _bigProcent : _smallProcent;

        uint256 amount = currentBalance * howDelaysAvailable * procent / 100;



        return amount / 12;

    }



    function _getTokenBalance(address holder) private view returns (uint256) {

        return _token.balanceOf(holder);

    }



    function _getLastWithdrawDate(address holder) private view returns (uint256) {

        uint256 lastWithdrawDate = _rewardTimeStamp[holder].lastWithdrawDate;

        if (lastWithdrawDate == 0) {

            lastWithdrawDate = _contractCreationDate;

        }



        return lastWithdrawDate;

    }

}