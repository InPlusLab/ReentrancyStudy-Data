/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity 0.5.7;

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
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
contract IERC20 {
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
@notice contract for staking
 */
contract ApologiaStaking is Ownable {
    using SafeMath for uint256;

    IERC20 public token;

    /**
    @notice Vote struct */
    struct Vote {
        uint256 tokenAmount;
        uint256 ETHAmount;
        address voter;
        uint8 personalityVoted;
        uint256[] txsTimeToken;
        uint256[] txsTimeETH;
        uint256[] stakesToken;
        uint256[] stakesETH;
        // uint256 stakesCount;
        uint256 unstakedTimestamp;
        bool withdrawn;
    }

    mapping(address => Vote) private votes;                // mapping from voter to Vote struct
    address[] public voters;

    uint256 public totalStakesCount;             // total count of stakes
    uint256 public totalStakedAmountToken;
    uint256 public totalStakedAmountETH;

    uint256 public stakeTimeStart;
    uint256 public stakeTimeStop;

    uint256 public minimumStakingAmountWEI;
    uint256 public minimumStakingAmountToken;

    bool public contractState;

    event ContractInitialized(
        uint stakeTimeStart,
        uint stakeTimeStop
    );

    constructor(
        address _token,
        uint _minStakingAmountToken,
        uint _minStakingAmountETH
    ) public {
        token = IERC20(_token);
        setMinimumStakingAmountToken(_minStakingAmountToken);
        setMinimumStakingAmountETH(_minStakingAmountETH);
    }

    function init(
        uint startTime,
        uint stopTime
    )
    public
    onlyOwner {
        require(
            !contractState,
            "contract is already initialized"
        );

        require(
            startTime > now,
            "start time cannot be set in the past"
        );

        require(
            stopTime > startTime,
            "stop time should be greater than stop time"
        );

        stakeTimeStart = startTime;
        stakeTimeStop = stopTime;

        contractState = true;

        emit ContractInitialized(
            stakeTimeStart,
            stakeTimeStop
        );
    }

    function setMinimumStakingAmountToken(uint _amount)
    public
    onlyOwner {
        minimumStakingAmountToken = _amount;
    }

    function setMinimumStakingAmountETH(uint _amount)
    public
    onlyOwner {
        minimumStakingAmountWEI = _amount;
    }

    event Staked(address user, uint256 amountToken, uint256 amountWEI, uint256 option);

    function stake(uint8 personality, uint tokensAmount, uint256 option)
    public
    payable {

        require(option == 1 || option == 2 || option == 3,
            "option provided is not valid"
        );

        require(
            contractState == true
        && now <= stakeTimeStop
        && now >= stakeTimeStart,
            "cannot stake"
        );

        require(
            personality == 1
            || personality == 2,
            "personality can be either 1 or 2"
        );

        Vote storage _vote = votes[msg.sender];

        if (
            _vote.ETHAmount > 0
            || _vote.tokenAmount > 0
        ) {
            require(
                _vote.personalityVoted == personality,
                "You cannot raise stake on a different personality"
            );
        }

        if (
            _vote.ETHAmount == 0
            && _vote.tokenAmount == 0
        ) {
            addVoter(msg.sender);
            // create a new stake entity
            uint256[] memory txs = new uint256[](0);
            uint256[] memory stx = new uint256[](0);

            Vote memory newVote = Vote(
                0,
                0,
                msg.sender,
                0,
                txs,
                txs,
                stx,
                stx,
                0,
                false
            );

            votes[msg.sender] = newVote;
            votes[msg.sender].personalityVoted = personality;
        }

        uint256 ethAmount = msg.value;

        // only deposing ether/WEI
        if (option == 1) {
            require(
                ethAmount >= minimumStakingAmountWEI,
                "ETH amountt must be greater than or equal to minimumStakingAmount"
            );

            _vote.ETHAmount = _vote.ETHAmount.add(ethAmount);
            _vote.stakesETH.push(ethAmount);
            _vote.txsTimeETH.push(now);

            _vote.stakesToken.push(0);
            _vote.txsTimeToken.push(0);

        }

        // only depositing tokens
        if (option == 2) {
            require(
                tokensAmount >= minimumStakingAmountToken,
                "tokens must be greater than or equal to minimumStakingAmount"
            );

            _vote.tokenAmount = _vote.tokenAmount.add(tokensAmount);
            _vote.stakesToken.push(tokensAmount);
            _vote.txsTimeToken.push(now);

            _vote.stakesETH.push(0);
            _vote.txsTimeETH.push(0);

            bool success = token.transferFrom(
                msg.sender,
                address(this),
                tokensAmount
            );

            require(
                success,
                "failed in transferFrom of stakeTokens"
            );

        }

        // depositing tokens and eth both
        if (option == 3) {
            require(
                ethAmount >= minimumStakingAmountWEI,
                "ETH amountt must be greater than or equal to minimumStakingAmount"
            );

            _vote.ETHAmount = _vote.ETHAmount.add(ethAmount);
            _vote.stakesETH.push(ethAmount);
            _vote.txsTimeETH.push(now);

            require(
                tokensAmount >= minimumStakingAmountToken,
                "tokens must be greater than or equal to minimumStakingAmount"
            );

            _vote.tokenAmount = _vote.tokenAmount.add(tokensAmount);
            _vote.stakesToken.push(tokensAmount);
            _vote.txsTimeToken.push(now);

            bool success = token.transferFrom(
                msg.sender,
                address(this),
                tokensAmount
            );

            require(
                success,
                "failed in transferFrom of stakeTokens"
            );

        }


        totalStakedAmountETH = totalStakedAmountETH.add(ethAmount);
        totalStakedAmountToken = totalStakedAmountToken.add(tokensAmount);

        emit Staked(msg.sender, tokensAmount, msg.value, option);

    }

    /**
    @notice fired when tokens are unstaked by the voter
     */
    event TokensUnstaked(
        address voter,
        uint256 amountToken,
        uint256 amountETH
    );

    /**
    @notice this is function is called by the voter to unstake tokens
     */
    function unstake() public {
        require(
            contractState == true
        && now >= stakeTimeStart,
            "cannot unstake"
        );

        Vote storage _vote = votes[msg.sender];

        require(
            _vote.txsTimeETH.length > 0
            || _vote.txsTimeToken.length > 0,
            "No stake found by the user"
        );

        require(
            !_vote.withdrawn,
            "Stake is already withdrawn"
        );

        uint256 withdrawAmountToken = _vote.tokenAmount;
        uint256 withdrawAmountETH = _vote.ETHAmount;

        _vote.withdrawn = true;
        _vote.unstakedTimestamp = now;

        bool success = token.transfer(
            msg.sender,
            withdrawAmountToken
        );

        require(
            success,
            "transfer failed in withdraw"
        );

        msg.sender.transfer(withdrawAmountETH);

        emit TokensUnstaked(
            msg.sender,
            withdrawAmountToken,
            withdrawAmountETH
        );
    }

    function getStakeInfo(address _voter)
    public
    view
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint8 personality,
        uint256[] memory txsTimeToken,
        uint256[] memory txsTimeETH,
        uint256[] memory stakesToken,
        uint256[] memory stakesETH,
        uint256 unstakedTimestamp,
        bool withdrawn
    ) {
        Vote memory vote = votes[_voter];

        amountToken = vote.tokenAmount;
        amountETH = vote.ETHAmount;
        personality = vote.personalityVoted;
        withdrawn = vote.withdrawn;
        unstakedTimestamp = vote.unstakedTimestamp;
        txsTimeToken = vote.txsTimeToken;
        txsTimeETH = vote.txsTimeETH;
        stakesToken = vote.stakesToken;
        stakesETH = vote.stakesETH;
    }

    function getAllVoters()
    public
    view
    returns (address[] memory allVoters) {
        allVoters = voters;
    }

    function getTokenStakeAmountByPersonalityId(uint personalityId)
    public
    view
    returns (uint256 amount) {
        for (uint i = 0; i < voters.length; i++) {
            Vote memory v = votes[voters[i]];
            if (v.personalityVoted == personalityId) {
                amount = amount.add(v.tokenAmount);
            }
        }
    }

    function getETHStakeAmountByPersonalityId(uint personalityId)
    public
    view
    returns (uint256 amount) {
        for (uint i = 0; i < voters.length; i++) {
            Vote memory v = votes[voters[i]];
            if (v.personalityVoted == personalityId) {
                amount = amount.add(v.ETHAmount);
            }
        }
    }

    function isContractActive()
    public
    view
    returns (bool) {
        return now >= stakeTimeStart && now <= stakeTimeStop;
    }

    function isVoter(address _address)
    internal
    view
    returns (bool, uint256)
    {
        for (uint256 i = 0; i < voters.length; i++) {
            if (_address == voters[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function addVoter(address _voter)
    internal
    {
        (bool _isVoter,) = isVoter(_voter);
        if (!_isVoter) {
            voters.push(_voter);

        }

    }

}