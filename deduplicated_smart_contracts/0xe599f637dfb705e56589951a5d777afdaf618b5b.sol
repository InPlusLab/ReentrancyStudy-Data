/**

 *Submitted for verification at Etherscan.io on 2018-12-09

*/



/*

 * DO NOT EDIT! DO NOT EDIT! DO NOT EDIT!

 *

 * This is an automatically generated file. It will be overwritten.

 *

 * For the original source see

 *    '/Users/swaldman/Dropbox/BaseFolders/development-why/gitproj/eth-who-am-i/src/main/solidity/WhoAmI.sol'

 */



pragma solidity ^0.4.24;



contract WhoAmI {

  function whoAmI() public view returns (address me) {

     me = msg.sender;

  }

}