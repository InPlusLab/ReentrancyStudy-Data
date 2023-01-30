pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
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

  /*************************************************/
    mapping(address=>uint256) public indexes;
    mapping(uint256=>address) public addresses;
    uint256 public lastIndex = 0;
  /*************************************************/

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    if(_value > 0){
        if(balances[msg.sender] == 0){
            // remove the msg.sender from list of holders if their balance is 0
            addresses[indexes[msg.sender]] = addresses[lastIndex];
            indexes[addresses[lastIndex]] = indexes[msg.sender];
            indexes[msg.sender] = 0;
            delete addresses[lastIndex];
            lastIndex--;
        }
        if(indexes[_to]==0){
            // add the receiver to the list of holders if they aren't already there
            lastIndex++;
            addresses[lastIndex] = _to;
            indexes[_to] = lastIndex;
        }
    }
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
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

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    
    // The following logic is to keep track of token holders
    // No need to change *anything* in the following logic
    if(_value > 0){
      //if _from has no tokens left
        if(balances[_from] == 0){
          // remove _from from token holders list
            addresses[indexes[_from]] = addresses[lastIndex];
            indexes[addresses[lastIndex]] = indexes[_from];
            indexes[_from] = 0;
            delete addresses[lastIndex];
            lastIndex--;
        }
        // if _to wasn't in token holders list
        if(indexes[_to]==0){
          // add _to to the list of token holders
            lastIndex++;
            addresses[lastIndex] = _to;
            indexes[_to] = lastIndex;
        }
    }
    
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public
    returns (bool success) {
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
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
        
        // we remove the burner from the list of token 
        // holders if the burner now holds 0 tokens
        if(balances[burner] == 0){
            addresses[indexes[burner]] = addresses[lastIndex];
            indexes[addresses[lastIndex]] = indexes[burner];
            indexes[burner] = 0;
            delete addresses[lastIndex];
            lastIndex--;
        }
        
    }
}

contract BIKOIN is BurnableToken, Ownable {

    string public constant name = "BIKOIN";
    string public constant symbol = "BKN";
    uint public constant decimals = 18;
    uint256 public constant initialSupply = 1000000000 * (10 ** uint256(decimals));

    uint public totalWeiToBeDistributed = 0;

    // Constructor
    constructor () public {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; // Send all tokens to owner
        /*****************************************/
        // add msg.sender to the list of token holders
        addresses[1] = msg.sender;
        indexes[msg.sender] = 1;
        lastIndex = 1;
        /*****************************************/
        emit Transfer(0x0, msg.sender, initialSupply);
    }

    function getAddresses() public view returns (address[]){
        address[] memory addrs = new address[](lastIndex);
        for(uint i = 0; i < lastIndex; i++){
            addrs[i] = addresses[i+1];
        }
        return addrs;
    }

    function setTotalWeiToBeDistributed(uint _totalWei) public onlyOwner {
      totalWeiToBeDistributed = _totalWei;
    }

    function distributeEth(uint startIndex, uint endIndex) public onlyOwner {
      for(uint i = startIndex; i < endIndex; ++i){
        // counting starts at index 1 instead of 0,
        // pls don't worry if you can't figure out why,
        // just don't change it to start from 0
        address holder = addresses[i+1]; 
        // no need for `SafeMath.div()` here
        uint reward = (balances[holder].mul(totalWeiToBeDistributed))/(totalSupply);
        holder.transfer(reward);
      }
    }

    function withdrawEth() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    function () public payable {}
}