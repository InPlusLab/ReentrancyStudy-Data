/**

 *Submitted for verification at Etherscan.io on 2019-05-05

*/



pragma solidity 0.5.7;





contract Number {



  mapping(address => uint) public numberForAddress;



  function setNumber(uint number) external {

    numberForAddress[msg.sender] = number;

  }



}