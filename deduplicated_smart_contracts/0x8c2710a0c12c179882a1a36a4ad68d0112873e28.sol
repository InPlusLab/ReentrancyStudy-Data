/**
 *Submitted for verification at Etherscan.io on 2021-08-25
*/

// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.3.0 https://hardhat.org

// File openzeppelin-solidity/contracts/utils/[email protected]


pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File openzeppelin-solidity/contracts/access/[email protected]


pragma solidity ^0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}


// File contracts/tokens/abstract/Pausable.sol


pragma solidity 0.8.4;
abstract contract Pausable is Context, Ownable {
    uint256 private _isPaused;

    modifier notPaused {
        require(_isPaused == 0 || _msgSender() == owner(), "Paused");
        _;
    }


    function isPaused() external view returns(bool) {
        return _isPaused == 1;
    }

    function togglePause() external onlyOwner returns(bool) {
        _isPaused = 1 - _isPaused;
        return true;
    }
}


// File openzeppelin-solidity/contracts/token/ERC20/[email protected]


pragma solidity ^0.8.0;

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


// File openzeppelin-solidity/contracts/utils/math/[email protected]


pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]

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


// File @uniswap/v2-core/contracts/interfaces/[email protected]

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


// File contracts/tokens/abstract/AbstractDeflationaryToken.sol


pragma solidity 0.8.4;
abstract contract AbstractDeflationaryToken is Context, IERC20, Ownable {
    using SafeMath for uint256; // only for custom reverts on sub

    mapping (address => uint256) internal _rOwned;
    mapping (address => uint256) internal _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) internal _isExcludedFromFee;
    mapping (address => uint256) internal _isExcludedFromReward;

    uint256 private constant MAX = type(uint256).max;
    uint256 private immutable _decimals;
    uint256 internal immutable _tTotal; // real total supply
    uint256 internal _tIncludedInReward;
    uint256 internal _rTotal;
    uint256 internal _rIncludedInReward;
    uint256 internal _tFeeTotal;

    uint256 public _taxHolderFee;

    uint256 public _maxTxAmount;

    string private _name; 
    string private _symbol;

    constructor ( 
        string memory tName, 
        string memory tSymbol, 
        uint256 totalAmount,
        uint256 tDecimals, 
        uint256 tTaxHolderFee, 
        uint256 maxTxAmount
        ) {
        _name = tName;
        _symbol = tSymbol;
        _tTotal = totalAmount;
        _tIncludedInReward = totalAmount;
        _rTotal = (MAX - (MAX % totalAmount));
        _decimals = tDecimals;
        _taxHolderFee = tTaxHolderFee;
        _maxTxAmount = maxTxAmount != 0 ? maxTxAmount : type(uint256).max;

        _rOwned[_msgSender()] = _rTotal;
        _rIncludedInReward = _rTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = 1;
        _isExcludedFromFee[address(this)] = 1;

        emit Transfer(address(0), _msgSender(), totalAmount);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override virtual returns (uint256) {
        return _tTotal;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true; 
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account] == 1;
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account] == 1;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(_isExcludedFromReward[sender] == 0, "Forbidden for excluded addresses");
        
        uint256 rAmount = tAmount * _getRate();
        _tFeeTotal += tAmount;
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
        _rIncludedInReward -= rAmount;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = 1;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = 0;
    }

    function setTaxHolderFeePercent(uint256 taxHolderFee) external onlyOwner {
        _taxHolderFee = taxHolderFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = _tTotal * maxTxPercent / 100;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(_isExcludedFromReward[account] == 0, "Account is already excluded");
        if(_rOwned[account] != 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
            _tIncludedInReward -= _tOwned[account];
            _rIncludedInReward -= _rOwned[account];
            _rOwned[account] = 0;
            
        }
        _isExcludedFromReward[account] = 1;
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcludedFromReward[account] == 1, "Account is already included");

        _rOwned[account] = reflectionFromToken(_tOwned[account], false);
        _rIncludedInReward += _rOwned[account];
        _tIncludedInReward += _tOwned[account];
        _tOwned[account] = 0;
        _isExcludedFromReward[account] = 0;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account] == 1) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        uint256 rate = _getRate();
        if (!deductTransferFee) {
            return tAmount * rate;
        } else {
            uint256[] memory fees = _getFeesArray(tAmount, rate, true);
            (, uint256 rTransferAmount) = _getTransferAmount(tAmount, fees[0], rate);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Can't exceed total reflections");
        return rAmount / _getRate();
    }

    function _reflectHolderFee(uint256 tFee, uint256 rFee)  internal {
        if (tFee != 0) _tFeeTotal += tFee;
        if (rFee != 0) {
            _rTotal -= rFee;
            _rIncludedInReward -= rFee;
        }
    }

    function _getRate() internal view returns(uint256) {
        uint256 rIncludedInReward = _rIncludedInReward; // gas savings

        uint256 koeff = _rTotal / _tTotal;

        if (rIncludedInReward < koeff) return koeff;
        return rIncludedInReward / _tIncludedInReward;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getFeesArray(uint256 tAmount, uint256 rate, bool takeFee) internal view virtual returns(uint256[] memory fees); 

    function _getTransferAmount(uint256 tAmount, uint256 totalFeesForTx, uint256 rate) internal virtual view
    returns(uint256 tTransferAmount, uint256 rTransferAmount);

    function _recalculateRewardPool(
        bool isSenderExcluded, 
        bool isRecipientExcluded,
        uint256[] memory fees,
        uint256 tAmount,
        uint256 rAmount,
        uint256 tTransferAmount,
        uint256 rTransferAmount) internal virtual;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual;

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool ignoreBalance) internal virtual;
}


