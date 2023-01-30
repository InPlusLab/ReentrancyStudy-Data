/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.4.18;
// -------------------------------------------------
// Coronnavirus Economic Relief Fund 90% payouts / 10% overhead with Ethereum tokenized investment potential via future Exchange trading
// aronline.io
// COR token sale contract
// static priced at 5000 tokens per Eth
// 1 vote per Token re: payouts
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
  address        public admin                     = owner;
  StandardToken  public tokenReward;

  // multi-sig addresses and price variable
  address public beneficiaryWallet;
  uint256 public tokensPerEthPrice;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // default function, map admin
  function CORCrowdsale() public onlyOwner {
          admin = msg.sender;
          tokenReward                             = StandardToken(0xB3352b5Da464f81DcD860d84CaCf5e254467D6c2);
          beneficiaryWallet                       = 0xf173a871D7b05E793bF15A208009759681779493;
          tokensPerEthPrice                       = 5000;
  }

  function BuyCORtokens() public payable {
    require(!(msg.value == 0));
    tokenReward.transfer(msg.sender, safeMul(tokensPerEthPrice,msg.value));
  }

  function () public payable {
    require(msg.data.length == 0);
    BuyCORtokens();
  }

  function beneficiaryMultiSigWithdraw(uint256 _amount) public onlyOwner {
    beneficiaryWallet.transfer(_amount);
  }
}