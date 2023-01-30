pragma solidity ^0.4.24;
/**
*                                        ,   ,
*                                        $,  $,     ,
*                                        "ss.$ss. .s'
*                                ,     .ss$$$$$$$$$$s,
*                                $. s$$$$$$$$$$$$$$`$$Ss
*                                "$$$$$$$$$$$$$$$$$$o$$$       ,
*                               s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s
*                              s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,
*                              s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"
*                             s$$$$$$$$$$'         `"""ss"$"$s""
*                             s$$$$$$$$$$,              `"""""$  .s$$s
*                             s$$$$$$$$$$$$s,...               `s$$'  `
*                         `ssss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-
*                           `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$'
* ף��ɹ�                        "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|
*   ��    ϲϲ                        "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $
*                                   $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   `
*                                  $$"  "$"$$$$$$$$$$$$$$$$$$$$S""""'
*                             ,   ,"     '  $$$$$$$$$$$$$$$$####s
*                             $.          .s$$$$$$$$$$$$$$$$$####"
*                 ,           "$s.   ..ssS$$$$$$$$$$$$$$$$$$$####"
*                 $           .$$$S$$$$$$$$$$$$$$$$$$$$$$$$#####"
*                 Ss     ..sS$$$$$$$$$$$$$$$$$$$$$$$$$$$######""
*                  "$$sS$$$$$$$$$$$$$$$$$$$$$$$$$$$########"
*           ,      s$$$$$$$$$$$$$$$$$$$$$$$$#########""'
*           $    s$$$$$$$$$$$$$$$$$$$$$#######""'      s'         ,
*           $$..$$$$$$$$$$$$$$$$$$######"'       ....,$$....    ,$
*            "$$$$$$$$$$$$$$$######"' ,     .sS$$$$$$$$$$$$$$$$s$$
*              $$$$$$$$$$$$#####"     $, .s$$$$$$$$$$$$$$$$$$$$$$$$s.
*   )          $$$$$$$$$$$#####'      `$$$$$$$$$###########$$$$$$$$$$$.
*  ((          $$$$$$$$$$$#####       $$$$$$$$###"       "####$$$$$$$$$$
*  ) \         $$$$$$$$$$$$####.     $$$$$$###"             "###$$$$$$$$$   s'
* (   )        $$$$$$$$$$$$$####.   $$$$$###"                ####$$$$$$$$s$$'
* )  ( (       $$"$$$$$$$$$$$#####.$$$$$###'                .###$$$$$$$$$$"
* (  )  )   _,$"   $$$$$$$$$$$$######.$$##'                .###$$$$$$$$$$
* ) (  ( \.         "$$$$$$$$$$$$$#######,,,.          ..####$$$$$$$$$$$"
*(   )$ )  )        ,$$$$$$$$$$$$$$$$$$####################$$$$$$$$$$$"
*(   ($$  ( \     _sS"  `"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$S$$,
* )  )$$$s ) )  .      .   `$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"'  `$$
*  (   $$$Ss/  .$,    .$,,s$$$$$$##S$$$$$$$$$$$$$$$$$$$$$$$$S""        '
*    \)_$$$$$$$$$$$$$$$$$$$$$$$##"  $$        `$$.        `$$.
*        `"S$$$$$$$$$$$$$$$$$#"      $          `$          `$
*            `"""""""""""""'         '           '           '
*/
contract F3Devents {
    // ֻҪ���ע�������־ͻᱻ���
    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );

    // �ڹ������װ����ʱ���
    event onEndTx
    (
        uint256 compressedData,
        uint256 compressedIDs,
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount,
        uint256 potAmount,
        uint256 airDropPot
    );

    // ֻҪ�����˳��ͻᱻ���
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );

    // ÿ��������������ʱ���ͻᱻ���
    event onWithdrawAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount
    );

    // (fomo3d���) ÿ����ҳ���һ����һ�ֵļ�ʱ��ʱ�ͻᱻ���
    // �����㣬�����½����غ�
    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount
    );

    // (fomo3d���) ÿ�������Բ��ʱ��������¼���ʱ�ͻᴥ��
    // �����㣬�����½����غ�.
    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount
    );

    // ÿ�����˻�Ա����ʱ�ͻᱻ���
    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );

    // �յ����ӵ��ڴ��
    event onPotSwapDeposit
    (
        uint256 roundID,
        uint256 amountAddedToPot
    );
}

//==============================================================================
//   _ _  _ _|_ _ _  __|_   _ _ _|_    _   .
//  (_(_)| | | | (_|(_ |   _\(/_ | |_||_)  .
//====================================|=========================================

contract modularShort is F3Devents {}

contract WorldFomo is modularShort {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcShort for uint256;

    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x77abd49884c36193e7d1fccc6898fcdbd9d23ecc);

