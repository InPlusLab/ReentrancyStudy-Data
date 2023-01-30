/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

// vault: (address, name, decimals, symbol, strategies[], archivedStrategies[], tokens[], governance) [getPricePerFullShare]
interface IVault {
    function token() external view returns (address);
    function underlying() external view returns (address);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
    function controller() external view returns (address);
    function governance() external view returns (address);

    function getPricePerFullShare() external view returns (uint);
    
}

// vault: (address, name, decimals, symbol, strategies[], archivedStrategies[], tokens[], governance) [getPricePerFullShare]
interface IWrappedVault {
    function token() external view returns (address);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
    function governance() external view returns (address);
    
    function vault() external view returns (address);

    function getPricePerFullShare() external view returns (uint);
    
}

interface IStrategy {
    function want() external view returns (address);
    function deposit() external;
    function withdraw(address) external;
    function withdraw(uint) external;
    function skim() external;
    function withdrawAll() external returns (uint);
    function balanceOf() external view returns (uint);
}


interface IController {
    function vaults(address) external view returns (address);
    function strategies(address) external view returns (address);
    function rewards() external view returns (address);
    function want(address) external view returns (address);
    function balanceOf(address) external view returns (uint);
    function withdraw(address, uint) external;
    function earn(address, uint) external;
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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


pragma solidity ^0.6.8;

contract YRegistry {
  //using Address for address;
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public governance;  
  address public pendingGovernance;

  EnumerableSet.AddressSet private vaults;
  EnumerableSet.AddressSet private controllers;

  mapping(address => address) private wrappedVaults;

  mapping(address => bool) public isDelegatedVault;

  constructor(address _governance) public {
    require(_governance != address(0), "Missing Governance");
    governance = _governance;
  }

  function getName() external pure returns (string memory) {
    return "YRegistry";
  }

  function addVault(address _vault) public onlyGovernance {
    setVault(_vault);

    (address controller,,,,) = getVaultData(_vault);
    
    setController(controller);
  }

  function addWrappedVault(address _vault) public onlyGovernance {
    setVault(_vault);
    address wrappedVault = IWrappedVault(_vault).vault();
    setWrappedVault(_vault, wrappedVault);

    (address controller,,,,) = getVaultData(_vault);

    // Adds to controllers array
    setController(controller);
    // TODO Add and track tokens and strategies? [historical]
    // (current ones can be obtained via getVaults + getVaultInfo)
  }
  function addDelegatedVault(address _vault) public onlyGovernance {
    setVault(_vault);
    setDelegatedVault(_vault);

    (address controller,,,,) = getVaultData(_vault);

    // Adds to controllers array
    setController(controller);
    // TODO Add and track tokens and strategies? [historical]
    // (current ones can be obtained via getVaults + getVaultInfo)
  }

  function setVault(address _vault) internal {
    //require(_vault.isContract(), "Vault is not a contract");
    // Checks if vault is already on the array
    require(!vaults.contains(_vault), "Vault already exists");
    // Adds unique _vault to vaults array
    vaults.add(_vault);
  }

  function setWrappedVault(address _vault, address _wrappedVault) internal {
    //require(_wrappedVault.isContract(), "WrappedVault is not a contract");
    wrappedVaults[_vault] = _wrappedVault;
  }

  function setDelegatedVault(address _vault) internal {
    // TODO Is there any way to check if a vault is delegated
    isDelegatedVault[_vault] = true;
  }

  function setController(address _controller) internal {
    // Adds Controller to controllers array
    if (!controllers.contains(_controller)) {
      controllers.add(_controller);
    }
  }

  function getVaultData(address _vault) internal view returns (
    address controller,
    address token,
    address strategy,
    bool isWrapped,
    bool isDelegated
  ) {
    address vault = _vault;
    isWrapped = wrappedVaults[_vault] != address(0);
    if (isWrapped) {
      vault = wrappedVaults[_vault];
    }
    isDelegated = isDelegatedVault[vault];
    
    // Get values from controller
    controller = IVault(vault).controller();
    if (isWrapped && IVault(vault).underlying() != address(0)) {
      token = IVault(_vault).token(); // Use non-wrapped vault
    } else {
      token = IVault(vault).token();
    }
    
    if (isDelegated) {
      strategy = IController(controller).strategies(vault);
    } else {
      strategy = IController(controller).strategies(token);
    }
    
    // Check if vault is set on controller for token
    address controllerVault = address(0);
    if (isDelegated) {
      controllerVault = IController(controller).vaults(strategy);
    } else {
      controllerVault = IController(controller).vaults(token);
    }
    require(controllerVault == vault, "Controller vault address does not match"); // Might happen on Proxy Vaults
    
    // Check if strategy has the same token as vault
    if (isWrapped) {
      address underlying = IVault(vault).underlying();
      require(underlying == token, "WrappedVault token address does not match"); // Might happen?
    } else if (!isDelegated) {
      address strategyToken = IStrategy(strategy).want();
      require(token == strategyToken, "Strategy token address does not match"); // Might happen?
    }

    return (controller, token, strategy, isWrapped, isDelegated);
  }

  // Vaults getters
  function getVault(uint index) external view returns (address vault) {
    return vaults.at(index);
  }

  function getVaultsLength() external view returns (uint) {
    return vaults.length();
  }

  function getVaults() external view returns (address[] memory) {
    address[] memory vaultsArray = new address[](vaults.length());
    for (uint i = 0; i < vaults.length(); i++) {
      vaultsArray[i] = vaults.at(i);
    }
    return vaultsArray;
  }

  function getVaultInfo(address _vault) external view returns (
    address controller,
    address token,
    address strategy,
    bool isWrapped,
    bool isDelegated
  ) {
    (controller, token, strategy, isWrapped, isDelegated) = getVaultData(_vault);
    return (
      controller,
      token,
      strategy,
      isWrapped,
      isDelegated
    );
  }

  function getVaultsInfo() external view returns (
    address[] memory controllerArray,
    address[] memory tokenArray,
    address[] memory strategyArray,
    bool[] memory isWrappedArray,
    bool[] memory isDelegatedArray
  ) {
    controllerArray = new address[](vaults.length());
    tokenArray = new address[](vaults.length());
    strategyArray = new address[](vaults.length());
    isWrappedArray = new bool[](vaults.length());
    isDelegatedArray = new bool[](vaults.length());

    for (uint i = 0; i < vaults.length(); i++) {
      (address _controller, address _token, address _strategy, bool _isWrapped, bool _isDelegated) = getVaultData(vaults.at(i));
      controllerArray[i] = _controller;
      tokenArray[i] = _token;
      strategyArray[i] = _strategy;
      isWrappedArray[i] = _isWrapped;
      isDelegatedArray[i] = _isDelegated;
    }
  }

 // Governance setters
  function setPendingGovernance(address _pendingGovernance) external onlyGovernance {
    pendingGovernance = _pendingGovernance;
  }
  function acceptGovernance() external onlyPendingGovernance {
    governance = msg.sender;
  }

  modifier onlyGovernance {
    require(msg.sender == governance, "Only governance can call this function.");
    _;
  }
  modifier onlyPendingGovernance {
    require(msg.sender == pendingGovernance, "Only pendingGovernance can call this function.");
    _;
  }
}