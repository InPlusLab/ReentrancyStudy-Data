/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

pragma solidity 0.4.25;

    library DappDatasets {

        struct Player {

            uint withdrawalAmount;

            uint wallet;

            uint fomoTotalRevenue;

            uint lotteryTotalRevenue;

            uint dynamicIncome;

            uint rechargeAmount;

            uint staticIncome;

            uint shareholderLevel;

            uint underUmbrellaLevel;

            uint subbordinateTotalPerformance;

            bool isExist;

            bool superior;

            address superiorAddr;

            address[] subordinates;
        }


        struct Fomo {

            bool whetherToEnd;

            uint endTime;

            uint fomoPrizePool;

            address[] participant;
        }

        struct Lottery {

            bool whetherToEnd;

            uint lotteryPool;

            uint unopenedBonus;

            uint number;

            uint todayAmountTotal;

            uint totayLotteryAmountTotal;

            uint[] grandPrizeNum;

            uint[] firstPrizeNum;

            uint[] secondPrizeNum;

            uint[] thirdPrizeNum;

            mapping(address => uint[]) lotteryMap;

            mapping(uint => address) numToAddr;

            mapping(address => uint) personalAmount;

            mapping(uint => uint) awardAmount;
        }


        function getNowTime() internal view returns(uint) {
            return now;
        }


        function rand(uint256 _length, uint num) internal view returns(uint256) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, now - num)));
            return random%_length;
        }

        function returnArray(uint len, uint range, uint number) internal view returns(uint[]) {
            uint[] memory numberArray = new uint[](len);
            uint i = 0;
            while(true) {
                number = number + 9;
                uint temp = rand(range, number);
                if(temp == 0) {
                    continue;
                }
                numberArray[i] = temp;
                i++;
                if(i == len) {
                    break;
                }
            }
            return numberArray;
        }
    }

