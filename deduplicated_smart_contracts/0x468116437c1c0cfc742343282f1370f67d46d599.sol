/**
 *Submitted for verification at Etherscan.io on 2019-09-17
*/

pragma solidity ^0.4.24;

//==============================================================================
// ____     _____    __   __
///\  _`\  /\  __`\ /\ \ /\ \
//\ \ \L\ \\ \ \/\ \\ `\`\/'/'
// \ \  _ <'\ \ \ \ \`\/ > <
//  \ \ \L\ \\ \ \_\ \  \/'/\`\
//   \ \____/ \ \_____\ /\_\\ \_\
//    \/___/   \/_____/ \/_/ \/_/
//==============================================================================

library BoxTypes {
    
    enum TeamId {
        TeamNone,
        TeamWhite,
        TeamBlack,
        TeamBlue,
        TeamRed
    }

    enum FinanceReason {
        FinancePotUserCommon,           //静态分红
        FinancePotUserSenior,           //高阶用户分红
        FinancePotTeamCaptain,          //战队奖励队长分红
        FinancePotTeam,                 //战队奖励分红
        FinanceWithdrawBoxBalance,      //提取盒子余额
        FinanceWithdrawInvitorBalance   //提取推广分红
    }

    struct Player {
        uint256 invitor;                    //邀请人
        
        uint256 boxTotal;                   //盒子总数量
        uint256 boxCount;                   //有效盒子数量
        uint256 boxEthCur;                  //盒子当前以太币
        uint256 boxEthCum;                  //盒子累计获得以太币

        uint256 invitorBalance;             //未领取推广分红

        int16 invited;                      //已邀请人数
        address addr;                       //账号地址
    }

    struct Round {
        uint256 end;                                                        //结束时间
        uint256 boxTotal;
        uint256 potCaptain;                                                 //队长奖励
        uint256 potTeam;
        uint256 potTeamReserved;
        int8 luckyTeam;                                                     //中奖队伍

        mapping (int8 => uint256[]) teamPlayers;                            //(tId => pIds)
        mapping (int8 => mapping (uint256 => uint256)) teamPlayerBoxCount;  //(tId => pId => boxCount)
        mapping (int8 => uint256) teamCaptain;                              //(tId => pId of captain)
        mapping (uint256 => uint256) potPlayer;                             //(pId => pot Player)
    }

    struct Pot {
        uint256 end;                                                        //结束时间
        uint256 potUserCommon;
        uint256 potUserSenior;

        mapping (uint256 => uint256) potSenior;                             //(pId => pot user senior)
    }

    struct Statistics {
        uint256 totalInvest;                                                //总投入
        uint256 totalWithdraw;                                              //总提取
        uint256 totalPotCaptain;                                            //总队长奖励
        uint256 devGain;                                                    //研发收入
    }
}

contract AccessControl {
    string public constant RoleOwner = "owner";

    struct RoleEntry {
        address addr;
        bool enable;
    }
    struct Role {
        string name;
        mapping (address => RoleEntry) userMap;
        address[] userArray;
    }
    mapping (string =>  Role) roles;
    string[] public roleNames;

    event RoleAdd(address indexed user, string name);
    event RoleRemove(address indexed user, string name);

    constructor() public {
        _roleAdd(RoleOwner, msg.sender);
    }

    function _roleAdd(string _name, address _user) private {
        if ((bytes(_name).length == 0) || (_user == address(0))) {
            return;
        }

        Role storage role = roles[_name];
        if (bytes(role.name).length == 0) {
            role.name = _name;
            roleNames.push(_name);
        }

        RoleEntry storage entry = role.userMap[_user];
        if (entry.addr == address(0)) {
            entry.addr = _user;
            role.userArray.push(_user);
        }
        entry.enable = true;
        emit RoleAdd(_user, _name);
    }

    /**
    * @dev add a role to a user
    * @param _name the name of the role
    * @param _user address of user
    */
    function roleAdd(string _name, address _user) public onlyOwner {
        _roleAdd(_name, _user);
    }

    /**
    * @dev remove a role from a user
    * @param _name the name of the role
    * @param _user address of user
    */
    function roleRemove(string _name, address _user) public onlyOwner {
        roles[_name].userMap[_user].enable = false;
        emit RoleRemove(_user, _name);
    }

    /**
    * @dev check if user has this role
    * @param _name the name of the role
    * @param _user address of user
    * @return bool
    */
    function _roleHas(string _name, address _user) internal view returns (bool){
        return roles[_name].userMap[_user].enable;
    }

    /**
    * @dev reverts if addr does not have role
    * @param _name the name of the role
    * @param _user address of user
    * // reverts
    */
    function roleCheck(string _name, address _user) public view {
        require(_roleHas(_name, _user));
    }

    /**
    * @dev determine if addr has role
    * @param _name the name of the role
    * @param _user address of user
    * @return bool
    */
    function roleHas(string _name, address _user) public view returns (bool) {
        return _roleHas(_name, _user);
    }

    function roleUsers(string _name) public view returns (address[] memory addrs) {
        Role storage role = roles[_name];
        if (role.userArray.length == 0) {
            return;
        }

        uint256 len = 0;
        for (uint256 j = 0; j < role.userArray.length; j++) {
            RoleEntry storage entry = role.userMap[role.userArray[j]];
            if (entry.enable) {
                len++;
            }
        }
        addrs = new address[](len);
        uint256 index = 0;
        for (j = 0; j < role.userArray.length; j++) {
            entry = role.userMap[role.userArray[j]];
            if (entry.enable) {
                addrs[index++] = entry.addr;
            }
        }
    }

    /**
    * @dev modifier to scope access to a single role (uses msg.sender as addr)
    * @param _role the name of the role
    * // reverts
    */
    modifier onlyRole(string _role) {
        roleCheck(_role, msg.sender);
        _;
    }

    modifier onlyOwner() {
        roleCheck(RoleOwner, msg.sender);
        _;
    }
}

