/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

// File: contracts/utils/LoggingErrors.sol

pragma solidity ^0.4.11;

/**
 * @title Log Various Error Types
 * @author Adam Lemmon <adam@oraclize.it>
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
    emit LogErrorString(_errorMessage);
    return false;
  }
}

// File: contracts/wallet/WalletConnector.sol

pragma solidity ^0.4.15;


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

// File: contracts/token/ERC20Interface.sol

pragma solidity ^0.4.11;

interface Token {
  /// @return total amount of tokens
  function totalSupply() external constant returns (uint256 supply);

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) external constant returns (uint256 balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) external returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of wei to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) external returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) external constant returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function decimals() external constant returns(uint);
  function name() external constant returns(string);
}

// File: contracts/wallet/WalletV3.sol

pragma solidity ^0.4.15;




/**
 * @title Wallet to hold and trade ERC20 tokens and ether
 * @dev User wallet to interact with the exchange.
 * all tokens and ether held in this wallet, 1 to 1 mapping to user EOAs.
 */
contract WalletV3 is LoggingErrors {
  /**
   * Storage
   */
  // Vars included in wallet logic "lib", the order must match between Wallet and Logic
  address public owner_;
  address public exchange_;
  mapping(address => uint256) public tokenBalances_;

  address public logic_; // storage location 0x3 loaded for delegatecalls so this var must remain at index 3
  uint256 public birthBlock_;

  WalletConnector private connector_;

  /**
   * Events
   */
  event LogDeposit(address token, uint256 amount, uint256 balance);
  event LogWithdrawal(address token, uint256 amount, uint256 balance);

  /**
   * @dev Contract constructor. Set user as owner and connector address.
   * @param _owner The address of the user's EOA, wallets created from the exchange
   * so must past in the owner address, msg.sender == exchange.
   * @param _connector The wallet connector to be used to retrieve the wallet logic
   */
  constructor(address _owner, address _connector, address _exchange) public {
    owner_ = _owner;
    connector_ = WalletConnector(_connector);
    exchange_ = _exchange;
    logic_ = connector_.latestLogic_();
    birthBlock_ = block.number;
  }

  function () external payable {}

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
    require(
      logic_.delegatecall(abi.encodeWithSignature('deposit(address,uint256)', 0, msg.value)),
      "depositEther() failed"
    );
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

    require(
      logic_.delegatecall(abi.encodeWithSignature('deposit(address,uint256)', _token, _amount)),
      "depositERC20Token() failed"
    );
    return true;
  }

  /**
   * @dev The result of an order, update the balance of this wallet.
   * param _token The address of the token balance to update.
   * param _amount The amount to update the balance by.
   * param _subtractionFlag If true then subtract the token amount else add.
   * @return Bool if the update was successful.
   */
  function updateBalance (
    address /*_token*/,
    uint256 /*_amount*/,
    bool /*_subtractionFlag*/
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
   * param _token The address of the token contract being sold.
   * param _amount The amount of tokens the order is for.
   * param _fee The fee for the current trade.
   * param _feeToken The token of which the fee is to be paid in.
   * @return If the order was verified or not.
   */
  function verifyOrder (
    address /*_token*/,
    uint256 /*_amount*/,
    uint256 /*_fee*/,
    address /*_feeToken*/
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
   * param _token The address of the token to withdraw.
   * param _amount The amount to withdraw.
   * @return Success of the withdrawal.
   */
  function withdraw(address /*_token*/, uint256 /*_amount*/)
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
    view
    returns(uint)
  {
    if (_token == address(0)) {
      return address(this).balance;
    } else {
      return Token(_token).balanceOf(this);
    }
  }

  function walletVersion() external pure returns(uint){
    return 3;
  }
}

// File: contracts/wallet/WalletBuilderInterface.sol

pragma solidity ^0.4.15;



/**
 * @title Wallet to hold and trade ERC20 tokens and ether
 */
interface WalletBuilderInterface {

  /**
   * @dev build a new trading wallet and returns its address
   * @param _owner user EOA of the created trading wallet
   * @param _exchange exchange address
   */
  function buildWallet(address _owner, address _exchange) external returns(address);
}

// File: contracts/utils/Ownable.sol

pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "msg.sender != owner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "newOwner == 0");
    owner = newOwner;
  }

}

// File: contracts/utils/SafeMath.sol

pragma solidity ^0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
}

// File: contracts/UsersManager.sol

pragma solidity ^0.4.24;







interface RetrieveWalletInterface {
  function retrieveWallet(address userAccount) external returns(address walletAddress);
}

