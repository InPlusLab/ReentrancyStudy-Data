/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

// https://github.com/ethereum/EIPs/issues/20
interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Must be owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Cannot transfer to zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SubscriptionsContract is Ownable {
    using SafeMath for uint256;
    
    address public feeWallet;
    address public currency;
    uint public feePercent;
    
    struct Subscription {
        address user;
        address merchant;
        string productId;
        string parentProductId;
        string status;
        bool unlimited;
        bool isSubProduct;
        uint cycles;
        uint payment;
        uint successPaymentsAmount;
        uint lastPaymentDate;
    }
    
    mapping(string => Subscription) private subscriptions;
    mapping(string => bool) private productPaused;
    
    event SubscriptionCreated(address user, address merchant, string subscriptionId, string productId);
    event SubscriptionMonthlyPaymentPaid(address user, address merchant, uint payment, uint lastPaymentDate);
    
    constructor(address _feeWallet, address _currency, uint _feePercent) public {
        feeWallet = _feeWallet;
        currency = _currency;
        feePercent = _feePercent;
    }
    
    function subscribeUser(address user, address merchant, string memory subscriptionId, string memory productId, uint cycles, uint payment, bool unlimited, bool isSubProduct, string memory parentProductId) public onlyOwner {
        require(ERC20(currency).balanceOf(user) >= payment, 'User doesnt have enough tokens for first payment');
        require(ERC20(currency).allowance(user, address(this)) >= payment.mul(cycles), 'User didnt approve needed amount of tokens');
        require(!productPaused[productId], 'Product paused by merchant');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("active"))), "User already has an active subscription for this merchant");
        
        if(subscriptions[subscriptionId].isSubProduct) {
            require(!productPaused[subscriptions[subscriptionId].parentProductId], "Parent product paused by merchant");
        }
        
        subscriptions[subscriptionId] = Subscription(user, merchant, productId, parentProductId, 'active', unlimited, isSubProduct, cycles, payment, 0, 0);
        emit SubscriptionCreated(user, merchant, subscriptionId, productId);
        processPayment(subscriptionId, payment);
    }
    
    function processPayment(string memory subscriptionId, uint payment) public onlyOwner {
        require((subscriptions[subscriptionId].successPaymentsAmount < subscriptions[subscriptionId].cycles) || subscriptions[subscriptionId].unlimited, 'Subscription is over');
        require((payment <= subscriptions[subscriptionId].payment) || subscriptions[subscriptionId].unlimited, 'Payment cant be more then started payment amount');
        require(!productPaused[subscriptions[subscriptionId].productId], 'Product paused by merchant');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("unsubscribe"))), 'Subscription must be unsubscribed');
        require(keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked(("pause"))), 'Subscription must not be paused');
        
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, payment.mul(uint(1000).sub(feePercent)).div(1000).sub(300000000000000000)), "Transfer to merchant failed");
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, feeWallet, payment.mul(feePercent).div(1000).add(300000000000000000)), "Transfer to fee wallet failed");
        
        subscriptions[subscriptionId].status = "active";
        subscriptions[subscriptionId].lastPaymentDate = block.timestamp;
        subscriptions[subscriptionId].successPaymentsAmount = subscriptions[subscriptionId].successPaymentsAmount.add(1);
        
        emit SubscriptionMonthlyPaymentPaid(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, payment, subscriptions[subscriptionId].lastPaymentDate);
        
        if(subscriptions[subscriptionId].successPaymentsAmount == subscriptions[subscriptionId].cycles && !subscriptions[subscriptionId].unlimited) {
            subscriptions[subscriptionId].status = "end";
        }
    }
    
    function pauseSubscriptionsByMerchant(string memory productId) public onlyOwner {
        productPaused[productId] = true;
    }
    
    function activateSubscriptionsByMerchant(string memory productId) public onlyOwner {
        productPaused[productId] = false;
    }
    
    function unsubscribeBatchByMerchant(string[] memory subscriptionIds) public onlyOwner {
        for(uint i = 0; i < subscriptionIds.length; i++) {
            subscriptions[subscriptionIds[i]].status = "unsubscribe";
        }
    }
    
    function cancelSubscription(string memory subscriptionId) public onlyOwner {
        subscriptions[subscriptionId].status = "unsubscribe";
    }
    
    function pauseSubscription(string memory subscriptionId) public onlyOwner {
        require(ERC20(currency).balanceOf(subscriptions[subscriptionId].user) >= subscriptions[subscriptionId].payment.mul(125).div(1000), 'User doesnt have enough tokens for first payment');
        require(ERC20(currency).allowance(subscriptions[subscriptionId].user, address(this)) >= subscriptions[subscriptionId].payment.mul(125).div(1000), 'User didnt approve needed amount of tokens');
        
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, subscriptions[subscriptionId].merchant, subscriptions[subscriptionId].payment.mul(10).div(100)), "Transfer to merchant failed");
        require(ERC20(currency).transferFrom(subscriptions[subscriptionId].user, feeWallet, subscriptions[subscriptionId].payment.mul(25).div(1000)), "Transfer to fee wallet failed");
        
        subscriptions[subscriptionId].status = "pause";
    }
    
    function activateSubscription(string memory subscriptionId) public onlyOwner {
        require((keccak256(abi.encodePacked(subscriptions[subscriptionId].status)) != keccak256(abi.encodePacked("active"))), "Subscription already active");
        subscriptions[subscriptionId].status = "active";
    }
    
    function getSubscriptionStatus(string calldata subscriptionId) external view returns(string memory) {
        return subscriptions[subscriptionId].status;
    }
    
    function getSubscriptionDetails(string calldata subscriptionId) external view returns(Subscription memory) {
        return subscriptions[subscriptionId];
    }
    
}