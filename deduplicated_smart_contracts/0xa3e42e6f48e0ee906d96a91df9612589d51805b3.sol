/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

pragma solidity ^0.4.24;


// ----------------------------------------------------------------------------
// MAINNET REDEEM RBAL 
// Author: RBAL Development Team
// Ver 1.0
//
// Deployed to : 0xa3e42e6f48e0ee906d96a91df9612589d51805b3
// Symbol      : RBAL
// Name        : Rebalance Token
// Total supply: 10,000,000
// Decimals    : 18
// Price : enter price
// Details of Contract : Users will be able to Redeem RBAL tokens by sending any Ether amount to contract.
// ------------------------------------------------------------------------------------------------------------



contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract REBALANCE is Owned, SafeMath {
    
   mapping(address => uint256) balances;
   mapping(address => mapping(address => uint)) allowed;
   //uint _totalSupply;
    
   event Transfer(address indexed from, address indexed to, uint tokens);

   function balanceOf(address tokenOwner) public constant returns (uint balance);

   // To release tokens to the address that have send ether.
   function releaseTokens(address _receiver, uint _amount) public;

   // To take back tokens after refunding ether.
   function refundTokens(address _receiver, uint _amount) public;
   
   function transfer(address to, uint tokens) public returns (bool);
   
   function transferFrom(address from, address to, uint tokens) public returns (bool success);

}

contract REBALANCERedeemV2 {

   uint public redeemStart;
   uint public redeemEnd;
   uint public tokenRate;
   REBALANCE public token;   
   uint public fundingGoal;
   uint public tokensRedeemed;
   uint public etherRaised;
   address public owner;
   uint decimals = 18;

   event BuyTokens(address buyer, uint etherAmount);
   event Transfer(address indexed from, address indexed to, uint tokens);
   event BuyerBalance(address indexed buyer, uint buyermoney);
   event TakeTokensBack(address ownerAddress, uint quantity );
   
   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

   

   constructor( uint _tokenRate, address _tokenAddress, uint _fundingGoal) public {

      require( _tokenRate != 0 &&
      _tokenAddress != address(0) &&
      _fundingGoal != 0);
     
      redeemStart = now;
      redeemStart = block.timestamp;
      
      redeemEnd = redeemStart + 4 weeks;
      tokenRate = _tokenRate;
      token = REBALANCE(_tokenAddress);
      fundingGoal = _fundingGoal;
      owner = msg.sender;
   }

   function () public payable {
      buy();
   }

   function buy() public payable {

      emit BuyTokens( msg.sender , msg.value);
	  
      require(msg.sender!=owner);
      require(etherRaised < fundingGoal);
      require(now < redeemEnd && now > redeemStart);
      uint tokensToGet;
      uint etherUsed = msg.value;
      tokensToGet = etherUsed * tokenRate;

      owner.transfer(etherUsed);
      
      // transfer tokens
      token.transfer(msg.sender, tokensToGet);
      
      emit BuyerBalance(msg.sender, tokensToGet);
      
      tokensRedeemed += tokensToGet;
      etherRaised += etherUsed;
   }
   
   function setRedeemEndDate(uint time) public onlyOwner {
        require(time>0);
        redeemEnd = time;
   }
   
   function setFundingGoal(uint goal) public onlyOwner {
        fundingGoal = goal;
   }
   
   function setTokenRate(uint tokenEthMultiplierRate) public onlyOwner {
        tokenRate = tokenEthMultiplierRate;
   }
   
   function takeTokensBackAfterRedeemOver(uint quantity) public onlyOwner {
        token.transfer(owner, quantity);
        emit TakeTokensBack(owner, quantity);
   }
 }