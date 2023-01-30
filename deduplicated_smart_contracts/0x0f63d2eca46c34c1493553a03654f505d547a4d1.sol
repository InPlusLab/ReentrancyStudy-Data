/**
 *Submitted for verification at Etherscan.io on 2020-06-28
*/

pragma solidity ^0.4.18;
// -------------------------------------------------
// Coronnavirus Economic Relief Fund 90% payouts / 10% overhead with Ethereum tokenized investment potential via future Exchange trading
// aronline.io
// COR token sale contract
// static priced at 5000 tokens per Eth
// 1 vote per Token re: payouts
// COR foundation retaining 47% of initial supply (149,460,000 of 318,000,000)
// -------------------------------------------------
contract owned {
    address public owner;

    function owned() internal {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract safeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    safeAssert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    safeAssert(b > 0);
    uint256 c = a / b;
    safeAssert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    safeAssert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    safeAssert(c>=a && c>=b);
    return c;
  }

  function safeAssert(bool assertion) internal pure {
    if (!assertion) revert();
  }
}

contract StandardToken is owned, safeMath {
  function balanceOf(address who) view public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract CORCrowdsale is owned, safeMath {
  // owner/admin & token reward
  address        public admin                     = owner;    // admin address
  StandardToken  public tokenReward;                          // address of the token used as reward

  // deployment variables for static supply sale
  uint256 public initialSupply;

  // multi-sig addresses and price variable
  address public beneficiaryWallet;
  uint256 public tokensPerEthPrice;                           // set initial value floating priceVar 1,500 tokens per Eth

  // uint256 values for min,max,caps,tracking
  uint256 public amountRaisedInWei;                           //

  // loop control, ICO startup and limiters
  string  public currentStatus                   = "Crowdsale is setup";
  bool    public isCrowdSaleSetup                = true;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Buy(address indexed _sender, uint256 _eth, uint256 _COR);
  event Burn(address _from, uint256 _value);

  // default function, map admin
  function CORCrowdsale() public onlyOwner {
          admin = msg.sender;
          currentStatus                           = "Crowdsale deployed to chain";
          tokenReward                             = StandardToken(0xf2DfD1658Bf984F106B403352E4e4691860294B5);
          beneficiaryWallet                       = 0xf173a871D7b05E793bF15A208009759681779493;
          tokensPerEthPrice                       = 5000;
          amountRaisedInWei                       = 0;
          isCrowdSaleSetup                        = true;
  }

  // total number of tokens initially
  function initialCORSupply() public view returns (uint256 tokenTotalSupply) {
      return safeDiv(initialSupply,100);
  }

    
  function BuyCORtokens() public payable {
      // 0. conditions
      require(!(msg.value == 0));

      // 2. effects
      amountRaisedInWei               = safeAdd(amountRaisedInWei,msg.value);

      // 3. interaction
      tokenReward.transfer(msg.sender, safeMul(tokensPerEthPrice,1000000000000000000));
  }

  function beneficiaryMultiSigWithdraw(uint256 _amount) public onlyOwner {
      beneficiaryWallet.transfer(_amount);
  }

    // default payable function when sending ether to this contract
  function () public payable {
      require(msg.data.length == 0);
      BuyCORtokens();
  }
}