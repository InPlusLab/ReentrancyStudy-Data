/**
 *Submitted for verification at Etherscan.io on 2019-08-30
*/

pragma solidity >=0.4.21 <0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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

// Compound finance ERC20 market interface
interface CERC20 {
  function mint(uint mintAmount) external returns (uint);
  function redeemUnderlying(uint redeemAmount) external returns (uint);
  function borrow(uint borrowAmount) external returns (uint);
  function repayBorrow(uint repayAmount) external returns (uint);
  function borrowBalanceCurrent(address account) external returns (uint);
  function exchangeRateCurrent() external returns (uint);
  function transfer(address recipient, uint256 amount) external returns (bool);

  function balanceOf(address account) external view returns (uint);
  function decimals() external view returns (uint);
  function underlying() external view returns (address);
  function exchangeRateStored() external view returns (uint);
}

// Compound finance comptroller
interface Comptroller {
  function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
  function markets(address cToken) external view returns (bool isListed, uint256 collateralFactorMantissa);
}

contract PooledCDAI is ERC20, Ownable {
  uint256 internal constant PRECISION = 10 ** 18;

  address public constant COMPTROLLER_ADDRESS = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
  address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

  string private _name;
  string private _symbol;

  address public beneficiary; // the account that will receive the interests from Compound

  event Mint(address indexed sender, address indexed to, uint256 amount);
  event Burn(address indexed sender, address indexed to, uint256 amount);
  event WithdrawInterest(address indexed sender, address beneficiary, uint256 amount, bool indexed inDAI);
  event SetBeneficiary(address oldBeneficiary, address newBeneficiary);

  /**
    * @dev Sets the values for `name` and `symbol`. Both of
    * these values are immutable: they can only be set once during
    * construction.
    */
  function init(string memory name, string memory symbol, address _beneficiary) public {
    require(beneficiary == address(0), "Already initialized");

    _name = name;
    _symbol = symbol;

    // Set beneficiary
    require(_beneficiary != address(0), "Beneficiary can't be zero");
    beneficiary = _beneficiary;
    emit SetBeneficiary(address(0), _beneficiary);
    
    _transferOwnership(msg.sender);

    // Enter cDAI market
    Comptroller troll = Comptroller(COMPTROLLER_ADDRESS);
    address[] memory cTokens = new address[](1);
    cTokens[0] = CDAI_ADDRESS;
    uint[] memory errors = troll.enterMarkets(cTokens);
    require(errors[0] == 0, "Failed to enter cDAI market");
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
    * Ether and Wei.
    *
    * NOTE: This information is only used for _display_ purposes: it in
    * no way affects any of the arithmetic of the contract, including
    * {IERC20-balanceOf} and {IERC20-transfer}.
    */
  function decimals() public pure returns (uint8) {
    return 18;
  }

  function mint(address to, uint256 amount) public returns (bool) {
    // transfer `amount` DAI from msg.sender
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transferFrom(msg.sender, address(this), amount), "Failed to transfer DAI from msg.sender");

    // use `amount` DAI to mint cDAI
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    require(dai.approve(CDAI_ADDRESS, 0), "Failed to clear DAI allowance");
    require(dai.approve(CDAI_ADDRESS, amount), "Failed to set DAI allowance");
    require(cDAI.mint(amount) == 0, "Failed to mint cDAI");

    // mint `amount` pcDAI for `to`
    _mint(to, amount);

    // emit event
    emit Mint(msg.sender, to, amount);

    return true;
  }

  function burn(address to, uint256 amount) public returns (bool) {
    // burn `amount` pcDAI for msg.sender
    _burn(msg.sender, amount);

    // burn cDAI for `amount` DAI
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    require(cDAI.redeemUnderlying(amount) == 0, "Failed to redeem");

    // transfer DAI to `to`
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transfer(to, amount), "Failed to transfer DAI to target");

    // emit event
    emit Burn(msg.sender, to, amount);

    return true;
  }

  function accruedInterestCurrent() public returns (uint256) {
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    return cDAI.exchangeRateCurrent().mul(cDAI.balanceOf(address(this))).div(PRECISION).sub(totalSupply());
  }

  function accruedInterestStored() public view returns (uint256) {
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    return cDAI.exchangeRateStored().mul(cDAI.balanceOf(address(this))).div(PRECISION).sub(totalSupply());
  }

  function withdrawInterestInDAI() public returns (bool) {
    // calculate amount of interest in DAI
    uint256 interestAmount = accruedInterestCurrent();

    // burn cDAI
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    require(cDAI.redeemUnderlying(interestAmount) == 0, "Failed to redeem");

    // transfer DAI to beneficiary
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transfer(beneficiary, interestAmount), "Failed to transfer DAI to beneficiary");

    emit WithdrawInterest(msg.sender, beneficiary, interestAmount, true);

    return true;
  }

  function withdrawInterestInCDAI() public returns (bool) {
    // calculate amount of cDAI to transfer
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    uint256 interestAmountInCDAI = accruedInterestCurrent().mul(PRECISION).div(cDAI.exchangeRateCurrent());

    // transfer cDAI to beneficiary
    require(cDAI.transfer(beneficiary, interestAmountInCDAI), "Failed to transfer cDAI to beneficiary");

    // emit event
    emit WithdrawInterest(msg.sender, beneficiary, interestAmountInCDAI, false);

    return true;
  }

  function setBeneficiary(address newBeneficiary) public onlyOwner returns (bool) {
    require(newBeneficiary != address(0), "Beneficiary can't be zero");
    emit SetBeneficiary(beneficiary, newBeneficiary);

    beneficiary = newBeneficiary;

    return true;
  }

  function() external payable {
    revert("Contract doesn't support receiving Ether");
  }
}

