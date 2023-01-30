/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

/**
Copyright (c) 2020 Austin Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/

interface IESDS {
    function transferCoupons(address _sender, address _recipient, uint256 _epoch, uint256 _amount) external;
    function balanceOfCoupons(address _account, uint256 _epoch) external view returns (uint256);
    function allowanceCoupons(address _owner, address _spender) external view returns (uint256);
}

interface IERC20 {
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);
    function balanceOf(address _account) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

contract CouponTrader {
    using SafeMath for uint256;

    IESDS constant private ESDS = IESDS(0x443D2f2755DB5942601fa062Cc248aAA153313D3);
    IERC20 constant private USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    uint256 constant private HOUSE_RATE = 100; // 100 basis points (1%) -- fee taken by the house
    address constant private OPEN_SALE_INDICATOR = 0x0000000000000000000000000000000000000001; // if this is the "buyer" then anyone can buy
    address public house = 0xE1dba80BAc43407360c7b0175444893eBaA30098; // collector of house take
    
    struct Offer {
        address buyer; // use OPEN_SALE_INDICATOR as the buyer address if you want to allow anyone to take the offer
        uint256 epoch;
        uint256 numCoupons; // 18 decimals
        uint256 totalUSDCRequiredFromSeller; // 6 decimals
    }
    
    mapping (address => Offer) private offerBySeller;
    
    event OfferSet(address indexed seller, address indexed buyer, uint256 indexed epoch, uint256 numCoupons, uint256 totalUSDCRequiredFromSeller);
    event SuccessfulTrade(address indexed seller, address indexed buyer, uint256 epoch, uint256 numCoupons, uint256 totalUSDCRequiredFromSeller);
    
    /** ======================== 
        STATE MUTATING FUNCTIONS
        ======================== **/
    
    // @notice Allows a seller to set or update an offer
    // @notice Caller MUST have approved this contract to move their coupons before calling this function or else this will revert.
    // @dev Does some sanity checks to make sure the seller can hold up their end. This check 
    //    is for UX purposes only and can be bypassed trivially. It is not security critical.
    // @param _buyer The buyer who is allowed to take this offer. If the _buyer param is set to OPEN_SALE_INDICATOR then
    //    anyone can take this offer.
    // @param _epoch The epoch of the coupons to be sold.
    // @param _numCoupons The number of coupons to be sold.
    // @param _totalUSDCRequiredFromSeller The amount of USDC the buyer must pay to take this offer. Remember that USDC uses 6 decimal places, not 18.
    function setOffer(address _buyer, uint256 _epoch, uint256 _numCoupons, uint256 _totalUSDCRequiredFromSeller) external {
        // sanity checks
        require(ESDS.balanceOfCoupons(msg.sender, _epoch) >= _numCoupons, "seller doesn't have enough coupons at that epoch");
        require(ESDS.allowanceCoupons(msg.sender, address(this)) >= _numCoupons, "seller hasn't approved this contract to move enough coupons");
        require(_totalUSDCRequiredFromSeller > 0, "_totalUSDCRequiredFromSeller is zero -- use the revokeOffer function");
        
        // store new offer
        Offer memory newOffer = Offer(_buyer, _epoch, _numCoupons, _totalUSDCRequiredFromSeller);
        offerBySeller[msg.sender] = newOffer;
        
        emit OfferSet(msg.sender, _buyer, _epoch, _numCoupons, _totalUSDCRequiredFromSeller);
    }
    
    // @notice A convenience function a seller can use to revoke their offer.
    function revokeOffer() external {
        delete offerBySeller[msg.sender];
        emit OfferSet(msg.sender, address(0), 0, 0, 0);
    }
    
    // @notice Allows a buyer to take an offer.
    // @dev Partial fills are not supported.
    // @dev The buyer must have approved this contract to move enough USDC to pay for this purchase.
    // @param _seller The seller whose offer the caller wants to take.
    // @param _epoch The epoch of the coupons being bought (must match the seller's offer). 
    // @param _numCoupons The number of coupons being bought (must match the seller's offer).
    // @param _totalUSDCRequiredFromSeller The amount of USDC the buyer is paying (must match the seller's offer).
    function takeOffer(address _seller, uint256 _epoch, uint256 _numCoupons, uint256 _totalUSDCRequiredFromSeller) external {
        // get offer information
        Offer memory offer = offerBySeller[_seller];
        
        // check that the caller is authorized
        require(msg.sender == offer.buyer || offer.buyer == OPEN_SALE_INDICATOR, "unauthorized buyer");
        
        // check that the order details are correct (protects buyer from frontrunning by the seller)
        require(
            offer.epoch == _epoch &&
            offer.numCoupons == _numCoupons &&
            offer.totalUSDCRequiredFromSeller == _totalUSDCRequiredFromSeller,
            "order details do not match the seller's offer"
        );
        
        // delete the seller's offer (so this offer cannot be filled twice)
        delete offerBySeller[_seller];
        
        // compute house take and seller take (USDC)
        uint256 houseTake = offer.totalUSDCRequiredFromSeller.mul(HOUSE_RATE).div(10_000);
        uint256 sellerTake = offer.totalUSDCRequiredFromSeller.sub(houseTake);
        
        // pay the seller USDC
        require(USDC.transferFrom(msg.sender, _seller, sellerTake), "could not pay seller");
        
        // pay the house USDC
        require(USDC.transferFrom(msg.sender, house, houseTake), "could not pay house");
        
        // transfer the coupons to the buyer
        ESDS.transferCoupons(_seller, msg.sender, _epoch, _numCoupons); // @audit-ok reverts on failure
        
        // emit events
        emit SuccessfulTrade(_seller, msg.sender, _epoch, _numCoupons, _totalUSDCRequiredFromSeller);
        emit OfferSet(_seller, address(0), 0, 0, 0);
    }
    
    // @notice Allows house address to change the house address
    function changeHouseAddress(address _newAddress) external {
        require(msg.sender == house);
        house = _newAddress;
    }
    
    /** ======================
        NON-MUTATING FUNCTIONS
        ====================== **/
    
    // @notice A getter for the offers
    // @param _seller The address of the seller whose offer we want to return.
    function getOffer(address _seller) external view returns (address, uint256, uint256, uint256) {
        Offer memory offer = offerBySeller[_seller];
        return (offer.buyer, offer.epoch, offer.numCoupons, offer.totalUSDCRequiredFromSeller);
    }
    
    // @notice Returns true iff the _buyer is authorized to take the _offer offer.
    function isAuthorizedBuyer(Offer memory _offer, address _buyer) public pure returns (bool) {
        return ( _buyer == _offer.buyer || _offer.buyer == OPEN_SALE_INDICATOR );
    }
    
    // @notice Returns true iff all the details passed match the _offer.
    function detailsMatch(Offer memory _offer, uint256 _epoch, uint256 _numCoupons, uint256 _totalUSDCRequiredFromSeller) public pure returns (bool) {
        return (
            _offer.epoch == _epoch &&
            _offer.numCoupons == _numCoupons &&
            _offer.totalUSDCRequiredFromSeller == _totalUSDCRequiredFromSeller
        );
    }
    
    // @notice Returns true iff the _seller holds at least _numCoupons coupons.
    function sellerHasTheCoupons(address _seller, uint256 _epoch, uint256 _numCoupons) public view returns (bool) {
        return ( ESDS.balanceOfCoupons(_seller, _epoch) >= _numCoupons );
    }
    
    // @notice Returns true iff the _seller has approve this contract to move at least _numCoupons coupons.
    function sellerHasApprovedCoupons(address _seller, uint256 _numCoupons) public view returns (bool) {
        return ( ESDS.allowanceCoupons(_seller, address(this)) >= _numCoupons );
    }
    
    // @notice Returns true iff the _buyer holds at least _totalUSDCRequiredFromSeller USDC.
    function buyerHasTheUSDC(address _buyer, uint256 _totalUSDCRequiredFromSeller) public view returns (bool) {
        return ( USDC.balanceOf(_buyer) >= _totalUSDCRequiredFromSeller );
    }
    
    // @notice Returns true iff the _buyer has approve this contract to move at least _totalUSDCRequiredFromSeller USDC.
    function buyerHasApprovedUSDC(address _buyer, uint256 _totalUSDCRequiredFromSeller) public view returns (bool) {
        return ( USDC.allowance(_buyer, address(this)) >= _totalUSDCRequiredFromSeller );
    }
    
    // @notice Returns true iff the entered offer would likely succeed if taken by the _buyer right now.
    // @dev This is just for UI convenience. It should not be relied upon for anything security-related.
    function tradeShouldSucceed(address _buyer, address _seller, uint256 _epoch, uint256 _numCoupons, uint256 _totalUSDCRequiredFromSeller)
        external
        view
        returns (bool)
    {
        Offer memory offer = offerBySeller[_seller];

        return (
            isAuthorizedBuyer(offer, _buyer) &&
            detailsMatch(offer, _epoch, _numCoupons, _totalUSDCRequiredFromSeller) &&
            sellerHasTheCoupons(_seller, _epoch, _numCoupons) &&
            sellerHasApprovedCoupons(_seller, _numCoupons) &&
            buyerHasTheUSDC(_buyer, _totalUSDCRequiredFromSeller) &&
            buyerHasApprovedUSDC(_buyer, _totalUSDCRequiredFromSeller)
        );
    }
    
    // @notice Convenience function for encoding offers.
    function offerEncoder(address _buyer, uint256 _epoch, uint256 _numCoupons, uint256 _totalUSDCRequiredFromSeller)
        external
        pure
        returns (Offer memory)
    {
        return Offer(_buyer, _epoch, _numCoupons, _totalUSDCRequiredFromSeller);   
    }
    
}





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