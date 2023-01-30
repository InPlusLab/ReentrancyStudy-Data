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

interface PlayerBookReceiverInterface {
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external;
    function receivePlayerNameList(uint256 _pID, bytes32 _name) external;
}


contract PlayerBook {
    using NameFilter for string;
    using SafeMath for uint256;

    address private admin = msg.sender;
//==============================================================================
//     _| _ _|_ _    _ _ _|_    _   .
//    (_|(_| | (_|  _\(/_ | |_||_)  .
//=============================|================================================
    uint256 public registrationFee_ = 10 finney;            // ע�����Ƶļ۸�
    mapping(uint256 => PlayerBookReceiverInterface) public games_;  // ӳ�����ǵ���Ϸ���棬�������ʻ���Ϣ���͵���Ϸ
    mapping(address => bytes32) public gameNames_;          // ������Ϸ����
    mapping(address => uint256) public gameIDs_;            // ������ϷID
    uint256 public gID_;        // ��Ϸ����
    uint256 public pID_;        // ��Ա����
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) ����ַ�������ID
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) �����Ʒ������ID
    mapping (uint256 => Player) public plyr_;               // (pID => data) ��Ա����
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) ���ӵ�е������б� ������������Ϳ��Ըı������ʾ���ƣ���������ӵ�е��κ����֣�
    mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_; // (pID => nameNum => name) ���ӵ�е������б�
    struct Player {
        address addr;
        bytes32 name;
        uint256 laff;
        uint256 names;
    }
//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  ����ͬ����ʱ�ĳ�ʼ�������ã�
//==============================================================================
    constructor()
        public
    {
        // premine the dev names (sorry not sorry)
            // No keys are purchased with this method, it's simply locking our addresses,
            // PID's and names for referral codes.
        plyr_[1].addr = 0x8e0d985f3Ec1857BEc39B76aAabDEa6B31B67d53;
        plyr_[1].name = "justo";
        plyr_[1].names = 1;
        pIDxAddr_[0x8e0d985f3Ec1857BEc39B76aAabDEa6B31B67d53] = 1;
        pIDxName_["justo"] = 1;
        plyrNames_[1]["justo"] = true;
        plyrNameList_[1][1] = "justo";

        plyr_[2].addr = 0x8b4DA1827932D71759687f925D17F81Fc94e3A9D;
        plyr_[2].name = "mantso";
        plyr_[2].names = 1;
        pIDxAddr_[0x8b4DA1827932D71759687f925D17F81Fc94e3A9D] = 2;
        pIDxName_["mantso"] = 2;
        plyrNames_[2]["mantso"] = true;
        plyrNameList_[2][1] = "mantso";

        plyr_[3].addr = 0x7ac74Fcc1a71b106F12c55ee8F802C9F672Ce40C;
        plyr_[3].name = "sumpunk";
        plyr_[3].names = 1;
        pIDxAddr_[0x7ac74Fcc1a71b106F12c55ee8F802C9F672Ce40C] = 3;
        pIDxName_["sumpunk"] = 3;
        plyrNames_[3]["sumpunk"] = true;
        plyrNameList_[3][1] = "sumpunk";

        plyr_[4].addr = 0x18E90Fc6F70344f53EBd4f6070bf6Aa23e2D748C;
        plyr_[4].name = "inventor";
        plyr_[4].names = 1;
        pIDxAddr_[0x18E90Fc6F70344f53EBd4f6070bf6Aa23e2D748C] = 4;
        pIDxName_["inventor"] = 4;
        plyrNames_[4]["inventor"] = true;
        plyrNameList_[4][1] = "inventor";

        pID_ = 4;
    }
