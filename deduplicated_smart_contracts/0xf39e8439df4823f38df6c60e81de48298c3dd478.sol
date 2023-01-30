/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

pragma solidity 0.5.16;

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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard is Initializable {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    function initialize() public initializer {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
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

    uint256[50] private ______gap;
}

// File: contracts\uniswapV2Periphery\interfaces\IUniswapV2Router01.sol

pragma solidity =0.5.16;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}


library BasisPoints {
    using SafeMath for uint;

    uint constant private BASIS_POINTS = 10000;

    function mulBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        return amt.mul(bp).div(BASIS_POINTS);
    }

    function divBP(uint amt, uint bp) internal pure returns (uint) {
        require(bp > 0, "Cannot divide by zero.");
        if (amt == 0) return 0;
        return amt.mul(BASIS_POINTS).div(bp);
    }

    function addBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.add(mulBP(amt, bp));
    }

    function subBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.sub(mulBP(amt, bp));
    }
}


interface ILidCertifiableToken {
    function activateTransfers() external;
    function activateTax() external;
    function mint(address account, uint256 amount) external returns (bool);
    function addMinter(address account) external;
    function renounceMinter() external;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function isMinter(address account) external view returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}


contract LidCertifiedPresaleTimer is Initializable, Ownable {
    using SafeMath for uint;

    uint public startTime;
    uint public baseTimer;
    uint public deltaTimer;

    function initialize(
        uint _startTime,
        uint _baseTimer,
        uint _deltaTimer,
        address owner
    ) external initializer {
        Ownable.initialize(msg.sender);
        startTime = _startTime;
        baseTimer = _baseTimer;
        deltaTimer = _deltaTimer;
        //Due to issue in oz testing suite, the msg.sender might not be owner
        _transferOwnership(owner);
    }

    function setStartTime(uint time) external onlyOwner {
        startTime = time;
    }

    function isStarted() external view returns (bool) {
        return (startTime != 0 && now > startTime);
    }

    function getEndTime(uint bal) external view returns (uint) {
        uint multiplier = 0;
        if (bal <= 1000 ether) {
            multiplier = bal.div(100 ether);
        } else if (bal <= 10000 ether) {
            multiplier = bal.div(1000 ether).add(9);
        } else if (bal <= 100000 ether) {
            multiplier = bal.div(10000 ether).add(19);
        } else if (bal <= 1000000 ether) {
            multiplier = bal.div(100000 ether).add(29);
        } else if (bal <= 10000000 ether) {
            multiplier = bal.div(1000000 ether).add(39);
        } else if (bal <= 100000000 ether) {
            multiplier = bal.div(10000000 ether).add(49);
        }
        return startTime.add(
            baseTimer
        ).add(
            deltaTimer.mul(multiplier)
        );
    }
}


