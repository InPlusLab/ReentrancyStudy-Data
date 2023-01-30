/**
 *Submitted for verification at Etherscan.io on 2020-08-01
*/

/*
¨X¨T¨T¨T¨[¨X¨T¨[¨X¨T¨[¨X¨T¨T¨T¨[¨X¨T¨T¨T¨[¨X¨T¨T¨T¨T¨[¨X¨T¨T¨[©¤¨X¨T¨T¨[¨X¨T¨T¨T¨T¨[¨X¨T¨T¨T¨[¨X¨T¨T¨T¨[¨X¨T¨T¨[¨X¨T¨[©¤¨X¨[¨X¨T¨T¨T¨T¨[
¨U¨X¨T¨[¨U¨U¨U¨^¨a¨U¨U¨U¨X¨T¨[¨U¨U¨X¨T¨[¨U¨U¨X¨[¨X¨[¨U¨U¨X¨[¨U©¤¨^¨g©¤¨a¨U¨X¨[¨X¨[¨U¨U¨X¨T¨[¨U¨U¨X¨T¨[¨U¨^¨g©¤¨a¨U¨U¨^¨[¨U¨U¨U¨X¨[¨X¨[¨U
¨U¨^¨T¨T¨[¨U¨X¨[¨X¨[¨U¨U¨U©¤¨U¨U¨U¨^¨T¨a¨U¨^¨a¨U¨U¨^¨a¨U¨^¨a¨^¨[©¤¨U¨U©¤¨^¨a¨U¨U¨^¨a¨U¨^¨T¨a¨U¨U¨U©¤¨U¨U©¤¨U¨U©¤¨U¨X¨[¨^¨a¨U¨^¨a¨U¨U¨^¨a
¨^¨T¨T¨[¨U¨U¨U¨U¨U¨U¨U¨U¨^¨T¨a¨U¨U¨X¨[¨X¨a©¤©¤¨U¨U©¤©¤¨U¨X¨T¨[¨U©¤¨U¨U©¤©¤©¤¨U¨U©¤©¤¨U¨X¨T¨T¨a¨U¨U©¤¨U¨U©¤¨U¨U©¤¨U¨U¨^¨[¨U¨U©¤©¤¨U¨U©¤©¤
¨U¨^¨T¨a¨U¨U¨U¨U¨U¨U¨U¨U¨X¨T¨[¨U¨U¨U¨U¨^¨[©¤©¤¨U¨U©¤©¤¨U¨^¨T¨a¨U¨X¨g©¤¨[©¤©¤¨U¨U©¤©¤¨U¨U©¤©¤©¤¨U¨^¨T¨a¨U¨X¨g©¤¨[¨U¨U©¤¨U¨U¨U©¤©¤¨U¨U©¤©¤
¨^¨T¨T¨T¨a¨^¨a¨^¨a¨^¨a¨^¨a©¤¨^¨a¨^¨a¨^¨T¨a©¤©¤¨^¨a©¤©¤¨^¨T¨T¨T¨a¨^¨T¨T¨a©¤©¤¨^¨a©¤©¤¨^¨a©¤©¤©¤¨^¨T¨T¨T¨a¨^¨T¨T¨a¨^¨a©¤¨^¨T¨a©¤©¤¨^¨a©¤©¤
international telegram channel: @smartbitpoint
international telegram group: @smartbitpoint_com
international telegram bot: @smartbitpoint_bot
hashtag: #smartbitpoint
*/
pragma solidity >=0.5.17 <0.7.0;

