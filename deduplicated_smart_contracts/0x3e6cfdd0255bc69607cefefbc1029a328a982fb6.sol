/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
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
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/lib/TimeLockUpgradeV2.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




/**
 * @title TimeLockUpgradeV2
 * @author Set Protocol
 *
 * The TimeLockUpgradeV2 contract contains a modifier for handling minimum time period updates
 *
 * CHANGELOG:
 * - Requires that the caller is the owner
 * - New function to allow deletion of existing timelocks
 * - Added upgradeData to UpgradeRegistered event
 */
contract TimeLockUpgradeV2 is
    Ownable
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */

    // Timelock Upgrade Period in seconds
    uint256 public timeLockPeriod;

    // Mapping of maps hash of registered upgrade to its registration timestam
    mapping(bytes32 => uint256) public timeLockedUpgrades;

    /* ============ Events ============ */

    event UpgradeRegistered(
        bytes32 indexed _upgradeHash,
        uint256 _timestamp,
        bytes _upgradeData
    );

    event RemoveRegisteredUpgrade(
        bytes32 indexed _upgradeHash
    );

    /* ============ Modifiers ============ */

    modifier timeLockUpgrade() {
        require(
            isOwner(),
            "TimeLockUpgradeV2: The caller must be the owner"
        );

        // If the time lock period is 0, then allow non-timebound upgrades.
        // This is useful for initialization of the protocol and for testing.
        if (timeLockPeriod > 0) {
            // The upgrade hash is defined by the hash of the transaction call data,
            // which uniquely identifies the function as well as the passed in arguments.
            bytes32 upgradeHash = keccak256(
                abi.encodePacked(
                    msg.data
                )
            );

            uint256 registrationTime = timeLockedUpgrades[upgradeHash];

            // If the upgrade hasn't been registered, register with the current time.
            if (registrationTime == 0) {
                timeLockedUpgrades[upgradeHash] = block.timestamp;

                emit UpgradeRegistered(
                    upgradeHash,
                    block.timestamp,
                    msg.data
                );

                return;
            }

            require(
                block.timestamp >= registrationTime.add(timeLockPeriod),
                "TimeLockUpgradeV2: Time lock period must have elapsed."
            );

            // Reset the timestamp to 0
            timeLockedUpgrades[upgradeHash] = 0;

        }

        // Run the rest of the upgrades
        _;
    }

    /* ============ Function ============ */

    /**
     * Removes an existing upgrade.
     *
     * @param  _upgradeHash    Keccack256 hash that uniquely identifies function called and arguments
     */
    function removeRegisteredUpgrade(
        bytes32 _upgradeHash
    )
        external
        onlyOwner
    {
        require(
            timeLockedUpgrades[_upgradeHash] != 0,
            "TimeLockUpgradeV2.removeRegisteredUpgrade: Upgrade hash must be registered"
        );

        // Reset the timestamp to 0
        timeLockedUpgrades[_upgradeHash] = 0;

        emit RemoveRegisteredUpgrade(
            _upgradeHash
        );
    }

    /**
     * Change timeLockPeriod period. Generally called after initially settings have been set up.
     *
     * @param  _timeLockPeriod   Time in seconds that upgrades need to be evaluated before execution
     */
    function setTimeLockPeriod(
        uint256 _timeLockPeriod
    )
        external
        onlyOwner
    {
        // Only allow setting of the timeLockPeriod if the period is greater than the existing
        require(
            _timeLockPeriod > timeLockPeriod,
            "TimeLockUpgradeV2: New period must be greater than existing"
        );

        timeLockPeriod = _timeLockPeriod;
    }
}

// File: contracts/lib/AddressArrayUtils.sol

// Pulled in from Cryptofin Solidity package in order to control Solidity compiler version
// https://github.com/cryptofinlabs/cryptofin-solidity/blob/master/contracts/array-utils/AddressArrayUtils.sol

pragma solidity 0.5.7;


