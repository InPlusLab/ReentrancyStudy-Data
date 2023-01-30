/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity 0.5.11;

contract BalanceChecker {

  function balances(address[] calldata users) external view returns (uint[] memory) {
    uint[] memory addrBalances = new uint[](users.length);
    
    for(uint i = 0; i < users.length; i++) {
        addrBalances[i] = users[i].balance;
    }
  
    return addrBalances;
  }

}