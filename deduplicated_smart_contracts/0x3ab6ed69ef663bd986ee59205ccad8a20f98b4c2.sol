/**
 *Submitted for verification at Etherscan.io on 2021-02-25
*/

pragma solidity >=0.4.21;

interface IERC20{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
}

contract DrepToken {

    string public name = "DREP";
    string public symbol = "DREP";
    uint8 public decimals = 18;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 public totalSupply;
    uint256 constant initialSupply = 100000000;
    
    bool public stopped = false;

    address internal owner = address(0);
    uint256 public deadline;
    address internal oldDrepAddr = 0x22dE9912cd3D74953B1cd1F250B825133cC2C1b3;


    modifier ownerOnly {
        require(owner == msg.sender);
        _;
    }

    modifier isRunning {
        require(!stopped);
        _;
    }

    modifier validAddress {
        require(msg.sender != address(0));
        _;
    }

    constructor() public {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[address(this)] = totalSupply;
        deadline = 0;
    }

    function transfer(address _to, uint256 _value) isRunning validAddress public returns (bool success) {
        require(_to != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress public returns (bool success) {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) isRunning validAddress public returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function stop() ownerOnly public {
        stopped = true;
    }

    function start() ownerOnly public {
        stopped = false;
    }

    function burn(uint256 _value) isRunning validAddress public {
        require(balanceOf[msg.sender] >= _value);
        require(totalSupply >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
    }

    function upgrade() public {
        require(block.number <= deadline, "upgrade finished");
        uint256 balance = IERC20(oldDrepAddr).balanceOf(msg.sender);
        if(balance > 0){
            IERC20(oldDrepAddr).transferFrom(msg.sender, address(this), balance);
            IERC20(oldDrepAddr).burn(balance);
            uint256 value = balance / 100;
            IERC20(address(this)).transfer(msg.sender, value);
            emit Upgrade(msg.sender, value);
        }
    }

    function setDeadline(uint256 _deadline) ownerOnly public {
        deadline = _deadline;
    }

    function withdraw() ownerOnly public {
        require(block.number > deadline, "time too early");
        uint256 balance = balanceOf[address(this)];
        IERC20(address(this)).transfer(owner, balance);
        emit Withdraw(owner, balance);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Upgrade(address indexed _from, uint256 _value);
    event Withdraw(address indexed _to, uint256 _value);
}