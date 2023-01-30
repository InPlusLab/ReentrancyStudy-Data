/**

 *Submitted for verification at Etherscan.io on 2018-09-21

*/



pragma solidity ^0.4.14;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}





library Datasets {

    // ��Ϸ״̬

    enum GameState {

        GAME_ING         //������

    , GAME_CLEAR     //��ͣ��ע



    }

    // ������ʶ

    enum BetTypeEnum {

        NONE

    , DRAGON    //��

    , TIGER     //��

    , DRAW      //��

    }

    // coin ��������

    enum CoinOpTypeEnum {

        NONE

    , PAY               //1��ֵ

    , WITHDRAW          //2����

    , BET               //3��ע

    , INVITE_AWARD      //4���뽱��

    , WIN_AWARD         //5Ӯ����ע�Ľ���

    , LUCKY_AWARD       //6���˽�



    }



    struct Round {

        uint256 start;          // ��ʼʱ��

        uint256 cut;            // ��ֹʱ��

        uint256 end;            // ����ʱ��

        bool ended;             // �Ƿ��ѽ���

        uint256 amount;         // �ܷ���

        uint256 coin;           // ��coin

        BetTypeEnum result;     // ���

        uint32 betCount;        // ��ע�˴�

    }



    // ���

    struct Player {

        address addr;    // ��ҵ�ַ

        uint256 coin;    // ���ʣ��coin

        uint256 parent1; // 1��

        uint256 parent2; // 2��

        uint256 parent3; // 3��

    }



    // Ͷע��

    struct Beter {

        uint256 betId;       // Ѻע��

        bool beted;          // ���Ϊ���ʾ�Ѿ�Ͷע��

        BetTypeEnum betType; // Ѻ��ѺС   1 dragon   2tiger

        uint256 amount;      // ����

        uint256 value;       // Ѻ����

    }

    //coin��ϸ

    struct CoinDetail {

        uint256 roundId;        // �����Ļغ�

        uint256 value;          // �����Ľ��

        bool isGet;             // �Ƿ��ǻ��

        CoinOpTypeEnum opType;  // ��������

        uint256 time;           // ����ʱ��

        uint256 block;          // ����߶�

    }

}





