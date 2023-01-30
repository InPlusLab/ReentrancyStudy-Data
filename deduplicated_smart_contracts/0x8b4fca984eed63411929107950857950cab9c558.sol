pragma solidity ^0.4.18;

// Splitter is an Ether payment splitter contract between an owner and a payee
// account. Both payee and owner gets funded immediately upon receipt of payment, whilst
// the owner can withdraw accumulated funds upon request if something goes wrong


//THIS CONTRACT DEPLOYMENT USES 362992 GAS


contract Splitter {
    address public owner;   // Owner of the contract, will get `percent` of all transferred funds
    address public payee = 0xc1f1D804254C7241D7FfC56Fb2174EE9b42E6b94;   // Payee of the contract, will get 100 - `percent` of all transferred funds
    uint    public percent = 10; // Percent of the funds to transfer to the payee (range: 1 - 99)
    
    // Splitter creates a fund splitter, forwarding &#39;percent&#39; of any received funds
    // to the &#39;owner&#39; and 100 percent for the payee.
    function Splitter() public {
        owner   = msg.sender;
    }
    
    // Withdraw pulls the entire (if any) balance of the contract to the owner&#39;s
    // account.
    function Withdraw() external {
        require(msg.sender == owner);
        owner.transfer(this.balance);
    }
    
    // Default function to accept Ether transfers and forward some percentage of it
    // to the owner&#39;s account and the payee
    function() external payable {
        owner.transfer(msg.value * percent / 100);
        payee.transfer(msg.value * (100 - percent) / 100);
    }
}