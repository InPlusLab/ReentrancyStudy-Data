/**
 *Submitted for verification at Etherscan.io on 2019-06-19
*/

pragma solidity 0.5.1;

/**
 * @title Partial ERC-20 token interface
 */
contract Token {
  function balanceOf(address) public view returns (uint256);
}

/**
 * @title An Ether or token balance scanner
 * @author Maarten Zuidhoorn
 * @author Luit Hollander
 */
contract BalanceScanner {
  /**
   * @notice Get the Ether balance for all addresses specified
   * @param addresses The addresses to get the Ether balance for
   * @return The Ether balance for all addresses in the same order as specified
   */
  function etherBalances(address[] calldata addresses) external view returns (uint256[] memory balances) {
    balances = new uint256[](addresses.length);

    for (uint256 i = 0; i < addresses.length; i++) {
      balances[i] = addresses[i].balance;
    }
  }

  /**
   * @notice Get the ERC-20 token balance of `token` for all addresses specified
   * @dev This does not check if the `token` address specified is actually an ERC-20 token
   * @param addresses The addresses to get the token balance for
   * @param token The address of the ERC-20 token contract
   * @return The token balance for all addresses in the same order as specified
   */
  function tokenBalances(address[] calldata addresses, address token) external view returns (uint256[] memory balances) {
    balances = new uint256[](addresses.length);
    Token tokenContract = Token(token);

    for (uint256 i = 0; i < addresses.length; i++) {
      balances[i] = tokenContract.balanceOf(addresses[i]);
    }
  }

  /**
    * @notice Get the ERC-20 token balance from multiple contracts for a single owner
    * @param owner The address of the token owner
    * @param contracts The addresses of the ERC-20 token contracts
    * @return The token balances in the same order as specified
   */
  function tokensBalance(address owner, address[] calldata contracts) external view returns (uint256[] memory balances) {
    balances = new uint256[](contracts.length);

    for(uint256 i = 0; i < contracts.length; i++) {
      uint256 size = codeSize(contracts[i]);

      if(size == 0) {
        balances[i] = 0;
      } else {
        Token tokenContract = Token(contracts[i]);
        balances[i] = tokenContract.balanceOf(owner);
      }
    }
  }

  /**
    * @notice Get code size of address
    * @param _address The address to get code size from
    * @return Unsigned 256-bits integer
   */
  function codeSize(address _address) internal view returns (uint256 size) {
    assembly {
      size := extcodesize(_address)
    }
  }
}