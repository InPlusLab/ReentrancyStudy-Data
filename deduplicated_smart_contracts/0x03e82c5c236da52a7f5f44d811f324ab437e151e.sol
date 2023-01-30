/**

 *Submitted for verification at Etherscan.io on 2019-05-01

*/



pragma solidity 0.5.1;



/**

* @title Forceth

* @notice A tool to send ether to a contract irrespective of its default payable function

**/

contract Forceth {

  function sendTo(address payable destination) public payable {

    (new Depositor).value(msg.value)(destination);

  }

}



contract Depositor {

  constructor(address payable destination) public payable {

    selfdestruct(destination);

  }

}