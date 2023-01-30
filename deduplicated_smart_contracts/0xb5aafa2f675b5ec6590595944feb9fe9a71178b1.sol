/**
 *Submitted for verification at Etherscan.io on 2020-06-13
*/

pragma solidity ^0.5.16;


/**
 * Game Credits Game Management Contract
 * https://www.gamecredits.org
 * (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
 */





// @title iGameContract
// @dev The interface for cross-contract calls to the Game contract
// @author GAME Credits Platform (https://www.gamecredits.org)
// (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
contract iGameContract {
  function isAdminForGame(uint _game, address account) external view returns(bool);

  // List of all games tracked by the Game contract
  uint[] public games;
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface iERC20 {

  /**
    * @dev Returns the amount of tokens in existence.
    */
  function totalSupply() external view returns (uint);

  /**
    * @dev Returns the amount of tokens owned by `account`.
    */
  function balanceOf(address account) external view returns (uint);

  /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transfer(address recipient, uint amount) external returns (bool);

  /**
    * @dev Returns the remaining number of tokens that `spender` will be
    * allowed to spend on behalf of `owner` through {transferFrom}. This is
    * zero by default.
    *
    * This value changes when {approve} or {transferFrom} are called.
    */
  function allowance(address owner, address spender) external view returns (uint);

  /**
    * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * IMPORTANT: Beware that changing an allowance with this method brings the risk
    * that someone may use both the old and the new allowance by unfortunate
    * transaction ordering. One possible solution to mitigate this race
    * condition is to first reduce the spender's allowance to 0 and set the
    * desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * Emits an {Approval} event.
    */
  function approve(address spender, uint amount) external returns (bool);

  /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
  function transferFrom(address sender, address recipient, uint amount) external returns (bool);

  /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
  event Transfer(address indexed from, address indexed to, uint value);

  /**
    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    * a call to {approve}. `value` is the new allowance.
    */
  event Approval(address indexed owner, address indexed spender, uint value);
}



// @title iERC20Contract
// @dev The interface for cross-contract calls to the ERC20 contract
// @author GAME Credits Platform (https://www.gamecredits.org)
// (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
contract iERC20Contract {
  function isOfficialAccount(address account) external view returns(bool);
}



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
  function sub(uint a, uint b) internal pure returns (uint) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
    * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    *
    * _Available since v2.4.0._
    */
  function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    require(b <= a, errorMessage);
    uint c = a - b;

    return c;
  }

  /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */
  function mul(uint a, uint b) internal pure returns (uint) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function div(uint a, uint b) internal pure returns (uint) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
    * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    *
    * _Available since v2.4.0._
    */
  function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function mod(uint a, uint b) internal pure returns (uint) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts with custom message when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    *
    * _Available since v2.4.0._
    */
  function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


