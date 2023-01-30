/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.12;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

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



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address public owner;

    address public pendingOwner;





    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );





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

     * @param _newOwner The address to transfer ownership to.

     */

    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0));

        pendingOwner = _newOwner;

    }



    /**

     * @dev Grants ownership to pendingOwner.

    */

    function acceptOwnership() public {

        require(msg.sender == pendingOwner);

        emit OwnershipTransferred(owner, pendingOwner);

        owner = pendingOwner;

        pendingOwner = address(0);

    }



}



/**

 * @title Support

 * @dev Provides authorization control to Support.

 */

contract Support is Ownable {

    mapping(address => bool) public supportList;



    event SupportAdded(address indexed _who);

    event SupportRemoved(address indexed _who);



    /**

    * @dev Throws if called by any account other than the supportList or owner.

    */

    modifier supportOrOwner {

        require(msg.sender == owner || supportList[msg.sender]);

        _;

    }



    /**

    * @dev Allows current owner to grant extended contract access to _who .

    * @param _who The address to change permissions.

    */

    function addSupport(address _who) public onlyOwner {

        require(_who != address(0));

        require(_who != owner);

        require(!supportList[_who]);

        supportList[_who] = true;

        emit SupportAdded(_who);

    }



    /**

    * @dev Allows current owner to revoke extended contract access from _who .

    * @param _who The address to change permissions.

    */

    function removeSupport(address _who) public onlyOwner {

        require(supportList[_who]);

        supportList[_who] = false;

        emit SupportRemoved(_who);

    }

}



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender)

    public view returns (uint256);



    function transferFrom(address from, address to, uint256 value)

    public returns (bool);



    function approve(address spender, uint256 value) public returns (bool);



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

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

    * @dev Transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[msg.sender]);



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

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];

    }



}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



    mapping(address => mapping(address => uint256)) internal allowed;





    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

        public

        returns (bool)

    {

        require(_from != address(0));

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

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint256 _value) public returns (bool) {

        require(_spender != address(0));

        require(_value <= balances[msg.sender]);



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

    function allowance(

        address _owner,

        address _spender

    )

        public

        view

        returns (uint256)

    {

        return allowed[_owner][_spender];

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

    function increaseApproval(

        address _spender,

        uint256 _addedValue

    )

        public

        returns (bool)

    {

        require(_spender != address(0));

        require(allowed[msg.sender][_spender].add(_addedValue) <= balances[msg.sender]);



        allowed[msg.sender][_spender] = (

        allowed[msg.sender][_spender].add(_addedValue));

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

    function decreaseApproval(

        address _spender,

        uint256 _subtractedValue

    )

        public

        returns (bool)

    {

        require(_spender != address(0));



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



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is BasicToken, Support {



    event Burn(address indexed burner, uint256 value);



    /**

     * @dev Burns a specific amount of tokens.

     * @param _value The amount of token to be burned.

     */

    function burn(uint256 _value) supportOrOwner public {

        _burn(msg.sender, _value);

    }



    function _burn(address _who, uint256 _value) internal {

        require(_value <= balances[_who]);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        balances[_who] = balances[_who].sub(_value);

        totalSupply_ = totalSupply_.sub(_value);

        emit Burn(_who, _value);

        emit Transfer(_who, address(0), _value);

    }

}



/**

 * @title FreezeTokenCrowdsale

 * @dev Freezes tokens transfer while crowdsale.

 * Only owner and supportList are able to transfer tokens during crowd sale.

 */

contract FreezeTokenCrowdsale is StandardToken, Support {



    event CrowdsaleFinalized();



    bool public freeze = false;



    /**

     * @dev Modifier to make a function available to everyone when crowd sale is over

     */

    modifier freezeTransfer() {

        require(freeze == false || msg.sender == owner || supportList[msg.sender]);

        _;

    }



    /**

     * @dev Has to be called when crowdsale is over to allow all users transfer tokens.

     */

    function finalizeCrowdsale() onlyOwner public {

        require(freeze == true);

        freeze = false;

        emit CrowdsaleFinalized();

    }



    function transfer(

        address _to,

        uint256 _value

    )

        public

        freezeTransfer

        returns (bool)

    {

        return super.transfer(_to, _value);

    }



    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

        public

        freezeTransfer

        returns (bool)

    {

        return super.transferFrom(_from, _to, _value);

    }



}



/**

 * @title RCARBITRAGE

 * @dev ERC20 Token.

 */

contract RCARBITRAGE is FreezeTokenCrowdsale, BurnableToken {



    string public constant name = "RCARBITRAGE"; // solium-disable-line uppercase

    string public constant symbol = "RCAP"; // solium-disable-line uppercase

    uint8 public constant decimals = 18; // solium-disable-line uppercase



    uint256 public constant INITIAL_SUPPLY = 4800000 * (10 ** uint256(decimals));



    /**

     * @dev Constructor that gives msg.sender all of existing tokens.

     */

    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

    }



}