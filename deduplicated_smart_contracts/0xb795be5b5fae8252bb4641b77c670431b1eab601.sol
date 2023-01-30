/**

 *Submitted for verification at Etherscan.io on 2019-04-13

*/



pragma solidity ^0.5.7;



/*

--------------------------------------------------------------------------------

Waste Chain Coin Smart Contract



Credit	: Rejean Leclerc 

Mail 	: [email protected]



--------------------------------------------------------------------------------

*/



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



contract WasteChainCoin {

           

    using SafeMath for uint256;

    

    string public constant name = "Waste Chain Coin";

    string public constant symbol = "WCC";

    uint8 public constant decimals = 18;

    /* The initially/total supply is 10,000,000,000 WCC with 18 decimals */

    uint256 public constant _totalSupply  = 10000000000000000000000000000;

    

    address payable owner;

    mapping(address => uint256) public balances;

    mapping(address => mapping (address => uint256)) public allowed;

    uint256 public RATE = 0;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed from, address indexed to, uint256 value);

	

	constructor() public {

	    owner = msg.sender; 

        balances[owner] = _totalSupply;	    

	}

    

   function () external payable {

        convertTokens();

    }

    

    function convertTokens() public payable {

        require(msg.value > 0);

		

        RATE = 18000;

	    uint256 tokens = msg.value.mul(RATE);

    	balances[msg.sender] = balances[msg.sender].add(tokens);

	    balances[owner] = balances[owner].sub(tokens);

    	owner.transfer(msg.value);

    }



    /* Transfer the balance from the sender's address to the address _to */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value

            && _value > 0

            && balances[_to] + _value > balances[_to]) {

              balances[msg.sender] = balances[msg.sender].sub(_value);

              balances[_to] = balances[_to].add(_value);

              emit Transfer(msg.sender, _to, _value);

              return true;

        } else {

            return false;

        }

    }



    /* Withdraws to address _to form the address _from up to the amount _value */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (balances[_from] >= _value

            && allowed[_from][msg.sender] >= _value

            && _value > 0

            && balances[_to] + _value > balances[_to]) {

              balances[_from] = balances[_from].sub(_value);

              allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

              balances[_to] = balances[_to].add(_value);

              emit Transfer(_from, _to, _value);

              return true;

        } else {

            return false;

        }

    }



    /* Allows _spender to withdraw the _allowance amount form sender */

    function approve(address _spender, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value) {

            allowed[msg.sender][_spender] = _value;

            emit Approval(msg.sender, _spender, _value);

            return true;

        } else {

            return false;

        }

    }



    /* Checks how much _spender can withdraw from _owner */

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



   function balanceOf(address _address) public view returns (uint256 balance) {

        return balances[_address];

    }

    

    function totalSupply() public view returns (uint256 totalSupply) {

        return _totalSupply;

    }

}