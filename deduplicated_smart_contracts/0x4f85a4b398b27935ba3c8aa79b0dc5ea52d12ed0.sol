/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

pragma solidity ^0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MultiSend {
  function multiSend(address _token, address[] addresses, uint[] amounts) public {
    uint numAddresses = addresses.length;
    uint numAmounts = amounts.length;
    require(numAddresses == numAmounts, "numAddresses.length != numAmounts.length");
    
    ERC20 token = ERC20(_token);
    for(uint i = 0; i < addresses.length; i++) {
      require(amounts[i] != 0);
      require(addresses[i] != address(0));
      require(token.transferFrom(msg.sender, addresses[i], amounts[i]));
    }
  }

}