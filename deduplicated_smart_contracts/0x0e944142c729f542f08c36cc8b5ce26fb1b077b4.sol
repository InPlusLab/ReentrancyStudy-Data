/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IUniswapV2Pair token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IUniswapV2Pair token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IUniswapV2Pair token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IUniswapV2Pair token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IUniswapV2Pair token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IUniswapV2Pair token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call{value: amount}(new bytes(0));
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


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


interface IERC20Custom {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function farmMint(address user, uint256 amount) external;
}


contract MoonFarm {
  using SafeMath for uint256;
  using SafeERC20 for IUniswapV2Pair;

  IUniswapV2Pair public lpToken = IUniswapV2Pair(address(0)); //Moonday-Mooncrops LP Token
  IUniswapV2Pair public cropsETHToken = IUniswapV2Pair(address(0)); //CROPS-WETH LP Token

  address weth;
  address crops;
  address moonday;

  address owner;
  address dev1;
  address dev2;
  address dev3;

  mapping(address => uint256) public refCode;
  mapping(uint256 => address) public refCodeIndex;
  uint256 public refCount = 50000000;

  mapping(address => mapping(uint256 => StakeData)) public stakeList;
  mapping(address => uint256) public stakeCount;

  struct StakeData{
    uint256 stakeTime;
    uint256 amount;
  }

  event Staked(address indexed user, uint256 amount, uint256 stakeIndex);
  event RewardPaid(address indexed user, uint256 reward);

  constructor(address _lpToken, address _cropsETHToken, address _weth, address _crops, address _moonday, address _owner, address _dev1, address _dev2, address _dev3) public {
    require(_lpToken != address(0) && _cropsETHToken != address(0) && _weth != address(0) && _crops != address(0) && _moonday != address(0), "Invalid Contract Address");
    require(_owner != address(0) && _dev1 != address(0) && _dev2 != address(0) && _dev3 != address(0), "Invalid User Address");
    lpToken = IUniswapV2Pair(_lpToken);
    cropsETHToken = IUniswapV2Pair(_cropsETHToken);
    weth = _weth;
    crops = _crops;
    moonday = _moonday;
    owner = _owner;
    dev1 = _dev1;
    dev2 = _dev2;
    dev3 = _dev3;
  }

  /// Create a refcode for the user
  /// @dev assigns a refCode value to users incrementally
  /// @return refCode number
  function createRefCode() public returns (uint256){
    require(refCode[msg.sender] == 0, "You Already Have A RefCode");
    refCode[msg.sender] = refCount;
    refCodeIndex[refCount] = msg.sender;
    refCount++;
    return refCode[msg.sender];
  }

  /// Get current reward for stake
  /// @dev calculates returnable stake amount
  /// @param _user the user to query
  /// @param _index the stake index to query
  /// @return total stake reward
  function currentReward(address _user, uint256 _index) public view returns (uint256) {
    if(stakeList[msg.sender][_index].amount == 0){
      return 0;
    }
    uint256 amount = stakeList[_user][_index].amount;
    uint256 daysPercent = (block.timestamp - stakeList[msg.sender][_index].stakeTime).div(86400).mul(7);
    uint256 minutePercent = (block.timestamp - stakeList[msg.sender][_index].stakeTime).mul(8101851);

    //
    uint moondayReserves;
    uint cropReserves;
    uint wethMReserves;
    uint wethCReserves;

    if(moonday < weth){
      (wethMReserves, moondayReserves,) = lpToken.getReserves();
    }
    else{
      (moondayReserves, wethMReserves,) = lpToken.getReserves();
    }

    if(crops < weth){
      (wethCReserves, cropReserves,) = cropsETHToken.getReserves();
    }
    else{
      (cropReserves, wethCReserves,) = cropsETHToken.getReserves();
    }

    uint256 cropsPrice = wethCReserves.mul(100000000).div(cropReserves).mul(10000000000).div(wethMReserves.mul(100000000).div(moondayReserves)).mul(100000000);
    /*
    if(daysPercent > 185){
      return cropsPrice.mul(amount).div(1 ether).mul(185).div(50);
    }
    else{
      return cropsPrice.mul(amount).div(1 ether).mul(daysPercent).div(50);
    }*/
    if(minutePercent > 18500000000000){
      return cropsPrice.mul(amount).div(1 ether).mul(18500000000000).div(5000000000000);
    }
    else{
      return cropsPrice.mul(amount).div(1 ether).mul(minutePercent).div(5000000000000);
    }
  }

  /// Stake LP token
  /// @dev stakes users LP tokens
  /// @param _amount the amount to stake
  /// @param _refCode optional referral code
  function stake(uint256 _amount, uint _refCode) public {
      require(_amount > 0, "Cannot stake 0");

      uint256 deposit = _amount.mul(7).div(10);
      stakeList[msg.sender][stakeCount[msg.sender]].amount = deposit;
      stakeList[msg.sender][stakeCount[msg.sender]].stakeTime = block.timestamp;
      lpToken.safeTransferFrom(msg.sender, address(this), deposit);
      stakeCount[msg.sender]++;

      if(refCodeIndex[_refCode] != address(0)){
        lpToken.safeTransferFrom(msg.sender, owner, _amount.mul(22).div(100));
        lpToken.safeTransferFrom(msg.sender, dev1, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev2, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev3, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, refCodeIndex[_refCode], _amount.div(20));
      }
      else{
        lpToken.safeTransferFrom(msg.sender, owner, _amount.mul(27).div(100));
        lpToken.safeTransferFrom(msg.sender, dev1, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev2, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev3, _amount.div(100));
      }

      emit Staked(msg.sender, deposit, stakeCount[msg.sender] - 1);
  }

  /// Give staker their mooncrop reward
  /// @dev calculates claim and pays user
  /// @param _index the stake to query
  /// @return dividend claimed by user
  function claim(uint256 _index) public returns(uint256){
      require(stakeList[msg.sender][_index].amount > 0, "Stake Doesnt Exist");

      uint256 reward = currentReward(msg.sender, _index);
      IERC20Custom(crops).farmMint(msg.sender, reward);
      stakeList[msg.sender][_index].amount = 0;
      emit RewardPaid(msg.sender, reward);
      return reward;
  }

}