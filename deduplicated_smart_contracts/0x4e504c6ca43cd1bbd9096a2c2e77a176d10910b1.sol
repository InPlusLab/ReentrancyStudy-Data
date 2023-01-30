/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

pragma solidity >=0.6.8;


// 
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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// 
/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// 
interface IMMStrategyHarvestKp3r {
    event Keep3rSet(address keep3r);
    event Keep3rHelperSet(address keep3rHelper);
    event SlidingOracleSet(address slidingOracle);

    // Actions by Keeper
    event HarvestedByKeeper(address _strategy);
	
    // Harvestable check
    event HarvestableCheck(address _strategy, uint256 profitTokenAmount, uint256 profitFactor, uint256 profitInEther, uint256 ethCallCost);

    // Setters
    function setKeep3r(address _keep3r) external;

    function setKeep3rHelper(address _keep3rHelper) external;

    function setSlidingOracle(address _slidingOracle) external;
	
    function setMinHarvestInterval(uint256 _interval) external;
	
    function setProfitFactor(uint256 _profitFactor) external;

    // Getters
    function strategies() external view returns (address[] memory);

    // psuedo view method, please use something similar to below tool to query
    // https://docs.ethers.io/v5/api/contract/contract/#contract-callStatic 
    function harvestable(address _strategy) external returns (bool);

    // harvest actions for Keep3r
    function harvest(address _strategy) external;
	
    // harvest actions for free
    function harvestForFree(address _strategy) external;

    // Name of the Keep3r
    function name() external pure returns (string memory);

    event HarvestStrategyAdded(address _strategy, uint256 _requiredHarvest);

    event HarvestStrategyModified(address _strategy, uint256 _requiredHarvest);

    event HarvestStrategyRemoved(address _strategy);

    // Modifiers
    function addStrategy(address _strategy, uint256 _requiredHarvest) external;

    function updateRequiredHarvestAmount(address _strategy, uint256 _requiredHarvest) external;

    function removeHarvestStrategy(address _strategy) external;

}

// 
interface IKeep3rV1 {
    function KPRH() external returns (address);

    function name() external returns (string memory);

    function isKeeper(address) external returns (bool);

    function worked(address keeper) external;

    function addKPRCredit(address job, uint256 amount) external;

    function addJob(address job) external;
}

// 
abstract contract Keep3r {
    IKeep3rV1 public keep3r;

    constructor(address _keep3r) public {
        _setKeep3r(_keep3r);
    }

    function _setKeep3r(address _keep3r) internal {
        keep3r = IKeep3rV1(_keep3r);
    }

    function _isKeeper() internal {
        require(tx.origin == msg.sender, "keep3r::isKeeper:keeper-is-a-smart-contract");
        require(keep3r.isKeeper(msg.sender), "keep3r::isKeeper:keeper-is-not-registered");
    }

    // Only checks if caller is a valid keeper, payment should be handled manually
    modifier onlyKeeper() {
        _isKeeper();
        _;
    }

    // Checks if caller is a valid keeper, handles default payment after execution
    modifier paysKeeper() {
        _isKeeper();
        _;
        keep3r.worked(msg.sender);
    }
}

// 
interface IKeep3rV1Helper {
    function getQuoteLimit(uint256 gasUsed) external view returns (uint256);
}

// 
interface IUniswapV2SlidingOracle {
    function current(
        address tokenIn,
        uint256 amountIn,
        address tokenOut
    ) external view returns (uint256);
    
    function pairs() external view returns (address[] memory);
}

// 
interface IStrategy {
    function rewards() external view returns (address);

    function gauge() external view returns (address);

    function want() external view returns (address);

    function timelock() external view returns (address);

    function deposit() external;

    function withdraw(address) external;

    function withdraw(uint256) external;

    function skim() external;

    function withdrawAll() external returns (uint256);

    function balanceOf() external view returns (uint256);

    function harvest() external;

    function setTimelock(address) external;

    function setController(address _controller) external;

    function execute(address _target, bytes calldata _data)
        external
        payable
        returns (bytes memory response);

    function execute(bytes calldata _data)
        external
        payable
        returns (bytes memory response);
}

// 
interface ICrvStrategy is IStrategy {
    function getHarvestable() external returns (uint256);
}

// 
interface ICompStrategy is IStrategy {
    function getCompAccrued() external returns (uint256);
}

