//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./matic/BasicMetaTransaction.sol";
import "./interfaces/IMogulSmartWallet.sol";
import "./interfaces/IMovieVotingMasterChef.sol";
import "./utils/Sqrt.sol";

contract MovieVoting is BasicMetaTransaction, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    // The Stars token.
    IERC20 public stars;
    // The movie NFT.
    IERC1155 public mglMovie;
    // The staking contrract.
    IMovieVotingMasterChef movieVotingMasterChef;
    // Max amount of movies per round
    uint256 public constant MAX_MOVIES = 5;

    enum VotingRoundState { Active, Paused, Canceled, Executed }

    struct VotingRound {
        // list of movies available to vote on.
        // The list must be filled left to right, leaving empty slots as 0.
        uint256[MAX_MOVIES] movieIds;
        // voting starts on this block.
        uint256 startVoteBlockNum;
        // voting ends at this block.
        uint256 endVoteBlockNum;
        // total Stars rewards for the round.
        uint256 starsRewards;
        VotingRoundState votingRoundState;
        // mapping variables: movieId
        mapping(uint256 => uint256) votes;
        // mapping variables: userAddress
        mapping(address => bool) rewardsClaimed;
        // mapping variables: userAddress, movieId
        mapping(address => mapping(uint256 => uint256)) totalStarsEntered;
    }

    VotingRound[] public votingRounds;

    event VotingRoundCreated(
        uint256[MAX_MOVIES] movieIds,
        uint256 startVoteBlockNum,
        uint256 endVoteBlockNum,
        uint256 starsRewards,
        uint256 votingRound
    );
    event VotingRoundPaused(uint256 roundId);
    event VotingRoundUnpaused(uint256 roundId);
    event VotingRoundCanceled(uint256 roundId);
    event VotingRoundExecuted(uint256 roundId);

    event Voted(
        address voter,
        uint256 roundId,
        uint256 movieId,
        uint256 starsAmountMantissa,
        uint256 quadraticVoteScore
    );
    event Unvoted(
        address voter,
        uint256 roundId,
        uint256 movieId,
        uint256 starsAmountMantissa,
        uint256 quadraticVoteScore
    );

    modifier onlyAdmin {
        require(hasRole(ROLE_ADMIN, msgSender()), "Sender is not admin");
        _;
    }

    modifier votingRoundMustExist(uint256 roundId) {
        require(
            roundId < votingRounds.length,
            "Voting Round id does not exist yet"
        );
        _;
    }

    /**
     * @dev Sets the admin role and records the stars, movie nft
     * and staking contract addresses. Also approves Stars
     * for the staking contract.
     *
     * Parameters:
     *
     * - _admin: admin of the smart wallet.
     * - _stars: Stars token address.
     * - _mglMovie: Movie NFT address.
     * - _movieVotingMasterChef: staking contract address.
     *
     */
    constructor(
        address _admin,
        address _stars,
        address _mglMovie,
        address _movieVotingMasterChef
    ) public {
        _setupRole(ROLE_ADMIN, _admin);
        _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);

        stars = IERC20(_stars);
        mglMovie = IERC1155(_mglMovie);
        movieVotingMasterChef = IMovieVotingMasterChef(_movieVotingMasterChef);
        // Note: uint256(-1) is max number
        stars.approve(_movieVotingMasterChef, uint256(-1));
    }

    /**
     * @dev Returns all movie NFT ids of the voting round.
     * id 0 represents empty slot.
     *
     * Parameters:
     *
     * - votingRoundId: id of the voting round.
     */
    function getMovieIds(uint256 votingRoundId)
        external
        view
        returns (uint256[MAX_MOVIES] memory)
    {
        return votingRounds[votingRoundId].movieIds;
    }

    /**
     * @dev Returns all movie NFT votes of the voting round.
     *
     * Parameters:
     *
     * - votingRoundId: voting round id.
     */
    function getMovieVotes(uint256 votingRoundId)
        external
        view
        returns (uint256[MAX_MOVIES] memory)
    {
        VotingRound storage votingRound = votingRounds[votingRoundId];
        uint256[MAX_MOVIES] memory votes;
        for (uint256 i; i < MAX_MOVIES; i++) {
            votes[i] = (votingRound.votes[votingRound.movieIds[i]]);
        }
        return votes;
    }

    /**
     * @dev Returns the details of the voting round.
     *
     * Parameters:
     *
     * - votingRoundId: voting round id.
     */
    function getVotingRound(uint256 votingRoundId)
        external
        view
        returns (
            uint256[MAX_MOVIES] memory,
            uint256[MAX_MOVIES] memory,
            uint256,
            uint256,
            uint256,
            VotingRoundState
        )
    {
        VotingRound storage votingRound = votingRounds[votingRoundId];
        uint256[MAX_MOVIES] memory movieIds = votingRound.movieIds;
        uint256[MAX_MOVIES] memory votes;

        for (uint256 i; i < MAX_MOVIES; i++) {
            votes[i] = (votingRound.votes[votingRound.movieIds[i]]);
        }
        return (
            movieIds,
            votes,
            votingRound.startVoteBlockNum,
            votingRound.endVoteBlockNum,
            votingRound.starsRewards,
            votingRound.votingRoundState
        );
    }

    /**
     * @dev Returns the total stars entered by a user.
     *
     * Parameters:
     *
     * - userAddress: user's address.
     * - movieId: movie round id.
     * - votingRoundId: voting round id.
     */
    function getUserMovieTotalStarsEntered(
        address userAddress,
        uint256 movieId,
        uint256 votingRoundId
    ) external view returns (uint256) {
        uint256 userMovieTotalStarsEntered =
            votingRounds[votingRoundId].totalStarsEntered[userAddress][movieId];
        return userMovieTotalStarsEntered;
    }

    /**
     * @dev Returns if user has already claimed their Stars rewards.
     *
     * Parameters:
     *
     * - userAddress: user's address.
     * - votingRoundId: voting round id.
     */
    function didUserClaimRewards(address userAddress, uint256 votingRoundId)
        external
        view
        returns (bool)
    {
        bool _didUserClaimRewards =
            votingRounds[votingRoundId].rewardsClaimed[userAddress];
        return _didUserClaimRewards;
    }

    /**
     * @dev Creates a new movie voting round.
     *
     * Parameters:
     *
     * - movieIds: list of movie ids, filled from left to right.
     * Id 0 represents empty slot.
     * - startVoteBlockNum: the block voting will start on.
     * - endVoteBlockNum: the block voting will end on.
     * - starsRewards: the total Stars rewards to distribute to voters.
     *
     * Requirements:
     *
     * - Start Vote Block must be less than End Vote Block.
     * - Caller must be an admin.
     */
    function createNewVotingRound(
        uint256[MAX_MOVIES] calldata movieIds,
        uint256 startVoteBlockNum,
        uint256 endVoteBlockNum,
        uint256 starsRewards
    ) external onlyAdmin {
        require(
            startVoteBlockNum < endVoteBlockNum,
            "Start block must be less than end block"
        );

        VotingRound memory votingRound;
        votingRound.movieIds = movieIds;
        votingRound.startVoteBlockNum = startVoteBlockNum;
        votingRound.endVoteBlockNum = endVoteBlockNum;
        votingRound.starsRewards = starsRewards;
        votingRound.votingRoundState = VotingRoundState.Active;

        votingRounds.push(votingRound);

        stars.transferFrom(msgSender(), address(this), starsRewards);

        // transfer stars for rewards
        movieVotingMasterChef.add(
            startVoteBlockNum,
            endVoteBlockNum,
            starsRewards,
            false
        );

        emit VotingRoundCreated(
            movieIds,
            startVoteBlockNum,
            endVoteBlockNum,
            starsRewards,
            votingRounds.length
        );
    }

    /**
     * @dev Pause a movie voting round.
     *
     * Parameters:
     *
     * - roundId: Voting round id.
     *
     * Requirements:
     *
     * - Caller must be an admin.
     * - Voting round must exist.
     * - Voting round must be active.
     * - Voting round has not ended.
     */
    function pauseVotingRound(uint256 roundId)
        external
        onlyAdmin
        votingRoundMustExist(roundId)
    {
        VotingRound storage votingRound = votingRounds[roundId];

        require(
            votingRound.votingRoundState == VotingRoundState.Active,
            "Only active voting rounds can be paused"
        );
        require(
            votingRound.endVoteBlockNum >= block.number,
            "Voting Round has already concluded"
        );
        votingRound.votingRoundState = VotingRoundState.Paused;

        emit VotingRoundPaused(roundId);
    }

    /**
     * @dev Unpause a movie voting round.
     *
     * Parameters:
     *
     * - roundId: Voting round id.
     *
     * Requirements:
     *
     * - Caller must be an admin.
     * - Voting round must exist.
     * - Voting round must be paused.
     */
    function unpauseVotingRound(uint256 roundId)
        external
        onlyAdmin
        votingRoundMustExist(roundId)
    {
        VotingRound storage votingRound = votingRounds[roundId];

        require(
            votingRound.votingRoundState == VotingRoundState.Paused,
            "Only paused voting rounds can be unpaused"
        );
        votingRound.votingRoundState = VotingRoundState.Active;

        emit VotingRoundUnpaused(roundId);
    }

    /**
     * @dev Cancel a movie voting round.
     *
     * Parameters:
     *
     * - roundId: Voting round id.
     *
     * Requirements:
     *
     * - Caller must be an admin.
     * - Voting round must exist.
     * - Voting round must be active or paused.
     */
    function cancelVotingRound(uint256 roundId)
        external
        onlyAdmin
        votingRoundMustExist(roundId)
    {
        VotingRound storage votingRound = votingRounds[roundId];

        require(
            votingRound.votingRoundState == VotingRoundState.Active ||
                votingRound.votingRoundState == VotingRoundState.Paused,
            "Only active or paused voting rounds can be cancelled"
        );
        require(
            block.number <= votingRound.endVoteBlockNum,
            "Voting Round has already concluded"
        );
        votingRound.votingRoundState = VotingRoundState.Canceled;

        emit VotingRoundCanceled(roundId);
    }

    /**
     * @dev Execute a movie voting round.
     *
     * Parameters:
     *
     * - roundId: Voting round id.
     *
     * Requirements:
     *
     * - Caller must be an admin.
     * - Voting round must exist.
     * - Voting round must be active.
     * - Voting round has not ended.
     */
    function executeVotingRound(uint256 roundId)
        external
        onlyAdmin
        votingRoundMustExist(roundId)
    {
        VotingRound storage votingRound = votingRounds[roundId];

        require(
            votingRound.votingRoundState == VotingRoundState.Active,
            "Only active voting rounds can be executed"
        );
        require(
            votingRound.endVoteBlockNum < block.number,
            "Voting round has not ended"
        );
        votingRound.votingRoundState = VotingRoundState.Executed;

        emit VotingRoundExecuted(roundId);
    }

    /**
     * @dev Returns the total amount of voting rounds
     * that have been created.
     *
     */
    function totalVotingRounds() external view returns (uint256) {
        return votingRounds.length;
    }

    /**
     * @dev Checks if the caller is the owner of the Mogul Smart Wallet and return its address.
     * Return the caller's addres if it is declared smart wallet is not used.
     *
     * Parameters:
     *
     * - isMogulSmartWallet: Whether or not smart wallet is used.
     * - mogulSmartWallet: address of the smart wallet, Zero address is passed if not used.
     * - msgSender: address of the caller.
     *
     */
    function _verifySmartWalletOwner(
        bool isMogulSmartWallet,
        address mogulSmartWallet,
        address msgSender
    ) internal returns (address) {
        if (isMogulSmartWallet) {
            require(
                msgSender == IMogulSmartWallet(mogulSmartWallet).owner(),
                "Invalid Mogul Smart Wallet Owner"
            );
            return mogulSmartWallet;
        } else {
            return msgSender;
        }
    }

    /**
     * @dev Vote for a movie by staking Stars.
     *
     * Parameters:
     *
     * - roundId: voting round id.
     * - movieId: movie id to vote for.
     * - starsAmountMantissa: total Stars to stake.
     * - isMogulSmartWallet: Whether or not smart wallet is used.
     * - mogulSmartWallet: address of the smart wallet, Zero address is passed if not used.
     *
     * Requirements:
     *
     * - Voting round id must exists.
     * - Must deposit at least 1 Stars token.
     * - Movie Id must be in voting round.
     * - Voting round must be active.
     * - Voting round must be started and has not ended.
     */
    function voteForMovie(
        uint256 roundId,
        uint256 movieId,
        uint256 starsAmountMantissa,
        bool isMogulSmartWallet,
        address mogulSmartWalletAddress
    ) external votingRoundMustExist(roundId) {
        require(
            starsAmountMantissa >= 1 ether,
            "Must deposit at least 1 Stars token"
        );

        address _msgSender =
            _verifySmartWalletOwner(
                isMogulSmartWallet,
                mogulSmartWalletAddress,
                msgSender()
            );

        VotingRound storage votingRound = votingRounds[roundId];

        uint256[MAX_MOVIES] memory movieIds = votingRound.movieIds;
        require(
            movieId != 0 &&
                (movieId == movieIds[0] ||
                    movieId == movieIds[1] ||
                    movieId == movieIds[2] ||
                    movieId == movieIds[3] ||
                    movieId == movieIds[4]),
            "Movie Id is not in voting round"
        );

        require(
            votingRound.votingRoundState == VotingRoundState.Active,
            "Can only vote in active rounds"
        );

        require(
            votingRound.startVoteBlockNum <= block.number &&
                block.number <= votingRound.endVoteBlockNum,
            "Voting round has not started or has ended"
        );

        uint256 quadraticVoteScoreOld =
            Sqrt.sqrt(
                votingRound.totalStarsEntered[_msgSender][movieId].div(1 ether)
            );

        votingRound.totalStarsEntered[_msgSender][movieId] = votingRound
            .totalStarsEntered[_msgSender][movieId]
            .add(starsAmountMantissa);

        uint256 quadraticVoteScoreNew =
            Sqrt.sqrt(
                votingRound.totalStarsEntered[_msgSender][movieId].div(1 ether)
            );

        votingRound.votes[movieId] = votingRound.votes[movieId]
            .add(quadraticVoteScoreNew)
            .sub(quadraticVoteScoreOld);

        movieVotingMasterChef.deposit(roundId, starsAmountMantissa, _msgSender);

        emit Voted(
            _msgSender,
            roundId,
            movieId,
            starsAmountMantissa,
            quadraticVoteScoreNew
        );
    }

    /**
     * @dev Remove vote for a movie by withdrawing Stars, and forgoing Stars rewards.
     *
     * Parameters:
     *
     * - roundId: voting round id.
     * - movieId: movie id to vote for.
     * - starsAmountMantissa: total Stars to stake.
     * - isMogulSmartWallet: Whether or not smart wallet is used.
     * - mogulSmartWallet: address of the smart wallet, Zero address is passed if not used.
     *
     * Requirements:
     *
     * - Voting round id must exists.
     * - Must withdraw more than 0 Stars token.
     * - Must have enough Stars deposited to withdraw.
     * - Movie Id must be in voting round.
     * - Voting round must be active.
     * - Voting round must be started and has not ended.
     */
    function removeVoteForMovie(
        uint256 roundId,
        uint256 movieId,
        uint256 starsAmountMantissa,
        bool isMogulSmartWallet,
        address mogulSmartWalletAddress
    ) external votingRoundMustExist(roundId) {
        require(starsAmountMantissa > 0, "Cannot remove 0 votes");

        address _msgSender =
            _verifySmartWalletOwner(
                isMogulSmartWallet,
                mogulSmartWalletAddress,
                msgSender()
            );

        VotingRound storage votingRound = votingRounds[roundId];

        uint256[MAX_MOVIES] memory movieIds = votingRound.movieIds;
        require(
            movieId == movieIds[0] ||
                movieId == movieIds[1] ||
                movieId == movieIds[2] ||
                movieId == movieIds[3] ||
                movieId == movieIds[4],
            "Movie Id is not in voting round"
        );
        require(
            starsAmountMantissa <=
                votingRound.totalStarsEntered[_msgSender][movieId],
            "Not enough Stars to remove"
        );
        require(
            votingRound.votingRoundState == VotingRoundState.Active,
            "Can only remove vote in active rounds"
        );

        require(
            votingRound.startVoteBlockNum <= block.number &&
                block.number <= votingRound.endVoteBlockNum,
            "Voting round has not started or ended"
        );

        uint256 oldQuadraticVoteScore =
            Sqrt.sqrt(
                votingRound.totalStarsEntered[_msgSender][movieId].div(1 ether)
            );

        votingRound.totalStarsEntered[_msgSender][movieId] = votingRound
            .totalStarsEntered[_msgSender][movieId]
            .sub(starsAmountMantissa);

        uint256 updatedUserTotalStarsEntered =
            votingRound.totalStarsEntered[_msgSender][movieId];

        movieVotingMasterChef.withdrawPartial(
            roundId,
            starsAmountMantissa,
            _msgSender
        );

        votingRound.votes[movieId] = votingRound.votes[movieId]
            .add(Sqrt.sqrt(updatedUserTotalStarsEntered.div(1 ether)))
            .sub(oldQuadraticVoteScore);

        emit Unvoted(
            _msgSender,
            roundId,
            movieId,
            starsAmountMantissa,
            Sqrt.sqrt(updatedUserTotalStarsEntered.div(1 ether))
        );
    }

    function calculateStarsRewards(address userAddress, uint256 roundId)
        external
        view
        votingRoundMustExist(roundId)
        returns (uint256)
    {
        return movieVotingMasterChef.pendingStars(roundId, userAddress);
    }

    /**
     * @dev Withdraw deposited Stars and claim Stars rewards for a given
     * voting round.
     *
     * Parameters:
     *
     * - roundId: voting round id.
     * - isMogulSmartWallet: Whether or not smart wallet is used.
     * - mogulSmartWallet: address of the smart wallet, Zero address is passed if not used.
     *
     * Requirements:
     *
     * - Rewards has not been claimed.
     */
    function withdrawAndClaimStarsRewards(
        uint256 roundId,
        bool isMogulSmartWallet,
        address mogulSmartWalletAddress
    ) external votingRoundMustExist(roundId) {
        address _msgSender =
            _verifySmartWalletOwner(
                isMogulSmartWallet,
                mogulSmartWalletAddress,
                msgSender()
            );

        VotingRound storage votingRound = votingRounds[roundId];

        require(
            !votingRound.rewardsClaimed[_msgSender],
            "Rewards have already been claimed"
        );

        votingRound.rewardsClaimed[_msgSender] = true;

        movieVotingMasterChef.withdraw(roundId, _msgSender);
    }

    /**
     * @dev Withdraw deposited ETH.
     *
     * Requirements:
     *
     * - Withdrawer must be an admin
     */
    function withdrawETH() external onlyAdmin {
        payable(msgSender()).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

pragma solidity 0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract BasicMetaTransaction {
    using SafeMath for uint256;

    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) private nonces;

    function getChainID() public pure returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * Main function to be called when user wants to execute meta transaction.
     * The actual function to be called should be passed as param with name functionSignature
     * Here the basic signature recovery is being used. Signature is expected to be generated using
     * personal_sign method.
     * @param userAddress Address of user trying to do meta transaction
     * @param functionSignature Signature of the actual function to be called via meta transaction
     * @param sigR R part of the signature
     * @param sigS S part of the signature
     * @param sigV V part of the signature
     */
    function executeMetaTransaction(
        address userAddress,
        bytes calldata functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory) {
        require(
            verify(
                userAddress,
                nonces[userAddress],
                getChainID(),
                functionSignature,
                sigR,
                sigS,
                sigV
            ),
            "Signer and signature do not match"
        );
        nonces[userAddress] = nonces[userAddress].add(1);

        // Append userAddress at the end to extract it from calling context
        (bool success, bytes memory returnData) =
            address(this).call(
                abi.encodePacked(functionSignature, userAddress)
            );

        require(success, "Function call not successful");
        emit MetaTransactionExecuted(
            userAddress,
            msg.sender,
            functionSignature
        );
        return returnData;
    }

    function getNonce(address user) external view returns (uint256 nonce) {
        nonce = nonces[user];
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function verify(
        address owner,
        uint256 nonce,
        uint256 chainID,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public view returns (bool) {
        bytes32 hash =
            prefixed(
                keccak256(
                    abi.encodePacked(nonce, this, chainID, functionSignature)
                )
            );
        address signer = ecrecover(hash, sigV, sigR, sigS);
        require(signer != address(0), "Invalid signature");
        return (owner == signer);
    }

    function msgSender() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            return msg.sender;
        }
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.2;

interface IMogulSmartWallet {
    function owner() external returns (address);

    function initialize(
        address _owner,
        address[] calldata _guardians,
        uint256 _minGuardianVotesRequired,
        uint256 _pausePeriod
    ) external;

    function addGuardians(address[] calldata newGuardians) external;

    function removeGuardians(address[] calldata newGuardians) external;

    function getGuardiansAmount() external view returns (uint256);

    function getAllGuardians() external view returns (address[100] memory);

    function isGuardian(address accountAddress) external view returns (bool);

    function changeOwnerByOwner(address newOwner) external;

    function createChangeOwnerProposal(address newOwner) external;

    function addVoteChangeOwnerProposal() external;

    function removeVoteChangeOwnerProposal() external;

    function changeOwnerByGuardian() external;

    function setMinGuardianVotesRequired(uint256 _minGuardianVotesRequired)
        external;

    function approveERC20(
        address erc20Address,
        address spender,
        uint256 amt
    ) external;

    function transferERC20(
        address erc20Address,
        address recipient,
        uint256 amt
    ) external;

    function transferFromERC20(
        address erc20Address,
        address sender,
        address recipient,
        uint256 amt
    ) external;

    function transferFromERC721(
        address erc721Address,
        address sender,
        address recipient,
        uint256 tokenId
    ) external;

    function safeTransferFromERC721(
        address erc721Address,
        address sender,
        address recipient,
        uint256 tokenId
    ) external;

    function safeTransferFromERC721(
        address erc721Address,
        address sender,
        address recipient,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function approveERC721(
        address erc721Address,
        address spender,
        uint256 tokenId
    ) external;

    function setApprovalForAllERC721(
        address erc721Address,
        address operator,
        bool approved
    ) external;

    function safeTransferFromERC1155(
        address erc1155Address,
        address sender,
        address recipient,
        uint256 tokenId,
        uint256 amt,
        bytes calldata data
    ) external;

    function safeBatchTransferFromERC1155(
        address erc1155Address,
        address sender,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata amts,
        bytes calldata data
    ) external;

    function setApprovalForAllERC1155(
        address erc1155Address,
        address operator,
        bool approved
    ) external;

    function transferNativeToken(address payable recipient, uint256 amt)
        external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.2;

interface IMovieVotingMasterChef {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        uint256 lastRewardBlock; // Last block number that Stars distribution occurs.
        uint256 accStarsPerShare; // Accumulated Stars per share, times ACC_SUSHI_PRECISION. See below.
        uint256 poolSupply;
        uint256 rewardAmount;
        uint256 rewardAmountPerBlock;
        uint256 startBlock;
        uint256 endBlock;
    }

    function userInfo(uint256 pid, address user)
        external
        returns (uint256, uint256);

    function init(address _movieVotingAddress) external;

    function poolLength() external returns (uint256);

    function add(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rewardAmount,
        bool _withUpdate
    ) external;

    function pendingStars(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function accStarsPerShareAtCurrRate(
        uint256 blocks,
        uint256 rewardAmountPerBlock,
        uint256 poolSupply,
        uint256 startBlock,
        uint256 endBlock
    ) external returns (uint256);

    function starsPerBlock(uint256 pid) external returns (uint256);

    function updatePool(uint256 _pid) external;

    function massUpdatePools() external;

    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _staker
    ) external;

    function withdraw(uint256 _pid, address _staker) external;

    function withdrawPartial(uint256 _pid, uint256 _amount, address _staker) external;

    function emergencyWithdraw(uint256 _pid, address _staker) external;

    function safeStarsTransfer(address _to, uint256 _amount) external;
}

pragma solidity ^0.6.2;

library Sqrt {
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1; // Seven iterations should be enough
        uint256 roundedDownResult = x / result;
        return result >= roundedDownResult ? roundedDownResult : result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}