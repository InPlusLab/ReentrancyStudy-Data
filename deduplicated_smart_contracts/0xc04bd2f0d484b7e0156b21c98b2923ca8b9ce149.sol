/**
 *Submitted for verification at Etherscan.io on 2019-09-24
*/

pragma solidity ^0.5.0;

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



contract EventMetadata {

    event MetadataSet(bytes metadata);

    // state functions

    function _setMetadata(bytes memory metadata) internal {
        emit MetadataSet(metadata);
    }
}



contract Operated {

    address private _operator;
    bool private _status;

    event OperatorUpdated(address operator, bool status);

    // state functions

    function _setOperator(address operator) internal {
        require(_operator != operator, "cannot set same operator");
        _operator = operator;
        emit OperatorUpdated(operator, hasActiveOperator());
    }

    function _transferOperator(address operator) internal {
        // transferring operator-ship implies there was an operator set before this
        require(_operator != address(0), "operator not set");
        _setOperator(operator);
    }

    function _renounceOperator() internal {
        require(hasActiveOperator(), "only when operator active");
        _operator = address(0);
        _status = false;
        emit OperatorUpdated(address(0), false);
    }

    function _activateOperator() internal {
        require(!hasActiveOperator(), "only when operator not active");
        _status = true;
        emit OperatorUpdated(_operator, true);
    }

    function _deactivateOperator() internal {
        require(hasActiveOperator(), "only when operator active");
        _status = false;
        emit OperatorUpdated(_operator, false);
    }

    // view functions

    function getOperator() public view returns (address operator) {
        operator = _operator;
    }

    function isOperator(address caller) public view returns (bool ok) {
        return (caller == getOperator());
    }

    function hasActiveOperator() public view returns (bool ok) {
        return _status;
    }

    function isActiveOperator(address caller) public view returns (bool ok) {
        return (isOperator(caller) && hasActiveOperator());
    }

}



/* Deadline
 *
 */
contract Deadline {

    uint256 private _deadline;

    event DeadlineSet(uint256 deadline);

    // state functions

    function _setDeadline(uint256 deadline) internal {
        _deadline = deadline;
        emit DeadlineSet(deadline);
    }

    // view functions

    function getDeadline() public view returns (uint256 deadline) {
        deadline = _deadline;
    }

    // if the _deadline is not set yet, isAfterDeadline will return true
    // due to now - 0 = now
    function isAfterDeadline() public view returns (bool status) {
        if (_deadline == 0) {
            status = false;
        } else {
            status = (now >= _deadline);
        }
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



contract iNMR {

    // ERC20
    function totalSupply() external returns (uint256);
    function balanceOf(address _owner) external returns (uint256);
    function allowance(address _owner, address _spender) external returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool ok);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool ok);
    function approve(address _spender, uint256 _value) external returns (bool ok);
    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);

    // burn
    function mint(uint256 _value) external returns (bool ok);
    // burnFrom
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);
}




/* Countdown timer
 */
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
    }

    // view functions

    function getLength() public view returns (uint256 length) {
        length = _length;
    }

    // if Deadline._setDeadline or Countdown._setLength is not called,
    // isOver will yield false
    function isOver() public view returns (bool status) {
        // when deadline not set,
        // countdown has not started, hence not isOver
        if (Deadline.getDeadline() == 0) {
            status = false;
        } else {
            status = Deadline.isAfterDeadline();
        }
    }

    // timeRemaining will default to 0 if _setDeadline is not called
    // if the now exceeds deadline, just return 0 as the timeRemaining
    function timeRemaining() public view returns (uint256 time) {
        if (now >= Deadline.getDeadline()) {
            time = 0;
        } else {
            time = Deadline.getDeadline().sub(now);
        }
    }

}



