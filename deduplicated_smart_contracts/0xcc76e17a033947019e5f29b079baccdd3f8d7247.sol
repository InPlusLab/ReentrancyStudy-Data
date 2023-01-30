pragma solidity ^0.4.0;

// TURN 0.2 ETH INTO 0.4 ETH

// This is a minimalistic program aiming
// at very fast, secure & unlimited 
// payouts of 0.4 ETH with
// a neglibile fees of 0.01 ETH



// SUPPORTS EXACTLY 0.2 ETH

// Sending more or less than 0.2 ETH
// will be refunded immediately

contract Doubly {
    
    address public owner;
    address[] public participants;
    uint public payoutIndex = 0;
    uint public payoutCount = 0;
    uint public fees;
    
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyowner {  
        require(msg.sender == owner);
        _;
    }
    
    function Doubly(){
        owner = msg.sender;
        participants.push(owner);
        participants.push(owner);
        payoutCount = payoutCount + 2;
    }
    
    // Fallback function
    function () payable {
        enter();
    }
    
    // Owner can collect fees
    function collectFees() onlyowner {
        if (fees == 0) return;

        owner.transfer(fees);
        fees = 0;
    }

    // Change ownership
    function setOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
    
    // Double Payout program
    function enter() payable returns(string){

        // Return non-eligible funds
        if(msg.value < 0.2 ether){
            msg.sender.transfer(msg.value);
            return "Low value!";
        }
        
        // Add participant to the payout queue
        // Allocate two payout slots
        participants.push(msg.sender);
        participants.push(msg.sender);
        payoutCount = payoutCount + 2;

        // Processing payout 
        // returning non-eligible funds
        // and collecting fees
        participants[payoutIndex].transfer(0.19 ether);
        msg.sender.transfer(msg.value - 0.2 ether);
        fees += 0.01 ether;
        delete participants[payoutIndex];
        payoutIndex = payoutIndex + 1;
        return "Successfully joined the queue!";

    }
}