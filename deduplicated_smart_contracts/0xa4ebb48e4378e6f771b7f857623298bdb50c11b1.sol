/*
 * DO NOT EDIT! DO NOT EDIT! DO NOT EDIT!
 *
 * This is an automatically generated file. It will be overwritten.
 *
 * For the original source see
 *    &#39;/Users/ragolta/ETH/swaldman/helloworld/src/main/solidity/helloworld.sol&#39;
 */

pragma solidity ^0.4.18;





contract HelloWorld{
    string input = "Hello world.";

    function sayHello() view public returns (string) {
        return input;
    }

    function setNewGreeting(string greeting) public {
        input = greeting;
    }
}