pragma solidity ^0.4.0;

contract TestSystem{

  bool public trueOrFalse;
  uint256 public amount;
  address public accountAddress;
  bytes32 public storedDataInBytes;
  string public text;

  function storeData(bool _bool, uint256 _uint, address _address, bytes32 _bytes, string _string) {
    trueOrFalse = _bool;
    amount = _uint;
    accountAddress = _address;
    storedDataInBytes = _bytes;
    text = _string;
  }

  function getData() constant returns (bool _trueOrFalse, uint256 _amount, address _accountAddress, bytes32 _storedDataInBytes, string _text) {
    return (trueOrFalse, amount, accountAddress, storedDataInBytes, text);
  }

}