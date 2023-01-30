pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./FutureBase.sol";
import "./AdminBase.sol";

contract Future is FutureBase,AdminBase {
    using SafeMath for uint256;
    address payable constant public ZERO_ADDR = address(0x00);
    uint256 public _dailyInvest = 0;
    uint256 public _staticPool = 0;
    uint256 public _safePool = 0;
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
    uint _gloryTime = 0;
    bool public _active = true;
    address[] public addressV1 = new address[](0);
    address[] public addressV2 = new address[](0);
    address[] public addressV3 = new address[](0);
    address[] public addressV4 = new address[](0);
    address[] public addressV5 = new address[](0);

    constructor() public {
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
        require(msg.value >= 0.5 ether && msg.sender != parentAddr, "Parameter Error.");
        require(isStart(), "Game Start Limit");
        require(_active, "Game Over");
        bool isFirst = false;
        if(allPlayers[msg.sender].index == 0){
            isFirst = true;
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
            uint256 totalBonus = 0;
            uint256 bonus = 0;
            bool outFlag;
            (totalBonus, bonus, outFlag) = calcBonus(user.self);
            if(outFlag) {
                user.bonus = bonus;
                user.totalBonus = 0;
                user.invest = msg.value;
            }else{
                user.invest = user.invest.add(msg.value);
                user.bonus = bonus;
                user.totalBonus = totalBonus;
            }
            user.round = lockedRound.length;
        }
        _dailyInvest = _dailyInvest.add(msg.value);
        _safePool = _safePool.add(msg.value.div(20));
        _staticPool = _staticPool.add(msg.value.mul(45).div(100));
        dailyPlayers.push(msg.sender);
        Player memory self = allPlayers[msg.sender];
        Player memory parent = allPlayers[self.parent];
        uint256 parentVal = msg.value.div(10);
        if(isFirst == true) {
            investBonus(parent.self, parentVal, true, 1);
        } else {
            investBonus(parent.self, parentVal, true, 0);
        }
        Player memory grand = allPlayers[parent.parent];
        if(grand.sons >= 2){
            uint256 grandVal = msg.value.div(20);
            investBonus(grand.self, grandVal, true, 0);
        }
        Player memory great = allPlayers[grand.parent];
        if(allPlayers[great.self].sons >= 3){
            uint256 greatVal = msg.value.div(20);
            investBonus(great.self, greatVal, true, 0);
        }
        Player memory greatFather = allPlayers[great.parent];
        if(allPlayers[greatFather.self].sons >= 4){
            uint256 superVal = msg.value.mul(3).div(100);
            investBonus(greatFather.self, superVal, true, 0);
        }
        Player memory greatGrandFather = allPlayers[greatFather.parent];
        if(allPlayers[greatGrandFather.self].sons >= 5){
            uint256 hyperVal = msg.value.div(50);
            investBonus(greatGrandFather.self, hyperVal, true, 0);
        }
        investments[investCount] = Investment(msg.sender,msg.value,now,lockedRound.length,isFirst);
        investCount=investCount.add(1);
        emit logUserInvest(msg.sender, parentAddr, isFirst, msg.value, now);

    }

    function calcBonus(address target) public view returns(uint256, uint256, bool) {
        Player memory player = allPlayers[target];
        uint256 lockedBonus = calcLocked(target);
        uint256 totalBonus = player.totalBonus.add(lockedBonus);
        bool outFlag = false;
        uint256 less = 0;
        uint256 maxIncome = 0;
        if(player.invest <= 10 ether){
            maxIncome = player.invest.mul(2);
        }else if(player.invest > 10 ether && player.invest <= 20 ether){
            maxIncome = player.invest.mul(3);
        }else if(player.invest > 20 ether){
            maxIncome = player.invest.mul(5);
        }
        if (totalBonus >= maxIncome) {
            less = totalBonus.sub(maxIncome);
            outFlag = true;
        }
        totalBonus = totalBonus.sub(less);
        uint256 bonus = player.bonus.add(lockedBonus).sub(less);

        return (totalBonus, bonus, outFlag);
    }

    function calcLocked(address target) public view returns(uint256) {
        Player memory self = allPlayers[target];
        uint randTotal = 0;
        for(uint i=self.round; i<lockedRound.length; i++){
            randTotal = randTotal.add(lockedRound[i]);
        }
        uint256 lockedBonus = self.invest.mul(randTotal).div(10000);
        return lockedBonus;
    }

    function saveRound() internal returns(bool) {
        bool retreat = false;
        uint random = getRandom(100).add(1);
        uint rand = 0;
        if(random == 1) {
            rand = 30;
        } else if(random == 2) {
            rand = 35;
        } else if (random > 2 && random <= 52){
            rand = 49;
        } else if(random > 52 && random <= 92){
            rand = 51;
        } else if(random > 92 && random <= 95){
            rand = 60;
        } else if(random > 95 && random <= 97){
            rand = 65;
        } else if(random > 97 && random <= 99){
            rand = 70;
        } else if(random == 100){
            rand = 120;
        }
        uint256 dayLocked = _dailyInvest.mul(45).div(100);
        uint256 releaseLocked = calcRelease();
        if(dayLocked < releaseLocked.mul(rand).div(10000)) {
            rand = 30;
        }
        if(_staticPool < releaseLocked.mul(rand).div(10000)) {
            rand = 0;
            retreat = true;
        }
        _staticPool = _staticPool.sub(releaseLocked.mul(rand).div(10000));
        lockedRound.push(rand);

        emit logRandom(rand, now);
        return retreat;
    }

    function calcRelease() public view returns(uint256) {
        uint256 totalRelease = 0;
        for(uint i=0; i<allAddress.length; i++){
            Player memory player = allPlayers[allAddress[i]];
            if(player.invest == 0) {
                continue;
            }
            uint256 bonus = 0;
            uint256 playerBonus = 0;
            bool outFlag;
            (bonus, playerBonus, outFlag) = calcBonus(player.self);
            if(!outFlag) {
                totalRelease = totalRelease.add(player.invest);
            }
        }
        return totalRelease;
    }

    function calcGlory() internal {
        // calc too hard for one time
        if(now.sub(_gloryTime).div(20 hours) < 1) return;
        _gloryTime = now;
        uint256[] memory achievements = new uint256[](allAddress.length);
        for(uint i=allAddress.length-1; i>0; i--) {
            Player memory player = allPlayers[allAddress[i]];
            uint256 selfAchieve = achievements[player.index];
            selfAchieve = selfAchieve.add(player.invest);
            if(player.parent == ZERO_ADDR) {
                continue;
            }
            Player memory parent = allPlayers[player.parent];
            achievements[parent.index] = achievements[parent.index].add(selfAchieve);
        }
        delete addressV1;
        delete addressV2;
        delete addressV3;
        delete addressV4;
        delete addressV5;
        for(uint i=0; i<allAddress.length; i++) {
            Player memory player = allPlayers[allAddress[i]];
            if(player.self == ZERO_ADDR || player.sons < 2 || achievements[player.index] < 300 ether){
                continue;
            }
            uint256 maxAchieve = 0;
            uint256 minAchieve = 0;
            for(uint j=i; j<allAddress.length; j++) {
                Player memory son = allPlayers[allAddress[j]];
                if(son.parent == player.self && maxAchieve < (achievements[son.index].add(son.invest))) {
                    maxAchieve = achievements[son.index].add(son.invest);
                }
            }
            minAchieve = achievements[player.index].sub(maxAchieve).add(player.invest);

            if(maxAchieve >= 2000 ether && minAchieve >= 4000 ether) {
                addressV5.push(player.self);
                continue;
            }
            if(maxAchieve >= 1000 ether && minAchieve >= 2000 ether) {
                addressV4.push(player.self);
                continue;
            }
            if(maxAchieve >= 500 ether && minAchieve >= 1000 ether) {
                addressV3.push(player.self);
                continue;
            }
            if(maxAchieve >= 200 ether && minAchieve >= 400 ether) {
                addressV2.push(player.self);
                continue;
            }
            if(maxAchieve >= 100 ether && minAchieve >= 200 ether) {
                addressV1.push(player.self);
                continue;
            }
        }
        uint256 bonusV1 = 0;
        uint256 bonusV2 = 0;
        uint256 bonusV3 = 0;
        uint256 bonusV4 = 0;
        uint256 bonusV5 = 0;
        if((addressV1.length + addressV2.length + addressV3.length + addressV4.length + addressV5.length) >0) {
            bonusV1 = _dailyInvest.div(25).div(addressV1.length + addressV2.length + addressV3.length + addressV4.length + addressV5.length);
            for(uint i=0; i<addressV1.length; i++) {
                Player memory player = allPlayers[addressV1[i]];
                investBonus(player.self, bonusV1, true, 0);
            }
        }
        if((addressV2.length + addressV3.length + addressV4.length + addressV5.length) >0) {
            bonusV2 = _dailyInvest.mul(3).div(100).div(addressV2.length + addressV3.length + addressV4.length + addressV5.length).add(bonusV1);
            for(uint i=0; i<addressV2.length; i++) {
                Player memory player = allPlayers[addressV2[i]];
                investBonus(player.self, bonusV2, true, 0);

            }
        }
        if((addressV3.length + addressV4.length + addressV5.length) >0) {
            bonusV3 = _dailyInvest.div(50).div(addressV3.length + addressV4.length + addressV5.length).add(bonusV2);
            for(uint i=0; i<addressV3.length; i++) {
                Player memory player = allPlayers[addressV3[i]];
                investBonus(player.self, bonusV3, true, 0);
            }
        }
        if((addressV4.length + addressV5.length) >0) {
            bonusV4 = _dailyInvest.div(50).div(addressV4.length + addressV5.length).add(bonusV3);
            for(uint i=0; i<addressV4.length; i++) {
                Player memory player = allPlayers[addressV4[i]];
                investBonus(player.self, bonusV4, true, 0);
            }
        }
        if(addressV5.length >0) {
            bonusV5 = _dailyInvest.div(100).div(addressV5.length).add(bonusV4);
            for(uint i=0; i<addressV5.length; i++) {
                Player memory player = allPlayers[addressV5[i]];
                investBonus(player.self, bonusV5, true, 0);
            }
        }
    }

    function lottery() internal {
        uint luckNum = dailyPlayers.length;
        if (luckNum >= 10) {
            luckNum = 10;
        }
        address[] memory luckyDogs = new address[](luckNum);
        uint[] memory luckyAmounts = new uint[](luckNum);
        if (luckNum <= 10) {
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
        uint256 lotteryAmount = 0;
        uint256 luckyPool = _dailyInvest.div(100);
        for(uint i=0; i<luckNum; i++){
            lotteryAmount = luckyAmounts[i].mul(luckyPool).div(totalRandom);
            investBonus(luckyDogs[i], lotteryAmount, false ,0);
            emit logLucky(luckyDogs[i], lotteryAmount, now, 1);
        }
    }

    function wLuckyDog(uint dayAmount) public view returns(address,uint256) {
        uint256[] memory achievements = new uint256[](allAddress.length);
        uint weekround = lockedRound.length-dayAmount;
        uint256 maxAchieve = 0;
        address targetAddress = ZERO_ADDR;
        uint256 luckyAmount = 0;
        for(uint i=investCount-1; i>0; i--) {
            if(investments[i].round < weekround) {
                break;
            }
            if(investments[i].round == lockedRound.length) {
                continue;
            }
            address selfAddr = investments[i].self;
            Player memory player = allPlayers[selfAddr];
            uint256 selfAchieve = achievements[player.index].add(investments[i].amount);
            if(selfAchieve>=maxAchieve) {
                targetAddress = selfAddr;
                maxAchieve = selfAchieve;
            }
            luckyAmount = luckyAmount.add(investments[i].amount.div(100));
        }
        return (targetAddress,luckyAmount);
    }

    function mLuckyDog(uint dayAmount) public view returns(address,uint256) {
        uint256[] memory sons = new uint256[](allAddress.length);
        uint monthlyRound = lockedRound.length-dayAmount;
        uint256 max = 0;
        address targetAddress = ZERO_ADDR;
        uint256 luckyAmount = 0;
        for(uint i=investCount-1; i>0; i--) {
            if(investments[i].round < monthlyRound) {
                break;
            }
            if(investments[i].round == lockedRound.length) {
                continue;
            }
            luckyAmount = luckyAmount.add(investments[i].amount.div(100));
            if(!investments[i].firstFlag) {
                continue;
            }
            Player memory player = allPlayers[investments[i].self];
            Player memory parent = allPlayers[player.parent];
            sons[parent.index] = sons[parent.index].add(1);

            if(sons[parent.index]>=max) {
                targetAddress = parent.self;
                max = sons[parent.index];
            }
        }
        return (targetAddress,luckyAmount);
    }


    function wWinner(uint gaps) onlyAdmin() public {
        (address weeklyWinner, uint256 weeklyAmount) = wLuckyDog(gaps);
        investBonus(weeklyWinner, weeklyAmount, false ,0);
        emit logLucky(weeklyWinner, weeklyAmount, now, 2);
    }


    function mWinner(uint gaps) onlyAdmin() public {
        (address monthlyWinner, uint256 monthlyAmount) = mLuckyDog(gaps);
        investBonus(monthlyWinner, monthlyAmount, false ,0);
        emit logLucky(monthlyWinner, monthlyAmount, now, 3);
    }


    // fomo
    function fomo() internal {
        uint256 amount = 0;
        for(uint i=investCount-1; i>0; i--) {
            if(_safePool<=0) {
                if(now.sub(_endTime).div(1 days)>5) {
                    _safeIndex = i+2;
                    _endTime = now;
                    _active = false;
                }
                break;
            }
            if(i == investCount-1) {
                amount = _safePool.div(5);
                investBonus(investments[i].self, amount, false, 0);
            } else {
                amount = investments[i].amount;
                if(amount > _safePool) {
                    amount = _safePool;
                }
            }
            _safePool = _safePool.sub(amount);
        }
    }

    function futureGame() public onlyAdmin() {
        bool retreatFlag = saveRound();
        if(retreatFlag) {
            fomo();
            if(now.sub(_endTime).div(1 days) >3) {
                msg.sender.transfer(address(this).balance);
            }
            return ;
        }
        fund();
        lottery();
        // calc too hard for one time.
        calcGlory();
        _dailyInvest = 0;
        delete dailyPlayers;
    }

    // calc too hard for one time
    function awardToGlory() public onlyAdmin() {
        calcGlory();
    }

    function fund() internal {
        address payable fundAddr = address(0xE6369df7A8a9A4d0bD8Da06b2E10303AB083FD83);
        if(_dailyInvest > 0) {
            fundAddr.transfer(_dailyInvest.div(10));
        }
    }


    function querySafety(address target) public view returns(uint256) {
        uint256 amount = 0;
        for (uint i = investCount-2; i >= _safeIndex; i--){
            if(investments[i].self == target) {
                amount = amount.add(investments[i].amount);
            }
        }
        return amount;
    }

    function withdraw() public {
        Player storage user = allPlayers[msg.sender];
        uint256 totalBonus = 0;
        uint256 withdrawBonus = 0;
        bool outFlag;
        (totalBonus, withdrawBonus, outFlag) = calcBonus(user.self);

        uint256 safety = 0;
        if(!_active && user.invest>0) {
            safety = querySafety(msg.sender);
            user.invest = 0;
        }
        
        if(outFlag) {
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


    function investBonus(address targetAddr, uint256 wwin, bool totalFlag, uint addson)
    internal {
        if(targetAddr == ZERO_ADDR || allPlayers[targetAddr].invest == 0 || wwin == 0) return;
        Player storage target = allPlayers[targetAddr];
        target.bonus = target.bonus.add(wwin);
        if(addson != 0) target.sons = target.sons+1;
        if(totalFlag) target.totalBonus = target.totalBonus.add(wwin);
    }

    function isStart() public view returns(bool) {
        return _startTime != 0 && now > _startTime;
    }

    function userInfo(address payable target)
    public view returns (address, address, address, uint256, uint256, uint256, uint, uint){
        Player memory self = allPlayers[target];
        Player memory parent = allPlayers[self.parent];
        Player memory grand = allPlayers[parent.parent];
        Player memory great = allPlayers[grand.parent];
        return (parent.self, grand.self, great.self,
        self.bonus, self.totalBonus, self.invest, self.sons, self.round);
    }


    function future(address player, address parent, uint256 amount)
    public payable {
        // require game is not start. 
        require(!isStart(), "Game Not Start Limit");
        require(player == msg.sender, "only limit");
        Player storage self = allPlayers[player];
        if(self.index == 0){
            return;
        }else{
            investments[investCount] = Investment(msg.sender,msg.value,now,lockedRound.length-1,false);
            self.invest = amount;
            self.parent = parent;
            investCount=investCount.add(1);
        }
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
}