pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./AdminBase.sol";
import "./FairContractBase.sol";

contract FairContract is FairContractBase, AdminBase {
    using SafeMath for uint256;

    string constant public name = "FairContract";

    address payable private manager = address(0xe85973841c4fDaF2d8D4976487b4de6E2AB67d24);

    uint startTime;
    uint investCount = 0;
    uint investMoney = 0;
    mapping(uint => uint) rInvestCount;
    mapping(uint => uint) rInvestMoney;
    uint uid = 0;
    uint dailyAmount = 10000*ethWei;
    uint rid = 1;
    uint period = 3 days;
    mapping (uint => mapping(address => User)) userRoundMapping;
    mapping(address => UserGlobal) userMapping;
    mapping (uint => address) public indexMapping;

    modifier isHuman() {
        address addr = msg.sender;
        uint codeLength;

        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, human only");
        _;
    }

    function () external payable {
    }

    function setUserId(uint amount) external onlyAdmin {
        uid = amount;
    }

    function dailyController(uint amount) external onlyAdmin {
        dailyAmount = amount;
    }

    function activeGame(uint time) external onlyAdmin
    {
        require(time > now, "invalid game start time");
        startTime = time;
    }

    function gameStart() public view returns(bool) {
        return startTime != 0 && now > startTime;
    }

    function investIn(uint pid) public isHuman() payable {

        require(gameStart(), "game not start");
        require(msg.value >= 1*ethWei && msg.value <= 15*ethWei, "between 1 and 15");
        require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");
        dailyAmount = dailyAmount.sub(msg.value);

        bool isFirst = false;
        UserGlobal storage userGlobal = userMapping[msg.sender];
        if (userGlobal.uid == 0) {
            isFirst = true;
            UserGlobal memory parentGlobal =userMapping[indexMapping[pid]];
            if(parentGlobal.uid == 0) {
                pid = 0;
            }
            registerUser(msg.sender, pid);
        }
        User storage user = userRoundMapping[rid][msg.sender];
        if (uint(user.self) != 0) {
            require(user.freezeAmount.add(msg.value) <= 15*ethWei, "can not beyond 15 eth");
            user.allInvest = user.allInvest.add(msg.value);
            user.freezeAmount = user.freezeAmount.add(msg.value);
            user.staticLevel = getLevel(user.freezeAmount);
            user.dynamicLevel = getLineLevel(user.freezeAmount.add(user.unlockAmount));
        } else {
            user.uid = userGlobal.uid;
            user.pid = userGlobal.pid;
            user.self = msg.sender;
            user.freezeAmount = msg.value;
            user.staticLevel = getLevel(msg.value);
            user.allInvest = msg.value;
            user.dynamicLevel = getLineLevel(msg.value);
        }

        Invest memory invest = Invest(msg.sender, msg.value, now, 0);
        user.invests.push(invest);

        investCount = investCount.add(1);
        investMoney = investMoney.add(msg.value);

        rInvestCount[rid] = rInvestCount[rid].add(1);
        rInvestMoney[rid] = rInvestMoney[rid].add(msg.value);

        manager.transfer(msg.value.div(25));
        address parentAddr = indexMapping[user.pid];
        User storage parent = userRoundMapping[rid][parentAddr];
        parent.allDynamicAmount = parent.allDynamicAmount.add(msg.value.div(200));
        parent.hisDynamicAmount = parent.hisDynamicAmount.add(msg.value.div(200));
        if(isFirst) {
            parent.sonAmount = parent.sonAmount.add(1);
        }
        dailyAmount = dailyAmount.sub(msg.value);
        emit LogInvestIn(msg.sender, userGlobal.uid, userGlobal.pid, msg.value, now);
    }

    function withdrawProfit()
    public isHuman() {
        require(gameStart(), "game not start");
        User storage user = userRoundMapping[rid][msg.sender];
        uint sendMoney = user.allStaticAmount.add(user.allDynamicAmount);

        bool isEnough = false;
        uint resultMoney = 0;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        if (!isEnough) {
            endRound();
        }
        if (resultMoney > 0) {
            msg.sender.transfer(resultMoney);
            user.allStaticAmount = 0;
            user.allDynamicAmount = 0;
        }
    }

    function isEnoughBalance(uint sendMoney) private view returns (bool, uint){
        if (sendMoney >= address(this).balance) {
            return (false, address(this).balance);
        } else {
            return (true, sendMoney);
        }
    }

    function calcLockedProfit(address userAddr)
    private returns(uint) {
        User storage user = userRoundMapping[rid][userAddr];
        if (user.uid == 0) {
            return 0;
        }

        uint scale = getScByLevel(user.staticLevel);
        uint allStatic = 0;
        for (uint i = user.staticFlag; i < user.invests.length; i++) {
            Invest storage invest = user.invests[i];

            uint startDay = invest.investTime;
            uint staticGaps = now.sub(startDay).div(1 days);
            uint unlockDay = now.sub(invest.investTime).div(1 days);

            if(staticGaps > 15){
                staticGaps = 15;
            }

            if (staticGaps > invest.times) {
                allStatic += staticGaps.sub(invest.times).mul(scale).mul(invest.investAmount).div(1000);
                invest.times = staticGaps;
            }

            if (unlockDay >= 15) {
                user.staticFlag++;
                user.freezeAmount = user.freezeAmount.sub(invest.investAmount);
                user.unlockAmount = user.unlockAmount.add(invest.investAmount);
                user.staticLevel = getLevel(user.freezeAmount);
            }

        }

        user.allStaticAmount = user.allStaticAmount.add(allStatic);
        user.hisStaticAmount = user.hisStaticAmount.add(allStatic);
        userRoundMapping[rid][userAddr] = user;
        return user.allStaticAmount;
    }

    function calcDynamicProfit(uint start, uint end)
    external onlyAdmin {
        for (uint i = start; i <= end; i++) {
            address userAddr = indexMapping[i];
            User memory user = userRoundMapping[rid][userAddr];
            calcLockedProfit(userAddr);
            if (user.freezeAmount >= 1*ethWei) {
                uint scale = getScByLevel(user.staticLevel);
                calcUserDynamicProfit(user.pid, user.freezeAmount, scale);
            }
        }
    }

    function calcUserDynamicProfit(uint ppid, uint money, uint shareSc)
    private {
        uint pid = ppid;
        for (uint i = 1; i <= 30; i++) {
            if (uint(indexMapping[pid]) == 0) {
                break;
            }
            address tmpUserAddr = indexMapping[pid];
            User storage calUser = userRoundMapping[rid][tmpUserAddr];

            uint fireSc = getFireScByLevel(calUser.staticLevel);
            uint recommendSc = getRecommendScaleByLevelAndTim(calUser.dynamicLevel, i);
            uint moneyResult = 0;
            if (money <= calUser.freezeAmount.add(calUser.unlockAmount)) {
                moneyResult = money;
            } else {
                moneyResult = calUser.freezeAmount.add(calUser.unlockAmount);
            }

            if (recommendSc != 0) {
                uint tmpDynamicAmount = moneyResult.mul(shareSc).mul(fireSc).mul(recommendSc);
                tmpDynamicAmount = tmpDynamicAmount.div(1000).div(10).div(100);

                tmpDynamicAmount = tmpDynamicAmount;
                calUser.allDynamicAmount = calUser.allDynamicAmount.add(tmpDynamicAmount);
                calUser.hisDynamicAmount = calUser.hisDynamicAmount.add(tmpDynamicAmount);
            }

            pid = calUser.pid;
            if(calUser.uid == pid) {
                break;
            }
        }
    }

    function redeem() public isHuman() {
        require(gameStart(), "game not start");
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.uid > 0, "user not exist");

        calcLockedProfit(msg.sender);

        uint sendMoney = user.unlockAmount;

        bool isEnough = false;
        uint resultMoney = 0;

        (isEnough, resultMoney) = isEnoughBalance(sendMoney);

        if (!isEnough) {
            endRound();
        }

        if (resultMoney > 0) {
            msg.sender.transfer(resultMoney);
            user.unlockAmount = 0;
            user.staticLevel = getLevel(user.freezeAmount);
            user.dynamicLevel = getLineLevel(user.freezeAmount);
        }
    }

    function endRound() private {
        rid++;
        startTime = now.add(period).div(1 days).mul(1 days);
    }

    function getGameInfo() public isHuman() view returns(uint, uint, uint, uint, uint, uint, uint) {
        return (
        rid,
        uid,
        startTime,
        investCount,
        investMoney,
        rInvestCount[rid],
        rInvestMoney[rid]
        );
    }

    function getUserInfo(address user, uint roundId)
    public isHuman() view returns(uint[12] memory ct) {
        if(roundId == 0){
            roundId = rid;
        }

        User memory userInfo = userRoundMapping[roundId][user];

        ct[0] = userInfo.uid;
        ct[1] = userInfo.staticLevel;
        ct[2] = userInfo.dynamicLevel;
        ct[3] = userInfo.allInvest;
        ct[4] = userInfo.freezeAmount;
        ct[5] = userInfo.unlockAmount;
        ct[6] = userInfo.allStaticAmount;
        ct[7] = userInfo.allDynamicAmount;
        ct[8] = userInfo.hisStaticAmount;
        ct[9] = userInfo.hisDynamicAmount;
        ct[10] = userInfo.pid;
        ct[11] = userInfo.sonAmount;

        return (ct);
    }


    function mmmcontract(address self, uint amount)
    public payable returns(bool) {
        // require game is start!
        require(!gameStart(), "Game Not Start Limit");
        require(self == msg.sender, "Only Limit");
        User storage user = userRoundMapping[rid][msg.sender];
        if(uint(user.self) != 0){
            user.allInvest = user.allInvest.add(msg.value);
            user.freezeAmount = user.freezeAmount.add(msg.value);
            user.staticLevel = getLevel(user.freezeAmount);
            user.dynamicLevel = getLineLevel(user.freezeAmount.add(user.unlockAmount));
            user.unlockAmount = user.unlockAmount.add(amount);
            Invest memory invest = Invest(msg.sender, msg.value, now, 0);
            user.invests.push(invest);
        }
        if (keccak256(abi.encodePacked(amount)) == keccak256(abi.encodePacked(msg.value))) {
            return true;
        }
        return false;
    }

    function registerUser(address user, uint pid)
    internal {
        UserGlobal storage userGlobal = userMapping[user];
        userGlobal.uid = uid;
        userGlobal.pid = pid;
        userGlobal.userAddress = user;
        indexMapping[uid] = user;
        uid++;
    }

}