// File contracts/tokens/deflationalAutoLP/abstract/AbstractDeflationaryAutoLPToken.sol


pragma solidity 0.8.4;
abstract contract AbstractDeflationaryAutoLPToken is AbstractDeflationaryToken {
   
    uint256 public _liquidityFee;

    address public liquidityOwner;
    address public immutable poolAddress;

    uint256 constant SWAP_AND_LIQUIFY_DISABLED = 0;
    uint256 constant SWAP_AND_LIQUIFY_ENABLED = 1;
    uint256 constant IN_SWAP_AND_LIQUIFY = 2;
    uint256 LiqStatus;

    uint256 private numTokensSellToAddToLiquidity;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event LiquidityOwnerChanged(address newLiquidityOwner);


    modifier lockTheSwap {
        LiqStatus = IN_SWAP_AND_LIQUIFY;
        _;
        LiqStatus = SWAP_AND_LIQUIFY_ENABLED;
    }

    constructor ( 
        string memory tName, 
        string memory tSymbol, 
        uint256 totalAmount,
        uint256 tDecimals, 
        uint256 tTaxFee, 
        uint256 tLiquidityFee,
        uint256 maxTxAmount,
        uint256 _numTokensSellToAddToLiquidity,
        bool _swapAndLiquifyEnabled,
        address liquidityPoolAddress

        ) AbstractDeflationaryToken(
            tName,
            tSymbol,
            totalAmount,
            tDecimals,
            tTaxFee,
            maxTxAmount
        ) {
        _liquidityFee = tLiquidityFee;
        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;

        if (_swapAndLiquifyEnabled) {
            LiqStatus = SWAP_AND_LIQUIFY_ENABLED;
        }

        liquidityOwner = _msgSender();
        poolAddress = liquidityPoolAddress;
    }

    receive() external virtual payable {}

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setNumTokensSellToAddToLiquidity(uint256 newNumTokensSellToAddToLiquidity) external onlyOwner {
        numTokensSellToAddToLiquidity = newNumTokensSellToAddToLiquidity;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        LiqStatus = _enabled ? 1 : 0;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setLiquidityOwner(address newLiquidityOwner) external onlyOwner {
        liquidityOwner = newLiquidityOwner;
        emit LiquidityOwnerChanged(newLiquidityOwner);
    }

    function _takeLiquidity(uint256 tLiquidity, uint256 rate) internal {
        if (tLiquidity == 0) return;
        
        if(_isExcludedFromReward[address(this)] == 1) {
            _tOwned[address(this)] += tLiquidity;
            _tIncludedInReward -= tLiquidity;
            _rIncludedInReward -= tLiquidity * rate;
        }
        else {
            _rOwned[address(this)] += tLiquidity * rate;
        }
    }
    function _getTransferAmount(uint256 tAmount, uint256 totalFeesForTx, uint256 rate) internal virtual override view 
    returns(uint256 tTransferAmount, uint256 rTransferAmount) {
        tTransferAmount = tAmount - totalFeesForTx;
        rTransferAmount = tTransferAmount * rate;
    }

    function _recalculateRewardPool(
        bool isSenderExcluded, 
        bool isRecipientExcluded,
        uint256[] memory fees,
        uint256 tAmount,
        uint256 rAmount,
        uint256 tTransferAmount,
        uint256 rTransferAmount) internal virtual override{

        if (isSenderExcluded) {
            if (isRecipientExcluded) {
                _tIncludedInReward += fees[0];
                _rIncludedInReward += fees[1];  
            } else {
                _tIncludedInReward += tAmount;
                _rIncludedInReward += rAmount;              
            }
        } else {
            if (isRecipientExcluded) {
                if (!isSenderExcluded) {
                    _tIncludedInReward -= tTransferAmount;
                    _rIncludedInReward -= rTransferAmount;
                }
            }
        }
    }

   
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "Transfer amount can't be zero");

        address __owner = owner();
        if(from != __owner && to != __owner)
            require(amount <= _maxTxAmount, "Amount exceeds the maxTxAmount");


        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 _numTokensSellToAddToLiquidity = numTokensSellToAddToLiquidity; // gas savings
        if (
            balanceOf(address(this)) >= _numTokensSellToAddToLiquidity &&
            _maxTxAmount >= _numTokensSellToAddToLiquidity &&
            LiqStatus == SWAP_AND_LIQUIFY_ENABLED &&
            from != poolAddress
        ) {
            //add liquidity
            _swapAndLiquify(_numTokensSellToAddToLiquidity);
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        bool takeFee = _isExcludedFromFee[from] == 0 && _isExcludedFromFee[to] == 0;

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee, false);
    }

    function _swapAndLiquify(uint256 contractTokenBalance) internal virtual;

    function _swapTokensForEth(uint256 tokenAmount) internal virtual;

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal virtual;
    
    function _getFeesArray(uint256 tAmount, uint256 rate, bool takeFee) internal view override virtual returns(uint256[] memory fees) {
        fees = new uint256[](5);
        if (takeFee) {
            // Holders fee
            fees[2] = tAmount * _taxHolderFee / 100; // t
            fees[3] = fees[2] * rate;                // r

            // liquidity fee
            fees[4] = tAmount * _liquidityFee / 100; // t

            // Total fees
            fees[0] = fees[2] + fees[4];             // t
            fees[1] = fees[3] + fees[4] * rate;      // r
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool ignoreBalance)
    internal override virtual {
            
        uint256 rate = _getRate();
        uint256 rAmount = amount * rate;
        uint256[] memory fees = _getFeesArray(amount, rate, takeFee);

        (uint256 tTransferAmount, uint256 rTransferAmount) = _getTransferAmount(amount, fees[0], rate);

        {
            bool isSenderExcluded = _isExcludedFromReward[sender] == 1;
            bool isRecipientExcluded = _isExcludedFromReward[recipient] == 1;

            if (isSenderExcluded) {
                _tOwned[sender] -= ignoreBalance ? 0 : amount;
            } else {
                _rOwned[sender] -= ignoreBalance ? 0 : rAmount;
            }

            if (isRecipientExcluded) {
                _tOwned[recipient] += tTransferAmount;
            } else {
                _rOwned[recipient] += rTransferAmount;
            }

            if (!ignoreBalance) _recalculateRewardPool( 
                isSenderExcluded, 
                isRecipientExcluded, 
                fees,
                amount, 
                rAmount,
                tTransferAmount,
                rTransferAmount);
        }

        _takeLiquidity(fees[4], rate);
        _reflectHolderFee(fees[2], fees[3]);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}


// File contracts/tokens/abstract/AbstractBurnableDeflToken.sol


pragma solidity 0.8.4;
abstract contract AbstractBurnableDeflToken is AbstractDeflationaryToken {
    uint256 public totalBurned;

    function burn(uint256 amount) external {
        require(balanceOf(_msgSender()) >= amount, 'Not enough tokens');
        totalBurned += amount;

        if(_isExcludedFromReward[_msgSender()] == 1) {
            _tOwned[_msgSender()] -= amount;
        }
        else {
            uint256 rate = _getRate();
            _rOwned[_msgSender()] -= amount * rate;
            _tIncludedInReward -= amount;
            _rIncludedInReward -= amount * rate;
        }
    }
}


// File contracts/tokens/abstract/AbstractAutoBurnableDeflToken.sol


pragma solidity 0.8.4;
abstract contract AbstractAutoBurnableDeflToken is AbstractBurnableDeflToken {
    uint256 public burnFee;

    function setBurnFee(uint256 newBurnFee) external onlyOwner {
        burnFee = newBurnFee;
    }

    function _getTransferAmount(uint256 tAmount, uint256 totalFeesForTx, uint256 rate) 
    internal override virtual view 
    returns(uint256 tTransferAmount, uint256 rTransferAmount) {
        if (totalFeesForTx != 0) {
            tTransferAmount = tAmount - totalFeesForTx - tAmount * burnFee/100;
        } else {
            tTransferAmount = tAmount;
        }
        rTransferAmount = tTransferAmount * rate;
    }

    function _recalculateRewardPool(
        bool isSenderExcluded, 
        bool isRecipientExcluded,
        uint256[] memory fees,
        uint256 tAmount,
        uint256 rAmount,
        uint256 tTransferAmount,
        uint256 rTransferAmount) internal override virtual {

        uint256 burned;
        if (fees[0] != 0) {
            burned = tAmount * burnFee/100;
            totalBurned += burned;
        }

        if (isSenderExcluded) {
            if (isRecipientExcluded) {
                _tIncludedInReward += fees[0];
                _rIncludedInReward += fees[1];  
            } else {
                
                _tIncludedInReward += tAmount - burned;
                _rIncludedInReward += rAmount - burned * (rAmount/tAmount);   
                          
            }
        } else {
            if (isRecipientExcluded) {
                if (!isSenderExcluded) {
                    _tIncludedInReward -= tTransferAmount;
                    _rIncludedInReward -= rTransferAmount;
                }
            }
        }
    }

}


// File contracts/tokens/deflationalAutoLP/UniswapV2/DeflationaryAutoLPToken.sol


pragma solidity 0.8.4;
contract DeflationaryAutoLPToken is AbstractDeflationaryAutoLPToken {

    IUniswapV2Router02 public immutable uniswapV2Router;
    address private immutable WETH;
    bool private immutable isToken0;

    constructor ( 
        string memory tName, 
        string memory tSymbol, 
        uint256 totalAmount,
        uint256 tDecimals, 
        uint256 tTaxFee, 
        uint256 tLiquidityFee,
        uint256 maxTxAmount,
        uint256 _numTokensSellToAddToLiquidity,
        bool _swapAndLiquifyEnabled,

        address tUniswapV2Router
        ) AbstractDeflationaryAutoLPToken (
            tName,
            tSymbol,
            totalAmount,
            tDecimals,
            tTaxFee,
            tLiquidityFee,
            maxTxAmount,
            _numTokensSellToAddToLiquidity,
            _swapAndLiquifyEnabled,
            IUniswapV2Factory(IUniswapV2Router02(tUniswapV2Router).factory())
                .createPair(address(this), IUniswapV2Router02(tUniswapV2Router).WETH()) // Create a uniswap pair for this new token
        ) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(tUniswapV2Router);
        uniswapV2Router = _uniswapV2Router;
        WETH = _uniswapV2Router.WETH();
        isToken0 = address(this) < _uniswapV2Router.WETH();
    }

    function withdrawStuckFunds() external onlyOwner {
        // normally balance of contract always should be zero
        // but slippage in _addLiquidity is possible
        payable(owner()).transfer(address(this).balance);
    }

    // try to find such amount for sale that there is nothing left in the remainder after liquify
    // it is not always possible to do it perfectly
    function getOptimalAmountToSell(int X, int dX) private pure returns(uint256) {
        int feeDenom = 1000000;
        int f = 997000; // 1 - fee
        unchecked {
            int T1 = X*(X*(feeDenom + f)**2 + 4*feeDenom*dX*f);

            // square root
            int z = (T1 + 1) / 2;
            int sqrtT1 = T1;
            while (z < sqrtT1) {
                sqrtT1 = z;
                z = (T1 / z + z) / 2;
            }

            return uint(
                ( 2*feeDenom*dX*X )/
                ( sqrtT1 + X*(feeDenom + f) )
            );
        }
    }

    function _swapAndLiquify(uint256 contractTokenBalance) internal override lockTheSwap {
        (uint256 r0, uint256 r1,) = IUniswapV2Pair(poolAddress).getReserves();
        // split the contract balance into halves
        uint256 half = getOptimalAmountToSell(isToken0 ? int(r0) : int(r1), int(contractTokenBalance));
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 currentBalance = address(this).balance;

        // swap tokens for ETH
        _swapTokensForEth(half);

        // how much ETH did we just swap into?
        currentBalance = address(this).balance - currentBalance;

        // add liquidity to uniswap
        _addLiquidity(otherHalf, currentBalance);

        emit SwapAndLiquify(half, currentBalance, otherHalf);
    }

    function _swapTokensForEth(uint256 tokenAmount) internal override {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal override {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityOwner,
            block.timestamp
        );
    }
}