/*
The MIT License (MIT)

Copyright (c) 2018 Murray Software, LLC.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}

contract PooledCDAIFactory is CloneFactory {

  address public libraryAddress;

  event CreatePool(address sender, address pool, bool indexed renounceOwnership);

  constructor(address _libraryAddress) public {
    libraryAddress = _libraryAddress;
  }

  function createPCDAI(string memory name, string memory symbol, address beneficiary, bool renounceOwnership) public returns (PooledCDAI) {
    PooledCDAI pcDAI = _createPCDAI(name, symbol, beneficiary, renounceOwnership);
    emit CreatePool(msg.sender, address(pcDAI), renounceOwnership);
    return pcDAI;
  }

  function _createPCDAI(string memory name, string memory symbol, address beneficiary, bool renounceOwnership) internal returns (PooledCDAI) {
    address payable clone = _toPayableAddr(createClone(libraryAddress));
    PooledCDAI pcDAI = PooledCDAI(clone);
    pcDAI.init(name, symbol, beneficiary);
    if (renounceOwnership) {
      pcDAI.renounceOwnership();
    } else {
      pcDAI.transferOwnership(msg.sender);
    }
    return pcDAI;
  }

  function _toPayableAddr(address _addr) internal pure returns (address payable) {
    return address(uint160(_addr));
  }
}

contract MetadataPooledCDAIFactory is PooledCDAIFactory {
  event CreatePoolWithMetadata(address sender, address pool, bool indexed renounceOwnership, bytes metadata);

  constructor(address _libraryAddress) public PooledCDAIFactory(_libraryAddress) {}

  function createPCDAIWithMetadata(
    string memory name,
    string memory symbol,
    address beneficiary,
    bool renounceOwnership,
    bytes memory metadata
  ) public returns (PooledCDAI) {
    PooledCDAI pcDAI = _createPCDAI(name, symbol, beneficiary, renounceOwnership);
    emit CreatePoolWithMetadata(msg.sender, address(pcDAI), renounceOwnership, metadata);
  }
}

interface KyberNetworkProxy {
  function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
      returns (uint expectedRate, uint slippageRate);

  function tradeWithHint(
    ERC20 src, uint srcAmount, ERC20 dest, address payable destAddress, uint maxDestAmount,
    uint minConversionRate, address walletId, bytes calldata hint) external payable returns(uint);
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
        // solhint-disable-next-line max-line-length
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

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
  @dev An extension to PooledCDAI that enables minting & burning pcDAI using ETH & ERC20 tokens
    supported by Kyber Network, rather than just DAI. There's no need to deploy one for each pool,
    since it uses pcDAI as a black box.
 */
