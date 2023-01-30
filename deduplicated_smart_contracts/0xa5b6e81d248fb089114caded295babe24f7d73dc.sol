/**
 *Submitted for verification at Etherscan.io on 2020-06-26
*/

/**
 *Submitted for verification at Etherscan.io on 2020-06-07
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

contract H3RainX {

 mapping(address => bool) internal ambassadors_;
 uint256 constant internal ambassadorMaxPurchase_ = 1000000e18;
 mapping(address => uint256) internal ambassadorAccumulatedQuota_;
 bool public onlyAmbassadors = true;
 uint256 ACTIVATION_TIME = 1593241200;

 modifier antiEarlyWhale(uint256 _amountOfH3RX, address _customerAddress) {
  if (now >= ACTIVATION_TIME) {
   onlyAmbassadors = false;
  }

  if (onlyAmbassadors) {
   require((ambassadors_[_customerAddress] == true && (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfH3RX) <= ambassadorMaxPurchase_));
   ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfH3RX);
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
  uint256 incomingH3RX,
  uint256 tokensMinted,
  address indexed referredBy,
  uint timestamp
 );

 event onTokenSell(
  address indexed customerAddress,
  uint256 tokensBurned,
  uint256 h3rxEarned,
  uint timestamp
 );

 event onReinvestment(
  address indexed customerAddress,
  uint256 h3rxReinvested,
  uint256 tokensMinted
 );

 event onWithdraw(
  address indexed customerAddress,
  uint256 h3rxWithdrawn
 );

 event Transfer(
  address indexed from,
  address indexed to,
  uint256 tokens
 );

 string public name = "H3RainX";
 string public symbol = "H3RX";
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
 uint256 public stakingRequirement = 1e18; // 1 H3X + 4 RAIN
 uint256 public totalHolder = 0;
 uint256 public totalDonation = 0;
 uint256 constant internal rainMultiplier = 4;
 uint256 constant internal h3xMultiplier = 1;
 TOKEN erc20Rain;
 TOKEN erc20H3x;

 constructor() public {
  ambassadors_[0x4ea0d6576E606778Cc9dcC329d06Ec70c3906CC2] = true;
  erc20Rain = TOKEN(address(0x61cDb66e56FAD942a7b5cE3F419FfE9375E31075));
  erc20H3x = TOKEN(address(0x85eBa557C06c348395fD49e35d860F58a4F7c95a));
 }

 function checkAndTransferH3RX(uint256 _amount) private {
  require(erc20Rain.transferFrom(msg.sender, address(this), SafeMath.mul(_amount, rainMultiplier)) == true, "transfer must succeed");
  require(erc20H3x.transferFrom(msg.sender, address(this), SafeMath.mul(_amount, h3xMultiplier)) == true, "transfer must succeed");
 }

 function distribute(uint256 _amount) public returns(uint256) {
  require(_amount > 0, "must be a positive value");
  checkAndTransferH3RX(_amount);
  totalDonation += _amount;
  profitPerShare_ = SafeMath.add(profitPerShare_, (_amount * magnitude) / tokenSupply_);
  emit onDistribute(msg.sender, _amount);
 }

 function buy(uint256 _amount, address _referredBy) public returns(uint256) {
  checkAndTransferH3RX(_amount);
  return purchaseTokens(_referredBy, msg.sender, _amount);
 }

 function buyFor(uint256 _amount, address _customerAddress, address _referredBy) public returns(uint256) {
  checkAndTransferH3RX(_amount);
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
  erc20Rain.transfer(_customerAddress, SafeMath.mul(_dividends, rainMultiplier));
  erc20H3x.transfer(_customerAddress, SafeMath.mul(_dividends, h3xMultiplier));
  emit onWithdraw(_customerAddress, _dividends);
 }

 function sell(uint256 _amountOfTokens) onlyTokenHolders public {
  address _customerAddress = msg.sender;
  require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

  uint256 _dividends = SafeMath.div(SafeMath.mul(_amountOfTokens, exitFee_), 100);
  uint256 _taxedH3RX = SafeMath.sub(_amountOfTokens, _dividends);

  tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
  tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

  int256 _updatedPayouts = (int256)(profitPerShare_ * _amountOfTokens + (_taxedH3RX * magnitude));
  payoutsTo_[_customerAddress] -= _updatedPayouts;

  if (tokenSupply_ > 0) {
   profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
  }

  emit Transfer(_customerAddress, address(0), _amountOfTokens);
  emit onTokenSell(_customerAddress, _amountOfTokens, _taxedH3RX, now);
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

 function getInvested() public view returns(uint256) {
  return invested_[msg.sender];
 }


  function totalH3xTokenBalance() public view returns(uint256) {
   return erc20H3x.balanceOf(address(this));
  }
  
  function totalRainTokenBalance() public view returns(uint256) {
   return erc20Rain.balanceOf(address(this));
  }

 function purchaseTokens(address _referredBy, address _customerAddress, uint256 _incomingH3RX) internal antiEarlyWhale(_incomingH3RX, _customerAddress) returns(uint256) {
  if (getInvested() == 0) {
   totalHolder++;
  }

  invested_[msg.sender] += _incomingH3RX;

  uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingH3RX, entryFee_), 100);

  uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, referralFee_), 100);

  uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
  uint256 _amountOfTokens = SafeMath.sub(_incomingH3RX, _undividedDividends);
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
  emit onTokenPurchase(_customerAddress, _incomingH3RX, _amountOfTokens, _referredBy, now);

  return _amountOfTokens;
 }

 function multiData()
 public
 view
 returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
  return (

   // [0] Total H3X in contract
   totalH3xTokenBalance(),

   // [0] Total Rain in contract
   totalRainTokenBalance(),
   
   // [1] Total H3RX supply
   totalSupply(),

   // [2] User H3RX balance
   balanceOf(msg.sender),

   // [3] User RAIN balance
   erc20Rain.balanceOf(msg.sender),

   // [4] User H3X balance
   erc20H3x.balanceOf(msg.sender),

   // [5] User divs
   dividendsOf(msg.sender)


  );
 }
}