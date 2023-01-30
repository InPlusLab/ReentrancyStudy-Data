// Abstract contract for the full ERC 20 Token standard

// https://github.com/ethereum/EIPs/issues/20

pragma solidity ^0.4.18;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

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



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



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



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is BasicToken {



    event Burn(address indexed burner, uint256 value);



    /**

     * @dev Burns a specific amount of tokens.

     * @param _value The amount of token to be burned.

     */

    function burn(uint256 _value) public {

        require(_value <= balances[msg.sender]);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        totalSupply = totalSupply.sub(_value);

        Burn(burner, _value);

    }

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

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

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

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

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



/**

 * @title SchedulableToken

 * @dev The SchedulableToken provide a method to create tokens progressively, in a gradual

 * and programed way, until a specified date and amount. To effectively create tokens, it

 * is necessary for someone to periodically run the release() function in the contract.

 * For example: You want to create a total of 1000 tokens (maxSupply) spread over 2 years (duration).

 * In this way, when calling the release() function, the number of tokens that are entitled at

 * that moment will be added to the beneficiary's wallet. In this scenario, by running the

 * release() function every day at the same time over 2 years, the beneficiary will receive

 * 1.37 tokens (1000 / 364.25 * 2) everyday.

 * @author Anselmo Zago ([email protected]), based in TokenVesting by Zeppelin Solidity library.

 */

contract SchedulableToken is StandardToken, BurnableToken {

  using SafeMath for uint256;



  event Released(uint256 amount);



  address public beneficiary;

  uint256 public maxSupply;

  uint256 public start;

  uint256 public duration;



  /**

   * @dev Constructor of the SchedulableToken contract that releases the tokens gradually and

   * programmatically. The balance will be assigned to _beneficiary in the maximum amount of

   * _maxSupply, divided proportionally during the _duration period.

   * @param _beneficiary address of the beneficiary to whom schedulable tokens will be added

   * @param _maxSupply schedulable token max supply

   * @param _duration duration in seconds of the period in which the tokens will released

   */

  function SchedulableToken(address _beneficiary, uint256 _maxSupply, uint256 _duration) public {

    require(_beneficiary != address(0));

    require(_maxSupply > 0);

    require(_duration > 0);



    beneficiary = _beneficiary;

    maxSupply = _maxSupply;

    duration = _duration;

    start = now;

  }



  /**

   * @notice Transfers schedulable tokens to beneficiary.

   */

  function release() public {

    uint256 amount = calculateAmountToRelease();

    require(amount > 0);



    balances[beneficiary] = balances[beneficiary].add(amount);

    totalSupply = totalSupply.add(amount);



    Released(amount);

  }



  /**

   * @dev Calculates the amount of tokens by right, until that moment.

   */

  function calculateAmountToRelease() public view returns (uint256) {

    if (now < start.add(duration)) {

      return maxSupply.mul(now.sub(start)).div(duration).sub(totalSupply);

    } else {

      return schedulableAmount();

    }

  }



  /**

   * @dev Returns the total amount that still to be released by the end of the duration.

   */

  function schedulableAmount() public view returns (uint256) {

    return maxSupply.sub(totalSupply);

  }



  /**

  * @dev Overridden the BurnableToken burn() function to also correct maxSupply.

  * @param _value The amount of token to be burned.

  */

  function burn(uint256 _value) public {

    super.burn(_value);

    maxSupply = maxSupply.sub(_value);

  }

}



/**

 * @title Letsfair Token (LTF)

 * @dev LetsfairToken contract implements the ERC20 with the StandardToken functions.

 * The token's creation is realize in a gradual and programmatic way, distributed

 * proportionally over a predefined period, specified by SchedulableToken.

 * @author Anselmo Zago ([email protected])

 */

 contract LetsfairToken is SchedulableToken {



  string public constant name = "Letsfair";

  string public constant symbol = "LTF";

  uint8 public constant decimals = 18;



  address _beneficiary = 0xe0F158B382F30A1eccecb5B67B1cf7EB92B5f1E4;

  uint256 _maxSupply = 10 ** 27; // 1 billion with decimals

  uint256 _duration = 157788000; // ~5 years in seconds



  function LetsfairToken() SchedulableToken(_beneficiary, _maxSupply, _duration) public {}

}