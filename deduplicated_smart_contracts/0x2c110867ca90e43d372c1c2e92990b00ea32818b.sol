/**

 *Submitted for verification at Etherscan.io on 2019-08-06

*/



pragma solidity ^0.4.26;



// This is the smart contract for FiatDex protocol version 1

// Anyone can use this smart contract to exchange Fiat for ETH or vice-versa without trusting the counterparty

// The goal of the FiatDex protocol is to remove the dependence on fiat to crypto gatekeepers for those who want to trade cryptocurrency

// There are no arbitrators or third party custodians. Collateral is used as leverage on the traders.



contract FiatDex_protocol_v1 {



  address public owner; // This is the address of the current owner of the contract, this address collects fees, nothing more, nothing less

  uint256 public feeDelay = 7; // This is the amount of days to wait before start charging the fee

  uint256 public dailyFeeIncrease = 1000; // This is the percent the fee increases per day (1000 = 1%, 1 = 0.001%)

  uint256 public version = 1; // This is the version of the protocol running



  constructor() public {

    owner = msg.sender; // Set the contract creator to the first owner

  }



  enum States {

    NOTOPEN,

    INITIALIZED,

    ACTIVE,

    CLOSED

  }



  struct Swap {

    States swapState;

    uint256 sendAmount;

    address fiatTrader;

    address ethTrader;

    uint256 openTime;

    uint256 ethTraderCollateral;

    uint256 fiatTraderCollateral;

    uint256 feeAmount;

  }



  mapping (bytes32 => Swap) private swaps; // Create the swaps map



  event Open(bytes32 _tradeID, address _fiatTrader, uint256 _sendAmount); // Auxillary events

  event Close(bytes32 _tradeID, uint256 _fee);

  event ChangedOwnership(address _newOwner);



  // ethTrader can only open swap positions from tradeIDs that haven't already been used

  modifier onlyNotOpenSwaps(bytes32 _tradeID) {

    require (swaps[_tradeID].swapState == States.NOTOPEN);

    _;

  }



  // fiatTrader can only add collateral to swap positions that have just been opened

  modifier onlyInitializedSwaps(bytes32 _tradeID) {

    require (swaps[_tradeID].swapState == States.INITIALIZED);

    _;

  }



  // ethTrader is trying to close the swap position, check this first

  modifier onlyActiveSwaps(bytes32 _tradeID) {

    require (swaps[_tradeID].swapState == States.ACTIVE);

    _;

  }



  // View functions

  function viewSwap(bytes32 _tradeID) public view returns (

    States swapState, 

    uint256 sendAmount,

    address ethTrader, 

    address fiatTrader, 

    uint256 openTime, 

    uint256 ethTraderCollateral, 

    uint256 fiatTraderCollateral,

    uint256 feeAmount

  ) {

    Swap memory swap = swaps[_tradeID];

    return (swap.swapState, swap.sendAmount, swap.ethTrader, swap.fiatTrader, swap.openTime, swap.ethTraderCollateral, swap.fiatTraderCollateral, swap.feeAmount);

  }



  function viewFiatDexSpecs() public view returns (

    uint256 _version, 

    address _owner, 

    uint256 _feeDelay, 

    uint256 _dailyFeeIncrease

  ) {

    return (version, owner, feeDelay, dailyFeeIncrease);

  }



  // Action functions

  function changeContractOwner(address _newOwner) public {

    require (msg.sender == owner); // Only the current owner can change the ownership of the contract

    

    owner = _newOwner; // Update the owner



     // Trigger ownership change event.

    emit ChangedOwnership(_newOwner);

  }



  // ethTrader opens the swap position

  function openSwap(bytes32 _tradeID, address _fiatTrader) public onlyNotOpenSwaps(_tradeID) payable {

    require (msg.value > 0); // Cannot open a swap position with a zero amount of ETH

    // Calculate some values

    uint256 _sendAmount = (msg.value * 2) / 5; // Essentially the same as dividing by 2.5 (or multiplying by 2/5)

    require (_sendAmount > 0); // Fail if the amount is so small that the sendAmount will be non-existant

    uint256 _ethTraderCollateral = msg.value - _sendAmount; // Collateral will be whatever is not being sent to fiatTrader



    // Store the details of the swap.

    Swap memory swap = Swap({

      swapState: States.INITIALIZED,

      sendAmount: _sendAmount,

      ethTrader: msg.sender,

      fiatTrader: _fiatTrader,

      openTime: now,

      ethTraderCollateral: _ethTraderCollateral,

      fiatTraderCollateral: 0,

      feeAmount: 0

    });

    swaps[_tradeID] = swap;



    // Trigger open event.

    emit Open(_tradeID, _fiatTrader, _sendAmount);

  }



  // fiatTrader adds collateral to the open swap

  function addFiatTraderCollateral(bytes32 _tradeID) public onlyInitializedSwaps(_tradeID) payable {

    Swap storage swap = swaps[_tradeID]; // Get information about the swap position

    require (msg.value >= swap.ethTraderCollateral); // Cannot send less than what the ethTrader has in collateral

    require (msg.sender == swap.fiatTrader); // Only the fiatTrader can add to the swap position

    swap.fiatTraderCollateral = msg.value;   

    swap.swapState = States.ACTIVE; // Now fiatTrader needs to send fiat

  }



  // ethTrader is refunding as fiatTrader never sent the collateral

  function refundSwap(bytes32 _tradeID) public onlyInitializedSwaps(_tradeID) {

    // Refund the swap.

    Swap storage swap = swaps[_tradeID];

    require (msg.sender == swap.ethTrader); // Only the ethTrader can call this function to refund

    swap.swapState = States.CLOSED; // Swap is now closed, sending all ETH back



    // Transfer the ETH value from this contract back to the ETH trader.

    swap.ethTrader.transfer(swap.sendAmount + swap.ethTraderCollateral);



     // Trigger expire event.

    emit Close(_tradeID, 0);

  }



  // ethTrader is completing the swap position as fiatTrader has sent the fiat

  function closeSwap(bytes32 _tradeID) public onlyActiveSwaps(_tradeID) {

    // Complete the swap.

    Swap storage swap = swaps[_tradeID];

    require (msg.sender == swap.ethTrader); // Only the ethTrader can call this function to close

    swap.swapState = States.CLOSED; // Swap is now closed, sending all ETH, prevent re-entry



    // Calculate the fee 

    uint256 feeAmount = 0; // This is the amount of fee in Wei

    uint256 currentTime = now;

    if(swap.openTime + 86400 * feeDelay < currentTime){

      // The swap has been open for a duration longer than the feeDelay window, so calculate fee

      uint256 seconds_over = currentTime - (swap.openTime + 86400 * feeDelay); // This is guaranteed to be a positive number

      uint256 feePercent = (dailyFeeIncrease * seconds_over) / 86400; // This will show us the percentage fee to charge

      // For feePercent, 1 = 0.001% of collateral, 1000 = 1% of collateral     

      if(feePercent > 0){

        if(feePercent > 99000) {feePercent = 99000;} // feePercent can never be greater than 99%

        // Calculate the feeAmount in Wei

        // This feeAmount will be subtracted equally from the ethTrader and fiatTrader

        feeAmount = (swap.ethTraderCollateral * feePercent) / 100000;

      }

    }



    // Transfer all the ETH to the appropriate parties, the owner will get some ETH if a fee is calculated

    if(feeAmount > 0){

      swap.feeAmount = feeAmount;

      owner.transfer(feeAmount * 2);

    }



    // Transfer the ETH collateral from this contract back to the ETH trader.

    swap.ethTrader.transfer(swap.ethTraderCollateral - feeAmount);



    // Transfer the ETH collateral back to fiatTrader and the sendAmount from ethTrader

    swap.fiatTrader.transfer(swap.sendAmount + swap.fiatTraderCollateral - feeAmount);



     // Trigger close event showing the fee.

    emit Close(_tradeID, feeAmount);

  }

}