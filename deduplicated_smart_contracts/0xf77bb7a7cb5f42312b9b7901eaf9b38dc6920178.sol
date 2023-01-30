/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

/**
 HyperSonic Contract!
*/

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

contract HyperSonic is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;

  address feeWallet = 0x93EE253eA487F99C3998cBf58F2E1177F230CfCb;
  address ownerWallet = 0x6Ba900dbfcFd566FBEf878D8405D74947CCa3338;
  address uniswapWallet = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
 
  //For liquidity stuck fix
  address public liquidityWallet = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
 
  address[] sonicWallets = [feeWallet, feeWallet, feeWallet, feeWallet, feeWallet];
  uint256[] transactionWeights = [2, 2, 2, 2, 2];
  string constant tokenName = "HyperSonic";
  string constant tokenSymbol = "HyperSonic";
  uint8  constant tokenDecimals = 18;
  uint256 public _totalSupply = 10000000000000000000000;
  uint256 public base50Percent = 50;
  uint256 public base9Percent = 9;
  uint256 public foundationRatio = 100;
  bool public hyperSonic = false;
  bool public liqBugFixed = false;
  bool public presaleMode = true;
 
  //Pre defined variables
  uint256[] sonicPayments = [0, 0, 0, 0, 0];
  uint256 tokensForFees = 0;
  uint256 feesForSonic = 0;
  uint256 weightForSonic = 0;
  uint256 tokensForNewWallets = 0;
  uint256 weightForNew = 0;
  uint256 tokensToBurn = 0;
  uint256 tokensToTransfer = 0;
  uint256 totalLoss = 0;
 
 
 
    
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
 
  function getBurnPercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(foundationRatio);
    uint256 twentyFivePercent = roundValue.mul(foundationRatio).div(400); // 25 percent burn
    return twentyFivePercent;
  }

  function amountToTake1(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(base50Percent);
    uint256 amountLost50 = roundValue.mul(base50Percent).div(100);
    return amountLost50;
  }
  
  function amountToTake2(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(base9Percent);
    uint256 amountLost9 =  roundValue.mul(base9Percent).div(100);
    return amountLost9;
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    if (hyperSonic && liqBugFixed){
        tokensToBurn = getBurnPercent(value);
        
        _balances[msg.sender] = _balances[msg.sender].sub(value);
            
     
        address previousSonic = sonicWallets[0];
        uint256 sonicWeight = transactionWeights[0];
        sonicWallets[0] = sonicWallets[1];
        transactionWeights[0] = transactionWeights[1];
        sonicWallets[1] = sonicWallets[2];
        transactionWeights[1] = transactionWeights[2];
        sonicWallets[2] = sonicWallets[3];
        transactionWeights[2] = transactionWeights[3];
        sonicWallets[3] = sonicWallets[4];
        transactionWeights[3] = transactionWeights[4];
        //Ensure the liquidity wallet or uniswap wallet don't receive any fees also fix fees on buys
        if (msg.sender == uniswapWallet || msg.sender == liquidityWallet){
            sonicWallets[4] = to;
            transactionWeights[4] = 2;
        }
        else{
            sonicWallets[4] = msg.sender;
            transactionWeights[4] = 1;
        }
        totalLoss = amountToTake1(value);
        tokensForFees =  totalLoss.div(50);
        
        feesForSonic = tokensForFees.mul(15);
        weightForSonic = sonicWeight.add(transactionWeights[0]).add(transactionWeights[1]);
        sonicPayments[0] = feesForSonic.div(weightForSonic).mul(sonicWeight);
        sonicPayments[1] = feesForSonic.div(weightForSonic).mul(transactionWeights[0]);
        sonicPayments[2] = feesForSonic.div(weightForSonic).mul(transactionWeights[1]);
        sonicPayments[3] = feesForSonic.div(weightForSonic).mul(transactionWeights[2]);
        sonicPayments[4] = feesForSonic.div(weightForSonic).mul(transactionWeights[3]);
        
        tokensToTransfer = value.sub(totalLoss);
        
        _balances[to] = _balances[to].add(tokensToTransfer);
        _balances[previousSonic] = _balances[previousSonic].add(sonicPayments[0]);
        _balances[sonicWallets[0]] = _balances[sonicWallets[0]].add(sonicPayments[1]);
        _balances[sonicWallets[1]] = _balances[sonicWallets[1]].add(sonicPayments[2]);
        _balances[sonicWallets[2]] = _balances[sonicWallets[2]].add(sonicPayments[3]);
        _balances[sonicWallets[3]] = _balances[sonicWallets[3]].add(sonicPayments[4]);
        _totalSupply = _totalSupply.sub(tokensToBurn);
    
        emit Transfer(msg.sender, to, tokensToTransfer);
        emit Transfer(msg.sender, previousSonic, sonicPayments[0]);
        emit Transfer(msg.sender, sonicWallets[0], sonicPayments[1]);
        emit Transfer(msg.sender, sonicWallets[1], sonicPayments[2]);
        emit Transfer(msg.sender, sonicWallets[2], sonicPayments[3]);
        emit Transfer(msg.sender, sonicWallets[3], sonicPayments[4]);
        emit Transfer(msg.sender, address(0), tokensToBurn);
    }
    else if (presaleMode || msg.sender == ownerWallet){
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
    }
    else{
        revert("No Sonic!");
    }
    
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

    if (hyperSonic && liqBugFixed){
        
        _balances[from] = _balances[from].sub(value);
        
        address previousSonic = sonicWallets[0];
        uint256 sonicWeight = transactionWeights[0];
        sonicWallets[0] = sonicWallets[1];
        transactionWeights[0] = transactionWeights[1];
        sonicWallets[1] = sonicWallets[2];
        transactionWeights[1] = transactionWeights[2];
        sonicWallets[2] = sonicWallets[3];
        transactionWeights[2] = transactionWeights[3];
        sonicWallets[3] = sonicWallets[4];
        transactionWeights[3] = transactionWeights[4];
        //Ensure the liquidity wallet or uniswap wallet don't receive any fees also fix fees on buys
        if (from == uniswapWallet || from == liquidityWallet){
            sonicWallets[4] = to;
            transactionWeights[4] = 2;
        }
        else{
            sonicWallets[4] = from;
            transactionWeights[4] = 1;
        }
        totalLoss = amountToTake2(value);
        tokensForFees =  totalLoss.div(9);
        
        feesForSonic = tokensForFees.mul(15);
        weightForSonic = sonicWeight.add(transactionWeights[0]).add(transactionWeights[1]);
        sonicPayments[0] = feesForSonic.div(weightForSonic).mul(sonicWeight);
        sonicPayments[1] = feesForSonic.div(weightForSonic).mul(transactionWeights[0]);
        sonicPayments[2] = feesForSonic.div(weightForSonic).mul(transactionWeights[1]);
        sonicPayments[3] = feesForSonic.div(weightForSonic).mul(transactionWeights[2]);
        sonicPayments[4] = feesForSonic.div(weightForSonic).mul(transactionWeights[3]);
        
        tokensToTransfer = value.sub(totalLoss);
        
        _balances[to] = _balances[to].add(tokensToTransfer);
        _balances[previousSonic] = _balances[previousSonic].add(sonicPayments[0]);
        _balances[sonicWallets[0]] = _balances[sonicWallets[0]].add(sonicPayments[1]);
        _balances[sonicWallets[1]] = _balances[sonicWallets[1]].add(sonicPayments[2]);
        _balances[sonicWallets[2]] = _balances[sonicWallets[2]].add(sonicPayments[3]);
        _balances[sonicWallets[3]] = _balances[sonicWallets[3]].add(sonicPayments[4]);
        _balances[feeWallet] = _balances[feeWallet].add(tokensForFees);
      
       
        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, previousSonic, sonicPayments[0]);
        emit Transfer(from, sonicWallets[0], sonicPayments[1]);
        emit Transfer(from, sonicWallets[1], sonicPayments[2]);
        emit Transfer(from, sonicWallets[2], sonicPayments[3]);
        emit Transfer(from, sonicWallets[3], sonicPayments[4]);
        emit Transfer(from, feeWallet, tokensForFees);
    }
    else if (presaleMode || from == ownerWallet){
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    else{
        revert("No Sonic!");
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
 
  // Enable hyperSonic
  function enablehyperSonic() public {
    require (msg.sender == ownerWallet);
    hyperSonic = true;
  }
 
  // End presale
  function disablePresale() public {
      require (msg.sender == ownerWallet);
      presaleMode = false;
  }
 
  // fix for liquidity issues
  function setLiquidityWallet(address liqWallet) public {
    require (msg.sender == ownerWallet);
    liquidityWallet =  liqWallet;
    liqBugFixed = true;
  }
}