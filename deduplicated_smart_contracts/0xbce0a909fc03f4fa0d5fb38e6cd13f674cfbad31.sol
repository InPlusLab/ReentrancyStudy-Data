/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



// This is the contract code for https://weirdeth.auction





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



// File: contracts/DollarAuction.sol



pragma solidity ^0.5.2;





contract DollarAuction {

    using SafeMath for uint256;



    uint256 public constant minimumBidDelta = 1e15;

    uint256 constant twentyFourHours = 24 * 60 * 60;

    uint256 constant tenthEth = 1e17;

    uint256 public expiryTime;

    uint256 public prize;

    address payable private originalOwner;

    address payable public largestDonor;

    address payable public winningBidder;

    address payable public losingBidder;

    uint256 public largestPrizeIncrease;

    uint256 public winningBid;

    uint256 public losingBid;



    constructor() public payable {

        originalOwner = msg.sender;

        reset();

    }



    modifier onlyActiveAuction() {

        require(isActiveAuction(), "Auction not active, call restart to start a new auction.");

        _;

    }



    modifier onlyInactiveAuction() {

        require(!isActiveAuction(), "Auction not expired. Wait for expiryTime to pass.");

        _;

    }



    function increasePrize() public payable onlyActiveAuction {

        require(msg.value >= largestPrizeIncrease.add(minimumBidDelta),

            "Must be larger than largestPrizeIncrease + minimumBidDelta");



        prize = prize.add(msg.value);

        largestDonor = msg.sender;

        largestPrizeIncrease = msg.value;

    }



    function bid() public payable onlyActiveAuction {

        uint bidAmount = msg.value;



        require(bidAmount >= winningBid.add(minimumBidDelta), "Bid too small");



        repayThirdPlace();

        updateLosingBidder();

        updateWinningBidder(bidAmount, msg.sender);



        if(expiryTime < block.timestamp + twentyFourHours){

            expiryTime = block.timestamp + twentyFourHours;

        }

    }



    function withdrawPrize() public onlyInactiveAuction {



        // Try to send the prize to the winner. If the send fails

        // (e.g. due to out of gas), Try the second place winner.

        // If this also fails, try the largestDonor and finally the

        // contract owner.

        if (!winningBidder.send(prize)){

            if(!losingBidder.send(prize)){

                if(!largestDonor.send(prize)){

                    originalOwner.transfer(prize);

                }

            }

        }



        // Same as above except swapping largestDonor and winingBidder

        uint256 bids = winningBid.add(losingBid);

        if(!largestDonor.send(bids)){

            if(!winningBidder.send(bids)){

                if(!losingBidder.send(bids)){

                    originalOwner.transfer(bids);

                }

            }

        }



        prize = 0;

    }



    function restart() public payable onlyInactiveAuction {

        if (prize != 0) {

            withdrawPrize();

        }

        reset();

    }



    function reset() internal onlyInactiveAuction {

        require(msg.value >= minimumBidDelta, "Prize must be at least minimumBidDelta");

        expiryTime = block.timestamp + 2*twentyFourHours;

        prize = msg.value;

        largestDonor = msg.sender;

        winningBidder = msg.sender;

        losingBidder = msg.sender;

        winningBid = 0;

        losingBid = 0;

        largestPrizeIncrease = msg.value;

    }



    function updateWinningBidder(uint256 _bid, address payable _bidder) internal {

        winningBid = _bid;

        winningBidder = _bidder;

    }



    function updateLosingBidder() internal {

        losingBidder = winningBidder;

        losingBid = winningBid;

    }



    function repayThirdPlace() internal {

        bool successfulRepayment = losingBidder.send(losingBid);



        // If for some reason we can't send ETH

        // to third place (e.g. to a contract that runs out of gas),

        // Add it to the prize

        if (!successfulRepayment){

            prize += losingBid;

        }

    }



    function isActiveAuction() public view returns(bool) {

        return block.timestamp < expiryTime;

    }



    // what happens if donate fails? Money returned to sender?

    function() external payable {

        bid();

    }

}