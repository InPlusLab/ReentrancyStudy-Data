pragma solidity ^0.4.24;

import "./ICompliance.sol";

contract CaymanIslandsCompliance is ICompliance {


    function mintCheck(address /* _investor */, uint _amount) external view returns(bool result) {
        return  denominationCheck(_amount);
    }

    function txCheck(address /* _investor */, uint256 _amount) external view returns(bool result) {
        return denominationCheck(_amount);
    }

    function denominationCheck(uint256 _amount) internal pure returns(bool result) {
        if (_amount >= 100 * 1000) 
            return true;
        return false;
    }
}