/**
 *Submitted for verification at Etherscan.io on 2020-07-18
*/

/**
*
* SmartCity
* https://ethercity.com
* (only for ethercity.com Community)
*
**/


pragma solidity ^0.5.15;

contract EtherCity {

    struct User {
        uint id;
        address refBy;
        address[] refs;
        uint refsCount;
        uint teamCount;
        // uint networkSize;

        mapping(uint => bool) activeMember;

        mapping(uint => Matrix) CityMatrix;

        mapping(uint => Myearnings) earnings;
    }

    struct Matrix {
        address refBy;
        address[] refs1;
        address[] refs2;
        bool active;
        uint expiresOn;
        uint reinvestCount;
    }

    struct Myearnings{
        uint dreEarnings;
        uint matrixEarnings;
        uint missedEarnings;
        uint matchingBonus;
        uint missedBonus;
    }

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances;
    
    bool public matrixInitialized = false;
    
    address private vaultMissed = 0x217E758839395FCd954C912519f5b8FB7F22E393;
    address public contractor;
    uint private MatrixexpiresOn_0 = 100000 days;
    uint private MatrixexpiresOn_1 = 30 days;
    uint private MatrixexpiresOn_2 = 60 days;
    uint private MatrixexpiresOn_3 = 90 days;
    uint private MatrixexpiresOn_4 = 120 days;
    
    
    uint public lastUserId = 1;
    uint public activeUsers = 1;
    uint public raisedToday = 0 ether;
    uint public raisedTotal = 0 ether;
    uint public distEarning = 0 ether;
    uint public lostEarnings = 0 ether;
    uint public matrixIncomes = 0 ether;
    uint public matchIncomes = 0 ether;
    uint public joinedToday = 0;
    uint public lasUpdate = now;

    uint private dre    = 10;
    uint private refs1  = 18;
    uint private refs1b = 9;
    uint private refs2  = 40;
    uint private refs2b = 20;
    uint private fees   = 1; // x3

    mapping(address => Initialisation) private inits;

    struct Initialisation{
        address[] members;
    }

    // address[] inits;

    mapping(uint => uint) public levelPrice;

    event NewUser(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Renewal(address indexed user, address indexed referrer, address indexed caller, uint matrix, uint level);
    event Upgrade(address indexed user, address indexed referrer, uint matrix);
    event NewDownline(address indexed user, address indexed referrer, uint level, uint generation, uint count);
    event DividentReceived(address indexed from, address indexed receiver, uint matrix, uint level);
    event MissedDivident(address indexed receiver, address indexed from, uint matrix, uint level, uint _type);
    event MissedEarnings(address indexed _beneficiary, uint _level, uint _position, uint _amount);

    constructor() public {

        contractor = msg.sender;

        User memory user = User({
            id: 1,
            refBy: address(0),
            refs: new address[](0),
            refsCount: uint(0),
            teamCount: uint(0)
        });

        users[contractor] = user;
        idToAddress[lastUserId] = contractor;
        userIds[lastUserId] = contractor;


        lastUserId++;
        joinedToday++;

        for (uint i = 1; i <= 12; i++) {
            users[contractor].activeMember[i] = true;
            users[contractor].CityMatrix[i].expiresOn = now + MatrixexpiresOn_0;
            users[contractor].CityMatrix[i].active = true;
        }
        // matrixInitialisation();

    }

    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, contractor);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }

    modifier validMatrixId(uint _matrixId) {
        require(_matrixId > 0 && _matrixId < 13, 'Invalid MatrixId');
        _;
    }
    
    modifier validateContractor(address _userId){
        require(_userId == contractor && address(this).balance > 0);
        _;
    }
    
    function afterOneDay(uint _lastUpdate) private view returns(bool){
        if(now >= _lastUpdate + 1 * 1 days){
            return true;
        }
        else{
            return false;
        }
    }
    
    function cannotJumpStages(address _userId, uint _matrixId) private view returns(bool canJoin){
        canJoin = true;
        for(uint p = _matrixId - 1; p > 0; p--){
            canJoin = users[_userId].CityMatrix[p].active;
        }
    }
    
    function highestStage(address _userId) public view returns(uint){
        uint p = 12;
        for(p - 1; p > 0; p--){
            if(users[_userId].CityMatrix[p].active){
                break;
            }
        }
        return p;
    }
    
    function newSignup(address _sponsor) external payable{
        require(msg.value == levelPrice[1], 'To register you Must Buy House 1 which costs 0.025 ether');
        require(!isUserExists(msg.sender), 'Already Registered');
        require(isUserExists(_sponsor), 'Invalid Sponsor Id');
        registration(msg.sender, _sponsor);
    }
    
    function registration(address _userId, address _sponsor) private{
        User memory user = User({
            id: lastUserId,
            refBy: _sponsor,
            refs: new address[](0),
            refsCount: uint(0),
            teamCount: uint(0)
        });
        
        users[_userId] = user;
        idToAddress[lastUserId] = _userId;
        userIds[lastUserId] = _userId;
        users[_userId].refBy = _sponsor;
        lastUserId++;

        users[_sponsor].refs.push(_userId);
        users[_sponsor].refsCount++;
        // Activates House1
        getProperty(_userId, 1);
        activeUsers++;
        if(afterOneDay(lasUpdate)){
            joinedToday = 0;
        }
        else{
            joinedToday++;
        }
        updateTeamData(_userId);
        // mPurchases += msg.value;
        emit NewUser(_userId, _sponsor, users[_userId].id, users[_sponsor].id);
    }
    
    function buyNewProperty(uint _matrixId) external payable validMatrixId(_matrixId){
        address _userId = msg.sender;
        require(isUserExists(_userId), 'You Must be a Registered Member');
        require(msg.value ==  levelPrice[_matrixId], 'Invalid amount');
        uint32 size;
        assembly {
            size := extcodesize(_userId)
        }
        require(size == 0, "cannot be a contract");
        if(_matrixId > 1){
            require(cannotJumpStages(_userId, _matrixId), 'You cannot Jump Stages');
        }
        getProperty(_userId, _matrixId);
    }
    
    function getProperty(address _userId, uint _matrixId) private {
        uint cost = levelPrice[_matrixId];
        
        uint _level = _matrixId;
        uint expiresOn = 0;
        if(users[_userId].id < 5){
            users[_userId].CityMatrix[_level].expiresOn = MatrixexpiresOn_0;
        }
        else{
           if(_level >= 1 && _level < 4){
               expiresOn = MatrixexpiresOn_1;
           }
           if(_level >= 4 && _level < 7){
               expiresOn = MatrixexpiresOn_2;
           }
           if(_level >= 7 && _level < 10){
               expiresOn = MatrixexpiresOn_3;
           }
           if(_level >= 10 && _level < 13){
               expiresOn = MatrixexpiresOn_4;
           }

           if(users[_userId].CityMatrix[_level].expiresOn < now || users[_userId].CityMatrix[_level].expiresOn == 0){
               users[_userId].CityMatrix[_level].expiresOn = now + expiresOn;
           }else{
               users[_userId].CityMatrix[_level].expiresOn += expiresOn;
           }
        }

        adminDivident(cost, 1);

        if(users[_userId].CityMatrix[_level].reinvestCount >= 1){
            // Renewal
            address _firstUpline = users[_userId].CityMatrix[_level].refBy;
            address _secondUpline = users[_firstUpline].refBy;
            processLevel(_firstUpline, _secondUpline, _level);
            users[_userId].CityMatrix[_level].reinvestCount++;
        }else{
            users[_userId].activeMember[_level] = true;
            users[_userId].CityMatrix[_level].active = true;
            users[_userId].CityMatrix[_level].reinvestCount = 1;
            DirectReferral(users[_userId].refBy, cost);
            // update Upline
            updateMatrixUpliner(_userId, getUpline(_userId, users[_userId].refBy, _level, 1), _matrixId);
        }
        if(afterOneDay(lasUpdate)){
            lasUpdate = now;
            raisedToday = 0;
        }
        else{
            raisedToday += cost;
        }
        raisedTotal += cost;
        emit Upgrade(_userId, users[_userId].refBy, _matrixId);
    }

    function getUpline(address _self, address _userId, uint _level, uint up) private returns(address){
        if(guDownlines(_userId, _level) < 3){
            if(checkActiveStatus(_userId, _level)){
                return _userId;
            }
            else{
                if(up == 1){
                    // Missed Income
                    // missedEarnings(_userId, _level);
                    // next Availble Upline
                    return getUpline(_self, users[_userId].refBy, _level, 2);
                }
                if(up == 2){
                    return getUpline(_self, contractor, _level, 3);
                }
            }
        }
        else{
            return spillOver(_self, _userId, _level);
        }
    }
    
    function spillOver(address _self, address _userId, uint _level) private returns(address){
        uint v = 0;
        while(v < 3){
            address downline = users[_userId].CityMatrix[_level].refs1[v];
            if(guDownlines(downline, _level) < 3){
                if(checkActiveStatus(downline, _level)){
                    return downline;
                }
            }
            v++;
        }
        uint d = 0;
        for(uint e = 0; e < users[_userId].refs.length; e++){
            address ddownline = users[_userId].refs[e];
            if(ddownline != _self){
                if(guDownlines(ddownline, _level) < 3){
                    if(checkActiveStatus(ddownline, _level)){
                        return ddownline;
                    }
                }
                else{
                    while(d < 3){
                        address dddownline = users[ddownline].CityMatrix[_level].refs1[d];
                        if(guDownlines(dddownline, _level) < 3){
                            if(checkActiveStatus(dddownline, _level)){
                                return dddownline;
                            }
                        }
                        d++;
                    }
                }
            }
        }
    }
    
    function updateTeamData(address _userId) private returns(bool){
        while(users[_userId].refBy != address(0)){
            users[users[_userId].refBy].teamCount++;
            _userId = users[_userId].refBy;
        }
        return true;
    }

    function updateMatrixUpliner(address _userId, address _upline, uint _level) private {
        users[_userId].CityMatrix[_level].refBy = _upline;
        users[_upline].CityMatrix[_level].refs1.push(_userId); // Level 1
        address _upline2 = users[_upline].CityMatrix[_level].refBy;
        users[_upline2].CityMatrix[_level].refs2.push(_userId); // Level 2
        processLevel(_upline, _upline2, _level);
        emit NewDownline(_userId, _upline, _level, 1, uint(users[_upline].CityMatrix[_level].refs1.length));
        emit NewDownline(_userId, _upline2, _level, 2, uint(users[_upline2].CityMatrix[_level].refs2.length));
    }

    function processLevel(address _firstUpline, address _secondUpline, uint _level) private{
        matrixIncome(_firstUpline, levelPrice[_level], _level, 1); // MI1
        matchIncome(users[_firstUpline].refBy, levelPrice[_level], _level, 1); // MB1
        matrixIncome(_secondUpline, levelPrice[_level], _level, 2); // MI2
        matchIncome(users[_secondUpline].refBy, levelPrice[_level], _level, 2); // MB2
    }

    function DirectReferral(address _userId, uint _amount) private{
        uint payDre = dre * _amount / 100;
        users[_userId].earnings[0].dreEarnings += payDre;
        dividentDistribution(_userId, payDre);
    }
    
    function matrixIncome(address _userId, uint _amount, uint _level, uint _position) private{
        uint refsc;
        if(_position == 1){
            refsc = refs1;
        }else{
            refsc = refs2;
        }
        
        uint payLevel = refsc * _amount / 100;
        users[_userId].earnings[0].matrixEarnings += payLevel;
        matrixIncomes += payLevel;
        address beneficiray;
        if(users[_userId].id > 1){
            beneficiray = checkBeneficiary(_userId, _level, 1, payLevel);
        }
        else{
            beneficiray = _userId;
        }
        dividentDistribution(beneficiray, payLevel);
    }

    function matchIncome(address _userId, uint _amount, uint _level, uint _position) private{
        uint refsb;
        if(_position == 1){
            refsb = refs1b;
        }else{
            refsb = refs2b;
        }
    
        uint payMb = refsb * _amount / 100;
        users[_userId].earnings[0].matchingBonus += payMb;
        matchIncomes += payMb;
        dividentDistribution(checkBeneficiary(_userId, _level, 2, payMb), payMb);
    }
    
    function dividentDistribution(address _userId, uint _amount) internal returns(bool){
        if(users[_userId].id == 1){
            adminDivident(_amount, 2);
        }
        else if(users[_userId].id == 3){
            contractDivident(_userId, _amount);
        }
        else{
            address(uint160(_userId)).transfer(_amount);
        }
        distEarning += _amount;
        // Emit Earnings Received
        return true;
    }

    function adminDivident(uint _amount, uint _type) internal returns(bool){
        uint pay;
        // uint div = _amount / 100;
        if(_type == 1){
            pay = _amount * fees / 100;
        }
        else{
            // pay = _amount * 33 / 100;
            pay = _amount / 3;
        }
        for(uint m = 0; m < 3; m++){
            address _admin = users[contractor].refs[m];
            if(m == 1){
                contractDivident(_admin, pay);
            }else{
                address(uint160(_admin)).transfer(pay);
            }
        }
        return true;
    }

    function contractDivident(address _userId, uint _amount) internal returns(bool){
        uint pay1 = _amount * 60 / 100;
        uint pay2 = _amount * 40 / 100;
        address(uint160(_userId)).transfer(pay1);
        address(uint160(contractor)).transfer(pay2);
        return true;
    }

    function checkBeneficiary(address _userId, uint _level, uint _type, uint _amount) private returns(address _beneficiary){
        if(checkActiveStatus(_userId, _level)){
            _beneficiary = _userId;
        }
        else{
            emit MissedEarnings(_userId, _level, _type, _amount);
            if(_type == 1){
                users[_userId].earnings[0].missedEarnings += _amount;
            }else{
                users[_userId].earnings[0].missedBonus += _amount;
            }
            lostEarnings += _amount;
            _beneficiary = vaultMissed;
        }
    }
    
    function getFallBackEther() public payable validateContractor(msg.sender){
        address(uint160(contractor)).transfer(address(this).balance);
    }
    
    function guDownlines(address _userId, uint _level) public view returns(uint){
        return users[_userId].CityMatrix[_level].refs1.length;
    }

    function checkActiveStatus(address _userId, uint _level) private returns(bool){
        if(!users[_userId].activeMember[_level] || users[_userId].CityMatrix[_level].expiresOn < now){
            users[_userId].activeMember[_level] = false;
            users[_userId].CityMatrix[_level].active = false;
            return false;
        }
        
        return true;
    }
    
    function matrixInitialisation() public returns(bool){
        require(msg.sender == contractor, 'Sorry you cannot Run this Function');
        
        require(matrixInitialized == false, 'Matrix Already Initialized');
        
        levelPrice[1] = 0.025 ether;
        for (uint i = 2; i <= 12; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        users[contractor].refs.push(0x4cDd2f156534d62b872B3C9E1876925207141a5e); // 0x4cDd2f156534d62b872B3C9E1876925207141a5e

        users[contractor].refs.push(0xA652D6520e3f092eB0Acf7F0DB9A1bC097AA5147); // 0xc12f180e02fb1b401946bd943d6de5150d5e4fc7

        users[contractor].refs.push(0xB9d504c6826875635C5f1F94E30F61E8D533a8Bd); // 0xB9d504c6826875635C5f1F94E30F61E8D533a8Bd

        for(uint i = 0; i < users[contractor].refs.length; i++){
            address _userId = users[contractor].refs[i];
            User memory user = User({
                id: lastUserId,
                refBy: address(contractor),
                refs: new address[](0),
                refsCount: uint(0),
                teamCount: uint(0)
            });

            users[_userId] = user;
            idToAddress[lastUserId] = _userId;
            userIds[lastUserId] = _userId;
            for (uint b = 1; b <= 12; b++) {
                users[_userId].activeMember[b] = true;
                users[_userId].CityMatrix[b].active = true;
                users[_userId].CityMatrix[b].expiresOn = now + MatrixexpiresOn_0;
            }

            users[contractor].refsCount++;
            activeUsers++;

            lastUserId++;
            joinedToday++;
            
            updateTeamData(_userId);
        }
        

        address _upline = users[contractor].refs[1];
        users[_upline].refs.push(0x22cFacA660BcaB211F9AbefD96396C8019fb6e5F);
        
        for(uint mi = 1; mi <= 12; mi++){
            if(users[contractor].CityMatrix[mi].refs1.length < 3){
                for(uint downe = 0; downe < users[contractor].refs.length; downe++){
                    address _userId = users[contractor].refs[downe];
                    users[_userId].CityMatrix[mi].refBy = contractor;
                    users[contractor].CityMatrix[mi].refs1.push(_userId);
                }
            }
        }
        
        User memory user = User({
            id: lastUserId,
            refBy: address(users[contractor].refs[1]),
            refs: new address[](0),
            refsCount: uint(0),
            teamCount: uint(0)
        });
        
        address _userId = users[_upline].refs[0];
        users[_userId] = user;
        idToAddress[lastUserId] = _userId;
        userIds[lastUserId] = _userId;
        for (uint b = 1; b <= 12; b++) {
            users[_userId].activeMember[b] = true;
            users[_userId].CityMatrix[b].active = true;
            users[_userId].CityMatrix[b].expiresOn = now + MatrixexpiresOn_0;
        }
        users[_upline].refsCount++;
        for(uint mi = 1; mi <= 12; mi++){
            if(users[_upline].CityMatrix[mi].refs1.length < 3){
                users[_userId].CityMatrix[mi].refBy = _upline;
                users[_upline].CityMatrix[mi].refs1.push(_userId);
                users[contractor].CityMatrix[mi].refs2.push(_userId);
            }
        }
        
        activeUsers++;
        lastUserId++;
        joinedToday++;
        
        updateTeamData(_userId);
            
        matrixInitialized = true;
        return true;
    }
    
    function stats() public view returns(uint lId, uint aU, uint rT, uint rTl, uint dE, uint lE, uint mI, uint mCI, uint jT){
        return (lastUserId, activeUsers, raisedToday, raisedTotal, distEarning, lostEarnings, matrixIncomes, matchIncomes, joinedToday);
    }

    function getUserData(address _userId) public view returns(address _refBy, uint _refs, uint _myTeam, uint _earnings, uint _dearnings, uint _mearnings, uint _maearnings, uint _missedEarning){
        require(isUserExists(_userId), 'Sorry No User Found with matching ETH Address!');
        _refBy = users[_userId].refBy;
        _refs = users[_userId].refsCount;
        _dearnings = users[_userId].earnings[0].dreEarnings;
        _mearnings = users[_userId].earnings[0].matrixEarnings;
        _maearnings = users[_userId].earnings[0].matchingBonus;
        _earnings = _dearnings + _maearnings + _mearnings;
        _missedEarning = users[_userId].earnings[0].missedEarnings + users[_userId].earnings[0].missedBonus;
        _myTeam = users[_userId].teamCount;
    }

    function isUserExists(address _userAddress) public view returns (bool) {
        return (users[_userAddress].id != 0);
    }
    
    function usersActiveCityMatrix(address _userId, uint _level) public view returns(bool){
        return users[_userId].activeMember[_level];
    }

    function userMatrixExpiration(address _userId, uint _level) public view returns(uint){
        return users[_userId].CityMatrix[_level].expiresOn;
    }

    function usersMatrix(address _userId, uint _level) public view returns(address, address[] memory, address[] memory, bool) {
        return (users[_userId].CityMatrix[_level].refBy,
                users[_userId].CityMatrix[_level].refs1,
                users[_userId].CityMatrix[_level].refs2, users[_userId].CityMatrix[_level].active);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}