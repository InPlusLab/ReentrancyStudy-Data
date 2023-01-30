/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

/**
 * SPDX-License-Identifier: UNLICENSED
*/

pragma solidity 0.6.8;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface ERC20 {
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external  view returns (uint256);
  function transfer(address to, uint value) external  returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
  function approve(address spender, uint value) external returns (bool success);
}

contract SLTDTokenSale {
  using SafeMath for uint256;

  uint256 public totalSold;
  ERC20 public SLTDToken;
  address payable public owner;
  uint256 public collectedETH;
  uint256 public startDate;
  bool public softCapMet;
  bool private presaleClosed = false;
  uint256 private ethWithdrawals = 0;
  uint256 private lastWithdrawal;

  mapping(address => uint256) internal _contributions;
  mapping(address => uint256) internal _averagePurchaseRate;
  mapping(address => uint256) internal _numberOfContributions;

  constructor(address _wallet) public {
    owner = msg.sender;
    SLTDToken = ERC20(_wallet);
  }

  uint256 amount;
  uint256 rateDay1 = 50;
  uint256 rateDay2 = 40;
  uint256 rateDay3 = 30;
 
  receive () external payable {
    require(startDate > 0 && now.sub(startDate) <= 3 days);
    require(SLTDToken.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 3 ether);
    require(!presaleClosed);
     
    if (now.sub(startDate) <= 1 days) {
       amount = msg.value.mul(50);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(rateDay1.mul(10));
    } else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days) {
       amount = msg.value.mul(40);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(rateDay2.mul(10));
    } else if(now.sub(startDate) > 2 days) {
       amount = msg.value.mul(30);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(rateDay3.mul(10));
    }
    
    require(amount <= SLTDToken.balanceOf(address(this)));
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    _contributions[msg.sender] = _contributions[msg.sender].add(amount);
    _numberOfContributions[msg.sender] = _numberOfContributions[msg.sender].add(1);
    SLTDToken.transfer(msg.sender, amount);
    if (!softCapMet && collectedETH >= 5 ether) {
      softCapMet = true;
    }
  }

  function contribute() external payable {
    require(startDate > 0 && now.sub(startDate) <= 3 days);
    require(SLTDToken.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 3 ether);
    require(!presaleClosed);

    if (now.sub(startDate) <= 1 days) {
       amount = msg.value.mul(50);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(rateDay1.mul(10));
    } else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days) {
       amount = msg.value.mul(40);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(rateDay2.mul(10));
    } else if(now.sub(startDate) > 2 days) {
       amount = msg.value.mul(30);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(rateDay3.mul(10));
    }
        
    require(amount <= SLTDToken.balanceOf(address(this)));
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    _contributions[msg.sender] = _contributions[msg.sender].add(amount);
    _numberOfContributions[msg.sender] = _numberOfContributions[msg.sender].add(1);
    SLTDToken.transfer(msg.sender, amount);
    if (!softCapMet && collectedETH >= 5 ether) {
      softCapMet = true;
    }
  }

  function numberOfContributions(address from) public view returns(uint256) {
    return _numberOfContributions[address(from)]; 
  }

  function contributions(address from) public view returns(uint256) {
    return _contributions[address(from)];
  }

  function averagePurchaseRate(address from) public view returns(uint256) {
    return _averagePurchaseRate[address(from)];
  }

  function buyBackETH(address payable from) public {
    require(now.sub(startDate) > 3 days && !softCapMet);
    require(_contributions[from] > 0);
    uint256 exchangeRate = _averagePurchaseRate[from].div(10).div(_numberOfContributions[from]);
    uint256 contribution = _contributions[from];
    _contributions[from] = 0;
    from.transfer(contribution.div(exchangeRate));
  }

  function withdrawETH() public {
    require(msg.sender == owner && address(this).balance > 0);
    require(softCapMet == true && presaleClosed == true);
    uint256 withdrawAmount;
    if (ethWithdrawals == 0) {
      if (collectedETH <= 150 ether) {
        withdrawAmount = collectedETH;
      } else {
        withdrawAmount = 150 ether;
      }
    } else {
      uint256 currDate = now;
      require(currDate.sub(lastWithdrawal) >= 1 days);
      if (collectedETH <= 150 ether) {
        withdrawAmount = collectedETH;
      } else {
        withdrawAmount = 150 ether;
      }
    }
    lastWithdrawal = now;
    ethWithdrawals = ethWithdrawals.add(1);
    collectedETH = collectedETH.sub(withdrawAmount);
    owner.transfer(withdrawAmount);
  }

  function endPresale() public {
    require(msg.sender == owner);
    presaleClosed = true;
  }

  function burnSLTD() public {
    require(msg.sender == owner && SLTDToken.balanceOf(address(this)) > 0 && now.sub(startDate) > 3 days);
    SLTDToken.transfer(address(0), SLTDToken.balanceOf(address(this)));
  }
  
  function startSale() public {
    require(msg.sender == owner && startDate==0);
    startDate=now;
  }
  
  function availableSLTD() public view returns(uint256) {
    return SLTDToken.balanceOf(address(this));
  }
}