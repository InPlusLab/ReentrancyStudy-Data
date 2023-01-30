/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// File: contracts/external/proxy/Proxy.sol

pragma solidity 0.5.7;


/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    function implementation() public view returns (address);
}

// File: contracts/external/proxy/UpgradeabilityProxy.sol

pragma solidity 0.5.7;



/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
    /**
    * @dev This event will be emitted every time the implementation gets upgraded
    * @param implementation representing the address of the upgraded implementation
    */
    event Upgraded(address indexed implementation);

    // Storage position of the address of the current implementation
    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    /**
    * @dev Constructor function
    */
    constructor() public {}

    /**
    * @dev Tells the address of the current implementation
    * @return address of the current implementation
    */
    function implementation() public view returns (address impl) {
        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    /**
    * @dev Sets the address of the current implementation
    * @param _newImplementation address representing the new implementation to be set
    */
    function _setImplementation(address _newImplementation) internal {
        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    /**
    * @dev Upgrades the implementation address
    * @param _newImplementation representing the address of the new implementation to be set
    */
    function _upgradeTo(address _newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}

// File: contracts/external/proxy/OwnedUpgradeabilityProxy.sol

pragma solidity 0.5.7;



/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    // Storage position of the owner of the contract
    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

    /**
    * @dev the constructor sets the original owner of the contract to the sender account.
    */
    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function proxyOwner() public view returns (address owner) {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {
        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    /**
    * @dev Allows the proxy owner to upgrade the current version of the proxy.
    * @param _implementation representing the address of the new implementation to be set.
    */
    function upgradeTo(address _implementation) public onlyProxyOwner {
        _upgradeTo(_implementation);
    }

    /**
     * @dev Sets the address of the owner
    */
    function _setUpgradeabilityOwner(address _newProxyOwner) internal {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}

// File: contracts/external/openzeppelin-solidity/math/SafeMath.sol

pragma solidity ^0.5.0;

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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath128 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
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
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint128 c = a - b;

        return c;
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
    function sub(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {
        require(b <= a, errorMessage);
        uint128 c = a - b;

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
    function mul(uint128 a, uint128 b) internal pure returns (uint128) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
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
    function div(uint128 a, uint128 b) internal pure returns (uint128) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint128 c = a / b;
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
    function mod(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
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
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
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
    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {
        require(b <= a, errorMessage);
        uint64 c = a - b;

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
    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
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
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;
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
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath32 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
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
    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint32 c = a - b;

        return c;
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
    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
        require(b <= a, errorMessage);
        uint32 c = a - b;

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
    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
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
    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint32 c = a / b;
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
    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/external/openzeppelin-solidity/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/external/govblocks-protocol/Governed.sol

/* Copyright (C) 2017 GovBlocks.io
  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/ */

pragma solidity 0.5.7;


contract IMaster {
    mapping(address => bool) public whitelistedSponsor;
    function dAppToken() public view returns(address);
    function isInternal(address _address) public view returns(bool);
    function getLatestAddress(bytes2 _module) public view returns(address);
    function isAuthorizedToGovern(address _toCheck) public view returns(bool);
}


contract Governed {

    address public masterAddress; // Name of the dApp, needs to be set by contracts inheriting this contract

    /// @dev modifier that allows only the authorized addresses to execute the function
    modifier onlyAuthorizedToGovern() {
        IMaster ms = IMaster(masterAddress);
        require(ms.getLatestAddress("GV") == msg.sender, "Not authorized");
        _;
    }

    /// @dev checks if an address is authorized to govern
    function isAuthorizedToGovern(address _toCheck) public view returns(bool) {
        IMaster ms = IMaster(masterAddress);
        return (ms.getLatestAddress("GV") == _toCheck);
    } 

}

// File: contracts/interfaces/ITokenController.sol

pragma solidity 0.5.7;

contract ITokenController {
	address public token;
    address public bLOTToken;

    /**
    * @dev Swap BLOT token.
    * account.
    * @param amount The amount that will be swapped.
    */
    function swapBLOT(address _of, address _to, uint256 amount) public;

    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount);

    function transferFrom(address _token, address _of, address _to, uint256 amount) public;

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specific time
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     * @param _time The timestamp to query the lock tokens for
     */
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount);

    /**
    * @dev burns an amount of the tokens of the message sender
    * account.
    * @param amount The amount that will be burnt.
    */
    function burnCommissionTokens(uint256 amount) external returns(bool);
 
    function initiateVesting(address _vesting) external;

    function lockForGovernanceVote(address _of, uint _days) public;

    function totalSupply() public view returns (uint256);

    function mint(address _member, uint _amount) public;

}

// File: contracts/interfaces/IChainLinkOracle.sol

pragma solidity 0.5.7;

interface IChainLinkOracle
{
	/**
    * @dev Gets the latest answer of chainLink oracle.
    * @return int256 representing the latest answer of chainLink oracle.
    */
	function latestAnswer() external view returns (int256);
	function decimals() external view returns (uint8);
	function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  	function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ); 
}

// File: contracts/interfaces/IMarketUtility.sol

pragma solidity 0.5.7;
contract IMarketUtility {

    function initialize(address payable[] calldata _addressParams, address _initiater) external;

	/**
     * @dev to Set authorized address to update parameters 
     */
    function setAuthorizedAddres() public;

	/**
     * @dev to update uint parameters in Market Config 
     */
    function updateUintParameters(bytes8 code, uint256 value) external;

    /**
     * @dev to Update address parameters in Market Config 
     */
    function updateAddressParameters(bytes8 code, address payable value) external;
 
     /**
    * @dev Get Parameters required to initiate market
    * @return Addresses of tokens to be distributed as incentives
    * @return Cool down time for market
    * @return Rate
    * @return Commission percent for predictions with ETH
    * @return Commission percent for predictions with PLOT
    **/
    function getMarketInitialParams() public view returns(address[] memory, uint , uint, uint, uint);

    function getAssetPriceUSD(address _currencyAddress) external view returns(uint latestAnswer);

    function getAssetValueETH(address _currencyAddress, uint256 _amount)
        public
        view
        returns (uint256 tokenEthValue);
    
    function checkMultiplier(address _asset, address _user, uint _predictionStake, uint predictionPoints, uint _stakeValue) public view returns(uint, bool);
  
    function calculatePredictionPoints(address _user, bool multiplierApplied, uint _predictionStake, address _asset, uint64 totalPredictionPoints, uint64 predictionPointsOnOption) external view returns(uint64 predictionPoints, bool isMultiplierApplied);

    function calculateOptionRange(uint _optionRangePerc, uint64 _decimals, uint8 _roundOfToNearest, address _marketFeed) external view returns(uint64 _minValue, uint64 _maxValue);
    
    function getOptionPrice(uint64 totalPredictionPoints, uint64 predictionPointsOnOption) public view returns(uint64 _optionPrice);
    
    function getPriceFeedDecimals(address _priceFeed) public view returns(uint8);

    function getValueAndMultiplierParameters(address _asset, uint256 _amount)
        public
        view
        returns (uint256, uint256);

    function update() external;
    
    function calculatePredictionValue(uint[] memory params, address asset, address user, address marketFeedAddress, bool _checkMultiplier) public view returns(uint _predictionValue, bool _multiplierApplied);
    
    /**
     * @dev Get basic market details
     * @return Minimum amount required to predict in market
     * @return Percentage of users leveraged amount to deduct when placed in wrong prediction
     * @return Decimal points for prediction positions
     **/
    function getBasicMarketDetails()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getDisputeResolutionParams() public view returns (uint256);
    function calculateOptionPrice(uint[] memory params, address marketFeedAddress) public view returns(uint _optionPrice);

    /**
     * @dev Get price of provided feed address
     * @param _currencyFeedAddress  Feed Address of currency on which market options are based on
     * @return Current price of the market currency
     **/
    function getSettlemetPrice(
        address _currencyFeedAddress,
        uint256 _settleTime
    ) public view returns (uint256 latestAnswer, uint256 roundId);
}

// File: contracts/interfaces/IToken.sol

pragma solidity 0.5.7;

contract IToken {

    function decimals() external view returns(uint8);

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() external view returns (uint256);

    /**
    * @dev Gets the balance of the specified address.
    * @param account The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address account) external view returns (uint256);

    /**
    * @dev Transfer token for a specified address
    * @param recipient The address to transfer to.
    * @param amount The amount to be transferred.
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
    * @dev function that mints an amount of the token and assigns it to
    * an account.
    * @param account The account that will receive the created tokens.
    * @param amount The amount that will be created.
    */
    function mint(address account, uint256 amount) external returns (bool);
    
     /**
    * @dev burns an amount of the tokens of the message sender
    * account.
    * @param amount The amount that will be burnt.
    */
    function burn(uint256 amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
    * @dev Transfer tokens from one address to another
    * @param sender address The address which you want to send tokens from
    * @param recipient address The address which you want to transfer to
    * @param amount uint256 the amount of tokens to be transferred
    */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

// File: contracts/interfaces/IAllMarkets.sol

pragma solidity 0.5.7;

contract IAllMarkets {

	enum PredictionStatus {
      Live,
      InSettlement,
      Cooling,
      InDispute,
      Settled
    }

    function marketStatus(uint256 _marketId) public view returns(PredictionStatus);

    function burnDisputedProposalTokens(uint _proposaId) external;

    function getTotalStakedValueInPLOT(uint256 _marketId) public view returns(uint256);

}

// File: contracts/MarketCreationRewards.sol

pragma solidity 0.5.7;










contract MarketCreationRewards is Governed {

    using SafeMath for *;

	  event MarketCreatorRewardPoolShare(address indexed createdBy, uint256 indexed marketIndex, uint256 plotIncentive, uint256 ethIncentive);
    event MarketCreationReward(address indexed createdBy, uint256 marketIndex, uint256 plotIncentive, uint256 gasUsed, uint256 gasCost, uint256 gasPriceConsidered, uint256 gasPriceGiven, uint256 maxGasCap, uint256 rewardPoolSharePerc);
    event ClaimedMarketCreationReward(address indexed user, uint256 ethIncentive, uint256 plotIncentive);

    modifier onlyInternal() {
      IMaster(masterAddress).isInternal(msg.sender);
      _;
    }
    
    struct MarketCreationRewardData {
      uint ethIncentive;
      uint plotIncentive;
      uint64 ethDeposited;
      uint64 plotDeposited;
      uint16 rewardPoolSharePerc;
      address createdBy;
    }

    struct MarketCreationRewardUserData {
      uint incentives;
      uint128 lastClaimedIndex;
      uint64[] marketsCreated;
    }
	
	  uint16 internal maxRewardPoolPercForMC;
    uint16 internal minRewardPoolPercForMC;
    uint256 internal maxGasPrice;
    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal plotToken;
    uint256 internal plotStakeForRewardPoolShare;
    uint256 internal rewardPoolShareThreshold;
    uint internal predictionDecimalMultiplier;
    ITokenController internal tokenController;
    IChainLinkOracle internal clGasPriceAggregator;
    IMarketUtility internal marketUtility;
    IAllMarkets internal allMarkets;
    mapping(uint256 => MarketCreationRewardData) internal marketCreationRewardData; //Of market
    mapping(address => MarketCreationRewardUserData) internal marketCreationRewardUserData; //Of user

    /**
     * @dev Changes the master address and update it's instance
     */
    function setMasterAddress() public {
      OwnedUpgradeabilityProxy proxy =  OwnedUpgradeabilityProxy(address(uint160(address(this))));
      require(msg.sender == proxy.proxyOwner(),"not owner.");
      IMaster ms = IMaster(msg.sender);
      masterAddress = msg.sender;
      plotToken = ms.dAppToken();
      tokenController = ITokenController(ms.getLatestAddress("TC"));
      allMarkets = IAllMarkets(ms.getLatestAddress("AM"));
    }

    /**
    * @dev Function to set inital parameters of contract
    * @param _utility MarketUtility address
    * @param _clGasPriceAggregator Chainlink gas price aggregator address
    */
    function initialise(address _utility, address _clGasPriceAggregator) external {
      require(address(clGasPriceAggregator) == address(0));
      clGasPriceAggregator = IChainLinkOracle(_clGasPriceAggregator);
      marketUtility = IMarketUtility(_utility);
      maxGasPrice = 100 * 10**9;
      maxRewardPoolPercForMC = 500; // Raised by 2 decimals
      minRewardPoolPercForMC = 50; // Raised by 2 decimals
      plotStakeForRewardPoolShare = 25000 ether;
      rewardPoolShareThreshold = 1 ether;
      predictionDecimalMultiplier = 10;
    }

    /**
    * @dev function to update integer parameters
    */
    function updateUintParameters(bytes8 code, uint256 value) external onlyAuthorizedToGovern {
      if(code == "MAXGAS") { // Maximum gas upto which is considered while calculating market creation incentives
        maxGasPrice = value;
      } else if(code == "MAXRPSP") { // Max Reward Pool percent for market creator
        maxRewardPoolPercForMC = uint16(value);
      } else if(code == "MINRPSP") { // Min Reward Pool percent for market creator
        minRewardPoolPercForMC = uint16(value);
      } else if(code == "PSFRPS") { // Reward Pool percent for market creator
        plotStakeForRewardPoolShare = value;
      } else if(code == "RPSTH") { // Reward Pool percent for market creator
        rewardPoolShareThreshold = value;
      }
    }

    /**
    * @dev function to update address parameters
    */
    function updateAddressParameters(bytes8 code, address payable value) external onlyAuthorizedToGovern {
      if(code == "GASAGG") { // Incentive to be distributed to user for market creation
        clGasPriceAggregator = IChainLinkOracle(value);
      }
    }

    /**
    * @dev function to get integer parameters
    */
    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint256 value) {
      codeVal = code;
      if(code == "MAXGAS") { // Maximum gas upto which is considered while calculating market creation incentives
        value = maxGasPrice;
      } else if(code == "MAXRPSP") { // Max Reward Pool percent for market creator
        value = maxRewardPoolPercForMC;
      } else if(code == "MINRPSP") { // Min Reward Pool percent for market creator
        value = minRewardPoolPercForMC;
      } else if(code == "PSFRPS") { // Reward Pool percent for market creator
        value = plotStakeForRewardPoolShare;
      } else if(code == "RPSTH") { // Reward Pool percent for market creator
        value = rewardPoolShareThreshold;
      }
    }

    /**
    * @dev function to get address parameters
    */
    function getAddressParameters(bytes8 code) external view returns(bytes8 codeVal, address value) {
      codeVal = code;
      if(code == "GASAGG") { // Incentive to be distributed to user for market creation
        value = address(clGasPriceAggregator);
      }
    }

    /**
    * @dev internal function to calculate market reward pool share percent to be rewarded to market creator
    */
    function _checkIfCreatorStaked(address _createdBy, uint64 _marketId) internal {
      uint256 tokensLocked = ITokenController(tokenController).tokensLockedAtTime(_createdBy, "SM", now);
      marketCreationRewardData[_marketId].createdBy = _createdBy;
      //Intentionally performed mul operation after div, to get absolute value instead of decimals
      marketCreationRewardData[_marketId].rewardPoolSharePerc
       = uint16(Math.min(
          maxRewardPoolPercForMC,
          minRewardPoolPercForMC + tokensLocked.div(plotStakeForRewardPoolShare).mul(minRewardPoolPercForMC)
        ));
    }

    /**
    * @dev function to calculate user incentive for market creation
    * @param _createdBy Address of market creator
    * @param _gasCosumed Gas consumed by the transaction till now 
    * @param _marketId Index of market
    */
    function calculateMarketCreationIncentive(address _createdBy, uint256 _gasCosumed, uint64 _marketId) external onlyInternal {
      _checkIfCreatorStaked(_createdBy, _marketId);
      marketCreationRewardUserData[_createdBy].marketsCreated.push(_marketId);
      uint256 gasUsedTotal;
      //Adding buffer gas for below calculations
      gasUsedTotal = _gasCosumed + 84000;
      uint256 gasPrice = _checkGasPrice();
      uint256 gasCost = gasUsedTotal.mul(gasPrice);
      (, uint256 incentive) = marketUtility.getValueAndMultiplierParameters(ETH_ADDRESS, gasCost);
      marketCreationRewardUserData[_createdBy].incentives = marketCreationRewardUserData[_createdBy].incentives.add(incentive);
      emit MarketCreationReward(_createdBy, _marketId, incentive, gasUsedTotal, gasCost, gasPrice, tx.gasprice, maxGasPrice, marketCreationRewardData[_marketId].rewardPoolSharePerc);
    }

    /**
    * @dev internal function to calculate gas price for market creation incentives
    */
    function _checkGasPrice() internal view returns(uint256) {
      uint fastGas = uint(clGasPriceAggregator.latestAnswer());
      uint fastGasWithMaxDeviation = fastGas.mul(125).div(100);
      return Math.min(Math.min(tx.gasprice,fastGasWithMaxDeviation), maxGasPrice);
    }

    /**
    * @dev Function to deposit market reward pool share funds for market creator
    * @param _marketId Index of market
    * @param _plotShare PLOT reward pool share
    * msg.value ETH reward pool share
    */
    function depositMarketRewardPoolShare(uint256 _marketId, uint256 _ethShare, uint256 _plotShare, uint64 _ethDeposited, uint64 _plotDeposited) external payable onlyInternal {
    	marketCreationRewardData[_marketId].ethIncentive = _ethShare;
    	marketCreationRewardData[_marketId].plotIncentive = _plotShare;
      marketCreationRewardData[_marketId].ethDeposited = _ethDeposited;
      marketCreationRewardData[_marketId].plotDeposited = _plotDeposited;
     	emit MarketCreatorRewardPoolShare(marketCreationRewardData[_marketId].createdBy, _marketId, _plotShare, _ethShare);
    }

    /**
    * @dev Function to return the market reward pool share funds of market creator: To be used in case of dispute
    * @param _marketId Index of market
    */
    function returnMarketRewardPoolShare(uint256 _marketId) external onlyInternal{
      uint256 plotToTransfer = marketCreationRewardData[_marketId].plotIncentive.add(marketCreationRewardData[_marketId].plotDeposited.mul(10**predictionDecimalMultiplier));
      uint256 ethToTransfer = marketCreationRewardData[_marketId].ethIncentive.add(marketCreationRewardData[_marketId].ethDeposited.mul(10**predictionDecimalMultiplier));
      delete marketCreationRewardData[_marketId].ethIncentive;
      delete marketCreationRewardData[_marketId].plotIncentive;
      delete marketCreationRewardData[_marketId].ethDeposited;
      delete marketCreationRewardData[_marketId].plotDeposited;
      _transferAsset(ETH_ADDRESS, msg.sender, ethToTransfer);
      _transferAsset(plotToken, msg.sender, plotToTransfer);
    }

    /**
    * @dev function to reward user for initiating market creation calls as per the new incetive calculations
    */
    function claimCreationReward(uint256 _maxRecords) external {
      uint256 pendingPLOTReward = marketCreationRewardUserData[msg.sender].incentives;
      delete marketCreationRewardUserData[msg.sender].incentives;
      (uint256 ethIncentive, uint256 plotIncentive) = _getRewardPoolIncentives(_maxRecords);
      pendingPLOTReward = pendingPLOTReward.add(plotIncentive);
      require(pendingPLOTReward > 0 || ethIncentive > 0, "No pending");
      _transferAsset(address(plotToken), msg.sender, pendingPLOTReward);
      _transferAsset(ETH_ADDRESS, msg.sender, ethIncentive);
      emit ClaimedMarketCreationReward(msg.sender, ethIncentive, pendingPLOTReward);
    }

    /**
    * @dev Transfer `_amount` number of market registry assets contract to `_to` address
    */
    function transferAssets(address _asset, address payable _to, uint _amount) external onlyAuthorizedToGovern {
      _transferAsset(_asset, _to, _amount);
    }

    /**
    * @dev internal function to calculate market reward pool share incentives for market creator
    */
    function _getRewardPoolIncentives(uint256 _maxRecords) internal returns(uint256 ethIncentive, uint256 plotIncentive) {
      MarketCreationRewardUserData storage rewardData = marketCreationRewardUserData[msg.sender];
      uint256 len = rewardData.marketsCreated.length;
      uint256 lastClaimed = len;
      uint256 count;
      uint128 i;
      for(i = rewardData.lastClaimedIndex;i < len && count < _maxRecords; i++) {
        MarketCreationRewardData storage marketData = marketCreationRewardData[rewardData.marketsCreated[i]];
        if(allMarkets.marketStatus(rewardData.marketsCreated[i]) == IAllMarkets.PredictionStatus.Settled) {
          ethIncentive = ethIncentive.add(marketData.ethIncentive);
          plotIncentive = plotIncentive.add(marketData.plotIncentive);
          delete marketData.ethIncentive;
          delete marketData.plotIncentive;
          count++;
        } else {
          if(lastClaimed == len) {
            lastClaimed = i;
          }
        }
      }
      if(lastClaimed == len) {
        lastClaimed = i;
      }
      rewardData.lastClaimedIndex = uint128(lastClaimed);
    }

    /**
    * @dev function to get pending reward of user for initiating market creation calls as per the new incetive calculations
    * @param _user Address of user for whom pending rewards to be checked
    * @return plotIncentive Incentives given for creating market as per the gas consumed
    * @return pendingPLOTReward PLOT Reward pool share of markets created by user
    * @return pendingETHReward ETH Reward pool share of markets created by user
    */
    function getPendingMarketCreationRewards(address _user) external view returns(uint256 plotIncentive, uint256 pendingPLOTReward, uint256 pendingETHReward){
      plotIncentive = marketCreationRewardUserData[_user].incentives;
      (pendingETHReward, pendingPLOTReward) = _getPendingRewardPoolIncentives(_user);
    }

    /**
    * @dev Get market reward pool share percent to be rewarded to market creator
    */
    function getMarketCreatorRPoolShareParams(uint256 _market, uint256 plotStaked, uint256 ethStaked) external view returns(uint16, bool) {
      return (marketCreationRewardData[_market].rewardPoolSharePerc, _checkIfThresholdReachedForRPS(_market, plotStaked, ethStaked));
    }

    /**
    * @dev Check if threshold reached for reward pool share percent for market creator.
    * Calculate total leveraged amount staked in market value in ETH
    * @param _marketId Index of market to check threshold
    */
    function _checkIfThresholdReachedForRPS(uint256 _marketId, uint256 plotStaked, uint256 ethStaked) internal view returns(bool) {
      uint256 _plotStaked;
      _plotStaked = marketUtility.getAssetValueETH(plotToken, plotStaked.mul(1e10));
      return (_plotStaked.add(ethStaked.mul(1e10)) > rewardPoolShareThreshold);
    }

    /**
    * @dev internal function to calculate market reward pool share incentives for market creator
    */
    function _getPendingRewardPoolIncentives(address _user) internal view returns(uint256 ethIncentive, uint256 plotIncentive) {
      MarketCreationRewardUserData memory rewardData = marketCreationRewardUserData[_user];
      uint256 len = rewardData.marketsCreated.length;
      for(uint256 i = rewardData.lastClaimedIndex;i < len; i++) {
        MarketCreationRewardData memory marketData = marketCreationRewardData[rewardData.marketsCreated[i]];
        if(marketData.ethIncentive > 0 || marketData.plotIncentive > 0) {
          if(allMarkets.marketStatus(rewardData.marketsCreated[i]) == IAllMarkets.PredictionStatus.Settled) {
            ethIncentive = ethIncentive.add(marketData.ethIncentive);
            plotIncentive = plotIncentive.add(marketData.plotIncentive);
          }
        }
      }
    }

    /**
    * @dev Transfer the assets to specified address.
    * @param _asset The asset transfer to the specific address.
    * @param _recipient The address to transfer the asset of
    * @param _amount The amount which is transfer.
    */
    function _transferAsset(address _asset, address payable _recipient, uint256 _amount) internal {
      if(_amount > 0) { 
        if(_asset == ETH_ADDRESS) {
          _recipient.transfer(_amount);
        } else {
          require(IToken(_asset).transfer(_recipient, _amount));
        }
      }
    }

    /**
    * @dev Payable Fallback function to receive funds
    */
    function () external payable {
    }

}