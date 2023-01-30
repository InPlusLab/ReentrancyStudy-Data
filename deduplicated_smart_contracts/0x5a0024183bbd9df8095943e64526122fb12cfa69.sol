pragma solidity 0.4.26;


// Meridian Network token

import "./IERC20.sol";
import "./SafeMath.sol";
import "./meridianToken.sol";
import "./staking.sol";
import "./upgrade.sol";

contract DeployMeridian{
  Meridian public m;
  MeridianStaking public s;
  MeridianUpgrade public u;
  address public previousToken= 0x896a07e3788983ec52eaf0F9C6F6E031464Ee2CC;

  constructor() public{
    m = new Meridian();
    s = new MeridianStaking(address(m));
    u = new MeridianUpgrade(previousToken,address(m));
    m.addBurnExempt(address(s));
    m.addBurnExempt(address(u));
    m.addBurnExempt(msg.sender);
    m.addBurnExempt(address(m));
    m.addBurnExempt(address(this));
    m.addBurnExempt(0x6e347f4D50f0E2F9AD86179e81097eB573920357);
    m.addBurnExempt(0xE7D6989D02dB48c4ffC663b0F770125088C2E6e5);
    m.addBurnExempt(0xB976bdA4F44Fb9d985b9c5C8c4c5362837dE6949);
    m.addBurnExempt(0xDf824317AA0B1CE4c9892b2a70F351b92d5A7236);
    m.addBurnExempt(0x6758744932533CF81523B26ef9074121102116D8);
    m.addBurnExempt(0xd4dEFDb0F2793a2eb84449a22Bf755eF622C1160);
    m.addBurnExempt(0xA1957D7413256464c8a403F2122E8F2b38F6d960);
    m.addBurnExempt(0x7C54B3eb8399f4adff273027f3aBdD200fF82F99);
    m.addBurnExempt(0x5Beaa2C98C42422C37A3B84D2C49c693351A2042);
    m.addBurnExempt(0xEf418EB1Ce666d27cCDd439ef99c62c56CE04971);
    m.addBurnExempt(0xf8E1698cDE2A80B1338d076B1cCEb6Af867Fe5f9);
    m.addBurnExempt(0xb9dd2dFd981778D3274c0b95d42f3931Ea0b8E51);
    m.addBurnExempt(0xBD13322500f95b4D9e046EC0bcc277db46779957);
    m.addBurnExempt(0x44F3899e5256B415B2d0525DB7889a655D966d63);
    m.addBurnExempt(0x0cE8A35B510FF2dCa82177a2a087aa0b579Daf6a);
    m.addBurnExempt(0x82D57DE9380dde5d097672471822CFb5CA4B1126);
    m.addBurnExempt(0x6ea1115b94CDf9B27B66Ae7935341BcD355b72d1);
    m.addBurnExempt(0xfC9F9e1BD38d49C4372eE303794C4b99Dcf15E6b);
    m.addBurnExempt(0xD73E95EDE4251b4B298A2154aA9b55de1A137317);
    m.addBurnExempt(0x4297e9755e4Cc10BaE4cEAaec33d4A11b80D0b19);
    m.addBurnExempt(0xDF862903b3f126D250019cb4524Ca5d0B593Af9A);
    m.addBurnExempt(0x824aDDB051Bb51a958875cf945831a03BC19963C);
    m.addBurnExempt(0x44f2D115219596D2F9d122056d609b81a7Fa4Dd6);
    m.addBurnExempt(0x53e14efD0c49424CC9F0A10c15Be127BE7d5C601);
    m.addBurnExempt(0x677fE73709C75E1a1d8ddD8364E9A1208Ef130F1);
    m.addBurnExempt(0xDf824317AA0B1CE4c9892b2a70F351b92d5A7236);
    m.addBurnExempt(0x6758744932533CF81523B26ef9074121102116D8);
    m.addBurnExempt(0x233dB06cc7aC69333eED55E4b6A6C17A7D589c76);
    m.transfer(address(u),10000000 ether);
    m.transfer(address(s),5000000 ether);
    m.transfer(msg.sender,m.balanceOf(address(this)));
    m.transferOwnership(msg.sender);
  }
}
