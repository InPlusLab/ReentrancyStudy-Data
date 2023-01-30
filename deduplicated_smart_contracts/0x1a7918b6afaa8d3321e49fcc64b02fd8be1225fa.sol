/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/**
 * This smart contract code is Copyright 2018, 2019 TokenMarket Ltd. For more information see https://tokenmarket.net
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

interface SecurityTransferAgent {
  function verify(address from, address to, uint256 value) external view returns (uint256 newValue);
}

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

interface ERC677Receiver {
  function tokenFallback(address from, uint256 amount, bytes data) returns (bool success);
}

interface ERC677 {

  // TODO: Have a different event name to make sure that tools with bad APIs do not mix this with ERC-20 Transfer() event that lacks data parameter
  event ERC677Transfer(address from, address receiver, uint256 amount, bytes data);

  function transferAndCall(ERC677Receiver receiver, uint amount, bytes data) returns (bool success);
}



contract ERC677Token is ERC20, ERC677 {
  function transferAndCall(ERC677Receiver receiver, uint amount, bytes data) returns (bool success) {
    require(transfer(address(receiver), amount));

    ERC677Transfer(msg.sender, address(receiver), amount, data);

    require(receiver.tokenFallback(msg.sender, amount, data));
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


/**
 * @author TokenMarket /  Ville Sundell <ville at tokenmarket.net>
 */
