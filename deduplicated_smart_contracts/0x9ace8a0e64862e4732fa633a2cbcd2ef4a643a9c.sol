/**
 *Submitted for verification at Etherscan.io on 2019-10-22
*/

pragma solidity >=0.5.0 <0.6.0;

interface IRelay {

    /// @notice Transfer NMR on behalf of a Numerai user
    ///         Can only be called by Manager or Owner
    /// @dev Can only be used on the first 1 million ethereum addresses
    /// @param _from The user address
    /// @param _to The recipient address
    /// @param _value The amount of NMR in wei
    function withdraw(address _from, address _to, uint256 _value) external returns (bool ok);

    /// @notice Burn the NMR sent to address 0 and burn address
    function burnZeroAddress() external;

    /// @notice Permanantly disable the relay contract
    ///         Can only be called by Owner
    function disable() external;

    /// @notice Permanantly disable token upgradability
    ///         Can only be called by Owner
    function disableTokenUpgradability() external;

    /// @notice Upgrade the token delegate logic.
    ///         Can only be called by Owner
    /// @param _newDelegate Address of the new delegate contract
    function changeTokenDelegate(address _newDelegate) external;

    /// @notice Upgrade the token delegate logic using the UpgradeDelegate
    ///         Can only be called by Owner
    /// @dev must be called after UpgradeDelegate is set as the token delegate
    /// @param _multisig Address of the multisig wallet address to receive NMR and ETH
    /// @param _delegateV3 Address of NumeraireDelegateV3
    function executeUpgradeDelegate(address _multisig, address _delegateV3) external;

    /// @notice Burn stakes during initialization phase
    ///         Can only be called by Manager or Owner
    /// @dev must be called after UpgradeDelegate is set as the token delegate
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    function destroyStake(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) external;

}


interface INMR {

    /* ERC20 Interface */

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /* NMR Special Interface */

    // used for user balance management
    function withdraw(address _from, address _to, uint256 _value) external returns(bool ok);

    // used for migrating active stakes
    function destroyStake(address _staker, bytes32 _tag, uint256 _tournamentID, uint256 _roundID) external returns (bool ok);

    // used for disabling token upgradability
    function createRound(uint256, uint256, uint256, uint256) external returns (bool ok);

    // used for upgrading the token delegate logic
    function createTournament(uint256 _newDelegate) external returns (bool ok);

    // used like burn(uint256)
    function mint(uint256 _value) external returns (bool ok);

    // used like burnFrom(address, uint256)
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);

    // used to check if upgrade completed
    function contractUpgradable() external view returns (bool);

    function getTournament(uint256 _tournamentID) external view returns (uint256, uint256[] memory);

    function getRound(uint256 _tournamentID, uint256 _roundID) external view returns (uint256, uint256, uint256);

    function getStake(uint256 _tournamentID, uint256 _roundID, address _staker, bytes32 _tag) external view returns (uint256, uint256, bool, bool);

    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);
}


interface IErasureStake {
    function increaseStake(uint256 currentStake, uint256 amountToAdd) external;
    function reward(uint256 currentStake, uint256 amountToAdd) external;
    function punish(uint256 currentStake, uint256 punishment, bytes calldata message) external returns (uint256 cost);
    function releaseStake(uint256 currentStake, uint256 amountToRelease) external;
}



/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/* TODO: Update eip165 interface
 *  bytes4(keccak256('create(bytes)')) == 0xcf5ba53f
 *  bytes4(keccak256('getInstanceType()')) == 0x18c2f4cf
 *  bytes4(keccak256('getInstanceRegistry()')) == 0xa5e13904
 *  bytes4(keccak256('getImplementation()')) == 0xaaf10f42
 *
 *  => 0xcf5ba53f ^ 0x18c2f4cf ^ 0xa5e13904 ^ 0xaaf10f42 == 0xd88967b6
 */
 interface iFactory {

     event InstanceCreated(address indexed instance, address indexed creator, string initABI, bytes initData);

     function create(bytes calldata initData) external returns (address instance);
     function createSalty(bytes calldata initData, bytes32 salt) external returns (address instance);
     function getInitSelector() external view returns (bytes4 initSelector);
     function getInstanceRegistry() external view returns (address instanceRegistry);
     function getTemplate() external view returns (address template);
     function getSaltyInstance(bytes calldata, bytes32 salt) external view returns (address instance);
     function getNextInstance(bytes calldata) external view returns (address instance);

     function getInstanceCreator(address instance) external view returns (address creator);
     function getInstanceType() external view returns (bytes4 instanceType);
     function getInstanceCount() external view returns (uint256 count);
     function getInstance(uint256 index) external view returns (address instance);
     function getInstances() external view returns (address[] memory instances);
     function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
 }


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

    uint256[50] private ______gap;
}