contract Template {

    address private _factory;

    // modifiers

    modifier initializeTemplate() {
        // set factory
        _factory = msg.sender;

        // only allow function to be delegatecalled from within a constructor.
        uint32 codeSize;
        assembly { codeSize := extcodesize(address) }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    // view functions

    function getCreator() public view returns (address creator) {
        // iFactory(...) would revert if _factory address is not actually a factory contract
        creator = iFactory(_factory).getInstanceCreator(address(this));
    }

    function isCreator(address caller) public view returns (bool ok) {
        ok = (caller == getCreator());
    }

    function getFactory() public view returns (address factory) {
        factory = _factory;
    }

}


/**
 * @title NMR token burning helper
 * @dev Allows for calling NMR burn functions using regular openzeppelin ERC20Burnable interface and revert on failure.
 */
contract BurnNMR {

    // address of the token
    address private constant _Token = address(0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671);

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function _burn(uint256 value) internal {
        require(iNMR(_Token).mint(value), "nmr burn failed");
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance.
     * @param from address The account whose tokens will be burned.
     * @param value uint256 The amount of token to be burned.
     */
    function _burnFrom(address from, uint256 value) internal {
        require(iNMR(_Token).numeraiTransfer(from, value), "nmr burnFrom failed");
    }

    function getToken() public pure returns (address token) {
        token = _Token;
    }

}





contract Staking is BurnNMR {

    using SafeMath for uint256;

    mapping (address => uint256) private _stake;

    event StakeAdded(address staker, address funder, uint256 amount, uint256 newStake);
    event StakeTaken(address staker, address recipient, uint256 amount, uint256 newStake);
    event StakeBurned(address staker, uint256 amount, uint256 newStake);

    function _addStake(address staker, address funder, uint256 currentStake, uint256 amountToAdd) internal {
        // require current stake amount matches expected amount
        require(currentStake == _stake[staker], "current stake incorrect");

        // require non-zero stake to add
        require(amountToAdd > 0, "no stake to add");

        // calculate new stake amount
        uint256 newStake = currentStake.add(amountToAdd);

        // set new stake to storage
        _stake[staker] = newStake;

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transferFrom(funder, address(this), amountToAdd), "token transfer failed");

        // emit event
        emit StakeAdded(staker, funder, amountToAdd, newStake);
    }

    function _takeStake(address staker, address recipient, uint256 currentStake, uint256 amountToTake) internal {
        // require current stake amount matches expected amount
        require(currentStake == _stake[staker], "current stake incorrect");

        // require non-zero stake to take
        require(amountToTake > 0, "no stake to take");

        // amountToTake has to be less than equal currentStake
        require(amountToTake <= currentStake, "cannot take more than currentStake");

        // calculate new stake amount
        uint256 newStake = currentStake.sub(amountToTake);

        // set new stake to storage
        _stake[staker] = newStake;

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transfer(recipient, amountToTake), "token transfer failed");

        // emit event
        emit StakeTaken(staker, recipient, amountToTake, newStake);
    }

    function _takeFullStake(address staker, address recipient) internal returns (uint256 stake) {
        // get stake from storage
        stake = _stake[staker];

        // take full stake
        _takeStake(staker, recipient, stake, stake);
    }

    function _burnStake(address staker, uint256 currentStake, uint256 amountToBurn) internal {
        // require current stake amount matches expected amount
        require(currentStake == _stake[staker], "current stake incorrect");

        // require non-zero stake to burn
        require(amountToBurn > 0, "no stake to burn");

        // amountToTake has to be less than equal currentStake
        require(amountToBurn <= currentStake, "cannot burn more than currentStake");

        // calculate new stake amount
        uint256 newStake = currentStake.sub(amountToBurn);

        // set new stake to storage
        _stake[staker] = newStake;

        // burn the stake amount
        BurnNMR._burn(amountToBurn);

        // emit event
        emit StakeBurned(staker, amountToBurn, newStake);
    }

    function _burnFullStake(address staker) internal returns (uint256 stake) {
        // get stake from storage
        stake = _stake[staker];

        // burn full stake
        _burnStake(staker, stake, stake);
    }

    // view functions

    function getStake(address staker) public view returns (uint256 stake) {
        stake = _stake[staker];
    }

}




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

    function _grief(
        address punisher,
        address staker,
        uint256 currentStake,
        uint256 punishment,
        bytes memory message
    ) internal returns (uint256 cost) {

        // prevent accidental double punish
        // cannot be strict equality to prevent frontrunning
        require(currentStake <= Staking.getStake(staker), "current stake incorrect");

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
        Staking._burnStake(staker, currentStake, punishment);

        // emit event
        emit Griefed(punisher, staker, punishment, cost, message);
    }

    // view functions

    function getRatio(address staker) public view returns (uint256 ratio, RatioType ratioType) {
        // get stake data from storage
        ratio = _griefRatio[staker].ratio;
        ratioType = _griefRatio[staker].ratioType;
    }

    // pure functions

    function getCost(uint256 ratio, uint256 punishment, RatioType ratioType) public pure returns(uint256 cost) {
        /*  Dec:  Cost multiplied by ratio interpreted as a decimal number with 18 decimals, e.g. 1 -> 1e18
         *  Inf:  Punishment at no cost
         *  NaN:  No Punishment */
        if (ratioType == RatioType.Dec) {
            return DecimalMath.mul(SafeMath.mul(punishment, e18), ratio) / e18;
        }
        if (ratioType == RatioType.Inf)
            return 0;
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

    function getPunishment(uint256 ratio, uint256 cost, RatioType ratioType) public pure returns(uint256 punishment) {
        /*  Dec: Ratio is a decimal number with 18 decimals
         *  Inf:  Punishment at no cost
         *  NaN:  No Punishment */
        if (ratioType == RatioType.Dec) {
            return DecimalMath.div(SafeMath.mul(cost, e18), ratio) / e18;
        }
        if (ratioType == RatioType.Inf)
            revert("ratioType cannot be RatioType.Inf");
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

}








/* Immediately engage with specific buyer
 * - Stake can be increased at any time.
 * - Counterparty can greif the staker at predefined ratio.
 *
 * NOTE:
 * - This top level contract should only perform access control and state transitions
 *
 */
contract SimpleGriefing is Griefing, EventMetadata, Operated, Template {

    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address staker;
        address counterparty;
    }

    event Initialized(address operator, address staker, address counterparty, uint256 ratio, Griefing.RatioType ratioType, bytes metadata);

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
            Operated._activateOperator();
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

    function setMetadata(bytes memory metadata) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isActiveOperator(msg.sender), "only staker or active operator");

        // update metadata
        EventMetadata._setMetadata(metadata);
    }

    function increaseStake(uint256 currentStake, uint256 amountToAdd) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isActiveOperator(msg.sender), "only staker or active operator");

        // add stake
        Staking._addStake(_data.staker, msg.sender, currentStake, amountToAdd);
    }

    function reward(uint256 currentStake, uint256 amountToAdd) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isActiveOperator(msg.sender), "only counterparty or active operator");

        // add stake
        Staking._addStake(_data.staker, msg.sender, currentStake, amountToAdd);
    }

    function punish(uint256 currentStake, uint256 punishment, bytes memory message) public returns (uint256 cost) {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isActiveOperator(msg.sender), "only counterparty or active operator");

        // execute griefing
        cost = Griefing._grief(msg.sender, _data.staker, currentStake, punishment, message);
    }

    function releaseStake(uint256 currentStake, uint256 amountToRelease) public {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isActiveOperator(msg.sender), "only counterparty or active operator");

        // release stake back to the staker
        Staking._takeStake(_data.staker, _data.staker, currentStake, amountToRelease);
    }

    function transferOperator(address operator) public {
        // restrict access
        require(Operated.isActiveOperator(msg.sender), "only active operator");

        // transfer operator
        Operated._transferOperator(operator);
    }

    function renounceOperator() public {
        // restrict access
        require(Operated.isActiveOperator(msg.sender), "only active operator");

        // transfer operator
        Operated._renounceOperator();
    }

    // view functions

    function isStaker(address caller) public view returns (bool validity) {
        validity = (caller == _data.staker);
    }

    function isCounterparty(address caller) public view returns (bool validity) {
        validity = (caller == _data.counterparty);
    }
}