contract SmartBitPoint {
    uint public currUserID;
    address private lastUser;
    address private owner; address private manager;
    uint START_PRICE;
    mapping (uint => uint) public StatsLevel;
    struct User {
        uint id;
        uint currentLevel;
        bool unlimited;
        uint referrerB; uint referrerT; uint referrerL;
        address[] referralsB; address[] referralsT; address[] referralsL;
        mapping (uint => uint) countGetMoney; mapping (uint => uint) countLostMoney;
    }
    mapping (address => User) public mapusers;
    mapping (uint => address) public usersAddress;
    bool private ContractInit;

    event regLevelEvent(address indexed _user, address indexed _referrer, uint indexed _type, uint _id, uint _time);
    event buyLevelEvent(address indexed _user, uint indexed _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint indexed _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint indexed _level, uint _time);

    modifier onlyOwner { require(msg.sender == owner, "Only owner can call this function."); _; }
    modifier onlyOwnerOrManager { require(msg.sender == owner || msg.sender == manager, "Only owner or manager can call this function."); _; }
    modifier userRegistered(address _user) { require(mapusers[_user].id != 0, 'User does not exist'); _; }
    modifier validPrice(uint _price) { require(_price > 0 && _price % 3 == 0, 'Invalid price'); _; }
    modifier validAddress(address _user) { require(_user != address(0), "Zero address"); _; }

    constructor() public {
        require(!ContractInit,"This contract inited"); owner = msg.sender; manager = msg.sender;
        address u1 = 0x9FE5F739D3df1BEf612bbB8a06952D233C5474E3; address u2 = 0x93fD13DD91236269cBDce8859521A0121E4A437E;
        address u3 = 0x4a664BBBFE84ddbC3186e9f164E7186D00a10648; address u4 = 0xeba8BD49249De044810701e10e8481DDEd858882;
        address u5 = 0x83cb295315f20453CAd48549ec5248bB7FB4633E; address u6 = 0xAB3870229CBCBe5C4BE1547B66181dFF58F4C5bc;
        address u7 = 0xaC77396F01Dd706108930CA1E375f4F400d39121; address u8 = 0xcF8AFeEdF9446ec79C3A3433F102E56A51fF90c0;
        lastUser = u8;
        START_PRICE = 0.03 ether;
        currUserID = 8;

        mapusers[u1] = User({ id: 1, currentLevel: 0, unlimited: true, referrerB: 0, referrerT: 0, referrerL: 0, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[1] = u1;
        mapusers[u2] = User({ id: 2, currentLevel: 0, unlimited: true, referrerB: 1, referrerT: 1, referrerL: 1, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[2] = u2;
        mapusers[u3] = User({ id: 3, currentLevel: 0, unlimited: true, referrerB: 2, referrerT: 2, referrerL: 2, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[3] = u3;
        mapusers[u4] = User({ id: 4, currentLevel: 5, unlimited: false, referrerB: 3, referrerT: 3, referrerL: 3, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[4] = u4;
        mapusers[u5] = User({ id: 5, currentLevel: 0, unlimited: true, referrerB: 2, referrerT: 2, referrerL: 2, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[5] = u5;
        mapusers[u6] = User({ id: 6, currentLevel: 0, unlimited: true, referrerB: 5, referrerT: 2, referrerL: 2, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[6] = u6;
        mapusers[u7] = User({ id: 7, currentLevel: 0, unlimited: true, referrerB: 1, referrerT: 1, referrerL: 1, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[7] = u7;
        mapusers[u8] = User({ id: 8, currentLevel: 0, unlimited: true, referrerB: 7, referrerT: 1, referrerL: 1, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[8] = u8;

        mapusers[u1].referralsB.push(u2);mapusers[u1].referralsB.push(u7);
        mapusers[u1].referralsT.push(u2);mapusers[u1].referralsT.push(u7);mapusers[u1].referralsT.push(u8);
        mapusers[u1].referralsL.push(u2);mapusers[u1].referralsL.push(u7);mapusers[u1].referralsL.push(u8);
        mapusers[u2].referralsB.push(u3);mapusers[u2].referralsB.push(u5);
        mapusers[u2].referralsT.push(u3);mapusers[u2].referralsT.push(u5);mapusers[u2].referralsT.push(u6);
        mapusers[u2].referralsL.push(u3);mapusers[u2].referralsL.push(u5);mapusers[u2].referralsL.push(u6);
        mapusers[u3].referralsB.push(u4);mapusers[u3].referralsT.push(u4);mapusers[u3].referralsL.push(u4);
        mapusers[u5].referralsB.push(u6);mapusers[u7].referralsB.push(u8);
        ContractInit = true;
    }

    function () external payable {
        uint level;
        if(msg.value == START_PRICE){
            level = 1;
        } else if(msg.value % 3 == 0){
            level = msg.value/START_PRICE;
        }
        require(level > 0, 'Invalid sum');

        uint32 size = _sGetA(msg.sender);
        require(size == 0, "Cannot be a contract");

        if(mapusers[msg.sender].id != 0){

            require(mapusers[msg.sender].unlimited == false, 'You have unlimited levels');
            if(mapusers[msg.sender].currentLevel >= level) revert('Level is already activated');
            if(mapusers[msg.sender].currentLevel+1 != level) revert('Buy previous level');
            mapusers[msg.sender].currentLevel = level;
            StatsLevel[level]++;
            payForLevel(level, msg.sender);
            emit buyLevelEvent(msg.sender, level, now);
        } else if(level == 1){
            address referrer = _bToA(msg.data);
            require(mapusers[referrer].id != 0, 'Incorrect referrer');

            uint bone = mapusers[referrer].id;
            uint two = mapusers[referrer].id;
            if(mapusers[referrer].referralsB.length >= 2)
                bone = mapusers[findFreeReferrerB(referrer)].id;
            if(mapusers[referrer].referralsT.length >= 3)
                two = mapusers[findFreeReferrerT(referrer)].id;
            currUserID++;
            mapusers[msg.sender] = User({ id: currUserID, currentLevel: 1, unlimited: false, referrerB: bone, referrerT: two, referrerL: mapusers[referrer].id, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
            usersAddress[currUserID] = msg.sender;
            mapusers[usersAddress[bone]].referralsB.push(msg.sender);
            mapusers[usersAddress[two]].referralsT.push(msg.sender);
            mapusers[referrer].referralsL.push(msg.sender);
            StatsLevel[1]++;
            payForLevel(1, msg.sender);
            lastUser = msg.sender;
            emit regLevelEvent(msg.sender, usersAddress[bone], 1, currUserID, now);
            emit regLevelEvent(msg.sender, usersAddress[two], 2, currUserID, now);
            emit regLevelEvent(msg.sender, referrer, 3, currUserID, now);
        } else {
            revert('Buy first level');
        }
    }

    function payForLevel(uint _level, address _user) internal {
        uint height;
        address referrer;

        height = _level;
        referrer = _user;
        while (true) {
            referrer = usersAddress[mapusers[referrer].referrerB];
            if(referrer == address(0)) { referrer = owner; break; }
            height--;
            if(height == 0){
                if(mapusers[referrer].currentLevel >= _level || mapusers[referrer].unlimited) break;
                emit lostMoneyForLevelEvent(referrer, msg.sender, _level, now);
                mapusers[referrer].countLostMoney[_level]++;
                height = _level;
            }
        }
        if(_aToP(referrer).send(msg.value/3)) {
            emit getMoneyForLevelEvent(referrer, msg.sender, _level, now);
            mapusers[referrer].countGetMoney[_level]++;
        }

        height = _level;
        referrer = _user;
        while (true) {
            referrer = usersAddress[mapusers[referrer].referrerT];
            if(referrer == address(0)) { referrer = owner; break; }
            height--;
            if(height == 0){
                if(mapusers[referrer].currentLevel >= _level || mapusers[referrer].unlimited) break;
                emit lostMoneyForLevelEvent(referrer, msg.sender, _level, now);
                mapusers[referrer].countLostMoney[_level]++;
                height = _level;
            }
        }
        if(_aToP(referrer).send(msg.value/3)) {
            emit getMoneyForLevelEvent(referrer, msg.sender, _level, now);
            mapusers[referrer].countGetMoney[_level]++;
        }

        referrer = _user;
        while (true) {
            referrer = usersAddress[mapusers[referrer].referrerL];
            if(referrer == address(0)) { referrer = owner; break; }
            if(mapusers[referrer].currentLevel >= _level || mapusers[referrer].unlimited) break;
            emit lostMoneyForLevelEvent(referrer, msg.sender, _level, now);
            mapusers[referrer].countLostMoney[_level]++;
        }
        if(_aToP(referrer).send(msg.value/3)) {
            emit getMoneyForLevelEvent(referrer, msg.sender, _level, now);
            mapusers[referrer].countGetMoney[_level]++;
        }
    }

    function findFreeReferrerB(address _user) public view returns(address) {
        if(mapusers[_user].referralsB.length < 2) return _user;
        address[] memory referrals = new address[](1022);
        referrals[0] = mapusers[_user].referralsB[0];
        referrals[1] = mapusers[_user].referralsB[1];
        for(uint i=0; i<1022;i++){
            if(mapusers[referrals[i]].referralsB.length < 2) return referrals[i];
            if(i > 509) continue;
            referrals[(i + 1) * 2] = mapusers[referrals[i]].referralsB[0];
            referrals[(i + 1) * 2 + 1] = mapusers[referrals[i]].referralsB[1];
        }
        return lastUser;
    }
    function findFreeReferrerT(address _user) public view returns(address) {
        if(mapusers[_user].referralsT.length < 3) return _user;
        address[] memory referrals = new address[](1092);
        referrals[0] = mapusers[_user].referralsT[0];
        referrals[1] = mapusers[_user].referralsT[1];
        referrals[2] = mapusers[_user].referralsT[2];
        for(uint i=0; i<1092;i++){
            if(mapusers[referrals[i]].referralsT.length < 3) return referrals[i];
            if(i > 362) continue;
            referrals[(i + 1) * 3] = mapusers[referrals[i]].referralsT[0];
            referrals[(i + 1) * 3 + 1] = mapusers[referrals[i]].referralsT[1];
            referrals[(i + 1) * 3 + 2] = mapusers[referrals[i]].referralsT[2];
        }
        return lastUser;
    }

    function viewUserReferralsB(address _user) public view returns(address[] memory) {
        return mapusers[_user].referralsB;
    }
    function viewUserReferralsT(address _user) public view returns(address[] memory) {
        return mapusers[_user].referralsT;
    }
    function viewUserReferralsL(address _user) public view returns(address[] memory) {
        return mapusers[_user].referralsL;
    }

    function getCountGetMoney(address _user, uint _level) public view returns(uint) {
        return mapusers[_user].countGetMoney[_level];
    }
    function getCountLostMoney(address _user, uint _level) public view returns(uint) {
        return mapusers[_user].countLostMoney[_level];
    }

    function getUserInfo(address _user) public view returns(uint,uint,bool,uint[3] memory,address[3] memory){
        return (mapusers[_user].id,mapusers[_user].currentLevel,mapusers[_user].unlimited,
        [mapusers[_user].referrerB,mapusers[_user].referrerT,mapusers[_user].referrerL],
        [usersAddress[mapusers[_user].referrerB], usersAddress[mapusers[_user].referrerT],usersAddress[mapusers[_user].referrerL]]);
    }

    function setStartPrice(uint _price) public onlyOwnerOrManager validPrice(_price) {
        START_PRICE = _price * 0.01 ether;
    }
    function setUserUnlimited(address _user) public onlyOwnerOrManager userRegistered(_user) {
        mapusers[_user].unlimited = true;
    }
    function delUserUnlimited(address _user) public onlyOwnerOrManager userRegistered(_user) {
        mapusers[_user].unlimited = false;
    }

    function setOwner(address _user) public onlyOwner validAddress(_user) { owner = _user; }
    function setManager(address _user) public onlyOwnerOrManager validAddress(_user) { manager = _user; }
    function getOwner() external view returns (address) { return owner; }
    function getManager() external view returns (address) { return manager; }
    function _bToA(bytes memory _bys) internal pure returns(address addr) { assembly { addr := mload(add(_bys, 20)) } }
    function _aToP(address _addr) internal pure returns(address payable) { return address(uint160(_addr)); }
    function _sGetA(address _addr) internal view returns(uint32 size) { assembly { size := extcodesize(_addr) } }
}