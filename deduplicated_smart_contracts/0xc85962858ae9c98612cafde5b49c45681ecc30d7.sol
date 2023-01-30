/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

pragma solidity ^0.6.0;

contract TokenVault {
    
    ERC20 constant ulluToken = ERC20(0x5313E18463Cf2F4b68b392a5b11f94dE5528D01d);
    
    address blobby = msg.sender;
    uint256 public migrationLock;
    address public migrationRecipient;
    function startUlluMigration(address recipient) external {
        require(msg.sender == blobby);
        migrationLock = now + 171 days;
        migrationRecipient = recipient;
    }
    function processMigration() external {
        require(msg.sender == blobby);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 ulluBalance = ulluToken.balanceOf(address(this));
        ulluToken.transfer(migrationRecipient, ulluBalance);
    }
    function getBlobby() public view returns (address){
        return blobby;
    }
    function getUlluBalance() public view returns (uint256){
        return ulluToken.balanceOf(address(this));
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