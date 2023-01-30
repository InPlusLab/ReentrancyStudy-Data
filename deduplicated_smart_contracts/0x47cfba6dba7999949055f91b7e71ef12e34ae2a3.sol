pragma solidity ^0.4.18;

// File: contracts\Auction.sol

/**
 * @title ���Ľӿ�
 */
contract Auction {
    function bid() public payable returns (bool);
    function end() public returns (bool);

    event AuctionBid(address indexed from, uint256 value);
}

// File: contracts\Base.sol

library Base {
    struct NTVUConfig {
        uint bidStartValue;
        int bidStartTime;
        int bidEndTime;

        uint tvUseStartTime;
        uint tvUseEndTime;

        bool isPrivate;
        bool special;
    }
}

// File: contracts\ownership\Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

// File: contracts\util\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: contracts\token\ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\token\BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: contracts\util\StringUtils.sol

library StringUtils {
    function uintToString(uint v) internal pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }

        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }

        str = string(s);
    }

    function concat(string _base, string _value) internal pure returns (string) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

    function bytesToBytes32(bytes memory source) internal pure returns (bytes32 result) {
        require(source.length <= 32);

        if (source.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function toBytes96(string memory text) internal pure returns (bytes32, bytes32, bytes32, uint8) {
        bytes memory temp = bytes(text);
        len = uint8(temp.length);
        require(len <= 96);

        uint8 i=0;
        uint8 j=0;
        uint8 k=0;

        string memory _b1 = new string(32);
        bytes memory b1 = bytes(_b1);

        string memory _b2 = new string(32);
        bytes memory b2 = bytes(_b2);

        string memory _b3 = new string(32);
        bytes memory b3 = bytes(_b3);

        uint8 len;

        for(i=0; i<len; i++) {
            k = i / 32;
            j = i % 32;

            if (k == 0) {
                b1[j] = temp[i];
            } else if(k == 1) {
                b2[j] = temp[i];
            } else if(k == 2) {
                b3[j] = temp[i];
            } 
        }

        return (bytesToBytes32(b1), bytesToBytes32(b2), bytesToBytes32(b3), len);
    }

    function fromBytes96(bytes32 b1, bytes32 b2, bytes32 b3, uint8 len) internal pure returns (string) {
        require(len <= 96);
        string memory _tmpValue = new string(len);
        bytes memory temp = bytes(_tmpValue);

        uint8 i;
        uint8 j = 0;

        for(i=0; i<32; i++) {
            if (j >= len) break;
            temp[j++] = b1[i];
        }

        for(i=0; i<32; i++) {
            if (j >= len) break;
            temp[j++] = b2[i];
        }

        for(i=0; i<32; i++) {
            if (j >= len) break;
            temp[j++] = b3[i];
        }

        return string(temp);
    }
}

// File: contracts\NTVUToken.sol

/**
 * �������Ļ�ʱ�α�
 */
contract NTVUToken is BasicToken, Ownable, Auction {
    string public name;
    string public symbol = "FOT";

    uint8 public number = 0;
    uint8 public decimals = 0;
    uint public INITIAL_SUPPLY = 1;

    uint public bidStartValue;
    uint public bidStartTime;
    uint public bidEndTime;

    uint public tvUseStartTime;
    uint public tvUseEndTime;

    bool public isPrivate = false;

    uint public maxBidValue;
    address public maxBidAccount;

    bool internal auctionEnded = false;

    string public text; // �û������ı�
    string public auditedText; // ���ͨ�����ı�
    string public defaultText; // Ĭ���ı�
    uint8 public auditStatus = 0; // 0:δ��ˣ�1:���ͨ����2:��˲�ͨ��

    uint32 public bidCount;
    uint32 public auctorCount;

    mapping(address => bool) acutors;

    address public ethSaver; // ��������ETH������

    /**
     * ʱ�αҺ�Լ���캯��
     *
     * �����ڼ����и��߳��ۣ�ǰһ�ֳ����ߵ���̫���Զ��˻���Ǯ��
     *
     * @param _number ʱ�αҵ���ţ���0��ʼ
     * @param _bidStartValue ���ļۣ���λ wei
     * @param _bidStartTime ����/˽ļ��ʼʱ�䣬��λs
     * @param _bidEndTime ����/˽ļ����ʱ�䣬��λs
     * @param _tvUseStartTime ʱ�α��ı���ʼ����ʱ��
     * @param _tvUseEndTime ʱ�α��ı���������ʱ��
     * @param _isPrivate �Ƿ�Ϊ˽ļ
     * @param _defaultText Ĭ���ı�
     * @param _ethSaver �������ñ�����
     */
    function NTVUToken(uint8 _number, uint _bidStartValue, uint _bidStartTime, uint _bidEndTime, uint _tvUseStartTime, uint _tvUseEndTime, bool _isPrivate, string _defaultText, address _ethSaver) public {
        number = _number;

        if (_number + 1 < 10) {
            symbol = StringUtils.concat(symbol, StringUtils.concat("0", StringUtils.uintToString(_number + 1)));
        } else {
            symbol = StringUtils.concat(symbol, StringUtils.uintToString(_number + 1));
        }

        name = symbol;
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;

        bidStartValue = _bidStartValue;
        bidStartTime = _bidStartTime;
        bidEndTime = _bidEndTime;

        tvUseStartTime = _tvUseStartTime;
        tvUseEndTime = _tvUseEndTime;

        isPrivate = _isPrivate;

        defaultText = _defaultText;

        ethSaver = _ethSaver;
    }

    /**
     * ���ĳ���
     *
     * �����ڼ����и��߳��ۣ�ǰһ�ֳ����ߵ���̫���Զ��˻���Ǯ��
     */
    function bid() public payable returns (bool) {
        require(now >= bidStartTime); // ���Ŀ�ʼʱ�䵽����ܾ���
        require(now < bidEndTime); // ���Ľ�ֹʱ�䵽�����پ���
        require(msg.value >= bidStartValue); // ���������Ҫ�������ļ�
        require(msg.value >= maxBidValue + 0.05 ether); // ���0.05ETH�Ӽ�
        require(!isPrivate || (isPrivate && maxBidAccount == address(0))); // ���Ļ���˽ļ��һ�γ���

        // ����ϴ����˳��ۣ����ϴγ��۵�ETH�˻�����
        if (maxBidAccount != address(0)) {
            maxBidAccount.transfer(maxBidValue);
        } 
        
        maxBidAccount = msg.sender;
        maxBidValue = msg.value;
        AuctionBid(maxBidAccount, maxBidValue); // �������˳����¼�

        // ͳ�Ƴ��۴���
        bidCount++;

        // ͳ�Ƴ�������
        bool bided = acutors[msg.sender];
        if (!bided) {
            auctorCount++;
            acutors[msg.sender] = true;
        }
    }

    /**
     * ���Ľ���
     *
     * ����������ϵͳȷ�Ͻ��ף���������߻�ø�ʱ��Token��
     */
    function end() public returns (bool) {
        require(!auctionEnded); // �Ѿ����������˲����ٽ���
        require((now >= bidEndTime) || (isPrivate && maxBidAccount != address(0))); // ��ͨ��������������ſ��Խ������ģ�˽ļֻҪ�����۾Ϳ��Խ�������
   
        // ������˳��ۣ���ʱ�δ���ת��������ߵ���
        if (maxBidAccount != address(0)) {
            address _from = owner;
            address _to = maxBidAccount;
            uint _value = INITIAL_SUPPLY;

            // ��ʱ�α�ת��������ߵ���
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value); // ֪ͨ������ߵ����յ�ʱ�α���

            //��ʱ�α���ETHת��ethSaver
            ethSaver.transfer(this.balance);
        }

        auctionEnded = true;
    }

    /**
     * ���������ı�
     *
     * ����ʱ�κ󣨰���������˽ļ������������ʱ���ı�
     * ÿʱ�����ֽ�������30�����ڣ������Ϳո񣩣�����ַ�����ʾ��
     * ��˽�ֹʱ���ǣ�ÿ��ʱ�β���ǰ30����
     */
    function setText(string _text) public {
        require(INITIAL_SUPPLY == balances[msg.sender]); // ӵ��ʱ�αҵ��˿��������ı�
        require(bytes(_text).length > 0 && bytes(_text).length <= 90); // ����ʹ��UTF8���룬1���������ռ��3���ֽڣ��������д90���ֽڵ���
        require(now < tvUseStartTime - 30 minutes); // ����ǰ30���Ӳ����������ı�

        text = _text;
    }

    function getTextBytes96() public view returns(bytes32, bytes32, bytes32, uint8) {
        return StringUtils.toBytes96(text);
    }

    /**
     * ����ı�
     */
    function auditText(uint8 _status, string _text) external onlyOwner {
        require((now >= tvUseStartTime - 30 minutes) && (now < tvUseEndTime)); // ʱ�β���ǰ30����Ϊ���ʱ�䣬��ֹ��ʱ�β�������ʱ��
        auditStatus = _status;

        if (_status == 2) { // ���ʧ�ܣ���������ı�
            auditedText = _text;
        } else if (_status == 1) { // ���ͨ��ʹ���û����õ��ı�
            auditedText = text; 
        }
    }

    /**
     * ��ȡ��ʾ�ı�
     */
    function getShowText() public view returns(string) {
        if (auditStatus == 1 || auditStatus == 2) { // ��˹���
            return auditedText;
        } else { // û����ˣ���ʾĬ���ı�
            return defaultText;
        }
    }

    function getShowTextBytes96() public view returns(bytes32, bytes32, bytes32, uint8) {
        return StringUtils.toBytes96(getShowText());
    }

    /**
     * ת�˴���
     *
     * ���ʱ�κ�ʱ�β���ǰ��������ת����ʱ�β����󣬿�����Ϊ�����ת��
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(now >= tvUseEndTime); // ʱ�β����󣬿���ת����

        super.transfer(_to, _value);
    }

    /**
     * ��ȡʱ�α�״̬��Ϣ
     *
     */
    function getInfo() public view returns(
        string _symbol,
        string _name,
        uint _bidStartValue, 
        uint _bidStartTime, 
        uint _bidEndTime, 
        uint _tvUseStartTime,
        uint _tvUseEndTime,
        bool _isPrivate
        ) {
        _symbol = symbol;
        _name = name;

        _bidStartValue = bidStartValue;
        _bidStartTime = bidStartTime;
        _bidEndTime = bidEndTime;

        _tvUseStartTime = tvUseStartTime;
        _tvUseEndTime = tvUseEndTime;

        _isPrivate = isPrivate;
    }

    /**
     * ��ȡʱ�αҿɱ�״̬��Ϣ
     *
     */
    function getMutalbeInfo() public view returns(
        uint _maxBidValue,
        address _maxBidAccount,
        bool _auctionEnded,
        string _text,
        uint8 _auditStatus,
        uint8 _number,
        string _auditedText,
        uint32 _bidCount,
        uint32 _auctorCount
        ) {
        _maxBidValue = maxBidValue;
        _maxBidAccount = maxBidAccount;

        _auctionEnded = auctionEnded;

        _text = text;
        _auditStatus = auditStatus;

        _number = number;
        _auditedText = auditedText;

        _bidCount = bidCount;
        _auctorCount = auctorCount;
    }

    /**
     * ��ȡ��̫����ethSaver
     */
    function reclaimEther() external onlyOwner {
        require((now > bidEndTime) || (isPrivate && maxBidAccount != address(0))); // ��ͨ�����������������˽ļ��ɺ󣬿�����ҵ�ethSaver��
        ethSaver.transfer(this.balance);
    }

    /**
     * Ĭ�ϸ���Լת��̫�����ǳ���
     */
    function() payable public {
        bid(); // ����
    }
}

