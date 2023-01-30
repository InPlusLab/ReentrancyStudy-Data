/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

/*
 * Copyright (c) The Force Protocol Development Team
 * Submitted for verification at Etherscan.io on 2019-09-17
*/

pragma solidity ^0.5.13;
// pragma experimental ABIEncoderV2;

contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}
// import "./ReentrancyGuard.sol";

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "uint mul overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "uint div by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "uint sub overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "uint add overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "uint mod by zero");
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}


library address_make_payable {
  function make_payable(address x) internal pure returns (address payable) {
    return address(uint160(x));
  }
}

contract IOracle {
  function get(address token) external view returns (uint, bool);
}

contract IInterestRateModel {
  function getLoanRate(int cash, int borrow) external view returns (int y);
  function getDepositRate(int cash, int borrow) external view returns (int y);

  function calculateBalance(int principal, int lastIndex, int newIndex) external view returns (int y);
  function calculateInterestIndex(int Index, int r, int t) external view returns (int y);
  function pert(int principal, int r, int t) external view returns (int y);
  function getNewReserve(int oldReserve, int cash, int borrow, int blockDelta) external view returns (int y);
}

contract PoolPawn is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using address_make_payable for address;

    address public admin; //the admin address
    address public proposedAdmin;//use pull over push pattern for admin

    uint256 public constant interestRateDenomitor = 1e18;

    /**
      * @notice Container for borrow balance information
      * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
      * @member interestIndex Global borrowIndex as of the most recent balance-changing action
      */
    //存款/贷款本金和利息
    struct Balance {
        uint principal;
        uint interestIndex;

        uint totalPnl;//total profit and loss
    }

    struct Market {
      uint accrualBlockNumber;
      int supplyRate;//存款利率
      int demondRate;//借款利率

      IInterestRateModel irm;

      uint totalSupply;
      uint supplyIndex;

      uint totalBorrows;
      uint borrowIndex;

      uint totalReserves;//系统盈利

      uint minPledgeRate;//最小质押率
      uint liquidationDiscount;//清算折扣

      uint decimals;//币种的最小精度
    }

    // 存币与借币的映射关系
    mapping (address => mapping (address => Balance)) public accountSupplySnapshot;//tokenContract->address(usr)->SupplySnapshot
    mapping (address => mapping (address => Balance)) public accountBorrowSnapshot;//tokenContract->address(usr)->BorrowSnapshot

    struct LiquidateInfo {
        address targetAccount;//被清算账户
        address liquidator;//清算人
        address assetCollatera;//抵押物token地址
        address assetBorrow;//债务token地址
        uint256 liquidateAmount;//清算额度，抵押物
        uint256 targetAmount;//目标额度, 债务
        uint256 timestamp;
    }

    mapping (uint => LiquidateInfo) public liquidateInfoMap;
    uint public liquidateIndexes;

    function setLiquidateInfoMap(address _targetAccount, address _liquidator, address _assetCollatera, address _assetBorrow, uint256 x, uint256 y) internal {
        //更新清算的历史记录Map
        liquidateInfoMap[liquidateIndexes].targetAccount = _targetAccount;
        liquidateInfoMap[liquidateIndexes].liquidator = _liquidator;
        liquidateInfoMap[liquidateIndexes].assetCollatera = _assetCollatera;
        liquidateInfoMap[liquidateIndexes].assetBorrow = _assetBorrow;
        liquidateInfoMap[liquidateIndexes].liquidateAmount = x;
        liquidateInfoMap[liquidateIndexes].targetAmount = y;
        liquidateInfoMap[liquidateIndexes].timestamp = now;

        liquidateIndexes++;
    }

    //user table
    mapping (uint256 => address) public accounts;
    mapping (address => uint256) public indexes;
    uint256 public index = 1;
    // 添加用户
    function join(address who) internal {
      if (indexes[who] == 0) {
        accounts[index] = who;
        indexes[who] = index;
        ++index;
      }
    }

    event SupplyPawnLog(address usr, address t, uint amount, uint beg, uint end);
    event WithdrawPawnLog(address usr, address t, uint amount, uint beg, uint end);
    event BorrowPawnLog(address usr, address t, uint amount, uint beg, uint end);
    event RepayFastBorrowLog(address usr, address t, uint amount, uint beg, uint end);
    event LiquidateBorrowPawnLog(
      address usr, address tBorrow, uint endBorrow,
      address liquidator, address tCol, uint endCol);
    event WithdrawPawnEquityLog(address t, uint equityAvailableBefore, uint amount, address owner);


    mapping (address => Market) public mkts;//tokenAddress->Market
    address[] public collateralTokens;//抵押币种
    IOracle public oracleInstance;

    uint public constant initialInterestIndex = 10 ** 18;
    uint public constant defaultOriginationFee = 0; // default is zero bps
    uint public constant originationFee = 0;
    uint public constant ONE_ETH = 1 ether;

    //增加抵押币种，WBTC，ETH，TBTC
    function addCollateralMarket(address asset) public onlyAdmin {
      for (uint i = 0; i < collateralTokens.length; i++) {
        if (collateralTokens[i] == asset) {
          return;
        }
      }
      collateralTokens.push(asset);
    }

    function getCollateralMarketsLength() external view returns (uint) {
      return collateralTokens.length;
    }

    function setInterestRateModel(address t, address irm) public onlyAdmin {
      mkts[t].irm = IInterestRateModel(irm);
    }

    function setMinPledgeRate(address t, uint minPledgeRate) external onlyAdmin {
      mkts[t].minPledgeRate = minPledgeRate;
    }

    function setLiquidationDiscount(address t, uint liquidationDiscount) external onlyAdmin {
      mkts[t].liquidationDiscount = liquidationDiscount;
    }

    function initCollateralMarket(address t, address irm, address oracle, uint decimals) external onlyAdmin {
      if (address(oracleInstance) == address(0)) {
        setOracle(oracle);
      }

      if (address(mkts[t].irm) == address(0)) {
        setInterestRateModel(t, irm);
      }

      addCollateralMarket(t);
      if (mkts[t].supplyIndex == 0) {
        mkts[t].supplyIndex = initialInterestIndex;
      }

      if (mkts[t].borrowIndex == 0) {
        mkts[t].borrowIndex = initialInterestIndex;
      }

      if (mkts[t].decimals == 0) {
        mkts[t].decimals = decimals;
      }
    }

constructor() public {
  admin = msg.sender;
}

//Starting from Solidity 0.4.0, contracts without a fallback function automatically revert payments, making the code above redundant.
// function() external payable {
//   revert("fallback can't be payable");
// }

