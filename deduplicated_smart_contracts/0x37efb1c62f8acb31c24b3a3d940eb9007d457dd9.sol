// "SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.6.6;

import "./SafeMath.sol";
import "./ITorro.sol";

/// @author ORayskiy - @robitnik_TorroDao
contract TorroIco {
  using SafeMath for uint256;

  ITorro private _token;
  address private _owner;
  uint256 private _startRate;
  uint256 private _rateDecrease;
  uint256 private _currentRate;
  uint256 private _startingBalance;
  uint256 private _rateDecreaseBalanceStep;
  uint256 private _rateDecreaseBalance;
  bool private _isClosed;
  uint256 private _weiLimit;
  mapping (address => uint256) private _addressSpent;

  event Purchase();

  // startRate = 180
  // rateDecrease = 10
  // rateSteps = 3
  // startingBalance = 60,000
  // ethLimit = 10
  constructor(address token_, uint256 startRate_, uint256 rateDecrease_, uint256 rateSteps_, uint256 startingBalance_, uint256 ethLimit_) public {
    require(startRate_ > 0);
    require(token_ != address(0x0));
    _token = ITorro(token_);
    _owner = msg.sender;
    _startRate = startRate_;
    _rateDecrease = rateDecrease_;
    _currentRate = _startRate;
    _startingBalance = startingBalance_.mul(10**uint256(_token.decimals()));
    _rateDecreaseBalanceStep = _startingBalance.div(rateSteps_);
    _rateDecreaseBalance = _startingBalance.sub(_rateDecreaseBalanceStep);
    _weiLimit = ethLimit_.mul(1 ether);
    _isClosed = true;
  }

  receive() external payable {
    require(_isClosed == false);
    require(msg.sender != address(0x0));

    uint256 weiAmount = msg.value;
    require(weiAmount > 0);

    uint256 alreadySpent = _addressSpent[msg.sender];
    uint256 afterSpent = alreadySpent.add(weiAmount);
    require(afterSpent <= _weiLimit);

    (uint256 tokens, uint256 refund) = _getTokenAmount(weiAmount);

    _token.transfer(msg.sender, tokens);

    if (refund > 0) {
      payable(msg.sender).transfer(refund);
    }

    _addressSpent[msg.sender] = afterSpent;

    emit Purchase();
  }

  function currentRate() public view returns (uint256) {
    return _currentRate;
  }

  function tokensLeftAtCurrentRate() public view returns (uint256) {
    uint256 balance = _token.balanceOf(address(this));
    if (balance < _rateDecreaseBalance) {
      return balance;
    }
    return balance.sub(_rateDecreaseBalance);
  }

  function isClosed() public view returns (bool) {
    return _isClosed;
  }

  function _getTokenAmount(uint256 weiAmount_) private returns (uint256, uint256) {
    uint256 amount = weiAmount_.mul(_currentRate);
    uint256 balance = _token.balanceOf(address(this));
    if (amount > balance || balance.sub(amount) <= _rateDecreaseBalance) {
      uint256 hiRateAmount = balance.sub(_rateDecreaseBalance);
      uint256 hiRateWeiAmount = hiRateAmount.div(_currentRate);
      uint256 leftOverWeiAmount = weiAmount_.sub(hiRateWeiAmount);

      bool proceed = _decreaseRate();
      if (!proceed) {
        return (hiRateAmount, leftOverWeiAmount);
      }
      uint256 loRateAmount = leftOverWeiAmount.mul(_currentRate);
      return (hiRateAmount.add(loRateAmount), 0);
    }
    return (amount, 0);
  }

  function _decreaseRate() private returns (bool) {
    if (_rateDecreaseBalance == 0) {
      _currentRate = 0;
      _isClosed = true;
      return false;
    }
    _rateDecreaseBalance = _rateDecreaseBalance.sub(_rateDecreaseBalanceStep);
    _currentRate = _currentRate.sub(_rateDecrease);
    return true;
  }

  function open() public {
    require(msg.sender == _owner);
    _isClosed = false;
  }

  function close() public {
    require(msg.sender == _owner);
    payable(_owner).transfer(address(this).balance);
    uint256 tokensLeft = _token.balanceOf(address(this));
    if (tokensLeft > 0) {
      _token.transfer(msg.sender, tokensLeft);
    }
    _isClosed = true;
  }
}
