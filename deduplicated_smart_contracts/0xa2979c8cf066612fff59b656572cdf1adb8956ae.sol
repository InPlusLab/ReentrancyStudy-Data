/**
 *Submitted for verification at Etherscan.io on 2020-04-05
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/interfaces/IMultiSigWalletWithDailyLimit.sol

pragma solidity 0.4.25;

interface IMultiSigWalletWithDailyLimit {

    function transactions(uint256 id) external view returns (address,uint,bytes,bool);

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
        external
        returns (uint transactionId);

    /// @dev Allows to change the daily limit. Transaction has to be sent by wallet.
    /// @param _dailyLimit Amount in wei.
    function changeDailyLimit(uint _dailyLimit) external;
}

// File: contracts/interfaces/IMultiSigWalletWithDailyLimitFactory.sol

pragma solidity 0.4.25;

interface IMultiSigWalletWithDailyLimitFactory {

    /// @dev Allows verified creation of multisignature wallet.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    /// @param _dailyLimit Amount in wei, which can be withdrawn without confirmations on a daily basis.
    /// @return Returns wallet address.
    function create(address[] _owners, uint _required, uint _dailyLimit)
        external
        returns (address wallet);
}

// File: contracts/interfaces/IFeePool.sol

pragma solidity 0.4.25;

interface IFeePool {
    /**
     * @notice Check if a particular address is able to claim fees right now
     * @param account The address you want to query for
     */
    function isFeesClaimable(address account) external view returns (bool);

    /**
     * @notice The fees available to be withdrawn by a specific account, priced in sUSD
     * @dev Returns two amounts, one for fees and one for SNX rewards
     */
    function feesAvailable(address account) external view returns (uint, uint);

    /**
     * @notice Delegated claimFees(). Call from the delegated address
     * and the fees will be sent to the claimingForAddress.
     * approveClaimOnBehalf() must be called first to approve the delegate address
     * @param claimingForAddress The account you are claiming fees for
     */
    function claimOnBehalf(address claimingForAddress) external returns (bool);
}

// File: contracts/interfaces/IDelegateApprovals.sol

pragma solidity 0.4.25;

interface IDelegateApprovals {

