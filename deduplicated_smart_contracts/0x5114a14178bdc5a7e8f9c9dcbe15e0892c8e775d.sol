/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

/**
*
* Hello
 * This contract belongs to MILLIONAIRECLUB
 * URL: https://millionaireclub.money
 * 
 */

pragma solidity  ^0.5.12;

contract MILLIONAIRECLUB {
  address public creator;
  uint MAX_LEVEL = 9;
  uint REFERRALS_LIMIT = 2;
  uint LEVEL_EXPIRE_TIME = 3650 days;
  mapping (address => User) public users;
  mapping (uint => address) public userAddresses;
  uint public last_uid;
  mapping (uint => uint) public levelPrice;
  mapping (uint => uint) public uplinesToRcvEth;
  mapping (address => ProfitsRcvd) public rcvdProfits;
  mapping (address => ProfitsGiven) public givenProfits;
  mapping (address => LostProfits) public lostProfits;
  
  struct User {
    uint id;
    uint referrerID;
    address[] referrals;
    mapping (uint => uint) levelExpiresAt;
  }
  
  struct ProfitsRcvd {
    uint uid;
    uint[] fromId;
    address[] fromAddr;
    uint[] amount;
  }
  
  struct LostProfits {
    uint uid;
    uint[] toId;
    address[] toAddr;
    uint[] amount;
    uint[] level;
  }
  
  struct ProfitsGiven {
    uint uid;
    uint[] toId;
    address[] toAddr;
    uint[] amount;
    uint[] level;
    uint[] line;
  }

  modifier validLevelAmount(uint _level) {
    require(msg.value == levelPrice[_level], 'Invalid level amount sent');
    _;
  }
  modifier userRegistered() {
    require(users[msg.sender].id != 0, 'User does not exist');
    _;
  }
  modifier validReferrerID(uint _referrerID) {
    require(_referrerID > 0 && _referrerID <= last_uid, 'Invalid referrer ID');
    _;
  }
  modifier userNotRegistered() {
    require(users[msg.sender].id == 0, 'User is already registered');
    _;
  }
  modifier validLevel(uint _level) {
    require(_level > 0 && _level <= MAX_LEVEL, 'Invalid level entered');
    _;
  }
  event RegisterUserEvent(address indexed user, address indexed referrer, uint time);
  event BuyLevelEvent(address indexed user, uint indexed level, uint time);
  event GetLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);
  event LostLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);

  constructor() public {
    last_uid++;
    creator = msg.sender;
    levelPrice[1] = 0.0 ether;
    levelPrice[2] = 0.10 ether;
    levelPrice[3] = 0.20 ether;
    levelPrice[4] = 0.40 ether;
    levelPrice[5] = 0.80 ether;
    levelPrice[6] = 1.60 ether;
    levelPrice[7] = 3.20 ether;
    levelPrice[8] = 6.40 ether;
    levelPrice[9] = 12.28 ether;
    uplinesToRcvEth[1] = 0;
    uplinesToRcvEth[2] = 20;
    uplinesToRcvEth[3] = 20;
    uplinesToRcvEth[4] = 20;
    uplinesToRcvEth[5] = 20;
    uplinesToRcvEth[6] = 20;
    uplinesToRcvEth[7] = 20;
    uplinesToRcvEth[8] = 20;
    uplinesToRcvEth[9] = 20;
   

    users[creator] = User({
      id: last_uid,
      referrerID: 0,
      referrals: new address[](0)
    });
    userAddresses[last_uid] = creator;
    // enter all levels expiry for creator
    for (uint i = 1; i <= MAX_LEVEL; i++) {
      users[creator].levelExpiresAt[i] = 1 << 37;
    }
  }


  function registerUser(uint _referrerID)
    public
    payable
    userNotRegistered()
    validReferrerID(_referrerID)
    validLevelAmount(1)
  {
    if (users[userAddresses[_referrerID]].referrals.length >= REFERRALS_LIMIT) {
      _referrerID = users[findReferrer(userAddresses[_referrerID])].id;
    }
    last_uid++;
    users[msg.sender] = User({
      id: last_uid,
      referrerID: _referrerID,
      referrals: new address[](0)
    });
    userAddresses[last_uid] = msg.sender;
    users[msg.sender].levelExpiresAt[1] = now + LEVEL_EXPIRE_TIME;
    users[userAddresses[_referrerID]].referrals.push(msg.sender);

    transferLevelPayment(1, msg.sender);
    emit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now);
  }

  function buyLevel(uint _level)
    public
    payable
    userRegistered()
    validLevel(_level)
    validLevelAmount(_level)
  {
    for (uint l = _level - 1; l > 0; l--) {
      require(getUserLevelExpiresAt(msg.sender, l) >= now, 'Buy previous level first');
    }
    if (getUserLevelExpiresAt(msg.sender, _level) == 0) {
      users[msg.sender].levelExpiresAt[_level] = now + LEVEL_EXPIRE_TIME;
    } else {
      users[msg.sender].levelExpiresAt[_level] += LEVEL_EXPIRE_TIME;
    }

    transferLevelPayment(_level, msg.sender);
    emit BuyLevelEvent(msg.sender, _level, now);
  }

  function findReferrer(address _user)
    public
    view
    returns (address)
  {
    if (users[_user].referrals.length < REFERRALS_LIMIT) {
      return _user;
    }

    address[1632] memory referrals;
    referrals[0] = users[_user].referrals[0];
    referrals[1] = users[_user].referrals[1];

    address referrer;

    for (uint i = 0; i < 16382; i++) {
      if (users[referrals[i]].referrals.length < REFERRALS_LIMIT) {
        referrer = referrals[i];
        break;
      }

      if (i >= 8191) {
        continue;
      }

      referrals[(i+1)*2] = users[referrals[i]].referrals[0];
      referrals[(i+1)*2+1] = users[referrals[i]].referrals[1];
    }

    require(referrer != address(0), 'Referrer not found');
    return referrer;
  }

  function transferLevelPayment(uint _level, address _user) internal {
    uint height = _level;
    address referrer = getUserUpline(_user, height);

    if (referrer == address(0)) { referrer = creator; }
   
    uint uplines = uplinesToRcvEth[_level];
    bool chkLostProfit = false;
    address lostAddr;
    for (uint i = 1; i <= uplines; i++) {
      referrer = getUserUpline(_user, i);
      
      if(chkLostProfit){
        lostProfits[lostAddr].uid = users[referrer].id;
        lostProfits[lostAddr].toId.push(users[referrer].id);
        lostProfits[lostAddr].toAddr.push(referrer);
        lostProfits[lostAddr].amount.push(levelPrice[_level] / uplinesToRcvEth[_level]);
        lostProfits[lostAddr].level.push(getUserLevel(referrer));
        chkLostProfit = false;
        
        emit LostLevelProfitEvent(referrer, msg.sender, _level, 0);
      }
      
      if (referrer != address(0) && (users[_user].levelExpiresAt[_level] == 0 || getUserLevelExpiresAt(referrer, _level) < now)) {
        chkLostProfit = true;
        uplines++;
        lostAddr = referrer;
        continue;
      }
      else {chkLostProfit = false;}
      
      //add msg.value / uplinesToRcvEth[_level] in user's earned
      
      if (referrer == address(0)) { referrer = creator; }
      if (address(uint160(referrer)).send( msg.value / uplinesToRcvEth[_level] )) {
        rcvdProfits[referrer].uid = users[referrer].id;
        rcvdProfits[referrer].fromId.push(users[msg.sender].id);
        rcvdProfits[referrer].fromAddr.push(msg.sender);
        rcvdProfits[referrer].amount.push(levelPrice[_level] / uplinesToRcvEth[_level]);
        
        givenProfits[msg.sender].uid = users[msg.sender].id;
        givenProfits[msg.sender].toId.push(users[referrer].id);
        givenProfits[msg.sender].toAddr.push(referrer);
        givenProfits[msg.sender].amount.push(levelPrice[_level] / uplinesToRcvEth[_level]);
        givenProfits[msg.sender].level.push(getUserLevel(referrer));
        givenProfits[msg.sender].line.push(i);
        
        emit GetLevelProfitEvent(referrer, msg.sender, _level, now);
      }
    }
  }

  function getUserUpline(address _user, uint height)
    public
    view
    returns (address)
  {
    if (height <= 0 || _user == address(0)) {
      return _user;
    }

    return this.getUserUpline(userAddresses[users[_user].referrerID], height - 1);
  }

  function getUserReferrals(address _user)
    public
    view
    returns (address[] memory)
  {
    return users[_user].referrals;
  }
  
  
  function getUserProfitsFromId(address _user)
    public
    view
    returns (uint[] memory)
  {
      return rcvdProfits[_user].fromId;
  }
  
  function getUserProfitsFromAddr(address _user)
    public
    view
    returns (address[] memory)
  {
      return rcvdProfits[_user].fromAddr;
  }
  
  function getUserProfitsAmount(address _user)
    public
    view
    returns (uint256[] memory)
  {
      return rcvdProfits[_user].amount;
  }
  
  
  
  function getUserProfitsGivenToId(address _user)
    public
    view
    returns (uint[] memory)
  {
      return givenProfits[_user].toId;
  }
  
  function getUserProfitsGivenToAddr(address _user)
    public
    view
    returns (address[] memory)
  {
      return givenProfits[_user].toAddr;
  }
  
  function getUserProfitsGivenToAmount(address _user)
    public
    view
    returns (uint[] memory)
  {
      return givenProfits[_user].amount;
  }
  
  function getUserProfitsGivenToLevel(address _user)
    public
    view
    returns (uint[] memory)
  {
      return givenProfits[_user].level;
  }
  
  function getUserProfitsGivenToLine(address _user)
    public
    view
    returns (uint[] memory)
  {
      return givenProfits[_user].line;
  }
  
  
  function getUserLostsToId(address _user)
    public
    view
    returns (uint[] memory)
  {
    return (lostProfits[_user].toId);
  }
  
  function getUserLostsToAddr(address _user)
    public
    view
    returns (address[] memory)
  {
    return (lostProfits[_user].toAddr);
  }
  
  function getUserLostsAmount(address _user)
    public
    view
    returns (uint[] memory)
  {
    return (lostProfits[_user].amount);
  }
  
  function getUserLostsLevel(address _user)
    public
    view
    returns (uint[] memory)
  {
    return (lostProfits[_user].level);
  }
  

  function getUserLevelExpiresAt(address _user, uint _level)
    public
    view
    returns (uint)
  {
    return users[_user].levelExpiresAt[_level];
  }

  

  function () external payable {
    revert();
  }
  
  
  function getUserLevel (address _user) public view returns (uint) {
      if (getUserLevelExpiresAt(_user, 1) < now) {
          return (0);
      }
      else if (getUserLevelExpiresAt(_user, 2) < now) {
          return (1);
      }
      else if (getUserLevelExpiresAt(_user, 3) < now) {
          return (2);
      }
      else if (getUserLevelExpiresAt(_user, 4) < now) {
          return (3);
      }
      else if (getUserLevelExpiresAt(_user, 5) < now) {
          return (4);
      }
      else if (getUserLevelExpiresAt(_user, 6) < now) {
          return (5);
      }
      else if (getUserLevelExpiresAt(_user, 7) < now) {
          return (6);
      }
      else if (getUserLevelExpiresAt(_user, 8) < now) {
          return (7);
      }
      else if (getUserLevelExpiresAt(_user, 9) < now) {
          return (8);
      }
      else if (getUserLevelExpiresAt(_user, 10) < now) {
          return (9);
      
      }
  }
  
  function getUserDetails (address _user) public view returns (uint, uint) {
      if (getUserLevelExpiresAt(_user, 1) < now) {
          return (1, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 2) < now) {
          return (2, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 3) < now) {
          return (3, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 4) < now) {
          return (4, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 5) < now) {
          return (5, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 6) < now) {
          return (6, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 7) < now) {
          return (7, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 8) < now) {
          return (8, users[_user].id);
      }
      else if (getUserLevelExpiresAt(_user, 9) < now) {
          return (9, users[_user].id);
      }
  }
      }