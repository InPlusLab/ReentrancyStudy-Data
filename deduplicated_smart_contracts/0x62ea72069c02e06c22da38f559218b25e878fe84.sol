pragma solidity ^0.4.11;
	/**
		* @title SafeMath
		* @dev Math operations with safety checks that throw on error
	*/
library SafeMath {
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }}
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
    }  }
}
	/**
		* @title ERC20Basic
		* @dev Simpler version of ERC20 interface
		* @dev see https://github.com/ethereum/EIPs/issues/179
	*/
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}
	/**
		* @title ERC20 interface
		* @dev see https://github.com/ethereum/EIPs/issues/20
	*/
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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
		* @param _value uint256 the amout of tokens to be transfered
	*/
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
	/**
		* @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
		* @param _spender The address which will spend the funds.
		* @param _value The amount of tokens to be spent.
	*/
  function approve(address _spender, uint256 _value) returns (bool) {
	/**
		* To change the approve amount you first have to reduce the addresses`
		* allowance to zero by calling `approve(_spender, 0)` if it is not
		* already 0 to mitigate the race condition described here:
		* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	*/
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
	/**
		* @dev Function to check the amount of tokens that an owner allowed to a spender.
		* @param _owner address The address which owns the funds.
		* @param _spender address The address which will spend the funds.
		* @return A uint256 specifing the amount of tokens still avaible for the spender.
	*/
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
contract BIONEUM is StandardToken, Ownable {
    using SafeMath for uint256;
    // Token Info.
    string  public constant name = "BIONEUM";
    string  public constant symbol = "BIO";
    uint256 public constant decimals = 8;
    uint256 public constant totalSupply = decVal(50000000);
	
    // Address where funds are collected.
    address public multisig = 0xFC8b6add05Dd6b5fd91F6559EFF84A20201fD86c;
    // Developer tokens.
	address public developers = 0x8D9acc27005419E0a260B44d060F7427Cd9739B2;
    // Founder tokens.
	address public founders = 0xB679919c63799c39d074EEad650889B24C06fdC6;
    // Bounty tokens.
	address public bounty = 0xCF2F450FB7d265fF82D0c2f1737d9f0258ae40A3;
	// Address of this contract/token
    address public constant tokenAddress = this;
    // Sale period.
    uint256 public startDate;
    uint256 public endDate;
    // Amount of raised money in wei.
    uint256 public weiRaised;
    // Amount of raised money in ether.
    uint256 public etherRaised;
    // Number of tokens sold.
	uint256 public tokensSold;
    // Modifiers.
    modifier uninitialized() {
        require(multisig == 0x0);
        _;
    }    
	function BIONEUM() {
        startDate = now.add(5 hours);
        endDate = startDate.add(30 days);
		
        balances[founders] 	= decVal(5000000);
        Transfer(0x0, founders	, balances[founders]);
		
        balances[bounty] 	= decVal(1000000);
        Transfer(0x0, bounty	, balances[bounty]);
		
        balances[developers] = decVal(4000000);
        Transfer(0x0, developers	, balances[developers]);
		
		balances[this] = totalSupply.sub(balances[developers].add(balances[founders]).add(balances[bounty]));
        Transfer(0x0, this		, balances[this]);
    }
    function supply() internal returns (uint256) {
        return balances[this];
    }
    function getRateAt(uint256 at) constant returns (uint256) {
        if (at < startDate) {
            return 0;
        } else if (at < startDate.add(7 days)) {
            return decVal(130);
        } else if (at < startDate.add(14 days)) {
            return decVal(115);
        } else if (at < startDate.add(21 days)) {
            return decVal(105);
        } else if (at < startDate.add(28 days) || at <= endDate) {
            return decVal(100);
        } else {
            return 0;
        }    
	}
	function decVal(uint256 amount) internal returns(uint256){
		return amount * 10 ** uint256(decimals);
	}
    // Fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender, msg.value);
    }
    function buyTokens(address sender, uint256 value) internal {
        require(saleActive());
        require(value >= 0.01 ether);

        uint256 weiAmount = value;
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);

        // Calculate token amount to be purchased
        uint256 actualRate = getRateAt(now);
        uint256 amount = weiAmount.mul(actualRate).div(1 ether);

        // We have enough token to sell
        require(supply() >= amount);

        // Transfer tokens
        balances[this] = balances[this].sub(amount);
        balances[sender] = balances[sender].add(amount);
		Transfer(0x0, sender, amount);
        // Update state.
        weiRaised = updatedWeiRaised;
		etherRaised = weiRaised.div(1 ether);
		tokensSold = tokensSold.add(amount);
		
        // Forward the fund to fund collection wallet.
        multisig.transfer(msg.value);
    }
    function finalize() onlyOwner {
        require(!saleActive());
        // Transfer the rest of token to Bioneum
        balances[owner] = balances[owner].add(balances[this]);
		Transfer(0x0, owner, balances[this]);
        balances[this] = 0;
    }
    function saleActive() public constant returns (bool) {
        return (now >= startDate && now < endDate && supply() > 0);
    }
}