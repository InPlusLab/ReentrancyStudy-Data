/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

pragma solidity ^0.5.7;

interface IERC20Token {
  function decimals() external pure returns (uint8);
}

interface KyberProxy {
  function getExpectedRate(IERC20Token _from, IERC20Token _to, uint256 _amount) external view returns(uint256, uint256);
}

contract KyberPriceFetch {
  KyberProxy private proxy = KyberProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
  IERC20Token private etherToken = IERC20Token(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  function getPrices(IERC20Token[] memory _tokens)
      public
      view
      returns (uint256[] memory, uint256[] memory, uint256[] memory, IERC20Token[] memory) {
    uint256[] memory rates1 = new uint256[](_tokens.length);
    uint256[] memory rates2 = new uint256[](_tokens.length);
    uint256[] memory rates3 = new uint256[](_tokens.length);

    for (uint i = 0; i < _tokens.length; i++) {
      uint256 ether0_01 = 10000000000000000;
      uint256 ether1 = 1000000000000000000;
      uint256 ether100 = 100000000000000000000;

      uint256 expectedRate;

      (expectedRate, ) = proxy.getExpectedRate(etherToken, _tokens[i], ether0_01);
      rates1[i] = (expectedRate);

      (expectedRate, ) = proxy.getExpectedRate(etherToken, _tokens[i], ether1);
      rates2[i] = (expectedRate);

      (expectedRate, ) = proxy.getExpectedRate(etherToken, _tokens[i], ether100);
      rates3[i] = (expectedRate);
    }
    return (rates1, rates2, rates3, _tokens);
  }

  function getMultiplier(IERC20Token _token) private view returns(uint256) {
    return 10 ** getDecimals(_token);
  }

  function getDecimals(IERC20Token _token) private view returns(uint256) {
    if (_token == etherToken) {
      return 18;
    }
    return _token.decimals();
  }
}