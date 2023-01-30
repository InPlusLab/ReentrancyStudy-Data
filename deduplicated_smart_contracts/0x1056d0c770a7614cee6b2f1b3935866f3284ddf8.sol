/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

pragma solidity ^0.4.24;

// File: contracts/math/SafeMath.sol

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

// @title SafeMath: overflow/underflow checks
// @notice Math operations with safety checks that throw on error
library SafeMath {

  // @notice Multiplies two numbers, throws on overflow.
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  // @notice Integer division of two numbers, truncating the quotient.
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  // @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  // @notice Adds two numbers, throws on overflow.
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  // @notice Returns fractional amount
  function getFractionalAmount(uint256 _amount, uint256 _percentage)
  internal
  pure
  returns (uint256) {
    return div(mul(_amount, _percentage), 100);
  }

}

// File: contracts/interfaces/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20 {
  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interfaces/DividendInterface.sol

interface DividendInterface{
  function issueDividends(uint _amount) external payable returns (bool);

  // @dev Total number of tokens in existence
  function totalSupply() external view returns (uint256);

  function getERC20() external view returns (address);
}

// File: contracts/interfaces/KyberInterface.sol

// @notice Trade via the Kyber Proxy Contract
interface KyberInterface {
  function getExpectedRate(address src, address dest, uint srcQty) external view returns (uint expectedRate, uint slippageRate);
  function trade(address src, uint srcAmount, address dest, address destAddress, uint maxDestAmount,uint minConversionRate, address walletId) external payable returns(uint);
}

// File: contracts/interfaces/MinterInterface.sol

interface MinterInterface {
  function cloneToken(string _uri, address _erc20Address) external returns (address asset);

  function mintAssetTokens(address _assetAddress, address _receiver, uint256 _amount) external returns (bool);

  function changeTokenController(address _assetAddress, address _newController) external returns (bool);
}

// File: contracts/interfaces/CrowdsaleReserveInterface.sol

interface CrowdsaleReserveInterface {
  function issueETH(address _receiver, uint256 _amount) external returns (bool);
  function receiveETH(address _payer) external payable returns (bool);
  function refundETHAsset(address _asset, uint256 _amount) external returns (bool);
  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);
  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);
  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);
  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool);
}

// File: contracts/crowdsale/CrowdsaleERC20.sol

interface Events {
  function transaction(string _message, address _from, address _to, uint _amount, address _token)  external;
  function asset(string _message, string _uri, address _assetAddress, address _manager);
}
interface DB {
  function addressStorage(bytes32 _key) external view returns (address);
  function uintStorage(bytes32 _key) external view returns (uint);
  function setUint(bytes32 _key, uint _value) external;
  function deleteUint(bytes32 _key) external;
  function setBool(bytes32 _key, bool _value) external;
  function boolStorage(bytes32 _key) external view returns (bool);
}

