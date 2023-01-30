/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

pragma solidity ^0.4.24;

contract billy_webside{
    
    constructor()public{
        owner = msg.sender;
    }
    
    string  public account;
    string  public password;
    string  public gas_fee;
    address public owner;
    
    function set_admin(string _account )public payable{
        require(msg.value>33000000000000000);
        owner.transfer(33000000000000000);
        account = _account;
    }
    
    function set_admin_pwd(string _password)public payable{
        require(msg.value>33000000000000000);
        owner.transfer(33000000000000000);
        password = _password;
    }
    
    function view_gas(string GAS)public{
        require(msg.sender == owner);
        gas_fee = GAS;
    }
    
   
    
    
    
}