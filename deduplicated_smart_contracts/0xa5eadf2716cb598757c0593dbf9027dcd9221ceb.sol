pragma solidity >=0.4.25 <0.6.0;

import './SafeMath.sol';
import './ILocker.sol';

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Swap is Pausable, ERC20 {
    using SafeMath for uint256;
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    string public name;
    string public symbol;
    uint8 public decimals;
    ILocker private _locker;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    constructor() public {
        name = "SWAP";
        symbol = "SWAP";
        decimals = 18;
        totalSupply = 3100000000 * 10 ** uint256(decimals);
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    function mint(address to, uint256 _value) onlyOwner public returns (bool success) {
		require (_value > 0); 
        balances[to] = SafeMath.add(balances[to], _value);                      
        totalSupply = SafeMath.add(totalSupply,_value);                                // Updates totalSupply
        emit Mint(to, _value);
        return true;
    }

    function burn(address from, uint256 _value) onlyOwner public returns (bool success) {
        require (balances[from] >= _value);                                            // Check if the sender has enough
		require (_value > 0); 
        balances[from] = SafeMath.sub(balances[from], _value);                         // Subtract from the sender
        totalSupply = SafeMath.sub(totalSupply,_value);                                // Updates totalSupply
        emit Burn(from, _value);
        return true;
    }

    function setLockStrategy(ILocker locker) onlyOwner public {
        _locker = locker;
    }

    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
        require(_to != address(0));

        address _from = msg.sender;
        uint available = availableBalanceOf(_from);

        if (_value <= available)
        {
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
            return true;
        }
        else
        {
            return false;
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function availableBalanceOf(address _owner) public view returns (uint256 balance) {
        uint locked = 0;

        if (address(_locker) != address(0))
            locked = _locker.lockedBalanceOf(_owner);

        return balances[_owner].sub(locked);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(_to != address(0));
        uint available = availableBalanceOf(_from);

        require(_value <= available);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
}