/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

// File: contracts\token\ERCToken.sol

pragma solidity ^0.5.11;

contract ERCToken {
  uint256 internal _totalSupply;
  function totalSupply() public view returns (uint256) {
	return _totalSupply;
  }

  // Fix for the ERC20 short address attack
  modifier onlyPayloadSize(uint size) {
       require(msg.data.length >= size + 4);
       _;
  }
}

// File: contracts\token\ERC20\ERC20Basic.sol

pragma solidity ^0.5.11;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic is ERCToken {
  function name() public view returns (string memory);
  function symbol() public  view returns (string memory);
  function decimals() public view returns (uint8 _decimals);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\token\ERC20\ERC20.sol

pragma solidity ^0.5.11;


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

// File: contracts\SafeMath.sol

pragma solidity ^0.5.11;

/**
 * Math operations with safety checks
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure  returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal pure  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
 
}

// File: contracts\token\TokenDeliverer.sol

pragma solidity ^0.5.11;

contract TokenDeliverer {
	function _delivery( address recipient, uint256 amount ) internal returns (bool);
}

// File: contracts\token\ERC20\BasicToken.sol

pragma solidity ^0.5.11;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic, TokenDeliverer {
    
  using SafeMath for uint256;
 
  struct Balance {
		uint256 value;
		bool    exists;
  }
  
  mapping(address => Balance) balances;

  address[] public 			  accounts;
  /*
  mapping(address => uint256) balances;
   */
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {

    require(_to != address(0), "BasicToken: transfer to the zero address");
    require(_to != address(this), "BasicToken: transfer address");
 
    balances[msg.sender].value = balances[msg.sender].value.sub(_value);
	if( balances[_to].exists != true )
	{
		accounts.push( _to );
		balances[_to].exists = true;
	}
    balances[_to].value = balances[_to].value.add(_value);
	
    emit Transfer(msg.sender, _to, _value );
    return true;
  }

  function _delivery(address _to, uint256 _value) internal returns (bool) {
   		balances[address(this)].value = balances[address(this)].value.sub(_value);

		if( balances[_to].exists != true )
		{
			accounts.push( _to );
			balances[_to].exists = true;
		}
    	balances[_to].value = balances[_to].value.add(_value);
    	emit Transfer( address(this), _to, _value);
    	return true;
  }
 
  function _create_balance( uint256 _value ) internal {

    	balances[address(this)].value  = _value;
		balances[address(this)].exists = true;

		emit Transfer( address(0), address(this), _totalSupply );
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */

  function balanceOf(address _owner) view public returns (uint256 balance) {
    return balances[_owner].value;
  }

}

// File: contracts\token\ERC20\StandardToken.sol

pragma solidity ^0.5.11;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  using SafeMath for uint256;
 
  mapping (address => mapping (address => uint256)) allowed;
 
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) returns (bool) {

    require(_from != address(0), "StandardToken: transfer from the zero address");
    require(_to   != address(0), "StandardToken: transfer to the zero address");

    uint256 _allowance = allowed[_from][msg.sender];
 
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);
	if( balances[_to].exists != true )
	{
		accounts.push( _to );
		balances[_to].exists = true;
	}
    balances[_to].value = balances[_to].value.add(_value);
    balances[_from].value = balances[_from].value.sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
 
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    require(_spender != address(0), "StandardToken: approve to the zero address");
 
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
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
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}

// File: contracts\token\ERC20\BurnableToken.sol

pragma solidity ^0.5.11;


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
 
  using SafeMath for uint256;

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint _value) public {
    require(_value > 0);
	require( msg.sender != address(0), "Burnable: burn from the zero address" );
    address burner = msg.sender;
    balances[burner].value = balances[burner].value.sub(_value);
    _totalSupply = _totalSupply.sub(_value);
    emit Transfer(burner, address(0), _value);
  }

  function burn_from( address burner, uint _value) internal {
    require(_value > 0);
	require( burner != address(0), "Burnable: burn from the zero address" );
    balances[burner].value = balances[burner].value.sub(_value);
    _totalSupply = _totalSupply.sub(_value);
    emit Transfer( burner, address(0), _value );
  }
}

