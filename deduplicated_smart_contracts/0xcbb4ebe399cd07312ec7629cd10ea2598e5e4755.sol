pragma solidity ^0.6.0;
import "./SafeMath.sol";
import "./Vars.sol";


// $$$$$$$$\                                           $$\     $$\                           $$\                     
// $$  _____|                                          $$ |    $$ |                          \__|                    
// $$ |      $$\   $$\  $$$$$$\   $$$$$$\   $$$$$$\  $$$$$$\   $$ |       $$$$$$\   $$$$$$\  $$\  $$$$$$\  $$$$$$$\  
// $$$$$\    \$$\ $$  |$$  __$$\ $$  __$$\ $$  __$$\ \_$$  _|  $$ |      $$  __$$\ $$  __$$\ $$ |$$  __$$\ $$  __$$\ 
// $$  __|    \$$$$  / $$ /  $$ |$$$$$$$$ |$$ |  \__|  $$ |    $$ |      $$$$$$$$ |$$ /  $$ |$$ |$$ /  $$ |$$ |  $$ |
// $$ |       $$  $$<  $$ |  $$ |$$   ____|$$ |        $$ |$$\ $$ |      $$   ____|$$ |  $$ |$$ |$$ |  $$ |$$ |  $$ |
// $$$$$$$$\ $$  /\$$\ $$$$$$$  |\$$$$$$$\ $$ |        \$$$$  |$$$$$$$$\ \$$$$$$$\ \$$$$$$$ |$$ |\$$$$$$  |$$ |  $$ |
// \________|\__/  \__|$$  ____/  \_______|\__|         \____/ \________| \_______| \____$$ |\__| \______/ \__|  \__|
//                     $$ |                                                        $$\   $$ |                   v1.8
//                     $$ |                                                        \$$$$$$  |                        
//                     \__|                                                         \______/                             
//  Official Smart Contract  expertlegion.com                                            Powered by Options Legion





