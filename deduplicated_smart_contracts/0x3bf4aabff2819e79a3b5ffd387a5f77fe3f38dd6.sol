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
  uint8 public constant decimals = 8;

  uint private _totalSupply;

  mapping(address => uint) private _balances;
  mapping(address => mapping(address => uint)) private _allowed;

  event Mint(address indexed to, uint tokens);
  event Burn(address indexed account, uint tokens);
  event BuyBack(address indexed tokenOwner, uint tokens);

  constructor(address _feeAddress, address _reserveAddress) {
    _totalSupply = 50000000 * 10 **uint(decimals);
    feeAddress = _feeAddress;
    reserveAddress = _reserveAddress;

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
    require(tokens >= 1000000, 'The minimum amount of tokens that can be transferred is 0.01.');

    uint tax = 0;
    if (msg.sender != owner) tax = _setTax(tokens);

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
    require(tokens >= 1000000, 'The minimum amount of tokens that can be transferred is 0.01.');
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

  function buyBack(address tokenOwner, uint tokens) public onlyOwner returns (bool success) {
    require(_balances[tokenOwner] >= tokens, 'Insufficient tokens!');

    _balances[tokenOwner] = _balances[tokenOwner].sub(tokens);
    _balances[reserveAddress] = _balances[reserveAddress].add(tokens);
    
    emit BuyBack(tokenOwner, tokens);
    return true;
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

  function newFeeAddress(address account) public onlyOwner returns (bool success) {
    require(account != feeAddress, 'The new feeAddress must be different from the current one.');

    address oldFeeAddress = feeAddress;
    transferFeeAddress(account);
    _balances[account] = _balances[oldFeeAddress];
    _balances[oldFeeAddress] = 0;
    FeeAddressTransferred(account);
    return true;
  }

  function newReserveAddress(address account) public onlyOwner returns (bool success) {
    require(account != reserveAddress, 'The new reserveAddress must be different from the current one.');

    address oldReserveAddress = reserveAddress;
    transferReserveAddress(account);
    _balances[account] = _balances[oldReserveAddress];
    _balances[oldReserveAddress] = 0;
    ReserveAddressTransferred(account);
    return true;
  }

  function close() public onlyOwner {
    selfdestruct(payable(owner));
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
      _balances[feeAddress] = _balances[feeAddress].add(tax);
    }
    
    _balances[sender] = _balances[sender].sub(tokens);
    _balances[recipient] = _balances[recipient].add(tokensWithTax);

    emit Transfer(sender, recipient, tokens);
  }

}