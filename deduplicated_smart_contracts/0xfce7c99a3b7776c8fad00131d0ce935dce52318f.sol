/**
 *Submitted for verification at Etherscan.io on 2020-04-07
*/

pragma solidity >=0.4.0 <0.7.0;

contract FondazioneEY {
    
    address private owner;
    int private donationCounter;
    mapping (int => string) private donationMessage;
    
    
     // ----------- Modifier --------- //
    modifier onlyManager() {
        require(msg.sender == owner, "Not allowed");
        _;
    }
    
     // ----------- Events ---------- //
    event DonationMessageSent(string);
    
    
      constructor() public {
        owner = msg.sender;
        donationCounter = 0;
    }
    
    
    function sendDonationMessage ( string calldata _message ) external onlyManager {
        require(bytes(_message).length > 0, "Message is required");
        
        donationCounter++;
        donationMessage[donationCounter] = _message;
        
        emit DonationMessageSent(_message);
    }
    
    
}