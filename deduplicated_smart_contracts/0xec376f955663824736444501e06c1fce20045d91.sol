/**

 *Submitted for verification at Etherscan.io on 2018-11-14

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

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

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



// File: openzeppelin-solidity/contracts/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.

  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056

  uint private constant REENTRANCY_GUARD_FREE = 1;



  /// @dev Constant for locked guard state

  uint private constant REENTRANCY_GUARD_LOCKED = 2;



  /**

   * @dev We use a single lock for the whole contract.

   */

  uint private reentrancyLock = REENTRANCY_GUARD_FREE;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one `nonReentrant` function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and an `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(reentrancyLock == REENTRANCY_GUARD_FREE);

    reentrancyLock = REENTRANCY_GUARD_LOCKED;

    _;

    reentrancyLock = REENTRANCY_GUARD_FREE;

  }



}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/access/rbac/Roles.sol



/**

 * @title Roles

 * @author Francisco Giordano (@frangio)

 * @dev Library for managing addresses assigned to a Role.

 * See RBAC.sol for example usage.

 */

library Roles {

  struct Role {

    mapping (address => bool) bearer;

  }



  /**

   * @dev give an address access to this role

   */

  function add(Role storage _role, address _addr)

    internal

  {

    _role.bearer[_addr] = true;

  }



  /**

   * @dev remove an address' access to this role

   */

  function remove(Role storage _role, address _addr)

    internal

  {

    _role.bearer[_addr] = false;

  }



  /**

   * @dev check if an address has this role

   * // reverts

   */

  function check(Role storage _role, address _addr)

    internal

    view

  {

    require(has(_role, _addr));

  }



  /**

   * @dev check if an address has this role

   * @return bool

   */

  function has(Role storage _role, address _addr)

    internal

    view

    returns (bool)

  {

    return _role.bearer[_addr];

  }

}



// File: openzeppelin-solidity/contracts/access/rbac/RBAC.sol



/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 * Supports unlimited numbers of roles and addresses.

 * See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 * for you to write your own implementation of this interface using Enums or similar.

 */

contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address indexed operator, string role);

  event RoleRemoved(address indexed operator, string role);



  /**

   * @dev reverts if addr does not have role

   * @param _operator address

   * @param _role the name of the role

   * // reverts

   */

  function checkRole(address _operator, string _role)

    public

    view

  {

    roles[_role].check(_operator);

  }



  /**

   * @dev determine if addr has role

   * @param _operator address

   * @param _role the name of the role

   * @return bool

   */

  function hasRole(address _operator, string _role)

    public

    view

    returns (bool)

  {

    return roles[_role].has(_operator);

  }



  /**

   * @dev add a role to an address

   * @param _operator address

   * @param _role the name of the role

   */

  function addRole(address _operator, string _role)

    internal

  {

    roles[_role].add(_operator);

    emit RoleAdded(_operator, _role);

  }



  /**

   * @dev remove a role from an address

   * @param _operator address

   * @param _role the name of the role

   */

  function removeRole(address _operator, string _role)

    internal

  {

    roles[_role].remove(_operator);

    emit RoleRemoved(_operator, _role);

  }



  /**

   * @dev modifier to scope access to a single role (uses msg.sender as addr)

   * @param _role the name of the role

   * // reverts

   */

  modifier onlyRole(string _role)

  {

    checkRole(msg.sender, _role);

    _;

  }



  /**

   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)

   * @param _roles the names of the roles to scope access to

   * // reverts

   *

   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this

   *  see: https://github.com/ethereum/solidity/issues/2467

   */

  // modifier onlyRoles(string[] _roles) {

  //     bool hasAnyRole = false;

  //     for (uint8 i = 0; i < _roles.length; i++) {

  //         if (hasRole(msg.sender, _roles[i])) {

  //             hasAnyRole = true;

  //             break;

  //         }

  //     }



  //     require(hasAnyRole);



  //     _;

  // }

}



// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol



/**

 * @title DetailedERC20 token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract DetailedERC20 is ERC20 {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }

}



// File: contracts/token/WToken.sol



contract WToken is DetailedERC20, Ownable {

    using SafeMath for uint256;



    mapping (address => mapping (address => uint256)) internal allowed;



    mapping(address => uint256) public balances;



    uint256 private _totalSupply;



    mapping (address => mapping (uint256 => uint256)) public vestingBalanceOf;



    mapping (address => uint[]) vestingTimes;



    mapping (address => bool) trustedAccounts;



    event VestingTransfer(address from, address to, uint256 value, uint256 agingTime);

    event Burn(address indexed burner, uint256 value);



    /**

    * @dev total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    constructor(string _name, string _symbol, uint8 _decimals) DetailedERC20(_name, _symbol, _decimals) public {

        trustedAccounts[msg.sender] = true;

    }



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) public returns (bool) {

        _checkMyVesting(msg.sender);

        require(_to != address(0));

        require(_value <= accountBalance(msg.sender));



        balances[msg.sender] = balances[msg.sender].sub(_value);



        balances[_to] = balances[_to].add(_value);



        emit Transfer(msg.sender, _to, _value);



        return true;

    }



    function vestingTransfer(address _to, uint256 _value, uint32 _vestingTime) external onlyTrusted(msg.sender) returns (bool) {

        transfer(_to, _value);



        if (_vestingTime > now) {

            _addToVesting(address(0), _to, _vestingTime, _value);

        }



        emit VestingTransfer(msg.sender, _to, _value, _vestingTime);



        return true;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    /**

    * @dev Transfer tokens from one address to another

    * @param _from address The address which you want to send tokens from

    * @param _to address The address which you want to transfer to

    * @param _value uint256 the amount of tokens to be transferred

    */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        _checkMyVesting(_from);



        require(_to != address(0));

        require(_value <= accountBalance(_from));

        require(_value <= allowed[_from][msg.sender]);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);



        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

    *

    * Beware that changing an allowance with this method brings the risk that someone may use both the old

    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    * @param _spender The address which will spend the funds.

    * @param _value The amount of tokens to be spent.

    */

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);



        return true;

    }



    /**

    * @dev Function to check the amount of tokens that an owner allowed to a spender.

    * @param _owner address The address which owns the funds.

    * @param _spender address The address which will spend the funds.

    * @return A uint256 specifying the amount of tokens still available for the spender.

    */

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];

    }



    /**

    * @dev Increase the amount of tokens that an owner allowed to a spender.

    *

    * approve should be called when allowed[_spender] == 0. To increment

    * allowed value is better to use this function to avoid 2 calls (and wait until

    * the first transaction is mined)

    * From MonolithDAO Token.sol

    * @param _spender The address which will spend the funds.

    * @param _addedValue The amount of tokens to increase the allowance by.

    */

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);



        return true;

    }



    /**

    * @dev Decrease the amount of tokens that an owner allowed to a spender.

    *

    * approve should be called when allowed[_spender] == 0. To decrement

    * allowed value is better to use this function to avoid 2 calls (and wait until

    * the first transaction is mined)

    * From MonolithDAO Token.sol

    * @param _spender The address which will spend the funds.

    * @param _subtractedValue The amount of tokens to decrease the allowance by.

    */

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue >= oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);



        return true;

    }



    function mint(address _to, uint _amount, uint32 _vestingTime) external onlyTrusted(msg.sender) returns (bool) {

        balances[_to] = balances[_to].add(_amount);

        _totalSupply = _totalSupply.add(_amount);



        if (_vestingTime > now) {

            _addToVesting(address(0), _to, _vestingTime, _amount);

        }



        emit Transfer(address(0), _to, _amount);

        emit VestingTransfer(address(0), _to, _amount, _vestingTime);



        return true;

    }



    function _addToVesting(address _from, address _to, uint256 _vestingTime, uint256 _amount) internal {

        vestingBalanceOf[_to][0] = vestingBalanceOf[_to][0].add(_amount);



        if(vestingBalanceOf[_to][_vestingTime] == 0)

            vestingTimes[_to].push(_vestingTime);



        vestingBalanceOf[_to][_vestingTime] = vestingBalanceOf[_to][_vestingTime].add(_amount);

    }



    /**

      * @dev Burns a specific amount of tokens.

      * @param _value The amount of token to be burned.

      */

    function burn(uint256 _value) public {

        _burn(msg.sender, _value);

    }



    /**

     * @dev Burns a specific amount of tokens from the target address and decrements allowance

     * @param _from address The address which you want to send tokens from

     * @param _value uint256 The amount of token to be burned

     */

    function burnFrom(address _from, uint256 _value) public {

        require(_value <= allowed[_from][msg.sender]);

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

        // this function needs to emit an event with the updated approval.

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        _burn(_from, _value);

    }



    function _burn(address _who, uint256 _value) internal {

        _checkMyVesting(_who);



        require(_value <= accountBalance(_who));

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        balances[_who] = balances[_who].sub(_value);

        _totalSupply = _totalSupply.sub(_value);

        emit Burn(_who, _value);

        emit Transfer(_who, address(0), _value);

    }



    function _checkMyVesting(address _from) internal {

        if (vestingBalanceOf[_from][0] == 0) return;



        for (uint256 k = 0; k < vestingTimes[_from].length; k++) {

            if (vestingTimes[_from][k] < now) {

                vestingBalanceOf[_from][0] = vestingBalanceOf[_from][0]

                    .sub(vestingBalanceOf[_from][vestingTimes[_from][k]]);

                vestingBalanceOf[_from][vestingTimes[_from][k]] = 0;

            }

        }

    }



    function accountBalance(address _address) public view returns (uint256 balance) {

        balance = balances[_address];



        if (vestingBalanceOf[_address][0] == 0) return;



        for (uint256 k = 0; k < vestingTimes[_address].length; k++) {

            if (vestingTimes[_address][k] >= now) {

                balance = balance.sub(vestingBalanceOf[_address][vestingTimes[_address][k]]);

            }

        }

    }



    function addTrustedAccount(address caller) external onlyOwner {

        trustedAccounts[caller] = true;

    }



    function removeTrustedAccount(address caller) external onlyOwner {

        trustedAccounts[caller] = false;

    }



    modifier onlyTrusted(address caller) {

        require(trustedAccounts[caller]);

        _;

    }

}



// File: contracts/interfaces/IW12Crowdsale.sol



interface IW12Crowdsale {

    function setParameters(uint price) external;



    // TODO: this should be external

    // See https://github.com/ethereum/solidity/issues/4832

    function setup(

        uint[6][] parametersOfStages,

        uint[] bonusConditionsOfStages,

        uint[4][] parametersOfMilestones,

        uint32[] nameAndDescriptionsOffsetOfMilestones,

        bytes nameAndDescriptionsOfMilestones

    ) external;



    function getWToken() external view returns(WToken);



    function getMilestone(uint index) external view returns (uint32, uint, uint32, uint32, bytes, bytes);



    function getStage(uint index) external view returns (uint32, uint32, uint, uint32, uint[], uint[]);



    function getCurrentMilestoneIndex() external view returns (uint, bool);



    function getLastMilestoneIndex() external view returns (uint index, bool found);



    function milestonesLength() external view returns (uint);



    function getCurrentStageIndex() external view returns (uint index, bool found);



    function getSaleVolumeBonus(uint value) external view returns (uint bonus);



    function isEnded() external view returns (bool);



    function isSaleActive() external view returns (bool);



    function () payable external;



    function buyTokens() payable external;



    function transferOwnership(address newOwner) external;

}



// File: contracts/interfaces/IW12CrowdsaleFactory.sol



interface IW12CrowdsaleFactory {

    function createCrowdsale(

        address tokenAddress,

        address _wTokenAddress,

        uint price,

        address serviceWallet,

        uint serviceFee,

        uint WTokenSaleFeePercent,

        uint trancheFeePercent ,

        address swap,

        address owner

    )

        external returns (IW12Crowdsale);

}



// File: contracts/libs/Percent.sol



library Percent {

    using SafeMath for uint;



    function ADD_EXP() public pure returns (uint) { return 2; }

    function EXP() public pure returns (uint) { return 2 + ADD_EXP(); }

    function MIN() public pure returns (uint) { return 0; }

    function MAX() public pure returns (uint) { return 10 ** EXP(); }



    function percent(uint _a, uint _b) internal pure returns (uint) {

        require(isPercent(_b));



        return _a.mul(_b).div(MAX());

    }



    function isPercent(uint _a) internal pure returns (bool) {

        return _a >= MIN() && _a <= MAX();

    }



    function toPercent(uint _a) internal pure returns (uint) {

        require(_a <= 100);



        return _a.mul(10 ** ADD_EXP());

    }



    function fromPercent(uint _a) internal pure returns (uint) {

        require(isPercent(_a));



        return _a.div(10 ** ADD_EXP());

    }

}



// File: contracts/token/exchanger/ITokenExchange.sol



contract ITokenExchange {

    function approve(ERC20 token, address spender, uint amount) external returns (bool);



    function exchange(ERC20 fromToken, uint amount) external;

}



// File: contracts/token/exchanger/ITokenLedger.sol



contract ITokenLedger {

    function addTokenToListing(ERC20 token, WToken wToken) external;



    function hasPair(ERC20 token1, ERC20 token2) public view returns (bool);



    function getWTokenByToken(address token) public view returns (WToken wTokenAddress);



    function getTokenByWToken(address wToken) public view returns (ERC20 tokenAddress);

}



// File: contracts/token/exchanger/ITokenExchanger.sol



contract ITokenExchanger is ITokenExchange, ITokenLedger {}



// File: contracts/versioning/Versionable.sol



contract Versionable {

    uint public version;



    constructor(uint _version) public {

        version = _version;

    }

}



// File: contracts/W12Lister.sol



contract W12Lister is Versionable, RBAC, Ownable, ReentrancyGuard {

    using SafeMath for uint;

    using Percent for uint;



    string public ROLE_ADMIN = "admin";



    ITokenExchanger public exchanger;

    IW12CrowdsaleFactory public factory;

    // get token index in approvedTokens list by token address and token owner address

    mapping (address => mapping (address => uint16)) public approvedTokensIndex;

    ListedToken[] public approvedTokens;

    // return owners by token address

    mapping ( address => address[] ) approvedOwnersList;

    uint16 public approvedTokensLength;

    address public serviceWallet;



    event OwnerWhitelisted(address indexed tokenAddress, address indexed tokenOwner, string name, string symbol);

    event TokenPlaced(address indexed originalTokenAddress, address indexed tokenOwner, uint tokenAmount, address placedTokenAddress);

    event CrowdsaleInitialized(address indexed tokenAddress, address indexed tokenOwner, uint amountForSale);

    event CrowdsaleTokenMinted(address indexed tokenAddress, address indexed tokenOwner, uint amount);



    struct ListedToken {

        string name;

        string symbol;

        uint8 decimals;

        mapping(address => bool) approvedOwners;

        uint feePercent;

        uint ethFeePercent;

        uint WTokenSaleFeePercent;

        uint trancheFeePercent;

        IW12Crowdsale crowdsaleAddress;

        uint tokensForSaleAmount;

        uint wTokensIssuedAmount;

        address tokenAddress;

    }



    constructor(

        uint version,

        address _serviceWallet,

        IW12CrowdsaleFactory _factory,

        ITokenExchanger _exchanger

    ) Versionable(version) public {

        require(_serviceWallet != address(0));

        require(_factory != address(0));

        require(_exchanger != address(0));



        exchanger = _exchanger;

        serviceWallet = _serviceWallet;

        factory = _factory;

        approvedTokens.length++; // zero-index element should never be used



        addRole(msg.sender, ROLE_ADMIN);

    }



    function addAdmin(address _operator) public onlyOwner {

        addRole(_operator, ROLE_ADMIN);

    }



    function removeAdmin(address _operator) public onlyOwner {

        removeRole(_operator, ROLE_ADMIN);

    }



    function whitelistToken(

        address tokenOwner,

        address tokenAddress,

        string name,

        string symbol,

        uint8 decimals,

        uint feePercent,

        uint ethFeePercent,

        uint WTokenSaleFeePercent,

        uint trancheFeePercent

    )

        external onlyRole(ROLE_ADMIN)

    {



        require(tokenOwner != address(0));

        require(tokenAddress != address(0));

        require(feePercent.isPercent() && feePercent.fromPercent() < 100);

        require(ethFeePercent.isPercent() && ethFeePercent.fromPercent() < 100);

        require(WTokenSaleFeePercent.isPercent() && WTokenSaleFeePercent.fromPercent() < 100);

        require(trancheFeePercent.isPercent() && trancheFeePercent.fromPercent() < 100);

        require(getApprovedToken(tokenAddress, tokenOwner).tokenAddress != tokenAddress);

        require(!getApprovedToken(tokenAddress, tokenOwner).approvedOwners[tokenOwner]);



        uint16 index = uint16(approvedTokens.length);



        approvedTokensIndex[tokenAddress][tokenOwner] = index;



        approvedTokensLength = uint16(approvedTokens.length++);



        approvedOwnersList[tokenAddress].push(tokenOwner);



        approvedTokens[index].approvedOwners[tokenOwner] = true;

        approvedTokens[index].name = name;

        approvedTokens[index].symbol = symbol;

        approvedTokens[index].decimals = decimals;

        approvedTokens[index].feePercent = feePercent;

        approvedTokens[index].ethFeePercent = ethFeePercent;

        approvedTokens[index].WTokenSaleFeePercent = WTokenSaleFeePercent;

        approvedTokens[index].trancheFeePercent = trancheFeePercent;

        approvedTokens[index].tokenAddress = tokenAddress;



        emit OwnerWhitelisted(tokenAddress, tokenOwner, name, symbol);

    }



    /**

     * @notice Place token for sale

     * @param tokenAddress Token that will be placed

     * @param amount Token amount to place

     */

    function placeToken(address tokenAddress, uint amount) external nonReentrant {

        require(amount > 0);

        require(tokenAddress != address(0));

        require(getApprovedToken(tokenAddress, msg.sender).tokenAddress == tokenAddress);

        require(getApprovedToken(tokenAddress, msg.sender).approvedOwners[msg.sender]);



        DetailedERC20 token = DetailedERC20(tokenAddress);



        require(token.allowance(msg.sender, address(this)) >= amount);



        ListedToken storage listedToken = getApprovedToken(tokenAddress, msg.sender);



        require(token.decimals() == listedToken.decimals);



        uint fee = listedToken.feePercent > 0

            ? amount.percent(listedToken.feePercent)

            : 0;

        uint amountWithoutFee = amount.sub(fee);



        _secureTokenTransfer(token, exchanger, amountWithoutFee);

        _secureTokenTransfer(token, serviceWallet, fee);



        listedToken.tokensForSaleAmount = listedToken.tokensForSaleAmount.add(amountWithoutFee);



        if (exchanger.getWTokenByToken(tokenAddress) == address(0)) {

            WToken wToken = new WToken(listedToken.name, listedToken.symbol, listedToken.decimals);



            exchanger.addTokenToListing(ERC20(tokenAddress), wToken);

        }



        emit TokenPlaced(tokenAddress, msg.sender, amountWithoutFee, exchanger.getWTokenByToken(tokenAddress));

    }



    /**

     * @dev Securely transfer token from sender to account

     */

    function _secureTokenTransfer(ERC20 token, address to, uint value) internal {

        // check for overflow before. we are not sure that the placed token has implemented save math

        uint expectedBalance = token.balanceOf(to).add(value);



        token.transferFrom(msg.sender, to, value);



        // check balance to be sure it was filled correctly

        assert(token.balanceOf(to) == expectedBalance);

    }



    function initCrowdsale(address tokenAddress, uint amountForSale, uint price) external nonReentrant {

        require(getApprovedToken(tokenAddress, msg.sender).approvedOwners[msg.sender] == true);

        require(getApprovedToken(tokenAddress, msg.sender).tokensForSaleAmount >= getApprovedToken(tokenAddress, msg.sender).wTokensIssuedAmount.add(amountForSale));

        require(getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress == address(0));



        WToken wtoken = exchanger.getWTokenByToken(tokenAddress);



        IW12Crowdsale crowdsale = factory.createCrowdsale(

            address(tokenAddress),

            address(wtoken),

            price,

            serviceWallet,

            getApprovedToken(tokenAddress, msg.sender).ethFeePercent,

            getApprovedToken(tokenAddress, msg.sender).WTokenSaleFeePercent,

            getApprovedToken(tokenAddress, msg.sender).trancheFeePercent,

            exchanger,

            msg.sender

        );



        getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress = crowdsale;

        wtoken.addTrustedAccount(crowdsale);



        if (getApprovedToken(tokenAddress, msg.sender).WTokenSaleFeePercent > 0) {

            exchanger.approve(

                ERC20(tokenAddress),

                address(crowdsale),

                getApprovedToken(tokenAddress, msg.sender).tokensForSaleAmount

                    .percent(getApprovedToken(tokenAddress, msg.sender).WTokenSaleFeePercent)

            );

        }



        addTokensToCrowdsale(tokenAddress, amountForSale);



        emit CrowdsaleInitialized(tokenAddress, msg.sender, amountForSale);

    }



    function addTokensToCrowdsale(address tokenAddress, uint amountForSale) public {

        require(amountForSale > 0);

        require(tokenAddress != address(0));

        require(exchanger.getWTokenByToken(tokenAddress) != address(0));

        require(getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress != address(0));

        require(getApprovedToken(tokenAddress, msg.sender).approvedOwners[msg.sender] == true);

        require(getApprovedToken(tokenAddress, msg.sender).tokensForSaleAmount >= getApprovedToken(tokenAddress, msg.sender).wTokensIssuedAmount.add(amountForSale));



        WToken token = exchanger.getWTokenByToken(tokenAddress);

        IW12Crowdsale crowdsale = getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress;



        getApprovedToken(tokenAddress, msg.sender).wTokensIssuedAmount = getApprovedToken(tokenAddress, msg.sender)

            .wTokensIssuedAmount.add(amountForSale);



        token.mint(crowdsale, amountForSale, 0);



        emit CrowdsaleTokenMinted(tokenAddress, msg.sender, amountForSale);

    }



    function getTokenCrowdsale(address tokenAddress, address ownerAddress) view external returns (address) {

        return getApprovedToken(tokenAddress, ownerAddress).crowdsaleAddress;

    }



    function getTokenOwners(address token) public view returns (address[]) {

        return approvedOwnersList[token];

    }



    function getExchanger() view external returns (ITokenExchanger) {

        return exchanger;

    }



    function getApprovedToken(address tokenAddress, address ownerAddress) internal view returns (ListedToken storage result) {

        return approvedTokens[approvedTokensIndex[tokenAddress][ownerAddress]];

    }

}