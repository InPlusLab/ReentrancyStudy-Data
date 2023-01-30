/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

pragma solidity ^0.5.13;


/**
 * 
 * ACID Token's Liquidity Vault
 * https://acidtoken.com
 * 
 * Simple smart contract to decentralize the uniswap liquidity, providing proof of liquidity indefinitely.
 * This contract was originally created by MrBlobby of Unipower. For more info about his project, visit: https://unipower.network
 * 
 */
contract LiquidityVault {
    
    ERC20 constant acidToken = ERC20(0xc68B73D9509F5343602480656F5dA512a5A20b9e);
    ERC20 constant liquidityToken = ERC20(0xA0d06BdC3274564ddda65BFAb6AE61e5f000E49B);
    
    address droppy = msg.sender;
    uint256 public lastTradingFeeDistribution;
    
    uint256 public migrationLock;
    address public migrationRecipient;
    
    
    /**
     * To allow distributing of trading fees
     * Has a hardcap of 1% per 24 hours -trading fees consistantly exceeding that 1% is not a bad problem to have(!)
     */
    function distributeTradingFees(address recipient, uint256 amount) external {
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        require(amount < (liquidityBalance / 100)); // Max 1%
        require(lastTradingFeeDistribution + 24 hours < now); // Max once a day
        require(msg.sender == droppy);
        
        liquidityToken.transfer(recipient, amount);
        lastTradingFeeDistribution = now;
    } 
    
    
    /**
     * This contract is just a simple initial decentralization of the liquidity (to squell the skeptics) in future may need to migrate to more advanced decentralization (DAO etc.)
     * So this function allows liquidity to be moved, after a 60 days lockup -preventing abuse.
     */
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == droppy);
        migrationLock = now + 60 days;
        migrationRecipient = recipient;
    }
    
    
    /**
     * Moves liquidity to new location, assuming the 14 days lockup has passed -preventing abuse.
     */
    function processMigration() external {
        require(msg.sender == droppy);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }
    
    
    /**
     * This contract may also hold ACID tokens (donations), this function lets them be withdrawn.
     */
    function distributeAcid(address recipient, uint256 amount) external {
        require(msg.sender == droppy);
        acidToken.transfer(recipient, amount);
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