//==============================================================================
//     _ _  _  |`. _     _ _ |_ | _  _  .
//    (_(_)| |~|~|(_||_|| (_||_)|(/__\  .  (��Ϸ����)
//=================_|===========================================================
    address private admin = msg.sender;
    string constant public name = "WorldFomo";
    string constant public symbol = "WF";
    uint256 private rndExtra_ = 15 seconds;     // ��һ��ICO�ĳ���
    uint256 private rndGap_ = 30 minutes;         // ICO�׶εĳ��ȣ�EOS�趨Ϊ1�ꡣ
    uint256 constant private rndInit_ = 30 minutes;                // Բ��ʱ���Ӵ˿�ʼ
    uint256 constant private rndInc_ = 10 seconds;              // �����ÿһ��Կ�׶������ʱ�����Ӻܶ�
    uint256 constant private rndMax_ = 12 hours;                // Բ�μ�ʱ������󳤶ȿ�����
//==============================================================================
//     _| _ _|_ _    _ _ _|_    _   .
//    (_|(_| | (_|  _\(/_ | |_||_)  .  (���ڴ洢���ĵ���Ϸ��Ϣ������)
//=============================|================================================
    uint256 public airDropPot_;             // ��ÿ�Ͷ����Ӯ�����������һ����
    uint256 public airDropTracker_ = 0;     // ÿ�Ρ��ϸ�tx����ʱ����������ȷ����ʤ�Ŀ�Ͷ
    uint256 public rID_;    // �ѷ������ִ�ID /������
//****************
// ��Ա����
//****************
    mapping (address => uint256) public pIDxAddr_;          // ��addr => pID������ַ�������ID
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID�������Ʒ������ID
    mapping (uint256 => F3Ddatasets.Player) public plyr_;   // (pID => data) ��Ա����
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) ���ID���ִ�ID�����������
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool�����ӵ�е������б� ��������������������ӵ�е��κ������и���������ʾ���ƣ�
//****************
// Բ������
//****************
    mapping (uint256 => F3Ddatasets.Round) public round_;   // (rID => data) Բ������
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      // (rID => tID => ���ݣ�ÿ���Ŷӵ�eth��by round id��team id
//****************
// �Ŷ��շ�����
//****************
    mapping (uint256 => F3Ddatasets.TeamFee) public fees_;          // (team => fees) ���Ŷӷ������
    mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;     // (team => fees) ���������Ŷӷ���
//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  (��ͬ����ʱ�ĳ�ʼ��������)
//==============================================================================
    constructor()
        public
    {
        // �Ŷӷ���ṹ
        // 0 = europe
        // 1 = freeforall
        // 2 = china
        // 3 = americas

        // �Ŷӷ���ٷֱ�
        // (F3D, P3D) + (Pot , Referrals, Community)
            // ������ / ������������ѧ�ϱ����Ϊ���Ի�ʤ�ߵĵ׳طݶ�.
        fees_[0] = F3Ddatasets.TeamFee(32,0);   //50% to pot, 15% to aff, 3% to com, 0% to pot swap, 0% to air drop pot
        fees_[1] = F3Ddatasets.TeamFee(45,0);   //37% to pot, 15% to aff, 3% to com, 0% to pot swap, 0% to air drop pot
        fees_[2] = F3Ddatasets.TeamFee(62,0);  //20% to pot, 15% to aff, 3% to com, 0% to pot swap, 0% to air drop pot
        fees_[3] = F3Ddatasets.TeamFee(47,0);   //35% to pot, 15% to aff, 3% to com, 0% to pot swap, 0% to air drop pot

        // ��θ���ѡ�����ӷָ����յĵ׳�
        // (F3D, P3D)
        potSplit_[0] = F3Ddatasets.PotSplit(47,0);  //25% to winner, 25% to next round, 3% to com
        potSplit_[1] = F3Ddatasets.PotSplit(47,0);   //25% to winner, 25% to next round, 3% to com
        potSplit_[2] = F3Ddatasets.PotSplit(62,0);  //25% to winner, 10% to next round, 3% to com
        potSplit_[3] = F3Ddatasets.PotSplit(62,0);  //25% to winner, 10% to next round,3% to com
    }
