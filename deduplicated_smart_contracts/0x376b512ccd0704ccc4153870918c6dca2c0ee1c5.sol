/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.5.13;


/**
 * 
 * EasySwap Liquidity Vault - Inspired on UniPower's Liquidity Vault - Thanks, Mr. Blobby
 * 
 * Simple smart contract to decentralize the uniswap liquidity, providing proof of liquidity indefinitely.
 * 
 * https://easyswap.trade
 */
contract LiquidityVault {
    
    ERC20 constant eswaToken = ERC20(0xA0471cdd5c0dc2614535fD7505b17A651a8F0DAB);
    ERC20 constant liquidityToken = ERC20(0x8C0e876F1da58140695673D07FF42D4786207D1B);
    
    address eswaaddress = msg.sender;
    uint256 public lastTradingFeeDistribution;
    
    uint256 public migrationLock;
    address public migrationRecipient;
    
    
    /**
     * To allow distributing of trading fees
     * 
     * Has a hardcap of 1% per 24 hours -trading fees consistantly exceeding that 1% is not a bad problem to have(!)
     */
    function distributeTradingFees(address recipient, uint256 amount) external {
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        require(amount < (liquidityBalance / 100)); // Max 1%
        require(lastTradingFeeDistribution + 24 hours < now); // Max once a day
        require(msg.sender == eswaaddress);
        
        liquidityToken.transfer(recipient, amount);
        lastTradingFeeDistribution = now;
    } 
    
    
    /**
     * This contract is just a simple initial decentralization of the liquidity (to squell the skeptics) in future may need to migrate to more advanced decentralization (DAO etc.)
     * So this function allows liquidity to be moved, after a 14 days lockup -preventing abuse.
     */
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == eswaaddress);
        migrationLock = now + 14 days;
        migrationRecipient = recipient;
    }
    
    
    /**
     * Moves liquidity to new location, assuming the 14 days lockup has passed -preventing abuse.
     */
    function processMigration() external {
        require(msg.sender == eswaaddress);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }
    
    
    /**
     * This contract may also hold ESWA tokens (donations) to run trading contests, this function lets them be withdrawn.
     */
    function distributeESWA(address recipient, uint256 amount) external {
        require(msg.sender == eswaaddress);
        eswaToken.transfer(recipient, amount);
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