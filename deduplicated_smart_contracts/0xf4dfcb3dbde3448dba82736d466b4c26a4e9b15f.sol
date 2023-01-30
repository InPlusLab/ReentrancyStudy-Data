/**
 *Submitted for verification at Etherscan.io on 2020-03-31
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/LoihiViews.sol
pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.6 <0.6.0 >=0.5.12 <0.6.0 >=0.5.15 <0.6.0;

////// lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// lib/openzeppelin-contracts/src/contracts/GSN/Context.sol
/* pragma solidity ^0.5.0; */

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
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

////// lib/openzeppelin-contracts/src/contracts/math/SafeMath.sol
/* pragma solidity ^0.5.0; */

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
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

////// lib/openzeppelin-contracts/src/contracts/token/ERC20/IERC20.sol
/* pragma solidity ^0.5.0; */

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

////// lib/openzeppelin-contracts/src/contracts/token/ERC20/ERC20.sol
/* pragma solidity ^0.5.0; */

/* import "../../GSN/Context.sol"; */
/* import "./IERC20.sol"; */
/* import "../../math/SafeMath.sol"; */

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowances;
    uint256 public totalSupply;

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
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
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        balances[sender] = balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balances[recipient] = balances[recipient].add(amount);
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
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] = balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

////// src/LoihiDelegators.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.15; */

