/**
 *Submitted for verification at Etherscan.io on 2019-07-21
*/

pragma solidity >0.4.99 <0.6.0;

contract Username {
  event Updated(address indexed user, bytes32 username);

  mapping(address => bytes32) public username;
  mapping(bytes32 => bool) public used;

  function Update(bytes32 _username) public {
    require(!used[_username]);
    bytes32 oldUserName = username[msg.sender];
    used[_username] = true;
    used[oldUserName] = false;
    username[msg.sender] = _username;
    emit Updated(msg.sender, _username);
  }
}