modifier onlyAdmin() {
  require(msg.sender == admin, "only admin can do this!");
  _;
}

function proposeNewAdmin(address admin_) external onlyAdmin {
    proposedAdmin = admin_;
}

function claimAdministration() external {
    require(msg.sender == proposedAdmin, "Not proposed admin.");
    admin = proposedAdmin;
    proposedAdmin = address(0);
}

    //设置USDT，DAI和抵押品的起始时间戳
    function setInitialTimestamp(address token) external onlyAdmin {
      mkts[token].accrualBlockNumber = now;
    }

    function setDecimals(address t, uint decimals) external onlyAdmin {
      mkts[t].decimals = decimals;
    }

    function setOracle(address oracle) public onlyAdmin {
      oracleInstance = IOracle(oracle);
    }

    modifier existOracle() {
      require(address(oracleInstance) != address(0), "oracle not set");
      _;
    }

    // 从预言机获取币种价格
    function fetchAssetPrice(address asset) public view returns (uint, bool) {
      require(address(oracleInstance) != address(0), "oracle not set");
      return oracleInstance.get(asset);
    }

    // 计算 assetAmount 数量的币种价格
    function getPriceForAssetAmount(address asset, uint assetAmount) public view returns (uint) {
      require(address(oracleInstance) != address(0), "oracle not set");
      (uint price, bool ok) = fetchAssetPrice(asset);
      require(ok && price > 0, "invalid token price");
      return price.mul(assetAmount).div(10**mkts[asset].decimals);
    }

    // 计算 usdValue 价值的币种数量
    function getAssetAmountForValue(address t, uint usdValue) public view returns (uint) {
      require(address(oracleInstance) != address(0), "oracle not set");
      (uint price, bool ok) = fetchAssetPrice(t);
      require(ok && price > 0, "invalid token price");
      return usdValue.mul(10**mkts[t].decimals).div(price);
    }

    //合约拥有的 t 币种余额
    function getCash(address t) public view returns (uint) {
      if (t == address(0)) {
        return address(this).balance;
      }
      IERC20 token = IERC20(t);
      return token.balanceOf(address(this));
    }

    // from 账户拥有的 asset 币种余额
    function getBalanceOf(address asset, address from) internal view returns (uint) {

      if (asset == address(0)) {
        return address(from).balance;
      }
      
      IERC20 token = IERC20(asset);

      return token.balanceOf(from);
    }

    //借存比，总借/总存 * 1e18，存贷比，贷存比
    function loanToDepositRatio(address asset) public view returns (uint) {
      uint256 loan = mkts[asset].totalBorrows;
      uint256 deposit = mkts[asset].totalSupply;
      uint256 _1 = 1 ether;

      return loan.mul(_1).div(deposit);
    }

    //m:market, a:account
    //i(n,m)=i(n-1,m)*(1+rm*t)
    //return P*(i(n,m)/i(n-1,a))
    // 计算当前 acc 用户的 t 币种存款额
    function getSupplyBalance(address acc, address t) public view returns (uint) {
      Balance storage supplyBalance = accountSupplySnapshot[t][acc];

      int mSupplyIndex = mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(now - mkts[t].accrualBlockNumber));

      uint userSupplyCurrent = uint(mkts[t].irm.calculateBalance(int(supplyBalance.principal), int(supplyBalance.interestIndex), mSupplyIndex));
      return userSupplyCurrent;
    }

    // 计算当前 who 用户 的 t 币种存款价值
    function getSupplyBalanceInUSD(address who, address t) public view returns (uint) {
      return getPriceForAssetAmount(t, getSupplyBalance(who, t));
    }

    // 计算当前总收益
    function getSupplyPnl(address acc, address t) public view returns (uint) {
      Balance storage supplyBalance = accountSupplySnapshot[t][acc];

      int mSupplyIndex = mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(now - mkts[t].accrualBlockNumber));

      uint userSupplyCurrent = uint(mkts[t].irm.calculateBalance(int(supplyBalance.principal), int(supplyBalance.interestIndex), mSupplyIndex));

      if (userSupplyCurrent > supplyBalance.principal) {
        return supplyBalance.totalPnl.add(userSupplyCurrent.sub(supplyBalance.principal));
      } else {
        return supplyBalance.totalPnl;
      }
    }

    //计算总利息（单位为美元）
    function getSupplyPnlInUSD(address who, address t) public view returns (uint) {
      return getPriceForAssetAmount(t, getSupplyPnl(who, t));
    }

    //Gets USD all token values of supply profit
    function getTotalSupplyPnl(address who) public view returns (uint) {
      uint length = collateralTokens.length;
      uint sumPnl = 0;

      for (uint i = 0; i < length; i++) {
        uint pnl = getSupplyPnlInUSD(who, collateralTokens[i]);
        sumPnl = sumPnl.add(pnl);
      }
      return sumPnl;
    }

    //m:market, a:account
    //i(n,m)=i(n-1,m)*(1+rm*t)
    //return P*(i(n,m)/i(n-1,a))
    function getBorrowBalance(address acc, address t) public view returns (uint) {
      Balance storage borrowBalance = accountBorrowSnapshot[t][acc];

      int mBorrowIndex = mkts[t].irm.pert(int(mkts[t].borrowIndex), int(mkts[t].demondRate), int(now - mkts[t].accrualBlockNumber));

      uint userBorrowCurrent = uint(mkts[t].irm.calculateBalance(int(borrowBalance.principal), int(borrowBalance.interestIndex), mBorrowIndex));
      return userBorrowCurrent;
    }

    function getBorrowBalanceInUSD(address who, address t) public view returns (uint) {
      return getPriceForAssetAmount(t, getBorrowBalance(who, t));
    }

    function getBorrowPnl(address acc, address t) public view returns (uint) {
      Balance storage borrowBalance = accountBorrowSnapshot[t][acc];

      int mBorrowIndex = mkts[t].irm.pert(int(mkts[t].borrowIndex), int(mkts[t].demondRate), int(now - mkts[t].accrualBlockNumber));

      uint userBorrowCurrent = uint(mkts[t].irm.calculateBalance(int(borrowBalance.principal), int(borrowBalance.interestIndex), mBorrowIndex));

      return borrowBalance.totalPnl.add(userBorrowCurrent).sub(borrowBalance.principal);
    }

    //计算总利息（单位为美元）
    function getBorrowPnlInUSD(address who, address t) public view returns (uint) {
      return getPriceForAssetAmount(t, getBorrowPnl(who, t));
    }

    //Gets USD all token values of borrow lose
    function getTotalBorrowPnl(address who) public view returns (uint) {
      uint length = collateralTokens.length;
      uint sumPnl = 0;

      for (uint i = 0; i < length; i++) {
        uint pnl = getBorrowPnlInUSD(who, collateralTokens[i]);
        sumPnl = sumPnl.add(pnl);
      }
      return sumPnl;
    }

    // BorrowBalance * collateral ratio
    // 用户 who 借的 t 币种的价值 * 该币种的质押率(质押率总大于1)
    function getBorrowBalanceLeverage(address who, address t) public view returns (uint) {
      return getBorrowBalanceInUSD(who,t).mul(mkts[t].minPledgeRate).div(ONE_ETH);
    }

    //Gets USD token values of supply and borrow balances
    // 返回 who 用户的 t 币种存款价值和借款价值
    function calcAccountTokenValuesInternal(address who, address t) public view returns (uint, uint) {
      return (getSupplyBalanceInUSD(who, t), getBorrowBalanceInUSD(who, t));
    }

    //Gets USD token values of supply and borrow balances
    // 返回 who 用户的 t 币种存款价值，与 借款价值质押率乘积
    function calcAccountTokenValuesLeverageInternal(address who, address t) public view returns (uint, uint) {
      return (getSupplyBalanceInUSD(who, t), getBorrowBalanceLeverage(who, t));
    }

    //Gets USD all token values of supply and borrow balances
    // 所有币种总存款价值 与 总借款价值质押率乘积
    function calcAccountAllTokenValuesLeverageInternal(address who) public view returns (uint, uint) {
      uint length = collateralTokens.length;
      uint sumSupplies;
      uint sumBorrowLeverage;

      for (uint i = 0; i < length; i++) {
        (uint supplyValue, uint borrowsLeverage) = calcAccountTokenValuesLeverageInternal(who, collateralTokens[i]);
        sumSupplies = sumSupplies.add(supplyValue);
        sumBorrowLeverage = sumBorrowLeverage.add(borrowsLeverage);
      }
      return (sumSupplies, sumBorrowLeverage);
    }

    // 计算用户此时是盈余状态还是亏欠状态，并返回差值
    function calcAccountLiquidity(address who) public view returns (uint, uint) {
      uint sumSupplies;
      uint sumBorrowsLeverage;//sumBorrows* collateral ratio
      (sumSupplies, sumBorrowsLeverage) = calcAccountAllTokenValuesLeverageInternal(who);
      if (sumSupplies < sumBorrowsLeverage) {
        return (0, sumBorrowsLeverage.sub(sumSupplies));//不足
      } else {
        return (sumSupplies.sub(sumBorrowsLeverage), 0);//有余
      }
    }

  struct SupplyIR {
      uint startingBalance;
      uint newSupplyIndex;
      uint userSupplyCurrent;
      uint userSupplyUpdated;
      uint newTotalSupply;
      uint currentCash;
      uint updatedCash;
      uint newBorrowIndex;
  }

  // 存钱
  function supplyPawn(address t, uint amount) external payable nonReentrant returns (uint) {
    uint supplyAmount = amount;
    if (t == address(0)) {
      require(amount == msg.value, "Eth value should be equal to amount");
      supplyAmount = msg.value;
    }
    SupplyIR memory tmp;
    Market storage market = mkts[t];
    Balance storage supplyBalance = accountSupplySnapshot[t][msg.sender];

    uint lastTimestamp = mkts[t].accrualBlockNumber;
    uint blockDelta = now - lastTimestamp;

    // 计算 t 币种的存款利率并更新用户的存款额
    tmp.newSupplyIndex = uint(mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(blockDelta)));
    tmp.userSupplyCurrent = uint(mkts[t].irm.calculateBalance(int(accountSupplySnapshot[t][msg.sender].principal), int(supplyBalance.interestIndex), int(tmp.newSupplyIndex)));
    tmp.userSupplyUpdated = tmp.userSupplyCurrent.add(supplyAmount);
    // 更新市场的存量
    tmp.newTotalSupply = market.totalSupply.add(tmp.userSupplyUpdated).sub(supplyBalance.principal);

    tmp.currentCash = getCash(t);
    // 如果是 ERC-20 代币，加 amount
    // 如果是 ETH，则已经在函数调用的时候转入了，就不用加了
    tmp.updatedCash = t != address(0) ? tmp.currentCash.add(supplyAmount) : tmp.currentCash;

    // 更新存借比率
    mkts[t].supplyRate = mkts[t].irm.getDepositRate(int(tmp.updatedCash), int(mkts[t].totalBorrows));
    tmp.newBorrowIndex = uint(mkts[t].irm.pert(int(mkts[t].borrowIndex), int(mkts[t].demondRate), int(blockDelta)));
    mkts[t].demondRate = mkts[t].irm.getLoanRate(int(tmp.updatedCash), int(mkts[t].totalBorrows));

    mkts[t].borrowIndex = tmp.newBorrowIndex;
    mkts[t].supplyIndex = tmp.newSupplyIndex;
    mkts[t].totalSupply = tmp.newTotalSupply;
    mkts[t].accrualBlockNumber = now;

    tmp.startingBalance = supplyBalance.principal;
    supplyBalance.principal = tmp.userSupplyUpdated;
    supplyBalance.interestIndex = tmp.newSupplyIndex;

    // 更新用户的 t 币种总收益
    if (tmp.userSupplyCurrent > tmp.startingBalance) {
      supplyBalance.totalPnl = supplyBalance.totalPnl.add(tmp.userSupplyCurrent.sub(tmp.startingBalance));
    }

    join(msg.sender);

    require(safeTransferFrom(t, msg.sender, address(this), address(this).make_payable(), supplyAmount, 0) == 0, "supply error");

    emit SupplyPawnLog(msg.sender, t, supplyAmount, tmp.startingBalance, tmp.userSupplyUpdated);
    return 0;
  }

  struct WithdrawIR {
    uint withdrawAmount;
    uint startingBalance;
    uint newSupplyIndex;
    uint userSupplyCurrent;
    uint userSupplyUpdated;
    uint newTotalSupply;
    uint currentCash;
    uint updatedCash;
    uint newBorrowIndex;

    uint accountLiquidity;
    uint accountShortfall;
    uint usdValueOfWithdrawal;
    uint withdrawCapacity;
  }

  // 取钱
  function withdrawPawn(address t, uint requestedAmount) external nonReentrant returns (uint) {
    Market storage market = mkts[t];
    Balance storage supplyBalance = accountSupplySnapshot[t][msg.sender];

    WithdrawIR memory tmp;

    uint lastTimestamp = mkts[t].accrualBlockNumber;
    uint blockDelta = now - lastTimestamp;

    // 先计算盈亏，判断是否还有能力取钱
    (tmp.accountLiquidity, tmp.accountShortfall) = calcAccountLiquidity(msg.sender);
    require(tmp.accountLiquidity > 0 && tmp.accountShortfall == 0, "can't withdraw, shortfall");
    // 更新存币的余额
    tmp.newSupplyIndex = uint(mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(blockDelta)));
    tmp.userSupplyCurrent = uint(mkts[t].irm.calculateBalance(int(supplyBalance.principal), int(supplyBalance.interestIndex), int(tmp.newSupplyIndex)));

    // 获取合约余额
    tmp.currentCash = getCash(t);
    if (requestedAmount == uint(-1)) {
      // 计算可以取的最大数量，最大数量只能为 （盈亏差值，当前币种余额，合约余额）中的较小值
      tmp.withdrawCapacity = getAssetAmountForValue(t, tmp.accountLiquidity);
      tmp.withdrawAmount = min(tmp.withdrawCapacity, tmp.userSupplyCurrent);
      tmp.withdrawAmount = min(tmp.withdrawAmount, tmp.currentCash);
    } else {
      tmp.withdrawAmount = requestedAmount;
    }

    // 更新本合约的余额
    tmp.updatedCash = tmp.currentCash.sub(tmp.withdrawAmount);
    tmp.userSupplyUpdated = tmp.userSupplyCurrent.sub(tmp.withdrawAmount);

    // 获取实际要取的币种价值
    tmp.usdValueOfWithdrawal = getPriceForAssetAmount(t, tmp.withdrawAmount);
    // 判断要取出的币种价值不能超过盈亏差值
    require(tmp.usdValueOfWithdrawal <= tmp.accountLiquidity);

    // 更新市场存量
    tmp.newTotalSupply = market.totalSupply.add(tmp.userSupplyUpdated).sub(supplyBalance.principal);

    // 更新利率
    tmp.newSupplyIndex = uint(mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(blockDelta)));

    // 更新存借比率
    market.supplyRate = mkts[t].irm.getDepositRate(int(tmp.updatedCash), int(market.totalBorrows));
    tmp.newBorrowIndex = uint(mkts[t].irm.pert(int(mkts[t].borrowIndex), mkts[t].demondRate, int(blockDelta)));
    market.demondRate = mkts[t].irm.getLoanRate(int(tmp.updatedCash), int(market.totalBorrows));


    market.accrualBlockNumber = now;
    market.totalSupply = tmp.newTotalSupply;
    market.supplyIndex = tmp.newSupplyIndex;
    market.borrowIndex = tmp.newBorrowIndex;

    tmp.startingBalance = supplyBalance.principal;
    supplyBalance.principal = tmp.userSupplyUpdated;
    supplyBalance.interestIndex = tmp.newSupplyIndex;

    safeTransferFrom(t, address(this).make_payable(), address(this), msg.sender, tmp.withdrawAmount, 0);
    
    emit WithdrawPawnLog(msg.sender, t, tmp.withdrawAmount, tmp.startingBalance, tmp.userSupplyUpdated);
    return 0;
  }

  struct PayBorrowIR {
    uint newBorrowIndex;
    uint userBorrowCurrent;
    uint repayAmount;

    uint userBorrowUpdated;
    uint newTotalBorrows;
    uint currentCash;
    uint updatedCash;

    uint newSupplyIndex;

    uint startingBalance;
  }

  function min(uint a, uint b) internal pure returns (uint) {
    if (a < b) {
        return a;
    } else {
        return b;
    }
  }

  //`(1 + originationFee) * borrowAmount`
  function calcBorrowAmountWithFee(uint borrowAmount) public pure returns (uint) {
    return borrowAmount.mul((ONE_ETH).add(originationFee)).div(ONE_ETH);
  }

  // 存币价值 * 质押率
  function getPriceForAssetAmountMulCollatRatio(address t, uint assetAmount) public view returns (uint) {
    return getPriceForAssetAmount(t, assetAmount).mul(mkts[t].minPledgeRate).div(ONE_ETH);
  }

  struct BorrowIR {
    uint newBorrowIndex;
    uint userBorrowCurrent;
    uint borrowAmountWithFee;

    uint userBorrowUpdated;
    uint newTotalBorrows;
    uint currentCash;
    uint updatedCash;

    uint newSupplyIndex;

    uint startingBalance;

    uint accountLiquidity;
    uint accountShortfall;
    uint usdValueOfBorrowAmountWithFee;
  }

  // 借钱
  function BorrowPawn(address t, uint amount) external nonReentrant returns (uint) {
    BorrowIR memory tmp;
    Market storage market = mkts[t];
    Balance storage borrowBalance = accountBorrowSnapshot[t][msg.sender];

    uint lastTimestamp = mkts[t].accrualBlockNumber;
    uint blockDelta = now - lastTimestamp;

    // 计算借币利率并更新用户借币余额
    tmp.newBorrowIndex = uint(mkts[t].irm.pert(int(mkts[t].borrowIndex), mkts[t].demondRate, int(blockDelta)));
    int lastIndex = int(borrowBalance.interestIndex);
    tmp.userBorrowCurrent = uint(mkts[t].irm.calculateBalance(int(borrowBalance.principal), lastIndex, int(tmp.newBorrowIndex)));
    // 添加借币手续费
    tmp.borrowAmountWithFee = calcBorrowAmountWithFee(amount);

    tmp.userBorrowUpdated = tmp.userBorrowCurrent.add(tmp.borrowAmountWithFee);
    // 更新市场借币余额
    tmp.newTotalBorrows = market.totalBorrows.add(tmp.userBorrowUpdated).sub(borrowBalance.principal);

    // 计算当前盈亏情况，判断是否有能力借钱
    (tmp.accountLiquidity, tmp.accountShortfall) = calcAccountLiquidity(msg.sender);
    require(tmp.accountLiquidity > 0 && tmp.accountShortfall == 0, "can't borrow, shortfall");

    // 判断要借的钱是否大于用户盈亏差值
    tmp.usdValueOfBorrowAmountWithFee = getPriceForAssetAmountMulCollatRatio(t, tmp.borrowAmountWithFee);
    require(tmp.usdValueOfBorrowAmountWithFee <= tmp.accountLiquidity, "can't borrow, without enough value");

    // 更新合约余额
    tmp.currentCash = getCash(t);
    tmp.updatedCash = tmp.currentCash.sub(amount);

    // 更新存借比率
    tmp.newSupplyIndex = uint(mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(blockDelta)));
    market.supplyRate = mkts[t].irm.getDepositRate(int(tmp.updatedCash), int(tmp.newTotalBorrows));
    market.demondRate = mkts[t].irm.getLoanRate(int(tmp.updatedCash), int(tmp.newTotalBorrows));


    market.accrualBlockNumber = now;
    market.totalBorrows = tmp.newTotalBorrows;
    market.supplyIndex = tmp.newSupplyIndex;
    market.borrowIndex = tmp.newBorrowIndex;

    tmp.startingBalance = borrowBalance.principal;
    borrowBalance.principal = tmp.userBorrowUpdated;
    borrowBalance.interestIndex = tmp.newBorrowIndex;

    // 更新币种的借币总额
    // borrowBalance.totalPnl = borrowBalance.totalPnl.add(tmp.userBorrowCurrent.sub(tmp.startingBalance));

    safeTransferFrom(t, address(this).make_payable(), address(this), msg.sender, amount, 0);

    emit BorrowPawnLog(msg.sender, t, amount, tmp.startingBalance, tmp.userBorrowUpdated);
    return 0;
  }

  // 还款，t: token
  function repayFastBorrow(address t, uint amount) external payable nonReentrant returns (uint) {
    PayBorrowIR memory tmp;
    Market storage market = mkts[t];
    Balance storage borrowBalance = accountBorrowSnapshot[t][msg.sender];

    uint lastTimestamp = mkts[t].accrualBlockNumber;
    uint blockDelta = now - lastTimestamp;

    // 计算借币利率并更新用户借的 t 币种总额
    tmp.newBorrowIndex = uint(mkts[t].irm.pert(int(mkts[t].borrowIndex), mkts[t].demondRate, int(blockDelta)));

    int lastIndex = int(borrowBalance.interestIndex);
    tmp.userBorrowCurrent = uint(mkts[t].irm.calculateBalance(int(borrowBalance.principal), lastIndex, int(tmp.newBorrowIndex)));

    if (amount == uint(-1)) {
        // 用户可以还款的最大量为（用户当前 t 币种的余额，用户当前借币 t 币种的量）中的较小值
        tmp.repayAmount = min(getBalanceOf(t, msg.sender), tmp.userBorrowCurrent);
        // 如果要还eth，用户发送的eth需要大于应还总额，多退
        if (t == address(0)) {
          require(msg.value > tmp.repayAmount, "Eth value should be larger than repayAmount");
        }
    } else {
        tmp.repayAmount = amount;
        if (t == address(0)) {
          require(msg.value == tmp.repayAmount, "Eth value should be equal to repayAmount");
        }
    }

    // 更新用户借币余额
    tmp.userBorrowUpdated = tmp.userBorrowCurrent.sub(tmp.repayAmount);
    // 更新市场借币余额
    tmp.newTotalBorrows = market.totalBorrows.add(tmp.userBorrowUpdated).sub(borrowBalance.principal);
    tmp.currentCash = getCash(t);
    // 如果是 ERC-20 代币，加 tmp.repayAmount
    // 如果是 ETH，则已经在函数调用的时候转入了，就不用加了
    tmp.updatedCash = t != address(0) ? tmp.currentCash.add(tmp.repayAmount) : tmp.currentCash;

    // 更新存借比率
    tmp.newSupplyIndex = uint(mkts[t].irm.pert(int(mkts[t].supplyIndex), int(mkts[t].supplyRate), int(blockDelta)));
    market.supplyRate = mkts[t].irm.getDepositRate(int(tmp.updatedCash), int(tmp.newTotalBorrows));
    market.demondRate = mkts[t].irm.getLoanRate(int(tmp.updatedCash), int(tmp.newTotalBorrows));

    market.accrualBlockNumber = now;
    market.totalBorrows = tmp.newTotalBorrows;
    market.supplyIndex = tmp.newSupplyIndex;
    market.borrowIndex = tmp.newBorrowIndex;

    tmp.startingBalance = borrowBalance.principal;
    borrowBalance.principal = tmp.userBorrowUpdated;
    borrowBalance.interestIndex = tmp.newBorrowIndex;

    safeTransferFrom(t, msg.sender, address(this), address(this).make_payable(), tmp.repayAmount, msg.value);

    emit RepayFastBorrowLog(msg.sender, t, tmp.repayAmount, tmp.startingBalance, tmp.userBorrowUpdated);

    return 0;
  }

  //shortfall/(price*(minPledgeRate-liquidationDiscount-1))
  //liquidationDiscount是清算折扣, in QIAN, 无清算折扣，但有罚金，罚金是8%，无清算折扣
  //underwaterAsset is borrowAsset
  function calcDiscountedRepayToEvenAmount(address targetAccount, address underwaterAsset, uint underwaterAssetPrice) public view returns (uint) {
    (, uint shortfall) = calcAccountLiquidity(targetAccount);
    uint minPledgeRate = mkts[underwaterAsset].minPledgeRate;
    uint liquidationDiscount = mkts[underwaterAsset].liquidationDiscount;
    uint gap = minPledgeRate.sub(liquidationDiscount).sub(1 ether);
    return shortfall.mul(10**mkts[underwaterAsset].decimals).div(underwaterAssetPrice.mul(gap).div(ONE_ETH));//underwater asset amount
  }

  //[supplyCurrent / (1 + liquidationDiscount)] * (Oracle price for the collateral / Oracle price for the borrow)
  //[supplyCurrent * (Oracle price for the collateral)] / [ (1 + liquidationDiscount) * (Oracle price for the borrow) ]
  // 被清算人 supplyCurrent_TargetCollateralAsset 数量的质押资产换成可以被变卖的 underwaterAsset 资产数量
  function calcDiscountedBorrowDenominatedCollateral(address underwaterAsset, address collateralAsset, uint underwaterAssetPrice, uint collateralPrice, uint supplyCurrent_TargetCollateralAsset) public view returns (uint) {
    uint liquidationDiscount = mkts[underwaterAsset].liquidationDiscount;
    uint onePlusLiquidationDiscount = (ONE_ETH).add(liquidationDiscount);
    uint supplyCurrentTimesOracleCollateral = supplyCurrent_TargetCollateralAsset.mul(collateralPrice);//10^8*10^18, supplyCurrent_TargetCollateralAsset is IMBTC, 10^26
    uint res = supplyCurrentTimesOracleCollateral.div(onePlusLiquidationDiscount.mul(underwaterAssetPrice).div(ONE_ETH));//underwaterAsset amout
    res = res.mul(10 ** mkts[underwaterAsset].decimals);
    res = res.div(10 ** mkts[collateralAsset].decimals);
    return res;

  }

  //closeBorrowAmount_TargetUnderwaterAsset * (1+liquidationDiscount) * priceBorrow/priceCollateral
  //underwaterAssetPrice * (1+liquidationDiscount) *closeBorrowAmount_TargetUnderwaterAsset) / collateralPrice
  //underwater is borrow
  // 计算清算时可用 closeBorrowAmount_TargetUnderwaterAsset 数量的 underwaterAsset 买到的 collateralAsset 资产数量
  function calcAmountSeize(address underwaterAsset, address collateralAsset, uint underwaterAssetPrice, uint collateralPrice, uint closeBorrowAmount_TargetUnderwaterAsset) public view returns (uint) {
    uint liquidationDiscount = mkts[underwaterAsset].liquidationDiscount;
    uint onePlusLiquidationDiscount = (ONE_ETH).add(liquidationDiscount);
    uint res = underwaterAssetPrice.mul(onePlusLiquidationDiscount);
    res = res.mul(closeBorrowAmount_TargetUnderwaterAsset);
    res = res.div(collateralPrice);
    res = res.div(ONE_ETH);
    res = res.mul(10**mkts[collateralAsset].decimals);
    res = res.div(10**mkts[underwaterAsset].decimals);
    return res;


  }

  struct LiquidateIR {
    // we need these addresses in the struct for use with `emitLiquidationEvent` to avoid `CompilerError: Stack too deep, try removing local variables.`
    address targetAccount;
    address assetBorrow;
    address liquidator;
    address assetCollateral;

    // borrow index and supply index are global to the asset, not specific to the user
    uint newBorrowIndex_UnderwaterAsset;
    uint newSupplyIndex_UnderwaterAsset;
    uint newBorrowIndex_CollateralAsset;
    uint newSupplyIndex_CollateralAsset;

    // the target borrow's full balance with accumulated interest
    uint currentBorrowBalance_TargetUnderwaterAsset;
    // currentBorrowBalance_TargetUnderwaterAsset minus whatever gets repaid as part of the liquidation
    uint updatedBorrowBalance_TargetUnderwaterAsset;

    uint newTotalBorrows_ProtocolUnderwaterAsset;

    uint startingBorrowBalance_TargetUnderwaterAsset;
    uint startingSupplyBalance_TargetCollateralAsset;
    uint startingSupplyBalance_LiquidatorCollateralAsset;

    uint currentSupplyBalance_TargetCollateralAsset;
    uint updatedSupplyBalance_TargetCollateralAsset;

    // If liquidator already has a balance of collateralAsset, we will accumulate
    // interest on it before transferring seized collateral from the borrower.
    uint currentSupplyBalance_LiquidatorCollateralAsset;
    // This will be the liquidator's accumulated balance of collateral asset before the liquidation (if any)
    // plus the amount seized from the borrower.
    uint updatedSupplyBalance_LiquidatorCollateralAsset;

    uint newTotalSupply_ProtocolCollateralAsset;
    uint currentCash_ProtocolUnderwaterAsset;
    uint updatedCash_ProtocolUnderwaterAsset;

    // cash does not change for collateral asset

    //mkts[t]
    uint newSupplyRateMantissa_ProtocolUnderwaterAsset;
    uint newBorrowRateMantissa_ProtocolUnderwaterAsset;

    // Why no variables for the interest rates for the collateral asset?
    // We don't need to calculate new rates for the collateral asset since neither cash nor borrows change

    uint discountedRepayToEvenAmount;

    //[supplyCurrent / (1 + liquidationDiscount)] * (Oracle price for the collateral / Oracle price for the borrow) (discountedBorrowDenominatedCollateral)
    uint discountedBorrowDenominatedCollateral;

    uint maxCloseableBorrowAmount_TargetUnderwaterAsset;
    uint closeBorrowAmount_TargetUnderwaterAsset;
    uint seizeSupplyAmount_TargetCollateralAsset;

    uint collateralPrice;
    uint underwaterAssetPrice;
  }

  // 获取可清算数量最大值
  function calcMaxLiquidateAmount(address targetAccount, address assetBorrow, address assetCollateral) external view returns (uint) {
      require(msg.sender != targetAccount, "can't self-liquidate");
      LiquidateIR memory tmp;

      uint blockDelta = now - mkts[assetBorrow].accrualBlockNumber;

      Market storage borrowMarket = mkts[assetBorrow];
      Market storage collateralMarket = mkts[assetCollateral];
      Balance storage borrowBalance_TargeUnderwaterAsset = accountBorrowSnapshot[assetBorrow][targetAccount];
      Balance storage supplyBalance_TargetCollateralAsset = accountSupplySnapshot[assetCollateral][targetAccount];
      
      tmp.newSupplyIndex_CollateralAsset = uint(collateralMarket.irm.pert(int(collateralMarket.supplyIndex), collateralMarket.supplyRate, int(blockDelta)));
      tmp.newBorrowIndex_UnderwaterAsset = uint(borrowMarket.irm.pert(int(borrowMarket.borrowIndex), borrowMarket.demondRate, int(blockDelta)));
      tmp.currentSupplyBalance_TargetCollateralAsset = uint(collateralMarket.irm.calculateBalance(int(supplyBalance_TargetCollateralAsset.principal), int(supplyBalance_TargetCollateralAsset.interestIndex), int(tmp.newSupplyIndex_CollateralAsset)));
      tmp.currentBorrowBalance_TargetUnderwaterAsset = uint(borrowMarket.irm.calculateBalance(int(borrowBalance_TargeUnderwaterAsset.principal), int(borrowBalance_TargeUnderwaterAsset.interestIndex), int(tmp.newBorrowIndex_UnderwaterAsset)));

      bool ok;
      (tmp.collateralPrice, ok) = fetchAssetPrice(assetCollateral);
      require(ok, "fail to get collateralPrice");

      (tmp.underwaterAssetPrice, ok) = fetchAssetPrice(assetBorrow);
      require(ok, "fail to get underwaterAssetPrice");

      tmp.discountedBorrowDenominatedCollateral = calcDiscountedBorrowDenominatedCollateral(assetBorrow, assetCollateral, tmp.underwaterAssetPrice, tmp.collateralPrice, tmp.currentSupplyBalance_TargetCollateralAsset);
      tmp.discountedRepayToEvenAmount = calcDiscountedRepayToEvenAmount(targetAccount, assetBorrow, tmp.underwaterAssetPrice);
      tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(tmp.currentBorrowBalance_TargetUnderwaterAsset, tmp.discountedBorrowDenominatedCollateral);
      tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset, tmp.discountedRepayToEvenAmount);

      return tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset;
  }


  // 清算
  function liquidateBorrowPawn(address targetAccount, address assetBorrow, address assetCollateral, uint requestedAmountClose) external payable nonReentrant returns (uint) {
        require(msg.sender != targetAccount, "can't self-liquidate");
        LiquidateIR memory tmp;
        // Copy these addresses into the struct for use with `emitLiquidationEvent`
        // We'll use tmp.liquidator inside this function for clarity vs using msg.sender.
        tmp.targetAccount = targetAccount;
        tmp.assetBorrow = assetBorrow;
        tmp.liquidator = msg.sender;
        tmp.assetCollateral = assetCollateral;

        uint blockDelta = now - mkts[assetBorrow].accrualBlockNumber;

        Market storage borrowMarket = mkts[assetBorrow];
        Market storage collateralMarket = mkts[assetCollateral];
        // 被清算人的借币余额与存币余额
        Balance storage borrowBalance_TargeUnderwaterAsset = accountBorrowSnapshot[assetBorrow][targetAccount];
        Balance storage supplyBalance_TargetCollateralAsset = accountSupplySnapshot[assetCollateral][targetAccount];

        // Liquidator might already hold some of the collateral asset
        // 清算人自己的质押币资产
        Balance storage supplyBalance_LiquidatorCollateralAsset = accountSupplySnapshot[assetCollateral][tmp.liquidator];

        bool ok;
        (tmp.collateralPrice, ok) = fetchAssetPrice(assetCollateral);
        require(ok, "fail to get collateralPrice");

        (tmp.underwaterAssetPrice, ok) = fetchAssetPrice(assetBorrow);
        require(ok, "fail to get underwaterAssetPrice");

        // 更新+被+清算人的借币余额
        tmp.newBorrowIndex_UnderwaterAsset = uint(borrowMarket.irm.pert(int(borrowMarket.borrowIndex), borrowMarket.demondRate, int(blockDelta)));
        tmp.currentBorrowBalance_TargetUnderwaterAsset = uint(borrowMarket.irm.calculateBalance(int(borrowBalance_TargeUnderwaterAsset.principal), int(borrowBalance_TargeUnderwaterAsset.interestIndex), int(tmp.newBorrowIndex_UnderwaterAsset)));

        // 更新+被+清算人的存币余额
        tmp.newSupplyIndex_CollateralAsset = uint(collateralMarket.irm.pert(int(collateralMarket.supplyIndex), collateralMarket.supplyRate, int(blockDelta)));
        tmp.currentSupplyBalance_TargetCollateralAsset = uint(collateralMarket.irm.calculateBalance(int(supplyBalance_TargetCollateralAsset.principal), int(supplyBalance_TargetCollateralAsset.interestIndex), int(tmp.newSupplyIndex_CollateralAsset)));

        // 更新清算人的此质押币余额
        tmp.currentSupplyBalance_LiquidatorCollateralAsset = uint(collateralMarket.irm.calculateBalance(int(supplyBalance_LiquidatorCollateralAsset.principal), int(supplyBalance_LiquidatorCollateralAsset.interestIndex), int(tmp.newSupplyIndex_CollateralAsset)));

        // 更新市场的此质押币余额
        tmp.newTotalSupply_ProtocolCollateralAsset = collateralMarket.totalSupply.add(tmp.currentSupplyBalance_TargetCollateralAsset).sub(supplyBalance_TargetCollateralAsset.principal);
        tmp.newTotalSupply_ProtocolCollateralAsset = tmp.newTotalSupply_ProtocolCollateralAsset.add(tmp.currentSupplyBalance_LiquidatorCollateralAsset).sub(supplyBalance_LiquidatorCollateralAsset.principal);

        // 计算可清算最大值
        tmp.discountedBorrowDenominatedCollateral = calcDiscountedBorrowDenominatedCollateral(assetBorrow, assetCollateral, tmp.underwaterAssetPrice, tmp.collateralPrice, tmp.currentSupplyBalance_TargetCollateralAsset);
        tmp.discountedRepayToEvenAmount = calcDiscountedRepayToEvenAmount(targetAccount, assetBorrow, tmp.underwaterAssetPrice);
        tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(tmp.currentBorrowBalance_TargetUnderwaterAsset, tmp.discountedBorrowDenominatedCollateral);
        tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset, tmp.discountedRepayToEvenAmount);

        // 设置实际清算量
        if (requestedAmountClose == uint(-1)) {
            tmp.closeBorrowAmount_TargetUnderwaterAsset = tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset;
        } else {
            tmp.closeBorrowAmount_TargetUnderwaterAsset = requestedAmountClose;
        }
        require(tmp.closeBorrowAmount_TargetUnderwaterAsset <= tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset, "closeBorrowAmount > maxCloseableBorrowAmount err");
        if (assetBorrow == address(0)) {
            // 如果是 ETH，需要保证清算人传入的 value 大于所需的量
            require(msg.value >= tmp.closeBorrowAmount_TargetUnderwaterAsset, "Not enough ETH");
        } else {
            // 如果是 ERC20， 需要保证清算人要有足够的资产
            require(getBalanceOf(assetBorrow, tmp.liquidator) >= tmp.closeBorrowAmount_TargetUnderwaterAsset, "insufficient balance");
        }

        // 计算清算人实际清算得到的此质押币数量
        tmp.seizeSupplyAmount_TargetCollateralAsset = calcAmountSeize(assetBorrow, assetCollateral, tmp.underwaterAssetPrice, tmp.collateralPrice, tmp.closeBorrowAmount_TargetUnderwaterAsset);

        // 被清算人借币余额减少
        tmp.updatedBorrowBalance_TargetUnderwaterAsset = tmp.currentBorrowBalance_TargetUnderwaterAsset.sub(tmp.closeBorrowAmount_TargetUnderwaterAsset);
        // 更新借币市场总量
        tmp.newTotalBorrows_ProtocolUnderwaterAsset = borrowMarket.totalBorrows.add(tmp.updatedBorrowBalance_TargetUnderwaterAsset).sub(borrowBalance_TargeUnderwaterAsset.principal);

        tmp.currentCash_ProtocolUnderwaterAsset = getCash(assetBorrow);
        // 如果是 ERC-20 代币，加 amount
        // 如果是 ETH，则已经在函数调用的时候转入了，就不用加了
        tmp.updatedCash_ProtocolUnderwaterAsset = assetBorrow != address(0) ? tmp.currentCash_ProtocolUnderwaterAsset.add(tmp.closeBorrowAmount_TargetUnderwaterAsset) : tmp.currentCash_ProtocolUnderwaterAsset;

        // 计算存借比率
        tmp.newSupplyIndex_UnderwaterAsset = uint(borrowMarket.irm.pert(int(borrowMarket.supplyIndex), borrowMarket.demondRate, int(blockDelta)));
        borrowMarket.supplyRate = borrowMarket.irm.getDepositRate(int(tmp.updatedCash_ProtocolUnderwaterAsset), int(tmp.newTotalBorrows_ProtocolUnderwaterAsset));
        borrowMarket.demondRate = borrowMarket.irm.getLoanRate(int(tmp.updatedCash_ProtocolUnderwaterAsset), int(tmp.newTotalBorrows_ProtocolUnderwaterAsset));
        tmp.newBorrowIndex_CollateralAsset = uint(collateralMarket.irm.pert(int(collateralMarket.supplyIndex), collateralMarket.demondRate, int(blockDelta)));

        // 被清算人存币余额减少
        tmp.updatedSupplyBalance_TargetCollateralAsset = tmp.currentSupplyBalance_TargetCollateralAsset.sub(tmp.seizeSupplyAmount_TargetCollateralAsset);
        // 清算人存币余额增加
        tmp.updatedSupplyBalance_LiquidatorCollateralAsset = tmp.currentSupplyBalance_LiquidatorCollateralAsset.add(tmp.seizeSupplyAmount_TargetCollateralAsset);

        borrowMarket.accrualBlockNumber = now;
        borrowMarket.totalBorrows = tmp.newTotalBorrows_ProtocolUnderwaterAsset;
        borrowMarket.supplyIndex = tmp.newSupplyIndex_UnderwaterAsset;
        borrowMarket.borrowIndex = tmp.newBorrowIndex_UnderwaterAsset;

        collateralMarket.accrualBlockNumber = now;
        collateralMarket.totalSupply = tmp.newTotalSupply_ProtocolCollateralAsset;
        collateralMarket.supplyIndex = tmp.newSupplyIndex_CollateralAsset;
        collateralMarket.borrowIndex = tmp.newBorrowIndex_CollateralAsset;

        tmp.startingBorrowBalance_TargetUnderwaterAsset = borrowBalance_TargeUnderwaterAsset.principal; // save for use in event
        borrowBalance_TargeUnderwaterAsset.principal = tmp.updatedBorrowBalance_TargetUnderwaterAsset;
        borrowBalance_TargeUnderwaterAsset.interestIndex = tmp.newBorrowIndex_UnderwaterAsset;

        tmp.startingSupplyBalance_TargetCollateralAsset = supplyBalance_TargetCollateralAsset.principal; // save for use in event
        supplyBalance_TargetCollateralAsset.principal = tmp.updatedSupplyBalance_TargetCollateralAsset;
        supplyBalance_TargetCollateralAsset.interestIndex = tmp.newSupplyIndex_CollateralAsset;

        tmp.startingSupplyBalance_LiquidatorCollateralAsset = supplyBalance_LiquidatorCollateralAsset.principal; // save for use in event
        supplyBalance_LiquidatorCollateralAsset.principal = tmp.updatedSupplyBalance_LiquidatorCollateralAsset;
        supplyBalance_LiquidatorCollateralAsset.interestIndex = tmp.newSupplyIndex_CollateralAsset;

        setLiquidateInfoMap(tmp.targetAccount, tmp.liquidator, tmp.assetCollateral, assetBorrow, tmp.seizeSupplyAmount_TargetCollateralAsset, tmp.closeBorrowAmount_TargetUnderwaterAsset);

        safeTransferFrom(assetBorrow, tmp.liquidator.make_payable(), address(this), address(this).make_payable(), tmp.closeBorrowAmount_TargetUnderwaterAsset, msg.value);

        emit LiquidateBorrowPawnLog(tmp.targetAccount, assetBorrow,
        tmp.updatedBorrowBalance_TargetUnderwaterAsset,
        tmp.liquidator,
        tmp.assetCollateral,
        tmp.updatedSupplyBalance_TargetCollateralAsset
        );

        return 0;
  }


