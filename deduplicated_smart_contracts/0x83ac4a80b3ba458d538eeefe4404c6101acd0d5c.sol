/**

 *Submitted for verification at Etherscan.io on 2018-10-27

*/



pragma solidity ^0.4.24;



/// @author David Li

contract Migrations {

  address public owner;

  uint public last_completed_migration;



  modifier restricted() {

    if (msg.sender == owner) _;

  }

  

  /// @dev classic migrations

  constructor() public {

    owner = msg.sender;

  }



  /// @param completed integer 

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;

  }



  /// @param new_address Ethereum address for new migration 

  function upgrade(address new_address) public restricted {

    Migrations upgraded = Migrations(new_address);

    upgraded.setCompleted(last_completed_migration);

  }

}