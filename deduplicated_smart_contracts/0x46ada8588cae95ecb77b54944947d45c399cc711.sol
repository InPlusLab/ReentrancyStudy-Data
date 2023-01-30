pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./LeagueBase.sol";
import "./AdminBase.sol";

contract League is LeagueBase,AdminBase {
    using SafeMath for uint;
    address payable constant public ZERO_ADDR = address(0x00);
    uint public _dailyInvest = 0;
    uint public _staticPool = 0;
    uint public _outInvest = 0;
    uint public _safePool = 0;
    uint public _gloryPool = 0;
    mapping(address => Player) allPlayers;
    address[] public allAddress = new address[](0);
    uint[] public lockedRound = new uint[](0);
    uint investCount = 0;
    mapping(uint => Investment) investments;
    address[] public dailyPlayers = new address[](0);
    uint _rand = 88;
    uint _safeIndex = 0;
    uint _endTime = 0;
    uint _startTime = 0;
    bool public _active = true;

    constructor() public payable {
        allPlayers[ZERO_ADDR] = Player({
            self : ZERO_ADDR,
            parent : ZERO_ADDR,
            bonus : 0,
            totalBonus : 0,
            invest : 0,
            sons : 0,
            round: 0,
            index: 0
        });
        lockedRound.push(0);
        allAddress.push(ZERO_ADDR);
        investments[investCount] =  Investment(ZERO_ADDR,0,now,0,true);
        investCount = investCount.add(1);
    }

    function () external payable {
        if(msg.value > 0){
            invest(ZERO_ADDR);
        }else{
            withdraw();
        }
    }

    function invest(address payable parentAddr) public payable {
        require(msg.value >= 0.5 ether, "Parameter Error");
        require(isStart(), "Game Start Limit");
        require(_active, "Game Over");
        bool isFirst = false;
        if(allPlayers[msg.sender].index == 0){
            isFirst = true;
            if(msg.sender == parentAddr) parentAddr=ZERO_ADDR;
            Player memory parent = allPlayers[parentAddr];
            if(parent.index == 0) {
                parentAddr = ZERO_ADDR;
            }
            allPlayers[msg.sender] = Player({
                self : msg.sender,
                parent : parentAddr,
                bonus: 0,
                totalBonus : 0,
                invest : msg.value,
                sons : 0,
                round: lockedRound.length,
                index: allAddress.length
            });
            allAddress.push(msg.sender);
        }else{
            Player storage user = allPlayers[msg.sender];
            uint totalBonus = 0;
            uint bonus = 0;
            bool outFlag;
            (totalBonus, bonus, outFlag) = calcBonus(user.self);
            require(outFlag, "Out Only");
            user.bonus = bonus;
            user.totalBonus = 0;
            user.invest = msg.value;
            user.round = lockedRound.length;
        }
        _dailyInvest = _dailyInvest.add(msg.value);
        _safePool = _safePool.add(msg.value.div(20));
        _gloryPool = _gloryPool.add(msg.value.mul(3).div(25));
        _staticPool = _staticPool.add(msg.value.mul(61).div(100));
        dailyPlayers.push(msg.sender);
        Player memory self = allPlayers[msg.sender];
        Player memory parent = allPlayers[self.parent];
        uint parentVal = msg.value.div(20);
        if(isFirst == true) {
            investBonus(parent.self, parentVal, true, 1);
        } else {
            investBonus(parent.self, parentVal, true, 0);
        }
        Player memory grand = allPlayers[parent.parent];
        if(grand.sons >= 2){
            uint grandVal = msg.value.mul(3).div(100);
            investBonus(grand.self, grandVal, true, 0);
        }
        Player memory great = allPlayers[grand.parent];
        if(allPlayers[great.self].sons >= 3){
            uint greatVal = msg.value.div(100);
            investBonus(great.self, greatVal, true, 0);
        }
        investments[investCount] = Investment(msg.sender,msg.value,now,lockedRound.length,isFirst);
        investCount=investCount.add(1);
        emit logUserInvest(msg.sender, parentAddr, isFirst, msg.value, now);
    }

    function calcBonus(address target) public view returns(uint, uint, bool) {
        Player memory player = allPlayers[target];
        uint lockedBonus = calcLocked(target);
        uint totalBonus = player.totalBonus.add(lockedBonus);
        bool outFlag = false;
        uint less = 0;
        uint maxIncome = 0;
        if(player.invest <= 11 ether){
            maxIncome = player.invest.mul(3).div(2);
        }else if(player.invest > 11 ether && player.invest <= 21 ether){
            maxIncome = player.invest.mul(9).div(5);
        }else if(player.invest > 21 ether){
            maxIncome = player.invest.mul(2);
        }
        if (totalBonus >= maxIncome) {
            less = totalBonus.sub(maxIncome);
            outFlag = true;
        }
        totalBonus = totalBonus.sub(less);
        uint bonus = player.bonus.add(lockedBonus).sub(less);

        return (totalBonus, bonus, outFlag);
    }

    function calcLocked(address target) public view returns(uint) {
        Player memory self = allPlayers[target];
        uint randTotal = 0;
        for(uint i=self.round; i<lockedRound.length; i++){
            randTotal = randTotal.add(lockedRound[i]);
        }
        uint lockedBonus = self.invest.mul(randTotal).div(10000);
        return lockedBonus;
    }

    function saveRound() internal returns(bool) {
        bool retreat = false;
        uint rand = getRandom(2).add(1);
        uint dayLocked = _dailyInvest.mul(61).div(100);
        uint releaseLocked = _safePool.mul(20).sub(_outInvest);
        if(dayLocked < releaseLocked.mul(rand).div(100)) {
            rand = 1;
        }
        if(_staticPool < releaseLocked.mul(rand).div(100)) {
            rand = 0;
            retreat = true;
            fomo();
        }
        _staticPool = _staticPool.sub(releaseLocked.mul(rand).div(100));
        lockedRound.push(rand);

        emit logRandom(rand, now);
        return retreat;
    }


    function sendGloryAward(address[] memory plays, uint[] memory selfAmount, uint totalAmount)
    public onlyAdmin() {
        require(_gloryPool>0, "GloryPool Limit");
        _gloryPool = _gloryPool.sub(totalAmount);
        for(uint i = 0; i < plays.length; i++){
            investBonus(plays[i], selfAmount[i], false, 0);
            emit logGlory(plays[i], selfAmount[i], now);
        }
    }

    function lottery() internal {
        uint luckNum = dailyPlayers.length;
        if (luckNum >= 30) {
            luckNum = 30;
        }
        address[] memory luckyDogs = new address[](luckNum);
        uint[] memory luckyAmounts = new uint[](luckNum);
        if (luckNum <= 30) {
            for(uint i=0; i<luckNum; i++) {
                luckyDogs[i] = dailyPlayers[i];
            }
        } else {
            for(uint i= 0; i<luckNum; i++){
                uint random = getRandom(dailyPlayers.length);
                luckyDogs[i] = dailyPlayers[random];
                delete dailyPlayers[random];
            }
        }
        uint totalRandom = 0;
        for(uint i=0; i<luckNum; i++){
            luckyAmounts[i] = getRandom(50).add(1);
            totalRandom = totalRandom.add(luckyAmounts[i]);
        }
        uint lotteryAmount = 0;
        uint luckyPool = _dailyInvest.div(100);
        for(uint i=0; i<luckNum; i++){
            lotteryAmount = luckyAmounts[i].mul(luckyPool).div(totalRandom);
            investBonus(luckyDogs[i], lotteryAmount, false ,0);
            emit logLucky(luckyDogs[i], lotteryAmount, now, 1);
        }
    }

    function leagueGame() public onlyAdmin() {
        bool retreatFlag = saveRound();
        if(retreatFlag) {
            if(now.sub(_endTime).div(1 days) >3) {
                uint amount = address(this).balance.sub(_staticPool);
                msg.sender.transfer(amount);
                _active = true;
            }
            return ;
        }
        msg.sender.transfer(_dailyInvest.div(10));
        lottery();
        _dailyInvest = 0;
        delete dailyPlayers;
    }

    // fomo，可能会循环2000次。最高可循环多少次呢？
    function fomo() internal {
        uint amount = 0;
        for(uint i=investCount-1; i>0; i--) {
            if(_safePool<=0) {
                if(now.sub(_endTime).div(1 days)>5) {
                    _safeIndex = i+2;
                    _endTime = now;
                    _active = false;
                }
                break;
            }
            amount = investments[i].amount;
            if(amount > _safePool) {
                amount = _safePool;
            }
            _safePool = _safePool.sub(amount);
        }
    }

    function getSafety(address target) public view returns(uint) {
        uint amount = 0;
        for (uint i = investCount-1; i >= _safeIndex; i--){
            if(investments[i].self == target) {
                amount = amount.add(investments[i].amount);
            }
        }
        return amount;
    }

    function withdraw() public {
        require(isStart(), "Game Start Limit");
        Player storage user = allPlayers[msg.sender];
        uint totalBonus = 0;
        uint withdrawBonus = 0;
        bool outFlag;
        (totalBonus, withdrawBonus, outFlag) = calcBonus(user.self);

        uint safety = 0;
        if(!_active && user.invest>0) {
            safety = getSafety(msg.sender);
            user.invest = 0;
        }
        
        if(outFlag) {
            _outInvest = _outInvest.add(user.invest);
            user.totalBonus = 0;
            user.invest = 0;
        }else {
            user.totalBonus = totalBonus;
        }

        user.round = lockedRound.length;
        user.bonus = 0;
        msg.sender.transfer(withdrawBonus.add(safety));
        emit logWithDraw(msg.sender, withdrawBonus.add(safety), now);
    }


    function investBonus(address targetAddr, uint wwin, bool totalFlag, uint addson)
    internal {
        if(targetAddr == ZERO_ADDR || allPlayers[targetAddr].invest == 0 || wwin == 0) return;
        Player storage target = allPlayers[targetAddr];
        target.bonus = target.bonus.add(wwin);
        if(addson != 0) target.sons = target.sons+1;
        if(totalFlag) target.totalBonus = target.totalBonus.add(wwin);
    }

    function getRandom(uint max)
    internal returns(uint) {
        _rand = _rand.add(1);
        uint rand = _rand*_rand;
        uint random = uint(keccak256(abi.encodePacked(block.difficulty, now, msg.sender, rand)));
        return random % max;
    }

    function start(uint time) external onlyAdmin() {
        require(time > now, "Invalid Time");
        _startTime = time;
    }

    function startArgs(uint staticPool, uint safePool, uint[] memory locks) public {
        require(!isStart(), "Game Not Start Limit");
        _staticPool = staticPool;
        _safePool = safePool;
        for(uint i=0; i<locks.length; i++) {
            lockedRound.push(locks[i]);
        }
    }

    function league(
        address[] memory plays, address[] memory parents,
        uint[] memory bonus, uint[] memory totalBonus,
        uint[] memory totalInvests, uint[] memory sons, uint[] memory round)
    public {
        require(!isStart(), "Game Not Start Limit");
        for(uint i=0; i<plays.length; i++) {
            Player storage user = allPlayers[plays[i]];
            user.self = plays[i];
            user.parent = parents[i];
            user.bonus = bonus[i];
            user.totalBonus = totalBonus[i];
            user.invest = totalInvests[i];
            user.sons = sons[i];
            user.round = round[i];
            user.index = allAddress.length;
            allAddress.push(plays[i]);
        }
    }

    function isStart() public view returns(bool) {
        return _startTime != 0 && now > _startTime;
    }

    function userInfo(address payable target)
    public view returns (address, address, address, uint, uint, uint, uint, uint){
        Player memory self = allPlayers[target];
        Player memory parent = allPlayers[self.parent];
        Player memory grand = allPlayers[parent.parent];
        Player memory great = allPlayers[grand.parent];
        return (parent.self, grand.self, great.self,
        self.bonus, self.totalBonus, self.invest, self.sons, self.round);
    }

}