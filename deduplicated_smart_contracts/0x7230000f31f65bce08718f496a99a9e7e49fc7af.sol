/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

/* Libertas Liquidity vault */
pragma solidity ^0.5.13;

contract LiquidityVault {
    
    /* I know you are watching me */
    /* Moon Soon */
    ERC20 constant liquidityToken = ERC20(0x6eF67eE504A60De5F558B5302bDbA9F5dA11DFAd);
    
    address blobby = msg.sender;
    uint256 public lastTradingFeeDistribution;
    
    uint256 public migrationLock;
    address public migrationRecipient;  
    

    /* Call to begin unlocking */
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == blobby);
        migrationLock = now + 90 days;
        migrationRecipient = recipient;
    }
    
    
     /* Moves liquidity to new location, assuming the 14 days lockup has passed -preventing abuse. */
    function processMigration() external {
        require(msg.sender == blobby);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }   
}

interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}