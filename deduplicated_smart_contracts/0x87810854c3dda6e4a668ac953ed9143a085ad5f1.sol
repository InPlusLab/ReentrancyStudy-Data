/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

contract SafeMath {

  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {

    //uint256 c = a * b;

    //require(a == 0 || c / a == b);

    //return c;

    

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {

    //require(b > 0);

    //uint256 c = a / b;

    //require(a == b * c + a % b);

    //return c;

    

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {

    //require(b <= a);

    //return a - b;

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {

    //uint256 c = a + b;

    //require(c>=a && c>=b);

    //return c;

    

    uint256 c = a + b;

    require(c >= a);



    return c;

  }

  

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }



  /*function assert(bool assertion) internal {

    if (!assertion) {

      throw;

    }

  }*/

}

/**

 * Smart Token Contract modified and developed by Marco Sanna,

 * blockchain developer of Namacoin ICO Project.

 */

contract Namacoin is SafeMath{

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

	address public owner;



    /* This creates an array with all balances */

    mapping (address => uint256) public balanceOf;

	mapping (address => uint256) public freezeOf;

    mapping (address => mapping (address => uint256)) public allowance;



    /* This generates a public event on the blockchain that will notify clients */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /* This notifies clients about the amount burnt */

    event Burn(address indexed from, uint256 value);

	

	/* This notifies clients about the amount frozen */

    event Freeze(address indexed from, uint256 value);

	

	/* This notifies clients about the amount unfrozen */

    event Unfreeze(address indexed from, uint256 value);

	

	/* This notifies clients that owner withdraw the ether */

	event Withdraw(address indexed from, uint256 value);

	

	/* This notifies the first creation of the contract */

	event Creation(address indexed owner, uint256 value);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor(

        uint256 initialSupply,

        string tokenName,

        uint8 decimalUnits,

        string tokenSymbol

        ) public {

        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens

        emit Creation(msg.sender, initialSupply);                // Notify anyone that the Tokes was create 

        totalSupply = initialSupply;                        // Update total supply

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

        decimals = decimalUnits;                            // Amount of decimals for display purposes

		owner = msg.sender;

    }



    /* Send coins */

    function transfer(address _to, uint256 _value) public {

        require(_to != 0x0);

        require(_value > 0);

        require(balanceOf[msg.sender] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        

        //if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead

		//if (_value <= 0) throw; 

        //if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough

        //if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient

        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place

    }



    /* Allow another contract to spend some tokens in your behalf */

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

            

        require(_value > 0);

		//if (_value <= 0) throw; 

        allowance[msg.sender][_spender] = _value;

        return true;

    }

       



    /* A contract attempts to get the coins */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        

        require(_to != 0x0);

        require(_value > 0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        require(_value <= allowance[_from][msg.sender]);

        

        //if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address. Use burn() instead

		//if (_value <= 0) throw; 

        //if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough

        //if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows

        //if (_value > allowance[_from][msg.sender]) throw;     // Check allowance

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient

        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        require(_value > 0);

        //if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough

		//if (_value <= 0) throw; 

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender

        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }

	

	function freeze(uint256 _value) public returns (bool success) {

	    require(balanceOf[msg.sender] >= _value);

	    require(_value > 0);

        //if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough

		//if (_value <= 0) throw; 

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender

        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply

        emit Freeze(msg.sender, _value);

        return true;

    }

	

	function unfreeze(uint256 _value) public returns (bool success) {

	    require(freezeOf[msg.sender] >= _value);

	    require(_value > 0);

        //if (freezeOf[msg.sender] < _value) throw;            // Check if the sender has enough

		//if (_value <= 0) throw; 

        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender

		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);

        emit Unfreeze(msg.sender, _value);

        return true;

    }

	

	// transfer balance to owner

	function withdrawEther(uint256 amount) public returns (bool success){

	    require(msg.sender == owner);

	    //require(amount > 0);

		//if(msg.sender != owner)throw;

		owner.transfer(amount);

		emit Withdraw(msg.sender, amount);

		return true;

	}

	

	// can accept ether

	function() public payable {

    }

}