/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity 0.4.26;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

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

contract HBIF is StandardToken {
    // 基本信息
    string public constant name = "HBIF";
    string public constant symbol = "HBIF";
    uint256 public INITIAL_SUPPLY = 1000000000000000;
    uint8 public constant decimals = 8;

    // 冻结
    mapping(address => bool) private frozenAccount;
    mapping(address => uint256) private frozenTimestamp;

    // 合约所有者
    address public owner;

    // 单个消息结构体
    struct Msg {
        uint256 timestamp;
        address sender;
        string content;
    }

    // 记录发送消息
    Msg[] private msgs;

    mapping(uint => address) public msgToOwner;
    mapping(address => uint) ownerMsgCount;

    // 事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event SendMsgEvent(address indexed _from, string _content);

    // 构造函数, 不需要参数
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY; // 5'000'000
        balances[0x537b569f39EfB56a7D1512e7e19185bA2C360e64] = INITIAL_SUPPLY; // 5'000'000
        owner = 0x537b569f39EfB56a7D1512e7e19185bA2C360e64; //
        emit Transfer(address(0),owner,totalSupply_);
    }

    // 标准修改器, 仅所有者可调用
    modifier onlyOwner {
        require(msg.sender == owner, "onlyOwner method called by non-owner.");
        _;
    }

    // 增加代币
    function increaseToken(address _target, uint256 _amount) external onlyOwner returns (bool) {
        require(_target != address(0));
        require(_amount > 0);
        balances[_target] = balances[_target].add(_amount);
        totalSupply_ = totalSupply_.add(_amount);
        INITIAL_SUPPLY = totalSupply_;
        return true;
    }

    // 减少代币
    function decreaseToken(address _target, uint256 _amount) external onlyOwner returns (bool) {
        require(_target != address(0));
        require(_amount > 0);
        balances[_target] = balances[_target].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        INITIAL_SUPPLY = totalSupply_;
        return true;
    }

    // 冻结帐户
    function freeze(address _target, bool _freeze) external onlyOwner returns (bool) {
        require(_target != address(0));
        frozenAccount[_target] = _freeze;
        return true;
    }

    // 冻结帐户
    function freezeByTimestamp(address _target, uint256 _timestamp) external onlyOwner returns (bool) {
        require(_target != address(0));
        frozenTimestamp[_target] = _timestamp;
        return true;
    }

    // 查询冻结帐户结束时间
    function getFrozenTimestamp(address _target) external onlyOwner view returns (uint256) {
        require(_target != address(0));
        return frozenTimestamp[_target];
    }

    // 转帐
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require(frozenAccount[msg.sender] != true);
        require(frozenTimestamp[msg.sender] < now);
        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    // 从某地址转帐
    function transferByOwner(address _from, address _to, uint256 _amount) external onlyOwner returns (bool) {
        require(_from != address(0));
        require(_to != address(0));
        require(balances[_from] >= _amount);

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Transfer(_from, _to, _amount);
        return true;
    }

    // 获取余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 销毁
    function kill() external onlyOwner {
        selfdestruct(msg.sender);
    }

    // 发送消息
    function sendMsg(string _content) external {
        uint id = msgs.push(Msg({
            timestamp:uint256(now),
            sender:msg.sender,
            content:_content
        })) - 1;

        msgToOwner[id] = msg.sender;
        ownerMsgCount[msg.sender]++;

        emit SendMsgEvent(msg.sender, _content);
    }

    // 获取消息
    function getMsg(uint _id) external view onlyOwner returns (string memory content, uint timestamp) {
        require(_id < msgs.length, "id should not larger than array length.");
        content = msgs[_id].content;
        timestamp = msgs[_id].timestamp;
        return (content, timestamp);
    }

    // 获取某人发的所有消息
    function getMsgsByOwner(address _owner) external view onlyOwner returns (uint[]) {
        uint[] memory result = new uint[](ownerMsgCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < msgs.length; i++) {
            if (msgToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    // 获取所有消息
    function getMsgsLength() external view onlyOwner returns (uint len) {
        len = msgs.length;
        return len;
    }
}