    function canClaimFor(address authoriser, address delegate) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.4.24;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(address(this), spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

// File: openzeppelin-solidity/contracts/Ownership/Ownable.sol

pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.4.24;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}

// File: contracts/utils/Withdrawable.sol

pragma solidity >=0.4.24;





contract Withdrawable is Ownable, ReentrancyGuard {
    using SafeERC20 for ERC20;
    address constant ETHER = address(0);

    event LogWithdrawAsset(
        address indexed _from,
        address indexed _asset,
        uint amount
    );

    /**
     * @dev Withdraw asset.
     * @param _assetAddress Asset to be withdrawn.
     * @return bool.
     */
    function withdrawAsset(address _assetAddress) public nonReentrant onlyOwner {
        uint assetBalance;
        if (_assetAddress == ETHER) {
            address self = address(this); // workaround for a possible solidity bug
            assetBalance = self.balance;
            require(msg.sender.call.value(assetBalance)(''), 'Transfer failed');
        } else {
            assetBalance = ERC20(_assetAddress).balanceOf(address(this));
            ERC20(_assetAddress).safeTransfer(msg.sender, assetBalance);
        }
        emit LogWithdrawAsset(msg.sender, _assetAddress, assetBalance);
    }

}

// File: contracts/SNXLinkV1.sol

pragma solidity 0.4.25;







contract SNXLinkV1 is Withdrawable, IFeePool, IDelegateApprovals {
    using SafeMath for uint256;

    /// Storage

    // @notice Mapping user max gas price settings
    mapping(address => uint256) public userMaxGasPrices;
    // @notice Mapping user max fee per claim
    mapping(address => uint256) public userMaxFeePerClaim;
    // @notice Mapping user fee wallets
    mapping(address => IMultiSigWalletWithDailyLimit) public userFeeWallets;
    // @notice Mapping user auto-claim activation status
    mapping(address => bool) public userAutoClaimDisabled;

    // @notice Gnosis Wallet Factory
    IMultiSigWalletWithDailyLimitFactory public userFeeWalletFactory;
    // @notice Synthetix FeePool
    IFeePool public snxFeePool;
    // @notice Synthetix DelegateApprovals
    IDelegateApprovals public snxDelegateApprovals;

    // @notice Platform fee wallet
    address public feeCollector;
    // @notice Platform fee
    uint256 public platformFee;
    // @notice Claimer fee
    uint256 public claimerFee;

    // @notice Gas correction offset
    uint256 public gasOffsetCorrection;

    // @notice Registered users
    address[] public registeredUsers;

    // @notice Count of total users registered
    uint256 public registeredUsersCount;

    // @notice Count of total users disabled
    uint256 public disabledUsersCount;

    // @notice Total fees claimed;
    uint256 public totalFeesClaimed;

    // @notice Total rewards claimed;
    uint256 public totalRewardsClaimed;


    /// Events

    // @notice Emits when fee sent to the claimer.
    event PayFeeToClaimer(
        address indexed claimer,
        uint256 amount
    );

    // @notice Emits when fee sent to the platform.
    event PayFeeToPlatform();

    // @notice Emits when claimer claims on behalf of user.
    event Claim(
        address indexed user,
        address indexed claimer,
        uint256 availableFees,
        uint256 availableRewards
    );

    // @notice Emits when the user register.
    event Register(address indexed user);

    // @notice Emits when the user change settings.
    event ChangeSettings(
        address indexed user,
        uint256 maxGasPrice,
        uint256 maxFeePerClaim,
        uint256 enabled
    );


    /// Modifiers

    // @dev Throws if the user does not exists
    modifier onlyRegisteredUser(address user) {
        require(isRegistered(user), 'Auch! User is not registered');
        _;
    }

    // @dev Throws if the gasPrice is invalid
    modifier validMaxGasPrice(uint256 maxGasPrice) {
        require(maxGasPrice != 0, 'Max Gas Price should be greater than 0');
        _;
    }

    // @dev Throws if the gasPrice is invalid
    modifier validMaxFeePerClaim(uint256 maxFeePerClaim) {
        require(maxFeePerClaim != 0, 'Max Fee per Claim should be greater than 0');
        _;
    }

    /// Logic

    constructor(
        address _userFeeWalletFactory,
        address _snxFeePool,
        address _snxDelegateApprovals,
        address _feeCollector,
        uint256 _platformFee,
        uint256 _claimerFee,
        uint256 _gasOffsetCorrection
    ) public {
        userFeeWalletFactory = IMultiSigWalletWithDailyLimitFactory(_userFeeWalletFactory);

        snxFeePool = IFeePool(_snxFeePool);
        snxDelegateApprovals = IDelegateApprovals(_snxDelegateApprovals);

        feeCollector = _feeCollector;
        platformFee = _platformFee;
        claimerFee = _claimerFee;

        gasOffsetCorrection = _gasOffsetCorrection;
    }

    function isRegistered(address user) public view returns (bool) {
        return address(userFeeWallets[user]) != address(0);
    }

    function register(uint256 _maxGasPrice, uint256 _maxFeePerClaim)
        validMaxGasPrice(_maxGasPrice)
        validMaxFeePerClaim(_maxFeePerClaim)
        external payable returns (address) {
        require(!isRegistered(msg.sender), 'User already registered');

        address[] memory owners = new address[](2);
        owners[0] = msg.sender;
        owners[1] = address(this);

        address userWallet = userFeeWalletFactory.create(
            owners,
            1,
            0
        );

        userFeeWallets[msg.sender] = IMultiSigWalletWithDailyLimit(userWallet);

        require(userWallet.call.value(msg.value)(''), 'Transfer failed');

        userMaxGasPrices[msg.sender] = _maxGasPrice;
        userMaxFeePerClaim[msg.sender] = _maxFeePerClaim;

        registeredUsersCount++;
        registeredUsers.push(msg.sender);
        emit Register(msg.sender);

        return userWallet;
    }

    function setMaxGasPrice(uint256 _maxGasPrice)
        validMaxGasPrice(_maxGasPrice)
        onlyRegisteredUser(msg.sender)
        external {
        require(userMaxGasPrices[msg.sender] != _maxGasPrice, 'Same setting');

        userMaxGasPrices[msg.sender] = _maxGasPrice;
        emit ChangeSettings(msg.sender, _maxGasPrice, 0, 0);
    }

    function setMaxFeePerClaim(uint256 _maxFeePerClaim)
        validMaxFeePerClaim(_maxFeePerClaim)
        onlyRegisteredUser(msg.sender)
        external {
        require(userMaxFeePerClaim[msg.sender] != _maxFeePerClaim, 'Same setting');

        userMaxFeePerClaim[msg.sender] = _maxFeePerClaim;
        emit ChangeSettings(msg.sender, 0, _maxFeePerClaim, 0);
    }

    function enable()
        onlyRegisteredUser(msg.sender)
        external {
        require(userAutoClaimDisabled[msg.sender], 'Already enabled');

        userAutoClaimDisabled[msg.sender] = false;
        disabledUsersCount--;
        emit ChangeSettings(msg.sender, 0, 0, 1);
    }

    function disable()
        onlyRegisteredUser(msg.sender)
        external {
        require(!userAutoClaimDisabled[msg.sender], 'Already disabled');

        userAutoClaimDisabled[msg.sender] = true;
        disabledUsersCount++;
        emit ChangeSettings(msg.sender, 0, 0, 2);
    }

    function applySettings(
        uint256 _maxGasPrice,
        uint256 _maxFeePerClaim,
        bool _enabled
    )   validMaxGasPrice(_maxGasPrice)
        validMaxFeePerClaim(_maxFeePerClaim)
        onlyRegisteredUser(msg.sender)
        external {

        uint256 maxGasPrice;
        uint256 maxFeePerClaim;
        uint256 enabled;

        bool changed;

        if (userMaxGasPrices[msg.sender] != _maxGasPrice) {
            userMaxGasPrices[msg.sender] = _maxGasPrice;
            maxGasPrice = _maxGasPrice;
            changed = true;
        }

        if (userMaxFeePerClaim[msg.sender] != _maxFeePerClaim) {
            userMaxFeePerClaim[msg.sender] = _maxFeePerClaim;
            maxFeePerClaim = _maxFeePerClaim;
            changed = true;
        }

        if (userAutoClaimDisabled[msg.sender] == _enabled) {
            if (_enabled) {
                userAutoClaimDisabled[msg.sender] = false;
                disabledUsersCount--;
                enabled = 1;
            } else {
                userAutoClaimDisabled[msg.sender] = true;
                disabledUsersCount++;
                enabled = 2;
            }

            changed = true;
        }

        require(changed, 'Nothing changed');

        emit ChangeSettings(
            msg.sender,
            maxGasPrice,
            maxFeePerClaim,
            enabled
        );
    }

    function topUp()
        onlyRegisteredUser(msg.sender)
        external payable {
        require(address(userFeeWallets[msg.sender]).call.value(msg.value)(''), 'Transfer failed');
    }

    function withdraw(uint256 value)
        onlyRegisteredUser(msg.sender)
        nonReentrant
        external {
        IMultiSigWalletWithDailyLimit userFeeWallet = userFeeWallets[msg.sender];

        uint256 txid = userFeeWallet.submitTransaction(msg.sender, value, '');

        (,,,bool executed) = userFeeWallet.transactions(txid);
        require(executed, 'Unable to withdraw from user wallet!');
    }

    function canClaimFor(address authoriser, address /* delegate */)
        external view returns (bool) {
        return snxDelegateApprovals.canClaimFor(authoriser, address (this));
    }

    function isFeesClaimable(address account)
        public view returns (bool) {
        return snxFeePool.isFeesClaimable(account);
    }

    function feesAvailable(address account)
        public view returns (uint, uint) {
        return snxFeePool.feesAvailable(account);
    }

    function canClaim(address user) public view returns (bool) {
        (uint256 availableFees, uint256 availableRewards) = snxFeePool.feesAvailable(user);

        return
            isRegistered(user) &&
            !userAutoClaimDisabled[user] &&
            (availableFees > 0 && availableRewards > 0) &&
            snxFeePool.isFeesClaimable(user) &&
            snxDelegateApprovals.canClaimFor(user, address(this));
    }

    function claimOnBehalf(address user)
        nonReentrant
        public returns(bool) {

        // Start gas counting
        uint256 startGas = gasleft();

        require(isRegistered(user), 'User is not registered');

        require(!userAutoClaimDisabled[user], 'User disabled auto-claim');

        require(tx.gasprice <= userMaxGasPrices[user], 'Gas Price higher than user configured');

        (uint256 availableFees, uint256 availableRewards) = snxFeePool.feesAvailable(user);

        require(snxFeePool.claimOnBehalf(user), 'Failed to ClaimOnBehalf');

        totalFeesClaimed = totalFeesClaimed.add(availableFees);
        totalRewardsClaimed = totalRewardsClaimed.add(availableRewards);
        emit Claim(user, msg.sender, availableFees, availableRewards);

        uint256 gasUsed = startGas - gasleft();

        // End gas counting

        uint256 totalRefundForClaimer =
            ((gasUsed.add(gasOffsetCorrection)).mul(tx.gasprice)).add(claimerFee);

        uint256 totalToWithdraw = totalRefundForClaimer.add(platformFee);
        require(totalToWithdraw <= userMaxFeePerClaim[user], 'Total cost higher than user configured');

        IMultiSigWalletWithDailyLimit userFeeWallet = userFeeWallets[user];
        uint256 txid = userFeeWallet.submitTransaction(address(this), totalToWithdraw, '');

        (,,,bool executed) = userFeeWallet.transactions(txid);
        require(executed, 'Unable to withdraw from user wallet!');

        require(msg.sender.call.value(totalRefundForClaimer)(''), 'Transfer to claimer failed');
        emit PayFeeToClaimer(msg.sender, totalRefundForClaimer);

        require(feeCollector.call.value(platformFee)(''), 'Transfer to feeCollector failed');
        emit PayFeeToPlatform();

        return true;
    }

    function () payable {}
}