/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.24;



contract Ownable {



    address private _owner;

    

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

        _owner = msg.sender;

    }



    /**

    * @return the address of the owner.

    */

    function owner() public view returns(address) {

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

    function isOwner() public view returns(bool) {

        return msg.sender == _owner;

    }



    /**

    * @dev Allows the current owner to relinquish control of the contract.

    * @notice Renouncing to ownership will leave the contract without an owner.

    * It will not be possible to call the functions with the `onlyOwner`

    * modifier anymore.

    */

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(_owner);

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

        require(value <= _balances[msg.sender]);

        require(to != address(0));



        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(msg.sender, to, value);

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

        require(value <= _balances[from]);

        require(value <= _allowed[from][msg.sender]);

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

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

    * @dev Internal function that mints an amount of the token and assigns it to

    * an account. This encapsulates the modification of balances such that the

    * proper events are emitted.

    * @param account The account that will receive the created tokens.

    * @param amount The amount that will be created.

    */

    function _mint(address account, uint256 amount) internal {

        require(account != 0);

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }



    /**

    * @dev Internal function that burns an amount of the token of a given

    * account.

    * @param account The account whose tokens will be burnt.

    * @param amount The amount that will be burnt.

    */

    function _burn(address account, uint256 amount) internal {

        require(account != 0);

        require(amount <= _balances[account]);



        _totalSupply = _totalSupply.sub(amount);

        _balances[account] = _balances[account].sub(amount);

        emit Transfer(account, address(0), amount);

    }



    /**

    * @dev Internal function that burns an amount of the token of a given

    * account, deducting from the sender's allowance for said account. Uses the

    * internal burn function.

    * @param account The account whose tokens will be burnt.

    * @param amount The amount that will be burnt.

    */

    function _burnFrom(address account, uint256 amount) internal {

        require(amount <= _allowed[account][msg.sender]);



        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

        // this function needs to emit an event with the updated approval.

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

        amount);

        _burn(account, amount);

    }

}



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



    /**

    * @dev Overrides ERC20._burn in order for burn and burnFrom to emit

    * an additional Burn event.

    */

    function _burn(address who, uint256 value) internal {

        super._burn(who, value);

    }

}



contract IFUM is Ownable, ERC20Burnable {



    string public name;

    

    string public symbol;

    

    uint8 public decimals;



    address private _crowdsale;



    bool private _freezed;



    mapping (address => bool) private _locked;

    

    constructor() public {

        symbol = "IFUM";

        name = "INFLEUM Token";

        decimals = 8;

        _crowdsale = address(0);

        _freezed = true;

    }



    function setCrowdsale(address crowdsale) public {

        require(crowdsale != address(0), "Invalid address");

        require(_crowdsale == address(0), "It is allowed only one time.");

        _crowdsale = crowdsale;

        _mint(crowdsale, 3000000000 * 10 ** uint(decimals));

    }



    function isFreezed() public view returns (bool) {

        return _freezed;

    }



    function unfreeze() public {

        require(msg.sender == _crowdsale, "Only crowdsale contract can unfreeze this token.");

        _freezed = false;

    }



    function isLocked(address account) public view returns (bool) {

        return _locked[account];

    }



    modifier test(address account) {

        require(!isLocked(account), "It is a locked account.");

        require(!_freezed || _crowdsale == account, "A token is frozen or not crowdsale contract executes this function.");

        _;

    }



    function lockAccount(address account) public onlyOwner {

        require(!isLocked(account), "It is already a locked account.");

        _locked[account] = true;

        emit LockAccount(account);

    }



    function unlockAccount(address account) public onlyOwner {

        require(isLocked(account), "It is already a unlocked account.");

        _locked[account] = false;

        emit UnlockAccount(account);

    }



    function transfer(address to, uint256 value) public test(msg.sender) returns (bool) {

        return super.transfer(to, value);

    }



    function approve(address spender, uint256 value) public test(msg.sender) returns (bool) {

        return super.approve(spender, value);

    }



    function transferFrom(address from, address to, uint256 value) public test(from) returns (bool) {

        return super.transferFrom(from, to, value);

    }



    function increaseAllowance(address spender, uint256 addedValue) public test(msg.sender) returns (bool) {

        return super.increaseAllowance(spender, addedValue);

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public test(msg.sender) returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);

    }



    function burn(uint256 value) public test(msg.sender) {

        return super.burn(value);

    }



    function burnFrom(address from, uint256 value) public test(from) {

        return super.burnFrom(from, value);

    }



    event LockAccount(address indexed account);



    event UnlockAccount(address indexed account);

}