//==============================================================================
//     _ _  _  _|. |`. _  _ _  .
//    | | |(_)(_||~|~|(/_| _\  .  ����Щ�ǰ�ȫ��飩
//==============================================================================
    /**
     * @dev ��ֹ��ͬ��worldfomo����
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }


    modifier isRegisteredGame()
    {
        require(gameIDs_[msg.sender] != 0);
        _;
    }
//==============================================================================
//     _    _  _ _|_ _  .
//    (/_\/(/_| | | _\  .
//==============================================================================
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
//==============================================================================
//     _  _ _|__|_ _  _ _  .
//    (_|(/_ |  | (/_| _\  . ������UI�Ͳ鿴etherscan�ϵ����ݣ�
//=====_|=======================================================================
    function checkIfNameValid(string _nameStr)
        public
        view
        returns(bool)
    {
        bytes32 _name = _nameStr.nameFilter();
        if (pIDxName_[_name] == 0)
            return (true);
        else
            return (false);
    }
//==============================================================================
//     _    |_ |. _   |`    _  __|_. _  _  _  .
//    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  ��ʹ����Щ���ͬ������
//====|=========================================================================
    /**
     * @dev ע��һ�����֡� UI��ʼ����ʾ��ע������ϡ�
     * �����Խ�ӵ��������ǰע�������������������Ա
     * - ����֧��ע��ѡ�
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
     * @param _affCode ��ԱID����ַ��˭�ᵽ�������
     * @param _all �����ϣ������Ϣ���͵�������Ϸ��������Ϊtrue
     * (����ܻ�ķѴ�������)
     */
    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        // ȷ��֧�����Ʒ���
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // ����������+�������
        bytes32 _name = NameFilter.nameFilter(_nameString);

        // ���õ�ַ
        address _addr = msg.sender;

        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        bool _isNewPlayer = determinePID(_addr);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[_addr];

        // �����Ա�в�
        // ���û�и������˴��룬��û�и����µ����˴��룬����
        // �����ͼʹ���Լ���pID��Ϊ���˴���
        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID)
        {
            // �������һ����Ա
            plyr_[_pID].laff = _affCode;
        } else if (_affCode == _pID) {
            _affCode = 0;
        }

        // ע������
        registerNameCore(_pID, _addr, _affCode, _name, _isNewPlayer, _all);
    }

    function registerNameXaddr(string _nameString, address _affCode, bool _all)
        isHuman()
        public
        payable
    {
        // ȷ��֧�����Ʒ���
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // ����������+�������
        bytes32 _name = NameFilter.nameFilter(_nameString);

        // ���õ�ַ
        address _addr = msg.sender;

        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        bool _isNewPlayer = determinePID(_addr);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[_addr];

        // �����Ա�в�
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr)
        {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxAddr_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ע������
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }

    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        // ȷ��֧�����Ʒ���
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // ����������+�������
        bytes32 _name = NameFilter.nameFilter(_nameString);

        // ���õ�ַ
        address _addr = msg.sender;

        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        bool _isNewPlayer = determinePID(_addr);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[_addr];

        // �����Ա�в�
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxName_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ע������
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }

    /**
     * @dev ��ң����������Ϸ����֮ǰע���˸������ϣ�����
     * ע��ʱ��all bool����Ϊfalse��ʹ�ô˹��ܽ�������
     * ���һ�������ĸ������ϡ����⣬����������������֣���ô��
     * ����ʹ�ô˹��ܽ������������͵���ѡ�����Ϸ�С�
     * -functionhash- 0x81c5b206
     * @param _gameID ��ϷID
     */
    function addMeToGame(uint256 _gameID)
        isHuman()
        public
    {
        require(_gameID <= gID_, "silly player, that game doesn't exist yet");
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "hey there buddy, you dont even have an account");
        uint256 _totalNames = plyr_[_pID].names;

        // �����Ҹ������Ϻ���������
        games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);

        // ����������Ƶ��б�
        if (_totalNames > 1)
            for (uint256 ii = 1; ii <= _totalNames; ii++)
                games_[_gameID].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
    }

    /**
     * @dev ��ң�ʹ�ô˹��ܽ���������������͵�������ע�����Ϸ��
     * -functionhash- 0x0c6940ea
     */
    function addMeToAllGames()
        isHuman()
        public
    {
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "hey there buddy, you dont even have an account");
        uint256 _laff = plyr_[_pID].laff;
        uint256 _totalNames = plyr_[_pID].names;
        bytes32 _name = plyr_[_pID].name;

        for (uint256 i = 1; i <= gID_; i++)
        {
            games_[i].receivePlayerInfo(_pID, _addr, _name, _laff);
            if (_totalNames > 1)
                for (uint256 ii = 1; ii <= _totalNames; ii++)
                    games_[i].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
        }

    }

    /**
     * @dev ���ʹ�������Ļ����һ�������֡�С�ѣ�����
     * ��Ȼ��Ҫ������Ϣ���͵�������Ϸ��
     * -functionhash- 0xb9291296
     * @param _nameString ��Ҫʹ�õ�����
     */
    function useMyOldName(string _nameString)
        isHuman()
        public
    {
        // ���������ƣ�����ȡpID
        bytes32 _name = _nameString.nameFilter();
        uint256 _pID = pIDxAddr_[msg.sender];

        // ȷ������ӵ���������
        require(plyrNames_[_pID][_name] == true, "umm... thats not a name you own");

        // �������ǵ�ǰ������
        plyr_[_pID].name = _name;
    }

//==============================================================================
//     _ _  _ _   | _  _ . _  .
//    (_(_)| (/_  |(_)(_||(_  .
//=====================_|=======================================================
    function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer, bool _all)
        private
    {
        // �����ʹ�����ƣ���Ҫ��ǰ��msg������ӵ�и�����
        if (pIDxName_[_name] != 0)
            require(plyrNames_[_pID][_name] == true, "sorry that names already taken");

        // Ϊ�����������ļ���ע�������Ʋ��������
        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;
        if (plyrNames_[_pID][_name] == false)
        {
            plyrNames_[_pID][_name] = true;
            plyr_[_pID].names++;
            plyrNameList_[_pID][plyr_[_pID].names] = _name;
        }

        // ע���ֱ�ӹ�����������
        admin.transfer(address(this).balance);

        // �������Ϣ���͵���Ϸ
        if (_all == true)
            for (uint256 i = 1; i <= gID_; i++)
                games_[i].receivePlayerInfo(_pID, _addr, _name, _affID);

        // �����¼�
        emit onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, msg.value, now);
    }