pragma solidity 0.4.25;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.4.25;

    contract AWGame {

        address owner;

        address mainAddr;

        address[] temp = new address[](0);

        uint[] numArr = new uint[](0);

        uint depositBalance;

        uint fomoSession;

        uint lotterySession = 1;

        AWToken awToken;

        AWMain main;

        mapping(uint => DappDatasets.Fomo) fomoGame;

        mapping(uint => DappDatasets.Lottery) lotteryGame;

        constructor(
            address _owner,
            address _awAddr
        )  public {
            owner = _owner;
            awToken = AWToken(_awAddr);
            lotteryGame[lotterySession] = DappDatasets.Lottery(
                {
                    whetherToEnd : false,
                    lotteryPool : 0,
                    unopenedBonus : 0,
                    number : 1,
                    todayAmountTotal : 0,
                    totayLotteryAmountTotal : 0,
                    grandPrizeNum : numArr,
                    firstPrizeNum : numArr,
                    secondPrizeNum : numArr,
                    thirdPrizeNum : numArr
                }
            );
        }

        function init(address addr) external {
            require(owner == msg.sender, "Insufficient permissions");
            main = AWMain(addr);
            mainAddr = addr;
        }


        function redeemAW(uint usdtVal, uint usdtPrice, address addr) external {
            require(mainAddr == msg.sender, "Insufficient permissions");

            awPushStraightDividend(addr, usdtVal, usdtPrice);

            awShareHolderDividend(addr, usdtVal, usdtPrice);

            uint awCount = SafeMath.div(usdtVal * 10 ** 8, usdtPrice);

            awToken.gainAWToken(awCount, true);
            awToken.transfer(addr, awCount);
        }

        function awPushStraightDividend(address addr, uint usdtVal, uint usdtPrice) internal {
            address playerAddr = addr;
            uint num = 9;
            address superiorAddr;
            for(uint i = 0; i < 3; i++) {
                (, superiorAddr, ) = main.getPlayer(playerAddr);
                if(superiorAddr != address(0x0)) {
                    uint usdt = SafeMath.div(SafeMath.mul(usdtVal, num), 100);
                    uint aw = SafeMath.div(usdt * 10 ** 8, usdtPrice);
                    fosterInteraction(superiorAddr, aw);
                    playerAddr = superiorAddr;
                    num -= 3;
                }else {
                    break;
                }
            }
        }

        function fosterInteraction(address addr, uint amount) internal {

            awToken.gainAWToken(amount, false);
            awToken.transfer(addr, amount);

            uint num = SafeMath.div(amount, 10);

            address superiorAddr;
            address[] memory subordinates;
            (, superiorAddr, subordinates) = main.getPlayer(addr);
            if(subordinates.length > 0) {
                uint length = subordinates.length;
                if(subordinates.length > 30) {
                    length = 30;
                }
                uint splitEqually = SafeMath.div(num, length);
                for(uint i = 0; i < length; i++) {
                    awToken.gainAWToken(splitEqually, false);
                    awToken.transfer(subordinates[i], splitEqually);
                }
            }
            if(superiorAddr != address(0x0)) {
                awToken.gainAWToken(num, false);
                awToken.transfer(superiorAddr, num);
            }
        }


        function awShareHolderDividend(address addr, uint usdtVal, uint usdtPrice) internal {

            address playerAddr = addr;
            address superiorAddr;
            uint shareholderLevel;
            uint level = 1;
            uint shareholderAmount = SafeMath.div(
                SafeMath.div(SafeMath.mul(usdtVal * 10 ** 8, 3), 100),
                usdtPrice
            );
            for(uint j = 0; j < 50; j++) {
                if(level >= 1 && level <= 4) {
                    (shareholderLevel, superiorAddr, ) = main.getPlayer(playerAddr);
                    if(superiorAddr != address(0x0)) {
                        if(shareholderLevel >= level) {
                            uint servings = SafeMath.sub(shareholderLevel + 1, level);
                            fosterInteraction(superiorAddr, shareholderAmount * servings);
                            level = level + servings;
                        }
                        playerAddr = superiorAddr;
                    }else {
                        break;
                    }
                }else {
                    break;
                }
            }
        }

        function buyLotto(uint usdtVal, address addr) external {
            require(mainAddr == msg.sender, "Insufficient permissions");
            require(lotteryGame[lotterySession].whetherToEnd == false,"Game over");
            uint count = SafeMath.div(usdtVal, 10 ** 6);
            getLottoCode(addr, count);
        }

        function getLottoCode(address addr, uint count) internal {
            if(count == 0) {
                return;
            }
            
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            lottery.lotteryMap[addr].push(lottery.number);
            if(count > 1) {
                lottery.lotteryMap[addr].push(SafeMath.add(lottery.number, count - 1));
            }
            lottery.lotteryMap[addr].push(0);
            for(uint i = 0; i < count; i++) {
                lottery.numToAddr[lottery.number] = addr;
                lottery.number++;
            }
            lottery.totayLotteryAmountTotal = SafeMath.add(lottery.totayLotteryAmountTotal, count * 10 ** 6);
           
        }

        function atomicOperationLottery() external {
            require(owner == msg.sender, "Insufficient permissions");
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            lottery.whetherToEnd = true;
             uint lotteryNumber = lottery.number;
            if(lottery.lotteryPool > 0 && lotteryNumber > 1) {
                uint[] memory grandPrizeNum;
                uint[] memory firstPrizeNum;
                uint[] memory secondPrizeNum;
                uint[] memory thirdPrizeNum;

                bool flag = lottery.totayLotteryAmountTotal >= SafeMath.mul(lottery.todayAmountTotal, 3);
                if(flag) {
                    grandPrizeNum = DappDatasets.returnArray(1, lotteryNumber, 7);
                    lottery.grandPrizeNum = grandPrizeNum;
                }
                prizeDistribution(grandPrizeNum, 3, 0, flag);

                uint number = 2;
                flag = lottery.totayLotteryAmountTotal >= lottery.todayAmountTotal;
                if(flag) {
                    if(lotteryNumber < 3) {
                        number = lotteryNumber - 1;
                    }
                    firstPrizeNum = DappDatasets.returnArray(number, lotteryNumber, 17);
                    lottery.firstPrizeNum = firstPrizeNum;
                }
                prizeDistribution(firstPrizeNum, 2, 1, flag);

                number = 5;
                flag = lottery.totayLotteryAmountTotal >= SafeMath.div(SafeMath.mul(lottery.todayAmountTotal, 3), 10);
                if(flag) {
                    if(lotteryNumber < 6) {
                        number = lotteryNumber - 1;
                    }
                    secondPrizeNum = DappDatasets.returnArray(number, lotteryNumber, 27);
                    lottery.secondPrizeNum = secondPrizeNum;
                }
                prizeDistribution(secondPrizeNum, 2, 2, flag);

                number = 20;
                if(lotteryNumber < 21) {
                    number = lotteryNumber - 1;
                }
                thirdPrizeNum = DappDatasets.returnArray(number, lotteryNumber, 37);
                lottery.thirdPrizeNum = thirdPrizeNum;
                prizeDistribution(thirdPrizeNum, 3, 3, true);
            }else {
                lottery.unopenedBonus = SafeMath.add(lottery.unopenedBonus, lottery.lotteryPool);
            }

            lotterySession++;
            lotteryGame[lotterySession] = DappDatasets.Lottery(
                {
                    whetherToEnd : false,
                    lotteryPool : 0,
                    unopenedBonus : lotteryGame[lotterySession - 1].unopenedBonus,
                    number : 1,
                    todayAmountTotal : 0,
                    totayLotteryAmountTotal : 0,
                    grandPrizeNum : numArr,
                    firstPrizeNum : numArr,
                    secondPrizeNum : numArr,
                    thirdPrizeNum : numArr
                }
            );
        }

        function prizeDistribution(uint[] winningNumber, uint divide, uint num, bool flag) internal {
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            uint prize = SafeMath.div(SafeMath.mul(lottery.lotteryPool, divide), 10);
            if(flag) {
                uint personal = SafeMath.div(prize, winningNumber.length);
                if(num == 0) {
                    personal = SafeMath.add(personal, lottery.unopenedBonus);
                    lottery.unopenedBonus = 0;
                }
                for(uint i = 0; i < winningNumber.length; i++) {
                    main.updateRevenue(lottery.numToAddr[winningNumber[i]], personal, false);
                    
                    lottery.personalAmount[lottery.numToAddr[winningNumber[i]]] = SafeMath.add(
                        lottery.personalAmount[lottery.numToAddr[winningNumber[i]]],
                        personal
                    );
                }
                lottery.awardAmount[num] = personal;
            }else {
                lottery.unopenedBonus = SafeMath.add(lottery.unopenedBonus, prize);
            }
        }

        function getLotteryInfo() external view returns(uint session, uint pool, uint unopenedBonus, bool isEnd, uint[]) {
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            return (
                lotterySession,
                lottery.lotteryPool,
                lottery.unopenedBonus,
                lottery.whetherToEnd,
                lottery.lotteryMap[msg.sender]
                );
        }

        function getHistoryLottery(uint num) external view returns(uint, uint[], uint[], uint[], uint[], uint[], uint[]) {
            DappDatasets.Lottery storage lottery = lotteryGame[num];
            uint[] memory awardArray = new uint[](4);
            for(uint i = 0; i < 4; i++) {
                awardArray[i] = lottery.awardAmount[i];
            }
            return (
                lottery.personalAmount[msg.sender],
                lottery.grandPrizeNum,
                lottery.firstPrizeNum,
                lottery.secondPrizeNum,
                lottery.thirdPrizeNum,
                lottery.lotteryMap[msg.sender],
                awardArray
            );
        }


        function getFOMOInfo() external view returns(uint Session, uint nowTime, uint endTime, uint prizePool, bool isEnd) {
            DappDatasets.Fomo memory fomo = fomoGame[fomoSession];
            return (fomoSession, DappDatasets.getNowTime(), fomo.endTime, fomo.fomoPrizePool, fomo.whetherToEnd);
        }


        function startFomoGame() external {
            require(owner == msg.sender, "Insufficient permissions");
            fomoSession++;
            if(fomoSession > 1) {
                require(fomoGame[fomoSession - 1].whetherToEnd == true, "The game is not over yet");
            }
            fomoGame[fomoSession] = DappDatasets.Fomo(
                {
                    whetherToEnd : false,
                    endTime : now + 24 * 60 * 60,
                    fomoPrizePool : 0,
                    participant : temp
                }
            );
        }


        function deposit(uint usdtVal, address addr) external returns(uint) {
            require(mainAddr == msg.sender, "Insufficient permissions");
            require(fomoSession > 0, "fomo game has not started yet");
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            require(fomo.whetherToEnd == false,"fomo game has not started yet");

            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];

            depositBalance = usdtVal;

            uint needAw = awToken.calculationNeedAW(usdtVal);
            awToken.burn(addr, needAw);

            fomo.participant.push(addr);

            uint lotteryPool = SafeMath.div(usdtVal, 10);
            depositBalance = SafeMath.sub(depositBalance, lotteryPool);
            lottery.lotteryPool = SafeMath.add(lottery.lotteryPool, lotteryPool);
            lottery.todayAmountTotal = SafeMath.add(lottery.todayAmountTotal, usdtVal);

            fomoPenny(usdtVal, addr);

            fomoShareHolderDistribution(addr, usdtVal);

            uint amount = SafeMath.div(SafeMath.mul(usdtVal, 3), 100);

            depositBalance = SafeMath.sub(depositBalance, amount * 2);


            uint fomoPool = SafeMath.div(SafeMath.mul(usdtVal, 8), 100);
            depositBalance = SafeMath.sub(depositBalance, fomoPool);


            if(SafeMath.add(fomo.fomoPrizePool, fomoPool) > 2100 * 10 ** 4 * 10 ** 6 ) {
                if(fomo.fomoPrizePool < 2100 * 10 ** 4 * 10 ** 6) {
                    uint n = SafeMath.sub(2100 * 10 ** 4 * 10 ** 6, fomo.fomoPrizePool);
                    fomo.fomoPrizePool = SafeMath.add(fomo.fomoPrizePool, n);
                    uint issue = SafeMath.sub(fomoPool, n);
                    main.releaseStaticPoolAndV4(issue);
                }else {
                    main.releaseStaticPoolAndV4(fomoPool);
                }
            }else {
                fomo.fomoPrizePool = SafeMath.add(fomo.fomoPrizePool, fomoPool);
            }

            timeExtended(usdtVal);
            return depositBalance;
        }


        function timeExtended(uint usdtVal) internal {
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];

            uint count = SafeMath.div(usdtVal, SafeMath.mul(100, 10 ** 6));
            uint nowTime = DappDatasets.getNowTime();
            uint laveTime = SafeMath.sub(fomo.endTime, nowTime);
            uint day = 24 * 60 * 60;
            uint hour = 2 * 60 * 60;

            if(count > 0) {
                laveTime = SafeMath.add(laveTime, SafeMath.mul(hour, count));
                if(laveTime <= day) {
                   fomo.endTime = SafeMath.add(nowTime, laveTime);
               }else {
                   fomo.endTime = SafeMath.add(nowTime, day);
               }
            }
        }


        function fomoPenny(uint usdtVal, address addr) internal {
            address playerAddr = addr;
            address superiorAddr;

            uint num = 9;
            for(uint i = 0; i < 3; i++) {
                (, superiorAddr, ) = main.getPlayer(playerAddr);
                if(superiorAddr != address(0x0)) {
                    uint usdt = SafeMath.div(SafeMath.mul(usdtVal, num), 100);
                    depositBalance = SafeMath.sub(depositBalance, main.rewardDistribution(superiorAddr, usdt));
                    num -= 3;
                    playerAddr = superiorAddr;
                }else {
                    break;
                }
            }
        }


        function fomoShareHolderDistribution(address addr, uint usdtVal) internal {
            address playerAddr = addr;
            address superiorAddr;
            uint shareholderLevel;

            uint shareholderAmount = SafeMath.div(SafeMath.mul(usdtVal, 3), 100);
            uint level = 1;
            for(uint k = 0; k < 50; k++) {
                if(level >= 1 && level <= 4) {
                    (shareholderLevel, superiorAddr, ) = main.getPlayer(playerAddr);
                    if(superiorAddr != address(0x0)) {
                        if(shareholderLevel >= level) {
                            uint servings = SafeMath.sub(shareholderLevel + 1, level);
                            depositBalance = SafeMath.sub(depositBalance, main.rewardDistribution(superiorAddr, shareholderAmount * servings));
                            level = level + servings;
                        }
                        playerAddr = superiorAddr;
                    }else {
                        break;
                    }
                }else {
                    break;
                }
            }
        }

        function getFomoParticpantLength() external view returns(uint) {
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            return fomo.participant.length;
        }

        function endFomoGame(uint number, uint frequency, uint index) external {
            require(owner == msg.sender, "Insufficient permissions");
            require(fomoSession > 0, "fomo game has not started");
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            require(DappDatasets.getNowTime() >= fomo.endTime, "The game is not over");

            fomo.whetherToEnd = true;
            if(fomo.fomoPrizePool == 0) {
                return;
            }
            uint fomoPool = SafeMath.div(SafeMath.mul(fomo.fomoPrizePool, number), 10);

            uint length = frequency;
            if(fomo.participant.length < frequency) {
                length = fomo.participant.length;
            }
            uint personalAmount = SafeMath.div(fomoPool, length);
            uint num = 0;
            for(uint i = fomo.participant.length - index; i > 0; i--) {
                main.updateRevenue(fomo.participant[i - 1], personalAmount, true);
                num++;
                if(num == 100 || num == length) {
                    break;
                }
            }
        }
    }

    contract AWToken {
       function burn(address addr, uint value) public;
       function balanceOf(address who) external view returns (uint);
       function calculationNeedAW(uint usdtVal) external view returns(uint);
       function gainAWToken(uint value, bool isCovert) external;
       function transfer(address to, uint value) public;
    }

    contract AWMain {
        function rewardDistribution(address addr, uint amount) external returns(uint);
        function getPlayer(address addr) external view returns(uint, address, address[]);
        function releaseStaticPoolAndV4(uint usdtVal) external;
        function updateRevenue(address addr, uint amount, bool flag) external;
    }