function safeTransferFrom(address token, address payable owner, address spender, address payable to, uint256 amount, uint256 msgValue) internal returns (uint256) {
  require(amount > 0, "invalid safeTransferFrom amount");
  // require(token != address(0), "invalid token address!");

  if (owner != spender && token != address(0)) {
      // 转入ERC20代币
      require(IERC20(token).allowance(owner, spender) >= amount, "Insufficient allowance");
  }
  if (token != address(0)) {
    require(IERC20(token).balanceOf(owner) >= amount, "Insufficient balance");
  } else if (owner == spender) {
    // eth， owner == spender 即转出，需要校验owner的eth余额
    require(owner.balance >= amount, "Insufficient eth balance");
  }

  if (owner != spender) {
    // 转入
    if (token != address(0)) {
      // ERC20代币 transferFrom 转入
      IERC20(token).safeTransferFrom(owner, to, amount);
    } else if (msgValue > 0 && msgValue > amount) {
      // 还钱时，用户多还了的 eth 需要返还
      owner.transfer(msgValue.sub(amount));
    }
    // eth 已从 payable 函数调用时转入
  } else {
    // 转出
    if (token != address(0)) {
      // ERC20转出
      IERC20(token).safeTransfer(to, amount);
    } else {
      // 参数设置， msgValue 大于0，即还款或清算逻辑，实际还的钱大于需要还的钱，需要返回多余的钱
      // msgValue 等于 0，借钱或取钱逻辑，直接转出 amount 数量的币
      if (msgValue > 0 && msgValue > amount) {
        to.transfer(msgValue.sub(amount));
      } else if (msgValue == 0) {
        to.transfer(amount);
      }
    }
  }

  return 0;
}

  // 管理员取钱
  function withdrawPawnEquity(address t, uint amount) external nonReentrant onlyAdmin returns (uint) {
    uint cash = getCash(t);
    uint equity = cash.add(mkts[t].totalBorrows).sub(mkts[t].totalSupply);
    require(equity >= amount, "insufficient equity amount");
    safeTransferFrom(t, address(this).make_payable(), address(this), admin.make_payable(), amount, 0);
    emit WithdrawPawnEquityLog(t, equity, amount, admin);
    return 0;
  }
}