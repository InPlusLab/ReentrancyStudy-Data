/**

 *Submitted for verification at Etherscan.io on 2019-02-28

*/



pragma solidity ^0.5.4;



contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract BasicToken is ERC20Basic {

    using SafeMath for uint256;



    mapping(address => uint256) balances;



    uint256 totalSupply_;



    /**

    * @dev total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[msg.sender]);



        // SafeMath.sub will throw if there is not enough balance.

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



}

contract Ownable {

    address public owner;





    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





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

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }



}

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

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

contract StandardToken is ERC20, BasicToken {



    mapping (address => mapping (address => uint256)) internal allowed;





    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

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

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     *

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     *

     * approve should be called when allowed[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _addedValue The amount of tokens to increase the allowance by.

     */

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     *

     * approve should be called when allowed[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



}

contract KrpToken is StandardToken, Ownable {



    string public constant name = "Kryptoin Blockchain 10 ETF";

    string public constant symbol = "ETF";

    uint8 public constant decimals = 18;



    event Mint(address indexed to, uint256 amount);

    event MintStopped();

    event MintStarted();

    bool public mintingStopped = false;

    bool public tradeOn = true;



    address mintManager;



    modifier canMint() {

        require(msg.sender == owner || msg.sender == mintManager);

        require(!mintingStopped);

        _;

    }



    modifier isTradeOn() {

        require(tradeOn == true);

        _;

    }



    function setMintManager(address _mintManager) public onlyOwner {

        mintManager = _mintManager;

    }



    /**

    * @dev Internal function that mints an amount of the token and assigns it to

    * an account.

    * @param account The account that will receive the created tokens.

    * @param amount The amount that will be created.

    */

    function mint(address account, uint256 amount) public canMint() returns(bool) {

        require(account != address(0));

        totalSupply_ = totalSupply_.add(amount);

        balances[account] = balances[account].add(amount);

        emit Mint(account, amount);

        emit Transfer(address(0), account, amount);

        return true;

    }



    /**

     * @dev Function to stop minting new tokens.

     * @return True if the operation was successful.

     */

    function stopMinting() onlyOwner public returns (bool) {

        mintingStopped = true;

        emit MintStopped();

        return true;

    }



    function startMinting() onlyOwner public returns (bool) {

        mintingStopped = false;

        emit MintStarted();

        return true;

    }



    event Burn(address indexed account, uint256 value);



    /**

     * @dev Function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param amount The amount that will be burnt.

     */

    function burn(address account, uint256 amount) public canMint() {

        require(account != address(0));

        require(amount <= balances[account]);



        totalSupply_ = totalSupply_.sub(amount);

        balances[account] = balances[account].sub(amount);

        emit Burn(account, amount);

        emit Transfer(account, address(0), amount);

    }



    // Overrided to put modifier

    function transfer(address _to, uint256 _value) public isTradeOn returns (bool) {

        super.transfer(_to, _value);

    }



    // Overrided to put modifier

    function transferFrom(address _from, address _to, uint256 _value) public isTradeOn returns (bool) {

        super.transferFrom(_from, _to, _value);

    }



    // Toggle trade on/off

    function toggleTradeOn() public onlyOwner{

        tradeOn = !tradeOn;

    }

}