/**
 *Submitted for verification at Etherscan.io on 2020-12-13
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
  uint256[4] public periods = [30 days, 90 days, 180 days, 360 days];
  uint256[4] public rates = [1020, 1070, 1190, 1450];
  uint256[4] public bonuses = [2, 21, 114, 540];
  uint256[4] public amounts = [1500000 ether, 2000000 ether, 3000000 ether, 5000000 ether];
  struct Stake {
    uint256 start;
    uint8 plan;
    uint8 cycle;
  }
  mapping(address => Stake) public stakes;

  function stake(uint8 _plan) public {
    require(stakes[msg.sender].start == 0, "Already staking");
    require(_plan < 4, "Invalid plan, must be from 0 to 3");

    require(TKN.allowance(msg.sender, address(this)) >= amounts[_plan], "Transfer impossible - low allowance");
    require(TKN.balanceOf(msg.sender) >= amounts[_plan], "Transfer impossible - low balance");
    require(TKN.transferFrom(msg.sender, address(this), amounts[_plan]));

    stakes[msg.sender] = Stake({start: block.timestamp, plan: _plan, cycle: 1});
  }

  function unstake() public {
    require(stakes[msg.sender].start != 0, "Not staking");
    Stake storage _s = stakes[msg.sender];
    uint8 _k = _s.plan;
    require(block.timestamp >= _s.start + periods[_k], "Period not passed yet");

    uint256 amount = amounts[_k];
    for (uint256 i = 0; i < _s.cycle; i++) amount = amount.mul(rates[_k] + bonuses[_k] * i).div(1000);
    require(TKN.transfer(msg.sender, amount), "Transfer failed, check contract balance");
    delete stakes[msg.sender];
  }

  function prolong() public {
    require(stakes[msg.sender].start != 0, "Not staking");
    Stake storage _s = stakes[msg.sender];
    require(block.timestamp >= _s.start + periods[_s.plan], "Period not passed yet");

    _s.start = block.timestamp;
    _s.cycle++;
  }

  constructor (ERC20Basic _token) {
    TKN = ERC20Basic(_token);
  }
}