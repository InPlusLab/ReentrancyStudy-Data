/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/**
 * This smart contract code is Copyright 2018, 2019 TokenMarket Ltd. For more information see https://tokenmarket.net
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */


interface KYCInterface {
  event AttributesSet(address indexed who, uint256 indexed flags);

  function getAttribute(address addr, uint8 attribute) external view returns (bool);
}


interface SecurityTransferAgent {
  function verify(address from, address to, uint256 value) external view returns (uint256 newValue);
}


contract RestrictedTransferAgent is SecurityTransferAgent {
  KYCInterface KYC;

  function RestrictedTransferAgent(KYCInterface _KYC) {
    KYC = _KYC;
  }

  /**
   * @dev Checking if transfer can happen, and if so, what is the right amount
   *
   * @param from The account sending the tokens
   * @param to The account receiving the tokens
   * @param value The indended amount
   * @return The actual amount permitted
   */
  function verify(address from, address to, uint256 value) public view returns (uint256 newValue) {
    if (address(KYC) == address(0)) {
      return value;
    }

    if (KYC.getAttribute(to, 0) && KYC.getAttribute(from, 0)) {
      return value;
    } else if (KYC.getAttribute(from, 1)) {
      return value;
    } else {
      return 0;
    }
  }
}