/**

 *Submitted for verification at Etherscan.io on 2018-11-04

*/



pragma solidity ^0.4.25;



contract Bakery {



  // index of created contracts



  address[] public contracts;



  // useful to know the row count in contracts index



  function getContractCount()

    public

    constant

    returns(uint contractCount)

  {

    return contracts.length;

  }



  // deploy a new contract



  function newCookie()

    public

    returns(address newContract)

  {

    Cookie c = new Cookie();

    contracts.push(c);

    return c;

  }

}





contract Cookie {



  function () public payable {}



  // suppose the deployed contract has a purpose



  function getFlavor()

    public

    constant

    returns (string flavor)

  {

    return "mmm ... chocolate chip";

  }

}