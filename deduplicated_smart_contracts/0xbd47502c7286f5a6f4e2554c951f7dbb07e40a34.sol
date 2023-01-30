/**
 *Submitted for verification at Etherscan.io on 2019-12-06
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.13;


contract iERC20 {
  string public name;
  uint8 public decimals;
  string public symbol;
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract iWETH is iERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

contract WethHelper {

    iWETH public weth = iWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function()
        external
        payable
    {}

    function claimEther(
        address receiver,
        uint256 amount)
        external
        returns (uint256 claimAmount)
    {
        claimAmount = weth.balanceOf(address(this));
        if (claimAmount != 0) {
            weth.withdraw(claimAmount);
        }
        claimAmount = address(this).balance;

        if (amount != 0) {
            require (amount <= claimAmount,
                "balance too low"
            );
            claimAmount = amount;
        }

        (bool success,) = receiver.call.value(claimAmount)("");
        require(success,
            "transfer failed"
        );
    }

    function claimToken(
        address tokenAddress,
        address receiver,
        uint256 amount)
        external
        returns (uint256 claimAmount)
    {
        iERC20 token = iERC20(tokenAddress);
        claimAmount = token.balanceOf(address(this));

        if (amount != 0) {
            require (amount <= claimAmount,
                "balance too low"
            );
            claimAmount = amount;
        }

        require(token.transfer(
            receiver,
            claimAmount),
            "transfer failed"
        );
    }
}