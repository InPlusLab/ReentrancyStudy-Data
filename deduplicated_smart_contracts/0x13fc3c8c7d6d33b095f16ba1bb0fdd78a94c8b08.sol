/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity >=0.4.21 <0.6.0;

contract Loyalt_Order {

    struct order {
        uint _id;
        uint customer_number;
        uint order_number;
        uint order_value;
        uint time;
        uint enterprise_id;
        uint store_id;
        uint points;
        uint expire_date;
    }
    
    mapping(uint => order) public orders;

    uint public ordersCount;   
    
    // voted event
    event votedEvent (
        uint indexed _id
    );

    constructor () public {
    }

    function createOrder(uint _customer_number, uint _order_number, uint _order_value, uint _time,
            uint _enterprise_id, uint _store_id, uint _points, uint _expire_date) public {
        ordersCount ++;
        orders[ordersCount] = order(ordersCount, _customer_number,_order_number,_order_value,_time,_enterprise_id,_store_id,_points,_expire_date);
    }
}