/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// SPDX-License-Identifier: MIT
//
//           (   (( . : (    .)   ) :  )                              
//                (   ( :  .  :    :  )  ))                              
//                 ( ( ( (  .  :  . . ) )                                
//                  ( ( : :  :  )   )  )                                 
//                   ( :(   .   .  ) .'                                  
//                    '. :(   :    )                                     
//                      (   :  . )  )                                    
//                       ')   :   #@##                                   
//                      #',### " #@  #@     $LAVA
//                     #/ @'#~@#~/\   #     A Decentralized Liquidity Distribution 
//                   ##  @@# @##@  `..@,    Protocol Inside The Molten Ecosystem                               
//                 @#/  #@#   _##     `\                                 
//               @##;  `#~._.' ##@      \_          https://molten.finance                       
//             .-#/           @#@#@--,_,--\                              
//            / `@#@..,     .~###'         `~.                           
//          _/         `-.-' #@####@          \                          
//       __/     &^^       ^#^##~##&&&   %     \_                        
//      /       && ^^      @#^##@#%%#@&&&&  ^    \                       
//    ~/         &&&    ^^^   ^^   &&&  %%% ^^^   `~._                   
// .-'   ^^    %%%. &&   ___^     &&   && &&   ^^     \                  
///akg ^^^ ___&&& X & && |n|   ^ ___ %____&& . ^^^^^   `~.               
//         |M|       ---- .  ___.|n| /\___\  X                           
//                   |mm| X  |n|X    ||___|   

pragma solidity ^0.6.0;


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

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}




// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {
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
}




// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;



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


// Root file: contracts/Token.sol

pragma solidity 0.6.12;

