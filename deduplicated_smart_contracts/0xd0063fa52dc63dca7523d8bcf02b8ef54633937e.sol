pragma solidity ^0.4.24;

/**
 *
 *
 * ,------. ,-----. ,--.   ,--. ,-----.     ,--.   ,--.,--.                                  ,--.   ,--.
 * |  .---''  .-.  '|   `.'   |'  .-.  '    |  |   |  |`--',--,--, ,--,--,  ,---. ,--.--.    |   `.'   | ,--,--.,--.--. ,---.
 * |  `--, |  | |  ||  |'.'|  ||  | |  |    |  |.'.|  |,--.|      \|      \| .-. :|  .--'    |  |'.'|  |' ,-.  ||  .--'(  .-'
 * |  |`   '  '-'  '|  |   |  |'  '-'  '    |   ,'.   ||  ||  ||  ||  ||  |\   --.|  |       |  |   |  |\ '-'  ||  |   .-'  `)
 * `--'     `-----' `--'   `--' `-----'     '--'   '--'`--'`--''--'`--''--' `----'`--'       `--'   `--' `--`--'`--'   `----'
 *
 *
 * Դ�벻��ԭ�������Ǿ����˱�����ˣ��������ʽ𱻳�������Աת�ߵĿ�����
 * master#fomowinner.com
 */

// ��������¼�
contract FlyToTheMarsEvents {

  // ��һ�׶ι���key�¼�
  event onFirStage
  (
    address indexed player,
    uint256 indexed rndNo,
    uint256 keys,
    uint256 eth,
    uint256 timeStamp
  );

  // �ڶ��׶γ�ΪӮ���¼�
  event onSecStage
  (
    address indexed player,
    uint256 indexed rndNo,
    uint256 eth,
    uint256 timeStamp
  );

  // ��������¼�
  event onWithdraw
  (
    address indexed player,
    uint256 indexed rndNo,
    uint256 eth,
    uint256 timeStamp
  );

  // ���¼�
  event onAward
  (
    address indexed player,
    uint256 indexed rndNo,
    uint256 eth,
    uint256 timeStamp
  );
}

