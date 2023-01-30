/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

/**
     * OhOhOh is a degen token that is directly inspired by Christmas. 
     * Even if you had a bad year, at the end of the year, there is always place for joy and wonder with Christmas. We wanted to to the same with $OhOhOh !
     * Telegram : t.me/ohohoh_christmas
     * Website : www.ohohoh.io
     * 
     * Code based on : HypeBurn contract 
     */


pragma solidity ^0.6.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract OhOhOh is ERC20, Ownable {
  
  address public feeRecipient;
  address public burnAddress;
  bool private activeFee;
  uint256 burnPercent; 
  uint256 rewardPercent; 
  uint256 xmasGift;
    
  constructor() public ERC20("ohohoh.io", "OHOHOH") { // Symbol and Name
    // Mint 2512 XMAS (18 Decimals)
    _mint(0x891f6D0e871b91dabdD89f77d91C0cd7A1f4eC0B, 2260000000000000000000);      // launch Address - 2260 tokens for private sale + liquidity
    _mint(address(this), 252000000000000000000);                                    // locked Xmas Reward - 252 tokens - unlocked the 20st Dec 2020 for a big prize
    feeRecipient = 0x891f6D0e871b91dabdD89f77d91C0cd7A1f4eC0B;                      // tax Address - for distributing rewards to holders every day before XMas
    burnAddress = 0x000000000000000000000000000000000000dEaD;                       // burn Address - don't go there, son. No token ever returned from dEaD address...
    activeFee = false;
    burnPercent = 5500;                                                             // 5500 = 55% of the tax is burnt                                    
    rewardPercent = 4500;                                                           // 4500 = 45% of the tax are used to reward holders
    xmasGift = 252000000000000000000;                                               // locked Xmas reward value
    
  }

  // Exception to transfer fees, for example for Uniswap contracts.
  mapping (address => bool) public feeException;
  
  event AddFeeException(address account);
  event RemoveFeeException(address account);
  
  function activateFee(bool _activeFee) public onlyOwner {
    activeFee = _activeFee;
  }

  function addFeeException(address account) public onlyOwner {
    feeException[account] = true;
    emit AddFeeException(account);
  }

  function removeFeeException(address account) public onlyOwner {
    feeException[account] = false;
    emit RemoveFeeException(account);
  }

  function getTransferFee() public view returns(uint256) {
    if (activeFee == false) return 0;
    uint256 transferFee;                        // Fee as percentage, where 100 = 1%
    uint256 blockTime = block.timestamp;

    if (blockTime < 1606780800) {               // before December 1 2020 
        transferFee = 0;                          // fee = 0%
    } else if(blockTime < 1606867200) {         // then until December 2 2020
        transferFee = 100;                       // fee = 1%
    } else if(blockTime < 1606953600) {         // then until December 3 2020
        transferFee = 200;                       // fee = 2%
    } else if(blockTime < 1607040000) {         // then until December 4 2020
        transferFee = 300;                       // fee = 3%
    } else if(blockTime < 1607126400) {         // then until December 5 2020
        transferFee = 400;                       // fee = 4%
    } else if(blockTime < 1607212800) {         // then until December 6 2020
        transferFee = 500;                       // fee = 5%
    } else if(blockTime < 1607299200) {         // then until December 7 2020
        transferFee = 600;                       // fee = 6%
    } else if(blockTime < 1607385600) {         // then until December 8 2020
        transferFee = 700;                       // fee = 7%
    } else if(blockTime < 1607472000) {         // then until December 9 2020
        transferFee = 800;                       // fee = 8%
    } else if(blockTime < 1607558400) {         // then until December 10 2020
        transferFee = 900;                       // fee = 9%
    } else if(blockTime < 1607644800) {         // then until December 11 2020
        transferFee = 1000;                       // fee = 10%
    } else if(blockTime < 1607731200) {         // then until December 12 2020
        transferFee = 1100;                       // fee = 11%
    } else if(blockTime < 1607817600) {         // then until December 13 2020
        transferFee = 1200;                       // fee = 12%
    } else if(blockTime < 1607904000) {         // then until December 14 2020
        transferFee = 1300;                       // fee = 13%
    } else if(blockTime < 1607990400) {         // then until December 15 2020
        transferFee = 1400;                       // fee = 14%
    } else if(blockTime < 1608076800) {         // then until December 16 2020
        transferFee = 1500;                       // fee = 15%
    } else if(blockTime < 1608163200) {         // then until December 17 2020
        transferFee = 1600;                       // fee = 16%
    } else if(blockTime < 1608249600) {         // then until December 18 2020
        transferFee = 1700;                       // fee = 17%
    } else if(blockTime < 1608336000) {         // then until December 19 2020
        transferFee = 1800;                       // fee = 18%
    } else if(blockTime < 1608422400) {         // then until December 20 2020
        transferFee = 1900;                       // fee = 19%
    } else if(blockTime < 1608508800) {         // then until December 21 2020
        transferFee = 2000;                       // fee = 20%
    } else if(blockTime < 1608595200) {         // then until December 22 2020
        transferFee = 2100;                       // fee = 21%
    } else if(blockTime < 1608681600) {         // then until December 23 2020
        transferFee = 2200;                       // fee = 22%
    } else if(blockTime < 1608768000) {         // then until December 24 2020
        transferFee = 2300;                       // fee = 23%
    } else if(blockTime < 1608854400) {         // then until December 25 2020
        transferFee = 2400;                       // fee = 24%
    } else {                                    // then after December 25 2020
        transferFee = 2500;                       // fee = 25%
    }
    
    return transferFee;
  }
  
  function unlockXmasReward() public {
      require(block.timestamp > 1608422400);    // Xmas reward will be unlocked on Dec 20th
      _transfer(address(this), feeRecipient, xmasGift);
  }


  // Transfer recipient recives amount - fee
  function transfer(address recipient, uint256 amount) public override returns (bool) {
    if (activeFee && feeException[_msgSender()] == false) {
      uint256 transferFee = getTransferFee();
      uint256 fee = transferFee.mul(amount).div(10000);
      uint256 amountLessFee = amount.sub(fee);
      uint256 amountBurnt = fee.mul(burnPercent).div(10000);
      uint256 amountRewarded = fee.mul(rewardPercent).div(10000);
      _transfer(_msgSender(), recipient, amountLessFee);
      _transfer(_msgSender(), feeRecipient, amountRewarded);
      _transfer(_msgSender(), burnAddress, amountBurnt);
    } else {
      _transfer(_msgSender(), recipient, amount);
    }
    return true;
  }

  // TransferFrom recipient recives amount, sender's account is debited amount + fee
  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    if (activeFee && feeException[recipient] == false) {
      uint256 transferFee = getTransferFee();
      uint256 fee = transferFee.mul(amount).div(10000);
      uint256 amountBurnt = fee.mul(burnPercent).div(10000);
      uint256 amountRewarded = fee.mul(rewardPercent).div(10000);
      _transfer(sender, feeRecipient, amountRewarded);
      _transfer(sender, burnAddress, amountBurnt);
    }
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

}