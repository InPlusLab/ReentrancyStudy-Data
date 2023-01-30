/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

/**

 * GearProtocol's Reserve Vault
 
 * Smart contract to lockup GEAR Reserve fund indefinitely.

 * Official Website: 
https://GearProtocol.com
 
 */




pragma solidity ^0.6.0;


library SafeMath 
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) 
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) 
    {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}

contract GearReserveVault {
   
    using SafeMath for uint256;
    
    ERC20 constant GearToken = ERC20(0xBD753A8D3bE45F4772145D75E28014a333B705Fb);
    
    address owner = msg.sender;
    
     
    uint256 public LockPeriod;
    address public UnlockRecipient;
    
    

// When initiated, function allows 5% of GEAR token in this reserved contract to be unlocked after 1 month lockup period. 


    function startUnlock(address recipient) external {
        require(msg.sender == owner);
        LockPeriod = now + 30 days;
        UnlockRecipient = recipient;
    }
    
    
// Transfer 5% of GEAR token in this reserved contract to Dev after 1 month lockup has passed


    function Unlock() external {
        require(msg.sender == owner);
        require(UnlockRecipient != address(0));
        require(now > LockPeriod);
        
        uint256 GearBalance = GearToken.balanceOf(address(this));

          
        uint256 FivePercent = GearBalance.mul(5).div(100);
        
        GearToken.transfer(UnlockRecipient, FivePercent);
    }  
  

     function ResetRecipient() external {
         require(msg.sender == owner);

         UnlockRecipient = 0x0000000000000000000000000000000000000000;
         
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