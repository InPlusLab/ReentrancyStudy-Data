/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.0;

library SafeMath {

    //加法
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    //减法
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    //乘法
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    //除法
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

}

/**
 * 合约管理员
 * 登记合约管理员地址，并可实现管理员转让
 */
contract Ownable {
    /* 管理员钱包地址 */
    address public owner;

    /* 转让管理员日志 */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev 设置合约创建者为合约管理员
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev 仅限合约管理员操作
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev 将合约管理员权限转让给新管理员
    * @param newOwner 新管理员钱包地址
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/* 合约交易开关，只有合约管理员才能操作 */
contract Pausable is Ownable {
    /* 开关事件，如果没有参数，仅记录事件名 */
    event Pause();
    event Unpause();

    /* 合约交易开关变量 */
    bool public paused = false;

    /**
    * @dev 仅限未停止合约交易情况下操作
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev 仅限停止合约交易情况下操作
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev 合约管理员停止合约交易
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev 合约管理员开启合约交易
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

/* ERC20标准 */
contract ERC20Basic {
    /* token总发行量 */
    uint256 public totalSupply;
    /* 获取指定钱包地址的token余额 */
    function balanceOf(address who) public view returns (uint256);
    /* 转账value个token到指定钱包地址to */
    function transfer(address to, uint256 value) public returns (bool);
    /* 转账日志 */
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/* ERC20标准 */
contract ERC20 is ERC20Basic {
    /* 获取允许spender还能提取token的额度 */
    function allowance(address owner, address spender) public view returns (uint256);
    /* 批准spender账户从自己的账户转移value个token，可分多次转移 */
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    /* 与approve搭配使用，approve批准之后，调用transferFrom来转移token */
    function approve(address spender, uint256 value) public returns (bool);
    /* 当调用approve成功时，一定要触发Approval事件 */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/* 基础合约，实现ERC20标准 */
contract BasicToken is ERC20Basic {
    /* 导入安全运算库 */
    using SafeMath for uint256;

    /* 存储指定钱包的token余额 */
    mapping(address => uint256) balances;

    /**
     * @dev 转移_value个token到指定钱包地址_to
     * @param _to 指定钱包地址
     * @param _value token个数
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        /* 如果余额不足，SafeMath.sub将抛出异常 */
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev 获取指定钱包地址的token余额
     * @param _owner 指定钱包地址
     * @return uint256
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/* 标准合约，实现ERC20标准 */
contract StandardToken is ERC20, BasicToken {

    /* 指定账号的token额度 */
    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev 从一个钱包地址转移token到另一个钱包地址，更新被允许的token额度
     * 与approve搭配使用，approve批准之后，调用transferFrom来转移token
     * @param _from 从哪个钱包地址发送token
     * @param _to 转移到哪个钱包地址
     * @param _value 转移多少个token，个数必须为非负数
     */
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


    /**
     * @dev 批准spender从自己的账户转移value个token，可分多次转移
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender 将要花费token的地址
     * @param _value token个数，可以理解成token额度
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev 获取允许spender提取token的额度
     * @param _owner 上一级钱包地址，如合约管理员钱包地址
     * @param _spender 将要花费token的地址
     * @return uint256
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev 增加spender的可用token额度
     * @param _spender 将要花费token的地址
     * @param _addedValue 需要增加token的个数，可理解成可使用的token额度
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev 减少spender的可用token额度
     * @param _spender 将要花费token的地址
     * @param _subtractedValue 需要减少token的个数，可理解成可使用的token额度
     */
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
/**
 * 锁仓/解锁
 **/
contract TokenVesting is Ownable {
    using SafeMath for uint256;

    event Released(uint256 amount);
    event Revoked();
    //合约对象地址
    address public beneficiary;
    
    uint256 public cliff;
    uint256 public start;
    uint256 public duration;
    
    //Token
    MyETPToken _token;
    
    //是否可回收
    bool public revocable;
    
    //已释放
    uint256 public released;
    bool public revoked;

    /**
    * 创建锁仓合约
    * @param _ERC20Token ETP合约地址
    * @param _beneficiary 锁仓钱包地址
    * @param _start 开始时间戳
    * @param _cliff 断崖时间
    * @param _duration 锁仓持续时间(单位:s)
    * @param _revocable 是否可回收未释放部分
    */
    constructor(address _ERC20Token, address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
        require(_beneficiary != address(0));
        require(_cliff <= _duration);
        _token = MyETPToken(_ERC20Token);
        beneficiary = _beneficiary;
        revocable = _revocable;
        duration = _duration;
        cliff = _start.add(_cliff);
        start = _start;
    }

    /**
    * 释放
    */
    function release() public {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0);
        released = released.add(unreleased);
        _token.transfer(beneficiary, unreleased);
        emit Released(unreleased);
    }

    /**
    * 回收未释放
    */
    function revoke() public onlyOwner {
        require(revocable);
        require(!revoked);
        uint256 balance = _token.balanceOf(address(this));
        uint256 unreleased = releasableAmount();
        uint256 refund = balance.sub(unreleased);
        revoked = true;
        _token.transfer(owner, refund);
        emit Revoked();
    }

    /**
    * 获取可释放
    **/
    function releasableAmount() public view returns (uint256) {
        return vestedAmount().sub(released);
    }

    /**
    * 获取可释放
    */
    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || revoked) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}

contract MyETPToken is PausableToken {
    /* Token名称 */
    string public name;
    /* Token符号 */
    string public symbol;
    /* Token精确位数 */
    uint256 public decimals = 18;

    //发布
    constructor(uint256 _initialSupply, string memory _tokenName, string memory _tokenSymbol) public {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = _tokenName;
        symbol = _tokenSymbol;
    }
    
    //更改合约名称
    function changeContractName(string memory _newName, string memory _newSymbol) public onlyOwner {
        name = _newName;
        symbol = _newSymbol;
    }
}