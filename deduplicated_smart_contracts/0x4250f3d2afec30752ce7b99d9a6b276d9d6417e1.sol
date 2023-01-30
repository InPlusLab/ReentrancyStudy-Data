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

// File: contracts/database/API.sol

interface TokenView {
  function totalSupply() external view returns (uint);
  function balanceOf(address _investor) external view returns (uint);
  function valuePerToken() external view returns (uint);
  function scalingFactor() external view returns (uint);
  function assetIncome() external view returns (uint);
  function getERC20() external view returns (address);
}

interface DBView {
  function uintStorage(bytes32 _key) external view returns (uint);
  function stringStorage(bytes32 _key) external  view returns (string);
  function addressStorage(bytes32 _key) external  view returns (address);
  function bytesStorage(bytes32 _key) external view returns (bytes);
  function bytes32Storage(bytes32 _key) external view returns (bytes32);
  function boolStorage(bytes32 _key) external view returns (bool);
  function intStorage(bytes32 _key) external view returns (bool);
}

// @title A contract that gets variables from the _database
// @notice The API contract can only view the database. It has no write privileges
contract API {
  using SafeMath for uint256;

  DBView private database;
  uint constant scalingFactor = 10e32;

  constructor(address _database)
  public {
    database = DBView(_database);
  }

  function getContract(string _name)
  public
  view
  returns (address) {
    return database.addressStorage(keccak256(abi.encodePacked('contract', _name)));
  }

  function getAddr(bytes32 _key)
  public
  view
  returns (address) {
    return database.addressStorage(_key);
  }

  function getUint(bytes32 _key)
  public
  view
  returns (uint) {
    return database.uintStorage(_key);
  }

  function hashSB(string _a, bytes32 _b)
  public
  pure
  returns (bytes32) {
    return keccak256(abi.encodePacked(_a, _b));
  }

  function getMethodID(string _functionString)
  public
  pure
  returns (bytes4) {
    return bytes4(keccak256(abi.encodePacked(_functionString)));
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                        Crowdsale and Assets
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function getAssetFundingToken(address _assetAddress)
  public
  view
  returns(address) {
    address fundingTokenAddress = TokenView(_assetAddress).getERC20();
    return fundingTokenAddress;
  }

  function getAssetIPFS(address _assetAddress)
  public
  view
  returns(string) {
    return database.stringStorage(keccak256(abi.encodePacked("asset.ipfs", _assetAddress)));
  }

  // IF we decide not to store assetIncome
  // function getAssetIncome(address _assetAddress)
  // public
  // view
  // returns (uint) {
  //   TokenView asset = TokenView(_assetAddress);
  //   uint valuePerToken =  asset.valuePerToken();
  //   return (valuePerToken * (asset.totalSupply())) / asset.scalingFactor();
  // }

  function getAssetROI(address _assetAddress)
  public
  view
  returns (uint) {
    TokenView assetToken = TokenView(_assetAddress);
    return (assetToken.assetIncome() * 100) /  assetToken.totalSupply();
  }

  function getCrowdsaleGoal(address _assetAddress)
  public
  view
  returns(uint) {
    uint fundingGoal = database.uintStorage(keccak256(abi.encodePacked("crowdsale.goal", _assetAddress)));
    return fundingGoal;
  }

  function getCrowdsaleDeadline(address _assetAddress)
  public
  view
  returns(uint) {
    return database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress)));
  }

  function crowdsaleFinalized(address _assetAddress)
  public
  view
  returns(bool) {
    return database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress)));
  }

  function crowdsalePaid(address _assetAddress)
  public
  view
  returns(bool) {
    return database.boolStorage(keccak256(abi.encodePacked("crowdsale.paid", _assetAddress)));
  }

  function crowdsaleFailed(address _assetAddress)
  public
  view
  returns(bool) {
    return (now > getCrowdsaleDeadline(_assetAddress) && !crowdsaleFinalized(_assetAddress));
  }


  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                        Asset Manager and Operator
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function getAssetManager(address _assetAddress)
  public
  view
  returns(address) {
    address managerAddress = database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
    return managerAddress;
  }

  function getAssetManagerFee(address _assetAddress)
  public
  view
  returns(uint) {
    uint managerFee = database.uintStorage(keccak256(abi.encodePacked("asset.managerTokens", _assetAddress)));
    return managerFee;
  }

  function getAssetPlatformFee(address _assetAddress)
  public
  view
  returns(uint) {
    uint platformFee = database.uintStorage(keccak256(abi.encodePacked("asset.platformTokens", _assetAddress)));
    return platformFee;
  }

  function getAssetManagerEscrowID(address _assetAddress, address _manager)
  public
  pure
  returns(bytes32) {
    bytes32 managerEscrowID = keccak256(abi.encodePacked(_assetAddress, _manager));
    return managerEscrowID;
  }

  function getAssetManagerEscrow(bytes32 _managerEscrowID)
  public
  view
  returns (uint) {
    return database.uintStorage(keccak256(abi.encodePacked("asset.escrow", _managerEscrowID)));
  }

  function getAssetManagerEscrowRemaining(bytes32 _managerEscrowID)
  public
  view
  returns(uint) {
    uint redeemed = getAssetManagerEscrowRedeemed(_managerEscrowID);
    uint escrow = getAssetManagerEscrow(_managerEscrowID);
    return escrow.sub(redeemed);
  }

  function getAssetManagerEscrowRedeemed(bytes32 _managerEscrowID)
  public
  view
  returns(uint) {
    uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked("asset.escrowRedeemed", _managerEscrowID)));
    return escrowRedeemed;
  }

  function getAssetModelID(address _assetAddress)
  public
  view
  returns(bytes32) {
    bytes32 modelID = database.bytes32Storage(keccak256(abi.encodePacked("asset.modelID", _assetAddress)));
    return modelID;
  }

  function checkAssetAcceptToken(bytes32 _modelID, address _tokenAddress)
  external
  view
  returns(bool) {
    return database.boolStorage(keccak256(abi.encodePacked("model.acceptsToken", _modelID, _tokenAddress)));
  }

  function checkAssetPayoutToken(bytes32 _modelID, address _tokenAddress)
  external
  view
  returns(bool) {
    return database.boolStorage(keccak256(abi.encodePacked("model.payoutToken", _modelID, _tokenAddress)));
  }

  function getAssetOperator(address _assetAddress)
  public
  view
  returns(address) {
    bytes32 modelID = getAssetModelID(_assetAddress);
    address operatorAddress = getModelOperator(modelID);
    return operatorAddress;
  }

  function generateOperatorID(string _operatorURI)
  public
  pure
  returns(bytes32) {
    bytes32 operatorID = keccak256(abi.encodePacked("operator.uri", _operatorURI));
    return operatorID;
  }

  function getOperatorID(address _operatorAddress)
  public
  view
  returns(bytes32) {
    bytes32 operatorID = database.bytes32Storage(keccak256(abi.encodePacked("operator", _operatorAddress)));
    return operatorID;
  }

  function getOperatorAddress(bytes32 _operatorID)
  public
  view
  returns(address) {
    address operatorAddress = database.addressStorage(keccak256(abi.encodePacked("operator", _operatorID)));
    return operatorAddress;
  }

  function getOperatorIPFS(bytes32 _operatorID)
  public
  view
  returns(string) {
    return database.stringStorage(keccak256(abi.encodePacked("operator.ipfs", _operatorID)));
  }

  function generateModelID(string _modelURI, bytes32 _operatorID)
  public
  pure
  returns(bytes32) {
    bytes32 modelID = keccak256(abi.encodePacked('model.id', _operatorID, _modelURI));
    return modelID;
  }

  function getModelOperator(bytes32 _modelID)
  public
  view
  returns(address) {
    address operatorAddress = database.addressStorage(keccak256(abi.encodePacked("model.operator", _modelID)));
    return operatorAddress;
  }

  function getModelIPFS(bytes32 _modelID)
  public
  view
  returns(string) {
    return database.stringStorage(keccak256(abi.encodePacked("model.ipfs", _modelID)));
  }

  function getManagerAssetCount(address _manager)
  public
  view
  returns(uint) {
    return database.uintStorage(keccak256(abi.encodePacked("manager.assets", _manager)));
  }

  function getCollateralLevel(address _manager)
  public
  view
  returns(uint) {
    return database.uintStorage(keccak256(abi.encodePacked("collateral.base"))).add(database.uintStorage(keccak256(abi.encodePacked("collateral.level", getManagerAssetCount(_manager)))));
  }


  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                        Platform and Contract State
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Platform functions
  function getPlatformToken()
  public
  view
  returns(address) {
    address tokenAddress = database.addressStorage(keccak256(abi.encodePacked("platform.token")));
    return tokenAddress;
  }

  function getPlatformTokenFactory()
  public
  view
  returns(address) {
    address factoryAddress = database.addressStorage(keccak256(abi.encodePacked("platform.tokenFactory")));
    return factoryAddress;
  }

  function getPlatformFee()
  public
  view
  returns(uint) {
    uint fee = database.uintStorage(keccak256(abi.encodePacked("platform.fee")));
    return fee;
  }

  function getPlatformPercentage()
  public
  view
  returns(uint) {
    uint percentage = database.uintStorage(keccak256(abi.encodePacked("platform.percentage")));
    return percentage;
  }

  function getPlatformAssetsWallet()
  public
  view
  returns(address) {
    address walletAddress = database.addressStorage(keccak256(abi.encodePacked("platform.wallet.assets")));
    return walletAddress;
  }

  function getPlatformFundsWallet()
  public
  view
  returns(address) {
    address walletAddress = database.addressStorage(keccak256(abi.encodePacked("platform.wallet.funds")));
    return walletAddress;
  }

  function getContractAddress(string _contractName)
  public
  view
  returns(address) {
    address contractAddress = database.addressStorage(keccak256(abi.encodePacked("contract", _contractName)));
    return contractAddress;
  }

  function contractPaused(address _contract)
  public
  view
  returns(bool) {
    bool status = database.boolStorage(keccak256(abi.encodePacked("paused", _contract)));
    return status;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                        Ownership
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function contractOwner(address _account)
  public
  view
  returns(bool) {
    bool status = database.boolStorage(keccak256(abi.encodePacked("owner", _account)));
    return status;
  }

}