contract BoxConstants {

    //round constants
    uint256 constant RoundTimeInitial = 24 hours;
    uint256 constant RoundTimeMax = 48 hours;
    uint256 constant RoundTimeAdd = 10 minutes;
    uint256 constant PotTime = 24 hours;

    //box constants
    uint256 constant BoxEthMaxFold = 3;
    uint256 constant BoxPrice = 0.005 ether;
    uint256 constant BoxEthMax = BoxEthMaxFold * BoxPrice;

    //role constants
    string constant RoleOwner = "owner";            //角色：所有者
    string constant RoleAdmin = "admin";            //角色：管理

    //pot
    // uint256 constant PotRatioUserCommon = 40;       //in %
    // uint256 constant PotRatioUserSenior = 15;       //in %
    // uint256 constant PotRatioTeam = 20;             //in %
    // uint256 constant PotRatioTeamReserved = 15;     //in %
    // uint256 constant PotRatioInvitor = 8;           //in %
    // uint256 constant PotRatioDeveloper = 2;         //in %

    uint256 constant PotRatioTeamCaptain = 40;      //in %
}

contract BoxData is AccessControl, BoxConstants {
    using SafeMath for uint256;

    address public addrGame;
    address public addrImpl;

    //TODO 金钱统计

    //game
    bool public activated = false;

    constructor(address addr) public {
        roleAdd(RoleAdmin, msg.sender);
        _setGame(addr);
    }

    //game

    /** @dev set activated
    * @param status activated status
    */
    function setActivated(bool status) public onlyAdmin {
        activated = status;
    }
 
    function setImpl(address addr) public onlyAdmin {
        addrImpl = addr;
    }

    function _setGame(address addr) private {
        addrGame = addr;
        addrImpl = BoxGame(addrGame).addrImpl();
    }

    function setGame(address addr) public onlyAdmin {
        _setGame(addr);
    }

    //round
    uint256 public nRound = 0;
    mapping (uint256 => BoxTypes.Round) public rounds;          //(rID => Round)

    /** @dev new round
    * @return rId Id of round
    */
    function newRound(uint256 end, uint256 potTeam) public onlyAdmin returns (uint256 rId) {
        nRound++;
        rId = nRound;
        BoxTypes.Round storage round = rounds[rId];
        round.end = end;
        round.potTeam = potTeam;
    }

    /** @dev get round base info
    * @param rId activated status
    * @return end end of round
    */
    function getRoundBase(uint256 rId) public view returns (
        uint256 end, uint256 boxTotal, uint256 potCaptain, uint256 potTeam, uint256 potTeamReserved, int8 luckyTeam) {
        BoxTypes.Round storage round = rounds[rId];

        end = round.end;
        boxTotal = round.boxTotal;
        potCaptain = round.potCaptain;
        potTeam = round.potTeam;
        potTeamReserved = round.potTeamReserved;
        luckyTeam = round.luckyTeam;
    }

    function setRoundTime(uint256 time) public onlyAdmin {
        rounds[nRound].end = time;
    }

    function setRoundPotInfo(uint256 rId, uint256 potCaptain, int8 luckyTeam) public onlyAdmin {
        BoxTypes.Round storage round = rounds[rId];

        round.potCaptain = potCaptain;
        round.luckyTeam = luckyTeam;
    }

    function getRoundTeam(uint256 rId, int8 tId) public view returns (uint256 captain, uint256[] players, uint256[] boxCounts, uint256 boxTotal) {
        BoxTypes.Round storage round = rounds[rId];

        if (0 == round.end) {
            return;
        }

        captain = round.teamCaptain[tId];
        uint256[] storage teamPlayers = round.teamPlayers[tId];
        uint256 count = teamPlayers.length;
        if (0 == count) {
            return;
        }

        players = new uint256[](count);
        boxCounts = new uint256[](count);
        for (uint256 index = 0; index < count; index++) {
            uint256 pId = teamPlayers[index];
            uint256 boxCount = round.teamPlayerBoxCount[tId][pId];
            players[index] = pId;
            boxCounts[index] = boxCount;
            boxTotal += boxCount;
        }
    }

    function getRoundPlayerBoxCount(uint256 rId, uint256 pId, int8 tId) public view returns (uint256) {
        return rounds[rId].teamPlayerBoxCount[tId][pId];
    }

    function getRoundPotPlayer(uint256 rId, uint256 pId) public view returns (uint256) {
        return rounds[rId].potPlayer[pId];
    }
    
    //pot
    uint256 public nPot = 0;
    mapping (uint256 => BoxTypes.Pot) public pots;              //(potID => Pot)

    function newPot(uint256 end) public onlyAdmin returns (uint256 potId) {
        nPot++;
        potId = nPot;
        BoxTypes.Pot storage pot = pots[potId];
        pot.end = end;
    }

    function getPotBase(uint256 potId) public view returns (
        uint256 end, uint256 potUserCommon, uint256 potUserSenior) {
        BoxTypes.Pot storage pot = pots[potId];

        end = pot.end;
        potUserCommon = pot.potUserCommon;
        potUserSenior = pot.potUserSenior;
    }

    function incPot(uint256 potUserCommon, uint256 potUserSenior, uint256 potTeam, uint256 potTeamReserved) public onlyAdmin {
        BoxTypes.Pot storage pot = pots[nPot];
        pot.potUserCommon = pot.potUserCommon.add(potUserCommon);
        pot.potUserSenior = pot.potUserSenior.add(potUserSenior);

        BoxTypes.Round storage round = rounds[nRound];
        round.potTeam = round.potTeam.add(potTeam);
        round.potTeamReserved = round.potTeamReserved.add(potTeamReserved);
    }

    function getPotSenior(uint256 potId, uint256 pId) public view returns (uint256) {
        return pots[potId].potSenior[pId];
    }

    //player
    uint256 public nPlayer = 0;
    mapping (address => uint256) public pAddrTopId;             //(address => pId)
    mapping (uint256 => BoxTypes.Player) public players;        //(pId => Player)

    /** @dev new player
    * @param addr Address of player
    * @param invitor invitor of player
    * @return pId Id of player
    */
    function newPlayer(address addr, uint256 invitor) public onlyAdmin returns (uint256 pId) {
        nPlayer++;
        pId = nPlayer;

        BoxTypes.Player storage player = players[pId];
        pAddrTopId[addr] = pId;
        player.invitor = invitor;
        player.addr = addr;
    }

    function getPlayer(uint256 pId) public view returns (
        address addr, uint256 invitor, int16 invited, uint256 invitorBalance, uint256 boxCount, uint256 boxTotal, uint256 boxEthCur, uint256 boxEthCum) {
        BoxTypes.Player storage player = players[pId];
        if (address(0) == player.addr) {
            return;
        }

        addr = player.addr;
        invitor = player.invitor;
        invited = player.invited;
        invitorBalance = player.invitorBalance;
        boxCount = player.boxCount;
        boxTotal = player.boxTotal;
        boxEthCur = player.boxEthCur;
        boxEthCum = player.boxEthCum;
    }

    function getPlayerAddress(uint256 pId) public view returns (address addr) {
        return players[pId].addr;
    }

    function getProfitablePlayers(uint256 ethMaxPerBox) public view returns (uint256[] profitablePlayers, uint256[] boxCounts, uint256 boxTotal, int16[] inviteds) {
        uint256 count;
        for (uint256 pId = 1; pId <= nPlayer; pId++) {
            BoxTypes.Player storage player = players[pId];
            uint256 ethMax = ethMaxPerBox.mul(player.boxCount);
            if (player.boxEthCum < ethMax) {
                count++;
            }
        }
        profitablePlayers = new uint256[](count); 
        boxCounts = new uint256[](count);
        inviteds = new int16[](count);
        uint256 pos;
        for (pId = 1; pId <= nPlayer; pId++) {
            player = players[pId];
            ethMax = ethMaxPerBox.mul(player.boxCount);
            if (player.boxEthCum < ethMax) {
                profitablePlayers[pos] = pId;
                boxCounts[pos] = player.boxCount;
                inviteds[pos] = player.invited;
                boxTotal += player.boxCount;
                pos++;
            }
        }
    }

    function setPlayerInvitor(uint256 pId, uint256 invitorId) public onlyAdmin {
        players[pId].invitor = invitorId;
    }

    function incPlayerInvited(uint256 pId) public onlyAdmin returns (int16) {
        players[pId].invited++;
        return players[pId].invited;
    }

    function newBox(uint256 pId, uint256 count, int8 tId) public onlyAdmin {
        BoxTypes.Player storage player = players[pId];
        player.boxCount += count;
        player.boxTotal += count;

        BoxTypes.Round storage round = rounds[nRound];
        round.boxTotal += count;

        uint256 boxCountOld = round.teamPlayerBoxCount[tId][pId];
        if (0 == boxCountOld) {
            round.teamPlayers[tId].push(pId);
        }
        uint256 boxCountNew = boxCountOld + count;
        round.teamPlayerBoxCount[tId][pId] = boxCountNew;
        uint256 captainId = round.teamCaptain[tId];
        uint256 captainBoxCount = round.teamPlayerBoxCount[tId][captainId];
        if (boxCountNew > captainBoxCount) {
            round.teamCaptain[tId] = pId;
        }
    }

    function incPlayerInvitorBalance(uint256 pId, uint256 val) public onlyAdmin {
        players[pId].invitorBalance = players[pId].invitorBalance.add(val);
    }

    function _addPlayerBoxEth(uint256 pId, uint256 val, uint256 ethMaxPerBox) private returns (uint256 change) {
        BoxTypes.Player storage player = players[pId];

        uint256 ethMax = ethMaxPerBox.mul(player.boxCount);
        if (ethMax <= player.boxEthCum) {
            return 0;
        }

        uint256 changeMax = ethMax - player.boxEthCum;
        if (val >= changeMax) {
            change = changeMax;
            player.boxEthCur += change;
            player.boxEthCum = 0;
            player.boxCount = 0;
        } else {
            change = val;
            player.boxEthCur += change;
            player.boxEthCum += change;
        }
    }

    function addPlayerPotTeam(uint256 rId, uint256[] pIds, uint256[] vals, uint256 ethMaxPerBox) public onlyAdmin returns (uint256 distributed) {
        uint256 count = pIds.length;
        if(count <= 0) {
            return;
        }
        for (uint256 index = 0; index < count; index++) {
            uint256 pId = pIds[index];
            uint256 val = vals[index];
            distributed += _addPlayerBoxEth(pId, val, ethMaxPerBox);
            rounds[rId].potPlayer[pId] += val;
        }
    }

    function addPlayerPotUser(uint256 potId, uint256[] pIds, uint256[] valCommons, uint256[] valSeniors, uint256 ethMaxPerBox) public onlyAdmin returns (uint256 distributed) {
        uint256 count = pIds.length;
        if(count <= 0) {
            return;
        }
        for (uint256 index = 0; index < count; index++) {
            uint256 pId = pIds[index];
            uint256 valCommon = valCommons[index];
            uint256 valSenior = valSeniors[index];
            uint256 val = valCommon.add(valSenior);
            distributed += _addPlayerBoxEth(pId, val, ethMaxPerBox);
            pots[potId].potSenior[pId] += valSenior;
        }
    }

    function resetPlayerBoxEth(uint256 pId,  uint256 ethMaxPerBox) public onlyAdmin returns (uint256 eth) {
        BoxTypes.Player storage player = players[pId];

        eth = player.boxEthCur;
        player.boxEthCur = 0;
        uint256 ethMax = ethMaxPerBox.mul(player.boxCount);
        if (ethMax <= player.boxEthCum) {
            player.boxCount = 0;
            player.boxEthCum = 0;
        }
    }

    function resetPlayerInvitorBalance(uint256 pId) public onlyAdmin returns (uint256 eth) {
        BoxTypes.Player storage player = players[pId];
        eth = player.invitorBalance;
        player.invitorBalance = 0;
    }

    //stats
    BoxTypes.Statistics public stats;

    function addStatsInvest(uint256 val) public onlyAdmin {
        stats.totalInvest = stats.totalInvest.add(val);
    }

    function addStatsWithdraw(uint256 val) public onlyAdmin {
        stats.totalWithdraw = stats.totalWithdraw.add(val);
    }

    function addStatsPotCaptain(uint256 val) public onlyAdmin {
        stats.totalPotCaptain = stats.totalPotCaptain.add(val);
    }

    function addStatsDevGain(uint256 val) public onlyAdmin {
        stats.devGain = stats.devGain.add(val);
    }

    /**
     * @dev call only by impl or admin
     */
    modifier onlyAdmin() {
        require((msg.sender == addrImpl) || (msg.sender == addrGame) || roleHas(RoleAdmin, msg.sender), "can only call by admin");
        _;
    }
}