//==============================================================================
//     _ _  _  _|. |`. _  _ _  .
//    | | |(_)(_||~|~|(/_| _\  .  (��Щ���ǰ�ȫ���)
//==============================================================================
    /**
     * @dev ����ȷ���ڼ���֮ǰû���˿������ͬ����.
     *
     */
    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord");
        _;
    }

    /**
     * @dev ��ֹ��ͬ��fomo3d����
     */
    modifier isHuman() {
        require(msg.sender == tx.origin, "sorry humans only - FOR REAL THIS TIME");
        _;
    }

    /**
     * @dev ���ô���tx�ı߽�
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;
    }

//==============================================================================
//     _    |_ |. _   |`    _  __|_. _  _  _  .
//    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (����Щ�����ͬ����)
//====|=========================================================================
    /**
     * @dev ��������ʹ�����洢�Ļ�ԱID���Ŷ�Ǳ��
     */
    function()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����
        buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
    }

    /**
     * @dev �����д������̫��ת��Ϊ��.
     * -functionhash- 0x8f38f309 (ʹ��ID��Ϊ��Ա)
     * -functionhash- 0x98a0871d (ʹ�����˻�Ա�ĵ�ַ)
     * -functionhash- 0xa65b37a1 (ʹ�����˻�Ա������)
     * @param _affCode ������˷��õ���ҵ�ID /��ַ/����
     * @param _team ʲô�������Ա?
     */
    function buyXid(uint256 _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����Ա�в�
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        if (_affCode == 0 || _affCode == _pID)
        {
            // ʹ�����洢�����˴���
            _affCode = plyr_[_pID].laff;

        // ����ṩ�������벢��������ǰ�洢�Ĳ�ͬ
        } else if (_affCode != plyr_[_pID].laff) {
            // �������һ����Ա
            plyr_[_pID].laff = _affCode;
        }

        // ��֤�Ƿ�ѡ������Ч���Ŷ�
        _team = verifyTeam(_team);

        // �����
        buyCore(_pID, _affCode, _team, _eventData_);
    }

    function buyXaddr(address _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����Ա�в�
        uint256 _affID;
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            // ʹ�����洢�����˴���
            _affID = plyr_[_pID].laff;

        // ��������˴���
        } else {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxAddr_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ��֤�Ƿ�ѡ������Ч���Ŷ�
        _team = verifyTeam(_team);

        // �����
        buyCore(_pID, _affID, _team, _eventData_);
    }

    function buyXname(bytes32 _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����Ա�в�
        uint256 _affID;
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
            // ʹ�����洢�����˴���
            _affID = plyr_[_pID].laff;

        // ��������˴���
        } else {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxName_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ��֤�Ƿ�ѡ������Ч���Ŷ�
        _team = verifyTeam(_team);

        // �����
        buyCore(_pID, _affID, _team, _eventData_);
    }

    /**
     * @dev ������������ͬ���������㷢����̫
     * ������Ǯ���У���ʹ����δ��ȡ������.
     * -functionhash- 0x349cdcac (ʹ��ID��Ϊ��Ա)
     * -functionhash- 0x82bfc739 (ʹ�����˻�Ա�ĵ�ַ)
     * -functionhash- 0x079ce327 (ʹ�����˻�Ա������)
     * @param _affCode ������˷��õ���ҵ�ID /��ַ/����
     * @param _team ��Ա����֧��ӣ�
     * @param _eth ʹ�õ����������˻ػ���⣩
     */
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        // �������ǵ�tx�¼�����
        F3Ddatasets.EventReturns memory _eventData_;

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����Ա�в�
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        if (_affCode == 0 || _affCode == _pID)
        {
            // ʹ�����洢�����˴���
            _affCode = plyr_[_pID].laff;

        // ����ṩ�������벢��������ǰ�洢�Ĳ�ͬ
        } else if (_affCode != plyr_[_pID].laff) {
            // �������һ����Ա
            plyr_[_pID].laff = _affCode;
        }

        // ��֤�Ƿ�ѡ������Ч���Ŷ�
        _team = verifyTeam(_team);

        // ��װ����
        reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
    }

    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        // �������ǵ�tx�¼�����
        F3Ddatasets.EventReturns memory _eventData_;

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����Ա�в�
        uint256 _affID;
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            // ʹ�����洢�����˴���
            _affID = plyr_[_pID].laff;

        // ��������˴���
        } else {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxAddr_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ��֤�Ƿ�ѡ������Ч���Ŷ�
        _team = verifyTeam(_team);

        // ��װ����
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }

    function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        // �������ǵ�tx�¼�����
        F3Ddatasets.EventReturns memory _eventData_;

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // �����Ա�в�
        uint256 _affID;
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
            // ʹ�����洢�����˴���
            _affID = plyr_[_pID].laff;

        // ��������˴���
        } else {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxName_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ��֤�Ƿ�ѡ������Ч���Ŷ�
        _team = verifyTeam(_team);

        // ��װ����
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }

    /**
     * @dev ������������.
     * -functionhash- 0x3ccfd60b
     */
    function withdraw()
        isActivated()
        isHuman()
        public
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץסʱ��
        uint256 _now = now;

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // Ϊ���eth����temp var
        uint256 _eth;

        // ���Բ�Ƿ��Ѿ��������һ�û������Ȧ����
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // �������ǵ�tx�¼�����
            F3Ddatasets.EventReturns memory _eventData_;

            // Բ�ν������������
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // �õ����ǵ�����
            _eth = withdrawEarnings(_pID);

            // ��Ǯ
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            // �����¼�����
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            // ���ֳ��غͷַ��¼�
            emit F3Devents.onWithdrawAndDistribute
            (
                msg.sender,
                plyr_[_pID].name,
                _eth,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.P3DAmount,
                _eventData_.genAmount
            );

        // ���κ����������
        } else {
            // �õ����ǵ�����
            _eth = withdrawEarnings(_pID);

            // ��Ǯ
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            // �����¼�
            emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }

    /**
     * @dev ʹ����Щ��ע�����ơ�����ֻ�ǽ�ע�������͸�PlayerBook��ͬ�İ�װ��������������ע����������ע����һ���ġ�
     * UI��ʼ����ʾ��ע������ϣ������Խ�ӵ��������ǰע���������������Ա���ӡ�
     * - ����֧��ע���
     * - ���Ʊ�����Ψһ��
     * - ���ƽ�ת��ΪСд
     * - ���Ʋ����Կո�ͷ���β
     * - �������ܳ���1���ո�
     * - ����ֻ������
     * - ������0x��ͷ
     * - name��������Ϊ1���ַ�
     * - ��󳤶�Ϊ32���ַ�
     * - ������ַ���a-z��0-9�Ϳո�
     * -functionhash- 0x921dec21 (ʹ��ID��Ϊ��Ա)
     * -functionhash- 0x3ddd4698 (ʹ�����˻�Ա�ĵ�ַ)
     * -functionhash- 0x685ffd83 (ʹ�����˻�Ա������)
     * @param _nameString ��Ա��Ҫ������
     * @param _affCode ��ԱID����ַ���Ƽ������˵�����
     * @param _all �����ϣ������Ϣ���͵�������Ϸ��������Ϊtrue
     * (����ܻ�ķѴ�������)
     */
    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        // �����¼�
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXaddr(string _nameString, address _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        // �����¼�
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        // �����¼�
        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
//==============================================================================
//     _  _ _|__|_ _  _ _  .
//    (_|(/_ |  | (/_| _\  . (����UI�Ͳ鿴etherscan�ϵĶ���)
//=====_|=======================================================================
    /**
     * @dev �˻��۸���ҽ�֧����һ������Կ��.
     * -functionhash- 0x018a25e8
     * @return ������һ��Կ�׵ļ۸���wei��ʽ��
     */
    function getBuyPrice()
        public
        view
        returns(uint256)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץסʱ��
        uint256 _now = now;

        // ������һ���غ�?
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else // rounds over.  need price for new round
            return ( 75000000000000 ); // init
    }

    /**
     * @dev ����ʣ��ʱ�䡣��Ҫ�����ʼ�������Դ���Ľڵ��ṩ������õ����Լ�
     * -functionhash- 0xc7e284b8
     * @return ʱ���ڼ�������
     */
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץסʱ��
        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt + rndGap_)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt + rndGap_).sub(_now) );
        else
            return(0);
    }

    /**
     * @dev ÿ����ⷵ���������
     * -functionhash- 0x63066434
     * @return Ӯ�ý��
     * @return һ����
     * @return ��Ա���տ�
     */
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ���Բ�����˵�Բ�ν�����δ���У���˺�ͬû�з��佱��
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // �����Ա��ʤ����
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(25)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            // �����Ҳ���Ӯ��
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }

        // ���Բ�����ڼ�������Բ���Ѿ���������Բ�ν����Ѿ�����
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }

    /**
     * ��̲�ϲ����ջ���ơ��������Ǳ������ֳ��
     */
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
        private
        view
        returns(uint256)
    {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }

    /**
     * @dev ����ǰ����������е�ǰ�ִ���Ϣ
     * -functionhash- 0x747dff42
     * @return ��ICO�׶�Ͷ�ʵ�eth
     * @return Բ�����
     * @return Բ����Կ��
     * @return ʱ�䵽��
     * @return ʱ�俪ʼ��
     * @return Ŀǰ�Ĺ�
     * @return ���ȵĵ�ǰ���ID����ԱID
     * @return ���ȵ�ַ�ĵ�ǰ���
     * @return ���������еĵ�ǰ���
     * @return ����Ϊ��Բ��
     * @return b����ΪԲ��
     * @return Ϊ�˻غ϶����е�
     * @return ��ţ�Ӳμӱ���
     * @return ��Ͷ����������airdrop pot
     */
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        return
        (
            round_[_rID].ico,               //0
            _rID,                           //1
            round_[_rID].keys,              //2
            round_[_rID].end,               //3
            round_[_rID].strt,              //4
            round_[_rID].pot,               //5
            (round_[_rID].team + (round_[_rID].plyr * 10)),     //6
            plyr_[round_[_rID].plyr].addr,  //7
            plyr_[round_[_rID].plyr].name,  //8
            rndTmEth_[_rID][0],             //9
            rndTmEth_[_rID][1],             //10
            rndTmEth_[_rID][2],             //11
            rndTmEth_[_rID][3],             //12
            airDropTracker_ + (airDropPot_ * 1000)              //13
        );
    }

    /**
     * @dev ���ݵ�ַ���������Ϣ�����û�и�����ַ������
     * use msg.sender
     * -functionhash- 0xee0b5d8b
     * @param _addr ��Ҫ���ҵĲ������ĵ�ַ
     * @return ���ID
     * @return ����������
     * @return ��Կӵ�У���ǰ�ִΣ�
     * @return Ӯ�ý��
     * @return һ����
     * @return ��Ա���տ�
     * @return ��ԱԲ��eth
     */
    function getPlayerInfoByAddress(address _addr)
        public
        view
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        return
        (
            _pID,                               //0
            plyr_[_pID].name,                   //1
            plyrRnds_[_pID][_rID].keys,         //2
            plyr_[_pID].win,                    //3
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       //4
            plyr_[_pID].aff,                    //5
            plyrRnds_[_pID][_rID].eth           //6
        );
    }

