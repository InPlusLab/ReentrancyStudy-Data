/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

pragma solidity ^0.4.24;


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



contract FICO {
    
    using SafeMath for uint;
    
    address owner; 
    uint constant a_1 = 1000000000000000000;
    uint constant a_2 = 0;
    uint constant b_1 = 6000000000000000000;
    uint constant b_2 = 18;
    uint constant c_1 = 10000000000000000000;
    uint constant c_2 = 30;
    uint constant d_1 = 25000000000000000000;
    uint constant d_2 = 75;
    uint constant e_1 = 50000000000000000000;
    uint constant e_2 = 150;
    uint constant f_1 = 80000000000000000000;
    uint constant f_2 = 240;
    
    
    constructor()public{
        owner = msg.sender;
        verification[owner]=keccak256(abi.encodePacked(owner));
        quota[owner] = f_2;
        quota_2[owner]=quota[owner].mul(7).div(24);
        quota_3[owner]=quota[owner].mul(4).div(24);
        amount[owner] = f_1;
        age[owner]=1;
        menbership[owner] = menber("Weber" ,owner,amount[owner],quota[owner],quota_2[owner],quota_3[owner],age[owner],superior[0x0]);
    }
  
    
    mapping(address => uint)quota; //投資者的分潤配比
    mapping(address => uint)quota_2;
    mapping(address => uint)quota_3;
    mapping(address => uint)amount; //投資者的投資金額
    mapping(address => address) superior;//輸入地址查詢其推薦人
    mapping(address => menber)public menbership; // 會員的資料
    mapping(address => bytes32) verification;
    mapping(address => uint)age; //第幾代
    address[] menber_count;
    uint public menber_count_length;
    
    event usermap(address menbership ,address refferer,uint amount );
    
    struct menber{
        string name; 
        address user_key;
        uint invest_amout;
        uint quota;
        uint quota_2;
        uint quota_3;
        uint age;
        address superior;
    }
    
    
    
     modifier _verification {
         bytes32 user = keccak256(abi.encodePacked(msg.sender));
         require (verification[msg.sender] != user ,"這組地址使用過");
         verification[msg.sender] =user;
        _;
    }
    
    
    function project (address refferer,string name)public _verification payable{
        
        require (msg.sender != refferer,"不能投給自己");
        require (refferer != address(0x0),"");
        require (age[refferer] != 0 ,"沒有該名會員");
       
        
        
        if(msg.value == a_1){
            quota[msg.sender] = a_2;
            amount[msg.sender] = msg.value;
        }else if (msg.value == b_1){
            quota[msg.sender] = b_2;
            amount[msg.sender] = msg.value;
        }else if(msg.value == c_1){
            quota[msg.sender] = c_2;
            amount[msg.sender] = msg.value;
        }else if(msg.value == d_1){
            quota[msg.sender] = d_2;
            amount[msg.sender] = msg.value;
        }else if(msg.value == e_1){
            quota[msg.sender] = e_2;
            amount[msg.sender] = msg.value;
        }else if(msg.value == f_1){
            quota[msg.sender] = f_2;
            amount[msg.sender] = msg.value;
        }else{
              revert("沒有這個項目");
        }
        
        age[msg.sender] = age[refferer].add(1);
        superior[msg.sender]=refferer;
        
        refferer.transfer(msg.value.mul(quota[refferer].div(1000))); 
        
        address A = superior[refferer];
        A.transfer(msg.value.mul(quota[A]).mul(7).div(24).div(1000));
        
        address B = superior[superior[refferer]];
        B.transfer(msg.value.mul(quota[B]).mul(4).div(24).div(1000));
        
        quota_2[msg.sender] = quota[msg.sender].mul(7).div(24);
        quota_3[msg.sender] = quota[msg.sender].mul(4).div(24);
        
        
        Safe_location();
        menber_count.push(msg.sender);
        menber_count_length = menber_count.length;
        menbership[msg.sender] = menber(name ,msg.sender,msg.value,quota[msg.sender],quota_2[msg.sender],quota_3[msg.sender],age[msg.sender],superior[msg.sender]);
        
        emit usermap(msg.sender , refferer ,msg.value );
    }
    
    
    function querybalance()public view returns (uint){
        return address(this).balance;
    }
    
    
    function Safe_location() private  {
        uint money = querybalance();
        owner.transfer(money);
    }
   
    function transfer() public {
        require(owner == msg.sender,"你沒有權限");
        uint money = querybalance();
        owner.transfer(money);
    } 
    
    function add_menber(address set_menber , string name)public {
        require(owner == msg.sender,"你沒有權限");
        bytes32 user = keccak256(abi.encodePacked(set_menber));
        require (verification[set_menber] != user,"你已經輸入過該該組公鑰");
        verification[set_menber]=user;
        
        quota[set_menber] = f_2;
        quota_2[set_menber]=quota[set_menber].mul(7).div(24);
        quota_3[set_menber]=quota[set_menber].mul(4).div(24);
        amount[set_menber] = f_1;
        superior[set_menber]=owner;
        age[set_menber] = age[owner].add(1);
        menbership[set_menber] = menber(name ,set_menber,amount[set_menber],quota[set_menber],quota_2[set_menber],quota_3[set_menber],age[set_menber],superior[set_menber]);
        
    }
    
    
}