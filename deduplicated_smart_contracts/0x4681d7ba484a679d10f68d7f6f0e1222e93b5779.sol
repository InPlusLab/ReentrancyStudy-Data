/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

pragma solidity 0.7.4;
// SPDX-License-Identifier: MIT

interface IESDS {
    function redeemCoupons(uint _epoch, uint _couponAmount) external;
    function transferCoupons(address _sender, address _recipient, uint _epoch, uint _amount) external;
    function totalRedeemable() external view returns (uint);
    function epoch() external view returns (uint);
    function balanceOfCoupons(address _account, uint _epoch) external view returns (uint);
    function advance() external;
}

interface IERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
}

interface ICHI {
    function freeFromUpTo(address _addr, uint _amount) external returns (uint);
}

// @notice Lets anybody trustlessly redeem coupons on anyone else's behalf for a fee (minimum fee is 1.5%).
//    Requires that the coupon holder has previously approved this contract via the ESDS `approveCoupons` function.
// @dev Bots should scan for the `CouponApproval` event emitted by the ESDS `approveCoupons` function to find out which 
//    users have approved this contract to redeem their coupons.
// @dev This contract's API should be backwards compatible with other CouponClippers.
contract CouponClipper {
    using SafeMath for uint;

    IERC20 constant private ESD = IERC20(0x36F3FD68E7325a35EB768F1AedaAe9EA0689d723);
    IESDS constant private ESDS = IESDS(0x443D2f2755DB5942601fa062Cc248aAA153313D3);
    ICHI  constant private CHI = ICHI(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    uint constant private HOUSE_RATE = 50; // 50 basis points (0.5%) -- fee taken by the house
    uint constant private MIN_OFFER = 150; // 150 basis points (1.5%) -- house fee, plus 1% to bot
    
    address public house = 0x871ee4648d0FBB08F39857F41da256659Eab6334; // collector of house take
    
    event SetOffer(address indexed user, uint offer);
    
    // frees CHI from msg.sender to reduce gas costs
    // requires that msg.sender has approved this contract to use their CHI
    modifier useCHI {
        uint gasStart = gasleft();
        _;
        uint gasSpent = 21000 + gasStart - gasleft() + (16 * msg.data.length);
        CHI.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
    }

    // The basis points offered by coupon holders to have their coupons redeemed -- default is 150 bps (1.5%)
    // E.g., offers[_user] = 500 indicates that _user will pay 500 basis points (5%) to the caller
    mapping(address => uint) private offers;

    // @notice Gets the number of basis points the _user is offering the bots
    // @dev The default value is 150 basis points (1.5%).
    //   That is, `offers[_user] = 0` is interpretted as 1.5%.
    //   This way users who are comfortable with the default 1.5% offer don't have to make any additional contract calls.
    // @param _user The account whose offer we're looking up.
    // @return The number of basis points the account is offering to have their coupons redeemed
    function getOffer(address _user) public view returns (uint) {
        uint offer = offers[_user];
        return offer < MIN_OFFER ? MIN_OFFER : offer;
    }

    // @notice Allows msg.sender to change the number of basis points they are offering.
    // @dev _newOffer must be at least 150 (1.5%) and no more than 10_000 (100%)
    // @dev A user's offer cannot be *decreased* during the 15 minutes before the epoch advance (frontrun protection)
    // @param _offer The number of basis points msg.sender wants to offer to have their coupons redeemed.
    function setOffer(uint _newOffer) external {
        require(_newOffer <= 10_000, "Clipper: Offer above 100%");
        require(_newOffer >= MIN_OFFER, "Clipper: Offer below 1.5%");

        if (_newOffer < offers[msg.sender]) {
            uint nextEpochStartTime = getEpochStartTime(ESDS.epoch() + 1);
            uint timeUntilNextEpoch = nextEpochStartTime.sub(block.timestamp);
            require(timeUntilNextEpoch > 15 minutes, "Clipper: Wait until next epoch");
        }
        
        offers[msg.sender] = _newOffer;
        emit SetOffer(msg.sender, _newOffer);
    }
    
    // @notice Internal logic used to redeem coupons on the coupon holder's bahalf
    // @param _user Address of the user holding the coupons (and who has approved this contract)
    // @param _epoch The epoch in which the _user purchased the coupons
    // @param _couponAmount The number of coupons to redeem (18 decimals)
    // @return the fee (in ESD) owned to the bot (msg.sender)
    function _redeem(address _user, uint _epoch, uint _couponAmount) internal returns (uint) {
        // pull user's coupons into this contract (requires that the user has approved this contract)
        ESDS.transferCoupons(_user, address(this), _epoch, _couponAmount); // @audit-info : reverts on failure
        // redeem the coupons for ESD
        ESDS.redeemCoupons(_epoch, _couponAmount); // @audit-info : reverts on failure
        
        // compute fees
        uint botRate = getOffer(_user).sub(HOUSE_RATE);
        uint botFee = _couponAmount.mul(botRate).div(10_000);
        uint houseFee = _couponAmount.mul(HOUSE_RATE).div(10_000);
        
        // send the ESD to the user
        ESD.transfer(_user, _couponAmount.sub(houseFee).sub(botFee)); // @audit-info : reverts on failure
        return botFee;
    }

    // @notice Internal logic used to redeem coupons on the coupon holder's bahalf
    // @param _users Addresses of users holding the coupons (and who has approved this contract)
    // @param _epochs The epochs in which the _users purchased the coupons
    // @param _couponAmounts The numbers of coupons to redeem (18 decimals)
    // @return the total fee (in ESD) owned to the bot (msg.sender)
    function _redeemMany(address[] calldata _users, uint[] calldata _epochs, uint[] calldata _couponAmounts) internal returns (uint) {
        // 0 by default, would cost extra gas to make that explicit
        uint botFee;

        for (uint i = 0; i < _users.length; i++) {
            botFee = botFee.add(_redeem(_users[i], _epochs[i], _couponAmounts[i]));
        }

        return botFee;
    }
    
    // @notice Allows anyone to redeem coupons for ESD on the coupon-holder's bahalf
    // @dev Backwards compatible with CouponClipper V1.
    function redeem(address _user, uint _epoch, uint _couponAmount) external {
        ESD.transfer(msg.sender, _redeem(_user, _epoch, _couponAmount));
    }

    function redeemMany(address[] calldata _users, uint[] calldata _epochs, uint[] calldata _couponAmounts) external {
        ESD.transfer(msg.sender, _redeemMany(_users, _epochs, _couponAmounts));
    }
    
    // @notice Advances the epoch (if needed) and redeems the max amount of coupons possible
    //    Also frees CHI tokens to save on gas (requires that msg.sender has CHI tokens in their
    //    account and has approved this contract to spend their CHI).
    // @param _user The user whose coupons will attempt to be redeemed
    // @param _epoch The epoch in which the coupons were created
    // @param _targetEpoch The epoch that is about to be advanced _to_.
    //    E.g., if the current epoch is 220 and we are about to advance to to epoch 221, then _targetEpoch
    //    would be set to 221. The _targetEpoch is the epoch in which the coupon redemption will be attempted.
    function advanceAndRedeem(address _user, uint _epoch, uint _targetEpoch) external useCHI {
        // End execution early if tx is mined too early
        if (block.timestamp < getEpochStartTime(_targetEpoch)) { return; }
        
        // advance epoch if it has not already been advanced 
        if (ESDS.epoch() != _targetEpoch) { ESDS.advance(); }
        
        // get max redeemable amount
        uint totalRedeemable = ESDS.totalRedeemable();
        if (totalRedeemable == 0) { return; } // no coupons to redeem
        uint userBalance = ESDS.balanceOfCoupons(_user, _epoch);
        if (userBalance == 0) { return; } // no coupons to redeem
        uint maxRedeemableAmount = totalRedeemable < userBalance ? totalRedeemable : userBalance;
        
        // attempt to redeem coupons
        ESD.transfer(msg.sender, _redeem(_user, _epoch, maxRedeemableAmount));
    }

    // @notice Advances the epoch (if needed) and redeems the max amount of coupons possible
    //    Also frees CHI tokens to save on gas (requires that msg.sender has CHI tokens in their
    //    account and has approved this contract to spend their CHI).
    // @param _users The users whose coupons will attempt to be redeemed
    // @param _epochs The epochs in which the coupons were created
    // @param _targetEpoch The epoch that is about to be advanced _to_.
    //    E.g., if the current epoch is 220 and we are about to advance to to epoch 221, then _targetEpoch
    //    would be set to 221. The _targetEpoch is the epoch in which the coupon redemption will be attempted.
    function advanceAndRedeemMany(address[] calldata _users, uint[] calldata _epochs, uint _targetEpoch) external useCHI {
        // End execution early if tx is mined too early
        if (block.timestamp < getEpochStartTime(_targetEpoch)) return;

        // Advance the epoch if necessary
        if (ESDS.epoch() != _targetEpoch) ESDS.advance();
        
        // 0 by default, would cost extra gas to make that explicit
        uint botFee;
        uint amtToRedeem;
        uint totalRedeemable = ESDS.totalRedeemable();

        for (uint i = 0; i < _users.length; i++) {
            if (totalRedeemable == 0) break;

            amtToRedeem = ESDS.balanceOfCoupons(_users[i], _epochs[i]);
            if (totalRedeemable < amtToRedeem) amtToRedeem = totalRedeemable;

            botFee = botFee.add(_redeem(_users[i], _epochs[i], amtToRedeem));
            totalRedeemable = totalRedeemable.sub(amtToRedeem);
        }

        ESD.transfer(msg.sender, botFee);
    }

    
    // @notice Returns the timestamp at which the _targetEpoch starts
    function getEpochStartTime(uint _targetEpoch) public pure returns (uint) {
        return _targetEpoch.sub(106).mul(28800).add(1602201600);
    }
    
    // @notice Allows house address to change the house address
    function changeHouseAddress(address _newAddress) external {
        require(msg.sender == house);
        house = _newAddress;
    }

    // @notice Allows house to withdraw accumulated fees
    function withdraw(address _token, uint _amount) external {
        IERC20(_token).transfer(house, _amount);
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
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
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
    function sub(uint a, uint b) internal pure returns (uint) {
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
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

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
    function mul(uint a, uint b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
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
    function div(uint a, uint b) internal pure returns (uint) {
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
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
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
    function mod(uint a, uint b) internal pure returns (uint) {
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
    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}