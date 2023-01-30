// SPDX-License-Identifier: BSD-3-Clause

/** 
*                                                                                                                                  
*       ##### /                                                             #######      /                                         
*    ######  /          #                                                 /       ###  #/                                          
*   /#   /  /          ###                                               /         ##  ##                                          
*  /    /  /            #                                                ##        #   ##                                          
*      /  /                                                               ###          ##                                          
*     ## ##           ###        /###    ###  /###         /###          ## ###        ##  /##      /###    ###  /###       /##    
*     ## ##            ###      / ###  /  ###/ #### /     / #### /        ### ###      ## / ###    / ###  /  ###/ #### /   / ###   
*     ## ##             ##     /   ###/    ##   ###/     ##  ###/           ### ###    ##/   ###  /   ###/    ##   ###/   /   ###  
*     ## ##             ##    ##    ##     ##    ##   k ####                  ### /##  ##     ## ##    ##     ##         ##    ### 
*     ## ##             ##    ##    ##     ##    ##   a   ###                   #/ /## ##     ## ##    ##     ##         ########  
*     #  ##             ##    ##    ##     ##    ##   i     ###                  #/ ## ##     ## ##    ##     ##         #######   
*        /              ##    ##    ##     ##    ##   z       ###                 # /  ##     ## ##    ##     ##         ##        
*    /##/           /   ##    ##    ##     ##    ##   e  /###  ##       /##        /   ##     ## ##    /#     ##         ####    / 
*   /  ############/    ### /  ######      ###   ###  n / #### /       /  ########/    ##     ##  ####/ ##    ###         ######/  
*  /     #########       ##/    ####        ###   ### -    ###/       /     #####       ##    ##   ###   ##    ###         #####   
*  #                                                  w               |                       /                                    
*   ##                                                e                \)                    /                                     
*                                                     b                                     /                                      
*                                                                                          /                                       
*
*
* Lion's Share is the very first true follow-me matrix smart contract ever created.
* Now you can build an organization and earn on up to 15 levels.
* https://www.lionsshare.io
* Get your share, join today!
*/

pragma solidity ^0.6.8;

import './DataStorage.sol';
import './Access.sol';
import './Events.sol';

