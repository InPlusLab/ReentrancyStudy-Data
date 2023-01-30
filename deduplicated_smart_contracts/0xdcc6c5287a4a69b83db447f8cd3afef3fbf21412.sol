/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



// Copyright (c) 2018, Jack Parkinson. All rights reserved.

// Use of this source code is governed by the BSD 3-Clause

// license that can be found in the LICENSE file at

// github.com/parkinsonj/exchangeth/blob/master/LICENSE



pragma solidity ^0.4.24;



library Orders {

    struct Order {

        address tokenOffered;

        uint256 valueOffered;

        address tokenWanted;

        uint256 valueWanted;

        uint256 expiry;

    }   



    struct Orderbook {

        uint256 lastId;

        mapping (uint256 => Order) orders;

        mapping (uint256 => address) makers;

        mapping (uint256 => uint256) indices;

        uint256[] ids;

    }



    modifier onlyExisting(Orderbook storage self, uint256 _id) {

        require(self.makers[_id] != address(0), "Order does not exist.");

        _;

    }



    modifier onlyValid(address _tokenOffered, address _tokenWanted, uint256 _expiry) {

        // Special case: expiry = 0 implies the order should not expire.

        if (_expiry > 0) { require(_expiry > block.timestamp, "Expiry must be in the future."); }



        // Check specified addresses are contracts; this does not guarantee that they are token

        // contracts but is a cheap check that prevents accidentally using an ordinary user address.

        //

        // Using ERC165 would be a more complete solution, but many ERC20 tokens do not support that

        // standard.

        //

        // It is debatable whether a stronger check is even worthwhile since in case that a user

        // creates an order with a non-token address, the worst case scenario is that the offer

        // cannot be closed. That is, the maximum potential loss is merely the gas used to create

        // the bad order.

        require(isContract(_tokenOffered), "Not a contract.");

        require(isContract(_tokenWanted), "Not a contract.");

        _;

    } 



    function createOrder(

        Orderbook storage self,

        address _maker,

        address _tokenOffered,

        uint256 _valueOffered,

        address _tokenWanted,

        uint256 _valueWanted,

        uint256 _expiry

    )

        internal

        onlyValid(_tokenOffered, _tokenWanted, _expiry)

        returns (uint256)

    {

        uint256 id = ++self.lastId; 

        self.orders[id] = Order(_tokenOffered, _valueOffered, _tokenWanted, _valueWanted, _expiry);

        self.makers[id] = _maker;

        

        uint256 index = self.ids.length++;

        self.ids[index] = id;

        self.indices[id] = index;

        

        return id;

    }



    function updateOrder(

        Orderbook storage self,

        uint256 _id,

        address _tokenOffered,

        uint256 _valueOffered,

        address _tokenWanted,

        uint256 _valueWanted,

        uint256 _expiry

    )

        internal

        onlyExisting(self, _id)

        onlyValid(_tokenOffered, _tokenWanted, _expiry)

    {

        Order storage o = self.orders[_id];

        o.tokenOffered = _tokenOffered;

        o.valueOffered = _valueOffered;

        o.tokenWanted = _tokenWanted;

        o.valueWanted = _valueWanted;

        o.expiry = _expiry;

    }



    function removeOrder(Orderbook storage self, uint256 _id) internal onlyExisting(self, _id) {

        // Get index of order to be removed.

        uint256 index = self.indices[_id];



        // Decrement the size of ids by moving the final element to the index-th position.

        uint256 id = self.ids[self.ids.length-1];

        self.ids[index] = id;

        self.ids.length--;



        // Update index for id and delete references to _id.

        self.indices[id] = index;

        delete self.makers[_id];

        delete self.orders[_id];

        delete self.indices[_id];

    }



    function getOrderAndMaker(Orderbook storage self, uint256 _id) internal view onlyExisting(self, _id) returns (Order memory, address) {

        return (self.orders[_id], self.makers[_id]);

    }

        

    function isContract(address _token) private view returns (bool) {

        uint256 size;

        assembly { size := extcodesize(_token) }

        return size > 0;

    }

}



contract Exchangeth {

    using Orders for Orders.Orderbook;

    

    Orders.Orderbook private orderbook;

    uint256 private constant UINT256_MAX = ~uint256(0);



    event OpenedOrder(uint256 indexed id, address indexed by);

	event ClosedOrder(uint256 indexed id, address indexed by);

	event CancelledOrder(uint256 indexed id, address indexed by);

    event UpdatedOrder(uint256 indexed id, address indexed by);

    

    modifier onlyMaker(uint256 _id) {

        require(msg.sender == orderbook.makers[_id], "");

        _;

    }    



	function make(

        address _tokenOffered,

        uint256 _valueOffered,

        address _tokenWanted,

        uint256 _valueWanted,

        uint256 _expiry

    )

        external

        returns (uint256)

    {

        uint256 id = orderbook.createOrder(msg.sender, _tokenOffered, _valueOffered, _tokenWanted, _valueWanted, _expiry);

        emit OpenedOrder(id, msg.sender);

        return id;

	}

    

	function take(uint256 _id) external {

        (Orders.Order memory o, address maker) = orderbook.getOrderAndMaker(_id);



        if (o.expiry > 0) { require(o.expiry > block.timestamp); }



        orderbook.removeOrder(_id);

        transferFrom(o.tokenWanted, msg.sender, maker, o.valueWanted);

        transferFrom(o.tokenOffered, maker, msg.sender, o.valueOffered);



		emit ClosedOrder(_id, msg.sender);

	}



	function cancel(uint256 _id) external onlyMaker(_id) {

        orderbook.removeOrder(_id);

		emit CancelledOrder(_id, msg.sender);

	}



    function update(

        uint256 _id,

        address _tokenOffered,

        uint256 _valueOffered,

        address _tokenWanted,

        uint256 _valueWanted,

        uint256 _expiry

    )

        external

        onlyMaker(_id)

    {

        orderbook.updateOrder(_id, _tokenOffered, _valueOffered, _tokenWanted, _valueWanted, _expiry);

        emit UpdatedOrder(_id, msg.sender);

    }



    function ids() external view returns (uint256[] memory) {

        return orderbook.ids;

    }



    function order(uint256 _id) external view returns (address, address, uint256, address, uint256, uint256) {

        (Orders.Order memory o, address maker) = orderbook.getOrderAndMaker(_id);

        return (maker, o.tokenOffered, o.valueOffered, o.tokenWanted, o.valueWanted, o.expiry);

    }



    function transferFrom(address _token, address _from, address _to, uint256 _val) private {

        bytes memory encoded = abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _val);

        bool success;

        bool result;

        assembly {

            let data := add(0x20, encoded)

            let size := mload(encoded)

            success := call(

                gas,

                _token,

                0,

                data,

                size,

                data,

                0x20

            )

            result := mload(data)

        }

        require(success && result, "Token transfer failed.");

    }    

}