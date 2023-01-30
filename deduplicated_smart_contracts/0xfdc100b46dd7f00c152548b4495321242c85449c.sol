/**
 *Submitted for verification at Etherscan.io on 2020-03-28
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

    contract AWMain {


        address owner;


        address specifyAddr;


        address technologyAddr;

        address gameAddr;

        address[] temp = new address[](0);

        uint staticDividendUsdt;

        uint public staticPrizePool;

        uint public staticTotalRecharge;

        address[] allPlayer;

        address[] shareholdersV1;

        address[] shareholdersV2;

        address[] shareholdersV3;

        address[] shareholdersV4;

        uint public usdtPool;

        TetherToken tether;
        AWToken awToken;

        AWGame game;

        mapping(address => DappDatasets.Player) public playerMap;

        constructor(
            address _owner,
            address _tetherAddr,
            address _awAddr,
            address _gameAddr,
            address _technologyAddr,
            address _specifyAddr
        )  public {
            owner = _owner;
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
            specifyAddr = _specifyAddr;
            playerMap[owner] = player;
            tether = TetherToken(_tetherAddr);
            awToken = AWToken(_awAddr);
            game = AWGame(_gameAddr);
            gameAddr = _gameAddr;
            technologyAddr = _technologyAddr;
            allPlayer.push(owner);
            if(owner != technologyAddr) {
                playerMap[technologyAddr] = player;
                allPlayer.push(technologyAddr);
            }
        }

        function() public payable {
            withdrawImpl(msg.sender);
        }

        function resetNodePool() external {
            require(owner == msg.sender, "Insufficient permissions");
            usdtPool = 0;
        }

        function addWalletAndDynamicIncome(address addr, uint num) internal {
            playerMap[addr].wallet = SafeMath.add(playerMap[addr].wallet, num);
            playerMap[addr].dynamicIncome = SafeMath.add(playerMap[addr].dynamicIncome, num);
        }

        function usdtNode(uint start, uint count) external {
            require(owner == msg.sender, "Insufficient permissions");
            if(shareholdersV4.length < 1) {
                staticPrizePool = SafeMath.add(staticPrizePool, usdtPool);
                return;
            }
            uint award = SafeMath.div(usdtPool, shareholdersV4.length);
            uint index = 0;
            for(uint i = start; i < shareholdersV4.length; i++) {
                fosterInteraction(shareholdersV4[i], award);
                index++;
                if(index == count) {
                    break;
                }

            }
        }

        function getShareholder() external view returns(uint, uint, uint, uint, uint) {
            return (
                shareholdersV1.length,
                shareholdersV2.length,
                shareholdersV3.length,
                shareholdersV4.length,
                allPlayer.length
            );
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
                awToken.balanceOf(address(0x0)),
                playerMap[msg.sender].fomoTotalRevenue,
                playerMap[msg.sender].lotteryTotalRevenue,
                SafeMath.sub(
                    SafeMath.mul(playerMap[msg.sender].rechargeAmount, 3),
                    playerMap[msg.sender].staticIncome
                )
            );
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
            uint value = SafeMath.add(playerMap[msg.sender].dynamicIncome, playerMap[msg.sender].staticIncome);
            uint difference = 0;
            if(value > SafeMath.mul(playerMap[msg.sender].rechargeAmount, 3)) {
                difference = 0;
            }else {
                difference = SafeMath.sub(SafeMath.mul(playerMap[msg.sender].rechargeAmount, 3), value);
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

        function withdrawImpl(address addr) internal {
            require(playerMap[addr].wallet > 0, "Insufficient wallet balance");

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

            uint handlingFee = SafeMath.div(value, 10);
            game.buyLotto(handlingFee, addr);
            staticPrizePool = SafeMath.add(staticPrizePool, handlingFee);
            tether.transfer(addr, SafeMath.sub(value, handlingFee));
        }

        function withdrawService() external {
            withdrawImpl(msg.sender);
        }

        function afterStaticPayment() external {
            require(owner == msg.sender, "Insufficient permissions");
            staticPrizePool = SafeMath.sub(staticPrizePool, staticDividendUsdt);
            staticDividendUsdt = 0;
        }

        function staticDividend(uint index) external {
            require(owner == msg.sender, "Insufficient permissions");
            uint count = 0;
            for(uint i = index; i < allPlayer.length; i++) {
                if(
                    playerMap[allPlayer[i]].rechargeAmount == 0 ||
                    SafeMath.add(playerMap[allPlayer[i]].staticIncome, playerMap[allPlayer[i]].dynamicIncome) >=
                    SafeMath.mul(playerMap[allPlayer[i]].rechargeAmount, 3)
                ) {
                    continue;
                }

                uint proportionOfInvestment = SafeMath.div(
                    SafeMath.mul(playerMap[allPlayer[i]].rechargeAmount, 10 ** 6),
                    staticTotalRecharge
                );

                uint personalAmount = SafeMath.div(
                    SafeMath.div(SafeMath.mul(staticPrizePool, proportionOfInvestment), 120),
                    10 ** 6
                );
                playerMap[allPlayer[i]].wallet = SafeMath.add(
                    playerMap[allPlayer[i]].wallet,
                    personalAmount
                );
                playerMap[allPlayer[i]].staticIncome = SafeMath.add(
                    playerMap[allPlayer[i]].staticIncome,
                    personalAmount
                );
                staticDividendUsdt += personalAmount;
                count++;
                if(count == 100) {
                    break;
                }
            }
        }

        function participateFomo(uint usdtVal, address superiorAddr) external {
            require(usdtVal >= 10 * 10 ** 6, "Less than the minimum amount");
            register(msg.sender, superiorAddr);

            DappDatasets.Player storage player = playerMap[msg.sender];
            player.rechargeAmount = SafeMath.add(player.rechargeAmount, usdtVal);
            staticTotalRecharge = SafeMath.add(staticTotalRecharge, usdtVal);

            uint amount = SafeMath.div(SafeMath.mul(usdtVal, 3), 100);
            playerMap[technologyAddr].wallet = SafeMath.add(playerMap[technologyAddr].wallet, amount);
            usdtPool = SafeMath.add(usdtPool, amount);

            increasePerformance(usdtVal);

            uint remaining = game.deposit(usdtVal, msg.sender);
            staticPrizePool = SafeMath.add(staticPrizePool, remaining);

            tether.transferFrom(msg.sender, this, usdtVal);
        }

        function increasePerformance(uint usdtVal) internal {
            DappDatasets.Player storage player = playerMap[msg.sender];
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
            if(player.subbordinateTotalPerformance >= 10 * 10 ** 10) {
                uint length = player.subordinates.length;
                if(player.subordinates.length > 30) {
                    length = 30;
                }
                for(uint i = 0; i < 4; i++) {
                    if(player.shareholderLevel == i) {
                        uint levelCount = 0;
                        for(uint j = 0; j < length; j++) {
                            if(i == 0 && player.rechargeAmount >= 1000 * 10 ** 6) {
                                uint areaTotal = SafeMath.add(
                                            playerMap[player.subordinates[j]].subbordinateTotalPerformance,
                                            playerMap[player.subordinates[j]].rechargeAmount
                                );
                                if(areaTotal >= 3 * 10 ** 10) {
                                    levelCount++;
                                }
                            }else if(i == 1 && player.rechargeAmount >= 3000 * 10 ** 6) {
                                if(playerMap[player.subordinates[j]].shareholderLevel >= 1 || playerMap[player.subordinates[j]].underUmbrellaLevel >= 1) {
                                    levelCount++;
                                }
                            }else if(i == 2 && player.rechargeAmount >= 5000 * 10 ** 6) {
                                if(playerMap[player.subordinates[j]].shareholderLevel >= 2 || playerMap[player.subordinates[j]].underUmbrellaLevel >= 2) {
                                    levelCount++;
                                }
                            }else if(i == 3 && player.rechargeAmount >= 10000 * 10 ** 6) {
                                if(playerMap[player.subordinates[j]].shareholderLevel >= 3 || playerMap[player.subordinates[j]].underUmbrellaLevel >= 3) {
                                    levelCount++;
                                }
                            }

                            if(levelCount >= 2) {
                                player.shareholderLevel = i + 1;
                                if(i == 0 ) {
                                    shareholdersV1.push(addr);
                                }else if(i == 1) {
                                    shareholdersV2.push(addr);
                                }else if(i == 2) {
                                    shareholdersV3.push(addr);
                                }else if(i == 3) {
                                    shareholdersV4.push(addr);
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

        function rewardDistribution(address addr, uint amount) external returns(uint) {
            require(gameAddr == msg.sender, "Insufficient permissions");
            return fosterInteraction(addr, amount);
        }


        function fosterInteraction(address addr, uint amount) internal returns(uint) {
            DappDatasets.Player storage player = playerMap[addr];
            addWalletAndDynamicIncome(addr, amount);
            uint number = amount;
            uint reward = SafeMath.div(amount, 10);
            if(player.superior) {
                addWalletAndDynamicIncome(player.superiorAddr, reward);
                number = SafeMath.add(number, reward);
            }
            if(player.subordinates.length > 0) {
                uint length = player.subordinates.length;
                if(player.subordinates.length > 30) {
                    length = 30;
                }
                uint splitEqually = SafeMath.div(reward, length);
                for(uint i = 0; i < length; i++) {
                    addWalletAndDynamicIncome(player.subordinates[i], splitEqually);
                }
                number = SafeMath.add(number, reward);
            }
            return number;
        }

        function releaseStaticPoolAndV4(uint usdtVal) external {
            require(gameAddr == msg.sender, "Insufficient permissions");
            uint staticPool60 = SafeMath.div(SafeMath.mul(usdtVal, 6), 10);
            staticPrizePool = SafeMath.add(staticPrizePool, staticPool60);

            uint amount = SafeMath.sub(usdtVal, staticPool60);
            if(shareholdersV4.length > 0) {
                uint length = 0;
                if(shareholdersV4.length > 100) {
                    length = 100;
                }else {
                    length = shareholdersV4.length;
                }
                uint splitEqually = SafeMath.div(amount, length);
                for(uint i = 0; i < length; i++) {
                    addWalletAndDynamicIncome(shareholdersV4[i], splitEqually);
                }
            }else {
                staticPrizePool = SafeMath.add(staticPrizePool, amount);
            }

        }

        function updateRevenue(address addr, uint amount, bool flag) external {
            require(gameAddr == msg.sender, "Insufficient permissions");
            DappDatasets.Player storage player = playerMap[addr];
            if(flag) {
                player.wallet = SafeMath.add(player.wallet, amount);
                player.fomoTotalRevenue = SafeMath.add(player.fomoTotalRevenue, amount);
            }else {
                player.wallet = SafeMath.add(player.wallet, amount);
                player.lotteryTotalRevenue = SafeMath.add(player.lotteryTotalRevenue, amount);
            }
        }

        function participateLottery(uint usdtVal, address superiorAddr) external {
            require(usdtVal <= 300 * 10 ** 6 && usdtVal >= 10 ** 6, "Purchase value between 1-300");
            register(msg.sender, superiorAddr);
            game.buyLotto(usdtVal, msg.sender);
            staticPrizePool = SafeMath.add(staticPrizePool, usdtVal);
            tether.transferFrom(msg.sender, this, usdtVal);
        }

        function getPlayer(address addr) external view returns(uint, address, address[]) {
            DappDatasets.Player storage player = playerMap[addr];
            return (playerMap[player.superiorAddr].shareholderLevel, player.superiorAddr, player.subordinates);
        }

        function exchange(uint usdtVal, address superiorAddr) external {
            require(usdtVal >= 10 ** 6, "Redeem at least 1USDT");
            register(msg.sender, superiorAddr);

            uint usdtPrice = awToken.usdtPrice();

            game.redeemAW(usdtVal, usdtPrice, msg.sender);
            uint staticAmount = SafeMath.div(SafeMath.mul(usdtVal, 4), 10);
            staticPrizePool = SafeMath.add(staticPrizePool, staticAmount);

            tether.transferFrom(msg.sender, this, staticAmount);

            tether.transferFrom(msg.sender, specifyAddr, SafeMath.sub(usdtVal, staticAmount));
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

    }

    contract TetherToken {
       function transfer(address to, uint value) public;
       function transferFrom(address from, address to, uint value) public;
    }

    contract AWToken {
       function burn(address addr, uint value) public;
       function balanceOf(address who) external view returns (uint);
       function calculationNeedAW(uint usdtVal) external view returns(uint);
       function usdtPrice() external view returns(uint);
    }

    contract AWGame {
        function deposit(uint usdtVal, address addr) external returns(uint);
        function updateLotteryPoolAndTodayAmountTotal(uint usdtVal, uint lotteryPool) external;
        function redeemAW(uint usdtVal, uint usdtPrice, address addr) external;
        function buyLotto(uint usdtVal, address addr) external;
    }