contract LoihiDelegators {

    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }

    function staticTo(address callee, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.staticcall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }


    function dViewRawAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSignature("viewRawAmount(uint256)", amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSignature("viewNumeraireAmount(uint256)", amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireBalance (address addr, address _this) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSignature("viewNumeraireBalance(address)", _this)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireAmount (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("getNumeraireAmount(uint256)", amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireBalance (address addr) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("getNumeraireBalance()")); // encoded selector of "getNumeraireBalance()";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address to the interface wrapper to be delegatecall'd
    /// @param amount the numeraire amount to be transfered into the contract. will be adjusted to the raw amount before transfer
    function dIntakeRaw (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("intakeRaw(uint256)", amount)); // encoded selector of "intakeRaw(uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address to the interface wrapper to be delegatecall'd
    /// @param amount the numeraire amount to be transfered into the contract. will be adjusted to the raw amount before transfer
    function dIntakeNumeraire (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("intakeNumeraire(uint256)", amount)); // encoded selector of "intakeNumeraire(uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address of the interface wrapper to be delegatecall'd
    /// @param dst the destination to which to send the raw amount
    /// @param amount the raw amount of the asset to send
    function dOutputRaw (address addr, address dst, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("outputRaw(address,uint256)", dst, amount)); // encoded selector of "outputRaw(address,uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions to retrieve the numeraire and raw values and vice versa
    /// @param addr address of the interface wrapper
    /// @param dst the destination to send the raw amount to
    /// @param amount the numeraire amount of the asset to be sent. this will be adjusted to the corresponding raw amount
    /// @return the raw amount of the asset that was transfered
    function dOutputNumeraire (address addr, address dst, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("outputNumeraire(address,uint256)", dst, amount)); // encoded selector of "outputNumeraire(address,uint256)";
        return abi.decode(result, (uint256));
    }
}
////// src/interfaces/IAToken.sol
/* pragma solidity ^0.5.15; */

interface IAToken {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Redeem(
        address indexed _from,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    event MintOnDeposit(
        address indexed _from,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    event BurnOnLiquidation(
        address indexed _from,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    event BalanceTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _toBalanceIncrease,
        uint256 _fromIndex,
        uint256 _toIndex
    );

    event InterestStreamRedirected(
        address indexed _from,
        address indexed _to,
        uint256 _redirectedBalance,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    event RedirectedBalanceUpdated(
        address indexed _targetAddress,
        uint256 _targetBalanceIncrease,
        uint256 _targetIndex,
        uint256 _redirectedBalanceAdded,
        uint256 _redirectedBalanceRemoved
    );

    event InterestRedirectionAllowanceChanged(
        address indexed _from,
        address indexed _to
    );

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function redirectInterestStream(address _to) external;
    function redirectInterestStreamOf(address _from, address _to) external;
    function allowInterestRedirectionTo(address _to) external;
    function redeem(uint256 _amount) external;
    function balanceOf(address _user) external view returns(uint256);
    function principalBalanceOf(address _user) external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);
    function getUserIndex(address _user) external view returns(uint256);
    function getInterestRedirectionAddress(address _user) external view returns(address);
    function getRedirectedBalance(address _user) external view returns(uint256);
    function decimals () external view returns (uint256);
    function deposit(uint256 _amount) external;


}
////// src/interfaces/ICToken.sol
/* pragma solidity ^0.5.15; */

interface ICToken {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function getCash() external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function balanceOfUnderlying(address account) external returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
////// src/interfaces/IChai.sol
/* pragma solidity ^0.5.12; */

interface IChai {
    function draw(address src, uint wad) external;
    function exit(address src, uint wad) external;
    function join(address dst, uint wad) external;
    function dai(address usr) external returns (uint wad);
    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;
    function approve(address usr, uint wad) external returns (bool);
    function move(address src, address dst, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}
////// src/interfaces/IPot.sol
/* pragma solidity ^0.5.15; */

interface IPot {
    function rho () external returns (uint256);
    function drip () external returns (uint256);
    function chi () external view returns (uint256);
}
////// src/LoihiRoot.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.15; */

/* import "ds-math/math.sol"; */

/* import "./interfaces/IAToken.sol"; */
/* import "./interfaces/ICToken.sol"; */
/* import "./interfaces/IChai.sol"; */
/* import "./interfaces/IPot.sol"; */
/* import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol"; */
/* import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol"; */

contract LoihiRoot is DSMath {

    string  public constant name = "Shells";
    string  public constant symbol = "SHL";
    uint8   public constant decimals = 18;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowances;
    uint256 public totalSupply;

    struct Flavor { address adapter; address reserve; }
    mapping(address => Flavor) public flavors;

    address[] public reserves;
    address[] public numeraires;
    uint256[] public weights;

    address public owner;
    bool internal notEntered = true;
    bool public frozen = false;

    uint256 public alpha;
    uint256 public beta;
    uint256 public delta;
    uint256 public epsilon;
    uint256 public lambda;
    uint256 internal omega;

    bytes4 constant internal ERC20ID = 0x36372b07;
    bytes4 constant internal ERC165ID = 0x01ffc9a7;

    // address constant exchange = 0xc2260aD1FaBC985c316dc32B9c8De9E74Db98447;
    // address constant liquidity = 0x3774A6dd0B776EfA40273BbA99cF9335D68942e1;
    // address constant views = 0xE8c8f8Ef5E19e17C0dd7510F5041EeCce8F7429D;
    // address constant erc20 = 0x7DB32869056647532f80f482E5bB1fcb311493cD;

    address exchange;
    address liquidity;
    address views;
    address erc20;

    IERC20 dai; ICToken cdai; IChai chai; IPot pot;
    IERC20 usdc; ICToken cusdc;
    IERC20 usdt; IAToken ausdt;
    IERC20 susd; IAToken asusd;

    function includeTestAdapterState(address _dai, address _cdai, address _chai, address _pot, address _usdc, address _cusdc, address _usdt, address _ausdt, address _susd, address _asusd) public {
        dai = IERC20(_dai); cdai = ICToken(_cdai); chai = IChai(_chai); pot = IPot(_pot);
        usdc = IERC20(_usdc); cusdc = ICToken(_cusdc);
        usdt = IERC20(_usdt); ausdt = IAToken(_ausdt);
        susd = IERC20(_susd); asusd = IAToken(_asusd);
    }

    event ShellsMinted(address indexed minter, uint256 amount, address[] indexed coins, uint256[] amounts);
    event ShellsBurned(address indexed burner, uint256 amount, address[] indexed coins, uint256[] amounts);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Trade(address indexed trader, address indexed origin, address indexed target, uint256 originAmount, uint256 targetAmount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier nonReentrant() {
        require(notEntered, "re-entered");
        notEntered = false;
        _;
        notEntered = true;
    }

    modifier notFrozen () {
        require(!frozen, "swaps, selective deposits and selective withdraws have been frozen.");
        _;
    }

}
////// src/LoihiViews.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.15; */

/* import "./LoihiRoot.sol"; */
/* import "./LoihiDelegators.sol"; */

contract LoihiViews is LoihiRoot, LoihiDelegators {

    function viewTargetAmount (uint256 _oAmt, address _oAdptr, address _tAdptr, address _this, address[] memory _rsrvs, address _oRsrv, address _tRsrv, uint256[] memory _weights, uint256[] memory _globals) public view returns (uint256 tNAmt_) {

        require(_oAdptr != address(0), "origin flavor not supported");
        require(_tAdptr != address(0), "target flavor not supported");

        if (_oRsrv == _tRsrv) {
            uint256 _oNAmt = dViewNumeraireAmount(_oAdptr, _oAmt);
            return dViewRawAmount(_tAdptr, _oNAmt);
        }

        uint256 _oNAmt = dViewNumeraireAmount(_oAdptr, _oAmt);

        uint256 _grossLiq;
        uint256[] memory _balances = new uint256[](_rsrvs.length);
        for (uint i = 0; i < _rsrvs.length; i++) {
            _balances[i] = dViewNumeraireBalance(_rsrvs[i], _this);
            _grossLiq += _balances[i];
        }

        tNAmt_ = wmul(_oNAmt, WAD-_globals[3]);
        uint256 _oNFAmt = tNAmt_;
        uint256 _psi;
        uint256 _nGLiq;
        for (uint j = 0; j < 10; j++) {
            _psi = 0;
            _nGLiq = _grossLiq + _oNAmt - tNAmt_;
            for (uint i = 0; i < _balances.length; i++) {
                if (_rsrvs[i] == _oRsrv) _psi += makeFee(add(_balances[i], _oNAmt), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else if (_rsrvs[i] == _tRsrv) _psi += makeFee(sub(_balances[i], tNAmt_), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else _psi += makeFee(_balances[i], wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
            }

            if (_globals[5] < _psi) {
                if ((tNAmt_ = _oNFAmt + _globals[5] - _psi) / 10000000000 == tNAmt_ / 10000000000) break;
            } else {
                if ((tNAmt_ = _oNFAmt + wmul(_globals[4], _globals[5] - _psi)) / 10000000000 == tNAmt_ / 10000000000) break;
            }

        }

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _ideal = wmul(_nGLiq, _weights[i]);
            if (_rsrvs[i] == _oRsrv) require(_balances[i] + _oNAmt < wmul(_ideal, WAD + _globals[0]), "origin halt check");
            if (_rsrvs[i] == _tRsrv) require(_balances[i] - tNAmt_ > wmul(_ideal, WAD - _globals[0]), "target halt check");
        }

        tNAmt_ = wmul(tNAmt_, WAD-_globals[3]);

        return dViewRawAmount(_tAdptr, tNAmt_);

    }

    function viewOriginAmount (uint256 _tAmt, address _tAdptr, address _oAdptr, address _this, address[] memory _rsrvs, address _tRsrv, address _oRsrv, uint256[] memory _weights, uint256[] memory _globals) public view returns (uint256 oNAmt_) {


        require(_oAdptr != address(0), "origin flavor not supported");
        require(_tAdptr != address(0), "target flavor not supported");

        if (_oRsrv == _tRsrv) {
            uint256 _tNAmt = dViewNumeraireAmount(_tAdptr, _tAmt);
            return dViewRawAmount(_oAdptr, _tNAmt);
        }

        uint256 _tNAmt = dViewNumeraireAmount(_tAdptr, _tAmt);

        uint256 _grossLiq;
        uint256[] memory _balances = new uint256[](_rsrvs.length);
        for (uint i = 0; i < _rsrvs.length; i++) {
            _balances[i] = dViewNumeraireBalance(_rsrvs[i], _this);
            _grossLiq += _balances[i];
        }

        oNAmt_ = wmul(_tNAmt, WAD+_globals[3]);
        uint256 _tNFAmt = oNAmt_;
        uint256 _psi;
        uint256 _nGLiq;
        for (uint j = 0; j < 10; j++) {
            _psi = 0;
            _nGLiq = _grossLiq + oNAmt_ - _tNAmt;
            for (uint i = 0; i < _rsrvs.length; i++) {
                if (_rsrvs[i] == _oRsrv) _psi += makeFee(add(_balances[i], oNAmt_), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else if (_rsrvs[i] == _tRsrv) _psi += makeFee(sub(_balances[i], _tNAmt), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else _psi += makeFee(_balances[i], wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
            }

            if (_globals[5] < _psi) {
                if ((oNAmt_ = _tNFAmt + _psi - _globals[5]) / 10000000000 == oNAmt_ / 10000000000) break;
            } else {
                if ((oNAmt_ = _tNFAmt - wmul(_globals[4], _globals[5] - _psi)) / 10000000000 == oNAmt_ / 10000000000) break;
            }
            
        }

        if (_globals[5] > _psi) oNAmt_ = sub(_tNFAmt, wmul(_globals[4], sub(_globals[5], _psi)));

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _ideal = wmul(_nGLiq, _weights[i]);
            if (_rsrvs[i] == _oRsrv) require(_balances[i] + oNAmt_ < wmul(_ideal, WAD + _globals[0]), "origin halt check");
            if (_rsrvs[i] == _tRsrv) require(_balances[i] - _tNAmt > wmul(_ideal, WAD - _globals[0]), "target halt check");
        }

        oNAmt_ = wmul(oNAmt_, WAD+_globals[3]);

        return dViewRawAmount(_oAdptr, oNAmt_);

    }

    function makeFee (uint256 _bal, uint256 _ideal, uint256 _beta, uint256 _delta) internal view returns (uint256 _fee) {

        uint256 threshold;
        if (_bal < (threshold = wmul(_ideal, WAD-_beta))) {
            _fee = wdiv(_delta, _ideal);
            _fee = wmul(_fee, (threshold = sub(threshold, _bal)));
            _fee = wmul(_fee, threshold);
        } else if (_bal > (threshold = wmul(_ideal, WAD+_beta))) {
            _fee = wdiv(_delta, _ideal);
            _fee = wmul(_fee, (threshold = sub(_bal, threshold)));
            _fee = wmul(_fee, threshold);
        } else _fee = 0;

    }

    function viewSelectiveWithdraw (address[] calldata _rsrvs, address[] calldata _flvrs, uint256[] calldata _amts, address _this, uint256[] calldata _weights, uint256[] calldata _globals) external view returns (uint256) {

        (uint256[] memory _balances, uint256[] memory _withdrawals) = viewBalancesAndAmounts(_rsrvs, _flvrs, _amts, _this);

        uint256 shellsBurned_;

        uint256 _nSum; uint256 _oSum;
        for (uint i = 0; i < _balances.length; i++) {
            _nSum = add(_nSum, sub(_balances[i], _withdrawals[i]));
            _oSum = add(_oSum, _balances[i]);
        }

        uint256 _psi = viewBurnFees(_balances, _withdrawals, _globals, _weights, _nSum, _oSum);

        if (_globals[5] < _psi) {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, _psi);
            if (_oUtil == 0) return _nUtil;
            shellsBurned_ = wdiv(wmul(sub(_oUtil, _nUtil), _globals[6]), _oUtil);
        } else {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, wmul(_psi, _globals[4]));
            if (_oUtil == 0) return _nUtil;
            uint256 _oUtilPrime = wmul(_globals[5], _globals[4]);
            _oUtilPrime = sub(_oSum, _oUtilPrime);
            shellsBurned_ = wdiv(wmul(sub(_oUtilPrime, _nUtil), _globals[6]), _oUtil);
        }

        return wmul(shellsBurned_, WAD+_globals[3]);

    }

    function viewSelectiveDeposit (address[] calldata _rsrvs, address[] calldata _flvrs, uint256[] calldata _amts, address _this, uint256[] calldata _weights, uint256[] calldata _globals) external view returns (uint256) {

        (uint256[] memory _balances, uint256[] memory _deposits) = viewBalancesAndAmounts(_rsrvs, _flvrs, _amts, _this);

        uint256 shellsMinted_;

        uint256 _nSum; uint256 _oSum;
        for (uint i = 0; i < _balances.length; i++) {
            _nSum = add(_nSum, add(_balances[i], _deposits[i]));
            _oSum = add(_oSum, _balances[i]);
        }

        uint256 _psi = viewMintFees(_balances, _deposits, _globals, _weights, _nSum, _oSum);

        if (_globals[5] < _psi) {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, _psi);
            if (_oUtil == 0) return _nUtil;
            shellsMinted_ = wdiv(wmul(sub(_nUtil, _oUtil), _globals[6]), _oUtil);
        } else {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, wmul(_psi, _globals[4]));
            if (_oUtil == 0) return _nUtil;
            uint256 _oUtilPrime = wmul(_globals[5], _globals[4]);
            _oUtilPrime = sub(_oSum, _oUtilPrime);
            shellsMinted_ = wdiv(wmul(sub(_nUtil, _oUtilPrime), _globals[6]), _oUtil);
        }

        return wmul(shellsMinted_, WAD-_globals[3]);
    }

    function viewMintFees (uint256[] memory _balances, uint256[] memory _deposits, uint256[] memory _globals, uint256[] memory _weights, uint256 _nSum, uint256 _oSum) public view returns (uint256 psi_) {

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _nBal = add(_balances[i], _deposits[i]);
            uint256 _nIdeal = wmul(_nSum, _weights[i]);
            require(_nBal <= wmul(_nIdeal, WAD + _globals[0]), "deposit upper halt check");
            require(_nBal >= wmul(_nIdeal, WAD - _globals[0]), "deposit lower halt check");
            psi_ += makeFee(_nBal, _nIdeal, _globals[1], _globals[2]);
        }

    }

    function viewBurnFees (uint256[] memory _balances, uint256[] memory _withdrawals, uint256[] memory _globals, uint256[] memory _weights, uint256 _nSum, uint256 _oSum) public view returns (uint256 psi_) {

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _nBal = sub(_balances[i], _withdrawals[i]);
            uint256 _nIdeal = wmul(_nSum, _weights[i]);
            require(_nBal <= wmul(_nIdeal, WAD + _globals[0]), "withdraw upper halt check");
            require(_nBal >= wmul(_nIdeal, WAD - _globals[0]), "withdraw lower halt check");
            psi_ += makeFee(_nBal, _nIdeal, _globals[1], _globals[2]);
        }

    }


    function viewBalancesAndAmounts (address[] memory _rsrvs, address[] memory _flvrs, uint256[] memory _amts, address _this) private view returns (uint256[] memory, uint256[] memory) {

        uint256[] memory balances_ = new uint256[](_rsrvs.length);
        uint256[] memory amounts_ = new uint256[](_rsrvs.length);

        for (uint i = 0; i < _flvrs.length/2; i++) {
            require(_flvrs[i*2] != address(0), "flavor not supported");
            for (uint j = 0; j < _rsrvs.length; j++) {
                if (balances_[j] == 0) balances_[j] = dViewNumeraireBalance(_rsrvs[j], _this);
                if (_rsrvs[j] == _flvrs[i*2+1] && _amts[i] > 0) amounts_[j] += dViewNumeraireAmount(_flvrs[i*2], _amts[i]);
            }
        }

        return (balances_, amounts_);

    }

    function totalReserves (address[] calldata _reserves, address _addr) external view returns (uint256, uint256[] memory) {
        uint256 totalBalance_;
        uint256[] memory balances_ = new uint256[](_reserves.length);
        for (uint i = 0; i < _reserves.length; i++) {
            balances_[i] = dViewNumeraireBalance(_reserves[i], _addr);
            totalBalance_ += balances_[i];
        }
        return (totalBalance_, balances_);
    }

}