library Roles {



    struct Role {

        mapping (address => bool) bearer;

    }



    /**

    * @dev give an account access to this role

    */

    function add(Role storage role, address account) internal {

        require(account != address(0));

        role.bearer[account] = true;

    }



    /**

    * @dev remove an account's access to this role

    */

    function remove(Role storage role, address account) internal {

        require(account != address(0));

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



contract PauserRole {



    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private pausers;



    constructor() public {

        pausers.add(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender));

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        pausers.add(account);

        emit PauserAdded(account);

    }



    function renouncePauser() public {

        pausers.remove(msg.sender);

    }



    function _removePauser(address account) internal {

        pausers.remove(account);

        emit PauserRemoved(account);

    }

}



contract Pausable is PauserRole {



    event Paused();

    event Unpaused();



    bool private _paused = false;





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

        emit Paused();

    }



    /**

    * @dev called by the owner to unpause, returns to normal state

    */

    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused();

    }

}



library SafeERC20 {



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

        require(token.approve(spender, value));

    }

}



contract IFUMCrowdsale is Ownable, Pausable {



    using SafeERC20 for IFUM;



    enum Stage {

        Prepare,        // 0

        Presale,        // 1

        Crowdsale,      // 2

        Distribution,   // 3

        Finished        // 4

    }



    IFUM public token;



    address public _wallet;



    Stage public stage = Stage.Prepare;



    /**

     * @dev Set the address of the wallet to transfer automatically when the contract receives ether.

     * @param wallet The address for receiving ether.

     */

    function setWallet(address wallet) public onlyOwner {

        require(wallet != address(0), "Invalid address");

        address prev = _wallet;

        _wallet = wallet;

        emit SetWallet(prev, wallet);

    }



    /**

     * @dev Set the token contract. This function must be called at Prepare(0) stage.

     * @param newToken The address of IFUM token contract.

     */

    function setTokenContract(IFUM newToken) public onlyOwner {

        require(newToken != address(0), "Invalid address");

        address prev = token;

        token = newToken;

        emit SetTokenContract(prev, newToken);

    }



    /**

     * @dev If the contact receives ether in Presale or Crowdsale stage, send ether to _wallet automatically.

     */

    function () external payable {

        require(msg.value != 0, "You must transfer more than 0 ether.");

        require(

            stage == Stage.Presale || stage == Stage.Crowdsale,

            "It is not a payable stage."

        );

        _wallet.transfer(msg.value);

    }



    /**

     * @dev Called when an external server sends an IFUM token to each buyer at the Distribution stage.

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     */

    function transfer(address to, uint256 value) public onlyOwner {

        require(

            stage == Stage.Presale || stage == Stage.Crowdsale || stage == Stage.Distribution,

            "Is is not a transferrable stage."

        );

        token.safeTransfer(to, value);

    }



    /**

     * @dev At the Distribution stage, burn all IFUM tokens owned by the contract.

     */

    function burnAll() public onlyOwner {

        require(stage == Stage.Distribution, "Is is not a burnable stage.");

        token.burn(token.balanceOf(this));

    }



    /**

     * @dev Change the contact stage to the next stage.

     * Stages:

     *  0 - Prepare

     *  1 - Presale      ---- ICO Start --------------

     *  2 - Crowdsale    ---- ICO End ----------------

     *  3 - Distribution

     *  4 - Finished     ---- Unfreeze IFUM Token ----

     */

    function setNextStage() public onlyOwner {

        uint8 intStage = uint8(stage);

        require(intStage < uint8(Stage.Finished), "It is the last stage.");

        intStage++;

        stage = Stage(intStage);

        if (stage == Stage.Finished) {

            token.unfreeze();

        }

        emit SetNextStage(intStage);

    }



    event SetNextStage(uint8 stage);



    event SetWallet(address previousWallet, address newWallet);



    event SetTokenContract(address previousToken, address newToken);

}