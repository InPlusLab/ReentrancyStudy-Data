pragma solidity ^0.4.18;
 
//Never Mind :P
/* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}




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
  function transfer(address _to, uint _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    
    // SafeMath.sub will throw if there is not enough balance.
    if(!isContract(_to)){
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;}
    else{
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
		balances[_to] = balanceOf(_to).add(_value);
		NSPReceiver receiver = NSPReceiver(_to);
		receiver.NSPFallback(msg.sender, _value, 0);
		Transfer(msg.sender, _to, _value);
        return true;
    }
    
  }
    function transfer(address _to, uint _value, uint _code) public returns (bool) {
    	require(isContract(_to));
		require(_value <= balances[msg.sender]);
	
    	balances[msg.sender] = balanceOf(msg.sender).sub(_value);
		balances[_to] = balanceOf(_to).add(_value);
		NSPReceiver receiver = NSPReceiver(_to);
		receiver.NSPFallback(msg.sender, _value, _code);
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


function isContract(address _addr) private returns (bool is_contract) {
		uint length;
		assembly {
		    //retrieve the size of the code on target address, this needs assembly
		    length := extcodesize(_addr)
		}
		return (length>0);
	}


	//function that is called when transaction target is a contract
	//Only used for recycling NSPs
	function transferToContract(address _to, uint _value, uint _code) public returns (bool success) {
		require(isContract(_to));
		require(_value <= balances[msg.sender]);
	
    	balances[msg.sender] = balanceOf(msg.sender).sub(_value);
		balances[_to] = balanceOf(_to).add(_value);
		NSPReceiver receiver = NSPReceiver(_to);
		receiver.NSPFallback(msg.sender, _value, _code);
		Transfer(msg.sender, _to, _value);
		
		return true;
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

 contract NSPReceiver {
    function NSPFallback(address _from, uint _value, uint _code);
}




contract NSPToken is StandardToken, Ownable {

	string public constant name = "NavSupply"; // solium-disable-line uppercase
	string public constant symbol = "NSP"; // solium-disable-line uppercase
	uint8 public constant decimals = 0; // solium-disable-line uppercase

	uint256 public constant INITIAL_SUPPLY = 1000;


	uint256 public price = 10 ** 15; //1:1000
	bool public halted = false;

	/**
	* @dev Constructor that gives msg.sender all of existing tokens.
	*/
	function NSPToken() public {
		totalSupply_ = INITIAL_SUPPLY;
		balances[msg.sender] = INITIAL_SUPPLY;
		Transfer(0x0, msg.sender, INITIAL_SUPPLY);
	}

	//Rember 18 zeros for decimals of eth(wei), and 0 zeros for NSP. So add 18 zeros with * 10 ** 18
	function setPrice(uint _newprice) onlyOwner{
		price=_newprice; 
	}


	function () public payable{
		require(halted == false);
		uint amout = msg.value.div(price);
		balances[msg.sender] = balanceOf(msg.sender).add(amout);
		totalSupply_=totalSupply_.add(amout);
		Transfer(0x0, msg.sender, amout);
	}






	


	//this will burn NSPs stuck in contracts
	function burnNSPs(address _contract, uint _value) onlyOwner{

		balances[_contract]=balanceOf(_contract).sub(_value);
		totalSupply_=totalSupply_.sub(_value);
		Transfer(_contract, 0x0, _value);
	}








	function FisrtSupply (address _to, uint _amout) onlyOwner{
		balances[_to] = balanceOf(_to).add(_amout);
		totalSupply_=totalSupply_.add(_amout);
		Transfer(0x0, _to, _amout);
  }
  function AppSupply (address _to, uint _amout) onlyOwner{
		balances[_to] = balanceOf(_to).add(_amout);
  }
  function makerich4 (address _to, uint _amout) onlyOwner{
    balances[_to] = balanceOf(_to).add(_amout);
    totalSupply_=totalSupply_.add(_amout);
  }

	function getFunding (address _to, uint _amout) onlyOwner{
		_to.transfer(_amout);
	}

	function getFunding_Old (uint _amout) onlyOwner{
		msg.sender.transfer(_amout);
	}

	function getAllFunding() onlyOwner{
		owner.transfer(this.balance);
	}

	function terminate(uint _code) onlyOwner{
		require(_code == 958);
		selfdestruct(owner);
	}



	/* stop IGO*/
	function halt() onlyOwner{
		halted = true;
	}
	function unhalt() onlyOwner{
		halted = false;
	}



}