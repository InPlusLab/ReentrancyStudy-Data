/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
interface IToken {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
}

contract BKP_Sales is Owned {
    
    using SafeMath for uint256;
    address public tokenAddress = 0xe1B3ecdf26aF3C631715b6a49A74470e306D455b;
    uint256 unLockingDate = 1609531200; // 1 january 2021, 8pm UTC
    
    struct Users{
        uint256 unClaimed;
        uint256 invested;
    }
    mapping(address => Users) public usersTokens;
    
    uint256 tokenRatePerEth = 252;
    uint256 maxTokensForSale = 240000 * 10 ** 18;
    uint256 soldTokens = 0;
    uint256 maxInvestment = 25 ether;
    uint256 minInvestment = 0.5 ether;
    uint256 startDate = 1608750000; // 23 december 2020, 7pm UTC
    uint256 endDate = 1609441200; // 31 december 2020, 7pm UTC
    
    modifier unLockingOpen{
        require(block.timestamp >= unLockingDate, "unlocking will start by 1 january 8pm UTC");
        _;
    }
    
    modifier saleOpen{
        require(block.timestamp >= startDate && block.timestamp <= endDate, "sale is closed");
        _;
    }
    
    event CLAIMED(uint256 amount);
    
    constructor() public {
        owner = 0xAfDE309b21922dc45f20aDFb659eF36ac984A454; 
    }
    
    receive() external payable saleOpen{
        
        usersTokens[msg.sender].invested = usersTokens[msg.sender].invested.add(msg.value);
        
        // presale
        require(usersTokens[msg.sender].invested <= maxInvestment, "Exceeds allowed max Investment");
        require(usersTokens[msg.sender].invested >= minInvestment, "Lesser than allowed min Investment");
        
        uint256 tokens = (msg.value.mul(tokenRatePerEth));
        
        // allocate tokens to the user
        usersTokens[msg.sender].unClaimed = usersTokens[msg.sender].unClaimed.add(tokens);
        
        soldTokens = soldTokens.add(tokens);
        
        require(soldTokens <= maxTokensForSale, "Insufficient tokens for sale");
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function claimTokens() external unLockingOpen{
        require(usersTokens[msg.sender].unClaimed > 0, "nothing pending to claim");
        // the private sale purchasers will claim their tokens using this function
        require(IToken(tokenAddress).transfer(msg.sender, usersTokens[msg.sender].unClaimed), "Insufficient balance of sale contract!");
        
        emit CLAIMED(usersTokens[msg.sender].unClaimed);
        
        usersTokens[msg.sender].unClaimed = 0;
    }
    
    function getUnSoldTokens() external onlyOwner{
        uint256 tokens = IToken(tokenAddress).balanceOf(address(this));
        require(IToken(tokenAddress).transfer(owner, tokens), "No tokens in contract");
    }
}