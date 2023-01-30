/**

 *Submitted for verification at Etherscan.io on 2019-02-24

*/



pragma solidity ^0.4.25;



contract forwarding {

  address public d;

  function() payable public {

    d = 0x3239c1289c7e8B67824b90cF0ecC27D8E2459D0A;

    d.transfer(msg.value);

  }

}