library AddressArrayUtils {

    /**
     * Finds the index of the first occurrence of the given element.
     * @param A The input array to search
     * @param a The value to find
     * @return Returns (index and isIn) for the first occurrence starting from index 0
     */
    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    /**
    * Returns true if the value is present in the list. Uses indexOf internally.
    * @param A The input array to search
    * @param a The value to find
    * @return Returns isIn for the first occurrence starting from index 0
    */
    function contains(address[] memory A, address a) internal pure returns (bool) {
        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    /**
     * Returns the combination of the two arrays
     * @param A The first array
     * @param B The second array
     * @return Returns A extended by B
     */
    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

    /**
     * Returns the array with a appended to A.
     * @param A The first array
     * @param a The value to append
     * @return Returns A appended by a
     */
    function append(address[] memory A, address a) internal pure returns (address[] memory) {
        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    /**
     * Returns the intersection of two arrays. Arrays are treated as collections, so duplicates are kept.
     * @param A The first array
     * @param B The second array
     * @return The intersection of the two arrays
     */
    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    /**
     * Returns the union of the two arrays. Order is not guaranteed.
     * @param A The first array
     * @param B The second array
     * @return The union of the two arrays
     */
    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

    /**
     * Computes the difference of two arrays. Assumes there are no duplicates.
     * @param A The first array
     * @param B The second array
     * @return The difference of the two arrays
     */
    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
        // First count the new length because can't push for in-memory arrays
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    /**
    * Removes specified index from array
    * Resulting ordering is not guaranteed
    * @return Returns the new array and the removed entry
    */
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    /**
     * @return Returns the new array
     */
    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    /**
     * Returns whether or not there's a duplicate. Runs in O(n^2).
     * @param A Array to search
     * @return Returns true if duplicate, false otherwise
     */
    function hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Returns whether the two arrays are equal.
     * @param A The first array
     * @param B The second array
     * @return True is the arrays are equal, false if not.
     */
    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {
        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }
}

// File: contracts/lib/OracleWhiteList.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;





/**
 * @title OracleWhiteList
 * @author Set Protocol
 *
 * WhiteList that matches whitelisted tokens to their on chain price oracle
 */
contract OracleWhiteList is
    Ownable,
    TimeLockUpgradeV2
{
    using AddressArrayUtils for address[];

    /* ============ State Variables ============ */

    address[] public addresses;
    mapping(address => address) public oracleWhiteList;

    /* ============ Events ============ */

    event TokenOraclePairAdded(
        address _tokenAddress,
        address _oracleAddress
    );

    event TokenOraclePairRemoved(
        address _tokenAddress,
        address _oracleAddress
    );

    /* ============ Constructor ============ */

    /**
     * Constructor function for OracleWhiteList
     *
     * Allow initial addresses to be passed in so a separate transaction is not required for each.
     * Each token address passed is matched with a corresponding oracle address at the same index.
     * The _initialTokenAddresses and _initialOracleAddresses arrays must be equal length.
     *
     * @param _initialTokenAddresses        Starting set of toke addresses to whitelist
     * @param _initialOracleAddresses       Starting set of oracle addresses to whitelist
     */
    constructor(
        address[] memory _initialTokenAddresses,
        address[] memory _initialOracleAddresses
    )
        public
    {
        require(
            _initialTokenAddresses.length == _initialOracleAddresses.length,
            "OracleWhiteList.constructor: Token and Oracle array lengths must match."
        );

        // Add each of initial addresses to state
        for (uint256 i = 0; i < _initialTokenAddresses.length; i++) {
            address tokenAddressToAdd = _initialTokenAddresses[i];

            addresses.push(tokenAddressToAdd);
            oracleWhiteList[tokenAddressToAdd] = _initialOracleAddresses[i];
        }
    }

    /* ============ External Functions ============ */

    /**
     * Add an address to the whitelist
     *
     * @param _tokenAddress    Token address to add to the whitelist
     * @param _oracleAddress   Oracle address to add to the whitelist under _tokenAddress
     */
    function addTokenOraclePair(
        address _tokenAddress,
        address _oracleAddress
    )
        external
        onlyOwner
        timeLockUpgrade
    {
        require(
            oracleWhiteList[_tokenAddress] == address(0),
            "OracleWhiteList.addTokenOraclePair: Token and Oracle pair already exists."
        );

        addresses.push(_tokenAddress);
        oracleWhiteList[_tokenAddress] = _oracleAddress;

        emit TokenOraclePairAdded(_tokenAddress, _oracleAddress);
    }

    /**
     * Remove a token oracle pair from the whitelist
     *
     * @param _tokenAddress    Token address to remove to the whitelist
     */
    function removeTokenOraclePair(
        address _tokenAddress
    )
        external
        onlyOwner
    {
        address oracleAddress = oracleWhiteList[_tokenAddress];

        require(
            oracleAddress != address(0),
            "OracleWhiteList.removeTokenOraclePair: Token Address is not current whitelisted."
        );

        addresses = addresses.remove(_tokenAddress);
        oracleWhiteList[_tokenAddress] = address(0);

        emit TokenOraclePairRemoved(_tokenAddress, oracleAddress);
    }

    /**
     * Edit oracle address associated with a token address
     *
     * @param _tokenAddress    Token address to add to the whitelist
     * @param _oracleAddress   Oracle address to add to the whitelist under _tokenAddress
     */
    function editTokenOraclePair(
        address _tokenAddress,
        address _oracleAddress
    )
        external
        onlyOwner
        timeLockUpgrade
    {
        require(
            oracleWhiteList[_tokenAddress] != address(0),
            "OracleWhiteList.editTokenOraclePair: Token and Oracle pair must exist."
        );

        // Set new oracle address for passed token address
        oracleWhiteList[_tokenAddress] = _oracleAddress;

        emit TokenOraclePairAdded(
            _tokenAddress,
            _oracleAddress
        );
    }

    /**
     * Return array of all whitelisted addresses
     *
     * @return address[]      Array of addresses
     */
    function validAddresses()
        external
        view
        returns (address[] memory)
    {
        return addresses;
    }

    /**
     * Return array of oracle addresses based on passed in token addresses
     *
     * @param  _tokenAddresses    Array of token addresses to get oracle addresses for
     * @return address[]          Array of oracle addresses
     */
    function getOracleAddressesByToken(
        address[] calldata _tokenAddresses
    )
        external
        view
        returns (address[] memory)
    {
        // Get length of passed array
        uint256 arrayLength = _tokenAddresses.length;

        // Check that passed array length is greater than 0
        require(
            arrayLength > 0,
            "OracleWhiteList.getOracleAddressesByToken: Array length must be greater than 0."
        );

        // Instantiate oracle addresses array
        address[] memory oracleAddresses = new address[](arrayLength);

        for (uint256 i = 0; i < arrayLength; i++) {
            // Get oracle address for token address at index i
            oracleAddresses[i] = getOracleAddressByToken(
                _tokenAddresses[i]
            );
        }

        return oracleAddresses;
    }

    /**
     * Return oracle address associated with a passed token address
     *
     * @param  _tokenAddress    Address of token
     * @return address          Address of oracle associated with token
     */
    function getOracleAddressByToken(
        address _tokenAddress
    )
        public
        view
        returns (address)
    {
        // Require token address to have matching oracle address
        require(
            oracleWhiteList[_tokenAddress] != address(0),
            "OracleWhiteList.getOracleAddressFromToken: No Oracle for that address."
        );

        // Return oracle address associated with token address
        return oracleWhiteList[_tokenAddress];
    }

    /**
     * Verifies an array of addresses against the whitelist
     *
     * @param  _tokenAddresses    Array of token addresses to check if oracle exists
     * @return bool               Whether all addresses in the list are whitelsited
     */
    function areValidAddresses(
        address[] calldata _tokenAddresses
    )
        external
        view
        returns (bool)
    {
        // Get length of passed array
        uint256 arrayLength = _tokenAddresses.length;

        // Check that passed array length is greater than 0
        require(
            arrayLength > 0,
            "OracleWhiteList.areValidAddresses: Array length must be greater than 0."
        );

        for (uint256 i = 0; i < arrayLength; i++) {
            // Return false if token address doesn't have matching oracle address
            if (oracleWhiteList[_tokenAddresses[i]] == address(0)) {
                return false;
            }
        }

        return true;
    }


}