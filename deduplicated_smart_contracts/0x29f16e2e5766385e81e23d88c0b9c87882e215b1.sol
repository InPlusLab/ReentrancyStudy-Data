/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

pragma solidity ^0.5.0;

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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
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
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface ICurveFi {
  function exchange_underlying(
    int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount
  ) external;
}

interface yERC20 {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint256);
}

interface borrower {
  function borrowAave(address _reserve, uint256 _amount) external;
  function getBorrowDebt(address _reserve) external view returns (uint256);
  function getBorrowInterest(address _reserve) external view returns (uint256);
  function repayAave(address _reserve, uint256 _amount) external;
}

contract iTrade is ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public constant yCurveSwap = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);

  address public constant yDAI = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
  address public constant yUSDC = address(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);
  address public constant yUSDT = address(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);
  address public constant yTUSD = address(0x73a052500105205d34Daf004eAb301916DA8190f);

  address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  address public constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  address public constant TUSD = address(0x0000000000085d4780B73119b644AE5ecd22b376);

  address public constant collateral = address(0xCC784c1d240dD721a02a121448fBE474ffa3Defa);

  uint256 public constant ltv = uint256(150);
  uint256 public constant base = uint256(100);

  // principal deposits
  mapping (address => mapping (address => uint256)) public principals;

  // debt shares
  mapping (address => mapping (address => uint256)) public debts;
  mapping (address => uint256) public debtsTotalSupply;

  mapping (address => mapping (address => uint256)) public positions;

  constructor() public {
    approveToken();
  }

  function approveToken() public {
      // Repayments to Aave
      IERC20(DAI).safeApprove(collateral, uint(-1));
      IERC20(USDC).safeApprove(collateral, uint(-1));
      IERC20(TUSD).safeApprove(collateral, uint(-1));

      IERC20(USDT).safeApprove(collateral, uint(0));
      IERC20(USDT).safeApprove(collateral, uint(-1));

      // Approvals for swaps
      IERC20(DAI).safeApprove(yCurveSwap, uint(-1));
      IERC20(USDC).safeApprove(yCurveSwap, uint(-1));
      IERC20(TUSD).safeApprove(yCurveSwap, uint(-1));

      IERC20(USDT).safeApprove(yCurveSwap, uint(0));
      IERC20(USDT).safeApprove(yCurveSwap, uint(-1));
  }

  function addCollateral(address _reserve, address _to, uint256 _amount, uint256 _min_to_amount, uint256 leverage) external {
      require(isLeverage(leverage) == true, "itrade: invalid leverage parameter");
      require(isReserve(_reserve) == true, "itrade: invalid reserve");

      IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _amount);
      principals[_reserve][msg.sender] = principals[_reserve][msg.sender].add(_amount);
      yERC20(getYToken(_reserve)).deposit(_amount);

      uint256 _borrow = (_amount.mul(leverage));
      uint256 _pool = borrower(collateral).getBorrowDebt(_reserve);
      uint256 _debt = 0;
      if (_pool == 0) {
        _debt = _borrow;
      } else {
        _debt = (_borrow.mul(debtsTotalSupply[_reserve])).div(_pool);
      }
      _mintDebt(_reserve, msg.sender, _debt);
      borrower(collateral).borrowAave(_reserve, _amount);

      uint8 _fromID = getCurveID(_reserve);
      uint8 _toID = getCurveID(_to);
      require(IERC20(_to).balanceOf(address(this)) == 0, "itrade: unexpected result");
      ICurveFi(yCurveSwap).exchange_underlying(_fromID, _toID, _borrow, _min_to_amount);
      uint256 _bought = IERC20(_to).balanceOf(address(this));
      positions[_to][msg.sender] = positions[_to][msg.sender].add(_bought);

      yERC20(getYToken(_to)).deposit(_bought);
  }

  function withdrawCollateral(address _reserve, uint256 _amount) external {
      require(isReserve(_reserve) == true, "itrade: invalid reserve");
      require(getUserDebt(_reserve, msg.sender) == 0, "itrade: outstanding debt to settle");

      require(_amount <= principals[_reserve][msg.sender], "itrade: insufficient balance");
      require(IERC20(_reserve).balanceOf(address(this)) == 0, "itrade: unexpected result");

      uint256 _price = yERC20(getYToken(_reserve)).getPricePerFullShare();
      uint256 _ytoken = _amount.mul(1e18).div(_price);
      yERC20(getYToken(_reserve)).withdraw(_ytoken);

      require(IERC20(_reserve).balanceOf(address(this)) >= _amount, "itrade: unexpected result");
      principals[_reserve][msg.sender] = principals[_reserve][msg.sender].sub(_amount);

      IERC20(_reserve).safeTransfer(msg.sender, _amount);

      // Cleanup dust (if any)
      if (IERC20(_reserve).balanceOf(address(this)) > 0) {
        yERC20(getYToken(_reserve)).deposit(IERC20(_reserve).balanceOf(address(this)));
      }
  }

  function repayDebt(address _reserve, uint256 _amount) external {
      require(isReserve(_reserve) == true, "itrade: invalid reserve");

      uint256 debt = getUserDebt(_reserve, msg.sender);

      if (_amount > debt) {
        _amount = debt;
      }

      IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _amount);
      uint256 shares = debts[_reserve][msg.sender].mul(_amount).div(debt);
      borrower(collateral).repayAave(_reserve, _amount);
      _burnDebt(_reserve, msg.sender, shares);
  }

  function settle(address _reserve) external {
      require(isReserve(_reserve) == true, "itrade: invalid reserve");

      uint256 _debt = getUserDebt(_reserve, msg.sender);
      IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _debt);
      borrower(collateral).repayAave(_reserve, _debt);
      _burnDebt(_reserve, msg.sender, debts[_reserve][msg.sender]);
  }

  function tradePosition(address _reserve, address _to, uint256 _amount, uint256 _min_to_amount) external {
      require(isReserve(_reserve) == true, "itrade: invalid reserve");
      require(_amount <= positions[_reserve][msg.sender], "itrade: insufficient balance");
      require(IERC20(_reserve).balanceOf(address(this)) == 0, "itrade: unexpected result");

      uint256 _price = yERC20(getYToken(_reserve)).getPricePerFullShare();
      uint256 _ytoken = _amount.mul(1e18).div(_price);
      yERC20(getYToken(_reserve)).withdraw(_ytoken);

      require(IERC20(_reserve).balanceOf(address(this)) >= _amount, "itrade: unexpected result");
      require(IERC20(_to).balanceOf(address(this)) == 0, "itrade: unexpected result");

      uint8 _fromID = getCurveID(_reserve);
      uint8 _toID = getCurveID(_to);

      ICurveFi(yCurveSwap).exchange_underlying(_fromID, _toID, _amount, _min_to_amount);
      positions[_reserve][msg.sender] = positions[_reserve][msg.sender].sub(_amount);
      uint256 _bought = IERC20(_to).balanceOf(address(this));
      positions[_to][msg.sender] = positions[_to][msg.sender].add(_bought);
      yERC20(getYToken(_to)).deposit(_bought);

      // Cleanup dust (if any)
      if (IERC20(_reserve).balanceOf(address(this)) > 0) {
        yERC20(getYToken(_reserve)).deposit(IERC20(_reserve).balanceOf(address(this)));
      }
  }

  function closePosition(address _reserve, uint256 _amount) external {
      require(isReserve(_reserve) == true, "itrade: invalid reserve");
      require(_amount <= positions[_reserve][msg.sender], "itrade: insufficient balance");
      require(IERC20(_reserve).balanceOf(address(this)) == 0, "itrade: unexpected result");

      uint256 debt = getUserDebt(_reserve, msg.sender);
      uint256 ret = 0;

      if (_amount > debt) {
        ret = _amount.sub(debt);
        _amount = debt;
      }

      uint256 _price = yERC20(getYToken(_reserve)).getPricePerFullShare();
      uint256 _ytoken = _amount.mul(1e18).div(_price);
      yERC20(getYToken(_reserve)).withdraw(_ytoken);

      uint256 shares = debts[_reserve][msg.sender].mul(_amount).div(debt);
      borrower(collateral).repayAave(_reserve, _amount);
      _burnDebt(_reserve, msg.sender, shares);

      // Profits from trade
      if (ret > 0) {
        IERC20(_reserve).safeTransfer(msg.sender, ret);
      }

      // Cleanup dust (if any)
      if (IERC20(_reserve).balanceOf(address(this)) > 0) {
        yERC20(getYToken(_reserve)).deposit(IERC20(_reserve).balanceOf(address(this)));
      }
  }

  function getUserDebt(address _reserve, address _user) public view returns (uint256) {
      return borrower(collateral).getBorrowDebt(_reserve).mul(debts[_reserve][_user]).div(debtsTotalSupply[_reserve]);
  }

  function getUserInterest(address _reserve, address _user) public view returns (uint256) {
      return borrower(collateral).getBorrowInterest(_reserve).mul(debts[_reserve][_user]).div(debtsTotalSupply[_reserve]);
  }
  function _mintDebt(address _reserve, address account, uint256 amount) internal {
      require(account != address(0), "DEBT: mint to the zero address");
      debtsTotalSupply[_reserve] = debtsTotalSupply[_reserve].add(amount);
      debts[_reserve][account] = debts[_reserve][account].add(amount);
  }
  function _burnDebt(address _reserve, address account, uint256 amount) internal {
      require(account != address(0), "DEBT: burn from the zero address");
      debts[_reserve][account] = debts[_reserve][account].sub(amount, "DEBT: burn amount exceeds balance");
      debtsTotalSupply[_reserve] = debtsTotalSupply[_reserve].sub(amount);
  }
  function getYToken(address _reserve) public pure returns (address) {
      if (_reserve == DAI) {
        return yDAI;
      } else if (_reserve == USDC) {
        return yUSDC;
      } else if (_reserve == USDT) {
        return yUSDT;
      /*} else if (_reserve == TUSD) {
        return yTUSD;*/
      } else {
        return address(0x0);
      }
  }
  function getCurveID(address _reserve) public pure returns (uint8) {
      if (_reserve == DAI) {
        return uint8(1);
      } else if (_reserve == USDC) {
        return uint8(2);
      } else if (_reserve == USDT) {
        return uint8(3);
      /*} else if (_reserve == TUSD) {
        return uint8(4);*/
      } else {
        return uint8(0);
      }
  }
  function isReserve(address _reserve) public pure returns (bool) {
      if (_reserve == DAI) {
        return true;
      } else if (_reserve == USDC) {
        return true;
      } else if (_reserve == USDT) {
        return true;
    /*  } else if (_reserve == TUSD) {
        return true;*/
      } else {
        return false;
      }
  }
  function isLeverage(uint256 leverage) public pure returns (bool) {
      if (leverage == 2||
        leverage == 5||
        leverage == 10||
        leverage == 25||
        leverage == 50||
        leverage == 75||
        leverage == 100||
        leverage == 1000) {
        return true;
      } else {
        return false;
      }
  }
  // incase of half-way error
  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
      uint qty = _TokenAddress.balanceOf(address(this));
      _TokenAddress.safeTransfer(msg.sender, qty);
  }
  // incase of half-way error
  function inCaseETHGetsStuck() onlyOwner public{
      (bool result, ) = msg.sender.call.value(address(this).balance)("");
      require(result, "transfer of ETH failed");
  }
}