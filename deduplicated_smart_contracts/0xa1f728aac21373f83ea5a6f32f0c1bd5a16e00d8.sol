/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity 0.4.25;

contract Balls {

string messageString = "Welcome to the Project 0xbt.net";

    

    function getPost() public constant returns (string) {

        return messageString;

    }

    

    function setPost(string newPost) public {

        messageString = newPost;

    }

    

}