/**

 *Submitted for verification at Etherscan.io on 2019-03-19

*/



pragma solidity ^0.4.24;



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {

        owner = msg.sender;

    }

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}



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



contract BasicToken is ERC20Basic{

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 internal totalSupply_;

    /**

     * @dev total number of tokens in existence

     */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {

        require(_to != address(0));

        require(_from != address(0));

        require(_value != 0);

        require(_value <= balances[_from]);

        // SafeMath.sub will throw if there is not enough balance.

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

     */



    function transfer(address _to, uint256 _value) public returns (bool) {

        return _transfer(msg.sender, _to, _value);

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

contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;



    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_value <= allowed[_from][msg.sender]);

        _transfer(_from, _to, _value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        return true;

    }



    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

    *

    * Beware that changing an allowance with this method brings the risk that someone may use both the old

    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

    * race condition is to first reduce the spenders allowance to 0 and set the desired value afterwards:

    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    * @param _spender The address which will spend the funds.

    * @param _value The amount of tokens to be spent.

     */



    function approve(address _spender, uint256 _value) public returns (bool) {

        require(_spender != address(0));

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

        require(_spender != address(0));

        require(_addedValue != 0);

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

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        require(_spender != address(0));

        require(_subtractedValue != 0);

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



contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**

    * @dev Burns a specific amount of tokens.

    * @param _value The amount of token to be burned.

    */

    function burn(uint256 _value) public {

        require(_value <= balances[msg.sender]);

        require(_value != 0);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[msg.sender] = balances[msg.sender].sub(_value);

        totalSupply_ = totalSupply_.sub(_value);

        emit Transfer(msg.sender, address(0), _value);

        emit Burn(msg.sender, _value);

    }

}



contract ISTCoin is BurnableToken, Ownable {

    string public constant name = "ISTCoin";

    string public constant symbol = "IST";

    uint8 public constant decimals = 8;



    bool public unFreeze = false;

    mapping (address => bool) public frozenAccount;



    modifier notFrozen(address sender) {

        require(!frozenAccount[sender] || unFreeze);

        _;

    }



    event FrozenFunds(address target, bool frozen);

    event FreezeAll(bool flag);

    event AccountFrozenError();



    uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));

    constructor () public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

    }



    function freezeAccount(address target, bool freeze) public onlyOwner {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



    // unfreeze all accounts

    function unFreezeAll(bool flag) public onlyOwner {

        unFreeze = flag;

        emit FreezeAll(flag);

    }



    function transfer(address _to, uint256 _value) public notFrozen(msg.sender) returns (bool) {

        return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public notFrozen(_from) returns (bool) {

        return super.transferFrom(_from, _to, _value);

    }



    function approve(address _spender, uint256 _value) public notFrozen(msg.sender) returns (bool) {

        return super.approve(_spender, _value);

    }

}