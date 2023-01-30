/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity >=0.4.21 <0.6.0;

contract IOT {

    struct sensor {
        address seller ;
        uint8 sensorType ;
        uint price ;
        uint32 startTime ;
        uint16 frequency ;
        int32 latitude ;
        int32 longitude ;
        string url ;
    }
    
    mapping(uint => sensor) public sensors;

    uint public sensorsCount;   
    
    // voted event
    event votedEvent (
        uint indexed seller
    );

    constructor () public {
    }

    function createSensor(address seller1, uint8 type1, uint price1, uint32 startTime1,
            uint16 frequency1, int32 latitude1, int32 longitude1, string memory url1) public {
        sensorsCount ++;
        sensors[sensorsCount] = sensor(seller1, type1,price1,startTime1,frequency1,latitude1,longitude1,url1);
    }
}