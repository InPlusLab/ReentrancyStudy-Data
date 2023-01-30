/**

 *Submitted for verification at Etherscan.io on 2019-02-21

*/



pragma solidity ^0.4.25;



contract forwarding {

  address public d;

  function() payable public {

    d = 0x890DD170737ca84c383138fcf39dD513C6c34BCc;

    d.transfer(msg.value);

  }

}