/**
 *Submitted for verification at Etherscan.io on 2021-06-16
*/

// File: openzeppelin-contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-contracts/GSN/Context.sol

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin-contracts/math/SafeMath.sol

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 */
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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. 
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
}

// File: openzeppelin-contracts/access/Ownable.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/TheRedOrder.sol

pragma solidity ^0.8.0;





contract TheRedOrder is Context, Ownable, IERC20 {

    using SafeMath for uint256;

    // holds the balances of everyone who owes tokens of this contract
    mapping (address => uint256) private _balances;
    // holds the amount authorized by address
    mapping (address => mapping (address => uint256)) private _allowances;

    string  private _name               = "TheRedOrder";
    string  private _symbol             = "ORDR";

    // 18 decimal contract
    uint8   private _decimals           = 18;
    // 1 trillion * decimal count
    uint256 private _totalSupply        = 500000 * 10**6 * 10**18;

    address private _marketingWallet    = 0xcdcacbAc38785E462dAe096b55a86A05419A060a;

    // send total supply to the address that has created the contract
    constructor () {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // return name of the token
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // return symbol of the token
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // return decimals of token
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    // return amount in supply
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // return the balance of tokens from the address passed in
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    // transfers amount from the person calling the function to 
    // the address called [@param 1] in the amount specified [@param 2]
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // returns the amount authorized by one account [@param 1] to allow account 2 [@aram2] to spend 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // approves the person who calles this function to allow another address [@param1] to spend the 
    // amount specified [@param2]
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // transferes from account 1 [@param1] to account 2 [@param 2] the designated amount [@param 3]
    // requires the person calling the function has at least the amount of the transfer authorized for them to send
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        uint256 newAllowance = currentAllowance.sub(amount);
        _approve(sender, _msgSender(), newAllowance);

        return true;
    }

    // the person calling this function INCREASES the allowance of the address called [@param1] can spend
    // on their belave by the amount send [@param2]
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        uint256 newAllowance = _allowances[_msgSender()][spender].add(addedValue);
        _approve(_msgSender(), spender, newAllowance);
        return true;
    }

    // the person calling this function DECREASED the allowance of the address called [@param1] can spend
    // on their belave by the amount send [@param2]
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        uint256 newAllowance = currentAllowance.sub(subtractedValue);
        _approve(_msgSender(), spender, newAllowance);

        return true;
    }

    // performs a transfer from address 1 [@param2] to address 2 [@param 2] in the amount
    // that is specified [@param 3]. Fees in the total amount of 12% are deducted. 2% goes
    // into a marketing walled, 2% is removed from total supply, 8% goes to liquidity wallet
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender    != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // amount to send to the marketing wallet (2%)
        uint256 marketingFee  = amount.mul(2).div(100);
        // amount to burn of the total supply (2%)
        uint256 burnFee       = amount.mul(2).div(100);
        // amount to send into pool (2%)
        uint256 liquidityFee  = amount.mul(2).div(100);

        // declare the amount the sender has in their account
        uint256 senderBalance = _balances[sender];

        // declare amount that actually gets transfered after burn, liquidity, and marketing fees
        uint256 totalTransfer   = amount.sub(marketingFee);
        totalTransfer           = totalTransfer.sub(burnFee);
        totalTransfer           = totalTransfer.sub(liquidityFee);

        _beforeTokenTransfer(sender, recipient, amount);

        // require that the balaner of the person this transfer is coming from has the funds
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        // reduce the full amount from the sender's balance
        _balances[sender]           -=  amount;
        // add the after fees amount to the recipeint
        _balances[recipient]        += totalTransfer;
        // add the balance to the marketing wallet
        _balances[_marketingWallet] += marketingFee;
        // add the burn balance to address 0
        _balances[address(0)]       += burnFee;
        // send taxed amount to the contract
        _balances[owner()]    += liquidityFee;

        // subtract burn fee from total supply
        _totalSupply = _totalSupply.sub(burnFee);

        // transfer the after fee amount to the recipient
        emit Transfer(sender, recipient, totalTransfer);
        // transfer the marketing percent to the marketing wallet
        emit Transfer(sender, _marketingWallet, marketingFee);
        // transfer the burn fee to the 0 address
        emit Transfer(sender, address(0), burnFee);
        // send the tax amount to the liquidity wallet
        emit Transfer(sender, owner(), liquidityFee);

    }

    // no need to check for balance here, _transfer function checks to see if the amount
    // being transfered is >= to the balance of the person sending the tokens
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}