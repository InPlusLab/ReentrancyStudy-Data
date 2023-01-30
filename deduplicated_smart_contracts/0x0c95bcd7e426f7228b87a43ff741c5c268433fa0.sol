/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

/**************************************************************************
 *            ____        _                              
 *           / ___|      | |     __ _  _   _   ___  _ __ 
 *          | |    _____ | |    / _` || | | | / _ \| '__|
 *          | |___|_____|| |___| (_| || |_| ||  __/| |   
 *           \____|      |_____|\__,_| \__, | \___||_|   
 *                                     |___/             
 * 
 **************************************************************************
 *
 *  The MIT License (MIT)
 *
 * Copyright (c) 2016-2019 Cyril Lapinte
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 **************************************************************************
 *
 * Flatten Contract: RatesProvider
 *
 * Git Commit:
 * https://github.com/c-layer/contracts/tree/43925ba24cc22f42d0ff7711d0e169e8c2a0e09f
 *
 **************************************************************************/


// File: contracts/interface/IRatesProvider.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title IRatesProvider
 * @dev IRatesProvider interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 */
contract IRatesProvider {

  function defineRatesExternal(uint256[] calldata _rates) external returns (bool);

  function name() public view returns (string memory);

  function rate(bytes32 _currency) public view returns (uint256);

  function currencies() public view
    returns (bytes32[] memory, uint256[] memory, uint256);
  function rates() public view returns (uint256, uint256[] memory);

  function convert(uint256 _amount, bytes32 _fromCurrency, bytes32 _toCurrency)
    public view returns (uint256);

  function defineCurrencies(
    bytes32[] memory _currencies,
    uint256[] memory _decimals,
    uint256 _rateOffset) public returns (bool);
  function defineRates(uint256[] memory _rates) public returns (bool);

  event RateOffset(uint256 rateOffset);
  event Currencies(bytes32[] currencies, uint256[] decimals);
  event Rate(bytes32 indexed currency, uint256 rate);
}

// File: contracts/util/math/SafeMath.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/util/governance/Ownable.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/util/governance/Operable.sol

pragma solidity >=0.5.0 <0.6.0;



/**
 * @title Operable
 * @dev The Operable contract enable the restrictions of operations to a set of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 * OP01: Message sender must be an operator
 * OP02: Address must be an operator
 * OP03: Address must not be an operator
 */
contract Operable is Ownable {

  mapping (address => bool) private operators_;

  /**
   * @dev Throws if called by any account other than the operator
   */
  modifier onlyOperator {
    require(operators_[msg.sender], "OP01");
    _;
  }

  /**
   * @dev constructor
   */
  constructor() public {
    defineOperator("Owner", msg.sender);
  }

  /**
   * @dev isOperator
   * @param _address operator address
   */
  function isOperator(address _address) public view returns (bool) {
    return operators_[_address];
  }

  /**
   * @dev removeOperator
   * @param _address operator address
   */
  function removeOperator(address _address) public onlyOwner {
    require(operators_[_address], "OP02");
    operators_[_address] = false;
    emit OperatorRemoved(_address);
  }

  /**
   * @dev defineOperator
   * @param _role operator role
   * @param _address operator address
   */
  function defineOperator(string memory _role, address _address)
    public onlyOwner
  {
    require(!operators_[_address], "OP03");
    operators_[_address] = true;
    emit OperatorDefined(_role, _address);
  }

  event OperatorRemoved(address address_);
  event OperatorDefined(
    string role,
    address address_
  );
}

// File: contracts/RatesProvider.sol

pragma solidity >=0.5.0 <0.6.0;





/**
 * @title RatesProvider
 * @dev RatesProvider interface
 * @dev The null value for a rate indicates that the rate is undefined
 * @dev It is recommended that smart contracts always check against a null rate
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 *   RP01: Currencies must match decimals length
 *   RP02: rateOffset cannot be null
 *   RP03: Rates definition must only target configured currencies
 */
