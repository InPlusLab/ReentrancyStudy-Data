/**

 *Submitted for verification at Etherscan.io on 2018-09-11

*/



pragma solidity ^0.4.23;



// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol



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



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol



/**

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropiate to concatenate

 * behavior.

 */

contract Crowdsale {

  using SafeMath for uint256;



  // The token being sold

  ERC20 public token;



  // Address where funds are collected

  address public wallet;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 public rate;



  // Amount of wei raised

  uint256 public weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokenPurchase(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param _rate Number of token units a buyer gets per wei

   * @param _wallet Address where collected funds will be forwarded to

   * @param _token Address of the token being sold

   */

  constructor(uint256 _rate, address _wallet, ERC20 _token) public {

    require(_rate > 0);

    require(_wallet != address(0));

    require(_token != address(0));



    rate = _rate;

    wallet = _wallet;

    token = _token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   */

  function () external payable {

    buyTokens(msg.sender);

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokens(address _beneficiary) public payable {



    uint256 weiAmount = msg.value;

    _preValidatePurchase(_beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    weiRaised = weiRaised.add(weiAmount);



    _processPurchase(_beneficiary, tokens);

    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(_beneficiary, weiAmount);



    _forwardFunds();

    _postValidatePurchase(_beneficiary, weiAmount);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    require(_beneficiary != address(0));

    require(_weiAmount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param _beneficiary Address performing the token purchase

   * @param _tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    token.transfer(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

   * @param _beneficiary Address receiving the tokens

   * @param _tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    _deliverTokens(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param _beneficiary Address receiving the tokens

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param _weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 _weiAmount)

    internal view returns (uint256)

  {

    return _weiAmount.mul(rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    wallet.transfer(msg.value);

  }

}



// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol



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



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol



/**

 * @title WhitelistedCrowdsale

 * @dev Crowdsale in which only whitelisted users can contribute.

 */

contract WhitelistedCrowdsale is Crowdsale, Ownable {



  mapping(address => bool) public whitelist;



  /**

   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.

   */

  modifier isWhitelisted(address _beneficiary) {

    require(whitelist[_beneficiary]);

    _;

  }



  /**

   * @dev Adds single address to whitelist.

   * @param _beneficiary Address to be added to the whitelist

   */

  function addToWhitelist(address _beneficiary) external onlyOwner {

    whitelist[_beneficiary] = true;

  }



  /**

   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.

   * @param _beneficiaries Addresses to be added to the whitelist

   */

  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {

    for (uint256 i = 0; i < _beneficiaries.length; i++) {

      whitelist[_beneficiaries[i]] = true;

    }

  }



  /**

   * @dev Removes single address from whitelist.

   * @param _beneficiary Address to be removed to the whitelist

   */

  function removeFromWhitelist(address _beneficiary) external onlyOwner {

    whitelist[_beneficiary] = false;

  }



  /**

   * @dev Extend parent behavior requiring beneficiary to be in whitelist.

   * @param _beneficiary Token beneficiary

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

    isWhitelisted(_beneficiary)

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



}



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol



/**

 * @title TimedCrowdsale

 * @dev Crowdsale accepting contributions only within a time frame.

 */

contract TimedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 public openingTime;

  uint256 public closingTime;



  /**

   * @dev Reverts if not in crowdsale time range.

   */

  modifier onlyWhileOpen {

    // solium-disable-next-line security/no-block-members

    require(block.timestamp >= openingTime && block.timestamp <= closingTime);

    _;

  }



  /**

   * @dev Constructor, takes crowdsale opening and closing times.

   * @param _openingTime Crowdsale opening time

   * @param _closingTime Crowdsale closing time

   */

  constructor(uint256 _openingTime, uint256 _closingTime) public {

    // solium-disable-next-line security/no-block-members

    require(_openingTime >= block.timestamp);

    require(_closingTime >= _openingTime);



    openingTime = _openingTime;

    closingTime = _closingTime;

  }



  /**

   * @dev Checks whether the period in which the crowdsale is open has already elapsed.

   * @return Whether crowdsale period has elapsed

   */

  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > closingTime;

  }



  /**

   * @dev Extend parent behavior requiring to be within contributing period

   * @param _beneficiary Token purchaser

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

    onlyWhileOpen

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



}



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol



/**

 * @title FinalizableCrowdsale

 * @dev Extension of Crowdsale where an owner can do extra work

 * after finishing.

 */

contract FinalizableCrowdsale is TimedCrowdsale, Ownable {

  using SafeMath for uint256;



  bool public isFinalized = false;



  event Finalized();



  /**

   * @dev Must be called after crowdsale ends, to do some extra finalization

   * work. Calls the contract's finalization function.

   */

  function finalize() onlyOwner public {

    require(!isFinalized);

    require(hasClosed());



    finalization();

    emit Finalized();



    isFinalized = true;

  }



  /**

   * @dev Can be overridden to add finalization logic. The overriding function

   * should call super.finalization() to ensure the chain of finalization is

   * executed entirely.

   */

  function finalization() internal {

  }



}



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/utils/RefundVault.sol



/**

 * @title RefundVault

 * @dev This contract is used for storing funds while a crowdsale

 * is in progress. Supports refunding the money if crowdsale fails,

 * and forwarding it if crowdsale is successful.

 */

contract RefundVault is Ownable {

  using SafeMath for uint256;



  enum State { Active, Refunding, Closed }



  mapping (address => uint256) public deposited;

  address public wallet;

  State public state;



  event Closed();

  event RefundsEnabled();

  event Refunded(address indexed beneficiary, uint256 weiAmount);



  /**

   * @param _wallet Vault address

   */

  constructor(address _wallet) public {

    require(_wallet != address(0));

    wallet = _wallet;

    state = State.Active;

  }



  /**

   * @param investor Investor address

   */

  function deposit(address investor) onlyOwner public payable {

    require(state == State.Active);

    deposited[investor] = deposited[investor].add(msg.value);

  }



  function close() onlyOwner public {

    require(state == State.Active);

    state = State.Closed;

    emit Closed();

    wallet.transfer(address(this).balance);

  }



  function enableRefunds() onlyOwner public {

    require(state == State.Active);

    state = State.Refunding;

    emit RefundsEnabled();

  }



  /**

   * @param investor Investor address

   */

  function refund(address investor) public {

    require(state == State.Refunding);

    uint256 depositedValue = deposited[investor];

    deposited[investor] = 0;

    investor.transfer(depositedValue);

    emit Refunded(investor, depositedValue);

  }

}



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol



/**

 * @title RefundableCrowdsale

 * @dev Extension of Crowdsale contract that adds a funding goal, and

 * the possibility of users getting a refund if goal is not met.

 * Uses a RefundVault as the crowdsale's vault.

 */

contract RefundableCrowdsale is FinalizableCrowdsale {

  using SafeMath for uint256;



  // minimum amount of funds to be raised in weis

  uint256 public goal;



  // refund vault used to hold funds while crowdsale is running

  RefundVault public vault;



  /**

   * @dev Constructor, creates RefundVault.

   * @param _goal Funding goal

   */

  constructor(uint256 _goal) public {

    require(_goal > 0);

    vault = new RefundVault(wallet);

    goal = _goal;

  }



  /**

   * @dev Investors can claim refunds here if crowdsale is unsuccessful

   */

  function claimRefund() public {

    require(isFinalized);

    require(!goalReached());



    vault.refund(msg.sender);

  }



  /**

   * @dev Checks whether funding goal was reached.

   * @return Whether funding goal was reached

   */

  function goalReached() public view returns (bool) {

    return weiRaised >= goal;

  }



  /**

   * @dev vault finalization task, called when owner calls finalize()

   */

  function finalization() internal {

    if (goalReached()) {

      vault.close();

    } else {

      vault.enableRefunds();

    }



    super.finalization();

  }



  /**

   * @dev Overrides Crowdsale fund forwarding, sending funds to vault.

   */

  function _forwardFunds() internal {

    vault.deposit.value(msg.value)(msg.sender);

  }



}



// File: node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol



/**

 * @title PostDeliveryCrowdsale

 * @dev Crowdsale that locks tokens from withdrawal until it ends.

 */

contract PostDeliveryCrowdsale is TimedCrowdsale {

  using SafeMath for uint256;



  mapping(address => uint256) public balances;



  /**

   * @dev Withdraw tokens only after crowdsale ends.

   */

  function withdrawTokens() public {

    require(hasClosed());

    uint256 amount = balances[msg.sender];

    require(amount > 0);

    balances[msg.sender] = 0;

    _deliverTokens(msg.sender, amount);

  }



  /**

   * @dev Overrides parent by storing balances instead of issuing tokens right away.

   * @param _beneficiary Token purchaser

   * @param _tokenAmount Amount of tokens purchased

   */

  function _processPurchase(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);

  }



}



// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



// File: contracts/crowdsale/OraclizeContractInterface.sol



/**

 * @title OraclizeContractInterface

 * @dev OraclizeContractInterface

 **/

contract OraclizeContractInterface {

  function finalize() public;

  function buyTokensWithLTC(address _ethWallet, string _ltcWallet, uint256 _ltcAmount) public;

  function buyTokensWithBTC(address _ethWallet, string _btcWallet, uint256 _btcAmount) public;

  function buyTokensWithBNB(address _ethWallet, string _bnbWallet, uint256 _bnbAmount) public payable;

  function buyTokensWithBCH(address _ethWallet, string _bchWallet, uint256 _bchAmount) public payable;

  function getMultiCurrencyInvestorContribution(string _currencyWallet) public view returns(uint256);

}



// File: contracts/crowdsale/BurnableTokenInterface.sol



/**

 * @title BurnableTokenInterface, defining one single function to burn tokens.

 * @dev BurnableTokenInterface

 **/

contract BurnableTokenInterface {



  /**

  * @dev Burns a specific amount of tokens.

  * @param _value The amount of token to be burned.

  */

  function burn(uint256 _value) public;

}



// File: installed_contracts/oraclize-api/contracts/usingOraclize.sol



// <ORACLIZE_API>

/*

Copyright (c) 2015-2016 Oraclize SRL

Copyright (c) 2016 Oraclize LTD







Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:







The above copyright notice and this permission notice shall be included in

all copies or substantial portions of the Software.







THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

THE SOFTWARE.

*/



// This api is currently targeted at 0.4.18, please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary

pragma solidity ^0.4.18;



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);

}

contract OraclizeAddrResolverI {

    function getAddress() public returns (address _addr);

}

contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Android = 0x20;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_consensys = 161;



    OraclizeAddrResolverI OAR;



    OraclizeI oraclize;

    modifier oraclizeAPI {

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))

            oraclize_setNetwork(networkID_auto);



        if(address(oraclize) != OAR.getAddress())

            oraclize = OraclizeI(OAR.getAddress());



        _;

    }

    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

      return oraclize_setNetwork();

      networkID; // silence the warning and remain backwards compatible

    }

    function oraclize_setNetwork() internal returns(bool){

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 myid, string result) public {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) public {

      return;

      myid; result; proof; // Silence compiler warnings

    }



    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource);

    }



    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource, gaslimit);

    }



    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(0, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(timestamp, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(0, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_cbAddress() oraclizeAPI internal returns (address){

        return oraclize.cbAddress();

    }

    function oraclize_setProof(byte proofP) oraclizeAPI internal {

        return oraclize.setProofType(proofP);

    }

    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) constant internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal pure returns (address){

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i=2; i<2+2*20; i+=2){

            iaddr *= 256;

            b1 = uint160(tmp[i]);

            b2 = uint160(tmp[i+1]);

            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;

            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;

            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;

            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;

            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;

            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;

            iaddr += (b1*16+b2);

        }

        return address(iaddr);

    }



    function strCompare(string _a, string _b) internal pure returns (int) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) minLength = b.length;

        for (uint i = 0; i < minLength; i ++)

            if (a[i] < b[i])

                return -1;

            else if (a[i] > b[i])

                return 1;

        if (a.length < b.length)

            return -1;

        else if (a.length > b.length)

            return 1;

        else

            return 0;

    }



    function indexOf(string _haystack, string _needle) internal pure returns (int) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if(h.length < 1 || n.length < 1 || (n.length > h.length))

            return -1;

        else if(h.length > (2**128 -1))

            return -1;

        else

        {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i ++)

            {

                if (h[i] == n[0])

                {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])

                    {

                        subindex++;

                    }

                    if(subindex == n.length)

                        return int(i);

                }

            }

            return -1;

        }

    }



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);

    }



    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal pure returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal pure returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i=0; i<bresult.length; i++){

            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                if (decimals){

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(bresult[i]) - 48;

            } else if (bresult[i] == 46) decimals = true;

        }

        if (_b > 0) mint *= 10**_b;

        return mint;

    }



    function uint2str(uint i) internal pure returns (string){

        if (i == 0) return "0";

        uint j = i;

        uint len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }



    function stra2cbor(string[] arr) internal pure returns (bytes) {

            uint arrlen = arr.length;



            // get correct cbor output length

            uint outputlen = 0;

            bytes[] memory elemArray = new bytes[](arrlen);

            for (uint i = 0; i < arrlen; i++) {

                elemArray[i] = (bytes(arr[i]));

                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types

            }

            uint ctr = 0;

            uint cborlen = arrlen + 0x80;

            outputlen += byte(cborlen).length;

            bytes memory res = new bytes(outputlen);



            while (byte(cborlen).length > ctr) {

                res[ctr] = byte(cborlen)[ctr];

                ctr++;

            }

            for (i = 0; i < arrlen; i++) {

                res[ctr] = 0x5F;

                ctr++;

                for (uint x = 0; x < elemArray[i].length; x++) {

                    // if there's a bug with larger strings, this may be the culprit

                    if (x % 23 == 0) {

                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;

                        elemcborlen += 0x40;

                        uint lctr = ctr;

                        while (byte(elemcborlen).length > ctr - lctr) {

                            res[ctr] = byte(elemcborlen)[ctr - lctr];

                            ctr++;

                        }

                    }

                    res[ctr] = elemArray[i][x];

                    ctr++;

                }

                res[ctr] = 0xFF;

                ctr++;

            }

            return res;

        }



    function ba2cbor(bytes[] arr) internal pure returns (bytes) {

            uint arrlen = arr.length;



            // get correct cbor output length

            uint outputlen = 0;

            bytes[] memory elemArray = new bytes[](arrlen);

            for (uint i = 0; i < arrlen; i++) {

                elemArray[i] = (bytes(arr[i]));

                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types

            }

            uint ctr = 0;

            uint cborlen = arrlen + 0x80;

            outputlen += byte(cborlen).length;

            bytes memory res = new bytes(outputlen);



            while (byte(cborlen).length > ctr) {

                res[ctr] = byte(cborlen)[ctr];

                ctr++;

            }

            for (i = 0; i < arrlen; i++) {

                res[ctr] = 0x5F;

                ctr++;

                for (uint x = 0; x < elemArray[i].length; x++) {

                    // if there's a bug with larger strings, this may be the culprit

                    if (x % 23 == 0) {

                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;

                        elemcborlen += 0x40;

                        uint lctr = ctr;

                        while (byte(elemcborlen).length > ctr - lctr) {

                            res[ctr] = byte(elemcborlen)[ctr - lctr];

                            ctr++;

                        }

                    }

                    res[ctr] = elemArray[i][x];

                    ctr++;

                }

                res[ctr] = 0xFF;

                ctr++;

            }

            return res;

        }





    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string) {

        return oraclize_network_name;

    }



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        require((_nbytes > 0) && (_nbytes <= 32));

        // Convert from seconds to ledger timer ticks

        _delay *= 10; 

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes memory delay = new bytes(32);

        assembly { 

            mstore(add(delay, 0x20), _delay) 

        }

        

        bytes memory delay_bytes8 = new bytes(8);

        copyBytes(delay, 24, 8, delay_bytes8, 0);



        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];

        bytes32 queryId = oraclize_query("random", args, _customGasLimit);

        

        bytes memory delay_bytes8_left = new bytes(8);

        

        assembly {

            let x := mload(add(delay_bytes8, 0x20))

            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))



        }

        

        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));

        return queryId;

    }

    

    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {

        oraclize_randomDS_args[queryId] = commitment;

    }



    mapping(bytes32=>bytes32) oraclize_randomDS_args;

    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;



    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){

        bool sigok;

        address signer;



        bytes32 sigr;

        bytes32 sigs;



        bytes memory sigr_ = new bytes(32);

        uint offset = 4+(uint(dersig[3]) - 0x20);

        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);



        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }





        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);

        if (address(keccak256(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(keccak256(pubkey)) == signer);

        }

    }



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {

        bool sigok;



        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);

        copyBytes(proof, sig2offset, sig2.length, sig2, 0);



        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);



        bytes memory tosign2 = new bytes(1+65+32);

        tosign2[0] = byte(1); //role

        copyBytes(proof, sig2offset-65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);



        if (sigok == false) return false;





        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";



        bytes memory tosign3 = new bytes(1+65);

        tosign3[0] = 0xFE;

        copyBytes(proof, 3, 65, tosign3, 1);



        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);

        copyBytes(proof, 3+65, sig3.length, sig3, 0);



        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);



        return sigok;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);



        _;

    }



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;



        return 0;

    }



    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){

        bool match_ = true;

        

        require(prefix.length == n_random_bytes);



        for (uint256 i=0; i< n_random_bytes; i++) {

            if (content[i] != prefix[i]) match_ = false;

        }



        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){



        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;



        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);



        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;



        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);



        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);



        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;





        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;



        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }



        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {

        uint minLength = length + toOffset;



        // Buffer too small

        require(to.length >= minLength); // Should be a better way?



        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint i = 32 + fromOffset;

        uint j = 32 + toOffset;



        while (i < (32 + fromOffset + length)) {

            assembly {

                let tmp := mload(add(from, i))

                mstore(add(to, j), tmp)

            }

            i += 32;

            j += 32;

        }



        return to;

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    // Duplicate Solidity's ecrecover, but catching the CALL return value

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {

        // We do our own memory management here. Solidity uses memory offset

        // 0x40 to store the current end of memory. We write past it (as

        // writes are memory extensions), but don't update the offset so

        // Solidity will reuse it. The memory used here is only needed for

        // this context.



        // FIXME: inline assembly can't access return values

        bool ret;

        address addr;



        assembly {

            let size := mload(0x40)

            mstore(size, hash)

            mstore(add(size, 32), v)

            mstore(add(size, 64), r)

            mstore(add(size, 96), s)



            // NOTE: we can reuse the request memory because we deal with

            //       the return code

            ret := call(3000, 1, 0, size, 128, size, 32)

            addr := mload(size)

        }



        return (ret, addr);

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        if (sig.length != 65)

          return (false, 0);



        // The signature format is a compact form of:

        //   {bytes32 r}{bytes32 s}{uint8 v}

        // Compact means, uint8 is not padded to 32 bytes.

        assembly {

            r := mload(add(sig, 32))

            s := mload(add(sig, 64))



            // Here we are loading the last 32 bytes. We exploit the fact that

            // 'mload' will pad with zeroes if we overread.

            // There is no 'mload8' to do this, but that would be nicer.

            v := byte(0, mload(add(sig, 96)))



            // Alternative solution:

            // 'byte' is not working due to the Solidity parser, so lets

            // use the second best option, 'and'

            // v := and(mload(add(sig, 65)), 255)

        }



        // albeit non-transactional signatures are not specified by the YP, one would expect it

        // to match the YP range of [27, 28]

        //

        // geth uses [0, 1] and some clients have followed. This might change, see:

        //  https://github.com/ethereum/go-ethereum/issues/2053

        if (v < 27)

          v += 27;



        if (v != 27 && v != 28)

            return (false, 0);



        return safer_ecrecover(hash, v, r, s);

    }



}

