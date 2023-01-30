/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



pragma solidity ^0.5.1;



contract SafeMath {

    // Overflow protected math functions



    /**

        @dev returns the sum of _x and _y, asserts if the calculation overflows



        @param _x   value 1

        @param _y   value 2



        @return sum

    */

    function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;

        require(z >= _x);        //assert(z >= _x);

        return z;

    }



    /**

        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number



        @param _x   minuend

        @param _y   subtrahend



        @return difference

    */

    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y);        //assert(_x >= _y);

        return _x - _y;

    }



    /**

        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows



        @param _x   factor 1

        @param _y   factor 2



        @return product

    */

    function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x * _y;

        require(_x == 0 || z / _x == _y);        //assert(_x == 0 || z / _x == _y);

        return z;

    }

	

	function safeDiv(uint256 _x, uint256 _y)internal pure returns (uint256){

	    // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return _x / _y;

	}

	

	function ceilDiv(uint256 _x, uint256 _y)internal pure returns (uint256){

		return (_x + _y - 1) / _y;

	}

}





contract Sqrt {

	function sqrt(uint x)public pure returns(uint y) {

        uint z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }

}



contract WIACToken is SafeMath {

	mapping (address => uint256) balances;

	address public owner = 0x9E94c8B22a4b60e8c017a245CDEb48b66497C4CB;

    string public name;

    string public symbol;

    uint8 public decimals = 18;

	// total amount of tokens

    uint256 public totalSupply;

    

	// `allowed` tracks any extra transfer rights as in all ERC20 tokens

    mapping (address => mapping (address => uint256)) allowed;



    constructor() public {

        uint256 initialSupply = 360000000;

        

        totalSupply = initialSupply * 10 ** uint256(decimals);

        balances[owner] = totalSupply;

        name = "WaldenGoton International Asset Chain";

        symbol = "WIAC";

    }

	

    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) public view returns (uint256 balance) {

		 return balances[_owner];

	}



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success) {

	    require(_value > 0 );                                          // Check send token value > 0;

		require(balances[msg.sender] >= _value);                       // Check if the sender has enough

        require(balances[_to] + _value > balances[_to]);               // Check for overflows											

    	balances[msg.sender] = safeSub(balances[msg.sender], _value);  // Subtract from the sender

		balances[_to]  = safeAdd(balances[_to], _value);               // Add the same to the recipient                       

	

		emit Transfer(msg.sender, _to, _value); 			       // Notify anyone listening that this transfer took place

		return true;      

	}



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

	  

	    require(balances[_from] >= _value);                 // Check if the sender has enough

        require(balances[_to] + _value >= balances[_to]);   // Check for overflows

        require(_value <= allowed[_from][msg.sender]);      // Check allowance

        balances[_from] = safeSub(balances[_from], _value);  // Subtract from the sender

        balances[_to] = safeAdd(balances[_to], _value);      // Add the same to the recipient

       

        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);

        

        emit Transfer(_from, _to, _value);

        return true;

	}



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success) {

		require(balances[msg.sender] >= _value);

		allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

		return true;

	

	}

	

    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

	}

	

	/* This unnamed function is called whenever someone tries to send ether to it */

    function () external {

        revert();     // Prevents accidental sending of ether

    }



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}