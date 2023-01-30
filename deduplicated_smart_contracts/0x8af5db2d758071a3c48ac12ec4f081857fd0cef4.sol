/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity ^0.5.13;

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


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/// @title iFactory
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
interface iFactory {

    event InstanceCreated(address indexed instance, address indexed creator, bytes callData);

    function create(bytes calldata callData) external returns (address instance);
    function createSalty(bytes calldata callData, bytes32 salt) external returns (address instance);
    function getInitSelector() external view returns (bytes4 initSelector);
    function getInstanceRegistry() external view returns (address instanceRegistry);
    function getTemplate() external view returns (address template);
    function getSaltyInstance(address creator, bytes calldata callData, bytes32 salt) external view returns (address instance, bool validity);
    function getNextNonceInstance(address creator, bytes calldata callData) external view returns (address instance);

    function getInstanceCreator(address instance) external view returns (address creator);
    function getInstanceType() external view returns (bytes4 instanceType);
    function getInstanceCount() external view returns (uint256 count);
    function getInstance(uint256 index) external view returns (address instance);
    function getInstances() external view returns (address[] memory instances);
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
}



/// @title iRegistry
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
interface iRegistry {

    enum FactoryStatus { Unregistered, Registered, Retired }

    event FactoryAdded(address owner, address factory, uint256 factoryID, bytes extraData);
    event FactoryRetired(address owner, address factory, uint256 factoryID);
    event InstanceRegistered(address instance, uint256 instanceIndex, address indexed creator, address indexed factory, uint256 indexed factoryID);

    // factory state functions

    function addFactory(address factory, bytes calldata extraData ) external;
    function retireFactory(address factory) external;

    // factory view functions

    function getFactoryCount() external view returns (uint256 count);
    function getFactoryStatus(address factory) external view returns (FactoryStatus status);
    function getFactoryID(address factory) external view returns (uint16 factoryID);
    function getFactoryData(address factory) external view returns (bytes memory extraData);
    function getFactoryAddress(uint16 factoryID) external view returns (address factory);
    function getFactory(address factory) external view returns (FactoryStatus state, uint16 factoryID, bytes memory extraData);
    function getFactories() external view returns (address[] memory factories);
    function getPaginatedFactories(uint256 startIndex, uint256 endIndex) external view returns (address[] memory factories);

    // instance state functions

    function register(address instance, address creator, uint80 extraData) external;

    // instance view functions

    function getInstanceType() external view returns (bytes4 instanceType);
    function getInstanceCount() external view returns (uint256 count);
    function getInstance(uint256 index) external view returns (address instance);
    function getInstances() external view returns (address[] memory instances);
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
}



/// @title EventMetadata
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract EventMetadata {

    event MetadataSet(bytes metadata);

    // state functions

    function _setMetadata(bytes memory metadata) internal {
        emit MetadataSet(metadata);
    }
}



/// @title Operated
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract Operated {

    address private _operator;

    event OperatorUpdated(address operator);

    // state functions

    function _setOperator(address operator) internal {

        // can only be called when operator is null
        require(_operator == address(0), "operator already set");

        // cannot set to address 0
        require(operator != address(0), "cannot set operator to address 0");

        // set operator in storage
        _operator = operator;

        // emit event
        emit OperatorUpdated(operator);
    }

    function _transferOperator(address operator) internal {

        // requires existing operator
        require(_operator != address(0), "only when operator set");

        // cannot set to address 0
        require(operator != address(0), "cannot set operator to address 0");

        // set operator in storage
        _operator = operator;

        // emit event
        emit OperatorUpdated(operator);
    }

    function _renounceOperator() internal {

        // requires existing operator
        require(_operator != address(0), "only when operator set");

        // set operator in storage
        _operator = address(0);

        // emit event
        emit OperatorUpdated(address(0));
    }

    // view functions

    function getOperator() public view returns (address operator) {
        return _operator;
    }

    function isOperator(address caller) internal view returns (bool ok) {
        return caller == _operator;
    }

}



/// @title Template
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract Template {

    address private _factory;

    // modifiers

    modifier initializeTemplate() {
        // set factory
        _factory = msg.sender;

        // only allow function to be `DELEGATECALL`ed from within a constructor.
        uint32 codeSize;
        assembly { codeSize := extcodesize(address) }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    // view functions

    function getCreator() public view returns (address creator) {
        // iFactory(...) would revert if _factory address is not actually a factory contract
        return iFactory(_factory).getInstanceCreator(address(this));
    }

    function isCreator(address caller) internal view returns (bool ok) {
        return (caller == getCreator());
    }

    function getFactory() public view returns (address factory) {
        return _factory;
    }

}



/// @title Deadline
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Deadline.png
contract Deadline {

    using SafeMath for uint256;

    uint256 private _deadline;

    event DeadlineSet(uint256 deadline);

    // state functions

    function _setDeadline(uint256 deadline) internal {
        _deadline = deadline;
        emit DeadlineSet(deadline);
    }

    // view functions

    function getDeadline() public view returns (uint256 deadline) {
        return _deadline;
    }

    // timeRemaining will default to 0 if _setDeadline is not called
    // if the now exceeds deadline, just return 0 as the timeRemaining
    function getTimeRemaining() public view returns (uint256 time) {
        if (_deadline > now)
            return _deadline.sub(now);
        else
            return 0;
    }

    enum DeadlineStatus { isNull, isSet, isOver }
    /// Return the status of the deadline state machine
    /// - isNull: the deadline has not been set
    /// - isSet: the deadline is set, but has not passed
    /// - isOver: the deadline has passed
    function getDeadlineStatus() public view returns (DeadlineStatus status) {
        if (_deadline == 0)
            return DeadlineStatus.isNull;
        if (_deadline > now)
            return DeadlineStatus.isSet;
        else
            return DeadlineStatus.isOver;
    }

    function isNull() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isNull;
    }

    function isSet() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isSet;
    }

    function isOver() internal view returns (bool status) {
        return getDeadlineStatus() == DeadlineStatus.isOver;
    }

}




