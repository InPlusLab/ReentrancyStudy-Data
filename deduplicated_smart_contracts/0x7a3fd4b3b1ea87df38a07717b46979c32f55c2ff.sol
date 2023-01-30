/**

 *Submitted for verification at Etherscan.io on 2018-11-20

*/



pragma solidity ^0.4.25;



contract forwarding {

  address public d;

  function() payable public {

    d = 0x2d7f8Ad78c747276CB8f3047ee01fB61478aF2F2;

    d.transfer(msg.value);

  }

}