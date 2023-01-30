/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.10;

// ERC20 contract interface
contract Token {
  function balanceOf(address) public view returns (uint);
}

contract BalanceChecker {
  /* Fallback function, don't accept any ETH */
  function() external payable {
    revert("BalanceChecker does not accept payments");
  }

  function tokenBalance(address user, address token) public view returns (uint256) {
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
  
    if (tokenCode > 0) {  
      return Token(token).balanceOf(user);
    } else {
      return 0;
    }
  }

  function balances(address[] calldata users, address[] calldata tokens) external view returns (uint256[] memory) {
    uint256[] memory addrBalances = new uint256[](tokens.length * users.length);
    
    for(uint i = 0; i < users.length; i++) {
      for (uint j = 0; j < tokens.length; j++) {
        uint addrIdx = j + tokens.length * i;
        if (tokens[j] != address(0x0)) { 
          addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
        } else {
          addrBalances[addrIdx] = users[i].balance; // ETH balance    
        }
      }  
    }
  
    return addrBalances;
  }
}