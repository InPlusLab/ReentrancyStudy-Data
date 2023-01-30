/**

 *Submitted for verification at Etherscan.io on 2018-11-22

*/



pragma solidity ^0.4.24;





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





/**

 * @title Controller

 * @dev The Controller contract has an owner address, and provides basic authorization and transfer control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Controller {

    

    address private _owner;

    bool private _paused;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event Paused(address account);

    event Unpaused(address account);

    

    mapping(address => bool) private owners;

    

    /**

    * @dev The Controller constructor sets the initial `owner` of the contract to the sender

    * account, and allows transfer by default.

    */

    constructor() internal {

        setOwner(msg.sender);

    }



    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyOwner() {

        require(owners[msg.sender]);

        _;

    }



    function setOwner(address addr) internal returns(bool) {

        if (!owners[addr]) {

          owners[addr] = true;

          _owner = addr;

          return true; 

        }

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param newOwner The address to transfer ownership to.

    */   

    function changeOwner(address newOwner) onlyOwner public returns(bool) {

        require (!owners[newOwner]);

          owners[newOwner];

          _owner = newOwner;

          emit OwnershipTransferred(_owner, newOwner);

          return; 

        }



    /**

    * @return the address of the owner.

    */

    function Owner() public view returns (address) {

        return _owner;

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

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is IERC20 {

  using SafeMath for uint256;



  mapping (address => uint256) private _balances;



  mapping (address => mapping (address => uint256)) private _allowed;



  uint256 private _totalSupply;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param owner The address to query the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param owner address The address which owns the funds.

   * @param spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

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

  * @dev Transfer token for a specified address

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function transfer(address to, uint256 value) public returns (bool) {

    _transfer(msg.sender, to, value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param spender The address which will spend the funds.

   * @param value The amount of tokens to be spent.

   */

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));



    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }



  /**

   * @dev Transfer tokens from one address to another

   * @param from address The address which you want to send tokens from

   * @param to address The address which you want to transfer to

   * @param value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address from,

    address to,

    uint256 value

  )

    public

    returns (bool)

  {

    require(value <= _allowed[from][msg.sender]);



    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    _transfer(from, to, value);

    return true;

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To increment

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

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].sub(subtractedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

  * @dev Transfer token for a specified addresses

  * @param from The address to transfer from.

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function _transfer(address from, address to, uint256 value) internal {

    require(value <= _balances[from]);

    require(to != address(0));



    _balances[from] = _balances[from].sub(value);

    _balances[to] = _balances[to].add(value);

    emit Transfer(from, to, value);

  }



  /**

   * @dev Internal function that mints an amount of the token and assigns it to

   * an account. This encapsulates the modification of balances such that the

   * proper events are emitted.

   * @param account The account that will receive the created tokens.

   * @param value The amount that will be created.

   */

  function _mint(address account, uint256 value) internal {

    require(account != 0);

    _totalSupply = _totalSupply.add(value);

    _balances[account] = _balances[account].add(value);

    emit Transfer(address(0), account, value);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burn(address account, uint256 value) internal {

    require(account != 0);

    require(value <= _balances[account]);



    _totalSupply = _totalSupply.sub(value);

    _balances[account] = _balances[account].sub(value);

    emit Transfer(account, address(0), value); 

  }

}





contract LobefyToken is ERC20, Controller {

    

    using SafeMath for uint256;

    

    string private _name = "Lobefy Token";

    string private _symbol = "CRWD";

    uint8 private _decimals = 18;

    

    address private team1 = 0xDA19316953D19f5f8C6361d68C6D0078c06285d3;

    address private team2 = 0x928bdD2F7b286Ff300b054ac0897464Ffe5455b2;

    address private team3 = 0x327d33e81988425B380B7f91C317961e3797Eedf;

    address private team4 = 0x4d76022f6df7D007119FDffc310984b1F1E30660;

    address private team5 = 0xA8534e7645003708B10316Dd5B6166b90649F4da;

    address private team6 = 0xfF3005C63FD5633c3bd5D3D4f34b0491D0a564E5;

    address private team7 = 0xb3FCDed4A67E56621F06dB5ff72bf8D93afeCb12;

    address private reserve = 0x6Fc693855Ef50fDf378Add1bf487dB12772F4c8f;

    

    uint256 private team1Balance = 50 * (10 ** 6) * (10 ** 18);

    uint256 private team2Balance = 50 * (10 ** 6) * (10 ** 18);

    uint256 private team3Balance = 25 * (10 ** 6) * (10 ** 18);

    uint256 private team4Balance = 15 * (10 ** 6) * (10 ** 18);

    uint256 private team5Balance = 25 * (10 ** 6) * (10 ** 18);

    uint256 private team6Balance = 25 * (10 ** 6) * (10 ** 18);

    uint256 private team7Balance = 25 * (10 ** 6) * (10 ** 18);

    uint256 private reserveBalance = 35 * (10 ** 6) * (10 ** 18);

    

    

    constructor() public {

        mint(team1,team1Balance);

        mint(team2,team2Balance);

        mint(team3,team3Balance);

        mint(team4,team4Balance);

        mint(team5,team5Balance);

        mint(team6,team6Balance);

        mint(team7,team7Balance);

        mint(reserve,reserveBalance);

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

    

    /**

    * @dev Function to mint tokens

    * @param to The address that will receive the minted tokens.

    * @param value The amount of tokens to mint.

    * @return A boolean that indicates if the operation was successful.

    */

    function mint(address to, uint256 value) public onlyOwner returns (bool) {

        _mint(to, value);

        return true;

    }



    /**

    * @dev ERC20 modified with pausable transfers.

    **/

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);

    }

    

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);

    }



    function increaseAllowance( address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);

    }



    function decreaseAllowance( address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);

    }

    

    /**

    * @dev Burns a specific amount of tokens.

    * @param value The amount of token to be burned.

    */

    function burn(uint256 value) public {

        _burn(msg.sender, value);

    }

}