contract Manageable is Initializable, Ownable {
    address private _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    /**
     * @dev The Managable constructor sets the original `manager` of the contract to the sender
     * account.
     */
    function initialize(address sender) initializer public {
        Ownable.initialize(sender);
        _manager = sender;
        emit ManagementTransferred(address(0), _manager);
    }

    /**
     * @return the address of the manager.
     */
    function manager() public view returns (address) {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the owner or manager.
     */
    modifier onlyManagerOrOwner() {
        require(isManagerOrOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner or manager of the contract.
     */
    function isManagerOrOwner() public view returns (bool) {
        return (msg.sender == _manager || isOwner());
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newManager.
     * @param newManager The address to transfer management to.
     */
    function transferManagement(address newManager) public onlyOwner {
        require(newManager != address(0));
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }

    uint256[50] private ______gap;
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 *      Modified from openzeppelin Pausable to simplify access control.
 */
contract Pausable is Initializable, Manageable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    /// @notice Initializer function called at time of deployment
    /// @param sender The address of the wallet to handle permission control
    function initialize(address sender) public initializer {
        Manageable.initialize(sender);
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "contract is paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "expected contract to be paused");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyManagerOrOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    uint256[50] private ______gap;
}








contract NumeraiErasureV1 is Initializable, Pausable {
    using SafeMath for uint256;

    event CreateStake(
        address indexed agreement,
        address indexed staker
    );

    event CreateAndIncreaseStake(
        address indexed agreement,
        address indexed staker,
        uint256 amount
    );

    event IncreaseStake(
        address indexed agreement,
        address indexed staker,
        uint256 oldStakeAmount,
        uint256 amountAdded
    );

    event Reward(
        address indexed agreement,
        address indexed staker,
        uint256 oldStakeAmount,
        uint256 amountAdded
    );

    event Punish(
        address indexed agreement,
        address indexed staker,
        uint256 oldStakeAmount,
        uint256 amountPunished,
        bytes message
    );

    event ReleaseStake(
        address indexed agreement,
        address indexed staker,
        uint256 oldStakeAmount,
        uint256 amountReleased
    );

    event ResolveAndReleaseStake(
        address indexed agreement,
        address indexed staker,
        uint256 oldStakeAmount,
        uint256 amountReleased,
        uint256 amountStakeChanged,
        bool isReward
    );

    // set the address of the NMR token as a constant (stored in runtime code)
    address private constant _TOKEN = address(
        0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671
    );

    // set the address of the relay as a constant (stored in runtime code)
    address private constant _RELAY = address(
        0xB17dF4a656505570aD994D023F632D48De04eDF2
    );

    /// @notice Initializer function called at time of deployment
    /// @param _owner The address of the wallet to handle permission control
    function initialize(
        address _owner
    ) public initializer {
        // initialize the contract's ownership.
        Pausable.initialize(_owner);
    }

    /////////////////////////////
    // Fund Recovery Functions //
    /////////////////////////////

    /// @notice Recover the ETH sent to this contract address
    ///         Can only be called by the owner
    /// @param recipient The address of the recipient
    function recoverETH(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
    }

    /// @notice Recover the NMR sent to this address
    ///         Can only be called by the owner
    /// @param recipient The address of the recipient
    function recoverNMR(address payable recipient) public onlyOwner {
        uint256 balance = INMR(_TOKEN).balanceOf(address(this));
        require(INMR(_TOKEN).transfer(recipient, balance), "transfer failed");
    }


    ////////////////////////
    // Internal Functions //
    ////////////////////////

    function _approveNMR(address agreement, uint256 amountToAdd) internal {
        uint256 oldAllowance = INMR(_TOKEN).allowance(address(this), agreement);
        uint256 newAllowance = oldAllowance.add(amountToAdd);
        require(INMR(_TOKEN).changeApproval(agreement, oldAllowance, newAllowance), "Failed to approve");
    }

    ///////////////////
    // NMR Functions //
    ///////////////////

    /// @notice Transfer NMR on behalf of a Numerai user
    ///         Can only be called by Numerai
    /// @dev Calls the NMR token contract through the relay contract
    ///      Can only be used on the first 1 million ethereum addresses.
    /// @param from The user address
    /// @param to The recipient address
    /// @param value The amount of NMR in wei
    function withdraw(
        address from,
        address to,
        uint256 value
    ) public onlyManagerOrOwner whenNotPaused {
        IRelay(_RELAY).withdraw(from, to, value);
    }

    ///////////////////////
    // Erasure Functions //
    ///////////////////////

    /// @notice Owned function to stake on Erasure agreement
    ///         Can only be called by Numerai
    ///         This function is intended as a bridge to allow for our custodied user accounts
    ///         (ie. the first million addresses), to stake in an Erasure agreement. Erasure
    ///         agreements assume an ERC-20 token, and the way we did custody doesn't quite fit
    ///         in the normal ERC-20 way of doing things. Ideally, we would be able to call
    ///         `changeApproval` on behalf of our custodied accounts, but that is unfortunately
    ///         not possible.
    ///         Instead what we have to do is `withdraw` the NMR into this contract and then call
    ///         `changeApproval` on this contract before calling `increaseStake` on the Erasure
    ///         agreement. The NMR is then taken from this contract to increase the stake.
    /// @param agreement The address of the agreement contract. Must conform to IErasureStake interface
    /// @param staker The address of the staker
    /// @param currentStake The amount of NMR in wei already staked on the agreement
    /// @param stakeAmount The amount of NMR in wei to incease the stake with this agreement
    function increaseStake(
        address agreement, address staker, uint256 currentStake, uint256 stakeAmount
    ) public onlyManagerOrOwner whenNotPaused {
        require(stakeAmount > 0, "Cannot stake zero NMR");

        uint256 oldBalance = INMR(_TOKEN).balanceOf(address(this));

        require(IRelay(_RELAY).withdraw(staker, address(this), stakeAmount), "Failed to withdraw");

        _approveNMR(agreement, stakeAmount);

        IErasureStake(agreement).increaseStake(currentStake, stakeAmount);

        uint256 newBalance = INMR(_TOKEN).balanceOf(address(this));
        require(oldBalance == newBalance, "Balance before/after did not match");

        emit IncreaseStake(agreement, staker, currentStake, stakeAmount);
    }

    /// @notice Owned function to create an Erasure agreement stake
    /// @param factory The address of the agreement factory. Must conform to iFactory interface
    /// @param agreement The address of the agreement contract that will be created. Get this value by running factory.getSaltyInstance(...)
    /// @param staker The address of the staker
    /// @param callData The callData used to create the agreement
    /// @param salt The salt used to create the agreement
    function createStake(
        address factory, address agreement, address staker, bytes memory callData, bytes32 salt
    ) public onlyManagerOrOwner whenNotPaused {
        require(iFactory(factory).createSalty(callData, salt) == agreement, "Unexpected agreement address");

        emit CreateStake(agreement, staker);
    }

    /// @notice Owned function to create an Erasure agreement stake
    /// @param factory The address of the agreement factory. Must conform to iFactory interface
    /// @param agreement The address of the agreement contract that will be created. Get this value by running factory.getSaltyInstance(...)
    /// @param staker The address of the staker
    /// @param stakeAmount The amount of NMR in wei to incease the stake with this agreement
    /// @param callData The callData used to create the agreement
    /// @param salt The salt used to create the agreement
    function createAndIncreaseStake(
        address factory, address agreement, address staker, uint256 stakeAmount, bytes memory callData, bytes32 salt
    ) public onlyManagerOrOwner whenNotPaused {
        createStake(factory, agreement, staker, callData, salt);

        increaseStake(agreement, staker, 0, stakeAmount);

        emit CreateAndIncreaseStake(agreement, staker, stakeAmount);
    }

    /// @notice Owned function to reward an Erasure agreement stake
    /// NMR tokens must be stored in this contract before this call.
    /// @param agreement The address of the agreement contract. Must conform to IErasureStake interface
    /// @param staker The address of the staker
    /// @param currentStake The amount of NMR in wei already staked on the agreement
    /// @param amountToAdd The amount of NMR in wei to incease the stake with this agreement
    function reward(
        address agreement, address staker, uint256 currentStake, uint256 amountToAdd
    ) public onlyManagerOrOwner whenNotPaused {
        require(amountToAdd > 0, "Cannot add zero NMR");

        uint256 oldBalance = INMR(_TOKEN).balanceOf(address(this));

        _approveNMR(agreement, amountToAdd);

        IErasureStake(agreement).reward(currentStake, amountToAdd);

        uint256 newBalance = INMR(_TOKEN).balanceOf(address(this));
        require(oldBalance.sub(amountToAdd) == newBalance, "Balance before/after did not match");

        emit Reward(agreement, staker, currentStake, amountToAdd);
    }

    /// @notice Owned function to punish an Erasure agreement stake
    /// @param agreement The address of the agreement contract. Must conform to IErasureStake interface
    /// @param staker The address of the staker
    /// @param currentStake The amount of NMR in wei already staked on the agreement
    /// @param punishment The amount of NMR in wei to punish the stake with this agreement
    function punish(
        address agreement, address staker, uint256 currentStake, uint256 punishment, bytes memory message
    ) public onlyManagerOrOwner whenNotPaused {
        require(punishment > 0, "Cannot punish zero NMR");

        uint256 oldBalance = INMR(_TOKEN).balanceOf(address(this));

        IErasureStake(agreement).punish(currentStake, punishment, message);

        uint256 newBalance = INMR(_TOKEN).balanceOf(address(this));
        require(oldBalance == newBalance, "Balance before/after did not match");

        emit Punish(agreement, staker, currentStake, punishment, message);
    }

    /// @notice Owned function to release an Erasure agreement stake
    /// @param agreement The address of the agreement contract. Must conform to IErasureStake interface
    /// @param staker The address of the staker
    /// @param currentStake The amount of NMR in wei already staked on the agreement
    /// @param amountToRelease The amount of NMR in wei to release back to the staker
    function releaseStake(
        address agreement, address staker, uint256 currentStake, uint256 amountToRelease
    ) public onlyManagerOrOwner whenNotPaused {
        require(amountToRelease > 0, "Cannot release zero NMR");

        IErasureStake(agreement).releaseStake(currentStake, amountToRelease);

        emit ReleaseStake(agreement, staker, currentStake, amountToRelease);
    }

    /// @notice Owned function to resolve and then release an Erasure agreement stake
    /// @param agreement The address of the agreement contract. Must conform to IErasureStake interface
    /// @param staker The address of the staker
    /// @param currentStake The amount of NMR in wei already staked on the agreement
    /// @param amountToRelease The amount of NMR in wei to release back to the staker
    /// @param amountToChangeStake The amount of NMR to change the stake with
    /// @param isReward Boolean, if true then reward, else punish
    function resolveAndReleaseStake(
        address agreement, address staker, uint256 currentStake, uint256 amountToRelease, uint256 amountToChangeStake, bool isReward
    ) public onlyManagerOrOwner whenNotPaused {
        require(amountToRelease != 0, "Cannot release with zero NMR");

        uint256 newStake = currentStake;
        if (amountToChangeStake != 0) {
            if(isReward) {
                reward(agreement, staker, currentStake, amountToChangeStake);
                newStake = currentStake.add(amountToChangeStake);
            } else {
                punish(agreement, staker, currentStake, amountToChangeStake, "punish before release");
                newStake = currentStake.sub(amountToChangeStake);
            }
        }

        releaseStake(agreement, staker, newStake, amountToRelease);

        emit ResolveAndReleaseStake(agreement, staker, currentStake, amountToRelease, amountToChangeStake, isReward);
    }
}