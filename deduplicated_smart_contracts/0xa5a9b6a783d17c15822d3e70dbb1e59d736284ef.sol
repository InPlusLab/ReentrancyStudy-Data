/**
 *Submitted for verification at Etherscan.io on 2019-11-01
*/

pragma solidity ^0.4.26;

// This is the smart contract for Simple FOMO
// A game theory based lottery that rewards the last entry with the entire pot.
// Modeled on the infamous Fomo3D but without its complexities, Simple FOMO has safeguards to reduce the chance
// a person will clog the blockchain to make them become the last entry and the winner.

contract Simple_FOMO_Round_1 {

  // Administrator information
  address public feeAddress; // This is the address of the person that collects the fees, nothing more, nothing less. It can be changed.
  uint256 public feePercent = 2500; // This is the percent of the fee (2500 = 2.5%, 1 = 0.001%)

  // Lotto information
  uint256 public potSize = 0; // This is the size of the lottery pool in Wei
  uint256 public entryCost = 1000000000000000; // This is the initial cost to enter the lottery pool (0.001 ETH)
  uint256 constant entryCostStep = 2000000000000000; // This is the increase in the entry cost per 25 entries (0.002 ETH)
  address public lastEntryAddress; // This is the address of the person who has entered the pool last
  uint256 public deadline; // This represents the initial deadline for the pool
  uint256 constant gameDuration = 7; // This is the default amount of days the lottery will last for, can be extended with entries
  uint256 public extensionTime = 600; // The default extension time per entry (600 seconds = 10 minutes)
                                      // Extension time is increased by 0.5 seconds for each entry
  uint256 public totalEntries = 0; // The total amount of entries in the pool

  constructor() public payable {
    feeAddress = msg.sender; // Set the contract creator to the first feeAddress
    lastEntryAddress = msg.sender;
    potSize = msg.value;
    deadline = now + gameDuration * 86400; // Set the game to end 7 days after lottery start
  }

  event ClaimedLotto(address _user, uint256 _amount); // Auxillary events
  event AddedEntry(address _user, uint256 _amount);
  event ChangedFeeAddress(address _newFeeAddress);

  // View function
  function viewLottoDetails() public view returns (
    uint256 _entryCost,
    uint256 _potSize,
    address _lastEntryAddress,
    uint256 _deadline
  ) {
    return (entryCost, potSize, lastEntryAddress, deadline);
  }

  // Action functions
  // Change contract fee address
  function changeContractFeeAddress(address _newFeeAddress) public {
    require (msg.sender == feeAddress); // Only the current feeAddress can change the feeAddress of the contract
    
    feeAddress = _newFeeAddress; // Update the fee address

     // Trigger event.
    emit ChangedFeeAddress(_newFeeAddress);
  }

  // Withdraw from pool when time has expired
  function claimLottery() public {
    require (msg.sender == lastEntryAddress); // Only the last person to enter can claim the lottery
    uint256 currentTime = now; // Get the current time in seconds
    uint256 claimTime = deadline + 300; // Add 5 minutes to the deadline, only after then can the lotto be claimed
    require (currentTime > claimTime);
    // Congrats, this person has won the lottery
    require (potSize > 0); // Cannot claim an empty pot
    uint256 transferAmount = potSize; // The amount that is going to the winner
    potSize = 0; // Set the potSize to zero before contacting the external address
    lastEntryAddress.transfer(transferAmount);

     // Trigger event.
    emit ClaimedLotto(lastEntryAddress, transferAmount);
  }

  // Add entry to the pool
  function addEntry() public payable {
    require (msg.value == entryCost); // Entry must be equal to entry cost, not more or less
    uint256 currentTime = now; // Get the current time in seconds
    require (currentTime <= deadline); // Cannot submit an entry if the deadline has passed

    // Entry is valid, now modify the pool based on it
    uint256 feeAmount = (entryCost * feePercent) / 100000; // Calculate the usage fee
    uint256 potAddition = entryCost - feeAmount; // This is the amount actually going into the pot

    potSize = potSize + potAddition; // Add this amount to the pot
    extensionTime = 600 + (totalEntries / 2); // The extension time increases as more entries are submitted
    totalEntries = totalEntries + 1; // Increased the amount of entries
    if(totalEntries % 25 == 0){
      entryCost = entryCost + entryCostStep; // Increase the cost to enter every 25 entries
    }

    if(currentTime + extensionTime > deadline){ // Move the deadline if the extension time brings it beyond
      deadline = currentTime + extensionTime;
    }

    lastEntryAddress = msg.sender; // Now this entry is the last address for now

    //Pay a fee to the feeAddress
    feeAddress.transfer(feeAmount);

    // Trigger event.
    emit AddedEntry(msg.sender, msg.value);
  }
}