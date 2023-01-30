/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
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
}

interface ERC20Basic {
  function balanceOf(address who) external view returns (uint256 balance);

  function transfer(address to, uint256 value) external returns (bool trans1);

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool trans);

  function approve(address spender, uint256 value) external returns (bool hello);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Staker {
  using SafeMath for uint256;

  ERC20Basic public TKN;
  uint256[4] periods = [30 days, 90 days, 180 days, 360 days];
  uint256[4] rates = [1020, 1050, 1150, 1400];
  uint256[4] bonuses = [2, 10, 75, 400];
  uint256[4] amounts = [200000 ether, 500000 ether, 1000000 ether, 2500000 ether];
  struct Stake {
    uint256 start;
    uint8 period;
    uint256 passed;
  }
  mapping(address => Stake) public stakes;

  function stake(uint8 _period) public {
    require(stakes[msg.sender].start == 0, "Already staking");
    require(_period < 4, "Invalid period, must be from 0 to 3");

    require(TKN.transferFrom(msg.sender, address(this), amounts[_period]), "Transfer failed, check allowance");
    stakes[msg.sender] = Stake({passed: 0, start: block.timestamp, period: _period});
  }

  function unstake() public {
    require(stakes[msg.sender].start != 0, "Not staking");
    Stake storage _s = stakes[msg.sender];
    uint8 _t = _s.period;
    require(block.timestamp >= _s.start + periods[_t] * (1 + _s.passed), "Period not passed yet");

    uint256 amount = amounts[_t];
    for (uint256 i = 0; i <= _s.passed; i++) amount = amount.mul(rates[_t] + bonuses[_t] * i).div(1000);
    require(TKN.transfer(msg.sender, amount), "Transfer failed, check contract balance");
    delete stakes[msg.sender];
  }

  function prolong() public {
    require(stakes[msg.sender].start != 0, "Not staking");
    Stake storage _s = stakes[msg.sender];
    require(block.timestamp >= _s.start + periods[_s.period] * (1 + _s.passed), "Period not passed yet");

    _s.passed++;
  }

  constructor (ERC20Basic _token) {
    TKN = ERC20Basic(_token);
  }
}