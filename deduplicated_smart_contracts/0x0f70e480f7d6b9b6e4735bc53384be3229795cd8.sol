/**

 *Submitted for verification at Etherscan.io on 2018-11-11

*/



/* FOOToken                             */

/* Released on 11.11.2018 v.1.0         */

/* To celebrate 100 years of Polish     */

/* INDEPENDENCE                         */   

/* ==================================== */

/* National Independence Day  is a      */

/* national day in Poland celebrated on */ 

/* 11 November to commemorate the       */

/* anniversary of the restoration of    */

/* Poland's sovereignty as the          */

/* Second Polish Republic in 1918 from  */

/* German, Austrian and Russian Empires */

/* Following the partitions in the late */

/* 18th century, Poland ceased to exist */

/* for 123 years until the end of       */

/* World War I, when the destruction of */

/* the neighbouring powers allowed the  */

/* country to reemerge.                 */



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

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



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



contract ERC223Interface {

    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value)  public ;

    function transfer(address to, uint value, bytes data)  public ;

    event Transfer(address indexed from, address indexed to, uint value, bytes data);

}



/**

 * @title Contract that will work with ERC223 tokens.

 */

 

contract ERC223ReceivingContract { 

/**

 * @dev Standard ERC223 function that will handle incoming token transfers.

 *

 * @param _from  Token sender address.

 * @param _value Amount of tokens.

 * @param _data  Transaction metadata.

 */

    function tokenFallback(address _from, uint _value, bytes _data) public;

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Paused(address account);

  event Unpaused(address account);



  bool private _paused;



  constructor() internal {

    _paused = false;

  }



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns(bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyOwner whenNotPaused {

    _paused = true;

    emit Paused(msg.sender);

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    _paused = false;

    emit Unpaused(msg.sender);

  }

}





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

  function totalSupply() external view returns (uint256);



  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender)

    external view returns (uint256);



  function transfer(address to, uint256 value) external returns (bool);



  function approve(address spender, uint256 value)

    external returns (bool);



  function transferFrom(address from, address to, uint256 value)

    external returns (bool);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



/**

 * @title Reference implementation of the ERC223 standard token.

 */

contract FOOToken is IERC20, ERC223Interface, Ownable, Pausable {

    using SafeMath for uint;

    

    mapping(address => uint) balances; // List of user balances.

    

    mapping (address => mapping (address => uint256)) private _allowed;

    

    modifier validDestination( address to ) {

      require(to != address(0x0));

      _;

    }

    

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    uint256 private _totalSupply;

    

 constructor() public {

      _name = "FOOToken";

      _symbol = "FOOT";

      _decimals = 18;

      _mint(msg.sender, 100000000 * (10 ** 18));

    }



    /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  /**

   * @return the name of the token.

   */

    function name() public view returns(string) {

      return _name;

    }



  /**

   * @return the symbol of the token.

   */

    function symbol() public view returns(string) {

      return _symbol;

    }



  /**

   * @return the number of decimals of the token.

   */

    function decimals() public view returns(uint8) {

      return _decimals;

    }

    

    function allowance(

    address owner,

    address spender

   )

    public

    view

    returns (uint256)

  {

    return _allowed[owner][spender];

  }

  

  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param addedValue The amount of tokens to increase the allowance by.

   */

   function increaseAllowance(

    address spender,

    uint256 addedValue

  )

    public

    whenNotPaused

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].add(addedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseAllowance(

    address spender,

    uint256 subtractedValue

  )

    public

    whenNotPaused

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].sub(subtractedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  

   function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

    require(spender != address(0));



    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }

  

  

  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    validDestination(_to) 

    public

    whenNotPaused

    returns (bool)

  {

    require(_value <= balances[_from]);

    require(_value <= _allowed[_from][msg.sender]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);



    

    uint codeLength;

    bytes memory empty;

    assembly {

      // Retrieve the size of the code on target address, this needs assembly .

      codeLength := extcodesize(_to)

    }

    if(codeLength>0) {

      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

      receiver.tokenFallback(_from, _value, empty);

    }

    



    return true;

  }



  

    /**

     * @dev Transfer the specified amount of tokens to the specified address.

     *      Invokes the `tokenFallback` function if the recipient is a contract.

     *      The token transfer fails if the recipient is a contract

     *      but does not implement the `tokenFallback` function

     *      or the fallback function to receive funds.

     *

     * @param _to    Receiver address.

     * @param _value Amount of tokens that will be transferred.

     * @param _data  Transaction metadata.

     */

    function transfer(address _to, uint _value, bytes _data)  whenNotPaused validDestination(_to) public {

        // Standard function transfer similar to ERC20 transfer with no _data .

        // Added due to backwards compatibility reasons .

        uint codeLength;



        assembly {

            // Retrieve the size of the code on target address, this needs assembly .

            codeLength := extcodesize(_to)

        }



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        if(codeLength>0) {

            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

            receiver.tokenFallback(msg.sender, _value, _data);

        }

        emit Transfer(msg.sender, _to, _value, _data);

    }

    

    

    

    /**

   * @dev Internal function that mints an amount of the token and assigns it to

   * an account. This encapsulates the modification of balances such that the

   * proper events are emitted.

   * @param _account The account that will receive the created tokens.

   * @param _amount The amount that will be created.

   */

  function _mint(address _account, uint256 _amount) internal {

    require(_account != 0);

    _totalSupply = _totalSupply.add(_amount);

    balances[_account] = balances[_account].add(_amount);

    emit Transfer(address(0), _account, _amount);



    

    uint codeLength;

    bytes memory empty;

    assembly {

      // Retrieve the size of the code on target address, this needs assembly .

      codeLength := extcodesize(_account)

    }

    if(codeLength>0) {

      ERC223ReceivingContract receiver = ERC223ReceivingContract(_account);

      receiver.tokenFallback(address(0), _amount, empty);

    }

    

  }



  

    /**

     * @dev Transfer the specified amount of tokens to the specified address.

     *      This function works the same with the previous one

     *      but doesn't contain `_data` param.

     *      Added due to backwards compatibility reasons.

     *

     * @param _to    Receiver address.

     * @param _value Amount of tokens that will be transferred.

     */

    function transfer(address _to, uint _value) whenNotPaused validDestination(_to) public {

        uint codeLength;

        bytes memory empty;



        assembly {

            // Retrieve the size of the code on target address, this needs assembly .

            codeLength := extcodesize(_to)

        }



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        if(codeLength>0) {

            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

            receiver.tokenFallback(msg.sender, _value, empty);

        }

        emit Transfer(msg.sender, _to, _value, empty);

    }



    

    /**

     * @dev Returns balance of the `_owner`.

     *

     * @param _owner   The address whose balance will be returned.

     * @return balance Balance of the `_owner`.

     */

    function balanceOf(address _owner) public view returns (uint balance) {

        return balances[_owner];

    }

    // Don't accept direct payments

  

  function() public payable {

    revert();

  }

  

  struct TKN {

        address sender;

        uint value;

        bytes data;

        bytes4 sig;

    }



    function tokenFallback(address _from, uint _value, bytes _data) pure public {

      TKN memory tkn;

      tkn.sender = _from;

      tkn.value = _value;

      tkn.data = _data;

      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);

      tkn.sig = bytes4(u);



      /* tkn variable is analogue of msg variable of Ether transaction

      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)

      *  tkn.value the number of tokens that were sent   (analogue of msg.value)

      *  tkn.data is data of token transaction   (analogue of msg.data)

      *  tkn.sig is 4 bytes signature of function

      *  if data of token transaction is a function execution

      */

    }

    

}