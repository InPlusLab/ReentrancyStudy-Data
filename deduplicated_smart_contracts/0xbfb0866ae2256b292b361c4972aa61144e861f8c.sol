/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                   //
//   ¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨[   ¨€¨€¨[ ¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[  ¨€¨€¨€¨€¨€¨€¨[¨€¨€¨[  ¨€¨€¨[¨€¨€¨[   ¨€¨€¨[    ¨€¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨[¨€¨€¨€¨[   ¨€¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨[      ¨€¨€¨€¨€¨€¨€¨[  ¨€¨€¨€¨€¨€¨€¨[¨€¨€¨[  ¨€¨€¨[  //
//  ¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨€¨€¨[  ¨€¨€¨U¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨U  ¨€¨€¨U¨^¨€¨€¨[ ¨€¨€¨X¨a    ¨^¨T¨T¨€¨€¨X¨T¨T¨a¨€¨€¨U¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨U¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨U     ¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨U ¨€¨€¨X¨a  //
//  ¨€¨€¨€¨€¨€¨€¨€¨U¨€¨€¨X¨€¨€¨[ ¨€¨€¨U¨€¨€¨€¨€¨€¨€¨€¨U¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U     ¨€¨€¨€¨€¨€¨€¨€¨U ¨^¨€¨€¨€¨€¨X¨a        ¨€¨€¨U   ¨€¨€¨U¨€¨€¨X¨€¨€¨€¨€¨X¨€¨€¨U¨€¨€¨€¨€¨€¨[  ¨€¨€¨U     ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U     ¨€¨€¨€¨€¨€¨X¨a   //
//  ¨€¨€¨X¨T¨T¨€¨€¨U¨€¨€¨U¨^¨€¨€¨[¨€¨€¨U¨€¨€¨X¨T¨T¨€¨€¨U¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨U     ¨€¨€¨X¨T¨T¨€¨€¨U  ¨^¨€¨€¨X¨a         ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U¨^¨€¨€¨X¨a¨€¨€¨U¨€¨€¨X¨T¨T¨a  ¨€¨€¨U     ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U     ¨€¨€¨X¨T¨€¨€¨[   //
//  ¨€¨€¨U  ¨€¨€¨U¨€¨€¨U ¨^¨€¨€¨€¨€¨U¨€¨€¨U  ¨€¨€¨U¨€¨€¨U  ¨€¨€¨U¨^¨€¨€¨€¨€¨€¨€¨[¨€¨€¨U  ¨€¨€¨U   ¨€¨€¨U          ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U ¨^¨T¨a ¨€¨€¨U¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[¨^¨€¨€¨€¨€¨€¨€¨X¨a¨^¨€¨€¨€¨€¨€¨€¨[¨€¨€¨U  ¨€¨€¨[  //
//  ¨^¨T¨a  ¨^¨T¨a¨^¨T¨a  ¨^¨T¨T¨T¨a¨^¨T¨a  ¨^¨T¨a¨^¨T¨a  ¨^¨T¨a ¨^¨T¨T¨T¨T¨T¨a¨^¨T¨a  ¨^¨T¨a   ¨^¨T¨a          ¨^¨T¨a   ¨^¨T¨a¨^¨T¨a     ¨^¨T¨a¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨T¨T¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨a  ¨^¨T¨T¨T¨T¨T¨a¨^¨T¨a  ¨^¨T¨a  //
//                                                                                                                                   // 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                                        
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Timelock {
  using SafeMath for uint256;

  // The token being locked
  ERC20 public token;

  // TeamWallet Address where funds are released
  address public teamWallet;
  
  // MarketingWallet Address where funds are released
  address public marketingWallet;
  
  // deployer
  address deployer;

  // lockedTime
  uint256 public lockTime;
  
  // token release flag
  bool public teamToken1stReleased;
  bool public teamToken2ndReleased;
  bool public teamToken3rdReleased;
  bool public teamToken4thReleased;

  bool public marketingTokenReleased;

  function Timelock() public {
    // Anarchy token contract address
    token = ERC20(0xD5f1F1338f7de2FdE3aA132667cbAA671860B9FC);
    
    marketingWallet = 0xE18A44813FB456c79fc79Ad1418bA03A7FEaBfe0;
    teamWallet = 0x827dDdF45B819dEaF6a5cc8f5D0486B131A778cE;
    
    teamToken1stReleased = false;
    teamToken2ndReleased = false;
    teamToken3rdReleased = false;
    teamToken4thReleased = false;
    
    marketingTokenReleased = false;
    lockTime = block.timestamp;
    deployer = msg.sender;
  }

  function releaseMarketingToken() external returns (bool) {
    require(msg.sender == marketingWallet);
    require(marketingTokenReleased == false);
    require(block.timestamp > lockTime + 30 days);
    
    token.transfer(marketingWallet, 5E21);
    marketingTokenReleased == true;
    return true;
  }
  
  function releaseTeamToken1st() external returns (bool) {
    require(msg.sender == teamWallet);
    require(teamToken1stReleased == false);
    require(block.timestamp > lockTime + 90 days);

    token.transfer(teamWallet, 1250E18);
    teamToken1stReleased = true;
    return true;
  }
  
  function releaseTeamToken2nd() external returns (bool) {
    require(msg.sender == teamWallet);
    require(teamToken2ndReleased == false);
    require(block.timestamp > lockTime + 180 days);

    token.transfer(teamWallet, 1250E18);
    teamToken2ndReleased = true;
    return true;
  }
  
  function releaseTeamToken3rd() external returns (bool) {
    require(msg.sender == teamWallet);  
    require(block.timestamp > lockTime + 270 days);
    require(teamToken3rdReleased == false);

    token.transfer(teamWallet, 1250E18);
    teamToken3rdReleased = true;
    return true;
  }
  
  function releaseTeamToken4th() external returns (bool) {
    require(msg.sender == teamWallet);
    require(block.timestamp > lockTime + 360 days);
    require(teamToken4thReleased == false);

    token.transfer(teamWallet, 1250E18);
    teamToken4thReleased = true;
    return true;
  }
  
  function wallet(address _teamWallet, address _marketingWallet) external returns (bool) {
    require(msg.sender == deployer);
    require(_teamWallet != address(0));
    require(_marketingWallet != address(0));
    
    teamWallet = _teamWallet;
    marketingWallet = _marketingWallet;
    return true;
  }
}