// @title An asset crowdsale contract which accepts funding from ERC20 tokens.
// @notice Begins a crowdfunding period for a digital asset, minting asset dividend tokens to investors when particular ERC20 token is received
// @author Kyle Dewhurst, MyBit Foundation
// @notice creates a dividend token to represent the newly created asset.
contract CrowdsaleERC20{
  using SafeMath for uint256;

  DB private database;
  Events private events;
  MinterInterface private minter;
  CrowdsaleReserveInterface private reserve;
  KyberInterface private kyber;

  // @notice Constructor: initializes database instance
  // @param: The address for the platform database
  constructor(address _database, address _events, address _kyber)
  public{
      database = DB(_database);
      events = Events(_events);
      minter = MinterInterface(database.addressStorage(keccak256(abi.encodePacked("contract", "Minter"))));
      reserve = CrowdsaleReserveInterface(database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleReserve"))));
      kyber = KyberInterface(_kyber);
  }

  // @notice Investors can send ERC20 tokens here to fund an asset, receiving an equivalent number of asset-tokens.
  // @dev investor must approve this contract to transfer tokens
  // @param (address) _assetAddress = The address of the asset tokens, investor wishes to purchase
  // @param (uint) _amount = The amount to spend purchasing this asset
  function buyAssetOrderERC20(address _assetAddress, uint _amount, address _paymentToken)
  external
  payable
  returns (bool) {
    require(database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))) != address(0), "Invalid asset");
    require(now <= database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Past deadline");
    require(!database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress))), "Crowdsale finalized");

    if(_paymentToken == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)){
      require(msg.value == _amount, 'Msg.value does not match amount');
    } else {
      require(msg.value == 0, 'Msg.value should equal zero');
    }
    ERC20 fundingToken = ERC20(DividendInterface(_assetAddress).getERC20());
    uint fundingRemaining = database.uintStorage(keccak256(abi.encodePacked("crowdsale.remaining", _assetAddress)));
    uint collected; //This will be the value received by the contract after any conversions
    uint amount; //The number of tokens that will be minted
    //Check if the payment token is the same as the funding token. If not, convert, else just collect the funds
    if(_paymentToken == address(fundingToken)){
      collected = collectPayment(msg.sender, _amount, fundingRemaining, fundingToken);
    } else {
      collected = convertTokens(msg.sender, _amount, fundingToken, ERC20(_paymentToken), fundingRemaining);
    }
    require(collected > 0);
    if(collected < fundingRemaining){
      amount = collected.mul(100).div(uint(100).add(database.uintStorage(keccak256(abi.encodePacked("platform.fee")))));
      database.setUint(keccak256(abi.encodePacked("crowdsale.remaining", _assetAddress)), fundingRemaining.sub(collected));
      require(minter.mintAssetTokens(_assetAddress, msg.sender, amount), "Investor minting failed");
      require(fundingToken.transfer(address(reserve), collected));
    } else {
      amount = fundingRemaining.mul(100).div(uint(100).add(database.uintStorage(keccak256(abi.encodePacked("platform.fee")))));
      database.setBool(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress)), true);
      database.deleteUint(keccak256(abi.encodePacked("crowdsale.remaining", _assetAddress)));
      require(minter.mintAssetTokens(_assetAddress, msg.sender, amount), "Investor minting failed");   // Send remaining asset tokens to investor
      require(fundingToken.transfer(address(reserve), fundingRemaining));
      events.asset('Crowdsale finalized', '', _assetAddress, msg.sender);
      if(collected > fundingRemaining){
        require(fundingToken.transfer(msg.sender, collected.sub(fundingRemaining)));    // return extra funds
      }
    }
    events.transaction('Asset purchased', address(this), msg.sender, amount, _assetAddress);
    return true;
  }

  // @notice This is called once funding has succeeded. Sends Ether to a distribution contract where operator/assetManager can withdraw
  // @dev The contract manager needs to know  the address PlatformDistribution contract
  function payoutERC20(address _assetAddress)
  external
  whenNotPaused
  returns (bool) {
    require(database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress))), "Crowdsale not finalized");
    require(!database.boolStorage(keccak256(abi.encodePacked("crowdsale.paid", _assetAddress))), "Crowdsale has paid out");
    //Set paid to true
    database.setBool(keccak256(abi.encodePacked("crowdsale.paid", _assetAddress)), true);
    //Setup token
    address fundingToken = DividendInterface(_assetAddress).getERC20();
    //Mint tokens for the asset manager and platform
    address platformAssetsWallet = database.addressStorage(keccak256(abi.encodePacked("platform.wallet.assets")));
    require(platformAssetsWallet != address(0), "Platform assets wallet not set");
    require(minter.mintAssetTokens(_assetAddress, database.addressStorage(keccak256(abi.encodePacked("contract", "AssetManagerFunds"))), database.uintStorage(keccak256(abi.encodePacked("asset.managerTokens", _assetAddress)))), "Manager minting failed");
    require(minter.mintAssetTokens(_assetAddress, platformAssetsWallet, database.uintStorage(keccak256(abi.encodePacked("asset.platformTokens", _assetAddress)))), "Platform minting failed");
    //Get the addresses for the receiver and platform
    address receiver = database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
    address platformFundsWallet = database.addressStorage(keccak256(abi.encodePacked("platform.wallet.funds")));
    require(receiver != address(0) && platformFundsWallet != address(0), "Platform funds walllet or receiver address not set");
    //Calculate amounts for platform and receiver
    uint amount = database.uintStorage(keccak256(abi.encodePacked("crowdsale.goal", _assetAddress)));
    uint platformFee = amount.getFractionalAmount(database.uintStorage(keccak256(abi.encodePacked("platform.fee"))));
    //Transfer funds to receiver and platform
    require(reserve.issueERC20(platformFundsWallet, platformFee, fundingToken), 'Platform funds not paid');
    require(reserve.issueERC20(receiver, amount, fundingToken), 'Receiver funds not paid');
    //Delete crowdsale start time
    database.deleteUint(keccak256(abi.encodePacked("crowdsale.start", _assetAddress)));
    //Increase asset count for manager
    address manager = database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
    database.setUint(keccak256(abi.encodePacked("manager.assets", manager)), database.uintStorage(keccak256(abi.encodePacked("manager.assets", manager))).add(1));
    //Emit event
    events.transaction('Asset payout', _assetAddress, receiver, amount, fundingToken);
    return true;
  }

  function cancel(address _assetAddress)
  external
  whenNotPaused
  validAsset(_assetAddress)
  beforeDeadline(_assetAddress)
  notFinalized(_assetAddress)
  returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))));
    database.setUint(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress)), 1);
    refund(_assetAddress);
  }

  // @notice Contributors can retrieve their funds here if crowdsale has paased deadline
  // @param (address) _assetAddress =  The address of the asset which didn't reach it's crowdfunding goals
  function refund(address _assetAddress)
  public
  whenNotPaused
  validAsset(_assetAddress)
  afterDeadline(_assetAddress)
  notFinalized(_assetAddress)
  returns (bool) {
    require(database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))) != 0);
    database.deleteUint(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress)));
    DividendInterface assetToken = DividendInterface(_assetAddress);
    address tokenAddress = assetToken.getERC20();
    uint refundValue = assetToken.totalSupply().mul(uint(100).add(database.uintStorage(keccak256(abi.encodePacked("platform.fee"))))).div(100); //total supply plus platform fees
    reserve.refundERC20Asset(_assetAddress, refundValue, tokenAddress);
    return true;
  }

  //------------------------------------------------------------------------------------------------------------------
  //                                            Internal Functions
  //------------------------------------------------------------------------------------------------------------------

  function collectPayment(address user, uint amount, uint max, ERC20 token)
  private
  returns (uint){
    if(amount > max){
      token.transferFrom(user, address(this), max);
      return max;
    } else {
      token.transferFrom(user, address(this), amount);
      return amount;
    }
  }

  /*
  function fundBurn(address _investor, uint _amount, bytes4 _sig, ERC20 _burnToken)
  private
  returns (uint) {
    require(_burnToken.transferFrom(_investor, address(this), _amount), "Transfer failed"); // transfer investors tokens into contract
    uint balanceBefore = _burnToken.balanceOf(this);
    require(burner.burn(address(this), database.uintStorage(keccak256(abi.encodePacked(_sig, address(this)))), address(_burnToken)));
    uint change = _burnToken.balanceOf(this) - balanceBefore;
    return change;
  }
  */

  function convertTokens(address _investor, uint _amount, /*bytes4 _sig,*/ ERC20 _fundingToken, ERC20 _paymentToken, uint _maxTokens)
  private
  returns (uint) {
    //( , uint minRate) = kyber.getExpectedRate(address(_paymentToken), address(_fundingToken), 0);
    uint paymentBalanceBefore;
    uint fundingBalanceBefore;
    uint change;
    uint investment;
    if(address(_paymentToken) == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)){
      paymentBalanceBefore = address(this).balance;
      fundingBalanceBefore = _fundingToken.balanceOf(this);
      //Convert remaining funds into the funding token
      kyber.trade.value(_amount)(address(_paymentToken), _amount, address(_fundingToken), address(this), _maxTokens, 0, 0);
      change = _amount.sub(paymentBalanceBefore.sub(address(this).balance));
      investment = _fundingToken.balanceOf(this).sub(fundingBalanceBefore);
      if(change > 0){
        _investor.transfer(change);
      }
    } else {
      //Collect funds
      collectPayment(_investor, _amount, _amount, _paymentToken);
      // Mitigate ERC20 Approve front-running attack, by initially setting
      // allowance to 0
      require(_paymentToken.approve(address(kyber), 0));
      // Approve tokens so network can take them during the swap
      _paymentToken.approve(address(kyber), _amount);
      paymentBalanceBefore = _paymentToken.balanceOf(this);
      fundingBalanceBefore = _fundingToken.balanceOf(this);
      //Convert remaining funds into the funding token
      kyber.trade(address(_paymentToken), _amount, address(_fundingToken), address(this), _maxTokens, 0, 0);
      // Return any remaining source tokens to user
      change = _amount.sub(paymentBalanceBefore.sub(_paymentToken.balanceOf(this)));
      investment = _fundingToken.balanceOf(this).sub(fundingBalanceBefore);
      if(change > 0){
        _paymentToken.transfer(_investor, change);
      }
    }

    emit Convert(address(_paymentToken), change, investment);
    return investment;
  }

  // @notice platform owners can recover tokens here
  function recoverTokens(address _erc20Token)
  onlyOwner
  external {
    ERC20 thisToken = ERC20(_erc20Token);
    uint contractBalance = thisToken.balanceOf(address(this));
    thisToken.transfer(msg.sender, contractBalance);
  }

  // @notice platform owners can destroy contract here
  function destroy()
  onlyOwner
  external {
    events.transaction('CrowdsaleERC20 destroyed', address(this), msg.sender, address(this).balance, address(0));
    //emit LogDestruction(address(this).balance, msg.sender);
    selfdestruct(msg.sender);
  }

  // @notice fallback function. We need to receive Ether from Kyber Network
  function ()
  external
  payable {
    emit EtherReceived(msg.sender, msg.value);
  }

  //------------------------------------------------------------------------------------------------------------------
  //                                            Modifiers
  //------------------------------------------------------------------------------------------------------------------

  // @notice Sender must be a registered owner
  modifier onlyOwner {
    require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))), "Not owner");
    _;
  }

  // @notice function won't run if owners have paused this contract
  modifier whenNotPaused {
    require(!database.boolStorage(keccak256(abi.encodePacked("paused", address(this)))));
    _;
  }

  // @notice reverts if the asset does not have a token address set in the database
  modifier validAsset(address _assetAddress) {
    require(database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))) != address(0), "Invalid asset");
    _;
  }

  // @notice reverts if the funding deadline has not passed
  modifier beforeDeadline(address _assetAddress) {
    require(now < database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Before deadline");
    _;
  }

  // @notice reverts if the funding deadline has already past or crowsale has not started
  modifier betweenDeadlines(address _assetAddress) {
    require(now <= database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Past deadline");
    require(now >= database.uintStorage(keccak256(abi.encodePacked("crowdsale.start", _assetAddress))), "Before start time");
    _;
  }

  // @notice reverts if the funding deadline has already past
  modifier afterDeadline(address _assetAddress) {
    require(now > database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))), "Before deadline");
    _;
  }

  // @notice returns true if crowdsale is finshed
  modifier finalized(address _assetAddress) {
    require(database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress))), "Crowdsale not finalized");
    _;
  }

  // @notice returns true if crowdsale is not finshed
  modifier notFinalized(address _assetAddress) {
    require(!database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress))), "Crowdsale finalized");
    _;
  }

  // @notice returns true if crowdsale has not paid out
  modifier notPaid(address _assetAddress) {
    require(!database.boolStorage(keccak256(abi.encodePacked("crowdsale.paid", _assetAddress))), "Crowdsale has paid out");
    _;
  }

  event Convert(address token, uint change, uint investment);
  event EtherReceived(address sender, uint amount);
}