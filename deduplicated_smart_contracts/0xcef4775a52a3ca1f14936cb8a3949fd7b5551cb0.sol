/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// File: contracts\test\BColor.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.6;

// abstract contract BColor {
//     function getColor()
//         external view virtual
//         returns (bytes32);
// }

contract BBronze {
    function getColor()
        external pure
        returns (bytes32) {
            return bytes32("BRONZE");
        }
}

// File: contracts\test\BConst.sol


pragma solidity ^0.6.6;


contract BConst is BBronze {
    uint public constant BONE              = 10**18;

    uint public constant MIN_BOUND_TOKENS  = 2;
    // uint public constant MAX_BOUND_TOKENS  = 8;              // not included - determined implicitly by governance

    uint public constant MIN_FEE           = BONE / 10**6;
    uint public constant MAX_FEE           = BONE / 10;
    // uint public constant EXIT_FEE          = 0;              // moved to configurable param

    uint public constant MIN_WEIGHT        = BONE;              // Future: make configurable to allow more weight granularity
    uint public constant MAX_WEIGHT        = BONE * 1000;       // Future: make configurable to allow more weight granularity
    uint public constant MAX_TOTAL_WEIGHT  = BONE * 1000;       // Future: make configurable to allow more weight granularity
    uint public constant MIN_BALANCE       = BONE / 10**12;

    uint public constant INIT_POOL_SUPPLY  = BONE * 100;

    uint public constant MIN_BPOW_BASE     = 1 wei;
    uint public constant MAX_BPOW_BASE     = (2 * BONE) - 1 wei;
    uint public constant BPOW_PRECISION    = BONE / 10**10;

    uint public constant MAX_IN_RATIO      = BONE / 2;
    uint public constant MAX_OUT_RATIO     = (BONE / 3) + 1 wei;
}

// File: contracts\test\BNum.sol


pragma solidity ^0.6.6;


// Core contract; can't be changed. So disable solhint (reminder for v2)

/* solhint-disable private-vars-leading-underscore */

