/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

// Price Oracle for Stabilize Protocol
// This contract uses Aave Price Oracle
// The main Operator contract can change which Price Oracle it uses

// Updated to use Chainlink upgrade

pragma solidity ^0.6.6;

/************
IPriceOracleGetter interface
Interface for the Aave price oracle.
*/
interface IPriceOracleGetter {
    function getAssetPrice(address _asset) external view returns (uint256);
    function getAssetsPrices(address[] calldata _assets) external view returns(uint256[] memory);
    function getSourceOfAsset(address _asset) external view returns(address);
    function getFallbackOracle() external view returns(address);
}

interface LendingPoolAddressesProvider {
    function getPriceOracle() external view returns (address);
}

interface AggregatorV3Interface {
  function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

interface zaToken {
    // For the proxy tokens
    function underlyingAsset() external view returns (address);
}

contract StabilizePriceOracle {
    function getPrice(address _address) external view returns (uint256) {
        // This version of the price oracle will use Aave contracts
        
        // First get the Ethereum USD price from Chainlink Aggregator
        // Mainnet address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        // Kovan address: 0x9326BFA02ADD2366b30bacB125260Af641031331
        AggregatorV3Interface ethOracle = AggregatorV3Interface(address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        ( , int intEthPrice, , , ) = ethOracle.latestRoundData(); // We only want the answer 
        uint256 ethPrice = uint256(intEthPrice);
        
        address underlyingAsset;
        // zaTokens store their underlying asset address in the contract
        try zaToken(_address).underlyingAsset() returns (address) {
            // If this address has that method, this will work
            underlyingAsset = zaToken(_address).underlyingAsset();
        }catch{
            underlyingAsset = _address;
        }
        
        // Retrieve PriceOracle address
        // Mainnet address: 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
        // Kovan address: 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8));
        address priceOracleAddress = provider.getPriceOracle();
        IPriceOracleGetter priceOracle = IPriceOracleGetter(priceOracleAddress);

        uint256 price = priceOracle.getAssetPrice(underlyingAsset); // This is relative to Ethereum, need to convert to USD
        ethPrice = ethPrice / 10000; // We only care about 4 decimal places from Chainlink priceOracleAddress
        price = price * ethPrice / 10000; // Convert to Wei format
        return price;
    }
}