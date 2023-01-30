/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.24;





/**

 * @title Log Various Error Types

 * @author Adam Lemmon <[email protected]>

 * @dev Inherit this contract and your may now log errors easily

 * To support various error types, params, etc.

 */

contract LoggingErrors {

  /**

  * Events

  */

  event LogErrorString(string errorString);



  /**

  * Error cases

  */



  /**

   * @dev Default error to simply log the error message and return

   * @param _errorMessage The error message to log

   * @return ALWAYS false

   */

  function error(string _errorMessage) internal returns(bool) {

    LogErrorString(_errorMessage);

    return false;

  }

}







/**

 * @title Wallet Connector

 * @dev Connect the wallet contract to the correct Wallet Logic version

 */

contract WalletConnector is LoggingErrors {

  /**

   * Storage

   */

  address public owner_;

  address public latestLogic_;

  uint256 public latestVersion_;

  mapping(uint256 => address) public logicVersions_;

  uint256 public birthBlock_;



  /**

   * Events

   */

  event LogLogicVersionAdded(uint256 version);

  event LogLogicVersionRemoved(uint256 version);



  /**

   * @dev Constructor to set the latest logic address

   * @param _latestVersion Latest version of the wallet logic

   * @param _latestLogic Latest address of the wallet logic contract

   */

  function WalletConnector (

    uint256 _latestVersion,

    address _latestLogic

  ) public {

    owner_ = msg.sender;

    latestLogic_ = _latestLogic;

    latestVersion_ = _latestVersion;

    logicVersions_[_latestVersion] = _latestLogic;

    birthBlock_ = block.number;

  }



  /**

   * Add a new version of the logic contract

   * @param _version The version to be associated with the new contract.

   * @param _logic New logic contract.

   * @return Success of the transaction.

   */

  function addLogicVersion (

    uint256 _version,

    address _logic

  ) external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner, WalletConnector.addLogicVersion()');



    if (logicVersions_[_version] != 0)

      return error('Version already exists, WalletConnector.addLogicVersion()');



    // Update latest if this is the latest version

    if (_version > latestVersion_) {

      latestLogic_ = _logic;

      latestVersion_ = _version;

    }



    logicVersions_[_version] = _logic;

    LogLogicVersionAdded(_version);



    return true;

  }



  /**

   * @dev Remove a version. Cannot remove the latest version.

   * @param  _version The version to remove.

   */

  function removeLogicVersion(uint256 _version) external {

    require(msg.sender == owner_);

    require(_version != latestVersion_);

    delete logicVersions_[_version];

    LogLogicVersionRemoved(_version);

  }



  /**

   * Constants

   */



  /**

   * Called from user wallets in order to upgrade their logic.

   * @param _version The version to upgrade to. NOTE pass in 0 to upgrade to latest.

   * @return The address of the logic contract to upgrade to.

   */

  function getLogic(uint256 _version)

    external

    constant

    returns(address)

  {

    if (_version == 0)

      return latestLogic_;

    else

      return logicVersions_[_version];

  }

}



/**

 * @title Wallet to hold and trade ERC20 tokens and ether

 * @author Adam Lemmon <[email protected]>

 * @dev User wallet to interact with the exchange.

 * all tokens and ether held in this wallet, 1 to 1 mapping to user EOAs.

 */

contract Wallet is LoggingErrors {

  /**

   * Storage

   */

  // Vars included in wallet logic "lib", the order must match between Wallet and Logic

  address public owner_;

  address public exchange_;

  mapping(address => uint256) public tokenBalances_;



  address public logic_; // storage location 0x3 loaded for delegatecalls so this var must remain at index 3

  uint256 public birthBlock_;



  // Address updated at deploy time

  WalletConnector private connector_ = WalletConnector(0x03d6e7b2f48120fd57a89ff0bbd56e9ec39af21c);



  /**

   * Events

   */

  event LogDeposit(address token, uint256 amount, uint256 balance);

  event LogWithdrawal(address token, uint256 amount, uint256 balance);



  /**

   * @dev Contract consturtor. Set user as owner and connector address.

   * @param _owner The address of the user's EOA, wallets created from the exchange

   * so must past in the owner address, msg.sender == exchange.

   */

  function Wallet(address _owner) public {

    owner_ = _owner;

    exchange_ = msg.sender;

    logic_ = connector_.latestLogic_();

    birthBlock_ = block.number;

  }



  /**

   * @dev Fallback - Only enable funds to be sent from the exchange.

   * Ensures balances will be consistent.

   */

  function () external payable {

    require(msg.sender == exchange_);

  }



  /**

  * External

  */



  /**

   * @dev Deposit ether into this wallet, default to address 0 for consistent token lookup.

   */

  function depositEther()

    external

    payable

  {

    require(logic_.delegatecall(bytes4(sha3('deposit(address,uint256)')), 0, msg.value));

  }



  /**

   * @dev Deposit any ERC20 token into this wallet.

   * @param _token The address of the existing token contract.

   * @param _amount The amount of tokens to deposit.

   * @return Bool if the deposit was successful.

   */

  function depositERC20Token (

    address _token,

    uint256 _amount

  ) external

    returns(bool)

  {

    // ether

    if (_token == 0)

      return error('Cannot deposit ether via depositERC20, Wallet.depositERC20Token()');



    require(logic_.delegatecall(bytes4(sha3('deposit(address,uint256)')), _token, _amount));

    return true;

  }



  /**

   * @dev The result of an order, update the balance of this wallet.

   * @param _token The address of the token balance to update.

   * @param _amount The amount to update the balance by.

   * @param _subtractionFlag If true then subtract the token amount else add.

   * @return Bool if the update was successful.

   */

  function updateBalance (

    address _token,

    uint256 _amount,

    bool _subtractionFlag

  ) external

    returns(bool)

  {

    assembly {

      calldatacopy(0x40, 0, calldatasize)

      delegatecall(gas, sload(0x3), 0x40, calldatasize, 0, 32)

      return(0, 32)

      pop

    }

  }



  /**

   * User may update to the latest version of the exchange contract.

   * Note that multiple versions are NOT supported at this time and therefore if a

   * user does not wish to update they will no longer be able to use the exchange.

   * @param _exchange The new exchange.

   * @return Success of this transaction.

   */

  function updateExchange(address _exchange)

    external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner_, Wallet.updateExchange()');



    // If subsequent messages are not sent from this address all orders will fail

    exchange_ = _exchange;



    return true;

  }



  /**

   * User may update to a new or older version of the logic contract.

   * @param _version The versin to update to.

   * @return Success of this transaction.

   */

  function updateLogic(uint256 _version)

    external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner_, Wallet.updateLogic()');



    address newVersion = connector_.getLogic(_version);



    // Invalid version as defined by connector

    if (newVersion == 0)

      return error('Invalid version, Wallet.updateLogic()');



    logic_ = newVersion;

    return true;

  }



  /**

   * @dev Verify an order that the Exchange has received involving this wallet.

   * Internal checks and then authorize the exchange to move the tokens.

   * If sending ether will transfer to the exchange to broker the trade.

   * @param _token The address of the token contract being sold.

   * @param _amount The amount of tokens the order is for.

   * @param _fee The fee for the current trade.

   * @param _feeToken The token of which the fee is to be paid in.

   * @return If the order was verified or not.

   */

  function verifyOrder (

    address _token,

    uint256 _amount,

    uint256 _fee,

    address _feeToken

  ) external

    returns(bool)

  {

    assembly {

      calldatacopy(0x40, 0, calldatasize)

      delegatecall(gas, sload(0x3), 0x40, calldatasize, 0, 32)

      return(0, 32)

      pop

    }

  }



  /**

   * @dev Withdraw any token, including ether from this wallet to an EOA.

   * @param _token The address of the token to withdraw.

   * @param _amount The amount to withdraw.

   * @return Success of the withdrawal.

   */

  function withdraw(address _token, uint256 _amount)

    external

    returns(bool)

  {

    if(msg.sender != owner_)

      return error('msg.sender != owner, Wallet.withdraw()');



    assembly {

      calldatacopy(0x40, 0, calldatasize)

      delegatecall(gas, sload(0x3), 0x40, calldatasize, 0, 32)

      return(0, 32)

      pop

    }

  }



  /**

   * Constants

   */



  /**

   * @dev Get the balance for a specific token.

   * @param _token The address of the token contract to retrieve the balance of.

   * @return The current balance within this contract.

   */

  function balanceOf(address _token)

    public

    constant

    returns(uint)

  {

    return tokenBalances_[_token];

  }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}