// �����������Լ
contract FlyToTheMars is FlyToTheMarsEvents {

  using SafeMath for *;           // ������ѧ����
  using KeysCalc for uint256;     // ����key����

  //ÿ����Ϸ�����ݽṹ
  struct Round {
    uint256 eth;        // eth����
    uint256 keys;       // key����
    uint256 startTime;  // ��ʼʱ��
    uint256 endTime;    // ����ʱ��
    address leader;     // Ӯ��
    uint256 lastPrice;  // �ڶ��׶ε��������
    bool award;         // �Ѿ�����
  }

  //������ݽṹ
  struct PlayerRound {
    uint256 eth;        // ����Ѿ����˶���eth
    uint256 keys;       // ����򵽵�key����
    uint256 withdraw;   // ����Ѿ����ֵ�����
  }

  uint256 public rndNo = 1;                                   // ��ǰ��Ϸ������
  uint256 public totalEth = 0;                                // eth����

  uint256 constant private rndFirStage_ = 12 hours;           // ��һ�ֵ���ʱ��
  uint256 constant private rndSecStage_ = 12 hours;           // �ڶ��ֵ���ʱ��

  mapping(uint256 => Round) public round_m;                  // (rndNo => Round) ��Ϸ�洢����
  mapping(uint256 => mapping(address => PlayerRound)) public playerRound_m;   // (rndNo => addr => PlayerRound) ��Ҵ洢�ṹ

  address public owner;               // �����ߵ�ַ
  uint256 public ownerWithdraw = 0;   // �����������˶���eth

  //���캯��
  constructor()
    public
  {
    //������Լ�趨��һ����Ϸ��ʼ
    round_m[1].startTime = now;
    round_m[1].endTime = now + rndFirStage_;

    //�����˾��Ƿ�����Լ����
    owner = msg.sender;
  }

  /**
   * ��ֹ������Լ����
   */
  modifier onlyHuman()
  {
    address _addr = msg.sender;
    uint256 _codeLength;

    assembly {_codeLength := extcodesize(_addr)}
    require(_codeLength == 0, "sorry humans only");
    _;
  }

  /**
   * ����ethת��ı߽�
   */
  modifier isWithinLimits(uint256 _eth)
  {
    require(_eth >= 1000000000, "pocket lint: not a valid currency"); //��С8λС�����
    require(_eth <= 100000000000000000000000, "no vitalik, no"); //���10��eth
    _;
  }

  /**
   * ֻ�д������ܵ���
   */
  modifier onlyOwner()
  {
    require(owner == msg.sender, "only owner can do it");
    _;
  }

  /**
   * ��������
   * �Զ����ܻ�ʵ�ֹ���key
   */
  function()
  onlyHuman()
  isWithinLimits(msg.value)
  public
  payable
  {
    uint256 _eth = msg.value;     //�û�ת���eth��
    uint256 _now = now;           //����ʱ��
    uint256 _rndNo = rndNo;       //��ǰ��Ϸ����
    uint256 _ethUse = msg.value;  //�û���������key��eth����

    // �Ƿ�Ҫ������һ��
    if (_now > round_m[_rndNo].endTime)
    {
      _rndNo = _rndNo.add(1);     //�����µ�һ��
      rndNo = _rndNo;

      round_m[_rndNo].startTime = _now;
      round_m[_rndNo].endTime = _now + rndFirStage_;
    }

    // �ж��Ƿ��ڵ�һ�׶Σ��Ӻ����߼�����key���ᳬ����
    if (round_m[_rndNo].keys < 10000000000000000000000000)
    {
      // ��������eth�������key
      uint256 _keys = (round_m[_rndNo].eth).keysRec(_eth);

      // key���� 10,000,000, �����������һ���׶�
      if (_keys.add(round_m[_rndNo].keys) >= 10000000000000000000000000)
      {
        // ���¼���ʣ��key������
        _keys = (10000000000000000000000000).sub(round_m[_rndNo].keys);

        // �����Ϸ��һ�׶δﵽ8562.5��eth��ô�Ͳ�������key��
        if (round_m[_rndNo].eth >= 8562500000000000000000)
        {
          _ethUse = 0;
        } else {
          _ethUse = (8562500000000000000000).sub(round_m[_rndNo].eth);
        }

        // �������Ľ����ڿ�����Ľ�����˵�����Ĳ���
        if (_eth > _ethUse)
        {
          // �˿�
          msg.sender.transfer(_eth.sub(_ethUse));
        } else {
          // fix
          _ethUse = _eth;
        }
      }

      // ����Ҫ��1��key�Żᴥ����Ϸ��������һ��key�����ΪӮ��
      if (_keys >= 1000000000000000000)
      {
        round_m[_rndNo].endTime = _now + rndFirStage_;
        round_m[_rndNo].leader = msg.sender;
      }

      // �޸��������
      playerRound_m[_rndNo][msg.sender].keys = _keys.add(playerRound_m[_rndNo][msg.sender].keys);
      playerRound_m[_rndNo][msg.sender].eth = _ethUse.add(playerRound_m[_rndNo][msg.sender].eth);

      // �޸���������
      round_m[_rndNo].keys = _keys.add(round_m[_rndNo].keys);
      round_m[_rndNo].eth = _ethUse.add(round_m[_rndNo].eth);

      // �޸�ȫ��eth����
      totalEth = _ethUse.add(totalEth);

      // ������һ�׶γ�ΪӮ���¼�
      emit FlyToTheMarsEvents.onFirStage
      (
        msg.sender,
        _rndNo,
        _keys,
        _ethUse,
        _now
      );
    } else {
      // �ڶ��׶��Ѿ�û��key��

      // lastPrice + 0.1Ether <= newPrice <= lastPrice + 10Ether
      // �¼۸��������ǰһ�γ���+0.1��10eth֮��
      uint256 _lastPrice = round_m[_rndNo].lastPrice;
      uint256 _maxPrice = (10000000000000000000).add(_lastPrice);

      // less than (lastPrice + 0.1Ether) ?
      // ���۱���������һ�γ�������0.1eth
      require(_eth >= (100000000000000000).add(_lastPrice), "Need more Ether");

      // more than (lastPrice + 10Ether) ?
      // �������Ƿ��Ѿ��������һ�γ���10eth
      if (_eth > _maxPrice)
      {
        _ethUse = _maxPrice;

        // ���۴���10eth�����Զ��˿�
        msg.sender.transfer(_eth.sub(_ethUse));
      }

      // ������һ����Ϣ
      round_m[_rndNo].endTime = _now + rndSecStage_;
      round_m[_rndNo].leader = msg.sender;
      round_m[_rndNo].lastPrice = _ethUse;

      // ���������Ϣ
      playerRound_m[_rndNo][msg.sender].eth = _ethUse.add(playerRound_m[_rndNo][msg.sender].eth);

      // ������һ�ֵ�eth����
      round_m[_rndNo].eth = _ethUse.add(round_m[_rndNo].eth);

      // ����ȫ��eth����
      totalEth = _ethUse.add(totalEth);

      // �����ڶ��׶γ�ΪӮ���¼�
      emit FlyToTheMarsEvents.onSecStage
      (
        msg.sender,
        _rndNo,
        _ethUse,
        _now
      );
    }
  }

  /**
   * ������Ϸ��������
   */
  function withdrawByRndNo(uint256 _rndNo)
  onlyHuman()
  public
  {
    require(_rndNo <= rndNo, "You're running too fast");                      //����ô������һ����Ϸ������

    //����60%�����ֵ���
    uint256 _total = (((round_m[_rndNo].eth).mul(playerRound_m[_rndNo][msg.sender].keys)).mul(60) / ((round_m[_rndNo].keys).mul(100)));
    uint256 _withdrawed = playerRound_m[_rndNo][msg.sender].withdraw;

    require(_total > _withdrawed, "No need to withdraw");                     //�����˾Ͳ�Ҫ������

    uint256 _ethOut = _total.sub(_withdrawed);                                //���㱾����ʵ��������
    playerRound_m[_rndNo][msg.sender].withdraw = _total;                      //��¼�������´��������û����

    msg.sender.transfer(_ethOut);                                             //˵����ô�࣬תǮ��

    // ������������¼�
    emit FlyToTheMarsEvents.onWithdraw
    (
      msg.sender,
      _rndNo,
      _ethOut,
      now
    );
  }

  /**
   * �����Ҫ��󽱰���ָ����Ϸ����
   */
  function awardByRndNo(uint256 _rndNo)
  onlyHuman()
  public
  {
    require(_rndNo <= rndNo, "You're running too fast");                        //����ô������һ����Ϸ������
    require(now > round_m[_rndNo].endTime, "Wait patiently");                   //��û�����أ���ʲô��
    require(round_m[_rndNo].leader == msg.sender, "The prize is not yours");    //�Բ������񲻶�
    require(round_m[_rndNo].award == false, "Can't get prizes repeatedly");     //�㻹���ظ���ô��û��

    uint256 _ethOut = ((round_m[_rndNo].eth).mul(35) / (100));  //������һ����Ϸ�е�35%���ʽ�
    round_m[_rndNo].award = true;                               //����Ѿ����ˣ��ɲ����ظ�����
    msg.sender.transfer(_ethOut);                               //ת�ˣ��Ӻ���

    // ��������¼�
    emit FlyToTheMarsEvents.onAward
    (
      msg.sender,
      _rndNo,
      _ethOut,
      now
    );
  }

  /**
   * ��Լ���������֣��ɷִ��ᣬ���Ϊ���ʽ���5%
   * �κ��˶�����ִ�У�����ֻ�к�Լ���������յ���
   */
  function feeWithdraw()
  onlyHuman()
  public
  {
    uint256 _total = (totalEth.mul(5) / (100));           //��ǰ������5%
    uint256 _withdrawed = ownerWithdraw;                  //�Ѿ����ߵ�����

    require(_total > _withdrawed, "No need to withdraw"); //����Ѿ����߳���������ô��������

    ownerWithdraw = _total;                               //�����������Ѿ����ߵ�������Ϊ��Լ�������������񱣻��ģ�������ִ��Ҳû����
    owner.transfer(_total.sub(_withdrawed));              //����Լ������ת��
  }

  /**
   * ���ĺ�Լ�����ߣ�ֻ�к�Լ�����߿��Ե���
   */
  function changeOwner(address newOwner)
  onlyOwner()
  public
  {
    owner = newOwner;
  }

  /**
   * ��ȡ��ǰ������Ϸ����Ϣ
   *
   * @return round id
   * @return total eth for round
   * @return total keys for round
   * @return time round started
   * @return time round ends
   * @return current leader
   * @return lastest price
   * @return current key price
   */
  function getCurrentRoundInfo()
  public
  view
  returns (uint256, uint256, uint256, uint256, uint256, address, uint256, uint256)
  {

    uint256 _rndNo = rndNo;

    return (
    _rndNo,
    round_m[_rndNo].eth,
    round_m[_rndNo].keys,
    round_m[_rndNo].startTime,
    round_m[_rndNo].endTime,
    round_m[_rndNo].leader,
    round_m[_rndNo].lastPrice,
    getBuyPrice()
    );
  }

  /**
   * ��ȡ������Ϸ�ĵ�һ�׶εĹ���۸�
   *
   * @return price for next key bought (in wei format)
   */
  function getBuyPrice()
  public
  view
  returns (uint256)
  {
    uint256 _rndNo = rndNo;
    uint256 _now = now;

    // start next round?
    if (_now > round_m[_rndNo].endTime)
    {
      return (75000000000000);
    }
    if (round_m[_rndNo].keys < 10000000000000000000000000)
    {
      return ((round_m[_rndNo].keys.add(1000000000000000000)).ethRec(1000000000000000000));
    }
    //second stage
    return (0);
  }
}

