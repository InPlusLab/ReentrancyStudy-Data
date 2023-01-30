/**

 *Submitted for verification at Etherscan.io on 2019-04-02

*/



pragma solidity ^0.4.15;



contract FiatContract {

  function ETH(uint _id) constant returns (uint256);

  function USD(uint _id) constant returns (uint256);

  function EUR(uint _id) constant returns (uint256);

  function GBP(uint _id) constant returns (uint256);

  function updatedAt(uint _id) constant returns (uint);

}



contract Example {



    FiatContract public price;

    event NewPayment(address sender, uint256 amount);



    function Example() {

        price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);

    }



    // returns $5.00 USD in ETH wei.

    function FiveETHUSD() constant returns (uint256) {

        // returns $0.01 ETH wei

        uint256 ethCent = price.USD(0);

        // $0.01 * 500 = $5.00

        return ethCent * 500;

    }



    function DoCall() external payable returns (string) {

        require(msg.value==FiveETHUSD());

        NewPayment(msg.sender, msg.value);

        return "you paid $5.00 USD!!!";

    }



}