// File: contracts\token\Ownable.sol

pragma solidity ^0.5.11;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;
 
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor()  public {
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
  }
 
}

// File: contracts\utils\Address.sol

pragma solidity ^0.5.11;

/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     */
    function toPayable(address account) internal pure returns (address payable) {
															   
        return address(uint160(account));
    }
}

// File: contracts\EmbededCrowdsale.sol

/*
This file is part of the WellCoinCrowdsale Contract.
The WellCoinCrowdsale Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
The WellCoinCrowdsale Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.
You should have received a copy of the GNU lesser General Public License
along with the WellCoinCrowdsale Contract. If not, see <http://www.gnu.org/licenses/>.
*/
pragma solidity ^0.5.11;





contract EmbededCrowdsale is Ownable, TokenDeliverer {
    
    // counter to allow mutex lock with only one SSTORE operation
    uint256 internal _guardCounter;

    using SafeMath for uint256;
    

	uint256 public ether_coef;
    uint public    presale_start;
    uint public    presale_finish;
   
    uint public    presale_hardcap;
    uint256 public presale_rate;
    uint public    presale_softcap;

    uint public    sale_start;
    uint public    sale_finish;

    uint public    sale_hardcap;
    uint public    sale_softcap;
    
    uint256 public sale_rate;

    constructor() public {

	  _guardCounter = 1;

   	  ether_coef = 1000000000000000000 / 1 ether;
      presale_rate    = 1000 * ether_coef;

      presale_start   = 1567123200; /*30.08.2019 0:0:0.000*/ 
      presale_finish  = 1569888000; /*01.10.2019 0:0:0.000*/ 

      presale_hardcap = 50000 * 1000000000000000000;
      presale_softcap = 10000 * 1000000000000000000;

      sale_start      = 1569888000; /*01.10.2019 0:0:0.000*/ 
	  sale_finish     = 1576800000; /*20.12.2019 0:0:0.000*/ 

      sale_rate       = 200    * ether_coef;
      sale_hardcap    = 200000 * 1000000000000000000;
      sale_softcap    = 40000  * 1000000000000000000;

    }
    

    function fpreSaleIsOn() internal view returns (bool) {
	  return now > presale_start && now < presale_finish;
    }

    function fsaleIsOn() internal view returns (bool) {
	  return now > sale_start && now < sale_finish;
    }

    modifier saleIsOn() {
      require( (now > sale_start && now < sale_finish) || (now > presale_start && now < presale_finish), "Crowdsale: sales closed" );
      _;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */

  modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

/*

1567123200 30.08.2019
1568505600 15.09.2019 17 days
1569456000 26.09.2019 28 days

1569888000 01.10.2019 
1571529600 20.10.2019 20 days
1573257600 09.11.2019 39 days

5% for WLX 100 - WLX 499
10% for WLX 500 - WLX 999
20% for WLX 1,000 - WLX 9,999
50% for WLX 10,000 and above

*/


	function calc_tokens( uint256 amount ) internal returns (uint) {
      uint tokens = 0;
      uint earlyBonus = 0;
      uint salebonus = 0;

	  if( fpreSaleIsOn() )
	  {
		tokens = presale_rate.mul(msg.value);
	  	assert(tokens >= 40000000000000000000 );
        if(now < presale_start + (17 * 1 days)) {
        	earlyBonus = tokens;
      	} else if(now < presale_start + (28 * 1 days)) {
        	earlyBonus = tokens.div(2);
      	}
      	
	  }
	  else if( fsaleIsOn() )
	  {
		tokens = sale_rate.mul(msg.value);
		assert(tokens >= 10000000000000000000);
      	if(now < sale_start + (20 * 1 days)) {
        	earlyBonus = tokens.div(5);
      	} else if(now < sale_start + (39 * 1 days)) {
        	earlyBonus = tokens.div(10);
      	}
	  }

	  if( tokens >= 10000000000000000000000 ) // 10 000 wlx
	  {
		salebonus = tokens.div( 2 );
	  }
	  else if( tokens >=  1000000000000000000000 ) // 1 000 wlx
	  {
		salebonus = tokens.div( 5 );
	  }
	  else if( tokens >=   500000000000000000000 ) // 500 wlx
	  {
		salebonus = tokens.div( 10 );
	  }
	  else if( tokens >=        100000000000000000000 ) // 100 wlx
	  {
		salebonus = tokens.div( 20 );
	  }
	  
	  // 5% for WLX 100 - WLX 499
	  // 10% for WLX 500 - WLX 999
	  // 20% for WLX 1,000 - WLX 9,999
	  // 50% for WLX 10,000 and above

      tokens += earlyBonus;
      tokens += salebonus;

	  return tokens;
	}


	function createTokens() internal saleIsOn nonReentrant {
      uint tokens = calc_tokens( msg.value );
      Address.toPayable(owner).transfer(msg.value);
	  _delivery( msg.sender, tokens );
    }
 
    function() external payable {
	   createTokens();
    }

}

// File: contracts\WellCoin.sol

pragma solidity ^0.5.11;







contract WellCoin is BurnableToken, EmbededCrowdsale {

	using SafeMath for uint256;    

    string private constant _name = "WELLCoin";
    
    string private constant _symbol = "WLX";
    
    uint8 private constant _decimals = 18;


    address public team;
    address public bounty;
	address public refferals;
	address public marketing;

	address owner;

	uint256 public INITIAL_SUPPLY                   = 120000000 * 1 ether;
	uint256 public TEAM_ADVISORS_SUPPLY             =  12000000 * 1 ether;
	uint256 public BOUNTY_SUPPLY 	           	    =  10000000 * 1 ether;
	uint256 public MARKETING_AND_ADVERTISING_SUPPLY =   3000000 * 1 ether;
	uint256 public REFFERALS_SUPPLY                 =   5000000 * 1 ether;
	uint    public sales_off;

	address public sale_address;

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    
  
	constructor() public {
		owner = msg.sender;
		//!! sale_address  = a_sale_address;
		sale_address  = address(0);

    	_totalSupply = INITIAL_SUPPLY;
		_create_balance( INITIAL_SUPPLY );

    	team       = 0x7c6d125130B740EaE82c9e9d23075348B9016A1E;
    	bounty     = 0x70533B6086BD917355638D2822Db4BDf5c02A5bF;
		refferals  = 0xE8469C048cB0a3FF75417b7D80d631A8cf1120aa;
		marketing  = 0xE8469C048cB0a3FF75417b7D80d631A8cf1120aa;

		_delivery( team, TEAM_ADVISORS_SUPPLY );
		_delivery( bounty, BOUNTY_SUPPLY );
		_delivery( refferals, REFFERALS_SUPPLY );
		_delivery( marketing, MARKETING_AND_ADVERTISING_SUPPLY );

		sales_off =  1576800000; // 12.20.2019 00:00:00
  	}    

    function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}

  	function accountsLength() public view returns ( uint ) {
		return accounts.length;
  	}

  	function accountsOf(uint index) public  view returns ( address ) {
		return accounts[index];
  	}

    function delivery(address _to, uint256 _value) external payable returns (bool) {
		require( now < sales_off, "Wellcoin: sales off" );
		if( msg.sender == owner )
		{
    		return _delivery( _to, _value );
		}
		else
		{
    		require( sale_address != address(0) && sale_address == msg.sender, "WellCoin: delivery token from saller address");
    		return _delivery( _to, _value );
		}
	}


	function close() public onlyOwner {
		burn_from( address(this), balances[address(this)].value );
  	}

 // ------------------------------------------------------------------------
 // Owner can transfer out any accidentally sent ERC220 tokens
 // ------------------------------------------------------------------------

  	function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }


}