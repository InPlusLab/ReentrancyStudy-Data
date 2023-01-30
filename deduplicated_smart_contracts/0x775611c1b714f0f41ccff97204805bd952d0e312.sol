pragma solidity ^0.4.24;

import "./ICompliance.sol";
import "./ContractBase.sol";
import "./StorageModule.sol";

contract DubaiCompliance is ICompliance, ContractBase {

    constructor(address _proxy) public ContractBase(_proxy) {
    }

    function mintCheck(address _investor, uint _amount) external view returns(bool result) {
        return investorCheck(_investor) || denominationCheck(_amount);
    }

    function txCheck(address _investor, uint256 _amount) external view returns(bool result) {
        return investorCheck(_investor) || denominationCheck(_amount);
    }

    function investorCheck(address _investor) internal view returns(bool result) {
        StorageModule sm = StorageModule(proxy.getModule("StorageModule"));
        if(sm.isProfessionalInvestor(_investor))
            return true;

        uint retailInvestorNo = sm.getRetailInvestor(_investor);
        if(retailInvestorNo != 0 && retailInvestorNo <= 50 )
            return true;
        
        return false;
    }

    function denominationCheck(uint256 _amount) internal pure returns(bool result) {

        if(_amount  >= 100 * 1000)
            return true;
        
        return false;
    }
}