contract LidCertifiedPresale is Initializable, Ownable, ReentrancyGuard {
    using BasisPoints for uint;
    using SafeMath for uint;

    uint public maxBuyPerAddressBase;
    uint public maxBuyPerAddressBP;
    uint public maxBuyWithoutWhitelisting;

    uint public redeemBP;
    uint public redeemInterval;

    uint public referralBP;

    uint public uniswapEthBP;
    address payable[] public etherPools;
    uint[] public etherPoolBPs;

    uint public uniswapTokenBP;
    uint public presaleTokenBP;
    address[] public tokenPools;
    uint[] public tokenPoolBPs;

    uint public startingPrice;
    uint public multiplierPrice;

    bool public hasSentToUniswap;
    bool public hasIssuedTokens;
    bool public hasSentEther;

    uint public totalTokens;
    uint private totalEth;
    uint public finalEndTime;

    ILidCertifiableToken private token;
    IUniswapV2Router01 private uniswapRouter;
    LidCertifiedPresaleTimer private timer;

    mapping(address => uint) public depositAccounts;
    mapping(address => uint) public accountEarnedLid;
    mapping(address => uint) public accountClaimedLid;
    mapping(address => bool) public whitelist;
    mapping(address => uint) public earnedReferrals;

    uint public totalDepositors;
    mapping(address => uint) public referralCounts;

    uint lidRepaired;
    bool pauseDeposit;

    mapping(address => bool) public isRepaired;

    modifier whenPresaleActive {
        require(timer.isStarted(), "Presale not yet started.");
        require(!_isPresaleEnded(), "Presale has ended.");
        _;
    }

    modifier whenPresaleFinished {
        require(timer.isStarted(), "Presale not yet started.");
        require(_isPresaleEnded(), "Presale has not yet ended.");
        _;
    }

    function initialize(
        uint _maxBuyPerAddressBase,
        uint _maxBuyPerAddressBP,
        uint _maxBuyWithoutWhitelisting,
        uint _redeemBP,
        uint _redeemInterval,
        uint _referralBP,
        uint _startingPrice,
        uint _multiplierPrice,
        address owner,
        LidCertifiedPresaleTimer _timer,
        ILidCertifiableToken _token
    ) external initializer {
        require(_token.isMinter(address(this)), "Presale SC must be minter.");
        Ownable.initialize(msg.sender);
        ReentrancyGuard.initialize();

        token = _token;
        timer = _timer;

        maxBuyPerAddressBase = _maxBuyPerAddressBase;
        maxBuyPerAddressBP = _maxBuyPerAddressBP;
        maxBuyWithoutWhitelisting = _maxBuyWithoutWhitelisting;

        redeemBP = _redeemBP;

        referralBP = _referralBP;
        redeemInterval = _redeemInterval;

        startingPrice = _startingPrice;
        multiplierPrice = _multiplierPrice;

        uniswapRouter = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        //Due to issue in oz testing suite, the msg.sender might not be owner
        _transferOwnership(owner);
    }

    function deposit() external payable {
        deposit(address(0x0));
    }

    function setEtherPools(
        address payable[] calldata _etherPools,
        uint[] calldata _etherPoolBPs
    ) external onlyOwner {
        require(_etherPools.length == _etherPoolBPs.length, "Must have exactly one etherPool addresses for each BP.");
        delete etherPools;
        delete etherPoolBPs;
        uniswapEthBP = 7500; //75%
        for (uint i = 0; i < _etherPools.length; ++i) {
            etherPools.push(_etherPools[i]);
        }
        uint totalEtherPoolsBP = uniswapEthBP;
        for (uint i = 0; i < _etherPoolBPs.length; ++i) {
            etherPoolBPs.push(_etherPoolBPs[i]);
            totalEtherPoolsBP = totalEtherPoolsBP.add(_etherPoolBPs[i]);
        }
        require(totalEtherPoolsBP == 10000, "Must allocate exactly 100% (10000 BP) of ether to pools");
    }

    function setTokenPools(
        address[] calldata _tokenPools,
        uint[] calldata _tokenPoolBPs
    ) external onlyOwner {
        require(_tokenPools.length == _tokenPoolBPs.length, "Must have exactly one tokenPool addresses for each BP.");
        delete tokenPools;
        delete tokenPoolBPs;
        uniswapTokenBP = 1600;
        presaleTokenBP = 4000;
        for (uint i = 0; i < _tokenPools.length; ++i) {
            tokenPools.push(_tokenPools[i]);
        }
        uint totalTokenPoolBPs = uniswapTokenBP.add(presaleTokenBP);
        for (uint i = 0; i < _tokenPoolBPs.length; ++i) {
            tokenPoolBPs.push(_tokenPoolBPs[i]);
            totalTokenPoolBPs = totalTokenPoolBPs.add(_tokenPoolBPs[i]);
        }
        require(totalTokenPoolBPs == 10000, "Must allocate exactly 100% (10000 BP) of tokens to pools");
    }

    function sendToUniswap() external whenPresaleFinished nonReentrant {
        require(etherPools.length > 0, "Must have set ether pools");
        require(tokenPools.length > 0, "Must have set token pools");
        require(!hasSentToUniswap, "Has already sent to Uniswap.");
        finalEndTime = now;
        hasSentToUniswap = true;
        totalTokens = totalTokens.divBP(presaleTokenBP);
        uint uniswapTokens = totalTokens.mulBP(uniswapTokenBP);
        totalEth = address(this).balance;
        uint uniswapEth = totalEth.mulBP(uniswapEthBP);
        token.mint(address(this), uniswapTokens);
        token.activateTransfers();
        token.approve(address(uniswapRouter), uniswapTokens);
        uniswapRouter.addLiquidityETH.value(uniswapEth)(
            address(token),
            uniswapTokens,
            uniswapTokens,
            uniswapEth,
            address(0x000000000000000000000000000000000000dEaD),
            now
        );
    }

    function issueTokens() external whenPresaleFinished {
        require(hasSentToUniswap, "Has not yet sent to Uniswap.");
        require(!hasIssuedTokens, "Has already issued tokens.");
        hasIssuedTokens = true;
        for (uint i = 0; i < tokenPools.length; ++i) {
            token.mint(
                tokenPools[i],
                totalTokens.mulBP(tokenPoolBPs[i])
            );
        }
    }

    function sendEther() external whenPresaleFinished nonReentrant {
        require(hasSentToUniswap, "Has not yet sent to Uniswap.");
        require(!hasSentEther, "Has already sent ether.");
        hasSentEther = true;
        for (uint i = 0; i < etherPools.length; ++i) {
            etherPools[i].transfer(
                totalEth.mulBP(etherPoolBPs[i])
            );
        }
        //remove dust
        if (address(this).balance > 0) {
            etherPools[0].transfer(
                address(this).balance
            );
        }
    }

    function setDepositPause(bool val) external onlyOwner {
        pauseDeposit = val;
    }

    function setWhitelist(address account, bool value) external onlyOwner {
        whitelist[account] = value;
    }

    function setWhitelistForAll(address[] calldata account, bool value) external onlyOwner {
        for (uint i=0; i < account.length; i++) {
            whitelist[account[i]] = value;
        }
    }

    function redeem() external whenPresaleFinished {
        require(hasSentToUniswap, "Must have sent to Uniswap before any redeems.");
        uint claimable = calculateReedemable(msg.sender);
        accountClaimedLid[msg.sender] = accountClaimedLid[msg.sender].add(claimable);
        token.mint(msg.sender, claimable);
    }

    function deposit(address payable referrer) public payable whenPresaleActive nonReentrant {
        require(!pauseDeposit, "Deposits are paused.");
        if (whitelist[msg.sender]) {
            require(
                depositAccounts[msg.sender].add(msg.value) <=
                getMaxWhitelistedDeposit(
                    address(this).balance.sub(msg.value)
                ),
                "Deposit exceeds max buy per address for whitelisted addresses."
            );
        } else {
            require(
                depositAccounts[msg.sender].add(msg.value) <= maxBuyWithoutWhitelisting,
                "Deposit exceeds max buy per address for non-whitelisted addresses."
            );
        }

        require(msg.value > 0.01 ether, "Must purchase at least 0.01 ether.");

        if(depositAccounts[msg.sender] == 0) totalDepositors = totalDepositors.add(1);

        uint depositVal = msg.value.subBP(referralBP);
        uint tokensToIssue = depositVal.mul(10**18).div(calculateRatePerEth());
        depositAccounts[msg.sender] = depositAccounts[msg.sender].add(depositVal);

        totalTokens = totalTokens.add(tokensToIssue);

        accountEarnedLid[msg.sender] = accountEarnedLid[msg.sender].add(tokensToIssue);

        if (referrer != address(0x0) && referrer != msg.sender) {
            uint referralValue = msg.value.sub(depositVal);
            earnedReferrals[referrer] = earnedReferrals[referrer].add(referralValue);
            referralCounts[referrer] = referralCounts[referrer].add(1);
            referrer.transfer(referralValue);
        }
    }

    function calculateReedemable(address account) public view returns (uint) {
        if (finalEndTime == 0) return 0;
        uint earnedLid = accountEarnedLid[account];
        uint claimedLid = accountClaimedLid[account];
        uint cycles = now.sub(finalEndTime).div(redeemInterval).add(1);
        uint totalRedeemable = earnedLid.mulBP(redeemBP).mul(cycles);
        uint claimable;
        if (totalRedeemable >= earnedLid) {
            claimable = earnedLid.sub(claimedLid);
        } else {
            claimable = totalRedeemable.sub(claimedLid);
        }
        return claimable;
    }

    function calculateRatePerEth() public view returns (uint) {
        return totalTokens.div(10**18).mul(multiplierPrice).add(startingPrice);
    }

    function getMaxWhitelistedDeposit(uint atTotalDeposited) public view returns (uint) {
        return atTotalDeposited.mulBP(maxBuyPerAddressBP).add(maxBuyPerAddressBase);
    }

    function _isPresaleEnded() internal view returns (bool) {
        return (
            (timer.isStarted() && (now > timer.getEndTime(address(this).balance)))
        );
    }

}