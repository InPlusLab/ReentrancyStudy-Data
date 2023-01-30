/**
 *Submitted for verification at Etherscan.io on 2019-10-15
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

interface IReferrals {

    function getSplit(address user) external view returns (uint8 discount, uint8 referrer);
        
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

contract Processor is Ownable {

    using SafeMath for uint256;

    IReferrals public referrals;
    address payable public vault;
    uint public count;
    mapping(address => bool) public approvedSellers;

    event PaymentProcessed(uint id, address user, uint cost, uint items, address referrer, uint toVault, uint toReferrer);
    event SellerApprovalChanged(address seller, bool approved);

    constructor(address payable _vault, IReferrals _referrals) public {
        referrals = _referrals;
        vault = _vault;
    }

    function setCanSell(address seller, bool approved) public onlyOwner {
        approvedSellers[seller] = approved;
        emit SellerApprovalChanged(seller, approved);
    }

    function processPayment(address payable user, uint cost, uint items, address payable referrer) public payable returns (uint) {

        require(approvedSellers[msg.sender]);
        require(user != referrer, "can't refer yourself");
        require(items != 0, "have to purchase at least one item");
        require(cost > 0, "items must cost something");
        // TODO: are these necessary for the simple percentage logic?
        require(cost >= 100, "items must cost at least 100 wei");
        require(cost % 100 == 0, "costs must be multiples of 100");

        uint toVault;
        uint toReferrer;
        
        (toVault, toReferrer) = getAllocations(cost, items, referrer);

        uint total = toVault.add(toReferrer);

        // check that the tx has enough value to complete the payment
        require(msg.value >= total, "not enough value sent to contract");
        if (msg.value > total) {
            uint change = msg.value.sub(total);
            user.transfer(change);
        }

        vault.transfer(toVault);

        // pay the referral fee
        if (toReferrer > 0 && referrer != address(0)) {
            referrer.transfer(toReferrer);
        }

        // give this payment a unique ID
        uint id = count++;
        emit PaymentProcessed(id, user, cost, items, referrer, toVault, toReferrer);

        return id;
    }

    // get the amount of the purchase which will be allocated to
    // the vault and to the referrer
    function getAllocations(uint cost, uint items, address referrer) public view returns (uint toVault, uint toReferrer) {
        uint8 discount;
        uint8 refer;
        (discount, refer) = referrals.getSplit(referrer);
        require(discount + refer <= 100 && discount + refer >= discount, "invalid referral split");
        // avoid overflow
        uint total = cost.mul(items);
        uint8 vaultPercentage = 100 - discount - refer;
        toVault = getPercentage(total, vaultPercentage);
        toReferrer = getPercentage(total, refer);
        uint discountedTotal = getPercentage(total, 100 - discount);
        require(discountedTotal == toVault.add(toReferrer), "not all funds allocated");
        return (toVault, toReferrer);
    }

    // returns the price (including discount) which must be paid by the user
    function getPrice(uint cost, uint items, address referrer) public view returns (uint) {

        uint8 discount;
        (discount, ) = referrals.getSplit(referrer);

        return getPercentage(cost.mul(items), 100 - discount);
    }

    function getPercentage(uint amount, uint8 percentage) public pure returns (uint) {
        
        // TODO: are these necessary for the percentage logic?
        require(amount >= 100, "items must cost at least 100 wei");
        require(amount % 100 == 0, "costs must be multiples of 100 wei");
    
        return amount.mul(percentage).div(100);
    }

}