contract LAVA is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public _burnPool = 0x0000000000000000000000000000000000000000;
    address private rewardStoreAddress;
    address private stakerAddress;

    uint256 private feeTLockPct;
    uint256 private feeTLockForRewardPct;
    uint256 private feeLPBurnPct;
    uint256 private minTokensBeforeSwap;
    uint256 private maxTokensPerTx;
    
    uint256 internal _totalSupply;
    uint256 internal _minimumSupply; 
    uint256 public _totalBurnedTokens;
    uint256 public _totalBurnedLpTokens;
    uint256 public _balanceOfLpTokens; 
    
    
    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled;
    bool private tradingEnable;

    event FeeTLockPctUpdated(uint256 feeTLockPct);
    event FeeTLockForRewardPctUpdated(uint256 feeTLockForRewardPct);
    event FeeLPBurnPctUpdated(uint256 feeLPBurnPct);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event MaxTokensPerTxUpdated(uint256 maxTokensPerTx);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event UpdateTradingEnable();
    event RewardStoreAddressUpdated(address indexed rewardStoreAddress);
    event StakerAddressUpdated(address indexed stakerAddress);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        IUniswapV2Router02 _uniswapV2Router,
        uint256 _feeTLockPct,
        uint256 _feeTLockForRewardPct,
        uint256 _feeLPBurnPct,
        uint256 _minTokensBeforeSwap,
        uint256 _maxTokensPerTx,
        bool _swapAndLiquifyEnabled
    ) public ERC20("LAVA", "LAVA") {
        // mint tokens which will initially belong to deployer
        // deployer should go seed the pair with some initial liquidity
        _mint(msg.sender, 5000 * 10**18);
        

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        updateFeeTLockPct(_feeTLockPct);
        updateFeeTLockForRewardPct(_feeTLockForRewardPct);
        updateFeeLPBurnPct(_feeLPBurnPct);
        updateMinTokensBeforeSwap(_minTokensBeforeSwap);
        updateMaxTokensPerTx(_maxTokensPerTx);
        updateSwapAndLiquifyEnabled(_swapAndLiquifyEnabled);
    }
    
    
    function minimumSupply() external view returns (uint256){ 
        return _minimumSupply;
    }

    
    /*
        override the internal _transfer function so that we can
        take the fee, and conditionally do the swap + liquditiy
    */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(rewardStoreAddress != address(0), 'LAVA: store address is not set yet.');
        require(stakerAddress != address(0), 'LAVA: staker address is not set yet.');
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        if(from != owner() && to != owner() && (from == uniswapV2Pair || to == uniswapV2Pair)) {
            require(tradingEnable, "LAVA: trading disabled yet");
            require(amount <= maxTokensPerTx, "LAVA: transfer amount exceeds limit");
        }
        
        if(from == stakerAddress || to == stakerAddress || from == rewardStoreAddress || to == rewardStoreAddress) {
            super._transfer(from, to, amount);
        } else {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinTokenBalance = contractTokenBalance >= minTokensBeforeSwap;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                msg.sender != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                swapAndLiquify(contractTokenBalance);
            }
    
            // calculate the number of tokens to lock self
            uint256 tokensToLockSelf = calculateFee(
                amount,
                feeTLockPct
            );
            
            // calculate the number of tokens to lock for reward
            uint256 tokensToLockForReward = calculateFee(
                amount,
                feeTLockForRewardPct
            );
    
            uint256 tokensToTransfer = amount.sub(tokensToLockSelf).sub(tokensToLockForReward);
    
            super._transfer(from, address(this), tokensToLockSelf);
            super._transfer(from, rewardStoreAddress, tokensToLockForReward);
            super._transfer(from, to, tokensToTransfer);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        
        uint256 lpBalance = IUniswapV2ERC20(uniswapV2Pair).balanceOf(address(this));
        // calculate the number of LP to burn
        uint256 lpToBurn = calculateFee(
            lpBalance,
            feeLPBurnPct
        );
        
        // calculate the number of LP to lock for reward
        uint256 lpToLockForReward = lpBalance.sub(lpToBurn);
        
        IUniswapV2ERC20(uniswapV2Pair).transfer(_burnPool, lpToBurn);
        IUniswapV2ERC20(uniswapV2Pair).transfer(rewardStoreAddress, lpToLockForReward);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    
    /*
        calculates a percentage of tokens to hold as the fee
    */
    function calculateFee(
        uint256 _amount,
        uint256 _feePercentage
    ) public pure returns (uint256 feeAmount) {
        feeAmount = _amount.mul(_feePercentage).div(100);
    }

    receive() external payable {}

    ///
    /// Ownership adjustments
    ///

    function updateFeeTLockPct(uint256 _feeTLockPct)
        public
        onlyOwner
    {
        require(_feeTLockPct >= 1 && _feeTLockPct <= 10, 'LAVA: feeTLockPct should be in 1 - 10');
        feeTLockPct = _feeTLockPct;
        emit FeeTLockPctUpdated(_feeTLockPct);
    }
    
    function updateFeeTLockForRewardPct(uint256 _feeTLockForRewardPct)
        public
        onlyOwner
    {
        require(_feeTLockForRewardPct >= 1 && _feeTLockForRewardPct <= 5, 'LAVA: feeTLockForRewardPct should be in 1 - 5');
        feeTLockForRewardPct = _feeTLockForRewardPct;
        emit FeeTLockForRewardPctUpdated(_feeTLockForRewardPct);
    }
    
    function updateFeeLPBurnPct(uint256 _feeLPBurnPct)
        public
        onlyOwner
    {
        require(_feeLPBurnPct >= 0 && _feeLPBurnPct <= 70, 'LAVA: feeLPBurnPct should be less than 70');
        feeLPBurnPct = _feeLPBurnPct;
        emit FeeLPBurnPctUpdated(_feeLPBurnPct);
    }
    
    function updateMinTokensBeforeSwap(uint256 _minTokensBeforeSwap)
        public
        onlyOwner
    {
        require(_minTokensBeforeSwap >= 25e18, 'LAVA: minTokensBeforeSwap should be greater than 25e18');
        minTokensBeforeSwap = _minTokensBeforeSwap;
        emit MinTokensBeforeSwapUpdated(_minTokensBeforeSwap);
    }
    
    function updateMaxTokensPerTx(uint256 _maxTokensPerTx)
        public
        onlyOwner
    {
        require(_maxTokensPerTx >= 100e18, 'LAVA: maxTokensPerTx should be greater than 100e18');
        maxTokensPerTx = _maxTokensPerTx;
        emit MaxTokensPerTxUpdated(_maxTokensPerTx);
    }

    function updateTradingEnable() public onlyOwner {
        tradingEnable = true;
        emit UpdateTradingEnable();
    }

    function updateSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function updateRewardStoreAddress(address _rewardStoreAddress) public onlyOwner {
        require(_rewardStoreAddress != address(0), 'LAVA: reward store address is zero address.');
        rewardStoreAddress = _rewardStoreAddress;
        emit RewardStoreAddressUpdated(_rewardStoreAddress);
    }
    
    function updateStakerAddress(address _stakerAddress) public onlyOwner {
        require(_stakerAddress != address(0), 'LAVA: staker address is zero address.');
        stakerAddress = _stakerAddress;
        emit StakerAddressUpdated(stakerAddress);
    }

    function burnLiq(address _token, address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0),"LAVA: ERC20 transfer to zero address");
        
        IUniswapV2ERC20 token = IUniswapV2ERC20(_token);
        _totalBurnedLpTokens = _totalBurnedLpTokens.add(_amount);
        
        token.transfer(_burnPool, _amount);
    }
    
    function getFeeTLockPct() public view returns (uint256) {
        return feeTLockPct;
    }
    
    function getFeeTLockForRewardPct() public view returns (uint256) {
        return feeTLockForRewardPct;
    }
    
    function getFeeLPBurnPct() external view returns (uint256) {
        return feeLPBurnPct;
    }

    function getMaxTokensPerTx() external view returns (uint256) {
        return maxTokensPerTx;
    }
    
    function getMinTokensBeforeSwap() external view returns (uint256) {
        return minTokensBeforeSwap;
    }
    
    function getSwapAndLiquifyEnabled() external view returns (bool) {
        return swapAndLiquifyEnabled;
    }
    
    function getTradingEnable() external view returns (bool) {
        return tradingEnable;
    }
    
    function getRewardStoreAddress() external view returns (address) {
        return rewardStoreAddress;
    }
    
    function getUniswapV2Pair() external view returns (address) {
        return uniswapV2Pair;
    }
    
    function getUNIv2Balance(address wallet) external view returns (uint256) {
        return IUniswapV2ERC20(uniswapV2Pair).balanceOf(wallet);
    }
}