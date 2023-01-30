/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity ^0.4.24;

library LibMapAddressBool {

    struct MapAddressBool {
        mapping(address => MapValue) data;  // do not modify this variable outside
        uint256 length;
    }

    struct MapValue {
        bool value;
        bool inited;
    }

    function add(MapAddressBool storage self, address _key, bool _val) public returns (bool newAdded) {
        if(!self.data[_key].inited) {
            self.data[_key].inited = true;
            self.length++;
            newAdded = true;
        }
        self.data[_key].value = _val;
    }

    function remove(MapAddressBool storage self, address _key) public returns (bool removed) {
        if(self.data[_key].inited) {
            self.data[_key].inited = false;
            // self.data[_key].value = false;  // no need to reset value here
            self.length--;
            removed = true;
        }
    }

    function contain(MapAddressBool storage self, address _key) public view returns (bool) {
        return self.data[_key].inited;
    }

    function get(MapAddressBool storage self, address _key) public view returns (bool) {
        if(!self.data[_key].inited)
            return false;
        return self.data[_key].value; 
    }

    // function getLength(AddressBool storage self) public view returns (uint) {
    //     return self.length;
    // }
}