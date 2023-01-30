/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity ^0.4.26;

contract LuckyDaily {

    mapping (address => uint256) public investedETH;
    mapping (address => uint256) public lastInvest;

    address public dev;
    uint256 public totalInvestor = 0;

    uint256 DAILY_RATE = 345600;
    uint256 DEV_TAX = 5;

    constructor() public {
      dev = address(0x72bEe2Cf43f658F3EdF5f4E08bAB03b5F777FA0A);
    }

    function() payable public {

    }

    function investETH() public payable {

        require(msg.value >= 0.01 ether);

        if (getInvested() == 0) {
          totalInvestor = SafeMath.add(totalInvestor, 1);
        }

        if (getProfit(msg.sender) > 0) {
            uint256 profit = getProfit(msg.sender);
            lastInvest[msg.sender] = now;
            msg.sender.transfer(profit);
        }

        uint256 amount = msg.value;

        uint256 devTax = SafeMath.div(SafeMath.mul(amount, DEV_TAX), 100);
        dev.transfer(devTax);

        investedETH[msg.sender] = SafeMath.add(investedETH[msg.sender], amount);
        lastInvest[msg.sender] = now;
    }

    function withdraw() public{

        uint256 profit = getProfit(msg.sender);

        require(profit > 0);
        lastInvest[msg.sender] = now;
        msg.sender.transfer(profit);

    }

    function reinvestProfit() public {

        uint256 profit = getProfit(msg.sender);

        require(profit > 0);
        lastInvest[msg.sender] = now;
        investedETH[msg.sender] = SafeMath.add(investedETH[msg.sender], profit);

    }

    function getProfitFromSender() public view returns(uint256){
        return getProfit(msg.sender);
    }

    function getProfit(address customer) public view returns(uint256){
        uint256 secondsPassed = SafeMath.sub(now, lastInvest[customer]);
        return SafeMath.div(SafeMath.mul(secondsPassed, investedETH[customer]), DAILY_RATE);
    }

    function getInvested() public view returns(uint256){
        return investedETH[msg.sender];
    }

    function getStatistics() public view returns(uint256,uint256){
        return (address(this).balance, totalInvestor);
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}