contract BNum is BConst {

    function btoi(uint a)
        internal pure
        returns (uint)
    {
        return a / BONE;
    }

    function bfloor(uint a)
        internal pure
        returns (uint)
    {
        return btoi(a) * BONE;
    }

    function badd(uint a, uint b)
        internal pure
        returns (uint)
    {
        uint c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint a, uint b)
        internal pure
        returns (uint)
    {
        (uint c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint a, uint b)
        internal pure
        returns (uint, bool)
    {
        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint a, uint b)
        internal pure
        returns (uint)
    {
        uint c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint a, uint b)
        internal pure
        returns (uint)
    {
        require(b != 0, "ERR_DIV_ZERO");
        uint c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
        uint c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint c2 = c1 / b;
        return c2;
    }

    // DSMath.wpow
    function bpowi(uint a, uint n)
        internal pure
        returns (uint)
    {
        uint z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    // Compute b^(e.w) by splitting it into (b^e)*(b^0.w).
    // Use `bpowi` for `b^e` and `bpowK` for k iterations
    // of approximation of b^0.w
    function bpow(uint base, uint exp)
        internal pure
        returns (uint)
    {
        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint whole  = bfloor(exp);   
        uint remain = bsub(exp, whole);

        uint wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint base, uint exp, uint precision)
        internal pure
        returns (uint)
    {
        // term 0:
        uint a     = exp;
        (uint x, bool xneg)  = bsubSign(base, BONE);
        uint term = BONE;
        uint sum   = term;
        bool negative = false;


        // term(k) = numer / denom 
        //         = (product(a - i - 1, i=1-->k) * x^k) / (k!)
        // each iteration, multiply previous term by (a-(k-1)) * x / k
        // continue until term is less than precision
        for (uint i = 1; term >= precision; i++) {
            uint bigK = i * BONE;
            (uint c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }

}

// File: libraries\BalancerConstants.sol


pragma solidity 0.6.12;

/**
 * @author Balancer Labs
 * @title Put all the constants in one place
 */

library BalancerConstants {
    // State variables (must be constant in a library)
    // Note: any changes need to also be reflected in BConst.sol

    // B "ONE" - all math is in the "realm" of 10 ** 18;
    // where numeric 1 = 10 ** 18
    uint public constant BONE = 10**18;
    uint public constant MIN_WEIGHT = BONE;                 // Future: make configurable to allow more weight granularity
    uint public constant MAX_WEIGHT = BONE * 1000;          // Future: make configurable to allow more weight granularity
    uint public constant MAX_TOTAL_WEIGHT = BONE * 1000;    // Future: make configurable to allow more weight granularity
    uint public constant MIN_BALANCE = BONE / 10**6;
    uint public constant MAX_BALANCE = BONE * 10**12;
    uint public constant MIN_POOL_SUPPLY = BONE * 100;
    uint public constant MAX_POOL_SUPPLY = BONE * 10**9;
    uint public constant MIN_FEE = BONE / 10**6;
    uint public constant MAX_FEE = BONE / 10;
    // EXIT_FEE must always be zero, or ConfigurableRightsPool._pushUnderlying will fail
    // uint public constant EXIT_FEE = 0;                   // moved to configurable param
    uint public constant MAX_IN_RATIO = BONE / 2;
    uint public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;
    // Must match BConst.MIN_BOUND_TOKENS and BConst.MAX_BOUND_TOKENS
    uint public constant MIN_ASSET_LIMIT = 2;
    // uint public constant MAX_ASSET_LIMIT = 8;            // not included - determined implicitly by governance
    uint public constant MAX_UINT = uint(-1);
}

// File: libraries\BalancerSafeMath.sol


pragma solidity 0.6.12;


// Imports


/**
 * @author Balancer Labs
 * @title SafeMath - wrap Solidity operators to prevent underflow/overflow
 * @dev badd and bsub are basically identical to OpenZeppelin SafeMath; mul/div have extra checks
 */
library BalancerSafeMath {
    /**
     * @notice Safe addition
     * @param a - first operand
     * @param b - second operand
     * @dev if we are adding b to a, the resulting sum must be greater than a
     * @return - sum of operands; throws if overflow
     */
    function badd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    /**
     * @notice Safe unsigned subtraction
     * @param a - first operand
     * @param b - second operand
     * @dev Do a signed subtraction, and check that it produces a positive value
     *      (i.e., a - b is valid if b <= a)
     * @return - a - b; throws if underflow
     */
    function bsub(uint a, uint b) internal pure returns (uint) {
        (uint c, bool negativeResult) = bsubSign(a, b);
        require(!negativeResult, "ERR_SUB_UNDERFLOW");
        return c;
    }

    /**
     * @notice Safe signed subtraction
     * @param a - first operand
     * @param b - second operand
     * @dev Do a signed subtraction
     * @return - difference between a and b, and a flag indicating a negative result
     *           (i.e., a - b if a is greater than or equal to b; otherwise b - a)
     */
    function bsubSign(uint a, uint b) internal pure returns (uint, bool) {
        if (b <= a) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    /**
     * @notice Safe multiplication
     * @param a - first operand
     * @param b - second operand
     * @dev Multiply safely (and efficiently), rounding down
     * @return - product of operands; throws if overflow or rounding error
     */
    function bmul(uint a, uint b) internal pure returns (uint) {
        // Gas optimization (see github.com/OpenZeppelin/openzeppelin-contracts/pull/522)
        if (a == 0) {
            return 0;
        }

        // Standard overflow check: a/a*b=b
        uint c0 = a * b;
        require(c0 / a == b, "ERR_MUL_OVERFLOW");

        // Round to 0 if x*y < BONE/2?
        uint c1 = c0 + (BalancerConstants.BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint c2 = c1 / BalancerConstants.BONE;
        return c2;
    }

    /**
     * @notice Safe division
     * @param dividend - first operand
     * @param divisor - second operand
     * @dev Divide safely (and efficiently), rounding down
     * @return - quotient; throws if overflow or rounding error
     */
    function bdiv(uint dividend, uint divisor) internal pure returns (uint) {
        require(divisor != 0, "ERR_DIV_ZERO");

        // Gas optimization
        if (dividend == 0){
            return 0;
        }

        uint c0 = dividend * BalancerConstants.BONE;
        require(c0 / dividend == BalancerConstants.BONE, "ERR_DIV_INTERNAL"); // bmul overflow

        uint c1 = c0 + (divisor / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require

        uint c2 = c1 / divisor;
        return c2;
    }

    /**
     * @notice Safe unsigned integer modulo
     * @dev Returns the remainder of dividing two unsigned integers.
     *      Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * @param dividend - first operand
     * @param divisor - second operand -- cannot be zero
     * @return - quotient; throws if overflow or rounding error
     */
    function bmod(uint dividend, uint divisor) internal pure returns (uint) {
        require(divisor != 0, "ERR_MODULO_BY_ZERO");

        return dividend % divisor;
    }

    /**
     * @notice Safe unsigned integer max
     * @dev Returns the greater of the two input values
     *
     * @param a - first operand
     * @param b - second operand
     * @return - the maximum of a and b
     */
    function bmax(uint a, uint b) internal pure returns (uint) {
        return a >= b ? a : b;
    }

    /**
     * @notice Safe unsigned integer min
     * @dev returns b, if b < a; otherwise returns a
     *
     * @param a - first operand
     * @param b - second operand
     * @return - the lesser of the two input values
     */
    function bmin(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    /**
     * @notice Safe unsigned integer average
     * @dev Guard against (a+b) overflow by dividing each operand separately
     *
     * @param a - first operand
     * @param b - second operand
     * @return - the average of the two values
     */
    function baverage(uint a, uint b) internal pure returns (uint) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    /**
     * @notice Babylonian square root implementation
     * @dev (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
     * @param y - operand
     * @return z - the square root result
     */
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        }
        else if (y != 0) {
            z = 1;
        }
    }
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol



pragma solidity ^0.6.0;

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

// File: contracts\PCToken.sol


pragma solidity 0.6.12;

// Imports




// Contracts

/* solhint-disable func-order */

/**
 * @author Balancer Labs
 * @title Highly opinionated token implementation
*/
contract PCToken is IERC20 {
    using BalancerSafeMath for uint;

    // State variables
    string public constant NAME = "AlpacaSwap OmniPool";
    uint8 public constant DECIMALS = 18;

    // No leading underscore per naming convention (non-private)
    // Cannot call totalSupply (name conflict)
    // solhint-disable-next-line private-vars-leading-underscore
    uint internal varTotalSupply;

    mapping(address => uint) private _balance;
    mapping(address => mapping(address => uint)) private _allowance;

    string private _symbol;
    string private _name;

    // Event declarations

    // See definitions above; must be redeclared to be emitted from this contract
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    // Function declarations

    /**
     * @notice Base token constructor
     * @param tokenSymbol - the token symbol
     */
    constructor (string memory tokenSymbol, string memory tokenName) public {
        _symbol = tokenSymbol;
        _name = tokenName;
    }

    // External functions

    /**
     * @notice Getter for allowance: amount spender will be allowed to spend on behalf of owner
     * @param owner - owner of the tokens
     * @param spender - entity allowed to spend the tokens
     * @return uint - remaining amount spender is allowed to transfer
     */
    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowance[owner][spender];
    }

    /**
     * @notice Getter for current account balance
     * @param account - address we're checking the balance of
     * @return uint - token balance in the account
     */
    function balanceOf(address account) external view override returns (uint) {
        return _balance[account];
    }

    /**
     * @notice Approve owner (sender) to spend a certain amount
     * @dev emits an Approval event
     * @param spender - entity the owner (sender) is approving to spend his tokens
     * @param amount - number of tokens being approved
     * @return bool - result of the approval (will always be true if it doesn't revert)
     */
    function approve(address spender, uint amount) external override returns (bool) {
        /* In addition to the increase/decreaseApproval functions, could
           avoid the "approval race condition" by only allowing calls to approve
           when the current approval amount is 0
        
           require(_allowance[msg.sender][spender] == 0, "ERR_RACE_CONDITION");

           Some token contracts (e.g., KNC), already revert if you call approve 
           on a non-zero allocation. To deal with these, we use the SafeApprove library
           and safeApprove function when adding tokens to the pool.
        */

        _allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /**
     * @notice Increase the amount the spender is allowed to spend on behalf of the owner (sender)
     * @dev emits an Approval event
     * @param spender - entity the owner (sender) is approving to spend his tokens
     * @param amount - number of tokens being approved
     * @return bool - result of the approval (will always be true if it doesn't revert)
     */
    function increaseApproval(address spender, uint amount) external returns (bool) {
        _allowance[msg.sender][spender] = BalancerSafeMath.badd(_allowance[msg.sender][spender], amount);

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    /**
     * @notice Decrease the amount the spender is allowed to spend on behalf of the owner (sender)
     * @dev emits an Approval event
     * @dev If you try to decrease it below the current limit, it's just set to zero (not an error)
     * @param spender - entity the owner (sender) is approving to spend his tokens
     * @param amount - number of tokens being approved
     * @return bool - result of the approval (will always be true if it doesn't revert)
     */
    function decreaseApproval(address spender, uint amount) external returns (bool) {
        uint oldValue = _allowance[msg.sender][spender];
        // Gas optimization - if amount == oldValue (or is larger), set to zero immediately
        if (amount >= oldValue) {
            _allowance[msg.sender][spender] = 0;
        } else {
            _allowance[msg.sender][spender] = BalancerSafeMath.bsub(oldValue, amount);
        }

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    /**
     * @notice Transfer the given amount from sender (caller) to recipient
     * @dev _move emits a Transfer event if successful
     * @param recipient - entity receiving the tokens
     * @param amount - number of tokens being transferred
     * @return bool - result of the transfer (will always be true if it doesn't revert)
     */
    function transfer(address recipient, uint amount) external override returns (bool) {
        require(recipient != address(0), "ERR_ZERO_ADDRESS");

        _move(msg.sender, recipient, amount);

        return true;
    }

    /**
     * @notice Transfer the given amount from sender to recipient
     * @dev _move emits a Transfer event if successful; may also emit an Approval event
     * @param sender - entity sending the tokens (must be caller or allowed to spend on behalf of caller)
     * @param recipient - recipient of the tokens
     * @param amount - number of tokens being transferred
     * @return bool - result of the transfer (will always be true if it doesn't revert)
     */
    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {
        require(recipient != address(0), "ERR_ZERO_ADDRESS");
        require(msg.sender == sender || amount <= _allowance[sender][msg.sender], "ERR_PCTOKEN_BAD_CALLER");

        _move(sender, recipient, amount);

        // memoize for gas optimization
        uint oldAllowance = _allowance[sender][msg.sender];

        // If the sender is not the caller, adjust the allowance by the amount transferred
        if (msg.sender != sender && oldAllowance != uint(-1)) {
            _allowance[sender][msg.sender] = BalancerSafeMath.bsub(oldAllowance, amount);

            emit Approval(msg.sender, recipient, _allowance[sender][msg.sender]);
        }

        return true;
    }

    // public functions

    /**
     * @notice Getter for the total supply
     * @dev declared external for gas optimization
     * @return uint - total number of tokens in existence
     */
    function totalSupply() external view override returns (uint) {
        return varTotalSupply;
    }

    // Public functions

    /**
     * @dev Returns the name of the token.
     *      We allow the user to set this name (as well as the symbol).
     *      Alternatives are 1) A fixed string (original design)
     *                       2) A fixed string plus the user-defined symbol
     *                          return string(abi.encodePacked(NAME, "-", _symbol));
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory) {
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
    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    // internal functions

    // Mint an amount of new tokens, and add them to the balance (and total supply)
    // Emit a transfer amount from the null address to this contract
    function _mint(uint amount) internal virtual {
        _balance[address(this)] = BalancerSafeMath.badd(_balance[address(this)], amount);
        varTotalSupply = BalancerSafeMath.badd(varTotalSupply, amount);

        emit Transfer(address(0), address(this), amount);
    }

    // Burn an amount of new tokens, and subtract them from the balance (and total supply)
    // Emit a transfer amount from this contract to the null address
    function _burn(uint amount) internal virtual {
        // Can't burn more than we have
        // Remove require for gas optimization - bsub will revert on underflow
        // require(_balance[address(this)] >= amount, "ERR_INSUFFICIENT_BAL");

        _balance[address(this)] = BalancerSafeMath.bsub(_balance[address(this)], amount);
        varTotalSupply = BalancerSafeMath.bsub(varTotalSupply, amount);

        emit Transfer(address(this), address(0), amount);
    }

    // Transfer tokens from sender to recipient
    // Adjust balances, and emit a Transfer event
    function _move(address sender, address recipient, uint amount) internal virtual {
        // Can't send more than sender has
        // Remove require for gas optimization - bsub will revert on underflow
        // require(_balance[sender] >= amount, "ERR_INSUFFICIENT_BAL");

        _balance[sender] = BalancerSafeMath.bsub(_balance[sender], amount);
        _balance[recipient] = BalancerSafeMath.badd(_balance[recipient], amount);

        emit Transfer(sender, recipient, amount);
    }

    // Transfer from this contract to recipient
    // Emits a transfer event if successful
    function _push(address recipient, uint amount) internal {
        _move(address(this), recipient, amount);
    }

    // Transfer from recipient to this contract
    // Emits a transfer event if successful
    function _pull(address sender, uint amount) internal {
        _move(sender, address(this), amount);
    }
}

// File: contracts\test\BToken.sol


pragma solidity ^0.6.6;



// Highly opinionated token implementation

/*
interface IERC20 {
    event Approval(address indexed src, address indexed dst, uint amt);
    event Transfer(address indexed src, address indexed dst, uint amt);

    function totalSupply() external view returns (uint);
    function balanceOf(address whom) external view returns (uint);
    function allowance(address src, address dst) external view returns (uint);

    function approve(address dst, uint amt) external returns (bool);
    function transfer(address dst, uint amt) external returns (bool);
    function transferFrom(
        address src, address dst, uint amt
    ) external returns (bool);
}
*/

// Core contract; can't be changed. So disable solhint (reminder for v2)

/* solhint-disable func-order */

contract BTokenBase is BNum {

    mapping(address => uint)                   internal _balance;
    mapping(address => mapping(address=>uint)) internal _allowance;
    uint internal _totalSupply;

    event Approval(address indexed src, address indexed dst, uint amt);
    event Transfer(address indexed src, address indexed dst, uint amt);

    function _mint(uint amt) internal {
        _balance[address(this)] = badd(_balance[address(this)], amt);
        _totalSupply = badd(_totalSupply, amt);
        emit Transfer(address(0), address(this), amt);
    }

    function _burn(uint amt) internal {
        require(_balance[address(this)] >= amt, "ERR_INSUFFICIENT_BAL");
        _balance[address(this)] = bsub(_balance[address(this)], amt);
        _totalSupply = bsub(_totalSupply, amt);
        emit Transfer(address(this), address(0), amt);
    }

    function _move(address src, address dst, uint amt) internal {
        require(_balance[src] >= amt, "ERR_INSUFFICIENT_BAL");
        _balance[src] = bsub(_balance[src], amt);
        _balance[dst] = badd(_balance[dst], amt);
        emit Transfer(src, dst, amt);
    }

    function _push(address to, uint amt) internal {
        _move(address(this), to, amt);
    }

    function _pull(address from, uint amt) internal {
        _move(from, address(this), amt);
    }
}

contract BToken is BTokenBase, IERC20 {

    string  private _name     = "Balancer Pool Token";
    string  private _symbol   = "BPT";
    uint8   private _decimals = 18;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }

    function allowance(address src, address dst) external view override returns (uint) {
        return _allowance[src][dst];
    }

    function balanceOf(address whom) external view override returns (uint) {
        return _balance[whom];
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function approve(address dst, uint amt) external override returns (bool) {
        _allowance[msg.sender][dst] = amt;
        emit Approval(msg.sender, dst, amt);
        return true;
    }

    function increaseApproval(address dst, uint amt) external returns (bool) {
        _allowance[msg.sender][dst] = badd(_allowance[msg.sender][dst], amt);
        emit Approval(msg.sender, dst, _allowance[msg.sender][dst]);
        return true;
    }

    function decreaseApproval(address dst, uint amt) external returns (bool) {
        uint oldValue = _allowance[msg.sender][dst];
        if (amt > oldValue) {
            _allowance[msg.sender][dst] = 0;
        } else {
            _allowance[msg.sender][dst] = bsub(oldValue, amt);
        }
        emit Approval(msg.sender, dst, _allowance[msg.sender][dst]);
        return true;
    }

    function transfer(address dst, uint amt) external override returns (bool) {
        _move(msg.sender, dst, amt);
        return true;
    }

    function transferFrom(address src, address dst, uint amt) external override returns (bool) {
        require(msg.sender == src || amt <= _allowance[src][msg.sender], "ERR_BTOKEN_BAD_CALLER");
        _move(src, dst, amt);
        if (msg.sender != src && _allowance[src][msg.sender] != uint256(-1)) {
            _allowance[src][msg.sender] = bsub(_allowance[src][msg.sender], amt);
            emit Approval(msg.sender, dst, _allowance[src][msg.sender]);
        }
        return true;
    }
}

// File: contracts\test\BMath.sol


pragma solidity ^0.6.6;


contract BMath is BBronze, BConst, BNum {
    /**********************************************************************************************
    // calcSpotPrice                                                                             //
    // sP = spotPrice                                                                            //
    // bI = tokenBalanceIn                ( bI / wI )         1                                  //
    // bO = tokenBalanceOut         sP =  -----------  *  ----------                             //
    // wI = tokenWeightIn                 ( bO / wO )     ( 1 - sF )                             //
    // wO = tokenWeightOut                                                                       //
    // sF = swapFee                                                                              //
    **********************************************************************************************/
    function calcSpotPrice(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint swapFee
    )
        public pure
        returns (uint spotPrice)
    {
        uint numer = bdiv(tokenBalanceIn, tokenWeightIn);
        uint denom = bdiv(tokenBalanceOut, tokenWeightOut);
        uint ratio = bdiv(numer, denom);
        uint scale = bdiv(BONE, bsub(BONE, swapFee));
        return  (spotPrice = bmul(ratio, scale));
    }

    /**********************************************************************************************
    // calcOutGivenIn                                                                            //
    // aO = tokenAmountOut                                                                       //
    // bO = tokenBalanceOut                                                                      //
    // bI = tokenBalanceIn              /      /            bI             \    (wI / wO) \      //
    // aI = tokenAmountIn    aO = bO * |  1 - | --------------------------  | ^            |     //
    // wI = tokenWeightIn               \      \ ( bI + ( aI * ( 1 - sF )) /              /      //
    // wO = tokenWeightOut                                                                       //
    // sF = swapFee                                                                              //
    **********************************************************************************************/
    function calcOutGivenIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountIn,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountOut)
    {
        uint weightRatio = bdiv(tokenWeightIn, tokenWeightOut);
        uint adjustedIn = bsub(BONE, swapFee);
        adjustedIn = bmul(tokenAmountIn, adjustedIn);
        uint y = bdiv(tokenBalanceIn, badd(tokenBalanceIn, adjustedIn));
        uint foo = bpow(y, weightRatio);
        uint bar = bsub(BONE, foo);
        tokenAmountOut = bmul(tokenBalanceOut, bar);
        return tokenAmountOut;
    }

    /**********************************************************************************************
    // calcInGivenOut                                                                            //
    // aI = tokenAmountIn                                                                        //
    // bO = tokenBalanceOut               /  /     bO      \    (wO / wI)      \                 //
    // bI = tokenBalanceIn          bI * |  | ------------  | ^            - 1  |                //
    // aO = tokenAmountOut    aI =        \  \ ( bO - aO ) /                   /                 //
    // wI = tokenWeightIn           --------------------------------------------                 //
    // wO = tokenWeightOut                          ( 1 - sF )                                   //
    // sF = swapFee                                                                              //
    **********************************************************************************************/
    function calcInGivenOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountOut,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountIn)
    {
        uint weightRatio = bdiv(tokenWeightOut, tokenWeightIn);
        uint diff = bsub(tokenBalanceOut, tokenAmountOut);
        uint y = bdiv(tokenBalanceOut, diff);
        uint foo = bpow(y, weightRatio);
        foo = bsub(foo, BONE);
        tokenAmountIn = bsub(BONE, swapFee);
        tokenAmountIn = bdiv(bmul(tokenBalanceIn, foo), tokenAmountIn);
        return tokenAmountIn;
    }

    /**********************************************************************************************
    // calcPoolOutGivenSingleIn                                                                  //
    // pAo = poolAmountOut         /                                              \              //
    // tAi = tokenAmountIn        ///      /     //    wI \      \\       \     wI \             //
    // wI = tokenWeightIn        //| tAi *| 1 - || 1 - --  | * sF || + tBi \    --  \            //
    // tW = totalWeight     pAo=||  \      \     \\    tW /      //         | ^ tW   | * pS - pS //
    // tBi = tokenBalanceIn      \\  ------------------------------------- /        /            //
    // pS = poolSupply            \\                    tBi               /        /             //
    // sF = swapFee                \                                              /              //
    **********************************************************************************************/
    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    )
        public pure
        returns (uint poolAmountOut)
    {
        // Charge the trading fee for the proportion of tokenAi
        //  which is implicitly traded to the other pool tokens.
        // That proportion is (1- weightTokenIn)
        // tokenAiAfterFee = tAi * (1 - (1-weightTi) * poolFee);
        uint normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint zaz = bmul(bsub(BONE, normalizedWeight), swapFee); 
        uint tokenAmountInAfterFee = bmul(tokenAmountIn, bsub(BONE, zaz));

        uint newTokenBalanceIn = badd(tokenBalanceIn, tokenAmountInAfterFee);
        uint tokenInRatio = bdiv(newTokenBalanceIn, tokenBalanceIn);

        // uint newPoolSupply = (ratioTi ^ weightTi) * poolSupply;
        uint poolRatio = bpow(tokenInRatio, normalizedWeight);
        uint newPoolSupply = bmul(poolRatio, poolSupply);
        poolAmountOut = bsub(newPoolSupply, poolSupply);
        return poolAmountOut;
    }

    /**********************************************************************************************
    // calcSingleInGivenPoolOut                                                                  //
    // tAi = tokenAmountIn              //(pS + pAo)\     /    1    \\                           //
    // pS = poolSupply                 || ---------  | ^ | --------- || * bI - bI                //
    // pAo = poolAmountOut              \\    pS    /     \(wI / tW)//                           //
    // bI = balanceIn          tAi =  --------------------------------------------               //
    // wI = weightIn                              /      wI  \                                   //
    // tW = totalWeight                          |  1 - ----  |  * sF                            //
    // sF = swapFee                               \      tW  /                                   //
    **********************************************************************************************/
    function calcSingleInGivenPoolOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountOut,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountIn)
    {
        uint normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint newPoolSupply = badd(poolSupply, poolAmountOut);
        uint poolRatio = bdiv(newPoolSupply, poolSupply);
      
        //uint newBalTi = poolRatio^(1/weightTi) * balTi;
        uint boo = bdiv(BONE, normalizedWeight); 
        uint tokenInRatio = bpow(poolRatio, boo);
        uint newTokenBalanceIn = bmul(tokenInRatio, tokenBalanceIn);
        uint tokenAmountInAfterFee = bsub(newTokenBalanceIn, tokenBalanceIn);
        // Do reverse order of fees charged in joinswap_ExternAmountIn, this way 
        //     ``` pAo == joinswap_ExternAmountIn(Ti, joinswap_PoolAmountOut(pAo, Ti)) ```
        //uint tAi = tAiAfterFee / (1 - (1-weightTi) * swapFee) ;
        uint zar = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountIn = bdiv(tokenAmountInAfterFee, bsub(BONE, zar));
        return tokenAmountIn;
    }

    /**********************************************************************************************
    // calcSingleOutGivenPoolIn                                                                  //
    // tAo = tokenAmountOut            /      /                                             \\   //
    // bO = tokenBalanceOut           /      // pS - (pAi * (1 - eF)) \     /    1    \      \\  //
    // pAi = poolAmountIn            | bO - || ----------------------- | ^ | --------- | * b0 || //
    // ps = poolSupply                \      \\          pS           /     \(wO / tW)/      //  //
    // wI = tokenWeightIn      tAo =   \      \                                             //   //
    // tW = totalWeight                    /     /      wO \       \                             //
    // sF = swapFee                    *  | 1 - |  1 - ---- | * sF  |                            //
    // eF = exitFee                        \     \      tW /       /                             //
    **********************************************************************************************/
    function calcSingleOutGivenPoolIn(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountIn,
        uint swapFee,
        uint exitFee
    )
        public pure
        returns (uint tokenAmountOut)
    {
        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        // charge exit fee on the pool token side
        // pAiAfterExitFee = pAi*(1-exitFee)
        // uint poolAmountInAfterExitFee = bmul(poolAmountIn, bsub(BONE, EXIT_FEE));
        uint poolAmountInAfterExitFee = bmul(poolAmountIn, bsub(BONE, exitFee));
        uint newPoolSupply = bsub(poolSupply, poolAmountInAfterExitFee);
        uint poolRatio = bdiv(newPoolSupply, poolSupply);
     
        // newBalTo = poolRatio^(1/weightTo) * balTo;
        uint tokenOutRatio = bpow(poolRatio, bdiv(BONE, normalizedWeight));
        uint newTokenBalanceOut = bmul(tokenOutRatio, tokenBalanceOut);

        uint tokenAmountOutBeforeSwapFee = bsub(tokenBalanceOut, newTokenBalanceOut);

        // charge swap fee on the output token side 
        //uint tAo = tAoBeforeSwapFee * (1 - (1-weightTo) * swapFee)
        uint zaz = bmul(bsub(BONE, normalizedWeight), swapFee); 
        tokenAmountOut = bmul(tokenAmountOutBeforeSwapFee, bsub(BONE, zaz));
        return tokenAmountOut;
    }

    /**********************************************************************************************
    // calcPoolInGivenSingleOut                                                                  //
    // pAi = poolAmountIn               // /               tAo             \\     / wO \     \   //
    // bO = tokenBalanceOut            // | bO - -------------------------- |\   | ---- |     \  //
    // tAo = tokenAmountOut      pS - ||   \     1 - ((1 - (tO / tW)) * sF)/  | ^ \ tW /  * pS | //
    // ps = poolSupply                 \\ -----------------------------------/                /  //
    // wO = tokenWeightOut  pAi =       \\               bO                 /                /   //
    // tW = totalWeight           -------------------------------------------------------------  //
    // sF = swapFee                                        ( 1 - eF )                            //
    // eF = exitFee                                                                              //
    **********************************************************************************************/
    function calcPoolInGivenSingleOut(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountOut,
        uint swapFee,
        uint exitFee
    )
        public pure
        returns (uint poolAmountIn)
    {

        // charge swap fee on the output token side 
        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        //uint tAoBeforeSwapFee = tAo / (1 - (1-weightTo) * swapFee) ;
        uint zoo = bsub(BONE, normalizedWeight);
        uint zar = bmul(zoo, swapFee); 
        uint tokenAmountOutBeforeSwapFee = bdiv(tokenAmountOut, bsub(BONE, zar));

        uint newTokenBalanceOut = bsub(tokenBalanceOut, tokenAmountOutBeforeSwapFee);
        uint tokenOutRatio = bdiv(newTokenBalanceOut, tokenBalanceOut);

        //uint newPoolSupply = (ratioTo ^ weightTo) * poolSupply;
        uint poolRatio = bpow(tokenOutRatio, normalizedWeight);
        uint newPoolSupply = bmul(poolRatio, poolSupply);
        uint poolAmountInAfterExitFee = bsub(poolSupply, newPoolSupply);

        // charge exit fee on the pool token side
        // pAi = pAiAfterExitFee/(1-exitFee)
        // poolAmountIn = bdiv(poolAmountInAfterExitFee, bsub(BONE, EXIT_FEE));
        poolAmountIn = bdiv(poolAmountInAfterExitFee, bsub(BONE, exitFee));
        return poolAmountIn;
    }


}

// File: node_modules\@openzeppelin\contracts\math\SafeMath.sol



pragma solidity ^0.6.0;

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

// File: node_modules\@openzeppelin\contracts\utils\Address.sol



pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

// File: @openzeppelin\contracts\token\ERC20\SafeERC20.sol



pragma solidity ^0.6.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts\test\BPool.sol


pragma solidity ^0.6.6;




// Core contract; can't be changed. So disable solhint (reminder for v2)

/* solhint-disable func-order */
/* solhint-disable event-name-camelcase */

contract BPool is BBronze, BToken, BMath {
    using SafeERC20 for IERC20;

    struct Record {
        bool bound;   // is token bound to pool
        uint index;   // private
        uint denorm;  // denormalized weight
        uint balance;
    }

    event LOG_SWAP(
        address indexed caller,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256         tokenAmountIn,
        uint256         tokenAmountOut
    );

    event LOG_JOIN(
        address indexed caller,
        address indexed tokenIn,
        uint256         tokenAmountIn
    );

    event LOG_EXIT(
        address indexed caller,
        address indexed tokenOut,
        uint256         tokenAmountOut
    );

    event LOG_CALL(
        bytes4  indexed sig,
        address indexed caller,
        bytes           data
    ) anonymous;

    modifier _logs_() {
        emit LOG_CALL(msg.sig, msg.sender, msg.data);
        _;
    }

    modifier _lock_() {
        require(!_mutex, "ERR_REENTRY");
        _mutex = true;
        _;
        _mutex = false;
    }

    modifier _viewlock_() {
        require(!_mutex, "ERR_REENTRY");
        _;
    }

    bool private _mutex;

    address private _factory;    // BFactory address to push token exitFee to
    address private _controller; // has CONTROL role
    bool private _publicSwap; // true if PUBLIC can call SWAP functions

    // `setSwapFee` and `finalize` require CONTROL
    // `finalize` sets `PUBLIC can SWAP`, `PUBLIC can JOIN`
    uint private _swapFee;
    uint private _exitFee;
    bool private _finalized;

    address[] private _tokens;
    mapping(address=>Record) private  _records;
    uint private _totalWeight;

    // fraction of the pool that has accrued due to fees since last fee harvest
    uint private _fracPoolFees;

    constructor() public {
        _controller = msg.sender;
        _factory = msg.sender;
        _swapFee = MIN_FEE;
        _publicSwap = false;
        _finalized = false;
    }

    function isPublicSwap()
        external view
        returns (bool)
    {
        return _publicSwap;
    }

    function isFinalized()
        external view
        returns (bool)
    {
        return _finalized;
    }

    function isBound(address t)
        external view
        returns (bool)
    {
        return _records[t].bound;
    }

    function getNumTokens()
        external view
        returns (uint) 
    {
        return _tokens.length;
    }

    function getCurrentTokens()
        external view _viewlock_
        returns (address[] memory tokens)
    {
        return _tokens;
    }

    function getFinalTokens()
        external view
        _viewlock_
        returns (address[] memory tokens)
    {
        require(_finalized, "ERR_NOT_FINALIZED");
        return _tokens;
    }

    function getDenormalizedWeight(address token)
        external view
        _viewlock_
        returns (uint)
    {

        require(_records[token].bound, "ERR_NOT_BOUND");
        return _records[token].denorm;
    }

    function getTotalDenormalizedWeight()
        external view
        _viewlock_
        returns (uint)
    {
        return _totalWeight;
    }

    function getNormalizedWeight(address token)
        external view
        _viewlock_
        returns (uint)
    {

        require(_records[token].bound, "ERR_NOT_BOUND");
        uint denorm = _records[token].denorm;
        return bdiv(denorm, _totalWeight);
    }

    function getBalance(address token)
        external view
        _viewlock_
        returns (uint)
    {

        require(_records[token].bound, "ERR_NOT_BOUND");
        return _records[token].balance;
    }

    function getSwapFee()
        external view
        _viewlock_
        returns (uint)
    {
        return _swapFee;
    }

    function getFracPoolFees()
        external view
        _viewlock_
        returns (uint)
    {
        return _fracPoolFees;
    }

    function getController()
        external view
        _viewlock_
        returns (address)
    {
        return _controller;
    }

    function setSwapFee(uint swapFee)
        external
        _logs_
        _lock_
    { 
        require(!_finalized, "ERR_IS_FINALIZED");
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(swapFee >= MIN_FEE, "ERR_MIN_FEE");
        require(swapFee <= MAX_FEE, "ERR_MAX_FEE");
        _swapFee = swapFee;
    }

    function setExitFee(uint exitFee)
        external
        _logs_
        _lock_
    {
        require(!_finalized, "ERR_IS_FINALIZED");
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(exitFee <= MAX_FEE, "ERR_MAX_FEE");
        _exitFee = exitFee;
    }

    function getExitFee()
        external view
        _viewlock_
        returns (uint)
    {
        return _exitFee;
    }

    function setController(address manager)
        external
        _logs_
        _lock_
    {
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        _controller = manager;
    }

    function setPublicSwap(bool public_)
        external
        _logs_
        _lock_
    {
        require(!_finalized, "ERR_IS_FINALIZED");
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        _publicSwap = public_;
    }

    // Not needed for ConfigurableRightsPool
    // function finalize()
    //     external
    //     _logs_
    //     _lock_
    // {
    //     require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
    //     require(!_finalized, "ERR_IS_FINALIZED");
    //     require(_tokens.length >= MIN_BOUND_TOKENS, "ERR_MIN_TOKENS");

    //     _finalized = true;
    //     _publicSwap = true;

    //     _mintPoolShare(INIT_POOL_SUPPLY);
    //     _pushPoolShare(msg.sender, INIT_POOL_SUPPLY);
    // }


    function bind(address token, uint balance, uint denorm)
        external
        _logs_
        // _lock_  Bind does not lock because it jumps to `rebind`, which does
    {
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(!_records[token].bound, "ERR_IS_BOUND");
        require(!_finalized, "ERR_IS_FINALIZED");

        // No bound on max tokens in Alpaca
        // Governance determines how many and which tokens are included
        // require(_tokens.length < MAX_BOUND_TOKENS, "ERR_MAX_TOKENS");

        _records[token] = Record({
            bound: true,
            index: _tokens.length,
            denorm: 0,    // balance and denorm will be validated
            balance: 0   // and set by `rebind`
        });
        _tokens.push(token);
        rebind(token, balance, denorm);
    }

    function rebind(address token, uint balance, uint denorm)
        public
        _logs_
        _lock_
    {

        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(_records[token].bound, "ERR_NOT_BOUND");
        require(!_finalized, "ERR_IS_FINALIZED");

        require(denorm >= MIN_WEIGHT, "ERR_MIN_WEIGHT");
        require(denorm <= MAX_WEIGHT, "ERR_MAX_WEIGHT");
        require(balance >= MIN_BALANCE, "ERR_MIN_BALANCE");

        // Adjust the denorm and totalWeight
        uint oldWeight = _records[token].denorm;
        if (denorm > oldWeight) {
            _totalWeight = badd(_totalWeight, bsub(denorm, oldWeight));
            require(_totalWeight <= MAX_TOTAL_WEIGHT, "ERR_MAX_TOTAL_WEIGHT");
        } else if (denorm < oldWeight) {
            _totalWeight = bsub(_totalWeight, bsub(oldWeight, denorm));
        }        
        _records[token].denorm = denorm;

        // Adjust the balance record and actual token balance
        uint oldBalance = _records[token].balance;
        _records[token].balance = balance;
        if (balance > oldBalance) {
            _pullUnderlying(token, msg.sender, bsub(balance, oldBalance));
        } else if (balance < oldBalance) {
            // In this case liquidity is being withdrawn, so charge EXIT_FEE
            uint tokenBalanceWithdrawn = bsub(oldBalance, balance);
            // uint tokenExitFee = bmul(tokenBalanceWithdrawn, EXIT_FEE);
            // uint tokenExitFee = bmul(tokenBalanceWithdrawn, _exitFee);
            uint tokenExitFee = 0;
            _pushUnderlying(token, msg.sender, bsub(tokenBalanceWithdrawn, tokenExitFee));
            // _pushUnderlying(token, _factory, tokenExitFee);
            // _pushUnderlying(token, msg.sender, tokenBalanceWithdrawn);
        }
    }

    function unbind(address token)
        external
        _logs_
        _lock_
    {

        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(_records[token].bound, "ERR_NOT_BOUND");
        require(!_finalized, "ERR_IS_FINALIZED");

        uint tokenBalance = _records[token].balance;
        // uint tokenExitFee = bmul(tokenBalance, EXIT_FEE);
        // uint tokenExitFee = bmul(tokenBalance, _exitFee);
        uint tokenExitFee = 0;

        _totalWeight = bsub(_totalWeight, _records[token].denorm);

        // Swap the token-to-unbind with the last token,
        // then delete the last token
        uint index = _records[token].index;
        uint last = _tokens.length - 1;
        _tokens[index] = _tokens[last];
        _records[_tokens[index]].index = index;
        _tokens.pop();
        _records[token] = Record({
            bound: false,
            index: 0,
            denorm: 0,
            balance: 0
        });

        _pushUnderlying(token, msg.sender, bsub(tokenBalance, tokenExitFee));
        _pushUnderlying(token, _factory, tokenExitFee);
    }

    // Absorb any tokens that have been sent to this contract into the pool
    function gulp(address token)
        external
        _logs_
        _lock_
    {
        require(_records[token].bound, "ERR_NOT_BOUND");
        _records[token].balance = IERC20(token).balanceOf(address(this));
    }

    function getSpotPrice(address tokenIn, address tokenOut)
        external view
        _viewlock_
        returns (uint spotPrice)
    {
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];
        return calcSpotPrice(inRecord.balance, inRecord.denorm, outRecord.balance, outRecord.denorm, _swapFee);
    }

    function getSpotPriceSansFee(address tokenIn, address tokenOut)
        external view
        _viewlock_
        returns (uint spotPrice)
    {
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];
        return calcSpotPrice(inRecord.balance, inRecord.denorm, outRecord.balance, outRecord.denorm, 0);
    }

    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn)
        external
        _logs_
        _lock_
    {
        require(_finalized, "ERR_NOT_FINALIZED");

        uint poolTotal = totalSupply();
        uint ratio = bdiv(poolAmountOut, poolTotal);
        require(ratio != 0, "ERR_MATH_APPROX");

        for (uint i = 0; i < _tokens.length; i++) {
            address t = _tokens[i];
            uint bal = _records[t].balance;
            uint tokenAmountIn = bmul(ratio, bal);
            require(tokenAmountIn != 0, "ERR_MATH_APPROX");
            require(tokenAmountIn <= maxAmountsIn[i], "ERR_LIMIT_IN");
            _records[t].balance = badd(_records[t].balance, tokenAmountIn);
            emit LOG_JOIN(msg.sender, t, tokenAmountIn);
            _pullUnderlying(t, msg.sender, tokenAmountIn);
        }
        _mintPoolShare(poolAmountOut);
        _pushPoolShare(msg.sender, poolAmountOut);
    }

    // function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut)
    //     external
    //     _logs_
    //     _lock_
    // {
    //     require(_finalized, "ERR_NOT_FINALIZED");

    //     uint poolTotal = totalSupply();
    //     // uint exitFee = bmul(poolAmountIn, EXIT_FEE);
    //     uint exitFee = bmul(poolAmountIn, _exitFee);
    //     uint pAiAfterExitFee = bsub(poolAmountIn, exitFee);
    //     uint ratio = bdiv(pAiAfterExitFee, poolTotal);
    //     require(ratio != 0, "ERR_MATH_APPROX");

    //     _pullPoolShare(msg.sender, poolAmountIn);
    //     _pushPoolShare(_factory, exitFee);
    //     _burnPoolShare(pAiAfterExitFee);

    //     for (uint i = 0; i < _tokens.length; i++) {
    //         address t = _tokens[i];
    //         uint bal = _records[t].balance;
    //         uint tokenAmountOut = bmul(ratio, bal);
    //         require(tokenAmountOut != 0, "ERR_MATH_APPROX");
    //         require(tokenAmountOut >= minAmountsOut[i], "ERR_LIMIT_OUT");
    //         _records[t].balance = bsub(_records[t].balance, tokenAmountOut);
    //         emit LOG_EXIT(msg.sender, t, tokenAmountOut);
    //         _pushUnderlying(t, msg.sender, tokenAmountOut);
    //     }
    // }


    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    )
        external
        _logs_
        _lock_
        returns (uint tokenAmountOut, uint spotPriceAfter)
    {

        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        require(_publicSwap, "ERR_SWAP_NOT_PUBLIC");

        Record storage inRecord = _records[address(tokenIn)];
        Record storage outRecord = _records[address(tokenOut)];

        require(tokenAmountIn <= bmul(inRecord.balance, MAX_IN_RATIO), "ERR_MAX_IN_RATIO");

        uint spotPriceBefore = calcSpotPrice(
                                    inRecord.balance,
                                    inRecord.denorm,
                                    outRecord.balance,
                                    outRecord.denorm,
                                    _swapFee
                                );
        require(spotPriceBefore <= maxPrice, "ERR_BAD_LIMIT_PRICE");

        tokenAmountOut = calcOutGivenIn(
                            inRecord.balance,
                            inRecord.denorm,
                            outRecord.balance,
                            outRecord.denorm,
                            tokenAmountIn,
                            _swapFee
                        );
        require(tokenAmountOut >= minAmountOut, "ERR_LIMIT_OUT");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);
        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        spotPriceAfter = calcSpotPrice(
                                inRecord.balance,
                                inRecord.denorm,
                                outRecord.balance,
                                outRecord.denorm,
                                _swapFee
                            );
        require(spotPriceAfter >= spotPriceBefore, "ERR_MATH_APPROX");     
        require(spotPriceAfter <= maxPrice, "ERR_LIMIT_PRICE");
        require(spotPriceBefore <= bdiv(tokenAmountIn, tokenAmountOut), "ERR_MATH_APPROX");

        emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);

        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        uint fracPoolFeesTrade = calcFracPoolFeesFromSwap(tokenIn, tokenAmountIn);
        _updateFracPoolFees(fracPoolFeesTrade);

        return (tokenAmountOut, spotPriceAfter);
    }

    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    )
        external
        _logs_
        _lock_ 
        returns (uint tokenAmountIn, uint spotPriceAfter)
    {
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        require(_publicSwap, "ERR_SWAP_NOT_PUBLIC");

        Record storage inRecord = _records[address(tokenIn)];
        Record storage outRecord = _records[address(tokenOut)];

        require(tokenAmountOut <= bmul(outRecord.balance, MAX_OUT_RATIO), "ERR_MAX_OUT_RATIO");

        uint spotPriceBefore = calcSpotPrice(
                                    inRecord.balance,
                                    inRecord.denorm,
                                    outRecord.balance,
                                    outRecord.denorm,
                                    _swapFee
                                );
        require(spotPriceBefore <= maxPrice, "ERR_BAD_LIMIT_PRICE");

        tokenAmountIn = calcInGivenOut(
                            inRecord.balance,
                            inRecord.denorm,
                            outRecord.balance,
                            outRecord.denorm,
                            tokenAmountOut,
                            _swapFee
                        );
        require(tokenAmountIn <= maxAmountIn, "ERR_LIMIT_IN");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);
        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        spotPriceAfter = calcSpotPrice(
                                inRecord.balance,
                                inRecord.denorm,
                                outRecord.balance,
                                outRecord.denorm,
                                _swapFee
                            );
        require(spotPriceAfter >= spotPriceBefore, "ERR_MATH_APPROX");
        require(spotPriceAfter <= maxPrice, "ERR_LIMIT_PRICE");
        require(spotPriceBefore <= bdiv(tokenAmountIn, tokenAmountOut), "ERR_MATH_APPROX");

        emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);

        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        // Update the running fraction of the pool attributable to accumulated fees
        uint fracPoolFeesTrade = calcFracPoolFeesFromSwap(tokenIn, tokenAmountIn);
        _updateFracPoolFees(fracPoolFeesTrade);

        return (tokenAmountIn, spotPriceAfter);
    }


    /* 
        Unused functions in CRP - disable to keep size of BFactory down
    */

    // function joinswapExternAmountIn(address tokenIn, uint tokenAmountIn, uint minPoolAmountOut)
    //     external
    //     _logs_
    //     _lock_
    //     returns (uint poolAmountOut)

    // {
    //     require(_finalized, "ERR_NOT_FINALIZED");
    //     require(_records[tokenIn].bound, "ERR_NOT_BOUND");
    //     require(tokenAmountIn <= bmul(_records[tokenIn].balance, MAX_IN_RATIO), "ERR_MAX_IN_RATIO");

    //     Record storage inRecord = _records[tokenIn];

    //     poolAmountOut = calcPoolOutGivenSingleIn(
    //                         inRecord.balance,
    //                         inRecord.denorm,
    //                         _totalSupply,
    //                         _totalWeight,
    //                         tokenAmountIn,
    //                         _swapFee
    //                     );

    //     require(poolAmountOut >= minPoolAmountOut, "ERR_LIMIT_OUT");

    //     inRecord.balance = badd(inRecord.balance, tokenAmountIn);

    //     emit LOG_JOIN(msg.sender, tokenIn, tokenAmountIn);

    //     _mintPoolShare(poolAmountOut);
    //     _pushPoolShare(msg.sender, poolAmountOut);
    //     _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);

    //     // Update the running fraction of the pool attributable to accumulated fees
    //     uint fracPoolFeesTrade = calcFracPoolFeesFromPoolJoin(tokenIn, tokenAmountIn);
    //     _updateFracPoolFees(fracPoolFeesTrade);
        
    //     return poolAmountOut;
    // }

    // function joinswapPoolAmountOut(address tokenIn, uint poolAmountOut, uint maxAmountIn)
    //     external
    //     _logs_
    //     _lock_
    //     returns (uint tokenAmountIn)
    // {
    //     require(_finalized, "ERR_NOT_FINALIZED");
    //     require(_records[tokenIn].bound, "ERR_NOT_BOUND");

    //     Record storage inRecord = _records[tokenIn];

    //     tokenAmountIn = calcSingleInGivenPoolOut(
    //                         inRecord.balance,
    //                         inRecord.denorm,
    //                         _totalSupply,
    //                         _totalWeight,
    //                         poolAmountOut,
    //                         _swapFee
    //                     );

    //     require(tokenAmountIn != 0, "ERR_MATH_APPROX");
    //     require(tokenAmountIn <= maxAmountIn, "ERR_LIMIT_IN");
        
    //     require(tokenAmountIn <= bmul(_records[tokenIn].balance, MAX_IN_RATIO), "ERR_MAX_IN_RATIO");

    //     inRecord.balance = badd(inRecord.balance, tokenAmountIn);

    //     emit LOG_JOIN(msg.sender, tokenIn, tokenAmountIn);

    //     _mintPoolShare(poolAmountOut);
    //     _pushPoolShare(msg.sender, poolAmountOut);
    //     _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);

    //     // Update the running fraction of the pool attributable to accumulated fees
    //     uint fracPoolFeesTrade = calcFracPoolFeesFromPoolJoin(tokenIn, tokenAmountIn);
    //     _updateFracPoolFees(fracPoolFeesTrade);

    //     return tokenAmountIn;
    // }

    // function exitswapPoolAmountIn(address tokenOut, uint poolAmountIn, uint minAmountOut)
    //     external
    //     _logs_
    //     _lock_
    //     returns (uint tokenAmountOut)
    // {
    //     require(_finalized, "ERR_NOT_FINALIZED");
    //     require(_records[tokenOut].bound, "ERR_NOT_BOUND");

    //     Record storage outRecord = _records[tokenOut];

    //     tokenAmountOut = calcSingleOutGivenPoolIn(
    //                         outRecord.balance,
    //                         outRecord.denorm,
    //                         _totalSupply,
    //                         _totalWeight,
    //                         poolAmountIn,
    //                         _swapFee,
    //                         _exitFee
    //                     );

    //     require(tokenAmountOut >= minAmountOut, "ERR_LIMIT_OUT");
        
    //     require(tokenAmountOut <= bmul(_records[tokenOut].balance, MAX_OUT_RATIO), "ERR_MAX_OUT_RATIO");

    //     outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

    //     // uint exitFee = bmul(poolAmountIn, EXIT_FEE);
    //     uint exitFee = bmul(poolAmountIn, _exitFee);

    //     emit LOG_EXIT(msg.sender, tokenOut, tokenAmountOut);

    //     _pullPoolShare(msg.sender, poolAmountIn);
    //     _burnPoolShare(bsub(poolAmountIn, exitFee));
    //     _pushPoolShare(_factory, exitFee);
    //     _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

    //     // Update the running fraction of the pool attributable to accumulated fees
    //     uint fracPoolFeesTrade = calcFracPoolFeesFromPoolExit(tokenOut, tokenAmountOut);
    //     _updateFracPoolFees(fracPoolFeesTrade);

    //     return tokenAmountOut;
    // }

    // function exitswapExternAmountOut(address tokenOut, uint tokenAmountOut, uint maxPoolAmountIn)
    //     external
    //     _logs_
    //     _lock_
    //     returns (uint poolAmountIn)
    // {
    //     require(_finalized, "ERR_NOT_FINALIZED");
    //     require(_records[tokenOut].bound, "ERR_NOT_BOUND");
    //     require(tokenAmountOut <= bmul(_records[tokenOut].balance, MAX_OUT_RATIO), "ERR_MAX_OUT_RATIO");

    //     Record storage outRecord = _records[tokenOut];

    //     poolAmountIn = calcPoolInGivenSingleOut(
    //                         outRecord.balance,
    //                         outRecord.denorm,
    //                         _totalSupply,
    //                         _totalWeight,
    //                         tokenAmountOut,
    //                         _swapFee,
    //                         _exitFee
    //                     );

    //     require(poolAmountIn != 0, "ERR_MATH_APPROX");
    //     require(poolAmountIn <= maxPoolAmountIn, "ERR_LIMIT_IN");

    //     outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

    //     // uint exitFee = bmul(poolAmountIn, EXIT_FEE);
    //     uint exitFee = bmul(poolAmountIn, _exitFee);

    //     emit LOG_EXIT(msg.sender, tokenOut, tokenAmountOut);

    //     _pullPoolShare(msg.sender, poolAmountIn);
    //     _burnPoolShare(bsub(poolAmountIn, exitFee));
    //     _pushPoolShare(_factory, exitFee);
    //     _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);        

    //     // Update the running fraction of the pool attributable to accumulated fees
    //     uint fracPoolFeesTrade = calcFracPoolFeesFromPoolExit(tokenOut, tokenAmountOut);
    //     _updateFracPoolFees(fracPoolFeesTrade);
        
    //     return poolAmountIn;
    // }


    /*
        Internal function to upate the running fraction of the pool attributable to accumulated fees

        Fee value as a percentage of the portfolio value at after trade t 
        (that is, the one that brings us from state T=t-1 to T=t) 
        if the input asset is i is:

        F_{t,t} = w_i * (f * D_{i,t}) / B_{i,t}

        where

        f = fee
        D_{i,t} = amount of the input asset traded in to the pool for trade t
        f * D_{i,t} = the value of the fee for trade t in terms of asset i
        B_{i,t} = amount of input asset in the pool after trade t
        w_i = weight of input asset
        and V_t = B_{i,t} / w_i = the value of the poot after trade t in terms of asset i

        For the total fee earned between T=0 and T=t, 
        we need to dilute the previous total amount by the new fee ownership

        That is, let G_{t} be the total accumulated fees between T=0 and T=t.  
        
        Then 

        G_{t+1} = G_{t} * (1 - F_{t+1,t+1}) + F_{t+1,t+1}

        So after each trade t, we need to:

        1. Retrieve G_{t-1} from global storage
        2. Calculate F_{t,t}
        3. Calculate G_{t}
        4. Store G_{t} in global storage
    */
    function calcFracPoolFeesFromSwap(
        address tokenIn,
        uint tokenAmountIn
    )
        public
        view
        returns (uint fracPoolFeesTrade)
    {
        uint balT = _records[tokenIn].balance;
        uint denorm = _records[tokenIn].denorm;
        uint weight = bdiv(denorm, _totalWeight);       // norm weight for tokenIn

        uint feeAmt = bmul(_swapFee, tokenAmountIn);    // fee size in terms of tokenIn
        fracPoolFeesTrade = bmul(weight, bdiv(feeAmt, balT));
        
        // uint fracPoolFeesPrev = _fracPoolFees;
        // uint dilutionFactor = bsub(BONE, fracPoolFeesTrade);
        // uint fracPoolFeesCurr = badd(bmul(fracPoolFeesPrev, dilutionFactor), fracPoolFeesTrade);
        // _fracPoolFees = fracPoolFeesCurr;
        
        return fracPoolFeesTrade;
    }

    /*
        Same as above, but for single-token pool joins (i.e. token in => pool shares out)
        Fees are only assessed on the fraction of the input token that is traded, i.e. (1-weight)
        See BMath.sol for more detail
    */
    function calcFracPoolFeesFromPoolJoin(
        address tokenIn,
        uint tokenAmountIn
    )
        public
        view
        returns (uint fracPoolFeesTrade)
    {
        uint balT = _records[tokenIn].balance;
        uint denorm = _records[tokenIn].denorm;
        uint weight = bdiv(denorm, _totalWeight);       // norm weight for tokenIn
        uint tokenAmountInTraded = bmul(tokenAmountIn, bsub(BONE, weight));

        uint feeAmt = bmul(_swapFee, tokenAmountInTraded);    // fee size in terms of tokenIn
        fracPoolFeesTrade = bmul(weight, bdiv(feeAmt, balT));
        
        // uint fracPoolFeesPrev = _fracPoolFees;
        // uint dilutionFactor = bsub(BONE, fracPoolFeesTrade);
        // uint fracPoolFeesCurr = badd(bmul(fracPoolFeesPrev, dilutionFactor), fracPoolFeesTrade);
        // _fracPoolFees = fracPoolFeesCurr;
        
        return fracPoolFeesTrade;
    }

    /*
        Same as above, but for single-token pool exits (i.e. pool shares in => token out)
        Swap fees are charged on the output token side
        See BMath.sol for more detail
        Note: Disregards exit fees
        
        Math:
        tAoBeforeSwapFee = tAo / (1 - (1-weightTo) * swapFee)
        feeAmt = tAoBeforeSwapFee - tAo
               = tAo * [1 / (1 - (1-weightTo) * swapFee) - 1]
               = tAo * ((1-weightTo) * swapFee) / (1 - (1-weightTo) * swapFee)
    */
    function calcFracPoolFeesFromPoolExit(
        address tokenOut,
        uint tokenAmountOutAfterFees
    )
        public
        view
        returns (uint fracPoolFeesTrade)
    {
        uint balT = _records[tokenOut].balance;
        uint denorm = _records[tokenOut].denorm;
        uint weight = bdiv(denorm, _totalWeight);       // norm weight for tokenOut
        
        // fee size in terms of tokenOut
        uint fracTokenOutTradedTimesFee = bmul(bsub(BONE, weight), _swapFee);   // gas savings
        uint feeAmt = bmul(tokenAmountOutAfterFees, bdiv(fracTokenOutTradedTimesFee, bsub(BONE, fracTokenOutTradedTimesFee)));
        
        fracPoolFeesTrade = bmul(weight, bdiv(feeAmt, balT));
        
        // uint fracPoolFeesPrev = _fracPoolFees;
        // uint dilutionFactor = bsub(BONE, fracPoolFeesTrade);
        // uint fracPoolFeesCurr = badd(bmul(fracPoolFeesPrev, dilutionFactor), fracPoolFeesTrade);
        // _fracPoolFees = fracPoolFeesCurr;

        return fracPoolFeesTrade;
    }


    /* 
        Update the fraction of pool fees based on previous trade
        See above function comment for explanation
    */
    function _updateFracPoolFees(
        uint fracPoolFeesTrade
    )
        internal
    {
        uint fracPoolFeesPrev = _fracPoolFees;
        uint dilutionFactor = bsub(BONE, fracPoolFeesTrade);
        uint fracPoolFeesCurr = badd(bmul(fracPoolFeesPrev, dilutionFactor), fracPoolFeesTrade);
        _fracPoolFees = fracPoolFeesCurr;
    }
    
    // External wrapper function to be called by ConfigurableRightsPool owner
    function updateFracPoolFees(
        uint fracPoolFeesTrade
    )
        external
        _logs_
        _lock_
    {
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        _updateFracPoolFees(fracPoolFeesTrade);
    }


    /* 
        Reset the running fraction of the pool attributable to accumulated fees
        Must be called any time fees are distributed externally
    */
    function resetFracPoolFees()
        external
        _logs_
        _lock_
    {
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        _fracPoolFees = 0;
    }


    // ==
    // 'Underlying' token-manipulation functions make external calls but are NOT locked
    // You must `_lock_` or otherwise ensure reentry-safety

    function _pullUnderlying(address erc20, address from, uint amount)
        internal
    {
        IERC20(erc20).safeTransferFrom(from, address(this), amount);
        // bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        // require(xfer, "ERR_ERC20_FALSE");
    }

    function _pushUnderlying(address erc20, address to, uint amount)
        internal
    {
        IERC20(erc20).safeTransfer(to, amount);
        // bool xfer = IERC20(erc20).transfer(to, amount);
        // require(xfer, "ERR_ERC20_FALSE");
    }

    function _pullPoolShare(address from, uint amount)
        internal
    {
        _pull(from, amount);
    }

    function _pushPoolShare(address to, uint amount)
        internal
    {
        _push(to, amount);
    }

    function _mintPoolShare(uint amount)
        internal
    {
        _mint(amount);
    }

    function _burnPoolShare(uint amount)
        internal
    {
        _burn(amount);
    }

}

