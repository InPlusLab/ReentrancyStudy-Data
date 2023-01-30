/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

pragma solidity 0.6.1;


interface Zxc { 

   
  function name()
    external
    view
    returns (string memory _name);

  
  function symbol()
    external
    view
    returns (string memory _symbol);

  
  function decimals()
    external
    view
    returns (uint8 _decimals);

  
  function totalSupply()
    external
    view
    returns (uint256 _totalSupply);

  
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256 _balance);

  
  function transfer(
    address _to,
    uint256 _value
  )
    external
    returns (bool _success);

  
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    external
    returns (bool _success);

  
  function approve(
    address _spender,
    uint256 _value
  )
    external
    returns (bool _success);

  
  function allowance(
    address _owner,
    address _spender
  )
    external
    view
    returns (uint256 _remaining);

  
  function transferOwnership(
    address _newOwner
  )
    external;

  
  function claimOwnership()
    external;

  
  function enableTransfer()
    external;

  
  function burn(
    uint256 _value
  )
    external;

  
  function setCrowdsaleAddress(
    address crowdsaleAddr
  )
    external;

  
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 _value
  );

  
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _value
  );

   
  event Burn(
    address indexed _burner,
    uint256 _value
  );

}

contract ZxcBurner {
  
  Zxc zxcToken;

  
  constructor(address _zxcAddress)
    public
  {
    zxcToken = Zxc(_zxcAddress);
  }

  
  function claim()
    external
  {
    zxcToken.claimOwnership();
  }

  
  function burn(
    uint256 _value
  )
    external
  {
    zxcToken.transferFrom(msg.sender, address(this), _value);
    zxcToken.burn(_value);
  }
}