/// @title Deposit
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Deposit.png
contract Deposit {

    using SafeMath for uint256;

    mapping (address => uint256) private _deposit;

    event DepositIncreased(address user, uint256 amount, uint256 newDeposit);
    event DepositDecreased(address user, uint256 amount, uint256 newDeposit);

    function _increaseDeposit(address user, uint256 amountToAdd) internal returns (uint256 newDeposit) {
        // calculate new deposit amount
        newDeposit = _deposit[user].add(amountToAdd);

        // set new stake to storage
        _deposit[user] = newDeposit;

        // emit event
        emit DepositIncreased(user, amountToAdd, newDeposit);

        // return
        return newDeposit;
    }

    function _decreaseDeposit(address user, uint256 amountToRemove) internal returns (uint256 newDeposit) {
        // get current deposit
        uint256 currentDeposit = _deposit[user];

        // check if sufficient deposit
        require(currentDeposit >= amountToRemove, "insufficient deposit to remove");

        // calculate new deposit amount
        newDeposit = currentDeposit.sub(amountToRemove);

        // set new stake to storage
        _deposit[user] = newDeposit;

        // emit event
        emit DepositDecreased(user, amountToRemove, newDeposit);

        // return
        return newDeposit;
    }

    function _clearDeposit(address user) internal returns (uint256 amountRemoved) {
        // get current deposit
        uint256 currentDeposit = _deposit[user];

        // remove deposit
        _decreaseDeposit(user, currentDeposit);

        // return
        return currentDeposit;
    }

    // view functions

    function getDeposit(address user) public view returns (uint256 deposit) {
        return _deposit[user];
    }

}


/* @title DecimalMath
 * @dev taken from https://github.com/PolymathNetwork/polymath-core
 * @dev Apache v2 License
 */
library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant e18 = uint256(10) ** uint256(18);

    /**
     * @notice This function multiplies two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of multiplication represented as (decimal * 10**DECIMALS)
     */
    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), (e18) / 2) / (e18);
    }

    /**
     * @notice This function divides two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of division represented as (decimal * 10**DECIMALS)
     */
    function div(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, (e18)), y / 2) / y;
    }

}



/// @title iNMR
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
contract iNMR {

    // ERC20
    function totalSupply() external returns (uint256);
    function balanceOf(address _owner) external returns (uint256);
    function allowance(address _owner, address _spender) external returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool ok);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool ok);
    function approve(address _spender, uint256 _value) external returns (bool ok);
    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);

    /// @dev Behavior has changed to match OpenZeppelin's `ERC20Burnable.burn(uint256 amount)`
    /// @dev Destoys `amount` tokens from `msg.sender`, reducing the total supply.
    ///
    /// Emits a `Transfer` event with `to` set to the zero address.
    /// Requirements:
    /// - `account` must have at least `amount` tokens.
    function mint(uint256 _value) external returns (bool ok);

    /// @dev Behavior has changed to match OpenZeppelin's `ERC20Burnable.burnFrom(address account, uint256 amount)`
    /// @dev Destoys `amount` tokens from `account`.`amount` is then deducted
    /// from the caller's allowance.
    ///
    /// Emits an `Approval` event indicating the updated allowance.
    /// Emits a `Transfer` event with `to` set to the zero address.
    ///
    /// Requirements:
    /// - `account` must have at least `amount` tokens.
    /// - `account` must have approved `msg.sender` with allowance of at least `amount` tokens.
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);
}




/// @title Countdown
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Countdown.png
contract Countdown is Deadline {

    using SafeMath for uint256;

    uint256 private _length;

    event LengthSet(uint256 length);

    // state functions

    function _setLength(uint256 length) internal {
        _length = length;
        emit LengthSet(length);
    }

    function _start() internal returns (uint256 deadline) {
        deadline = _length.add(now);
        Deadline._setDeadline(deadline);
        return deadline;
    }

    // view functions

    function getLength() public view returns (uint256 length) {
        return _length;
    }

    enum CountdownStatus { isNull, isSet, isActive, isOver }
    /// Return the status of the state machine
    /// - isNull: the length has not been set
    /// - isSet: the length is set, but the countdown is not started
    /// - isActive: the countdown has started but not yet ended
    /// - isOver: the countdown has completed
    function getCountdownStatus() public view returns (CountdownStatus status) {
        if (_length == 0)
            return CountdownStatus.isNull;
        if (Deadline.getDeadlineStatus() == DeadlineStatus.isNull)
            return CountdownStatus.isSet;
        if (Deadline.getDeadlineStatus() != DeadlineStatus.isOver)
            return CountdownStatus.isActive;
        else
            return CountdownStatus.isOver;
    }

    function isNull() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isNull;
    }

    function isSet() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isSet;
    }

    function isActive() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isActive;
    }

    function isOver() internal view returns (bool validity) {
        return getCountdownStatus() == CountdownStatus.isOver;
    }

}


