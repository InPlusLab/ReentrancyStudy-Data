pragma solidity ^0.5.1;

import "WebsensorsDoracleInterface.sol";

// Do not use in production environments.

contract WebsensorsDoracle is WebsensorsDoracleInterface {

    

    address public owner;
    uint256 public last_sensor_id;
    uint8 public last_sensor_status;
    mapping(uint256 => uint8) public sensors_status;
    address public oracle1;
    address public oracle2;
    address public oracle3;
    bytes32 public id_iexec;

    constructor() public {
        owner = msg.sender;
    }

    function receiveResult(bytes32 id, bytes calldata b) external {
        require(oracle1==msg.sender || oracle2==msg.sender || oracle3==msg.sender,"The message sender is not an authorized oracle.");
        require(b.length <= 64,'Result is too long.');
    
        last_sensor_id = 0;

        uint x = uint8(b[1]); uint r = x/16; uint s = x%16; uint c = r*10+s;
        last_sensor_id += c*1000000;
            
            
        x = uint8(b[2]); r = x/16; s = x%16; c = r*10+s;
        last_sensor_id += c*10000;
            
        x = uint8(b[3]); r = x/16; s = x%16; c = r*10+s;
        last_sensor_id += c*100;
            
        x = uint8(b[4]); r = x/16; s = x%16; c = r*10+s;
        last_sensor_id += c;
        
        last_sensor_status = uint8(b[5]);
        sensors_status[last_sensor_id] = last_sensor_status;
        
        id_iexec = id;
    }
    
    function setOracle1(address _oracle1) public{
        require(msg.sender==owner,"The message sender is not the owner.");
        oracle1 = _oracle1;
    }
    
    function setOracle2(address _oracle2) public{
        require(msg.sender==owner,"The message sender is not the owner.");
        oracle2 = _oracle2;
    }
    
    function setOracle3(address _oracle3) public{
        require(msg.sender==owner,"The message sender is not the owner.");
        oracle3 = _oracle3;
    }

  
}