// key����
library KeysCalc {

  //������ѧ����
  using SafeMath for *;

  /**
   * �����յ�һ��ethʱ������key����
   *
   * @param _curEth current amount of eth in contract
   * @param _newEth eth being spent
   * @return amount of ticket purchased
   */
  function keysRec(uint256 _curEth, uint256 _newEth)
  internal
  pure
  returns (uint256)
  {
    return (keys((_curEth).add(_newEth)).sub(keys(_curEth)));
  }

  /**
   * �������һ��keyʱ�յ���eth����
   *
   * @param _curKeys current amount of keys that exist
   * @param _sellKeys amount of keys you wish to sell
   * @return amount of eth received
   */
  function ethRec(uint256 _curKeys, uint256 _sellKeys)
  internal
  pure
  returns (uint256)
  {
    return ((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
  }

  /**
   * ����һ��������eth��һ�����key
   *
   * @param _eth eth "in contract"
   * @return number of keys that would exist
   */
  function keys(uint256 _eth)
  internal
  pure
  returns (uint256)
  {
    return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
  }

  /**
   * �������key���������eth����
   *
   * @param _keys number of keys "in contract"
   * @return eth that would exists
   */
  function eth(uint256 _keys)
  internal
  pure
  returns (uint256)
  {
    return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
  }
}

/**
 * ��ѧ������
 *
 * @dev Math operations with safety checks that throw on error
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {

  /**
  * �˷�
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
  * ����
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
  * �ӷ�
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
   * ƽ����
   */
  function sqrt(uint256 x)
  internal
  pure
  returns (uint256 y)
  {
    uint256 z = ((add(x, 1)) / 2);
    y = x;
    while (z < y)
    {
      y = z;
      z = ((add((x / z), z)) / 2);
    }
  }

  /**
   * ƽ��
   */
  function sq(uint256 x)
  internal
  pure
  returns (uint256)
  {
    return (mul(x, x));
  }

  /**
   * �˷�����
   */
  function pwr(uint256 x, uint256 y)
  internal
  pure
  returns (uint256)
  {
    if (x == 0)
      return (0);
    else if (y == 0)
      return (1);
    else
    {
      uint256 z = x;
      for (uint256 i = 1; i < y; i++)
        z = mul(z, x);
      return (z);
    }
  }
}