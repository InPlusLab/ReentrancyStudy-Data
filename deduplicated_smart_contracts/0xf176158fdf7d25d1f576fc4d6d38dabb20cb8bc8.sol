/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

pragma solidity ^0.4.25;


library SafeMath {
  // caculate for uint256
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

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
      return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
      return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
      return a < b ? a : b;
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   * 
   * why not user constructor?
   * change function Owner() to constructor() 
   * 
   * 0.4.22 constructor
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   * 
   * which means that the function extends onlyOwner is called must by the owner 
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * 
   * @param newOwner The address to transfer ownership to.
   * 
   * Strangely, the owner and the new owner are the same person here
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }

}

contract ERC20Interface {
  // METHODS

  // NOTE:
  //   public getter functions are not currently recognised as an
  //   implementation of the matching abstract function by the compiler.

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#name
  // function name() public view returns (string);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#symbol
  // function symbol() public view returns (string);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#totalsupply
  // function decimals() public view returns (uint8);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#totalsupply
  function totalSupply() public view returns (uint256);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#balanceof
  function balanceOf(address _owner) public view returns (uint256 balance);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transfer
  function transfer(address _to, uint256 _value) public returns (bool success);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transferfrom
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
  function approve(address _spender, uint256 _value) public returns (bool success);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#allowance
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  // EVENTS
  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transfer-1
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approval
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20Interface {
    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    
    /**
    * @dev Get the totalSupply of the contract
    * @return An uint256 representing the amount of token supplied
    */
    function totalSupply() public view returns(uint256) {
        return totalSupply;
    }
    
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner address The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
    * @dev Transfer token for a specified address.
    * @param _to address The address to transfer to.
    * @param _value uint256 The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another.
    * @param _from address The address which you want to send tokens from.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 the amout of tokens to be transfered.
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender address The address which will spend the funds.
    * @param _value uint256 The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
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
    * @return A uint256 specifing the amount of tokens still avaible for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    

}


contract CreateToken is StandardToken, Ownable {
    using SafeMath for uint256;
    
    /// @dev Reverts if address is 0x0 or this token address
    modifier validRecipient(address _recipient) {
        require(_recipient != address(0) && _recipient != address(this));
        _;
    }
    
    constructor(
        string _name,
        string _symbol,
        uint256 _decimals,
        uint256 _totalSupply
        ) public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10 ** _decimals);
        balances[msg.sender] = totalSupply;
    }
    
    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender address The address which will spend the funds.
    * @param _value uint256 The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value)
        public
        validRecipient(_spender)
        returns (bool)
    {
        return super.approve(_spender, _value);
    }
    
    /**
    * @dev Transfer token for a specified address.
    * @param _to address The address to transfer to.
    * @param _value uint256 The amount to be transferred.
    */
    function transfer(address _to, uint256 _value)
        public
        validRecipient(_to)
        returns (bool)
    {
        return super.transfer(_to, _value);
    }
    
    /**
    * @dev Transfer tokens from one address to another.
    * @param _from address The address which you want to send tokens from.
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered. 
    */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validRecipient(_to)
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }
    
}