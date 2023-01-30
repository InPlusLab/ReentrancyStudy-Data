/**

 *Submitted for verification at Etherscan.io on 2018-08-21

*/



pragma solidity ^0.4.17;



contract ENS {

    address public owner;

    mapping(string=>address)  ensmap;

    mapping(address=>string)  addressmap;

    

    constructor() public {

        owner = msg.sender;

    }

     //��������

     function setEns(string newEns,address addr) onlyOwner public{

          ensmap[newEns] = addr;

          addressmap[addr] = newEns;

     }

     

    //ͨ��ens��ȡ0x��ַ

     function getAddress(string aens) view public returns(address) {

           return ensmap[aens];

     }

	 //ͨ��address��ȡ����

     function getEns(address addr) view public returns(string) {

           return addressmap[addr];

     }

    //����ӵ����

    function transferOwnership(address newOwner) onlyOwner public {

        if (newOwner != address(0)) {

            owner = newOwner;

        }

    }



     //����ӵ���� 

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

  

}