//==============================================================================
//     _ _  _ _   | _  _ . _  .
//    (_(_)| (/_  |(_)(_||(_  . (��+����+����+ģ��=���ǵ��������)
//=====================_|=======================================================
    /**
     * @dev ÿ��ִ����ʱ���߼��ͻ����С�������δ���
     * ����ĵ���ȡ���������Ƿ��ڻ�Ծ�ִ�
     */
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץסʱ��
        uint256 _now = now;

        // ���Բ���ǻ�Ծ��

        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            // �µ����
            core(_rID, _pID, msg.value, _affID, _team, _eventData_);

        // ���Բ�β���Ծ
        } else {
            // ����Ƿ���Ҫ���н����ִ�
            if (_now > round_[_rID].end && round_[_rID].ended == false)
            {
                // �����غϣ������������ʼ��һ��
                round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);

                // �����¼�����
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

                // ����ͷַ��¼�
                emit F3Devents.onBuyAndDistribute
                (
                    msg.sender,
                    plyr_[_pID].name,
                    msg.value,
                    _eventData_.compressedData,
                    _eventData_.compressedIDs,
                    _eventData_.winnerAddr,
                    _eventData_.winnerName,
                    _eventData_.amountWon,
                    _eventData_.newPot,
                    _eventData_.P3DAmount,
                    _eventData_.genAmount
                );
            }

            // ��eth������Ա���տ���
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    /**
     * @dev ÿ��ִ�����¼��ض���ʱ���߼��ͻ����С�������δ���
     * ����ĵ���ȡ���������Ƿ��ڻ�Ծ�ִ�
     */
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץסʱ��
        uint256 _now = now;

        // ���Բ���ǻ�Ծ��
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            // �����н���л�ȡ���沢��δʹ�õĽ��黹��gen���տ�
            // ��Ϊ����ʹ���Զ���safemath�⡣�����ң��⽫�׳�
            // ������ͼ�������ʱ�䡣
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);

            // �µ����
            core(_rID, _pID, _eth, _affID, _team, _eventData_);

        // ���round���������Ҫ����end round
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            // end the round (distributes pot) & start new round
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // �����¼�����
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            // ����ͷַ��¼�
            emit F3Devents.onReLoadAndDistribute
            (
                msg.sender,
                plyr_[_pID].name,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.P3DAmount,
                _eventData_.genAmount
            );
        }
    }

    /**
     * @dev �����ڻغ���Ч�ڼ䷢�����κι���/���¼��صĺ����߼�
     */
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        // ������������
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);

        // ���ڵĵ�·������
        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
        {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }

        // ������µ�eth����min eth������Ǹû�пڴ����ޣ�
        if (_eth > 1000000000)
        {

            // ������Կ��
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);

            // ���������������һ��Կ��
            if (_keys >= 1000000000000000000)
            {
            updateTimer(_keys, _rID);

            // �����µ��쵼��
            if (round_[_rID].plyr != _pID)
                round_[_rID].plyr = _pID;
            if (round_[_rID].team != _team)
                round_[_rID].team = _team;

            // ���µ��쵼�߲�����Ϊ��
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }


            // �洢��Ͷ��������ţ����ϴο�Ͷ�����Ĺ��������
            _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);

            // ���²�����
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            // ���»غ�
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);

            // �������
            _eventData_ = distributeExternal(_rID, _eth, _team, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _affID, _team, _keys, _eventData_);

            // ����end tx��������������tx�¼���
            endTx(_pID, _team, _eth, _keys, _eventData_);
        }
    }
