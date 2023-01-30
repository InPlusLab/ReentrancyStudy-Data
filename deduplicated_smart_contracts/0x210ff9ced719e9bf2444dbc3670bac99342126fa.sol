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






/// @title SimpleGriefing
/// @author Stephane Gosselin (@thegostep) for Numerai Inc
/// @dev Security contact: security@numer.ai
/// @dev Version: 1.2.0
/// @dev State Machine: https://github.com/erasureprotocol/erasure-protocol/blob/v1.2.0/docs/state-machines/agreements/SimpleGriefing.png
/// @notice This agreement template allows a staker to grant permission to a counterparty to punish, reward, or release their stake.
///         A new instance is initialized by the factory using the `initData` received. See the `initialize()` function for details on initialization parameters.
///         Notable features:
///             - The staker can increase the stake at any time.
///             - The counterparty can increase, release, or punish the stake at any time.
///             - The agreement can be terminated by the counterparty by releasing or punishing the full stake amount. Note it is always possible for the staker to increase their stake again.
///             - Punishments use griefing which requires the counterparty to pay an appropriate amount based on the desired punishment and a predetermined ratio.
///             - An operator can optionally be defined to grant full permissions to a trusted external address or contract.
contract SimpleGriefing is Griefing, EventMetadata, Operated, Template {

    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address staker;
        address counterparty;
    }

    event Initialized(address operator, address staker, address counterparty, uint256 ratio, Griefing.RatioType ratioType, bytes metadata);

    /// @notice Constructor used to initialize the agreement parameters.
    ///         All parameters are passed as ABI-encoded calldata to the factory. This calldata must include the function selector.
    /// @dev Access Control: only factory
    ///      State Machine: before all
    /// @param operator address of the operator that overrides access control. Optional parameter. Passing the address(0) will disable operator functionality.
    /// @param staker address of the staker who owns the stake. Required parameter. This address is the only one able to retrieve the stake and cannot be changed.
    /// @param counterparty address of the counterparty who has the right to reward, release, and punish the stake. Required parameter. This address cannot be changed.
    /// @param ratio uint256 number (18 decimals) used to determine punishment cost. Required parameter. See Griefing module for details on valid input.
    /// @param ratioType Griefing.RatioType number used to determine punishment cost. Required parameter. See Griefing module for details on valid input.
    /// @param metadata bytes data (any format) to emit as event on initialization. Optional parameter.
    function initialize(
        address operator,
        address staker,
        address counterparty,
        uint256 ratio,
        Griefing.RatioType ratioType,
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

        // set metadata
        if (metadata.length != 0) {
            EventMetadata._setMetadata(metadata);
        }

        // log initialization params
        emit Initialized(operator, staker, counterparty, ratio, ratioType, metadata);
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
    ///      State Machine: anytime
    /// @param amountToAdd uint256 amount of NMR (18 decimals) to be added to the stake
    function increaseStake(uint256 amountToAdd) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isOperator(msg.sender), "only staker or operator");

        // add stake
        Staking._addStake(_data.staker, msg.sender, amountToAdd);
    }

    /// @notice Called by the counterparty to increase the stake
    ///          - tokens (ERC-20) are transfered from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: anytime
    /// @param amountToAdd uint256 amount of NMR (18 decimals) to be added to the stake
    function reward(uint256 amountToAdd) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // add stake
        Staking._addStake(_data.staker, msg.sender, amountToAdd);
    }

    /// @notice Called by the counterparty to punish the stake
    ///          - burns the punishment from the stake and a proportional amount from the counterparty balance
    ///          - the cost of the punishment is calculated with the `Griefing.getCost()` function using the predetermined griefing ratio
    ///          - tokens (ERC-20) are burned from the caller and requires approval of this contract for appropriate amount
    /// @dev Access Control: counterparty OR operator
    ///      State Machine: anytime
    /// @param punishment uint256 amount of NMR (18 decimals) to be burned from the stake
    /// @param message bytes data (any format) to emit as event giving reason for the punishment
    /// @return cost uint256 amount of NMR (18 decimals) it cost to perform punishment
    function punish(uint256 punishment, bytes memory message) public returns (uint256 cost) {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isOperator(msg.sender), "only counterparty or operator");

        // execute griefing
        cost = Griefing._grief(msg.sender, _data.staker, punishment, message);
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

    enum AgreementStatus { isInitialized, isStaked }
    /// @notice Get the status of the state machine
    /// @return status AgreementStatus from the following states:
    ///          - isInitialized: initialized but no deposits made
    ///          - isStaked: stake is deposited
    function getAgreementStatus() public view returns (AgreementStatus status) {
        if (getCurrentStake() > 0) {
            return AgreementStatus.isStaked;
        } else {
            return AgreementStatus.isInitialized;
        }
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isInitialized state
    /// @return validity bool true if correct state
    function isInitialized() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isInitialized;
    }

    /// @notice Validate if the state machine is in the AgreementStatus.isStaked state
    /// @return validity bool true if correct state
    function isStaked() internal view returns (bool validity) {
        return getAgreementStatus() == AgreementStatus.isStaked;
    }
}