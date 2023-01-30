/**

 *Submitted for verification at Etherscan.io on 2018-12-05

*/



pragma solidity ^0.4.24;





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



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

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

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

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

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



contract StandardToken is ERC20,Pausable {

    using SafeMath for uint256;



    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) whenNotPaused returns (bool success) {

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    /**

    * @dev Transfer tokens from one address to another

    * @param _from address The address which you want to send tokens from

    * @param _to address The address which you want to transfer to

    * @param _value uint256 the amout of tokens to be transfered

    */

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        balances[_to] = balances[_to].add(_value);

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }



    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

    * This only works when the allowance is 0. Cannot be used to change allowance.

    * https://github.com/ethereum/EIPs/issues/738#issuecomment-336277632

    * @param _spender The address which will spend the funds.

    * @param _value The amount of tokens to be spent.

    */

    function approve(address _spender, uint256 _value) whenNotPaused returns (bool success) {

        require(allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

    * @dev Function to check the amount of tokens that an owner allowed to a spender.

    * @param _owner address The address which owns the funds.

    * @param _spender address The address which will spend the funds.

    * @return A uint256 specifing the amount of tokens still available for the spender.

    */

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    /**

     * To increment allowed value is better to use this function.

     * From MonolithDAO Token.sol

     */

    function increaseApproval(address _spender, uint _addedValue) whenNotPaused public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused public returns (bool) {

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



library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}





/* Contract class to mint tokens and transfer */

contract SPRINGToken is StandardToken {

  using SafeMath for uint256;



  string constant public name = 'SPRING Token';

  string constant public symbol = 'SPRING';

  uint constant public decimals = 18;

  uint256 public totalSupply;

  uint256 public maxSupply;



  /* Constructor function to set maxSupply*/

  constructor(uint256 _maxSupply) public {

    maxSupply = _maxSupply;

  }



  /**

 * @dev Function to mint tokens

 * @param _amount The amount of tokens to mint.

 * @return A boolean that indicates if the operation was successful.

 */

  function mint(uint256 _amount) onlyOwner public returns (bool) {

    require (maxSupply >= (totalSupply.add(_amount)));

    totalSupply = totalSupply.add(_amount);

    balances[msg.sender] = balances[msg.sender].add(_amount);

    emit Transfer(address(0), msg.sender, _amount);

    return true;

  }



}