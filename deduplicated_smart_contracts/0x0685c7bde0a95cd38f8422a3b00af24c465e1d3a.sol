/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.25;



contract FundEIF {



  address public destinationAddress;

  event Logged(address indexed sender, uint amount, uint256 timestamp, bool sent);



  constructor() public {

    destinationAddress = 0x35027a992A3c232Dd7A350bb75004aD8567561B2;  //EasyInvestForever

  }

  

  function () external payable {

      emit Logged(msg.sender, msg.value, now, msg.sender != destinationAddress);

      if (msg.sender != destinationAddress) {  //prevents sending interest back immediately

         if(!destinationAddress.call.value(address(this).balance)()) {

            revert();

         }

      } 

  }



}