// File: contracts\test\BFactory.sol


pragma solidity ^0.6.6;

// Builds new BPools, logging their addresses and providing `isBPool(address) -> (bool)`


// Core contract; can't be changed. So disable solhint (reminder for v2)

/* solhint-disable func-order */
/* solhint-disable event-name-camelcase */

contract BFactory is BBronze {
    event LOG_NEW_POOL(
        address indexed caller,
        address indexed pool
    );

    event LOG_BLABS(
        address indexed caller,
        address indexed blabs
    );

    mapping(address=>bool) private _isBPool;

    function isBPool(address b)
        external view returns (bool)
    {
        return _isBPool[b];
    }

    function newBPool()
        external
        returns (BPool)
    {
        BPool bpool = new BPool();
        _isBPool[address(bpool)] = true;
        emit LOG_NEW_POOL(msg.sender, address(bpool));
        bpool.setController(msg.sender);
        return bpool;
    }

    address private _blabs;

    constructor() public {
        _blabs = msg.sender;
    }

    function getBLabs()
        external view
        returns (address)
    {
        return _blabs;
    }

    function setBLabs(address b)
        external
    {
        require(msg.sender == _blabs, "ERR_NOT_BLABS");
        emit LOG_BLABS(msg.sender, b);
        _blabs = b;
    }

    function collect(BPool pool)
        external 
    {
        require(msg.sender == _blabs, "ERR_NOT_BLABS");
        uint collected = IERC20(pool).balanceOf(address(this));
        bool xfer = pool.transfer(_blabs, collected);
        require(xfer, "ERR_ERC20_FAILED");
    }
}