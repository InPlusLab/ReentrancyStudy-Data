/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

// File: openzeppelin-solidity-2.3.0/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
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
        return msg.sender == _owner;
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
}

// File: openzeppelin-solidity-2.3.0/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity-2.3.0/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
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
}

// File: synthetix/contracts/interfaces/IStakingRewards.sol

pragma solidity >=0.4.24;


interface IStakingRewards {
    // Views
    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    // Mutative

    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getReward() external;

    function exit() external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @uniswap/v2-core/contracts/libraries/Math.sol

pragma solidity =0.5.16;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: contracts/uniswap/IUniswapV2Router02.sol

pragma solidity >=0.5.0;

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: contracts/Strategy.sol

pragma solidity 0.5.16;

interface Strategy {
    /// @dev Execute worker strategy. Take LP tokens + ETH. Return LP tokens + ETH.
    /// @param user The original user that is interacting with the operator.
    /// @param debt The user's total debt, for better decision making context.
    /// @param data Extra calldata information passed along to this strategy.
    function execute(address user, uint256 debt, bytes calldata data) external payable;
}

// File: contracts/SafeToken.sol

pragma solidity 0.5.16;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// File: contracts/Goblin.sol

pragma solidity 0.5.16;

interface Goblin {
    /// @dev Work on a (potentially new) position. Optionally send ETH back to Bank.
    function work(uint256 id, address user, uint256 debt, bytes calldata data) external payable;

    /// @dev Re-invest whatever the goblin is working on.
    function reinvest() external;

    /// @dev Return the amount of ETH wei to get back if we are to liquidate the position.
    function health(uint256 id) external view returns (uint256);