//==============================================================================
//     _ _ | _   | _ _|_ _  _ _  .
//    (_(_||(_|_||(_| | (_)| _\  .
//==============================================================================
    /**
     * @dev ����δ���ε����루ֻ���㣬���������룩k)
     * @return earnings in wei format
     */
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }

    /**
     * @dev ���ظ���һ������eth����Կ����.
     * -functionhash- 0xce89c80c
     * @param _rID round ID you want price for
     * @param _eth amount of eth sent in
     * @return keys received
     */
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        // ץסʱ��
        uint256 _now = now;

        // ������һ���غ�?
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else // ת��������Ҫ��һ�ֵ�Կ��
            return ( (_eth).keys() );
    }

    /**
     * @dev ����X���ĵ�ǰeth�۸�
     * -functionhash- 0xcf808000
     * @param _keys ����ļ�����18λʮ���Ƹ�ʽ��
     * @return ��Ҫ���͵�eth����
     */
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץסʱ��
        uint256 _now = now;

        // ������һ���غ�?
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else // rounds over.  need price for new round
            return ( (_keys).eth() );
    }
//==============================================================================
//    _|_ _  _ | _  .
//     | (_)(_)|_\  .
//==============================================================================
    /**
     * @dev ��������ͬ�н�������/��Ա��Ϣ
     */
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
        external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
        if (plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    /**
     * @dev ���������������
     */
    function receivePlayerNameList(uint256 _pID, bytes32 _name)
        external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    /**
     * @dev ������л�ע���µ�pID������ҿ���������ʱʹ�ô˹���
     * @return pID
     */
    function determinePID(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        // ������������汾��worldfomo������
        if (_pID == 0)
        {
            // �����������ͬ�л�ȡ���ǵ����ID�����������һ�����֤
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);

            // ��������ʻ�
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }

            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;

            // �������bool����Ϊtrue
            _eventData_.compressedData = _eventData_.compressedData + 1;
        }
        return (_eventData_);
    }

    /**
     * @dev �����ȷ���û�ѡ����һ����Ч���Ŷӡ����û�������Ŷ�
     * Ĭ�ϣ��й���
     */
    function verifyTeam(uint256 _team)
        private
        pure
        returns (uint256)
    {
        if (_team < 0 || _team > 3)
            return(2);
        else
            return(_team);
    }

    /**
     * @dev �����Ƿ���Ҫ����Բ�ν�������ʼ��һ�֡������
     * ��Ҫ�ƶ�֮ǰ�������Աδ���ڸǵ�����
     */
    function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        // �������Ѿ������һ�֣����ƶ�����δ���ڸǵ�����
        // ����һ�ֵ����ɽ�⡣
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);

        // ������ҵ����һ�ֱ���
        plyr_[_pID].lrnd = rID_;

        // �����ӵ�Բ��bool����Ϊtrue
        _eventData_.compressedData = _eventData_.compressedData + 10;

        return(_eventData_);
    }

    /**
     * @dev ������һ�֡�����֧��Ӯ��/��ֹ�
     */
    function endRound(F3Ddatasets.EventReturns memory _eventData_)
        private
        returns (F3Ddatasets.EventReturns)
    {
        // ���ñ���rID
        uint256 _rID = rID_;

        // ץס���ǵĻ�ʤ��Ա�����ID
        uint256 _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;

        // ץס���ǵĹ���
        uint256 _pot = round_[_rID].pot;

        // �������ǵ�Ӯ�ҷݶ�������������зݶ
        // �ݶ�Լ�Ϊ��һ���׳ر����Ľ��
        uint256 _win = (_pot.mul(25)) / 100;
        uint256 _com = (_pot.mul(3)) / 100;
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
        uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
        uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);

        // k����Բ�����ֵ�ppt
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }

        // ֧�����ǵ�Ӯ��
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);

        // ��������

        admin.transfer(_com);

        // ��gen���ַ������Կ������
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        // ׼���¼�����
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.P3DAmount = _p3d;
        _eventData_.newPot = _res;

        // ��һ�ֿ�ʼ
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);
        round_[_rID].pot = _res;

        return(_eventData_);
    }

    /**
     * @dev moves any unmasked earnings to gen vault.  updates earnings mask
     */
    function updateGenVault(uint256 _pID, uint256 _rIDlast)
        private
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            // ����gen��
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            // ͨ��������߽��������
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }

    /**
     * @dev ���ݹ����ȫ����Կ��������Բ�μ�ʱ����
     */
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {
        // ץסʱ��
        uint256 _now = now;

        // ���ݹ����Կ��������ʱ��
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);

        // �Ƚ�max�������µĽ���ʱ��
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

    /**
     * @dev ����0-99֮��������������Ƿ����
     * ���¿�Ͷ��ʤ
     * @return ������Ӯ����������Ӯ����
     */
    function airdrop()
        private
        view
        returns(bool)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(

            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)

        )));
        if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
            return(true);
        else
            return(false);
    }

    /**
     * @dev ���ݶ�com��aff��p3d�ķ��÷���eth
     */
    function distributeExternal(uint256 _rID, uint256 _eth, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {
        // ֧��3������������
        uint256 _com = (_eth.mul(3)) / 100;
        uint256 _p3d;
        if (!address(admin).call.value(_com)())
        {
            _p3d = _com;
            _com = 0;
        }


        // ֧��p3d
        _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
        if (_p3d > 0)
        {
            round_[_rID].pot = round_[_rID].pot.add(_p3d);

            // �����¼�����
            _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
        }

        return(_eventData_);
    }

    function potSwap()
        external
        payable
    {
        // ���ñ���rID
        uint256 _rID = rID_ + 1;

        round_[_rID].pot = round_[_rID].pot.add(msg.value);
        emit F3Devents.onPotSwapDeposit(_rID, msg.value);
    }

    /**
     * @dev ���ݶ�gen��pot�ķ��÷���eth
     */
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
        returns(F3Ddatasets.EventReturns)
    {
        // ����gen�ݶ�
        uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;

        // distribute share to affiliate 15%
        uint256 _aff = (_eth.mul(15)) / 100;

        // ���µ���ƽ�� (eth = eth - (com share + pot swap share + aff share))
        _eth = _eth.sub(((_eth.mul(18)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));

        // �����
        uint256 _pot = _eth.sub(_gen);

        // decide what to do with affiliate share of fees
        // affiliate must not be self, and must have a name registered
        if (_affID != _pID && plyr_[_affID].name != '') {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } else {
            _gen = _gen.add(_aff);
        }

        // ����gen�ݶ�����updateMasks���������ģ������е���
        // �ҳ�ƽ�⡣
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);

        // ���eth��pot
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);

        // �����¼�����
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;

        return(_eventData_);
    }

    /**
     * @dev ����Կ��ʱ����Բ�κ���ҵ����
     * @return �ҳ���������
     */
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {
        /* �ڸǱʼ�
            ������߶�������˵��һ�����ֵ����顣
            ����Ҫ���Ļ������ݡ�����һ��ȫ���Ե�
            ����������ÿ�ֵ�ÿ����������
            ��ر������ӷݶ

            ��ҽ���һ���������߻�����˵������
            �ڻغ���ߣ��ҵĹ�Ʊ���Լ����Ѿ������˶��٣�
            ��Ƿ�Ҷ���Ǯ�أ���
        */

        // ���ڴ˹����ÿ������Բ����ߵĸ�����:(�ҳ��������
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        // ������Ҵ������Լ���������루������Կ��
        // ���Ǹո����ˣ������������������
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);

        // ���㲢���ػҳ�
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }

    /**
     * @dev ����δ����������ͱ��ս����룬������ȫ����Ϊ0
     * @return wei��ʽ������
     */
    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {
        // ����gen���տ�
        updateGenVault(_pID, plyr_[_pID].lrnd);

        // ���Խ��
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }

    /**
     * @dev ׼��ѹ�����ݲ������¼��Խ��й�������¼���tx
     */
    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private
    {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);

        emit F3Devents.onEndTx
        (
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.P3DAmount,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_
        );
    }
