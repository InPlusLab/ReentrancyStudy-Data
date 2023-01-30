/**
 * SPDX-License-Identifier: MIT
 */

pragma solidity >=0.7;

import "./MarketMaker.sol";

contract MarketMakerFactory {

  event ContractDeployed(address contractAddress);
    
  function create(bytes32 salt, address baseCurrency, address shareToken) public returns (address) {
    MarketMaker marketMaker = new MarketMaker{salt: salt}();
    marketMaker.initialize(baseCurrency, shareToken);
    emit ContractDeployed(address(marketMaker));
    marketMaker.transferOwnership(msg.sender);
    return address(marketMaker);
  }
}