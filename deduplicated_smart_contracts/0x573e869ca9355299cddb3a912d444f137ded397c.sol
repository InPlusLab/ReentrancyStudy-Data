/**

 *Submitted for verification at Etherscan.io on 2018-08-10

*/



pragma solidity ^0.4.24;



/**



  https://fortisgames.com https://fortisgames.com https://fortisgames.com https://fortisgames.com https://fortisgames.com



                                                                                                  

FFFFFFFFFFFFFFFFFFFFFF                                           tttt            iiii                   

F::::::::::::::::::::F                                        ttt:::t           i::::i                  

F::::::::::::::::::::F                                        t:::::t            iiii                   

FF::::::FFFFFFFFF::::F                                        t:::::t                                   

  F:::::F       FFFFFFooooooooooo   rrrrr   rrrrrrrrr   ttttttt:::::ttttttt    iiiiiii     ssssssssss   

  F:::::F           oo:::::::::::oo r::::rrr:::::::::r  t:::::::::::::::::t    i:::::i   ss::::::::::s  

  F::::::FFFFFFFFFFo:::::::::::::::or:::::::::::::::::r t:::::::::::::::::t     i::::i ss:::::::::::::s 

  F:::::::::::::::Fo:::::ooooo:::::orr::::::rrrrr::::::rtttttt:::::::tttttt     i::::i s::::::ssss:::::s

  F:::::::::::::::Fo::::o     o::::o r:::::r     r:::::r      t:::::t           i::::i  s:::::s  ssssss 

  F::::::FFFFFFFFFFo::::o     o::::o r:::::r     rrrrrrr      t:::::t           i::::i    s::::::s      

  F:::::F          o::::o     o::::o r:::::r                  t:::::t           i::::i       s::::::s   

  F:::::F          o::::o     o::::o r:::::r                  t:::::t    tttttt i::::i ssssss   s:::::s 

FF:::::::FF        o:::::ooooo:::::o r:::::r                  t::::::tttt:::::ti::::::is:::::ssss::::::s

F::::::::FF        o:::::::::::::::o r:::::r                  tt::::::::::::::ti::::::is::::::::::::::s 

F::::::::FF         oo:::::::::::oo  r:::::r                    tt:::::::::::tti::::::i s:::::::::::ss  

FFFFFFFFFFF           ooooooooooo    rrrrrrr                      ttttttttttt  iiiiiiii  sssssssssss    

                                                                                                        



An interactive, variable-dividend rate contract with an ICO-capped price floor and collectibles.



Discord:   https://discord.gg/gDtTX62





**/





