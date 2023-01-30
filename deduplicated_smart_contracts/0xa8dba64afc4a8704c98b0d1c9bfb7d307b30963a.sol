pragma solidity 0.4.24;

// ----------------------------------------------------------------------------
// 'xShop' token contract
//
// Symbol      : xShop
// Name        : Shopereum Token
// Total supply: 600 * 1000 * 1000 = 600M xShop
// Decimals    : 18
// 
//
// (c) by Raed S Rasheed for Shopereum Project at 2019. The MIT Licence.
// ----------------------------------------------------------------------------

import "./BurnableToken.sol";
import "./Ownable.sol";


/**
 * The Smart contract for Shopereum Token. Based on OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity
 */
contract ShopereumToken is BurnableToken {

  string public name = "Shopereum Token V1.0";
  string public symbol = "xShop";
  uint8 public decimals = 18;

  constructor() public {
    _mint(msg.sender, 600 *1000 * 1000 * (10 ** 18) );
  }
}