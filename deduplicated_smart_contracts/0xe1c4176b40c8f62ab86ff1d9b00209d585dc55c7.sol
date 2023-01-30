/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

pragma solidity 0.5.12;


interface CTokenInterface {
  function supplyRatePerBlock() external view returns (uint256 rate);
  function exchangeRateStored() external view returns (uint256 rate);
  function accrualBlockNumber() external view returns (uint256 blockNumber);
}


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }
}


contract CUSDCExchangeRateView {
  using SafeMath for uint256;    
    
  uint256 internal constant _SCALING_FACTOR = 1e18;

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 // mainnet
  );   
    
  /**
   * @notice Internal view function to get the current cUSDC exchange rate.
   * @return The current cUSDC exchange rate, or amount of USDC that is redeemable
   * for each cUSDC (with 18 decimal places added to the returned exchange rate).
   */
  function getCurrentExchangeRate() external view returns (uint256 exchangeRate) {
    uint256 storedExchangeRate = _CUSDC.exchangeRateStored();
    uint256 blockDelta = block.number.sub(_CUSDC.accrualBlockNumber());

    if (blockDelta == 0) return storedExchangeRate;

    exchangeRate = blockDelta == 0 ? storedExchangeRate : storedExchangeRate.add(
      storedExchangeRate.mul(
        _CUSDC.supplyRatePerBlock().mul(blockDelta)
      ) / _SCALING_FACTOR
    );
  }
}