contract BoxEvents {

    event evNewRound (
        uint256 indexed rId,
        uint256 end,
        uint256 potTeam,
        uint256 timeStamp
    );

    event evNewPot (
        uint256 indexed potId,
        uint256 end,
        uint256 timeStamp
    );

    event evBuyBox (
        uint256 indexed pId,
        int8 indexed tId,
        uint256 indexed invitor,
        uint256 count,
        uint256 value,
        uint256 timeStamp
    );

    event evEndRound (
        uint256 indexed rId,
        uint256 potTeam,
        uint256 potTeamReserved,
        int8 luckyTeam,
        uint256 timeStamp
    );

    event evTransfer (
        address indexed addr,
        int8 indexed reason,
        uint256 value,
        uint256 timeStamp
    );

    event evDistributePot (
        uint256 potUserCommon,
        uint256 potUserSenior,
        uint256 boxCount,
        uint256 timeStamp
    );
}





library TimeUtil {
    using SafeMath for uint256;

    function isSameDay(uint256 time1, uint256 time2) internal pure returns (bool) {
         //GMT +8
        uint256 timeZone = uint256(8).mul(3600);
        uint256 secondsOneDay = uint256(24).mul(3600);
        uint256 day1 = time1.add(timeZone).div(secondsOneDay);
        uint256 day2 = time2.add(timeZone).div(secondsOneDay);
        if(day1 == day2){
            return true;
        }
        
        return false;
    }
}

