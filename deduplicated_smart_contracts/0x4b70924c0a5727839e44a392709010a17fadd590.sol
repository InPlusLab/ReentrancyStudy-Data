/**
 *Submitted for verification at Etherscan.io on 2020-07-08
*/

pragma solidity ^0.4.24;
//ORIXHEM
contract Contrato_Orixhem{
    address private owner;
    string private mess;
    address private orixhem_R=0x3AD2E7C81393a377c3877F948282A8fE9886082a;
    constructor() public{
        owner = msg.sender;
    }
    function paquetes(uint _i) public payable{
	if (_i == 1) {
        require (msg.value== 0.15 ether);
        send_owner(37500000000000000);
        mess="Compro paquete 1";
    } else if (_i == 2) {
        require (msg.value== 0.30 ether);
         send_owner(75000000000000000);
        mess="Compro paquete 2";
    } else if (_i == 3) {
        require (msg.value== 0.60 ether);
         send_owner(150000000000000000);
        mess="Compro paquete 3";
    } 
    else if (_i == 4) {
        require (msg.value== 1.20 ether);
         send_owner(300000000000000000);
        mess="Compro paquete 4";
    } 
    else if (_i == 5) {
        require (msg.value== 2.40 ether);
         send_owner(600000000000000000);
        mess="Compro paquete 5";
    } 
    else if (_i == 6) {
        require (msg.value== 4 ether);
         send_owner(1000000000000000000);
        mess="Compro paquete 6";
    } 
    else if (_i == 7) {
        require (msg.value== 7 ether);
         send_owner(1750000000000000000);
        mess="Compro paquete 7";
    } 
    else if (_i == 8) {
        require (msg.value== 13 ether);
         send_owner(3250000000000000000);
        mess="Compro paquete 8";
    } 
    else if (_i == 9) {
        require (msg.value== 26 ether);
         send_owner(6500000000000000000);
        mess="Compro paquete 9";
    } 
    else if (_i == 10) {
        require (msg.value== 52 ether);
         send_owner(13000000000000000000);
        mess="Compro paquete 10";
    } 
    else if (_i == 11) {
        require (msg.value== 106 ether);
         send_owner(26500000000000000000);
        mess="Compro paquete 11";
    } 
}
    function send_owner(uint amount) private {
        orixhem_R.transfer(amount); 
    }
    function obtenerbalance() public isowner view returns(uint){
        address orixhem=this;
        return orixhem.balance;
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