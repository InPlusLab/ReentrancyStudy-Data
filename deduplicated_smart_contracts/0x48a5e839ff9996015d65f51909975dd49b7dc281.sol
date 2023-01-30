/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

/*
FIREBULL


My URL : https://firebull.run

Hashtag: #Firebull
*/
pragma solidity 0.5.11 - 0.6.4;

contract FireBull {
     address public ownerWallet;
      uint public currUserID = 0;
      uint public pool1currUserID = 0;
      uint public pool2currUserID = 0;
      uint public pool3currUserID = 0;
      uint public pool4currUserID = 0;
      uint public pool5currUserID = 0;
      uint public pool6currUserID = 0;
      uint public pool7currUserID = 0;
      uint public pool8currUserID = 0;
      uint public pool9currUserID = 0;
      uint public pool10currUserID = 0;
      
        uint public pool1activeUserID = 0;
      uint public pool2activeUserID = 0;
      uint public pool3activeUserID = 0;
      uint public pool4activeUserID = 0;
      uint public pool5activeUserID = 0;
      uint public pool6activeUserID = 0;
      uint public pool7activeUserID = 0;
      uint public pool8activeUserID = 0;
      uint public pool9activeUserID = 0;
      uint public pool10activeUserID = 0;
      
      
      uint public unlimited_level_price=0;
     
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
     
    mapping(uint => uint) public LEVEL_PRICE;
    
   uint REGESTRATION_FESS=0.05 ether;
   uint pool1_price=0.1 ether;
   uint pool2_price=0.2 ether ;
   uint pool3_price=0.5 ether;
   uint pool4_price=1 ether;
   uint pool5_price=2 ether;
   uint pool6_price=5 ether;
   uint pool7_price=0.2 ether ;
   uint pool8_price=0.5 ether;
   uint pool9_price=1 ether;
   uint pool10_price=5 ether;

   
   
     event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
      event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
      
     event regPoolEntry(address indexed _user,uint _level,   uint _time);
     event getMoneyBuyPool(address indexed _user, address indexed _referral, uint _level, uint _levelpool, uint _time);
   
     
    event getPoolPayment(address indexed _user,address indexed _receiver, uint _level, uint _time);
   
    UserStruct[] public requests;
     
      constructor() public {
          ownerWallet = msg.sender;

        LEVEL_PRICE[1] = 0.01 ether;
        LEVEL_PRICE[2] = 0.005 ether;
        LEVEL_PRICE[3] = 0.0025 ether;
        LEVEL_PRICE[4] = 0.00025 ether;
      unlimited_level_price=0.00025 ether;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referredUsers:0
           
        });
        
        users[ownerWallet] = userStruct;
       userList[currUserID] = ownerWallet;
       
       
         PoolUserStruct memory pooluserStruct;
        
        pool1currUserID++;

        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });
    pool1activeUserID=pool1currUserID;
       pool1users[msg.sender] = pooluserStruct;
       pool1userList[pool1currUserID]=msg.sender;
      
        
        pool2currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });
    pool2activeUserID=pool2currUserID;
       pool2users[msg.sender] = pooluserStruct;
       pool2userList[pool2currUserID]=msg.sender;
       
       
        pool3currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });
    pool3activeUserID=pool3currUserID;
       pool3users[msg.sender] = pooluserStruct;
       pool3userList[pool3currUserID]=msg.sender;
       
       
         pool4currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });
    pool4activeUserID=pool4currUserID;
       pool4users[msg.sender] = pooluserStruct;
       pool4userList[pool4currUserID]=msg.sender;

        
          pool5currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });
    pool5activeUserID=pool5currUserID;
       pool5users[msg.sender] = pooluserStruct;
       pool5userList[pool5currUserID]=msg.sender;
       
       
         pool6currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });
    pool6activeUserID=pool6currUserID;
       pool6users[msg.sender] = pooluserStruct;
       pool6userList[pool6currUserID]=msg.sender;
       
         pool7currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool7currUserID,
            payment_received:0
        });
    pool7activeUserID=pool7currUserID;
       pool7users[msg.sender] = pooluserStruct;
       pool7userList[pool7currUserID]=msg.sender;
       
       pool8currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool8currUserID,
            payment_received:0
        });
    pool8activeUserID=pool8currUserID;
       pool8users[msg.sender] = pooluserStruct;
       pool8userList[pool8currUserID]=msg.sender;
       
        pool9currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool9currUserID,
            payment_received:0
        });
    pool9activeUserID=pool9currUserID;
       pool9users[msg.sender] = pooluserStruct;
       pool9userList[pool9currUserID]=msg.sender;
       
       
        pool10currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool10currUserID,
            payment_received:0
        });
    pool10activeUserID=pool10currUserID;
       pool10users[msg.sender] = pooluserStruct;
       pool10userList[pool10currUserID]=msg.sender;
       
       
      }
     
       function regUser(uint _referrerID) public payable {
       
      require(!users[msg.sender].isExist, "User Exists");
      require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referral ID');
        require(msg.value == REGESTRATION_FESS, 'Incorrect Value');
       
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referredUsers:0
        });
   
    
       users[msg.sender] = userStruct;
       userList[currUserID]=msg.sender;
       
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
                emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
                if(_level < 100 && users[referer].referrerID >= 1){
                    payReferral(_level+1,referer);
                }
                else
                {
                    sendBalance();
                }
               
            }
       
        if(!sent) {
          //  emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);

            payReferral(_level, referer);
        }
     }
   
   
   
   
       function buyPool1() public payable {
       require(users[msg.sender].isExist, "User Not Registered");
      require(!pool1users[msg.sender].isExist, "Already in AutoPool");
      
        require(msg.value == pool1_price, 'Incorrect Value');
        
       
        PoolUserStruct memory userStruct;
        address pool1Currentuser=pool1userList[pool1activeUserID];
        
        pool1currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });
   
       pool1users[msg.sender] = userStruct;
       pool1userList[pool1currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool1Currentuser)).send(pool1_price/2);

            if (sent) {
                pool1users[pool1Currentuser].payment_received+=1;
                if(pool1users[pool1Currentuser].payment_received>=3)
                {
                    pool1activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool1Currentuser, 1, now);
            }
       emit regPoolEntry(msg.sender, 1, now);
       
  
     
     payrefpool1(1,msg.sender);
 
       
    }

    function payrefpool1(uint _level,address _user) internal{
        address referer1;
        referer1 = userList[users[_user].referrerID];
        bool sent = false;
        
        if(_level == 1){
        sent = address(uint160(referer1)).send((pool1_price*3)/10);
        emit getMoneyBuyPool(referer1, msg.sender, _level,1, now);
        }
        if(_level == 2){
        sent = address(uint160(referer1)).send(pool1_price/10);
        emit getMoneyBuyPool(referer1, msg.sender, _level,1, now);
        }
        if(_level == 3){
        sent = address(uint160(referer1)).send(pool1_price/20);
        emit getMoneyBuyPool(referer1, msg.sender, _level,1, now);
        }
        if(_level == 4){
        sent = address(0x3291030c8ffcAd820AfE45636e5FC26405499E22).send(pool1_price/20);
        }
        if(_level < 4 && users[referer1].referrerID >= 1){
                    payrefpool1(_level+1,referer1);
        }
        else
        {
            sendBalance();
        }
        
    }
    

    
    
      function buyPool2() public payable {
          require(users[msg.sender].isExist, "User Not Registered");
      require(!pool2users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool2_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=0, "Must need 0 referral");
         
        PoolUserStruct memory userStruct;
        address pool2Currentuser=pool2userList[pool2activeUserID];
        
        pool2currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });
       pool2users[msg.sender] = userStruct;
       pool2userList[pool2currUserID]=msg.sender;
       
       
       
       bool sent = false;
       sent = address(uint160(pool2Currentuser)).send(pool2_price/2);

            if (sent) {
                pool2users[pool2Currentuser].payment_received+=1;
                if(pool2users[pool2Currentuser].payment_received>=3)
                {
                    pool2activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool2Currentuser, 2, now);
            }
            emit regPoolEntry(msg.sender,2,  now);
            
    payrefpool2(1,msg.sender);
 
       
    }

    function payrefpool2(uint _level,address _user) internal{
        address referer2;
        referer2 = userList[users[_user].referrerID];
        bool sent = false;
        
        if(_level == 1){
        sent = address(uint160(referer2)).send((pool2_price*3)/10);
        emit getMoneyBuyPool(referer2, msg.sender, _level,2, now);
        }
        if(_level == 2){
        sent = address(uint160(referer2)).send(pool2_price/10);
        emit getMoneyBuyPool(referer2, msg.sender, _level,2, now);
        }
        if(_level == 3){
        sent = address(uint160(referer2)).send(pool2_price/20);
        emit getMoneyBuyPool(referer2, msg.sender, _level,2, now);
        }
        if(_level == 4){
        sent = address(0x3291030c8ffcAd820AfE45636e5FC26405499E22).send(pool2_price/20);
        }
        if(_level < 4 && users[referer2].referrerID >= 1){
                    payrefpool2(_level+1,referer2);
        }
        else
        {
            sendBalance();
        }
        
    }
    
    
     function buyPool3() public payable {
         require(users[msg.sender].isExist, "User Not Registered");
      require(!pool3users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool3_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=0, "Must need 0 referral");
        
        PoolUserStruct memory userStruct;
        address pool3Currentuser=pool3userList[pool3activeUserID];
        
        pool3currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });
       pool3users[msg.sender] = userStruct;
       pool3userList[pool3currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool3Currentuser)).send(pool3_price/2);

            if (sent) {
                pool3users[pool3Currentuser].payment_received+=1;
                if(pool3users[pool3Currentuser].payment_received>=3)
                {
                    pool3activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool3Currentuser, 3, now);
            }
