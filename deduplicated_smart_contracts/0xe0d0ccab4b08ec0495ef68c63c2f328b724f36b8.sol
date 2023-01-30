/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

pragma solidity ^0.5.0;

contract Ownable {

    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address payable _owner) public onlyOwner {
        owner = _owner;
    }

    function getOwner() public view returns (address payable) {
        return owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "must be owner to call this function");
        _;
    }

}

// from OZ

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Referrals is Ownable {

    using SafeMath for uint;

    uint public discountLimit;
    uint public defaultDiscount;
    uint public defaultRefer;

    mapping(address => Split) public splits;

    struct Split {
        bool set;
        uint8 discountPercentage;
        uint8 referrerPercentage;
    }

    event SplitChanged(address user, uint8 discount, uint8 referrer);

    constructor(uint _discountLimit, uint _defaultDiscount, uint _defaultRefer) public {   
        setDiscountLimit(_discountLimit);
        setDefaults(_defaultDiscount, _defaultRefer);
    }

    // sets the discount and referral percentages for the current user
    // this is deliberately user-customisable
    function setSplit(uint8 discount, uint8 referrer) public {
        require(discountLimit >= discount + referrer, "can't give more than the limit");
        require(discount + referrer >= discount, "can't overflow");
        splits[msg.sender] = Split({
            discountPercentage: discount,
            referrerPercentage: referrer,
            set: true
        });
        emit SplitChanged(msg.sender, discount, referrer);
    }

    // override a user's split
    function overrideSplit(address user, uint8 discount, uint8 referrer) public onlyOwner {
        require(discountLimit >= discount + referrer, "can't give more than the limit");
        require(discount + referrer >= discount, "can't overflow");
        splits[user] = Split({
            discountPercentage: discount,
            referrerPercentage: referrer,
            set: true
        });
        emit SplitChanged(user, discount, referrer);
    }

    // sets the max purchase total discount
    function setDiscountLimit(uint _limit) public onlyOwner {
        require(_limit <= 100, "discount limit must be <= 100");
        discountLimit = _limit;
    }

    // sets the default discount and referral percentages
    function setDefaults(uint _discount, uint _refer) public onlyOwner {
        require(discountLimit >= _discount + _refer, "can't be more than the limit");
        require(_discount + _refer >= _discount, "can't overflow");
        defaultDiscount = _discount;
        defaultRefer = _refer;
    }

    // gets the discount and referral rates for a particular user
    function getSplit(address user) public view returns (uint8 discount, uint8 referrer) {
        if (user == address(0)) {
            return (0, 0);
        }
        Split memory s = splits[user];
        if (!s.set) {
            return (uint8(defaultDiscount), uint8(defaultRefer));
        }
        return (s.discountPercentage, s.referrerPercentage);
    }

}