// 
// inspired by & thanks to https://macarse.medium.com/the-keep3r-network-experiment-bb1c5182bda3
contract GenericKeep3rV2 is Keep3r, IMMStrategyHarvestKp3r {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal availableStrategies;
    // required gas cost on harvest
    mapping(address => uint256) public requiredHarvest;
	// last harvest timestamp for strategy
    mapping(address => uint256) public strategyLastHarvest;
    address public keep3rHelper;
    address public slidingOracle;

    address public constant KP3R = address(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant COMP = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    // for curve strategy
    address public constant THREE_CRV_STRATEGY = address(0x1f11055EB66F2bBa647FB1ADc64B0DD4E0018dE7);
    address public constant RENBTC_CRV_STRATEGY = address(0x5A709Dfa094273795B787CaAfC6855a120B2bEbd);

	// for compound strategy
    address public constant DAI_STRATEGY = address(0xf0BA303fd2CE5eBbb22d0d6590463D7549A08388);
    address public constant USDC_STRATEGY = address(0x8F288A56A6c06ffc75994a2d46E84F8bDa1a0744);

    // The minimum number of seconds between harvest calls, once half a day
    uint256 public minHarvestInterval = 43200;

    // The minimum multiple that `callCost` must be above the profit to be "justifiable"
    uint256 public profitFactor = 88;

    address public governor;

    constructor(
        address _keep3r,
        address _keep3rHelper,
        address _slidingOracle
    ) public Keep3r(_keep3r) {
        keep3rHelper = _keep3rHelper;
        slidingOracle = _slidingOracle;
        governor = msg.sender;
    }

    modifier onlyGovernor {
        require(msg.sender == governor, "governable::only-governor");
        _;
    }

    function _setGovernor(address _governor) external onlyGovernor {
        require(_governor != address(0), "governable::governor-should-not-be-zero-addres");
        governor = _governor;
    }

    // Unique method to add a strategy with specified gas cost to the system
    function addStrategy(address _strategy, uint256 _requiredHarvest) external override onlyGovernor {
        _addHarvestStrategy(_strategy, _requiredHarvest);
        availableStrategies.add(_strategy);
    }

    function _addHarvestStrategy(address _strategy, uint256 _requiredHarvest) internal {
        require(requiredHarvest[_strategy] == 0, "generic-keep3r-v2::add-harvest-strategy:strategy-already-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        emit HarvestStrategyAdded(_strategy, _requiredHarvest);
    }

    // Unique method to update a strategy with specified gas cost
    function updateRequiredHarvestAmount(address _strategy, uint256 _requiredHarvest) external override onlyGovernor {
        require(requiredHarvest[_strategy] > 0, "generic-keep3r-v2::update-required-harvest:strategy-not-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        emit HarvestStrategyModified(_strategy, _requiredHarvest);
    }

    function removeHarvestStrategy(address _strategy) external override onlyGovernor {
        require(requiredHarvest[_strategy] > 0, "generic-keep3r-v2::remove-harvest-strategy:strategy-not-added");
        requiredHarvest[_strategy] = 0;
        emit HarvestStrategyRemoved(_strategy);
    }

    function setMinHarvestInterval(uint256 _interval) external override onlyGovernor {
        require(_interval > 0, "!_interval");
        minHarvestInterval = _interval;
    }

    function setProfitFactor(uint256 _profitFactor) external override onlyGovernor {
        require(_profitFactor > 0, "!_profitFactor");
        profitFactor = _profitFactor;
    }

    function setKeep3r(address _keep3r) external override onlyGovernor {
        _setKeep3r(_keep3r);
        emit Keep3rSet(_keep3r);
    }

    function setKeep3rHelper(address _keep3rHelper) external override onlyGovernor {
        keep3rHelper = _keep3rHelper;
        emit Keep3rHelperSet(_keep3rHelper);
    }

    function setSlidingOracle(address _slidingOracle) external override onlyGovernor {
        slidingOracle = _slidingOracle;
        emit SlidingOracleSet(_slidingOracle);
    }

    function _setRequiredHarvest(address _strategy, uint256 _requiredHarvest) internal {
        require(_requiredHarvest > 0, "generic-keep3r-v2::set-required-harvest:should-not-be-zero");
        requiredHarvest[_strategy] = _requiredHarvest;
    }

    // Getters
    function name() external pure override returns (string memory) {
        return "Generic Strategy Keep3r for Mushrooms harvest";
    }

    function strategies() public view override returns (address[] memory _strategies) {
        _strategies = new address[](availableStrategies.length());
        for (uint256 i; i < availableStrategies.length(); i++) {
            _strategies[i] = availableStrategies.at(i);
        }
    }

    // this method is not specified as view since some strategy maybe not able to return accurate underlying profit in snapshot,
	// please use something similar to below tool to query
	// https://docs.ethers.io/v5/api/contract/contract/#contract-callStatic
    function harvestable(address _strategy) public override returns (bool) {
        require(requiredHarvest[_strategy] > 0, "generic-keep3r-v2::harvestable:strategy-not-added");

        // Should not trigger if had been called recently
        if (strategyLastHarvest[_strategy] > 0 && block.timestamp.sub(strategyLastHarvest[_strategy]) <= minHarvestInterval){
            return false;
        }

        // quote from keep3r network for specified workload
        uint256 kp3rCallCost = IKeep3rV1Helper(keep3rHelper).getQuoteLimit(requiredHarvest[_strategy]);
        // get ETH gas cost by querying uniswap sliding oracle
        uint256 ethCallCost = IUniswapV2SlidingOracle(slidingOracle).current(KP3R, kp3rCallCost, WETH);

        // estimate yield profit to harvest
        uint256 profitInEther = 0;
        uint256 profitTokenAmount = 0;
        if(_strategy == DAI_STRATEGY || _strategy == USDC_STRATEGY){
            profitTokenAmount = ICompStrategy(_strategy).getCompAccrued();
            profitInEther = IUniswapV2SlidingOracle(slidingOracle).current(COMP, profitTokenAmount, WETH);
        }else{
            profitTokenAmount = ICrvStrategy(_strategy).getHarvestable();
            profitInEther = IUniswapV2SlidingOracle(slidingOracle).current(CRV, profitTokenAmount, WETH);
        }
		
        emit HarvestableCheck(_strategy, profitTokenAmount, profitFactor, profitInEther, ethCallCost);

        // Only trigger if it "makes sense" economically (gas cost * profitFactor no bigger than profit to be harvested)
        return (profitInEther >= profitFactor.mul(ethCallCost));
    }

    // harvest actions for Keep3r
    function harvest(address _strategy) external override paysKeeper {
        require(harvestable(_strategy), "generic-keep3r-v2::harvest:not-workable");
        _harvest(_strategy);
        emit HarvestedByKeeper(_strategy);
    }

    // harvest actions for free
    function harvestForFree(address _strategy) external override {
        require(harvestable(_strategy), "generic-keep3r-v2::harvest:not-workable");
        _harvest(_strategy);
    }

    function _harvest(address _strategy) internal {
        IStrategy(_strategy).harvest();
        strategyLastHarvest[_strategy] = block.timestamp;
    }
}