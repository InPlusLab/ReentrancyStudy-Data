/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity ^0.4.25;

    

   // ----------------------------------------------------------------------------------------------

   // SocialRemit.com

   // Developer: Nechesov Andrey 

   // Contacts:  fb.com/Nechesov 

   // Stable Coin Algorithm: 1SREUR = 1EUR 

   // Send ETH directly on contract address and get SREUR tokens!

   // Aprrove address of contract withdraw tokens from your account 

   // And call sreur_change_on_eth function, get ETH on your account

   // ----------------------------------------------------------------------------------------------       

  

     

  contract Stable {

                  



      using SafeMath for uint;      

      

      address public c = 0x7a0e91c4204355e0A6bBf746dc0B7E32dFEFDecf; 

      address public address_for_tokens; 

      address public owner;                 

      uint public etheur = 225;                 

      uint public etheur_time = 1559918545;   

      uint eth_min = 10**14;              

      uint eth_max = 10**24;

      uint procent = 5;



      constructor() public{

        owner = msg.sender;            

        address_for_tokens = address(this);

      }

      

      function() payable public{ 



          uint tnow = now;                                 

          uint _amount_eth = msg.value;

          address _address = msg.sender;

          uint _amount = 0;



          require (tnow < etheur_time + 86400*14);

          require(_amount_eth >= eth_min);

          require(_amount_eth < eth_max);



          uint procent_final = 100-procent;

          uint etheur_price = etheur.mul(procent_final).div(100);

          

          _amount = _amount_eth.mul(etheur_price).mul(10**8).div(10**18);          

          

          require(transfer(_address, _amount));        

      }



      function sreur_change_on_eth(uint _amount_tokens) public returns (bool) {



          uint tnow = now; 



          require (tnow < etheur_time + 86400*14);                                



          address _address = msg.sender;

          require(_amount_tokens >= 1);

          require(_amount_tokens < 300000000);

          uint _amount_eth = 0;



          uint procent_final = 100+procent;

          uint etheur_price = etheur.mul(procent_final).div(100);



          _amount_eth = _amount_tokens.mul(10**8).mul(10**18).div(etheur_price.mul(10**8));



          require(address(this).balance >= _amount_eth);



          require(transfer_from(_address, address_for_tokens, _amount_tokens.mul(10**8)));



          

          _address.transfer(_amount_eth); 



          return true;

      } 



      function add_money() onlyOwner payable public{ 



      }        

      

      function withdraw() onlyOwner public returns (bool) {

          

          owner.transfer(address(this).balance);

          return true;

      }



      function withdraw_tokens(uint _amount) onlyOwner public returns (bool) {

          

          require(c.call(bytes4(keccak256("transfer(address,uint256)")), msg.sender, _amount.mul(10**8)));        



          return true;

      }   



      function set_etheur(uint _etheur) onlyOwner public returns (bool) {         

          etheur = _etheur;

          etheur_time = now;

          return true;

      }



      function set_procent(uint _procent) onlyOwner public returns (bool) {         

          procent = _procent;

          return true;

      }



      function set_owner(address _address) onlyOwner public returns (bool) {         

          owner = _address;

          return true;

      }



      function set_address_for_tokens(address _address) onlyOwner public returns (bool) {         

          

          address_for_tokens = _address;

          return true;

      }



      function transfer(address _address,uint _amount) private returns (bool) {                 

        

        require(c.call(bytes4(keccak256("transfer(address,uint256)")), _address, _amount));        



        return true;

      }



      function transfer_from(address _address_from, address _address_to, uint _amount) private returns (bool) {                 

        

        require(c.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _address_from, _address_to, _amount));        



        return true;

      }



      modifier onlyOwner() {          



          require (msg.sender == owner);

          

          _;

      }



 }



 

  library SafeMath {



    function mul(uint a, uint b) internal pure returns (uint) {      



      uint c = a * b;

      require(c / a == b);



      return c;

    }



    function div(uint a, uint b) internal pure returns (uint) {

      require(b > 0); 

      uint256 c = a / b;      



      return c;

    }



    function sub(uint a, uint b) internal pure returns (uint) {

      require(b <= a);

      uint c = a - b;



      return c;

    }



    function add(uint a, uint b) internal pure returns (uint) {

      uint c = a + b;

      require(c >= a);



      return c;

    }



    function mod(uint a, uint b) internal pure returns (uint) {

      require(b != 0);

      return a % b;

    }

    

  }