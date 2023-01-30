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

    contract GODGame {

        address owner;

        address technologyAddr;

        address themisAddr;

        address lotteryAddr;

        address[] allPlayer;

        address[] temp = new address[](0);

        struct GlobalShareholder {

            address[] shareholdersV1;

            address[] shareholdersV2;

            address[] shareholdersV3;

            address[] shareholdersV4;
        }

        uint fomoSession;

        uint depositBalance;

        GODThemis themis;

        GODToken godToken;

        TetherToken tether;

        GODLottery lottery;

        mapping(uint => DappDatasets.Fomo) fomoGame;  

        mapping(address => DappDatasets.Player) playerMap;

        mapping(address => GlobalShareholder) globalShareholder;


        constructor(
                address _owner,
                address _tetherAddr,
                address _godAddr,
                address _themisAddr,
                address _lotteryAddr,
                address _technologyAddr
        )  public {
            owner = _owner;
            tether = TetherToken(_tetherAddr);
            godToken = GODToken(_godAddr);
            themis = GODThemis(_themisAddr);
            lotteryAddr = _lotteryAddr;
            lottery = GODLottery(_lotteryAddr);
            DappDatasets.Player memory player = DappDatasets.Player(
                {
                    withdrawalAmount : 0,
                    wallet : 0,
                    fomoTotalRevenue : 0,
                    lotteryTotalRevenue : 0,
                    dynamicIncome : 0,
                    rechargeAmount : 0,
                    staticIncome : 0,
                    shareholderLevel : 0,
                    underUmbrellaLevel : 0,
                    subbordinateTotalPerformance : 0,
                    isExist : true,
                    superior : false,
                    superiorAddr : address(0x0),
                    subordinates : temp
                }
            );
            playerMap[owner] = player;
            allPlayer.push(owner);
            technologyAddr = _technologyAddr;
            themisAddr = _themisAddr;
            if(owner != technologyAddr) {
                playerMap[technologyAddr] = player;
                allPlayer.push(technologyAddr);
            }
            globalShareholder[owner] = GlobalShareholder(
                {
                    shareholdersV1 : temp,
                    shareholdersV2 : temp,
                    shareholdersV3 : temp,
                    shareholdersV4 : temp
                }
            );
        }

        function() public payable {
            withdrawImpl(msg.sender);
        }

        function redeemGod(uint usdtVal, address superiorAddr) external {
            register(msg.sender, superiorAddr);
            lottery.exchange(usdtVal, msg.sender);
            tether.transferFrom(msg.sender, this, usdtVal);
        }

        function buyLotto(uint usdtVal, address superiorAddr) external {
            register(msg.sender, superiorAddr);
            lottery.participateLottery(usdtVal, msg.sender);
            tether.transferFrom(msg.sender, this, usdtVal);
        }

        function interactive(address addr, uint amount) internal {
            DappDatasets.Player storage player = playerMap[addr];
            if(player.subordinates.length > 0) {
                uint length = player.subordinates.length;
                if(player.subordinates.length > 30) {
                    length = 30;
                }
                uint splitEqually = SafeMath.div(amount, length);
                for(uint i = 0; i < length; i++) {
                    playerMap[player.subordinates[i]].wallet = SafeMath.add(
                        playerMap[player.subordinates[i]].wallet,
                        splitEqually
                    );
                    playerMap[player.subordinates[i]].dynamicIncome = SafeMath.add(
                        playerMap[player.subordinates[i]].dynamicIncome,
                        splitEqually
                    );
                }
            }
        }

        function withdrawImpl(address addr) internal {
            require(owner != addr, "admin no allow withdraw");
            require(playerMap[addr].wallet > 0, "Insufficient wallet balance");
            require(lottery.getLotteryIsEnd() == false,"Game over");

            uint number = 0;
            uint motionAndStaticAmount = SafeMath.add(playerMap[addr].staticIncome, playerMap[addr].dynamicIncome);
            uint withdrawableBalance = SafeMath.mul(playerMap[addr].rechargeAmount, 3);

            if(motionAndStaticAmount > withdrawableBalance) {
                number = SafeMath.sub(motionAndStaticAmount, withdrawableBalance);
            }
            uint amount = SafeMath.sub(playerMap[addr].wallet, number);
            uint value = amount;
            if(amount > 1000 * 10 ** 6) {
                value = 1000 * 10 ** 6;
            }
            playerMap[addr].wallet = SafeMath.sub(playerMap[addr].wallet, value);
            playerMap[addr].withdrawalAmount = SafeMath.add(playerMap[addr].withdrawalAmount, value);

            uint lotteryPool = SafeMath.div(value, 10);
            uint count = SafeMath.div(lotteryPool, 10 ** 6);
            lottery.getLottoCodeByGameAddr(addr, count);
            tether.transfer(addr, SafeMath.sub(value, count * 10 ** 6));
        }

        function withdraw() external {
            withdrawImpl(msg.sender);
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
                    endTime : now + 48 * 60 * 60,
                    fomoPrizePool : 0,
                    participant : temp
                }
            );
        }

        function participateFomo(uint usdtVal, address superiorAddr) external {
            require(usdtVal >= 10 ** 6, "Redeem at least 1USDT");
            require(fomoSession > 0, "fomo game has not started yet");
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            require(fomo.whetherToEnd == false,"fomo game has not started yet");
            require(lottery.lotterySession() > 0, "Big Lotto game has not started yet");
            require(lottery.getLotteryIsEnd() == false,"Big Lotto game has not started yet");
            register(msg.sender, superiorAddr);
            depositBalance = usdtVal;

            uint needGOD = godToken.calculationNeedGOD(usdtVal);
            godToken.burn(msg.sender, needGOD);

            fomo.participant.push(msg.sender);

            DappDatasets.Player storage player = playerMap[msg.sender];
            player.rechargeAmount = SafeMath.add(player.rechargeAmount, usdtVal);

            uint lotteryPool = SafeMath.div(usdtVal, 10);
            depositBalance = SafeMath.sub(depositBalance, lotteryPool);
            lottery.updateLotteryPoolAndTodayAmountTotal(usdtVal, lotteryPool);

            increasePerformance(msg.sender, usdtVal);

            fomoPenny(msg.sender, usdtVal);

            uint fomoPool = SafeMath.div(SafeMath.mul(usdtVal, 8), 100);
            depositBalance = SafeMath.sub(depositBalance, fomoPool);

            if(SafeMath.add(fomo.fomoPrizePool, fomoPool) > 2100 * 10 ** 4 * 10 ** 6 ) {
                if(fomo.fomoPrizePool < 2100 * 10 ** 4 * 10 ** 6) {
                    uint n = SafeMath.sub(2100 * 10 ** 4 * 10 ** 6, fomo.fomoPrizePool);
                    fomo.fomoPrizePool = SafeMath.add(fomo.fomoPrizePool, n);
                    uint issue = SafeMath.sub(fomoPool, n);
                    releaseStaticPoolAndV4(issue);
                }else {
                    releaseStaticPoolAndV4(fomoPool);
                }
            }else {
                fomo.fomoPrizePool = SafeMath.add(fomo.fomoPrizePool, fomoPool);
            }

            timeExtended(usdtVal);
            themis.addStaticTotalRechargeAndStaticPool(usdtVal, depositBalance);
            tether.transferFrom(msg.sender, this, usdtVal);
        }
		

        function timeExtended(uint usdtVal) internal {
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            uint count = SafeMath.div(usdtVal, SafeMath.mul(10, 10 ** 6));
            uint nowTime = DappDatasets.getNowTime();
            uint laveTime = SafeMath.sub(fomo.endTime, nowTime);
            uint day = 48 * 60 * 60;
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

        function fomoPenny(address addr, uint usdtVal) internal {
            DappDatasets.Player storage player = playerMap[addr];
            uint num = 9;
            for(uint i = 0; i < 3; i++) {
                if(player.superior) {
                    uint usdt = SafeMath.div(SafeMath.mul(usdtVal, num), 100);
                    playerMap[player.superiorAddr].wallet = SafeMath.add(
                        playerMap[player.superiorAddr].wallet,
                        usdt
                    );
                    playerMap[player.superiorAddr].dynamicIncome = SafeMath.add(
                        playerMap[player.superiorAddr].dynamicIncome,
                        usdt
                    );
                    depositBalance = SafeMath.sub(depositBalance, usdt);
                    uint reward = SafeMath.div(usdt, 10);
                    interactive(player.superiorAddr, reward);
                    if(playerMap[player.superiorAddr].superior) {
                        playerMap[playerMap[player.superiorAddr].superiorAddr].wallet = SafeMath.add(
                            playerMap[playerMap[player.superiorAddr].superiorAddr].wallet,
                            reward
                        );
                        playerMap[playerMap[player.superiorAddr].superiorAddr].dynamicIncome = SafeMath.add(
                            playerMap[playerMap[player.superiorAddr].superiorAddr].dynamicIncome,
                            reward
                        );
                    }else {
                        break;
                    }
                    num -= 3;
                    player = playerMap[player.superiorAddr];
                }else {
                    break;
                }
                
            }

            uint technicalRewards = SafeMath.div(SafeMath.mul(usdtVal, 3), 100);
            depositBalance = SafeMath.sub(depositBalance, technicalRewards);
            playerMap[technologyAddr].wallet = SafeMath.add(playerMap[technologyAddr].wallet, technicalRewards);

            uint vUsdt = SafeMath.div(SafeMath.mul(usdtVal, 4), 100);
            uint vUsdt4 = SafeMath.div(SafeMath.mul(usdtVal, 3), 100);
            depositBalance = SafeMath.sub(depositBalance, SafeMath.mul(vUsdt, 3));
            depositBalance = SafeMath.sub(depositBalance, vUsdt4);
            themis.addUsdtPool(vUsdt, vUsdt4);
        }


        function increasePerformance(address addr, uint usdtVal) internal {
            DappDatasets.Player storage player = playerMap[addr];
            uint length = 0;
            while(player.superior) {
                address tempAddr = player.superiorAddr;
                player = playerMap[player.superiorAddr];
                player.subbordinateTotalPerformance = SafeMath.add(player.subbordinateTotalPerformance, usdtVal);
                promotionMechanisms(tempAddr);
                length++;
                if(length == 50) {
                    break;
                }
            }
        }

        function promotionMechanisms(address addr) internal {
            DappDatasets.Player storage player = playerMap[addr];
            if(player.subbordinateTotalPerformance >= 10 * 10 ** 4 * 10 ** 6) {
                uint len = player.subordinates.length;
                if(player.subordinates.length > 30) {
                    len = 30;
                }
                for(uint i = 0; i < 4; i++) {
                    if(player.shareholderLevel == i) {
                        uint levelCount = 0;
                        for(uint j = 0; j < len; j++) {
                            if(i == 0) {
                                uint areaTotal = SafeMath.add(
                                            playerMap[player.subordinates[j]].subbordinateTotalPerformance,
                                            playerMap[player.subordinates[j]].rechargeAmount
                                );
                                if(areaTotal >= 3 * 10 ** 4 * 10 ** 6) {
                                    levelCount++;
                                }
                            }else {
                                if(playerMap[player.subordinates[j]].shareholderLevel >= i || playerMap[player.subordinates[j]].underUmbrellaLevel >= i) {
                                    levelCount++;
                                }
                            }

                            if(levelCount >= 2) {
                                player.shareholderLevel = i + 1;
                                if(i == 0) {
                                    globalShareholder[owner].shareholdersV1.push(addr);
                                }else if(i == 1) {
                                    globalShareholder[owner].shareholdersV2.push(addr);
                                }else if(i == 2) {
                                    globalShareholder[owner].shareholdersV3.push(addr);
                                }else if(i == 3) {
                                    globalShareholder[owner].shareholdersV4.push(addr);
                                }
                                
                                DappDatasets.Player storage tempPlayer = player;
                                uint count = 0;
                                while(tempPlayer.superior) {
                                    tempPlayer = playerMap[tempPlayer.superiorAddr];
                                    if(tempPlayer.underUmbrellaLevel < i + 1) {
                                        tempPlayer.underUmbrellaLevel = i + 1;
                                    }else {
                                        break;
                                    }
                                    count++;
                                    if(count == 49) {
                                        break;
                                    }
                                }
                                break;
                            }
                            
                        }
                    }
                }

            }
        }

        function releaseStaticPoolAndV4(uint usdtVal) internal {
            uint staticPool60 = SafeMath.div(SafeMath.mul(usdtVal, 6), 10);
            themis.addStaticPrizePool(staticPool60);

            if(globalShareholder[owner].shareholdersV4.length > 0) {
                uint length = globalShareholder[owner].shareholdersV4.length;
                if(globalShareholder[owner].shareholdersV4.length > 100) {
                    length = 100;
                }
                uint splitEqually = SafeMath.div(SafeMath.sub(usdtVal, staticPool60), length);
                for(uint i = 0; i < length; i++) {
                    playerMap[globalShareholder[owner].shareholdersV4[i]].wallet = SafeMath.add(
                        playerMap[globalShareholder[owner].shareholdersV4[i]].wallet,
                        splitEqually
                    );
                }
            }else{
				themis.addStaticPrizePool(SafeMath.sub(usdtVal, staticPool60));
			}

        }

        function register(address addr, address superiorAddr) internal{
            if(playerMap[addr].isExist == true) {
                return;
            }
            DappDatasets.Player memory player;
            if(superiorAddr == address(0x0) || playerMap[superiorAddr].isExist == false) {
                player = DappDatasets.Player(
                    {
                        withdrawalAmount : 0,
                        wallet : 0,
                        fomoTotalRevenue : 0,
                        lotteryTotalRevenue : 0,
                        dynamicIncome : 0,
                        rechargeAmount : 0,
                        staticIncome : 0,
                        shareholderLevel : 0,
                        underUmbrellaLevel : 0,
                        subbordinateTotalPerformance : 0,
                        isExist : true,
                        superior : false,
                        superiorAddr : address(0x0),
                        subordinates : temp
                    }
                );
                playerMap[addr] = player;
            }else {
                player = DappDatasets.Player(
                    {
                        withdrawalAmount : 0,
                        wallet : 0,
                        fomoTotalRevenue : 0,
                        lotteryTotalRevenue : 0,
                        dynamicIncome : 0,
                        rechargeAmount : 0,
                        staticIncome : 0,
                        shareholderLevel : 0,
                        underUmbrellaLevel : 0,
                        subbordinateTotalPerformance : 0,
                        isExist : true,
                        superior : true,
                        superiorAddr : superiorAddr,
                        subordinates : temp
                    }
                );
                DappDatasets.Player storage superiorPlayer = playerMap[superiorAddr];
                superiorPlayer.subordinates.push(addr);
                playerMap[addr] = player;
            }
            allPlayer.push(addr);
        }
        function endFomoGame() external {
            require(owner == msg.sender, "Insufficient permissions");
            require(fomoSession > 0, "The game has not started");
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            require(fomo.whetherToEnd == false,"Game over");
            require(DappDatasets.getNowTime() >= fomo.endTime, "The game is not over");
            fomo.whetherToEnd = true;
        }

        function getFomoParticpantLength() external view returns(uint) {
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            return fomo.participant.length;
        }

        function fomoBatchDistribution(uint number, uint frequency, uint index) external {
            require(owner == msg.sender, "Insufficient permissions");
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            require(fomo.whetherToEnd == true,"fomo is not over");
            require(fomo.fomoPrizePool > 0, "fomo pool no bonus");

            uint fomoPool = SafeMath.div(SafeMath.mul(fomo.fomoPrizePool, number), 10);

            uint length = frequency;
            if(fomo.participant.length < frequency) {
                length = fomo.participant.length;
            }
            uint personalAmount = SafeMath.div(fomoPool, length);
            uint num = 0;
            for(uint i = fomo.participant.length - index; i > 0; i--) {
                DappDatasets.Player storage player = playerMap[fomo.participant[i - 1]];
                player.wallet = SafeMath.add(
                    player.wallet,
                    personalAmount
                );
                player.fomoTotalRevenue = SafeMath.add(
                    player.fomoTotalRevenue,
                    personalAmount
                );
                num++;
                if(num == 100 || num == length) {
                    break;
                }
            }
        }

        function getFOMOInfo() external view returns(uint session, uint nowTime, uint endTime, uint prizePool, bool isEnd) {
            DappDatasets.Fomo storage fomo = fomoGame[fomoSession];
            return (fomoSession, DappDatasets.getNowTime(), fomo.endTime, fomo.fomoPrizePool, fomo.whetherToEnd);
        }

        function getSubordinatesAndPerformanceByAddr(address addr) external view returns(address[], uint[], uint[]) {
            DappDatasets.Player storage player = playerMap[addr];
            uint[] memory performance = new uint[](player.subordinates.length);
            uint[] memory numberArray = new uint[](player.subordinates.length);
            for(uint i = 0; i < player.subordinates.length; i++) {
                performance[i] = SafeMath.add(
                    playerMap[player.subordinates[i]].subbordinateTotalPerformance,
                    playerMap[player.subordinates[i]].rechargeAmount
                );
                numberArray[i] = playerMap[player.subordinates[i]].subordinates.length;
            }
            return (player.subordinates, performance, numberArray);
        }

        function getPlayerInfo() external view returns(address superiorAddr, address ownerAddr, uint numberOfInvitations, bool exist) {
            return (playerMap[msg.sender].superiorAddr,  msg.sender, playerMap[msg.sender].subordinates.length, playerMap[msg.sender].isExist);
        }

        function getStatistics() external view returns(
            uint level,
            uint destroyedQuantity,
            uint fomoTotalRevenue,
            uint lotteryTotalRevenue,
            uint difference
        ) {
            return (
                playerMap[msg.sender].shareholderLevel,
                godToken.balanceOf(address(0x0)),
                playerMap[msg.sender].fomoTotalRevenue,
                playerMap[msg.sender].lotteryTotalRevenue,
                SafeMath.sub(
                    SafeMath.mul(playerMap[msg.sender].rechargeAmount, 3),
                    playerMap[msg.sender].staticIncome
                )
            );
        }

        function getRevenueAndPerformance() external view returns(
            uint withdrawalAmount,
            uint subbordinateTotalPerformance,
            uint dynamicIncome,
            uint staticIncome,
            uint withdrawn,
            uint outboundDifference
        ) {
            uint number = 0;
            uint motionAndStaticAmount = SafeMath.add(playerMap[msg.sender].staticIncome, playerMap[msg.sender].dynamicIncome);
            uint withdrawableBalance = SafeMath.mul(playerMap[msg.sender].rechargeAmount, 3);
            if(motionAndStaticAmount > withdrawableBalance) {
                number = SafeMath.sub(motionAndStaticAmount, withdrawableBalance);
            }
            uint difference = 0;
            if(motionAndStaticAmount < withdrawableBalance) {
                difference = SafeMath.sub(withdrawableBalance, motionAndStaticAmount);
            }
            return (
                SafeMath.sub(playerMap[msg.sender].wallet, number),
                playerMap[msg.sender].subbordinateTotalPerformance,
                playerMap[msg.sender].dynamicIncome,
                playerMap[msg.sender].staticIncome,
                playerMap[msg.sender].withdrawalAmount,
                difference
            );
        }
        function getAllPlayer() external view returns(address[]) {
            return allPlayer;
        }
        function getAllPlayerLength() external view returns(uint) {
            return allPlayer.length;
        }

        function getShareholder() external view returns(uint, uint, uint, uint) {
            return (
                globalShareholder[owner].shareholdersV1.length,
                globalShareholder[owner].shareholdersV2.length,
                globalShareholder[owner].shareholdersV3.length,
                globalShareholder[owner].shareholdersV4.length
            );
        }

        function getGlobalShareholder() external view returns(address[], address[], address[], address[]) {
            return (
                globalShareholder[owner].shareholdersV1,
                globalShareholder[owner].shareholdersV2,
                globalShareholder[owner].shareholdersV3,
                globalShareholder[owner].shareholdersV4
            );
        }

        function getPlayer(address addr) external view returns(uint, uint, uint, address, address[]) {
            DappDatasets.Player storage player = playerMap[addr];
            return(
                player.rechargeAmount,
                player.staticIncome,
                player.dynamicIncome,
                player.superiorAddr,
                player.subordinates
            );
        }

        function updatePlayer(address addr, uint amount, bool flag) external {
            require(themisAddr == msg.sender, "Insufficient permissions");
            DappDatasets.Player storage player = playerMap[addr];
            player.wallet = SafeMath.add(player.wallet, amount);
            if(flag) {
                player.staticIncome = SafeMath.add(player.staticIncome, amount);
            }else {
                player.dynamicIncome = SafeMath.add(player.dynamicIncome, amount);
            }
        }

        function updatePlayer(address addr, uint amount) external {
            require(lotteryAddr == msg.sender, "Insufficient permissions");
            DappDatasets.Player storage player = playerMap[addr];
            player.wallet = SafeMath.add(player.wallet, amount);
            player.lotteryTotalRevenue = SafeMath.add(player.lotteryTotalRevenue, amount);
        }
    }

    contract GODThemis {
        function addStaticPrizePool(uint usdtVal) external;
        function addStaticTotalRechargeAndStaticPool(uint usdtVal, uint depositBalance) external;
        function addUsdtPool(uint vUsdt, uint vUsdt4) external;
    }

    contract GODToken {
        function burn(address addr, uint value) public;
        function usdtPrice() public view returns(uint);
        function balanceOf(address who) external view returns (uint);
        function calculationNeedGOD(uint usdtVal) external view returns(uint);
    }

    contract TetherToken {
        function transferFrom(address from, address to, uint value) public;
        function transfer(address to, uint value) public;
    }

    contract GODLottery {
        function getLottoCodeByGameAddr(address addr, uint count) external;
        function lotterySession() public view returns(uint);
        function getLotteryIsEnd() external view returns(bool);
        function updateLotteryPoolAndTodayAmountTotal(uint usdtVal, uint lotteryPool) external;
        function exchange(uint usdtVal, address addr) external;
        function participateLottery(uint usdtVal, address addr) external;
    }