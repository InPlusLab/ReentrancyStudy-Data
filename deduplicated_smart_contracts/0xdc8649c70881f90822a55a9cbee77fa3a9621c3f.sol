/**
 *Submitted for verification at Etherscan.io on 2021-06-13
*/

// SPDX-License-Identifier: Apache-2.0
// SPDX-License-Identifier: MIT

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
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


//ownerable

contract Ownable is Context {
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


contract Staking is Ownable{
    using SafeMath for uint256;
    
    event Withdraw(address a,uint256 amount);
    event Stake(address a,uint256 amount,uint256 unlocktime);
    
    struct staker{
        uint256 amount;
        uint256 lockedtime;
        uint256 rate;
    }
    
    mapping (address => staker) public _stakers;
    
    
    //staking steps
    uint256[] private times;
    uint256[] private rates;
    
    //locked balance in contract
    uint256 public lockedBalance;
    
    //buyforstaking
    
    IERC20 public usdt = IERC20 (0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 public weth =IERC20 (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public atari = IERC20 (0xdacD69347dE42baBfAEcD09dC88958378780FB62);
    
    address private pairAtariEth = 0xc4d9102e36c5063b98010A03C1F7C8bD44c32A00;
    address public pairEthUsdt = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852;
    
    constructor(){
        times.push(2592000);
        times.push(7776000);
        times.push(15552000);
        times.push(31104000);
        rates.push(1);
        rates.push(5);
        rates.push(12);
        rates.push(30);
        
    }
    
    function stake(uint256 amount,uint256 stakestep) external {
        require(_stakers[msg.sender].amount==0,"already stake exist");
        require(amount!=0 ,"amount must not 0");
        require(times[stakestep]!=0,"lockedtime must not 0");
        
        atari.transferFrom(msg.sender,address(this),amount);
        
        uint256 lockBalance=amount.mul(rates[stakestep].add(100)).div(100);
        lockedBalance=lockedBalance.add(lockBalance);
        
        require(lockedBalance<atari.balanceOf(address(this)),"Stake : staking is full");
        
        _stakers[msg.sender]= staker(lockBalance,block.timestamp.add(times[stakestep]),rates[stakestep]);
        
        emit Stake(msg.sender,lockBalance,block.timestamp.add(times[stakestep]));
    }
    
    function withdraw() external {
        require(_stakers[msg.sender].amount>0,"there is no staked amount");
        require(_stakers[msg.sender].lockedtime<block.timestamp,"not ready to withdraw");
        
        lockedBalance=lockedBalance.sub(_stakers[msg.sender].amount);
        atari.transfer(msg.sender,_stakers[msg.sender].amount);
        _stakers[msg.sender]=staker(0,0,0);
    }
    
    function getlocktime(address a)external view returns (uint256){
        if(block.timestamp>_stakers[a].lockedtime)
            return 0;
        return _stakers[a].lockedtime.sub(block.timestamp);
    }
    
    function getamount(address a)external view returns(uint256){
        return _stakers[a].amount;
    }
    
    function getTotoalAmount() external view returns(uint256){
       return atari.balanceOf(address(this));
    }
    
    
    //for Owner
    function withdrawOwner(uint256 amount) external onlyOwner{
        require(amount<atari.balanceOf(address(this)).sub(lockedBalance));
        atari.transfer(_msgSender(),amount);
    }
    
    function withdrawOwnerETH(uint256 amount) external payable onlyOwner{
        require(address(this).balance>amount);
        _msgSender().transfer(amount);    
    }
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'Uniswap: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'Uniswap: INSUFFICIENT_LIQUIDITY');
        uint numerator = amountIn.mul(reserveOut);
        uint denominator = reserveIn.add(amountIn);
        amountOut = numerator / denominator;
    }
    
    
    
    function tokenPriceOut(uint256 amountin) public view returns(uint256){
        
        uint256 ethAmount = weth.balanceOf(pairAtariEth);
        uint256 atariAmount = atari.balanceOf(pairAtariEth);
        
        return getAmountOut(amountin,ethAmount,atariAmount);
    }
    
    function tokenPriceOutUsdt(uint256 amountin) public view returns(uint256){
        
        //get eth amount with usdt amount
        uint256 ethAmount = weth.balanceOf(pairEthUsdt);
        uint256 usdtAmount = usdt.balanceOf(pairEthUsdt);
        
        uint256 amountin1 = getAmountOut(amountin,usdtAmount,ethAmount);
        
        uint256 ethAmount1 = weth.balanceOf(pairAtariEth);
        uint256 atariAmount = atari.balanceOf(pairAtariEth);
        
        return getAmountOut(amountin1,ethAmount1,atariAmount);
    }
    

    
    function buyforstakingwithexactEHTforToken(uint256 stakestep) external payable {
        uint256 tokenAmount=tokenPriceOut(msg.value.mul(100).div(100-rates[stakestep]));
        
        lockedBalance=lockedBalance.add(tokenAmount);
        require(lockedBalance<atari.balanceOf(address(this)),"Stake : staking is full");
        _stakers[msg.sender]=staker(tokenAmount,block.timestamp.add(times[stakestep]),rates[stakestep]);
        payable(owner()).transfer(msg.value);
        emit Stake(msg.sender,tokenAmount,block.timestamp.add(times[stakestep]));
    }
    
    function buyforstakingwithexactUsdtforToken(uint256 amount, uint256 stakestep) external {
        
        uint256 tokenAmount=tokenPriceOutUsdt(amount.mul(100).div(100-rates[stakestep]));
        usdt.transferFrom(msg.sender,owner(),amount);
        lockedBalance=lockedBalance.add(tokenAmount);
        require(lockedBalance<atari.balanceOf(address(this)),"Stake : staking is full");
        _stakers[msg.sender]=staker(tokenAmount,block.timestamp.add(times[stakestep]),rates[stakestep]);
        
        emit Stake(msg.sender,tokenAmount,block.timestamp.add(times[stakestep]));
    }
    
    function buy() external payable {
        uint256 tokenAmount=tokenPriceOut(msg.value);
        require(atari.balanceOf(address(this)).sub(lockedBalance)>tokenAmount, "stake: atari balance not enough");
        atari.transfer(msg.sender,tokenAmount);
        payable(owner()).transfer(msg.value);
    }
    
    function buyforUsdt(uint256 amount) external  {
        uint256 tokenAmount=tokenPriceOutUsdt(amount);
        require(atari.balanceOf(address(this)).sub(lockedBalance)>tokenAmount, "stake: atari balance not enough");
        atari.transfer(msg.sender,tokenAmount);
        usdt.transferFrom(msg.sender,owner(),amount);
    }
    
    
    // function buyforstakingwithEHTforexactToken(uint256 amountOut,uint256 stakestep) external payable {
        
    //     uint256 ETHAmount=tokenPriceIn(amountOut).mul(100-rates[stakestep]).div(100);
    //     require(ETHAmount==msg.value,"buyforstaking : wrong ETH amount");
        
    //     lockedBalance=lockedBalance.add(amountOut);
    //     _stakers[msg.sender]=staker(amountOut,block.timestamp.add(times[stakestep]),rates[stakestep]);
        
    //     emit Stake(msg.sender,amountOut,block.timestamp.add(times[stakestep]));
    // }
    
}