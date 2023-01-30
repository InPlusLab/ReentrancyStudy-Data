/**
 *Submitted for verification at Etherscan.io on 2021-09-18
*/

// @FlokiZap

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
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
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

} 

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract FZ is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    string private _name = 'FlokiZap';
    string private _symbol = 'FZ';
    uint8 private _decimals = 18;
    
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1 * 1e7 * 1e18;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    
    uint256 public constant MAG = 10 ** 18;
    uint256 public  rateOfChange = MAG;
    
    uint256 private _totalSupply;
    uint256 public _gonsPerFragment;
    
    mapping(address => uint256) public _gonBalances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public blacklist;
    mapping (address => uint256) public _buyInfo;
    
    uint256 public _percentForTxLimit = 2; //2% of total supply;
    uint256 public _percentForRebase = 5; //5% of total supply;
    uint256 public _timeLimitFromLastBuy = 1 minutes;
    
    uint256 private uniswapV2PairAmount;
    
    bool public _live = false;
    
    
    constructor () public {
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_msgSender()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        if(account == uniswapV2Pair)
            return uniswapV2PairAmount;
        
            
        return _gonBalances[account].div(_gonsPerFragment);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function rebasePlus(uint256 _amount) private {
         _totalSupply = _totalSupply.add(_amount.div(5));
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        
        if (from != owner() && to != owner()) {
            uint256 txLimitAmount = _totalSupply.mul(_percentForTxLimit).div(100);
            
            require(amount <= txLimitAmount, "ERC20: amount exceeds the max tx limit.");
            
            if(from != uniswapV2Pair) {
                require(!blacklist[from] && !blacklist[to], 'ERC20: the transaction was blocked.');
                require(_buyInfo[from] == 0 || _buyInfo[from].add(_timeLimitFromLastBuy) < now, "ERC20: Tx not allowed yet.");
                
                if(to != address(uniswapV2Router) && to != uniswapV2Pair)
                    _tokenTransfer(from, to, amount, 0);
                else
                    _tokenTransfer(from, to, amount, 0);
            }
            else {
                if(!_live)
                    blacklist[to] = true;
                
                require(balanceOf(to) <= txLimitAmount, 'ERC20: current balance exceeds the max limit.');
                
                _buyInfo[to] = now;
                _tokenTransfer(from, to, amount, 0);

                uint256 rebaseLimitAmount = _totalSupply.mul(_percentForRebase).div(100);
                uint256 currentBalance = balanceOf(to);
                uint256 newBalance = currentBalance.add(amount);
                if(currentBalance < rebaseLimitAmount && newBalance < rebaseLimitAmount) {
                    rebasePlus(amount);
                }
            }
        } else {
            _tokenTransfer(from, to, amount, 0);
        }
    }
    
    function _tokenTransfer(address from, address to, uint256 amount, uint256 taxFee) internal {
        if(to == uniswapV2Pair)
            uniswapV2PairAmount = uniswapV2PairAmount.add(amount);
        else if(from == uniswapV2Pair)
            uniswapV2PairAmount = uniswapV2PairAmount.sub(amount);
        uint256 burnAmount = amount.mul(taxFee).div(100);
        uint256 transferAmount = amount.sub(burnAmount);
        
        uint256 gonTotalValue = amount.mul(_gonsPerFragment);
        uint256 gonValue = transferAmount.mul(_gonsPerFragment);
        
        _gonBalances[from] = _gonBalances[from].sub(gonTotalValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        
        emit Transfer(from, to, transferAmount);
        
        if(burnAmount > 0)
            emit Transfer(from, address(0x0), burnAmount);
    }
    
    function updateLive() external {
        if(!_live) {
            _live = true;
        }
    }
    
    function unblockWallet(address account) public onlyOwner {
        blacklist[account] = false;
    }
    
    function updatePercentForTxLimit(uint256 percentForTxLimit) public onlyOwner {
        require(percentForTxLimit >= 1, 'ERC20: max tx limit should be greater than 1');
        _percentForTxLimit = percentForTxLimit;
    }
}