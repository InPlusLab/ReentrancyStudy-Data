/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

/**

 * GearProtocol's Liquidity Vault
 
 * Smart contract to decentralize the uniswap liquidity for Gearprotocol, providing proof of liquidity indefinitely!

 * Official Website: 
https://GearProtocol.com
 
 */




pragma solidity ^0.6.0;


contract GearLiquidityVault {
    
    ERC20 constant liquidityToken = ERC20(0x5CE6f7BD479437f534Ec783e95e213CfBEE70F7C);
    
    address owner = msg.sender;
    uint256 public lastTradingFeeDistribution;
    
    uint256 public migrationLock;
    address public migrationRecipient;
    
    
// Has a hardcap of 1% per trading fees distribution in one week.

    function distributeTradingFees(address recipient, uint256 amount) external {
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        require(amount < (liquidityBalance / 100)); // Max 1%
        require(lastTradingFeeDistribution + 168 hours < now); // Max once a week 
        require(msg.sender == owner);
               liquidityToken.transfer(recipient, amount);
        lastTradingFeeDistribution = now;
    } 
    

// Function allows liquidity to be migrated, after 3 months lockup -preventing abuse.


    function startLiquidityMigration(address recipient) external {
        require(msg.sender == owner);
        migrationLock = now + 2160 hours;
        migrationRecipient = recipient;
    }
    
    
// Migrates liquidity to new location, assuming the 3 months lockup has passed -preventing abuse.


    function processMigration() external {
        require(msg.sender == owner);
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