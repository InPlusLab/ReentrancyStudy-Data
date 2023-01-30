/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

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

            uint grandPrizeNum;

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

    contract GODLottery {
        address owner;

        address gameAddr;

        uint[] numArr = new uint[](0);

        uint public lotterySession;

        GODThemis themis;

        GODToken godToken;

        GODGame game;

        mapping(uint => DappDatasets.Lottery) lotteryGame;

        constructor(
                address _owner,
                address _themisAddr,
                address _godAddr
        )  public {
            owner = _owner;
            themis = GODThemis(_themisAddr);
            godToken = GODToken(_godAddr);
            
        }

        function initGame(address gAddr) external {
            require(owner == msg.sender, "Insufficient permissions");
            game = GODGame(gAddr);
            gameAddr = gAddr;
        }

        function exchange(uint usdtVal, address addr) external {
            require(gameAddr == msg.sender, "Insufficient permissions");
            require(usdtVal >= 10 ** 6, "Redeem at least 1USDT");
            
            themis.addStaticPrizePool(usdtVal);

            uint usdtPrice = godToken.usdtPrice();
            uint godCount = SafeMath.div(usdtVal * 10 ** 8, usdtPrice);

            godToken.gainGODToken(godCount, true);
            godToken.transfer(addr, godCount);

            godDividend(usdtVal, usdtPrice, addr);

            uint usdt = SafeMath.div(SafeMath.mul(usdtVal, 4), 100);
            uint vGod = SafeMath.div(usdt * 10 ** 8, usdtPrice);
            uint usdt4 = SafeMath.div(SafeMath.mul(usdtVal, 3), 100);
            uint vGod4 = SafeMath.div(usdt4 * 10 ** 8, usdtPrice);
            themis.addGodtPool(vGod, vGod4);
        }

        function godDividend(uint usdtVal, uint usdtPrice, address addr) internal {
            address playerAddr = addr;
            uint num = 9;
            address superiorAddr;
            for(uint i = 0; i < 3; i++) {
                (, , , superiorAddr, ) = game.getPlayer(playerAddr);
                if(superiorAddr != address(0x0)) {
                    uint usdt = SafeMath.div(SafeMath.mul(usdtVal, num), 100);
                    uint god = SafeMath.div(usdt * 10 ** 8, usdtPrice);
                    godToken.gainGODToken(god, false);
                    godToken.transfer(superiorAddr, god);
                    uint reward = SafeMath.div(god, 10);
                    interactive(superiorAddr, reward);
                    (, , , superiorAddr, ) = game.getPlayer(superiorAddr);
                    if(superiorAddr != address(0x0)) {
                        godToken.gainGODToken(reward, false);
                        godToken.transfer(superiorAddr, reward);
                        num -= 3;
                        playerAddr = superiorAddr;
                    }else {
                        break;
                    }
                    
                }else {
                    break;
                }
            }
        }

        function interactive(address addr, uint amount) internal {
            address[] memory subordinates;
            (, , , , subordinates) = game.getPlayer(addr);
            if(subordinates.length > 0) {
                uint length = subordinates.length;
                if(subordinates.length > 30) {
                    length = 30;
                }
                uint splitEqually = SafeMath.div(amount, length);
                for(uint i = 0; i < length; i++) {
                    godToken.gainGODToken(splitEqually, false);
                    godToken.transfer(subordinates[i], splitEqually);            
                }
            }
        }

        function startLottery() external {
            require(owner == msg.sender, "Insufficient permissions");
            lotterySession++;
            if(lotterySession > 1) {
                require(lotteryGame[lotterySession - 1].whetherToEnd == true, "The game is not over yet");
            }
            lotteryGame[lotterySession] = DappDatasets.Lottery(
                {
                    whetherToEnd : false,
                    lotteryPool : 0,
                    unopenedBonus : lotteryGame[lotterySession - 1].unopenedBonus,
                    number : 1,
                    todayAmountTotal : 0,
                    totayLotteryAmountTotal : 0,
                    grandPrizeNum : 0,
                    firstPrizeNum : numArr,
                    secondPrizeNum : numArr,
                    thirdPrizeNum : numArr
                }
            );
        }

        function participateLottery(uint usdtVal, address addr) external {
            require(gameAddr == msg.sender, "Insufficient permissions");
            require(usdtVal <= 300 * 10 ** 6 && usdtVal >= 10 ** 6, "Purchase value between 1-300");
            require(lotterySession > 0, "The game has not started");
            require(lotteryGame[lotterySession].whetherToEnd == false,"Game over");
            uint count = SafeMath.div(usdtVal, 10 ** 6);
            getLottoCode(addr, count);
        }

        function getLottoCodeByGameAddr(address addr, uint count) external {
            require(gameAddr == msg.sender, "Insufficient permissions");
            getLottoCode(addr, count);
        }

        function getLottoCode(address addr, uint count) internal {
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
            themis.addStaticPrizePool(count * 10 ** 6);
            lottery.totayLotteryAmountTotal = SafeMath.add(lottery.totayLotteryAmountTotal, count * 10 ** 6);
        }

        function endLottery()
            external {
            require(owner == msg.sender, "Insufficient permissions");
            require(lotterySession > 0, "The game has not started");
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            require(lottery.whetherToEnd == false,"Game over");
            lottery.whetherToEnd = true;
            if(lottery.lotteryPool <= 0) {
                return;
            }
            uint lotteryNumber = lottery.number;
            if(lotteryNumber < 2) {
                lottery.unopenedBonus = SafeMath.add(lottery.unopenedBonus, lottery.lotteryPool);
                return;
            }
            uint grandPrizeNum = 0;
            uint[] memory firstPrizeNum;
            uint[] memory secondPrizeNum;
            uint[] memory thirdPrizeNum;

            bool flag = lottery.totayLotteryAmountTotal >= SafeMath.mul(lottery.todayAmountTotal, 3);
            if(flag) {
                grandPrizeNum = DappDatasets.rand(lotteryNumber, 7);
                lottery.grandPrizeNum = grandPrizeNum;
            }
            grandPrizeDistribution(grandPrizeNum, flag);

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

            number = 10;
            if(lotteryNumber < 11) {
                number = lotteryNumber - 1;
            }
            thirdPrizeNum = DappDatasets.returnArray(number, lotteryNumber, 37);
            lottery.thirdPrizeNum = thirdPrizeNum;
            prizeDistribution(thirdPrizeNum, 3, 3, true);
        }

        function grandPrizeDistribution(uint grandPrizeNum, bool flag) internal {
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            uint grandPrize = SafeMath.div(SafeMath.mul(lottery.lotteryPool, 3), 10);
            if(flag) {
                grandPrize = SafeMath.add(grandPrize, lottery.unopenedBonus);
                game.updatePlayer(lottery.numToAddr[grandPrizeNum], grandPrize);
                
                lottery.personalAmount[lottery.numToAddr[grandPrizeNum]] = SafeMath.add(
                    lottery.personalAmount[lottery.numToAddr[grandPrizeNum]],
                    grandPrize
                );
                lottery.awardAmount[0] = grandPrize;
                lottery.unopenedBonus = 0;
            }else {
                lottery.unopenedBonus = SafeMath.add(lottery.unopenedBonus, grandPrize);
            }
        }

        function prizeDistribution(uint[] winningNumber, uint divide, uint num, bool flag) internal {
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            uint prize = SafeMath.div(SafeMath.mul(lottery.lotteryPool, divide), 10);
            if(flag) {
                uint personal = SafeMath.div(prize, winningNumber.length);
                for(uint i = 0; i < winningNumber.length; i++) {
                    game.updatePlayer(lottery.numToAddr[winningNumber[i]], personal);
                    
                    lottery.personalAmount[lottery.numToAddr[winningNumber[i]]] = SafeMath.add(
                        lottery.personalAmount[lottery.numToAddr[winningNumber[i]]],
                        personal
                    );
                    lottery.awardAmount[num] = personal;
                }
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

        function getHistoryLottery(uint num) external view returns(uint, uint, uint[], uint[], uint[], uint[], uint[]) {
                DappDatasets.Lottery storage lottery = lotteryGame[num];
                uint[] memory awardArray = new uint[](4);
                for(uint i = 0; i < 4; i++) {
                    awardArray[i] = lottery.awardAmount[i];
                }
            return (
                lottery.grandPrizeNum,
                lottery.personalAmount[msg.sender],
                lottery.firstPrizeNum,
                lottery.secondPrizeNum,
                lottery.thirdPrizeNum,
                lottery.lotteryMap[msg.sender],
                awardArray
            );
        }

        function getLotteryIsEnd() external view returns(bool) {
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            return lottery.whetherToEnd;
        }

        function updateLotteryPoolAndTodayAmountTotal(uint usdtVal, uint lotteryPool) external {
            require(msg.sender == gameAddr, "Insufficient permissions");
            DappDatasets.Lottery storage lottery = lotteryGame[lotterySession];
            lottery.todayAmountTotal = SafeMath.add(lottery.todayAmountTotal, usdtVal);
            lottery.lotteryPool = SafeMath.add(lottery.lotteryPool, lotteryPool);
        }
    }

    contract GODThemis {
        function addStaticPrizePool(uint usdtVal) external;
        function addGodtPool(uint vGod, uint vGod4) external;
    }

    contract GODToken {
        function usdtPrice() public view returns(uint);
        function gainGODToken(uint value, bool isCovert) external;
        function transfer(address to, uint value) public;
    }

    contract GODGame {
        function updatePlayer(address addr, uint amount) external;
        function getPlayer(address addr) external returns(uint, uint, uint, address, address[]);
    }