/**

 *Submitted for verification at Etherscan.io on 2018-08-10

*/



pragma solidity ^0.4.23;



contract Destroy{

      function delegatecall_selfdestruct(address _target) external returns (bool _ans) {

          _ans = _target.delegatecall(bytes4(sha3("address)")), this); 

      }

}