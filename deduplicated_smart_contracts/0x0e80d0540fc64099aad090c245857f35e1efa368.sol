/**

 *Submitted for verification at Etherscan.io on 2018-11-21

*/



pragma solidity 0.4.25;



interface IERC20 {

	function balanceOf(address owner) external view returns (uint256 balance);

	function transfer(address to, uint256 value) external returns (bool success);

	function transferFrom(address from, address to, uint256 value) external returns (bool success);

	function approve(address spender, uint256 value) external returns (bool success);

	function allowance(address owner, address spender) external view returns (uint256 remaining);



	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);

	event Issuance(address indexed to, uint256 value);

}



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



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal burn function.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burnFrom(address account, uint256 value) internal {

    require(value <= _allowed[account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

      value);

    _burn(account, value);

  }

}



contract ERC20Burnable is ERC20 {



  /**

   * @dev Burns a specific amount of tokens.

   * @param value The amount of token to be burned.

   */

  function burn(uint256 value) public {

    _burn(msg.sender, value);

  }



  /**

   * @dev Burns a specific amount of tokens from the target address and decrements allowance

   * @param from address The address which you want to send tokens from

   * @param value uint256 The amount of token to be burned

   */

  function burnFrom(address from, uint256 value) public {

    _burnFrom(from, value);

  }

}



interface IOldManager {

    function released(address investor) external view returns (uint256);

}



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



contract Owned {



	address public owner = msg.sender;

	address public potentialOwner;



	modifier onlyOwner {

		require(msg.sender == owner);

		_;

	}



	modifier onlyPotentialOwner {

		require(msg.sender == potentialOwner);

		_;

	}



	event NewOwner(address old, address current);

	event NewPotentialOwner(address old, address potential);



	function setOwner(address _new)

		public

		onlyOwner

	{

		emit NewPotentialOwner(owner, _new);

		potentialOwner = _new;

	}



	function confirmOwnership()

		public

		onlyPotentialOwner

	{

		emit NewOwner(owner, potentialOwner);

		owner = potentialOwner;

		potentialOwner = address(0);

	}

}



contract Manager is Owned {

    using SafeMath for uint256;



    event InvestorVerified(address investor);

    event VerificationRevoked(address investor);



    mapping (address => bool) public verified_investors;

    mapping (address => uint256) public released;



    IOldManager public old_manager;

    ERC20Burnable public old_token;

    IERC20 public presale_token;

    IERC20 public new_token;



    modifier onlyVerifiedInvestor {

        require(verified_investors[msg.sender]);

        _;

    }



    constructor(IOldManager _old_manager, ERC20Burnable _old_token, IERC20 _presale_token, IERC20 _new_token) public {

        old_manager = _old_manager;

        old_token = _old_token;

        presale_token = _presale_token;

        new_token = _new_token;

    }



    function updateVerificationStatus(address investor, bool is_verified) public onlyOwner {

        require(verified_investors[investor] != is_verified);



        verified_investors[investor] = is_verified;

        if (is_verified) emit InvestorVerified(investor);

        if (!is_verified) emit VerificationRevoked(investor);

    }



    function migrate() public onlyVerifiedInvestor {

        uint256 tokens_to_transfer = old_token.allowance(msg.sender, address(this));

        require(tokens_to_transfer > 0);

        require(old_token.transferFrom(msg.sender, address(this), tokens_to_transfer));

        old_token.burn(tokens_to_transfer);

        _transferTokens(msg.sender, tokens_to_transfer);

    }



    function release() public onlyVerifiedInvestor {

        uint256 presale_tokens = presale_token.balanceOf(msg.sender);

        uint256 tokens_to_release = presale_tokens - totalReleased(msg.sender);

        require(tokens_to_release > 0);

        _transferTokens(msg.sender, tokens_to_release);

        released[msg.sender] = tokens_to_release;

    }



    function totalReleased(address investor) public view returns (uint256) {

        return released[investor] + old_manager.released(investor);

    }



    function _transferTokens(address recipient, uint256 amount) internal {

        uint256 initial_balance = new_token.balanceOf(recipient);

        require(new_token.transfer(recipient, amount));

        assert(new_token.balanceOf(recipient) == initial_balance + amount);

    }

}