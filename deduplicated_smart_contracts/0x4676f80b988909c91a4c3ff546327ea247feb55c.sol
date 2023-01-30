/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: contracts/interfaces/ITwistedSisterAccessControls.sol

pragma solidity ^0.5.12;

contract ITwistedSisterAccessControls {
    function isWhitelisted(address account) public view returns (bool);

    function isWhitelistAdmin(address account) public view returns (bool);
}

// File: contracts/interfaces/ITwistedSisterTokenCreator.sol

pragma solidity ^0.5.12;

contract ITwistedSisterTokenCreator {
    function createTwisted(
        uint256 _round,
        uint256 _parameter,
        string calldata _ipfsHash,
        address _recipient
    ) external returns (uint256 _tokenId);
}

// File: contracts/interfaces/ITwistedSisterArtistCommissionRegistry.sol

pragma solidity ^0.5.12;

contract ITwistedSisterArtistCommissionRegistry {
    function getCommissionSplits() external view returns (uint256[] memory _percentages, address payable[] memory _artists);
    function getMaxCommission() external view returns (uint256);
}

// File: contracts/TwistedSisterArtistFundSplitter.sol

pragma solidity ^0.5.12;




contract TwistedSisterArtistFundSplitter {
    using SafeMath for uint256;

    event FundSplitAndTransferred(uint256 _totalValue, address payable _recipient);

    ITwistedSisterArtistCommissionRegistry public artistCommissionRegistry;

    constructor(ITwistedSisterArtistCommissionRegistry _artistCommissionRegistry) public {
        artistCommissionRegistry = _artistCommissionRegistry;
    }

    function() external payable {
        (uint256[] memory _percentages, address payable[] memory _artists) = artistCommissionRegistry.getCommissionSplits();
        require(_percentages.length > 0, "No commissions found");

        uint256 modulo = artistCommissionRegistry.getMaxCommission();

        for (uint256 i = 0; i < _percentages.length; i++) {
            uint256 percentage = _percentages[i];
            address payable artist = _artists[i];

            uint256 valueToSend = msg.value.div(modulo).mul(percentage);
            (bool success, ) = artist.call.value(valueToSend)("");
            require(success, "Transfer failed");

            emit FundSplitAndTransferred(valueToSend, artist);
        }
    }
}

// File: contracts/TwistedSisterAuction.sol

pragma solidity ^0.5.12;