    /// @dev Liquidate the given position to ETH. Send all ETH back to Bank.
    function liquidate(uint256 id) external;
}

// File: contracts/UniswapGoblin.sol

pragma solidity 0.5.16;












contract UniswapGoblin is Ownable, ReentrancyGuard, Goblin {
    /// @notice Libraries
    using SafeToken for address;
    using SafeMath for uint256;

    /// @notice Events
    event Reinvest(address indexed caller, uint256 reward, uint256 bounty);
    event AddShare(uint256 indexed id, uint256 share);
    event RemoveShare(uint256 indexed id, uint256 share);
    event Liquidate(uint256 indexed id, uint256 wad);

    /// @notice Immutable variables
    IStakingRewards public staking;
    IUniswapV2Factory public factory;
    IUniswapV2Router02 public router;
    IUniswapV2Pair public lpToken;
    address public weth;
    address public fToken;
    address public uni;
    address public operator;

    /// @notice Mutable state variables
    mapping(uint256 => uint256) shares;
    mapping(address => bool) okStrats;
    uint256 public totalShare;
    Strategy public addStrat;
    Strategy public liqStrat;
    uint256 public reinvestBountyBps;

    constructor(
        address _operator,
        IStakingRewards _staking,
        IUniswapV2Router02 _router,
        address _fToken,
        address _uni,
        Strategy _addStrat,
        Strategy _liqStrat,
        uint256 _reinvestBountyBps
    ) public {
        operator = _operator;
        weth = _router.WETH();
        staking = _staking;
        router = _router;
        factory = IUniswapV2Factory(_router.factory());
        lpToken = IUniswapV2Pair(factory.getPair(weth, _fToken));
        fToken = _fToken;
        uni = _uni;
        addStrat = _addStrat;
        liqStrat = _liqStrat;
        okStrats[address(addStrat)] = true;
        okStrats[address(liqStrat)] = true;
        reinvestBountyBps = _reinvestBountyBps;
        lpToken.approve(address(_staking), uint256(-1)); // 100% trust in the staking pool
        lpToken.approve(address(router), uint256(-1)); // 100% trust in the router
        _fToken.safeApprove(address(router), uint256(-1)); // 100% trust in the router
        _uni.safeApprove(address(router), uint256(-1)); // 100% trust in the router
    }

    /// @dev Require that the caller must be an EOA account to avoid flash loans.
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "not eoa");
        _;
    }

    /// @dev Require that the caller must be the operator (the bank).
    modifier onlyOperator() {
        require(msg.sender == operator, "not operator");
        _;
    }

    /// @dev Return the entitied LP token balance for the given shares.
    /// @param share The number of shares to be converted to LP balance.
    function shareToBalance(uint256 share) public view returns (uint256) {
        if (totalShare == 0) return share; // When there's no share, 1 share = 1 balance.
        uint256 totalBalance = staking.balanceOf(address(this));
        return share.mul(totalBalance).div(totalShare);
    }

    /// @dev Return the number of shares to receive if staking the given LP tokens.
    /// @param balance the number of LP tokens to be converted to shares.
    function balanceToShare(uint256 balance) public view returns (uint256) {
        if (totalShare == 0) return balance; // When there's no share, 1 share = 1 balance.
        uint256 totalBalance = staking.balanceOf(address(this));
        return balance.mul(totalShare).div(totalBalance);
    }

    /// @dev Re-invest whatever this worker has earned back to staked LP tokens.
    function reinvest() public onlyEOA nonReentrant {
        // 1. Withdraw all the rewards.
        staking.getReward();
        uint256 reward = uni.myBalance();
        if (reward == 0) return;
        // 2. Send the reward bounty to the caller.
        uint256 bounty = reward.mul(reinvestBountyBps) / 10000;
        uni.safeTransfer(msg.sender, bounty);
        // 3. Convert all the remaining rewards to ETH.
        address[] memory path = new address[](2);
        path[0] = address(uni);
        path[1] = address(weth);
        router.swapExactTokensForETH(reward.sub(bounty), 0, path, address(this), now);
        // 4. Use add ETH strategy to convert all ETH to LP tokens.
        addStrat.execute.value(address(this).balance)(address(0), 0, abi.encode(fToken, 0));
        // 5. Mint more LP tokens and stake them for more rewards.
        staking.stake(lpToken.balanceOf(address(this)));
        emit Reinvest(msg.sender, reward, bounty);
    }

    /// @dev Work on the given position. Must be called by the operator.
    /// @param id The position ID to work on.
    /// @param user The original user that is interacting with the operator.
    /// @param debt The amount of user debt to help the strategy make decisions.
    /// @param data The encoded data, consisting of strategy address and calldata.
    function work(uint256 id, address user, uint256 debt, bytes calldata data)
        external payable
        onlyOperator nonReentrant
    {
        // 1. Convert this position back to LP tokens.
        _removeShare(id);
        // 2. Perform the worker strategy; sending LP tokens + ETH; expecting LP tokens + ETH.
        (address strat, bytes memory ext) = abi.decode(data, (address, bytes));
        require(okStrats[strat], "unapproved work strategy");
        lpToken.transfer(strat, lpToken.balanceOf(address(this)));
        Strategy(strat).execute.value(msg.value)(user, debt, ext);
        // 3. Add LP tokens back to the farming pool.
        _addShare(id);
        // 4. Return any remaining ETH back to the operator.
        SafeToken.safeTransferETH(msg.sender, address(this).balance);
    }

    /// @dev Return maximum output given the input amount and the status of Uniswap reserves.
    /// @param aIn The amount of asset to market sell.
    /// @param rIn the amount of asset in reserve for input.
    /// @param rOut The amount of asset in reserve for output.
    function getMktSellAmount(uint256 aIn, uint256 rIn, uint256 rOut) public pure returns (uint256) {
        if (aIn == 0) return 0;
        require(rIn > 0 && rOut > 0, "bad reserve values");
        uint256 aInWithFee = aIn.mul(997);
        uint256 numerator = aInWithFee.mul(rOut);
        uint256 denominator = rIn.mul(1000).add(aInWithFee);
        return numerator / denominator;
    }

    /// @dev Return the amount of ETH to receive if we are to liquidate the given position.
    /// @param id The position ID to perform health check.
    function health(uint256 id) external view returns (uint256) {
        // 1. Get the position's LP balance and LP total supply.
        uint256 lpBalance = shareToBalance(shares[id]);
        uint256 lpSupply = lpToken.totalSupply(); // Ignore pending mintFee as it is insignificant
        // 2. Get the pool's total supply of WETH and farming token.
        uint256 totalWETH = weth.balanceOf(address(lpToken));
        uint256 totalfToken = fToken.balanceOf(address(lpToken));
        // 3. Convert the position's LP tokens to the underlying assets.
        uint256 userWETH = lpBalance.mul(totalWETH).div(lpSupply);
        uint256 userfToken = lpBalance.mul(totalfToken).div(lpSupply);
        // 4. Convert all farming tokens to ETH and return total ETH.
        return getMktSellAmount(
            userfToken, totalfToken.sub(userfToken), totalWETH.sub(userWETH)
        ).add(userWETH);
    }

    /// @dev Liquidate the given position by converting it to ETH and return back to caller.
    /// @param id The position ID to perform liquidation
    function liquidate(uint256 id) external onlyOperator nonReentrant {
        // 1. Convert the position back to LP tokens and use liquidate strategy.
        _removeShare(id);
        lpToken.transfer(address(liqStrat), lpToken.balanceOf(address(this)));
        liqStrat.execute(address(0), 0, abi.encode(fToken, 0));
        // 2. Return all available ETH back to the operator.
        uint256 wad = address(this).balance;
        SafeToken.safeTransferETH(msg.sender, wad);
        emit Liquidate(id, wad);
    }

    /// @dev Internal function to stake all outstanding LP tokens to the given position ID.
    function _addShare(uint256 id) internal {
        uint256 balance = lpToken.balanceOf(address(this));
        if (balance > 0) {
            uint256 share = balanceToShare(balance);
            staking.stake(balance);
            shares[id] = shares[id].add(share);
            totalShare = totalShare.add(share);
            emit AddShare(id, share);
        }
    }

    /// @dev Internal function to remove shares of the ID and convert to outstanding LP tokens.
    function _removeShare(uint256 id) internal {
        uint256 share = shares[id];
        if (share > 0) {
            uint256 balance = shareToBalance(share);
            staking.withdraw(balance);
            totalShare = totalShare.sub(share);
            shares[id] = 0;
            emit RemoveShare(id, share);
        }
    }

    /// @dev Recover ERC20 tokens that were accidentally sent to this smart contract.
    /// @param token The token contract. Can be anything. This contract should not hold ERC20 tokens.
    /// @param to The address to send the tokens to.
    /// @param value The number of tokens to transfer to `to`.
    function recover(address token, address to, uint256 value) external onlyOwner nonReentrant {
        token.safeTransfer(to, value);
    }

    /// @dev Set the reward bounty for calling reinvest operations.
    /// @param _reinvestBountyBps The bounty value to update.
    function setReinvestBountyBps(uint256 _reinvestBountyBps) external onlyOwner {
        reinvestBountyBps = _reinvestBountyBps;
    }

    /// @dev Set the given strategies' approval status.
    /// @param strats The strategy addresses.
    /// @param isOk Whether to approve or unapprove the given strategies.
    function setStrategyOk(address[] calldata strats, bool isOk) external onlyOwner {
        uint256 len = strats.length;
        for (uint256 idx = 0; idx < len; idx++) {
            okStrats[strats[idx]] = isOk;
        }
    }

    /// @dev Update critical strategy smart contracts. EMERGENCY ONLY. Bad strategies can steal funds.
    /// @param _addStrat The new add strategy contract.
    /// @param _liqStrat The new liquidate strategy contract.
    function setCriticalStrategies(Strategy _addStrat, Strategy _liqStrat) external onlyOwner {
        addStrat = _addStrat;
        liqStrat = _liqStrat;
    }

    function() external payable {}
}