// @title Game Access (Game Access Control)
// @dev Game contract for controlling access to games, and allowing managers to add and remove operator accounts
// @author GAME Credits Platform (https://www.gamecredits.org)
// (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
contract GameAccess is iGameContract {
  using SafeMath for uint;

  // Reference to the address of the ERC20 contract
  iERC20 public erc20Contract;

  event AdminPrivilegesChanged(uint indexed game, address indexed account, bool isAdmin);
  event AdminRecoveryBlocked(uint indexed game, bool isBlocked);

  // Admin addresses are stored both by gameId and address
  mapping(uint => address[]) public adminAddressesByGameId;
  mapping(address => uint[]) public gameIdsByAdminAddress;

  // Stores admin status (as a boolean) by gameId and account
  mapping(uint => mapping(address => bool)) public gameAdmins;

  // Stores ability for official accounts to act on the game admin list
  // Defaults
  mapping(uint => bool) public adminRecoveryBlocked;

  // @dev Access control modifier to limit access to game admin accounts
  modifier onlyGameAdmin(uint _game) {
    require(gameAdmins[_game][msg.sender], "sender must be a game admin");
    _;
  }

  // @dev Access control modifier to limit access to either the recovery or
  //   owner accounts.
  modifier onlyOfficialAccount() {
    require(
      iERC20Contract(address(erc20Contract)).isOfficialAccount(msg.sender),
      "sender must be the owner or recovery account"
    );
    _;
  }

  // @dev Access control modifier to limit access to the ERC20 contract
  modifier onlyERC20Contract() {
    require(msg.sender == address(erc20Contract), "Can only be called from the ERC20 contract");
    _;
  }

  // @dev Internal constructor to ensure this contract can't be deployed alone
  constructor() internal{ }

  // @dev gets the admin status for a game & account
  // @param _game - the gameId of the game
  // @param _account - the address of the user
  // @returns bool - the admin status of the requested account for the requested game
  function isAdminForGame(uint _game, address _account)
    external
    view
  returns(bool) {
    return gameAdmins[_game][_account];
  }

  // @dev gets the list of admins for a game
  // @param _game - the gameId of the game
  // @returns address[] - the list of admin addresses for the requested game
  function getAdminsForGame(uint _game)
    external
    view
  returns(address[] memory) {
    return adminAddressesByGameId[_game];
  }

  // @dev gets the list of games that the requested account is the admin of
  // @param _account - the address of the user
  // @returns uint[] - the list of game Ids for the requested account
  function getGamesForAdmin(address _account)
    external
    view
  returns(uint[] memory) {
    return gameIdsByAdminAddress[_account];
  }

  // @dev Adds an address as an admin for a game
  // @notice Can only be called by an admin of the game
  // @param _game - the gameId of the game
  // @param _account - the address of the user
  function addAdminAccount(uint _game, address _account)
    external
    onlyGameAdmin(_game)
  {
    require(_account != msg.sender, "new admin can't be sender");
    require(_account != address(0), "new admin can't be the zero address");
    require(!gameAdmins[_game][_account], "new admin can't already be an admin");
    _addAdminAccount(_game, _account);
  }

  // @dev Adds an address as an admin for a game; used in emergencies
  // @notice Can only be called by the erc20 owner or recovery accounts
  // @param _game - the gameId of the game
  // @param _account - the address of the user
  function recoverAdminAccount(uint _game, address _account)
    external
    onlyOfficialAccount
  {
    require(_account != msg.sender, "new admin can't be sender");
    require(_account != address(0), "new admin can't be the zero address");
    require(!gameAdmins[_game][_account], "new admin can't already be an admin");
    require(!adminRecoveryBlocked[_game], "this game has blocked admin recovery");
    _addAdminAccount(_game, _account);
  }

  // @dev Blocks the erc20 owner or recovery accounts from adding admin accounts
  // @notice Can only be called by a game admin account
  // @param _game - the gameId of the game
  // @param _isBlocked - whether to block or unblock recovery
  function blockAdminRecovery(uint _game, bool _isBlocked)
    external
    onlyGameAdmin(_game)
  {
    adminRecoveryBlocked[_game] = _isBlocked;
    emit AdminRecoveryBlocked(_game, _isBlocked);
  }

  // @dev Removes an address from an admin for a game
  // @notice Can only be called by an admin of the game.
  // @notice Can't remove your own account's admin privileges.
  // @param _game - the gameId of the game
  // @param _account - the address of the user to remove admin privileges.
  function removeAdminAccount(uint _game, address _account)
    external
    onlyGameAdmin(_game)
  {
    require(_account != msg.sender, "can't remove yourself as admin");
    require(gameAdmins[_game][_account], "account to remove must be an admin");

    address[] storage opsAddresses = adminAddressesByGameId[_game];
    uint startingLength = opsAddresses.length;
    // Yes, "i < startingLength" is right. 0 - 1 == uint.maxvalue, not -1.
    for (uint i = opsAddresses.length - 1; i < startingLength; i--) {
      if (opsAddresses[i] == _account) {
        uint newLength = opsAddresses.length.sub(1);
        opsAddresses[i] = opsAddresses[newLength];
        delete opsAddresses[newLength];
        opsAddresses.length = newLength;
      }
    }

    uint[] storage gamesByAdmin = gameIdsByAdminAddress[_account];
    startingLength = gamesByAdmin.length;
    for (uint i = gamesByAdmin.length - 1; i < startingLength; i--) {
      if (gamesByAdmin[i] == _game) {
        uint newLength = gamesByAdmin.length.sub(1);
        gamesByAdmin[i] = gamesByAdmin[newLength];
        delete gamesByAdmin[newLength];
        gamesByAdmin.length = newLength;
      }
    }

    gameAdmins[_game][_account] = false;
    emit AdminPrivilegesChanged(_game, _account, false);
  }

  // @dev Internal function to add an address as an admin for a game
  // @param _game - the gameId of the game
  // @param _account - the address of the user
  function _addAdminAccount(uint _game, address _account)
    internal
  {
    address[] storage opsAddresses = adminAddressesByGameId[_game];
    require(opsAddresses.length < 256, "a game can only have 256 admins");
    for (uint i = opsAddresses.length; i < opsAddresses.length; i--) {
      require(opsAddresses[i] != _account, "new admin account can't already be in the admin addess list");
    }

    uint[] storage gamesByAdmin = gameIdsByAdminAddress[_account];
    require(gamesByAdmin.length < 256, "you can only own 256 games");
    for (uint i = gamesByAdmin.length; i < gamesByAdmin.length; i--) {
      require(gamesByAdmin[i] != _game, "you can't become an operator twice");
    }
    gamesByAdmin.push(_game);

    opsAddresses.push(_account);
    gameAdmins[_game][_account] = true;
    emit AdminPrivilegesChanged(_game, _account, true);
  }
}



