/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

pragma solidity ^0.4.11;


contract ERC20PreSale {
    ERC20 public token;
    address public owner;
    uint public amountRaised;
    uint public rate;  


    function ERC20PreSale(
        ERC20 _token,
        uint256 _rate
    ) {
        token = ERC20(_token);
        owner = msg.sender;
        rate = _rate;
    }

    function () payable {
       buyToken();
    }
   function buyToken() public payable {
        uint amount = msg.value;
        uint tokenAmount = amount * rate;
        require(tokenAmount  <= token.balanceOf(address(this)));
        amountRaised += tokenAmount;
        token.transfer(msg.sender, tokenAmount);
    }
    function withdrawToken() public payable {
        require(msg.sender == owner);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }


    function TransferETH(address _to, uint _amount) {
        require(msg.sender == owner);
        _to.transfer(_amount);
    }
    function changeRate(uint _rate) {
        require(msg.sender == owner);
        rate = _rate;
    }
    function amountRaised() public view returns(uint) {
        return amountRaised;
    }
     function rate() public view returns(uint) {
        return rate;
    }
    function maxAllowed() public view returns(uint) {
        return token.balanceOf(address(this));
    }
}
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}