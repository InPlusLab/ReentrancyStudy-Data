/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.4.25;



interface ERC20Token {

  function transfer( address to, uint256 quantity ) external;

}



contract Ownable {

  address public owner;

  constructor() public { owner = msg.sender; }



  function chown( address newowner ) isOwner public { owner = newowner; }



  modifier isOwner {

    require( msg.sender == owner );

    _;

  }

}



contract DecentraSearch is Ownable {



  event SiteSubmitted( string url,

                       string title,

                       string meta );



  uint256 public fee_ = 1 finney;



  function submit( string _url,

                   string _title,

                   string _meta ) public payable {

    require( msg.value >= fee_ );

    emit SiteSubmitted( _url, _title, _meta );

  }



  function setFee( uint _fee ) isOwner public {

    fee_ = _fee;

  }



  function retrieve( uint _amount ) isOwner public {

    owner.transfer( _amount );

  }



  function fwdTokens( address _toksca,

                      address _to,

                      uint256 _quantity ) isOwner public {

    ERC20Token(_toksca).transfer( _to, _quantity );

  }

}