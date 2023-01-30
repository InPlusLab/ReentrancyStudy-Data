/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity ^ 0.4.26;

library SafeMath {

 function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
  if (a == 0) {
   return 0;
  }
  c = a * b;
  assert(c / a == b);
  return c;
 }

 function div(uint256 a, uint256 b) internal pure returns(uint256) {
  return a / b;
 }

 function sub(uint256 a, uint256 b) internal pure returns(uint256) {
  assert(b <= a);
  return a - b;
 }

 function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
  c = a + b;
  assert(c >= a);
  return c;
 }

}

contract TOKEN {
 function totalSupply() external view returns(uint256);
 function balanceOf(address account) external view returns(uint256);
 function transfer(address recipient, uint256 amount) external returns(bool);
 function allowance(address owner, address spender) external view returns(uint256);
 function approve(address spender, uint256 amount) external returns(bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
}

contract Ownable {
 address public owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor() public {
  owner = msg.sender;
 }
 modifier onlyOwner() {
  require(msg.sender == owner);
  _;
 }
 function transferOwnership(address newOwner) public onlyOwner {
  require(newOwner != address(0));
  emit OwnershipTransferred(owner, newOwner);
  owner = newOwner;
 }
}

contract UBS is Ownable {

 mapping(address => bool) internal ambassadors_;
 uint256 constant internal ambassadorMaxPurchase_ = 1000000e18;
 mapping(address => uint256) internal ambassadorAccumulatedQuota_;
 bool public onlyAmbassadors = true;
 uint256 ACTIVATION_TIME = 1591725847;

 modifier antiEarlyWhale(uint256 _amountOfUBS, address _customerAddress) {
  if (now >= ACTIVATION_TIME) {
   onlyAmbassadors = false;
  }

  if (onlyAmbassadors) {
   require((ambassadors_[_customerAddress] == true && (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfUBS) <= ambassadorMaxPurchase_));
   ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfUBS);
   _;
  } else {
   if (now < (ACTIVATION_TIME + 60 seconds)) {
    require(tx.gasprice <= 0.1 szabo);
   }

   onlyAmbassadors = false;
   _;
  }
 }

 modifier onlyTokenHolders {
  require(myTokens() > 0);
  _;
 }

 modifier onlyDivis {
  require(myDividends(true) > 0);
  _;
 }

 event onDistribute(
  address indexed customerAddress,
  uint256 price
 );

 event onTokenPurchase(
  address indexed customerAddress,
  uint256 incomingUBS,
  uint256 tokensMinted,
  address indexed referredBy,
  uint timestamp
 );

 event onTokenSell(
  address indexed customerAddress,
  uint256 tokensBurned,
  uint256 ubsEarned,
  uint timestamp
 );

 event onReinvestment(
  address indexed customerAddress,
  uint256 ubsReinvested,
  uint256 tokensMinted
 );

 event onWithdraw(
  address indexed customerAddress,
  uint256 ubsWithdrawn
 );

 event Transfer(
  address indexed from,
  address indexed to,
  uint256 tokens
 );

 string public name = "UBOMB Staking";
 string public symbol = "UBS";
 uint8 constant public decimals = 18;
 uint256 internal entryFee_ = 10; // 10%
 uint256 internal transferFee_ = 1;
 uint256 internal exitFee_ = 10; // 10%
 uint256 internal referralFee_ = 20; // 2% of the 10% fee
 uint256 constant internal magnitude = 2 ** 64;
 mapping(address => uint256) internal tokenBalanceLedger_;
 mapping(address => uint256) internal referralBalance_;
 mapping(address => int256) internal payoutsTo_;
 mapping(address => uint256) internal invested_;
 uint256 internal tokenSupply_;
 uint256 internal profitPerShare_;
 uint256 public stakingRequirement = 1e18; // 1 UBOMB
 uint256 public totalHolder = 0;
 uint256 public totalDonation = 0;
 TOKEN erc20;

 constructor() public {
  ambassadors_[0xB016D18C7a0D90F9E3eab4e834437BBD5357ADf7] = true;
  ambassadors_[0xBBA60Ed9377c28786bF9196A649c7eEFf2B63803] = true;
  erc20 = TOKEN(address(0xe31DEbd7AbFF90B06bCA21010dD860d8701fd901));
 }

 function checkAndTransferUBS(uint256 _amount) private {
  require(erc20.transferFrom(msg.sender, address(this), _amount) == true, "transfer must succeed");
 }

 function distribute(uint256 _amount) public returns(uint256) {
  require(_amount > 0, "must be a positive value");
  checkAndTransferUBS(_amount);
  totalDonation += _amount;
  profitPerShare_ = SafeMath.add(profitPerShare_, (_amount * magnitude) / tokenSupply_);
  emit onDistribute(msg.sender, _amount);
 }

 function buy(uint256 _amount, address _referredBy) public returns(uint256) {
  checkAndTransferUBS(_amount);
  return purchaseTokens(_referredBy, msg.sender, _amount);
 }

 function buyFor(uint256 _amount, address _customerAddress, address _referredBy) public returns(uint256) {
  checkAndTransferUBS(_amount);
  return purchaseTokens(_referredBy, _customerAddress, _amount);
 }

 function() payable public {
  revert();
 }

 function reinvest() onlyDivis public {
  address _customerAddress = msg.sender;
  uint256 _dividends = myDividends(false);
  payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);
  _dividends += referralBalance_[_customerAddress];
  referralBalance_[_customerAddress] = 0;
  uint256 _tokens = purchaseTokens(0x0, _customerAddress, _dividends);
  emit onReinvestment(_customerAddress, _dividends, _tokens);
 }

 function exit() external {
  address _customerAddress = msg.sender;
  uint256 _tokens = tokenBalanceLedger_[_customerAddress];
  if (_tokens > 0) sell(_tokens);
  withdraw();
 }

 function withdraw() onlyDivis public {
  address _customerAddress = msg.sender;
  uint256 _dividends = myDividends(false);
  payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);
  _dividends += referralBalance_[_customerAddress];
  referralBalance_[_customerAddress] = 0;
  erc20.transfer(_customerAddress, _dividends);
  emit onWithdraw(_customerAddress, _dividends);
 }

 function sell(uint256 _amountOfTokens) onlyTokenHolders public {
  address _customerAddress = msg.sender;
  require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

  uint256 _dividends = SafeMath.div(SafeMath.mul(_amountOfTokens, exitFee_), 100);
  uint256 _taxedUBS = SafeMath.sub(_amountOfTokens, _dividends);

  tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
  tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

  int256 _updatedPayouts = (int256)(profitPerShare_ * _amountOfTokens + (_taxedUBS * magnitude));
  payoutsTo_[_customerAddress] -= _updatedPayouts;

  if (tokenSupply_ > 0) {
   profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
  }

  emit Transfer(_customerAddress, address(0), _amountOfTokens);
  emit onTokenSell(_customerAddress, _amountOfTokens, _taxedUBS, now);
 }

 function transfer(address _toAddress, uint256 _amountOfTokens) onlyTokenHolders external returns(bool) {
  address _customerAddress = msg.sender;
  require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

  if (myDividends(true) > 0) {
   withdraw();
  }

  uint256 _tokenFee = SafeMath.div(SafeMath.mul(_amountOfTokens, transferFee_), 100);
  uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
  uint256 _dividends = _tokenFee;

  tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

  tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
  tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

  payoutsTo_[_customerAddress] -= (int256)(profitPerShare_ * _amountOfTokens);
  payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _taxedTokens);

  profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

  emit Transfer(_customerAddress, _toAddress, _taxedTokens);

  return true;
 }

 function setName(string _name) onlyOwner public {
  name = _name;
 }

 function setSymbol(string _symbol) onlyOwner public {
  symbol = _symbol;
 }

 function totalUbombBalance() public view returns(uint256) {
  return erc20.balanceOf(address(this));
 }

 function totalSupply() public view returns(uint256) {
  return tokenSupply_;
 }

 function myTokens() public view returns(uint256) {
  address _customerAddress = msg.sender;
  return balanceOf(_customerAddress);
 }

 function myDividends(bool _includeReferralBonus) public view returns(uint256) {
  address _customerAddress = msg.sender;
  return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress);
 }

 function balanceOf(address _customerAddress) public view returns(uint256) {
  return tokenBalanceLedger_[_customerAddress];
 }

 function dividendsOf(address _customerAddress) public view returns(uint256) {
  return (uint256)((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
 }

 function sellPrice() public view returns(uint256) {
  uint256 _ubs = 1e18;
  uint256 _dividends = SafeMath.div(SafeMath.mul(_ubs, exitFee_), 100);
  uint256 _taxedUBS = SafeMath.sub(_ubs, _dividends);

  return _taxedUBS;
 }

 function buyPrice() public view returns(uint256) {
  uint256 _ubs = 1e18;
  uint256 _dividends = SafeMath.div(SafeMath.mul(_ubs, entryFee_), 100);
  uint256 _taxedUBS = SafeMath.add(_ubs, _dividends);

  return _taxedUBS;
 }

 function calculateTokensReceived(uint256 _ubombToSpend) public view returns(uint256) {
  uint256 _dividends = SafeMath.div(SafeMath.mul(_ubombToSpend, entryFee_), 100);
  uint256 _amountOfTokens = SafeMath.sub(_ubombToSpend, _dividends);

  return _amountOfTokens;
 }

 function calculateUbombReceived(uint256 _tokensToSell) public view returns(uint256) {
  require(_tokensToSell <= tokenSupply_);
  uint256 _dividends = SafeMath.div(SafeMath.mul(_tokensToSell, exitFee_), 100);
  uint256 _taxedUBS = SafeMath.sub(_tokensToSell, _dividends);

  return _taxedUBS;
 }

 function getInvested() public view returns(uint256) {
  return invested_[msg.sender];
 }

 function purchaseTokens(address _referredBy, address _customerAddress, uint256 _incomingUBS) internal antiEarlyWhale(_incomingUBS, _customerAddress) returns(uint256) {
  if (getInvested() == 0) {
   totalHolder++;
  }

  invested_[msg.sender] += _incomingUBS;

  uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingUBS, entryFee_), 100);

  uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, referralFee_), 100);

  uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
  uint256 _amountOfTokens = SafeMath.sub(_incomingUBS, _undividedDividends);
  uint256 _fee = _dividends * magnitude;

  require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);

  if (_referredBy != address(0) && _referredBy != _customerAddress && tokenBalanceLedger_[_referredBy] >= stakingRequirement) {
   referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
  } else {
   _dividends = SafeMath.add(_dividends, _referralBonus);
   _fee = _dividends * magnitude;
  }

  if (tokenSupply_ > 0) {
   tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
   profitPerShare_ += (_dividends * magnitude / tokenSupply_);
   _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));
  } else {
   tokenSupply_ = _amountOfTokens;
  }

  tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

  int256 _updatedPayouts = (int256)(profitPerShare_ * _amountOfTokens - _fee);
  payoutsTo_[_customerAddress] += _updatedPayouts;

  emit Transfer(address(0), msg.sender, _amountOfTokens);
  emit onTokenPurchase(_customerAddress, _incomingUBS, _amountOfTokens, _referredBy, now);

  return _amountOfTokens;
 }

 function multiData()
 public
 view
 returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
  return (

   // [0] Total UBOMB in contract
   totalUbombBalance(),

   // [1] Total UBS supply
   totalSupply(),

   // [2] User UBS balance
   balanceOf(msg.sender),

   // [3] User UBS balance
   erc20.balanceOf(msg.sender),

   // [4] User divs
   dividendsOf(msg.sender),

   // [5] Buy price
   buyPrice(),

   // [6] Sell price
   sellPrice()

  );
 }
}