contract PooledCDAIKyberExtension {
  using SafeERC20 for ERC20;
  using SafeERC20 for PooledCDAI;
  using SafeMath for uint256;

  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
  address public constant KYBER_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
  ERC20 internal constant ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
  bytes internal constant PERM_HINT = "PERM"; // Only use permissioned reserves from Kyber
  uint internal constant MAX_QTY   = (10**28); // 10B tokens

  function mintWithETH(PooledCDAI pcDAI, address to) public payable returns (bool) {
    // convert `msg.value` ETH to DAI
    ERC20 dai = ERC20(DAI_ADDRESS);
    (uint256 actualDAIAmount, uint256 actualETHAmount) = _kyberTrade(ETH_TOKEN_ADDRESS, msg.value, dai);

    // mint `actualDAIAmount` pcDAI
    _mint(pcDAI, to, actualDAIAmount);

    // return any leftover ETH
    if (actualETHAmount < msg.value) {
      msg.sender.transfer(msg.value.sub(actualETHAmount));
    }

    return true;
  }

  function mintWithToken(PooledCDAI pcDAI, address tokenAddress, address to, uint256 amount) public returns (bool) {
    require(tokenAddress != address(ETH_TOKEN_ADDRESS), "Use mintWithETH() instead");
    require(tokenAddress != DAI_ADDRESS, "Use mint() instead");

    // transfer `amount` token from msg.sender
    ERC20 token = ERC20(tokenAddress);
    token.safeTransferFrom(msg.sender, address(this), amount);

    // convert `amount` token to DAI
    ERC20 dai = ERC20(DAI_ADDRESS);
    (uint256 actualDAIAmount, uint256 actualTokenAmount) = _kyberTrade(token, amount, dai);

    // mint `actualDAIAmount` pcDAI
    _mint(pcDAI, to, actualDAIAmount);

    // return any leftover tokens
    if (actualTokenAmount < amount) {
      token.safeTransfer(msg.sender, amount.sub(actualTokenAmount));
    }

    return true;
  }

  function burnToETH(PooledCDAI pcDAI, address payable to, uint256 amount) public returns (bool) {
    // burn `amount` pcDAI for msg.sender to get DAI
    _burn(pcDAI, amount);

    // convert `amount` DAI to ETH
    ERC20 dai = ERC20(DAI_ADDRESS);
    (uint256 actualETHAmount, uint256 actualDAIAmount) = _kyberTrade(dai, amount, ETH_TOKEN_ADDRESS);

    // transfer `actualETHAmount` ETH to `to`
    to.transfer(actualETHAmount);

    // transfer any leftover DAI
    if (actualDAIAmount < amount) {
      dai.safeTransfer(msg.sender, amount.sub(actualDAIAmount));
    }

    return true;
  }

  function burnToToken(PooledCDAI pcDAI, address tokenAddress, address to, uint256 amount) public returns (bool) {
    require(tokenAddress != address(ETH_TOKEN_ADDRESS), "Use burnToETH() instead");
    require(tokenAddress != DAI_ADDRESS, "Use burn() instead");

    // burn `amount` pcDAI for msg.sender to get DAI
    _burn(pcDAI, amount);

    // convert `amount` DAI to token
    ERC20 dai = ERC20(DAI_ADDRESS);
    ERC20 token = ERC20(tokenAddress);
    (uint256 actualTokenAmount, uint256 actualDAIAmount) = _kyberTrade(dai, amount, token);

    // transfer `actualTokenAmount` token to `to`
    token.safeTransfer(to, actualTokenAmount);

    // transfer any leftover DAI
    if (actualDAIAmount < amount) {
      dai.safeTransfer(msg.sender, amount.sub(actualDAIAmount));
    }

    return true;
  }

  function _mint(PooledCDAI pcDAI, address to, uint256 actualDAIAmount) internal {
    ERC20 dai = ERC20(DAI_ADDRESS);
    dai.safeApprove(address(pcDAI), 0);
    dai.safeApprove(address(pcDAI), actualDAIAmount);
    require(pcDAI.mint(to, actualDAIAmount), "Failed to mint pcDAI");
  }

  function _burn(PooledCDAI pcDAI, uint256 amount) internal {
    // transfer `amount` pcDAI from msg.sender
    pcDAI.safeTransferFrom(msg.sender, address(this), amount);

    // burn `amount` pcDAI for DAI
    require(pcDAI.burn(address(this), amount), "Failed to burn pcDAI");
  }

  /**
   * @notice Get the token balance of an account
   * @param _token the token to be queried
   * @param _addr the account whose balance will be returned
   * @return token balance of the account
   */
  function _getBalance(ERC20 _token, address _addr) internal view returns(uint256) {
    if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
      return uint256(_addr.balance);
    }
    return uint256(_token.balanceOf(_addr));
  }

  function _toPayableAddr(address _addr) internal pure returns (address payable) {
    return address(uint160(_addr));
  }

  /**
   * @notice Wrapper function for doing token conversion on Kyber Network
   * @param _srcToken the token to convert from
   * @param _srcAmount the amount of tokens to be converted
   * @param _destToken the destination token
   * @return _destPriceInSrc the price of the dest token, in terms of source tokens
   *         _srcPriceInDest the price of the source token, in terms of dest tokens
   *         _actualDestAmount actual amount of dest token traded
   *         _actualSrcAmount actual amount of src token traded
   */
  function _kyberTrade(ERC20 _srcToken, uint256 _srcAmount, ERC20 _destToken)
    internal
    returns(
      uint256 _actualDestAmount,
      uint256 _actualSrcAmount
    )
  {
    // Get current rate & ensure token is listed on Kyber
    KyberNetworkProxy kyber = KyberNetworkProxy(KYBER_ADDRESS);
    (, uint256 rate) = kyber.getExpectedRate(_srcToken, _destToken, _srcAmount);
    require(rate > 0, "Price for token is 0 on Kyber");

    uint256 beforeSrcBalance = _getBalance(_srcToken, address(this));
    uint256 msgValue;
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      msgValue = 0;
      _srcToken.safeApprove(KYBER_ADDRESS, 0);
      _srcToken.safeApprove(KYBER_ADDRESS, _srcAmount);
    } else {
      msgValue = _srcAmount;
    }
    _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
      _srcToken,
      _srcAmount,
      _destToken,
      _toPayableAddr(address(this)),
      MAX_QTY,
      rate,
      0x8B2315243349f461045854beec3c5aFA84f600B6,
      PERM_HINT
    );
    require(_actualDestAmount > 0, "Received 0 dest token");
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      _srcToken.safeApprove(KYBER_ADDRESS, 0);
    }

    _actualSrcAmount = beforeSrcBalance.sub(_getBalance(_srcToken, address(this)));
  }
  
  function() external payable {}
}