contract Token {

  /// @return total amount of tokens

  function totalSupply() constant returns (uint256 supply) {}



  /// @param _owner The address from which the balance will be retrieved

  /// @return The balance

  function balanceOf(address _owner) constant returns (uint256 balance) {}



  /// @notice send `_value` token to `_to` from `msg.sender`

  /// @param _to The address of the recipient

  /// @param _value The amount of token to be transferred

  /// @return Whether the transfer was successful or not

  function transfer(address _to, uint256 _value) returns (bool success) {}



  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

  /// @param _from The address of the sender

  /// @param _to The address of the recipient

  /// @param _value The amount of token to be transferred

  /// @return Whether the transfer was successful or not

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}



  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens

  /// @param _spender The address of the account able to transfer the tokens

  /// @param _value The amount of wei to be approved for transfer

  /// @return Whether the approval was successful or not

  function approve(address _spender, uint256 _value) returns (bool success) {}



  /// @param _owner The address of the account owning tokens

  /// @param _spender The address of the account able to transfer the tokens

  /// @return Amount of remaining tokens allowed to spent

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}



  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);



  uint public decimals;

  string public name;

}





/**

 * @title Decentralized exchange for ether and ERC20 tokens.

 * @author Adam Lemmon <[email protected]>

 * @dev All trades brokered by this contract.

 * Orders submitted by off chain order book and this contract handles

 * verification and execution of orders.

 * All value between parties is transferred via this exchange.

 * Methods arranged by visibility; external, public, internal, private and alphabatized within.

 */

