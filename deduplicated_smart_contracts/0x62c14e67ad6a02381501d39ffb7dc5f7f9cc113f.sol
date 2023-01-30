/**
 *Submitted for verification at Etherscan.io on 2020-02-21
*/

pragma solidity >=0.4.21 <0.7.0;


contract IDai {
  function transferFrom(address src, address dst, uint wad) public returns (bool) {}
  function permit(address holder, address spender, uint256 nonce, uint256 expiry,
    bool allowed, uint8 v, bytes32 r, bytes32 s) external {}
}

contract DaiExtender {

  // kovan
  //  address public constant DAI_ADDRESS = '0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa';

  // mainnet
  address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  IDai public daiContract;

  address public constant WALLET = 0x7671f5bce54fA9760900C52BCB870Ac1fc2dbdFf;

  constructor() public {
    daiContract = IDai(DAI_ADDRESS);
  }

  function permitAndTransfer(address holder, address spender, uint256 nonce, uint256 expiry,
    uint256 amount, uint8 v, bytes32 r, bytes32 s) public {

    daiContract.permit(holder, spender, nonce, expiry, amount>0, v, r, s);
    daiContract.transferFrom(holder, WALLET, amount);
  }
}