// </ORACLIZE_API>



// File: contracts/crowdsale/FiatContractInterface.sol



/**

 * @title FiatContractInterface, defining one single function to get 0,01 $ price.

 * @dev FiatContractInterface

 **/

contract FiatContractInterface {

  function USD(uint _id) view public returns (uint256);

}



// File: contracts/utils/strings.sol



/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[email protected]>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */



pragma solidity ^0.4.14;



library strings {

    struct slice {

        uint _len;

        uint _ptr;

    }



    function memcpy(uint dest, uint src, uint len) private pure {

        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }

    }



    /*

     * @dev Returns a slice containing the entire string.

     * @param self The string to make a slice from.

     * @return A newly allocated slice containing the entire string.

     */

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;

        assembly {

            ptr := add(self, 0x20)

        }

        return slice(bytes(self).length, ptr);

    }



    /*

     * @dev Returns the length of a null-terminated bytes32 string.

     * @param self The value to find the length of.

     * @return The length of the string, from 0 to 32.

     */

    function len(bytes32 self) internal pure returns (uint) {

        uint ret;

        if (self == 0)

            return 0;

        if (self & 0xffffffffffffffffffffffffffffffff == 0) {

            ret += 16;

            self = bytes32(uint(self) / 0x100000000000000000000000000000000);

        }

        if (self & 0xffffffffffffffff == 0) {

            ret += 8;

            self = bytes32(uint(self) / 0x10000000000000000);

        }

        if (self & 0xffffffff == 0) {

            ret += 4;

            self = bytes32(uint(self) / 0x100000000);

        }

        if (self & 0xffff == 0) {

            ret += 2;

            self = bytes32(uint(self) / 0x10000);

        }

        if (self & 0xff == 0) {

            ret += 1;

        }

        return 32 - ret;

    }



    /*

     * @dev Returns a slice containing the entire bytes32, interpreted as a

     *      null-terminated utf-8 string.

     * @param self The bytes32 value to convert to a slice.

     * @return A new slice containing the value of the input argument up to the

     *         first null.

     */

    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {

        // Allocate space for `self` in memory, copy it there, and point ret at it

        assembly {

            let ptr := mload(0x40)

            mstore(0x40, add(ptr, 0x20))

            mstore(ptr, self)

            mstore(add(ret, 0x20), ptr)

        }

        ret._len = len(self);

    }



    /*

     * @dev Returns a new slice containing the same data as the current slice.

     * @param self The slice to copy.

     * @return A new slice containing the same data as `self`.

     */

    function copy(slice memory self) internal pure returns (slice memory) {

        return slice(self._len, self._ptr);

    }



    /*

     * @dev Copies a slice to a new string.

     * @param self The slice to copy.

     * @return A newly allocated string containing the slice's text.

     */

    function toString(slice memory self) internal pure returns (string memory) {

        string memory ret = new string(self._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        memcpy(retptr, self._ptr, self._len);

        return ret;

    }



    /*

     * @dev Returns the length in runes of the slice. Note that this operation

     *      takes time proportional to the length of the slice; avoid using it

     *      in loops, and call `slice.empty()` if you only need to know whether

     *      the slice is empty or not.

     * @param self The slice to operate on.

     * @return The length of the slice in runes.

     */

    function len(slice memory self) internal pure returns (uint l) {

        // Starting at ptr-31 means the LSB will be the byte we care about

        uint ptr = self._ptr - 31;

        uint end = ptr + self._len;

        for (l = 0; ptr < end; l++) {

            uint8 b;

            assembly { b := and(mload(ptr), 0xFF) }

            if (b < 0x80) {

                ptr += 1;

            } else if(b < 0xE0) {

                ptr += 2;

            } else if(b < 0xF0) {

                ptr += 3;

            } else if(b < 0xF8) {

                ptr += 4;

            } else if(b < 0xFC) {

                ptr += 5;

            } else {

                ptr += 6;

            }

        }

    }



    /*

     * @dev Returns true if the slice is empty (has a length of 0).

     * @param self The slice to operate on.

     * @return True if the slice is empty, False otherwise.

     */

    function empty(slice memory self) internal pure returns (bool) {

        return self._len == 0;

    }



    /*

     * @dev Returns a positive number if `other` comes lexicographically after

     *      `self`, a negative number if it comes before, or zero if the

     *      contents of the two slices are equal. Comparison is done per-rune,

     *      on unicode codepoints.

     * @param self The first slice to compare.

     * @param other The second slice to compare.

     * @return The result of the comparison.

     */

    function compare(slice memory self, slice memory other) internal pure returns (int) {

        uint shortest = self._len;

        if (other._len < self._len)

            shortest = other._len;



        uint selfptr = self._ptr;

        uint otherptr = other._ptr;

        for (uint idx = 0; idx < shortest; idx += 32) {

            uint a;

            uint b;

            assembly {

                a := mload(selfptr)

                b := mload(otherptr)

            }

            if (a != b) {

                // Mask out irrelevant bytes and check again

                uint256 mask = uint256(-1); // 0xffff...

                if(shortest < 32) {

                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);

                }

                uint256 diff = (a & mask) - (b & mask);

                if (diff != 0)

                    return int(diff);

            }

            selfptr += 32;

            otherptr += 32;

        }

        return int(self._len) - int(other._len);

    }



    /*

     * @dev Returns true if the two slices contain the same text.

     * @param self The first slice to compare.

     * @param self The second slice to compare.

     * @return True if the slices are equal, false otherwise.

     */

    function equals(slice memory self, slice memory other) internal pure returns (bool) {

        return compare(self, other) == 0;

    }



    /*

     * @dev Extracts the first rune in the slice into `rune`, advancing the

     *      slice to point to the next rune and returning `self`.

     * @param self The slice to operate on.

     * @param rune The slice that will contain the first rune.

     * @return `rune`.

     */

    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {

        rune._ptr = self._ptr;



        if (self._len == 0) {

            rune._len = 0;

            return rune;

        }



        uint l;

        uint b;

        // Load the first byte of the rune into the LSBs of b

        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }

        if (b < 0x80) {

            l = 1;

        } else if(b < 0xE0) {

            l = 2;

        } else if(b < 0xF0) {

            l = 3;

        } else {

            l = 4;

        }



        // Check for truncated codepoints

        if (l > self._len) {

            rune._len = self._len;

            self._ptr += self._len;

            self._len = 0;

            return rune;

        }



        self._ptr += l;

        self._len -= l;

        rune._len = l;

        return rune;

    }



    /*

     * @dev Returns the first rune in the slice, advancing the slice to point

     *      to the next rune.

     * @param self The slice to operate on.

     * @return A slice containing only the first rune from `self`.

     */

    function nextRune(slice memory self) internal pure returns (slice memory ret) {

        nextRune(self, ret);

    }



    /*

     * @dev Returns the number of the first codepoint in the slice.

     * @param self The slice to operate on.

     * @return The number of the first codepoint in the slice.

     */

    function ord(slice memory self) internal pure returns (uint ret) {

        if (self._len == 0) {

            return 0;

        }



        uint word;

        uint length;

        uint divisor = 2 ** 248;



        // Load the rune into the MSBs of b

        assembly { word:= mload(mload(add(self, 32))) }

        uint b = word / divisor;

        if (b < 0x80) {

            ret = b;

            length = 1;

        } else if(b < 0xE0) {

            ret = b & 0x1F;

            length = 2;

        } else if(b < 0xF0) {

            ret = b & 0x0F;

            length = 3;

        } else {

            ret = b & 0x07;

            length = 4;

        }



        // Check for truncated codepoints

        if (length > self._len) {

            return 0;

        }



        for (uint i = 1; i < length; i++) {

            divisor = divisor / 256;

            b = (word / divisor) & 0xFF;

            if (b & 0xC0 != 0x80) {

                // Invalid UTF-8 sequence

                return 0;

            }

            ret = (ret * 64) | (b & 0x3F);

        }



        return ret;

    }



    /*

     * @dev Returns the keccak-256 hash of the slice.

     * @param self The slice to hash.

     * @return The hash of the slice.

     */

    function keccak(slice memory self) internal pure returns (bytes32 ret) {

        assembly {

            ret := keccak256(mload(add(self, 32)), mload(self))

        }

    }



    /*

     * @dev Returns true if `self` starts with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        if (self._ptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let length := mload(needle)

            let selfptr := mload(add(self, 0x20))

            let needleptr := mload(add(needle, 0x20))

            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

        }

        return equal;

    }



    /*

     * @dev If `self` starts with `needle`, `needle` is removed from the

     *      beginning of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {

            return self;

        }



        bool equal = true;

        if (self._ptr != needle._ptr) {

            assembly {

                let length := mload(needle)

                let selfptr := mload(add(self, 0x20))

                let needleptr := mload(add(needle, 0x20))

                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

            }

        }



        if (equal) {

            self._len -= needle._len;

            self._ptr += needle._len;

        }



        return self;

    }



    /*

     * @dev Returns true if the slice ends with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        uint selfptr = self._ptr + self._len - needle._len;



        if (selfptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let length := mload(needle)

            let needleptr := mload(add(needle, 0x20))

            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

        }



        return equal;

    }



    /*

     * @dev If `self` ends with `needle`, `needle` is removed from the

     *      end of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {

            return self;

        }



        uint selfptr = self._ptr + self._len - needle._len;

        bool equal = true;

        if (selfptr != needle._ptr) {

            assembly {

                let length := mload(needle)

                let needleptr := mload(add(needle, 0x20))

                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

            }

        }



        if (equal) {

            self._len -= needle._len;

        }



        return self;

    }



    // Returns the memory address of the first byte of the first occurrence of

    // `needle` in `self`, or the first byte after `self` if not found.

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr = selfptr;

        uint idx;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));



                bytes32 needledata;

                assembly { needledata := and(mload(needleptr), mask) }



                uint end = selfptr + selflen - needlelen;

                bytes32 ptrdata;

                assembly { ptrdata := and(mload(ptr), mask) }



                while (ptrdata != needledata) {

                    if (ptr >= end)

                        return selfptr + selflen;

                    ptr++;

                    assembly { ptrdata := and(mload(ptr), mask) }

                }

                return ptr;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := keccak256(needleptr, needlelen) }



                for (idx = 0; idx <= selflen - needlelen; idx++) {

                    bytes32 testHash;

                    assembly { testHash := keccak256(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr;

                    ptr += 1;

                }

            }

        }

        return selfptr + selflen;

    }



    // Returns the memory address of the first byte after the last occurrence of

    // `needle` in `self`, or the address of `self` if not found.

    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));



                bytes32 needledata;

                assembly { needledata := and(mload(needleptr), mask) }



                ptr = selfptr + selflen - needlelen;

                bytes32 ptrdata;

                assembly { ptrdata := and(mload(ptr), mask) }



                while (ptrdata != needledata) {

                    if (ptr <= selfptr)

                        return selfptr;

                    ptr--;

                    assembly { ptrdata := and(mload(ptr), mask) }

                }

                return ptr + needlelen;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := keccak256(needleptr, needlelen) }

                ptr = selfptr + (selflen - needlelen);

                while (ptr >= selfptr) {

                    bytes32 testHash;

                    assembly { testHash := keccak256(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr + needlelen;

                    ptr -= 1;

                }

            }

        }

        return selfptr;

    }



    /*

     * @dev Modifies `self` to contain everything from the first occurrence of

     *      `needle` to the end of the slice. `self` is set to the empty slice

     *      if `needle` is not found.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len -= ptr - self._ptr;

        self._ptr = ptr;

        return self;

    }



    /*

     * @dev Modifies `self` to contain the part of the string from the start of

     *      `self` to the end of the first occurrence of `needle`. If `needle`

     *      is not found, `self` is set to the empty slice.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len = ptr - self._ptr;

        return self;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and `token` to everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = self._ptr;

        token._len = ptr - self._ptr;

        if (ptr == self._ptr + self._len) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

            self._ptr = ptr + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and returning everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` up to the first occurrence of `delim`.

     */

    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        split(self, needle, token);

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and `token` to everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = ptr;

        token._len = self._len - (ptr - self._ptr);

        if (ptr == self._ptr) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and returning everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` after the last occurrence of `delim`.

     */

    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        rsplit(self, needle, token);

    }



    /*

     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return The number of occurrences of `needle` found in `self`.

     */

    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;

        while (ptr <= self._ptr + self._len) {

            cnt++;

            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;

        }

    }



    /*

     * @dev Returns True if `self` contains `needle`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return True if `needle` is found in `self`, false otherwise.

     */

    function contains(slice memory self, slice memory needle) internal pure returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;

    }



    /*

     * @dev Returns a newly allocated string containing the concatenation of

     *      `self` and `other`.

     * @param self The first slice to concatenate.

     * @param other The second slice to concatenate.

     * @return The concatenation of the two strings.

     */

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);

        memcpy(retptr + self._len, other._ptr, other._len);

        return ret;

    }



    /*

     * @dev Joins an array of slices, using `self` as a delimiter, returning a

     *      newly allocated string.

     * @param self The delimiter to use.

     * @param parts A list of slices to join.

     * @return A newly allocated string containing all the slices in `parts`,

     *         joined with `self`.

     */

    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {

        if (parts.length == 0)

            return "";



        uint length = self._len * (parts.length - 1);

        for(uint i = 0; i < parts.length; i++)

            length += parts[i]._len;



        string memory ret = new string(length);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        for(i = 0; i < parts.length; i++) {

            memcpy(retptr, parts[i]._ptr, parts[i]._len);

            retptr += parts[i]._len;

            if (i < parts.length - 1) {

                memcpy(retptr, self._ptr, self._len);

                retptr += self._len;

            }

        }



        return ret;

    }

}



// File: contracts/crowdsale/MultiCurrencyRates.sol



/**

 * @title MultiCurrencyRates

 * @dev MultiCurrencyRates

 */

// solium-disable-next-line max-len

contract MultiCurrencyRates is usingOraclize, Ownable {

  using SafeMath for uint256;

  using strings for *;



  FiatContractInterface public fiatContract;



  /**

   * @param _fiatContract Address of fiatContract

   */



  constructor(address _fiatContract) public {

    require(_fiatContract != address(0));

    fiatContract = FiatContractInterface(_fiatContract);

  }



  /**

  * @dev Set fiat contract

  * @param _fiatContract Address of new fiatContract

  */

  function setFiatContract(address _fiatContract) public onlyOwner {

    fiatContract = FiatContractInterface(_fiatContract);

  }



  /**

  * @dev Returns the current 0.01$ => ETH wei rate

  */

  function getUSDCentToWeiRate() internal view returns (uint256) {

    return fiatContract.USD(0);

  }



  /**

  * @dev Returns the current 0.01$ => BTC satoshi rate

  */

  function getUSDCentToBTCSatoshiRate() internal view returns (uint256) {

    return fiatContract.USD(1);

  }



  /**

  * @dev Returns the current 0.01$ => LTC satoshi rate

  */

  function getUSDCentToLTCSatoshiRate() internal view returns (uint256) {

    return fiatContract.USD(2);

  }



  /**

  * @dev Returns the current BNB => 0.01$ rate

  */

  function getBNBToUSDCentRate(string oraclizeResult) internal pure returns (uint256) {

    return parseInt(parseCurrencyRate(oraclizeResult, "BNB"), 2);

  }



  /**

  * @dev Returns the current BCH => 0.01$ rate

  */

  function getBCHToUSDCentRate(string oraclizeResult) internal pure returns (uint256) {

    return parseInt(parseCurrencyRate(oraclizeResult, "BCH"), 2);

  }



  /**

   * @dev Parse currency rate from oraclize response

   * @param oraclizeResult Result from Oraclize with currencies prices

   * @param _currencyTicker Currency tiker

   * @return Currency price string in USD

   */

  function parseCurrencyRate(string oraclizeResult, string _currencyTicker) internal pure returns(string) {

    strings.slice memory response = oraclizeResult.toSlice();

    strings.slice memory needle = _currencyTicker.toSlice();

    strings.slice memory tickerPrice = response.find(needle).split("}".toSlice()).find(" ".toSlice()).rsplit(" ".toSlice());

    return tickerPrice.toString();

  }



}



// File: contracts/crowdsale/PhaseCrowdsaleInterface.sol



/**

 * @title PhaseCrowdsaleInterface

 * @dev PhaseCrowdsaleInterface

 */

contract PhaseCrowdsaleInterface {

     

  /**

  * @dev Get phase number depending on the current time

  */

  function getPhaseNumber() public view returns (uint256);



  /**

  * @dev Returns the current token price in $ cents depending on the current time

  */

  function getCurrentTokenPriceInCents() public view returns (uint256);



  /**

  * @dev Returns the token sale bonus percentage depending on the current time

  */

  function getCurrentBonusPercentage() public view returns (uint256);

}



// File: contracts/crowdsale/CryptonityCrowdsale.sol



/**

 * @title CryptonityCrowdsale

 * @dev CryptonityCrowdsale

 */

// solium-disable-next-line max-len

contract CryptonityCrowdsale is TimedCrowdsale, WhitelistedCrowdsale, RefundableCrowdsale, PostDeliveryCrowdsale, MultiCurrencyRates, Pausable {

  using SafeMath for uint256;

  OraclizeContractInterface public oraclizeContract;

  PhaseCrowdsaleInterface public phaseCrowdsale;

  // Public supply of token

  uint256 public publicSupply = 60000000 * 1 ether;

  // Remaining public supply of token for each phase

  uint256[3] public remainingPublicSupplyPerPhase = [15000000 * 1 ether, 26000000 * 1 ether, 19000000 * 1 ether];

  // When tokens will be available for withdraw

  uint256 public deliveryTime;

  // A limit for total contributions in USD cents

  uint256 public cap;

  // Is goal reached

  bool public isGoalReached = false;



  event LogInfo(string description);



  /**

   * @param _phasesTime Crowdsale phases time [openingTime, closingTime, secondPhaseStartTime, thirdPhaseStartTime]

   * @param _rate Number of token units a buyer gets per wei

   * @param _wallet Address where collected funds will be forwarded to

   * @param _token Address of the token being sold

   * @param _softCapUSDInCents Funding goal in USD cents

   * @param _hardCapUSDInCents Max amount of USD cents to be contributed

   * @param _fiatContract FiatContract

   * @param _phaseCrowdsale info about current phase

   * @param _oraclizeContract oraclize contract

   */

  constructor(

    uint256[4] _phasesTime,

    uint256 _rate,

    address _wallet,

    ERC20 _token,

    uint256 _softCapUSDInCents,

    uint256 _hardCapUSDInCents,

    address _fiatContract,

    address _phaseCrowdsale,

    address _oraclizeContract

  )

    public

    Crowdsale(_rate, _wallet, _token)

    RefundableCrowdsale(_softCapUSDInCents)

    TimedCrowdsale(_phasesTime[0], _phasesTime[1])

    MultiCurrencyRates(_fiatContract)

  {



    require(_phasesTime[2] >= _phasesTime[0]);

    require(_phasesTime[3] >= _phasesTime[2]);

    require(_phasesTime[1] >= _phasesTime[3]);

    require(_hardCapUSDInCents > 0);

    require(_softCapUSDInCents <= _hardCapUSDInCents);

    cap = _hardCapUSDInCents;

    // token delivery starts 15 days after the crowdsale ends

    deliveryTime = _phasesTime[1].add(15 days);

    oraclizeContract = OraclizeContractInterface(_oraclizeContract);

    phaseCrowdsale = PhaseCrowdsaleInterface(_phaseCrowdsale);



  }



  /**

   * @dev Reverts if crowdsale is not finalized

   */

  modifier whenFinalized {

    require(isFinalized);

    _;

  }



  /**

   * @dev Reverts if caller isn't oraclizeContract

   */

  modifier onlyOraclize {

    require(msg.sender == address(oraclizeContract));

    _;

  }



  /**

   * @dev Get multi currency investor contribution.

   * @param _currencyWallet Address of currency wallet

   * @return Amount of currency contribution

   */

  function getMultiCurrencyInvestorContribution(string _currencyWallet) public view returns(uint256) {

    return  oraclizeContract.getMultiCurrencyInvestorContribution(_currencyWallet);

  }



  /**

   * @dev Calculates the sum amount of tokens which were unsold or remaining during all crowdsale phases.

   * @return The total amount of unsold tokens

   */

  function calculateTotalRemainingPublicSupply() private view returns (uint256) {

    uint256 totalRemainingPublicSupply = 0;

    for (uint i = 0; i < remainingPublicSupplyPerPhase.length; i++) {

      totalRemainingPublicSupply = totalRemainingPublicSupply.add(remainingPublicSupplyPerPhase[i]);

    }

    return totalRemainingPublicSupply;

  }



  /**

   * @dev Validation of an incoming purchase. Allowas purchases only when crowdsale is not paused.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {

    super._preValidatePurchase(_beneficiary, _weiAmount);

    rate = uint256(1 ether).mul(1 ether).div(getUSDCentToWeiRate()).div(phaseCrowdsale.getCurrentTokenPriceInCents());

  }

  /**

   * @dev Executed by oraclize when a purchase has been validated and is ready to be executed.

   * It computes the bonus.

   * @param _beneficiary Address receiving the tokens

   * @param _tokenAmount Number of tokens to be purchased

   */

  function processPurchase(address _beneficiary, uint256 _tokenAmount) public onlyOraclize onlyWhileOpen isWhitelisted(_beneficiary) {

    _processPurchase(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

   * It computes the bonus.

   * @param _beneficiary Address receiving the tokens

   * @param _tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

    uint256 totalAmount = _tokenAmount;

    uint256 bonusPercent = phaseCrowdsale.getCurrentBonusPercentage();



    if (bonusPercent > 0) {

      uint256 bonusAmount = totalAmount.mul(bonusPercent).div(100); // tokens * bonus (%) / 100%

      totalAmount = totalAmount.add(bonusAmount);

    }

    uint256 phaseNumber = phaseCrowdsale.getPhaseNumber();

    require(remainingPublicSupplyPerPhase[phaseNumber] >= totalAmount);

    super._processPurchase(_beneficiary, totalAmount);

    remainingPublicSupplyPerPhase[phaseNumber] = remainingPublicSupplyPerPhase[phaseNumber].sub(totalAmount);

  }



  /**

  * @dev Withdraw tokens only after the deliveryTime

  */

  function withdrawTokens() public whenFinalized {

    require(isGoalReached);

    // solium-disable-next-line security/no-block-members

    require(now > deliveryTime);

    super.withdrawTokens();

  }



  /**

   * @dev Investors can claim refunds here if crowdsale is unsuccessful

   */

  function claimRefund() public whenFinalized {

    require(!isGoalReached);

    vault.refund(msg.sender);

  }



  /**

   * @dev Token purchase with LTC

   * @param _ethWallet Address receiving the tokens

   * @param _ltcWallet LTC address who paid for the tokens

   * @param _ltcAmount Value in LTC involved in the purchase

   */

  function buyTokensWithLTC(address _ethWallet, string _ltcWallet, uint256 _ltcAmount) public onlyOwner {

    oraclizeContract.buyTokensWithLTC(_ethWallet, _ltcWallet, _ltcAmount);

  }



  /**

   * @dev Token purchase with BTC

   * @param _ethWallet Address receiving the tokens

   * @param _btcWallet BTC address who paid for the tokens

   * @param _btcAmount Value in BTC involved in the purchase

   */

  function buyTokensWithBTC(address _ethWallet, string _btcWallet, uint256 _btcAmount) public onlyOwner {

    oraclizeContract.buyTokensWithBTC(_ethWallet, _btcWallet, _btcAmount);

  }



  /**

   * @dev Token purchase with BNB

   * @param _ethWallet Address receiving the tokens

   * @param _bnbWallet BNB address who paid for the tokens

   * @param _bnbAmount Value in BNB involved in the purchase

   */

  function buyTokensWithBNB(address _ethWallet, string _bnbWallet, uint256 _bnbAmount) public payable onlyOwner {

    oraclizeContract.buyTokensWithBNB.value(msg.value)(_ethWallet, _bnbWallet, _bnbAmount);

  }



  /**

   * @dev Token purchase with BCH

   * @param _ethWallet Address receiving the tokens

   * @param _bchWallet BCH address who paid for the tokens

   * @param _bchAmount Value in BCH involved in the purchase

   */

  function buyTokensWithBCH(address _ethWallet, string _bchWallet, uint256 _bchAmount) public payable onlyOwner {

    oraclizeContract.buyTokensWithBCH.value(msg.value)(_ethWallet, _bchWallet, _bchAmount);

  }



  /**

  * @dev The way in which ether is converted to tokens.

  * @param _weiAmount Value in wei to be converted into tokens

  * @return Number of tokens that can be purchased with the specified _weiAmount

  */

  function _getTokenAmount(uint256 _weiAmount)

    internal view returns (uint256)

  {

    return _weiAmount.mul(rate).div(1 ether); // divisor 10^18 to nullify multiplier from _calculateCurrentRate

  }



  /**

   * @dev Finalization logic.

   * Burn the remaining tokens.

   * Transfer token ownership to contract owner.

   */

  function finalization() internal {

    oraclizeContract.finalize();

  }



  /**

   * @dev Executed by oraclize when multicurrency finalization is calculated

   * @param _usdRaised usdCent reised with multicurrency

   */

  function finalizationCallback(uint256 _usdRaised) public onlyOraclize {

    uint256 usdRaised = weiRaised.div(getUSDCentToWeiRate()).add(_usdRaised);

    if(usdRaised >= goal) {

      emit LogInfo("Finalization completed");

      isGoalReached = true;

      vault.close();

    } else {

      emit LogInfo("Finalization failed");

      vault.enableRefunds();

    }

    uint256 totalRemainingPublicSupply = calculateTotalRemainingPublicSupply();

    if (totalRemainingPublicSupply > 0) {

      BurnableTokenInterface(address(token)).burn(totalRemainingPublicSupply);

      delete remainingPublicSupplyPerPhase;

    }

    Ownable(address(token)).transferOwnership(owner);

  }

}