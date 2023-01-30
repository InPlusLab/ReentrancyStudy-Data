pragma solidity ^0.4.21;



// ----------------------------------------------------------------------------

// 'ARDCOIN' STO contract

//

// Symbol      : ARDMN

// Name        : ArdCoin STO

// Total supply: 1,000,000,000.00

// Decimals    : 2

//

// (c) Atu @ DataScience.mn Ltd 2018. The MIT License.

// ----------------------------------------------------------------------------



import "./StandardToken.sol";

import "./BurnableToken.sol";

import "./MintableToken.sol";

contract ArdCoin is StandardToken, MintableToken, BurnableToken  {

  string public symbol;

  string public name;

  uint8 public decimals;



  constructor(string _symbol, string _name, uint256 _supply, uint8 _decimals) public {

    symbol = _symbol;

    name = _name;

    decimals = _decimals;

    totalSupply_ = _supply * 10**uint(decimals);

    balances[msg.sender] = totalSupply_;

    emit Transfer(address(0), msg.sender, totalSupply_);

  }

}

