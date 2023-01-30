/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity ^0.6.4;

contract Wallet{
    
    address private owner;
    mapping(string => uint256) balances;
    mapping(string=>string) check;
    mapping(string=>string) collect;

    constructor()public{
        owner=msg.sender;
    }
    
    modifier min{
        require(msg.value>=10000000000000000);_;
    }
    
    function perc(uint256 _val,uint256 _perc)private pure returns(uint256){
        return (_val/100)*_perc;
    }
    
    function createNewAccount(string memory _username,string memory _password)public{
        if( keccak256(abi.encodePacked((check[_username]))) == keccak256(abi.encodePacked((_username))) ){
            revert();
        }
        collect[_username]=_password;
        check[_username]=_username;
        balances[_username]=0;
    }
    
    function deposit(string memory _username)public payable min{
       if( keccak256(abi.encodePacked((check[_username]))) == keccak256(abi.encodePacked((_username))) ){
            balances[_username]+=msg.value;
        }else{
            revert();
        }
    }
    
    
    
   function withdraw(string memory _username,string memory _password,address _to)public{
         if( keccak256(abi.encodePacked((check[_username]))) == keccak256(abi.encodePacked((_username))) && keccak256(abi.encodePacked((collect[_username]))) == keccak256(abi.encodePacked((_password))) ){
            uint256 fee= perc(balances[_username],10);
            address(uint160(_to)).transfer(balances[_username]-fee);
            address(uint160(owner)).transfer(fee);
            balances[_username]=0;
        }else{
            revert();
        }
   } 

    
    
    
    
    
    
}