contract LionShareUL is DataStorage, Access, Events {

  constructor() public {
    owner = msg.sender;

    reentryStatus = ENTRY_ENABLED;
    contractEnabled = false;
  }

  function init(address _addr) external isOwner(msg.sender) {
    require(contractEnabled == false, "Require Closed For Maintenance!");
    require(topLevel == 0, "Already initiated!");

    uint[] memory commission = new uint[](15);
    commission[0] = 0.004 ether;
    commission[1] = 0.002 ether;
    commission[2] = 0.002 ether;
    commission[3] = 0.001 ether;
    commission[4] = 0.001 ether;
    commission[5] = 0.001 ether;
    commission[6] = 0.001 ether;
    commission[7] = 0.001 ether;
    commission[8] = 0.001 ether;
    commission[9] = 0.001 ether;
    commission[10] = 0.001 ether;
    commission[11] = 0.001 ether;
    commission[12] = 0.001 ether;
    commission[13] = 0.001 ether;
    commission[14] = 0.001 ether;

    levelCost[1] = Level({cost: 0.02 ether, commission: commission, fee: 0});
    topLevel = 1;

    createAccount(_addr);
    createPosition(_addr, _addr, 1, 1, true);
  }

  fallback() external payable blockReEntry() {
    preRegistration(msg.sender);
  }

  receive() external payable blockReEntry() {
    preRegistration(msg.sender);
  }

  function registration() external payable blockReEntry() {
    preRegistration(msg.sender);
  }

  function preRegistration(address _addr) internal {
    require(contractEnabled == true, "Closed For Maintenance");
    require(levelCost[1].cost == msg.value, "Require .02 eth to register!");

    address sponsor = createAccount(_addr);

    address activeSponsor = findActiveSponsor(_addr, sponsor, 1, true);

    createPosition(_addr, activeSponsor, (members[activeSponsor].Positions[1].depth + 1), 1, false);
    
    handlePayout(_addr, activeSponsor, 1, true);
  }

  function createAccount(address _addr) internal returns (address) {
    require(members[_addr].id == 0, "Already a member!");

    //Get the member details from LionShare contract
    (uint memberId, uint sales, bool exist, address sponsor) = ls_handle.members(_addr);

    require(memberId != 0, "Lions Share account required!");

    orderId++;

    members[_addr] = Account({id: memberId, sponsor: sponsor, activeLevel: 0});
    idToMember[memberId] = _addr;
    
    emit Registration(_addr, memberId, sponsor, orderId);

    return sponsor;
  }

  function purchaseLevel(uint _level) external payable isMember(msg.sender) blockReEntry() {
    require(contractEnabled == true, "Closed For Maintenance");
    require((members[msg.sender].activeLevel > 0), "Need active account.");
    require((_level > 0 && _level <= topLevel), "Invalid matrix level.");

    uint activeLevel = members[msg.sender].activeLevel;

    require((activeLevel < _level), "Already active at level!");
    require((activeLevel == (_level - 1)), "Level upgrade req. in order!");
    require((msg.value == levelCost[_level].cost), "Wrong amount transferred.");
  
    orderId++;

    handleLevel(_level);
  }

  function purchaseBundle(uint _level) external payable isMember(msg.sender) blockReEntry() {
    require(contractEnabled == true, "Closed For Maintenance");
    require((members[msg.sender].activeLevel > 0), "Need active account.");
    require((_level > 0 && _level <= topLevel), "Invalid matrix level.");

    uint activeLevel = members[msg.sender].activeLevel;
    
    require((activeLevel < _level), "Already active at level!");

    uint amount = 0;

    for (uint num = (activeLevel + 1);num <= _level;num++) {
      amount += levelCost[num].cost;
    }

    require(msg.value == amount, "Wrong amount transferred.");

    orderId++;

    for (uint num = (activeLevel + 1);num <= _level;num++) {
      handleLevel(num);
    }
  }

  function bundleCost(uint _level) external view isMember(msg.sender) returns (uint) {
    require(contractEnabled == true, "Closed For Maintenance");
    require((_level > 0 && _level <= topLevel), "Invalid unilevel.");

    uint activeLevel = members[msg.sender].activeLevel;
    
    require((activeLevel < _level), "Already active at level!");

    uint amount = 0;

    for (uint num = (activeLevel + 1);num <= _level;num++) {
      amount += levelCost[num].cost;
    }

    return amount;
  }

  function handleLevel(uint _level) internal {
    address sponsor = members[msg.sender].sponsor;
    address activeSponsor = findActiveSponsor(msg.sender, sponsor, _level, true);

    emit Upgrade(msg.sender, activeSponsor, _level, orderId);

    createPosition(msg.sender, activeSponsor, (members[activeSponsor].Positions[_level].depth + 1), _level, false);

    handlePayout(msg.sender, activeSponsor, _level, true);

    if (levelCost[_level].fee > 0) {
      processPayout(feeSystem, levelCost[_level].fee);
    }
  }

  function createPosition(address _addr, address _sponsor, uint depth, uint _level, bool _initial) internal {
    Account storage member = members[_addr];

    member.activeLevel = _level;
    member.Positions[_level] = Position({sponsor: _sponsor, depth: depth});

    if (_initial == true) {
      return ;
    }

    emit Placement(_addr, _sponsor, _level, depth, orderId);
  }

  function findActiveSponsor(address _addr, address _sponsor, uint _level, bool _emit) internal returns (address) {
    address sponsorAddress = _sponsor;
    uint memberId;
    uint sales;
    bool exist;

    while (true) {
      if (members[sponsorAddress].activeLevel >= _level) {
        return sponsorAddress;
      }

      if (_emit == true) {
        emit FundsPassup(sponsorAddress, _addr, _level, orderId);
      }

      if (members[sponsorAddress].activeLevel >= _level) {
        sponsorAddress = members[sponsorAddress].Positions[_level].sponsor;
      } else if (members[sponsorAddress].id > 0) {
        sponsorAddress = members[sponsorAddress].sponsor;
      } else {
        (memberId, sales, exist, sponsorAddress) = ls_handle.members(sponsorAddress);

        if (memberId == 0) {
          sponsorAddress = idToMember[1]; //Force to company if we cant locate the address in main contract (should not be possible, but incase)
        }
      }
    }
  }

  function findPayoutReceiver(address _addr, uint _level) internal view returns (address) {
    address sponsorAddress = members[_addr].Positions[_level].sponsor;

    while (true) {
      if (members[sponsorAddress].activeLevel >= _level) {
        return sponsorAddress;
      }

      sponsorAddress = members[sponsorAddress].Positions[_level].sponsor;
    }
  }

  function handlePayout(address _addr, address _sponsor, uint _level, bool _transferPayout) internal {
    address receiver = _sponsor;
    uint[] memory commission = levelCost[_level].commission;

    for (uint i=0;i < commission.length;i++) {
      if (i > 0) {
        receiver = findPayoutReceiver(receiver, _level);
      }

      if (commission[i] > 0) {
        emit FundsPayout(receiver, _addr, _level, (i + 1), orderId);

        if (_transferPayout == true) {
          processPayout(receiver, commission[i]);
        }
      }
    }
  }

  function processPayout(address _addr, uint _amount) internal {
    (bool success, ) = address(uint160(_addr)).call{ value: _amount, gas: 40000 }("");

    if (success == false) { //Failsafe to prevent malicious contracts from blocking matrix
      (success, ) = address(uint160(idToMember[1])).call{ value: _amount, gas: 40000 }("");
      require(success, 'Transfer Failed');
    }
  }

  function getAffiliateWallet(uint memberId) external view returns (address) {
    return idToMember[memberId];
  }

  function getAffiliatePosition(address _addr, uint _level) external view returns (uint, address) {
    return (members[_addr].Positions[_level].depth, members[_addr].Positions[_level].sponsor);
  }

  function setupAccount(address _addr, uint _level) external isOwner(msg.sender) {
    createAccount(_addr);
    processCompLevel(_addr, _level);
  }

  function compLevel(address _addr, uint _level) public isOwner(msg.sender) isMember(_addr) {
    orderId++;

    processCompLevel(_addr, _level);
  }

  function processCompLevel(address _addr, uint _level) internal {
    require((_level > 0 && _level <= topLevel), "Invalid matrix level.");

    uint activeLevel = members[_addr].activeLevel;
    address sponsor = members[_addr].sponsor;

    require((activeLevel < _level), "Already active at level!");

    for (uint num = (activeLevel + 1);num <= _level;num++) {
      address activeSponsor = findActiveSponsor(_addr, sponsor, num, true);

      emit Upgrade(_addr, activeSponsor, num, orderId);

      createPosition(_addr, activeSponsor, (members[activeSponsor].Positions[_level].depth + 1), num, false);
      handlePayout(_addr, activeSponsor, num, false);
    }
  }

  function addLevel(uint _levelPrice, uint[] calldata _levelCommission, uint _levelFee) external isOwner(msg.sender) {
    require((levelCost[topLevel].cost < _levelPrice), "Check price point!");
    uint commission = 0;

    for (uint i=0;i < _levelCommission.length;i++) {
      commission += _levelCommission[i];
    }

    require((commission + _levelFee) == _levelPrice, "Check price point!");

    topLevel++;

    levelCost[topLevel] = Level({cost: _levelPrice, commission: _levelCommission, fee: _levelFee});

    createPosition(idToMember[1], idToMember[1], 1, topLevel, true);
  }

  function updateLevelCost(uint _level, uint _levelPrice, uint[] calldata _levelCommission, uint _levelFee) external isOwner(msg.sender) {
    require((_level > 0 && _level <= topLevel), "Invalid matrix level.");
    require((_levelPrice > 0), "Check price point!");
    uint commission = 0;

    for (uint i=0;i < _levelCommission.length;i++) {
      commission += _levelCommission[i];
    }

    require((commission + _levelFee) == _levelPrice, "Check price point!");

    if (_level > 1) {
      require((levelCost[(_level - 1)].cost < _levelPrice), "Check price point!");
    }

    if (_level < topLevel) {
      require((levelCost[(_level + 1)].cost > _levelPrice), "Check price point!");
    }

    levelCost[_level] = Level({cost: _levelPrice, commission: _levelCommission, fee: _levelFee});
  }

  function changeContractStatus() external isOwner(msg.sender) {
    contractEnabled = !contractEnabled;
    }

  function setFeeSystem(address _addr) external isOwner(msg.sender) {
    feeSystem = _addr;
  }

  function setLionShareContract(LionShareABI _addr) external isOwner(msg.sender) {
    ls_handle = _addr;
  }
}