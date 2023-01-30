pragma solidity ^0.4.24;

import "./PROTtoken.sol";

contract PROT_MN_reward {
    
    struct UserInfo {
        uint16 mnCnt;
        uint32 tokenCnt;
        uint256 applyTime;
        uint32 totalReward;
        uint32 unPayedReward;
        uint32 payedReward;
    }
    
    uint256 public deployTime;
    uint32 private totalUserReward;
    uint16 public totalMNcount = 0;
    uint256 private constant aMonth = 1 * 30 days;
    uint24 public  constant tokenPerMN = 50000;
    uint8 private constant applyMNcount = 1;
    uint8 private constant withdrawMNcount = 1;
    uint16 private constant dailyRewardCount = 1440;
    uint16[11] private rewardLevel = [
         36, // 1 month
         48, // 2 month
         40, // 3 month
         60, // 4 month
         80, // 5 month
         84, // 6 month
         92, // 8 month
         96, // 10 month
        100, // 12 month
         72, // 24 month
         36  // after 24 month
    ];
    
    mapping (address => UserInfo) public user; 
    address[] internal users;
    address private owner;
    
    PROTtoken public protToken;
    
    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        deployTime = now + (1 * 7 days);
        owner = msg.sender;
    }
    
    function () external payable{
        if(msg.value <= 0){
            revert();
        }
    }
    
    function getOwner() public onlyOwner view returns(address){
        return owner;
    }
    
    function setPROTtoken (address _addr) public onlyOwner {
        protToken = PROTtoken(_addr);    
    }
    
    //ok - user function
    function applyMasternode() public returns (bool) {
        
        require(protToken.balanceOf(msg.sender) >= applyMNcount * tokenPerMN);
        
        bool result = saveUserInfo(msg.sender);
        
        protToken.transferFrom2(msg.sender, address(this), applyMNcount * tokenPerMN * 10 ** uint256(protToken.decimals()));
        
        return result;
    }
    
    
    //ok
    function saveUserInfo(address _user) private returns(bool) {
        
        if(applyMNcount != 1) { revert();}
        
        //existing account flag
        uint8 chkUser;
        
        for(uint16 i=0; i<users.length; i++){
            if(users[i] == _user){
                chkUser += 1;
            }
        }
        
        if(chkUser == 0){  //first masternode apply
            users.push(_user); 
            user[_user].applyTime = now;
        }else if(chkUser != 0 && user[_user].applyTime == 0){  //masternode re-apply
            user[_user].applyTime = now;
        }
        
        user[_user].mnCnt    += applyMNcount;
        user[_user].tokenCnt += applyMNcount * tokenPerMN;
        
        totalMNcount += applyMNcount;
        
        return true;
    }    
    
    //ok - automatical apply
    function applyMasternode2(address _user,uint16 _mnCnt) public onlyOwner returns (bool) {
        
        require(protToken.balanceOf(owner) >= _mnCnt * tokenPerMN);
        
        bool result = saveUserInfo2(_user, _mnCnt);
        
        protToken.transferFrom2(owner, address(this), _mnCnt * tokenPerMN * 10 ** uint256(protToken.decimals()));
        
        return result;
    }
    
    //ok - automatical apply
    function saveUserInfo2(address _user, uint16 _mnCnt) private returns(bool) {
        
        if(_mnCnt <= 0) { revert();}
        
        uint8 chkUser;
        
        for(uint16 i=0; i<users.length; i++){
            if(users[i] == _user){
                chkUser += 1;
            }
        }
        
        if(chkUser == 0){ 
            users.push(_user); 
            
            user[_user].mnCnt     = _mnCnt;
            user[_user].tokenCnt  = _mnCnt * tokenPerMN;
            user[_user].applyTime = now;    
        }else{
            user[_user].mnCnt    += _mnCnt;
            user[_user].tokenCnt += _mnCnt * tokenPerMN;
        }
        
        totalMNcount += _mnCnt;
        
        return true;
    }
    
    //ok
    function dailyReward(uint16 _startNum, uint16 _endNum, uint8 _period) public onlyOwner returns(uint32, uint16) {
        uint32 todayReward;
        uint16 rewardUsers;
        
        (todayReward, rewardUsers) = masterNodeReward(_startNum, _endNum, _period);
        
        
        // protToken.transferFrom2(owner, address(this), todayReward * 10 ** uint256(protToken.decimals()));
        
        return (todayReward, rewardUsers);
    }
    
    //ok
    function masterNodeReward(uint16 _startNum, uint16 _endNum, uint8 _period) private returns(uint32, uint16){
        
        uint32 thisTimeTotalReward;
        uint16 userCnt;
        uint32 _todayNodeReward_ = todayPerNodeReward() * _period;

        if(users.length == 0){
            revert();
        }else{
            for(uint16 i=_startNum; i<=_endNum; i++){
                if(user[users[i]].mnCnt > 0){
                    user[users[i]].totalReward   += user[users[i]].mnCnt * _todayNodeReward_;
                    user[users[i]].unPayedReward += user[users[i]].mnCnt * _todayNodeReward_;
                    
                    thisTimeTotalReward += user[users[i]].mnCnt * _todayNodeReward_;
                    userCnt++;
                    totalUserReward += thisTimeTotalReward;
                }
            }
        }
        
        return (thisTimeTotalReward, userCnt); 
    }
    
    //ok
    function withdraw(uint32 _amount) public returns(uint256){
        
        uint32 amount = _amount;
        
        if(amount > user[msg.sender].unPayedReward) {revert();}
        
        applyWithdraw(msg.sender, amount);
        
        protToken.transferFrom2(address(this), msg.sender, amount * 10 ** uint256(protToken.decimals()));
        
        return protToken.balanceOf(msg.sender);
    }
    
    //ok user function
    function withdrawMasterNode() public returns(uint256){
        
        uint32 withdrawAmount = withdrawMNcount * tokenPerMN;
        
        if(withdrawMNcount > user[msg.sender].mnCnt) {revert();}
        
        user[msg.sender].mnCnt -= withdrawMNcount;
                                    
        user[msg.sender].tokenCnt -= withdrawAmount;
        
        //totally close
        if(user[msg.sender].mnCnt == 0 && user[msg.sender].tokenCnt == 0){
            withdrawAmount += user[msg.sender].unPayedReward;
            user[msg.sender].applyTime     = 0;
            user[msg.sender].totalReward   = 0;
            user[msg.sender].unPayedReward = 0;
            user[msg.sender].payedReward   = 0;
        }
        
        protToken.transferFrom2(address(this), msg.sender, withdrawAmount  * 10 ** uint256(protToken.decimals()));
        
        return protToken.balanceOf(msg.sender);   
    }
    
    //ok
    function applyWithdraw(address _addr, uint32 _amount) private {
        
        user[_addr].unPayedReward -= _amount;
        user[_addr].payedReward   += _amount;
        
    }
    
    //ok - user function
    function closeMNandWithdrawl() public returns(uint256){
        
        uint256 closeMNandToken = (user[msg.sender].mnCnt * tokenPerMN) + user[msg.sender].unPayedReward;
        
        totalMNcount -= user[msg.sender].mnCnt;
        
        user[msg.sender].mnCnt         = 0;
        user[msg.sender].tokenCnt      = 0;
        user[msg.sender].applyTime     = 0;
        user[msg.sender].totalReward   = 0;
        user[msg.sender].unPayedReward = 0;
        user[msg.sender].payedReward   = 0;
        
        protToken.transferFrom2(address(this), msg.sender, closeMNandToken * 10 ** uint256(protToken.decimals()));
        
        return protToken.balanceOf(msg.sender);
    }

    // added
    function modUserMNstatus(address _user, uint16 _mnCnt, uint32 _totalReward) public onlyOwner returns (bool){
        
        uint16 userIdx = searchUserIndex(_user);
        
        if(userIdx == 65535){ 
            
            revert(); 
            
        }else{
            
            user[_user].mnCnt         = _mnCnt;
            user[_user].tokenCnt      = _mnCnt * tokenPerMN;
            user[_user].totalReward   = _totalReward;
            user[_user].unPayedReward = _totalReward - user[_user].payedReward;
            
            return true;
        }
    }
    
    function getUserInfo(address _user) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
      
        return (
            user[_user].mnCnt, 
            user[_user].tokenCnt, 
            user[_user].applyTime, 
            user[_user].totalReward, 
            user[_user].unPayedReward, 
            user[_user].payedReward
        );
    }
    
    //ok - user function
    function getMyInfo() public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
      
        return (
            user[msg.sender].mnCnt, 
            user[msg.sender].tokenCnt, 
            user[msg.sender].applyTime, 
            user[msg.sender].totalReward, 
            user[msg.sender].unPayedReward, 
            user[msg.sender].payedReward
        );
    }
    
    function getTotalMNcount() public view returns(uint256){
        return totalMNcount;
    }
    
    function getBalanceInfo() public view returns(uint256, uint256){
        
        uint256 tokenBalance = protToken.balanceOf(address(this));
        uint256 ethBalance   = address(this).balance;
        
        return (tokenBalance,ethBalance);
    }
    
    function getTotalUsersReward() public view returns(uint256){
        return totalUserReward;
    }
    
    function getEachUserReward(address _addr) public view returns(uint256, uint256){ 
        return (user[_addr].totalReward, user[_addr].unPayedReward);
    }
    
    //ok - user function
    function getCurrentReward() public view returns(uint16){
        if(now <= deployTime + aMonth){return rewardLevel[0];}    //36
        else if(now > deployTime + aMonth && now <= deployTime + (aMonth * 2)){return rewardLevel[1];}       //48
        else if(now > deployTime + (aMonth * 2) && now <= deployTime + (aMonth * 3)){return rewardLevel[2];} //40
        else if(now > deployTime + (aMonth * 3) && now <= deployTime + (aMonth * 4)){return rewardLevel[3];} //60 
        else if(now > deployTime + (aMonth * 4) && now <= deployTime + (aMonth * 5)){return rewardLevel[4];} //80
        else if(now > deployTime + (aMonth * 5) && now <= deployTime + (aMonth * 6)){return rewardLevel[5];} //84
        else if(now > deployTime + (aMonth * 6) && now <= deployTime + (aMonth * 8)){return rewardLevel[6];} //92
        else if(now > deployTime + (aMonth * 8) && now <= deployTime + (aMonth * 10)){return rewardLevel[7];} //96
        else if(now > deployTime + (aMonth * 10) && now <= deployTime + (aMonth * 12)){return rewardLevel[8];} //100
        else if(now > deployTime + (aMonth * 12) && now <= deployTime + (aMonth * 24)){return rewardLevel[9];} //72 
        else if(now > deployTime + (aMonth * 24) && now <= deployTime + (aMonth * 84)){return rewardLevel[10];} //36
        else{ return 0;}
    }
    
    //ok - user function
    function getTotalSupply() public view returns(uint256){
        return protToken.totalSupply();
    } 
    
    function getBalanceOf(address _user) public view returns(uint256){
        return protToken.balanceOf(_user);
    }
    
    //ok
    function todayPerNodeReward() private view returns(uint32){
    
        uint32 todayReward = ((dailyRewardCount * getCurrentReward()) / totalMNcount);
        
        return todayReward;
    }
    
    //ok - user function
    function getMyBalance() public view returns(uint256){
        return protToken.balanceOf(msg.sender);
    }
    
    //important
    function withdrawEth() public onlyOwner returns(bool){
        address(msg.sender).transfer(address(this).balance);
    }
    
    //important
    function withdrawPROTbalance(uint32 _amount) public onlyOwner returns(bool){
        
        protToken.transferFrom2(address(this), owner , _amount * 10 ** uint256(protToken.decimals()));
        
        return true;
    }
    
    //ok - user function
    function protTransfer(address _recipient, uint32 _amount) public returns(bool) {
        
        protToken.transferFrom2(msg.sender, _recipient , _amount * 10 ** uint256(protToken.decimals()));
        
        return true;
    }
    
    function getUsersLength() public view returns(uint256){
        return users.length;    
    }
    
    function getUserInfoByIndex(uint256 _index) public view returns(address, uint256){
        
        address userAccount = users[_index]; 
        
        return (userAccount, user[userAccount].mnCnt);
        
    }

    //added
    function searchUserIndex(address _user) public view returns(uint16) {
        
        for(uint16 i=0; i<users.length; i++){
            if(users[i] == _user){
                return i;
            }
        }
        
        return 65535;
    }
}