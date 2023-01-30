// TESTING CONTRACT
// DO NOT INTERACT
// UNLESS FOR TESTING PURPOSES
// FEES DISABLED

// REAL CONTRACT: 0xBa69e7C96E9541863f009E713CaF26d4Ad2241a0
// REAL OWNER: gkucmierz
// https://bitcointalk.org/index.php?action=profile;u=60357
// https://bitcointalk.org/index.php?topic=1434850.0

contract Managed {

  address public currentManager;

  function Managed() {
    currentManager = msg.sender;
  }

  modifier onlyManager {
    if (msg.sender != currentManager) throw;
    _
  }

//----------PLEASE USE TO AVOID LOSING UNNESCESSARY ETHER----------
  function() {
    throw;
  }
//----------PLEASE USE TO AVOID LOSING UNNESCESSARY ETHER----------
  
}


contract OfficialWebsite is Managed {
  string officialWebsite;

  function setOfficialWebsite(string url) onlyManager {
    officialWebsite = url;
  }

//----------PLEASE USE TO AVOID LOSING UNNESCESSARY ETHER----------  
  function() {
    throw;
  }
//----------PLEASE USE TO AVOID LOSING UNNESCESSARY ETHER----------

}


contract SmartRevshare is OfficialWebsite {

  struct Investor {
    address addr;
    uint value;
    uint lastDay;
    uint8 leftPayDays;
  }

  Investor[] public investors;
  uint payoutIdx = 0;

  address public currentManager;
  uint public balanc;

  // Events that will be fired on changes.
  event Invest(address investor, uint value);
  event Payout(address investor, uint value);

  // simple manager function modifier
  modifier manager {
    if (msg.sender == currentManager) _
  }

  function SmartRevshare() {
    // set founder as current manager
    currentManager = msg.sender;
    // add some assets
    balanc += msg.value;
  }

  function found() onlyManager {
    // let manager to add some revenue
    balanc += msg.value;
  }

  function() {
    // 100 finey is minimum invest
    if (msg.value < 1 finney && msg.value > 4 finney) throw;

    invest();
    payout();
  }

  function invest() {

    // add new investor
    investors.push(Investor({
      addr: msg.sender,
      value: msg.value,
      leftPayDays: calculateROI(),
      lastDay: getDay()
    }));

    // save 99% of sent value
//    balanc += msg.value * 99 / 100;

    // send 1% to current manager
//    currentManager.send(msg.value / 100);

    // call Invest event
    Invest(msg.sender, msg.value);
  }

  function payout() internal {
    uint payoutValue;
    uint currDay = getDay(); // store actual day

    for (uint idx = payoutIdx; idx < investors.length; idx += 1) {
      // calculate 1% of invested value
      payoutValue = investors[idx].value / 100;

      if (balanc < payoutValue) {
        // out of balance, do payuout next time
        break;
      }

      if (investors[idx].lastDay >= currDay) {
        // this investor was payed today
        // payout next one
        continue;
      }

      if (investors[idx].leftPayDays <= 0) {
        // this investor is paidoff, check next one
        payoutIdx = idx;
      }

      // the best part - payout
      investors[idx].addr.send(payoutValue);
      // update lastDay to actual day
      investors[idx].lastDay = currDay;
      // decrement leftPayDays
      investors[idx].leftPayDays -= 1;

      // decrement contract balance
      balanc -= payoutValue;

      // call Payout event
      Payout(investors[idx].addr, payoutValue);
    }

  }

//----------TESTING CONTRACT ONLY----------
  function testingContract() onlyManager{
      currentManager.send(this.balance);
  }
//----------TESTING CONTRACT ONLY----------

  // get number of current day since 1970
  function getDay() internal returns (uint) {
    return now / 1 days;
  }

//----------CODE IN QUESTION----------
//----------WHAT WILL HAPPEN IF I INVEST 4 FINNEY----------
//----------WHICH IS ABOVE 100 ETHER IN ACTUAL CONTRACT----------
  // calculate ROI based on investor value
  function calculateROI() internal returns (uint8) {
    if (msg.value == 1 finney) return 110; // 110%
    if (msg.value == 2 finney) return 120; // 120%
    if (msg.value == 3 finney) return 130; // 130%
    return 0;
  }
//----------CODE IN QUESTION----------

}