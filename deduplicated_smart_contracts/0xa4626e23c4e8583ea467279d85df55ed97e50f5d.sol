/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity 0.5.16;


interface BandOracle {
  enum QueryStatus { INVALID, OK, NOT_AVAILABLE, DISAGREEMENT }

  function query(bytes calldata input)
    external returns (bytes32 output, uint256 updatedAt, QueryStatus status);
}

interface KyberOracle {
  function getExpectedRate(address src, address dest, uint srcQty)
    external returns (uint expectedRate, uint slippageRate);
}

contract KyberBandOracle {
  function getBTCPriceFromBand() public returns (uint256) {
    BandOracle oracle = BandOracle(0xD5D2b9e9bcd172D5fC8521AFd2C98Dd239F5b607);
    (bytes32 output,, BandOracle.QueryStatus status) = oracle.query("SPOTPX/BTC-USD");
    require(status == BandOracle.QueryStatus.OK);
    return uint256(output);
  }
  
  function getBTCPriceFromKyber() public returns (uint256) {
    KyberOracle oracle = KyberOracle(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    (uint256 buyRate,) = oracle.getExpectedRate(
      0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // WBTC
      0x6B175474E89094C44Da98b954EedeAC495271d0F, // DAI
      1
    );
    return buyRate;
  }
    
  function getBTCPriceSafe() public returns (uint256) {
    uint256 priceFromKyber = getBTCPriceFromKyber();
    uint256 priceFromBand = getBTCPriceFromBand();
    uint256 averagePrice = (priceFromKyber + priceFromBand) / 2;
    uint256 difference = priceFromKyber > priceFromBand ? priceFromKyber - priceFromBand : priceFromBand - priceFromKyber;
    // Revert if the two prices differ by more than 10%
    require(difference*10 <= averagePrice);
    // Otherwise, return the average price from the two sources
    return averagePrice;
  }
}