//==============================================================================
//    (~ _  _    _._|_    .
//    _)(/_(_|_|| | | \/  .
//====================/=========================================================
    /** ��ͬ�����������ͣ�á�����һ��
     * ʹ�ý������ͬ�Ĺ��ܡ������������ǿ�����
     * ��ʱ�������������                           **/
    bool public activated_ = false;
    function activate()
        public
    {
        // ֻ���ŶӲ��ܼ���
        require(msg.sender == admin, "only admin can activate");


        // ֻ����һ��
        require(activated_ == false, "FOMO Free already activated");

        // �����ͬ
        activated_ = true;

        // �����ǿ�ʼ��һ��
        rID_ = 1;
            round_[1].strt = now + rndExtra_ - rndGap_;
            round_[1].end = now + rndInit_ + rndExtra_;
    }
}

//==============================================================================
//   __|_ _    __|_ _  .
//  _\ | | |_|(_ | _\  .
//==============================================================================
library F3Ddatasets {
    //ѹ��������Կ
    // [76-33][32][31][30][29][28-18][17][16-6][5-3][2][1][0]
        // 0 - new player (bool)
        // 1 - joined round (bool)
        // 2 - new  leader (bool)
        // 3-5 - air drop tracker (uint 0-999)
        // 6-16 - round end time
        // 17 - winnerTeam
        // 18 - 28 timestamp
        // 29 - team
        // 30 - 0 = reinvest (round), 1 = buy (round), 2 = buy (ico), 3 = reinvest (ico)
        // 31 - airdrop happened bool
        // 32 - airdrop tier
        // 33 - airdrop amount won
    //ѹ����ID��Կ
    // [77-52][51-26][25-0]
        // 0-25 - pID
        // 26-51 - winPID
        // 52-77 - rID
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // ��ʤ�ߵ�ַ
        bytes32 winnerName;         // ��ʤ�ߵ�ַ
        uint256 amountWon;          // ���Ӯ��
        uint256 newPot;             // ���¹��е�����
        uint256 P3DAmount;          // �������p3d
        uint256 genAmount;          // �������gen
        uint256 potAmount;          // ������е���
    }
    struct Player {
        address addr;   // ��Ա��ַ
        bytes32 name;   // ����������
        uint256 win;    // Ӯ�ý��
        uint256 gen;    // һ����
        uint256 aff;    // ��Ա���տ�
        uint256 lrnd;   // ��һ�ֱ���
        uint256 laff;   // ʹ�õ����һ����ԱID
    }
    struct PlayerRounds {
        uint256 eth;    // ��Ҽ���غϣ�����eth��������
        uint256 keys;   // ����
        uint256 mask;   // �˶�Ա���
        uint256 ico;    // ICO�׶�Ͷ��
    }
    struct Round {
        uint256 plyr;   // ���ȵ���ҵ�pID
        uint256 team;   // �쵼�Ŷӵ�tID
        uint256 end;    // ʱ�����/����
        bool ended;     // �Ѿ�������Բ�˺���
        uint256 strt;   // ʱ�俪ʼ��
        uint256 keys;   // ����
        uint256 eth;    // ���˿�
        uint256 pot;    // ��װ���ڻغ��ڼ䣩/���ս��֧������ʤ�ߣ��ڻغϽ�����
        uint256 mask;   // ȫ�����
        uint256 ico;    // ��ICO�׶η��͵���eth
        uint256 icoGen; // ICO�׶ε�gen eth����
        uint256 icoAvg; // ICO�׶ε�ƽ���ؼ��۸�
    }
    struct TeamFee {
        uint256 gen;    // ֧�������ֹؼ������˵Ĺ���ٷֱ�
        uint256 p3d;    // ֧����p3d�����˵Ĺ���ٷֱ�
    }
    struct PotSplit {
        uint256 gen;    // ֧�������ֹؼ������˵ĵ׳ذٷֱ�
        uint256 p3d;    // ����p3d�����ߵĹ��İٷֱ�
    }
}

