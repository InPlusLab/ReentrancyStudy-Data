pragma solidity ^0.4.24;

import "Proxy.sol";
import "StorageModule.sol";
import "TokenModule.sol";
import "Authorization.sol";
import "ICompliance.sol";

contract ComplianceModule is Authorization {

    mapping (bytes32 => ICompliance[] ) public nationalCompliances;
    ICompliance[] generalCompliances;

    event UpdateNationalCompliance(bytes32 _country, address _compliance);
    event RemoveNationalCompliance(bytes32 _country, address _compliance);
    event UpdateGeneralCompliance(address _compliance);
    event RemoveGeneralCompliance(address _compliance);

    constructor(address _proxy) public Authorization(_proxy) {
        
    }

    function mintCheck(address[] _investors, uint256[] _amounts) public view returns (bool) {
        StorageModule sm = StorageModule(proxy.getModule("StorageModule"));
        
        if(sm.shareholderExceeded(_investors.length) || sm.isTXFrozen())
            return false;
        for(uint i = 0; i<_investors.length; i++) 
        {
            if(sm.isInvestorInWhitelist(_investors[i]) == false || sm.isInBlacklist(_investors[i]))
                return false;

            // general compliance
            for(uint j = 0; j< generalCompliances.length; j++) 
            {
                if(generalCompliances[j] != address(0) && generalCompliances[j].mintCheck(_investors[i], _amounts[i]) == false)
                    return false;
            }

            // national compliance
            bytes32 country = sm.getInvestorCountry(_investors[i]);
            for(j = 0; j< nationalCompliances[country].length; j++) 
            {
                if(nationalCompliances[country][j] != address(0) && nationalCompliances[country][j].mintCheck(_investors[i], _amounts[i]) == false)
                    return false;
            }
        }
        return true;
    }

    // TODO: should return result code not bool
    // will be called while mint, burn and transaction
    function txCheck(
        address _from, 
        address _to, 
        uint256 _amount
    ) 
        public 
        view
        whenNotPaused 
        returns (bool) 
    {
        StorageModule sm = StorageModule(proxy.getModule("StorageModule"));
        if(sm.isInvestorInWhitelist(_to) == false || sm.isInBlacklist(_from) || sm.isInBlacklist(_to) || sm.isTXFrozen())
            return false;

        // general compliance
        for(uint i = 0; i< generalCompliances.length; i++) 
        {
            if(generalCompliances[i] != address(0) && generalCompliances[i].txCheck(_to, _amount) == false)
                return false;
        }

        // national compliance
        bytes32 country = sm.getInvestorCountry(_to);
        
        for( i = 0; i< nationalCompliances[country].length; i++) 
        {
            if(nationalCompliances[country][i] != address(0) && nationalCompliances[country][i].txCheck(_to, _amount) == false)
                return false;
        }
            
        if(sm.shareholderExceeded(1) == false) 
        {
            return true;
        }
        else 
        {
            TokenModule token = TokenModule(proxy.getModule("TokenModule"));
            uint256 balance = token.balanceOf(_from);
            if(balance == _amount) {
                // if the balance of _from is 0 after transaction, the new shareholder can swap out _from
                // even if there is no available quota for new shareholder.
                return true;    
            }         
            return false;
        }
    }

    function updateNationalCompliance
    (
        bytes32 _country,
        address _compliance
    )
        public
        whenNotPaused
        onlyAdmin(msg.sender)
        returns (bool)
    {
        uint length = nationalCompliances[_country].length;
        uint firstAvaiPlace = length;
        for(uint i = 0; i< length; i++) 
        {
            if(nationalCompliances[_country][i] == _compliance) // just return
            {
                return false;
            }
            if (nationalCompliances[_country][i] == address(0) && firstAvaiPlace == length)
            {
                firstAvaiPlace = i;
            }
        }
        if (firstAvaiPlace < length) 
        {
            nationalCompliances[_country][firstAvaiPlace] = ICompliance(_compliance);
        }
        else
        {
            nationalCompliances[_country].push(ICompliance(_compliance));
        }
        emit UpdateNationalCompliance(_country, _compliance);
        return true;
    }

    function removeNationalCompliance
    (
        bytes32 _country,
        address _compliance
    )
        public
        whenNotPaused
        onlyAdmin(msg.sender)
        returns(bool result)
    {
        uint length = nationalCompliances[_country].length;

        for(uint i = 0; i< length; i++) 
        {
            if(nationalCompliances[_country][i] == _compliance)
            {
                delete nationalCompliances[_country][i];
                emit RemoveNationalCompliance(_country, _compliance);
                return true;
            }
        }
        return false;
    }

    function updateGeneralCompliance
    (
        address _compliance
    )
        public
        whenNotPaused
        onlyAdmin(msg.sender)
        returns(bool result)
    {
        uint length = generalCompliances.length;
        uint firstAvaiPlace = length;
        for(uint i = 0; i < length; i++) 
        {
            if(generalCompliances[i] == _compliance)
            {
                return false;
            }
            if (generalCompliances[i] == address(0) && firstAvaiPlace == length)
            {
                firstAvaiPlace = i;
            }
        }
        if (firstAvaiPlace < length)
        {
            generalCompliances[firstAvaiPlace] = ICompliance(_compliance);
        }
        else
        {
            generalCompliances.push(ICompliance(_compliance));
        }
        
        emit UpdateGeneralCompliance(_compliance);
        return true;
    }

    function removeGeneralCompliance
    (
        address _compliance
    )
        public
        whenNotPaused
        onlyAdmin(msg.sender)
        returns(bool result)
    {
        uint length = generalCompliances.length;

        for(uint i = 0; i < length; i++) 
        {
            if(generalCompliances[i] == _compliance)
            {
                delete generalCompliances[i];
                emit RemoveGeneralCompliance(_compliance);
                return true;
            }
        }
        return false;
    }
}