/// @title BurnNMR
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @notice Allows for calling NMR burn functions using regular openzeppelin ERC20Burnable interface and revert on failure.
contract BurnNMR {

    // address of the token
    address private constant _Token = address(0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671);

    /// @notice Burns a specific amount of NMR from this contract.
    /// @param value uint256 The amount of NMR (18 decimals) to be burned.
    function _burn(uint256 value) internal {
        require(iNMR(_Token).mint(value), "nmr burn failed");
    }

    /// @dev Burns a specific amount of NMR from the target address and decrements allowance.
    /// @param from address The account whose tokens will be burned.
    /// @param value uint256 The amount of NMR (18 decimals) to be burned.
    function _burnFrom(address from, uint256 value) internal {
        require(iNMR(_Token).numeraiTransfer(from, value), "nmr burnFrom failed");
    }

    /// @notice Get the NMR token address.
    /// @return token address The NMR token address.
    function getToken() public pure returns (address token) {
        token = _Token;
    }

}






/// @title Staking
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Staking.png
contract Staking is Deposit, BurnNMR {

    using SafeMath for uint256;

    event StakeAdded(address staker, address funder, uint256 amount);
    event StakeTaken(address staker, address recipient, uint256 amount);
    event StakeBurned(address staker, uint256 amount);

    function _addStake(address staker, address funder, uint256 amountToAdd) internal {
        // update deposit
        Deposit._increaseDeposit(staker, amountToAdd);

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transferFrom(funder, address(this), amountToAdd), "token transfer failed");

        // emit event
        emit StakeAdded(staker, funder, amountToAdd);
    }

    function _takeStake(address staker, address recipient, uint256 amountToTake) internal returns (uint256 newStake) {
        // update deposit
        uint256 newDeposit = Deposit._decreaseDeposit(staker, amountToTake);

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transfer(recipient, amountToTake), "token transfer failed");

        // emit event
        emit StakeTaken(staker, recipient, amountToTake);

        // return
        return newDeposit;
    }

    function _takeFullStake(address staker, address recipient) internal returns (uint256 amountTaken) {
        // get deposit
        uint256 currentDeposit = Deposit.getDeposit(staker);

        // take full stake
        _takeStake(staker, recipient, currentDeposit);

        // return
        return currentDeposit;
    }

    function _burnStake(address staker, uint256 amountToBurn) internal returns (uint256 newStake) {
        // update deposit
        uint256 newDeposit = Deposit._decreaseDeposit(staker, amountToBurn);

        // burn the stake amount
        BurnNMR._burn(amountToBurn);

        // emit event
        emit StakeBurned(staker, amountToBurn);

        // return
        return newDeposit;
    }

    function _burnFullStake(address staker) internal returns (uint256 amountBurned) {
        // get deposit
        uint256 currentDeposit = Deposit.getDeposit(staker);

        // burn full stake
        _burnStake(staker, currentDeposit);

        // return
        return currentDeposit;
    }

    // view functions

    function getStake(address staker) public view returns (uint256 stake) {
        return Deposit.getDeposit(staker);
    }

}