// @title iSupportContract
// @dev The interface for cross-contract calls to Support contracts
// @author GAME Credits Platform (https://www.gamecredits.org)
// (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
contract iSupportContract {

  function isSupportContract() external pure returns(bool);

  function getGameAccountSupport(uint _game, address _account) external view returns(uint);
  function updateSupport(uint _game, address _account, uint _supportAmount) external;
  function fundRewardsPool(uint _amount, uint _startWeek, uint _numberOfWeeks) external;

  function receiveGameCredits(uint _game, address _account, uint _tokenId, uint _payment, bytes32 _data) external;
  function receiveLoyaltyPayment(uint _game, address _account, uint _tokenId, uint _payment, bytes32 _data) external;
  function contestEntry(uint _game, address _account, uint _tokenId, uint _contestId, uint _payment, bytes32 _data) external;

  event GameCreditsPayment(uint indexed _game, address indexed account, uint indexed _tokenId, uint _payment, bytes32 _data);
  event LoyaltyPayment(uint indexed _game, address indexed account, uint indexed _tokenId, uint _payment, bytes32 _data);
  event EnterContest(uint indexed _game, address indexed account, uint _tokenId, uint indexed _contestId, uint _payment, bytes32 _data);
}


// @title Game Contract (Game Data)
// @dev Game contract for managing all game data
// @author GAME Credits Platform (https://www.gamecredits.org)
// (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
contract GameBase is GameAccess, iSupportContract {

  // Url of the GameCredits network site
  string public url = "https://www.gamecredits.org";

  // balance of individual games from payments for tokens
  mapping (uint => uint) public gameBalances;

  // balance of the system owner from payments for tokens
  uint public ownerBalance;

  // fee, in points, paid to the system owner for creating a token
  uint public tokenFee;

  event TokenFee(uint tokenFee);
  event GameBalance(uint indexed game, uint balance);
  event Withdrawal(uint indexed game, address indexed account, uint amount);

  constructor()
    internal
  {
    tokenFee = 2000;
    emit TokenFee(tokenFee);
  }

  // @dev Withdraw all the balance of a game's account from the system to the caller.
  // @param _game - the game to withdraw from
  // @notice can only be called by a game admin for the game
  function withdrawGameBalance(uint _game)
    external
    onlyGameAdmin(_game)
  {
    uint toWithdraw = gameBalances[_game];
    gameBalances[_game] = 0;
    erc20Contract.transfer(msg.sender, toWithdraw);
    emit Withdrawal(_game, msg.sender, toWithdraw);
    emit GameBalance(_game, 0);
  }

  // @dev Withdraw all the balance of the owner's account from the system to the caller.
  // @notice can only be called by the owner or recovery account
  function withdrawOwnerBalance()
    external
    onlyOfficialAccount
  {
    uint toWithdraw = ownerBalance;
    ownerBalance = 0;
    erc20Contract.transfer(msg.sender, toWithdraw);
    emit Withdrawal(0, msg.sender, toWithdraw);
    emit GameBalance(0, 0);
  }

  // @dev Sets the fee for token creation, in points.
  // @param _tokenFee - the fee, in points
  // @notice can only be called by the owner or recovery account
  function setTokenFee(uint _tokenFee)
    external
    onlyOfficialAccount
  {
    require(_tokenFee < 10000, "the fee is too damn high");
    tokenFee = _tokenFee;
    emit TokenFee(tokenFee);
  }

  // @dev This support contract doesn't implement getGameAccountSupport
  function getGameAccountSupport(uint, address)
    external
    view
  returns(uint)
  {
    revert("This support contract doesn't implement getGameAccountSupport");
  }

  // @dev This support contract doesn't implement updateSupport
  function updateSupport(uint, address, uint)
    external
  {
    revert("This support contract doesn't implement updateSupport");
  }

  // @dev This support contract doesn't implement fundRewardsPool
  function fundRewardsPool(uint, uint, uint)
    external
  {
    revert("This support contract doesn't implement fundRewardsPool");
  }

  // @dev Called by the erc20 contract, when that contract is used to send Game Credits as a payment
  // @param _game - the gameId of the game
  // @param _account - the address of the account that called the erc20 function
  // @param _tokenId - the ID of the relevant token, if any
  // @param _payment - the amount in game credits that was transferred to this contract by
  //   the erc20 contract when that contract was called
  // @param _data - an additional data field to be read by the oracle
  function receiveGameCredits(uint _game, address _account, uint _tokenId, uint _payment, bytes32 _data)
    external
    onlyERC20Contract
  {
    require(_game < games.length, "game must exist or be zero");
    uint ownerPayment = _payment.div(10000).mul(tokenFee);
    uint gamePayment = _payment.sub(ownerPayment);
    uint newBalance = gameBalances[_game].add(gamePayment);
    uint newOwnerBalance = ownerBalance.add(ownerPayment);
    gameBalances[_game] = newBalance;
    ownerBalance = newOwnerBalance;

    emit GameCreditsPayment(_game, _account, _tokenId, _payment, _data);
    emit GameBalance(_game, newBalance);
    emit GameBalance(0, newOwnerBalance);
  }

  // @dev Called by the erc20 contract, when that contract is used to request a Loyalty Points
  //   payment on the sidechain
  // @param _game - the gameId of the game
  // @param _account - the address of the account that called the erc20 function
  // @param _tokenId - the ID of the relevant token, if any
  // @param _payment - the amount in loyalty points that was requested to be paid, and will be
  //   paid on the sidechain
  // @param _data - an additional data field to be read by the oracle
  function receiveLoyaltyPayment(uint _game, address _account, uint _tokenId, uint _payment, bytes32 _data)
    external
    onlyERC20Contract
  {
    require(_game < games.length, "game must exist or be zero");
    emit LoyaltyPayment(_game, _account, _tokenId, _payment, _data);
  }

  // @dev This support contract doesn't implement contestEntry
  function contestEntry(uint, address, uint, uint, uint, bytes32)
    external
  {
    revert("This support contract doesn't implement contestEntry");
  }

  // @dev confirms that this contract is a support contract
  // @returns bool - always returns true because this is a support contract
  function isSupportContract()
    external
    pure
  returns(bool)
  {
    return true;
  }
}


