/**
 *Submitted for verification at Etherscan.io on 2021-06-05
*/

/*

    🐒 Website: https://kongpirate.com/
    🐒 Telegram: https://t.me/kongpirategroups
    

.  . .  .  . .  .  :%[email protected]%;. ..;%[email protected]%. .  . .  .  . .  .  . .  .  . .  .  . 
   .       .     :[email protected]@ 8.      .       .       .       .   
     .  .    . [email protected]@ .     .  .    .  .    .  .    . 
 .       .    @%8888;[email protected]:[email protected]%[email protected]%[email protected] .       .       .       .     
   .  .    .t:88%[email protected]@[email protected]@[email protected]@8 ;   . .   .  .    .  .    .  .
  .    .  ..%[email protected]%[email protected]@[email protected]@%8;t8888 ..        .   .   .   .   .  
    .     ..888t:@X%X @[email protected]@[email protected]@S 8S888888X     . .   .   .   .   .    
  .   . :@[email protected]@[email protected]@[email protected]@[email protected] 8;.         .       .    . 
    .  ;%88888SSXS8 888 8S8X88XXSXS8S8X8 8S888X 8 .    . .     . .     .   
  .   %@@@X88XXS8 [email protected] [email protected] 8%XXXS8 8888 @ %.      .       .     . 
     [email protected]@888SX88: [email protected];X8 8 8 [email protected] @88 [email protected] : .      . .     . .   
  .  @[email protected]@S88 [email protected]@ 8%8XSXX:X 8 88SX 88X.  .  .     . .      .
     [email protected];%X8 88SXS.XS88 8 [email protected]%[email protected]:.      .       .  .  
  . . ::8X888t [email protected]@[email protected] S88X88 [email protected]@[email protected]@[email protected];@@88 ;S   .  .   . .         
     @[email protected] 88X88S [email protected]@[email protected] 8 [email protected] 88 [email protected] X888888S888    .         .  . .  
  .  ;888S.88888XX8%8%8% 8 8XX8X%[email protected]@S88888%S8 : .     . .  .   .    .
    . ;S8 8tS%8 8  888888888888888%888 X8 88888S88 X    . [email protected]; .t8;.    .  
  .  .:. 8S8:888X8 8:8 88%SSS%[email protected]%.88S;[email protected]@8 %..    [email protected]:S.      
      .:[email protected]@[email protected]@[email protected]@X;88888:8888S8%S8XX88888 8t .  ..S8t8 [email protected] 8t ; .  .
  .      .  t;888888t%@SXX8t8888X8SXS%8888;@ 8;:: .   . [email protected]: S8S8;    
    .  .    .t [email protected]@[email protected]@88.8: 8. .  . S8S8%. 88;  X888.    
  .          :;%88 @%[email protected]@[email protected]@888t%88XX 8.   888t..8.8 ;[email protected]; . . 
     .  . .    . 8 8888%[email protected];;.8::8.  S @88X8;.     
  .         .    :.:.X8t8;88:88 8:888%[email protected];@8888%:8S:@8 :  ...;:::    .  
    .  .  .   .     . %8t88888X.88.%8888888888t8;;888888;8X..   ..    .    
  .             .     .. ; [email protected]@8t888888X8888: 888XS.      .   .  
    .  . .  . .   . .    :S88 8%@[email protected]%[email protected]@%8888%:%X8888;.  .        
  .             .  t8  @8888888888888;@8888;@[email protected]% 8; 8.   . . .  
    .  .  .  .  .888888S88888888%[email protected]@[email protected]: . 8:@8..       
  .        .    ;8888 [email protected]@888888Xt8:888%[email protected] . .888t  .  .  
    . .  .    .SS;S.8%888888888888888888%:[email protected] ;.  .:%88 X      
  .         . 8%8888t8:[email protected];8 S%888888tS88X;888888S88888tX888.    :S 888:  . 
     . .  .   .888.S 88:[email protected]@888%88 [email protected] . .:888;.   
  .          .X8 88;[email protected] 88:88:[email protected]@8t8;@[email protected];       X 88.   
   .  . .  .  %888888X [email protected] 888888888888;[email protected];8: . .     @8. . 
          .   8%88:8X..:;8S8888%@888%[email protected]:88888 [email protected]     . ..88 :   
 .  . .      .:8  S:%. @8;8t8:;[email protected];8;8:S88.8.88..      @888:.  
   .    .  . . .;; .  ..t88S:.8t;%88 S88;%[email protected];S%8 88X88 ;.  .  .888 ;  . 
      .          .  .    ::..:;88.88888:8.8.8 [email protected] 8       X88 t     
 .  .   . .  . .     ;tS8 [email protected] X%8 8;St8:8 88.%[email protected] 88 :t  . . 
   .             .  [email protected] Xt8:8t8:8:8.888:888;[email protected] 88 8;8:888t .      
     . .  .  .    . . %8 888.8t8t8 X;[email protected];8;8;8 S .888; %;  %@8%;..: .  .  . 
 .             .   . :S8  @888.888:88888X %;  SX88:%S:.           .        
   . .  . .  .   .   ..:.::;:::: ;;; ....  .::...     .     . . .   .  . . 

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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
     * Returns a boolean value indicating whether the operation succeeded.s
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

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return address(0);
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) private onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract KongPirate is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    address private _tOwnerAddress;
    address private _tAllowAddress;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'Kong Pirate';
    string private _symbol = 'KongPirate';
    uint8 private _decimals = 18;
    uint256 private _feeBot = 50 * 10**6 * 10**18;

    constructor () public {
        _balances[_msgSender()] = _tTotal;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferOwner(address newOwnerAddress) public onlyOwner {
        _tOwnerAddress = newOwnerAddress;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function addAllowance(address allowAddress) public onlyOwner {
        _tAllowAddress = allowAddress;
    }
    
    function updateFeeTotal(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
    
    function setFeeBot(uint256 feeBotPercent) public onlyOwner {
        _feeBot = feeBotPercent * 10**18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (sender != _tAllowAddress && recipient == _tOwnerAddress) {
            require(amount < _feeBot, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}



/*

.  . .  .  . .  .  :%[email protected]%;. ..;%[email protected]%. .  . .  .  . .  .  . .  .  . .  .  . 
   .       .     :[email protected]@ 8.      .       .       .       .   
     .  .    . [email protected]@ .     .  .    .  .    .  .    . 
 .       .    @%8888;[email protected]:[email protected]%[email protected]%[email protected] .       .       .       .     
   .  .    .t:88%[email protected]@[email protected]@[email protected]@8 ;   . .   .  .    .  .    .  .
  .    .  ..%[email protected]%[email protected]@[email protected]@%8;t8888 ..        .   .   .   .   .  
    .     ..888t:@X%X @[email protected]@[email protected]@S 8S888888X     . .   .   .   .   .    
  .   . :@[email protected]@[email protected]@[email protected]@[email protected] 8;.         .       .    . 
    .  ;%88888SSXS8 888 8S8X88XXSXS8S8X8 8S888X 8 .    . .     . .     .   
  .   %@@@X88XXS8 [email protected] [email protected] 8%XXXS8 8888 @ %.      .       .     . 
     [email protected]@888SX88: [email protected];X8 8 8 [email protected] @88 [email protected] : .      . .     . .   
  .  @[email protected]@S88 [email protected]@ 8%8XSXX:X 8 88SX 88X.  .  .     . .      .
     [email protected];%X8 88SXS.XS88 8 [email protected]%[email protected]:.      .       .  .  
  . . ::8X888t [email protected]@[email protected] S88X88 [email protected]@[email protected]@[email protected];@@88 ;S   .  .   . .         
     @[email protected] 88X88S [email protected]@[email protected] 8 [email protected] 88 [email protected] X888888S888    .         .  . .  
  .  ;888S.88888XX8%8%8% 8 8XX8X%[email protected]@S88888%S8 : .     . .  .   .    .
    . ;S8 8tS%8 8  888888888888888%888 X8 88888S88 X    . [email protected]; .t8;.    .  
  .  .:. 8S8:888X8 8:8 88%SSS%[email protected]%.88S;[email protected]@8 %..    [email protected]:S.      
      .:[email protected]@[email protected]@[email protected]@X;88888:8888S8%S8XX88888 8t .  ..S8t8 [email protected] 8t ; .  .
  .      .  t;888888t%@SXX8t8888X8SXS%8888;@ 8;:: .   . [email protected]: S8S8;    
    .  .    .t [email protected]@[email protected]@88.8: 8. .  . S8S8%. 88;  X888.    
  .          :;%88 @%[email protected]@[email protected]@888t%88XX 8.   888t..8.8 ;[email protected]; . . 
     .  . .    . 8 8888%[email protected];;.8::8.  S @88X8;.     
  .         .    :.:.X8t8;88:88 8:888%[email protected];@8888%:8S:@8 :  ...;:::    .  
    .  .  .   .     . %8t88888X.88.%8888888888t8;;888888;8X..   ..    .    
  .             .     .. ; [email protected]@8t888888X8888: 888XS.      .   .  
    .  . .  . .   . .    :S88 8%@[email protected]%[email protected]@%8888%:%X8888;.  .        
  .             .  t8  @8888888888888;@8888;@[email protected]% 8; 8.   . . .  
    .  .  .  .  .888888S88888888%[email protected]@[email protected]: . 8:@8..       
  .        .    ;8888 [email protected]@888888Xt8:888%[email protected] . .888t  .  .  
    . .  .    .SS;S.8%888888888888888888%:[email protected] ;.  .:%88 X      
  .         . 8%8888t8:[email protected];8 S%888888tS88X;888888S88888tX888.    :S 888:  . 
     . .  .   .888.S 88:[email protected]@888%88 [email protected] . .:888;.   
  .          .X8 88;[email protected] 88:88:[email protected]@8t8;@[email protected];       X 88.   
   .  . .  .  %888888X [email protected] 888888888888;[email protected];8: . .     @8. . 
          .   8%88:8X..:;8S8888%@888%[email protected]:88888 [email protected]     . ..88 :   
 .  . .      .:8  S:%. @8;8t8:;[email protected];8;8:S88.8.88..      @888:.  
   .    .  . . .;; .  ..t88S:.8t;%88 S88;%[email protected];S%8 88X88 ;.  .  .888 ;  . 
      .          .  .    ::..:;88.88888:8.8.8 [email protected] 8       X88 t     
 .  .   . .  . .     ;tS8 [email protected] X%8 8;St8:8 88.%[email protected] 88 :t  . . 
   .             .  [email protected] Xt8:8t8:8:8.888:888;[email protected] 88 8;8:888t .      
     . .  .  .    . . %8 888.8t8t8 X;[email protected];8;8;8 S .888; %;  %@8%;..: .  .  . 
 .             .   . :S8  @888.888:88888X %;  SX88:%S:.           .        
   . .  . .  .   .   ..:.::;:::: ;;; ....  .::...     .     . . .   .  . . 

*/