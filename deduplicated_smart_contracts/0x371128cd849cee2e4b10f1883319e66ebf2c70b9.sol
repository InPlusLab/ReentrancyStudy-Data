/**
 *Submitted for verification at Etherscan.io on 2020-03-12
*/

/*
// ¨X¨T¨T¨T¨[©¤©¤©¤©¤©¤©¤©¤¨X¨[¨X¨T¨T¨[©¤¨X¨[¨X¨T¨T¨T¨[©¤©¤©¤©¤©¤©¤¨X¨[
// ¨U¨X¨T¨[¨U©¤©¤©¤©¤©¤©¤¨X¨a¨^¨g¨X¨[¨U¨X¨a¨^¨g¨X¨T¨[¨U©¤©¤©¤©¤©¤¨X¨a¨^¨[
// ¨U¨^¨T¨T¨j¨[¨X¨j¨T¨T¨j¨m¨[¨X¨g¨^¨a¨^¨p¨[¨X¨g¨^¨T¨a¨d¨T¨T¨j¨j¨T¨p¨[¨X¨a
// ¨^¨T¨T¨[¨U¨^¨a¨U¨X¨[¨U¨X¨g¨U¨U¨X¨T¨[¨d¨g¨U¨U¨X¨T¨T¨g¨X¨[¨d¨g¨X¨[¨g¨U
// ¨U¨^¨T¨a¨U¨U¨U¨U¨X¨[¨U¨U¨U¨^¨g¨^¨T¨a¨U¨U¨^¨g¨U©¤©¤¨U¨^¨a¨U¨U¨U¨U¨U¨^¨[
// ¨^¨T¨T¨T¨m¨m¨m¨m¨a¨^¨m¨a¨^¨T¨m¨T¨T¨T¨m¨m¨T¨m¨a©¤©¤¨^¨T¨T¨m¨m¨a¨^¨m¨T¨a
// telegram: @smartbitpoint
// hashtag: #smartbitpoint
*/
pragma solidity ^0.5.7;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract Ownable {
  address public owner;
  address public manager;
  address public adminWallet;
  address public ownerWallet;
  constructor() public {
    owner = msg.sender;
    manager = msg.sender;
    adminWallet = 0x93fD13DD91236269cBDce8859521A0121E4A437E;
    ownerWallet = 0x9FE5F739D3df1BEf612bbB8a06952D233C5474E3;
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "only for owner");
    _;
  }
  modifier onlyOwnerOrManager() {
     require((msg.sender == owner)||(msg.sender == manager), "only for owner or manager");
      _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    owner = newOwner;
  }
  function setManager(address _manager) public onlyOwnerOrManager {
      manager = _manager;
  }
}
contract SmartBitPoint is Ownable {
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event buyLevelEvent(address indexed _user, uint _level, uint _time);
    event prolongateLevelEvent(address indexed _user, uint _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    mapping (uint => uint) public LEVEL_PRICE;
    uint REFERRER_1_LEVEL_LIMIT = 3;
    uint PERIOD_LENGTH = 180 days;
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        address[] referral;
        mapping (uint => uint) levelExpired;
    }
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    uint public currUserID = 0;
    constructor() public {
        LEVEL_PRICE[1] = 0.03 ether;
        LEVEL_PRICE[2] = 0.09 ether;
        LEVEL_PRICE[3] = 0.27 ether;
        LEVEL_PRICE[4] = 0.81 ether;
        LEVEL_PRICE[5] = 2.43 ether;
        LEVEL_PRICE[6] = 7.29 ether;
        LEVEL_PRICE[7] = 21.87 ether;
        LEVEL_PRICE[8] = 65.61 ether;
        UserStruct memory userStruct;
        currUserID++;
        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : 0,
            referral : new address[](0)
        });
        users[ownerWallet] = userStruct;
        users[ownerWallet].referral.push(adminWallet);
        userList[currUserID] = ownerWallet;
        users[ownerWallet].levelExpired[1] = 77777777777;
        users[ownerWallet].levelExpired[2] = 77777777777;
        users[ownerWallet].levelExpired[3] = 77777777777;
        users[ownerWallet].levelExpired[4] = 77777777777;
        users[ownerWallet].levelExpired[5] = 77777777777;
        users[ownerWallet].levelExpired[6] = 77777777777;
        users[ownerWallet].levelExpired[7] = 77777777777;
        users[ownerWallet].levelExpired[8] = 77777777777;
        currUserID++;
        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : 1,
            referral : new address[](0)
        });
        users[adminWallet] = userStruct;
        userList[currUserID] = adminWallet;
        users[adminWallet].levelExpired[1] = 77777777777;
        users[adminWallet].levelExpired[2] = 77777777777;
        users[adminWallet].levelExpired[3] = 77777777777;
        users[adminWallet].levelExpired[4] = 77777777777;
        users[adminWallet].levelExpired[5] = 77777777777;
        users[adminWallet].levelExpired[6] = 77777777777;
        users[adminWallet].levelExpired[7] = 77777777777;
        users[adminWallet].levelExpired[8] = 77777777777;
    }
    function () external payable {
        uint level;
        if(msg.value == LEVEL_PRICE[1]){
            level = 1;
        }else if(msg.value == LEVEL_PRICE[2]){
            level = 2;
        }else if(msg.value == LEVEL_PRICE[3]){
            level = 3;
        }else if(msg.value == LEVEL_PRICE[4]){
            level = 4;
        }else if(msg.value == LEVEL_PRICE[5]){
            level = 5;
        }else if(msg.value == LEVEL_PRICE[6]){
            level = 6;
        }else if(msg.value == LEVEL_PRICE[7]){
            level = 7;
        }else if(msg.value == LEVEL_PRICE[8]){
            level = 8;
        }else {
            revert('Incorrect Value send');
        }
        if(users[msg.sender].isExist){
            buyLevel(level);
        } else if(level == 1) {
            uint refId = 0;
            address referrer = bytesToAddress(msg.data);
            if (users[referrer].isExist){
                refId = users[referrer].id;
            } else {
                revert('Incorrect referrer');
            }
            regUser(refId);
        } else {
            revert("Please buy first level");
        }
    }
    function regUser(uint _referrerID) public payable {
        require(!users[msg.sender].isExist, 'User exist');
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        require(msg.value==LEVEL_PRICE[1], 'Incorrect Value');
        if(users[userList[_referrerID]].referral.length >= REFERRER_1_LEVEL_LIMIT)
        {
            _referrerID = users[findFreeReferrer(userList[_referrerID])].id;
        }
        UserStruct memory userStruct;
        currUserID++;
        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : _referrerID,
            referral : new address[](0)
        });
        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;
        users[msg.sender].levelExpired[1] = now + PERIOD_LENGTH;
        users[msg.sender].levelExpired[2] = 0;
        users[msg.sender].levelExpired[3] = 0;
        users[msg.sender].levelExpired[4] = 0;
        users[msg.sender].levelExpired[5] = 0;
        users[msg.sender].levelExpired[6] = 0;
        users[msg.sender].levelExpired[7] = 0;
        users[msg.sender].levelExpired[8] = 0;
        users[userList[_referrerID]].referral.push(msg.sender);
        payForLevel(1, msg.sender);
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    function buyLevel(uint _level) public payable {
        require(users[msg.sender].isExist, 'User not exist');
        require( _level>0 && _level<=8, 'Incorrect level');
        if(_level == 1){
            require(msg.value==LEVEL_PRICE[1], 'Incorrect Value');
            users[msg.sender].levelExpired[1] += PERIOD_LENGTH;
        } else {
            require(msg.value==LEVEL_PRICE[_level], 'Incorrect Value');
            for(uint l =_level-1; l>0; l-- ){
                require(users[msg.sender].levelExpired[l] >= now, 'Buy the previous level');
            }
            if(users[msg.sender].levelExpired[_level] == 0){
                users[msg.sender].levelExpired[_level] = now + PERIOD_LENGTH;
            } else {
                users[msg.sender].levelExpired[_level] += PERIOD_LENGTH;
            }
        }
        payForLevel(_level, msg.sender);
        emit buyLevelEvent(msg.sender, _level, now);
    }
    function payForLevel(uint _level, address _user) internal {
        address referer;
        address referer1;
        address referer2;
        address referer3;
        if(_level == 1 || _level == 5){
            referer = userList[users[_user].referrerID];
        } else if(_level == 2 || _level == 6){
            referer1 = userList[users[_user].referrerID];
            referer = userList[users[referer1].referrerID];
        } else if(_level == 3 || _level == 7){
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer = userList[users[referer2].referrerID];
        } else if(_level == 4 || _level == 8){
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer = userList[users[referer3].referrerID];
        }
        if(!users[referer].isExist){
            referer = userList[1];
        }
        if(users[referer].levelExpired[_level] >= now ){
            bool result;
            result = address(uint160(referer)).send(LEVEL_PRICE[_level]);
            emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
        } else {
            emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);
            payForLevel(_level,referer);
        }
    }
    function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].referral.length < REFERRER_1_LEVEL_LIMIT){
            return _user;
        }
        address[] memory referrals = new address[](363);
        referrals[0] = users[_user].referral[0]; 
        referrals[1] = users[_user].referral[1];
        referrals[2] = users[_user].referral[2];
        address freeReferrer;
        bool noFreeReferrer = true;
        for(uint i =0; i<363;i++){
            if(users[referrals[i]].referral.length == REFERRER_1_LEVEL_LIMIT){
                if(i<120){
                    referrals[(i+1)*3] = users[referrals[i]].referral[0];
                    referrals[(i+1)*3+1] = users[referrals[i]].referral[1];
                    referrals[(i+1)*3+2] = users[referrals[i]].referral[2];
                }
            }else{
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
        require(!noFreeReferrer, 'No Free Referrer');
        return freeReferrer;

    }
    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }
    function viewUserLevelExpired(address _user, uint _level) public view returns(uint) {
        return users[_user].levelExpired[_level];
    }
    function bytesToAddress(bytes memory bys) private pure returns (address  addr ) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}