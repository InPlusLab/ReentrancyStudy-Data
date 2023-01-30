/**

 *Submitted for verification at Etherscan.io on 2018-09-10

*/



pragma solidity ^0.4.18;



library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

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

        Transfer(msg.sender, _to, _value);

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



contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

        Transfer(_from, _to, _value);

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

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

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

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

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

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {

        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



}





contract hasHolders {

    //    using SafeMath for uint256;



    struct Holder {

        uint256 id; //§á§à§â§ñ§Õ§Ü§à§Ó§í§Û §ß§à§Þ§Ö§â

        uint256 holderSince;

    }



    mapping(address => Holder) holders;

    // §Ó§ß§Ú§Þ§Ñ§ß§Ú§Ö! id §ç§à§Ý§Õ§Ö§â§Ñ §ß§Ñ§é§Ú§ß§Ñ§ð§ä§ã§ñ §ã 1!

    mapping(uint256 => address) holdersId;

    uint256 public holderCount = 0;



    event AddHolder(address indexed holder, uint256 index);

    event DelHolder(address indexed holder);

    event UpdHolder(address indexed holder, uint256 index);



    function _addHolder(address _holder) internal returns (bool) {

        if (holders[_holder].id == 0) {

            holders[_holder].id = ++holderCount;

            holders[_holder].holderSince = now;

            holdersId[holderCount] = _holder;

            AddHolder(_holder, holderCount);

            return true;

        }

        return false;

    }



    function _delHolder(address _holder) internal returns (bool){

        uint256 id = holders[_holder].id;

        if (id != 0 && holderCount > 0) {

            //replace with last

            holdersId[id] = holdersId[holderCount];

            // delete Holder element

            delete holders[_holder];

            //delete last id and decrease count

            delete holdersId[holderCount--];

            DelHolder(_holder);

            UpdHolder(holdersId[id], id);

            return true;

        }

        return false;

    }



    // §Ó§ß§Ú§Þ§Ñ§ß§Ú§Ö! id §ç§à§Ý§Õ§Ö§â§Ñ §ß§Ñ§é§Ú§ß§Ñ§ð§ä§ã§ñ §ã 1!

    function getHolder(uint256 _id) external view returns (address) {

        return holdersId[_id];

    }



    function getHoldersCount() external view returns (uint256) {

        return holderCount;

    }



    //    function getHolderId(address _holder) public constant returns (uint256) {

    //        return holders[_holder].id;

    //    }

}



contract UnicornDividendToken is StandardToken, hasHolders {

    using SafeMath for uint256;



    string public constant name = "Unicorn Dividend Token";

    string public constant symbol = "UDT";

    // §å§Þ§Ö§ß§î§ê§Ú§Ý §Õ§à 3, §ä.§Ü. §á§â§Ú §â§Ñ§ã§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§Ú §Ó§í§á§Ý§Ñ§ä §Õ§Ö§Ý§Ö§ß§Ú§Ö §ï§æ§Ú§â§Ñ §Ó wei §ß§Ñ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó (10**deciamls) §á§â§à§Ú§ã§ç§à§Õ§Ú§ä §ã §à§Õ§Ú§ß§Ñ§Ü§à§Ó§í§Þ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à§Þ §Ù§ß§Ñ§Ü§à§Ó

    // §é§ä§à §Ó §â§Ö§Ù§å§Ý§î§ä§Ñ§ä§Ö §Õ§Ñ§Ö§ä §Ó§ã§Ö§Ô§Õ§Ñ 0, §Ö§ã§Ý§Ú §á§â§Ú§ê§Ý§à §Þ§Ö§ß§î§ê§Ö 100 §ï§æ§Ú§â§Ñ

    uint8 public constant decimals = 3;

    uint256 public constant INITIAL_SUPPLY = 100  * (10 ** uint256(decimals));



    function UnicornDividendToken() public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

        _addHolder(msg.sender);

    }



    //§á§â§à§Ó§Ö§â§ñ§Ö§ä, §ñ§Ó§Ý§ñ§Ö§ä§ã§ñ §Ý§Ú §Ñ§Õ§â§Ö§ã§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§à§Þ §Ú§Ý§Ú §Ñ§Ü§Ü§Ñ§å§ß§ä§à§Þ

    function isAccount(address addr) private view returns (bool) {

        uint256 size;

        assembly { size := extcodesize(addr) }

        return size == 0;

    }



    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);



        // SafeMath.sub will throw if there is not enough balance.

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        // §á§â§à§Ó§Ö§â§Ú§Þ, §ñ§Ó§Ý§ñ§Ö§ä§ã§ñ §Ý§Ú §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ñ§Ü§Ü§Ñ§å§ß§ä§à§Þ

        if (isAccount(_to)) {

            _addHolder(_to);

        }

        if (balances[_from] == 0) {

            _delHolder(_from);

        }

        Transfer(_from, _to, _value);

        return true;

    }



    function transfer(address _to, uint256 _value) public returns (bool) {

        return _transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_value <= allowed[_from][msg.sender]);

        _transfer(_from, _to, _value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        return true;

    }



}