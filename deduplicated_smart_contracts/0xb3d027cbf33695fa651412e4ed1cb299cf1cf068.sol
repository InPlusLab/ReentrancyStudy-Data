// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


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
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function initialize(address sender) public initializer {
    _owner = sender;
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
    emit OwnershipRenounced(_owner);
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

  uint256[50] private ______gap;
}

// File: contracts/lib/SafeMathInt.sol

/*
MIT License

Copyright (c) 2018 requestnetwork

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity >=0.4.24;


/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

// File: contracts/lib/UInt256Lib.sol

pragma solidity >=0.4.24;


/**
 * @title Various utilities useful for uint256.
 */
library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    /**
     * @dev Safely converts a uint256 to an int256.
     */
    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {
        require(a <= MAX_INT256);
        return int256(a);
    }
}

// File: contracts/interface/ISeigniorageShares.sol

pragma solidity >=0.4.24;


interface ISeigniorageShares {
    function setDividendPoints(address account, uint256 totalDividends) external returns (bool);
    function mintShares(address account, uint256 amount) external returns (bool);
    function lastDividendPoints(address who) external view returns (uint256);
    function externalRawBalanceOf(address who) external view returns (uint256);
    function externalTotalSupply() external view returns (uint256);
}

// File: openzeppelin-eth/contracts/math/SafeMath.sol

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

// File: openzeppelin-eth/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.4.24;




/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is Initializable, IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string name, string symbol, uint8 decimals) public initializer {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
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

  uint256[50] private ______gap;
}

// File: contracts/dollars.sol

pragma solidity >=0.4.24;







interface IDollarPolicy {
    function getUsdSharePrice() external view returns (uint256 price);
}

/*
 *  Dollar ERC20
 */

