pragma solidity ^0.4.18;

/**
 *
 * @author  <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="08787a697c717d7b60266a60697c7c48787a677c676665696164266b6765">[email&#160;protected]</a>>
 *
 * RDFDM - Riverdimes Fiat Donation Manager
 * Version D
 *
 * Overview:
 * four basic round-up operations are supported:
 *
 * A) fiatCollected: Record Fiat Donation (collection)
 *    inputs:        charity (C), fiat amount ($XX.XX),
 *    summary:       creates a log of a fiat donation to a specified charity, C.
 *    message:       $XX.XX collected FBO Charity C, internal document #ABC
 *    - add $XX.XX to chariy&#39;s fiatBalanceIn, fiatCollected
 *
 * B) fiatToEth:     Fiat Converted to ETH
 *    inputs:        charity (C), fiat amount ($XX.XX), ETH amount (Z), document reference (ABC)
 *    summary:       deduct $XX.XX from charity C&#39;s fiatBalanceIn; credit charity C&#39;s ethBalanceIn. this operation is invoked
 *                   when fiat donations are converted to ETH. it includes a deposit of Z ETH.
 *    message(s):    On behalf of Charity C, $XX.XX used to purchase Z ETH
 *    - $XX.XX deducted from charity C&#39;s fiatBalanceIn
 *    - skims 4% of Z for RD Token holders, and 16% for operational overhead
 *    - credits charity C with 80% of Z ETH (ethBalance)
 *
 * C) ethToFiat:     ETH Converted to Fiat
 *    inputs:        charity (C), ETH amount (Z), fiat amount ($XX.XX), document reference (ABC)
 *    summary:       withdraw ETH from and convert to fiat
 *    message(s):    Z ETH converted to $XX.XX FBO Charity C
 *    - deducts Z ETH from charity C&#39;s ethBalance
 *    - adds $XX.XX to charity C&#39;s fiatBalanceOut
 *
 * D) fiatDelivered: Record Fiat Delivery to Specified Charity
 *    inputs:        charity (C), fiat amount ($XX.XX), document reference (ABC)
 *    summary:       creates a log of a fiat delivery to a specified charity, C:
 *    message:       $XX.XX delivered to Charity C, internal document #ABC
 *    - deducts the dollar amount, $XX.XX from charity&#39;s fiatBalanceOut
 *    - add $XX.XX to charity&#39;s totalDelivered
 *
 * one basic operation, unrelated to round-up
 *
 * A) ethDonation:        Direct ETH Donation to Charity
 *    inputs:             charity (C), ETH amount (Z), document reference (ABC)
 *    summary:            ETH donation to a specified charity, crediting charity&#39;s ethBalance. ETH in transaction.
 *    messages:           Z ETH donated to Charity C, internal document #ABC
 *    - add Z ETH to chariy&#39;s ethDonated
 *    - skims 0.5% of Z for RD Token holders, and 1.5% for operational overhead
 *    - credits charity C with 98% of Z ETH (ethBalance)
 *
 * in addition there are shortcut operations (related to round-up):
 *
 * A) fiatCollectedToEth: Record Fiat Donation (collection) and convert to ETH
 *    inputs:             charity (C), fiat amount ($XX.XX), ETH amount (Z), document reference (ABC)
 *    summary:            creates a log of a fiat donation to a specified charity, C; fiat donation is immediately converted to
 *                        ETH, crediting charity C&#39;s ethBalance. the transaction includes a deposit of Z ETH.
 *    messages:           $XX.XX collected FBO Charity C, internal document #ABC
 *                        On behalf of Charity C, $XX.XX used to purchase Z ETH
 *    - add $XX.XX to chariy&#39;s fiatCollected
 *    - skims 4% of Z for RD Token holders, and 16% for operational overhead
 *    - credits charity C with 80% of Z ETH (ethBalance)
 *
 * B) ethToFiatDelivered: Record ETH Conversion to Fiat; and Fiat Delivery to Specified Charity
 *    inputs:             charity (C), ETH amount (Z), fiat amount ($XX.XX), document reference (ABC)
 *    summary:            withdraw ETH from charity C&#39;s ethBalance and convert to fiat; log fiat delivery of $XX.XX.
 *    messages:           Z ETH converted to $XX.XX FBO Charity C
 *                        $XX.XX delivered to Charity C, internal document #ABC
 *    - deducts Z ETH from charity C&#39;s ethBalance
 *    - add $XX.XX to charity&#39;s totalDelivered
 *
 */