contract Exchange is LoggingErrors {



  using SafeMath for uint256;



  /**

   * Data Structures

   */

  struct Order {

    bool active_;  // True: active, False: filled or cancelled

    address offerToken_;

    uint256 offerTokenTotal_;

    uint256 offerTokenRemaining_;  // Amount left to give

    address wantToken_;

    uint256 wantTokenTotal_;

    uint256 wantTokenReceived_;  // Amount received, note this may exceed want total

  }



  /**

   * Storage

   */

  address private orderBookAccount_;

  address private owner_;

  uint256 public minOrderEthAmount_;

  uint256 public birthBlock_;

  address public edoToken_;

  uint256 public edoPerWei_;

  uint256 public edoPerWeiDecimals_;

  address public eidooWallet_;

  mapping(bytes32 => Order) public orders_; // Map order hashes to order data struct

  mapping(address => address) public userAccountToWallet_; // User EOA to wallet addresses



  /**

   * Events

   */

  event LogEdoRateSet(uint256 rate);

  event LogOrderExecutionSuccess();

  event LogOrderFilled(bytes32 indexed orderId, uint256 fillAmount, uint256 fillRemaining);

  event LogUserAdded(address indexed user, address walletAddress);

  event LogWalletDeposit(address indexed walletAddress, address token, uint256 amount, uint256 balance);

  event LogWalletWithdrawal(address indexed walletAddress, address token, uint256 amount, uint256 balance);



  /**

   * @dev Contract constructor - CONFIRM matches contract name.  Set owner and addr of order book.

   * @param _bookAccount The EOA address for the order book, will submit ALL orders.

   * @param _minOrderEthAmount Minimum amount of ether that each order must contain.

   * @param _edoToken Deployed edo token.

   * @param _edoPerWei Rate of edo tokens per wei.

   * @param _edoPerWeiDecimals Decimlas carried in edo rate.

   * @param _eidooWallet Wallet to pay fees to.

   */

  function Exchange(

    address _bookAccount,

    uint256 _minOrderEthAmount,

    address _edoToken,

    uint256 _edoPerWei,

    uint256 _edoPerWeiDecimals,

    address _eidooWallet

  ) public {

    orderBookAccount_ = _bookAccount;

    minOrderEthAmount_ = _minOrderEthAmount;

    owner_ = msg.sender;

    birthBlock_ = block.number;

    edoToken_ = _edoToken;

    edoPerWei_ = _edoPerWei;

    edoPerWeiDecimals_ = _edoPerWeiDecimals;

    eidooWallet_ = _eidooWallet;

  }



  /**

   * @dev Fallback. wallets utilize to send ether in order to broker trade.

   */

  function () external payable { }



  /**

   * External

   */



  /**

   * @dev Add a new user to the exchange, create a wallet for them.

   * Map their account address to the wallet contract for lookup.

   * @param _userAccount The address of the user's EOA.

   * @return Success of the transaction, false if error condition met.

   */

  function addNewUser(address _userAccount)

    external

    returns (bool)

  {

    if (userAccountToWallet_[_userAccount] != address(0))

      return error('User already exists, Exchange.addNewUser()');



    // Pass the userAccount address to wallet constructor so owner is not the exchange contract

    address userWallet = new Wallet(_userAccount);



    userAccountToWallet_[_userAccount] = userWallet;



    LogUserAdded(_userAccount, userWallet);



    return true;

  }



  /**

   * Execute orders in batches.

   * @param  _token_and_EOA_Addresses Tokan and user addresses.

   * @param  _amountsExpirationAndSalt Offer and want token amount and expiration and salt values.

   * @param _sig_v All order signature v values.

   * @param _sig_r_and_s All order signature r and r values.

   * @return The success of this transaction.

   */

  function batchExecuteOrder(

    address[4][] _token_and_EOA_Addresses,

    uint256[8][] _amountsExpirationAndSalt, // Packing to save stack size

    uint8[2][] _sig_v,

    bytes32[4][] _sig_r_and_s

  ) external

    returns(bool)

  {

    for (uint256 i = 0; i < _amountsExpirationAndSalt.length; i++) {

      require(executeOrder(

        _token_and_EOA_Addresses[i],

        _amountsExpirationAndSalt[i],

        _sig_v[i],

        _sig_r_and_s[i]

      ));

    }



    return true;

  }



  /**

   * @dev Execute an order that was submitted by the external order book server.

   * The order book server believes it to be a match.

   * There are components for both orders, maker and taker, 2 signatures as well.

   * @param _token_and_EOA_Addresses The addresses of the maker and taker EOAs and offered token contracts.

   * [makerEOA, makerOfferToken, takerEOA, takerOfferToken]

   * @param _amountsExpirationAndSalt The amount of tokens, [makerOffer, makerWant, takerOffer, takerWant].

   * and the block number at which this order expires

   * and a random number to mitigate replay. [makerExpiry, makerSalt, takerExpiry, takerSalt]

   * @param _sig_v ECDSA signature parameter v, maker 0 and taker 1.

   * @param _sig_r_and_s ECDSA signature parameters r ans s, maker 0, 1 and taker 2, 3.

   * @return Success of the transaction, false if error condition met.

   * Like types grouped to eliminate stack depth error

   */

  function executeOrder (

    address[4] _token_and_EOA_Addresses,

    uint256[8] _amountsExpirationAndSalt, // Packing to save stack size

    uint8[2] _sig_v,

    bytes32[4] _sig_r_and_s

  ) public

    returns(bool)

  {

    // Only read wallet addresses from storage once

    // Need one more stack slot so squashing into array

    Wallet[2] memory wallets = [

      Wallet(userAccountToWallet_[_token_and_EOA_Addresses[0]]), // maker

      Wallet(userAccountToWallet_[_token_and_EOA_Addresses[2]]) // taker

    ];



    // Basic pre-conditions, return if any input data is invalid

    if(!__executeOrderInputIsValid__(

      _token_and_EOA_Addresses,

      _amountsExpirationAndSalt,

      wallets[0],

      wallets[1]

    ))

      return error('Input is invalid, Exchange.executeOrder()');



    // Verify Maker and Taker signatures

    bytes32 makerOrderHash;

    bytes32 takerOrderHash;

    (makerOrderHash, takerOrderHash) = __generateOrderHashes__(_token_and_EOA_Addresses, _amountsExpirationAndSalt);



    if (!__signatureIsValid__(

      _token_and_EOA_Addresses[0],

      makerOrderHash,

      _sig_v[0],

      _sig_r_and_s[0],

      _sig_r_and_s[1]

    ))

      return error('Maker signature is invalid, Exchange.executeOrder()');



    if (!__signatureIsValid__(

      _token_and_EOA_Addresses[2],

      takerOrderHash,

      _sig_v[1],

      _sig_r_and_s[2],

      _sig_r_and_s[3]

    ))

      return error('Taker signature is invalid, Exchange.executeOrder()');



    // Exchange Order Verification and matching.

    Order memory makerOrder = orders_[makerOrderHash];

    Order memory takerOrder = orders_[takerOrderHash];



    if (makerOrder.wantTokenTotal_ == 0) {  // Check for existence

      makerOrder.active_ = true;

      makerOrder.offerToken_ = _token_and_EOA_Addresses[1];

      makerOrder.offerTokenTotal_ = _amountsExpirationAndSalt[0];

      makerOrder.offerTokenRemaining_ = _amountsExpirationAndSalt[0]; // Amount to give

      makerOrder.wantToken_ = _token_and_EOA_Addresses[3];

      makerOrder.wantTokenTotal_ = _amountsExpirationAndSalt[1];

      makerOrder.wantTokenReceived_ = 0; // Amount received

    }



    if (takerOrder.wantTokenTotal_ == 0) {  // Check for existence

      takerOrder.active_ = true;

      takerOrder.offerToken_ = _token_and_EOA_Addresses[3];

      takerOrder.offerTokenTotal_ = _amountsExpirationAndSalt[2];

      takerOrder.offerTokenRemaining_ = _amountsExpirationAndSalt[2];  // Amount to give

      takerOrder.wantToken_ = _token_and_EOA_Addresses[1];

      takerOrder.wantTokenTotal_ = _amountsExpirationAndSalt[3];

      takerOrder.wantTokenReceived_ = 0; // Amount received

    }



    if (!__ordersMatch_and_AreVaild__(makerOrder, takerOrder))

      return error('Orders do not match, Exchange.executeOrder()');



    // Trade amounts

    uint256 toTakerAmount;

    uint256 toMakerAmount;

    (toTakerAmount, toMakerAmount) = __getTradeAmounts__(makerOrder, takerOrder);



    // TODO consider removing. Can this condition be met?

    if (toTakerAmount < 1 || toMakerAmount < 1)

      return error('Token amount < 1, price ratio is invalid! Token value < 1, Exchange.executeOrder()');



    // Taker is offering edo tokens so ensure sufficient balance in order to offer edo and pay fee in edo

    if (

        takerOrder.offerToken_ == edoToken_ &&

        Token(edoToken_).balanceOf(wallets[1]) < __calculateFee__(makerOrder, toTakerAmount, toMakerAmount).add(toMakerAmount)

      ) {

        return error('Taker has an insufficient EDO token balance to cover the fee AND the offer, Exchange.executeOrder()');

    // Taker has sufficent EDO token balance to pay the fee

    } else if (Token(edoToken_).balanceOf(wallets[1]) < __calculateFee__(makerOrder, toTakerAmount, toMakerAmount))

      return error('Taker has an insufficient EDO token balance to cover the fee, Exchange.executeOrder()');



    // Wallet Order Verification, reach out to the maker and taker wallets.

    if (!__ordersVerifiedByWallets__(

        _token_and_EOA_Addresses,

        toMakerAmount,

        toTakerAmount,

        wallets[0],

        wallets[1],

        __calculateFee__(makerOrder, toTakerAmount, toMakerAmount)

      ))

      return error('Order could not be verified by wallets, Exchange.executeOrder()');



    // Order Execution, Order Fully Verified by this point, time to execute!

    // Local order structs

    __updateOrders__(makerOrder, takerOrder, toTakerAmount, toMakerAmount);



    // Write to storage then external calls

    //  Update orders active flag if filled

    if (makerOrder.offerTokenRemaining_ == 0)

      makerOrder.active_ = false;



    if (takerOrder.offerTokenRemaining_ == 0)

      takerOrder.active_ = false;



    // Finally write orders to storage

    orders_[makerOrderHash] = makerOrder;

    orders_[takerOrderHash] = takerOrder;



    // Transfer the external value, ether <> tokens

    require(

      __executeTokenTransfer__(

        _token_and_EOA_Addresses,

        toTakerAmount,

        toMakerAmount,

        __calculateFee__(makerOrder, toTakerAmount, toMakerAmount),

        wallets[0],

        wallets[1]

      )

    );



    // Log the order id(hash), amount of offer given, amount of offer remaining

    LogOrderFilled(makerOrderHash, toTakerAmount, makerOrder.offerTokenRemaining_);

    LogOrderFilled(takerOrderHash, toMakerAmount, takerOrder.offerTokenRemaining_);



    LogOrderExecutionSuccess();



    return true;

  }



  /**

   * @dev Set the rate of wei per edo token in or to calculate edo fee

   * @param _edoPerWei Rate of edo tokens per wei.

   * @return Success of the transaction.

   */

  function setEdoRate(

    uint256 _edoPerWei

  ) external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner, Exchange.setEdoRate()');



    edoPerWei_ = _edoPerWei;



    LogEdoRateSet(edoPerWei_);



    return true;

  }



  /**

   * @dev Set the wallet for fees to be paid to.

   * @param _eidooWallet Wallet to pay fees to.

   * @return Success of the transaction.

   */

  function setEidooWallet(

    address _eidooWallet

  ) external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner, Exchange.setEidooWallet()');



    eidooWallet_ = _eidooWallet;



    return true;

  }



  /**

   * @dev Set the minimum amount of ether required per order.

   * @param _minOrderEthAmount Min amount of ether required per order.

   * @return Success of the transaction.

   */

  function setMinOrderEthAmount (

    uint256 _minOrderEthAmount

  ) external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner, Exchange.setMinOrderEtherAmount()');



    minOrderEthAmount_ = _minOrderEthAmount;



    return true;

  }



  /**

   * @dev Set a new order book account.

   * @param _account The new order book account.

   */

  function setOrderBookAcount (

    address _account

  ) external

    returns(bool)

  {

    if (msg.sender != owner_)

      return error('msg.sender != owner, Exchange.setOrderBookAcount()');



    orderBookAccount_ = _account;

    return true;

  }



  /*

   Methods to catch events from external contracts, user wallets primarily

   */



  /**

   * @dev Simply log the event to track wallet interaction off-chain

   * @param _token The address of the token that was deposited.

   * @param _amount The amount of the token that was deposited.

   * @param _walletBalance The updated balance of the wallet after deposit.

   */

  function walletDeposit(

    address _token,

    uint256 _amount,

    uint256 _walletBalance

  ) external

  {

    LogWalletDeposit(msg.sender, _token, _amount, _walletBalance);

  }



  /**

   * @dev Simply log the event to track wallet interaction off-chain

   * @param _token The address of the token that was deposited.

   * @param _amount The amount of the token that was deposited.

   * @param _walletBalance The updated balance of the wallet after deposit.

   */

  function walletWithdrawal(

    address _token,

    uint256 _amount,

    uint256 _walletBalance

  ) external

  {

    LogWalletWithdrawal(msg.sender, _token, _amount, _walletBalance);

  }



  /**

   * Private

   */



  /**

   * Calculate the fee for the given trade. Calculated as the set % of the wei amount

   * converted into EDO tokens using the manually set conversion ratio.

   * @param _makerOrder The maker order object.

   * @param _toTaker The amount of tokens going to the taker.

   * @param _toMaker The amount of tokens going to the maker.

   * @return The total fee to be paid in EDO tokens.

   */

  function __calculateFee__(

    Order _makerOrder,

    uint256 _toTaker,

    uint256 _toMaker

  ) private

    constant

    returns(uint256)

  {

    // weiAmount * (fee %) * (EDO/Wei) / (decimals in edo/wei) / (decimals in percentage)

    if (_makerOrder.offerToken_ == address(0)) {

      return _toTaker.mul(edoPerWei_).div(10**edoPerWeiDecimals_);

    } else {

      return _toMaker.mul(edoPerWei_).div(10**edoPerWeiDecimals_);

    }

  }



  /**

   * @dev Verify the input to order execution is valid.

   * @param _token_and_EOA_Addresses The addresses of the maker and taker EOAs and offered token contracts.

   * [makerEOA, makerOfferToken, takerEOA, takerOfferToken]

   * @param _amountsExpirationAndSalt The amount of tokens, [makerOffer, makerWant, takerOffer, takerWant].

   * as well as The block number at which this order expires, maker[4] and taker[6].

   * @return Success if all checks pass.

   */

  function __executeOrderInputIsValid__(

    address[4] _token_and_EOA_Addresses,

    uint256[8] _amountsExpirationAndSalt,

    address _makerWallet,

    address _takerWallet

  ) private

    constant

    returns(bool)

  {

    if (msg.sender != orderBookAccount_)

      return error('msg.sender != orderBookAccount, Exchange.__executeOrderInputIsValid__()');



    if (block.number > _amountsExpirationAndSalt[4])

      return error('Maker order has expired, Exchange.__executeOrderInputIsValid__()');



    if (block.number > _amountsExpirationAndSalt[6])

      return error('Taker order has expired, Exchange.__executeOrderInputIsValid__()');



    // Wallets

    if (_makerWallet == address(0))

      return error('Maker wallet does not exist, Exchange.__executeOrderInputIsValid__()');



    if (_takerWallet == address(0))

      return error('Taker wallet does not exist, Exchange.__executeOrderInputIsValid__()');



    // Tokens, addresses and amounts, ether exists

    if (_token_and_EOA_Addresses[1] != address(0) && _token_and_EOA_Addresses[3] != address(0))

      return error('Ether omitted! Is not offered by either the Taker or Maker, Exchange.__executeOrderInputIsValid__()');



    if (_token_and_EOA_Addresses[1] == address(0) && _token_and_EOA_Addresses[3] == address(0))

      return error('Taker and Maker offer token are both ether, Exchange.__executeOrderInputIsValid__()');



    if (

        _amountsExpirationAndSalt[0] == 0 ||

        _amountsExpirationAndSalt[1] == 0 ||

        _amountsExpirationAndSalt[2] == 0 ||

        _amountsExpirationAndSalt[3] == 0

      )

      return error('May not execute an order where token amount == 0, Exchange.__executeOrderInputIsValid__()');



    // Confirm order ether amount >= min amount

    // Maker

    uint256 minOrderEthAmount = minOrderEthAmount_; // Single storage read

    if (_token_and_EOA_Addresses[1] == 0 && _amountsExpirationAndSalt[0] < minOrderEthAmount)

      return error('Maker order does not meet the minOrderEthAmount_ of ether, Exchange.__executeOrderInputIsValid__()');



    // Taker

    if (_token_and_EOA_Addresses[3] == 0 && _amountsExpirationAndSalt[2] < minOrderEthAmount)

      return error('Taker order does not meet the minOrderEthAmount_ of ether, Exchange.__executeOrderInputIsValid__()');



    return true;

  }



  /**

   * @dev Execute the external transfer of tokens.

   * @param _token_and_EOA_Addresses The addresses of the maker and taker EOAs and offered token contracts.

   * [makerEOA, makerOfferToken, takerEOA, takerOfferToken]

   * @param _toTakerAmount The amount of tokens to transfer to the taker.

   * @param _toMakerAmount The amount of tokens to transfer to the maker.

   * @return Success if both wallets verify the order.

   */

  function __executeTokenTransfer__(

    address[4] _token_and_EOA_Addresses,

    uint256 _toTakerAmount,

    uint256 _toMakerAmount,

    uint256 _fee,

    Wallet _makerWallet,

    Wallet _takerWallet

  ) private

    returns (bool)

  {

    // Wallet mapping balances

    address makerOfferToken = _token_and_EOA_Addresses[1];

    address takerOfferToken = _token_and_EOA_Addresses[3];



    // Taker to pay fee before trading

    require(_takerWallet.updateBalance(edoToken_, _fee, true));  // Subtraction flag

    require(Token(edoToken_).transferFrom(_takerWallet, eidooWallet_, _fee));



    // Move the toTakerAmount from the maker to the taker

    require(_makerWallet.updateBalance(makerOfferToken, _toTakerAmount, true));  // Subtraction flag

      /*return error('Unable to subtract maker token from maker wallet, Exchange.__executeTokenTransfer__()');*/



    require(_takerWallet.updateBalance(makerOfferToken, _toTakerAmount, false));

      /*return error('Unable to add maker token to taker wallet, Exchange.__executeTokenTransfer__()');*/



    // Move the toMakerAmount from the taker to the maker

    require(_takerWallet.updateBalance(takerOfferToken, _toMakerAmount, true));  // Subtraction flag

      /*return error('Unable to subtract taker token from taker wallet, Exchange.__executeTokenTransfer__()');*/



    require(_makerWallet.updateBalance(takerOfferToken, _toMakerAmount, false));

      /*return error('Unable to add taker token to maker wallet, Exchange.__executeTokenTransfer__()');*/



    // Contract ether balances and token contract balances

    // Ether to the taker and tokens to the maker

    if (makerOfferToken == address(0)) {

      _takerWallet.transfer(_toTakerAmount);

      require(

        Token(takerOfferToken).transferFrom(_takerWallet, _makerWallet, _toMakerAmount)

      );

      assert(

        __tokenAndWalletBalancesMatch__(_makerWallet, _takerWallet, takerOfferToken)

      );



    // Ether to the maker and tokens to the taker

    } else if (takerOfferToken == address(0)) {

      _makerWallet.transfer(_toMakerAmount);

      require(

        Token(makerOfferToken).transferFrom(_makerWallet, _takerWallet, _toTakerAmount)

      );

      assert(

        __tokenAndWalletBalancesMatch__(_makerWallet, _takerWallet, makerOfferToken)

      );



    // Something went wrong one had to have been ether

    } else revert();



    return true;

  }



  /**

   * @dev compute the log10 of a given number, takes the floor, ie. 2.5 = 2

   * @param _number The number to compute the log 10 of.

   * @return The floored log 10.

   */

  function __flooredLog10__(uint _number)

    public

    constant

    returns (uint256)

  {

    uint unit = 0;

    while (_number / (10**unit) >= 10)

      unit++;

    return unit;

  }



  /**

   * @dev Calculates Keccak-256 hash of order with specified parameters.

   * @param _token_and_EOA_Addresses The addresses of the order, [makerEOA, makerOfferToken, makerWantToken].

   * @param _amountsExpirationAndSalt The amount of tokens as well as

   * the block number at which this order expires and random salt number.

   * @return Keccak-256 hash of each order.

   */

  function __generateOrderHashes__(

    address[4] _token_and_EOA_Addresses,

    uint256[8] _amountsExpirationAndSalt

  ) private

    constant

    returns (bytes32, bytes32)

  {

    bytes32 makerOrderHash = keccak256(

      address(this),

      _token_and_EOA_Addresses[0], // _makerEOA

      _token_and_EOA_Addresses[1], // offerToken

      _amountsExpirationAndSalt[0],  // offerTokenAmount

      _token_and_EOA_Addresses[3], // wantToken

      _amountsExpirationAndSalt[1],  // wantTokenAmount

      _amountsExpirationAndSalt[4], // expiry

      _amountsExpirationAndSalt[5] // salt

    );





    bytes32 takerOrderHash = keccak256(

      address(this),

      _token_and_EOA_Addresses[2], // _makerEOA

      _token_and_EOA_Addresses[3], // offerToken

      _amountsExpirationAndSalt[2],  // offerTokenAmount

      _token_and_EOA_Addresses[1], // wantToken

      _amountsExpirationAndSalt[3],  // wantTokenAmount

      _amountsExpirationAndSalt[6], // expiry

      _amountsExpirationAndSalt[7] // salt

    );



    return (makerOrderHash, takerOrderHash);

  }



  /**

   * @dev Returns the price ratio for this order.

   * The ratio is calculated with the largest value as the numerator, this aids

   * to significantly reduce rounding errors.

   * @param _makerOrder The maker order data structure.

   * @return The ratio to `_decimals` decimal places.

   */

  function __getOrderPriceRatio__(Order _makerOrder, uint256 _decimals)

    private

    constant

    returns (uint256 orderPriceRatio)

  {

    if (_makerOrder.offerTokenTotal_ >= _makerOrder.wantTokenTotal_) {

      orderPriceRatio = _makerOrder.offerTokenTotal_.mul(10**_decimals).div(_makerOrder.wantTokenTotal_);

    } else {

      orderPriceRatio = _makerOrder.wantTokenTotal_.mul(10**_decimals).div(_makerOrder.offerTokenTotal_);

    }

  }



  /**

   * @dev Compute the tradeable amounts of the two verified orders.

   * Token amount is the min remaining between want and offer of the two orders that isn't ether.

   * Ether amount is then: etherAmount = tokenAmount * priceRatio, as ratio = eth / token.

   * @param _makerOrder The maker order data structure.

   * @param _takerOrder The taker order data structure.

   * @return The amount moving from makerOfferRemaining to takerWantRemaining and vice versa.

   * TODO: consider rounding errors, etc

   */

  function __getTradeAmounts__(

    Order _makerOrder,

    Order _takerOrder

  ) private

    constant

    returns (uint256 toTakerAmount, uint256 toMakerAmount)

  {

    bool ratioIsWeiPerTok = __ratioIsWeiPerTok__(_makerOrder);

    uint256 decimals = __flooredLog10__(__max__(_makerOrder.offerTokenTotal_, _makerOrder.wantTokenTotal_)) + 1;

    uint256 priceRatio = __getOrderPriceRatio__(_makerOrder, decimals);



    // Amount left for order to receive

    uint256 makerAmountLeftToReceive = _makerOrder.wantTokenTotal_.sub(_makerOrder.wantTokenReceived_);

    uint256 takerAmountLeftToReceive = _takerOrder.wantTokenTotal_.sub(_takerOrder.wantTokenReceived_);



    // wei/tok and taker receiving wei or tok/wei and taker receiving tok

    if (

        ratioIsWeiPerTok && _takerOrder.wantToken_ == address(0) ||

        !ratioIsWeiPerTok && _takerOrder.wantToken_ != address(0)

    ) {

      // In the case that the maker is offering more than the taker wants for the same quantity being offered

      // For example: maker offer 20 wei for 10 tokens but taker offers 10 tokens for 10 wei

      // Taker receives 20 wei for the 10 tokens, both orders filled

      if (

        _makerOrder.offerTokenRemaining_ > takerAmountLeftToReceive &&

        makerAmountLeftToReceive <= _takerOrder.offerTokenRemaining_

      ) {

        toTakerAmount = __max__(_makerOrder.offerTokenRemaining_, takerAmountLeftToReceive);

      } else {

        toTakerAmount = __min__(_makerOrder.offerTokenRemaining_, takerAmountLeftToReceive);

      }



      toMakerAmount = toTakerAmount.mul(10**decimals).div(priceRatio);



    // wei/tok and maker receiving wei or tok/wei and maker receiving tok

    } else {

      toMakerAmount = __min__(_takerOrder.offerTokenRemaining_, makerAmountLeftToReceive);

      toTakerAmount = toMakerAmount.mul(10**decimals).div(priceRatio);

    }

  }



  /**

   * @dev Return the maximum of two uints

   * @param _a Uint 1

   * @param _b Uint 2

   * @return The grater value or a if equal

   */

  function __max__(uint256 _a, uint256 _b)

    private

    constant

    returns (uint256)

  {

    return _a < _b ? _b : _a;

  }



  /**

   * @dev Return the minimum of two uints

   * @param _a Uint 1

   * @param _b Uint 2

   * @return The smallest value or b if equal

   */

  function __min__(uint256 _a, uint256 _b)

    private

    constant

    returns (uint256)

  {

    return _a < _b ? _a : _b;

  }



  /**

   * @dev Define if the ratio to be used is wei/tok to tok/wei. Largest uint will

   * always act as the numerator.

   * @param _makerOrder The maker order object.

   * @return If the ratio is wei/tok or not.

   */

  function __ratioIsWeiPerTok__(Order _makerOrder)

    private

    constant

    returns (bool)

  {

    bool offerIsWei = _makerOrder.offerToken_ == address(0) ? true : false;



    // wei/tok

    if (offerIsWei && _makerOrder.offerTokenTotal_ >= _makerOrder.wantTokenTotal_) {

      return true;



    } else if (!offerIsWei && _makerOrder.wantTokenTotal_ >= _makerOrder.offerTokenTotal_) {

      return true;



    // tok/wei. otherwise wanting wei && offer > want, OR offer wei && want > offer

    } else {

      return false;

    }

  }



  /**

   * @dev Confirm that the orders do match and are valid.

   * @param _makerOrder The maker order data structure.

   * @param _takerOrder The taker order data structure.

   * @return Bool if the orders passes all checks.

   */

  function __ordersMatch_and_AreVaild__(

    Order _makerOrder,

    Order _takerOrder

  ) private

    constant

    returns (bool)

  {

    // Orders still active

    if (!_makerOrder.active_)

      return error('Maker order is inactive, Exchange.__ordersMatch_and_AreVaild__()');



    if (!_takerOrder.active_)

      return error('Taker order is inactive, Exchange.__ordersMatch_and_AreVaild__()');



    // Confirm tokens match

    // NOTE potentially omit as matching handled upstream?

    if (_makerOrder.wantToken_ != _takerOrder.offerToken_)

      return error('Maker wanted token does not match taker offer token, Exchange.__ordersMatch_and_AreVaild__()');



    if (_makerOrder.offerToken_ != _takerOrder.wantToken_)

      return error('Maker offer token does not match taker wanted token, Exchange.__ordersMatch_and_AreVaild__()');



    // Price Ratios, to x decimal places hence * decimals, dependent on the size of the denominator.

    // Ratios are relative to eth, amount of ether for a single token, ie. ETH / GNO == 0.2 Ether per 1 Gnosis

    uint256 orderPrice;  // The price the maker is willing to accept

    uint256 offeredPrice; // The offer the taker has given

    uint256 decimals = _makerOrder.offerToken_ == address(0) ? __flooredLog10__(_makerOrder.wantTokenTotal_) : __flooredLog10__(_makerOrder.offerTokenTotal_);



    // Ratio = larger amount / smaller amount

    if (_makerOrder.offerTokenTotal_ >= _makerOrder.wantTokenTotal_) {

      orderPrice = _makerOrder.offerTokenTotal_.mul(10**decimals).div(_makerOrder.wantTokenTotal_);

      offeredPrice = _takerOrder.wantTokenTotal_.mul(10**decimals).div(_takerOrder.offerTokenTotal_);



      // ie. Maker is offering 10 ETH for 100 GNO but taker is offering 100 GNO for 20 ETH, no match!

      // The taker wants more ether than the maker is offering.

      if (orderPrice < offeredPrice)

        return error('Taker price is greater than maker price, Exchange.__ordersMatch_and_AreVaild__()');



    } else {

      orderPrice = _makerOrder.wantTokenTotal_.mul(10**decimals).div(_makerOrder.offerTokenTotal_);

      offeredPrice = _takerOrder.offerTokenTotal_.mul(10**decimals).div(_takerOrder.wantTokenTotal_);



      // ie. Maker is offering 100 GNO for 10 ETH but taker is offering 5 ETH for 100 GNO, no match!

      // The taker is not offering enough ether for the maker

      if (orderPrice > offeredPrice)

        return error('Taker price is less than maker price, Exchange.__ordersMatch_and_AreVaild__()');



    }



    return true;

  }



  /**

   * @dev Ask each wallet to verify this order.

   * @param _token_and_EOA_Addresses The addresses of the maker and taker EOAs and offered token contracts.

   * [makerEOA, makerOfferToken, takerEOA, takerOfferToken]

   * @param _toMakerAmount The amount of tokens to be sent to the maker.

   * @param _toTakerAmount The amount of tokens to be sent to the taker.

   * @param _makerWallet The maker's wallet contract.

   * @param _takerWallet The taker's wallet contract.

   * @param _fee The fee to be paid for this trade, paid in full by taker.

   * @return Success if both wallets verify the order.

   */

  function __ordersVerifiedByWallets__(

    address[4] _token_and_EOA_Addresses,

    uint256 _toMakerAmount,

    uint256 _toTakerAmount,

    Wallet _makerWallet,

    Wallet _takerWallet,

    uint256 _fee

  ) private

    constant

    returns (bool)

  {

    // Have the transaction verified by both maker and taker wallets

    // confirm sufficient balance to transfer, offerToken and offerTokenAmount

    if(!_makerWallet.verifyOrder(_token_and_EOA_Addresses[1], _toTakerAmount, 0, 0))

      return error('Maker wallet could not verify the order, Exchange.__ordersVerifiedByWallets__()');



    if(!_takerWallet.verifyOrder(_token_and_EOA_Addresses[3], _toMakerAmount, _fee, edoToken_))

      return error('Taker wallet could not verify the order, Exchange.__ordersVerifiedByWallets__()');



    return true;

  }



  /**

   * @dev On chain verification of an ECDSA ethereum signature.

   * @param _signer The EOA address of the account that supposedly signed the message.

   * @param _orderHash The on-chain generated hash for the order.

   * @param _v ECDSA signature parameter v.

   * @param _r ECDSA signature parameter r.

   * @param _s ECDSA signature parameter s.

   * @return Bool if the signature is valid or not.

   */

  function __signatureIsValid__(

    address _signer,

    bytes32 _orderHash,

    uint8 _v,

    bytes32 _r,

    bytes32 _s

  ) private

    constant

    returns (bool)

  {

    address recoveredAddr = ecrecover(

      keccak256('\x19Ethereum Signed Message:\n32', _orderHash),

      _v, _r, _s

    );



    return recoveredAddr == _signer;

  }



  /**

   * @dev Confirm wallet local balances and token balances match.

   * @param _makerWallet  Maker wallet address.

   * @param _takerWallet  Taker wallet address.

   * @param _token  Token address to confirm balances match.

   * @return If the balances do match.

   */

  function __tokenAndWalletBalancesMatch__(

    address _makerWallet,

    address _takerWallet,

    address _token

  ) private

    constant

    returns(bool)

  {

    if (Token(_token).balanceOf(_makerWallet) != Wallet(_makerWallet).balanceOf(_token))

      return false;



    if (Token(_token).balanceOf(_takerWallet) != Wallet(_takerWallet).balanceOf(_token))

      return false;



    return true;

  }



  /**

   * @dev Update the order structs.

   * @param _makerOrder The maker order data structure.

   * @param _takerOrder The taker order data structure.

   * @param _toTakerAmount The amount of tokens to be moved to the taker.

   * @param _toTakerAmount The amount of tokens to be moved to the maker.

   * @return Success if the update succeeds.

   */

  function __updateOrders__(

    Order _makerOrder,

    Order _takerOrder,

    uint256 _toTakerAmount,

    uint256 _toMakerAmount

  ) private

  {

    // taker => maker

    _makerOrder.wantTokenReceived_ = _makerOrder.wantTokenReceived_.add(_toMakerAmount);

    _takerOrder.offerTokenRemaining_ = _takerOrder.offerTokenRemaining_.sub(_toMakerAmount);



    // maker => taker

    _takerOrder.wantTokenReceived_ = _takerOrder.wantTokenReceived_.add(_toTakerAmount);

    _makerOrder.offerTokenRemaining_ = _makerOrder.offerTokenRemaining_.sub(_toTakerAmount);

  }

}



