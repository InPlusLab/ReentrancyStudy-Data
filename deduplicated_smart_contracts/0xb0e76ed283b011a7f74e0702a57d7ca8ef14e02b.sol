/**

 *Submitted for verification at Etherscan.io on 2019-05-23

*/



pragma solidity ^0.5.2;

 

/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

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

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

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

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);

 

    function balanceOf(address who) external view returns (uint256);

 

    function allowance(address owner, address spender) external view returns (uint256);

 

    function transfer(address to, uint256 value) external returns (bool);

 

    function approve(address spender, uint256 value) external returns (bool);

 

    function transferFrom(address from, address to, uint256 value) external returns (bool);

 

    event Transfer(address indexed from, address indexed to, uint256 value);

 

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

     * @return True if the contract is paused, false otherwise.

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

     * @dev Called by a pauser to pause, triggers stopped state.

     */

    function pause() public onlyOwner whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }

 

    /**

     * @dev Called by a pauser to unpause, returns to normal state.

     */

    function unpause() public onlyOwner whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}

 

/**

 * @title ERACoin

 * @dev ERC20 Token 

 */

contract ERACoin is IERC20, Ownable, ReentrancyGuard, Pausable  {

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

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

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

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

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

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

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

 

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    uint256 private _initSupply;

    

    constructor (string memory name, string memory symbol, uint8 decimals, uint256 initSupply) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

        _initSupply = initSupply.mul(10 **uint256(decimals));

        _mint(msg.sender, _initSupply);

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

    

    /**

     * @return the initial Supply of the token.

     */

    function initSupply() public view returns (uint256) {

        return _initSupply;

    }

   

   mapping (address => bool) status; 

   

   

   // Address bounty Admin

    address private _walletAdmin; 

   // Address where funds can be collected

    address payable _walletBase90;

    // Address where funds can be collected too

    address payable _walletF5;

    // Address where funds can be collected too

    address payable _walletS5;

    // How many token units a buyer gets per wei.

    // The rate is the conversion between wei and the smallest and indivisible token unit.

    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK

    // 1 wei will give you 1 unit, or 0.001 TOK.

    uint256 private _rate;

    // _rate share index

    uint256 private _y;

    // Amount of wei raised

    uint256 private _weiRaised;

    // Min token*s qty required to buy  

    uint256 private _MinTokenQty;

    // Max token*s qty is available for transfer by bounty Admin 

    uint256 private _MaxTokenAdminQty;

    

   /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address to, uint256 value) public onlyOwner returns (bool) {

        _mint(to, value);

        return true;

    }

    

   /**

     * @dev Function to burn tokens

     * @param to The address to burn tokens.

     * @param value The amount of tokens to burn.

     * @return A boolean that indicates if the operation was successful.

     */

    function burn(address to, uint256 value) public onlyOwner returns (bool) {

        _burn(to, value);

        return true;

    }

    

    /**

    * @dev Transfer token for a specified address.onlyOwner

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transferOwner(address to, uint256 value) public onlyOwner returns (bool) {

      

        _transfer(msg.sender, to, value);

        return true;

    }

    

    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

      

        _transfer(msg.sender, to, value);

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

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

      

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }

     

   /**

     * @dev check an account's status

     * @return bool

     */

    function CheckStatus(address account) public view returns (bool) {

        require(account != address(0));

        bool currentStatus = status[account];

        return currentStatus;

    }

    

    /**

     * @dev change an account's status. OnlyOwner

     * @return bool

     */

    function ChangeStatus(address account) public  onlyOwner {

        require(account != address(0));

        bool currentStatus1 = status[account];

       status[account] = (currentStatus1 == true) ? false : true;

    }

 

   /**

     * @dev fallback function ***DO NOT OVERRIDE***

     * Note that other contracts will transfer fund with a base gas stipend

     * of 2300, which is not enough to call buyTokens. Consider calling

     * buyTokens directly when purchasing tokens from a contract.

     */

    function () external payable {

        buyTokens(msg.sender, msg.value);

        }

        

    function buyTokens(address beneficiary, uint256 weiAmount) public nonReentrant payable {

        require(beneficiary != address(0) && beneficiary !=_walletBase90 && beneficiary !=_walletF5 && beneficiary !=_walletS5);

        require(weiAmount > 0);

        address _walletTokenSale = owner();

        require(_walletTokenSale != address(0));

        require(_walletBase90 != address(0));

        require(_walletF5 != address(0));

        require(_walletS5 != address(0));

        require(CheckStatus(beneficiary) != true);

        // calculate token amount to be created

        uint256 tokens = weiAmount.div(_y).mul(_rate);

        // update min token amount to be buy by beneficiary

        uint256 currentMinQty = MinTokenQty();

        // check token amount to be transfered from _wallet

        require(balanceOf(_walletTokenSale) > tokens);

        // check token amount to be buy by beneficiary

        require(tokens >= currentMinQty);

        // update state

        _weiRaised = _weiRaised.add(weiAmount);

        // transfer tokens to beneficiary from CurrentFundWallet

       _transfer(_walletTokenSale, beneficiary, tokens);

       // transfer 90% weiAmount to _walletBase90

       _walletBase90.transfer(weiAmount.div(100).mul(90));

       // transfer 5% weiAmount to _walletF5

       _walletF5.transfer(weiAmount.div(100).mul(5));

       // transfer 5% weiAmount to _walletS5

       _walletS5.transfer(weiAmount.div(100).mul(5));

    }

  

    /**

     * Set Rate. onlyOwner

     */

    function setRate(uint256 rate) public onlyOwner  {

        require(rate >= 1);

        _rate = rate;

    }

   

    /**

     * Set Y. onlyOwner

     */

    function setY(uint256 y) public onlyOwner  {

        require(y >= 1);

        _y = y;

    }

    

    /**

     * Set together the _walletBase90,_walletF5,_walletS5. onlyOwner

     */

    function setFundWallets(address payable B90Wallet,address payable F5Wallet,address payable S5Wallet) public onlyOwner  {

        _walletBase90 = B90Wallet;

         _walletF5 = F5Wallet;

         _walletS5 = S5Wallet;

    } 

    

    /**

     * Set the _walletBase90. onlyOwner

     */

    function setWalletB90(address payable B90Wallet) public onlyOwner  {

        _walletBase90 = B90Wallet;

    } 

    

    /**

     * @return the _walletBase90.

     */

    function WalletBase90() public view returns (address) {

        return _walletBase90;

    }

    

    /**

     * Set the _walletF5. onlyOwner

     */

    function setWalletF5(address payable F5Wallet) public onlyOwner  {

        _walletF5 = F5Wallet;

    } 

    

    /**

     * @return the _walletF5.

     */

    function WalletF5() public view returns (address) {

        return _walletF5;

    }

    

     /**

     * Set the _walletS5. onlyOwner

     */

    function setWalletS5(address payable S5Wallet) public onlyOwner  {

        _walletS5 = S5Wallet;

    } 

    

    /**

     * @return the _walletS5.

     */

    function WalletS5() public view returns (address) {

        return _walletS5;

    }

    

    /**

     * Set the _walletTokenSale. onlyOwner

     */

    function setWalletAdmin(address WalletAdmin) public onlyOwner  {

        _walletAdmin = WalletAdmin;

    } 

    

     /**

     * @return the _walletTokenSale.

     */

    function WalletAdmin() public view returns (address) {

        return _walletAdmin;

    }

    

    /**

     * @dev Throws if called by any account other than the admin.

     */

    modifier onlyAdmin() {

        require(isAdmin());

        _;

    }

 

    /**

     * @return true if `msg.sender` is the admin of the contract.

     */

    function isAdmin() public view returns (bool) {

        return msg.sender == _walletAdmin;

    }

 

    /**

    * @dev Transfer token for a specified address.onlyOwner

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transferAdmin(address to, uint256 value) public onlyAdmin returns (bool) {

        require(value <= MaxTokenAdminQty());

        _transfer(msg.sender, to, value);

        return true;

    }

    

    /**

     * Set the _MinTokenQty. onlyOwner

     */

    function setMinTokenQty(uint256 MinTokenQty) public onlyOwner  {

        _MinTokenQty = MinTokenQty;

    } 

    

    /**

     * Set the _MinTokenQty. onlyOwner

     */

    function setMaxTokenAdminQty(uint256 MaxTokenAdminQty) public onlyOwner  {

        _MaxTokenAdminQty = MaxTokenAdminQty;

    } 

    

    /**

     * @return Rate.

     */

    function Rate() public view returns (uint256) {

        return _rate;

    }

   

    /**

     * @return _Y.

     */

    function Y() public view returns (uint256) {

        return _y;

    }

    

    /**

     * @return the number of wei income Total.

     */

    function WeiRaised() public view returns (uint256) {

        return _weiRaised;

    }

    

    /**

     * @return _MinTokenQty.

     */

    function MinTokenQty() public view returns (uint256) {

        return _MinTokenQty;

    }

    

     /**

     * @return _MinTokenQty.

     */

    function MaxTokenAdminQty() public view returns (uint256) {

        return _MaxTokenAdminQty;

    }

    

}