/**
 *Submitted for verification at Etherscan.io on 2019-10-09
*/

/**


dETH is the provably dead token.

HOW DETH WORKS:

ETH sent to this smart contract is irrevocably killed and removed from the
economy. It is not just burned, it is dead.

This is accomplished by transferring ETH to Hades, a self-destructing
smart contract that sends ETH to itself during self-destruction. The dead
eth isn't just inaccessible, it literally ceases to exist.

TOKENOMICS:

The price of dETH increases by .1% with each purchase from this smart contract.

This simple bonding curve incentives destroying large amounts of ETH in each
transaction to lock-in the lowest possible price.

Plus, receive a 30% bonus by destroying 3 eth or more.

3 eth is the block reward in Ethereum and by destroying more than 3 eth in a
single transaction, you are removing more ether from the economy than is created.

GAME THEORY:

Making a large mint and then making many small mints will drive the price
up for others.

The price doubles every 1000 times dETH has been minted.

FEE DISCLOSURE:

There is a .01 eth fee for minting dETH. This is paid to Charon to cross the
River Styx into Hades. All eth collected by Charon is converted into Sparkle,
a redistributive currency.

Pro-tip: Share in Charon's profits by buying Sparkle.

The fee is the same regardless of the amount of dETH minted. This further
incentives destroying large amounts of ETH in each transaction.

SPECIAL CONTRACT FUNCTIONS:

function totalDead returns the total amount of wei that has been destroyed

____

Created by Micah White for Halloween 2019

____

Happy Halloween!

*/

pragma solidity ^0.5.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
     * - The divisor cannot be zero.
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
     constructor (string memory name, string memory symbol, uint8 decimals) public {
         _name = name;
         _symbol = symbol;
         _decimals = decimals;
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
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Sparkle is ERC20Detailed {

    function totalSupply() public view returns (uint256) {

    }

    function tobinsCollected() public view returns (uint256) {

    }

    function balanceOf(address owner) public view returns (uint256) {

    }

    function allowance(address owner, address spender) public view returns (uint256) {

    }

    function transfer(address to, uint256 value) public returns (bool) {

    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

    }

    function approve(address spender, uint256 value) public returns (bool) {

    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

    }

    function () external payable {
        mintSparkle();
    }

    function mintSparkle() public payable returns (bool) {

    }

    function sellSparkle(uint256 amount) public returns (bool) {

    }


}

contract Hades {

  function () external payable {
    selfdestruct(address(this));
    }

}

contract dETH is ERC20Detailed {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _totalDead;
  uint256 private _numberOfBuys;
  address payable charon = 0x4C3cC1D2229CBD17D26ec984F2E1b9bD336cBf69;
  address payable deployed_sparkle = 0x286ae10228C274a9396a05A56B9E3B8f42D1cE14;
  uint256 constant private COST_PER_SPARKLE = 1e14; // 1 Sparkle = .0001 ETH
  uint256 constant private MAX_SPARKLE_SUPPLY = 400000000 * 10 ** 18;

  constructor() public ERC20Detailed("dETH", "DETH", 18) {}

  /**
   * @dev See `IERC20.totalSupply`.
   */
  function totalSupply() public view returns (uint256) {
      return _totalSupply;
  }

  function totalDead() public view returns (uint256) {
      return _totalDead;
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


  function createDeath() internal returns (Hades tokenAddress) {
      return new Hades();
  }


    function () external payable {
        mintDeth();
    }

    function mintDeth() public payable returns (bool) {
        require(gasleft() >= 101000, "Increase gas limit to over 101,000");
        require(msg.value > 1e16, "Insufficient deposit. Minimum mint is .01 eth");

        if (msg.value >= 3000000000000000000) {
          uint256 amount = msg.value.sub(1e16); // Charon takes .01 eth to cross River Styx
          uint256 amountBonus = amount.mul(13).div(10); // 30% bonus for destroying more than block reward
          uint256 _price = _numberOfBuys.add(1000);
          uint256 buyerAmount = amountBonus.div(_price).mul(1000);
          _numberOfBuys = _numberOfBuys.add(1);

          address payable riverStyx = address(createDeath());
          riverStyx.transfer(amount);

          _balances[msg.sender] = _balances[msg.sender].add(buyerAmount);

          _totalSupply = _totalSupply.add(buyerAmount);
          _totalDead = _totalDead.add(amount);

          emit Transfer(address(0), msg.sender, buyerAmount);

          return true;
        } else {
        uint256 amount = msg.value.sub(1e16); // Charon takes .01 eth to cross River Styx
        uint256 _price = _numberOfBuys.add(1000);
        uint256 buyerAmount = amount.div(_price).mul(1000);
        _numberOfBuys = _numberOfBuys.add(1);

        address payable riverStyx = address(createDeath());
        riverStyx.transfer(amount);

        _balances[msg.sender] = _balances[msg.sender].add(buyerAmount);

        _totalSupply = _totalSupply.add(buyerAmount);
        _totalDead = _totalDead.add(amount);

        emit Transfer(address(0), msg.sender, buyerAmount);

        return true;
        }
    }


    // all ether collected by Charon must be converted into Sparkle in order to withdraw it
    function buySparkle() public returns (bool) {
      require(msg.sender == charon, "Access denied.");
      uint256 pot = address(this).balance;
      uint256 buyingAmount = pot.div(COST_PER_SPARKLE);
      uint256 sparkleSupply = Sparkle(deployed_sparkle).totalSupply();
      // if the Sparkle max supply cap has been reached, send colleted eth to Charon
      if (MAX_SPARKLE_SUPPLY >= sparkleSupply.add(buyingAmount)) {
      deployed_sparkle.call.value(pot).gas(120000)("");
      return true;
    } else {
      charon.transfer(address(this).balance);
      return true;
    }
    }

    function sellSparkle(uint256 amount) public returns (bool) {
            require(msg.sender == charon, "Access denied.");
            Sparkle(deployed_sparkle).sellSparkle(amount);
            charon.transfer(address(this).balance);
            return true;
        }


    function withdrawSparkle(uint256 amount) public returns (bool) {
          require(msg.sender == charon, "Access denied.");
              Sparkle(deployed_sparkle).transfer(charon, amount);
              return true;
                    }

}