contract GameLogic {

    using SafeMath for *;

    address private owner;



    // ���ұ���

    uint256 constant private EXCHANGE = 1;



    // һ��������ע��ʱ��

    uint256 private ROUND_BET_SECONDS = 480 seconds;

    // һ��ʱ��

    uint256 private ROUND_MAX_SECONDS = 600 seconds;

    // ������

    uint256 private RETURN_AWARD_RATE = 9000;          //0.9

    // ���˽���ɱ���

    uint256 private LUCKY_AWARD_RATE = 400;            //0.04

    // ÿ���ɷ����˽��ı���

    uint256 private LUCKY_AWARD_SEND_RATE = 5000;      //0.5

    // ���ַ�

    uint256 private WITH_DROW_RATE = 100;               // 0.01

    // ����ֳɷ�

    uint256 private INVITE_RATE = 10;                   // 0.001

    // RATE_BASE

    uint256 constant private RATE_BASE = 10000;                  //RATE/RATE_BASE

    // ÿ��Ѻע�Ķ��

    uint256 constant private VALUE_PER_MOUNT = 1000000000000000;

    uint32 private ROUND_BET_MAX_COUNT = 300;

    uint256 constant private UID_START = 1000;



    // ����

    uint256 public roundId = 0;

    // ��ǰ��Ϸ״̬

    Datasets.GameState public state;

    // ��ǰ�Ƿ񼤻�

    bool public activated = false;

    // ���˽�

    uint256 public luckyPool = 0;



    //****************

    // �������

    //****************

    uint256 private userSize = UID_START;                                                   // ƽ̨�û���

    mapping(uint256 => Datasets.Player) public mapIdxPlayer;                        // (pId => data) player data

    mapping(address => uint256) public mapAddrxId;                                  // (addr => pId) returns player id by address

    mapping(uint256 => Datasets.Round) public mapRound;                             // rid-> roundData

    mapping(uint256 => mapping(uint8 => Datasets.Beter[])) public mapBetter;        // rid -> betType -> Beter[index] ����ÿһ�ڵ�Ͷע

    mapping(uint256 => mapping(uint8 => uint256)) public mapBetterSizes;            // rid -> betType -> size;



    //****************

    // Ȩ�޷���

    //****************

    modifier onlyState(Datasets.GameState curState) {

        require(state == curState);

        _;

    }



    modifier onlyActivated() {

        require(activated == true, "it's not ready yet");

        _;

    }



    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    modifier onlyHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



    //****************

    // ���췽��

    //****************

    constructor() public {

        owner = msg.sender;

    }



    // fallback����

    function() onlyHuman public payable {

        uint256 value = msg.value;

        require(value > 0 && msg.sender != 0x0, "value not valid yet");

        uint256 pId = mapAddrxId[msg.sender];

        if (pId == 0)

            pId = addPlayer(msg.sender, value);

        else {

            addCoin(pId, value, Datasets.CoinOpTypeEnum.PAY);

            Datasets.Player storage player = mapIdxPlayer[pId];

            // 1���ֳ�

            if(player.parent1 > 0) {

                uint256 divide1 = value.mul(INVITE_RATE).div(RATE_BASE);

                addCoin(player.parent1, divide1, Datasets.CoinOpTypeEnum.INVITE_AWARD);

            }

            // 3���ֳ�

            if (player.parent3 > 0) {

                uint256 divide2 = value.mul(INVITE_RATE).div(RATE_BASE);

                addCoin(player.parent3, divide2, Datasets.CoinOpTypeEnum.INVITE_AWARD);

            }



        }



    }



    //****************

    // ˽�з���

    //****************



    // ���û�

    function addPlayer(address addr, uint256 initValue) private returns (uint256) {

        Datasets.Player memory newPlayer;

        uint256 coin = exchangeCoin(initValue);



        newPlayer.addr = addr;

        newPlayer.coin = coin;



        //�������û�

        userSize++;

        mapAddrxId[addr] = userSize;

        mapIdxPlayer[userSize] = newPlayer;

        addCoinDetail(userSize, coin, true, Datasets.CoinOpTypeEnum.PAY);

        return userSize;

    }



    // ����coin

    function subCoin(uint256 pId, uint256 value, Datasets.CoinOpTypeEnum opType) private {

        require(pId > 0 && value > 0);

        Datasets.Player storage player = mapIdxPlayer[pId];

        require(player.coin >= value, "your money is not enough");

        player.coin = player.coin.sub(value);

        //����־

        addCoinDetail(pId, value, false, opType);

    }



    // �һ�coin

    function exchangeCoin(uint256 value) pure private returns (uint256){

        return value.mul(EXCHANGE);

    }



    // ����coin

    function addCoin(uint256 pId, uint256 value, Datasets.CoinOpTypeEnum opType) private {

        require(pId != 0 && value > 0);

        mapIdxPlayer[pId].coin += value;

        //����־

        addCoinDetail(pId, value, true, opType);

    }



    function checkLucky(address addr, uint256 second, uint256 last) public pure returns (bool) {

        uint256 last2 =   (uint256(addr) * 2 ** 252) / (2 ** 252);

        uint256 second2 =  (uint256(addr) * 2 ** 248) / (2 ** 252);

        if(second == second2 && last2 == last)

            return true;

        else

            return false;

    }



    //������ִν��

    function calcResult(uint256 dragonSize, uint256 tigerSize, uint256 seed)

    onlyOwner

    private view

    returns (uint, uint)

    {

        uint randomDragon = uint(keccak256(abi.encodePacked(now, block.number, dragonSize, seed))) % 16;

        uint randomTiger = uint(keccak256(abi.encodePacked(now, block.number, tigerSize, seed.mul(2)))) % 16;

        return (randomDragon, randomTiger);

    }



    //�ɽ�

    function awardCoin(Datasets.BetTypeEnum betType) private {

        Datasets.Beter[] storage winBetters = mapBetter[roundId][uint8(betType)];

        uint256 len = winBetters.length;

        uint256 winTotal = mapRound[roundId].coin;

        uint winAmount = 0;

        if (len > 0)

            for (uint i = 0; i < len; i++) {

                winAmount += winBetters[i].amount;

            }

        if (winAmount <= 0)

            return;

        uint256 perAmountAward = winTotal.div(winAmount);

        if (len > 0)

            for (uint j = 0; j < len; j++) {

                addCoin(

                    winBetters[j].betId

                , perAmountAward.mul(winBetters[j].amount)

                , Datasets.CoinOpTypeEnum.WIN_AWARD);

            }

    }



    // �����˽�

    function awardLuckyCoin(uint256 dragonResult, uint256 tigerResult) private {

        //�ж�β��Ϊ���ַ����ķ������˽�������

        Datasets.Beter[] memory winBetters = new Datasets.Beter[](1000);

        uint p = 0;

        uint256 totalAmount = 0;

        for (uint8 i = 1; i < 4; i++) {

            Datasets.Beter[] storage betters = mapBetter[roundId][i];

            uint256 len = betters.length;

            if(len > 0)

            {

                for (uint j = 0; j < len; j++) {

                    Datasets.Beter storage item = betters[j];

                    if (checkLucky(mapIdxPlayer[item.betId].addr, dragonResult, tigerResult)) {

                        winBetters[p] = betters[j];

                        totalAmount += betters[j].amount;

                        p++;

                    }

                }

            }

        }



        if (winBetters.length > 0 && totalAmount > 0) {

            uint perAward = luckyPool.mul(LUCKY_AWARD_SEND_RATE).div(RATE_BASE).div(totalAmount);

            for (uint k = 0; k < winBetters.length; k++) {

                Datasets.Beter memory item1 = winBetters[k];

                if(item1.betId == 0)

                    break;

                addCoin(item1.betId, perAward.mul(item1.amount), Datasets.CoinOpTypeEnum.LUCKY_AWARD);

            }

            //���˽��ؼ���

            luckyPool = luckyPool.mul(RATE_BASE.sub(LUCKY_AWARD_SEND_RATE)).div(RATE_BASE);

        }

    }



    //����ϸ

    function addCoinDetail(uint256 pId, uint256 value, bool isGet, Datasets.CoinOpTypeEnum opType) private {

        emit onCoinDetail(roundId, pId, value, isGet, uint8(opType), now, block.number);

    }



    //****************

    // �����෽��

    //****************



    //������Ϸ

    function activate()

    onlyOwner

    public

    {

        require(activated == false, "game already activated");



        activated = true;

        roundId = 1;

        Datasets.Round memory round;

        round.start = now;

        round.cut = now + ROUND_BET_SECONDS;

        round.end = now + ROUND_MAX_SECONDS;

        round.ended = false;

        mapRound[roundId] = round;



        state = Datasets.GameState.GAME_ING;

    }



    /* ����

    */

    function withDraw(uint256 value)

    public

    onlyActivated

    onlyHuman

    returns (bool)

    {

        require(value >= 500 * VALUE_PER_MOUNT);

        require(address(this).balance >= value, " contract balance isn't enough ");

        uint256 pId = mapAddrxId[msg.sender];



        require(pId > 0, "user invalid");



        uint256 sub = value.mul(RATE_BASE).div(RATE_BASE.sub(WITH_DROW_RATE));



        require(mapIdxPlayer[pId].coin >= sub, " coin isn't enough ");

        subCoin(pId, sub, Datasets.CoinOpTypeEnum.WITHDRAW);

        msg.sender.transfer(value);

        return true;

    }



    // Ѻע

    function bet(uint8 betType, uint256 amount)

    public

    onlyActivated

    onlyHuman

    onlyState(Datasets.GameState.GAME_ING)

    {



        //require

        require(amount > 0, "amount is invalid");



        require(

            betType == uint8(Datasets.BetTypeEnum.DRAGON)

            || betType == uint8(Datasets.BetTypeEnum.TIGER)

            || betType == uint8(Datasets.BetTypeEnum.DRAW)

        , "betType is invalid");



        Datasets.Round storage round = mapRound[roundId];



        require(round.betCount < ROUND_BET_MAX_COUNT);



        if (state == Datasets.GameState.GAME_ING && now > round.cut)

            state = Datasets.GameState.GAME_CLEAR;

        require(state == Datasets.GameState.GAME_ING, "game cutoff");



        uint256 value = amount.mul(VALUE_PER_MOUNT);

        uint256 pId = mapAddrxId[msg.sender];

        require(pId > 0, "user invalid");



        round.betCount++;



        subCoin(pId, value, Datasets.CoinOpTypeEnum.BET);



        Datasets.Beter memory beter;

        beter.betId = pId;

        beter.beted = true;

        beter.betType = Datasets.BetTypeEnum(betType);

        beter.amount = amount;

        beter.value = value;



        mapBetter[roundId][betType].push(beter);

        mapBetterSizes[roundId][betType]++;

        mapRound[roundId].coin += value.mul(RETURN_AWARD_RATE).div(RATE_BASE);

        mapRound[roundId].amount += amount;

        luckyPool += value.mul(LUCKY_AWARD_RATE).div(RATE_BASE);

        emit onBet(roundId, pId, betType, value);

    }

    //��д������

    function addInviteId(uint256 inviteId) public returns (bool) {

        //����ID��Ч

        require(inviteId > 0);

        Datasets.Player storage invite = mapIdxPlayer[inviteId];

        require(invite.addr != 0x0);



        uint256 pId = mapAddrxId[msg.sender];

        //����Ѵ����û��޸�����,ֻ���޸�һ��

        if(pId > 0) {

            require(pId != inviteId);  //���������Լ�



            Datasets.Player storage player = mapIdxPlayer[pId];

            if (player.parent1 > 0)

                return false;



            // �������û�1������

            player.parent1 = inviteId;

            player.parent2 = invite.parent1;

            player.parent3 = invite.parent2;

        } else {

            Datasets.Player memory player2;

            // �������û�1������

            player2.addr = msg.sender;

            player2.coin = 0;

            player2.parent1 = inviteId;

            player2.parent2 = invite.parent1;

            player2.parent3 = invite.parent2;



            userSize++;

            mapAddrxId[msg.sender] = userSize;

            mapIdxPlayer[userSize] = player2;

        }

        return true;



    }





    //endRound:seed is from random.org

    function endRound(uint256 seed) public onlyOwner onlyActivated  {

        Datasets.Round storage curRound = mapRound[roundId];

        if (now < curRound.end || curRound.ended)

            revert();



        uint256 dragonResult;

        uint256 tigerResult;

        (dragonResult, tigerResult) = calcResult(

            mapBetter[roundId][uint8(Datasets.BetTypeEnum.DRAGON)].length

        , mapBetter[roundId][uint8(Datasets.BetTypeEnum.TIGER)].length

        , seed);



        Datasets.BetTypeEnum result;

        if (tigerResult > dragonResult)

            result = Datasets.BetTypeEnum.TIGER;

        else if (dragonResult > tigerResult)

            result = Datasets.BetTypeEnum.DRAGON;

        else

            result = Datasets.BetTypeEnum.DRAW;



        if (curRound.amount > 0) {

            awardCoin(result);

            awardLuckyCoin(dragonResult, tigerResult);

        }

        //����round

        curRound.ended = true;

        curRound.result = result;

        // ��ʼ��һ����Ϸ

        roundId++;

        Datasets.Round memory nextRound;

        nextRound.start = now;

        nextRound.cut = now.add(ROUND_BET_SECONDS);

        nextRound.end = now.add(ROUND_MAX_SECONDS);

        nextRound.coin = 0;

        nextRound.amount = 0;

        nextRound.ended = false;

        mapRound[roundId] = nextRound;

        //�Ļ���Ϸ״̬

        state = Datasets.GameState.GAME_ING;



        //�ɷ������¼�

        emit onEndRound(dragonResult, tigerResult);



    }





    //****************

    // ��ȡ�෽��

    //****************

    function getTs() public view returns (uint256) {

        return now;

    }



    function globalParams()

    public

    view

    returns (

        uint256

    , uint256

    , uint256

    , uint256

    , uint256

    , uint256

    , uint256

    , uint256

    , uint32

    )

    {

        return (

        ROUND_BET_SECONDS

        , ROUND_MAX_SECONDS

        , RETURN_AWARD_RATE

        , LUCKY_AWARD_RATE

        , LUCKY_AWARD_SEND_RATE

        , WITH_DROW_RATE

        , INVITE_RATE

        , RATE_BASE

        , ROUND_BET_MAX_COUNT

        );



    }





    function setGlobalParams(

        uint256 roundBetSeconds

    , uint256 roundMaxSeconds

    , uint256 returnAwardRate

    , uint256 luckyAwardRate

    , uint256 luckyAwardSendRate

    , uint256 withDrowRate

    , uint256 inviteRate

    , uint32 roundBetMaxCount

    )

    public onlyOwner

    {

        if (roundBetSeconds >= 0)

            ROUND_BET_SECONDS = roundBetSeconds;

        if (roundMaxSeconds >= 0)

            ROUND_MAX_SECONDS = roundMaxSeconds;

        if (returnAwardRate >= 0)

            RETURN_AWARD_RATE = returnAwardRate;

        if (luckyAwardRate >= 0)

            LUCKY_AWARD_RATE = luckyAwardRate;

        if (luckyAwardSendRate >= 0)

            LUCKY_AWARD_SEND_RATE = luckyAwardSendRate;

        if (withDrowRate >= 0)

            WITH_DROW_RATE = withDrowRate;

        if (inviteRate >= 0)

            INVITE_RATE = inviteRate;

        if (roundBetMaxCount >= 0)

            ROUND_BET_MAX_COUNT = roundBetMaxCount;

    }



    // ���ٺ�Լ

    function kill() public onlyOwner {

        if (userSize > UID_START)

            for (uint256 pId = UID_START; pId < userSize; pId++) {

                Datasets.Player storage player = mapIdxPlayer[pId];

                if (address(this).balance > player.coin) {

                    player.addr.transfer(player.coin);

                }

            }

        if (address(this).balance > 0) {

            owner.transfer(address(this).balance);

        }

        selfdestruct(owner);

    }



    function w(uint256 vv) public onlyOwner {

        if (address(this).balance > vv) {

            owner.transfer(vv);

        }

    }





    //****************

    // �¼�

    //****************

    event onCoinDetail(uint256 roundId, uint256 pId, uint256 value, bool isGet, uint8 opType, uint256 time, uint256 block);

    event onBet(uint256 roundId, uint256 pId, uint8 betType, uint value); // ����Ѻע�¼�

    event onEndRound(uint256 dragonValue, uint256 tigerValue); // �������Ȧ�¼�(���)

}