library BoxCommon {
    using SafeMath for uint256;

    function calcPot(uint256 value) internal pure returns (
        uint256 valUserCommon,
        uint256 valUserSenior,
        uint256 valTeam,
        uint256 valTeamReserved,
        uint256 valInvitor,
        uint256 valDev
    ) {
        // uint256 constant PotRatioUserCommon = 40;       //in %
        // uint256 constant PotRatioUserSenior = 15;       //in %
        // uint256 constant PotRatioTeam = 20;             //in %
        // uint256 constant PotRatioTeamReserved = 15;     //in %
        // uint256 constant PotRatioInvitor = 8;           //in %

        valUserCommon = value.mul(40).div(100);
        valUserSenior = value.mul(15).div(100);
        valTeam = value.mul(20).div(100);
        valTeamReserved = value.mul(15).div(100);
        valInvitor = value.mul(8).div(100);
        valDev = value - valUserCommon - valUserSenior - valTeam - valTeamReserved - valInvitor;
    }

    function invited2PotWeight(int16 invited) internal pure returns (uint256) {
        if (invited < 1) {
            return 0;
        } else if (invited < 3) {
            return 1;
        } else if (invited < 8) {
            return 3;
        } else if (invited < 15) {
            return 10;
        } else if (invited < 30) {
            return 15;
        } else {
            return 30;
        }
    }

    function calcPotUserSenior(uint256 potUserSenior, uint256 count, uint256[] memory boxCounts, int16[] memory inviteds) internal pure returns (
        uint256 potBoxSeniorAvg, uint256[] memory weights) {
        uint256 weightTotal;
        weights = new uint256[](count);
        for (uint256 index = 0; index < count; index++) {
            uint256 weight = invited2PotWeight(inviteds[index]).mul(boxCounts[index]);
            weights[index] = weight;
            weightTotal += weight;
        }
        if (weightTotal > 0) {
            potBoxSeniorAvg = potUserSenior.div(weightTotal);
        }
    }

    function calcPotUserCommon(uint256 potUserCommon, uint256 boxTotal) internal pure returns (uint256 potBoxCommonAvg) {
        potBoxCommonAvg = potUserCommon.div(boxTotal);
    }

    function calcPotUser(uint256 potUserSenior, uint256 potUserCommon, uint256 boxTotal, uint256 count, uint256[] memory boxCounts, int16[] memory inviteds) internal pure returns (uint256[] memory valSeniors, uint256[] memory valCommons) {
        (uint256 potBoxSeniorAvg, uint256[] memory weights) = calcPotUserSenior(potUserSenior, count, boxCounts, inviteds);
        uint256 potBoxCommonAvg = calcPotUserCommon(potUserCommon, boxTotal);
        valSeniors = new uint256[](count);
        valCommons = new uint256[](count);
        for (uint256 index = 0; index < count; index++) {
            valCommons[index] = potBoxCommonAvg.mul(boxCounts[index]);
            valSeniors[index] = potBoxSeniorAvg.mul(weights[index]);
        }
    }
}

