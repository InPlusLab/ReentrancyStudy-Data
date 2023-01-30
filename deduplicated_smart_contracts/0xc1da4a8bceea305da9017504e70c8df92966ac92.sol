/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

contract A  {

    address internal constant ONE_INCH_ADDRESS = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;
   
    uint256 public v1 = 1;   
    uint256 public v2 = 2;
   
    event Ev1( uint256  v1, uint256  v2);

    function A1 () public {
       
        v1 = 11;  /*this does not work*/
         
 
        ONE_INCH_ADDRESS.call(abi.encodeWithSignature(
                                "getExpectedReturn(address,address,uint256,uint256,uint256)",
                                                    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                                                    0x6B175474E89094C44Da98b954EedeAC495271d0F,
                                                    1000000000000000000, 100, 0));
        v2 = 22; /* this works*/

        emit Ev1(v1, v2); /* here v1 is 1 but should be 11 ! and v2 is 22*/
    }
}