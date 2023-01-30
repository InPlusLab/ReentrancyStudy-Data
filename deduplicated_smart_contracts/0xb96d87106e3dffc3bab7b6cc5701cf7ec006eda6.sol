/**

 *Submitted for verification at Etherscan.io on 2019-03-03

*/



pragma solidity ^0.4.23;





contract ProxyTest {



    event ETHSent(uint amt);



    function sendETH() public payable {

        address(msg.sender).transfer(msg.value);

        emit ETHSent(msg.value);

    }



}