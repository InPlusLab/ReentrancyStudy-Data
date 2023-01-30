/**
 *Submitted for verification at Etherscan.io on 2020-07-21
*/

pragma solidity ^0.4.18;


/*
                 _     _   _                  _     _                         _         
  _ __    __ _  (_)   (_) (_)  _ __     ___  | |_  | |__     ___   _ __      (_)   ___  
 | '__|  / _` | | |   | | | | | '_ \   / _ \ | __| | '_ \   / _ \ | '__|     | |  / _ \ 
 | |    | (_| | | |   | | | | | | | | |  __/ | |_  | | | | |  __/ | |     _  | | | (_) |
 |_|     \__,_| |_|  _/ | |_| |_| |_|  \___|  \__| |_| |_|  \___| |_|    (_) |_|  \___/ 
                    |__/                                                                

https://www.raijinether.io/
*/

contract raijinether {
    struct MemberInfo {
        uint userID; address referrer; uint highPkg; uint totalpurchased;
    }
    struct MatrixInfo {
        bool isActive; uint enterred; address[] referrals; uint totalcyle;
    }
    mapping(uint => address) public userIds;
    mapping (address => MemberInfo)  memberInfos;
    mapping(uint => mapping(uint => MatrixInfo))  matrixInfos;
    mapping(address => uint) public balance;
    mapping(uint => uint) public matrixTransaction;
    uint256 public totalTransactions;
    address  owner;
    uint public lastID = 2;
    uint packageLvl;
    uint memberId;
    uint uplineUserId;
    constructor() public {
        owner = msg.sender;
        userIds[1] = owner;
        MemberInfo storage _memberInfo = memberInfos[owner];
        _memberInfo.userID = 1;
        _memberInfo.highPkg = 50 ether;
        _memberInfo.totalpurchased = _memberInfo.highPkg;
        for(uint i= 1; i<=10; i++)
        {
            MatrixInfo storage _newMatrixInfo = matrixInfos[1][i];
            _newMatrixInfo.isActive = true;
        }
        
    }
    function registration(address uplineAddress) external payable {
        require(msg.value >= 0.05 ether, "registration starts at 0.05");
        packageLvl = getPackageLevel(msg.value);
        memberId = getUserId(msg.sender);
        require(memberId == 0, "member is already registered.");
        bool memberHasPackage = hasSamePackage(msg.sender, packageLvl);
        require(!memberHasPackage, "member already registered to this level");
        uplineUserId  = getUserId(uplineAddress);
        require(uplineUserId > 0, "upline address not found");
        bool uplineHasPackage = hasSamePackage(uplineAddress, packageLvl);
        require(uplineHasPackage, "upline not registered to this level");
        
        MemberInfo storage _memberInfo = memberInfos[msg.sender]; 
        memberId = lastID++;   
        _memberInfo.referrer = uplineAddress;
        _memberInfo.userID = memberId;
        _memberInfo.highPkg = msg.value;
        _memberInfo.totalpurchased += msg.value;
        userIds[memberId] = msg.sender;  
            
        MatrixInfo storage _newMatrixInfo = matrixInfos[memberId][packageLvl];
        _newMatrixInfo.isActive = true;
        
        MatrixInfo storage _uplineMatrixInfo = matrixInfos[uplineUserId][packageLvl];
        _uplineMatrixInfo.referrals.push(msg.sender);
            
        if(uplineUserId == 1){
            owner.transfer(msg.value);
            balance[owner] += msg.value;
        }else{
            uint profit = msg.value / 2;
            
            if(_uplineMatrixInfo.enterred == 3){
                _uplineMatrixInfo.enterred = 0;
                _uplineMatrixInfo.totalcyle += 1;
                owner.transfer(profit);
                balance[owner] += profit;
            }else{
                
                _uplineMatrixInfo.enterred += 1;
                uplineAddress.transfer(profit);
                balance[uplineAddress] += profit;
            }
            
            disburseProfit(uplineAddress, profit, packageLvl);
        }
        
        //members.push(msg.sender) -1;
        totalTransactions += msg.value;
        matrixTransaction[packageLvl] += 1;
    }
    
    function disburseProfit(address _uplineAddress, uint _profit, uint _packageLvl) internal{
        
            address xRefAddress = _uplineAddress;
            uint remainProfit = _profit;

            uint basicProfit = (0.05 ether / 2) / 5;
            uint giveProfit = basicProfit;
            
            for(int i=1; i<=5; i++){
                    address indirectUpline = getUpline(xRefAddress);
                    if(indirectUpline != address(0)){
                        if(_packageLvl > 1){
                            giveProfit = getPkgValue(indirectUpline, _profit) / 5; 
                        }
                        indirectUpline.transfer(giveProfit);
                        balance[indirectUpline] += giveProfit;
                        remainProfit -= giveProfit;
                        xRefAddress = indirectUpline;
                    }else{
                        owner.transfer(remainProfit);
                        balance[owner] += remainProfit;
                        break;
                    }
            }
    }
    
    function buynewpackage() external payable {
        require(msg.value >= 0.5 ether, "upgrade starts from 0.5 eth");
        memberId = getUserId(msg.sender);
        require(memberId > 0, "register to matrix level 1 first");
        packageLvl = getPackageLevel(msg.value);
        require(packageLvl > 1, "invalid package amount entry");
        bool hasPackage = matrixInfos[memberId][packageLvl].isActive;
        require(!hasPackage, "you are already registered to this level");
        MatrixInfo storage _newMatrixInfo = matrixInfos[memberId][packageLvl];
        _newMatrixInfo.isActive = true;
        uint profit = msg.value / 2;
        
        address directUpline = getUpline(msg.sender);
        uint remainProfit = msg.value;
        
        MemberInfo storage _memberInfo = memberInfos[msg.sender]; 
        _memberInfo.totalpurchased += msg.value;
        
        if(_memberInfo.highPkg < msg.value){
            _memberInfo.highPkg = msg.value;
        }
        
        if(directUpline != address(0)){
            uint giveProfit = getPkgValue(directUpline, profit); 
            
            directUpline.transfer(giveProfit);
            balance[directUpline] += giveProfit;
            remainProfit -= giveProfit;
            owner.transfer(remainProfit);
            balance[owner] += remainProfit;
        }else{
            owner.transfer(msg.value);
            balance[owner] += msg.value;
        }
        
        totalTransactions += msg.value;
        matrixTransaction[packageLvl] += 1;
    }
    
    
    function getPackageLevel(uint amount) pure internal  returns (uint) {
        uint level = 0;
        if(amount == 0.5 ether){
            level = 2;
        }else if(amount == 1 ether){
            level = 3;
        }else if(amount == 3 ether){
            level = 4;
        }else if(amount == 5 ether){
            level = 5;
        }else if(amount == 10 ether){
            level = 6;
        }else if(amount == 15 ether){
            level = 7;
        }else if(amount == 20 ether){
            level = 8;
        }else if(amount == 30 ether){
            level = 9;
        }else if(amount == 50 ether){
            level = 10;
        }else{
            level = 1;
        }
        return level;
    }
    
    function getUserId(address _address) view public returns (uint userId) { 
        if(_address == owner){
            return 1;
        }
        return (memberInfos[_address].userID);
    }
    
    function hasSamePackage(address _address, uint _packageLvl) view internal returns (bool haspackage) {
        uint _userId = getUserId(_address);
        return matrixInfos[_userId][_packageLvl].isActive;
    }
    
    function getPkgValue(address _address, uint _amount) view internal returns (uint pkgValue) {
        uint _uplinePkg = memberInfos[_address].highPkg / 2;
        if(_uplinePkg >= _amount){
            return _amount;
        }
        return _uplinePkg;
    }
    
    function getHighestPkg(address _address) view public returns (uint HighestPackage) {
        return memberInfos[_address].highPkg;
    }
    function getTotalPurchased(address _address) view public returns (uint TotalPurchased) {
        return memberInfos[_address].totalpurchased;
    }
    
    function getUpline(address _address) view public returns (address upline) { 
        return (memberInfos[_address].referrer);
    }
    
    function getMatrixInfo(uint userId, uint level) view public returns (bool isactive, uint occupiedslots, uint totalcycle) {
        return (matrixInfos[userId][level].isActive, matrixInfos[userId][level].enterred, matrixInfos[userId][level].totalcyle);
    }
    
    function getAllReferrals(address _address, uint level) view public returns (address[] referrals) {
        uint _memberId = getUserId(_address);
        return (matrixInfos[_memberId][level].referrals);
    }
    
    function getAllReferralsById(uint userId , uint level) view public returns (address[] referrals) {
        return (matrixInfos[userId][level].referrals);
    }
    
}