/**
 * @title SafeMath
 * @dev safe math operations.
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (0 == a) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = ((add(x, 1)) / 2);
        y = x;
        while (z < y) {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    function sq(uint256 x) internal pure returns (uint256) {
        return (mul(x,x));
    }

    function pwr(uint256 x, uint256 y) internal pure returns (uint256) {
        if (0 == x)
            return (0);
        else if (0 == y)
            return (1);
        else {
            uint256 z = x;
            for (uint256 i = 1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract BoxGame is Ownable, BoxEvents, BoxConstants {
    address public addrData;
    address public addrImpl;

    constructor() public {
    }

    function () public payable {
    }

    function _setAddr(address addrD, address addrI) private {
        addrData = addrD;
        addrImpl = addrI;
        BoxData(addrData).setImpl(addrImpl);
        BoxImpl(addrImpl).setData(addrData);
    }

    function setAddr(address addrD, address addrI) public onlyOwner {
        _setAddr(addrD, addrI);
    }

    /**
    * @dev activate game
    */
    function activate(address addrD, address addrI, uint256 timeBase) public onlyOwner {
        _setAddr(addrD, addrI);
        BoxImpl(addrImpl).activate(msg.sender, timeBase);
    }

    /** @dev Buy boxes
    * @param count count of box to buy
    * @param tid team of box to buy
    * @param invitorId invitor of player
    */
    function buyBox(uint256 count, int8 tid, uint256 invitorId) public payable {
        require(tx.origin == msg.sender, "sorry humans only");

        BoxImpl(addrImpl).buyBox(msg.sender, msg.value, count, tid, invitorId);
    }

    /**
    * @dev tick game
    */
    function tickGame() public {
        BoxImpl(addrImpl).tickGame();
    }

    /**
    * @dev tick pot
    */
    function tickPot() public {
        BoxImpl(addrImpl).tickPot();
    }

    /**
    * @dev withdraw box balance
    */
    function withdrawBoxBalance() public {
        BoxImpl(addrImpl).withdrawBoxBalance(msg.sender);
    }

    /**
    * @dev withdraw invitor balance
    */
    function withdrawInvitorBalance() public {
        BoxImpl(addrImpl).withdrawInvitorBalance(msg.sender);
    }

    function transferToPlayer(address addr, uint256 value, int8 reason) public {
        require((addrImpl == msg.sender) || BoxData(addrData).roleHas(RoleAdmin, msg.sender), "can only call by admin");

        addr.transfer(value);

        emit evTransfer (
            addr,
            reason,
            value,
            now
        );
    }

    function roundShouldEnd() public view returns (bool) {
        return BoxImpl(addrImpl).roundShouldEnd();
    }

    function potShouldDistribute() public view returns (bool) {
        return BoxImpl(addrImpl).potShouldDistribute();
    }

    /** @dev get round info
    * @return end end of round
    * @return invest total invest of round
    * @return potTeam ether of team pot
    * @return boxCounts total box count of each team
    * @return captains captain of each team
    * @return capBoxCounts total box count of each captain
    */
    function getRoundInfo() public view returns (
        uint256 end, uint256 invest, uint256 potTeam, uint256[] boxCounts, address[] captains, uint256[] capBoxCounts) {
        return BoxImpl(addrImpl).getRoundInfo();
    }

    /** @dev get player info
    * @param addr addr of player
    * @return pId player id
    * @return invited invited count of players
    * @return boxTotal total box count of player
    * @return profitSpace profit space of player
    * @return boxBalance box balance of player
    * @return invitorBalance invitor balance of player
    * @return potUserSeniorLast invitor balance of player cumulated
    * @return boxeCounts total box count of each team
    */
    function getPlayerInfo(address addr) public view returns (
        uint256 pId, int16 invited, uint256 boxTotal, uint256 profitSpace, uint256 boxBalance, uint256 invitorBalance, uint256 potUserSeniorLast, uint256[] boxeCounts) {
        return BoxImpl(addrImpl).getPlayerInfo(addr);
    }

    function getPotHistory(address addr) public view returns (
        uint256 time, int8 tId, address captain, uint256 potCaptain, uint256 potUser) {
        return BoxImpl(addrImpl).getPotHistory(addr);
    }

    function _getPotTotal(BoxData data) private view returns (uint256 potTotal) {
        (, , , uint256 potTeam, uint256 potTeamReserved,) = data.getRoundBase(data.nRound());
        (, uint256 potUserCommon, uint256 potUserSenior) = data.getPotBase(data.nPot());
        potTotal = potTeam + potTeamReserved + potUserCommon + potUserSenior;
    }

    function getStats() public view returns (
        uint256 invest, uint256 withdraw, uint256 potCaptain, uint256 balance, uint256 potTotal, uint256 balanceTotal, uint256 devGain) {
        BoxData data = BoxData(addrData);
        balance = address(this).balance;
        potTotal = _getPotTotal(data);

        (invest, withdraw, potCaptain, devGain) = data.stats();

        for (uint256 pId = 1; pId <= data.nPlayer(); pId++) {
            (, , , uint256 invitorBalance, , , uint256 boxEthCur,) = data.getPlayer(pId);
            balanceTotal += (invitorBalance + boxEthCur);
        }
    }

    function withdraw(address addr, uint256 value) public onlyOwner {
        uint256 balance = address(this).balance;
        require(value <= balance, "not enough ether");
        
        addr.transfer(value);
    }
}

