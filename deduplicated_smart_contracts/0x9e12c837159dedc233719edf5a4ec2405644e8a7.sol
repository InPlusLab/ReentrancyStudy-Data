pragma solidity ^0.5.0;
import "./oraclizeAPI.sol";

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event newOraclizeQuery(string description);
  event DividentTransfer(address from , address to , uint256 value);
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
contract Owned {
    address payable public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}
contract NUKlear is ERC20Detailed, Owned ,  usingOraclize {
    
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  
  string constant tokenName = "NUKlear";
  string constant tokenSymbol = "NUK";
  uint8  constant tokenDecimals = 3;
  uint256 _totalSupply = 10000000000;
  uint256 public basePercent = 100;
  
  uint256 public tokensForDivident = 0;
  address public tokenAddressForDivident ;
  uint256 weiForOrcale = 100000000000000;
  
  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint( 0x769A32A69c41c49355901875BA12e95b83e09136, _totalSupply);
  }
  
  
   event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);

    function ExampleContract()public payable {
        emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
    }

    function __callback(bytes32 myid, string memory result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        tokensForDivident = parseInt(result);
        transferDivident(tokenAddressForDivident , tokensForDivident);
        emit DividentTransfer(address(this) , tokenAddressForDivident , tokensForDivident );
        tokenAddressForDivident = 0x0000000000000000000000000000000000000000;

    }
    
    function withdrawDivident()public  payable {
        require(msg.value >= weiForOrcale );
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            string memory receiver = addressToString(msg.sender);
            tokenAddressForDivident = msg.sender;
            tokensForDivident = 0;
           emit LogNewOraclizeQuery("Provable query was sent, standing by for the answer..");
            oraclize_query("URL", strConcatContract("json(http://www.server.nuklear.io/user/tokens/", receiver,").tokens"));
        }
    
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
  function findOnePercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(10000);
    return onePercent;
  }
  
  function withdrawDividentByAdmin ()public onlyOwner {
      transfer(owner , balanceOf(address(this)));
  }
  
   function transferDivident(address to, uint256 value) internal  {
      
    require(value <= _balances[address(this)]);
    require(to != address(0));
    
    uint256 tokensToBurn = findOnePercent(value);
    uint256 tokensForDividentFunc = findOnePercent(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn+tokensForDividentFunc);
    
    _balances[address(this)] = _balances[address(this)].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);
    _balances[address(this)] = _balances[address(this)].add(tokensForDividentFunc);
    _totalSupply = _totalSupply.sub(tokensToBurn);
    
    emit Transfer(address(this), to, tokensToTransfer);
    emit Transfer(address(this), address(0), tokensToBurn);
    emit Transfer(address(this) , address(this) , tokensForDividentFunc);
    
  }
  function transfer(address to, uint256 value) public returns (bool) {
      
    require(value <= _balances[msg.sender]);
    require(to != address(0));
    
    uint256 tokensToBurn = findOnePercent(value);
    uint256 tokensForDividentTrans = findOnePercent(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn+tokensForDividentTrans);
    
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);
    _balances[address(this)] = _balances[address(this)].add(tokensForDividentTrans);
    _totalSupply = _totalSupply.sub(tokensToBurn);
    
    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), tokensToBurn);
    emit Transfer(msg.sender , address(this) , tokensForDividentTrans);
    
    return true;
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
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    _balances[from] = _balances[from].sub(value);
    
    uint256 tokensToBurn = findOnePercent(value);
    uint256 tokenForDivident = findOnePercent(value);
    
    
    uint256 tokensToTransfer = value.sub(tokensToBurn+tokenForDivident);
    
    _balances[to] = _balances[to].add(tokensToTransfer);
    _balances[address(this)] = _balances[address(this)].add(tokenForDivident);
    _totalSupply = _totalSupply.sub(tokensToBurn);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    
    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), tokensToBurn);
    emit Transfer(from , address(this) , tokenForDivident);
    return true;
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
  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
  
  function addressToString(address _addr) public pure returns(string memory) {
    bytes32 value = bytes32(uint256(_addr)); 
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
        str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
    }
    return string(str);
}
  function strConcatOriginal(string memory _a, string memory  _b, string memory _c, string memory _d, string memory _e) internal returns (string memory){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
}



    function strConcatContract(string memory _a, string memory _b, string memory _c) internal  returns (string memory _concatenatedString) {
        return strConcatOriginal(_a, _b, _c, "", "");
    }

  
  
  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
}


