/**

 *Submitted for verification at Etherscan.io on 2019-05-14

*/



pragma solidity 0.5.2;



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

}



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function mint(address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



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

 * @dev Role who can mint the new tokens

 */

contract MinterRole {

    using Roles for Roles.Role;



    event MinterAdded(address indexed account);

    event MinterRemoved(address indexed account);



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



    function _addMinter(address account) internal {

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

 * @title TuneTradeToken burnable and mintable smart contract

 */

contract TuneTradeToken is ERC20Burnable, ERC20Mintable {

    string private constant _name = "TuneTradeX";

    string private constant _symbol = "TXT";

    uint8 private constant _decimals = 18;



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

 * @title TeamRole

 * @dev TeamRole should be able to swap tokens with other limits

 */

contract TeamRole is WhitelistedRole {

    using Roles for Roles.Role;



    event TeamMemberAdded(address indexed account);

    event TeamMemberRemoved(address indexed account);



    Roles.Role private _team;



    modifier onlyTeamMember() {

        require(isTeamMember(msg.sender));

        _;

    }



    function isTeamMember(address account) public view returns (bool) {

        return _team.has(account);

    }



    function _addTeam(address account) internal onlyWhitelistAdmin {

        _team.add(account);

        emit TeamMemberAdded(account);

    }



    function removeTeam(address account) public onlyWhitelistAdmin {

        _team.remove(account);

        emit TeamMemberRemoved(account);

    }

}



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));

    }

}



/**

 * @title SwapContract

 * @dev The ERC20 to ERC20 tokens swapping smart contract, which should replace the old TXT tokens with the new TXT tokens

 */

contract SwapContract is TeamRole {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    uint256 private _remaining;

    uint256 private _lastReset;



    uint256 private constant _period = 1 days;

    uint256 private constant _publicLimit = 10000 * 1 ether;

    uint256 private constant _teamLimit = 30000 * 1 ether;

    uint256 private constant _contractLimit = 100000 * 1 ether;



    address private constant _swapMaster = 0x26a9f0b85db899237c6F07603475df43Eb366F8b;



    struct SwapInfo {

        bool alreadyWhitelisted;

        uint256 availableTokens;

        uint256 lastSwapTimestamp;

    }



    mapping (address => SwapInfo) private _infos;



    IERC20 private _newToken;

    IERC20 private _oldToken = IERC20(0xA57a2aD52AD6b1995F215b12fC037BffD990Bc5E);



    event MasterTokensSwapped(uint256 amount);

    event TokensSwapped(address swapper, uint256 amount);

    event TeamTokensSwapped(address swapper, uint256 amount);

    event SwapApproved(address swapper, uint256 amount);



    /**

     * @dev The constructor of SwapContract, which will deploy the TXT Token and can mint new tokens for swappers

     */

    constructor () public {

        _newToken = IERC20(address(new TuneTradeToken()));

        

        _newToken.mint(_swapMaster, 50000010000000000000000010);

        emit MasterTokensSwapped(50000010000000000000000010);

            

        _reset();

    }



    // -----------------------------------------

    // EXTERNAL

    // -----------------------------------------



    function approveSwap(address swapper) public onlyWhitelistAdmin {

        require(swapper != address(0), "approveSwap: invalid swapper address");



        uint256 balance = _oldToken.balanceOf(swapper);

        require(balance > 0, "approveSwap: the swapper token balance is zero");

        require(_infos[swapper].alreadyWhitelisted == false, "approveSwap: the user already swapped his tokens");



        _addWhitelisted(swapper);

        _infos[swapper] = SwapInfo({

            alreadyWhitelisted: true,

            availableTokens: balance,

            lastSwapTimestamp: 0

        });



        emit SwapApproved(swapper, balance);

    }



    function approveTeam(address member) external onlyWhitelistAdmin {

        require(member != address(0), "approveTeam: invalid team address");



        _addTeam(member);

        approveSwap(member);

    }



    function swap() external onlyWhitelisted {

        if (now >= _lastReset + _period) {

            _reset();

        }



        require(_remaining != 0, "swap: no tokens available");

        require(_infos[msg.sender].availableTokens != 0, "swap: no tokens available for swap");

        require(now >= _infos[msg.sender].lastSwapTimestamp + _period, "swap: msg.sender can not call this method now");



        uint256 toSwap = _infos[msg.sender].availableTokens;



        if (toSwap > _publicLimit) {

            toSwap = _publicLimit;

        }



        if (toSwap > _remaining) {

            toSwap = _remaining;

        }



        if (toSwap > _oldToken.balanceOf(msg.sender)) {

            toSwap = _oldToken.balanceOf(msg.sender);

        }



        _swap(toSwap);

        _update(toSwap);

        _remaining = _remaining.sub(toSwap);



        emit TokensSwapped(msg.sender, toSwap);

    }



    function swapTeam() external onlyTeamMember {

        require(_infos[msg.sender].availableTokens != 0, "swapTeam: no tokens available for swap");

        require(now >= _infos[msg.sender].lastSwapTimestamp + _period, "swapTeam: team member can not call this method now");



        uint256 toSwap = _infos[msg.sender].availableTokens;



        if (toSwap > _teamLimit) {

            toSwap = _teamLimit;

        }



        if (toSwap > _oldToken.balanceOf(msg.sender)) {

            toSwap = _oldToken.balanceOf(msg.sender);

        }



        _swap(toSwap);

        _update(toSwap);



        emit TeamTokensSwapped(msg.sender, toSwap);

    }



    function swapMaster(uint256 amount) external {

        require(msg.sender == _swapMaster, "swapMaster: only swap master can call this methid");

        _swap(amount);

        emit MasterTokensSwapped(amount);

    }



    // -----------------------------------------

    // GETTERS

    // -----------------------------------------



    function getSwappableAmount(address swapper) external view returns (uint256) {

        return _infos[swapper].availableTokens;

    }



    function getTimeOfLastSwap(address swapper) external view returns (uint256) {

        return _infos[swapper].lastSwapTimestamp;

    }



    function getRemaining() external view returns (uint256) {

        return _remaining;

    }



    function getLastReset() external view returns (uint256) {

        return _lastReset;

    }



    function getTokenAddress() external view returns (address) {

        return address(_newToken);

    }



    // -----------------------------------------

    // INTERNAL

    // -----------------------------------------



    function _reset() private {

        _lastReset = now;

        _remaining = _contractLimit;

    }



    function _update(uint256 amountToSwap) private {

        _infos[msg.sender].availableTokens = _infos[msg.sender].availableTokens.sub(amountToSwap);

        _infos[msg.sender].lastSwapTimestamp = now;

    }



    function _swap(uint256 amountToSwap) private {

        _oldToken.safeTransferFrom(msg.sender, address(this), amountToSwap);

        _newToken.mint(msg.sender, amountToSwap);

    }

}