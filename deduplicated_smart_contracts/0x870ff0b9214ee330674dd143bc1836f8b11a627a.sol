/**

 *Submitted for verification at Etherscan.io on 2019-06-14

*/



// ERC20 Token for iOWN project

// https://www.iowntoken.com



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.5.2;



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



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol



pragma solidity ^0.5.2;





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



    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.5.2;







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



// File: openzeppelin-solidity/contracts/access/Roles.sol



pragma solidity ^0.5.2;



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



// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol



pragma solidity ^0.5.2;





contract PauserRole {

    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private _pausers;



    constructor () internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender));

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        _addPauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        _pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        _pausers.remove(account);

        emit PauserRemoved(account);

    }

}



// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



pragma solidity ^0.5.2;





/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol



pragma solidity ^0.5.2;







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



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



pragma solidity ^0.5.2;



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



// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol



pragma solidity ^0.5.2;





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



    function addMinter(address account) public onlyMinter {

        _addMinter(account);

    }



    function renounceMinter() public {

        _removeMinter(msg.sender);

    }



    function _addMinter(address account) internal {

        _minters.add(account);

        emit MinterAdded(account);

    }



    function _removeMinter(address account) internal {

        _minters.remove(account);

        emit MinterRemoved(account);

    }

}



// File: contracts/CappedBurnableToken.sol



pragma solidity 0.5.7;









/**

 * @title CappedBurnableToken

 * @dev Mintable token with a token cap which also supports burning

 * This contract encapsulates the functionality of ERC20Mintable, ERC20Capped and ERC20Burnable

 * With minor modifications

 */

contract CappedBurnableToken is ERC20, MinterRole {

    using SafeMath for uint256;



    /** Maximum amount of tokens which can be minted*/

    uint256 private _cap;



    constructor (uint256 cap) public {

        require(cap > 0, "Minting cap should be greater than 0");

        _cap = cap;

    }



    /**

     * @dev A preview method of the token cap

     * @return the cap for the token minting.

     */

    function cap() public view returns (uint256) {

        return _cap;

    }



    /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        require(totalSupply().add(value) <= _cap, "Token supply fully minted");

        _mint(to, value);

        return true;

    }



    /**

     * @dev Burns a specific amount of tokens.

     * @param value The amount of token to be burned.

     */

    function burn(uint256 value) public {

        _cap.sub(value); //Prevents minting more tokens in place of burnt ones

        _burn(msg.sender, value);

    }



     /**

     * @dev Burns a specific amount of tokens from the target address and decrements allowance

     * @param from address The account whose tokens will be burned.

     * @param value uint256 The amount of token to be burned.

     */

    function burnFrom(address from, uint256 value) public {

        _cap.sub(value); //Prevents minting more tokens in place of burnt ones

        _burnFrom(from, value);

    }

}



// File: contracts/UpgradeAgent.sol



pragma solidity 0.5.7;



/**

 * @dev Upgrade agent interface inspired by Lunyr.

 *

 * Upgrade agent transfers tokens to a new contract.

 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.

 * Originally https://github.com/TokenMarketNet/smart-contracts/blob/master/contracts/UpgradeAgent.sol

 */

contract UpgradeAgent {



	/** Original supply of token*/

    uint public originalSupply;



    /** Interface marker */

    function isUpgradeAgent() public pure returns (bool) {

        return true;

    }



    /**

     * @dev Upgrade a set of tokens

     */

    function upgradeFrom(address from, uint256 value) public;



}



// File: contracts/UpgradeableToken.sol



pragma solidity 0.5.7;











/**

 * @title UpgradeableToken

 * @dev UpgradeableToken is A token which allows its holders to migrate their tokens to an future version

 * This contract should be overridden in the future as more functionality is needed

 */

contract UpgradeableToken is CappedBurnableToken, ERC20Pausable, Ownable  {



    /** The next contract where the tokens will be migrated. */

    address private _upgradeAgent;



    /** How many tokens we have upgraded by now. */

    uint256 private _totalUpgraded = 0;



    /** Set to true if we have an upgrade agent and we're ready to update tokens */

    bool private _upgradeReady = false;



    /** Somebody has upgraded some of his tokens. */

    event Upgrade(address indexed _from, address indexed _to, uint256 _amount);



    /** New upgrade agent available. */

    event UpgradeAgentSet(address agent);



    /**

    * @dev Modifier to check if upgrading is allowed

    */

    modifier upgradeAllowed() {

        require(_upgradeReady == true, "Upgrade not allowed");

        _;

    }



    /**

     * @dev Modifier to check if setting upgrade agent is allowed for owner

     */

    modifier upgradeAgentAllowed() {

        require(_totalUpgraded == 0, "Upgrade is already in progress");

        _;

    }



    /**

    * @dev Allow the token holder to upgrade some of their tokens to a new contract.

    * @param amount An amount to upgrade to the next contract

    */

    function upgrade(uint256 amount) public upgradeAllowed whenPaused {

        require(amount > 0, "Amount should be greater than zero");

        require(balanceOf(msg.sender) >= amount, "Amount exceeds tokens owned");

        //Burn user's tokens:

        burn(amount);

        _totalUpgraded = _totalUpgraded.add(amount);

        // Upgrade agent reissues the tokens in the new contract

        UpgradeAgent(_upgradeAgent).upgradeFrom(msg.sender, amount);

        emit Upgrade(msg.sender, _upgradeAgent, amount);

    }



    /**

    * @dev Set an upgrade agent that handles transition of tokens from this contract

    * @param agent Sets the address of the UpgradeAgent (new token)

    */

    function setUpgradeAgent(address agent) external onlyOwner whenPaused upgradeAgentAllowed {

        require(agent != address(0), "Upgrade agent can not be at address 0");

        UpgradeAgent upgradeAgent = UpgradeAgent(agent);

        // Basic validation for target contract

        require(upgradeAgent.isUpgradeAgent() == true, "Address provided is an invalid agent");

        require(upgradeAgent.originalSupply() == cap(), "Upgrade agent should have the same supply");

        _upgradeAgent = agent;

        _upgradeReady = true;

        emit UpgradeAgentSet(agent);

    }

}



