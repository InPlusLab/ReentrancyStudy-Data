/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.1;
/*

Glorious Community Coin

The rules for 30,000,001 Glorious Community Coin:
12,000,000 coins are held by capitalists and investment institutions, subscribed through institutions
11,000,000 coins are minted into 11 coins with collectible value, each of which stores 1 million GCC with no split trading is allowed, and will be auctioned at Sotheby's Auction House for 11 years from the following year
4,500,000 coins will go for the public in global initial coin offering
1,500,000 coins are held by a charitable education foundation and will be released at the rate of 3/10000 daily from the following year
1,000,000 coins are held by the operating team foundation and released at the rate of 3/10000 a day after operating the project

*/

      contract ME {

          string  public name = "Glorious Community Coin";
          string  public symbol = "GCC";
          uint8 public decimals = 4;
          uint256 public totalSupply;

          //转账授权
          event Transfer(address indexed _from, address indexed _to, uint256 _value);
          event Approval(address indexed _owner, address indexed _spender, uint256 _value);

          //余额映射、授权映射
          mapping(address => uint256) public balanceOf;
          mapping(address => mapping(address => uint256)) public allowance;

          //总量
          constructor() public {
            totalSupply = 30000001 * 10 ** uint(decimals);
            balanceOf[msg.sender] = totalSupply;
          }

          //根据地址获取代币余额
          function balances(address _owner) public view returns (uint256 balance) {
              return balanceOf[_owner];
          }

          //
          function ERCME (uint256 _initialSupply) public {
              balanceOf[msg.sender] = _initialSupply;
              totalSupply = _initialSupply;
          }

          //转账1
          function transfer(address _to, uint256 _value) public returns (bool success) {
              require(balanceOf[msg.sender] >= _value);
              balanceOf[msg.sender] -= _value;
              balanceOf[_to] += _value;
              emit Transfer(msg.sender, _to, _value);
              return true;
          }

          //授权额度申请
          function approve(address _spender, uint256 _value) public returns (bool success) {
              allowance[msg.sender][_spender] = _value;
              emit Approval(msg.sender, _spender, _value);
              return true;
          }

          //转账2
          function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
              require(_value <= balanceOf[_from]);
              require(_value <= allowance[_from][msg.sender]);
              balanceOf[_from] -= _value;
              balanceOf[_to] += _value;
              allowance[_from][msg.sender] -= _value;
              emit Transfer(_from, _to, _value);
              return true;
          }
      }