pragma solidity 0.4.20;

import './hyip.sol' ;

/**
 * 
 * HYIP DAPP POOL FORWARDER
 * 
**/
contract HyipForwarder {
    
    // HYIP Contract address
    address hp = 0x4acdCD9Ad9D73235F104E52Df2BBfB8de61937Fc;
    
    // HYIP Moderator
    address moderator = 0xef280094dCdD73C0aF0B84AAe93ACFb8141a7931;
    
    function ()  public payable{
        
        HYIP_Dapp_pool hyip = HYIP_Dapp_pool(hp);
        
        hyip.sendEth.value(msg.value)();
    
        
    }
    
    function getBalance() external view returns(uint256){
        
        return address(this).balance;
    }
    
    //  Locked balance flus
    function flush() external {
        
        require(msg.sender == moderator);
        moderator.transfer(address(this).balance);
    
        
    }
}