// File: contracts/TokenTreasury.sol



pragma solidity 0.5.7;





/**

 * @dev Token Treasury

 * A token treasury base: a future implementation for iOWN Private Treasury

 * The treasury works like a token vault, with special conditions to be implemented prior/at release of tokens back to owner.

 */

contract TokenTreasury is Ownable {



	/** Holds the address of the Smart Contract for tokens being treasured*/

    address private _tokenAddress;



    constructor(

        address owner,

        address tokenAddress

    )

        Ownable()

        public

    {

        require(owner != address(0), "Invalid token owner address provided");

        require(tokenAddress != address(0), "Invalid token address provided");

        _tokenAddress = tokenAddress;

        super._transferOwnership(owner);

    }



	/**

	 * @dev Basic check that the contract is a treasury implementation

	 * @return bool true

	 */

    function isTokenTreasury() external pure returns (bool) {

        return true;

    }



	/**

	 * @dev Primary treasury method: allows an external contract to trigger adding tokens to the treasury for a period of time

	 * @param sender The original sender of the treasure transaction (original owner of tokens)

	 * @param amount The amount of tokens which are to be treasured: Contract should ensure after treasuring tokens,

	 * its own balance in tokenAddress matches total tokens in treasury.

	 * @param until Timestamp until which the tokens are in treasury.

	 */

    function treasureTokens(address sender, uint256 amount, uint until) external;

}



// File: contracts/IownToken.sol



pragma solidity 0.5.7;











/**

 * @title IownToken

 * @dev iOWN Token is an ERC20 Token for iOWN Project, intended to allow users to access iOWN Services

 */

contract IownToken is ERC20Detailed, UpgradeableToken {

    using SafeMath for uint256;



    /** The date before which release must be triggered or token MUST be upgraded. */

    uint private _releaseDate;



    /** Token release switch. */

    bool private _released = false;



    /** Holds the ODR address: where remainder of hard cap goes*/

    address private _odrAddress;



    /** Holds the address of the treasury smart contract */

    address private _treasuryAddress;



    /** Occurs when someone puts tokens into iOWN Private Treasury */

    event TreasuredTokens(address owner, uint256 amount, uint until);



    /** Occurs when owner updates the address of the iOWN Treasury */

    event TreasuryReconfigured(address newTreasury);



    /**

     * @dev Modifier for checked whether the token has not been released yet

     */

    modifier whenNotReleased() {

        require(_released == false, "Not allowed after token release");

        _;

    }



    constructor(

        string memory name,

        string memory symbol,

        uint totalSupply,

        uint8 decimals,

        uint releaseDate,

        address managingWallet

    )

        ERC20()

        ERC20Detailed(name, symbol, decimals)

        MinterRole()

        CappedBurnableToken(totalSupply)

        PauserRole()

        Pausable()

        ERC20Pausable()

        Ownable()

        UpgradeableToken()

        public

    {

        require(managingWallet != address(0), "Managing wallet not set");

        _releaseDate = releaseDate;

        transferOwnership(managingWallet);

    }



    /**

     * @dev Function to transfer ownership of contract to another address

     * Does not remove original owner from roles "pauser" and "minter"

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Invalid new owner address");

         //Give the newOwner address full control

        addMinter(newOwner);

        addPauser(newOwner);

        super.transferOwnership(newOwner);

    }



    /**

     * @dev Function to mark the token as released and disable minting

     */

    function releaseTokenTransfer() external onlyOwner returns (bool isSuccess) {

        require(_odrAddress != address(0), "ODR Address must be set before releasing token");

        uint256 remainder = cap().sub(totalSupply());

        if(remainder > 0) mint(_odrAddress, remainder); //Mint remainder of tokens to ODR wallet

        _released = true;

        return _released;

    }



    /**

     * @dev Allows Owner to set the ODR address which will hold the remainder of the tokens on release

     * @param odrAddress The address of the ODR wallet

     */

    function setODR(address odrAddress) external onlyOwner returns (bool isSuccess) {

        require(odrAddress != address(0), "Invalid ODR address");

        _odrAddress = odrAddress;

        return true;

    }



    /**

     * @dev Getter for ODR address

     * @return address of ODR

     */

    function odr() public view returns (address) {

        return _odrAddress;

    }



    /**

     * @dev Is token released yet

     * @return true if released

     */

    function released() public view returns (bool) {

        return _released;

    }



    /**

     * @dev Mint tokens: restricted only when token not released

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address to, uint256 value) public whenNotReleased onlyMinter returns (bool) {

        return super.mint(to, value);

    }



    /**

     * @dev Transfer token for a specified addresses

     * @param from The address to transfer from.

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     * Added as resolution for audit on contract: 30/5/2019

     * Reference here https://docs.google.com/document/d/1Feh5sP6oQL1-1NHi-X1dbgT3ch2WdhbXRevDN681Jv4/edit

     */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(this), "Invalid transfer to address");

        super._transfer(from, to, value);

    }

}