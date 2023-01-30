/**
 *Submitted for verification at Etherscan.io on 2019-07-28
*/

pragma solidity 0.5.10;

contract Alec {
    address payable public owner;
    
    int256 public guesses_allowed;
    
    bytes32 public answer;
    
    string public quiz;
    
    constructor() payable public {
        owner = tx.origin;
        
        quiz = "What runs but never walks, has a mouth but never talks, has a choice he cannot make, and is wrong for his own sake?";
        answer = 0x33a9640cbe967f2bd7a3eff25df2f6e818e74919f3ecb842a0a766dac2479231;
        
        guesses_allowed = 1;
    }
    
    function buy_guess() payable external {
        require(msg.value >= .2 ether);
        guesses_allowed++;
    }
    // <yes> Reentrancy
    function guess(string calldata attempt) external {
        if(guesses_allowed <= 0) {
            return;
        }
        
        if(owner != tx.origin) {
            return;
        }
        
        if(keccak256(abi.encode("saltysaltsalt", attempt)) == answer) {
            // send ether for winning
            msg.sender.call.value(.2 ether)("");
        }
        
        guesses_allowed--;
    }
    

    // do not give up
    function igiveup() external {
        require(tx.origin == owner);
        selfdestruct(owner);
    }    
}