contract TwistedSisterAuction {
    using SafeMath for uint256;

    event BidAccepted(
        uint256 indexed _round,
        uint256 _timeStamp,
        uint256 _param,
        uint256 _amount,
        address indexed _bidder
    );

    event BidderRefunded(
        uint256 indexed _round,
        uint256 _amount,
        address indexed _bidder
    );

    event RoundFinalised(
        uint256 indexed _round,
        uint256 _timestamp,
        uint256 _param,
        uint256 _highestBid,
        address _highestBidder
    );

    address payable printingFund;
    address payable auctionOwner;

    uint256 public auctionStartTime;

    uint256 public minBid = 0.02 ether;
    uint256 public currentRound = 1;
    uint256 public numOfRounds = 21;
    uint256 public roundLengthInSeconds = 0.5 days;
    uint256 constant public secondsInADay = 1 days;

    // round <> parameter from highest bidder
    mapping(uint256 => uint256) public winningRoundParameter;

    // round <> highest bid value
    mapping(uint256 => uint256) public highestBidFromRound;

    // round <> address of the highest bidder
    mapping(uint256 => address) public highestBidderFromRound;

    ITwistedSisterAccessControls public accessControls;
    ITwistedSisterTokenCreator public twistedTokenCreator;
    TwistedSisterArtistFundSplitter public artistFundSplitter;

    modifier isWhitelisted() {
        require(accessControls.isWhitelisted(msg.sender), "Caller not whitelisted");
        _;
    }

    constructor(ITwistedSisterAccessControls _accessControls,
                ITwistedSisterTokenCreator _twistedTokenCreator,
                TwistedSisterArtistFundSplitter _artistFundSplitter,
                address payable _printingFund,
                address payable _auctionOwner,
                uint256 _auctionStartTime) public {
        require(now < _auctionStartTime, "Auction start time is not in the future");
        accessControls = _accessControls;
        twistedTokenCreator = _twistedTokenCreator;
        artistFundSplitter = _artistFundSplitter;
        printingFund = _printingFund;
        auctionStartTime = _auctionStartTime;
        auctionOwner = _auctionOwner;
    }

    function _isWithinBiddingWindowForRound() internal view returns (bool) {
        uint256 offsetFromStartingRound = currentRound.sub(1);
        uint256 currentRoundSecondsOffsetSinceFirstRound = secondsInADay.mul(offsetFromStartingRound);
        uint256 currentRoundStartTime = auctionStartTime.add(currentRoundSecondsOffsetSinceFirstRound);
        uint256 currentRoundEndTime = currentRoundStartTime.add(roundLengthInSeconds);
        return now >= currentRoundStartTime && now <= currentRoundEndTime;
    }

    function _isBidValid(uint256 _bidValue) internal view {
        require(currentRound <= numOfRounds, "Auction has ended");
        require(_bidValue >= minBid, "The bid didn't reach the minimum bid threshold");
        require(_bidValue >= highestBidFromRound[currentRound].add(minBid), "The bid was not higher than the last");
        require(_isWithinBiddingWindowForRound(), "This round's bidding window is not open");
    }

    function _refundHighestBidder() internal {
        uint256 highestBidAmount = highestBidFromRound[currentRound];
        if (highestBidAmount > 0) {
            address highestBidder = highestBidderFromRound[currentRound];

            // Clear out highest bidder as there is no longer one
            delete highestBidderFromRound[currentRound];

            (bool success, ) = highestBidder.call.value(highestBidAmount)("");
            require(success, "Failed to refund the highest bidder");

            emit BidderRefunded(currentRound, highestBidAmount, highestBidder);
        }
    }

    function _splitFundsFromHighestBid() internal {
        // Split - 50% -> 3D Printing Fund, 50% -> TwistedArtistFundSplitter
        uint256 valueToSend = highestBidFromRound[currentRound.sub(1)].div(2);

        (bool pfSuccess, ) = printingFund.call.value(valueToSend)("");
        require(pfSuccess, "Failed to transfer funds to the printing fund");

        (bool fsSuccess, ) = address(artistFundSplitter).call.value(valueToSend)("");
        require(fsSuccess, "Failed to send funds to the auction fund splitter");
    }

    function bid(uint256 _parameter) external payable {
        require(_parameter > 0, "The parameter cannot be zero");
        _isBidValid(msg.value);
        _refundHighestBidder();
        highestBidFromRound[currentRound] = msg.value;
        highestBidderFromRound[currentRound] = msg.sender;
        winningRoundParameter[currentRound] = _parameter;
        emit BidAccepted(currentRound, now, winningRoundParameter[currentRound], highestBidFromRound[currentRound], highestBidderFromRound[currentRound]);
    }

    function issueTwistAndPrepNextRound(string calldata _ipfsHash) external isWhitelisted {
        require(!_isWithinBiddingWindowForRound(), "Current round still active");
        require(currentRound <= numOfRounds, "Auction has ended");

        uint256 previousRound = currentRound;
        currentRound = currentRound.add(1);

        // Handle no-bid scenario
        if (highestBidderFromRound[previousRound] == address(0)) {
            highestBidderFromRound[previousRound] = auctionOwner;
            winningRoundParameter[previousRound] = 1; // 1 is the default and first param (1...64)
        }

        // Issue the TWIST
        address winner = highestBidderFromRound[previousRound];
        uint256 winningRoundParam = winningRoundParameter[previousRound];
        uint256 tokenId = twistedTokenCreator.createTwisted(previousRound, winningRoundParam, _ipfsHash, winner);
        require(tokenId == previousRound, "Error minting the TWIST token");

        // Take the proceedings from the highest bid and split funds accordingly
        _splitFundsFromHighestBid();

        emit RoundFinalised(previousRound, now, winningRoundParam, highestBidFromRound[previousRound], winner);
    }

    function updateAuctionStartTime(uint256 _auctionStartTime) external isWhitelisted {
        auctionStartTime = _auctionStartTime;
    }

    function updateNumberOfRounds(uint256 _numOfRounds) external isWhitelisted {
        require(_numOfRounds >= currentRound, "Number of rounds can't be smaller than the number of previous");
        numOfRounds = _numOfRounds;
    }

    function updateRoundLength(uint256 _roundLengthInSeconds) external isWhitelisted {
        require(_roundLengthInSeconds < secondsInADay);
        roundLengthInSeconds = _roundLengthInSeconds;
    }

    function updateArtistFundSplitter(TwistedSisterArtistFundSplitter _artistFundSplitter) external isWhitelisted {
        artistFundSplitter = _artistFundSplitter;
    }
}