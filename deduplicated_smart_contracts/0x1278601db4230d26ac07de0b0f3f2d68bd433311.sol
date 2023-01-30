/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function burn(uint256 amount) external;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

contract Bonded is OwnableUpgradeSafe {

    using SafeMath for uint256;

    uint public TGE;
    uint public constant month = 30 days;
    uint constant decimals = 18;
    uint constant decMul = uint(10) ** decimals;
    
    address public advisorsAddress;
    address public foundationAddress;
    address public ecosystemAddress;
    address public reserveAddress;
    address public marketingAddress;
    address public employeesAddress;
    
    uint public constant SEED_POOL        = 50000000 * decMul;
    uint public constant ADVISORS_POOL    = 4800000 * decMul;
    uint public constant FOUNDATION_POOL  = 12000000 * decMul;
    uint public constant ECOSYSTEM_POOL   = 12000000 * decMul;
    uint public constant RESERVE_POOL     = 6000000 * decMul;
    uint public constant MARKETING_POOL   = 4800000 * decMul;
    uint public constant EMPLOYEES_POOL   = 8400000 * decMul;
    
    uint public currentSeedPool         = SEED_POOL;
    uint public currentAdvisorsPool     = ADVISORS_POOL;
    uint public currentFoundationPool   = FOUNDATION_POOL;
    uint public currentEcosystemPool    = ECOSYSTEM_POOL;
    uint public currentReservePool      = RESERVE_POOL;
    uint public currentMarketingPool    = MARKETING_POOL;
    uint public currentEmployeesPool    = EMPLOYEES_POOL;

    IERC20 public token;
    
    mapping(address => uint) public seedWhitelist;

    constructor(address _advisorsAddress,
                address _foundationAddress,
                address _ecosystemAddress,
                address _reserveAddress,
                address _marketingAddress,
                address _employeesAddress) public {
        __Ownable_init_unchained();

        advisorsAddress = _advisorsAddress;
        foundationAddress = _foundationAddress;
        ecosystemAddress = _ecosystemAddress;
        reserveAddress = _reserveAddress;
        marketingAddress = _marketingAddress;
        employeesAddress = _employeesAddress;
    }

    /**
     * @dev Sets the Plutus ERC-20 token contract address
     */
    function setTokenContract(address _tokenAddress) public onlyOwner {
        token = IERC20(_tokenAddress);
    }
    
    /**
     * @dev Sets the current TGE from where the vesting period will be counted. Can be used only if TGE is zero.
     */
    function setTGE() public onlyOwner {
        require(TGE == 0, "TGE has already been set");
        TGE = now;
    }
    
    /**
     * @dev Sets each address from `addresses` as the key and each balance
     * from `balances` to the privateWhitelist. Can be used only by an owner.
     */
    function addToWhitelist(address[] memory addresses, uint[] memory balances) public onlyOwner {
        require(addresses.length == balances.length, "Invalid request length");
        for(uint i = 0; i < addresses.length; i++) {
            seedWhitelist[addresses[i]] = balances[i];
        }
    }
    
    /**
     * @dev claim seed tokens from the contract balance.
     * `amount` means how many tokens must be claimed.
     * Can be used only by an owner or by any whitelisted person
     */
    function claimSeedTokens(uint amount) public {
        require(seedWhitelist[msg.sender] > 0 || msg.sender == owner(), "Sender is not whitelisted");
        require(seedWhitelist[msg.sender] >= amount || msg.sender == owner(), "Exceeded token amount");
        require(currentSeedPool >= amount, "Exceeded seedpool");
        
        currentSeedPool = currentSeedPool.sub(amount);
        
        // Bridge fees are not taken off for contract owner
        if (msg.sender == owner()) {
            token.transfer(msg.sender, amount);
            return;
        }
        
        seedWhitelist[msg.sender] = seedWhitelist[msg.sender].sub(amount);
        
        uint amountToBurn = amount.mul(getCurrentFee()).div(1000);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(msg.sender, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim advisors tokens from the contract balance.
     * Can be used only by an owner or from advisorsAddress.
     * Tokens will be send to sender address.
     */
    function claimAdvisorsTokens() public {
        require(msg.sender == advisorsAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");

        //6 months of vestiong period
        require(now >= TGE + 6*month, "Vesting period");
        
        uint amount = 0;
        if (currentAdvisorsPool == ADVISORS_POOL) {
            currentAdvisorsPool -= ADVISORS_POOL.div(4);
            amount += ADVISORS_POOL.div(4);
        }

        if (now >= TGE + 12*month && currentAdvisorsPool == ADVISORS_POOL.sub(ADVISORS_POOL.div(4))) {
            currentAdvisorsPool -= ADVISORS_POOL.div(4);
            amount += ADVISORS_POOL.div(4);
        }

        if (now >= TGE + 18*month && currentAdvisorsPool == ADVISORS_POOL.sub(ADVISORS_POOL.div(2))) {
            currentAdvisorsPool -= ADVISORS_POOL.div(4);
            amount += ADVISORS_POOL.div(4);
        }

        if (now >= TGE + 24*month && currentAdvisorsPool == ADVISORS_POOL.sub(ADVISORS_POOL.mul(3).div(4))) {    
            currentAdvisorsPool -= ADVISORS_POOL.div(4);
            amount += ADVISORS_POOL.div(4);
        }
        
        // 25% each 6 months
        require(amount > 0, "nothing to claim");
        
        uint amountToBurn = amount.mul(getCurrentFee()).div(1000);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(advisorsAddress, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim foundation tokens from the contract balance.
     * Can be used only by an owner or from foundationAddress.
     * Tokens will be send to foundationAddress.
     */
    function claimFoundationTokens() public {
        require(msg.sender == foundationAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");

        // 2.5 years of vestiong period
        require(now >= TGE + 30*month, "Vesting period");
                
        uint amount = 0;
        if (now >= TGE + 30*month && currentFoundationPool == FOUNDATION_POOL) {
            currentFoundationPool -= FOUNDATION_POOL.div(4);
            amount += FOUNDATION_POOL.div(4);
        }

        if (now >= TGE + 36*month && currentFoundationPool == FOUNDATION_POOL.sub(FOUNDATION_POOL.div(4))) {
            currentFoundationPool -= FOUNDATION_POOL.div(4);
            amount += FOUNDATION_POOL.div(4);
        }

        if (now >= TGE + 42*month && currentFoundationPool == FOUNDATION_POOL.sub(FOUNDATION_POOL.div(2))) {
            currentFoundationPool -= FOUNDATION_POOL.div(4);
            amount += FOUNDATION_POOL.div(4);
        }

        if (now >= TGE + 48*month && currentFoundationPool == FOUNDATION_POOL.sub(FOUNDATION_POOL.mul(3).div(4))) {
            currentFoundationPool -= FOUNDATION_POOL.div(4);
            amount += FOUNDATION_POOL.div(4);
        }
        
        // 25% each 6 months
        require(amount > 0, "nothing to claim");
       
        // No sense to burn because 2.5 years vestiong period
        token.transfer(foundationAddress, amount);
    }
    
    /**
     * @dev claim ecosystem tokens from the contract balance.
     * Can be used only by an owner or from ecosystemAddress.
     * Tokens will be send to ecosystemAddress.
     */
    function claimEcosystemTokens() public {
        require(msg.sender == ecosystemAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");

        //6 months of vestiong period
        require(now >= TGE + 6*month, "Vesting period");
        
        uint monthPassed = ((now.sub(TGE)).div(month)).sub(5);
        
        // Avoid overflow when releasing 2% each month
        if (monthPassed > 50) {
            monthPassed = 50;
        }

        uint amount = currentEcosystemPool.sub(ECOSYSTEM_POOL.sub((ECOSYSTEM_POOL.mul(monthPassed*2)).div(100)));
        require(amount > 0, "nothing to claim");
        
        currentEcosystemPool = currentEcosystemPool.sub(amount);
        
        uint amountToBurn = amount.mul(getCurrentFee()).div(1000);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(ecosystemAddress, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim reserve tokens from the contract balance.
     * Can be used only by an owner or from reserveAddress.
     * Tokens will be send to reserveAddress.
     */
    function claimReserveTokens() public {
        require(msg.sender == reserveAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");

        //6 months of vestiong period
        require(now >= TGE + 6*month, "Vesting period");
        
        uint monthPassed = now.sub(TGE).div(month).sub(5);
        
        // Avoid overflow when releasing 5% each month
        if (monthPassed > 20) {
            monthPassed = 20;
        }
        
        uint amount = currentReservePool.sub(RESERVE_POOL.sub((RESERVE_POOL.mul(monthPassed*5)).div(100)));

        currentReservePool = currentReservePool.sub(amount);
        require(amount > 0, "nothing to claim");
        
        uint amountToBurn = amount.mul(getCurrentFee()).div(1000);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(reserveAddress, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim marketing tokens from the contract balance.
     * Can be used only by an owner or from marketingAddress.
     * Tokens will be send to marketingAddress.
     */
    function claimMarketingTokens() public {
        require(msg.sender == marketingAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");

        // no vestiong period
        uint monthPassed = (now.sub(TGE)).div(month).add(1);
        
        // Avoid overflow when releasing 10% each month
        if (monthPassed > 10) {
            monthPassed = 10;
        }
        
        uint amount = currentMarketingPool.sub(MARKETING_POOL.sub(MARKETING_POOL.mul(monthPassed*10).div(100)));
        require(amount > 0, "nothing to claim");

        currentMarketingPool = currentMarketingPool.sub(amount);
        
        uint amountToBurn = amount.mul(getCurrentFee()).div(1000);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(marketingAddress, amount.sub(amountToBurn));
    }

    /**
     * @dev claim employee tokens from the contract balance.
     * Can be used only by an owner or from employeesAddress
     */
    function claimEmployeeTokens() public {
        require(msg.sender == employeesAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");

        // 1.5 years of vesting period
        require(now >= TGE + 18 * month, "Vesting period");

        // Get the total months passed after the vesting period of 1.5 years
        uint monthPassed = (now.sub(TGE)).div(month).sub(18).add(1);

        // Avoid overflow when releasing 10% each month
        // If more than 10 months passed without token claim then 100% tokens can be claimed at once.
        if (monthPassed > 10) {
            monthPassed = 10;
        }

        uint amount = currentEmployeesPool.sub(EMPLOYEES_POOL.sub(EMPLOYEES_POOL.mul(monthPassed*10).div(100)));
        require(amount > 0, "nothing to claim");

        currentEmployeesPool = currentEmployeesPool.sub(amount);

        //18 month of vesting period, no need to check fee        
        token.transfer(employeesAddress, amount);
    }

    /**
     * @dev getCurrentFee calculate current fee according to TGE and returns it.
     * NOTE: divide result by 1000 to calculate current percent.
     */
    function getCurrentFee() public view returns (uint) {
        if (now >= TGE + 9 * month) {
            return 0;
        }
        if (now >= TGE + 8 * month) {
            return 92;
        }
        if (now >= TGE + 7 * month) {
           return 115;
        }
        if (now >= TGE + 6 * month) {
            return 144;
        }
        if (now >= TGE + 5 * month) {
            return 180;
        }
        if (now >= TGE + 4 * month) {
            return 225;
        }
        if (now >= TGE + 3 * month) {
            return 282;
        }
        if (now >= TGE + 2 * month) {
            return 352;
        }
        if (now >= TGE + 1 * month) {
            return 440;
        }

        return 550;
    }
}