contract Dollars is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogContraction(uint256 indexed epoch, uint256 dollarsToBurn);
    event LogRebasePaused(bool paused);
    event LogBurn(address indexed from, uint256 value);
    event LogClaim(address indexed from, uint256 value);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

    // Used for authentication
    address public monetaryPolicy;
    address public sharesAddress;

    modifier onlyMonetaryPolicy() {
        require(msg.sender == monetaryPolicy);
        _;
    }

    // Precautionary emergency controls.
    bool public rebasePaused;

    modifier whenRebaseNotPaused() {
        require(!rebasePaused);
        _;
    }

    // coins needing to be burned (9 decimals)
    uint256 private _remainingDollarsToBeBurned;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_DOLLAR_SUPPLY = 1 * 10**6 * 10**DECIMALS;
    uint256 private _maxDiscount;

    modifier validDiscount(uint256 discount) {
        require(discount <= _maxDiscount, 'DISCOUNT_TOO_HIGH');
        _;
    }

    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private _totalSupply;

    uint256 private constant POINT_MULTIPLIER = 10 ** 9;

    uint256 private _totalDividendPoints;
    uint256 private _unclaimedDividends;

    ISeigniorageShares shares;

    mapping(address => uint256) private _dollarBalances;

    // This is denominated in Dollars, because the cents-dollars conversion might change before
    // it's fully paid.
    mapping (address => mapping (address => uint256)) private _allowedDollars;

    IDollarPolicy dollarPolicy;
    uint256 public burningDiscount; // percentage (10 ** 9 Decimals)
    uint256 public defaultDiscount; // discount on first negative rebase
    uint256 public defaultDailyBonusDiscount; // how much the discount increases per day for consecutive contractions

    uint256 public minimumBonusThreshold;

    bool reEntrancyMutex;
    bool reEntrancyRebaseMutex;

    address public uniswapV2Pool;

    modifier uniqueAddresses(address addr1, address addr2) {
        require(addr1 != addr2, "Addresses are not unique");
        _;
    }

    /**
     * @param monetaryPolicy_ The address of the monetary policy contract to use for authentication.
     */
    function setMonetaryPolicy(address monetaryPolicy_)
        external
        onlyOwner
    {
        monetaryPolicy = monetaryPolicy_;
        dollarPolicy = IDollarPolicy(monetaryPolicy_);
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    function setUniswapV2SyncAddress(address uniswapV2Pair_)
        external
        onlyOwner
    {
        uniswapV2Pool = uniswapV2Pair_;
    }

    function test()
        external
        onlyOwner
    {
        uniswapV2Pool.call(abi.encodeWithSignature('sync()'));
    }

    function setBurningDiscount(uint256 discount)
        external
        onlyOwner
        validDiscount(discount)
    {
        burningDiscount = discount;
    }

    // amount in is 10 ** 9 decimals
    function burn(uint256 amount)
        external
        updateAccount(msg.sender)
    {
        require(!reEntrancyMutex, "RE-ENTRANCY GUARD MUST BE FALSE");
        reEntrancyMutex = true;

        require(amount != 0, 'AMOUNT_MUST_BE_POSITIVE');
        require(_remainingDollarsToBeBurned != 0, 'COIN_BURN_MUST_BE_GREATER_THAN_ZERO');
        require(amount <= _dollarBalances[msg.sender], 'INSUFFICIENT_DOLLAR_BALANCE');
        require(amount <= _remainingDollarsToBeBurned, 'AMOUNT_MUST_BE_LESS_THAN_OR_EQUAL_TO_REMAINING_COINS');

        _burn(msg.sender, amount);

        reEntrancyMutex = false;
    }

    function setDefaultDiscount(uint256 discount)
        external
        onlyOwner
        validDiscount(discount)
    {
        defaultDiscount = discount;
    }

    function setMaxDiscount(uint256 discount)
        external
        onlyOwner
    {
        _maxDiscount = discount;
    }

    function setDefaultDailyBonusDiscount(uint256 discount)
        external
        onlyOwner
        validDiscount(discount)
    {
        defaultDailyBonusDiscount = discount;
    }

    /**
     * @dev Pauses or unpauses the execution of rebase operations.
     * @param paused Pauses rebase operations if this is true.
     */
    function setRebasePaused(bool paused)
        external
        onlyOwner
    {
        rebasePaused = paused;
        emit LogRebasePaused(paused);
    }

    // action of claiming funds
    function claimDividends(address account) external updateAccount(account) returns (uint256) {
        uint256 owing = dividendsOwing(account);
        return owing;
    }

    function setMinimumBonusThreshold(uint256 minimum)
        external
        onlyOwner
    {
        require(minimum < _totalSupply, 'MINIMUM_TOO_HIGH');
        minimumBonusThreshold = minimum;
    }

    /**
     * @dev Notifies Dollars contract about a new rebase cycle.
     * @param supplyDelta The number of new dollar tokens to add into circulation via expansion.
     * @return The total number of dollars after the supply adjustment.
     */
    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        whenRebaseNotPaused
        returns (uint256)
    {
        reEntrancyRebaseMutex = true;
        uint256 burningDefaultDiscount = burningDiscount.add(defaultDailyBonusDiscount);

        if (supplyDelta == 0) {
            if (_remainingDollarsToBeBurned > minimumBonusThreshold) {

                burningDiscount = burningDefaultDiscount > _maxDiscount ? _maxDiscount : burningDefaultDiscount;
            } else {
                burningDiscount = defaultDiscount;
            }

            emit LogRebase(epoch, _totalSupply);
        } else if (supplyDelta < 0) {
            uint256 dollarsToBurn = uint256(supplyDelta.abs());
            uint256 tenPercent = _totalSupply.div(10);

            if (dollarsToBurn > tenPercent) { // maximum contraction is 10% of the total USD Supply
                dollarsToBurn = tenPercent;
            }

            if (dollarsToBurn.add(_remainingDollarsToBeBurned) > _totalSupply) {
                dollarsToBurn = _totalSupply.sub(_remainingDollarsToBeBurned);
            }

            if (_remainingDollarsToBeBurned > minimumBonusThreshold) {
                burningDiscount = burningDefaultDiscount > _maxDiscount ?
                    _maxDiscount : burningDefaultDiscount;
            } else {
                burningDiscount = defaultDiscount; // default 1%
            }

            _remainingDollarsToBeBurned = _remainingDollarsToBeBurned.add(dollarsToBurn);
            emit LogContraction(epoch, dollarsToBurn);
        } else {
            disburse(uint256(supplyDelta));

            uniswapV2Pool.call(abi.encodeWithSignature('sync()'));

            emit LogRebase(epoch, _totalSupply);

            if (_totalSupply > MAX_SUPPLY) {
                _totalSupply = MAX_SUPPLY;
            }
        }

        reEntrancyRebaseMutex = false;
        return _totalSupply;
    }

    function initialize(address owner_, address seigniorageAddress)
        public
        initializer
    {
        ERC20Detailed.initialize("Dollars", "USD", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePaused = false;
        _totalSupply = INITIAL_DOLLAR_SUPPLY;

        sharesAddress = seigniorageAddress;
        shares = ISeigniorageShares(seigniorageAddress);

        _dollarBalances[owner_] = _totalSupply;
        _maxDiscount = 50 * 10 ** 9; // 50%
        defaultDiscount = 1 * 10 ** 9;              // 1%
        burningDiscount = defaultDiscount;
        defaultDailyBonusDiscount = 1 * 10 ** 9;    // 1%
        minimumBonusThreshold = 100 * 10 ** 9;    // 100 dollars is the minimum threshold. Anything above warrants increased discount

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    function dividendsOwing(address account) public view returns (uint256) {
        if (_totalDividendPoints > shares.lastDividendPoints(account)) {
            uint256 newDividendPoints = _totalDividendPoints.sub(shares.lastDividendPoints(account));
            uint256 sharesBalance = shares.externalRawBalanceOf(account);
            return sharesBalance.mul(newDividendPoints).div(POINT_MULTIPLIER);
        } else {
            return 0;
        }
    }

    // auto claim modifier
    // if user is owned, we pay out immedietly
    // if user is not owned, we prevent them from claiming until the next rebase
    modifier updateAccount(address account) {
        uint256 owing = dividendsOwing(account);

        if (owing != 0) {
            _unclaimedDividends = _unclaimedDividends.sub(owing);
            _dollarBalances[account] += owing;
        }

        shares.setDividendPoints(account, _totalDividendPoints);

        emit LogClaim(account, owing);
        _;
    }


    /**
     * @return The total number of dollars.
     */
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _dollarBalances[who].add(dividendsOwing(who));
    }

    function getRemainingDollarsToBeBurned()
        public
        view
        returns (uint256)
    {
        return _remainingDollarsToBeBurned;
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */
    function transfer(address to, uint256 value)
        public
        uniqueAddresses(msg.sender, to)
        validRecipient(to)
        updateAccount(msg.sender)
        updateAccount(to)
        returns (bool)
    {
        require(!reEntrancyRebaseMutex, "RE-ENTRANCY GUARD MUST BE FALSE");
        _dollarBalances[msg.sender] = _dollarBalances[msg.sender].sub(value);
        _dollarBalances[to] = _dollarBalances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowedDollars[owner_][spender];
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value)
        public
        validRecipient(to)
        updateAccount(from)
        updateAccount(msg.sender)
        updateAccount(to)
        returns (bool)
    {
        require(!reEntrancyRebaseMutex, "RE-ENTRANCY GUARD MUST BE FALSE");

        _allowedDollars[from][msg.sender] = _allowedDollars[from][msg.sender].sub(value);

        _dollarBalances[from] = _dollarBalances[from].sub(value);
        _dollarBalances[to] = _dollarBalances[to].add(value);
        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value)
        public
        uniqueAddresses(msg.sender, spender)
        validRecipient(spender)
        updateAccount(msg.sender)
        updateAccount(spender)
        returns (bool)
    {
        _allowedDollars[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        uniqueAddresses(msg.sender, spender)
        updateAccount(msg.sender)
        updateAccount(spender)
        returns (bool)
    {
        _allowedDollars[msg.sender][spender] =
            _allowedDollars[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedDollars[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        uniqueAddresses(msg.sender, spender)
        updateAccount(spender)
        updateAccount(msg.sender)
        returns (bool)
    {
        uint256 oldValue = _allowedDollars[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedDollars[msg.sender][spender] = 0;
        } else {
            _allowedDollars[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedDollars[msg.sender][spender]);
        return true;
    }

    function consultBurn(uint256 amount)
        public
        returns (uint256)
    {
        require(amount > 0, 'AMOUNT_MUST_BE_POSITIVE');
        require(burningDiscount >= 0, 'DISCOUNT_NOT_VALID');
        require(_remainingDollarsToBeBurned > 0, 'COIN_BURN_MUST_BE_GREATER_THAN_ZERO');
        require(amount <= _dollarBalances[msg.sender].add(dividendsOwing(msg.sender)), 'INSUFFICIENT_DOLLAR_BALANCE');
        require(amount <= _remainingDollarsToBeBurned, 'AMOUNT_MUST_BE_LESS_THAN_OR_EQUAL_TO_REMAINING_COINS');

        uint256 usdPerShare = dollarPolicy.getUsdSharePrice(); // 1 share = x dollars
        uint256 decimals = 10 ** 9;
        uint256 percentDenominator = 100;
        usdPerShare = usdPerShare.sub(usdPerShare.mul(burningDiscount).div(percentDenominator * decimals)); // 10^9
        uint256 sharesToMint = amount.mul(decimals).div(usdPerShare); // 10^9

        return sharesToMint;
    }

    function unclaimedDividends()
        public
        view
        returns (uint256)
    {
        return _unclaimedDividends;
    }

    function totalDividendPoints()
        public
        view
        returns (uint256)
    {
        return _totalDividendPoints;
    }

    function disburse(uint256 amount) internal returns (bool) {
        _totalDividendPoints = _totalDividendPoints.add(amount.mul(POINT_MULTIPLIER).div(shares.externalTotalSupply()));
        _totalSupply = _totalSupply.add(amount);
        _unclaimedDividends = _unclaimedDividends.add(amount);
        return true;
    }

    function _burn(address account, uint256 amount)
        internal 
    {
        _totalSupply = _totalSupply.sub(amount);
        _dollarBalances[account] = _dollarBalances[account].sub(amount);

        uint256 usdPerShare = dollarPolicy.getUsdSharePrice(); // 1 share = x dollars
        uint256 decimals = 10 ** 9;
        uint256 percentDenominator = 100;

        usdPerShare = usdPerShare.sub(usdPerShare.mul(burningDiscount).div(percentDenominator * decimals)); // 10^9
        uint256 sharesToMint = amount.mul(decimals).div(usdPerShare); // 10^9
        _remainingDollarsToBeBurned = _remainingDollarsToBeBurned.sub(amount);

        shares.mintShares(account, sharesToMint);

        emit Transfer(account, address(0), amount);
        emit LogBurn(account, amount);
    }
}

// File: contracts/dollarsPolicy.sol

pragma solidity >=0.4.24;




/*
 *  Dollar Policy
 */


interface IDecentralizedOracle {
    function update() external;
    function consult(address token, uint amountIn) external view returns (uint amountOut);
}

contract DollarsPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 cpi,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    Dollars public dollars;

    // Provides the current CPI, as an 18 decimal fixed point number.
    IDecentralizedOracle public sharesPerUsdOracle;
    IDecentralizedOracle public ethPerUsdOracle;
    IDecentralizedOracle public ethPerUsdcOracle;

    uint256 public deviationThreshold;

    uint256 public rebaseLag;

    uint256 private cpi;

    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;

    uint256 public rebaseWindowOffsetSec;

    uint256 public rebaseWindowLengthSec;

    uint256 public epoch;

    address WETH_ADDRESS;
    address SHARE_ADDRESS;

    uint256 private constant DECIMALS = 18;

    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    address public orchestrator;
    bool private initializedOracle;

    modifier onlyOrchestrator() {
        require(msg.sender == orchestrator);
        _;
    }

    uint256 public minimumDollarCirculation;

    function getUsdSharePrice() external view returns (uint256) {
        sharesPerUsdOracle.update();

        uint256 shareDecimals = 10 ** 9;
        uint256 sharePrice = sharesPerUsdOracle.consult(SHARE_ADDRESS, 1 * shareDecimals);        // 10^9 decimals
        return sharePrice;
    }

    function rebase() external onlyOrchestrator {
        require(inRebaseWindow(), "OUTISDE_REBASE");
        require(initializedOracle, 'ORACLE_NOT_INITIALIZED');

        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now, "MIN_TIME_NOT_MET");

        lastRebaseTimestampSec = now.sub(
            now.mod(minRebaseTimeIntervalSec)).add(rebaseWindowOffsetSec);

        epoch = epoch.add(1);

        sharesPerUsdOracle.update();
        ethPerUsdOracle.update();
        ethPerUsdcOracle.update();

        uint256 wethDecimals = 10 ** 18;
        uint256 shareDecimals = 10 ** 9;

        uint256 ethUsdcPrice = ethPerUsdcOracle.consult(WETH_ADDRESS, 1 * wethDecimals);        // 10^18 decimals ropsten, 10^6 mainnet
        uint256 ethUsdPrice = ethPerUsdOracle.consult(WETH_ADDRESS, 1 * wethDecimals);          // 10^9 decimals
        uint256 dollarCoinExchangeRate = ethUsdcPrice.mul(10 ** 21)                             // 10^18 decimals, 10**9 ropsten, 10**21 on mainnet
            .div(ethUsdPrice);
        uint256 sharePrice = sharesPerUsdOracle.consult(SHARE_ADDRESS, 1 * shareDecimals);      // 10^9 decimals
        uint256 shareExchangeRate = sharePrice.mul(dollarCoinExchangeRate).div(shareDecimals);  // 10^18 decimals

        uint256 targetRate = cpi;

        if (dollarCoinExchangeRate > MAX_RATE) {
            dollarCoinExchangeRate = MAX_RATE;
        }

        // dollarCoinExchangeRate & targetRate arre 10^18 decimals
        int256 supplyDelta = computeSupplyDelta(dollarCoinExchangeRate, targetRate);        // supplyDelta = 10^9 decimals

        // Apply the Dampening factor.
        // supplyDelta = supplyDelta.mul(10 ** 9).div(rebaseLag.toInt256Safe());
        uint256 algorithmicLag_ = getAlgorithmicRebaseLag(supplyDelta);
        require(algorithmicLag_ != 0, "algorithmic rate must be positive");
        rebaseLag = algorithmicLag_;

        supplyDelta = supplyDelta.mul(10 ** 9).div(algorithmicLag_.toInt256Safe()); // v 0.0.1

        // check on the expansionary side
        if (supplyDelta > 0 && dollars.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(dollars.totalSupply())).toInt256Safe();
        }

        // check on the contraction side
        if (supplyDelta < 0 && dollars.getRemainingDollarsToBeBurned().add(uint256(supplyDelta.abs())) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(dollars.getRemainingDollarsToBeBurned())).toInt256Safe();
        }

        // set minimum floor
        if (supplyDelta < 0 && dollars.totalSupply().sub(dollars.getRemainingDollarsToBeBurned().add(uint256(supplyDelta.abs()))) < minimumDollarCirculation) {
            supplyDelta = (dollars.totalSupply().sub(dollars.getRemainingDollarsToBeBurned()).sub(minimumDollarCirculation)).toInt256Safe();
        }

        uint256 supplyAfterRebase;

        if (supplyDelta < 0) { // contraction, we send the amount of shares to mint
            uint256 dollarsToBurn = uint256(supplyDelta.abs());
            supplyAfterRebase = dollars.rebase(epoch, (dollarsToBurn).toInt256Safe().mul(-1));
        } else { // expansion, we send the amount of dollars to mint
            supplyAfterRebase = dollars.rebase(epoch, supplyDelta);
        }

        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, dollarCoinExchangeRate, cpi, supplyDelta, now);
    }

    function setOrchestrator(address orchestrator_)
        external
        onlyOwner
    {
        orchestrator = orchestrator_;
    }

    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {
        deviationThreshold = deviationThreshold_;
    }

    function setCpi(uint256 cpi_)
        external
        onlyOwner
    {
        require(cpi_ != 0);
        cpi = cpi_;
    }

    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {
        require(rebaseLag_ != 0);
        rebaseLag = rebaseLag_;
    }

    function initializeOracles(
        address sharesPerUsdOracleAddress,
        address ethPerUsdOracleAddress,
        address ethPerUsdcOracleAddress
    ) external onlyOwner {
        require(!initializedOracle, 'ALREADY_INITIALIZED_ORACLE');
        sharesPerUsdOracle = IDecentralizedOracle(sharesPerUsdOracleAddress);
        ethPerUsdOracle = IDecentralizedOracle(ethPerUsdOracleAddress);
        ethPerUsdcOracle = IDecentralizedOracle(ethPerUsdcOracleAddress);

        initializedOracle = true;
    }

    function changeOracles(
        address sharesPerUsdOracleAddress,
        address ethPerUsdOracleAddress,
        address ethPerUsdcOracleAddress
    ) external onlyOwner {
        sharesPerUsdOracle = IDecentralizedOracle(sharesPerUsdOracleAddress);
        ethPerUsdOracle = IDecentralizedOracle(ethPerUsdOracleAddress);
        ethPerUsdcOracle = IDecentralizedOracle(ethPerUsdcOracleAddress);
    }

    function setWethAddress(address wethAddress)
        external
        onlyOwner
    {
        WETH_ADDRESS = wethAddress;
    }

    function setShareAddress(address shareAddress)
        external
        onlyOwner
    {
        SHARE_ADDRESS = shareAddress;
    }

    function setMinimumDollarCirculation(uint256 minimumDollarCirculation_)
        external
        onlyOwner
    {
        minimumDollarCirculation = minimumDollarCirculation_;
    }

    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyOwner
    {
        require(minRebaseTimeIntervalSec_ != 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    function initialize(address owner_, Dollars dollars_)
        public
        initializer
    {
        Ownable.initialize(owner_);

        deviationThreshold = 5 * 10 ** (DECIMALS-2);

        rebaseLag = 50 * 10 ** 9;
        minRebaseTimeIntervalSec = 1 days;
        rebaseWindowOffsetSec = 63000;  // with stock market, 63000 for 1:30pm EST (debug)
        rebaseWindowLengthSec = 15 minutes;
        lastRebaseTimestampSec = 0;
        cpi = 1 * 10 ** 18;
        epoch = 0;
        minimumDollarCirculation = 1000000 * 10 ** 9; // 1M minimum dollar circulation

        dollars = dollars_;
    }

    // takes current marketcap of USD and calculates the algorithmic rebase lag
    // returns 10 ** 9 rebase lag factor
    function getAlgorithmicRebaseLag(int256 supplyDelta) public view returns (uint256) {
        if (dollars.totalSupply() >= 30000000 * 10 ** 9) {
            return 30 * 10 ** 9;
        } else {
            if (supplyDelta < 0) {
                uint256 dollarsToBurn = uint256(supplyDelta.abs()); // 1.238453076e15
                return uint256(100 * 10 ** 9).sub((dollars.totalSupply().sub(1000000 * 10 ** 9)).div(500000));
            } else {
                return uint256(29).mul(dollars.totalSupply().sub(1000000 * 10 ** 9)).div(35000000).add(1 * 10 ** 9);
            }
        }
    }

    function inRebaseWindow() public view returns (bool) {
        return (
            now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec))
        );
    }

    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        private
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        int256 targetRateSigned = targetRate.toInt256Safe();
        return dollars.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        private
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
}

// File: contracts/orchestrator.sol

pragma solidity >=0.4.24;



/*
 *  Orchestrator
 */


contract Orchestrator is Ownable {

    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);

    Transaction[] public transactions;

    DollarsPolicy public policy;

    constructor(address policy_) public {
        Ownable.initialize(msg.sender);
        policy = DollarsPolicy(policy_);
    }

    function rebase()
        external
    {
        require(msg.sender == tx.origin);  // solhint-disable-line avoid-tx-origin

        policy.rebase();

        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
    }

    function addTransaction(address destination, bytes data)
        external
        onlyOwner
    {
        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }

    function removeTransaction(uint index)
        external
        onlyOwner
    {
        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOwner
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

    function transactionsSize()
        external
        view
        returns (uint256)
    {
        return transactions.length;
    }

    function externalCall(address destination, bytes data)
        internal
        returns (bool)
    {
        bool result;
        assembly {  // solhint-disable-line no-inline-assembly
            // "Allocate" memory for output
            // (0x40 is where "free memory" pointer is stored by convention)
            let outputAddress := mload(0x40)

            // First 32 bytes are the padded length of data, so exclude that
            let dataAddress := add(data, 32)

            result := call(
                // 34710 is the value that solidity is currently emitting
                // It includes callGas (700) + callVeryLow (3, to pay for SUB)
                // + callValueTransferGas (9000) + callNewAccountGas
                // (25000, in case the destination address does not exist and needs creating)
                sub(gas, 34710),


                destination,
                0, // transfer value in wei
                dataAddress,
                mload(data),  // Size of the input, in bytes. Stored in position 0 of the array.
                outputAddress,
                0  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
}