contract UsersManager is Ownable, RetrieveWalletInterface {
  mapping(address => address) public userAccountToWallet_; // User EOA to wallet addresses
  WalletBuilderInterface public walletBuilder;
  RetrieveWalletInterface public previousMapping;

  event LogUserAdded(address indexed user, address walletAddress);
  event LogWalletUpgraded(address indexed user, address oldWalletAddress, address newWalletAddress);
  event LogWalletBuilderChanged(address newWalletBuilder);

  constructor (
    address _previousMappingAddress,
    address _walletBuilder
  ) public {
    require(_walletBuilder != address (0), "WalletConnector address == 0");
    previousMapping = RetrieveWalletInterface(_previousMappingAddress);
    walletBuilder = WalletBuilderInterface(_walletBuilder);
  }

  /**
   * External
   */

  /**
   * @dev Returns the Wallet contract address associated to a user account. If the user account is not known, try to
   * migrate the wallet address from the old exchange instance. This function is equivalent to getWallet(), in addition
   * it stores the wallet address fetched from old the exchange instance.
   * @param userAccount The user account address
   * @return The address of the Wallet instance associated to the user account
   */
  function retrieveWallet(address userAccount)
    public
    returns(address walletAddress)
  {
    walletAddress = userAccountToWallet_[userAccount];
    if (walletAddress == address(0) && address(previousMapping) != address(0)) {
      // Retrieve the wallet address from the old exchange.
      walletAddress = previousMapping.retrieveWallet(userAccount);

      if (walletAddress != address(0)) {
        userAccountToWallet_[userAccount] = walletAddress;
      }
    }
  }

  /**
 * @dev Private implementation for addNewUser function. Add a new user
 * into the exchange, create a wallet for them.
 * Map their account address to the wallet contract for lookup.
 * @param userExternalOwnedAccount The address of the user"s EOA.
 * @param exchangeAddress The address of the exchange smart contract.
 * @return the created trading wallet address.
 */
  function __addNewUser(address userExternalOwnedAccount, address exchangeAddress)
    private
    returns (address)
  {
    address userTradingWallet = walletBuilder.buildWallet(userExternalOwnedAccount, exchangeAddress);
    userAccountToWallet_[userExternalOwnedAccount] = userTradingWallet;
    emit LogUserAdded(userExternalOwnedAccount, userTradingWallet);
    return userTradingWallet;
  }

  /**
   * @dev Add a new user to the exchange, create a wallet for them.
   * Map their account address to the wallet contract for lookup.
   * @param userExternalOwnedAccount The address of the user"s EOA.
   * @return Success of the transaction, false if error condition met.
   */
  function addNewUser(address userExternalOwnedAccount)
    public
    returns (bool)
  {
    require (
      retrieveWallet(userExternalOwnedAccount) == address(0),
      "User already exists, Exchange.addNewUser()"
    );

    // Create a new wallet passing EOA for owner and msg.sender for exchange. If the caller of this function is not the
    // exchange, the trading wallet is not operable and requires an updateExchange()
    __addNewUser(userExternalOwnedAccount, msg.sender);
    return true;
  }

  /**
   * @dev Recreate the trading wallet for the user calling the function.
   */
  function upgradeWallet() external
  {
    address oldWallet = retrieveWallet(msg.sender);
    require(
      oldWallet != address(0),
      "User does not exists yet, Exchange.upgradeWallet()"
    );
    address exchange = WalletV3(oldWallet).exchange_();
    address userTradingWallet = __addNewUser(msg.sender, exchange);
    emit LogWalletUpgraded(msg.sender, oldWallet, userTradingWallet);
  }

  /**
   * @dev Administratively changes the wallet address for a specific EOA.
   */
  function adminSetWallet(address userExternalOwnedAccount, address userTradingWallet)
    onlyOwner
    external
  {
    address oldWallet = retrieveWallet(userExternalOwnedAccount);
    userAccountToWallet_[userExternalOwnedAccount] = userTradingWallet;
    emit LogUserAdded(userExternalOwnedAccount, userTradingWallet);
    if (oldWallet != address(0)) {
      emit LogWalletUpgraded(userExternalOwnedAccount, oldWallet, userTradingWallet);
    }
  }

  /**
   * @dev Add a new user to the exchange, create a wallet for them.
   * Map their account address to the wallet contract for lookup.
   * @param newWalletBuilder The address of the new wallet builder
   * @return Success of the transaction, false if error condition met.
   */
  function setWalletBuilder(address newWalletBuilder)
    public
    onlyOwner
    returns (bool)
  {
    require(newWalletBuilder != address(0), "setWalletBuilder(): newWalletBuilder == 0");
    walletBuilder = WalletBuilderInterface(newWalletBuilder);
    emit LogWalletBuilderChanged(walletBuilder);
    return true;
  }
}

// File: contracts/utils/SafeERC20.sol

pragma solidity ^0.4.11;