interface BadERC20 {

  function transfer(address to, uint value) external;

  function transferFrom(address from, address to, uint256 value) external;

  function approve(address spender, uint value) external;

}



/**

 * @title Wallet logic library

 * @dev Standard logic universally used by wallets.

 */

contract WalletLogic3 is LoggingErrors {

  using SafeMath for uint256;



  /**

   * Storage

   */

  // NOTE order of storage vars must match Wallet contract do not revise in later versions

  address public owner_;

  address public exchange_;

  mapping(address => uint256) public tokenBalances_;



  /**

   * Events

   */

  event LogDeposit(address token, uint256 amount, uint256 balance);

  event LogWithdrawal(address token, uint256 amount, uint256 balance);



  /**

   * Core library methods

   */



  /**

   * @dev Deposit ether or any ERC20 token into this wallet.

   * @param _token The address of the existing token contract, including ether.

   * @param _amount The amount of tokens to deposit.

   * @return If the funcion was successful.

   */

  function deposit (

    address _token,

    uint256 _amount

  ) external

    payable

    returns(bool)

  {

    // Ensure not depositing ERC20 and mistakenly sending ether along

    if (_token != 0 && msg.value > 0) {

      return error("ERC20 deposited but msg.value > 0, WalletLogic.deposit()");

    }



    if (_amount <= 0) {

      return error("Token amount must be greater than 0, WalletLogic.deposit()");

    }



    // NOT depositing ether, must transfer the tokens to the calling contract

    if (_token != address(0)) {

      require(

        safeTransferFrom(_token, msg.sender, this, _amount),

        "Cannot deposit token, WalletLogic.deposit()"

      );

    }



    tokenBalances_[_token] = tokenBalances_[_token].add(_amount);

    emit LogDeposit(_token, _amount, tokenBalances_[_token]);



    // Notify the exchange of the deposit

    Exchange(exchange_).walletDeposit(_token, _amount, tokenBalances_[_token]);



    return true;

  }



  /**

   * @dev Update the token balance within this wallet, increment or decrement.

   * @param _token The address of the token balance to update.

   * @param _amount The amount to update the balance by.

   * @param _subtractionFlag If true then subtract the token amount else add.

   * @return If the funcion was successful.

   */

  function updateBalance (

    address _token,

    uint256 _amount,

    bool _subtractionFlag

  ) external

    returns (bool)

  {

    if (msg.sender != exchange_) {

      return error("msg.sender != exchange, potential Exchange version mis-match, wallet must upgrade. WalletLogic.updateBalance()");

    }



    if (_amount == 0) {

      return error("Cannot update by 0, WalletLogic.updateBalance()");

    }



    // If sub then check the balance is sufficient in order to log the error

    if (_subtractionFlag) {

      if (tokenBalances_[_token] < _amount) {

        return error("Insufficient balance to subtract, WalletLogic.updateBalance()");

      }



      tokenBalances_[_token] = tokenBalances_[_token].sub(_amount);

    } else {

      tokenBalances_[_token] = tokenBalances_[_token].add(_amount);

    }



    return true;

  }



  /**

   * @dev Verify an order that the Exchange has received involving this wallet.

   * Internal checks and then authorize the exchange to move the tokens.

   * If sending ether then will transfer to the exchange to broker the trade.

   * @param _token The address of the token contract being bought / sold

   * ether is buying, always selling ERC20 tokens.

   * @param _amount The amount of tokens the order is for.

   * @param _fee The fee for the current trade.

   * @param _feeToken The token of which the fee is to be paid in.

   * @return If the funcion was successful.

   */

  function verifyOrder (

    address _token,

    uint256 _amount,

    uint256 _fee,

    address _feeToken

  ) external

    returns(bool)

  {

    if (msg.sender != exchange_) {

      return error("msg.sender != exchange, potential Exchange version mis-match, wallet must upgrade. WalletLogic.verifyOrder()");

    }



    if (tokenBalances_[_token] < _amount) {

      return error("Insufficient funds in local mapping, WalletLogic.verifyOrder()");

    }



    if (_fee > 0 && _token != _feeToken) {

      // If there is a fee, approve the exchange to `transferFrom` this wallet the fee amount of EDO tokens

      require(

        Token(_feeToken).approve(msg.sender, _fee),

        "Cannot approve the feeToken transfer when _token != _feeToken, WalletLogic.verifyOrder()"

      );

    }



    if (_fee > 0 && _token == _feeToken) {

      // Fee and amount offered are the same token so approve a summed amount

      require(

        Token(_feeToken).approve(msg.sender, _fee.add(_amount)),

        "Cannot approve the feeToken transfer when _token == _feeToken, WalletLogic.verifyOrder()"

      );

    } else if (_token != address(0)) {

      // Not ether or EDO, Approve the exchange to `transferFrom` this wallet

      if (Token(_token).balanceOf(this) < _amount) {

        // token.balanceOf and tokenBalances do not match!!

        return error("CRITICAL: Mismatch between balances, Insufficient funds in token contract, WalletLogic.verifyOrder()");

      }

      require(

        safeApprove(_token, msg.sender, _amount),

        "Cannot approve the token to be traded transfer, WalletLogic.verifyOrder()"

      );

    } else {

      // If ether this wallet must have suficient balance

      // If so, will send the ether to the exchange to broker the trade

      if (address(this).balance < _amount) {

        // this.balance and tokenBalances do not match!!

        return error("CRITICAL: Mismatch between balances, Insufficient ether balance in wallet contract, WalletLogic.verifyOrder()");

      }



      exchange_.transfer(_amount);

    }



    return true;

  }



  /**

   * @dev Withdraw any token, including ether from this wallet to an EOA.

   * @param _token The address of the token to withdraw.

   * @param _amount The amount to withdraw.

   * @return Success of the withdrawal.

   */

  function withdraw (

    address _token,

    uint256 _amount

  ) external

    returns(bool)

  {

    if(msg.sender != owner_) {

      return error("msg.sender != owner, WalletLogic.withdraw()");

    }



    if(_amount == 0) {

      return error("May not withdraw an amount of 0, WalletLogic.withdraw()");

    }



    if (_amount < tokenBalances_[_token]) {

      tokenBalances_[_token] = tokenBalances_[_token].sub(_amount);

    } else {

      tokenBalances_[_token] = 0;

    }



    if (_token == address(0)) {

      if (address(this).balance < _amount) {

        return error("Insufficient funds in wallet, WalletLogic.withdraw()");

      }

      msg.sender.transfer(_amount);

      // non required but can protect from balance misalignment

      tokenBalances_[address(0)] = address(this).balance;

    } else {

      if (Token(_token).balanceOf(this) < _amount) {

        return error("Insufficient funds in wallet, WalletLogic.withdraw()");

      }

      require(

        safeTransfer(_token, msg.sender, _amount),

        "safeTransfer failed, WalletLogic.withdraw()"

      );

      // non required but can protect from balance misalignment

      tokenBalances_[_token] = Token(_token).balanceOf(this);

    }



    emit LogWithdrawal(_token, _amount, tokenBalances_[_token]);



    // Notify the exchange of the withdrawal

    Exchange(exchange_).walletWithdrawal(_token, _amount, tokenBalances_[_token]);



    return true;

  }



  /**

   * @dev Wrapping the ERC20 transfer function to avoid missing returns.

   * @param _token The address of bad formed ERC20 token.

   * @param _to Transfer receiver.

   * @param _amount Amount to be transfered.

   * @return Success of the safeTransfer.

   */



  function safeTransfer(

    address _token,

    address _to,

    uint _amount

  )

    public

    returns (bool result)

  {

    BadERC20(_token).transfer(_to, _amount);



    assembly {

      switch returndatasize()

      case 0 {                      // This is our BadToken

        result := not(0)            // result is true

      }

      case 32 {                     // This is our GoodToken

        returndatacopy(0, 0, 32)

        result := mload(0)          // result == returndata of external call

      }

      default {                     // This is not an ERC20 token

        revert(0, 0)

      }

    }

  }





  /**

   * @dev Wrapping the ERC20 transferFrom function to avoid missing returns.

   * @param _token The address of bad formed ERC20 token.

   * @param _from Transfer sender.

   * @param _to Transfer receiver.

   * @param _value Amount to be transfered.

   * @return Success of the safeTransferFrom.

   */



  function safeTransferFrom(

    address _token,

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool result)

  {

    BadERC20(_token).transferFrom(_from, _to, _value);



    assembly {

      switch returndatasize()

      case 0 {                      // This is our BadToken

        result := not(0)            // result is true

      }

      case 32 {                     // This is our GoodToken

        returndatacopy(0, 0, 32)

        result := mload(0)          // result == returndata of external call

      }

      default {                     // This is not an ERC20 token

        revert(0, 0)

      }

    }

  }



  /**

   * @dev Wrapping the ERC20 approve function to avoid missing returns.

   * @param _token The address of bad formed ERC20 token.

   * @param _spender Spender address.

   * @param _value Amount allowed to be spent.

   * @return Success of the safeApprove.

   */



  function safeApprove(

    address _token,

    address _spender,

    uint256 _value

  )

    public

    returns (bool result)

  {

    BadERC20(_token).approve(_spender, _value);



    assembly {

      switch returndatasize()

      case 0 {                      // This is our BadToken

        result := not(0)            // result is true

      }

      case 32 {                     // This is our GoodToken

        returndatacopy(0, 0, 32)

        result := mload(0)          // result == returndata of external call

      }

      default {                     // This is not an ERC20 token

        revert(0, 0)

      }

    }

  }

}