emit regPoolEntry(msg.sender,3,  now);
    
    payrefpool3(1,msg.sender);
 
       
    }

    function payrefpool3(uint _level,address _user) internal{
        address referer3;
        referer3 = userList[users[_user].referrerID];
        bool sent = false;
        
        if(_level == 1){
        sent = address(uint160(referer3)).send((pool3_price*3)/10);
        emit getMoneyBuyPool(referer3, msg.sender, _level,3, now);
        }
        if(_level == 2){
        sent = address(uint160(referer3)).send(pool3_price/10);
        emit getMoneyBuyPool(referer3, msg.sender, _level,3, now);
        }
        if(_level == 3){
        sent = address(uint160(referer3)).send(pool3_price/20);
        emit getMoneyBuyPool(referer3, msg.sender, _level,3, now);
        }
        if(_level == 4){
        sent = address(0x3291030c8ffcAd820AfE45636e5FC26405499E22).send(pool3_price/20);
        }
        if(_level < 4 && users[referer3].referrerID >= 1){
                    payrefpool3(_level+1,referer3);
        }
        else
        {
            sendBalance();
        }
        
    }
    
    
    function buyPool4() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool4users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool4_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=0, "Must need 0 referral");
      
        PoolUserStruct memory userStruct;
        address pool4Currentuser=pool4userList[pool4activeUserID];
        
        pool4currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });
       pool4users[msg.sender] = userStruct;
       pool4userList[pool4currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool4Currentuser)).send(pool4_price/2);

            if (sent) {
                pool4users[pool4Currentuser].payment_received+=1;
                if(pool4users[pool4Currentuser].payment_received>=3)
                {
                    pool4activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool4Currentuser, 4, now);
            }
        emit regPoolEntry(msg.sender,4, now);
    
    payrefpool4(1,msg.sender);
 
       
    }

    function payrefpool4(uint _level,address _user) internal{
        address referer4;
        referer4 = userList[users[_user].referrerID];
        bool sent = false;
        
        if(_level == 1){
        sent = address(uint160(referer4)).send((pool4_price*3)/10);
        emit getMoneyBuyPool(referer4, msg.sender, _level,4, now);
        }
        if(_level == 2){
        sent = address(uint160(referer4)).send(pool4_price/10);
        emit getMoneyBuyPool(referer4, msg.sender, _level,4, now);
        }
        if(_level == 3){
        sent = address(uint160(referer4)).send(pool4_price/20);
        emit getMoneyBuyPool(referer4, msg.sender, _level,4, now);
        }
        if(_level == 4){
        sent = address(0x3291030c8ffcAd820AfE45636e5FC26405499E22).send(pool4_price/20);
        }
        if(_level < 4 && users[referer4].referrerID >= 1){
                    payrefpool4(_level+1,referer4);
        }
        else
        {
            sendBalance();
        }
        
    }
    
    
    
    function buyPool5() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool5users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool5_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=0, "Must need 0 referral");
        
        PoolUserStruct memory userStruct;
        address pool5Currentuser=pool5userList[pool5activeUserID];
        
        pool5currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });
       pool5users[msg.sender] = userStruct;
       pool5userList[pool5currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool5Currentuser)).send(pool5_price/2);

            if (sent) {
                pool5users[pool5Currentuser].payment_received+=1;
                if(pool5users[pool5Currentuser].payment_received>=3)
                {
                    pool5activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool5Currentuser, 5, now);
            }
        emit regPoolEntry(msg.sender,5,  now);
    
    payrefpool5(1,msg.sender);
 
       
    }

    function payrefpool5(uint _level,address _user) internal{
        address referer5;
        referer5 = userList[users[_user].referrerID];
        bool sent = false;
        
        if(_level == 1){
        sent = address(uint160(referer5)).send((pool5_price*3)/10);
        emit getMoneyBuyPool(referer5, msg.sender, _level,5, now);
        }
        if(_level == 2){
        sent = address(uint160(referer5)).send(pool5_price/10);
        emit getMoneyBuyPool(referer5, msg.sender, _level,5, now);
        }
        if(_level == 3){
        sent = address(uint160(referer5)).send(pool5_price/20);
        emit getMoneyBuyPool(referer5, msg.sender, _level,5, now);
        }
        if(_level == 4){
        sent = address(0x3291030c8ffcAd820AfE45636e5FC26405499E22).send(pool5_price/20);
        }
        if(_level < 4 && users[referer5].referrerID >= 1){
                    payrefpool5(_level+1,referer5);
        }
        else
        {
            sendBalance();
        }
        
    }
    
    function buyPool6() public payable {
      require(!pool6users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool6_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=0, "Must need 0 referral");
        
        PoolUserStruct memory userStruct;
        address pool6Currentuser=pool6userList[pool6activeUserID];
        
        pool6currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });
       pool6users[msg.sender] = userStruct;
       pool6userList[pool6currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool6Currentuser)).send(pool6_price/2);

            if (sent) {
                pool6users[pool6Currentuser].payment_received+=1;
                if(pool6users[pool6Currentuser].payment_received>=3)
                {
                    pool6activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool6Currentuser, 6, now);
            }
        emit regPoolEntry(msg.sender,6,  now);
    
    payrefpool6(1,msg.sender);
 
       
    }

    function payrefpool6(uint _level,address _user) internal{
        address referer6;
        referer6 = userList[users[_user].referrerID];
        bool sent = false;
        
        if(_level == 1){
        sent = address(uint160(referer6)).send((pool6_price*3)/10);
        emit getMoneyBuyPool(referer6, msg.sender, _level,6, now);
        }
        if(_level == 2){
        sent = address(uint160(referer6)).send(pool6_price/10);
        emit getMoneyBuyPool(referer6, msg.sender, _level,6, now);
        }
        if(_level == 3){
        sent = address(uint160(referer6)).send(pool6_price/20);
        emit getMoneyBuyPool(referer6, msg.sender, _level,6, now);
        }
        if(_level == 4){
        sent = address(0x3291030c8ffcAd820AfE45636e5FC26405499E22).send(pool6_price/20);
        }
        if(_level < 4 && users[referer6].referrerID >= 1){
                    payrefpool6(_level+1,referer6);
        }
        else
        {
            sendBalance();
        }
        
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