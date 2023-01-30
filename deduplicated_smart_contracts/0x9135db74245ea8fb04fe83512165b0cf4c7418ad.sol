/**

 *Submitted for verification at Etherscan.io on 2019-03-01

*/



pragma solidity 0.5.4;





interface IGTSTOKEN {

    function transfer(address _to, uint _value) external;

    function transferFrom(address _from, address _to, uint _value) external;

    function balanceOf(address who) external view returns (uint);

    function setDestoryAddress(address _destory) external;

    function ifDestory(address from) external returns (bool);

}





library SafeMath {



    uint256 constant internal MAX_UINT = 2 ** 256 - 1; // max uint256



    /**

     * @dev Multiplies two numbers, reverts on overflow.

     */

    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {

        if (_a == 0) {

            return 0;

        }

        require(MAX_UINT / _a >= _b);

        return _a * _b;

    }



    /**

     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {

        require(_b != 0);

        return _a / _b;

    }



    /**

     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {

        require(_b <= _a);

        return _a - _b;

    }



    /**

     * @dev Adds two numbers, reverts on overflow.

     */

    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {

        require(MAX_UINT - _a >= _b);

        return _a + _b;

    }



}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address public owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () public {

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

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}





contract Pausable is Ownable {

    event Pause();

    event Unpause();



    bool public paused = false;



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() public onlyOwner whenNotPaused {

        paused = true;

        emit Pause();

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyOwner whenPaused {

        paused = false;

        emit Unpause();

    }

}





contract StandardToken {

    using SafeMath for uint256;



    mapping(address => uint256) internal balances;



    mapping(address => mapping(address => uint256)) internal allowed;



    uint256 public totalSupply;



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 vaule);



    /**

     * @dev Gets the balance of the specified address.

     * @param _owner The address to query the the balance of.

     * @return An uint256 representing the amount owned by the passed address.

     */

    function balanceOf(address _owner) public view returns(uint256) {

        return balances[_owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address _owner, address _spender) public view returns(uint256) {

        return allowed[_owner][_spender];

    }



    /**

     * @dev Transfer token for a specified address

     * @param _to The address to transfer to.

     * @param _value The amount to be transferred.

     */

    function transfer(address _to, uint256 _value) public returns(bool) {

        require(_to != address(0));

        require(_value <= balances[msg.sender]);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint256 _value) public returns(bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _addedValue The amount of tokens to increase the allowance by.

     */

    function increaseApproval(address _spender, uint256 _addedValue) public returns(bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns(bool) {

        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue >= oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        totalSupply = totalSupply.sub(value);

        balances[account] = balances[account].sub(value);

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

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

        // this function needs to emit an event with the updated approval.

        allowed[account][msg.sender] = allowed[account][msg.sender].sub(value);

        _burn(account, value);

    }



}





contract BurnableToken is StandardToken {



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

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 */

contract PausableToken is StandardToken, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);

    }



    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);

    }



    function increaseApproval(address spender, uint256 addedValue) public whenNotPaused returns (bool success) {

        return super.increaseApproval(spender, addedValue);

    }



    function decreaseApproval(address spender, uint256 subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseApproval(spender, subtractedValue);

    }

}





/**

 * @title GTSToken

 * @dev basic token information and other functions about exchange.

 */

contract GTSToken is PausableToken, BurnableToken {

    string public constant name = "test1"; // name of Token.

    string public constant symbol = "ZZZZ"; // symbol of Token.

    uint8 public constant decimals = 9; // decimals of Token.

    uint256 internal constant INIT_TOTALSUPPLY = 1000000000; // Total amount of tokens.



    uint8 public constant exchangeRate = 10; // rate of one new token to old token. 

    address public constant oldToken = 0x00E9bCfaB52C108505411849faBA90e83c98101b; // old token address

    

    /**

     * @dev initialize the token information.

     */

    constructor() public {

        totalSupply = INIT_TOTALSUPPLY * 10 ** uint256(decimals);

        balances[owner] = totalSupply;

    }

    

    /**

     * @dev throw when user has none of old token.

     */

    modifier hasOldToken() {

        IGTSTOKEN oldGTS = IGTSTOKEN(oldToken);

        require(oldGTS.balanceOf(msg.sender) > 0);

        _;

    }



    /**

     * @dev inquiry the amount which exchangeable from old token.

     */

    function tokenAmountOldToNew() public view returns(uint256){

        uint256 amount;

        IGTSTOKEN oldGTS = IGTSTOKEN(oldToken);

        amount = oldGTS.balanceOf(msg.sender).div(exchangeRate);

        return amount;

    }



    /**

     * @dev exchange old token to new token.

     */

    function tokenExchange() public hasOldToken returns(bool) {

        uint256 newTokenAmount = tokenAmountOldToNew();

        IGTSTOKEN oldGTS = IGTSTOKEN(oldToken);

        if(oldGTS.ifDestory(address(this))){

            oldGTS.setDestoryAddress(address(0));

        }

        oldGTS.transferFrom(msg.sender, address(this), oldGTS.balanceOf(msg.sender));

        require(balances[owner] >= newTokenAmount);

        balances[owner] = balances[owner].sub(newTokenAmount);

        balances[msg.sender] = balances[msg.sender].add(newTokenAmount);

        emit Transfer(owner, msg.sender, newTokenAmount);

        return true;

    }



    /**

     * @dev withdraw old token for recovery.

     */

    function withdrawOldToken() public onlyOwner returns(bool){

        IGTSTOKEN oldGTS = IGTSTOKEN(oldToken);

        if(oldGTS.ifDestory(address(this))){

            oldGTS.setDestoryAddress(address(0));

        }

        uint256 getAmount = oldGTS.balanceOf(address(this));

        oldGTS.transfer(owner, getAmount);

        return true;

    }

}