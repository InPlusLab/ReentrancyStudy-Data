/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.4.25;

//team.gutalik//
//mit 
//base on the Nagaganesh Jaladanki

contract Lottery {

    event LotteryTicketPurchased(address indexed _purchaser, uint256 _ticketID);
    event LotteryAmountPaid(address indexed _winner, uint64 _ticketID, uint256 _amount);

    // Note: prone to change
    uint64 public ticketPrice = 0.1 ether;
    uint64 public ticketMax = 5;
    address owner;
    // Initialize mapping
    address[6] public ticketMapping;
    uint256 public ticketsBought = 0;
    address public fee = 0xd44f59581056EaF5d601edD1244Ff4AA55516666;
    // Prevent potential locked funds by checking greater than
    modifier allTicketsSold() {
      require(ticketsBought >= ticketMax);
      _;
    }
    constructor() public{
        owner = msg.sender;
    }

    /* @dev Tickets may only be purchased through the buyTickets function */
    function() payable public{
      revert();
    }

    /**
      * @dev Purchase ticket and send reward if necessary
      * @param _ticket Ticket number to purchase
      * @return bool Validity of transaction
      */
    function buyTicket(uint16 _ticket) payable public returns (bool) {
      require(msg.value == ticketPrice);
      require(_ticket > 0 && _ticket < ticketMax + 1);
      require(ticketMapping[_ticket] == address(0));
      require(ticketsBought < ticketMax);

      // Avoid reentrancy attacks
      address purchaser = msg.sender;
      ticketsBought += 1;
      ticketMapping[_ticket] = purchaser;
      fee.transfer(0.01 ether);
      emit LotteryTicketPurchased(purchaser, _ticket);

      /** Placing the "burden" of sendReward() on the last ticket
        * buyer is okay, because the refund from destroying the
        * arrays decreases net gas cost
        */
      if (ticketsBought>=ticketMax) {
        sendReward();
      }

      return true;
    }

    /**
      * @dev Send lottery winner their reward
      * @return address of winner
      */
    function sendReward() public allTicketsSold returns (address) {
      uint64 winningNumber = lotteryPicker();
      address winner = ticketMapping[winningNumber];
      uint256 totalAmount = ticketMax * ticketPrice;

      // Prevent locked funds by sending to bad address
      require(winner != address(0));

      // Prevent reentrancy
      reset();
      winner.transfer(0.45 ether);
      emit LotteryAmountPaid(winner, winningNumber, totalAmount);
      return winner;
    }

    /* @return a random number based off of current block information */
    function lotteryPicker() public view allTicketsSold returns (uint64) {
      bytes memory entropy = abi.encodePacked(block.timestamp, block.number);
      bytes32 hash = sha256(entropy);
      return uint64(hash) % ticketMax;
    }

    /* @dev Reset lottery mapping once a round is finished */
    function reset() private allTicketsSold returns (bool) {
      ticketsBought = 0;
      for(uint x = 0; x < ticketMax+1; x++) {
        delete ticketMapping[x];
      }
      return true;
    }
    
    function restart() public returns (bool){
        require (msg.sender == owner);
        ticketsBought = 0;
      for(uint x = 0; x < ticketMax+1; x++) {
        delete ticketMapping[x];
      }
      return true;
    }
    /** @dev Returns ticket map array for front-end access.
      * Using a getter method is ineffective since it allows
      * only element-level access
      */
    function getTicketsPurchased() public view returns(address[6]) {
      return ticketMapping;
    }
}