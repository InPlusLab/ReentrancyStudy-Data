pragma solidity ^0.5.8;
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./ReentrancyGuard.sol";
import "./Address.sol";
import "./WeFairPlayInvestment.sol";
contract BigOrSmall is ReentrancyGuard {
    using SafeMath for uint;
    using IterableMapping for IterableMapping.itmap;
    uint8 constant MIN_DUR_BLOCKS = 5;
    uint8 constant MIN_LIMIT_BLOCKS = 4;
    uint8 constant MIN_INTERVAL_BLOCKS = 1;
    uint32 constant MAX_TIME_PER_GAME = 1 days;
    uint32 constant DESTROY_DURATION = 30 days;//30 days;
    uint constant POOL_MIN = 1e18;//1e18;
    uint constant POOL_MAX = 100e18;//100e18;

    enum BetTypes {
        Big,
        Small,
        Triple,
        EachDouble,
        Sum,
        OneNum,
        TwoNum,
        BetTypeCnt
    }
    address owner;
    bytes32 adminKey;
    bool public noAdminMode;
    address payable addrInvest;
    uint public poolCache = 1e18;
    uint public totalCanGetRewards;
    uint public totalOweRewards;
    IterableMapping.itmap mapBig;
    IterableMapping.itmap mapSmall;
    IterableMapping.itmap[7] mapTriple;
    IterableMapping.itmap[6] mapDouble;
    IterableMapping.itmap[14] mapSum;
    uint8[14] rateSum = [uint8(50),18,14,12,8,6,6,6,6,8,12,14,18,50];
    IterableMapping.itmap[6] mapOne;
    IterableMapping.itmap[15] mapTwo;
    IterableMapping.itmap mapPlayerRewards;
    IterableMapping.itmap mapCanGetRewards;
    IterableMapping.itmap mapOweRewards;
    uint public totalGameBets;
    uint public systemBalance;
    uint totalWinBets;
    uint public bigBets;
    uint public smallBets;
    uint public startBlockNum;
    uint startTime;
    uint32 public gameDurationBlocks;
    uint public endBlockNum;
    uint32 public gameLimitBlocks;
    uint public betLimitBlockNum;
    bytes32 serverRandomHash;
    uint public lastBetTime;
    bool isInvested;
    uint public round;
    uint8 public gameState;
    event PlayerBet(address player,uint round,uint ret,uint numBet,uint bet);
    event EndGame(uint round,uint one,uint two,uint three);
    modifier onlyAdministrator()
    {
        require(owner == msg.sender || adminKey == keccak256(abi.encodePacked(msg.sender)));
        _;
    }
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    modifier onlyBetting(){ require((block.number <= betLimitBlockNum) || gameState == 2); _;}
    constructor(address payable investAddress,uint32 gameDurBlocks,uint32 bLimitBlocks,bytes32 serverRandom) public
    {
        owner = msg.sender;
        adminKey = 0x6e87e5c3130679f898089256718f36b117cb685debd8d2511298b3f0dabadf1e;
        addrInvest = investAddress;
        serverRandomHash = serverRandom;
        if(gameDurBlocks < MIN_DUR_BLOCKS)
            gameDurBlocks = MIN_DUR_BLOCKS;
        gameDurationBlocks = gameDurBlocks;
        if(bLimitBlocks < MIN_LIMIT_BLOCKS)
            bLimitBlocks = MIN_LIMIT_BLOCKS;
        if(bLimitBlocks > gameDurBlocks - MIN_INTERVAL_BLOCKS)
            bLimitBlocks = gameDurBlocks - MIN_INTERVAL_BLOCKS;
        gameLimitBlocks = bLimitBlocks;
        gameState = 3;
    }
    function getTwoNumIdxByCalced(uint8 calced)
    internal
    pure
    returns(uint8)
    {
        if(12 == calced){return 0;}
        else if(13 == calced){return 1;}
        else if(14 == calced){return 2;}
        else if(15 == calced){return 3;}
        else if(16 == calced){return 4;}
        else if(23 == calced){return 5;}
        else if(24 == calced){return 6;}
        else if(25 == calced){return 7;}
        else if(26 == calced){return 8;}
        else if(34 == calced){return 9;}
        else if(35 == calced){return 10;}
        else if(36 == calced){return 11;}
        else if(45 == calced){return 12;}
        else if(46 == calced){return 13;}
        else if(56 == calced){return 14;}
        else {return 15;}
    }
    function isAdministrator()
    view
    public
    returns(bool)
    {
        return (owner == msg.sender || adminKey == keccak256(abi.encodePacked(msg.sender)));
    }
    function setAdministrator(bytes32 _identifier, bool _status) onlyAdministrator  public
    {
        if(_status)
        {
            adminKey = _identifier;
        }
        else if(_identifier == adminKey)
        {
            adminKey = 0;
        }
        noAdminMode = false;
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function kill() onlyOwner public
    {
        require(totalOweRewards == 0);
        require(lastBetTime > 0 && now.sub(lastBetTime) > DESTROY_DURATION);
        selfdestruct(toPayable(owner));
    }
    function setDurAndBetLimit(uint32 gameDurBlocks,uint32 bLimitBlocks) onlyAdministrator onlyBetting public
    {
        require(gameDurBlocks >= MIN_DUR_BLOCKS
            && bLimitBlocks >= MIN_LIMIT_BLOCKS
            && gameDurBlocks-MIN_INTERVAL_BLOCKS >= bLimitBlocks
            );
        gameDurationBlocks = gameDurBlocks;
        gameLimitBlocks = bLimitBlocks;
    }
    function launchGame() onlyAdministrator public
    {
        require(gameState == 3);
        startNextRound();
    }
    function systemOweMyRewards()
    view
    public
    returns(uint)
    {
        return mapOweRewards.data[uint(msg.sender)].value;
    }
    function myCanGetRewards()
    view
    public
    returns(uint)
    {
        return mapCanGetRewards.data[uint(msg.sender)].value;
    }
    function bet(uint8 btype,uint8 numBet) onlyBetting payable public
    {
        require(msg.value >= 1e16);
        require(btype >= 0 &&  btype < uint8(BetTypes.BetTypeCnt));
        if(gameState == 2)
        {
            startNextRound();
        }
        totalGameBets = totalGameBets.add(msg.value);
        BetTypes betType = BetTypes(btype);
        if(betType == BetTypes.Big)
        {
            mapBig.add_or_insert(uint(msg.sender),msg.value);
            bigBets = bigBets.add(msg.value);
        }
        else if(betType == BetTypes.Small)
        {
            mapSmall.add_or_insert(uint(msg.sender),msg.value);
            smallBets = smallBets.add(msg.value);
        }
        else if(betType == BetTypes.Triple)
        {
            require(numBet<7);
            mapTriple[numBet].add_or_insert(uint(msg.sender),msg.value);
        }
        else if(betType == BetTypes.EachDouble)
        {
            require(numBet>0 && numBet<7);
            mapDouble[numBet-1].add_or_insert(uint(msg.sender),msg.value);
        }
        else if(betType == BetTypes.Sum)
        {
            require(numBet>=4 && numBet<=17);
            mapSum[numBet-4].add_or_insert(uint(msg.sender),msg.value);
        }
        else if(betType == BetTypes.OneNum)
        {
            require(numBet>0 && numBet<7);
            mapOne[numBet-1].add_or_insert(uint(msg.sender),msg.value);
        }
        else if(betType == BetTypes.TwoNum)
        {
            require(numBet>=1 && numBet<=15);
            mapTwo[numBet-1].add_or_insert(uint(msg.sender),msg.value);
        }
        systemBalance = address(this).balance;
        lastBetTime = now;
        startTime = now;
        emit PlayerBet(msg.sender,round,btype,numBet,msg.value);
    }
    function calcBetTwoResult(uint8 small ,uint8 big) internal
    {
        if(small > big)
        {
            uint8 temp = small;
            small = big;
            big = temp;
        }
        uint8 calced = uint8(small*10+big);
        uint8 idx = getTwoNumIdxByCalced(calced);
        IterableMapping.itmap storage mapWin = mapTwo[idx];
        for (uint i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
        {
            (uint key, uint value) = mapWin.iterate_get(i);
            mapPlayerRewards.add_or_insert(key,value*6);
            totalWinBets = totalWinBets.add(value*6);
        }
    }
    function calcBetOneResult(uint8 one,uint8 two,uint8 three) internal
    {
        uint i = 0;
        uint key = 0;
        uint value = 0;
        if(one == two && one == three)
        {
            IterableMapping.itmap storage mapWin = mapOne[one-1];
            for (i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                ( key,  value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*4);
                totalWinBets = totalWinBets.add(value*4);
            }
        }
        bool bTwoSame = false;
        uint8 sameNum = 0;
        uint8 other = 0;
        if(one == two && one != three)
        {
            bTwoSame = true;
            sameNum = one;
            other = three;
        }
        else if(two == three && one != three)
        {
            bTwoSame = true;
            other = one;
            sameNum = two;
        }
        else if(one == three && one != two)
        {
            bTwoSame = true;
            sameNum = one;
            other = two;
        }
        if(bTwoSame)
        {
            IterableMapping.itmap storage mapWin = mapOne[sameNum-1];
            for (i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                (key, value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*3);
                totalWinBets = totalWinBets.add(value*3);
            }

            mapWin = mapOne[other-1];
            for (i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                (key, value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*2);
                totalWinBets = totalWinBets.add(value*2);
            }
        }
        if(one!=two && one!=three && two!=three)
        {
            uint8[3] memory arrNums = [one,two,three];
            for(uint8 j = 0;j<3; j++)
            {
                uint8 num = arrNums[j];
                IterableMapping.itmap storage mapWin = mapOne[num-1];
                for (i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
                {
                    (key, value) = mapWin.iterate_get(i);
                    mapPlayerRewards.add_or_insert(key,value*2);
                    totalWinBets = totalWinBets.add(value*2);
                }
            }
        }
    }
    function calcBetTwoOrBigSmallResult(uint8 one,uint8 two,uint8 three) internal
    {
        uint i = 0;
        uint key = 0;
        uint value = 0;
        uint8 sum = one + two + three;
        if(!(one == two && one == three))
        {
            if(sum>=4 && sum<=10)
            {
                for ( i = mapSmall.iterate_start(); mapSmall.iterate_valid(i); i = mapSmall.iterate_next(i))
                {
                    ( key,  value) = mapSmall.iterate_get(i);
                    mapPlayerRewards.add_or_insert(key,value*2);
                    totalWinBets = totalWinBets.add(value*2);
                }
            }
            else if(sum>=11 && sum<=17)
            {
                for (i = mapBig.iterate_start(); mapBig.iterate_valid(i); i = mapBig.iterate_next(i))
                {
                    (key, value) = mapBig.iterate_get(i);
                    mapPlayerRewards.add_or_insert(key,value*2);
                    totalWinBets = totalWinBets.add(value*2);
                }
            }
            if(one != two && one != three && two != three)
            {
                calcBetTwoResult(one,two);
                calcBetTwoResult(one,three);
                calcBetTwoResult(two,three);
            }
            bool bTwoSame = false;
            uint8 small = 0;
            uint8 big = 0;
            if(one == two || two == three)
            {
                bTwoSame = true;
                small = one;
                big = three;
            }
            else if(one == three)
            {
                bTwoSame = true;
                small = one;
                big = two;
            }
            if(bTwoSame)
            {
                calcBetTwoResult(small,big);
            }
        }
    }
    function calcBetSumResult(uint8 sum) internal
    {
        if(sum >= 4 && sum <= 17)
        {
            uint8 idx = sum - 4;
            IterableMapping.itmap storage mapWin = mapSum[idx];
            uint8 rate = rateSum[idx];
            for (uint i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                (uint key, uint value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*(rate+1));
                totalWinBets = totalWinBets.add(value*(rate+1));
            }
        }
    }
    function calcBetDoubleResult(uint8 one,uint8 two,uint8 three) internal
    {
        bool isDouble = false;
        uint8 sameNum = 0;
        if(one == two || one == three)
        {
            isDouble = true;
            sameNum = one;
        }
        else if(two == three)
        {
            isDouble = true;
            sameNum = two;
        }
        if(isDouble)
        {
            IterableMapping.itmap storage mapWin = mapDouble[sameNum-1];
            for (uint i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                (uint key, uint value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*9);
                totalWinBets = totalWinBets.add(value*9);
            }
        }
    }
    function calcBetTripleResult(uint8 one,uint8 two,uint8 three) internal
    {
        uint i = 0;
        uint key = 0;
        uint value = 0;
        if(one == two && one == three)
        {
            IterableMapping.itmap storage mapWin = mapTriple[0];
            for ( i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                ( key,  value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*25);
                totalWinBets = totalWinBets.add(value*25);
            }
            mapWin = mapTriple[one];
            for (i = mapWin.iterate_start(); mapWin.iterate_valid(i); i = mapWin.iterate_next(i))
            {
                (key, value) = mapWin.iterate_get(i);
                mapPlayerRewards.add_or_insert(key,value*151);
                totalWinBets = totalWinBets.add(value*151);
            }
        }
    }
    function end(string memory curServerSeed,bytes32 nextServerRandom) public
    {
        require((block.number-1) >= endBlockNum,'block number should >= endBlock+1');
        require(gameState == 0,'gameState is not 0');
        if(noAdminMode)
        {
            if(owner == msg.sender || adminKey == keccak256(abi.encodePacked(msg.sender)))
            {
                noAdminMode = false;
            }
            else if(now <= startTime + MAX_TIME_PER_GAME)
            {
                require(bytes32(keccak256(abi.encodePacked(curServerSeed))) == serverRandomHash,'server hash is not right.');
            }
        }
        else
        {
            if(now > startTime + MAX_TIME_PER_GAME)
            {
                noAdminMode = true;
            }
            else
            {
                require(owner == msg.sender || adminKey == keccak256(abi.encodePacked(msg.sender)),'msg.sender is not owner or admin.');
                require(bytes32(keccak256(abi.encodePacked(curServerSeed))) == serverRandomHash,'server hash is not right.');
            }
        }
        gameState = 1;
        uint checkBlockNum = (endBlockNum + betLimitBlockNum)/2;
        uint base1 = uint(keccak256(abi.encodePacked(uint(blockhash(checkBlockNum)),curServerSeed , totalGameBets)));
        uint8 one = uint8((base1 % 6) + 1);
        uint base2 = uint(keccak256(abi.encodePacked(base1,totalGameBets)));
        uint8 two = uint8((base2 % 6) + 1);
        uint8 three = uint8((uint(keccak256(abi.encodePacked(base2,totalGameBets))) % 6) + 1);
        if(totalGameBets == 0)
        {
            emit EndGame(round,one,two,three);
            clearGameState(nextServerRandom);
            return;
        }
        calcBetOneResult(one,two,three);
        calcBetTwoOrBigSmallResult(one,two,three);
        calcBetSumResult(one + two + three);
        calcBetDoubleResult(one,two,three);
        calcBetTripleResult(one,two,three);
        uint totalCanUse = (address(this).balance > totalCanGetRewards) ?
            (address(this).balance).sub(totalCanGetRewards) : 0;
        if(totalWinBets > 0)
        {
            uint lastWinBets = totalWinBets;
            if(lastWinBets > totalCanUse)
            {
                lastWinBets = totalCanUse;
            }
            calcPlayerRewards(lastWinBets);
        }
        if(totalOweRewards > 0 && totalCanUse > totalWinBets && totalCanGetRewards <= address(this).balance)
        {
            uint totalCanRepay = (address(this).balance).sub(totalCanGetRewards);
            if(totalCanRepay > poolCache)
            {
                totalCanRepay = poolCache;
            }
            paybackOwePlayerRewards(totalCanRepay);
        }
        paybackBankerProfits();
        retrieveInvest();
        emit EndGame(round,one,two,three);
        clearGameState(nextServerRandom);
        systemBalance = address(this).balance;
    }
    function calcPlayerRewards(uint lastWinBets)
    internal
    {
        for (uint i = mapPlayerRewards.iterate_start(); mapPlayerRewards.iterate_valid(i); i = mapPlayerRewards.iterate_next(i))
        {
            (uint addrWin,uint betCnt) = mapPlayerRewards.iterate_get(i);
            uint canGetReward = 0;
            uint oweReward = 0;
            if(lastWinBets < totalWinBets)
            {
                canGetReward = betCnt.mul(lastWinBets).div(totalWinBets);
                oweReward = betCnt.sub(canGetReward);
            }
            else
            {
                canGetReward = betCnt;
            }
            if(canGetReward > 0)
            {
                mapCanGetRewards.add_or_insert(addrWin,canGetReward);
                totalCanGetRewards = totalCanGetRewards.add(canGetReward);
            }
            if(oweReward > 0)
            {
                mapOweRewards.add_or_insert(addrWin,oweReward);
                totalOweRewards = totalOweRewards.add(oweReward);
            }
        }
    }
    function paybackOwePlayerRewards(uint totalCanRepay)
    internal
    {
        uint canBackReward = totalOweRewards;
        if(canBackReward > totalCanRepay)
        {
            canBackReward = totalCanRepay;
        }
        uint totalOweCount = totalOweRewards;
        uint16 j = 0;
        for(uint i = mapOweRewards.iterate_start(); mapOweRewards.iterate_valid(i); i = mapOweRewards.iterate_next(i))
        {
            if(j > 200)
            {
                break;
            }
            (uint addrPlayer,uint oweCount) = mapOweRewards.iterate_get(i);
            if(oweCount == 0)
            {
                continue;
            }
            uint backCount = 0;
            if(canBackReward < totalOweCount)
            {
                backCount = oweCount.mul(canBackReward).div(totalOweCount);
                if(backCount > oweCount)
                {
                    backCount = oweCount;
                }
            }
            else
            {
                backCount = oweCount;
            }
            if(backCount > totalOweRewards)
            {
                backCount = totalOweRewards;
            }
            mapCanGetRewards.add_or_insert(addrPlayer,backCount);
            mapOweRewards.sub(addrPlayer,backCount);
            totalOweRewards = totalOweRewards.sub(backCount);
            totalCanGetRewards = totalCanGetRewards.add(backCount);
            j++;
        }
    }
    function paybackBankerProfits()
    internal
    {
        uint lastRestBalance = (address(this).balance < totalCanGetRewards) ? 0 :
                (address(this).balance).sub(totalCanGetRewards);
        bool needDec = false;
        if(lastRestBalance > 0)
        {
            if(lastRestBalance > poolCache)
            {
                if(Address.isContract(addrInvest))
                {
                    bytes memory payload = abi.encodeWithSignature("buy()");
                    (bool bSuc,) = addrInvest.call.value(lastRestBalance.sub(poolCache))(payload);
                    if(bSuc)
                    {
                        isInvested = true;
                    }
                }
                if(poolCache.add(1e18) <= POOL_MAX)
                {
                    poolCache = poolCache.add(1e18);
                }
            }
            else if((lastRestBalance + 1e18) <= poolCache)
            {
                needDec = true;
            }
        }
        else
        {
            needDec = true;
        }
        if(needDec && poolCache.sub(1e18) >= POOL_MIN)
        {
            poolCache = poolCache.sub(1e18);
        }
    }
    function retrieveInvest()
    internal
    {
        if(totalOweRewards > 0 && isInvested && Address.isContract(addrInvest))
        {
            bytes memory payload = abi.encodeWithSignature("exit()");
            (bool bSuc,) = addrInvest.call(payload);
            if(bSuc)
            {
                isInvested = false;
            }
        }
    }
    function extractPlayerRewards(uint rewards, bool all) nonReentrant() public
    {
        uint addrPlayer = uint(msg.sender);
        uint canGetRewards = mapCanGetRewards.data[addrPlayer].value;
        if(all)
        {
            rewards = canGetRewards;
        }
        require(rewards > 0 && rewards <= canGetRewards);
        if(rewards > totalCanGetRewards)
        {
            rewards = totalCanGetRewards;
        }
        mapCanGetRewards.sub(addrPlayer,rewards);
        if(rewards == canGetRewards)
        {
            mapCanGetRewards.remove(addrPlayer);
        }
        totalCanGetRewards = totalCanGetRewards.sub(rewards);
        systemBalance = address(this).balance - rewards;
        msg.sender.transfer(rewards);
    }
    function clearGameState(bytes32 nextServerRandom) internal
    {
        mapBig.clear();
        mapSmall.clear();
        uint8 i = 0;
        for(i=0; i<7; i++)
        {
            mapTriple[i].clear();
        }
        for(i=0; i<6; i++)
        {
            mapDouble[i].clear();
        }
        for(i=0; i<14; i++)
        {
            mapSum[i].clear();
        }
        for(i=0; i<6; i++)
        {
            mapOne[i].clear();
        }
        for(i=0; i<15; i++)
        {
            mapTwo[i].clear();
        }
        mapPlayerRewards.clear();
        totalGameBets = 0;
        totalWinBets = 0;
        bigBets = 0;
        smallBets = 0;
        serverRandomHash = nextServerRandom;
        gameState = 2;
        round++;
    }
    function startNextRound() internal
    {
        startBlockNum = block.number;
        startTime = now;
        endBlockNum = startBlockNum + gameDurationBlocks;
        betLimitBlockNum = startBlockNum + gameLimitBlocks;
        gameState = 0;
    }
    function () payable external
    {
        require(msg.sender == addrInvest);
    }
}
