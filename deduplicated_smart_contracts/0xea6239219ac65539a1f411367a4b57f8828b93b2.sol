/**

 *Submitted for verification at Etherscan.io on 2018-11-06

*/



//File: node_modules\openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.4.24;



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



//File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

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



//File: node_modules\openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

pragma solidity ^0.4.24;









/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {



  using SafeMath for uint256;



  function safeTransfer(

    IERC20 token,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(

    IERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    // safeApprove should only be called when setting an initial allowance, 

    // or when resetting it to zero. To increase and decrease it, use 

    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

    require((value == 0) || (token.allowance(msg.sender, spender) == 0));

    require(token.approve(spender, value));

  }



  function safeIncreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).add(value);

    require(token.approve(spender, newAllowance));

  }



  function safeDecreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value);

    require(token.approve(spender, newAllowance));

  }

}



//File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol

pragma solidity ^0.4.24;









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



//File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.4.24;



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



//File: contracts\RKRToken.sol

/**

 * @title RKR token

 *

 * @version 1.0

 * @author Rockerchain

 */

pragma solidity ^0.4.21;













contract RKRToken is ERC20, Ownable {

    using SafeMath for uint256;

    

    string public constant name = "RKRToken";

    string public constant symbol = "RKR";

    uint8 public constant decimals = 18;

    uint256 public constant UNLOCKED_SUPPLY = 36e6 * 1e18;

    uint256 public constant TEAM_SUPPLY = 10e6 * 1e18;

    uint256 public constant ADVISOR_SUPPLY = 10e6 * 1e18;

    uint256 public constant RESERVED_SUPPLY = 44e6 * 1e18;

    bool public ADVISOR_SUPPLY_INITIALIZED;

    bool public TEAM_SUPPLY_INITIALIZED;

    bool public RESERVED_SUPPLY_INITIALIZED;



     /**

     * @dev Constructor of RKRToken 

     */

    constructor() public {

        _mint(msg.sender, UNLOCKED_SUPPLY);

        ADVISOR_SUPPLY_INITIALIZED = false;

        TEAM_SUPPLY_INITIALIZED = false;

        RESERVED_SUPPLY_INITIALIZED = false;

    }



     /**

     * @dev Mints and initialize Advisor reserve 

     */

    function initializeAdvisorVault(address advisorVault) public onlyOwner {

        require(ADVISOR_SUPPLY_INITIALIZED == false);

        ADVISOR_SUPPLY_INITIALIZED = true;

        _mint(advisorVault, ADVISOR_SUPPLY);

    }



     /**

     * @dev Mints and initialize Team reserve 

     */

    function initializeTeamVault(address teamVault) public onlyOwner {

        require(TEAM_SUPPLY_INITIALIZED == false);

        TEAM_SUPPLY_INITIALIZED = true;

        _mint(teamVault, TEAM_SUPPLY);

    }



     /**

     * @dev Mints and initialize Reserved reserve 

     */

    function initializeReservedVault(address reservedVault) public onlyOwner {

        require(RESERVED_SUPPLY_INITIALIZED == false);

        RESERVED_SUPPLY_INITIALIZED = true;

        _mint(reservedVault, RESERVED_SUPPLY);

    }



}









//File: contracts\ReservedVault.sol

/**

 * @title RKR ReservedVault Vault

 *

 * @version 1.0

 * @author Rockerchain

 */

pragma solidity ^0.4.21;













contract ReservedVault {

    using SafeMath for uint256;

    using SafeERC20 for RKRToken;



    uint256[5] public vesting_offsets = [

        90 days,

        180 days,

        270 days,

        360 days,

        450 days

    ];



    uint256[5] public vesting_amounts = [

        8.8e6 * 1e18,

        8.8e6 * 1e18,

        8.8e6 * 1e18,

        8.8e6 * 1e18,

        8.8e6 * 1e18

    ];



    address public reservedWallet;

    RKRToken public token;

    uint256 public start;

    uint256 public released;



    /**

     * @dev Constructor.

     * @param _reservedWallet The address that will receive the vested tokens.

     * @param _token The RKR Token, which is being vested.

     */

    constructor(

        address _reservedWallet,

        address _token

    )

        public

    {

        reservedWallet = _reservedWallet;

        token = RKRToken(_token);

        start = block.timestamp;

    }



    /**

     * @dev Transfers vested tokens to Reserved Wallet.

     */

    function release() public {

        uint256 unreleased = releasableAmount();

        require(unreleased > 0);



        released = released.add(unreleased);



        token.safeTransfer(reservedWallet, unreleased);

    }



    /**

     * @dev Calculates the amount that has already vested but hasn't been released yet.

     */

    function releasableAmount() public view returns (uint256) {

        return vestedAmount().sub(released);

    }



    /**

     * @dev Calculates the amount that has already vested.

     */

    function vestedAmount() public view returns (uint256) {

        uint256 vested = 0;

        for (uint256 i = 0; i < vesting_offsets.length; i = i.add(1)) {

            if (block.timestamp > start.add(vesting_offsets[i])) {

                vested = vested.add(vesting_amounts[i]);

            }

        }

        return vested;

    }

    

    /**

     * @dev Calculates the amount that has not yet released.

     */

    function unreleasedAmount() public view returns (uint256) {

        uint256 unreleased = 0;

        for (uint256 i = 0; i < vesting_offsets.length; i = i.add(1)) {

            unreleased = unreleased.add(vesting_amounts[i]);

        }

        return unreleased.sub(released);

    }

}