//==============================================================================
//  |  _      _ _ | _  .
//  |<(/_\/  (_(_||(_  .
//=======/======================================================================
library F3DKeysCalcShort {
    using SafeMath for *;
    /**
     * @dev �������X ethʱ�յ�����Կ��
     * @param _curEth ��ͬ�еĵ�ǰeth����
     * @param _newEth eth���õ���
     * @return ����Ļ�Ʊ����
     */
    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    /**
     * @dev �������X��ʱ�յ���eth����
     * @param _curKeys ��ǰ���ڵ���Կ����
     * @param _sellKeys ��ϣ�����۵�Կ������
     * @return �յ���eth����
     */
    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    /**
     * @dev �������һ��������eth����ڶ��ٸ���Կ
     * @param _eth ��ͬ�еĵ���
     * @return �����ڵ���Կ��
     */
    function keys(uint256 _eth)
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    /**
     * @dev �ڸ���һЩ��Կ������¼����ͬ�е�eth����
     * @param _keys ����Լ���еļ���
     * @return ���ڵĵ���
     */
    function eth(uint256 _keys)
        internal
        pure
        returns(uint256)
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

//==============================================================================
//  . _ _|_ _  _ |` _  _ _  _  .
//  || | | (/_| ~|~(_|(_(/__\  .
//==============================================================================

interface PlayerBookInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}