interface BadERC20 {
  function transfer(address to, uint value) external;
  function transferFrom(address from, address to, uint256 value) external;
  function approve(address spender, uint value) external;
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeERC20 {

  event LogWarningNonZeroAllowance(address token, address spender, uint256 allowance);

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
  internal
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
  internal
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

  function checkAndApprove(
    address _token,
    address _spender,
    uint256 _value
  )
  internal
  returns (bool result)
  {
    uint currentAllowance = Token(_token).allowance(this, _spender);
    if (currentAllowance > 0) {
      emit LogWarningNonZeroAllowance(_token, _spender, currentAllowance);
      // no check required for approve because it eventually will fail in the second approve
      safeApprove(_token, _spender, 0);
    }
    return safeApprove(_token, _spender, _value);
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
  internal
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

// File: contracts/ExchangeV3.sol

pragma solidity ^0.4.24;






/**
 * @title Decentralized exchange for ether and ERC20 tokens.
 * @author Eidoo SAGL.
 * @dev All trades brokered by this contract.
 * Orders submitted by off chain order book and this contract handles
 * verification and execution of orders.
 * All value between parties is transferred via this exchange.
 * Methods arranged by visibility; external, public, internal, private and alphabatized within.
 *
 * New Exchange SC with eventually no fee and ERC20 tokens as quote
 */
contract ExchangeV3 {

  using SafeMath for uint256;

  /**
   * Data Structures
   */
  struct Order {
    address offerToken_;
    uint256 offerTokenTotal_;
    uint256 offerTokenRemaining_;  // Amount left to give
    address wantToken_;
    uint256 wantTokenTotal_;
    uint256 wantTokenReceived_;  // Amount received, note this may exceed want total
  }

  struct OrderStatus {
    uint256 expirationBlock_;
    uint256 wantTokenReceived_;    // Amount received, note this may exceed want total
    uint256 offerTokenRemaining_;  // Amount left to give
  }

  struct Orders {
    Order makerOrder;
    Order takerOrder;
    bool isMakerBuy;
  }

  struct FeeRate {
    uint256 edoPerQuote;
    uint256 edoPerQuoteDecimals;
  }

  struct Balances {
    uint256 makerWantTokenBalance;
    uint256 makerOfferTokenBalance;
    uint256 takerWantTokenBalance;
    uint256 takerOfferTokenBalance;
  }

  struct TradingWallets {
    WalletV3 maker;
    WalletV3 taker;
  }

  struct TradingAmounts {
    uint256 toTaker;
    uint256 toMaker;
    uint256 fee;
  }

  struct OrdersHashes {
    bytes32 makerOrder;
    bytes32 takerOrder;
  }

  /**
   * Storage
   */
  address private orderBookAccount_;
  address public owner_;
  address public feeManager_;
  uint256 public birthBlock_;
  address public edoToken_;
  uint256 public dustLimit = 100;

  mapping (address => uint256) public feeEdoPerQuote;
  mapping (address => uint256) public feeEdoPerQuoteDecimals;

  address public eidooWallet_;

  // Define if fee calculation must be skipped for a given trade. By default (false) fee must not be skipped.
  mapping(address => mapping(address => FeeRate)) public customFee;
  // whitelist of EOA that should not pay fee
  mapping(address => bool) public feeTakersWhitelist;

  /**
   * @dev Define in a trade who is the quote using a priority system:
   * values example
   *   0: not used as quote
   *  >0: used as quote
   *  if wanted and offered tokens have value > 0 the quote is the token with the bigger value
   */
  mapping(address => uint256) public quotePriority;

  mapping(bytes32 => OrderStatus) public orders_; // Map order hashes to order data struct
  UsersManager public users;

  /**
   * Events
   */
  event LogFeeRateSet(address indexed token, uint256 rate, uint256 decimals);
  event LogQuotePrioritySet(address indexed quoteToken, uint256 priority);
  event LogCustomFeeSet(address indexed base, address indexed quote, uint256 edoPerQuote, uint256 edoPerQuoteDecimals);
  event LogFeeTakersWhitelistSet(address takerEOA, bool value);
  event LogWalletDeposit(address indexed walletAddress, address token, uint256 amount, uint256 balance);
  event LogWalletWithdrawal(address indexed walletAddress, address token, uint256 amount, uint256 balance);
  event LogWithdraw(address recipient, address token, uint256 amount);

  event LogOrderExecutionSuccess(
    bytes32 indexed makerOrderId,
    bytes32 indexed takerOrderId,
    uint256 toMaker,
    uint256 toTaker
  );
  event LogBatchOrderExecutionFailed(
    bytes32 indexed makerOrderId,
    bytes32 indexed takerOrderId,
    uint256 position
  );
  event LogOrderFilled(bytes32 indexed orderId, uint256 totalOfferRemaining, uint256 totalWantReceived);

  /**
   * @dev Contract constructor - CONFIRM matches contract name.  Set owner and addr of order book.
   * @param _bookAccount The EOA address for the order book, will submit ALL orders.
   * @param _edoToken Deployed edo token.
   * @param _edoPerWei Rate of edo tokens per wei.
   * @param _edoPerWeiDecimals Decimlas carried in edo rate.
   * @param _eidooWallet Wallet to pay fees to.
   * @param _usersMapperAddress Previous exchange smart contract address.
   */
  constructor (
    address _bookAccount,
    address _edoToken,
    uint256 _edoPerWei,
    uint256 _edoPerWeiDecimals,
    address _eidooWallet,
    address _usersMapperAddress
  ) public {
    orderBookAccount_ = _bookAccount;
    owner_ = msg.sender;
    birthBlock_ = block.number;
    edoToken_ = _edoToken;
    feeEdoPerQuote[address(0)] = _edoPerWei;
    feeEdoPerQuoteDecimals[address(0)] = _edoPerWeiDecimals;
    eidooWallet_ = _eidooWallet;
    quotePriority[address(0)] = 10;
    setUsersMapper(_usersMapperAddress);
  }

  /**
   * @dev Fallback. wallets utilize to send ether in order to broker trade.
   */
  function () external payable { }

  modifier onlyOwner() {
    require (
      msg.sender == owner_,
      "msg.sender != owner"
    );
    _;
  }

  function setUsersMapper(address _userMapperAddress)
    public
    onlyOwner
    returns (bool)
  {
    require(_userMapperAddress != address(0), "_userMapperAddress == 0");
    users = UsersManager(_userMapperAddress);
    return true;
  }

  function setFeeManager(address feeManager)
    public
    onlyOwner
  {
    feeManager_ = feeManager;
  }

  function setDustLimit(uint limit)
    public
    onlyOwner
  {
    dustLimit = limit;
  }

  /**
   * @dev Add a new user to the exchange, create a wallet for them.
   * Map their account address to the wallet contract for lookup.
   * @param userExternalOwnedAccount The address of the user"s EOA.
   * @return Success of the transaction, false if error condition met.
   */
  function addNewUser(address userExternalOwnedAccount)
    external
    returns (bool)
  {
    return users.addNewUser(userExternalOwnedAccount);
  }

  /**
   * @dev For backward compatibility.
   * @param userExternalOwnedAccount The address of the user's EOA.
   * @return The address of the trading wallet
   */
  function userAccountToWallet_(address userExternalOwnedAccount) external returns(address)
  {
    return users.retrieveWallet(userExternalOwnedAccount);
  }

  function retrieveWallet(address userExternalOwnedAccount)
    external
    returns(address)
  {
    return users.retrieveWallet(userExternalOwnedAccount);
  }

  /**
   * Execute orders in batches.
   * @param ownedExternalAddressesAndTokenAddresses Tokan and user addresses.
   * @param amountsExpirationsAndSalts Offer and want token amount and expiration and salt values.
   * @param vSignatures All order signature v values.
   * @param rAndSsignatures All order signature r and r values.
   * @return The success of this transaction.
   */
  function batchExecuteOrder(
    address[4][] ownedExternalAddressesAndTokenAddresses,
    uint256[8][] amountsExpirationsAndSalts, // Packing to save stack size
    uint8[2][] vSignatures,
    bytes32[4][] rAndSsignatures
  ) external
    returns(bool)
  {
    require(
      msg.sender == orderBookAccount_,
      "msg.sender != orderBookAccount, Exchange.batchExecuteOrder()"
    );

    for (uint256 i = 0; i < amountsExpirationsAndSalts.length; i++) {
      // TODO: the following 3 lines requires solc 0.5.0
//      bytes memory payload = abi.encodeWithSignature("executeOrder(address[4],uint256[8],uint8[2],bytes32[4])",
//        ownedExternalAddressesAndTokenAddresses[i],
//        amountsExpirationsAndSalts[i],
//        vSignatures[i],
//        rAndSsignatures[i]
//      );
//      (bool success, bytes memory returnData) = address(this).call(payload);
//      if (!success || !bool(returnData)) {
      bool success = address(this).call(abi.encodeWithSignature("executeOrder(address[4],uint256[8],uint8[2],bytes32[4])",
        ownedExternalAddressesAndTokenAddresses[i],
        amountsExpirationsAndSalts[i],
        vSignatures[i],
        rAndSsignatures[i]
      ));
      if (!success) {
        OrdersHashes memory hashes = __generateOrderHashes__(
          ownedExternalAddressesAndTokenAddresses[i],
          amountsExpirationsAndSalts[i]
        );
        emit LogBatchOrderExecutionFailed(hashes.makerOrder, hashes.takerOrder, i);
      }
    }

    return true;
  }

  /**
   * @dev Execute an order that was submitted by the external order book server.
   * The order book server believes it to be a match.
   * There are components for both orders, maker and taker, 2 signatures as well.
   * @param ownedExternalAddressesAndTokenAddresses The maker and taker external owned accounts addresses and offered tokens contracts.
   * [
   *   makerEOA
   *   makerOfferToken
   *   takerEOA
   *   takerOfferToken
   * ]
   * @param amountsExpirationsAndSalts The amount of tokens and the block number at which this order expires and a random number to mitigate replay.
   * [
   *   makerOffer
   *   makerWant
   *   takerOffer
   *   takerWant
   *   makerExpiry
   *   makerSalt
   *   takerExpiry
   *   takerSalt
   * ]
   * @param vSignatures ECDSA signature parameter.
   * [
   *   maker V
   *   taker V
   * ]
   * @param rAndSsignatures ECDSA signature parameters r ans s, maker 0, 1 and taker 2, 3.
   * [
   *   maker R
   *   maker S
   *   taker R
   *   taker S
   * ]
   * @return Success of the transaction, false if error condition met.
   * Like types grouped to eliminate stack depth error.
   */
  function executeOrder (
    address[4] ownedExternalAddressesAndTokenAddresses,
    uint256[8] amountsExpirationsAndSalts, // Packing to save stack size
    uint8[2] vSignatures,
    bytes32[4] rAndSsignatures
  ) public
    returns(bool)
  {
    // get users trading wallets and check if they exist
    TradingWallets memory wallets =
      getMakerAndTakerTradingWallets(ownedExternalAddressesAndTokenAddresses);

    // Basic pre-conditions, return if any input data is invalid
    __executeOrderInputIsValid__(
      ownedExternalAddressesAndTokenAddresses,
      amountsExpirationsAndSalts
    );

    // Verify Maker and Taker signatures
    OrdersHashes memory hashes = __generateOrderHashes__(
      ownedExternalAddressesAndTokenAddresses,
      amountsExpirationsAndSalts
    );

    // Check maker order signature
    require(
      __signatureIsValid__(
      ownedExternalAddressesAndTokenAddresses[0],
        hashes.makerOrder,
        vSignatures[0],
        rAndSsignatures[0],
        rAndSsignatures[1]
      ),
      "Maker signature is invalid, Exchange.executeOrder()"
    );

    // Check taker order signature
    require(__signatureIsValid__(
        ownedExternalAddressesAndTokenAddresses[2],
        hashes.takerOrder,
        vSignatures[1],
        rAndSsignatures[2],
        rAndSsignatures[3]
      ),
      "Taker signature is invalid, Exchange.executeOrder()"
    );

    // Exchange Order Verification and matching
    Orders memory orders = __getOrders__(ownedExternalAddressesAndTokenAddresses, amountsExpirationsAndSalts, hashes);

    // Trade amounts and fee
    TradingAmounts memory amounts = __getTradeAmounts__(orders, ownedExternalAddressesAndTokenAddresses[2]);

    require(
      amounts.toTaker > 0 && amounts.toMaker > 0,
      "Token amount < 1, price ratio is invalid! Token value < 1, Exchange.executeOrder()"
    );

    // Update orders status
    orders.makerOrder.offerTokenRemaining_ = orders.makerOrder.offerTokenRemaining_.sub(amounts.toTaker);
    orders.makerOrder.wantTokenReceived_ = orders.makerOrder.wantTokenReceived_.add(amounts.toMaker);

    orders.takerOrder.offerTokenRemaining_ = orders.takerOrder.offerTokenRemaining_.sub(amounts.toMaker);
    orders.takerOrder.wantTokenReceived_ = orders.takerOrder.wantTokenReceived_.add(amounts.toTaker);

    // Write orders status to storage. If the remaining to trade in the order is below the limit,
    // cleanup the storage marking the order as completed.
    uint limit = dustLimit;
    if ((orders.makerOrder.offerTokenRemaining_ <= limit) ||
        (orders.isMakerBuy && (orders.makerOrder.wantTokenReceived_ + limit) >= orders.makerOrder.wantTokenTotal_)
    ) {
      orders_[hashes.makerOrder].offerTokenRemaining_ = 0;
      orders_[hashes.makerOrder].wantTokenReceived_ = 0;
    } else {
      orders_[hashes.makerOrder].offerTokenRemaining_ = orders.makerOrder.offerTokenRemaining_;
      orders_[hashes.makerOrder].wantTokenReceived_ = orders.makerOrder.wantTokenReceived_;
    }

    if ((orders.takerOrder.offerTokenRemaining_ <= limit) ||
        (!orders.isMakerBuy && (orders.takerOrder.wantTokenReceived_ + limit) >= orders.takerOrder.wantTokenTotal_)
    ) {
      orders_[hashes.takerOrder].offerTokenRemaining_ = 0;
      orders_[hashes.takerOrder].wantTokenReceived_ = 0;
    } else {
      orders_[hashes.takerOrder].offerTokenRemaining_ = orders.takerOrder.offerTokenRemaining_;
      orders_[hashes.takerOrder].wantTokenReceived_ = orders.takerOrder.wantTokenReceived_;
    }

    // Transfer the external value, ether <> tokens
    __executeTokenTransfer__(
      ownedExternalAddressesAndTokenAddresses,
      amounts,
      wallets
    );

    // Log the order id(hash), amount of offer given, amount of offer remaining
    emit LogOrderFilled(hashes.makerOrder, orders.makerOrder.offerTokenRemaining_, orders.makerOrder.wantTokenReceived_);
    emit LogOrderFilled(hashes.takerOrder, orders.takerOrder.offerTokenRemaining_, orders.takerOrder.wantTokenReceived_);
    emit LogOrderExecutionSuccess(hashes.makerOrder, hashes.takerOrder, amounts.toMaker, amounts.toTaker);

    return true;
  }

  /**
   * @dev Set the fee rate for a specific quote
   * @param _quoteToken Quote token.
   * @param _edoPerQuote EdoPerQuote.
   * @param _edoPerQuoteDecimals EdoPerQuoteDecimals.
   * @return Success of the transaction.
   */
  function setFeeRate(
    address _quoteToken,
    uint256 _edoPerQuote,
    uint256 _edoPerQuoteDecimals
  ) external
    returns(bool)
  {
    require(
      msg.sender == owner_ || msg.sender == feeManager_,
      "msg.sender != owner, Exchange.setFeeRate()"
    );

    require(
      quotePriority[_quoteToken] != 0,
      "quotePriority[_quoteToken] == 0, Exchange.setFeeRate()"
    );

    feeEdoPerQuote[_quoteToken] = _edoPerQuote;
    feeEdoPerQuoteDecimals[_quoteToken] = _edoPerQuoteDecimals;

    emit LogFeeRateSet(_quoteToken, _edoPerQuote, _edoPerQuoteDecimals);

    return true;
  }

  /**
   * @dev Set the wallet for fees to be paid to.
   * @param eidooWallet Wallet to pay fees to.
   * @return Success of the transaction.
   */
  function setEidooWallet(
    address eidooWallet
  ) external
    returns(bool)
  {
    require(
      msg.sender == owner_,
      "msg.sender != owner, Exchange.setEidooWallet()"
    );
    eidooWallet_ = eidooWallet;
    return true;
  }

  /**
   * @dev Set a new order book account.
   * @param account The new order book account.
   */
  function setOrderBookAcount (
    address account
  ) external
    returns(bool)
  {
    require(
      msg.sender == owner_,
      "msg.sender != owner, Exchange.setOrderBookAcount()"
    );
    orderBookAccount_ = account;
    return true;
  }

  /**
   * @dev Set custom fee for a pair. If both _edoPerQuote and _edoPerQuoteDecimals are 0 there is no custom fee.
   *      If _edoPerQuote is 0 and _edoPerQuoteDecimals is greater than 0 the resulting fee rate is 0 (disable fee for the pair).
   * @param _baseTokenAddress The trade base token address that must skip fee calculation.
   * @param _quoteTokenAddress The trade quote token address that must skip fee calculation.
   * @param _edoPerQuote Rate
   * @param _edoPerQuoteDecimals Rate decimals
   */
  function setCustomFee (
    address _baseTokenAddress,
    address _quoteTokenAddress,
    uint256 _edoPerQuote,
    uint256 _edoPerQuoteDecimals
  ) external
    returns(bool)
  {
    // Preserving same owner check style
    require(
      msg.sender == owner_ || msg.sender == feeManager_,
      "msg.sender != owner, Exchange.setCustomFee()"
    );
    if (_edoPerQuote == 0 && _edoPerQuoteDecimals == 0) {
      delete customFee[_baseTokenAddress][_quoteTokenAddress];
    } else {
      customFee[_baseTokenAddress][_quoteTokenAddress] = FeeRate({
        edoPerQuote: _edoPerQuote,
        edoPerQuoteDecimals: _edoPerQuoteDecimals
      });
    }
    emit LogCustomFeeSet(_baseTokenAddress, _quoteTokenAddress, _edoPerQuote, _edoPerQuoteDecimals);
    return true;
  }

  /**
   *  For backward compatibility
   */
  function mustSkipFee(address base, address quote) external view returns(bool) {
    FeeRate storage rate = customFee[base][quote];
    return rate.edoPerQuote == 0 && rate.edoPerQuoteDecimals != 0;
  }

  /**
   * @dev Set a taker EOA in the fees whitelist
   * @param _takerEOA EOA address of the taker
   * @param _value true if the take should not pay fees
   *
   */
  function setFeeTakersWhitelist(
    address _takerEOA,
    bool _value
  ) external
    returns(bool)
  {
    require(
      msg.sender == owner_,
      "msg.sender != owner, Exchange.setFeeTakersWhitelist()"
    );
    feeTakersWhitelist[_takerEOA] = _value;
    emit LogFeeTakersWhitelistSet(_takerEOA, _value);
    return true;
  }

  /**
   * @dev Set quote priority token.
   * Set the sorting of token quote based on a priority.
   * @param _token The address of the token that was deposited.
   * @param _priority The amount of the token that was deposited.
   * @return Operation success.
   */

  function setQuotePriority(address _token, uint256 _priority)
    external
    returns(bool)
  {
    require(
      msg.sender == owner_,
      "msg.sender != owner, Exchange.setQuotePriority()"
    );
    quotePriority[_token] = _priority;
    emit LogQuotePrioritySet(_token, _priority);
    return true;
  }

  /*
   Methods to catch events from external contracts, user wallets primarily
   */

  /**
   * @dev DEPRECATED!
   * Simply log the event to track wallet interaction off-chain.
   * @param tokenAddress The address of the token that was deposited.
   * @param amount The amount of the token that was deposited.
   * @param tradingWalletBalance The updated balance of the wallet after deposit.
   */
  function walletDeposit(
    address tokenAddress,
    uint256 amount,
    uint256 tradingWalletBalance
  ) external
  {
    emit LogWalletDeposit(msg.sender, tokenAddress, amount, tradingWalletBalance);
  }

  /**
   * @dev DEPRECATED!
   * Simply log the event to track wallet interaction off-chain.
   * @param tokenAddress The address of the token that was deposited.
   * @param amount The amount of the token that was deposited.
   * @param tradingWalletBalance The updated balance of the wallet after deposit.
   */
  function walletWithdrawal(
    address tokenAddress,
    uint256 amount,
    uint256 tradingWalletBalance
  ) external
  {
    emit LogWalletWithdrawal(msg.sender, tokenAddress, amount, tradingWalletBalance);
  }

  /**
   * Private
   */

  /**
   * @dev Convenient function to resolve call stack size error in ExchangeV3
   * @param ownedExternalAddressesAndTokenAddresses -
   */
  function getMakerAndTakerTradingWallets(address[4] ownedExternalAddressesAndTokenAddresses)
    private
    returns (TradingWallets wallets)
  {
    wallets = TradingWallets(
      WalletV3(users.retrieveWallet(ownedExternalAddressesAndTokenAddresses[0])), // maker
      WalletV3(users.retrieveWallet(ownedExternalAddressesAndTokenAddresses[2])) // taker
    );

    // Operating on existing tradingWallets
    require(
      wallets.maker != address(0),
      "Maker wallet does not exist, Exchange.getMakerAndTakerTradingWallets()"
    );

    require(
      wallets.taker != address(0),
      "Taker wallet does not exist, Exchange.getMakerAndTakerTradingWallets()"
    );
  }

  function calculateFee(
    address base,
    address quote,
    uint256 quoteAmount,
    address takerEOA
  ) public
    view
    returns(uint256)
  {
    require(quotePriority[quote] > quotePriority[base], "Invalid pair");
    return __calculateFee__(base, quote, quoteAmount, takerEOA);
  }

  function __calculateFee__(
    address base,
    address quote,
    uint256 quoteAmount,
    address takerEOA
  )
    internal view returns(uint256)
  {
    FeeRate memory fee;
    if (feeTakersWhitelist[takerEOA]) {
      return 0;
    }

    // weiAmount * (fee %) * (EDO/Wei) / (decimals in edo/wei) / (decimals in percentage)
      fee = customFee[base][quote];
      if (fee.edoPerQuote == 0 && fee.edoPerQuoteDecimals == 0) {
        // no custom fee
        fee.edoPerQuote = feeEdoPerQuote[quote];
        fee.edoPerQuoteDecimals = feeEdoPerQuoteDecimals[quote];
      }
      return quoteAmount.mul(fee.edoPerQuote).div(10**fee.edoPerQuoteDecimals);
  }

  /**
   * @dev Verify the input to order execution is valid.
   * @param ownedExternalAddressesAndTokenAddresses The maker and taker external owned accounts addresses and offered tokens contracts.
   * [
   *   makerEOA
   *   makerOfferToken
   *   takerEOA
   *   takerOfferToken
   * ]
   * @param amountsExpirationsAndSalts The amount of tokens and the block number at which this order expires and a random number to mitigate replay.
   * [
   *   makerOffer
   *   makerWant
   *   takerOffer
   *   takerWant
   *   makerExpiry
   *   makerSalt
   *   takerExpiry
   *   takerSalt
   * ]
   * @return Success if all checks pass.
   */
  function __executeOrderInputIsValid__(
    address[4] ownedExternalAddressesAndTokenAddresses,
    uint256[8] amountsExpirationsAndSalts
  ) private view
  {
    // msg.send needs to be the orderBookAccount
    require(
      msg.sender == orderBookAccount_ || msg.sender == address(this),
      "msg.sender != orderBookAccount, Exchange.__executeOrderInputIsValid__()"
    );

    // Check expirations base on the block number
    require (
      block.number <= amountsExpirationsAndSalts[4],
      "Maker order has expired, Exchange.__executeOrderInputIsValid__()"
    );

    require(
      block.number <= amountsExpirationsAndSalts[6],
      "Taker order has expired, Exchange.__executeOrderInputIsValid__()"
    );

    require(
      quotePriority[ownedExternalAddressesAndTokenAddresses[1]] != quotePriority[ownedExternalAddressesAndTokenAddresses[3]],
      "Quote token is omitted! Is not offered by either the Taker or Maker, Exchange.__executeOrderInputIsValid__()"
    );

    // Check that none of the amounts is = to 0
    if (
        amountsExpirationsAndSalts[0] == 0 ||
        amountsExpirationsAndSalts[1] == 0 ||
        amountsExpirationsAndSalts[2] == 0 ||
        amountsExpirationsAndSalts[3] == 0
      )
    {
      revert("May not execute an order where token amount == 0, Exchange.__executeOrderInputIsValid__()");
    }
  }

  function __getBalance__(address token, address owner) private view returns(uint256) {
    if (token == address(0)) {
      return owner.balance;
    } else {
      return Token(token).balanceOf(owner);
    }
  }

  /**
   * @dev Execute the external transfer of tokens.
   * @param ownedExternalAddressesAndTokenAddresses The maker and taker external owned accounts addresses and offered tokens contracts.
   * [
   *   makerEOA
   *   makerOfferToken
   *   takerEOA
   *   takerOfferToken
   * ]
   * @param amounts The amount of tokens to transfer.
   * @return Success if both wallets verify the order.
   */
  function __executeTokenTransfer__(
    address[4] ownedExternalAddressesAndTokenAddresses,
    TradingAmounts amounts,
    TradingWallets wallets
  ) private
  {

    // Get balances. Must be taken before trading wallet verifyOrder() call because it can transfer ethers
    Balances memory initialBalances;
    initialBalances.takerOfferTokenBalance = __getBalance__(ownedExternalAddressesAndTokenAddresses[3], wallets.taker);
    initialBalances.makerOfferTokenBalance = __getBalance__(ownedExternalAddressesAndTokenAddresses[1], wallets.maker);
    initialBalances.takerWantTokenBalance = __getBalance__(ownedExternalAddressesAndTokenAddresses[1], wallets.taker);
    initialBalances.makerWantTokenBalance = __getBalance__(ownedExternalAddressesAndTokenAddresses[3], wallets.maker);
    //    initialBalances.takerFeeTokenBalance = __getBalance__(edoToken_, wallets.taker);


    // Wallet Order Verification, reach out to the maker and taker wallets. Approve the tokens and transfer ethers
    // to the exchange contract
    require(
      wallets.maker.verifyOrder(
        ownedExternalAddressesAndTokenAddresses[1],
        amounts.toTaker,
        0,
        0
      ),
      "Maker wallet could not prepare the transfer, Exchange.__executeTokenTransfer__()"
    );

    require(
      wallets.taker.verifyOrder(
        ownedExternalAddressesAndTokenAddresses[3],
        amounts.toMaker,
        amounts.fee,
        edoToken_
      ),
      "Taker wallet could not prepare the transfer, Exchange.__executeTokenTransfer__()"
    );

    // Wallet mapping balances
    address makerOfferTokenAddress = ownedExternalAddressesAndTokenAddresses[1];
    address takerOfferTokenAddress = ownedExternalAddressesAndTokenAddresses[3];

    WalletV3 makerTradingWallet = wallets.maker;
    WalletV3 takerTradingWallet = wallets.taker;

    // Taker to pay fee before trading
    if(amounts.fee != 0) {
      uint256 takerInitialFeeTokenBalance = Token(edoToken_).balanceOf(takerTradingWallet);

      require(
        Token(edoToken_).transferFrom(takerTradingWallet, eidooWallet_, amounts.fee),
        "Cannot transfer fees from taker trading wallet to eidoo wallet, Exchange.__executeTokenTransfer__()"
      );
      require(
        Token(edoToken_).balanceOf(takerTradingWallet) == takerInitialFeeTokenBalance.sub(amounts.fee),
        "Wrong fee token balance after transfer, Exchange.__executeTokenTransfer__()"
      );
    }

    // Ether to the taker and tokens to the maker
    if (makerOfferTokenAddress == address(0)) {
      address(takerTradingWallet).transfer(amounts.toTaker);
    } else {
      require(
        SafeERC20.safeTransferFrom(makerOfferTokenAddress, makerTradingWallet, takerTradingWallet, amounts.toTaker),
        "Token transfership from makerTradingWallet to takerTradingWallet failed, Exchange.__executeTokenTransfer__()"
      );
    }

    if (takerOfferTokenAddress == address(0)) {
      address(makerTradingWallet).transfer(amounts.toMaker);
    } else {
      require(
        SafeERC20.safeTransferFrom(takerOfferTokenAddress, takerTradingWallet, makerTradingWallet, amounts.toMaker),
        "Token transfership from takerTradingWallet to makerTradingWallet failed, Exchange.__executeTokenTransfer__()"
      );
    }

    // Check balances
    Balances memory expected;
    if (takerTradingWallet != makerTradingWallet) {
      expected.makerWantTokenBalance = initialBalances.makerWantTokenBalance.add(amounts.toMaker);
      expected.makerOfferTokenBalance = initialBalances.makerOfferTokenBalance.sub(amounts.toTaker);
      expected.takerWantTokenBalance = edoToken_ == makerOfferTokenAddress
        ? initialBalances.takerWantTokenBalance.add(amounts.toTaker).sub(amounts.fee)
        : initialBalances.takerWantTokenBalance.add(amounts.toTaker);
      expected.takerOfferTokenBalance = edoToken_ == takerOfferTokenAddress
        ? initialBalances.takerOfferTokenBalance.sub(amounts.toMaker).sub(amounts.fee)
        : initialBalances.takerOfferTokenBalance.sub(amounts.toMaker);
    } else {
      expected.makerWantTokenBalance = expected.takerOfferTokenBalance =
        edoToken_ == takerOfferTokenAddress
        ? initialBalances.takerOfferTokenBalance.sub(amounts.fee)
        : initialBalances.takerOfferTokenBalance;
      expected.makerOfferTokenBalance = expected.takerWantTokenBalance =
        edoToken_ == makerOfferTokenAddress
        ? initialBalances.takerWantTokenBalance.sub(amounts.fee)
        : initialBalances.takerWantTokenBalance;
    }

    require(
      expected.takerOfferTokenBalance == __getBalance__(takerOfferTokenAddress, takerTradingWallet),
      "Wrong taker offer token balance after transfer, Exchange.__executeTokenTransfer__()"
    );
    require(
      expected.makerOfferTokenBalance == __getBalance__(makerOfferTokenAddress, makerTradingWallet),
      "Wrong maker offer token balance after transfer, Exchange.__executeTokenTransfer__()"
    );
    require(
      expected.takerWantTokenBalance == __getBalance__(makerOfferTokenAddress, takerTradingWallet),
      "Wrong taker want token balance after transfer, Exchange.__executeTokenTransfer__()"
    );
    require(
      expected.makerWantTokenBalance == __getBalance__(takerOfferTokenAddress, makerTradingWallet),
      "Wrong maker want token balance after transfer, Exchange.__executeTokenTransfer__()"
    );
  }

  /**
   * @dev Calculates Keccak-256 hash of order with specified parameters.
   * @param ownedExternalAddressesAndTokenAddresses The orders maker EOA and current exchange address.
   * @param amountsExpirationsAndSalts The orders offer and want amounts and expirations with salts.
   * @return Keccak-256 hash of the passed order.
   */
  function generateOrderHashes(
    address[4] ownedExternalAddressesAndTokenAddresses,
    uint256[8] amountsExpirationsAndSalts
  ) public
    view
    returns (bytes32[2])
  {
    OrdersHashes memory hashes = __generateOrderHashes__(
      ownedExternalAddressesAndTokenAddresses,
      amountsExpirationsAndSalts
    );
    return [hashes.makerOrder, hashes.takerOrder];
  }

  function __generateOrderHashes__(
    address[4] ownedExternalAddressesAndTokenAddresses,
    uint256[8] amountsExpirationsAndSalts
  ) internal
    view
    returns (OrdersHashes)
  {
    bytes32 makerOrderHash = keccak256(abi.encodePacked(
      address(this),
      ownedExternalAddressesAndTokenAddresses[0], // _makerEOA
      ownedExternalAddressesAndTokenAddresses[1], // offerToken
      amountsExpirationsAndSalts[0],  // offerTokenAmount
      ownedExternalAddressesAndTokenAddresses[3], // wantToken
      amountsExpirationsAndSalts[1],  // wantTokenAmount
      amountsExpirationsAndSalts[4], // expiry
      amountsExpirationsAndSalts[5] // salt
    ));

    bytes32 takerOrderHash = keccak256(abi.encodePacked(
      address(this),
      ownedExternalAddressesAndTokenAddresses[2], // _makerEOA
      ownedExternalAddressesAndTokenAddresses[3], // offerToken
      amountsExpirationsAndSalts[2],  // offerTokenAmount
      ownedExternalAddressesAndTokenAddresses[1], // wantToken
      amountsExpirationsAndSalts[3],  // wantTokenAmount
      amountsExpirationsAndSalts[6], // expiry
      amountsExpirationsAndSalts[7] // salt
    ));

    return OrdersHashes(makerOrderHash, takerOrderHash);
  }

  function __getOrders__(
    address[4] ownedExternalAddressesAndTokenAddresses,
    uint256[8] amountsExpirationsAndSalts,
    OrdersHashes hashes
  ) private
    returns(Orders orders)
  {
    OrderStatus storage makerOrderStatus = orders_[hashes.makerOrder];
    OrderStatus storage takerOrderStatus = orders_[hashes.takerOrder];

    orders.makerOrder.offerToken_ = ownedExternalAddressesAndTokenAddresses[1];
    orders.makerOrder.offerTokenTotal_ = amountsExpirationsAndSalts[0];
    orders.makerOrder.wantToken_ = ownedExternalAddressesAndTokenAddresses[3];
    orders.makerOrder.wantTokenTotal_ = amountsExpirationsAndSalts[1];

    if (makerOrderStatus.expirationBlock_ > 0) {  // Check for existence
      // Orders still active
      require(
        makerOrderStatus.offerTokenRemaining_ != 0,
        "Maker order is inactive, Exchange.executeOrder()"
      );
      orders.makerOrder.offerTokenRemaining_ = makerOrderStatus.offerTokenRemaining_; // Amount to give
      orders.makerOrder.wantTokenReceived_ = makerOrderStatus.wantTokenReceived_; // Amount received
    } else {
      makerOrderStatus.expirationBlock_ = amountsExpirationsAndSalts[4]; // maker order expiration block, persist order on storage
      orders.makerOrder.offerTokenRemaining_ = amountsExpirationsAndSalts[0]; // Amount to give
      orders.makerOrder.wantTokenReceived_ = 0; // Amount received
    }

    orders.takerOrder.offerToken_ = ownedExternalAddressesAndTokenAddresses[3];
    orders.takerOrder.offerTokenTotal_ = amountsExpirationsAndSalts[2];
    orders.takerOrder.wantToken_ = ownedExternalAddressesAndTokenAddresses[1];
    orders.takerOrder.wantTokenTotal_ = amountsExpirationsAndSalts[3];

    if (takerOrderStatus.expirationBlock_ > 0) {  // Check for existence
      require(
        takerOrderStatus.offerTokenRemaining_ != 0,
        "Taker order is inactive, Exchange.executeOrder()"
      );
      orders.takerOrder.offerTokenRemaining_ = takerOrderStatus.offerTokenRemaining_;  // Amount to give
      orders.takerOrder.wantTokenReceived_ = takerOrderStatus.wantTokenReceived_; // Amount received
    } else {
      takerOrderStatus.expirationBlock_ = amountsExpirationsAndSalts[6]; // taker order expiration block, persist order on storage
      orders.takerOrder.offerTokenRemaining_ = amountsExpirationsAndSalts[2];  // Amount to give
      orders.takerOrder.wantTokenReceived_ = 0; // Amount received
    }

    orders.isMakerBuy = __isSell__(orders.takerOrder);
  }

  /**
   * @dev Returns a bool representing a SELL or BUY order based on quotePriority.
   * @param _order The maker order data structure.
   * @return The bool indicating if the order is a SELL or BUY.
   */
  function __isSell__(Order _order) internal view returns (bool) {
    return quotePriority[_order.offerToken_] < quotePriority[_order.wantToken_];
  }

  /**
   * @dev Compute the tradeable amounts of the two verified orders.
   * Token amount is the __min__ remaining between want and offer of the two orders that isn"t ether.
   * Ether amount is then: etherAmount = tokenAmount * priceRatio, as ratio = eth / token.
   * @param orders The maker and taker orders data structure.
   * @return The amount moving from makerOfferRemaining to takerWantRemaining and vice versa.
   */
  function __getTradeAmounts__(
    Orders memory orders,
    address takerEOA
  ) internal
    view
    returns (TradingAmounts)
  {
    Order memory makerOrder = orders.makerOrder;
    Order memory takerOrder = orders.takerOrder;
    bool isMakerBuy = orders.isMakerBuy;  // maker buy = taker sell
    uint256 priceRatio;
    uint256 makerAmountLeftToReceive;
    uint256 takerAmountLeftToReceive;

    uint toTakerAmount;
    uint toMakerAmount;

    if (makerOrder.offerTokenTotal_ >= makerOrder.wantTokenTotal_) {
      priceRatio = makerOrder.offerTokenTotal_.mul(2**128).div(makerOrder.wantTokenTotal_);
      require(
        priceRatio >= takerOrder.wantTokenTotal_.mul(2**128).div(takerOrder.offerTokenTotal_),
        "Taker price is greater than maker price, Exchange.__getTradeAmounts__()"
      );
      if (isMakerBuy) {
        // MP > 1
        makerAmountLeftToReceive = makerOrder.wantTokenTotal_.sub(makerOrder.wantTokenReceived_);
        toMakerAmount = __min__(takerOrder.offerTokenRemaining_, makerAmountLeftToReceive);
        // add 2**128-1 in order to obtain a round up
        toTakerAmount = toMakerAmount.mul(priceRatio).div(2**128);
      } else {
        // MP < 1
        takerAmountLeftToReceive = takerOrder.wantTokenTotal_.sub(takerOrder.wantTokenReceived_);
        toTakerAmount = __min__(makerOrder.offerTokenRemaining_, takerAmountLeftToReceive);
        toMakerAmount = toTakerAmount.mul(2**128).div(priceRatio);
      }
    } else {
      priceRatio = makerOrder.wantTokenTotal_.mul(2**128).div(makerOrder.offerTokenTotal_);
      require(
        priceRatio <= takerOrder.offerTokenTotal_.mul(2**128).div(takerOrder.wantTokenTotal_),
        "Taker price is less than maker price, Exchange.__getTradeAmounts__()"
      );
      if (isMakerBuy) {
        // MP < 1
        makerAmountLeftToReceive = makerOrder.wantTokenTotal_.sub(makerOrder.wantTokenReceived_);
        toMakerAmount = __min__(takerOrder.offerTokenRemaining_, makerAmountLeftToReceive);
        toTakerAmount = toMakerAmount.mul(2**128).div(priceRatio);
      } else {
        // MP > 1
        takerAmountLeftToReceive = takerOrder.wantTokenTotal_.sub(takerOrder.wantTokenReceived_);
        toTakerAmount = __min__(makerOrder.offerTokenRemaining_, takerAmountLeftToReceive);
        // add 2**128-1 in order to obtain a round up
        toMakerAmount = toTakerAmount.mul(priceRatio).div(2**128);
      }
    }

    uint fee = isMakerBuy
      ? __calculateFee__(makerOrder.wantToken_, makerOrder.offerToken_, toTakerAmount, takerEOA)
      : __calculateFee__(makerOrder.offerToken_, makerOrder.wantToken_, toMakerAmount, takerEOA);

    return TradingAmounts(toTakerAmount, toMakerAmount, fee);
  }

  /**
   * @dev Return the maximum of two uints
   * @param a Uint 1
   * @param b Uint 2
   * @return The grater value or a if equal
   */
  function __max__(uint256 a, uint256 b)
    private
    pure
    returns (uint256)
  {
    return a < b
      ? b
      : a;
  }

  /**
   * @dev Return the minimum of two uints
   * @param a Uint 1
   * @param b Uint 2
   * @return The smallest value or b if equal
   */
  function __min__(uint256 a, uint256 b)
    private
    pure
    returns (uint256)
  {
    return a < b
      ? a
      : b;
  }

  /**
   * @dev On chain verification of an ECDSA ethereum signature.
   * @param signer The EOA address of the account that supposedly signed the message.
   * @param orderHash The on-chain generated hash for the order.
   * @param v ECDSA signature parameter v.
   * @param r ECDSA signature parameter r.
   * @param s ECDSA signature parameter s.
   * @return Bool if the signature is valid or not.
   */
  function __signatureIsValid__(
    address signer,
    bytes32 orderHash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) private
    pure
    returns (bool)
  {
    address recoveredAddr = ecrecover(
      keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)),
      v,
      r,
      s
    );

    return recoveredAddr == signer;
  }

  /**
   * @dev Confirm wallet local balances and token balances match.
   * @param makerTradingWallet  Maker wallet address.
   * @param takerTradingWallet  Taker wallet address.
   * @param token  Token address to confirm balances match.
   * @return If the balances do match.
   */
  function __tokenAndWalletBalancesMatch__(
    address makerTradingWallet,
    address takerTradingWallet,
    address token
  ) private
    view
    returns(bool)
  {
    if (Token(token).balanceOf(makerTradingWallet) != WalletV3(makerTradingWallet).balanceOf(token)) {
      return false;
    }

    if (Token(token).balanceOf(takerTradingWallet) != WalletV3(takerTradingWallet).balanceOf(token)) {
      return false;
    }

    return true;
  }

  /**
 * @dev Withdraw asset.
 * @param _tokenAddress Asset to be withdrawed.
 * @return bool.
 */
  function withdraw(address _tokenAddress)
    public
    onlyOwner
  returns(bool)
  {
    uint tokenBalance;
    if (_tokenAddress == address(0)) {
      tokenBalance = address(this).balance;
      msg.sender.transfer(tokenBalance);
    } else {
      tokenBalance = Token(_tokenAddress).balanceOf(address(this));
      require(
        Token(_tokenAddress).transfer(msg.sender, tokenBalance),
        "withdraw transfer failed"
      );
    }
    emit LogWithdraw(msg.sender, _tokenAddress, tokenBalance);
    return true;
  }

}