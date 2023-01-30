/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

/**
__                  _    _
/ _\_ __   __ _ _ __| | _| | ___
\ \| '_ \ / _` | '__| |/ / |/ _ \
_\ \ |_) | (_| | |  |   <| |  __/
\__/ .__/ \__,_|_|  |_|\_\_|\___|
  |_|


Sparkle is the world's first redistributive currency.

Sparkle! offers an alternative to economies based on income inequality by
creating a currency that proportionally redistributes two percent of every
transaction to each person in the economy.

Put simply: When the rich spend, the poor receive a share.

Sparkle is minted via an anti-speculative system whereby the smart contract
maintains a stable buy price of 1 ETH = 9700 SPRK and sell price of
10000 SPRK = .97 ETH until 400,000,000 SPRK have been minted.

Once 400 million Sparkle are in circulation, the buy function of this contract
is disabled and no more SPRK will be minted until supply drops below the
threshold. The sell function remains active to preserve a minimum value of
10,000 SPRK equals .97 ETH.

Everyone can mint Sparkle! by sending ETH to this contract.

Everyone can earn ETH by selling Sparkle! to this contract.

Everyone starts with free Sparkle!: by entering into the economy of Sparkle!
you will automatically receive your share of the transaction taxes collected.

Sparkle! is an activist experiment created by Micah White and released on
September 17, 2019 to commemorate the eighth anniversary of Occupy Wall Street.

SPARKLE! IS:

• Autonomous — Sparkle! has no kill switch or pause function.

• Adversarial — Sparkle! is an act of protest that offers an alternative.

• Experimental — Sparkle! tests new economic laws that could form the basis for
                 an activist society.

• Anti-speculative — Sparkle! fights currency speculation and is backed by a
                      verifiable reserve of ETH that guarantees as a
                      minimum value.

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

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    event SparkleRedistribution(address from, uint amount);
    event Mint(address to, uint amount);
    event Sell(address from, uint amount);

    uint256 public constant MAX_SUPPLY = 400000000 * 10 ** 18; // 40000 ETH of Sparkle
    uint256 public constant PERCENT = 100; // 100%
    uint256 public constant TAX = 2; // 2%
    uint256 public constant COST_PER_TOKEN = 1e14; // 1 Sparkle = .0001 ETH
    address payable creator = 0x4C3cC1D2229CBD17D26ec984F2E1b9bD336cBf69;

    uint256 private _tobinsCollected;
    uint256 private _totalSupply;
    mapping (address => uint256) private _tobinsClaimed; // Internal accounting

    constructor() public ERC20Detailed("Sparkle!", "SPRK", 18) {}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function tobinsCollected() public view returns (uint256) {
        return _tobinsCollected;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (_totalSupply == 0) return 0;

        uint256 unclaimed = _tobinsCollected.sub(_tobinsClaimed[owner]);
        uint256 floatingSupply = _totalSupply.sub(_tobinsCollected);
        uint256 redistribution = _balances[owner].mul(unclaimed).div(floatingSupply);

        return _balances[owner].add(redistribution);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0));

        uint256 taxAmount = value.mul(TAX).div(PERCENT);

        _balances[msg.sender] = balanceOf(msg.sender).sub(value).sub(taxAmount);
        _balances[to] = balanceOf(to).add(value);

        _tobinsClaimed[msg.sender] = _tobinsCollected;
        _tobinsClaimed[to] = _tobinsCollected;
        _tobinsCollected = _tobinsCollected.add(taxAmount);

        emit Transfer(msg.sender, to, value);
        emit SparkleRedistribution(msg.sender, taxAmount);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        uint256 taxAmount = value.mul(TAX).div(PERCENT);

        _balances[from] = balanceOf(from).sub(value).sub(taxAmount);
        _balances[to] = balanceOf(to).add(value);

        _tobinsClaimed[from] = _tobinsCollected;
        _tobinsClaimed[to] = _tobinsCollected;
        _tobinsCollected = _tobinsCollected.add(taxAmount);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);
        emit SparkleRedistribution(from, taxAmount);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function () external payable {
        mintSparkle();
    }

    function mintSparkle() public payable returns (bool) {
        uint256 amount = msg.value.mul(10 ** 18).div(COST_PER_TOKEN);
        require(_totalSupply.add(amount) <= MAX_SUPPLY);

        uint256 taxAmount = amount.mul(TAX).div(PERCENT);
        uint256 creatorAmount = amount.mul(1).div(PERCENT);
        uint256 buyerAmount = amount.sub(taxAmount).sub(creatorAmount);

        _balances[msg.sender] = balanceOf(msg.sender).add(buyerAmount);
        _balances[creator]= balanceOf(creator).add(creatorAmount);

        _totalSupply = _totalSupply.add(amount);

        _tobinsClaimed[msg.sender] = _tobinsCollected;
        _tobinsClaimed[creator] = _tobinsCollected;
        _tobinsCollected = _tobinsCollected.add(taxAmount);

        emit Mint(msg.sender, buyerAmount);
        emit SparkleRedistribution(msg.sender, taxAmount);

        return true;
    }

    function sellSparkle(uint256 amount) public returns (bool) {
        require(amount > 0 && balanceOf(msg.sender) >= amount);

        uint256 reward = amount.mul(COST_PER_TOKEN).div(10 ** 18);

        uint256 creatorAmount = reward.mul(3).div(PERCENT);
        uint256 sellerAmount = reward.sub(creatorAmount);

        _balances[msg.sender] = balanceOf(msg.sender).sub(amount);
        _tobinsClaimed[msg.sender] = _tobinsCollected;

        _totalSupply = _totalSupply.sub(amount);

        creator.transfer(creatorAmount);
        msg.sender.transfer(sellerAmount);

        emit Sell(msg.sender, amount);

        return true;
    }


}