/**
 *Submitted for verification at Etherscan.io on 2019-10-10
*/

// File: browser/test.sol

pragma solidity ^0.5.11;

contract ICToken {
    function underlying() external view returns(address);
}

contract test {
    
    function maxInt() public view returns(uint256) {
        return uint256(0-1);
    }
    
    function toBytes(uint256 _value) external pure returns(bytes32) {
        return bytes32(_value);
    }
    
    function toInt(bytes32 _value) external pure returns(uint256) {
        return(uint256(_value));
    }
    
    function decodeAddresses(bytes calldata _data) external pure returns(address, address){
        return abi.decode(_data, (address, address));
    }
    
    function getCompoundUnderlying(address _cToken) external view returns(address) {
        return ICToken(_cToken).underlying();
    }
    
}