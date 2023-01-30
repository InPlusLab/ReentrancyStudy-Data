/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

pragma solidity ^0.4.26;

// Simple Options is a binary option smart contract. Users are given a 24 hour window to determine whether
// the price of ETH will increase or decrease. Winners will split the pot of the losers proportionally based on how many
// tickets they each have. The first 12 hours of the window allows users to bet against each other, while in the second 12 hours,
// they must wait to see if they were right. Once the time has expired, users can force the round to end which will trigger
// balance transfers to the winning side and start a new round with the current price set as the starting price; however,
// if they don't, a cron job ran externally will automatically close the round.

// The price per ticket will gradually increase per hour as the round continues. In the first hour, the price is 0.01 ETH,
// while in the final (12th) hour before betting ends, the price is 1 ETH. Users can buy more than 1 ticket.

// The price Oracle for this contract is the Maker medianizer (0x729D19f657BD0614b4985Cf1D82531c67569197B), which updates
// around every 6 hours.

// The contract charges a fee that goes to the contract feeAddress. It is 5%. This fee is taken from the losers pot before
// being distributed to the winners. If there are no losers (see below), there are no fees subtracted.

// If at the end of the round, the price stays the same, there are no winners or losers. Everyone can withdraw their balance.
// If the round is not ended within 3 minutes after the deadline, the price is considered stale and there are no winners or
// losers. Everyone can withdraw their balance.

contract MakerOracle_ETHUSD {
  function peek() external view returns (uint256,bool);
}