library NameFilter {
    /**
     * @dev ���������ַ���
     * -����дת��ΪСд.
     * -ȷ�������Կո�ʼ/����
     * -ȷ���������������Ķ���ո�
     * -����ֻ������
     * -������0x��ͷ
     * -���ַ�����ΪA-Z��a-z��0-9�Ϳո�
     * @return ���ֽ�32��ʽ���´�����ַ���
     */
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //�Բ�������32���ַ�
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // ȷ�������Կո�ͷ���Կո��β
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // ȷ��ǰ�����ַ�����0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // ����һ��bool�����������Ƿ��з������ַ�
        bool _hasNonNumber;

        // ת���ͼ��
        for (uint256 i = 0; i < _length; i++)
        {
            // ������Ĵ�дA-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // ת��ΪСдa-z
                _temp[i] = byte(uint(_temp[i]) + 32);

                // ������һ��������
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // Ҫ���ɫ��һ���ռ�
                    _temp[i] == 0x20 ||
                    // ��Сдa-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // ��0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // ȷ���������в��ǿո�
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                // ���������Ƿ���һ������������ַ�
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

/**
 * @title SafeMath v0.1.9
 * @dev ���а�ȫ������ѧ�������������
 * - ��� sqrt
 * - ��� sq
 * - ��� pwr
 * - �����Ը���Ϊ��Ҫ���д�����־���
 * - ɾ��div����û��
 */
library SafeMath {

    /**
    * @dev ������������ˣ��׳������
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
    * @dev ��ȥ�������֣������ʱ�׳�����������������ڼ�������
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
    * @dev ����������֣����ʱ�׳���
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
     * @dev ��������x��ƽ����.
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
     * @dev ���㳡����x����x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x��y������
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