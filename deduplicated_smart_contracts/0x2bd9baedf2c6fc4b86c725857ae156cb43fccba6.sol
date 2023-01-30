/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.0;

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


// We should reference that this was inspired by Melon Protocol Engine

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

contract BurnableToken {
    function burnAndRetrieve(uint256 _tokensToBurn) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

/// @notice NEC Auction Engine
contract Engine {
    using SafeMath for uint256;

    event Thaw(uint amount);
    event Burn(uint amount, uint price, address burner);
    event FeesPaid(uint amount);
    event AuctionClose(uint indexed auctionNumber, uint ethPurchased, uint necBurned);

    uint public constant NEC_DECIMALS = 18;
    address public necAddress;

    uint public frozenEther;
    uint public liquidEther;
    uint public lastThaw;
    uint public thawingDelay;
    uint public totalEtherConsumed;
    uint public totalNecBurned;
    uint public thisAuctionTotalEther;

    uint private necPerEth; // Price at which the previous auction ended
    uint private lastSuccessfulSale;

    uint public auctionCounter;

    // Params for auction price multiplier - TODO: can make customizable with an admin function
    uint private startingPercentage = 200;
    uint private numberSteps = 35;

    constructor(uint _delay, address _token) public {
        lastThaw = 0;
        thawingDelay = _delay;
        necAddress = _token;
        necPerEth = uint(20000).mul(10 ** uint(NEC_DECIMALS));
    }

    function payFeesInEther() external payable {
        totalEtherConsumed = totalEtherConsumed.add(msg.value);
        frozenEther = frozenEther.add(msg.value);
        emit FeesPaid(msg.value);
    }

    /// @notice Move frozen ether to liquid pool after delay
    /// @dev Delay only restarts when this function is called
    function thaw() public {
        require(
            block.timestamp >= lastThaw.add(thawingDelay),
            "Thawing delay has not passed"
        );
        require(frozenEther > 0, "No frozen ether to thaw");
        lastThaw = block.timestamp;
        if (lastSuccessfulSale > 0) {
          necPerEth = lastSuccessfulSale;
        } else {
          necPerEth = necPerEth.div(4);
        }
        liquidEther = liquidEther.add(frozenEther);
        thisAuctionTotalEther = liquidEther;
        emit Thaw(frozenEther);
        frozenEther = 0;
        lastSuccessfulSale = 0;

        emit AuctionClose(auctionCounter, totalEtherConsumed, totalNecBurned);
        auctionCounter++;
    }

    function getPriceWindow() public view returns (uint window) {
      window = (now.sub(lastThaw)).mul(numberSteps).div(thawingDelay);
    }

    function percentageMultiplier() public view returns (uint) {
        return (startingPercentage.sub(getPriceWindow().mul(5)));
    }

    /// @return NEC per ETH including premium
    function enginePrice() public view returns (uint) {
        return necPerEth.mul(percentageMultiplier()).div(100);
    }

    function ethPayoutForNecAmount(uint necAmount) public view returns (uint) {
        return necAmount.mul(10 ** uint(NEC_DECIMALS)).div(enginePrice());
    }

    /// @notice NEC must be approved first
    function sellAndBurnNec(uint necAmount) external {
        if (block.timestamp >= lastThaw.add(thawingDelay)) {
          thaw();
          return;
        }
        require(
            necToken().transferFrom(msg.sender, address(this), necAmount),
            "NEC transferFrom failed"
        );
        uint ethToSend = ethPayoutForNecAmount(necAmount);
        require(ethToSend > 0, "No ether to pay out");
        require(liquidEther >= ethToSend, "Not enough liquid ether to send");
        if (liquidEther > 0.1 ether) {
            lastSuccessfulSale = enginePrice();
        }
        liquidEther = liquidEther.sub(ethToSend);
        totalNecBurned = totalNecBurned.add(necAmount);
        msg.sender.transfer(ethToSend);
        necToken().burnAndRetrieve(necAmount);
        emit Burn(necAmount, lastSuccessfulSale, msg.sender);
    }

    /// @dev Get NEC token
    function necToken()
        public
        view
        returns (BurnableToken)
    {
        return BurnableToken(necAddress);
    }


/// Useful read functions for UI

    function getNextPriceChange() public view returns (
        uint newPriceMultiplier,
        uint nextChangeTimeSeconds )
    {
        uint nextWindow = getPriceWindow() + 1;
        nextChangeTimeSeconds = lastThaw + thawingDelay.mul(nextWindow).div(numberSteps);
        newPriceMultiplier = (startingPercentage.sub(nextWindow.mul(5)));
    }

    function getNextAuction() public view returns (
        uint nextStartTimeSeconds,
        uint predictedEthAvailable,
        uint predictedStartingPrice
        ) {
        nextStartTimeSeconds = lastThaw + thawingDelay;
        predictedEthAvailable = frozenEther;
        if (lastSuccessfulSale > 0) {
          predictedStartingPrice = lastSuccessfulSale * 2;
        } else {
          predictedStartingPrice = necPerEth.div(4);
        }
    }

    function getCurrentAuction() public view returns (
        uint auctionNumber,
        uint startTimeSeconds,
        uint nextPriceChangeSeconds,
        uint currentPrice,
        uint nextPrice,
        uint initialEthAvailable,
        uint remainingEthAvailable
        ) {
        auctionNumber = auctionCounter;
        startTimeSeconds = lastThaw;
        currentPrice = enginePrice();
        uint nextPriceMultiplier;
        (nextPriceMultiplier, nextPriceChangeSeconds) = getNextPriceChange();
        nextPrice = currentPrice.mul(nextPriceMultiplier).div(percentageMultiplier());
        initialEthAvailable = thisAuctionTotalEther;
        remainingEthAvailable = liquidEther;
    }


}