// @title Game Contract (Game Data)
// @dev Game contract for managing all game data
// @author GAME Credits Platform (https://www.gamecredits.org)
// (c) 2020 GAME Credits. All Rights Reserved. This code is not open source.
contract GameContract is GameBase {

  struct GameData {
    string json;
    uint tradeLockSeconds;
    bytes32[] metadata;
  }

  event GameCreated(uint indexed game, address indexed owner, string json, bytes32[] metadata);

  event GameMetadataUpdated(
    uint indexed game,
    string json,
    uint tradeLockSeconds,
    bytes32[] metadata
  );

  mapping(uint => GameData) internal gameData;

  constructor(iERC20 _erc20Contract)
    public
  {
    erc20Contract = _erc20Contract;
    games.push(2**32);
  }

  // @notice The fallback function reverts
  function ()
    external
    payable
  {
    revert("this contract is not payable");
  }

  // @dev Create a new game by setting its data.
  //   Created games are initially owned and managed by the game's creator
  // @notice - there's a maximum of 2^32 games (4.29 billion games)
  // @param _json - a json encoded string containing the game's name, uri, logo, description, etc
  // @param _tradeLockSeconds - the number of seconds a card remains locked to a purchaser's account
  // @param _metadata - game-specific metadata, in bytes32 format.
  function createGame(string calldata _json, uint _tradeLockSeconds, bytes32[] calldata _metadata)
    external
  returns(uint _game) {
    // Create the game
    _game = games.length;
    require(_game < games[0], "too many games created");
    games.push(_game);

    // Log the game as created
    emit GameCreated(_game, msg.sender, _json, _metadata);

    // Add the creator as the first game admin
    _addAdminAccount(_game, msg.sender);

    // Store the game's metadata
    updateGameMetadata(_game, _json, _tradeLockSeconds, _metadata);
  }

  // @dev Gets the number of games in the system
  // @returns the number of games stored in the system
  function numberOfGames()
    external
    view
  returns(uint) {
    return games.length;
  }

  // @dev Get all game data for one given game
  // @param _game - the # of the game
  // @returns game - the game ID of the requested game
  // @returns json - the json data of the game
  // @returns tradeLockSeconds - the number of card sets
  // @returns balance - the erc20 Token balance
  // @returns metadata - a bytes32 array of metadata used by the game
  function getGameData(uint _game)
    external
    view
  returns(uint game,
    string memory json,
    uint tradeLockSeconds,
    uint balance,
    bytes32[] memory metadata)
  {
    GameData storage data = gameData[_game];
    game = _game;
    json = data.json;
    tradeLockSeconds = data.tradeLockSeconds;
    balance = 0;
    metadata = data.metadata;
  }

  // @dev Update the json, trade lock, and metadata for a single game
  // @param _game - the # of the game
  // @param _json - a json encoded string containing the game's name, uri, logo, description, etc
  // @param _tradeLockSeconds - the number of seconds a card remains locked to a purchaser's account
  // @param _metadata - game-specific metadata, in bytes32 format.
  function updateGameMetadata(uint _game, string memory _json, uint _tradeLockSeconds, bytes32[] memory _metadata)
    public
    onlyGameAdmin(_game)
  {
    gameData[_game].tradeLockSeconds = _tradeLockSeconds;
    gameData[_game].json = _json;

    bytes32[] storage data = gameData[_game].metadata;
    if (_metadata.length > data.length) {
      data.length = _metadata.length;
    }
    uint j = 0;
    for (j = 0; j < _metadata.length; j++) {
      data[j] = _metadata[j];
    }
    for (uint k = j; k < data.length; k++) {
      delete data[k];
    }
    if (_metadata.length < data.length) {
      data.length = _metadata.length;
    }

    emit GameMetadataUpdated(_game, _json, _tradeLockSeconds, _metadata);
  }
}