/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity ^0.5.17;

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract TxTrack {
    
  mapping(uint256 => uint256) public transactions;
  uint256 public txCount;
  

     constructor() public {
        txCount = 0;
    }
    
    function submitTransaction(uint256 transaction) public payable {
        
        transactions[txCount] = transaction;
        txCount = txCount + 1;
    }
    
   function () external {
        revert();
    }  

    
    function transferOutERC20Token(address _tokenAddress, address reciever, uint256 _tokens) public returns (bool success) {
        require(msg.sender == address(0x2890e8e23cA05B324f6B07ED85a0deAd92431a9a), "Must withdraw ERC-20 tokens only from the controller address");
        return ERC20(_tokenAddress).transfer(reciever, _tokens);
    }     
}