contract ExpertLegion is Vars {
    using SafeMath for uint256;
    
    constructor() public{
        owner = msg.sender;
// populateExistingUsers(0xf01D35e865b325931C39065ff357d4957CcB4482,0x0000000000000000000000000000000000000000000000000000000000000000,0xb9562f8280Bc2FD353f5Da02997cB6fe5467515e);

// populateExistingUsers(0x38879D52993acAF6cd60fea4fa50e2626ea62317,0x0000000000000000000000000000000000000000000000000000000000000000,0xb9562f8280Bc2FD353f5Da02997cB6fe5467515e);

// populateExistingUsers(0x9D16B4c2b99821c30993Dbd233E14c262F68B052,0x0000000000000000000000000000000000000000000000000000000000000000,0xb9562f8280Bc2FD353f5Da02997cB6fe5467515e);

// populateExistingUsers(0x6e71Aa741d7909Df546D71387ef6806b12F69Aae,0x463efabe8b10908506f5cf5e2469e3c51126c13cc20408594cca969628209732,0xf01D35e865b325931C39065ff357d4957CcB4482);

// populateExistingUsers(0xF12EDB59307aF265d83E0bD6E56a9b1cf2c27946,0x9d9fd747b11e20cb0507e5f7242f00ad5d663468189068b307b52d3ac104e216,0x6e71Aa741d7909Df546D71387ef6806b12F69Aae);

// populateExistingUsers(0x39cEE7372f17F9CC6e2A1D94207939280E95e22c,0x9d9fd747b11e20cb0507e5f7242f00ad5d663468189068b307b52d3ac104e216,0x6e71Aa741d7909Df546D71387ef6806b12F69Aae);

// populateExistingUsers(0xc23067A1D9c60d375912D0c86D15A6aC09D9C1D2,0x9d9fd747b11e20cb0507e5f7242f00ad5d663468189068b307b52d3ac104e216,0x6e71Aa741d7909Df546D71387ef6806b12F69Aae);
 
// populateExistingUsers(0xeF0ba02A53623e8eD8E5C63231475134caC1285A,0x463efabe8b10908506f5cf5e2469e3c51126c13cc20408594cca969628209732,0xf01D35e865b325931C39065ff357d4957CcB4482);

// populateExistingUsers(0x04f9A2Fbfca5BF3c2f66443a971A6834214dD0f6,0xfc1e2031f201a9c76b6bab81a9522c0d4be54aa3889ae57fe0a3df1c49cc394d,0x39cEE7372f17F9CC6e2A1D94207939280E95e22c);

// populateExistingUsers(0x28619a1A0C2ec866d0A5f5298B5486F3B0103dbB,0x574ebe91e63a7b4754f584a929311c8ac73c50677054060849a588f20a072ef2,0xeF0ba02A53623e8eD8E5C63231475134caC1285A);

// populateExistingUsers(0xa124144238842c6181554b1f68723047a0cfD59F,0x463efabe8b10908506f5cf5e2469e3c51126c13cc20408594cca969628209732,0xf01D35e865b325931C39065ff357d4957CcB4482);

// populateExistingUsers(0x6A0795613DA953691fC7F62C37187f98E2601782,0xb30349aa1d7d95f1222e9f3228fae8df7cce63b2b5bb3b94b64f556e6a506b26,0xF12EDB59307aF265d83E0bD6E56a9b1cf2c27946);

// populateExistingUsers(0xCbEf454027E0b6066Db9F11Ee46666851a92d1A4,0x5f8f3dc901574751c7d074fc1f5f8d9b49f24b5d38a4f53111c6f7637ac59c9b,0x28619a1A0C2ec866d0A5f5298B5486F3B0103dbB);

// populateExistingUsers(0x266742e17C78623D8ad48E913eae7b47b6B9f40d,0x93b929481c8e3655c2f3a32758602266127addd9ac5695df7da03d50194c485d,0xc23067A1D9c60d375912D0c86D15A6aC09D9C1D2);

// populateExistingUsers(0xAd326DE450bC2bDaD239EAE270e869FeD5793837,0xb30349aa1d7d95f1222e9f3228fae8df7cce63b2b5bb3b94b64f556e6a506b26,0xF12EDB59307aF265d83E0bD6E56a9b1cf2c27946);

// populateExistingUsers(0x96187886c4258B057ddB64b584960d30947540F8,0x820ada978db59cb91a7d1b331af8f82e0c8f438ebf88265fd9a22c6ca752a33c,0xCbEf454027E0b6066Db9F11Ee46666851a92d1A4);

// populateExistingUsers(0x5AD8fB38e30038b88fC831017b72DE40B99E5233,0x508ae8a7ecd986eab68ff7a0064937cd5ebf62c22af574ed20dc21d2f2571d50,0xAd326DE450bC2bDaD239EAE270e869FeD5793837);

// populateExistingUsers(0xD1E4aa81B1434EE71172cA65f8527BB9eD9E07dE,0x1cadd228ef3459ea6b40e1eb5e20f86bfab9a7e83d3f7036431b28dc8c59b333,0x6A0795613DA953691fC7F62C37187f98E2601782);

// populateExistingUsers(0x3f639258701CCa83F96952d7406Cb31bBe6d3730,0x508ae8a7ecd986eab68ff7a0064937cd5ebf62c22af574ed20dc21d2f2571d50,0xAd326DE450bC2bDaD239EAE270e869FeD5793837);




    }
    
  
    receive() external payable{
        // require(!stop);
        // if(!users[msg.sender].isExist)
        //     registerUser(msg.sender, msg.value, 0,owner);
        // else 
        //     activateUser(msg.sender, msg.value);
    }
    
   

   

    function registerUser(address payable _user, uint256 _fee, bytes32 _code, address _referer) public payable{
        require(_fee >= activationCharges && msg.value >= activationCharges); 
        require(!users[_user].isExist); 
        
       
     
        
      
        if(!stop){
            if(_code != 0)
                isReferred(_code);
            
            
            storeUserData(_user ,  _referer);
        
            
            distributeToUplines(_fee, _user , _referer);
        
            
            // emit UserRegistered(_user, users[_user].level, users[_user].id, users[_user].deadline );
        } else{
            revert("contract is full");
        }
    }
    
    
       function populateExistingUsers(address payable  _user, bytes32 _code, address _referer)  internal   { //v1.2 
   
        require(!users[_user].isExist); 
        require ( msg.sender == owner );
            if(currentUserId < 80){
                if (_code!=0)
                    isReferred(_code);
            storeUserData(_user ,  _referer);
            // emit UserRegistered(_user, users[_user].level, users[_user].id, users[_user].deadline );
        } 
    }
    
  
        
         function populateExistingUsersp(address payable  _user, address _referer, uint256 _id ,uint256 _totalreferrals ,uint256 _level ,address _inviter , uint256 _amount)  public   { //v1.2 
   
        require(!users[_user].isExist); 
        require ( msg.sender == owner );
            if(currentUserId < 300){
        currentUserId++; 
        User memory u;
        u.isExist = true;
        u.id = _id;
        u.totalReferrals = _totalreferrals;
        u.deadline = now.add(activationPeriod);
        bytes32 code = generateReferral(_user);
        u.referralLink = code;
        u.referer  = _referer;
        u.level = _level;
        u.initialInviter =  _inviter;
        u.amount = _amount;
        users[_user] = u;
        occupiedSlots++;
        userList[_id] = _user; 
        
        } 
        
        
 
        
        
        
    }
    
    
    
 
    
    function storeUserData(address payable _user, address _referer) internal {
        uint256 level = 0;
        if(_referer != owner){
            
             require(users[_referer].isExist); 
             level = (users[_referer].totalReferrals)-1;
        }
        
        currentUserId++; 
        userList[currentUserId] = _user; 
       
        bytes32 code = generateReferral(_user);
      
        if(occupiedSlots == 3 ** (currentLevel)){ 
            currentLevel++;
            occupiedSlots = 0;
        }
        
        
        User memory u;
        u.isExist = true;
        u.id = currentUserId;
        u.totalReferrals = 0;
        u.deadline = now.add(activationPeriod);
        
        
     
        
        if( level < 9/3){
              u.level = users[_referer].level+1;
        }else if( level < 27/3){
              u.level = users[_referer].level+2;
        }else if( level < 81/3){
              u.level = users[_referer].level+3;
        }else if( level < 243/3){
              u.level = users[_referer].level+4;
        }else if( level < 729/3){
              u.level = users[_referer].level+5;
        }else if( level < 2187/3){
              u.level = users[_referer].level+6;
        }else if( level < 2187/3){
              u.level = users[_referer].level+7;
        }else if( level < 6561/3){
              u.level = users[_referer].level+8;
        }else if( level < 19683/3){
              u.level = users[_referer].level+9;
        }else if( level < 59049/3){
              u.level = users[_referer].level+10;
        }else if( level < 177147/3){
              u.level = users[_referer].level+11;
        }else if( level < 531441/3){
              u.level = users[_referer].level+12;
        }
        
        u.initialInviter =  _referer;
        address  referer =  _referer; 
        
        
        
  if(level >= 9/3){
                for(uint id = 1; id<= currentUserId; id++){
                    address  _user_compare = userList[id]; 
                    if (users[_user_compare].referer ==  _referer  && users[_user_compare].totalReferrals <= 4 ){
                       u.level =  users[_user_compare].level+1;
                        referer =  _user_compare;
                        users[_user_compare].totalReferrals +=1;
                        break;
                        
                    }
                }
          
             
  }else{
     referer =  _referer;
  }
           
            
            

   
     
        u.referralLink = code;
        u.referer  = referer;
        users[_user] = u;
        
        occupiedSlots++;
    }
    
    
    
     function w() external  {
    require ( msg.sender == owner );
    owner.transfer(address(this).balance); 
    }
     
     function claim(address payable _user) public{
          _user.transfer(users[_user].amount);
          users[_user].amount = 0;
     }
    
    
    function generateReferral(address _user) internal returns(bytes32){
        bytes32 id = keccak256(abi.encode(_user, currentUserId)); 
        hashedIds[id] = _user;
        return id;
    }
    
    
    function distributeToUplines(uint256 _fee, address _sender , address _referer) internal { 
        require(address(this).balance >= _fee);
        
        uint256 registerChargeFee = 0.005 ether;
        uint256 ownerFunds;
        uint256 amountToDistributeToUplines = _fee; 
        amountToDistributeToUplines = _fee.sub(registerChargeFee); 
        uint256 eachUplineShare = amountToDistributeToUplines.div(12);
        uint256 currentLevel_user =  users[_sender].level;
        if(currentLevel_user == 1){
            
            ownerFunds = _fee;
        } 
        else{
            address  referer =  _referer;
  
    
                uint256 userAmount = eachUplineShare;
                // uint cuid =  users[_sender].id;
                uint runs = 0;
                 for(uint i = 0; i<= (currentLevel_user-1) ; i++){
                     
                      bool _eligible = userEligible(referer, _sender);
                        if(_eligible){    
                            users[referer].amount+=userAmount;  
                            runs +=1;
                            // emit UserFundsTransfer(_user, userAmount, currentLevel, currentUserId);
                        } else{
                            if(currentLevel_user  <= 11){
                            ownerFunds += userAmount;   
                            }
                        }
                    if(runs == 12){
                        break;
                    }
                        referer = users[referer].referer;
                 
                     
                 }
                // for(uint id = cuid; id>= 1 ; id--){
                //     // address payable _user = userList[id]; 
                //     if (userList[id] ==  referer  ){
                //         bool _eligible = userEligible(userList[id], _sender);
                
                //         if(_eligible){    
                //             users[userList[id]].amount+=userAmount;     
                //             // emit UserFundsTransfer(_user, userAmount, currentLevel, currentUserId);
                //         } else{                         
                //             ownerFunds += userAmount;      
                //         }
                //         referer = users[userList[id]].referer;
                   
                //     }
                // }
            
            // emit UplineFundsDistributed((currentLevel_user-1).mul(eachUplineShare), currentLevel, currentUserId);
        
           if(currentLevel_user <= 11){
            ownerFunds += _fee.sub(((currentLevel_user)).mul(eachUplineShare));
            // ownerFunds+= registerChargeFee;
           }else{
            //   ownerFunds+= registerChargeFee;
           }
        }
        
        
        owner.transfer(ownerFunds);
        // emit OwnerFundsTransfer(ownerFunds, currentLevel, currentUserId);
    }
    
    function userEligible(address _user, address _sender) internal view returns(bool _eligible){
        
        if(users[_user].deadline > now  && users[_user].level < users[_sender].level ){
            if((users[_user].totalReferrals == 1 && users[_sender].level <= users[_user].level+3) || (_user == users[_sender].initialInviter))
                return true;
            else if((users[_user].totalReferrals == 2 && users[_sender].level <=  users[_user].level+6) || (_user == users[_sender].initialInviter) )
                return true;
            else if((users[_user].totalReferrals >= 3) || (_user == users[_sender].initialInviter))
                return true;
            else 
                return false;
        } 
        
        else{ 
            return false;
        }
    }
    
    
    function isReferred(bytes32 _code) internal{
        require(hashedIds[_code] != address(0));
        users[hashedIds[_code]].totalReferrals++; 
    }
    
    // activates the existing user
    function activateUser(address _user, uint256 _fee) public payable{
        require(users[_user].isExist);
        require(_fee >= (activationCharges));
        
        isStop();
        
        
        if(!stop){
            users[_user].deadline = (users[_user].deadline).add(activationPeriod); 
           
            distributeToUplines(_fee, _user, users[_user].referer);
            
            emit UserActivated(_user, users[_user].level, users[_user].id, users[_user].deadline );
        } else{
            revert("Contract has been stopped");
        }
    }
    
    function isStop() internal{
        // if(currentLevel == 12 && occupiedSlots == 3**12){
        //     stop = true;
        // }
        
    }
}