/// @title Griefing
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/modules/Griefing.png
contract Griefing is Staking {

    enum RatioType { NaN, Inf, Dec }

    mapping (address => GriefRatio) private _griefRatio;
    struct GriefRatio {
        uint256 ratio;
        RatioType ratioType;
   }

    event RatioSet(address staker, uint256 ratio, RatioType ratioType);
    event Griefed(address punisher, address staker, uint256 punishment, uint256 cost, bytes message);

    uint256 internal constant e18 = uint256(10) ** uint256(18);

    // state functions

    /// @notice Set the grief ratio and type for a given staker
    /// @param staker Address of the staker
    /// @param ratio Uint256 number (18 decimals)
    ///              NOTE: ratio must be 0 if ratioType is Inf or NaN
    /// @param ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    function _setRatio(address staker, uint256 ratio, RatioType ratioType) internal {
        if (ratioType == RatioType.NaN || ratioType == RatioType.Inf) {
            require(ratio == 0, "ratio must be 0 when ratioType is NaN or Inf");
        }

        // set data in storage
        _griefRatio[staker].ratio = ratio;
        _griefRatio[staker].ratioType = ratioType;

        // emit event
        emit RatioSet(staker, ratio, ratioType);
    }

    /// @notice Punish a stake through griefing
    ///         NOTE: the cost of the punishment is taken form the account of the punisher. This therefore requires appropriate ERC-20 token approval.
    /// @param punisher Address of the punisher
    /// @param staker Address of the staker
    /// @param punishment Amount of NMR (18 decimals) to punish
    /// @param message Bytes reason string for the punishment
    /// @return cost Amount of NMR (18 decimals) to pay
    function _grief(
        address punisher,
        address staker,
        uint256 punishment,
        bytes memory message
    ) internal returns (uint256 cost) {
        // get grief data from storage
        uint256 ratio = _griefRatio[staker].ratio;
        RatioType ratioType = _griefRatio[staker].ratioType;

        require(ratioType != RatioType.NaN, "no punishment allowed");

        // calculate cost
        // getCost also acts as a guard when _setRatio is not called before
        cost = getCost(ratio, punishment, ratioType);

        // burn the cost from the punisher's balance
        BurnNMR._burnFrom(punisher, cost);

        // burn the punishment from the target's stake
        Staking._burnStake(staker, punishment);

        // emit event
        emit Griefed(punisher, staker, punishment, cost, message);

        // return
        return cost;
    }

    // view functions

    /// @notice Get the ratio of a staker
    /// @param staker Address of the staker
    /// @return ratio Uint256 number (18 decimals)
    /// @return ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    function getRatio(address staker) public view returns (uint256 ratio, RatioType ratioType) {
        // get stake data from storage
        return (_griefRatio[staker].ratio, _griefRatio[staker].ratioType);
    }

    // pure functions

    /// @notice Get exact cost for a given punishment and ratio
    /// @param ratio Uint256 number (18 decimals)
    /// @param punishment Amount of NMR (18 decimals) to punish
    /// @param ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    /// @return cost Amount of NMR (18 decimals) to pay
    function getCost(uint256 ratio, uint256 punishment, RatioType ratioType) public pure returns(uint256 cost) {
        if (ratioType == RatioType.Dec) {
            return DecimalMath.mul(SafeMath.mul(punishment, e18), ratio) / e18;
        }
        if (ratioType == RatioType.Inf)
            return 0;
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

    /// @notice Get approximate punishment for a given cost and ratio.
    ///         The punishment is an approximate value due to quantization / rounding.
    /// @param ratio Uint256 number (18 decimals)
    /// @param cost Amount of NMR (18 decimals) to pay
    /// @param ratioType Griefing.RatioType number. Ratio Type must be one of the following three values:
    ///                   - Dec: Ratio is a decimal number with 18 decimals
    ///                   - Inf: Punishment at no cost
    ///                   - NaN: No Punishment
    /// @return punishment Approximate amount of NMR (18 decimals) to punish
    function getPunishment(uint256 ratio, uint256 cost, RatioType ratioType) public pure returns(uint256 punishment) {
        if (ratioType == RatioType.Dec) {
            return DecimalMath.div(SafeMath.mul(cost, e18), ratio) / e18;
        }
        if (ratioType == RatioType.Inf)
            revert("ratioType cannot be RatioType.Inf");
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

}







/// @title CountdownGriefing
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/agreements/CountdownGriefing.png
/// @notice This agreement template allows a staker to grant permission to a counterparty to punish, reward, or release their stake until the countdown is completed.
///         A new instance is initialized by the factory using the `initData` received. See the `initialize()` function for details on initialization parameters.
///         Notable features:
///             - The staker can increase the stake at any time before the end of the countdown.
///             - The counterparty can increase, release, or punish the stake at any time before the end of the countdown.
///             - The agreement can be terminated by the staker by starting the countdown. Once the countdown completes the staker can retrieve their remaining stake.
///             - Punishments use griefing which requires the counterparty to pay an appropriate amount based on the desired punishment and a predetermined ratio.
///             - An operator can optionally be defined to grant full permissions to a trusted external address or contract.
contract CountdownGriefing is Countdown, Griefing, EventMetadata, Operated, Template {

    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address staker;
        address counterparty;
    }

    event Initialized(address operator, address staker, address counterparty, uint256 ratio, Griefing.RatioType ratioType, uint256 countdownLength, bytes metadata);

    /// @notice Constructor used to initialize the agreement parameters.
    ///         All parameters are passed as ABI-encoded calldata to the factory. This calldata must include the function selector.
    /// @dev Access Control: only factory
    ///      State Machine: before all
    /// @param operator address of the operator that overrides access control. Optional parameter. Passing the address(0) will disable operator functionality.
    /// @param staker address of the staker who owns the stake. Required parameter. This address is the only one able to retrieve the stake and cannot be changed.
    /// @param counterparty address of the counterparty who has the right to reward, release, and punish the stake. Required parameter. This address cannot be changed.
    /// @param ratio uint256 number (18 decimals) used to determine punishment cost. Required parameter. See Griefing module for details on valid input.
    /// @param ratioType Griefing.RatioType number used to determine punishment cost. Required parameter. See Griefing module for details on valid input.
    /// @param countdownLength uint256 amount of time (in seconds) the counterparty has to punish or reward before the agreement ends. Required parameter.
    /// @param metadata bytes data (any format) to emit as event on initialization. Optional parameter.
    function initialize(
        address operator,
        address staker,
        address counterparty,
        uint256 ratio,
        Griefing.RatioType ratioType,
        uint256 countdownLength,
        bytes memory metadata
    ) public initializeTemplate() {
        // set storage values
        _data.staker = staker;
        _data.counterparty = counterparty;

        // set operator
        if (operator != address(0)) {
            Operated._setOperator(operator);
        }

        // set griefing ratio
        Griefing._setRatio(staker, ratio, ratioType);

        // set countdown length
        Countdown._setLength(countdownLength);

        // set metadata
        if (metadata.length != 0) {
            EventMetadata._setMetadata(metadata);
        }

        // log initialization params
        emit Initialized(operator, staker, counterparty, ratio, ratioType, countdownLength, metadata);
    }

    // state functions

    /// @notice Emit metadata event
    /// @dev Access Control: operator
    ///      State Machine: always
    /// @param metadata bytes data (any format) to emit as event
    function setMetadata(bytes memory metadata) public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // update metadata
        EventMetadata._setMetadata(metadata);
    }

    /// @notice Called by the staker to increase the stake
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: staker OR operator
    ///      State Machine: before isTerminated()
    /// @param amountToAdd uint256 amount of NMR (18 decimals) to be added to the stake
    function increaseStake(uint256 amountToAdd) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // require agreement is not ended
        require(!isTerminated(), "agreement ended");

        // add stake
        Staking._addStake(_data.staker, msg.sender, amountToAdd);
    }

    /// @notice Called by the counterparty to increase the stake
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: before isTerminated()
    /// @param amountToAdd uint256 amount of NMR (18 decimals) to be added to the stake
    function reward(uint256 amountToAdd) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // require agreement is not ended
        require(!isTerminated(), "agreement ended");

        // add stake
        Staking._addStake(_data.staker, msg.sender, amountToAdd);
    }

    /// @notice Called by the counterparty to punish the stake
    ///          - burns the punishment from the stake and a proportional amount from the counterparty balance
    ///          - the cost of the punishment is calculated with the `Griefing.getCost()` function using the predetermined griefing ratio
    ///          - tokens (ERC-20) are burned from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: before isTerminated()
    /// @param punishment uint256 amount of NMR (18 decimals) to be burned from the stake
    /// @param message bytes data (any format) to emit as event giving reason for the punishment
    /// @return cost uint256 amount of NMR (18 decimals) it cost to perform punishment
    function punish(uint256 punishment, bytes memory message) public returns (uint256 cost) {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // require agreement is not ended
        require(!isTerminated(), "agreement ended");

        // execute griefing
        return Griefing._grief(msg.sender, _data.staker, punishment, message);
    }

    /// @notice Called by the counterparty to release the stake to the staker
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: anytime
    /// @param amountToRelease uint256 amount of NMR (18 decimals) to be released from the stake
    function releaseStake(uint256 amountToRelease) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // release stake back to the staker
        Staking._takeStake(_data.staker, _data.staker, amountToRelease);
    }

    /// @notice Called by the staker to begin countdown to finalize the agreement
    /// @dev Access Control: staker OR operator
    ///      State Machine: before Countdown.isActive()
    /// @return deadline uint256 timestamp (Unix seconds) at which the agreement will be finalized
    function startCountdown() public returns (uint256 deadline) {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // require countdown is not started
        require(isInitialized(), "deadline already set");

        // start countdown
        return Countdown._start();
    }

    /// @notice Called by the staker to retrieve the remaining stake once the agreement has ended
    /// @dev Access Control: staker OR operator
    ///      State Machine: after Countdown.isOver()
    /// @param recipient address of the account where to send the stake
    /// @return amount uint256 amount of NMR (18 decimals) retrieved
    function retrieveStake(address recipient) public returns (uint256 amount) {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // require deadline is passed
        require(isTerminated(), "deadline not passed");

        // retrieve stake
        return Staking._takeFullStake(_data.staker, recipient);
    }

    /// @notice Called by the operator to transfer control to new operator
    /// @dev Access Control: operator
    ///      State Machine: anytime
    /// @param operator address of the new operator
    function transferOperator(address operator) public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // transfer operator
        Operated._transferOperator(operator);
    }

    /// @notice Called by the operator to renounce control
    /// @dev Access Control: operator
    ///      State Machine: anytime
    function renounceOperator() public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // renounce operator
        Operated._renounceOperator();
    }

    // view functions

    /// @notice Get the address of the staker (if set)
    /// @return staker address of the staker
    function getStaker() public view returns (address staker) {
        return _data.staker;
    }

    /// @notice Validate if the address matches the stored staker address
    /// @param caller address to validate
    /// @return validity bool true if matching address
    function isStaker(address caller) internal view returns (bool validity) {
        return caller == getStaker();
    }

    /// @notice Get the address of the counterparty (if set)
    /// @return counterparty address of counterparty account
    function getCounterparty() public view returns (address counterparty) {
        return _data.counterparty;
    }

    /// @notice Validate if the address matches the stored counterparty address
    /// @param caller address to validate
    /// @return validity bool true if matching address
    function isCounterparty(address caller) internal view returns (bool validity) {
        return caller == getCounterparty();
    }

    /// @notice Get the current stake of the agreement
    /// @return stake uint256 amount of NMR (18 decimals) staked
    function getCurrentStake() public view returns (uint256 stake) {
        return Staking.getStake(_data.staker);
    }

    /// @notice Validate if the current stake is greater than 0
    /// @return validity bool true if non-zero stake
    function isStaked() public view returns (bool validity) {
        return getCurrentStake() > 0;
    }

    enum AgreementStatus { isInitialized, isInCountdown, isTerminated }
    /// @notice Get the status of the state machine
    /// @return status AgreementStatus from the following states:
    ///          - isInitialized: initialized but no deposits made
    ///          - isInCountdown: staker has triggered countdown to termination
    ///          - isTerminated: griefing agreement is over, staker can retrieve stake
    function getAgreementStatus() public view returns (AgreementStatus status) {
        if (Countdown.isOver()) {
            return AgreementStatus.isTerminated;
        } else if (Countdown.isActive()) {
            return AgreementStatus.isInCountdown;
        } else {
            return AgreementStatus.isInitialized;
        }
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isInitialized state
    /// @return validity bool true if correct state
    function isInitialized() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isInitialized;
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isInCountdown state
    /// @return validity bool true if correct state
    function isInCountdown() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isInCountdown;
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isTerminated state
    /// @return validity bool true if correct state
    function isTerminated() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isTerminated;
    }
}











