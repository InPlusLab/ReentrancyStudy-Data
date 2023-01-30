/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

pragma solidity 0.5.11;


interface IERC20 {
  function balanceOf(address) external view returns (uint256);
}


contract DepositStateChecker {
  enum DepositState {
    NoContractNoFunds,
    NoContractDust,
    NoContractSufficientFunds,
    ContractNoFunds,
    ContractDust,
    ContractSufficientFunds
  }
    
  IERC20 internal constant _DAI = IERC20(
    0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359 // mainnet
  );

  IERC20 internal constant _USDC = IERC20(
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet
  );
  
  // Minimum supported deposit & non-maximum withdrawal size is .001 underlying.
  uint256 private constant _JUST_UNDER_ONE_1000th_DAI = 999999999999999;
  uint256 private constant _JUST_UNDER_ONE_1000th_USDC = 999;
  
  function getDepositStates(
    address[] calldata smartWallets
  ) external view returns (
    DepositState[] memory depositStates
  ) {
    depositStates = new DepositState[](smartWallets.length);
    address smartWallet;
    uint256 size;
    uint256 daiBalance;
    uint256 usdcBalance;
    for (uint256 i = 0; i < smartWallets.length; i++) {
      smartWallet = smartWallets[i];
      assembly { size := extcodesize(smartWallet) }
      
      daiBalance = _DAI.balanceOf(smartWallet);
      if (daiBalance > _JUST_UNDER_ONE_1000th_DAI) {
        depositStates[i] = (
          size == 0 ?
            DepositState.NoContractSufficientFunds :
            DepositState.ContractSufficientFunds
        );
        continue;
      }
      
      usdcBalance = _USDC.balanceOf(smartWallet);
      if (daiBalance > _JUST_UNDER_ONE_1000th_DAI) {
        depositStates[i] = (
          size == 0 ?
            DepositState.NoContractSufficientFunds :
            DepositState.ContractSufficientFunds
        );
        continue;
      }
      
      if (daiBalance == 0 && usdcBalance == 0) {
        depositStates[i] = (
          size == 0 ?
            DepositState.NoContractNoFunds :
            DepositState.ContractNoFunds
        );
      } else {
        depositStates[i] = (
          size == 0 ?
            DepositState.NoContractDust :
            DepositState.ContractDust
        );
      }
    }
  }
}