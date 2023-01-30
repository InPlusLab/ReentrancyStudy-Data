/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

pragma solidity 0.6.10;

library SafeMath {
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
   *
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
   *
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
   *
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
   *
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
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
   *
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
   *
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

// Interface to the UniswapV2Router02
interface Router {
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] memory path, address to, uint256 deadline) external;
  function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external;
}

// Interface to the UST/MQQQ liquidity pool
interface lpPool {
  function stake(uint256 countryID) external;
  function balanceOf(address account) external view returns(uint256);
}

contract StrategyDAI {
  using SafeMath for uint256;

  lpPool public pool;
  Router public uni;
  IERC20 public dai;
  IERC20 public ust;
  IERC20 public mQQQ;
  address public owner;
  address public lpAddress   = address(0xc1d2ca26A59E201814bF6aF633C3b3478180E91F);
  address public uniAddress  = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address public daiAddress  = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  address public ustAddress  = address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD);
  address public mQQQAddress = address(0x13B02c8dE71680e71F0820c996E4bE43c2F57d15);

  address[] pathOne;
  address[] pathTwo;

  constructor () public {
    owner = msg.sender;
    pool = lpPool(lpAddress);
    uni  = Router(uniAddress);
    dai  = IERC20(daiAddress);
    ust  = IERC20(ustAddress);
    mQQQ = IERC20(mQQQAddress);
  }

  uint256 public precision = 10;

  function changePrecision(uint256 _value) public {
    require(msg.sender == owner);
    precision = _value;
  }

  function setPaths() public {
    require(msg.sender == owner);
    pathOne.push(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
    pathOne.push(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
    pathOne.push(address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD));
    pathTwo.push(address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD));
    pathTwo.push(address(0x13B02c8dE71680e71F0820c996E4bE43c2F57d15));
  }

  function implement(uint256 _rate) external {
    // swap DAI to UST -- minimum returned is 90%
    uint256 _dai = dai.balanceOf(msg.sender);
    uni.swapExactTokensForTokens(_dai, _dai.mul(9000).div(10000), pathOne, msg.sender, block.timestamp.add(3600));
    // swap 50% UST to MQQQ
    uint256 half = ust.balanceOf(msg.sender).mul(5000).div(10000);
    uni.swapExactTokensForTokens(half, half.mul(1).div(1000), pathTwo, msg.sender, block.timestamp.add(3600)); 
    // add liquidity.
    uint256 desiredA = ust.balanceOf(msg.sender).mul(precision).div(_rate);
    uint256 desiredB = ust.balanceOf(msg.sender);
    uint256 minA = desiredA.mul(9000).div(10000);
    uint256 minB = desiredB.mul(9000).div(10000);
    uni.addLiquidity(mQQQAddress, ustAddress, desiredA, desiredB, minA, minB, msg.sender, block.timestamp.add(3600));
    // get amount of lp tokens and stake them.
    uint256 lpBalance = pool.balanceOf(msg.sender);
    pool.stake(lpBalance);
  }

  function withdrawFailsafe(IERC20 _token, address _to) public {
    require(msg.sender == owner);
    IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
  }
}