//import &#39;./SafeMath.sol&#39;;
//contract RDFDM is SafeMath
contract RDFDM {

  //events relating to donation operations
  //
  event FiatCollectedEvent(uint indexed charity, uint usd, string ref);
  event FiatToEthEvent(uint indexed charity, uint usd, uint eth);
  event EthToFiatEvent(uint indexed charity, uint eth, uint usd);
  event FiatDeliveredEvent(uint indexed charity, uint usd, string ref);
  event EthDonationEvent(uint indexed charity, uint eth);

  //events relating to adding and deleting charities
  //
  event CharityAddedEvent(uint indexed charity, string name, uint8 currency);
  event CharityModifiedEvent(uint indexed charity, string name, uint8 currency);

  //currencies
  //
  uint constant  CURRENCY_USD  = 0x01;
  uint constant  CURRENCY_EURO = 0x02;
  uint constant  CURRENCY_NIS  = 0x03;
  uint constant  CURRENCY_YUAN = 0x04;


  struct Charity {
    uint fiatBalanceIn;           // funds in external acct, collected fbo charity
    uint fiatBalanceOut;          // funds in external acct, pending delivery to charity
    uint fiatCollected;           // total collected since dawn of creation
    uint fiatDelivered;           // total delivered since dawn of creation
    uint ethDonated;              // total eth donated since dawn of creation
    uint ethCredited;             // total eth credited to this charity since dawn of creation
    uint ethBalance;              // current eth balance of this charity
    uint fiatToEthPriceAccEth;    // keep track of fiat to eth conversion price: total eth
    uint fiatToEthPriceAccFiat;   // keep track of fiat to eth conversion price: total fiat
    uint ethToFiatPriceAccEth;    // kkep track of eth to fiat conversion price: total eth
    uint ethToFiatPriceAccFiat;   // kkep track of eth to fiat conversion price: total fiat
    uint8 currency;               // fiat amounts are in smallest denomination of currency
    string name;                  // eg. "Salvation Army"
  }

  uint public charityCount;
  address public owner;
  address public manager;
  address public token;           //token-holder fees sent to this address
  address public operatorFeeAcct; //operations fees sent to this address
  mapping (uint => Charity) public charities;
  bool public isLocked;

  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }

  modifier managerOnly {
    require(msg.sender == owner || msg.sender == manager);
    _;
  }

  modifier unlockedOnly {
    require(!isLocked);
    _;
  }


  //
  //constructor
  //
  function RDFDM() public {
    owner = msg.sender;
    manager = msg.sender;
    token = msg.sender;
    operatorFeeAcct = msg.sender;
  }
  function lock() public ownerOnly { isLocked = true; }
  function setToken(address _token) public ownerOnly unlockedOnly { token = _token; }
  function setOperatorFeeAcct(address _operatorFeeAcct) public ownerOnly { operatorFeeAcct = _operatorFeeAcct; }
  function setManager(address _manager) public managerOnly { manager = _manager; }
  function deleteManager() public managerOnly { manager = owner; }


  function addCharity(string _name, uint8 _currency) public managerOnly {
    charities[charityCount].name = _name;
    charities[charityCount].currency = _currency;
    CharityAddedEvent(charityCount, _name, _currency);
    ++charityCount;
  }

  function modifyCharity(uint _charity, string _name, uint8 _currency) public managerOnly {
    require(_charity < charityCount);
    charities[_charity].name = _name;
    charities[_charity].currency = _currency;
    CharityModifiedEvent(_charity, _name, _currency);
  }



  //======== basic operations

  function fiatCollected(uint _charity, uint _fiat, string _ref) public managerOnly {
    require(_charity < charityCount);
    charities[_charity].fiatBalanceIn += _fiat;
    charities[_charity].fiatCollected += _fiat;
    FiatCollectedEvent(_charity, _fiat, _ref);
  }

  function fiatToEth(uint _charity, uint _fiat) public managerOnly payable {
    require(token != 0);
    require(_charity < charityCount);
    //keep track of fiat to eth conversion price
    charities[_charity].fiatToEthPriceAccFiat += _fiat;
    charities[_charity].fiatToEthPriceAccEth += msg.value;
    charities[_charity].fiatBalanceIn -= _fiat;
    uint _tokenCut = (msg.value * 4) / 100;
    uint _operatorCut = (msg.value * 16) / 100;
    uint _charityCredit = (msg.value - _operatorCut) - _tokenCut;
    operatorFeeAcct.transfer(_operatorCut);
    token.transfer(_tokenCut);
    charities[_charity].ethBalance += _charityCredit;
    charities[_charity].ethCredited += _charityCredit;
    FiatToEthEvent(_charity, _fiat, msg.value);
  }

  function ethToFiat(uint _charity, uint _eth, uint _fiat) public managerOnly {
    require(_charity < charityCount);
    require(charities[_charity].ethBalance >= _eth);
    //keep track of fiat to eth conversion price
    charities[_charity].ethToFiatPriceAccFiat += _fiat;
    charities[_charity].ethToFiatPriceAccEth += _eth;
    charities[_charity].ethBalance -= _eth;
    charities[_charity].fiatBalanceOut += _fiat;
    //withdraw funds to the caller
    msg.sender.transfer(_eth);
    EthToFiatEvent(_charity, _eth, _fiat);
  }

  function fiatDelivered(uint _charity, uint _fiat, string _ref) public managerOnly {
    require(_charity < charityCount);
    require(charities[_charity].fiatBalanceOut >= _fiat);
    charities[_charity].fiatBalanceOut -= _fiat;
    charities[_charity].fiatDelivered += _fiat;
    FiatDeliveredEvent(_charity, _fiat, _ref);
  }

  //======== unrelated to round-up
  function ethDonation(uint _charity) public payable {
    require(token != 0);
    require(_charity < charityCount);
    uint _tokenCut = (msg.value * 1) / 200;
    uint _operatorCut = (msg.value * 3) / 200;
    uint _charityCredit = (msg.value - _operatorCut) - _tokenCut;
    operatorFeeAcct.transfer(_operatorCut);
    token.transfer(_tokenCut);
    charities[_charity].ethDonated += _charityCredit;
    charities[_charity].ethBalance += _charityCredit;
    charities[_charity].ethCredited += _charityCredit;
    EthDonationEvent(_charity, msg.value);
  }


  //======== combo operations
  function fiatCollectedToEth(uint _charity, uint _fiat, string _ref) public managerOnly payable {
    require(token != 0);
    require(_charity < charityCount);
    charities[_charity].fiatCollected += _fiat;
    //charities[_charity].fiatBalanceIn does not change, since we immediately convert to eth
    //keep track of fiat to eth conversion price
    charities[_charity].fiatToEthPriceAccFiat += _fiat;
    charities[_charity].fiatToEthPriceAccEth += msg.value;
    uint _tokenCut = (msg.value * 4) / 100;
    uint _operatorCut = (msg.value * 16) / 100;
    uint _charityCredit = (msg.value - _operatorCut) - _tokenCut;
    operatorFeeAcct.transfer(_operatorCut);
    token.transfer(_tokenCut);
    charities[_charity].ethBalance += _charityCredit;
    charities[_charity].ethCredited += _charityCredit;
    FiatCollectedEvent(_charity, _fiat, _ref);
    FiatToEthEvent(_charity, _fiat, msg.value);
  }

  function ethToFiatDelivered(uint _charity, uint _eth, uint _fiat, string _ref) public managerOnly {
    require(_charity < charityCount);
    require(charities[_charity].ethBalance >= _eth);
    //keep track of fiat to eth conversion price
    charities[_charity].ethToFiatPriceAccFiat += _fiat;
    charities[_charity].ethToFiatPriceAccEth += _eth;
    charities[_charity].ethBalance -= _eth;
    //charities[_charity].fiatBalanceOut does not change, since we immediately deliver
    //withdraw funds to the caller
    msg.sender.transfer(_eth);
    EthToFiatEvent(_charity, _eth, _fiat);
    charities[_charity].fiatDelivered += _fiat;
    FiatDeliveredEvent(_charity, _fiat, _ref);
  }


  //note: constant fcn does not need safe math
  function divRound(uint256 _x, uint256 _y) pure internal returns (uint256) {
    uint256 z = (_x + (_y / 2)) / _y;
    return z;
  }

  function quickAuditEthCredited(uint _charityIdx) public constant returns (uint _fiatCollected,
                                                                            uint _fiatToEthNotProcessed,
                                                                            uint _fiatToEthProcessed,
                                                                            uint _fiatToEthPricePerEth,
                                                                            uint _fiatToEthCreditedFinney,
                                                                            uint _fiatToEthAfterFeesFinney,
                                                                            uint _ethDonatedFinney,
                                                                            uint _ethDonatedAfterFeesFinney,
                                                                            uint _totalEthCreditedFinney,
                                                                            int _quickDiscrepancy) {
    require(_charityIdx < charityCount);
    Charity storage _charity = charities[_charityIdx];
    _fiatCollected = _charity.fiatCollected;                                                   //eg. $450 = 45000
    _fiatToEthNotProcessed = _charity.fiatBalanceIn;                                           //eg.            0
    _fiatToEthProcessed = _fiatCollected - _fiatToEthNotProcessed;                                        //eg.        45000
    if (_charity.fiatToEthPriceAccEth == 0) {
      _fiatToEthPricePerEth = 0;
      _fiatToEthCreditedFinney = 0;
    } else {
      _fiatToEthPricePerEth = divRound(_charity.fiatToEthPriceAccFiat * (1 ether),              //eg. 45000 * 10^18 = 45 * 10^21
                                       _charity.fiatToEthPriceAccEth);                          //eg 1.5 ETH        = 15 * 10^17
                                                                                                //               --------------------
                                                                                                //                     3 * 10^4 (30000 cents per ether)
      uint _finneyPerEth = 1 ether / 1 finney;
      _fiatToEthCreditedFinney = divRound(_fiatToEthProcessed * _finneyPerEth,                  //eg. 45000 * 1000 / 30000 = 1500 (finney)
                                          _fiatToEthPricePerEth);
      _fiatToEthAfterFeesFinney = divRound(_fiatToEthCreditedFinney * 8, 10);                   //eg. 1500 * 8 / 10 = 1200 (finney)
    }
    _ethDonatedFinney = divRound(_charity.ethDonated, 1 finney);                                //eg. 1 ETH = 1 * 10^18 / 10^15 = 1000 (finney)
    _ethDonatedAfterFeesFinney = divRound(_ethDonatedFinney * 98, 100);                         //eg. 1000 * 98/100 = 980 (finney)
    _totalEthCreditedFinney = _fiatToEthAfterFeesFinney + _ethDonatedAfterFeesFinney;           //eg 1200 + 980 = 2180 (finney)
    uint256 tecf = divRound(_charity.ethCredited, 1 finney);                                    //eg. 2180000000000000000 * (10^-15) = 2180
    _quickDiscrepancy = int256(_totalEthCreditedFinney) - int256(tecf);
  }




  //note: contant fcn does not need safe math
  function quickAuditFiatDelivered(uint _charityIdx) public constant returns (uint _totalEthCreditedFinney,
                                                                              uint _ethNotProcessedFinney,
                                                                              uint _processedEthCreditedFinney,
                                                                              uint _ethToFiatPricePerEth,
                                                                              uint _ethToFiatCreditedFiat,
                                                                              uint _ethToFiatNotProcessed,
                                                                              uint _ethToFiatProcessed,
                                                                              uint _fiatDelivered,
                                                                              int _quickDiscrepancy) {
    require(_charityIdx < charityCount);
    Charity storage _charity = charities[_charityIdx];
    _totalEthCreditedFinney = divRound(_charity.ethCredited, 1 finney);                      //eg. 2180000000000000000 * (10^-15) = 2180
    _ethNotProcessedFinney = divRound(_charity.ethBalance, 1 finney);                        //eg. 1 ETH = 1 * 10^18 / 10^15 = 1000 (finney)
    _processedEthCreditedFinney = _totalEthCreditedFinney - _ethNotProcessedFinney;          //eg 1180 finney
    if (_charity.ethToFiatPriceAccEth == 0) {
      _ethToFiatPricePerEth = 0;
      _ethToFiatCreditedFiat = 0;
    } else {
      _ethToFiatPricePerEth = divRound(_charity.ethToFiatPriceAccFiat * (1 ether),           //eg. 29400 * 10^18 = 2940000 * 10^16
                                       _charity.ethToFiatPriceAccEth);                       //eg 0.980 ETH      =      98 * 10^16
                                                                                             //               --------------------
                                                                                             //                      30000 (30000 cents per ether)
      uint _finneyPerEth = 1 ether / 1 finney;
      _ethToFiatCreditedFiat = divRound(_processedEthCreditedFinney * _ethToFiatPricePerEth, //eg. 1180 * 30000 / 1000 = 35400
                                        _finneyPerEth);
    }
    _ethToFiatNotProcessed = _charity.fiatBalanceOut;
    _ethToFiatProcessed = _ethToFiatCreditedFiat - _ethToFiatNotProcessed;
    _fiatDelivered = _charity.fiatDelivered;
    _quickDiscrepancy = int256(_ethToFiatProcessed) - int256(_fiatDelivered);
  }


  //
  // default payable function.
  //
  function () public payable {
    revert();
  }

  //for debug
  //only available before the contract is locked
  function haraKiri() public ownerOnly unlockedOnly {
    selfdestruct(owner);
  }

}