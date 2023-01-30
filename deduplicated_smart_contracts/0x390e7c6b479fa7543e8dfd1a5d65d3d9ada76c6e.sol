/**

 *Submitted for verification at Etherscan.io on 2019-01-24

*/



pragma solidity ^0.4.17;



contract callBackContract {

    function __response(uint _price) public;

}



contract CoinMarketCapApi {

    

    uint public totalRequests;

    uint price;

    uint public gasAmount;

    address public admin;

    

    mapping ( address => bool ) public admins;

    mapping ( uint => address ) public _callbackAddress;

    mapping ( uint => mapping ( address => RequestMeta ) ) public requests;

    

    struct RequestMeta {

        bool processed;

        bool active;

        string ticker;

        uint current_block;

        uint expiry_block;

        uint time;

    }

    

    event newCMCRequest(uint indexed _req_id, string _ticker);

    event requestProcessed(uint indexed _req_id, uint _price);

    

    modifier onlyAdmin {

        require(admin == msg.sender);

        _;

    }

    

    

    function CoinMarketCapApi() public {

        admin = msg.sender;

        

        price = 1000000000000000;

        gasAmount = 1000000000;

    }

    

    function setPrice(uint _price) public onlyAdmin {

        price = _price;

    }

    

    function setGasAmount(uint _gasamount) public onlyAdmin {

        gasAmount = _gasamount;

    }

    

    function transferOwnership(address _newAdmin) public onlyAdmin {

        admin = _newAdmin;

    }

    

    function transferEther(address _address) public onlyAdmin {

        _address.transfer(this.balance);

    }

    

    function processRequest(uint _req_id, uint _price) public onlyAdmin returns (bool) {

        address _address = _callbackAddress[_req_id];

        RequestMeta storage r = requests[_req_id][_address];

        

        require(

            _address != address(0x0)

            && r.active

            && !r.processed 

            && r.expiry_block > block.number

        );

        

        r.processed = true;

        

        callBackContract(_address).__response.gas(gasAmount)(_price);

        

        requestProcessed(_req_id, _price);

        return true;

    }

    

    function _cost() public view returns (uint _price) {

        _price = price;

    }

    

    

    function getRequestMeta(uint _req_id) public view 

        returns (

            bool _active, 

            bool _processed, 

            string _ticker, 

            uint _current_block, 

            uint _expiry_block, 

            uint _time

        )

    {

        address _address = _callbackAddress[_req_id];

        RequestMeta storage r = requests[_req_id][_address];

        

        _active = r.active;

        _processed = r.processed;

        _ticker = r.ticker;

        _current_block = r.current_block;

        _expiry_block = r.expiry_block;

        _time = r.time;

    }

    

    function requestPrice(string _ticker) public payable {

        require(

            msg.value >= price

        );

        

        // uint _amount = price - gasPrice;

        admin.transfer(price);

        

        totalRequests++;

        RequestMeta storage r = requests[totalRequests][msg.sender];

        

        r.active = true;

        r.ticker = _ticker;

        r.current_block = block.number;

        r.expiry_block = block.number + 20;

        r.time = now;

        

        _callbackAddress[totalRequests] = msg.sender;

        

        newCMCRequest(totalRequests, _ticker);

    }

    

}