/**

 *Submitted for verification at Etherscan.io on 2019-02-28

*/



pragma solidity ^0.4.24;

 

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

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

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

     * @dev transfer token for a specified address

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

    mapping (address => mapping (address => uint256)) internal allowed;

    

    event Burn(address _address, uint256 _value);

    

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

  

    /**

     * Destroy tokens

     * Remove `_value` tokens from the system irreversibly

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);                 // Check if the sender has enough

        balances[msg.sender] = balances[msg.sender].sub(_value); // Subtract from the sender

        totalSupply_ = totalSupply_.sub(_value);                 // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }



    /**

     * Destroy tokens from other account

     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.

     * @param _from the address of the sender

     * @param _value the amount of money to burn

     */

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value);                // Check if the targeted balance is enough

        require(_value <= allowed[_from][msg.sender]);    // Check allowance

        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance

        totalSupply_ = totalSupply_.sub(_value);                              // Update totalSupply

        emit Burn(_from, _value);

        return true;

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

        owner = newOwner;

        emit OwnershipTransferred(owner, newOwner);

    }

}





/**

 * @title FLC

 * @dev Token that implements the erc20 interface

 */

contract FLC is StandardToken, Ownable {

    address public holder1Account = address(0xbae265cc7039699381865BC78D527fdACca1f97B);

	address public holder2Account = address(0x8A1984217dd81f1F204C26e707a3F73A2F26d20C);

	address public holder3Account = address(0xc64165E3E8c0240D3E89E9Dbb432b6b21eef3705);

    address public holder4Account = address(0xA34baC41CF04726A9557736ED9D483Bd7062c6F8);

    address public holder5Account = address(0x2b06b787e77D776c8e95C6b8a094Ba137b0Dd1A1); 

    

	mapping(address => bool) public owners;

	

	string public name   = "Fast Lane Coin";  // set Token name

	string public symbol = "FLC";  // set Token symbol

	uint public decimals = 18;

	uint public INITIAL_SUPPLY = 250000000000 * (10 ** uint256(decimals));  // set Token total supply

		

	bool public released      = false;   // all lock

	bool public stepLockCheck = false;    // step lock

	uint8 public transferStep = 0;       // avail step

    mapping(uint8 => mapping(address => bool)) public holderStep; // holder step

	

	event ReleaseToken(address _owner, bool released);

	event ChangeTransferStep(address _owner, uint8 newStep);

	

	/**

     * Constructor function

     * Initializes contract with initial supply tokens to the creator of the contract

     */ 

	constructor() public {

	    require(msg.sender != address(0));

		totalSupply_ = INITIAL_SUPPLY;      // Set total supply

		balances[msg.sender] = INITIAL_SUPPLY;

		emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

		

		super.transfer(holder1Account, INITIAL_SUPPLY.mul(20).div(100));

		super.transfer(holder2Account, INITIAL_SUPPLY.mul(20).div(100));

		super.transfer(holder3Account, INITIAL_SUPPLY.mul(20).div(100));

		super.transfer(holder4Account, INITIAL_SUPPLY.mul(20).div(100));

		super.transfer(holder5Account, INITIAL_SUPPLY.mul(20).div(100));



		// set owners

		owners[msg.sender] = true;

		owners[holder1Account] = true;

		owners[holder2Account] = true;

		owners[holder3Account] = true;

		owners[holder4Account] = true;

		owners[holder5Account] = true;

		

		holderStep[0][msg.sender] = true;

		holderStep[0][holder1Account] = true;

		holderStep[0][holder2Account] = true;

		holderStep[0][holder3Account] = true;

		holderStep[0][holder4Account] = true;

		holderStep[0][holder5Account] = true;

    }	

	

	/**

     * Token lock management

     */

	function releaseToken() onlyOwner public {

	    require(!released);

	    released = true;

	    emit ReleaseToken(msg.sender, released);

	}

	function lockToken() onlyOwner public {

		require(released);

		released = false;

		emit ReleaseToken(msg.sender, released); 

	}

	function changeTransferStepLock(bool _stepLock) onlyOwner public {

	    require(stepLockCheck != _stepLock);

	    stepLockCheck = _stepLock;

	}

	function changeTransferStep(uint8 _changeStep) onlyOwner public {

	    require(transferStep != _changeStep);

	    require(_changeStep >= 0 && _changeStep < 10);

        transferStep = _changeStep;

        emit ChangeTransferStep(msg.sender, _changeStep);

	}

	

	/**

     * Check the token and step lock

     */

	modifier onlyReleased(address _funderAddr) {

	    if (!owners[_funderAddr]) {

	        require(released);

	    }

	    _;

	}

	modifier onlyStepUnlock(address _funderAddr) {

	    if (!owners[_funderAddr]) {

	        if (stepLockCheck) {

    		    require(checkHolderStep(_funderAddr));

	        }    

	    }

	    _;

	}

	

	/**

     * Regist holder step

     */

    function registHolderStep(uint8 _step, address _funderAddr) public returns (bool) {		

		require(_step > 0);

        holderStep[_step][_funderAddr] = true;

        

        return true;

    }

	/**

     * Check the funder step lock

     */

	function checkHolderStep(address _funderAddr) public view returns (bool) {

		bool returnBool = false;        

        for (uint8 i = transferStep; i >= 1; i--) {

            if (holderStep[i][_funderAddr]) {

                returnBool = true;

                break;

            }

        }

		return returnBool;

	}

		

	/**

	 * Override ERC20 interface funtion, To verify token release

	 */

	function transfer(address to, uint256 value) public onlyReleased(msg.sender) onlyStepUnlock(msg.sender) returns (bool) {

	    return super.transfer(to, value);

    }

    function allowance(address owner, address spender) public onlyReleased(msg.sender) view returns (uint256) {

        return super.allowance(owner,spender);

    }

    function transferFrom(address from, address to, uint256 value) public onlyReleased(msg.sender) onlyStepUnlock(msg.sender) returns (bool) {

        

        return super.transferFrom(from, to, value);

    }

    function approve(address spender, uint256 value) public onlyReleased(msg.sender) returns (bool) {

        return super.approve(spender,value);

    }

	// Only the owner can manage burn function

	function burn(uint256 _value) public onlyOwner returns (bool success) {

		return super.burn(_value);

	}

	function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) {

		return super.burnFrom(_from, _value);

	}

}