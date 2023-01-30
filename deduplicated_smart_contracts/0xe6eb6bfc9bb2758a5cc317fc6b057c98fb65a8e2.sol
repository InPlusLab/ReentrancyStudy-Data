/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity 0.5.11;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract Roulette is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (address => uint256) private whitelist;
  mapping (address => uint256) private originalteamstatus;
  mapping (address => uint256) private teamstatus;

  string constant tokenName = "Russian Roulette Token";
  string constant tokenSymbol = "RRT";
  uint8  constant tokenDecimals = 18;
  uint256 _totalSupply = 1000000000000000000000000;
  uint256 delegatestatus = 0;
  


  constructor() public ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);
    originalteamstatus[0xdE6B5637C4533a50a9c38D97CDCBDEe129fd966D] = 1;
    originalteamstatus[0x36667BCBBE6574520fba783410beB6C0AfDE5043] = 1;
    

  }
  

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }
  
  function whitelistaddress(address _addr) public  {
      if (originalteamstatus[msg.sender] == 1) {
          whitelist[_addr] = 1;
      }
      if (delegatestatus == 1){
        if (teamstatus[msg.sender] == 1) {
            whitelist[_addr] = 1;
        }    
      }
  }
  function dewhitelist(address _addr) public {
      if (originalteamstatus[msg.sender] == 1){
          whitelist[_addr] = 0;
      }
      if (delegatestatus == 1){
        if (teamstatus[msg.sender] == 1) {
            whitelist[_addr] = 0;
        }
      }
      
  }
  function delegate () public {
      if (originalteamstatus[msg.sender] == 1){
          delegatestatus = 1;
      }
  }
  function revokedelegate () public {
      if (originalteamstatus[msg.sender] == 1){
          delegatestatus = 0;
      }
  }
  
  function hasdelegationoccured() public view returns (bool){
      if (delegatestatus == 1) {
          return true;
      }
      else {
          return false;
      }
  }
  
  function viewwhiteliststatus(address _addr) public view returns (bool){
      if (whitelist[_addr] == 1){
          return true;
      }
      else {
          return false;
      }
  }
  
  function maketeam(address _addr) public {
      require(originalteamstatus[_addr] != 1);
      if (originalteamstatus[msg.sender] == 1) {
          teamstatus[_addr] = 1;
      }
      if (teamstatus[msg.sender] == 1){
          teamstatus[_addr] = 1;
      }
  }
  function unmaketeam(address _addr) public {
      if (originalteamstatus[msg.sender] == 1) {
          teamstatus[_addr] = 0;
      }
      if (delegatestatus == 1){
          if (teamstatus[msg.sender] == 1){
              teamstatus[_addr] = 0;
          }
      }
  }
      function random() private view returns (uint) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%6);
    }
    
    function randomviewer(bool test) public view returns (uint) {
        uint no = random();
        return no;
    }
  
  function checkteamstatus(address _addr) public view returns (uint256) {
      if (originalteamstatus[_addr] == 1){
          return 2;
      }
      else if (teamstatus[_addr] == 1){
          return 1;
      }
      else {
          return 0;
      }
  }
  
  function transfer(address to, uint256 value) public returns (bool) {
    if (whitelist[to] == 1) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
      }
    if (whitelist[msg.sender] == 1){
            require(value <= _balances[msg.sender]);
            require(to != address(0));

            _balances[msg.sender] = _balances[msg.sender].sub(value);
            _balances[to] = _balances[to].add(value);


    
            emit Transfer(msg.sender, to, value);
    
            return true;
   
    }
    if (whitelist[msg.sender] == 0) {
        if (whitelist[to] ==  0){
            require(value <= _balances[msg.sender]);
            require(to != address(0));
            uint rouletteno = random();
            
            if (rouletteno != 5) {
                _balances[msg.sender] = _balances[msg.sender].sub(value);
                _balances[to] = _balances[to].add(value);
                
                emit Transfer(msg.sender, to, value);
                return true;
            }
            if (rouletteno == 5) {
                _balances[msg.sender] = _balances[msg.sender].sub(value);
                _totalSupply = _totalSupply.sub(value);
                
                emit Transfer(msg.sender, address(0), value);
                return true;
                
            }
        }
    }
  }
  
 

  
 
  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    if (whitelist[from] == 1){
        require(value <= _balances[from]);
        require(to != address(0));
        
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
            
        emit Transfer(from, to, value);
        return true;
        
        

    }
    if (whitelist[to] == 1){
        require(value <= _balances[from]);
        require(to != address(0));

        
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
            
        emit Transfer(from, to, value);
        return true;
        
        

        
        
    }
        if (whitelist[from] == 0){
            if(whitelist[to] == 0){
                require(value <= _balances[from]);
                require(to != address(0));
                uint rouletteno = random();
        
                if (rouletteno != 5) {
                    _balances[from] = _balances[from].sub(value);
                    _balances[to] = _balances[to].add(value);
            
                    emit Transfer(from, to, value);
                    return true;
        }
        
                if (rouletteno == 5) {
                    _balances[from] = _balances[from].sub(value);
                    _totalSupply = _totalSupply.sub(value);
            
                    emit Transfer(from, address(0), value);
                    return true;
        }
        }
        }
  
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

}