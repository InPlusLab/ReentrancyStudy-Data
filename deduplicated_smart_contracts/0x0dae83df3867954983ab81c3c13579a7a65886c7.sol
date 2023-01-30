/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

/*
      ___                                                 ___           ___                       ___           ___           ___     
     /  /\                      ___           ___        /  /\         /__/\        ___          /__/\         /  /\         /  /\    
    /  /:/_                    /  /\         /  /\      /  /:/_       _\_ \:\      /  /\         \  \:\       /  /:/_       /  /:/_   
   /  /:/ /\    ___     ___   /  /:/        /  /:/     /  /:/ /\     /__/\ \:\    /  /:/          \  \:\     /  /:/ /\     /  /:/ /\  
  /  /:/ /:/_  /__/\   /  /\ /__/::\       /  /:/     /  /:/ /:/_   _\_ \:\ \:\  /__/::\      _____\__\:\   /  /:/_/::\   /  /:/ /::\ 
 /__/:/ /:/ /\ \  \:\ /  /:/ \__\/\:\__   /  /::\    /__/:/ /:/ /\ /__/\ \:\ \:\ \__\/\:\__  /__/::::::::\ /__/:/__\/\:\ /__/:/ /:/\:\
 \  \:\/:/ /:/  \  \:\  /:/     \  \:\/\ /__/:/\:\   \  \:\/:/ /:/ \  \:\ \:\/:/    \  \:\/\ \  \:\~~\~~\/ \  \:\ /~~/:/ \  \:\/:/~/:/
  \  \::/ /:/    \  \:\/:/       \__\::/ \__\/  \:\   \  \::/ /:/   \  \:\ \::/      \__\::/  \  \:\  ~~~   \  \:\  /:/   \  \::/ /:/ 
   \  \:\/:/      \  \::/        /__/:/       \  \:\   \  \:\/:/     \  \:\/:/       /__/:/    \  \:\        \  \:\/:/     \__\/ /:/  
    \  \::/        \__\/         \__\/         \__\/    \  \::/       \  \::/        \__\/      \  \:\        \  \::/        /__/:/   
     \__\/                                               \__\/         \__\/                     \__\/         \__\/         \__\/    


Hello 
I am Elitewings,
Global One line AutoPool Smart contract.

*/

pragma solidity 0.5.11;