// File: contracts\NTVToken.sol

/**
 * �������Ļ���Լ
 */
contract NTVToken is Ownable {
    using SafeMath for uint256;

    uint8 public MAX_TIME_RANGE_COUNT = 66; // ��෢��66��ʱ�δ���

    bool public isRunning; // �Ƿ���������

    uint public onlineTime; // ����ʱ�䣬��һʱ���ϵ��ӵ�ʱ��
    uint8 public totalTimeRange; // ��ǰ�Ѿ��ͷŵ��ܵ�ʱ����
    mapping(uint => address) internal timeRanges; // ÿ��ʱ�εĺ�Լ��ַ����Ŵ�0��ʼ

    string public defaultText = "�˻�����ǧ��ѩ���һ�����һ�Ӵ���"; // �������ʹ�õ�Ĭ���ı�

    mapping(uint8 => Base.NTVUConfig) internal dayConfigs; // ÿ��ʱ������
    mapping(uint8 => Base.NTVUConfig) internal specialConfigs; // ����ʱ������

    address public ethSaver; // ��������ETH������

    event OnTV(address indexed ntvu, address indexed winer, string text); // �ı��ϵ���

    /**
     * ��ϵ���Ӻ�Լ���캯��
     */
    function NTVToken() public {}

    /**
     * ��������������
     *
     * @param _onlineTime ��������������ʱ�䣬����Ϊ���㣬���� 2018-03-26 00:00:00
     * @param _ethSaver ��������ETH������
     */
    function startup(uint256 _onlineTime, address _ethSaver) public onlyOwner {
        require(!isRunning); // ֻ������һ�Σ����ߺ���ֹͣ
        require((_onlineTime - 57600) % 1 days == 0); // ����ʱ��ֻ��������ʱ�䣬57600Ϊ����ʱ���'1970/1/2 0:0:0'
        require(_onlineTime >= now); // ����ʱ����Ҫ���ڵ�ǰʱ��
        require(_ethSaver != address(0));

        onlineTime = _onlineTime;
        ethSaver = _ethSaver;

        isRunning = true;

        // ---------------------------
        // ÿ���ʱ�����ã���6��ʱ��
        //
        // ͨ�ù���
        // 1�����ĺ�ÿ��18:30-22:00Ϊ����ʱ��
        // ---------------------------
        uint8[6] memory tvUseStartTimes = [0, 10, 12, 18, 20, 22]; // ����ʹ�ÿ�ʼʱ��
        uint8[6] memory tvUseEndTimes = [2, 12, 14, 20, 22, 24]; // ����ʹ�ý���ʱ��

        for (uint8 i=0; i<6; i++) {
            dayConfigs[i].bidStartValue = 0.1 ether; // �������ļ�0.1ETH
            dayConfigs[i].bidStartTime = 18 hours + 30 minutes - 1 days; // һ��ǰ���� 18:30����
            dayConfigs[i].bidEndTime = 22 hours - 1 days; // һ��ǰ���� 22:00 ��������

            dayConfigs[i].tvUseStartTime = uint(tvUseStartTimes[i]) * 1 hours;
            dayConfigs[i].tvUseEndTime = uint(tvUseEndTimes[i]) * 1 hours;

            dayConfigs[i].isPrivate = false; // �������Ǿ��ģ���˽ļ
        }

        // ---------------------------
        // ����ʱ������
        // ---------------------------

        // ���ģ���1���6��ʱ�ζ������ģ�����ʱ�������ǰ��18:30��һ��ǰ��22:00
        for(uint8 p=0; p<6; p++) {
            specialConfigs[p].special = true;
            
            specialConfigs[p].bidStartValue = 0.1 ether; // ���ļ�0.1ETH
            specialConfigs[p].bidStartTime = 18 hours + 30 minutes - 2 days; // ����ǰ��18:30
            specialConfigs[p].bidEndTime = 22 hours - 1 days; // һ��ǰ��22:00
            specialConfigs[p].isPrivate = false; // ��˽ļ
        }
    }

    /**
     * ��ȡ�����ʱ�������λs
     */
    function time() constant internal returns (uint) {
        return block.timestamp;
    }

    /**
     * ��ȡĳ��ʱ�������ߵڼ��죬��1�췵��1������֮ǰ����0
     * 
     * @param timestamp ʱ���
     */
    function dayFor(uint timestamp) constant public returns (uint) {
        return timestamp < onlineTime
            ? 0
            : (timestamp.sub(onlineTime) / 1 days) + 1;
    }

    /**
     * ��ȡ��ǰʱ���ǽ���ĵڼ���ʱ�Σ���һ��ʱ�η���1��û��ƥ��ķ���0
     *
     * @param timestamp ʱ���
     */
    function numberFor(uint timestamp) constant public returns (uint8) {
        if (timestamp >= onlineTime) {
            uint current = timestamp.sub(onlineTime) % 1 days;

            for(uint8 i=0; i<6; i++) {
                if (dayConfigs[i].tvUseStartTime<=current && current<dayConfigs[i].tvUseEndTime) {
                    return (i + 1);
                }
            }
        }

        return 0;
    }

    /**
     * ����ʱ�α�
     */
    function createNTVU() public onlyOwner {
        require(isRunning);
        require(totalTimeRange < MAX_TIME_RANGE_COUNT);

        uint8 number = totalTimeRange++;
        uint8 day = number / 6;
        uint8 num = number % 6;

        Base.NTVUConfig memory cfg = dayConfigs[num]; // ��ȡÿ��ʱ�ε�Ĭ������

        // ��������������򸲸�
        Base.NTVUConfig memory expCfg = specialConfigs[number];
        if (expCfg.special) {
            cfg.bidStartValue = expCfg.bidStartValue;
            cfg.bidStartTime = expCfg.bidStartTime;
            cfg.bidEndTime = expCfg.bidEndTime;
            cfg.isPrivate = expCfg.isPrivate;
        }

        // ��������ʱ���������ʱ��ʱ��
        uint bidStartTime = uint(int(onlineTime) + day * 24 hours + cfg.bidStartTime);
        uint bidEndTime = uint(int(onlineTime) + day * 24 hours + cfg.bidEndTime);
        uint tvUseStartTime = onlineTime + day * 24 hours + cfg.tvUseStartTime;
        uint tvUseEndTime = onlineTime + day * 24 hours + cfg.tvUseEndTime;

        timeRanges[number] = new NTVUToken(number, cfg.bidStartValue, bidStartTime, bidEndTime, tvUseStartTime, tvUseEndTime, cfg.isPrivate, defaultText, ethSaver);
    }

    /**
     * ��ѯ����ʱ��
     */
    function queryNTVUs(uint startIndex, uint count) public view returns(address[]){
        startIndex = (startIndex < totalTimeRange)? startIndex : totalTimeRange;
        count = (startIndex + count < totalTimeRange) ? count : (totalTimeRange - startIndex);

        address[] memory result = new address[](count);
        for(uint i=0; i<count; i++) {
            result[i] = timeRanges[startIndex + i];
        }

        return result;
    }

    /**
     * ��ѯ��ǰ���ڲ��ŵ�ʱ��
     */
    function playingNTVU() public view returns(address){
        uint day = dayFor(time());
        uint8 num = numberFor(time());

        if (day>0 && (num>0 && num<=6)) {
            day = day - 1;
            num = num - 1;

            return timeRanges[day * 6 + uint(num)];
        } else {
            return address(0);
        }
    }

    /**
     * ����ı�
     */
    function auditNTVUText(uint8 index, uint8 status, string _text) public onlyOwner {
        require(isRunning); // ��Լ������������
        require(index >= 0 && index < totalTimeRange); //ֻ������Ѿ����ߵ�ʱ��
        require(status==1 || (status==2 && bytes(_text).length>0 && bytes(_text).length <= 90)); // ��˲�ͨ����Ҫ�����ı�

        address ntvu = timeRanges[index];
        assert(ntvu != address(0));

        NTVUToken ntvuToken = NTVUToken(ntvu);
        ntvuToken.auditText(status, _text);

        var (b1, b2, b3, len) = ntvuToken.getShowTextBytes96();
        var auditedText = StringUtils.fromBytes96(b1, b2, b3, len);
        OnTV(ntvuToken, ntvuToken.maxBidAccount(), auditedText); // ��˺���ı���¼����־��
    }

    /**
     * ��ȡ���Ӳ����ı�
     */
    function getText() public view returns(string){
        address playing = playingNTVU();

        if (playing != address(0)) {
            NTVUToken ntvuToken = NTVUToken(playing);

            var (b1, b2, b3, len) = ntvuToken.getShowTextBytes96();
            return StringUtils.fromBytes96(b1, b2, b3, len);
        } else {
            return ""; // ��ǰ���ǲ���ʱ�Σ����ؿ��ı�
        }
    }

    /**
     * ��ȡ����״̬
     */
    function status() public view returns(uint8) {
        if (!isRunning) {
            return 0; // δ��������
        } else if (time() < onlineTime) {
            return 1; // δ���ײ�ʱ��
        } else {
            if (totalTimeRange == 0) {
                return 2; // û�д�������ʱ��
            } else {
                if (time() < NTVUToken(timeRanges[totalTimeRange - 1]).tvUseEndTime()) {
                    return 3; // �������Ļ������
                } else {
                    return 4; // �������Ļ�ѽ���
                }
            }
        }
    }
    
    /**
     * ��ȡ�ܵľ�������
     */
    function totalAuctorCount() public view returns(uint32) {
        uint32 total = 0;

        for(uint8 i=0; i<totalTimeRange; i++) {
            total += NTVUToken(timeRanges[i]).auctorCount();
        }

        return total;
    }

    /**
     * ��ȡ�ܵľ��Ĵ���
     */
    function totalBidCount() public view returns(uint32) {
        uint32 total = 0;

        for(uint8 i=0; i<totalTimeRange; i++) {
            total += NTVUToken(timeRanges[i]).bidCount();
        }

        return total;
    }

    /**
     * ��ȡ�ܵĳ���ETH
     */
    function totalBidEth() public view returns(uint) {
        uint total = 0;

        for(uint8 i=0; i<totalTimeRange; i++) {
            total += NTVUToken(timeRanges[i]).balance;
        }

        total += this.balance;
        total += ethSaver.balance;

        return total;
    }

    /**
     * ��ȡ��ʷ������ߵ�ETH
     */
    function maxBidEth() public view returns(uint) {
        uint maxETH = 0;

        for(uint8 i=0; i<totalTimeRange; i++) {
            uint val = NTVUToken(timeRanges[i]).maxBidValue();
            maxETH =  (val > maxETH) ? val : maxETH;
        }

        return maxETH;
    }

    /**
     * ��ȡ��ǰ��Լ��ETH��ethSaver
     */
    function reclaimEther() public onlyOwner {
        require(isRunning);

        ethSaver.transfer(this.balance);
    }

    /**
     * ��ȡʱ�αҵ�ETH��ethSaver
     */
    function reclaimNtvuEther(uint8 index) public onlyOwner {
        require(isRunning);
        require(index >= 0 && index < totalTimeRange); //ֻ������Ѿ����ߵ�ʱ��

        NTVUToken(timeRanges[index]).reclaimEther();
    }

    /**
     * ����ETH
     */
    function() payable external {}
}