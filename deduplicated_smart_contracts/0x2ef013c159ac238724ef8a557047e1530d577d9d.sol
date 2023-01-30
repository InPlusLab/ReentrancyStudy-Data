/**

 *Submitted for verification at Etherscan.io on 2019-03-30

*/



pragma solidity ^0.5.0;





contract ProxyTest {



    event ETHSent(uint amt);



    function sendETH(uint amt) public payable {

        msg.sender.transfer(amt);

        emit ETHSent(amt);

    }



}