contract Elitewings {
    address public ownerWallet;
    struct Variables {
        uint currUserID          ;
        uint pool1currUserID     ;
        uint pool2currUserID     ;
        uint pool3currUserID     ;
        uint pool4currUserID     ;
        uint pool5currUserID     ;
        uint pool6currUserID     ;
        uint pool7currUserID     ;
        uint pool8currUserID     ;
        uint pool9currUserID     ;
        uint pool10currUserID    ;
        uint pool11currUserID    ;
        uint pool12currUserID    ;
    }
    struct Variables2 {
        uint pool1activeUserID   ;
        uint pool2activeUserID   ;
        uint pool3activeUserID   ;
        uint pool4activeUserID   ;
        uint pool5activeUserID   ;
        uint pool6activeUserID   ;
        uint pool7activeUserID   ;
        uint pool8activeUserID   ;
        uint pool9activeUserID   ;
        uint pool10activeUserID  ;
        uint pool11activeUserID  ;
        uint pool12activeUserID  ;
    }
    Variables public vars;
    Variables2 public vars2;

    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint referredUsers;
        mapping(uint => uint) levelExpired;
    }
    
    struct PoolUserStruct {
        bool isExist;
        uint id;
        uint payment_received; 
    }
    
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    
    mapping (address => PoolUserStruct) public pool1users;
    mapping (uint => address) public pool1userList;
    
    mapping (address => PoolUserStruct) public pool2users;
    mapping (uint => address) public pool2userList;
    
    mapping (address => PoolUserStruct) public pool3users;
    mapping (uint => address) public pool3userList;
    
    mapping (address => PoolUserStruct) public pool4users;
    mapping (uint => address) public pool4userList;
    
    mapping (address => PoolUserStruct) public pool5users;
    mapping (uint => address) public pool5userList;
    
    mapping (address => PoolUserStruct) public pool6users;
    mapping (uint => address) public pool6userList;
    
    mapping (address => PoolUserStruct) public pool7users;
    mapping (uint => address) public pool7userList;
    
    mapping (address => PoolUserStruct) public pool8users;
    mapping (uint => address) public pool8userList;
    
    mapping (address => PoolUserStruct) public pool9users;
    mapping (uint => address) public pool9userList;
    
    mapping (address => PoolUserStruct) public pool10users;
    mapping (uint => address) public pool10userList;
    
    mapping (address => PoolUserStruct) public pool11users;
    mapping (uint => address) public pool11userList;
    
    mapping (address => PoolUserStruct) public pool12users;
    mapping (uint => address) public pool12userList;
     
    mapping(uint => uint) public LEVEL_PRICE;
    
    uint public unlimited_level_price   = 0;
    
    uint REGESTRATION_FESS      =   0.10    ether;
    
    uint pool1_price            =   0.25    ether;
    uint pool2_price            =   0.50    ether;
    uint pool3_price            =   0.75    ether;
    uint pool4_price            =   1.25    ether;
    uint pool5_price            =   2.00    ether;
    uint pool6_price            =   3.50    ether;
    uint pool7_price            =   6.00    ether;
    uint pool8_price            =   10.00   ether;
    uint pool9_price            =   15.00   ether;
    uint pool10_price           =   20.00   ether;
    uint pool11_price           =   30.00   ether;
    uint pool12_price           =   50.00   ether;
   
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event regPoolEntry(address indexed _user,uint _level,   uint _time);
    event getPoolPayment(address indexed _user,address indexed _receiver, uint _level, uint _time);
   
    UserStruct[] public requests;
    uint public totalEarned = 0;
     
    constructor() public {
        ownerWallet = msg.sender;

        LEVEL_PRICE[1] = 0.040 ether;   
        LEVEL_PRICE[2] = 0.006 ether;   
        LEVEL_PRICE[3] = 0.004 ether;   
        LEVEL_PRICE[4] = 0.00222 ether;   
        unlimited_level_price=0.00222 ether;   

        UserStruct memory userStruct;
        vars.currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: vars.currUserID,
            referrerID: 0,
            referredUsers:0
           
        });
        
        users[ownerWallet] = userStruct;
        userList[vars.currUserID] = ownerWallet;
       
       
        PoolUserStruct memory pooluserStruct;
        
        vars.pool1currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool1currUserID,
            payment_received:0
        });
        vars2.pool1activeUserID=vars.pool1currUserID;
        pool1users[msg.sender] = pooluserStruct;
        pool1userList[vars.pool1currUserID]=msg.sender;

        vars.pool2currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool2currUserID,
            payment_received:0
        });
        vars2.pool2activeUserID=vars.pool2currUserID;
        pool2users[msg.sender] = pooluserStruct;
        pool2userList[vars.pool2currUserID]=msg.sender;
       
        vars.pool3currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool3currUserID,
            payment_received:0
        });
        vars2.pool3activeUserID=vars.pool3currUserID;
        pool3users[msg.sender] = pooluserStruct;
        pool3userList[vars.pool3currUserID]=msg.sender;
       
        vars.pool4currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool4currUserID,
            payment_received:0
        });
        vars2.pool4activeUserID=vars.pool4currUserID;
        pool4users[msg.sender] = pooluserStruct;
        pool4userList[vars.pool4currUserID]=msg.sender;

        vars.pool5currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool5currUserID,
            payment_received:0
        });
        vars2.pool5activeUserID=vars.pool5currUserID;
        pool5users[msg.sender] = pooluserStruct;
        pool5userList[vars.pool5currUserID]=msg.sender;

        vars.pool6currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool6currUserID,
            payment_received:0
        });
        vars2.pool6activeUserID=vars.pool6currUserID;
        pool6users[msg.sender] = pooluserStruct;
        pool6userList[vars.pool6currUserID]=msg.sender;
       
        vars.pool7currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool7currUserID,
            payment_received:0
        });
        vars2.pool7activeUserID=vars.pool7currUserID;
        pool7users[msg.sender] = pooluserStruct;
        pool7userList[vars.pool7currUserID]=msg.sender;
       
        vars.pool8currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool8currUserID,
            payment_received:0
        });
        vars2.pool8activeUserID=vars.pool8currUserID;
        pool8users[msg.sender] = pooluserStruct;
        pool8userList[vars.pool8currUserID]=msg.sender;
       
        vars.pool9currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool9currUserID,
            payment_received:0
        });
        vars2.pool9activeUserID=vars.pool9currUserID;
        pool9users[msg.sender] = pooluserStruct;
        pool9userList[vars.pool9currUserID]=msg.sender;
       
        vars.pool10currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool10currUserID,
            payment_received:0
        });
        vars2.pool10activeUserID=vars.pool10currUserID;
        pool10users[msg.sender] = pooluserStruct;
        pool10userList[vars.pool10currUserID]=msg.sender;
        
        vars.pool11currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool11currUserID,
            payment_received:0
        });
        vars2.pool11activeUserID=vars.pool11currUserID;
        pool11users[msg.sender] = pooluserStruct;
        pool11userList[vars.pool11currUserID]=msg.sender;
        
        vars.pool12currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:vars.pool12currUserID,
            payment_received:0
        });
        vars2.pool12activeUserID=vars.pool12currUserID;
        pool12users[msg.sender] = pooluserStruct;
        pool12userList[vars.pool12currUserID]=msg.sender;
       
       
    }
     
    function regUser(uint _referrerID) public payable {
       
        require(!users[msg.sender].isExist, "User Exists");
        require(_referrerID > 0 && _referrerID <= vars.currUserID, 'Incorrect referral ID');
        require(msg.value == REGESTRATION_FESS, 'Incorrect Value');
       
        UserStruct memory userStruct;
        vars.currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: vars.currUserID,
            referrerID: _referrerID,
            referredUsers:0
        });
   
        users[msg.sender] = userStruct;
        userList[vars.currUserID]=msg.sender;
       
        users[userList[users[msg.sender].referrerID]].referredUsers=users[userList[users[msg.sender].referrerID]].referredUsers+1;
        
        payReferral(1,msg.sender);
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    
    }

    function payReferral(uint _level, address _user) internal {
        address referer;
       
        referer = userList[users[_user].referrerID];
        bool sent = false;
       
        uint level_price_local=0;
        if(_level>4){
            level_price_local=unlimited_level_price;
        }
        else{
            level_price_local=LEVEL_PRICE[_level];
        }
        sent = address(uint160(referer)).send(level_price_local);

        if (sent) {
            totalEarned += level_price_local;
            emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
            if(_level <= 20 && users[referer].referrerID >= 1){
                payReferral(_level+1,referer);
            }
            else
            {
                sendBalance();
            }
           
        }
       
        if(!sent) {
            payReferral(_level, referer);
        }
     }
    
    function buyPool(uint poolNumber) public payable{
        require(users[msg.sender].isExist, "User Not Registered");
        
        bool isinpool = isInPool(poolNumber,msg.sender);
        require(!isinpool, "Already in AutoPool");
        
        require(poolNumber>=1,"Pool number <0");
        require(poolNumber<=12,"Pool number >12");
        
        bool isPriceValid = checkPrice(poolNumber,msg.value);
        require(isPriceValid,"Price of Pool is Wrong");
        
        PoolUserStruct memory userStruct;
        address poolCurrentuser=getPoolCurrentUser(poolNumber);
        increasePoolCurrentUserID(poolNumber);
        
        userStruct = PoolUserStruct({
            isExist:true,
            id:getPoolCurrentUserID(poolNumber),
            payment_received:0
        });
        assignPoolUser(poolNumber,msg.sender,userStruct.id,userStruct);
        uint pool_price = getPoolPrice(poolNumber);
        
        bool sent = false;
        //direct fee for referer (10%)
        uint fee = (pool_price * 10) / 100;
        address referer;
        referer = userList[users[msg.sender].referrerID];
        
        uint poolshare = pool_price - fee;
        
        if (address(uint160(referer)).send(fee))
            sent = address(uint160(poolCurrentuser)).send(poolshare);
        
        if (sent) {
            totalEarned += poolshare;
            increasePoolPaymentReceive(poolNumber,poolCurrentuser);
            if(getPoolPaymentReceive(poolNumber,poolCurrentuser)>=getPoolPaymentNumber(poolNumber))
            {
                increasePoolActiveUserID(poolNumber);
            }
            emit getPoolPayment(msg.sender,poolCurrentuser, poolNumber, now);
            emit regPoolEntry(msg.sender, poolNumber, now);
        }
        
    }
    function getPoolPaymentNumber(uint _poolNumber) internal pure returns (uint){
        if (_poolNumber <=6)
            return 2;
        else if ((_poolNumber > 6) && (_poolNumber <=10))
            return 3;
        else if (_poolNumber ==11)
            return 4;
        else if (_poolNumber ==12)
            return 5; 
        
        return 0;
    }
    
    function isInPool(uint _poolNumber,address _PoolMember) internal view returns (bool){
        if (_poolNumber == 1)
            return pool1users[_PoolMember].isExist;
        else if (_poolNumber == 2)
            return pool2users[_PoolMember].isExist;
        else if (_poolNumber == 3)
            return pool3users[_PoolMember].isExist;
        else if (_poolNumber == 4)
            return pool4users[_PoolMember].isExist;
        else if (_poolNumber == 5)
            return pool5users[_PoolMember].isExist;
        else if (_poolNumber == 6)
            return pool6users[_PoolMember].isExist;
        else if (_poolNumber == 7)
            return pool7users[_PoolMember].isExist;
        else if (_poolNumber == 8)
            return pool8users[_PoolMember].isExist;
        else if (_poolNumber == 9)
            return pool9users[_PoolMember].isExist;
        else if (_poolNumber == 10)
            return pool10users[_PoolMember].isExist;
        else if (_poolNumber == 11)
            return pool11users[_PoolMember].isExist;
        else if (_poolNumber == 12)
            return pool12users[_PoolMember].isExist;
        
        return true;
    }
    
    function checkPrice(uint _poolNumber,uint256 Amount) internal view returns (bool){
        bool ret = false;
        
        if ((_poolNumber == 1)&&(Amount ==pool1_price))
            ret = true;
        else if ((_poolNumber == 2)&&(Amount ==pool2_price))
            ret = true;
        else if ((_poolNumber == 3)&&(Amount ==pool3_price))
            ret = true;
        else if ((_poolNumber == 4)&&(Amount ==pool4_price))
            ret = true;
        else if ((_poolNumber == 5)&&(Amount ==pool5_price))
            ret = true;
        else if ((_poolNumber == 6)&&(Amount ==pool6_price))
            ret = true;
        else if ((_poolNumber == 7)&&(Amount ==pool7_price))
            ret = true;
        else if ((_poolNumber == 8)&&(Amount ==pool8_price))
            ret = true;
        else if ((_poolNumber == 9)&&(Amount ==pool9_price))
            ret = true;
        else if ((_poolNumber == 10)&&(Amount ==pool10_price))
            ret = true;
        else if ((_poolNumber == 11)&&(Amount ==pool11_price))
            ret = true;
        else if ((_poolNumber == 12)&&(Amount ==pool12_price))
            ret = true;
            
        return ret;
    }
    
    function getPoolCurrentUser(uint _poolNumber) internal view returns (address){
        if (_poolNumber == 1)
            return pool1userList[vars2.pool1activeUserID];
        else if (_poolNumber == 2)
            return pool2userList[vars2.pool2activeUserID];
        else if (_poolNumber == 3)
            return pool3userList[vars2.pool3activeUserID];
        else if (_poolNumber == 4)
            return pool4userList[vars2.pool4activeUserID];
        else if (_poolNumber == 5)
            return pool5userList[vars2.pool5activeUserID];
        else if (_poolNumber == 6)
            return pool6userList[vars2.pool6activeUserID];
        else if (_poolNumber == 7)
            return pool7userList[vars2.pool7activeUserID];
        else if (_poolNumber == 8)
            return pool8userList[vars2.pool8activeUserID];
        else if (_poolNumber == 9)
            return pool9userList[vars2.pool9activeUserID];
        else if (_poolNumber == 10)
            return pool10userList[vars2.pool10activeUserID];
        else if (_poolNumber == 11)
            return pool11userList[vars2.pool11activeUserID];
        else if (_poolNumber == 12)
            return pool12userList[vars2.pool12activeUserID];
        
        return address(0);
    }
    
    function increasePoolCurrentUserID(uint _poolNumber) internal {
       if (_poolNumber == 1)
            vars.pool1currUserID++;
        else if (_poolNumber == 2)
            vars.pool2currUserID++;
        else if (_poolNumber == 3)
            vars.pool3currUserID++;
        else if (_poolNumber == 4)
            vars.pool4currUserID++;
        else if (_poolNumber == 5)
            vars.pool5currUserID++;
        else if (_poolNumber == 6)
            vars.pool6currUserID++;
        else if (_poolNumber == 7)
            vars.pool7currUserID++;
        else if (_poolNumber == 8)
            vars.pool8currUserID++;
        else if (_poolNumber == 9)
            vars.pool9currUserID++;
        else if (_poolNumber == 10)
            vars.pool10currUserID++;
        else if (_poolNumber == 11)
            vars.pool11currUserID++;
        else if (_poolNumber == 12)
            vars.pool12currUserID++;
    }
    
    function getPoolCurrentUserID(uint _poolNumber) internal view returns (uint){
        if (_poolNumber == 1)
            return vars.pool1currUserID;
        else if (_poolNumber == 2)
            return vars.pool2currUserID;
        else if (_poolNumber == 3)
            return vars.pool3currUserID;
        else if (_poolNumber == 4)
            return vars.pool4currUserID;
        else if (_poolNumber == 5)
            return vars.pool5currUserID;
        else if (_poolNumber == 6)
            return vars.pool6currUserID;
        else if (_poolNumber == 7)
            return vars.pool7currUserID;
        else if (_poolNumber == 8)
            return vars.pool8currUserID;
        else if (_poolNumber == 9)
            return vars.pool9currUserID;
        else if (_poolNumber == 10)
            return vars.pool10currUserID;
        else if (_poolNumber == 11)
            return vars.pool11currUserID;
        else if (_poolNumber == 12)
            return vars.pool12currUserID;
        
        return 0;
    }
    
    function assignPoolUser(uint _poolNumber,address newPoolMember,uint poolCurrentUserID,PoolUserStruct memory userStruct) internal {
        if (_poolNumber == 1){
            pool1users[newPoolMember] = userStruct;
            pool1userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 2){
            pool2users[newPoolMember] = userStruct;
            pool2userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 3){
            pool3users[newPoolMember] = userStruct;
            pool3userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 4){
            pool4users[newPoolMember] = userStruct;
            pool4userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 5){
            pool5users[newPoolMember] = userStruct;
            pool5userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 6){
            pool6users[newPoolMember] = userStruct;
            pool6userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 7){
            pool7users[newPoolMember] = userStruct;
            pool7userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 8){
            pool8users[newPoolMember] = userStruct;
            pool8userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 9){
            pool9users[newPoolMember] = userStruct;
            pool9userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 10){
            pool10users[newPoolMember] = userStruct;
            pool10userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 11){
            pool11users[newPoolMember] = userStruct;
            pool11userList[poolCurrentUserID]=newPoolMember;
        }
        else if (_poolNumber == 12){
            pool12users[newPoolMember] = userStruct;
            pool12userList[poolCurrentUserID]=newPoolMember;
        }
    }
    
    function getPoolPrice(uint _poolNumber) internal view returns (uint){
        if (_poolNumber == 1)
            return pool1_price;
        else if (_poolNumber == 2)
            return pool2_price;
        else if (_poolNumber == 3)
            return pool3_price;
        else if (_poolNumber == 4)
            return pool4_price;
        else if (_poolNumber == 5)
            return pool5_price;
        else if (_poolNumber == 6)
            return pool6_price;
        else if (_poolNumber == 7)
            return pool7_price;
        else if (_poolNumber == 8)
            return pool8_price;
        else if (_poolNumber == 9)
            return pool9_price;
        else if (_poolNumber == 10)
            return pool10_price;
        else if (_poolNumber == 11)
            return pool11_price;
        else if (_poolNumber == 12)
            return pool12_price;
        
        return 0;
    }
    
    function increasePoolPaymentReceive(uint _poolNumber, address CurrentUser) internal {
        if (_poolNumber == 1)
            pool1users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 2)
            pool2users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 3)
            pool3users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 4)
            pool4users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 5)
            pool5users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 6)
            pool6users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 7)
            pool7users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 8)
            pool8users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 9)
            pool9users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 10)
            pool10users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 11)
            pool11users[CurrentUser].payment_received+=1;
        else if (_poolNumber == 12)
            pool12users[CurrentUser].payment_received+=1;
    }
    
    function getPoolPaymentReceive(uint _poolNumber, address CurrentUser) internal view returns(uint){
        if (_poolNumber == 1)
            return pool1users[CurrentUser].payment_received;
        else if (_poolNumber == 2)
            return pool2users[CurrentUser].payment_received;
        else if (_poolNumber == 3)
            return pool3users[CurrentUser].payment_received;
        else if (_poolNumber == 4)
            return pool4users[CurrentUser].payment_received;
        else if (_poolNumber == 5)
            return pool5users[CurrentUser].payment_received;
        else if (_poolNumber == 6)
            return pool6users[CurrentUser].payment_received;
        else if (_poolNumber == 7)
            return pool7users[CurrentUser].payment_received;
        else if (_poolNumber == 8)
            return pool8users[CurrentUser].payment_received;
        else if (_poolNumber == 9)
            return pool9users[CurrentUser].payment_received;
        else if (_poolNumber == 10)
            return pool10users[CurrentUser].payment_received;
        else if (_poolNumber == 11)
            return pool11users[CurrentUser].payment_received;
        else if (_poolNumber == 12)
            return pool12users[CurrentUser].payment_received;
    }
    
    function increasePoolActiveUserID(uint _poolNumber) internal {
        if (_poolNumber == 1)
            vars2.pool1activeUserID+=1;
        else if (_poolNumber == 2)
            vars2.pool2activeUserID+=1;
        else if (_poolNumber == 3)
            vars2.pool3activeUserID+=1;
        else if (_poolNumber == 4)
            vars2.pool4activeUserID+=1;
        else if (_poolNumber == 5)
            vars2.pool5activeUserID+=1;
        else if (_poolNumber == 6)
            vars2.pool6activeUserID+=1;
        else if (_poolNumber == 7)
            vars2.pool7activeUserID+=1;
        else if (_poolNumber == 8)
            vars2.pool8activeUserID+=1;
        else if (_poolNumber == 9)
            vars2.pool9activeUserID+=1;
        else if (_poolNumber == 10)
            vars2.pool10activeUserID+=1;
        else if (_poolNumber == 11)
            vars2.pool11activeUserID+=1;
        else if (_poolNumber == 12)
            vars2.pool12activeUserID+=1;
    }
    
    function getEthBalance() public view returns(uint) {
    return address(this).balance;
    }
    
    function sendBalance() private
    {
         if (!address(uint160(ownerWallet)).send(getEthBalance()))
         {
             
         }
    }
   
   
}