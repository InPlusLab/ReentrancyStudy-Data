/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^0.5.1;

contract SimpleOracle {

    mapping(uint256 => uint8) public sensors_status;

    function receiveResult(bytes32 id, bytes calldata b) external {
        
        //This Oracle does not check msg.sender. For testing purposes only.
        
        uint256 last_sensor_id;
        uint8 last_sensor_status;
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
        
    }

 
  
}