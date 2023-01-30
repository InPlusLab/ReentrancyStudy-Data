/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

/**
*
* SmartCity
* https://ethercity.io
* (only for ethercity.io Community)
* Version 2.0
*
**/

pragma solidity ^0.5.17;

contract EtherCity2 {
    
    EtherCity internal EtherCity_v1;

    struct User {
        uint id;
        bool isSynched;
        address refBy;
        address[] refs;
        uint afund;
        uint pool_bonus;
        uint withdrawn;
        uint dreEarnings;
        uint matrixEarnings;
        uint missedEarnings;
        uint matchingBonus;
        uint missedBonus;
        uint refsCount;
        uint teamCount;
        uint teamvolume; // Resets Weekly

        mapping(uint => bool) activeMember;

        mapping(uint => Matrix) CityMatrix;
    }

    struct Matrix {
        address refBy;
        address[] refs1;
        address[] refs2;
        uint earnings;
        bool computed;
        bool active;
        uint expiresOn;
        uint reinvestCount;
    }
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(uint => address) public pool_lead;
    
    mapping(uint => uint) internal levelPrice;
    mapping(uint => uint) internal poolPrizes;
    mapping(uint => mapping(address => uint)) internal pool_users_balance;
    uint internal pool_last_draw = uint(block.timestamp);
    uint internal nexpool = 1;
    
    uint internal MatrixexpiresOn = 100 days;
    
    uint public lastUserId = 1;
    uint internal activeUsers = 1;
    uint internal raisedToday = 0 ether;
    uint internal raisedTotal = 0 ether;
    uint internal distEarning = 0 ether;
    uint internal lostEarnings = 0 ether;
    uint internal matrixIncomes = 0 ether;
    uint internal matchIncomes = 0 ether;
    uint internal joinedToday;
    uint internal pool_balance = 0 ether;
    uint internal safety_funds = 0 ether;
    uint internal lastUpdate = uint(block.timestamp);
    uint internal lastSynched = 1;
    
    bool internal allowSyncing;
    bool internal citySyncing;

    uint internal constant dre    = 10;
    uint internal constant refs1  = 10;
    uint internal constant refs1b = 5;
    uint internal constant refs2  = 30;
    uint internal constant refs2b = 15;
    uint internal constant system = 5;
    uint internal constant safetyR = 20;
    uint internal constant poolR = 5;
    uint internal constant poolShare = 15;
    uint internal constant divider = 100;
    
    address internal constant vaultMissed = 0x217E758839395FCd954C912519f5b8FB7F22E393;
    address internal contractor;
    address internal admin;

    event NewUser(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Renewal(address indexed user, address indexed referrer, address indexed caller, uint matrix, uint level);
    event Upgrade(address indexed user, address indexed referrer, uint matrix);
    event NewDownline(address indexed user, address indexed referrer, uint level, uint generation, uint count);
    event DividentReceived(address indexed from, address indexed receiver, uint matrix, uint level);
    event MissedDivident(address indexed receiver, address indexed from, uint matrix, uint level, uint _type);
    event MissedEarnings(address indexed _beneficiary, uint _level, uint _position, uint _amount);

    constructor(address _admin) public {
        contractor = msg.sender;
        admin = _admin;
        
        levelPrice[1] = 0.025 ether;
        for (uint i = 2; i <= 12; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
    }

    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, contractor);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }
    
    modifier onlyContractor(){
        require(msg.sender == contractor, 'You do not have Permission to Proceed!');
        _;
    }
    
    function newSignup(address _sponsor) public payable{
        address _userId = msg.sender;
        require(msg.value == levelPrice[1], 'To register you Must Buy House 1 which costs 0.025 ether');
        require(!isUserExists(_userId), 'Already Registered');
        require(isUserExists(_sponsor), 'Invalid Sponsor Id');
        
        registration(_userId, _sponsor);
        activeUsers++;
        joinedToday++;
        lastUserId++;
        updateTeamData(_userId);
        getProperty(_userId, 1);
        
        emit NewUser(_userId, _sponsor, users[_userId].id, users[_sponsor].id);
    }
    
    function registration(address _userId, address _sponsor) internal{
        require(allowSyncing, 'Registration Closed');
        
        User memory user = User({
            id: lastUserId,
            isSynched: true,
            refBy: _sponsor,
            refs: new address[](0),
            afund: uint(0),
            pool_bonus: uint(0),
            withdrawn: uint(0),
            dreEarnings: uint(0),
            matrixEarnings: uint(0),
            missedEarnings: uint(0),
            matchingBonus: uint(0),
            missedBonus: uint(0),
            refsCount: uint(0),
            teamCount: uint(0),
            teamvolume: uint(0)
        });
        
        users[_userId] = user;
        idToAddress[lastUserId] = _userId;
        userIds[lastUserId] = _userId;
        users[_userId].refBy = _sponsor;
        
        users[_sponsor].refs.push(_userId);
        users[_sponsor].refsCount++;
        
    }
    
    function buyNewProperty(uint _matrixId) public payable {
        require(_matrixId > 0 && _matrixId < 13, 'Wrong Matrix');
        address _userId = msg.sender;
        require(isUserExists(_userId), 'You Must be a Registered Member');
        require(msg.value ==  levelPrice[_matrixId], 'Invalid amount');
        uint32 size;
        assembly {
            size := extcodesize(_userId)
        }
        require(size == 0, "cannot be a contract");
        bool canJoin = true;
        if(_matrixId > 1){
            for(uint p = _matrixId - 1; p > 0; p--){
                canJoin = users[_userId].CityMatrix[p].active;
            }
        }
        require(canJoin, 'Cannot Jump Stages');
        getProperty(_userId, _matrixId);
    }
    
    function getProperty(address _userId, uint _matrixId) internal {
        
        uint cost = levelPrice[_matrixId];
        
        uint _level = _matrixId;
        
        incentivePool(_userId, _level);

        if(users[_userId].CityMatrix[_level].expiresOn < block.timestamp || users[_userId].CityMatrix[_level].expiresOn == 0){
            users[_userId].CityMatrix[_level].expiresOn = uint(block.timestamp) + MatrixexpiresOn;
        }else{
            users[_userId].CityMatrix[_level].expiresOn += MatrixexpiresOn;
        }
        
        uint payDre = cost * dre / divider;
        users[users[_userId].refBy].dreEarnings += payDre;
        dividentDistribution(users[_userId].refBy, payDre, _level);

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
            // update Upline
            updateMatrixUpliner(_userId, getUpline(_userId, users[_userId].refBy, _level, 1), _matrixId);
        }
        
        users[_userId].CityMatrix[_level].computed = false;
        
        incomeDistribution(cost, 1);
        
        raisedToday += cost;
        
        if(block.timestamp >= lastUpdate + 1 days){
            joinedToday = 0;
            raisedToday = 0;
            lastUpdate = uint(block.timestamp);
        }
        raisedTotal += cost;
        if(block.timestamp >= pool_last_draw + 7 days){
            drawPool();
        }
        
        emit Upgrade(_userId, users[_userId].refBy, _matrixId);
    }
    
    function incentivePool(address _userId, uint _level) internal{
        address upline = users[_userId].refBy;
        uint _amount = levelPrice[_level];
        if(upline != address(0)){
            users[upline].teamvolume += _amount;
            pool_users_balance[nexpool][upline] += _amount;
            for(uint i = 0; i < 5; i++){
                if(pool_lead[i] == upline){
                    break;
                }
                else if(pool_lead[i] == address(0)){
                    pool_lead[i] = upline;
                    break;
                }
                if(pool_users_balance[nexpool][upline] > pool_users_balance[nexpool][pool_lead[i]]){
                    for(uint p = i + 1; p < 5; p++){
                        if(pool_lead[p] == upline){
                            for(uint k = p; k <= 5; k++){
                                pool_lead[k] = pool_lead[k + 1];
                            }
                            break;
                        }
                    }
    
                    for(uint p = 4; p > i; p--) {
                        pool_lead[p] = pool_lead[p - 1];
                    }
    
                    pool_lead[i] = upline;
    
                    break;
                }
            }
        }
    }

    function getUpline(address _self, address _userId, uint _level, uint up) internal returns(address){
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
    
    function updateTeamData(address _userId) internal returns(bool){
        while(users[_userId].refBy != address(0)){
            users[users[_userId].refBy].teamCount++;
            _userId = users[_userId].refBy;
        }
        return true;
    }

    function updateMatrixUpliner(address _userId, address _upline, uint _level) internal {
        users[_userId].CityMatrix[_level].refBy = _upline;
        users[_upline].CityMatrix[_level].refs1.push(_userId); // Level 1
        address _upline2 = users[_upline].CityMatrix[_level].refBy;
        users[_upline2].CityMatrix[_level].refs2.push(_userId); // Level 2
        processLevel(_upline, _upline2, _level);
        // emit NewDownline(_userId, _upline, _level, 1, uint(users[_upline].CityMatrix[_level].refs1.length));
        // emit NewDownline(_userId, _upline2, _level, 2, uint(users[_upline2].CityMatrix[_level].refs2.length));
    }

    function processLevel(address _firstUpline, address _secondUpline, uint _level) internal{
        matrixIncome(_firstUpline, levelPrice[_level], _level, 1); // MI1
        if(users[_firstUpline].refBy != address(0)){
            matchIncome(users[_firstUpline].refBy, levelPrice[_level], _level, 1); // MB1
            matrixIncome(_secondUpline, levelPrice[_level], _level, 2); // MI2
            matchIncome(users[_secondUpline].refBy, levelPrice[_level], _level, 2); // MB2
        }
    }
    
    function matrixIncome(address _userId, uint _amount, uint _level, uint _position) internal{
        uint refsc;
        if(_position == 1){
            refsc = refs1;
        }else{
            refsc = refs2;
        }
        
        // uint payLevel = SafeMath.mul(_amount , SafeMath.div(refsc , divider));
        uint payLevel = _amount * refsc / divider;
        users[_userId].matrixEarnings += payLevel;
        matrixIncomes += payLevel;
        address beneficiray;
        if(users[_userId].id > 1){
            beneficiray = checkBeneficiary(_userId, _level, 1, payLevel);
        }
        else{
            beneficiray = _userId;
        }
        dividentDistribution(beneficiray, payLevel, _level);
    }

    function matchIncome(address _userId, uint _amount, uint _level, uint _position) internal{
        uint refsb;
        if(_position == 1){
            refsb = refs1b;
        }else{
            refsb = refs2b;
        }
    
        // uint payMb = SafeMath.mul(_amount, SafeMath.div(refsb , divider));
        uint payMb = _amount * refsb / divider;
        users[_userId].matchingBonus += payMb;
        matchIncomes += payMb;
        dividentDistribution(checkBeneficiary(_userId, _level, 2, payMb), payMb, _level);
    }
    
    function dividentDistribution(address _userId, uint _amount, uint _level) internal returns(bool){
        if(users[_userId].id == 1){
            incomeDistribution(_amount, 2);
        }
        else{
            // address(uint160(_userId)).transfer(_amount);
            users[_userId].afund += _amount;
            users[_userId].CityMatrix[_level].earnings += _amount;
        }
        distEarning += _amount;
        // Emit Earnings Received
        return true;
    }

    function incomeDistribution(uint _amount, uint _type) internal returns(bool){
        uint pay;
        if(_type == 1){
            // pay = SafeMath.div(SafeMath.mul(_amount, SafeMath.div(system, divider)), 4);
            
            uint rpay = _amount * system / divider;
            pay = rpay  / 4;
            // safety_funds += SafeMath.mul(_amount, SafeMath.div(safetyR, divider));
            // pool_balance += SafeMath.mul(_amount, SafeMath.div(poolR, divider));
            safety_funds += _amount * safetyR / divider;
            pool_balance += _amount * poolR / divider;
        }
        else{
            pay = _amount / 4;
        }
        for(uint m = 2; m <= 5; m++){
            address _admin = userIds[m];
            users[_admin].afund += pay;
        }
        return true;
    }

    function checkBeneficiary(address _userId, uint _level, uint _type, uint _amount) internal returns(address _beneficiary){
        if(checkActiveStatus(_userId, _level)){
            _beneficiary = _userId;
        }
        else{
            emit MissedEarnings(_userId, _level, _type, _amount);
            if(_type == 1){
                users[_userId].missedEarnings += _amount;
            }else{
                users[_userId].missedBonus += _amount;
            }
            lostEarnings += _amount;
            _beneficiary = userIds[1];
        }
    }
    
    function drawPool() internal {
        pool_last_draw = uint(block.timestamp);
        nexpool++;
        for(uint i = 0; i < 5; i++){
           uint _amount = pool_balance * poolPrizes[i + 1] / divider;
           users[pool_lead[i]].afund += _amount;
           users[pool_lead[i]].pool_bonus += _amount;
        }
        
        pool_balance -= pool_balance * poolShare  / divider;
      
        for(uint8 i = 0; i < 5; i++) {
            pool_lead[i] = address(0);
        }
    }

    function aDrawPool() public {
        require(msg.sender == address(admin),  'Permission Denied!');
        require(block.timestamp >= pool_last_draw + 7 days, 'Weekly Only!');
        drawPool();
    } 
    
    function computeSafety(address _userId, uint _level) public payable {
        // require(_expiresOn <= block.timestamp, 'Wait expiration');
        require(block.timestamp >= users[_userId].CityMatrix[_level].expiresOn && earningsRatio(_userId, _level) > 0, 'Wait expiration!');
        require(!users[_userId].CityMatrix[_level].computed, 'Already Computed!');
        uint _amount = users[_userId].afund + earningsRatio(_userId, _level);
        require(address(this).balance > _amount + _amount * 15  / divider, 'Unavailable Funds!');
        users[_userId].afund = 0;
        users[msg.sender].withdrawn += _amount;
        safety_funds -= earningsRatio(_userId, _level);
        users[_userId].CityMatrix[_level].earnings += earningsRatio(_userId, _level);
        users[_userId].CityMatrix[_level].computed = true;
        address(uint160(msg.sender)).transfer(_amount);
    }
    
    function earningsRatio(address _userId, uint _level) internal view returns(uint){
        if(users[_userId].CityMatrix[_level].reinvestCount >= 1){
            uint safetyProfit = users[_userId].CityMatrix[_level].reinvestCount * levelPrice[_level] * 120 / divider;
            uint actualProfit = users[_userId].CityMatrix[_level].earnings;
            if(actualProfit < safetyProfit){
                return safetyProfit - actualProfit;
            }
        }
    }
    
    function syncOldUsers() public {
        if(address(EtherCity_v1) == address(0)){
            EtherCity_v1 = EtherCity(0xea1CdB66886CC2d0C6c60F8BbD4aEd37E6A88062);
        }
        require(!allowSyncing, 'closed');
        // GetUserAddress
        address _userId = msg.sender;
        (bool userXists) = EtherCity_v1.isUserExists(_userId);
        if(userXists){
            if(!isUserExists(_userId)){
                (address _refBy, uint refs, uint _myTeam, uint earnings, uint _dearnings, uint _mearnings, uint _maearnings, uint _missedEarning) = EtherCity_v1.getUserData(_userId);
                // Registered
                registration(_userId, _refBy);
                users[_userId].isSynched = false;
                users[_userId].withdrawn = earnings;
                users[_userId].dreEarnings = _dearnings;
                users[_userId].matrixEarnings = _mearnings;
                users[_userId].missedEarnings = _missedEarning * 0;
                users[_userId].matchingBonus = _maearnings;
                users[_userId].refsCount = refs;
                users[_userId].teamCount = _myTeam;
                lastUserId++;
                // Restructure Matrix Here
                synchMatrix(_userId);
            }
        }
    }
    
    function synchMatrix(address _userId) private {
        if(isUserExists(_userId) && !users[_userId].isSynched){
            for(uint i = 1; i <= 12; i++){
                (address _sponsor, address[] memory level1, address[] memory level2, bool status) = EtherCity_v1.usersMatrix(_userId, i);
                if(status){
                    users[_userId].CityMatrix[i].active = true;
                    users[_userId].activeMember[i] = true;
                    users[_userId].CityMatrix[i].expiresOn = EtherCity_v1.userMatrixExpiration(_userId, i);
                    if(_sponsor != address(0)){
                        users[_userId].CityMatrix[i].refBy = _sponsor;
                    }
                    else{
                        users[_userId].CityMatrix[i].refBy = address(0);
                    }
                    
                    for(uint d = 0; d < level1.length; d++){
                       users[_userId].CityMatrix[i].refs1.push(level1[d]);
                    }
                    
                    for(uint e = 0; e < level2.length; e++){
                        users[_userId].CityMatrix[i].refs2.push(level2[e]);
                    }
                }
            }
            
            users[_userId].isSynched = true;
            lastSynched++;
        }
    }
    
    function closeSyncin() public {
        require(msg.sender == admin, 'Not Allowed!');
        citySyncing = true;
        allowSyncing = true;
    }
    
    
    function withdraw() public {
        require(users[msg.sender].afund > 0 
        && address(this).balance > users[msg.sender].afund + users[msg.sender].afund * 15 / divider, 
        'Low Balance');
        uint _amount = users[msg.sender].afund;
        users[msg.sender].afund = 0;
        users[msg.sender].withdrawn += _amount;
        address(uint160(msg.sender)).transfer(_amount);
    }

    function isUserExists(address _userAddress) internal view returns (bool) {
        return (users[_userAddress].id != 0);
    }

    function checkActiveStatus(address _userId, uint _level) internal returns(bool){
        if(!users[_userId].activeMember[_level] || users[_userId].CityMatrix[_level].expiresOn < now){
            users[_userId].activeMember[_level] = false;
            users[_userId].CityMatrix[_level].active = false;
            return false;
        }
        
        return true;
    }
    
    function guDownlines(address _userId, uint _level) internal view returns(uint){
        return users[_userId].CityMatrix[_level].refs1.length;
    }
    
    function usersActiveCityMatrix(address _userId, uint _level) external view returns(bool active, uint){
        return (users[_userId].activeMember[_level],  users[_userId].CityMatrix[_level].expiresOn);
    }

    function usersMatrix(address _userId, uint _level) public view returns(address, address[] memory, address[] memory, bool) {
        return (users[_userId].CityMatrix[_level].refBy,
                users[_userId].CityMatrix[_level].refs1,
                users[_userId].CityMatrix[_level].refs2, users[_userId].CityMatrix[_level].active);
    }
    
    function stats() public view returns(uint lId, uint aU, uint rT, uint rTl, uint dE, uint lE, uint mI, uint mCI, uint jT, uint sF, uint pB){
        return (lastUserId, activeUsers, raisedToday, raisedTotal, distEarning, lostEarnings, matrixIncomes, matchIncomes, joinedToday, safety_funds, pool_balance);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}

contract EtherCity {

    function checkActiveStatus(address _userId, uint _level) private returns(bool){}

    function getUserData(address _userId) public view returns(address _refBy, uint _refs, uint _myTeam, uint _earnings, uint _dearnings, uint _mearnings, uint _maearnings, uint _missedEarning){}

    function isUserExists(address _userAddress) public view returns (bool) {}
    
    function usersActiveCityMatrix(address _userId, uint _level) public view returns(bool){}

    function userMatrixExpiration(address _userId, uint _level) public view returns(uint){}

    function usersMatrix(address _userId, uint _level) public view returns(address, address[] memory, address[] memory, bool) {}
}