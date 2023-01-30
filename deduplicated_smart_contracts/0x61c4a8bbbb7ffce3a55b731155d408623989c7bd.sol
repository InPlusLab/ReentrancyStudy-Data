/**

 *Submitted for verification at Etherscan.io on 2019-03-20

*/



pragma solidity ^0.5.0;





contract ProxyTest {



    event ETHSent(uint amt);



    function sendETH() public payable {

        address(msg.sender).transfer(msg.value);

        emit ETHSent(msg.value);

    }



}