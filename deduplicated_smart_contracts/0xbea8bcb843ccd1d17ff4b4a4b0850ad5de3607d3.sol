/**
 *Submitted for verification at Etherscan.io on 2019-11-05
*/

pragma solidity >=0.4.0 <0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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

contract Ethconomy is Ownable {

    mapping(uint => Order) private orderIdToOrders;
    mapping(address => uint[]) private userToOrderIds;
    // highest orderId so far, increamental
    uint public sequenceNumber;

    event PlaceOrder (
        uint _orderId,
        uint indexed _productId,
        address indexed _from,
        uint _value
    );

    event CancelOrder (
        uint _orderId
    );

    event FillOrder (
        uint _orderId
    );

    enum OrderStatus { Placed, Cancelled, Completed }

    struct Order {
        uint orderId;
        uint productId;
        address buyer;
        uint price;
        OrderStatus status;
        bytes email;
        uint timestamp;
    }

    function placeOrder(uint _productId, bytes memory _email) public payable {
        ++sequenceNumber;
        uint orderId = generateOrderId(address(this), sequenceNumber);
        orderIdToOrders[orderId] = Order(orderId, _productId, msg.sender, msg.value, OrderStatus.Placed, _email, now);
        userToOrderIds[msg.sender].push(orderId);

        emit PlaceOrder(orderId, _productId, msg.sender, msg.value);
    }

    function cancelOrder(uint _orderId) public {
        Order storage order = orderIdToOrders[_orderId];
        require (
            order.orderId == _orderId,
            'Error: cannot cancel nonexisting orders'
        );
        require (
            msg.sender == order.buyer,
            'Error: cannot cancel order of others'
        );
        require (
            order.status != OrderStatus.Cancelled,
            'Error: order already cancelled'
        );
        order.status = OrderStatus.Cancelled;
        msg.sender.transfer(order.price);

        emit CancelOrder(_orderId);
    }

    function fillOrder(uint _orderId) public onlyOwner {
        Order storage order = orderIdToOrders[_orderId];
        require (
            order.status == OrderStatus.Placed,
            'Error: order not in placed status'
        );
        order.status = OrderStatus.Completed;
        msg.sender.transfer(order.price);

        emit FillOrder(_orderId);
    }

    function getUserOrders(address _user) public view returns (uint[] memory) {
        return userToOrderIds[_user];
    }

    function getOrder(uint _orderId) public view returns (
        uint orderId_,
        uint productId_,
        address buyer_,
        uint price_,
        OrderStatus orderStatus_,
        bytes memory email_,
        uint timestamp_) {

        Order memory order = orderIdToOrders[_orderId];
        orderId_ = order.orderId;
        productId_ = order.productId;
        buyer_ = order.buyer;
        price_ = order.price;
        orderStatus_ = order.status;
        email_ = order.email;
        timestamp_ = order.timestamp;
    }

    function generateOrderId(address _contractAddress, uint _sequenceNumber) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(_contractAddress, _sequenceNumber)));
    }
}