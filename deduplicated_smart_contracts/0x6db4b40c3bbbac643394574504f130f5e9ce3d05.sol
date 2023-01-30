pragma solidity ^0.5.0;

import './EIP20.sol';

/// @author robinhood.casino
/// @title Robinhood (RHC) ERC20 token
contract RHC is EIP20 {

  /// @notice reports number of tokens that are promised to vest in a future date
  uint256 public pendingGrants;

  /// @notice raised when tokens are issued for an account
  event Issuance(address indexed _beneficiary, uint256 _amount);

  struct Grant {
    /// number of shares in the grant
    uint256 amount;
    /// a linux timestamp of when shares can be claimed
    uint vestTime;
    /// whether the claim has been cancelled by admins
    bool isCancelled;
    /// whether the grant has been claimed by the user
    bool isClaimed;
  }

  /// @dev token balance of all addresses
  mapping (address => uint256) private _balances;

  /// @dev tracks who can spend how much.
  mapping (address => mapping (address => uint256)) private _allowances;

  /// @dev balance of tokens that are not vested yet
  mapping (address => Grant[]) private _grants;

  // used for access management
  address private _owner;
  mapping (address => bool) private _admins;

  constructor(address admin) public {
    _owner = admin;
  }

  /// @notice name of the Robinhood token
  function name() public pure returns (string memory) {
    return "Robinhood";
  }

  /// @notice symbol of the Robinhood token
  function symbol() public pure returns (string memory) {
    return "RHC";
  }

  /// @notice RHC does not allow breaking up of tokens into fractions.
  function decimals() public pure returns (uint8) {
    return 0;
  }

  modifier onlyAdmins() {
    require(msg.sender == _owner || _admins[msg.sender] == true, "only admins can invoke this function");
    _;
  }

  /// @dev registers a new admin
  function addAdmin(address admin) public onlyAdmins() {
    _admins[admin] = true;
  }

  /// @dev removes an existing admin
  function removeAdmin(address admin) public onlyAdmins() {
    require(admin != _owner, "owner can't be removed");
    delete _admins[admin];
  }

  /// @dev Gets the balance of the specified address.
  /// @param owner The address to query the balance of.
  /// @return A uint256 representing the amount owned by the passed address.
  function balanceOf(address owner) public view returns (uint256) {
      return _balances[owner];
  }

  /// @dev Function to check the amount of tokens that an owner allowed to a spender.
  /// @param owner address The address which owns the funds.
  /// @param spender address The address which will spend the funds.
  /// @return A uint256 specifying the amount of tokens still available for the spender.
  function allowance(address owner, address spender) public view returns (uint256) {
      return _allowances[owner][spender];
  }

  /// @dev Transfer token to a specified address.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function transfer(address to, uint256 value) public returns (bool success) {
    require(to != address(0), "Can't transfer tokens to address 0");
    require(balanceOf(msg.sender) >= value, "You don't have sufficient balance to move tokens");

    _move(msg.sender, to, value);

    return true;
  }

  /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  /// Beware that changing an allowance with this method brings the risk that someone may use both the old
  /// and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  /// race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  /// @param spender The address which will spend the funds.
  /// @param value The amount of tokens to be spent.
  function approve(address spender, uint256 value) public returns (bool success) {
    require(spender != address(0), "Can't set allowance for address 0");
    require(spender != msg.sender, "Use transfer to move your own funds");

    _allowances[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /// @dev Transfer tokens from one address to another.
  /// @param from address The address which you want to send tokens from
  /// @param to address The address which you want to transfer to
  /// @param value uint256 the amount of tokens to be transferred
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(to != address(0), "Can't transfer funds to address 0");

    // Validate that the sender is allowed to move funds on behalf of the owner
    require(allowance(from, msg.sender) >= value, "You're not authorized to transfer funds from this account");
    require(balanceOf(from) >= value, "Owner of funds does not have sufficient balance");

    // Decrease allowance
    _allowances[from][msg.sender] -= value;

    // Move actual token balances
    _move(from, to, value);

    return true;
  }

  /// @notice cancels all grants pending for a given beneficiary. If you want to cancel a single
  /// vest, cancel all pending grants, and reinstate the ones you plan to keep
  function cancelGrants(address beneficiary) public onlyAdmins() {
    Grant[] storage userGrants = _grants[beneficiary];
    for (uint i = 0; i < userGrants.length; i++) {
      Grant storage grant = userGrants[i];
      if (!grant.isCancelled && !grant.isClaimed) {
        grant.isCancelled = true;

        // remove from pending grants
        pendingGrants -= grant.amount;
      }
    }
  }

  /// @notice Converts a vest schedule into actual shares. Must be called by the beneficiary
  // to convert their vests into actual shares
  function claimGrant() public {
    Grant[] storage userGrants = _grants[msg.sender];
    for (uint i = 0; i < userGrants.length; i++) {
      Grant storage grant = userGrants[i];
      if (!grant.isCancelled && !grant.isClaimed && now >= grant.vestTime) {
        grant.isClaimed = true;

        // remove from pending grants
        pendingGrants -= grant.amount;

        // issue tokens to the user
        _issue(msg.sender, grant.amount);
      }
    }
  }

  /// @notice returns information about a grant that user has. Returns a tuple indicating
  /// the amount of the grant, when it will vest, whether it's been cancelled, and whether it's been claimed
  /// already.
  /// @param grantIndex a 0-based index of user's grant to retrieve
  function getGrant(address beneficiary, uint grantIndex) public view returns (uint, uint, bool, bool) {
    Grant[] storage grants = _grants[beneficiary];
    if (grantIndex < grants.length) {
      Grant storage grant = grants[grantIndex];
      return (grant.amount, grant.vestTime, grant.isCancelled, grant.isClaimed);
    } else {
      revert("grantIndex must be smaller than length of grants");
    }
  }

  /// @notice returns number of grants a user has
  function getGrantCount(address beneficiary) public view returns (uint) {
    return _grants[beneficiary].length;
  }

  /// @dev Internal function that increases the token supply by issuing new ones
  /// and assigning them to an owner.
  /// @param account The account that will receive the created tokens.
  /// @param amount The amount that will be created.
  function issue(address account, uint256 amount) public onlyAdmins() {
    require(account != address(0), "can't mint to address 0");
    require(amount > 0, "must issue a positive amount of tokens");
    _issue(account, amount);
  }

  /// @dev Internal function that grants shares to a beneficiary in a future date.
  /// @param vestTime milliseconds since epoch at which time shares can be claimed
  function grant(address account, uint256 amount, uint vestTime) public onlyAdmins() {
    require(account != address(0), "grant to the zero address is not allowed");
    require(vestTime > now, "vest schedule must be in the future");

    pendingGrants += amount;
    _grants[account].push(Grant(amount, vestTime, false, false));
  }

  /// @dev Internal helper to move balances around between two accounts.
  function _move(address from, address to, uint256 value) private {
    _balances[from] -= value;
    _balances[to] += value;
    emit Transfer(from, to, value);
  }

  /// @dev issues/mints new tokens for the specified account
  function _issue(address account, uint256 amount) private {
    totalSupply += amount;
    _balances[account] += amount;
    emit Issuance(account, amount);
  }
}