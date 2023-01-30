pragma solidity 0.4.21;




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




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value)
    internal
  {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/// @dev Right now, the Biddable application is responsible for being the arbitrator to all escrows.
///  This means, the Biddable application has to enforce boundaries such that auction houses can
///  only release escrows for users on their platform. This is done via the shared secret that is
///  provisioned for each platform that onboards with the service.
contract BiddableEscrow is CanReclaimToken {

  using SafeMath for uint256;

  // Mapping of escrows. Key is a UUID generated by Biddable
  mapping (string => EscrowDeposit) private escrows;

  // The arbitrator that is responsible for releasing escrow.
  // At this time this is the Biddable service.
  // This should be separate key than the one used for the creation of the contract.
  address public arbitrator;

  // Gas fees that have accumulated in this contract to reimburse the arbitrator
  // for paying fees for releasing escrow. These are stored locally to avoid having to
  // pay additional gas costs for transfer during each release.
  uint256 public accumulatedGasFees;

  struct EscrowDeposit {
    // Used to avoid collisions
    bool exists;

    // Address of the bidder
    address bidder;

    // Encrypted data of the escrow
    // This is the ownership data of the escrow in the context of the auction house platform
    // It holds the platformId, auctionId, and the userId on the platform
    bytes data;

    // The amount in the escrow
    uint256 amount;
  }

  modifier onlyArbitrator() {
    require(msg.sender == arbitrator);
    _;
  }

  /// @dev Constructor for the smart contract
  /// @param _arbitrator Address for an arbitrator that is responsible for signing the transaction data
  function BiddableEscrow(address _arbitrator) public {
    arbitrator = _arbitrator;
    accumulatedGasFees = 0;
  }

  /// @notice Sets a new arbitrator. Only callable by the owner
  /// @param _newArbitrator Address for the new arbitrator
  function setArbitrator(address _newArbitrator) external onlyOwner {
    arbitrator = _newArbitrator;
  }

  /// @dev This event is emitted when funds have been deposited into a new escrow.
  ///  The data is an encrypted blob that contains the user's userId so that the
  ///  Biddable service can tell the calling platform which user to approve for bidding.
  event Created(address indexed sender, string id, bytes data);

  /// @notice Deposit ether into escrow. The data must be signed by the Biddable service.
  /// @dev We don't use an 'onlyArbitrator' modifier because the transaction itself is sent by the bidder,
  ///  but the data must be signed by the Biddable service. Thus, the function must be available to call
  ///  by anyone.
  /// @param _id Is the unique identifier of the escrow
  /// @param _depositAmount The deposit required to be in escrow for approval
  /// @param _data The encrypted deposit data
  /// @param _v Recovery number
  /// @param _r First part of the signature
  /// @param _s Second part of the signature
  function deposit(
    string _id,
    uint256 _depositAmount,
    bytes _data,
    uint8 _v,
    bytes32 _r,
    bytes32 _s)
    external payable
  {
    // Throw if the amount sent doesn't mean the deposit amount
    require(msg.value == _depositAmount);

    // Throw if a deposit with this id already exists
    require(!escrows[_id].exists);

    bytes32 hash = keccak256(_id, _depositAmount, _data);
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";

    address recoveredAddress = ecrecover(
      keccak256(prefix, hash),
      _v,
      _r,
      _s
    );

    // Throw if the signature wasn't created by the arbitrator
    require(recoveredAddress == arbitrator);

    escrows[_id] = EscrowDeposit(
      true,
      msg.sender,
      _data,
      msg.value);

    emit Created(msg.sender, _id, _data);
  }

  uint256 public constant RELEASE_GAS_FEES = 45989;

  /// @dev This event is emitted when funds have been released from escrow at which time
  ///  the escrow will be removed from storage (i.e., destroyed).
  event Released(address indexed sender, address indexed bidder, uint256 value, string id);

  /// @notice Release ether from escrow. Only the arbitrator is able to perform this action.
  /// @param _id Is the unique identifier of the escrow
  function release(string _id) external onlyArbitrator {
    // Throw if this deposit doesn't exist
    require(escrows[_id].exists);

    EscrowDeposit storage escrowDeposit = escrows[_id];

    // Shouldn't need to use SafeMath here because this should never cause an overflow
    uint256 gasFees = RELEASE_GAS_FEES.mul(tx.gasprice);
    uint256 amount = escrowDeposit.amount.sub(gasFees);
    address bidder = escrowDeposit.bidder;

    // Remove the deposit from storage
    delete escrows[_id];

    accumulatedGasFees = accumulatedGasFees.add(gasFees);
    bidder.transfer(amount);

    emit Released(
      msg.sender,
      bidder,
      amount,
      _id);
  }

  /// @notice Withdraw accumulated gas fees from the arbitratror releasing escrow.
  ///  Only callable by the owner
  function withdrawAccumulatedFees(address _to) external onlyOwner {
    uint256 transferAmount = accumulatedGasFees;
    accumulatedGasFees = 0;

    _to.transfer(transferAmount);
  }

  /// @dev This accessor method is needed because the compiler is not able to create one with a string mapping
  /// @notice Gets the EscrowDeposit based on the input id. Throws if the deposit doesn't exist.
  /// @param _id The unique identifier of the escrow
  function getEscrowDeposit(string _id) external view returns (address bidder, bytes data, uint256 amount) {
    // Throw if this deposit doesn't exist
    require(escrows[_id].exists);

    EscrowDeposit storage escrowDeposit = escrows[_id];

    bidder = escrowDeposit.bidder;
    data = escrowDeposit.data;
    amount = escrowDeposit.amount;
  }
}