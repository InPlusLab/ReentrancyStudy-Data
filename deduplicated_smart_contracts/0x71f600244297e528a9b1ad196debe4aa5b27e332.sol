/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.10;

interface Token {
  function balanceOf(address who) external view returns (uint256);
}

contract BalanceChecker {
  function() external payable {
    revert("BalanceChecker does not accept payments");
  }

  function balances(address[] calldata users, address[] calldata tokens) external view returns (uint256[] memory) {
    uint256[] memory addrBalances = new uint256[](tokens.length * users.length);
    
    for(uint i = 0; i < users.length; i++) {
      for (uint j = 0; j < tokens.length; j++) {
        uint addrIdx = j + tokens.length * i;
        if (tokens[j] != address(0x0)) { 
          addrBalances[addrIdx] = Token(tokens[j]).balanceOf(users[i]);
        } else {
          addrBalances[addrIdx] = users[i].balance;
        }
      }  
    }
  
    return addrBalances;
  }
}