/// @title CountdownGriefingEscrow
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/escrows/CountdownGriefingEscrow.png
/// @notice This escrow allows for a buyer and a seller to deposit their stake and payment before sending it to a CountdownGriefing agreement.
///         A new instance is initialized by the factory using the `initData` received. See the `initialize()` function for details.
///         Notable features:
///             - The deposited payment and stake become the stake of the agreement once the escrow is finalized.
///             - If the buyer is not defined on creation, the first user to deposit the payment becomes the buyer.
///             - If the seller is not defined on creation, the first user to deposit the stake becomes the seller.
///             - Either party is able to cancel the escrow and retrieve their deposit if their counterparty never completes their deposit.
///             - If the buyer deposits their payment after the stake has already been deposited by the seller, this starts a countdown for the seller to finalize the escrow.
///             - If the seller does not finalize the escrow before the end of the countdown, the buyer can timeout the escrow and recover their stake.
///             - An operator can optionally be defined to grant full permissions to a trusted external address or contract.
///         **Note**
///             Given the nature of ethereum, it is possible that while a cancel request is pending, the counterparty finalizes the escrow and the deposits are transfered to the agreement.
///             This contract is designed such that there is only two end states: deposits are returned to the buyer and the seller OR the agreement is successfully created.
///             This is why a user CANNOT rely on the cancellation feature to always work.
contract CountdownGriefingEscrow is Countdown, Staking, EventMetadata, Operated, Template {

    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address buyer;
        address seller;
        uint128 paymentAmount;
        uint128 stakeAmount;
        EscrowStatus status;
        AgreementParams agreementParams;
    }

    struct AgreementParams {
        uint120 ratio;
        Griefing.RatioType ratioType;
        uint128 countdownLength;
    }

    event Initialized(
        address operator,
        address buyer,
        address seller,
        uint256 paymentAmount,
        uint256 stakeAmount,
        uint256 countdownLength,
        bytes metadata,
        bytes agreementParams
    );
    event StakeDeposited(address seller, uint256 amount);
    event PaymentDeposited(address buyer, uint256 amount);
    event Finalized(address agreement);
    event DataSubmitted(bytes data);
    event Cancelled();

    /// @notice Constructor used to initialize the escrow parameters.
    /// @dev Access Control: only factory
    ///      State Machine: before all
    /// @param operator address of the operator that overrides access control. Optional parameter. Passing the address(0) will disable operator functionality.
    /// @param buyer address of the buyer. Optional parameter. This address is the only one able to deposit the payment. If not set, the first to deposit the payment becomes the buyer.
    /// @param seller address of the seller. Optional parameter. This address is the only one able to deposit the stake. If not set, the first to deposit the stake becomes the seller.
    /// @param paymentAmount uint256 amount of NMR (18 decimals) to be deposited by buyer as payment. Required parameter. This number must fit in a uint128 for optimization reasons.
    /// @param stakeAmount uint256 amount of NMR (18 decimals) to be deposited by seller as stake. Required parameter. This number must fit in a uint128 for optimization reasons.
    /// @param escrowCountdown uint256 amount of time (in seconds) the seller has to finalize the escrow after the payment and stake is deposited. Required parameter.
    /// @param metadata bytes data (any format) to emit as event on initialization. Optional parameter.
    /// @param agreementParams bytes ABI-encoded parameters used by CountdownGriefing agreement on initialization. Required parameter.
    ///                        This encoded data blob must contain the uint120 ratio, Griefing.RatioType ratioType, and uint128 agreementCountdown encoded as `abi.encode(ratio, ratioType, agreementCountdown)`.
    ///                        See CountdownGriefing initialize function for additional details.
    function initialize(
        address operator,
        address buyer,
        address seller,
        uint256 paymentAmount,
        uint256 stakeAmount,
        uint256 escrowCountdown,
        bytes memory metadata,
        bytes memory agreementParams
    ) public initializeTemplate() {
        // set participants if defined
        if (buyer != address(0)) {
            _data.buyer = buyer;
        }
        if (seller != address(0)) {
            _data.seller = seller;
        }

        // set operator if defined
        if (operator != address(0)) {
            Operated._setOperator(operator);
        }

        // set amounts if defined
        if (paymentAmount != uint256(0)) {
            require(paymentAmount <= uint256(uint128(paymentAmount)), "paymentAmount is too large");
            _data.paymentAmount = uint128(paymentAmount);
        }
        if (stakeAmount != uint256(0)) {
            require(stakeAmount == uint256(uint128(stakeAmount)), "stakeAmount is too large");
            _data.stakeAmount = uint128(stakeAmount);
        }

        // set countdown length
        Countdown._setLength(escrowCountdown);

        // set metadata if defined
        if (metadata.length != 0) {
            EventMetadata._setMetadata(metadata);
        }

        // set agreementParams if defined
        if (agreementParams.length != 0) {
            (
                uint256 ratio,
                Griefing.RatioType ratioType,
                uint256 agreementCountdown
            ) = abi.decode(agreementParams, (uint256, Griefing.RatioType, uint256));
            require(ratio == uint256(uint120(ratio)), "ratio out of bounds");
            require(agreementCountdown == uint256(uint128(agreementCountdown)), "agreementCountdown out of bounds");
            _data.agreementParams = AgreementParams(uint120(ratio), ratioType, uint128(agreementCountdown));
        }

        // emit event
        emit Initialized(operator, buyer, seller, paymentAmount, stakeAmount, escrowCountdown, metadata, agreementParams);
    }

    /// @notice Emit metadata event
    /// @dev Access Control: operator
    ///      State Machine: always
    /// @param metadata Data (any format) to emit as event
    function setMetadata(bytes memory metadata) public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // update metadata
        EventMetadata._setMetadata(metadata);
    }

    /// @notice Deposit Stake in NMR and set seller address
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    ///          - if buyer already deposited the payment, finalize the escrow
    /// @dev Access Control: anyone
    ///      State Machine: before finalize() OR before cancel()
    function depositAndSetSeller(address seller) public {
        // restrict access control
        require(_data.seller == address(0), "seller already set");

        // set seller
        _data.seller = seller;

        // deposit stake
        _depositStake();
    }

    /// @notice Deposit Stake in NMR
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    ///          - if buyer already deposited the payment, finalize the escrow
    /// @dev Access Control: buyer OR operator
    ///      State Machine: before finalize() OR before cancel()
    function depositStake() public {
        // restrict access control
        require(_data.seller != address(0), "seller not yet set");
        require(isSeller(msg.sender) || Operated.isOperator(msg.sender), "only seller or operator");

        // deposit stake
        _depositStake();
    }

    function _depositStake() private {
        // restrict state machine
        require(isOpen() || onlyPaymentDeposited(), "can only deposit stake once");

        // declare storage variables in memory
        address seller = _data.seller;
        uint256 stakeAmount = uint256(_data.stakeAmount);

        // Add the stake amount
        if (stakeAmount != uint256(0)) {
            Staking._addStake(seller, msg.sender, stakeAmount);
        }

        // emit event
        emit StakeDeposited(seller, stakeAmount);

        // If payment is deposited, finalize the escrow
        if (onlyPaymentDeposited()) {
            _data.status = EscrowStatus.isDeposited;
            finalize();
        } else {
            _data.status = EscrowStatus.onlyStakeDeposited;
        }
    }

    /// @notice Deposit Payment in NMR and set buyer address
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    ///          - if seller already deposited the stake, start the finalization countdown
    /// @dev Access Control: buyer OR operator
    ///      State Machine: before finalize() OR before cancel()
    function depositAndSetBuyer(address buyer) public {
        // restrict access control
        require(_data.buyer == address(0), "buyer already set");

        // set buyer
        _data.buyer = buyer;

        // deposit payment
        _depositPayment();
    }

    /// @notice Deposit Payment in NMR
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    ///          - if seller already deposited the stake, start the finalization countdown
    /// @dev Access Control: buyer OR operator
    ///      State Machine: before finalize() OR before cancel()
    function depositPayment() public {
        // restrict access control
        require(_data.buyer != address(0), "buyer not yet set");
        require(isBuyer(msg.sender) || Operated.isOperator(msg.sender), "only buyer or operator");

        // deposit payment
        _depositPayment();
    }

    function _depositPayment() private {
        // restrict state machine
        require(isOpen() || onlyStakeDeposited(), "can only deposit payment once");

        // declare storage variables in memory
        address buyer = _data.buyer;
        uint256 paymentAmount = uint256(_data.paymentAmount);

        // Add the payment as a stake
        if (paymentAmount != uint256(0)) {
            Staking._addStake(buyer, msg.sender, paymentAmount);
        }

        // emit event
        emit PaymentDeposited(buyer, paymentAmount);

        // If stake is deposited, start countdown for seller to finalize
        if (onlyStakeDeposited()) {
            _data.status = EscrowStatus.isDeposited;
            Countdown._start();
        } else {
            _data.status = EscrowStatus.onlyPaymentDeposited;
        }
    }

    /// @notice Finalize escrow and execute completion script
    ///          - create the agreement
    ///          - transfer deposited stake and payment to agreement
    ///          - start agreement countdown
    ///          - disable agreement operator
    /// @dev Access Control: seller OR operator
    ///      State Machine: after depositStake() AND after depositPayment()
    function finalize() public {
        // restrict access control
        require(isSeller(msg.sender) || Operated.isOperator(msg.sender), "only seller or operator");
        // restrict state machine
        require(isDeposited(), "only after deposit");

        // create the agreement

        address agreement;
        {
            // get the agreement factory address

            address escrowFactory = Template.getFactory();
            address escrowRegistry = iFactory(escrowFactory).getInstanceRegistry();
            address agreementFactory = abi.decode(iRegistry(escrowRegistry).getFactoryData(escrowFactory), (address));

            // encode initialization function
            bytes memory initCalldata = abi.encodeWithSignature(
                'initialize(address,address,address,uint256,uint8,uint256,bytes)',
                address(this),
                _data.seller,
                _data.buyer,
                uint256(_data.agreementParams.ratio),
                _data.agreementParams.ratioType,
                uint256(_data.agreementParams.countdownLength),
                bytes("")
            );

            // deploy and initialize agreement contract
            agreement = iFactory(agreementFactory).create(initCalldata);
        }

        // transfer stake and payment to the agreement

        uint256 totalStake;
        {
            uint256 paymentAmount = Deposit._clearDeposit(_data.buyer);
            uint256 stakeAmount = Deposit._clearDeposit(_data.seller);
            totalStake = paymentAmount.add(stakeAmount);
        }

        if (totalStake > 0) {
            require(IERC20(BurnNMR.getToken()).approve(agreement, totalStake), "token approval failed");
            CountdownGriefing(agreement).increaseStake(totalStake);
        }

        // start agreement countdown

        CountdownGriefing(agreement).startCountdown();

        // transfer operator
        address operator = Operated.getOperator();
        if (operator != address(0)) {
            CountdownGriefing(agreement).transferOperator(operator);
        } else {
            CountdownGriefing(agreement).renounceOperator();
        }

        // update status
        _data.status = EscrowStatus.isFinalized;

        // delete storage
        delete _data.paymentAmount;
        delete _data.stakeAmount;
        delete _data.agreementParams;

        // emit event
        emit Finalized(agreement);
    }

    /// @notice Submit data to the buyer
    /// @dev Access Control: seller OR operator
    ///      State Machine: after finalize()
    /// @param data Data (any format) to submit to the buyer
    function submitData(bytes memory data) public {
        // restrict access control
        require(isSeller(msg.sender) || Operated.isOperator(msg.sender), "only seller or operator");
        // restrict state machine
        require(isFinalized(), "only after finalized");

        // emit event
        emit DataSubmitted(data);
    }

    /// @notice Cancel escrow because no interested counterparty
    ///          - return deposit to caller
    ///          - close escrow
    /// @dev Access Control: seller OR buyer OR operator
    ///      State Machine: before depositStake() OR before depositPayment()
    function cancel() public {
        // restrict access control
        require(isSeller(msg.sender) || isBuyer(msg.sender) || Operated.isOperator(msg.sender), "only seller or buyer or operator");
        // restrict state machine
        require(isOpen() || onlyStakeDeposited() || onlyPaymentDeposited(), "only before deposits are completed");

        // cancel escrow and return deposits
        _cancel();
    }

    /// @notice Cancel escrow if seller does not finalize
    ///          - return stake to seller
    ///          - return payment to buyer
    ///          - close escrow
    /// @dev Access Control: buyer OR operator
    ///      State Machine: after depositStake() AND after depositPayment() AND after Countdown.isOver()
    function timeout() public {
        // restrict access control
        require(isBuyer(msg.sender) || Operated.isOperator(msg.sender), "only buyer or operator");
        // restrict state machine
        require(isDeposited() && Countdown.isOver(), "only after countdown ended");

        // cancel escrow and return deposits
        _cancel();
    }

    function _cancel() private {
        // declare storage variables in memory
        address seller = _data.seller;
        address buyer = _data.buyer;

        // return stake to seller
        if (Staking.getStake(seller) != 0) {
            Staking._takeFullStake(seller, seller);
        }

        // return payment to buyer
        if (Staking.getStake(buyer) != 0) {
            Staking._takeFullStake(buyer, buyer);
        }

        // update status
        _data.status = EscrowStatus.isCancelled;

        // delete storage
        delete _data.paymentAmount;
        delete _data.stakeAmount;
        delete _data.agreementParams;

        // emit event
        emit Cancelled();
    }

    /// @notice Called by the operator to transfer control to new operator
    /// @dev Access Control: operator
    ///      State Machine: anytime
    /// @param operator Address of the new operator
    function transferOperator(address operator) public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // transfer operator
        Operated._transferOperator(operator);
    }

    /// @notice Called by the operator to renounce control
    /// @dev Access Control: operator
    ///      State Machine: anytime
    function renounceOperator() public {
        // restrict access
        require(Operated.isOperator(msg.sender), "only operator");

        // renounce operator
        Operated._renounceOperator();
    }

    /// View functions

    /// @notice Get the address of the buyer (if set)
    /// @return buyer Buyer account address
    function getBuyer() public view returns (address buyer) {
        return _data.buyer;
    }

    /// @notice Validate if the address matches the stored buyer address
    /// @param caller Address to validate
    /// @return validity True if matching address
    function isBuyer(address caller) internal view returns (bool validity) {
        return caller == getBuyer();
    }

    /// @notice Get the address of the seller (if set)
    /// @return seller Seller account address
    function getSeller() public view returns (address seller) {
        return _data.seller;
    }

    /// @notice Validate if the address matches the stored seller address
    /// @param caller Address to validate
    /// @return validity True if matching address
    function isSeller(address caller) internal view returns (bool validity) {
        return caller == getSeller();
    }

    /// @notice Get the data in storage
    /// @return uint128 paymentAmount set in initialization
    /// @return uint128 stakeAmount set in initialization
    /// @return uint120 ratio used for initialization of agreement on completion
    /// @return Griefing.RatioType ratioType used for initialization of agreement on completion
    /// @return uint128 countdownLength used for initialization of agreement on completion
    function getData() public view returns (
        uint128 paymentAmount,
        uint128 stakeAmount,
        uint120 ratio,
        Griefing.RatioType ratioType,
        uint128 countdownLength
    ) {
        return (
            _data.paymentAmount,
            _data.stakeAmount,
            _data.agreementParams.ratio,
            _data.agreementParams.ratioType,
            _data.agreementParams.countdownLength
        );
    }

    enum EscrowStatus { isOpen, onlyStakeDeposited, onlyPaymentDeposited, isDeposited, isFinalized, isCancelled }
    /// @notice Return the status of the state machine
    /// @return EscrowStatus status from of the following states:
    ///          - isOpen: initialized but no deposits made
    ///          - onlyStakeDeposited: only stake deposit completed
    ///          - onlyPaymentDeposited: only payment deposit completed
    ///          - isDeposited: both payment and stake deposit is completed
    ///          - isFinalized: the escrow completed successfully
    ///          - isCancelled: the escrow was cancelled
    function getEscrowStatus() public view returns (EscrowStatus status) {
        return _data.status;
    }

    function isOpen() internal view returns (bool validity) {
        return getEscrowStatus() == EscrowStatus.isOpen;
    }

    function onlyStakeDeposited() internal view returns (bool validity) {
        return getEscrowStatus() == EscrowStatus.onlyStakeDeposited;
    }

    function onlyPaymentDeposited() internal view returns (bool validity) {
        return getEscrowStatus() == EscrowStatus.onlyPaymentDeposited;
    }

    function isDeposited() internal view returns (bool validity) {
        return getEscrowStatus() == EscrowStatus.isDeposited;
    }

    function isFinalized() internal view returns (bool validity) {
        return getEscrowStatus() == EscrowStatus.isFinalized;
    }

    function isCancelled() internal view returns (bool validity) {
        return getEscrowStatus() == EscrowStatus.isCancelled;
    }
}