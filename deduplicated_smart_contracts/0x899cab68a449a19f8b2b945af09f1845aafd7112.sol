/**
 *Submitted for verification at Etherscan.io on 2020-12-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}


contract preSale{
    
    using SafeMath for uint256;
    
    address payable constant public fundsReceiver = 0x1F1800e21dD5080354A06d678ae9B30C00CA4E53;
    
    uint256 public totalFundsReceived;
    uint256 public totalDepositors;
    uint256 public EventEndDate;
    uint256 public softCap = 200 ether;
    
    mapping(address => uint256) public investors; // save each user investment
    
    modifier onlyFundsReceiver{
        require(msg.sender == fundsReceiver);
        _;
    }
    
    
    function setEventEndDate(uint256 endDate) external onlyFundsReceiver{
        EventEndDate = endDate;
    }

    receive() external payable{
        deposit();
    }
    
    function deposit() public payable{
        if(EventEndDate > 0)
            require(block.timestamp <= EventEndDate, "Event is closed");
        if(investors[msg.sender] == 0)
            totalDepositors = totalDepositors.add(1);
        totalFundsReceived = totalFundsReceived.add(msg.value);
        investors[msg.sender] = investors[msg.sender].add(msg.value);
        fundsReceiver.transfer(msg.value);
    }

}