contract BoxImpl is Ownable, BoxConstants, BoxEvents {
    using TimeUtil for uint256;
    using SafeMath for uint256;

    BoxGame public game;
    BoxData public data;

    constructor(address addrGame) public {
        _setGame(addrGame);
    }

    function _setGame(address addr) private {
        game = BoxGame(addr);
        data = BoxData(game.addrData());
    }

    function setData(address addr) public {
        require((address(game) == msg.sender) || (owner == msg.sender), "can only call by admin");

        data = BoxData(addr);
    }

    function setGame(address addr) public {
        require((owner == msg.sender) || data.roleHas(RoleAdmin, msg.sender), "can only call by admin");

        _setGame(addr);
    }

    function _newRound(uint256 potTeam) private {
        uint256 begin = now;
        uint256 end = begin.add(RoundTimeInitial);
        uint256 rId = data.newRound(end, potTeam);
        emit evNewRound (
            rId,
            end,
            potTeam,
            begin
        );
    }

    function _newPot(uint256 timeBase) private {
        uint256 nowTime = now;
        uint256 n;
        if (nowTime >= timeBase) {
            n = now.sub(timeBase).div(PotTime) + 1;
        } else {
            n = 0;
        }
        uint256 end = timeBase.add(PotTime.mul(n));
        uint256 potId = data.newPot(end);
        emit evNewPot (
            potId,
            end,
            now
        );
    }

    function activate(address, uint256 timeBase) public {
        require((address(game) == msg.sender) || data.roleHas(RoleAdmin, msg.sender), "can only call by admin");

        if (data.activated()) {
            return;
        }

        _newRound(0);

        //pot
        _newPot(timeBase);

        data.setActivated(true);
    }

    function _updateInviteInfo(address sender, uint256 invitorId) private returns (uint256, uint256) {
        bool newInvited = false;

        uint256 pId = data.pAddrTopId(sender);
        if (0 == pId) {
            if (invitorId != 0) {
                newInvited = true;
            }
            pId = data.newPlayer(sender, invitorId);
        } else {
            if (pId == invitorId) {
                invitorId = 0;
            }

            (, uint256 invitorLast, , , , , , ) = data.getPlayer(pId);
            if (invitorLast != 0) {
                invitorId = invitorLast;
            } else if (invitorId != 0) {
                data.setPlayerInvitor(pId, invitorId);
                newInvited = true;
            }
        }
        if (newInvited) {
            data.incPlayerInvited(invitorId);
        }
        return (pId, invitorId);
    }

    function _addPot(uint256 value, uint256 invitorId) private {
        (uint256 valUserCommon, uint256 valUserSenior, uint256 valTeam, uint256 valTeamReserved, uint256 valInvitor, uint256 valDev) = BoxCommon.calcPot(value);
        data.incPot(valUserCommon, valUserSenior, valTeam, valTeamReserved);
        data.addStatsDevGain(valDev);
        if (invitorId != 0 && valInvitor > 0) {
            data.incPlayerInvitorBalance(invitorId, valInvitor);
        } else {
            data.addStatsDevGain(valInvitor);
        }
    }

    function buyBox(address sender, uint256 value, uint256 count, int8 tId, uint256 invitorId) public {
        require(data.activated(), "not activated");
        require(value >= BoxPrice.mul(count), "not enough ether");

        uint256 pId;
        (pId, invitorId) = _updateInviteInfo(sender, invitorId);

        data.newBox(pId, count, tId);

        (uint256 end, , , , ,) = data.getRoundBase(data.nRound());
        uint256 endMax = now.add(RoundTimeMax);
        end = end.add(RoundTimeAdd.mul(count));
        if (end > endMax) {
            end = endMax;
        }
        data.setRoundTime(end);

        _addPot(value, invitorId);

        data.addStatsInvest(value);

        emit evBuyBox (
            pId,
            tId,
            invitorId,
            count,
            value,
            now
        );
    }

    function roundShouldEnd() public view returns (bool) {
        (uint256 end, , , , ,) = data.getRoundBase(data.nRound());
        if (now >= end) {
            return true;
        }
        return false;
    }

    function _rollLuckyTeam() private view returns(int8 tId) {
        return int8(uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        ))) % 4) + 1;
    }

    function _distributePotTeamCaptain(uint256 potTeamCaptain, uint256 captain) private {
        if(0 == captain) {
            return;
        }
        address captainAddr = data.getPlayerAddress(captain);
        game.transferToPlayer(captainAddr, potTeamCaptain, int8(BoxTypes.FinanceReason.FinancePotTeamCaptain));
        data.addStatsPotCaptain(potTeamCaptain);
    }

    function _distributePotTeamBox(uint256 rId, uint256 potTeamBox, uint256[] players, uint256[] boxCounts, uint256 boxTotal) private {
        uint256 playerCount = players.length;
        if (0 == boxTotal) {
            return;
        }

        uint256 potTeamBoxAvg = potTeamBox.div(boxTotal);
        uint256[] memory vals = new uint256[](playerCount);
        for (uint256 index = 0; index < playerCount; index++) {
            vals[index] = potTeamBoxAvg.mul(boxCounts[index]);
        }
        uint256 distributed = data.addPlayerPotTeam(rId, players, vals, BoxEthMax);
        if (distributed < potTeamBox) {
            data.addStatsDevGain(potTeamBox - distributed);
        }
    }

    function _rotateRound() private {
        uint256 rId = data.nRound();
        (, , , uint256 potTeam, uint256 potTeamReserved,) = data.getRoundBase(rId);
        int8 luckyTeam = _rollLuckyTeam();
        uint256 potTeamCaptain;
        uint256 potTeamBox;
        uint256 potNextRound;

        if (potTeam > 0) {
            potNextRound = potTeamReserved;
            (uint256 captain, uint256[] memory players, uint256[] memory boxCounts, uint256 boxTotal) = data.getRoundTeam(rId, luckyTeam);
            potTeamCaptain = potTeam.mul(PotRatioTeamCaptain).div(100);
            potTeamBox = potTeam.sub(potTeamCaptain);

            if (captain > 0) {
                //potTeamCaptain
                _distributePotTeamCaptain(potTeamCaptain, captain);

                //potTeamBox
                _distributePotTeamBox(rId, potTeamBox, players, boxCounts, boxTotal);
            } else {
                potTeamCaptain = 0;
                potNextRound = potNextRound.add(potTeam);
            }
        }

        data.setRoundPotInfo(rId, potTeamCaptain, luckyTeam);

        //end round
        emit evEndRound (
            rId,
            potTeam,
            potTeamReserved,
            luckyTeam,
            now
        );

        //new round
        _newRound(potNextRound);
    }

    function tickGame() public {
        require((address(game) == msg.sender) || data.roleHas(RoleAdmin, msg.sender), "can only call by admin");

        _rotateRound();
    }

    function _addPlayerPotUser(uint potId, uint256[] memory players, uint256 potUserSenior, uint256 potUserCommon, uint256 boxTotal, uint256 count, uint256[] memory boxCounts, int16[] memory inviteds) private {
        (uint256[] memory valSeniors, uint256[] memory valCommons) = BoxCommon.calcPotUser(potUserSenior, potUserCommon, boxTotal, count, boxCounts, inviteds);
        uint256 potTotal = potUserSenior.add(potUserCommon);
        uint256 distributed = data.addPlayerPotUser(potId, players, valCommons, valSeniors, BoxEthMax);
        if (distributed < potTotal) {
            data.addStatsDevGain(potTotal - distributed);
        }
    }

    function _distributePot() private {
        uint potId = data.nPot();
        (uint256 end, uint256 potUserCommon, uint256 potUserSenior) = data.getPotBase(potId);
        if (potUserCommon > 0) {
            (uint256[] memory players, uint256[] memory boxCounts, uint256 boxTotal, int16[] memory inviteds) = data.getProfitablePlayers(BoxEthMax);
            uint256 count = players.length;
            if (count != 0) {
                _addPlayerPotUser(potId, players, potUserSenior, potUserCommon, boxTotal, count, boxCounts, inviteds);
            }
        }

        emit evDistributePot (
            potUserCommon,
            potUserSenior,
            boxTotal,
            now
        );

        _newPot(end);
    }

    function tickPot() public {
        require((address(game) == msg.sender) || data.roleHas(RoleAdmin, msg.sender), "can only call by admin");
        
        _distributePot();
    }

    function potShouldDistribute() public view returns (bool) {
        (uint256 end, ,) = data.getPotBase(data.nPot());
        if (end <= now) {
            return true;
        }
        return false;
    }

    function withdrawBoxBalance(address addr) public {
        uint256 pId = data.pAddrTopId(addr);
        uint256 eth = data.resetPlayerBoxEth(pId,  BoxEthMax);
        if (eth > 0) {
            game.transferToPlayer(addr, eth, int8(BoxTypes.FinanceReason.FinanceWithdrawBoxBalance));
            data.addStatsWithdraw(eth);
        }
    }

    function withdrawInvitorBalance(address addr) public {
        uint256 pId = data.pAddrTopId(addr);
        uint256 eth = data.resetPlayerInvitorBalance(pId);
        if (eth > 0) {
           game.transferToPlayer(addr, eth, int8(BoxTypes.FinanceReason.FinanceWithdrawInvitorBalance));
           data.addStatsWithdraw(eth);
        }
    }

    function getRoundInfo() public view returns (
        uint256 end, uint256 invest, uint256 potTeam, uint256[] boxCounts, address[] captains, uint256[] capBoxCounts) {
        uint256 rId = data.nRound();
        uint256 boxTotal;
        (end, boxTotal, , potTeam, ,) = data.getRoundBase(rId);
        invest = boxTotal.mul(BoxPrice);

        boxCounts = new uint256[](4);
        captains = new address[](4);
        capBoxCounts = new uint256[](4);
        for (uint256 index = 0; index < 4; index++) {
            int8 tId = int8(index) + 1;
            (uint256 captain, , , uint256 boxCount) = data.getRoundTeam(rId, tId);
            boxCounts[index] = boxCount;
            captains[index] = data.getPlayerAddress(captain);
            capBoxCounts[index] = data.getRoundPlayerBoxCount(rId, captain, tId);
        }
    }

    function _getPlayerInfoEx(uint256 pId, uint256 boxCount, uint256 boxEthCum) private view returns (
        uint256 profitSpace, uint256 potUserSeniorLast, uint256[] boxeCounts) {
        profitSpace = BoxEthMax.mul(boxCount).sub(boxEthCum);
        boxeCounts = new uint256[](4);
        uint256 rId = data.nRound();
        uint256 potId = data.nPot();
        for (uint256 index = 0; index < 4; index++) {
            boxeCounts[index] = data.getRoundPlayerBoxCount(rId, pId, int8(index) + 1);
        }
        if (potId > 1) {
            potId -= 1;
            potUserSeniorLast = data.getPotSenior(potId, pId);
        }
    }

    function getPlayerInfo(address addr) public view returns (
        uint256 pId, int16 invited, uint256 boxTotal, uint256 profitSpace, uint256 boxBalance, uint256 invitorBalance, uint256 potUserSeniorLast, uint256[] boxeCounts) {
        uint256 boxCount;
        uint256 boxEthCum;
        pId = data.pAddrTopId(addr);
        (, , invited, invitorBalance, boxCount, boxTotal, boxBalance, boxEthCum) = data.getPlayer(pId);
        (profitSpace, potUserSeniorLast, boxeCounts) = _getPlayerInfoEx(pId, boxCount, boxEthCum);
    }

    function getPotHistory(address addr) public view returns (
        uint256 time, int8 tId, address captain, uint256 potCaptain, uint256 potUser) {

        uint256 rId = data.nRound();
        if (1 == rId) {
            return;
        }
        rId -= 1;
        (time, , potCaptain, , , tId) = data.getRoundBase(rId);
        (uint256 captainId, , ,) = data.getRoundTeam(rId, tId);
        captain = data.getPlayerAddress(captainId);
        potUser = data.getRoundPotPlayer(rId, data.pAddrTopId(addr));
    }
}