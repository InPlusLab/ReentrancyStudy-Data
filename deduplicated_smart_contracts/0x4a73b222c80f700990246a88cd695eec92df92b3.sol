/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity 0.5.14;

contract MineTree {
    address public Wallet;
    address public usirs;

    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint totalEarning;
        address[] referral;
        mapping(uint => uint) levelExpired;
    }

    uint public REFERRER_1_LEVEL_LIMIT = 2;
    uint public PERIOD_LENGTH = 77 days;
    uint public GRACE_PERIOD = 3 days;

    mapping(uint => uint) public LEVEL_PRICE;

    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    mapping(address => mapping (uint => uint)) public levelEarned;
    mapping (address => uint) public loopCheck;
    uint public currUserID = 0;
    bool public lockStatus;

    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event buyLevelEvent(address indexed _user, uint _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);

    constructor(address _usirsAddress) public {
        Wallet = msg.sender;
        lockStatus = true;
        usirs = _usirsAddress;
        
        //FOUNDATION
        LEVEL_PRICE[1] = 0.07 ether;
        LEVEL_PRICE[2] = 0.12 ether;
        LEVEL_PRICE[3] = 0.24 ether;
        LEVEL_PRICE[4] = 0.96 ether;
        LEVEL_PRICE[5] = 3 ether;
        LEVEL_PRICE[6] = 10 ether;
        //PREMIUM
        LEVEL_PRICE[7] = 20 ether;
        LEVEL_PRICE[8] = 30 ether;
        LEVEL_PRICE[9] = 40 ether;
        LEVEL_PRICE[10] = 60 ether;
        LEVEL_PRICE[11] = 120 ether;
        LEVEL_PRICE[12] = 240 ether;
        //ELITE
        LEVEL_PRICE[13] = 100 ether;
        LEVEL_PRICE[14] = 150 ether;
        LEVEL_PRICE[15] = 300 ether;
        LEVEL_PRICE[16] = 500 ether;
        LEVEL_PRICE[17] = 1000 ether;
        LEVEL_PRICE[18] = 2000 ether;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            totalEarning:0,
            referrerID: 0,
            referral: new address[](0)
        });
        users[Wallet] = userStruct;
        userList[currUserID] = Wallet;

        for(uint i = 1; i <= 18; i++) {
            users[Wallet].levelExpired[i] = 55555555555;
        }
    }
    
    modifier isUnlock(){
        require(lockStatus == true,"Contract is locked");
        _;
    }

    function () external payable isUnlock {
        uint level;

        if(msg.value == LEVEL_PRICE[1]) level = 1;
        else if(msg.value == LEVEL_PRICE[2]) level = 2;
        else if(msg.value == LEVEL_PRICE[3]) level = 3;
        else if(msg.value == LEVEL_PRICE[4]) level = 4;
        else if(msg.value == LEVEL_PRICE[5]) level = 5;
        else if(msg.value == LEVEL_PRICE[6]) level = 6;
        else if(msg.value == LEVEL_PRICE[7]) level = 7;
        else if(msg.value == LEVEL_PRICE[8]) level = 8;
        else if(msg.value == LEVEL_PRICE[9]) level = 9;
        else if(msg.value == LEVEL_PRICE[10]) level = 10;
        else if(msg.value == LEVEL_PRICE[11]) level = 11;
        else if(msg.value == LEVEL_PRICE[12]) level = 12;
        else if(msg.value == LEVEL_PRICE[13]) level = 13;
        else if(msg.value == LEVEL_PRICE[14]) level = 14;
        else if(msg.value == LEVEL_PRICE[15]) level = 15;
        else if(msg.value == LEVEL_PRICE[16]) level = 16;
        else if(msg.value == LEVEL_PRICE[17]) level = 17;
        else if(msg.value == LEVEL_PRICE[18]) level = 18;
        else revert("Incorrect Value send");

        if(users[msg.sender].isExist) buyLevel(level);
        else if(level == 1) {
            uint refId = 0;
            address referrer = bytesToAddress(msg.data);

            if(users[referrer].isExist) refId = users[referrer].id;
            else revert("Incorrect referrer");

            regUser(refId);
        }
        else revert("Please buy first level for 0.07 ETH");
    }

    function regUser(uint _referrerID) public payable isUnlock {
        require(!users[msg.sender].isExist, "User exist");
        require(_referrerID > 0 && _referrerID <= currUserID, "Incorrect referrer Id");
        require(msg.value == LEVEL_PRICE[1], "Incorrect Value");

        if(users[userList[_referrerID]].referral.length >= REFERRER_1_LEVEL_LIMIT) _referrerID = users[findFreeReferrer(userList[_referrerID])].id;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            totalEarning:0,
            referrerID: _referrerID,
            referral: new address[](0)
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        users[msg.sender].levelExpired[1] = now + PERIOD_LENGTH;

        users[userList[_referrerID]].referral.push(msg.sender);
        loopCheck[msg.sender] = 0;

        payForLevel(1, msg.sender);

        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }

    function buyLevel(uint _level) public payable isUnlock {
        require(users[msg.sender].isExist, "User not exist"); 
        require(_level > 0 && _level <= 18, "Incorrect level");

        if(_level == 1) {
            require(msg.value == LEVEL_PRICE[1], "Incorrect Value");
            users[msg.sender].levelExpired[1] += PERIOD_LENGTH;
        }
        else {
            require(msg.value == LEVEL_PRICE[_level], "Incorrect Value");

            for(uint l =_level - 1; l > 0; l--) require(users[msg.sender].levelExpired[l]+GRACE_PERIOD >= now, "Buy the previous level");

            if(users[msg.sender].levelExpired[_level] == 0) users[msg.sender].levelExpired[_level] = now + PERIOD_LENGTH;
            else users[msg.sender].levelExpired[_level] += PERIOD_LENGTH;
        }
        loopCheck[msg.sender] = 0;
        payForLevel(_level, msg.sender);

        emit buyLevelEvent(msg.sender, _level, now);
    }


    function payForLevel(uint _level, address _user) internal {
        address referer;
        address referer1;
        address referer2;
        address referer3;
        address referer4;
        address referer5;

        if(_level == 1 || _level == 7 || _level == 13) {
            referer = userList[users[_user].referrerID];
        }
        else if(_level == 2 || _level == 8 || _level == 14) {
            referer1 = userList[users[_user].referrerID];
            referer = userList[users[referer1].referrerID];
        }
        else if(_level == 3 || _level == 9 || _level == 15) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer = userList[users[referer2].referrerID];
        }
        else if(_level == 4 || _level == 10 || _level == 16) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer = userList[users[referer3].referrerID];
        }
        else if(_level == 5 || _level == 11 || _level == 17) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer4 = userList[users[referer3].referrerID];
            referer = userList[users[referer4].referrerID];
        }
        else if(_level == 6 || _level == 12 || _level == 18) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer4 = userList[users[referer3].referrerID];
            referer5 = userList[users[referer4].referrerID];
            referer = userList[users[referer5].referrerID];
        }

        if(!users[referer].isExist) referer = userList[1];

        if (loopCheck[msg.sender] >= 12) {
            referer = userList[1];
        }
        
        if(users[referer].levelExpired[_level] >= now) {
            if(referer == Wallet) {
                require(address(uint160(usirs)).send(LEVEL_PRICE[_level]), "Transfer failed");
                emit getMoneyForLevelEvent(usirs, msg.sender, _level, now);
            }    
            else{    
                require(address(uint160(referer)).send(LEVEL_PRICE[_level]), "Referrer transfer failed");
                emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
            }
            users[referer].totalEarning += LEVEL_PRICE[_level];
            levelEarned[referer][_level] +=  LEVEL_PRICE[_level];
                
        }
        else {
            if (loopCheck[msg.sender] < 12) {
                loopCheck[msg.sender] += 1;
                
            emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);

            payForLevel(_level, referer);
            }
        }
    }

    function updateUsirs(address _usirsAddress) public returns (bool) {
       require(msg.sender == Wallet, "Only Wallet");
       
       usirs = _usirsAddress;
       return true;
    }
    
    function updatePrice(uint _level, uint _price) public returns (bool) {
        require(msg.sender == Wallet, "Only Wallet");

        LEVEL_PRICE[_level] = _price;
        return true;
    }
    
    function failSafe(address payable _toUser, uint _amount) public returns (bool) {
        require(msg.sender == Wallet, "Only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (_toUser).transfer(_amount);
        return true;
    }

    function contractLock(bool _lockStatus) public returns (bool) {
        require(msg.sender == Wallet, "Invalid User");

        lockStatus = _lockStatus;
        return true;
    }

    function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].referral.length < REFERRER_1_LEVEL_LIMIT) return _user;

        address[] memory referrals = new address[](254);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 254; i++) {
            if(users[referrals[i]].referral.length == REFERRER_1_LEVEL_LIMIT) {
                if(i < 126) {
                    referrals[(i+1)*2] = users[referrals[i]].referral[0];
                    referrals[(i+1)*2+1] = users[referrals[i]].referral[1];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, "No Free Referrer");

        return freeReferrer;
    }

    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }

    function viewUserLevelExpired(address _user, uint _level) public view returns(uint) {
        return users[_user].levelExpired[_level];
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}