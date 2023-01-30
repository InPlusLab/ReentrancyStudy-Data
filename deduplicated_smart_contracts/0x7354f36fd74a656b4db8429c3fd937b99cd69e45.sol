pragma solidity ^0.6.2;



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

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}


interface IStaking {

    function getFrozenFrom() external view returns (uint256);

    function getFrozenUntil() external view returns (uint256);

    function getDripPerBlock() external view returns (uint256);

    function getTotalDeposited() external view returns (uint256);

    function getTokenToStake() external view returns (address);

    function getIssuingToken() external view returns (address);

    function getUserDeposit(address user) external view returns (uint256);

    function initializeNewRound(uint256 frozenFrom, uint256 frozenUntil, uint256 drip) external returns (bool);

    function deposit(uint256 amount) external returns (bool);

    function withdrawAndRedeem(uint256 amount) external returns (bool);

    function redeem() external returns (bool);

    function accumulated(address account) external view returns (uint256);
}

contract Staking is IStaking, Ownable, ReentrancyGuard  {
    //using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address internal tokenToStake;
    address internal issuingToken;
    uint256 internal frozenFrom;
    uint256 internal frozenUntil;
    uint256 internal dripPerBlock;
    uint256 internal totalDeposited;
    uint256 internal totalDepositedDynamic;
    mapping(address => uint256) internal deposited;
    mapping(address => uint256) internal latestRedeem;

    event Deposited(address account, uint256 amount);
    event WithdrawnAndRedeemed(address acount, uint256 amount, uint256 issued);
    event Redeemed(address account, uint256 amount);

    constructor(
        address stakedToken,
        address issuedToken
    ) public {
        tokenToStake  = stakedToken;
        issuingToken = issuedToken;
    }

    /**
    *
    */
    function getFrozenFrom() external view override returns (uint256) {
        return frozenFrom;
    }

    /**
    *
    */
    function getFrozenUntil() external view override returns (uint256) {
        return frozenUntil;
    }

    /**
    *
    */
    function getDripPerBlock() external view override returns (uint256) {
        return dripPerBlock;
    }

    /**
    *
    */
    function getTotalDeposited() external view override returns (uint256) {
        return totalDepositedDynamic;
    }

    /**
    *
    */
    function getTokenToStake() external view override returns (address) {
        return tokenToStake;
    }

    /**
    *
    */
    function getIssuingToken() external view override returns (address) {
        return issuingToken;
    }

    /**
    *
    */
    function getUserDeposit(address user) external view override returns (uint256) {
        return deposited[user];
    }

    /**
    *
    */
    function setTimeWindow(uint256 from, uint256 to) internal returns (bool) {
        require(from > block.number, "'from' too small");
        require(to > block.number, "'to' too small");
        require(from < to, "'from' is larger than 'to'");
        frozenFrom = from;
        frozenUntil = to;
        return true;
    }

    /**
    *
    */
    function setDripRate(uint256 drip) internal returns (bool) {
        dripPerBlock = drip;
        return true;
    }

    /**
    *
    */
    function initializeNewRound(
        uint256 _frozenFrom,
        uint256 _frozenUntil,
        uint256 drip) external onlyOwner override returns (bool) {
        setTimeWindow(_frozenFrom, _frozenUntil);
        dripPerBlock = drip;
        return true;
    }

    /**
    *
    */
    function deposit(uint256 amount) external override nonReentrant returns (bool) {
        require(block.number < frozenFrom, "deposits not allowed");
        deposited[msg.sender] = deposited[msg.sender].add(amount);
        totalDeposited = totalDeposited.add(amount);
        totalDepositedDynamic = totalDepositedDynamic.add(amount);
        latestRedeem[msg.sender] = frozenFrom;
        emit Deposited(msg.sender, amount);
        require(IERC20(tokenToStake).transferFrom(msg.sender, address(this), amount),"deposit() failed.");
        return true;
    }

    /**
    *
    */
    function withdrawAndRedeem(uint256 amount) external override nonReentrant returns (bool) {
        require(deposited[msg.sender] >= amount, "deposit too small");
        if(block.number < frozenFrom){
            deposited[msg.sender] = deposited[msg.sender].sub(amount);
            totalDeposited = totalDeposited.sub(amount);
            totalDepositedDynamic = totalDepositedDynamic.sub(amount);
            require(IERC20(tokenToStake).transfer(msg.sender, amount),"withdrawAndRedeem() failed.");
        } else {
            require(block.number >= frozenUntil, "withdraws not allowed");
            uint256 accumulated = accumulated(msg.sender);
            deposited[msg.sender] = deposited[msg.sender].sub(amount);
            emit WithdrawnAndRedeemed(msg.sender, amount, accumulated);
            totalDepositedDynamic = totalDepositedDynamic.sub(amount);
            require(_redeem(msg.sender, accumulated), "Failed to redeem tokens");
            require(IERC20(tokenToStake).transfer(msg.sender, amount),"withdrawAndRedeem() failed.");
        }
        return true;
    }

    /**
    *
    */
    function redeem() external override nonReentrant returns (bool) {
        uint256 accumulated = accumulated(msg.sender);
        Redeemed(msg.sender, accumulated);
        return _redeem(msg.sender, accumulated);
    }

    /**
    *
    */
    function _redeem(address account, uint256 amount) internal returns (bool) {
        if (block.number >= frozenUntil) {
            latestRedeem[account] = frozenUntil;
        } else {
            if(block.number > frozenFrom){
                latestRedeem[account] = block.number;
            } else {
                latestRedeem[account] = frozenFrom;
            }
        }
        if(amount > 0) {
            IERC20(issuingToken).transfer(account, amount);
        }
        return true;
    }

    /**
    *
    */
    function accumulated(address account) public view override returns (uint256) {
        if(deposited[account] == 0) {
            return 0;
        }
        if(block.number > frozenFrom) {
            if(block.number <= frozenUntil) {
                return deposited[account].mul(
                    dripPerBlock.mul(
                        block.number.sub(
                            latestRedeem[account]
                        )
                    )
                ).div(totalDeposited);
            } else {
                return deposited[account].mul(
                    dripPerBlock.mul(
                        frozenUntil.sub(
                            latestRedeem[account]
                        )
                    )
                ).div(totalDeposited);
            }
        } else {
            return 0;
        }
    }


}