contract Simple_Options {

  // Administrator information
  address public feeAddress; // This is the address of the person that collects the fees, nothing more, nothing less. It can be changed.
  uint256 public feePercent = 5000; // This is the percent of the fee (5000 = 5.0%, 1 = 0.001%)
  uint256 constant roundCutoff = 43200; // The cut-off time (in seconds) to submit a bet before the round ends. Currently 12 hours
  uint256 constant roundLength = 86400; // The length of the round (in seconds)
  address constant makerOracle = 0x729D19f657BD0614b4985Cf1D82531c67569197B; // Contract address for the maker oracle. Controlled by MakerDAO.

  // Different types of round Status
  enum RoundStatus {
    OPEN,
    CLOSED,
    STALEPRICE, // No winners due to price being too late
    NOCONTEST // No winners
  }

  struct Round {
    uint256 roundNum; // The round number
    RoundStatus roundStatus; // The round status
    uint256 startPriceWei; // ETH price at start of round
    uint256 endPriceWei; // ETH price at end
    uint256 startTime; // Unix seconds at start of round
    uint256 endTime; // Unix seconds at end
    uint256 totalCallTickets; // Tickets for expected price increase
    uint256 totalCallPotWei; // Pot size for the users who believe in call
    uint256 totalPutTickets; // Tickets for expected price decrease
    uint256 totalPutPotWei; // Pot size for the users who believe in put

    uint256 totalUsers; // Total users in this round
    mapping (uint256 => address) userList;
    mapping (address => User) users;
  }

  struct User {
    uint256 numCallTickets;
    uint256 numPutTickets;
    uint256 callBalanceWei;
    uint256 putBalanceWei;
  }

  mapping (uint256 => Round) roundList; // A mapping of all the rounds based on an integer
  uint256 public currentRound = 0; // The current round

  event ChangedFeeAddress(address _newFeeAddress);
  event FailedFeeSend(address _user, uint256 _amount);
  event FeeSent(address _user, uint256 _amount);
  event BoughtCallTickets(address _user, uint256 _ticketNum, uint256 _roundNum);
  event BoughtPutTickets(address _user, uint256 _ticketNum, uint256 _roundNum);
  event FailedPriceOracle();
  event StartedNewRound(uint256 _roundNum);

  constructor() public {
    feeAddress = msg.sender; // Set the contract creator to the first feeAddress
  }

  // View function
  // View round information
  function viewRoundInfo(uint256 _numRound) public view returns (
    uint256 _startPriceWei,
    uint256 _endPriceWei,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _totalCallPotWei,
    uint256 _totalPutPotWei,
    uint256 _totalCallTickets, 
    uint256 _totalPutTickets,
    RoundStatus _status
  ) {
    assert(_numRound <= currentRound);
    assert(_numRound >= 1);
    Round memory _round = roundList[_numRound];
    return (_round.startPriceWei, _round.endPriceWei, _round.startTime, _round.endTime, _round.totalCallPotWei, _round.totalPutPotWei, _round.totalCallTickets, _round.totalPutTickets, _round.roundStatus);
  }

  // View user information that is round specific
  function viewUserInfo(uint256 _numRound, address _userAddress) public view returns (
    uint256 _numCallTickets,
    uint256 _numPutTickets,
    uint256 _balanceWei
  ) {
    assert(_numRound <= currentRound);
    assert(_numRound >= 1);
    Round storage _round = roundList[_numRound];
    User memory _user = _round.users[_userAddress];
    uint256 balance = _user.callBalanceWei + _user.putBalanceWei;
    return (_user.numCallTickets, _user.numPutTickets, balance);
  }

  // View the current round's ticket cost based on the reported current time
  function viewCurrentCost(uint256 _currentTime) public view returns (
    uint256 _cost
  ) {
    assert(currentRound > 0);
    Round memory _round = roundList[currentRound];
    uint256 startTime = _round.startTime;
    uint256 currentTime = _currentTime;
    assert(currentTime >= startTime);
    uint256 cost = calculateCost(startTime, currentTime);
    return (cost);
  }

  // Action functions
  // Change contract fee address
  function changeContractFeeAddress(address _newFeeAddress) public {
    require (msg.sender == feeAddress); // Only the current feeAddress can change the feeAddress of the contract
    
    feeAddress = _newFeeAddress; // Update the fee address

     // Trigger event.
    emit ChangedFeeAddress(_newFeeAddress);
  }

  // This function creates a new round if the time is right (only after the endTime of the previous round) or if no rounds exist
  // Anyone can request to start a new round, it is not priviledged
  function startNewRound() public {
    if(currentRound == 0){
      // This is the first round of the contract
      Round memory _newRound;
      currentRound = currentRound + 1;
      _newRound.roundNum = currentRound;
      
      // Obtain the current price from the Maker Oracle
      _newRound.startPriceWei = getOraclePrice(0,true); // This function must return a price

      // Set the timers up
      _newRound.startTime = now;
      _newRound.endTime = _newRound.startTime + roundLength; // 24 Hour rounds
      roundList[currentRound] = _newRound;

      emit StartedNewRound(currentRound);
    }else if(currentRound > 0){
      // The user wants to close the current round and start a new one
      uint256 cTime = now;
      uint256 feeAmount = 0;
      Round storage _round = roundList[currentRound];
      require( cTime >= _round.endTime ); // Cannot close a round unless the endTime is reached

      // Obtain the current price from the Maker Oracle
      _round.endPriceWei = getOraclePrice(_round.startPriceWei, false);

      bool no_contest = false; 

      // If the price is stale, the current round has no losers or winners   
      if( cTime - 180 > _round.endTime){ // More than 3 minutes after round has ended, price is stale
        no_contest = true;
        _round.endTime = cTime;
        _round.roundStatus = RoundStatus.STALEPRICE;
      }

      if(_round.endPriceWei == _round.startPriceWei){
        no_contest = true; // The price hasn't changed, so no one wins
        _round.roundStatus = RoundStatus.NOCONTEST;
      }

      if(_round.totalPutTickets == 0 || _round.totalCallTickets == 0){
        no_contest = true; // There is no one on the opposite side, can't compete
        _round.roundStatus = RoundStatus.NOCONTEST;
      }

      if(no_contest == false){
        // There are winners and losers
        uint256 addAmount = 0;
        uint256 it = 0;
        uint256 rewardPerTicket = 0;
        uint256 roundTotal = 0;
        if(_round.endPriceWei > _round.startPriceWei){
          // The calls have won the game
          // Take the putters funds, subtract the fee then divide it up among the callers
          roundTotal = _round.totalPutPotWei; // Get the putters total in the round
          feeAmount = (roundTotal * feePercent) / 100000; // Calculate the usage fee
          roundTotal = roundTotal - feeAmount; // Take fee from the total Pot
          uint256 putRemainBalance = roundTotal;    
          rewardPerTicket = roundTotal / _round.totalCallTickets;

          for(it = 0; it < _round.totalUsers; it++){ // Go through each user in the round
            User storage _user = _round.users[_round.userList[it]];
            if(_user.numPutTickets > 0){
              // We have some losing tickets, set our put balance to zero
              _user.putBalanceWei = 0;
            }
            if(_user.numCallTickets > 0){
              // We have some winning tickets, add to our call balance
              addAmount = _user.numCallTickets * rewardPerTicket;
              if(addAmount > putRemainBalance){addAmount = putRemainBalance;} // Cannot be greater than what is left
              _user.callBalanceWei = _user.callBalanceWei + addAmount;
              putRemainBalance = putRemainBalance - addAmount;
            }
          }
        }else{
          // The puts have won the game, price has decreased
          // Take the callers funds, subtract the fee then divide it up among the putters
          roundTotal = _round.totalCallPotWei; // Get the callers total in the round
          feeAmount = (roundTotal * feePercent) / 100000; // Calculate the usage fee
          roundTotal = roundTotal - feeAmount; // Take fee from the total Pot
          uint256 callRemainBalance = roundTotal;    
          rewardPerTicket = roundTotal / _round.totalPutTickets;

          for(it = 0; it < _round.totalUsers; it++){ // Go through each user in the round
            User storage _user2 = _round.users[_round.userList[it]];
            if(_user2.numCallTickets > 0){
              // We have some losing tickets, set our call balance to zero
              _user2.callBalanceWei = 0;
            }
            if(_user2.numPutTickets > 0){
              // We have some winning tickets, add to our put balance
              addAmount = _user2.numPutTickets * rewardPerTicket;
              if(addAmount > callRemainBalance){addAmount = callRemainBalance;} // Cannot be greater than what is left
              _user2.putBalanceWei = _user2.putBalanceWei + addAmount;
              callRemainBalance = callRemainBalance - addAmount;
            }
          }
        }

        // Close out the round completely which allows users to withdraw balance
        _round.roundStatus = RoundStatus.CLOSED;
      }

      // Open up a new round using the endTime for the last round as the startTime
      // and the endprice of the last round as the startprice
      Round memory _nextRound;
      currentRound = currentRound + 1;
      _nextRound.roundNum = currentRound;
      
      // The current price will be the previous round's end price
      _nextRound.startPriceWei = _round.endPriceWei;

      // Set the timers up
      _nextRound.startTime = _round.endTime; // Set the start time to the previous round endTime
      _nextRound.endTime = _nextRound.startTime + roundLength; // 24 Hour rounds
      roundList[currentRound] = _nextRound;

      // Send the fee if present
      if(feeAmount > 0){
        bool sentfee = feeAddress.send(feeAmount);
        if(sentfee == false){
          emit FailedFeeSend(feeAddress, feeAmount); // Create an event in case of fee sending failed, but don't stop ending the round
        }else{
          emit FeeSent(feeAddress, feeAmount); // Record that the fee was sent
        }
      }

      emit StartedNewRound(currentRound);
    }
  }

  // Buy some call tickets
  function buyCallTickets() public payable {
    buyTickets(0);
  }

  // Buy some put tickets
  function buyPutTickets() public payable {
    buyTickets(1);
  }

  // Withdraw from a previous round
  // Cannot withdraw partial funds, all funds are withdrawn
  function withdrawFunds(uint256 roundNum) public {
    require( roundNum > 0 && roundNum < currentRound); // Can only withdraw from previous rounds
    Round storage _round = roundList[roundNum];
    require( _round.roundStatus != RoundStatus.OPEN ); // Round must be closed
    User storage _user = _round.users[msg.sender];
    uint256 balance = _user.callBalanceWei + _user.putBalanceWei;
    require( _user.callBalanceWei + _user.putBalanceWei > 0); // Must have a balance to send out
    _user.callBalanceWei = 0;
    _user.putBalanceWei = 0;
    msg.sender.transfer(balance); // Protected from re-entrancy
  }

  // Private functions
  function calculateCost(uint256 startTime, uint256 currentTime) private pure returns (uint256 _weiCost){
    uint256 timediff = currentTime - startTime;
    uint256 chour = timediff / 3600;
    uint256 cost = 10000000000000000; // The starting cost, 0.01 ETH
    cost = cost + 90000000000000000 * chour; // The cost increases at 0.09 ETH per hour
    return cost;
  }

  // Grabs the price from the MakerDAO oracle
  function getOraclePrice(uint256 _currentPrice, bool required) private returns (uint256 _price){
    MakerOracle_ETHUSD oracle = MakerOracle_ETHUSD(makerOracle);
    (uint256 price, bool ok) = oracle.peek(); // Get the price in Wei

    if(ok == true){
      return price;
    }else{
      if(required == false){
        // Failed to get the price from the Oracle, set to the start price and rule round no contest
        // Emit an event that shows this failed
        emit FailedPriceOracle();
        return _currentPrice;       
      }else{
        // If required to obtain a price but unable to, revert the transaction
        revert();
      }
    }
  }

  function buyTickets(uint256 ticketType) private {
    require( currentRound > 0 ); // There must be an active round ongoing
    Round storage _round = roundList[currentRound];
    uint256 endTime = _round.endTime;
    uint256 startTime = _round.startTime;
    uint256 currentTime = now;
    require( currentTime <= endTime - roundCutoff); // Cannot buy a ticket after the cutoff time
    uint256 currentCost = calculateCost(startTime, currentTime); // Calculate the price
    require(msg.value % currentCost == 0); // The value must be a multiple of the cost
    require(msg.value >= currentCost); // Must have some value
    require(_round.totalUsers <= 1000); // Cannot have more than 1000 users per round
    require(_round.roundStatus == RoundStatus.OPEN); // Round is still open, it should be
    
    uint256 numTickets = msg.value / currentCost; // The user can buy multple tickets

    // Check if user is in the mapping
    User memory _user = _round.users[msg.sender];
    if(_user.numCallTickets + _user.numPutTickets == 0){
      // No tickets yet for user, new user
      _round.userList[_round.totalUsers] = msg.sender;
      _round.totalUsers = _round.totalUsers + 1;
    }

    if(ticketType == 0){
      // Call ticket
      _user.numCallTickets = _user.numCallTickets + numTickets;
      _user.callBalanceWei = _user.callBalanceWei + msg.value;
      _round.totalCallTickets = _round.totalCallTickets + numTickets;
      _round.totalCallPotWei = _round.totalCallPotWei + msg.value;

      emit BoughtCallTickets(msg.sender, numTickets, currentRound);
    }else{
      // Put ticket
      _user.numPutTickets = _user.numPutTickets + numTickets;
      _user.putBalanceWei = _user.putBalanceWei + msg.value;
      _round.totalPutTickets = _round.totalPutTickets + numTickets;
      _round.totalPutPotWei = _round.totalPutPotWei + msg.value;

      emit BoughtPutTickets(msg.sender, numTickets, currentRound);
    }

    _round.users[msg.sender] = _user; // Add the user information to the game
  }
}