contract CheckpointToken is ERC677Token {
  using SafeMath for uint256; // We use only uint256 for safety reasons (no boxing)

  /// @dev Name of the token, usually the company and/or series (like "TokenMeerkat Ltd. Series A"):
  string public name;
  /// @dev Ticker symbol, usually bases on the "name" above (like "MEER"):
  string public symbol;
  /// @dev Decimals are usually set to 18 for EIP-20 tokens:
  uint256 public decimals;
  /// @dev If transactionVerifier is set, that contract will be queried upon every token transaction:
  SecurityTransferAgent public transactionVerifier;

  /// @dev Checkpoint is the fundamental unit for our internal accounting
  ///      (who owns what, and at what moment in time)
  struct Checkpoint {
    uint256 blockNumber;
    uint256 value;
  }
  /// @dev This mapping contains checkpoints for every address:
  mapping (address => Checkpoint[]) public tokenBalances;
  /// @dev This is a one dimensional Checkpoint mapping of the overall token supply:
  Checkpoint[] public tokensTotal;

  /// @dev This mapping keeps account for approve() -> fransferFrom() pattern:
  mapping (address => mapping (address => uint256)) public allowed;

  /**
   * @dev Constructor for CheckpointToken, initializing the token
   *
   * Here we define initial values for name, symbol and decimals.
   *
   * @param _name Initial name of the token
   * @param _symbol Initial symbol of the token
   * @param _decimals Number of decimals for the token, industry standard is 18
   */
  function CheckpointToken(string _name, string _symbol, uint256 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

  /** PUBLIC FUNCTIONS
   ****************************************/

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address owner, address spender) public view returns (uint256) {
    return allowed[owner][spender];
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   * @return true if the call function was executed successfully
   */
  function approve(address spender, uint256 value) public returns (bool) {
    allowed[msg.sender][spender] = value;
    Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   * @return true if the call function was executed successfully
   */
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= allowed[from][msg.sender]);

    transferInternal(from, to, value);
    Transfer(from, to, value);
    return true;
  }

  /**
   * @dev transfer token for a specified address
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   * @return true if the call function was executed successfully
   */
  function transfer(address to, uint256 value) public returns (bool) {
    transferInternal(msg.sender, to, value);
    Transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev total number of tokens in existence
   * @return A uint256 specifying the total number of tokens in existence
   */
  function totalSupply() public view returns (uint256 tokenCount) {
    tokenCount = balanceAtBlock(tokensTotal, block.number);
  }

  /**
   * @dev total number of tokens in existence at the given block
   * @param blockNumber The block number we want to query for the total supply
   * @return A uint256 specifying the total number of tokens at a given block
   */
  function totalSupplyAt(uint256 blockNumber) public view returns (uint256 tokenCount) {
    tokenCount = balanceAtBlock(tokensTotal, blockNumber);
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param owner The address to query the the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceOf(address owner) public view returns (uint256 balance) {
    balance = balanceAtBlock(tokenBalances[owner], block.number);
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param owner The address to query the the balance of.
   * @param blockNumber The block number we want to query for the balance.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceAt(address owner, uint256 blockNumber) public view returns (uint256 balance) {
    balance = balanceAtBlock(tokenBalances[owner], blockNumber);
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address spender, uint addedValue) public returns (bool) {
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
    Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address spender, uint subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][spender];
    if (subtractedValue > oldValue) {
      allowed[msg.sender][spender] = 0;
    } else {
      allowed[msg.sender][spender] = oldValue.sub(subtractedValue);
    }
    Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Increase the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * This is originally from OpenZeppelin.
   *
   * approve should be called when allowed[spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   * @param data ABI-encoded contract call to call `spender` address.
   */
  function increaseApproval(address spender, uint addedValue, bytes data) public returns (bool) {
    require(spender != address(this));

    increaseApproval(spender, addedValue);

    require(spender.call(data));

    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * This is originally from OpenZeppelin.
   *
   * approve should be called when allowed[spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   * @param data ABI-encoded contract call to call `spender` address.
   */
  function decreaseApproval(address spender, uint subtractedValue, bytes data) public returns (bool) {
    require(spender != address(this));

    decreaseApproval(spender, subtractedValue);

    require(spender.call(data));

    return true;
  }

  /** INTERNALS
   ****************************************/

  function balanceAtBlock(Checkpoint[] storage checkpoints, uint256 blockNumber) internal returns (uint256 balance) {
    uint256 currentBlockNumber;
    (currentBlockNumber, balance) = getCheckpoint(checkpoints, blockNumber);
  }

  function transferInternal(address from, address to, uint256 value) internal {
    uint256 fromBalance = balanceOf(from);
    uint256 toBalance = balanceOf(to);

    if (address(transactionVerifier) != address(0)) {
      value = transactionVerifier.verify(from, to, value);
      require(value > 0);
    }

    setCheckpoint(tokenBalances[from], fromBalance.sub(value));
    setCheckpoint(tokenBalances[to], toBalance.add(value));
  }


  /** CORE
   ** The Magic happens below:
   ***************************************/

  function setCheckpoint(Checkpoint[] storage checkpoints, uint256 newValue) internal {
    if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].blockNumber < block.number)) {
      checkpoints.push(Checkpoint(block.number, newValue));
    } else {
       checkpoints[checkpoints.length.sub(1)] = Checkpoint(block.number, newValue);
    }
  }

  function getCheckpoint(Checkpoint[] storage checkpoints, uint256 blockNumber) internal returns (uint256 blockNumber_, uint256 value) {
    if (checkpoints.length == 0) {
      return (0, 0);
    }

    // Shortcut for the actual value
    if (blockNumber >= checkpoints[checkpoints.length.sub(1)].blockNumber) {
      return (checkpoints[checkpoints.length.sub(1)].blockNumber, checkpoints[checkpoints.length.sub(1)].value);
    }

    if (blockNumber < checkpoints[0].blockNumber) {
      return (0, 0);
    }

    // Binary search of the value in the array
    uint256 min = 0;
    uint256 max = checkpoints.length.sub(1);
    while (max > min) {
      uint256 mid = (max.add(min.add(1))).div(2);
      if (checkpoints[mid].blockNumber <= blockNumber) {
        min = mid;
      } else {
        max = mid.sub(1);
      }
    }

    return (checkpoints[min].blockNumber, checkpoints[min].value);
  }
}




/* Largely copied from https://github.com/OpenZeppelin/openzeppelin-solidity/pull/741/files */

contract ERC865 is CheckpointToken {
  /** @dev This is used to prevent nonce reuse: */
  mapping(bytes => bool) signatures;

  event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
  event Debug(address from, bytes32 hash);

  /**
    * @notice Submit a presigned transfer
    * @param _signature bytes The signature, issued by the owner.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 The amount of tokens to be transferred.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the person who used to own the tokens.
    * @param _nonce uint256 Presigned transaction number
    */
  function transferPreSigned(
    bytes _signature,
    address _to,
    uint256 _value,
    uint256 _fee,
    uint256 _nonce
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(signatures[_signature] == false);
    bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
    address from = recover(hashedTx, _signature);
    require(from != address(0));

    transferInternal(from, _to, _value);
    transferInternal(from, msg.sender, _fee);

    signatures[_signature] = true;
    TransferPreSigned(from, _to, msg.sender, _value, _fee);
    Transfer(from, _to, _value);
    Transfer(from, msg.sender, _fee);
    return true;
  }

  /**
    * @notice Hash (keccak256) of the payload used by transferPreSigned
    * @param _token address The address of the token.
    * @param _to address The address which you want to transfer to.
    * @param _value uint256 The amount of tokens to be transferred.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    */
  function transferPreSignedHashing(
    address _token,
    address _to,
    uint256 _value,
    uint256 _fee,
    uint256 _nonce
  )
    public
    pure
    returns (bytes32)
  {
    /* "48664c16": transferPreSignedHashing(address,address,address,uint256,uint256,uint256) */
    return keccak256(bytes4(0x48664c16), _token, _to, _value, _fee, _nonce);
  }

  /**
    * @notice Recover signer address from a message by using his signature.
    *         Signature is delivered as a byte array, hence need for this
    *         implementation.
    * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
    * @param sig bytes signature, the signature is generated using web3.eth.sign()
    */
  function recover(bytes32 hash, bytes sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    /* Check the signature length */
    if (sig.length != 65) {
      return (address(0));
    }

    /* Divide the signature in r, s and v variables */
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    /* Version of signature should be 27 or 28, but 0 and 1 are also possible versions */
    if (v < 27) {
      v += 27;
    }

    /* If the version is correct return the signer address */
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}

/**
 * @dev Interface for general announcements about the security.
 *
 * Announcements can be for instance for dividend sharing, voting, or
 * just for general announcements.
 */

interface Announcement {
  function announcementName() public view returns (bytes32);
  function announcementURI() public view returns (bytes32);
  function announcementType() public view returns (uint256);
  function announcementHash() public view returns (uint256);
}


/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */




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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract Recoverable is Ownable {

  /// @dev Empty constructor (for now)
  function Recoverable() {
  }

  /// @dev This will be invoked by the owner, when owner wants to rescue tokens
  /// @param token Token which will we rescue to the owner from the contract
  function recoverTokens(ERC20Basic token) onlyOwner public {
    token.transfer(owner, tokensToBeReturned(token));
  }

  /// @dev Interface function, can be overwritten by the superclass
  /// @param token Token which balance we will check and return
  /// @return The amount of tokens (in smallest denominator) the contract owns
  function tokensToBeReturned(ERC20Basic token) public returns (uint) {
    return token.balanceOf(this);
  }
}





/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}



/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 *      Supports unlimited numbers of roles and addresses.
 *      See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * A constant role name for indicating admins.
   */
  string public constant ROLE_ADMIN = "admin";

  /**
   * @dev constructor. Sets msg.sender as admin by default
   */
  function RBAC()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
  }

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminAddRole(address addr, string roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminRemoveRole(address addr, string roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to admins
   * // reverts
   */
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}



/**
 * @author TokenMarket /  Ville Sundell <ville at tokenmarket.net>
 */
contract SecurityToken is CheckpointToken, RBAC, Recoverable, ERC865 {
  using SafeMath for uint256; // We use only uint256 for safety reasons (no boxing)

  string public constant ROLE_ANNOUNCE = "announce()";
  string public constant ROLE_FORCE = "forceTransfer()";
  string public constant ROLE_ISSUE = "issueTokens()";
  string public constant ROLE_BURN = "burnTokens()";
  string public constant ROLE_INFO = "setTokenInformation()";
  string public constant ROLE_SETVERIFIER = "setTransactionVerifier()";

  /// @dev Version string telling the token is TM-01, and its version:
  string public version = 'TM-01 0.1';

  /// @dev URL where you can get more information about the security
  ///      (for example company website or investor interface):
  string public url;

  /** SecurityToken specific events **/
  /// @dev This is emitted when new tokens are created:
  event Issued(address indexed to, uint256 value);
  /// @dev This is emitted when tokens are burned from token's own stash:
  event Burned(address indexed burner, uint256 value);
  /// @dev This is emitted upon forceful transfer of tokens by the Board:
  event Forced(address indexed from, address indexed to, uint256 value);
  /// @dev This is emitted when new announcements (like dividends, voting, etc.) are issued by the Board:
  event Announced(address indexed announcement, uint256 indexed announcementType, bytes32 indexed announcementName, bytes32 announcementURI, uint256 announcementHash);
  /// @dev This is emitted when token information is changed:
  event UpdatedTokenInformation(string newName, string newSymbol, string newUrl);
  /// @dev This is emitted when transaction verifier (the contract which would check KYC, etc.):
  event UpdatedTransactionVerifier(address newVerifier);

  /// @dev Address list of Announcements (see "interface Announcement").
  ///      Announcements are things like votings, dividends, or any kind of
  ///      smart contract:
  address[] public announcements;
  /// @dev For performance reasons, we also maintain address based mapping of
  ///      Announcements:
  mapping(address => uint256) public announcementsByAddress;

  /**
   * @dev Contructor to create SecurityToken, and subsequent CheckpointToken.
   *
   * CheckpointToken will be created with hardcoded 18 decimals.
   *
   * @param _name Initial name of the token
   * @param _symbol Initial symbol of the token
   */
  function SecurityToken(string _name, string _symbol, string _url) CheckpointToken(_name, _symbol, 18) public {
    url = _url;

    addRole(msg.sender, ROLE_ANNOUNCE);
    addRole(msg.sender, ROLE_FORCE);
    addRole(msg.sender, ROLE_ISSUE);
    addRole(msg.sender, ROLE_BURN);
    addRole(msg.sender, ROLE_INFO);
    addRole(msg.sender, ROLE_SETVERIFIER);
  }

  /**
   * @dev Function to announce Announcements.
   *
   * Announcements can be for instance for dividend sharing, voting, or
   * just for general announcements.
   *
   * Instead of storing the announcement details, we just broadcast them as an
   * event, and store only the address.
   *
   * @param announcement Address of the Announcement
   */
  function announce(Announcement announcement) external onlyRole(ROLE_ANNOUNCE) {
    announcements.push(announcement);
    announcementsByAddress[address(announcement)] = announcements.length;
    Announced(address(announcement), announcement.announcementType(), announcement.announcementName(), announcement.announcementURI(), announcement.announcementHash());
  }

  /**
   * @dev Function to forcefully transfer tokens from A to B by board decission
   *
   * This must be implemented carefully, since this is a very critical part
   * to ensure investor safety.
   *
   * This is intended to be called by the BAC (The Board).
   * The BAC must have the RBAC role ROLE_FORCE.
   *
   * @param from Address of the account to confisticate the tokens from
   * @param to Address to deposit the confisticated token to
   * @param value amount of tokens to be confisticated
   */
  function forceTransfer(address from, address to, uint256 value) external onlyRole(ROLE_FORCE) {
    transferInternal(from, to, value);

    Forced(from, to, value);
  }

  /**
   * @dev Issue new tokens to the board by a board decission
   *
   * Issue new tokens. This is intended to be called by the BAC (The Board).
   * The BAC must have the RBAC role ROLE_ISSUE.
   *
   * @param value Token amount to issue
   */
  function issueTokens(uint256 value) external onlyRole(ROLE_ISSUE) {
    address issuer = msg.sender;
    uint256 blackHoleBalance = balanceOf(address(0));
    uint256 totalSupplyNow = totalSupply();

    setCheckpoint(tokenBalances[address(0)], blackHoleBalance.add(value));
    transferInternal(address(0), issuer, value);
    setCheckpoint(tokensTotal, totalSupplyNow.add(value));

    Issued(issuer, value);
  }

  /**
   * @dev Burn tokens from contract's own balance by a board decission
   *
   * Burn tokens from contract's own balance to prevent accidental burnings.
   * This is intended to be called by the BAC (The Board).
   * The BAC must have the RBAC role ROLE_BURN.
   *
   * @param value Token amount to burn from this contract's balance
   */
  function burnTokens(uint256 value) external onlyRole(ROLE_BURN) {
    address burner = address(this);
    uint256 burnerBalance = balanceOf(burner);
    uint256 totalSupplyNow = totalSupply();

    transferInternal(burner, address(0), value);
    setCheckpoint(tokenBalances[address(0)], burnerBalance.sub(value));
    setCheckpoint(tokensTotal, totalSupplyNow.sub(value));

    Burned(burner, value);
  }

  /**
   * @dev Permissioned users (The Board, BAC) can update token information here.
   *
   * It is often useful to conceal the actual token association, until
   * the token operations, like central issuance or reissuance have been completed.
   *
   * This function allows the token owner to rename the token after the operations
   * have been completed and then point the audience to use the token contract.
   *
   * The BAC must have the RBAC role ROLE_INFO.
   *
   * @param _name New name of the token
   * @param _symbol New symbol of the token
   * @param _url New URL of the token
   */
  function setTokenInformation(string _name, string _symbol, string _url) external onlyRole(ROLE_INFO) {
    name = _name;
    symbol = _symbol;
    url = _url;

    UpdatedTokenInformation(name, symbol, url);
  }

  /**
   * @dev Set transaction verifier
   *
   * This sets a SecurityTransferAgent to be used as a transaction verifier for
   * each transfer. This is implemented for possible regulatory requirements.
   *
   * @param newVerifier Address of the SecurityTransferAgent used as verifier
   */
  function setTransactionVerifier(SecurityTransferAgent newVerifier) external onlyRole(ROLE_SETVERIFIER) {
    transactionVerifier = newVerifier;

    UpdatedTransactionVerifier(newVerifier);
  }
}