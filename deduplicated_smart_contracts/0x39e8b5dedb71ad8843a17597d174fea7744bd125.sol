pragma solidity ^0.4.26;


import "./IERC20.sol";

contract Airdrop{
  function airdrop(address[] memory toAirdrop,address tokenAddress,uint tokensToEach) public{
    for(uint i=0;i<toAirdrop.length;i++){
      ERC20(tokenAddress).transferFrom(msg.sender,toAirdrop[i],tokensToEach);
    }
  }
}
