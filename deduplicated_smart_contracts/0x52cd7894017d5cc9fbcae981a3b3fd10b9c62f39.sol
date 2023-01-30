/**
 *Submitted for verification at Etherscan.io on 2020-10-18
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

interface IUniswap {
  // To convert DAI to ETH
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
  // To convert ETH to YELD and burn it
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
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

contract Ownable is Context {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address payable) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

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

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

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
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
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

interface Compound {
    function mint ( uint256 mintAmount ) external returns ( uint256 );
    function redeem(uint256 redeemTokens) external returns (uint256);
    function exchangeRateStored() external view returns (uint);
}

interface Fulcrum {
    function mint(address receiver, uint256 amount) external payable returns (uint256 mintAmount);
    function burn(address receiver, uint256 burnAmount) external returns (uint256 loanAmountPaid);
    function assetBalanceOf(address _owner) external view returns (uint256 balance);
}

interface ILendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
}

interface Aave {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
}

interface AToken {
    function redeem(uint256 amount) external;
}

interface IIEarnManager {
    function recommend(address _token) external view returns (
      string memory choice,
      uint256 capr,
      uint256 iapr,
      uint256 aapr,
      uint256 dapr
    );
}

contract Structs {
    struct Val {
        uint256 value;
    }

    enum ActionType {
        Deposit,   // supply tokens
        Withdraw  // borrow tokens
    }

    enum AssetDenomination {
        Wei // the amount is denominated in wei
    }

    enum AssetReference {
        Delta // the amount is given as a delta from the current value
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct Info {
        address owner;  // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}

contract DyDx is Structs {
    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);
    function operate(Info[] memory, ActionArgs[] memory) public;
}

interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
}

contract yTUSD is ERC20, ERC20Detailed, ReentrancyGuard, Structs, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  uint256 public pool;
  address public token;
  address public compound;
  address public fulcrum;
  address public aave;
  address public aavePool;
  address public aaveToken;
  address public dydx;
  uint256 public dToken;
  address public apr;
  address public chai;
  // Add other tokens if implemented for another stablecoin
  address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public tusd = 0x0000000000085d4780B73119b644AE5ecd22b376;
  address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address payable public retirementYeldTreasury;
  IERC20 public yeldToken;
  uint256 public maximumTokensToBurn = 50000 * 1e18;
  
  // When you stake say 1000 TUSD for a day that will be your maximum
  // if you stake the next time 300 TUSD your maximum will stay the same
  // if you stake 2000 at once it will increase to 2000 TUSD
  mapping(bytes32 => uint256) public numberOfParticipants;
  mapping(address => uint256) public depositBlockStarts;
  uint256 public constant oneDayInBlocks = 6500;
  uint256 public yeldToRewardPerDay = 100e18; // 100 YELD per day per 1 million stablecoins padded with 18 zeroes to have that flexibility
  uint256 public constant oneMillion = 1e6;


  enum Lender {
      NONE,
      DYDX,
      COMPOUND,
      AAVE,
      FULCRUM
  }

  Lender public provider = Lender.NONE;

  constructor (address _yeldToken, address payable _retirementYeldTreasury) public ERC20Detailed("yearn TUSD", "yTUSD", 18) {
    token = address(0x0000000000085d4780B73119b644AE5ecd22b376);
    apr = address(0xdD6d648C991f7d47454354f4Ef326b04025a48A8);
    dydx = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
    aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    fulcrum = address(0x49f4592E641820e928F9919Ef4aBd92a719B4b49);
    aaveToken = address(0x4DA9b813057D04BAef4e5800E36083717b4a0341);
    compound = address(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    dToken = 0;
    yeldToken = IERC20(_yeldToken);
    retirementYeldTreasury = _retirementYeldTreasury;
    approveToken();
  }

  // To receive ETH after converting it from TUSD
  function () external payable {}

  function setRetirementYeldTreasury(address payable _treasury) public onlyOwner {
    retirementYeldTreasury = _treasury;
  }

  // In case a new uniswap router version is released
  function setUniswapRouter(address _uniswapRouter) public onlyOwner {
    uniswapRouter = _uniswapRouter;
  }

  function extractTokensIfStuck(address _token, uint256 _amount) public onlyOwner {
    IERC20(_token).transfer(msg.sender, _amount);
  }

  function extractETHIfStuck() public onlyOwner {
    owner().transfer(address(this).balance);
  }

  function changeYeldToRewardPerDay(uint256 _amount) public onlyOwner {
    yeldToRewardPerDay = _amount;
  }

  function getGeneratedYelds() public view returns(uint256) {
    uint256 blocksPassed;
    if (depositBlockStarts[msg.sender] > 0) {
      blocksPassed = block.number.sub(depositBlockStarts[msg.sender]);
    } else {
      return 0;
    }
    // This will work because amount is a token with 18 decimals
    // Take the deposit, reduce it by 1 million (by removing 6 zeroes) so you get 1
    // That 1 means get 1 YELD per day (in blocks). Now multiply that 1 by 100 to get 100 YELD per day
    //                       your deposits in dai       div by 1 million * by yeld to reward / 1e18 since yeldToReward is in 18 decimals to be able to provide a smaller price since
    // we can't go below 1 in a variable. You can't make the price 0.00001 that's why we need that 1e18 padding
    // For USDC and Tether gotta multiply by 1e12 since they have 6 decimals to get the proper result of YELD
    uint256 ibalance = balanceOf(msg.sender); // Balance of yTokens
    uint256 accomulatedStablecoins;
    if (_totalSupply <= 0) {
      accomulatedStablecoins = 0;
    } else {
      accomulatedStablecoins = (calcPoolValueInToken().mul(ibalance)).div(_totalSupply);
    }
    uint256 generatedYelds = accomulatedStablecoins.div(oneMillion).mul(yeldToRewardPerDay.div(1e18)).mul(blocksPassed).div(oneDayInBlocks);
    return generatedYelds;
  }

  function extractYELDEarningsWhileKeepingDeposit() public {
    uint256 ibalance = balanceOf(msg.sender);
    uint256 accomulatedStablecoins = (calcPoolValueInToken().mul(ibalance)).div(_totalSupply);
    require(depositBlockStarts[msg.sender] > 0 && accomulatedStablecoins > 0, 'Must have deposited stablecoins beforehand');
    uint256 generatedYelds = getGeneratedYelds();
    depositBlockStarts[msg.sender] = block.number;
    yeldToken.transfer(msg.sender, generatedYelds);
  }

  function deposit(uint256 _amount)
      external
      nonReentrant
  {
    require(_amount > 0, "deposit must be greater than 0");
    pool = calcPoolValueInToken();
    IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);

    // Yeld
    if (getGeneratedYelds() > 0) extractYELDEarningsWhileKeepingDeposit();
    depositBlockStarts[msg.sender] = block.number;
    // Yeld

    // Calculate pool shares
    uint256 shares = 0;
    if (pool == 0) {
      shares = _amount;
      pool = _amount;
    } else {
      shares = (_amount.mul(_totalSupply)).div(pool);
    }
    pool = calcPoolValueInToken();
    _mint(msg.sender, shares);
    rebalance();
  }

  // Converts TUSD to ETH and returns how much ETH has been received from Uniswap
  function tusdToETH(uint256 _amount) internal returns(uint256) {
      IERC20(tusd).safeApprove(uniswapRouter, 0);
      IERC20(tusd).safeApprove(uniswapRouter, _amount);
      address[] memory path = new address[](2);
      path[0] = tusd;
      path[1] = weth;
      // swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
      // 'amounts' is an array where [0] is input TUSD amount and [1] is the resulting ETH after the conversion
      // even tho we've specified the WETH address, we'll receive ETH since that's how it works on uniswap
      // https://uniswap.org/docs/v2/smart-contracts/router02/#swapexacttokensforeth
      uint[] memory amounts = IUniswap(uniswapRouter).swapExactTokensForETH(_amount, uint(0), path, address(this), now.add(1800));
      return amounts[1];
  }

  // Buys YELD tokens paying in ETH on Uniswap and removes them from circulation
  // Returns how many YELD tokens have been burned
  function buyNBurn(uint256 _ethToSwap) internal returns(uint256) {
    address[] memory path = new address[](2);
    path[0] = weth;
    path[1] = address(yeldToken);
    // Burns the tokens by taking them out of circulation, sending them to the 0x0 address
    uint[] memory amounts = IUniswap(uniswapRouter).swapExactETHForTokens.value(_ethToSwap)(uint(0), path, address(0), now.add(1800));
    return amounts[1];
  }

  // No rebalance implementation for lower fees and faster swaps
  function withdraw(uint256 _shares)
      external
      nonReentrant
  {
      require(_shares > 0, "withdraw must be greater than 0");
      uint256 ibalance = balanceOf(msg.sender);
      require(_shares <= ibalance, "insufficient balance");
      pool = calcPoolValueInToken();
      // Yeld
      uint256 generatedYelds = getGeneratedYelds();
      // Yeld
      uint256 stablecoinsToWithdraw = (pool.mul(_shares)).div(_totalSupply);
      _balances[msg.sender] = _balances[msg.sender].sub(_shares, "redeem amount exceeds balance");
      _totalSupply = _totalSupply.sub(_shares);
      emit Transfer(msg.sender, address(0), _shares);
      uint256 b = IERC20(token).balanceOf(address(this));
      if (b < stablecoinsToWithdraw) {
        _withdrawSome(stablecoinsToWithdraw.sub(b));
      }

      // Yeld
      // Take 1% of the amount to withdraw
      uint256 onePercent = stablecoinsToWithdraw.div(100);
      depositBlockStarts[msg.sender] = block.number;
      yeldToken.transfer(msg.sender, generatedYelds);

      // Take a portion of the profits for the buy and burn and retirement yeld
      // Convert half the TUSD earned into ETH for the protocol algorithms
      uint256 stakingProfits = tusdToETH(onePercent);
      uint256 tokensAlreadyBurned = yeldToken.balanceOf(address(0));
      if (tokensAlreadyBurned < maximumTokensToBurn) {
        // 98% is the 49% doubled since we already took the 50%
        uint256 ethToSwap = stakingProfits.mul(98).div(100);
        // Buy and burn only applies up to 50k tokens burned
        buyNBurn(ethToSwap);
        // 1% for the Retirement Yield
        uint256 retirementYeld = stakingProfits.mul(2).div(100);
        // Send to the treasury
        retirementYeldTreasury.transfer(retirementYeld);
      } else {
        // If we've reached the maximum burn point, send half the profits to the treasury to reward holders
        uint256 retirementYeld = stakingProfits;
        // Send to the treasury
        retirementYeldTreasury.transfer(retirementYeld);
      }
      IERC20(token).safeTransfer(msg.sender, stablecoinsToWithdraw.sub(onePercent));
      // Yeld
      
      pool = calcPoolValueInToken();
      rebalance();
  }

  function recommend() public view returns (Lender) {
    (,uint256 capr,uint256 iapr,uint256 aapr,uint256 dapr) = IIEarnManager(apr).recommend(token);
    uint256 max = 0;
    if (capr > max) {
      max = capr;
    }
    if (iapr > max) {
      max = iapr;
    }
    if (aapr > max) {
      max = aapr;
    }
    if (dapr > max) {
      max = dapr;
    }

    Lender newProvider = Lender.NONE;
    if (max == capr) {
      newProvider = Lender.COMPOUND;
    } else if (max == iapr) {
      newProvider = Lender.FULCRUM;
    } else if (max == aapr) {
      newProvider = Lender.AAVE;
    } else if (max == dapr) {
      newProvider = Lender.DYDX;
    }
    return newProvider;
  }

  function getAave() public view returns (address) {
    return LendingPoolAddressesProvider(aave).getLendingPool();
  }
  function getAaveCore() public view returns (address) {
    return LendingPoolAddressesProvider(aave).getLendingPoolCore();
  }

  function approveToken() public {
      IERC20(token).safeApprove(compound, uint(-1));
      IERC20(token).safeApprove(dydx, uint(-1));
      IERC20(token).safeApprove(getAaveCore(), uint(-1));
      IERC20(token).safeApprove(fulcrum, uint(-1));
  }

  function balance() public view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }
  function balanceDydxAvailable() public view returns (uint256) {
      return IERC20(token).balanceOf(dydx);
  }
  function balanceDydx() public view returns (uint256) {
      Wei memory bal = DyDx(dydx).getAccountWei(Info(address(this), 0), dToken);
      return bal.value;
  }
  function balanceCompound() public view returns (uint256) {
      return IERC20(compound).balanceOf(address(this));
  }
  function balanceCompoundInToken() public view returns (uint256) {
    // Mantisa 1e18 to decimals
    uint256 b = balanceCompound();
    if (b > 0) {
      b = b.mul(Compound(compound).exchangeRateStored()).div(1e18);
    }
    return b;
  }
  function balanceFulcrumAvailable() public view returns (uint256) {
      return IERC20(chai).balanceOf(fulcrum);
  }
  function balanceFulcrumInToken() public view returns (uint256) {
    uint256 b = balanceFulcrum();
    if (b > 0) {
      b = Fulcrum(fulcrum).assetBalanceOf(address(this));
    }
    return b;
  }
  function balanceFulcrum() public view returns (uint256) {
    return IERC20(fulcrum).balanceOf(address(this));
  }
  function balanceAaveAvailable() public view returns (uint256) {
      return IERC20(token).balanceOf(aavePool);
  }
  function balanceAave() public view returns (uint256) {
    return IERC20(aaveToken).balanceOf(address(this));
  }

  function rebalance() public {
    Lender newProvider = recommend();

    if (newProvider != provider) {
      _withdrawAll();
    }

    if (balance() > 0) {
      if (newProvider == Lender.DYDX) {
        _supplyDydx(balance());
      } else if (newProvider == Lender.FULCRUM) {
        _supplyFulcrum(balance());
      } else if (newProvider == Lender.COMPOUND) {
        _supplyCompound(balance());
      } else if (newProvider == Lender.AAVE) {
        _supplyAave(balance());
      }
    }

    provider = newProvider;
  }

  function _withdrawAll() internal {
    uint256 amount = balanceCompound();
    if (amount > 0) {
      _withdrawSomeCompound(balanceCompoundInToken().sub(1));
    }
    amount = balanceDydx();
    if (amount > 0) {
      if (amount > balanceDydxAvailable()) {
        amount = balanceDydxAvailable();
      }
      _withdrawDydx(amount);
    }
    amount = balanceFulcrum();
    if (amount > 0) {
      if (amount > balanceFulcrumAvailable().sub(1)) {
        amount = balanceFulcrumAvailable().sub(1);
      }
      _withdrawSomeFulcrum(amount);
    }
    amount = balanceAave();
    if (amount > 0) {
      if (amount > balanceAaveAvailable()) {
        amount = balanceAaveAvailable();
      }
      _withdrawAave(amount);
    }
  }

  function _withdrawSomeCompound(uint256 _amount) internal {
    uint256 b = balanceCompound();
    uint256 bT = balanceCompoundInToken();
    require(bT >= _amount, "insufficient funds");
    // can have unintentional rounding errors
    uint256 amount = (b.mul(_amount)).div(bT).add(1);
    _withdrawCompound(amount);
  }

  function _withdrawSomeFulcrum(uint256 _amount) internal {
    uint256 b = balanceFulcrum();
    uint256 bT = balanceFulcrumInToken();
    require(bT >= _amount, "insufficient funds");
    // can have unintentional rounding errors
    uint256 amount = (b.mul(_amount)).div(bT).add(1);
    _withdrawFulcrum(amount);
  }


  function _withdrawSome(uint256 _amount) internal returns (bool) {
    uint256 origAmount = _amount;

    uint256 amount = balanceCompound();
    if (amount > 0) {
      if (_amount > balanceCompoundInToken().sub(1)) {
        _withdrawSomeCompound(balanceCompoundInToken().sub(1));
        _amount = origAmount.sub(IERC20(token).balanceOf(address(this)));
      } else {
        _withdrawSomeCompound(_amount);
        return true;
      }
    }

    amount = balanceDydx();
    if (amount > 0) {
      if (_amount > balanceDydxAvailable()) {
        _withdrawDydx(balanceDydxAvailable());
        _amount = origAmount.sub(IERC20(token).balanceOf(address(this)));
      } else {
        _withdrawDydx(_amount);
        return true;
      }
    }

    amount = balanceFulcrum();
    if (amount > 0) {
      if (_amount > balanceFulcrumAvailable().sub(1)) {
        amount = balanceFulcrumAvailable().sub(1);
        _withdrawSomeFulcrum(balanceFulcrumAvailable().sub(1));
        _amount = origAmount.sub(IERC20(token).balanceOf(address(this)));
      } else {
        _withdrawSomeFulcrum(amount);
        return true;
      }
    }

    amount = balanceAave();
    if (amount > 0) {
      if (_amount > balanceAaveAvailable()) {
        _withdrawAave(balanceAaveAvailable());
        _amount = origAmount.sub(IERC20(token).balanceOf(address(this)));
      } else {
        _withdrawAave(_amount);
        return true;
      }
    }

    return true;
  }

  function _supplyDydx(uint256 amount) internal {
      Info[] memory infos = new Info[](1);
      infos[0] = Info(address(this), 0);

      AssetAmount memory amt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, amount);
      ActionArgs memory act;
      act.actionType = ActionType.Deposit;
      act.accountId = 0;
      act.amount = amt;
      act.primaryMarketId = dToken;
      act.otherAddress = address(this);

      ActionArgs[] memory args = new ActionArgs[](1);
      args[0] = act;

      DyDx(dydx).operate(infos, args);
  }

  function _supplyAave(uint amount) internal {
      Aave(getAave()).deposit(token, amount, 0);
  }
  function _supplyFulcrum(uint amount) internal {
      require(Fulcrum(fulcrum).mint(address(this), amount) > 0, "FULCRUM: supply failed");
  }
  function _supplyCompound(uint amount) internal {
      require(Compound(compound).mint(amount) == 0, "COMPOUND: supply failed");
  }
  function _withdrawAave(uint amount) internal {
      AToken(aaveToken).redeem(amount);
  }
  function _withdrawFulcrum(uint amount) internal {
      require(Fulcrum(fulcrum).burn(address(this), amount) > 0, "FULCRUM: withdraw failed");
  }
  function _withdrawCompound(uint amount) internal {
      require(Compound(compound).redeem(amount) == 0, "COMPOUND: withdraw failed");
  }

  function _withdrawDydx(uint256 amount) internal {
      Info[] memory infos = new Info[](1);
      infos[0] = Info(address(this), 0);

      AssetAmount memory amt = AssetAmount(false, AssetDenomination.Wei, AssetReference.Delta, amount);
      ActionArgs memory act;
      act.actionType = ActionType.Withdraw;
      act.accountId = 0;
      act.amount = amt;
      act.primaryMarketId = dToken;
      act.otherAddress = address(this);

      ActionArgs[] memory args = new ActionArgs[](1);
      args[0] = act;

      DyDx(dydx).operate(infos, args);
  }

  function calcPoolValueInToken() public view returns (uint) {
    return balanceCompoundInToken()
      .add(balanceFulcrumInToken())
      .add(balanceDydx())
      .add(balanceAave())
      .add(balance());
  }

  function getPricePerFullShare() public view returns (uint) {
    uint _pool = calcPoolValueInToken();
    return _pool.mul(1e18).div(_totalSupply);
  }
}