contract Fortis {

  using SafeMath for uint;



  /*=================================

  =            MODIFIERS            =

  =================================*/



  modifier onlyHolders() {

    require(myFrontEndTokens() > 0);

    _;

  }



  modifier dividendHolder() {

    require(myDividends(true) > 0);

    _;

  }



  modifier onlyAdministrator(){

    address _customerAddress = msg.sender;

    require(administrators[_customerAddress]);

    _;

  }



  /*==============================

  =            EVENTS            =

  ==============================*/



  event onTokenPurchase(

    address indexed customerAddress,

    uint incomingEthereum,

    uint tokensMinted,

    address indexed referredBy

  );



  event UserDividendRate(

    address user,

    uint divRate

  );



  event onTokenSell(

    address indexed customerAddress,

    uint tokensBurned,

    uint ethereumEarned

  );



  event onReinvestment(

    address indexed customerAddress,

    uint ethereumReinvested,

    uint tokensMinted

  );



  event onWithdraw(

    address indexed customerAddress,

    uint ethereumWithdrawn

  );



  event Transfer(

    address indexed from,

    address indexed to,

    uint tokens

  );



  event Approval(

    address indexed tokenOwner,

    address indexed spender,

    uint tokens

  );



  event Allocation(

    uint toBankRoll,

    uint toReferrer,

    uint toTokenHolders,

    uint toDivCardHolders,

    uint forTokens

  );



  event Referral(

    address referrer,

    uint amountReceived

  );



  /*=====================================

  =            CONSTANTS                =

  =====================================*/



  uint8 constant public                decimals              = 18;



  uint constant internal               tokenPriceInitial_    = 0.000653 ether;

  uint constant internal               magnitude             = 2**64;



  uint constant internal               icoHardCap            = 250 ether;

  uint constant internal               addressICOLimit       = 1   ether;

  uint constant internal               icoMinBuyIn           = 0.1 finney;

  uint constant internal               icoMaxGasPrice        = 50000000000 wei;



  uint constant internal               MULTIPLIER            = 9615;



  uint constant internal               MIN_ETH_BUYIN         = 0.0001 ether;

  uint constant internal               MIN_TOKEN_SELL_AMOUNT = 0.0001 ether;

  uint constant internal               MIN_TOKEN_TRANSFER    = 1e10;

  uint constant internal               referrer_percentage   = 25;



  uint public                          stakingRequirement    = 100e18;



  /*================================

   =          CONFIGURABLES         =

   ================================*/



  string public                        name               = "Fortis";

  string public                        symbol             = "IRON";



  bytes32 constant public              icoHashedPass      = bytes32(0x5ddcde33b94b19bdef79dd9ea75be591942b9ec78286d64b44a356280fb6a262);



  address internal                     bankrollAddress;



  ZethrDividendCards                   divCardContract;



  /*================================

   =            DATASETS            =

   ================================*/



  // Tracks front & backend tokens

  mapping(address => uint) internal    frontTokenBalanceLedger_;

  mapping(address => uint) internal    dividendTokenBalanceLedger_;

  mapping(address =>

  mapping (address => uint))

  public      allowed;



  // Tracks dividend rates for users

  mapping(uint8   => bool)    internal validDividendRates_;

  mapping(address => bool)    internal userSelectedRate;

  mapping(address => uint8)   internal userDividendRate;



  // Payout tracking

  mapping(address => uint)    internal referralBalance_;

  mapping(address => int256)  internal payoutsTo_;



  // ICO per-address limit tracking

  mapping(address => uint)    internal ICOBuyIn;



  uint public                          tokensMintedDuringICO;

  uint public                          ethInvestedDuringICO;



  uint public                          currentEthInvested;



  uint internal                        tokenSupply    = 0;

  uint internal                        divTokenSupply = 0;



  uint internal                        profitPerDivToken;



  mapping(address => bool) public      administrators;



  bool public                          icoPhase     = false;

  bool public                          regularPhase = false;



  uint                                 icoOpenTime;



  /*=======================================

  =            PUBLIC FUNCTIONS           =

  =======================================*/

  constructor (address _bankrollAddress, address _divCardAddress)

  public

  {

    bankrollAddress = _bankrollAddress;

    divCardContract = ZethrDividendCards(_divCardAddress);



    administrators[0x9b3bb44b1a9243db229e5ccc6d20cada9efce5f8] = true; // Rayner

    administrators[0x487a03097b4d7320d5a0e7451f6a0e1224c37f09] = true; // Rustam

    administrators[0x24d6e2d15a85c27b0282bbc2afbc06cfbd9c15a0] = true; // Glandur



    administrators[msg.sender] = true; // Helps with debugging!



    validDividendRates_[2] = true;

    validDividendRates_[5] = true;

    validDividendRates_[10] = true;

    validDividendRates_[15] = true;

    validDividendRates_[20] = true;

    validDividendRates_[25] = true;

    validDividendRates_[33] = true;



    userSelectedRate[bankrollAddress] = true;

    userDividendRate[bankrollAddress] = 33;



  }



  /**

   * Same as buy, but explicitly sets your dividend percentage.

   * If this has been called before, it will update your `default' dividend

   *   percentage for regular buy transactions going forward.

   */

  function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass)

  public

  payable

  returns (uint)

  {

    require(icoPhase || regularPhase);



    if (icoPhase) {

 

      // Anti-bot measures - not perfect, but should help some.

      bytes32 hashedProvidedPass = keccak256(providedUnhashedPass);

      require(hashedProvidedPass == icoHashedPass || msg.sender == bankrollAddress);



      uint gasPrice = tx.gasprice;



      // Prevents ICO buyers from getting substantially burned if the ICO is reached

      //   before their transaction is processed.

      require(gasPrice <= icoMaxGasPrice && ethInvestedDuringICO <= icoHardCap);



    }



    // Dividend percentage should be a currently accepted value.

    require (validDividendRates_[_divChoice]);



    // Set the dividend fee percentage denominator.

    userSelectedRate[msg.sender] = true;

    userDividendRate[msg.sender] = _divChoice;

    emit UserDividendRate(msg.sender, _divChoice);



    // Finally, purchase tokens.

    purchaseTokens(msg.value, _referredBy);

  }



  // All buys except for the above one require regular phase.



  function buy(address _referredBy)

  public

  payable

  returns(uint)

  {

    require(regularPhase);

    address _customerAddress = msg.sender;

    require (userSelectedRate[_customerAddress]);

    purchaseTokens(msg.value, _referredBy);

  }



  function buyAndTransfer(address _referredBy, address target)

  public

  payable

  {

    bytes memory empty;

    buyAndTransfer(_referredBy,target, empty, 20);

  }



  function buyAndTransfer(address _referredBy, address target, bytes _data)

  public

  payable

  {

    buyAndTransfer(_referredBy, target, _data, 20);

  }



  // Overload

  function buyAndTransfer(address _referredBy, address target, bytes _data, uint8 divChoice)

  public

  payable

  {

    require(regularPhase);

    address _customerAddress = msg.sender;

    uint256 frontendBalance = frontTokenBalanceLedger_[msg.sender];

    if (userSelectedRate[_customerAddress] && divChoice == 0) {

      purchaseTokens(msg.value, _referredBy);

    } else {

      buyAndSetDivPercentage(_referredBy, divChoice, "0x0");

    }

    uint256 difference = SafeMath.sub(frontTokenBalanceLedger_[msg.sender], frontendBalance);

    transferTo(msg.sender, target, difference, _data);

  }



  // Fallback function only works during regular phase - part of anti-bot protection.

  function()

  payable

  public

  {

    /**

    / If the user has previously set a dividend rate, sending

    /   Ether directly to the contract simply purchases more at

    /   the most recent rate. If this is their first time, they

    /   are automatically placed into the 20% rate `bucket'.

    **/

    require(regularPhase);

    address _customerAddress = msg.sender;

    if (userSelectedRate[_customerAddress]) {

      purchaseTokens(msg.value, 0x0);

    } else {

      buyAndSetDivPercentage(0x0, 20, "0x0");

    }

  }



  function reinvest()

  dividendHolder()

  public

  {

    require(regularPhase);

    uint _dividends = myDividends(false);



    // Pay out requisite `virtual' dividends.

    address _customerAddress            = msg.sender;

    payoutsTo_[_customerAddress]       += (int256) (_dividends * magnitude);



    _dividends                         += referralBalance_[_customerAddress];

    referralBalance_[_customerAddress]  = 0;



    uint _tokens                        = purchaseTokens(_dividends, 0x0);



    // Fire logging event.

    emit onReinvestment(_customerAddress, _dividends, _tokens);

  }



  function exit()

  public

  {

    require(regularPhase);

    // Retrieve token balance for caller, then sell them all.

    address _customerAddress = msg.sender;

    uint _tokens             = frontTokenBalanceLedger_[_customerAddress];



    if(_tokens > 0) sell(_tokens);



    withdraw(_customerAddress);

  }



  function withdraw(address _recipient)

  dividendHolder()

  public

  {

    require(regularPhase);

    // Setup data

    address _customerAddress           = msg.sender;

    uint _dividends                    = myDividends(false);



    // update dividend tracker

    payoutsTo_[_customerAddress]       +=  (int256) (_dividends * magnitude);



    // add ref. bonus

    _dividends                         += referralBalance_[_customerAddress];

    referralBalance_[_customerAddress]  = 0;



    if (_recipient == address(0x0)){

      _recipient = msg.sender;

    }

    _recipient.transfer(_dividends);



    // Fire logging event.

    emit onWithdraw(_recipient, _dividends);

  }



  // Sells front-end tokens.

  // Logic concerning step-pricing of tokens pre/post-ICO is encapsulated in tokensToEthereum_.

  function sell(uint _amountOfTokens)

  onlyHolders()

  public

  {

    // No selling during the ICO. You don't get to flip that fast, sorry!

    require(!icoPhase);

    require(regularPhase);



    require(_amountOfTokens <= frontTokenBalanceLedger_[msg.sender]);



    uint _frontEndTokensToBurn = _amountOfTokens;



    // Calculate how many dividend tokens this action burns.

    // Computed as the caller's average dividend rate multiplied by the number of front-end tokens held.

    // As an additional guard, we ensure that the dividend rate is between 2 and 50 inclusive.

    uint userDivRate  = getUserAverageDividendRate(msg.sender);

    require ((2*magnitude) <= userDivRate && (50*magnitude) >= userDivRate );

    uint _divTokensToBurn = (_frontEndTokensToBurn.mul(userDivRate)).div(magnitude);



    // Calculate ethereum received before dividends

    uint _ethereum = tokensToEthereum_(_frontEndTokensToBurn);



    if (_ethereum > currentEthInvested){

      // Well, congratulations, you've emptied the coffers.

      currentEthInvested = 0;

    } else { currentEthInvested = currentEthInvested - _ethereum; }



    // Calculate dividends generated from the sale.

    uint _dividends = (_ethereum.mul(getUserAverageDividendRate(msg.sender)).div(100)).div(magnitude);



    // Calculate Ethereum receivable net of dividends.

    uint _taxedEthereum = _ethereum.sub(_dividends);



    // Burn the sold tokens (both front-end and back-end variants).

    tokenSupply         = tokenSupply.sub(_frontEndTokensToBurn);

    divTokenSupply      = divTokenSupply.sub(_divTokensToBurn);



    // Subtract the token balances for the seller

    frontTokenBalanceLedger_[msg.sender]    = frontTokenBalanceLedger_[msg.sender].sub(_frontEndTokensToBurn);

    dividendTokenBalanceLedger_[msg.sender] = dividendTokenBalanceLedger_[msg.sender].sub(_divTokensToBurn);



    // Update dividends tracker

    int256 _updatedPayouts  = (int256) (profitPerDivToken * _divTokensToBurn + (_taxedEthereum * magnitude));

    payoutsTo_[msg.sender] -= _updatedPayouts;



    // Let's avoid breaking arithmetic where we can, eh?

    if (divTokenSupply > 0) {

      // Update the value of each remaining back-end dividend token.

      profitPerDivToken = profitPerDivToken.add((_dividends * magnitude) / divTokenSupply);

    }



    // Fire logging event.

    emit onTokenSell(msg.sender, _frontEndTokensToBurn, _taxedEthereum);

  }



  /**

   * Transfer tokens from the caller to a new holder.

   * No charge incurred for the transfer. We'd make a terrible bank.

   */

  function transfer(address _toAddress, uint _amountOfTokens)

  onlyHolders()

  public

  returns(bool)

  {

    require(_amountOfTokens >= MIN_TOKEN_TRANSFER

    && _amountOfTokens <= frontTokenBalanceLedger_[msg.sender]);

    bytes memory empty;

    transferFromInternal(msg.sender, _toAddress, _amountOfTokens, empty);

    return true;



  }



  function approve(address spender, uint tokens)

  public

  returns (bool)

  {

    address _customerAddress           = msg.sender;

    allowed[_customerAddress][spender] = tokens;



    // Fire logging event.

    emit Approval(_customerAddress, spender, tokens);



    // Good old ERC20.

    return true;

  }



  /**

   * Transfer tokens from the caller to a new holder: the Used By Smart Contracts edition.

   * No charge incurred for the transfer. No seriously, we'd make a terrible bank.

   */

  function transferFrom(address _from, address _toAddress, uint _amountOfTokens)

  public

  returns(bool)

  {

    // Setup variables

    address _customerAddress     = _from;

    bytes memory empty;

    // Make sure we own the tokens we're transferring, are ALLOWED to transfer that many tokens,

    // and are transferring at least one full token.

    require(_amountOfTokens >= MIN_TOKEN_TRANSFER

    && _amountOfTokens <= frontTokenBalanceLedger_[_customerAddress]

    && _amountOfTokens <= allowed[_customerAddress][msg.sender]);



    transferFromInternal(_from, _toAddress, _amountOfTokens, empty);



    // Good old ERC20.

    return true;



  }



  function transferTo (address _from, address _to, uint _amountOfTokens, bytes _data)

  public

  {

    if (_from != msg.sender){

      require(_amountOfTokens >= MIN_TOKEN_TRANSFER

      && _amountOfTokens <= frontTokenBalanceLedger_[_from]

      && _amountOfTokens <= allowed[_from][msg.sender]);

    }

    else{

      require(_amountOfTokens >= MIN_TOKEN_TRANSFER

      && _amountOfTokens <= frontTokenBalanceLedger_[_from]);

    }



    transferFromInternal(_from, _to, _amountOfTokens, _data);

  }



  // Who'd have thought we'd need this thing floating around?

  function totalSupply()

  public

  view

  returns (uint256)

  {

    return tokenSupply;

  }



  // Anyone can start the regular phase 2 weeks after the ICO phase starts.

  // In case the devs die. Or something.

  function publicStartRegularPhase()

  public

  {

    require(now > (icoOpenTime + 2 weeks) && icoOpenTime != 0);



    icoPhase     = false;

    regularPhase = true;

  }



  /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/





  // Fire the starting gun and then duck for cover.

  function startICOPhase()

  onlyAdministrator()

  public

  {

    // Prevent us from startaring the ICO phase again

    require(icoOpenTime == 0);

    icoPhase = true;

    icoOpenTime = now;

  }



  // Fire the ... ending gun?

  function endICOPhase()

  onlyAdministrator()

  public

  {

    icoPhase = false;

  }



  function startRegularPhase()

  onlyAdministrator

  public

  {

    // disable ico phase in case if that was not disabled yet

    icoPhase = false;

    regularPhase = true;

  }



  // The death of a great man demands the birth of a great son.

  function setAdministrator(address _newAdmin, bool _status)

  onlyAdministrator()

  public

  {

    administrators[_newAdmin] = _status;

  }



  function setStakingRequirement(uint _amountOfTokens)

  onlyAdministrator()

  public

  {

    // This plane only goes one way, lads. Never below the initial.

    require (_amountOfTokens >= 100e18);

    stakingRequirement = _amountOfTokens;

  }



  function setName(string _name)

  onlyAdministrator()

  public

  {

    name = _name;

  }



  function setSymbol(string _symbol)

  onlyAdministrator()

  public

  {

    symbol = _symbol;

  }



  function changeBankroll(address _newBankrollAddress)

  onlyAdministrator

  public

  {

    bankrollAddress = _newBankrollAddress;

  }



  /*----------  HELPERS AND CALCULATORS  ----------*/



  function totalEthereumBalance()

  public

  view

  returns(uint)

  {

    return address(this).balance;

  }



  function totalEthereumICOReceived()

  public

  view

  returns(uint)

  {

    return ethInvestedDuringICO;

  }



  /**

   * Retrieves your currently selected dividend rate.

   */

  function getMyDividendRate()

  public

  view

  returns(uint8)

  {

    address _customerAddress = msg.sender;

    require(userSelectedRate[_customerAddress]);

    return userDividendRate[_customerAddress];

  }



  /**

   * Retrieve the total frontend token supply

   */

  function getFrontEndTokenSupply()

  public

  view

  returns(uint)

  {

    return tokenSupply;

  }



  /**

   * Retreive the total dividend token supply

   */

  function getDividendTokenSupply()

  public

  view

  returns(uint)

  {

    return divTokenSupply;

  }



  /**

   * Retrieve the frontend tokens owned by the caller

   */

  function myFrontEndTokens()

  public

  view

  returns(uint)

  {

    address _customerAddress = msg.sender;

    return getFrontEndTokenBalanceOf(_customerAddress);

  }



  /**

   * Retrieve the dividend tokens owned by the caller

   */

  function myDividendTokens()

  public

  view

  returns(uint)

  {

    address _customerAddress = msg.sender;

    return getDividendTokenBalanceOf(_customerAddress);

  }



  function myReferralDividends()

  public

  view

  returns(uint)

  {

    return myDividends(true) - myDividends(false);

  }



  function myDividends(bool _includeReferralBonus)

  public

  view

  returns(uint)

  {

    address _customerAddress = msg.sender;

    return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;

  }



  function theDividendsOf(bool _includeReferralBonus, address _customerAddress)

  public

  view

  returns(uint)

  {

    return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;

  }



  function getFrontEndTokenBalanceOf(address _customerAddress)

  view

  public

  returns(uint)

  {

    return frontTokenBalanceLedger_[_customerAddress];

  }



  function balanceOf(address _owner)

  view

  public

  returns(uint)

  {

    return getFrontEndTokenBalanceOf(_owner);

  }



  function getDividendTokenBalanceOf(address _customerAddress)

  view

  public

  returns(uint)

  {

    return dividendTokenBalanceLedger_[_customerAddress];

  }



  function dividendsOf(address _customerAddress)

  view

  public

  returns(uint)

  {

    return (uint) ((int256)(profitPerDivToken * dividendTokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;

  }



  // Get the sell price at the user's average dividend rate

  function sellPrice()

  public

  view

  returns(uint)

  {

    uint price;



    if (icoPhase || currentEthInvested < ethInvestedDuringICO) {

      price = tokenPriceInitial_;

    } else {



      // Calculate the tokens received for 100 finney.

      // Divide to find the average, to calculate the price.

      uint tokensReceivedForEth = ethereumToTokens_(0.001 ether);



      price = (1e18 * 0.001 ether) / tokensReceivedForEth;

    }



    // Factor in the user's average dividend rate

    uint theSellPrice = price.sub((price.mul(getUserAverageDividendRate(msg.sender)).div(100)).div(magnitude));



    return theSellPrice;

  }



  // Get the buy price at a particular dividend rate

  function buyPrice(uint dividendRate)

  public

  view

  returns(uint)

  {

    uint price;



    if (icoPhase || currentEthInvested < ethInvestedDuringICO) {

      price = tokenPriceInitial_;

    } else {



      // Calculate the tokens received for 100 finney.

      // Divide to find the average, to calculate the price.

      uint tokensReceivedForEth = ethereumToTokens_(0.001 ether);



      price = (1e18 * 0.001 ether) / tokensReceivedForEth;

    }



    // Factor in the user's selected dividend rate

    uint theBuyPrice = (price.mul(dividendRate).div(100)).add(price);



    return theBuyPrice;

  }



  function calculateTokensReceived(uint _ethereumToSpend)

  public

  view

  returns(uint)

  {

    uint _dividends      = (_ethereumToSpend.mul(userDividendRate[msg.sender])).div(100);

    uint _taxedEthereum  = _ethereumToSpend.sub(_dividends);

    uint _amountOfTokens = ethereumToTokens_(_taxedEthereum);

    return  _amountOfTokens;

  }



  // When selling tokens, we need to calculate the user's current dividend rate.

  // This is different from their selected dividend rate.

  function calculateEthereumReceived(uint _tokensToSell)

  public

  view

  returns(uint)

  {

    require(_tokensToSell <= tokenSupply);

    uint _ethereum               = tokensToEthereum_(_tokensToSell);

    uint userAverageDividendRate = getUserAverageDividendRate(msg.sender);

    uint _dividends              = (_ethereum.mul(userAverageDividendRate).div(100)).div(magnitude);

    uint _taxedEthereum          = _ethereum.sub(_dividends);

    return  _taxedEthereum;

  }



  /*

   * Get's a user's average dividend rate - which is just their divTokenBalance / tokenBalance

   * We multiply by magnitude to avoid precision errors.

   */



  function getUserAverageDividendRate(address user) public view returns (uint) {

    return (magnitude * dividendTokenBalanceLedger_[user]).div(frontTokenBalanceLedger_[user]);

  }



  function getMyAverageDividendRate() public view returns (uint) {

    return getUserAverageDividendRate(msg.sender);

  }



  /*==========================================

  =            INTERNAL FUNCTIONS            =

  ==========================================*/



  /* Purchase tokens with Ether.

     During ICO phase, dividends should go to the bankroll

     During normal operation:

       0.5% should go to the master dividend card

       0.5% should go to the matching dividend card

       25% of dividends should go to the referrer, if any is provided. */

  function purchaseTokens(uint _incomingEthereum, address _referredBy)

  internal

  returns(uint)

  {

    require(_incomingEthereum >= MIN_ETH_BUYIN || msg.sender == bankrollAddress, "Tried to buy below the min eth buyin threshold.");



    uint toBankRoll;

    uint toReferrer;

    uint toTokenHolders;

    uint toDivCardHolders;



    uint dividendAmount;



    uint tokensBought;

    uint dividendTokensBought;



    uint remainingEth = _incomingEthereum;



    uint fee;



    // 1% for dividend card holders is taken off before anything else

    if (regularPhase) {

      toDivCardHolders = _incomingEthereum.div(100);

      remainingEth = remainingEth.sub(toDivCardHolders);

    }



    /* Next, we tax for dividends:

       Dividends = (ethereum * div%) / 100

       Important note: if we're out of the ICO phase, the 1% sent to div-card holders

                       is handled prior to any dividend taxes are considered. */



    // Grab the user's dividend rate

    uint dividendRate = userDividendRate[msg.sender];



    // Calculate the total dividends on this buy

    dividendAmount = (remainingEth.mul(dividendRate)).div(100);



    remainingEth   = remainingEth.sub(dividendAmount);



    // If we're in the ICO and bankroll is buying, don't tax

    if (icoPhase && msg.sender == bankrollAddress) {

      remainingEth = remainingEth + dividendAmount;

    }



    // Calculate how many tokens to buy:

    tokensBought         = ethereumToTokens_(remainingEth);

    dividendTokensBought = tokensBought.mul(dividendRate);



    // This is where we actually mint tokens:

    tokenSupply    = tokenSupply.add(tokensBought);

    divTokenSupply = divTokenSupply.add(dividendTokensBought);



    /* Update the total investment tracker

       Note that this must be done AFTER we calculate how many tokens are bought -

       because ethereumToTokens needs to know the amount *before* investment, not *after* investment. */



    currentEthInvested = currentEthInvested + remainingEth;



    // If ICO phase, all the dividends go to the bankroll

    if (icoPhase) {

      toBankRoll     = dividendAmount;



      // If the bankroll is buying, we don't want to send eth back to the bankroll

      // Instead, let's just give it the tokens it would get in an infinite recursive buy

      if (msg.sender == bankrollAddress) {

        toBankRoll = 0;

      }



      toReferrer     = 0;

      toTokenHolders = 0;



      /* ethInvestedDuringICO tracks how much Ether goes straight to tokens,

         not how much Ether we get total.

         this is so that our calculation using "investment" is accurate. */

      ethInvestedDuringICO = ethInvestedDuringICO + remainingEth;

      tokensMintedDuringICO = tokensMintedDuringICO + tokensBought;



      // Cannot purchase more than the hard cap during ICO.

      require(ethInvestedDuringICO <= icoHardCap);

      // Contracts aren't allowed to participate in the ICO.

      require(tx.origin == msg.sender || msg.sender == bankrollAddress);



      // Cannot purchase more then the limit per address during the ICO.

      ICOBuyIn[msg.sender] += remainingEth;

      require(ICOBuyIn[msg.sender] <= addressICOLimit || msg.sender == bankrollAddress);



      // Stop the ICO phase if we reach the hard cap

      if (ethInvestedDuringICO == icoHardCap){

        icoPhase = false;

      }



    } else {

      // Not ICO phase, check for referrals



      // 25% goes to referrers, if set

      // toReferrer = (dividends * 25)/100

      if (_referredBy != 0x0000000000000000000000000000000000000000 &&

      _referredBy != msg.sender &&

      frontTokenBalanceLedger_[_referredBy] >= stakingRequirement)

      {

        toReferrer = (dividendAmount.mul(referrer_percentage)).div(100);

        referralBalance_[_referredBy] += toReferrer;

        emit Referral(_referredBy, toReferrer);

      }



      // The rest of the dividends go to token holders

      toTokenHolders = dividendAmount.sub(toReferrer);



      fee = toTokenHolders * magnitude;

      fee = fee - (fee - (dividendTokensBought * (toTokenHolders * magnitude / (divTokenSupply))));



      // Finally, increase the divToken value

      profitPerDivToken       = profitPerDivToken.add((toTokenHolders.mul(magnitude)).div(divTokenSupply));

      payoutsTo_[msg.sender] += (int256) ((profitPerDivToken * dividendTokensBought) - fee);

    }



    // Update the buyer's token amounts

    frontTokenBalanceLedger_[msg.sender] = frontTokenBalanceLedger_[msg.sender].add(tokensBought);

    dividendTokenBalanceLedger_[msg.sender] = dividendTokenBalanceLedger_[msg.sender].add(dividendTokensBought);



    // Transfer to bankroll and div cards

    if (toBankRoll != 0) { ZethrBankroll(bankrollAddress).receiveDividends.value(toBankRoll)(); }

    if (regularPhase) { divCardContract.receiveDividends.value(toDivCardHolders)(dividendRate); }



    // This event should help us track where all the eth is going

    emit Allocation(toBankRoll, toReferrer, toTokenHolders, toDivCardHolders, remainingEth);



    // Sanity checking

    uint sum = toBankRoll + toReferrer + toTokenHolders + toDivCardHolders + remainingEth - _incomingEthereum;

    assert(sum == 0);

  }



  // How many tokens one gets from a certain amount of ethereum.

  function ethereumToTokens_(uint _ethereumAmount)

  public

  view

  returns(uint)

  {

    require(_ethereumAmount > MIN_ETH_BUYIN, "Tried to buy tokens with too little eth.");



    if (icoPhase) {

      return _ethereumAmount.div(tokenPriceInitial_) * 1e18;

    }



    /*

     *  i = investment, p = price, t = number of tokens

     *

     *  i_current = p_initial * t_current                   (for t_current <= t_initial)

     *  i_current = i_initial + (2/3)(t_current)^(3/2)      (for t_current >  t_initial)

     *

     *  t_current = i_current / p_initial                   (for i_current <= i_initial)

     *  t_current = t_initial + ((3/2)(i_current))^(2/3)    (for i_current >  i_initial)

     */



    // First, separate out the buy into two segments:

    //  1) the amount of eth going towards ico-price tokens

    //  2) the amount of eth going towards pyramid-price (variable) tokens

    uint ethTowardsICOPriceTokens = 0;

    uint ethTowardsVariablePriceTokens = 0;



    if (currentEthInvested >= ethInvestedDuringICO) {

      // Option One: All the ETH goes towards variable-price tokens

      ethTowardsVariablePriceTokens = _ethereumAmount;



    } else if (currentEthInvested < ethInvestedDuringICO && currentEthInvested + _ethereumAmount <= ethInvestedDuringICO) {

      // Option Two: All the ETH goes towards ICO-price tokens

      ethTowardsICOPriceTokens = _ethereumAmount;



    } else if (currentEthInvested < ethInvestedDuringICO && currentEthInvested + _ethereumAmount > ethInvestedDuringICO) {

      // Option Three: Some ETH goes towards ICO-price tokens, some goes towards variable-price tokens

      ethTowardsICOPriceTokens = ethInvestedDuringICO.sub(currentEthInvested);

      ethTowardsVariablePriceTokens = _ethereumAmount.sub(ethTowardsICOPriceTokens);

    } else {

      // Option Four: Should be impossible, and compiler should optimize it out of existence.

      revert();

    }



    // Sanity check:

    assert(ethTowardsICOPriceTokens + ethTowardsVariablePriceTokens == _ethereumAmount);



    // Separate out the number of tokens of each type this will buy:

    uint icoPriceTokens = 0;

    uint varPriceTokens = 0;



    // Now calculate each one per the above formulas.

    // Note: since tokens have 18 decimals of precision we multiply the result by 1e18.

    if (ethTowardsICOPriceTokens != 0) {

      icoPriceTokens = ethTowardsICOPriceTokens.mul(1e18).div(tokenPriceInitial_);

    }



    if (ethTowardsVariablePriceTokens != 0) {

      // Note: we can't use "currentEthInvested" for this calculation, we must use:

      //  currentEthInvested + ethTowardsICOPriceTokens

      // This is because a split-buy essentially needs to simulate two separate buys -

      // including the currentEthInvested update that comes BEFORE variable price tokens are bought!



      uint simulatedEthBeforeInvested = toPowerOfThreeHalves(tokenSupply.div(MULTIPLIER * 1e6)).mul(2).div(3) + ethTowardsICOPriceTokens;

      uint simulatedEthAfterInvested  = simulatedEthBeforeInvested + ethTowardsVariablePriceTokens;



      /* We have the equations for total tokens above; note that this is for TOTAL.

         To get the number of tokens this purchase buys, use the simulatedEthInvestedBefore

         and the simulatedEthInvestedAfter and calculate the difference in tokens.

         This is how many we get. */



      uint tokensBefore = toPowerOfTwoThirds(simulatedEthBeforeInvested.mul(3).div(2)).mul(MULTIPLIER);

      uint tokensAfter  = toPowerOfTwoThirds(simulatedEthAfterInvested.mul(3).div(2)).mul(MULTIPLIER);



      /* Note that we could use tokensBefore = tokenSupply + icoPriceTokens instead of dynamically calculating tokensBefore;

         either should work.



         Investment IS already multiplied by 1e18; however, because this is taken to a power of (2/3),

         we need to multiply the result by 1e6 to get back to the correct number of decimals. */



      varPriceTokens = (1e6) * tokensAfter.sub(tokensBefore);

    }



    uint totalTokensReceived = icoPriceTokens + varPriceTokens;



    assert(totalTokensReceived > 0);

    return totalTokensReceived;

  }



  // How much Ether we get from selling N tokens

  function tokensToEthereum_(uint _tokens)

  public

  view

  returns(uint)

  {

    require (_tokens >= MIN_TOKEN_SELL_AMOUNT, "Tried to sell too few tokens.");



    /*

     *  i = investment, p = price, t = number of tokens

     *

     *  i_current = p_initial * t_current                   (for t_current <= t_initial)

     *  i_current = i_initial + (2/3)(t_current)^(3/2)      (for t_current >  t_initial)

     *

     *  t_current = i_current / p_initial                   (for i_current <= i_initial)

     *  t_current = t_initial + ((3/2)(i_current))^(2/3)    (for i_current >  i_initial)

     */



    // First, separate out the sell into two segments:

    //  1) the amount of tokens selling at the ICO price.

    //  2) the amount of tokens selling at the variable (pyramid) price

    uint tokensToSellAtICOPrice = 0;

    uint tokensToSellAtVariablePrice = 0;



    if (tokenSupply <= tokensMintedDuringICO) {

      // Option One: All the tokens sell at the ICO price.

      tokensToSellAtICOPrice = _tokens;



    } else if (tokenSupply > tokensMintedDuringICO && tokenSupply - _tokens >= tokensMintedDuringICO) {

      // Option Two: All the tokens sell at the variable price.

      tokensToSellAtVariablePrice = _tokens;



    } else if (tokenSupply > tokensMintedDuringICO && tokenSupply - _tokens < tokensMintedDuringICO) {

      // Option Three: Some tokens sell at the ICO price, and some sell at the variable price.

      tokensToSellAtVariablePrice = tokenSupply.sub(tokensMintedDuringICO);

      tokensToSellAtICOPrice      = _tokens.sub(tokensToSellAtVariablePrice);



    } else {

      // Option Four: Should be impossible, and the compiler should optimize it out of existence.

      revert();

    }



    // Sanity check:

    assert(tokensToSellAtVariablePrice + tokensToSellAtICOPrice == _tokens);



    // Track how much Ether we get from selling at each price function:

    uint ethFromICOPriceTokens;

    uint ethFromVarPriceTokens;



    // Now, actually calculate:



    if (tokensToSellAtICOPrice != 0) {



      /* Here, unlike the sister equation in ethereumToTokens, we DON'T need to multiply by 1e18, since

         we will be passed in an amount of tokens to sell that's already at the 18-decimal precision.

         We need to divide by 1e18 or we'll have too much Ether. */



      ethFromICOPriceTokens = tokensToSellAtICOPrice.mul(tokenPriceInitial_).div(1e18);

    }



    if (tokensToSellAtVariablePrice != 0) {



      /* Note: Unlike the sister function in ethereumToTokens, we don't have to calculate any "virtual" token count.

         This is because in sells, we sell the variable price tokens **first**, and then we sell the ICO-price tokens.

         Thus there isn't any weird stuff going on with the token supply.



         We have the equations for total investment above; note that this is for TOTAL.

         To get the eth received from this sell, we calculate the new total investment after this sell.

         Note that we divide by 1e6 here as the inverse of multiplying by 1e6 in ethereumToTokens. */



      uint investmentBefore = toPowerOfThreeHalves(tokenSupply.div(MULTIPLIER * 1e6)).mul(2).div(3);

      uint investmentAfter  = toPowerOfThreeHalves((tokenSupply - tokensToSellAtVariablePrice).div(MULTIPLIER * 1e6)).mul(2).div(3);



      ethFromVarPriceTokens = investmentBefore.sub(investmentAfter);

    }



    uint totalEthReceived = ethFromVarPriceTokens + ethFromICOPriceTokens;



    assert(totalEthReceived > 0);

    return totalEthReceived;

  }



  function transferFromInternal(address _from, address _toAddress, uint _amountOfTokens, bytes _data)

  internal

  {

    require(regularPhase);

    require(_toAddress != address(0x0));

    address _customerAddress     = _from;

    uint _amountOfFrontEndTokens = _amountOfTokens;



    // Withdraw all outstanding dividends first (including those generated from referrals).

    if(theDividendsOf(true, _customerAddress) > 0) withdrawFrom(_customerAddress);



    // Calculate how many back-end dividend tokens to transfer.

    // This amount is proportional to the caller's average dividend rate multiplied by the proportion of tokens being transferred.

    uint _amountOfDivTokens = _amountOfFrontEndTokens.mul(getUserAverageDividendRate(_customerAddress)).div(magnitude);



    if (_customerAddress != msg.sender){

      // Update the allowed balance.

      // Don't update this if we are transferring our own tokens (via transfer or buyAndTransfer)

      allowed[_customerAddress][msg.sender] -= _amountOfTokens;

    }



    // Exchange tokens

    frontTokenBalanceLedger_[_customerAddress]    = frontTokenBalanceLedger_[_customerAddress].sub(_amountOfFrontEndTokens);

    frontTokenBalanceLedger_[_toAddress]          = frontTokenBalanceLedger_[_toAddress].add(_amountOfFrontEndTokens);

    dividendTokenBalanceLedger_[_customerAddress] = dividendTokenBalanceLedger_[_customerAddress].sub(_amountOfDivTokens);

    dividendTokenBalanceLedger_[_toAddress]       = dividendTokenBalanceLedger_[_toAddress].add(_amountOfDivTokens);



    // Recipient inherits dividend percentage if they have not already selected one.

    if(!userSelectedRate[_toAddress])

    {

      userSelectedRate[_toAddress] = true;

      userDividendRate[_toAddress] = userDividendRate[_customerAddress];

    }



    // Update dividend trackers

    payoutsTo_[_customerAddress] -= (int256) (profitPerDivToken * _amountOfDivTokens);

    payoutsTo_[_toAddress]       += (int256) (profitPerDivToken * _amountOfDivTokens);



    uint length;



    assembly {

      length := extcodesize(_toAddress)

    }



    if (length > 0){

      // its a contract

      // note: at ethereum update ALL addresses are contracts

      ERC223Receiving receiver = ERC223Receiving(_toAddress);

      receiver.tokenFallback(_from, _amountOfTokens, _data);

    }



    // Fire logging event.

    emit Transfer(_customerAddress, _toAddress, _amountOfFrontEndTokens);

  }



  // Called from transferFrom. Always checks if _customerAddress has dividends.

  function withdrawFrom(address _customerAddress)

  internal

  {

    // Setup data

    uint _dividends                    = theDividendsOf(false, _customerAddress);



    // update dividend tracker

    payoutsTo_[_customerAddress]       +=  (int256) (_dividends * magnitude);



    // add ref. bonus

    _dividends                         += referralBalance_[_customerAddress];

    referralBalance_[_customerAddress]  = 0;



    _customerAddress.transfer(_dividends);



    // Fire logging event.

    emit onWithdraw(_customerAddress, _dividends);

  }





  /*=======================

   =    RESET FUNCTIONS   =

   ======================*/



  function injectEther()

  public

  payable

  onlyAdministrator

  {



  }



  /*=======================

   =   MATHS FUNCTIONS    =

   ======================*/



  function toPowerOfThreeHalves(uint x) public pure returns (uint) {

    // m = 3, n = 2

    // sqrt(x^3)

    return sqrt(x**3);

  }



  function toPowerOfTwoThirds(uint x) public pure returns (uint) {

    // m = 2, n = 3

    // cbrt(x^2)

    return cbrt(x**2);

  }



  function sqrt(uint x) public pure returns (uint y) {

    uint z = (x + 1) / 2;

    y = x;

    while (z < y) {

      y = z;

      z = (x / z + z) / 2;

    }

  }



  function cbrt(uint x) public pure returns (uint y) {

    uint z = (x + 1) / 3;

    y = x;

    while (z < y) {

      y = z;

      z = (x / (z*z) + 2 * z) / 3;

    }

  }

}



/*=======================

 =     INTERFACES       =

 ======================*/





contract ZethrDividendCards {

  function ownerOf(uint /*_divCardId*/) public pure returns (address) {}

  function receiveDividends(uint /*_divCardRate*/) public payable {}

}



contract ZethrBankroll{

  function receiveDividends() public payable {}

}





contract ERC223Receiving {

  function tokenFallback(address _from, uint _amountOfTokens, bytes _data) public returns (bool);

}



// Think it's safe to say y'all know what this is.



library SafeMath {



  function mul(uint a, uint b) internal pure returns (uint) {

    if (a == 0) {

      return 0;

    }

    uint c = a * b;

    assert(c / a == b);

    return c;

  }



  function div(uint a, uint b) internal pure returns (uint) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint a, uint b) internal pure returns (uint) {

    assert(b <= a);

    return a - b;

  }



  function add(uint a, uint b) internal pure returns (uint) {

    uint c = a + b;

    assert(c >= a);

    return c;

  }

}