//==============================================================================
//    _|_ _  _ | _  .
//     | (_)(_)|_\  .
//==============================================================================
    function determinePID(address _addr)
        private
        returns (bool)
    {
        if (pIDxAddr_[_addr] == 0)
        {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;

            // �������bool����Ϊtrue
            return (true);
        } else {
            return (false);
        }
    }
//==============================================================================
//   _   _|_ _  _ _  _ |   _ _ || _  .
//  (/_>< | (/_| | |(_||  (_(_|||_\  .
//==============================================================================
    function getPlayerID(address _addr)
        isRegisteredGame()
        external
        returns (uint256)
    {
        determinePID(_addr);
        return (pIDxAddr_[_addr]);
    }
    function getPlayerName(uint256 _pID)
        external
        view
        returns (bytes32)
    {
        return (plyr_[_pID].name);
    }
    function getPlayerLAff(uint256 _pID)
        external
        view
        returns (uint256)
    {
        return (plyr_[_pID].laff);
    }
    function getPlayerAddr(uint256 _pID)
        external
        view
        returns (address)
    {
        return (plyr_[_pID].addr);
    }
    function getNameFee()
        external
        view
        returns (uint256)
    {
        return(registrationFee_);
    }
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all)
        isRegisteredGame()
        external
        payable
        returns(bool, uint256)
    {
        // ȷ��֧�����Ʒ���
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        bool _isNewPlayer = determinePID(_addr);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[_addr];

        // �����Ա�в�
        // ���û�и������˴��룬��û�и����µ����˴��룬����
        // �����ͼʹ���Լ���pID��Ϊ���˴���
        uint256 _affID = _affCode;
        if (_affID != 0 && _affID != plyr_[_pID].laff && _affID != _pID)
        {
            // �������һ����Ա
            plyr_[_pID].laff = _affID;
        } else if (_affID == _pID) {
            _affID = 0;
        }

        // ע������
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

        return(_isNewPlayer, _affID);
    }
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all)
        isRegisteredGame()
        external
        payable
        returns(bool, uint256)
    {
        // ȷ��֧�����Ʒ���
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        bool _isNewPlayer = determinePID(_addr);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[_addr];

        // �����Ա�в�
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr)
        {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxAddr_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ע������
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

        return(_isNewPlayer, _affID);
    }
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all)
        isRegisteredGame()
        external
        payable
        returns(bool, uint256)
    {
        // ȷ��֧�����Ʒ���
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // �������ǵ�tx�¼����ݲ�ȷ������Ƿ�������
        bool _isNewPlayer = determinePID(_addr);

        // ��ȡ���ID
        uint256 _pID = pIDxAddr_[_addr];

        // �����Ա�в�
        // ���û�и������˴�����������ͼʹ�������Լ��Ĵ���
        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            // ��aff Code��ȡ��ԱID
            _affID = pIDxName_[_affCode];

            // ���affID����ǰ�洢�Ĳ�ͬ
            if (_affID != plyr_[_pID].laff)
            {
                // �������һ����Ա
                plyr_[_pID].laff = _affID;
            }
        }

        // ע������
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

        return(_isNewPlayer, _affID);
    }

//==============================================================================
//   _ _ _|_    _   .
//  _\(/_ | |_||_)  .
//=============|================================================================
    function addGame(address _gameAddress, string _gameNameStr)
        public
    {
        require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");
            gID_++;
            bytes32 _name = _gameNameStr.nameFilter();
            gameIDs_[_gameAddress] = gID_;
            gameNames_[_gameAddress] = _name;
            games_[gID_] = PlayerBookReceiverInterface(_gameAddress);

            games_[gID_].receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name, 0);
            games_[gID_].receivePlayerInfo(2, plyr_[2].addr, plyr_[2].name, 0);
            games_[gID_].receivePlayerInfo(3, plyr_[3].addr, plyr_[3].name, 0);
            games_[gID_].receivePlayerInfo(4, plyr_[4].addr, plyr_[4].name, 0);
    }

    function setRegistrationFee(uint256 _fee)
        public
    {
      registrationFee_ = _fee;
    }

}


library NameFilter {

    /**
     * @dev ���������ַ���
     * -����дת��ΪСд��
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
        //ȷ�������Կո�ͷ���Կո��β
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
     * @dev ��������x��ƽ������
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