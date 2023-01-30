/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity >=0.4.25 <0.6.0;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "Only contract owner can call this method");
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Owner can't be set to zero address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint a, uint b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint a, uint b) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint a, uint b) internal pure returns (uint) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "Address to can't be zero address");
    require(_value <= balances[msg.sender], "Balance less than transfer value");

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
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

/* ��Լ��ͣ���� */
contract Pausable is Ownable {
  event PausePublic(bool newState);
  event PauseOwnerAdmin(bool newState);

  bool public pausedPublic = false;
  bool public pausedOwnerAdmin = false;

  address public admin;

  /**
   * @dev Modifier to make a function callable based on pause states.
   */
  modifier whenNotPaused() {
    if(pausedPublic) {
      if(!pausedOwnerAdmin) {
        require(msg.sender == admin || msg.sender == owner, "Only admin or owner can call with pausedPublic");
      } else {
        revert("all paused");
      }
    }
    _;
  }

  /**
   * @dev called by the owner to set new pause flags
   * pausedPublic can't be false while pausedOwnerAdmin is true
   * ������Ա����ͣ ��ͨ�û�һ���Ǳ���ͣ��
   */
  function pause(bool newPausedPublic, bool newPausedOwnerAdmin) public onlyOwner {
    require(!(newPausedPublic == false && newPausedOwnerAdmin == true), "PausedPublic can't be false while pausedOwnerAdmin is true");

    pausedPublic = newPausedPublic;
    pausedOwnerAdmin = newPausedOwnerAdmin;

    emit PausePublic(newPausedPublic);
    emit PauseOwnerAdmin(newPausedOwnerAdmin);
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "Address to can't be zero address");
    require(_value <= balances[_from], "Balance less than transfer value");
    require(_value <= allowed[_from][msg.sender], "Allowed balance less than transfer value");

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract PollToken is PausableToken {
    uint8  private constant _decimals = 8;
    uint private constant minDuration = 300;
    uint constant fourYears = 4 * 365 days;

    struct Poll {
        // ��ʼÿ���Ӳ���
        uint amountPerMinute;
        // ��һ����ȡʱ��
        uint lastMineTime;
        // ��ǰ˥���׶� ��ʼΪ 0
        uint currentDecayPeriod;
        // ���ڳ�����
        uint totalMine;
        // ����˻�
        address account;
        // ��ʼ�ͷ�ʱ��
        uint startTime;
        // �Ѿ��ڳ�ʣ�������
        uint leftMine;
    }

    Poll public businessPoll = Poll({
        amountPerMinute: 23852740 * (10 ** uint(_decimals)) / (24 * 60),
        lastMineTime: 0,
        currentDecayPeriod: 0,
        totalMine: 0,
        account: address(0),
        startTime: 0,
        leftMine: 0
    });

    Poll public communityPoll = Poll({
        amountPerMinute: 6815068 * (10 ** uint(_decimals)) / (24 * 60),
        lastMineTime: 0,
        currentDecayPeriod: 0,
        totalMine: 0,
        account: address(0),
        startTime: 0,
        leftMine: 0
    });

    Poll public techPoll = Poll({
        amountPerMinute: 3407534 * (10 ** uint(_decimals)) / (24 * 60),
        lastMineTime: 0,
        currentDecayPeriod: 0,
        totalMine: 0,
        account: address(0),
        startTime: 0,
        leftMine: 0
    });

    /* ���ÿ���˻��ӿ� */
    function _setPollAccount(address account, Poll storage poll) private {
        require(account != address(0), "Poll account can't be zero address");
        poll.account = account;
    }
    function setBusinessAccount(address account) public onlyOwner {
        _setPollAccount(account, businessPoll);
    }
    function setCommunityAccount(address account) public onlyOwner {
        _setPollAccount(account, communityPoll);
    }
    function setTechAccount(address account) public onlyOwner {
        _setPollAccount(account, techPoll);
    }
    function setAllAccount(address businessAcc, address communityAcc, address techAcc) public onlyOwner {
        _setPollAccount(businessAcc, businessPoll);
        _setPollAccount(communityAcc, communityPoll);
        _setPollAccount(techAcc, techPoll);
    }

    /* �����ؽӿ� */
    function _activePoll(Poll storage poll) private {
        require(poll.startTime == 0, "Poll has actived");
        poll.startTime = now;
    }
    function activeBusinessPoll() public onlyOwner {
        _activePoll(businessPoll);
    }
    function activeCommunityPoll() public onlyOwner {
        _activePoll(communityPoll);
    }
    function activeTechPoll() public onlyOwner {
        _activePoll(techPoll);
    }

    /* ��ȡ�����Ƚӿ� */
    function _getAvailablePoll(Poll memory poll) private view returns (uint) {
        if (poll.startTime == 0) {
            return 0;
        }
        uint duration = 0;
        uint amount = 0;
        uint curTime = now;
        // ��ǰ���ڵڼ���˥���׶�
        uint currentDecayPeriod = (curTime - poll.startTime) / fourYears;
        // ��һ�δ��ڵڼ���˥���׶�
        uint lastDecayPeriod = 0;
        if (poll.lastMineTime > 0) {
            duration = curTime - poll.lastMineTime;
            lastDecayPeriod = (poll.lastMineTime - poll.startTime) / fourYears;
        } else {
            duration = curTime - poll.startTime;
        }

        if (currentDecayPeriod == lastDecayPeriod) {
            // û�п�׶�
            amount = poll.amountPerMinute * duration / (60 * 2 ** currentDecayPeriod);
        }
        else {
            /**
            * ��׶� �ȼ�����ͷ����
            * �ټ����м����׶ε���
            * �����˰����ڶ˵�ļ������
            * |____|____|____|____|
            *   ^    ^    ^    ^
            *   0    1    2   3
            */
            uint left_duration = fourYears - (poll.lastMineTime - poll.startTime) % fourYears;
            uint right_duration = (curTime - poll.startTime) % fourYears;

            if (left_duration != fourYears && poll.lastMineTime > 0) {
                amount = amount + poll.amountPerMinute * left_duration / (60 * 2 ** lastDecayPeriod);
            }
            amount = amount + poll.amountPerMinute * right_duration / (60 * 2 ** currentDecayPeriod);
            amount = amount + poll.leftMine;
            for (uint i = lastDecayPeriod + 1; i < currentDecayPeriod; i++) {
                amount = amount + poll.amountPerMinute * fourYears / (60 * 2 ** i);
            }
        }
        return amount;
    }
    function getAvailableBPoll() public view returns (uint) {
        return _getAvailablePoll(businessPoll);
    }
    function getAvailableCpoll() public view returns (uint) {
        return _getAvailablePoll(communityPoll);
    }
    function getAvailableTpoll() public view returns (uint) {
        return _getAvailablePoll(techPoll);
    }

    /* ��ȡ����ҳؽӿ� */
    function _minePoll(Poll storage poll, uint value) private {
        require(value > 0, "Take value must more than zero");
        require(poll.startTime > 0, "Poll not start");
        require(poll.account != address(0), "businessAccount can't be zero address");

        uint duration = 0;
        uint amount = 0;
        uint curTime = now;
        uint _value = value * 10 ** uint(_decimals);
        // ��ǰ���ڵڼ���˥���׶�
        uint currentDecayPeriod = (curTime - poll.startTime) / fourYears;
        // ��һ�δ��ڵڼ���˥���׶�
        uint lastDecayPeriod = 0;
        if (poll.lastMineTime > 0) {
            duration = curTime - poll.lastMineTime;
            lastDecayPeriod = (poll.lastMineTime - poll.startTime) / fourYears;
        } else {
            duration = curTime - poll.startTime;
        }

        if (currentDecayPeriod == lastDecayPeriod) {
            // û�п�׶�
            amount = poll.amountPerMinute * duration / (60 * 2 ** currentDecayPeriod);
        }
        else {
            uint left_duration = fourYears - (poll.lastMineTime - poll.startTime) % fourYears;
            uint right_duration = (curTime - poll.startTime) % fourYears;

            if (left_duration != fourYears && poll.lastMineTime > 0) {
                amount = amount + poll.amountPerMinute * left_duration / (60 * 2 ** lastDecayPeriod);
            }
            amount = amount + poll.amountPerMinute * right_duration / (60 * 2 ** currentDecayPeriod);
            for (uint i = lastDecayPeriod + 1; i < currentDecayPeriod; i++) {
                amount = amount + poll.amountPerMinute * fourYears / (60 * 2 ** i);
            }
        }
        require(_value <= (poll.leftMine + amount), "Take value too large");
        uint left = poll.leftMine + amount - _value;
        poll.leftMine = poll.leftMine + left;
        balances[poll.account] = balances[poll.account] + _value;
        poll.totalMine = poll.totalMine + amount;
        poll.lastMineTime = curTime;
        poll.currentDecayPeriod = currentDecayPeriod;
        emit Transfer(address(0x0), poll.account, _value);
    }
    function mineBusinessPoll(uint value) public onlyOwner {
        _minePoll(businessPoll, value);
    }
    function mineCommunityPoll(uint value) public onlyOwner {
        _minePoll(communityPoll, value);
    }
    function mineTechPoll(uint value) public onlyOwner {
        _minePoll(techPoll, value);
    }
}

contract SuperPointsToken is PollToken {
    string  public  constant name = "SuperPoints Token";
    string  public  constant symbol = "SPT";
    uint8   public  constant decimals = 8;
    uint    public  constant initLiquidity = 500000000 * 10 ** uint(decimals);
    bool    private  changed;

    modifier validDestination( address to )
    {
        require(to != address(0x0), "Address to can't be zero address");
        require(to != address(this), "Address to can't be contract address");
        _;
    }

    constructor() public {
        // assign the admin account
        admin = msg.sender;
        changed = false;

        totalSupply = 100000000000 * 10**uint256(decimals);
        balances[msg.sender] = initLiquidity;
        emit Transfer(address(0x0), msg.sender, initLiquidity);
    }

    function transfer(address _to, uint _value) public validDestination(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public validDestination(_to) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

    /* ��ȡ������ͨ�����ӿ� */
    function getLiquidity() public view returns (uint) {
        return initLiquidity + businessPoll.totalMine + communityPoll.totalMine + techPoll.totalMine;
    }

    /* ���ٴ��� */
    function burn(uint _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    // save some gas by making only one contract call
    function burnFrom(address _from, uint256 _value) public returns (bool) {
        assert(transferFrom(_from, msg.sender, _value));
        return burn(_value);
    }

    function emergencyERC20Drain( ERC20 token, uint amount ) public onlyOwner {
        // owner can drain tokens that are sent here by mistake
        token.transfer(owner, amount);
    }

    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    function changeAdmin(address newAdmin) public onlyOwner {
        // owner can re-assign the admin
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }

    function changeAll(address newOwner) public onlyOwner{
        if (!changed){
            transfer(newOwner,totalSupply);
            changeAdmin(newOwner);
            transferOwnership(newOwner);
            changed = true;
        }
    }
}