contract RatesProvider is IRatesProvider, Operable {
  using SafeMath for uint256;

  string internal name_;

  // decimals offset with which rates are stored using the counter currency
  // this must be high enought to cover worse case
  // Can only be set to 1 with ETH or ERC20 which already have 18 decimals
  // It should likely be configured to 10**16 (18-2) for GBP, USD or CHF.
  uint256 internal rateOffset_ = 1;

  // The first currency will be the counter currency
  bytes32[] internal currencies_ =
    [ bytes32("ETH"), "BTC", "EOS", "GBP", "USD", "CHF", "EUR", "CNY", "JPY", "CAD", "AUD" ];
  uint256[] internal decimals_ = [ uint256(18), 8, 4, 2, 2, 2, 2, 2, 2, 2, 2 ];

  mapping(bytes32 => uint256) internal ratesMap;
  uint256[] internal rates_ = new uint256[](currencies_.length-1);
  uint256 internal updatedAt_;

  /*
   * @dev constructor
   */
  constructor(string memory _name) public {
    name_ = _name;
    for (uint256 i=0; i < currencies_.length; i++) {
      ratesMap[currencies_[i]] = i;
    }
  }

  /**
   * @dev define all rates
   * @dev The rates should be defined in the base currency (WEI, Satoshi, cents, ...)
   * @dev Rates should also account for rateOffset
   */
  function defineRatesExternal(uint256[] calldata _rates)
    external onlyOperator returns (bool)
  {
    require(_rates.length < currencies_.length, "RP03");

    // solhint-disable-next-line not-rely-on-time
    updatedAt_ = now;
    for (uint256 i=0; i < _rates.length; i++) {
      if (rates_[i] != _rates[i]) {
        rates_[i] = _rates[i];
        emit Rate(currencies_[i+1], _rates[i]);
      }
    }
    return true;
  }

  /**
   * @dev name
   */
  function name() public view returns (string memory) {
    return name_;
  }

  /**
   * @dev rate for a currency
   */
  function rate(bytes32 _currency) public view returns (uint256) {
    return ratePrivate(_currency);
  }

  /**
   * @dev currencies
   */
  function currencies() public view
    returns (bytes32[] memory, uint256[] memory, uint256)
  {
    return (currencies_, decimals_, rateOffset_);
  }

  /**
   * @dev rate as store for a currency
   */
  function rates() public view returns (uint256, uint256[] memory) {
    return (updatedAt_, rates_);
  }

  /**
   * @dev convert between two currency (base units)
   */
  function convert(uint256 _amount, bytes32 _fromCurrency, bytes32 _toCurrency)
    public view returns (uint256)
  {
    if (_fromCurrency == _toCurrency) {
      return _amount;
    }

    uint256 rateFrom = (_fromCurrency != currencies_[0]) ?
      ratePrivate(_fromCurrency) : rateOffset_;
    uint256 rateTo = (_toCurrency != currencies_[0]) ?
      ratePrivate(_toCurrency) : rateOffset_;

    return (rateTo != 0) ?
      _amount.mul(rateFrom).div(rateTo) : 0;
  }

  /**
   * @dev define all currencies
   * @dev @param _rateOffset is to be used when the default currency
   * @dev does not have enough decimals for sufficient rate precisions
   */
  function defineCurrencies(
    bytes32[] memory _currencies,
    uint256[] memory _decimals,
    uint256 _rateOffset) public onlyOperator returns (bool)
  {
    require(_currencies.length == _decimals.length, "RP01");
    require(_rateOffset != 0, "RP02");

    for (uint256 i= _currencies.length; i < currencies_.length; i++) {
      delete ratesMap[currencies_[i]];
      emit Rate(currencies_[i], 0);
    }
    rates_.length = _currencies.length-1;

    bool hasBaseCurrencyChanged = _currencies[0] != currencies_[0];
    for (uint256 i=1; i < _currencies.length; i++) {
      bytes32 currency = _currencies[i];
      if (rateOffset_ != _rateOffset
        || ratesMap[currency] != i
        || hasBaseCurrencyChanged)
      {
        ratesMap[currency] = i;
        rates_[i-1] = 0;

        if (i < currencies_.length) {
          emit Rate(currencies_[i], 0);
        }
      }
    }

    if (rateOffset_ != _rateOffset) {
      emit RateOffset(_rateOffset);
      rateOffset_ = _rateOffset;
    }

    // solhint-disable-next-line not-rely-on-time
    updatedAt_ = now;
    currencies_ = _currencies;
    decimals_ = _decimals;

    emit Currencies(_currencies, _decimals);
    return true;
  }
  
  /**
   * @dev define all rates
   * @dev The rates should be defined in the base currency (WEI, Satoshi, cents, ...)
   * @dev Rates should also account for rateOffset
   */
  function defineRates(uint256[] memory _rates)
    public onlyOperator returns (bool)
  {
    require(_rates.length < currencies_.length, "RP03");

    // solhint-disable-next-line not-rely-on-time
    updatedAt_ = now;
    for (uint256 i=0; i < _rates.length; i++) {
      if (rates_[i] != _rates[i]) {
        rates_[i] = _rates[i];
        emit Rate(currencies_[i+1], _rates[i]);
      }
    }
    return true;
  }

  /**
   * @dev rate for a currency
   */
  function ratePrivate(bytes32 _currency) private view returns (uint256) {
    if (_currency == currencies_[0]) {
      return 1;
    }

    uint256 id = ratesMap[_currency];
    return (id > 0) ? rates_[id-1] : 0;
  }
}