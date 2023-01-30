// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;
import './IERC20.sol';
import './Ownable.sol';
import './SafeMathLib.sol';

contract TreasuryBondsPlus is Ownable, IERC20 {

  using SafeMath for uint;

  string public constant name = 'Treasury Bonds Plus';
  string public constant symbol = 'TB+';
  uint8 public constant decimals = 2;

  uint private _totalSupply;
  uint public tokenPrice;

  struct PurchaseRecord {
    uint date;
    uint quantity;
  }

  mapping(address => uint) private _balances;
  mapping(address => mapping(address => uint)) private _allowed;
  mapping(address => PurchaseRecord[]) private _purchaseRecords;
  mapping(address => bool) private _approvedKYC;
  mapping(uint8 => uint8) public yieldPerMonth;

  event Mint(address indexed to, uint tokens);
  event Burn(address indexed account, uint tokens);
  event Repurchase(address indexed tokenOwner, uint tokens);

  constructor(address _transactionFee, address _buyBack) {
    _totalSupply = 200000 * 10 **uint(decimals);
    tokenPrice = 1; // 1 Dollar
    transactionFee = _transactionFee;
    buyBack = _buyBack;

    for (uint8 i=12; i <= 120; i++) {
      uint8 mpy;
      if (i <= 23) mpy = 50; // 0,50 %
      else if (i <= 35) mpy = 60; // 0,60 %
      else if (i <= 47) mpy = 70; // 0,70 %
      else if (i <= 59) mpy = 80; // 0,80 %
      else if (i <= 71) mpy = 90; // 0,90 %
      else if (i <= 83) mpy = 100; // 1,00 %
      else if (i <= 95) mpy = 120; // 1,20 %
      else if (i <= 107) mpy = 140; // 1,40 %
      else if (i <= 119) mpy = 160; // 1,60 %
      else mpy = 180; // 1,80 %
      yieldPerMonth[i] = mpy;
    }

    _balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }

  function totalSupply() public override view returns (uint) {
    return _totalSupply;
  }

  function balanceOf(address tokenOwner) public override view returns (uint balance) {
    return _balances[tokenOwner];
  }

  function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
    return _allowed[tokenOwner][spender];
  }

  function transfer(address to, uint tokens) public override returns (bool success) {  
    uint tax = 0;
    if (msg.sender != owner) {
      require(tokens >= 100 * 10 **uint(decimals), 'The minimum token quantity is 100.');
      tax = _setTax(tokens);
    } else require(tokens >= 1 * 10 ** uint(decimals), 'The minimum that can be sold is 1.');

    _transfer(msg.sender, to, tokens, tax);
    return true;
  }

  function approve(address spender, uint tokens) public override returns (bool success) {
    require(msg.sender != address(0), 'Invalid address!');
    require(spender != address(0), 'Invalid address!');

    _allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
    require(tokens >= 100 * 10 **uint(decimals), 'The minimum quantity of tokens that can be transferred is 100.');
    require(_allowed[from][msg.sender] >= tokens, 'Quantity of tokens allowed is insufficient!');
    require(to == msg.sender, 'The receiving address must be the same as the one calling the function!');

    uint tax = _setTax(tokens);
    _transfer(from, to, tokens, tax);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(tokens);
    return true;
  }

  function mint(address to, uint tokens) public onlyOwner {
    require(to != address(0), 'Invalid address!');

    _balances[to] = _balances[to].add(tokens);
    _totalSupply = _totalSupply.add(tokens);
    emit Mint(to, tokens);
  }

  function burn(address account, uint tokens) public onlyOwner {
    require(account != address(0), 'Invalid address!');
    require(_balances[account] >= tokens, 'Account balance is less than the number of tokens');

    _balances[account] = _balances[account].sub(tokens);
    _totalSupply = _totalSupply.sub(tokens);
    emit Burn(account, tokens);
  }

  function repurchase(address tokenOwner, uint tokens) public onlyOwner returns (bool success) {
    require(_balances[tokenOwner] >= tokens, 'Insufficient tokens!');

    _balances[tokenOwner] = _balances[tokenOwner].sub(tokens);
    _balances[buyBack] = _balances[buyBack].add(tokens);
    
    emit Repurchase(tokenOwner, tokens);
    return true;
  }

  function purchaseRecords(address tokenOwner) public view onlyOwner returns (PurchaseRecord[] memory) {
    return _purchaseRecords[tokenOwner];
  }

  function approveKYC(address account) public onlyOwner returns (bool success) {
    require(!(_approvedKYC[account]), 'The address already exists!');

    _approvedKYC[account] = true;
    return true;
  }

  function getApprovedKYC(address account) public view onlyOwner returns (bool status) {
    return _approvedKYC[account];
  }

  function newOwner(address account) public onlyOwner returns (bool success) {
    require(account != owner, 'The address of the new owner must be different from the current one.');

    address oldOwner = owner;
    transferOwnership(account);
    _balances[account] = _balances[oldOwner];
    _balances[oldOwner] = 0;
    OwnershipTransferred(account);
    return true;
  }

  function newTransactionFee(address account) public onlyOwner returns (bool success) {
    require(account != transactionFee, 'The address of the new transaction_fee must be different from the current one.');

    address oldTransactionFee = transactionFee;
    transferTransactionFee(account);
    _balances[account] = _balances[oldTransactionFee];
    _balances[oldTransactionFee] = 0;
    TransactionFeeTransferred(account);
    return true;
  }

  function newBuyBack(address account) public onlyOwner returns (bool success) {
    require(account != buyBack, 'the address of the new buy_back must be different from the current one.');

    address oldBuyBack = buyBack;
    transferBuyBack(account);
    _balances[account] = _balances[oldBuyBack];
    _balances[oldBuyBack] = 0;
    BuyBackTransferred(account);
    return true;
  }

  function _setTax(uint tokens) private pure returns (uint) {
    uint tokensInPercentage = tokens / 100;
    uint tax;

    if (tokens <= 10000 * 10 **uint(decimals)) tax = tokensInPercentage * 1 / 2; // 0,50%
    else if (tokens <= 50000 * 10 **uint(decimals)) tax = tokensInPercentage * 7 / 20; // 0,35%
    else if (tokens <= 100000 * 10 **uint(decimals)) tax = tokensInPercentage * 1 / 4; // 0,25%
    else if (tokens <= 1000000 * 10 **uint(decimals)) tax = tokensInPercentage * 1 / 5; // 0,20%
    else if (tokens <= 10000000 * 10 **uint(decimals)) tax = tokensInPercentage * 9 / 50; // 0,18%
    else if (tokens <= 50000000 * 10 **uint(decimals)) tax = tokensInPercentage * 3 / 20; // 0,15%
    else if (tokens <= 100000000 * 10 **uint(decimals)) tax = tokensInPercentage * 1 / 10; // 0,10%
    else if (tokens <= 300000000 * 10 **uint(decimals)) tax = tokensInPercentage * 7 / 100; // 0,07%
    else if (tokens <= 500000000 * 10 **uint(decimals)) tax = tokensInPercentage * 3 / 50; // 0,06%
    else if (tokens <= 1000000000 * 10 **uint(decimals)) tax = tokensInPercentage * 1 / 20; // 0,05%
    else tax = tokensInPercentage * 1 / 25; // 0,04%

    return tax;
  }

  function _transfer(address sender, address recipient, uint tokens, uint tax) private {
    require(sender != address(0), 'Invalid address!');
    require(recipient != address(0), 'Invalid address!');
    require(sender != recipient, 'Addresses must be different!');
    require(_balances[sender] >= tokens, 'Insufficient tokens!');

    uint tokensWithTax = tokens;
    if (tax > 0) {
      tokensWithTax = tokens - tax;
      _balances[transactionFee] = _balances[transactionFee].add(tax);
    }
    
    _balances[sender] = _balances[sender].sub(tokens);
    _balances[recipient] = _balances[recipient].add(tokensWithTax);
      
    _purchaseRecords[recipient].push(PurchaseRecord({
      date: block.timestamp,
      quantity: tokensWithTax
    }));

    emit Transfer(sender, recipient, tokens);
  }

}