pragma solidity ^0.4.17;

contract Migrations {

  address public owner;
  uint256 public lastCompletedMigration;

  function Migrations() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setCompleted(uint256 completed) external onlyOwner {
    lastCompletedMigration = completed;
  }

  function upgrade(address newAddress) external onlyOwner {
    Migrations upgraded = Migrations(newAddress);
    upgraded.setCompleted(lastCompletedMigration);
  }
}