// File contracts/tokens/abstract/FeeToAddress.sol


pragma solidity 0.8.4;
abstract contract FeeToAddress is Ownable {
    uint256 public feeToAddress;
    address public feeBeneficiary;

    event FeeBeneficiaryChanged(address newBeneficiary);

    function setToAddressFee(uint256 newFeeToAddressPercent) external onlyOwner {
        feeToAddress = newFeeToAddressPercent;
    }

    function setFeeBeneficiary(address newBeneficiary) external onlyOwner {
        feeBeneficiary = newBeneficiary;
        emit FeeBeneficiaryChanged(newBeneficiary);
    }

}


// File contracts/tokens/deflationalAutoLP/UniswapV2/extensions/FeeToAddr/FeeToAddr.sol


pragma solidity 0.8.4;
contract FeeToAddrDeflAutoLPToken is DeflationaryAutoLPToken, FeeToAddress {
    constructor(
        string memory tName, 
        string memory tSymbol, 
        uint256 totalAmount,
        uint256 tDecimals, 
        uint256 tTaxFee, 
        uint256 tLiquidityFee,
        uint256 maxTxAmount,
        uint256 _numTokensSellToAddToLiquidity,
        bool _swapAndLiquifyEnabled,
        address tUniswapV2Router
    ) DeflationaryAutoLPToken(
        tName,
        tSymbol,
        totalAmount,
        tDecimals,
        tTaxFee,
        tLiquidityFee,
        maxTxAmount,
        _numTokensSellToAddToLiquidity,
        _swapAndLiquifyEnabled,
        tUniswapV2Router) {
    }

    function _getFeesArray(uint256 tAmount, uint256 rate, bool takeFee) 
    internal view override virtual returns(uint256[] memory fees) {
        fees = super._getFeesArray(tAmount, rate, takeFee);

        if (takeFee) {
            uint256 _feeSize = feeToAddress * tAmount / 100; // gas savings
            fees[0] += _feeSize; // increase totalFee
            fees[1] += _feeSize * rate; // increase totalFee reflections
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool ignoreBalance) internal override virtual {
        if (takeFee) {
            uint256 _feeSize = feeToAddress * amount / 100; // gas savings
            super._tokenTransfer(sender, feeBeneficiary, _feeSize, false, true); // cannot take fee - circular transfer
        }
        super._tokenTransfer(sender, recipient, amount, takeFee, ignoreBalance);
    }
}


// File contracts/tokens/deflationalAutoLP/UniswapV2/extensions/FeeToAddr/AutoBurnableFeeToAddr.sol


pragma solidity 0.8.4;
contract AutoBurnableFeeToAddrDeflAutoLPToken is FeeToAddrDeflAutoLPToken, AbstractAutoBurnableDeflToken {

    constructor(
        string memory tName, 
        string memory tSymbol, 
        uint256 totalAmount,
        uint256 tDecimals, 
        uint256 tTaxFee, 
        uint256 tLiquidityFee,
        uint256 maxTxAmount,
        uint256 _numTokensSellToAddToLiquidity,
        bool _swapAndLiquifyEnabled,
        address tUniswapV2Router,
        uint256 burnFeePercent
    ) FeeToAddrDeflAutoLPToken(
        tName,
        tSymbol,
        totalAmount,
        tDecimals,
        tTaxFee,
        tLiquidityFee,
        maxTxAmount,
        _numTokensSellToAddToLiquidity,
        _swapAndLiquifyEnabled,
        tUniswapV2Router) {
        
        burnFee = burnFeePercent;
    }

    function totalSupply() external view override returns(uint256) {
        return _tTotal - totalBurned;
    }

    function _getTransferAmount(uint256 tAmount, uint256 totalFeesForTx, uint256 rate) 
    internal override(AbstractDeflationaryAutoLPToken, AbstractAutoBurnableDeflToken) view 
    returns(uint256 tTransferAmount, uint256 rTransferAmount) {
        (tTransferAmount, rTransferAmount) = super._getTransferAmount(tAmount, totalFeesForTx, rate);
    }

    function _recalculateRewardPool(
        bool isSenderExcluded, 
        bool isRecipientExcluded,
        uint256[] memory fees,
        uint256 tAmount,
        uint256 rAmount,
        uint256 tTransferAmount,
        uint256 rTransferAmount) internal override(AbstractDeflationaryAutoLPToken, AbstractAutoBurnableDeflToken) {

        super._recalculateRewardPool(
            isSenderExcluded,
            isRecipientExcluded,
            fees,
            tAmount,
            rAmount,
            tTransferAmount,
            rTransferAmount
        );
    }
}


// File contracts/tokens/deflationalAutoLP/UniswapV2/extensions/FeeToAddr/ELONM_constructed.sol


pragma solidity 0.8.4;
contract ELONM is AutoBurnableFeeToAddrDeflAutoLPToken, Pausable {
    constructor(
        string memory tName, 
        string memory tSymbol, 
        uint256 totalAmount,
        uint256 tDecimals, 
        uint256 tTaxFee, 
        uint256 tLiquidityFee,
        uint256 maxTxAmount,
        uint256 _numTokensSellToAddToLiquidity,
        bool _swapAndLiquifyEnabled,
        address tUniswapV2Router,
        uint256 burnFeePercent
    ) AutoBurnableFeeToAddrDeflAutoLPToken(
        tName,
        tSymbol,
        totalAmount,
        tDecimals,
        tTaxFee,
        tLiquidityFee,
        maxTxAmount,
        _numTokensSellToAddToLiquidity,
        _swapAndLiquifyEnabled,
        tUniswapV2Router,
        burnFeePercent) {
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override notPaused {
        super._transfer(from, to, amount);
    }
}