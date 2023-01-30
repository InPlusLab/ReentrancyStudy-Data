/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
}

contract ERC20Events {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _addr) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Ownable {
  address private owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, 'authentication error');
    _;
  }
  
  function ownershipTransfer(address _addr) internal returns (bool) {
        owner = _addr;
        return true;
    }
}

contract BlackList {
    using SafeMath for uint256;
    
    event BlackListSetting(address indexed _addr, bool status);

    mapping(address => bool) private blackList;
    
    function _blackListAdd(address _addr) internal returns (bool) {
        blackList[_addr] = true; 
        emit BlackListSetting(_addr, true);
        return true;
    }

    function _blackListRemove(address _addr) internal returns (bool) {
        delete blackList[_addr];
        emit BlackListSetting(_addr, false);
        return true;
    }
    
    function accountStatus(address _addr) public view returns (bool) {
        return blackList[_addr];
    }
}

contract Pausable is Ownable {
    bool private isPause;
    
    event PauseTransaction(address indexed _pauser, bool indexed status);

    constructor () internal {
        isPause = false;
    }

    modifier canTrans() {
        require(!isPause, 'transaction is currently paused');
        _;
    }

    function pauseSwitch() public onlyOwner {
        isPause = !isPause;
        emit PauseTransaction(msg.sender, isPause);
    }
}

contract FansiToken is ERC20, Ownable, BlackList, Pausable{
    using SafeMath for uint256;
    
    event Mint(address indexed _addr, uint256 _value);
    event Burn(address indexed _addr, uint256 _value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    string public name;
    string public symbol;
    uint8 public decimals;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    uint256 public maxSupply;
    uint256 public _totalSupply;
    
    constructor (string memory _name, string memory _symbol, uint8 _decimals, uint256 _maxSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        maxSupply = _maxSupply;
    }
  
    function transferOwnership(address _addr) public notNull(_addr) onlyOwner {
        require(!accountStatus(_addr), 'address is on black list');
        uint256 remainTokens = _balances[msg.sender];
        _balances[msg.sender] = 0;
        _balances[_addr] = _balances[_addr].add(remainTokens);
        emit Transfer(msg.sender, _addr, remainTokens);
        emit OwnershipTransferred(msg.sender, _addr);
        ownershipTransfer(_addr);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply.sub(_balances[address(0x0)]);
    }
    
    function balanceOf(address _addr) public view returns (uint256) {
        return _balances[_addr];
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowances[_owner][_spender];
    }
    
    function transfer(address _to, uint256 _value) public canTrans returns (bool) {
        require(!accountStatus(msg.sender), 'sender is on bloack list');
        return transferFrom(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public notNull(_to) canTrans returns (bool)
    {
        require(!accountStatus(_from), 'sender is on bloack list');
        require(_balances[_from] >= _value, "insufficient balance");
        
        if (_from != msg.sender) {
            require(_allowances[_from][msg.sender] >= _value, "allowance failed insufficient balance");
            _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
        }

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }
    
    function approve(address _spender, uint256 _value) public notNull(_spender) canTrans returns (bool) {
        require(!accountStatus(msg.sender), 'sender is on bloack list');
        require((_value == 0) || (_allowances[msg.sender][_spender] == 0), 'Please reset to zero before approval');

        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function transferAnyERC20Token(address _tokenAddr, address _to, uint256 _value) public onlyOwner returns (bool success) 
    {
        return ERC20(_tokenAddr).transfer(_to, _value);
    }
    
    function reclaimEther(address payable _addr, uint256 _value) external onlyOwner{
        require(!accountStatus(_addr), 'receiver is on bloack list');
        require(address(this).balance >= _value);
        _addr.transfer(_value);
    }
    
    function mint(uint256 _value) public onlyOwner 
    {
        require((_value > 0), 'mint amount should be greater than 0');
        require(_totalSupply.add(_value) <= maxSupply, 'over maximum supply');
        _balances[msg.sender] = _balances[msg.sender].add(_value);
        _totalSupply = _totalSupply.add(_value);
        
        emit Transfer(address(this), msg.sender, _value);
    }
 
    function burn(uint256 _value) public onlyOwner 
    {
        require(_balances[msg.sender] >= _value, 'insufficient balance');
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        
        emit Transfer(msg.sender, address(0x0), _value);
    }
    
    function blackListAdd(address _addr) public onlyOwner returns (bool){
        _blackListAdd(_addr);
    }
    
    function blackListRemove(address _addr) public onlyOwner returns (bool){
        _blackListRemove(_addr);
    }
    
    function blackFundRemove(address _addr) public onlyOwner returns (bool) {
        require(accountStatus(_addr), 'address not in black list');
        _blackFundRemove(_addr);
        return true;
    }
    
    function _blackFundRemove(address addr) internal {
        uint256 blackFunds = _balances[addr];
        _balances[addr] = 0;
        _totalSupply = _totalSupply.sub(blackFunds);

        emit Transfer(addr, address(0x0), blackFunds);
    }

    modifier notNull(address _address) {
        require(_address != address(0x0), "ERC20: request from the zero address");
        _;
    }
}