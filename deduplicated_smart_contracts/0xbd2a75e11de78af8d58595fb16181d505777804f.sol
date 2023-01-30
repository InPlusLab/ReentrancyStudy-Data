/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

// File: @openzeppelin/contracts/math/SafeMath.sol

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
        return sub(a, b, "SafeMath: subtraction overflow");
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @devprotocol/i-s-tokens/contracts/interface/ISTokensManager.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface ISTokensManager {
	/*
	 * @dev The event fired when a token is minted.
	 * @param tokenId The ID of the created new staking position
	 * @param owner The address of the owner of the new staking position
	 * @param property The address of the Property as the staking destination
	 * @param amount The amount of the new staking position
	 * @param price The latest unit price of the cumulative staking reward
	 */
	event Minted(
		uint256 tokenId,
		address owner,
		address property,
		uint256 amount,
		uint256 price
	);

	/*
	 * @dev The event fired when a token is updated.
	 * @param tokenId The ID of the staking position
	 * @param amount The new staking amount
	 * @param price The latest unit price of the cumulative staking reward
	 * This value equals the 3rd return value of the Lockup.calculateCumulativeRewardPrices
	 * @param cumulativeReward The cumulative withdrawn reward amount
	 * @param pendingReward The pending withdrawal reward amount amount
	 */
	event Updated(
		uint256 tokenId,
		uint256 amount,
		uint256 price,
		uint256 cumulativeReward,
		uint256 pendingReward
	);

	/*
	 * @dev perform the initial setup
	 * @param _config AddressConfig
	 */
	function initialize(address _config) external;

	/*
	 * @dev Creates the new staking position for the caller.
	 * Mint must be called from the Lockup contract.
	 * @param _owner The address of the owner of the new staking position
	 * @param _property The address of the Property as the staking destination
	 * @param _amount The amount of the new staking position
	 * @param _price The latest unit price of the cumulative staking reward
	 * @return uint256 The ID of the created new staking position
	 */
	function mint(
		address _owner,
		address _property,
		uint256 _amount,
		uint256 _price
	) external returns (uint256);

	/*
	 * @dev Updates the existing staking position.
	 * Update must be called from the Lockup contract.
	 * @param _tokenId The ID of the staking position
	 * @param _amount The new staking amount
	 * @param _price The latest unit price of the cumulative staking reward
	 * This value equals the 3rd return value of the Lockup.calculateCumulativeRewardPrices
	 * @param _cumulativeReward The cumulative withdrawn reward amount
	 * @param _pendingReward The pending withdrawal reward amount amount
	 * @return bool On success, true will be returned
	 */
	function update(
		uint256 _tokenId,
		uint256 _amount,
		uint256 _price,
		uint256 _cumulativeReward,
		uint256 _pendingReward
	) external returns (bool);

	/*
	 * @dev Gets the existing staking position.
	 * @param _tokenId The ID of the staking position
	 * @return address The address of the Property as the staking destination
	 * @return uint256 The amount of the new staking position
	 * @return uint256 The latest unit price of the cumulative staking reward
	 * @return uint256 The cumulative withdrawn reward amount
	 * @return uint256 The pending withdrawal reward amount amount
	 */
	function positions(uint256 _tokenId)
		external
		view
		returns (
			address,
			uint256,
			uint256,
			uint256,
			uint256
		);

	/*
	 * @dev Gets the reward status of the staking position.
	 * @param _tokenId The ID of the staking position
	 * @return uint256 The reward amount of adding the cumulative withdrawn amount
	 to the withdrawable amount
	 * @return uint256 The cumulative withdrawn reward amount
	 * @return uint256 The withdrawable reward amount
	 */
	function rewards(uint256 _tokenId)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);

	/*
	 * @dev get token ids by property
	 * @param _property property address
	 * @return uint256[] token id list
	 */
	function positionsOfProperty(address _property)
		external
		view
		returns (uint256[] memory);

	/*
	 * @dev get token ids by owner
	 * @param _owner owner address
	 * @return uint256[] token id list
	 */
	function positionsOfOwner(address _owner)
		external
		view
		returns (uint256[] memory);
}

// File: contracts/src/common/libs/Decimals.sol

pragma solidity 0.5.17;


/**
 * Library for emulating calculations involving decimals.
 */
library Decimals {
	using SafeMath for uint256;
	uint120 private constant BASIS_VAKUE = 1000000000000000000;

	/**
	 * @dev Returns the ratio of the first argument to the second argument.
	 * @param _a Numerator.
	 * @param _b Fraction.
	 * @return Calculated ratio.
	 */
	function outOf(uint256 _a, uint256 _b)
		internal
		pure
		returns (uint256 result)
	{
		if (_a == 0) {
			return 0;
		}
		uint256 a = _a.mul(BASIS_VAKUE);
		if (a < _b) {
			return 0;
		}
		return (a.div(_b));
	}

	/**
	 * @dev Returns multiplied the number by 10^18.
	 * @param _a Numerical value to be multiplied.
	 * @return Multiplied value.
	 */
	function mulBasis(uint256 _a) internal pure returns (uint256) {
		return _a.mul(BASIS_VAKUE);
	}

	/**
	 * @dev Returns divisioned the number by 10^18.
	 * This function can use it to restore the number of digits in the result of `outOf`.
	 * @param _a Numerical value to be divisioned.
	 * @return Divisioned value.
	 */
	function divBasis(uint256 _a) internal pure returns (uint256) {
		return _a.div(BASIS_VAKUE);
	}
}

// File: contracts/interface/IAddressConfig.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IAddressConfig {
	function token() external view returns (address);

	function allocator() external view returns (address);

	function allocatorStorage() external view returns (address);

	function withdraw() external view returns (address);

	function withdrawStorage() external view returns (address);

	function marketFactory() external view returns (address);

	function marketGroup() external view returns (address);

	function propertyFactory() external view returns (address);

	function propertyGroup() external view returns (address);

	function metricsGroup() external view returns (address);

	function metricsFactory() external view returns (address);

	function policy() external view returns (address);

	function policyFactory() external view returns (address);

	function policySet() external view returns (address);

	function policyGroup() external view returns (address);

	function lockup() external view returns (address);

	function lockupStorage() external view returns (address);

	function voteTimes() external view returns (address);

	function voteTimesStorage() external view returns (address);

	function voteCounter() external view returns (address);

	function voteCounterStorage() external view returns (address);

	function setAllocator(address _addr) external;

	function setAllocatorStorage(address _addr) external;

	function setWithdraw(address _addr) external;

	function setWithdrawStorage(address _addr) external;

	function setMarketFactory(address _addr) external;

	function setMarketGroup(address _addr) external;

	function setPropertyFactory(address _addr) external;

	function setPropertyGroup(address _addr) external;

	function setMetricsFactory(address _addr) external;

	function setMetricsGroup(address _addr) external;

	function setPolicyFactory(address _addr) external;

	function setPolicyGroup(address _addr) external;

	function setPolicySet(address _addr) external;

	function setPolicy(address _addr) external;

	function setToken(address _addr) external;

	function setLockup(address _addr) external;

	function setLockupStorage(address _addr) external;

	function setVoteTimes(address _addr) external;

	function setVoteTimesStorage(address _addr) external;

	function setVoteCounter(address _addr) external;

	function setVoteCounterStorage(address _addr) external;
}

// File: contracts/src/common/config/UsingConfig.sol

pragma solidity 0.5.17;


/**
 * Module for using AddressConfig contracts.
 */
contract UsingConfig {
	address private _config;

	/**
	 * Initialize the argument as AddressConfig address.
	 */
	constructor(address _addressConfig) public {
		_config = _addressConfig;
	}

	/**
	 * Returns the latest AddressConfig instance.
	 */
	function config() internal view returns (IAddressConfig) {
		return IAddressConfig(_config);
	}

	/**
	 * Returns the latest AddressConfig address.
	 */
	function configAddress() external view returns (address) {
		return _config;
	}
}

// File: contracts/interface/IUsingStorage.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IUsingStorage {
	function getStorageAddress() external view returns (address);

	function createStorage() external;

	function setStorage(address _storageAddress) external;

	function changeOwner(address newOwner) external;
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/src/common/storage/EternalStorage.sol

pragma solidity 0.5.17;

/**
 * Module for persisting states.
 * Stores a map for `uint256`, `string`, `address`, `bytes32`, `bool`, and `int256` type with `bytes32` type as a key.
 */
contract EternalStorage {
	address private currentOwner = msg.sender;

	mapping(bytes32 => uint256) private uIntStorage;
	mapping(bytes32 => string) private stringStorage;
	mapping(bytes32 => address) private addressStorage;
	mapping(bytes32 => bytes32) private bytesStorage;
	mapping(bytes32 => bool) private boolStorage;
	mapping(bytes32 => int256) private intStorage;

	/**
	 * Modifiers to validate that only the owner can execute.
	 */
	modifier onlyCurrentOwner() {
		require(msg.sender == currentOwner, "not current owner");
		_;
	}

	/**
	 * Transfer the owner.
	 * Only the owner can execute this function.
	 */
	function changeOwner(address _newOwner) external {
		require(msg.sender == currentOwner, "not current owner");
		currentOwner = _newOwner;
	}

	// *** Getter Methods ***

	/**
	 * Returns the value of the `uint256` type that mapped to the given key.
	 */
	function getUint(bytes32 _key) external view returns (uint256) {
		return uIntStorage[_key];
	}

	/**
	 * Returns the value of the `string` type that mapped to the given key.
	 */
	function getString(bytes32 _key) external view returns (string memory) {
		return stringStorage[_key];
	}

	/**
	 * Returns the value of the `address` type that mapped to the given key.
	 */
	function getAddress(bytes32 _key) external view returns (address) {
		return addressStorage[_key];
	}

	/**
	 * Returns the value of the `bytes32` type that mapped to the given key.
	 */
	function getBytes(bytes32 _key) external view returns (bytes32) {
		return bytesStorage[_key];
	}

	/**
	 * Returns the value of the `bool` type that mapped to the given key.
	 */
	function getBool(bytes32 _key) external view returns (bool) {
		return boolStorage[_key];
	}

	/**
	 * Returns the value of the `int256` type that mapped to the given key.
	 */
	function getInt(bytes32 _key) external view returns (int256) {
		return intStorage[_key];
	}

	// *** Setter Methods ***

	/**
	 * Maps a value of `uint256` type to a given key.
	 * Only the owner can execute this function.
	 */
	function setUint(bytes32 _key, uint256 _value) external onlyCurrentOwner {
		uIntStorage[_key] = _value;
	}

	/**
	 * Maps a value of `string` type to a given key.
	 * Only the owner can execute this function.
	 */
	function setString(bytes32 _key, string calldata _value)
		external
		onlyCurrentOwner
	{
		stringStorage[_key] = _value;
	}

	/**
	 * Maps a value of `address` type to a given key.
	 * Only the owner can execute this function.
	 */
	function setAddress(bytes32 _key, address _value)
		external
		onlyCurrentOwner
	{
		addressStorage[_key] = _value;
	}

	/**
	 * Maps a value of `bytes32` type to a given key.
	 * Only the owner can execute this function.
	 */
	function setBytes(bytes32 _key, bytes32 _value) external onlyCurrentOwner {
		bytesStorage[_key] = _value;
	}

	/**
	 * Maps a value of `bool` type to a given key.
	 * Only the owner can execute this function.
	 */
	function setBool(bytes32 _key, bool _value) external onlyCurrentOwner {
		boolStorage[_key] = _value;
	}

	/**
	 * Maps a value of `int256` type to a given key.
	 * Only the owner can execute this function.
	 */
	function setInt(bytes32 _key, int256 _value) external onlyCurrentOwner {
		intStorage[_key] = _value;
	}

	// *** Delete Methods ***

	/**
	 * Deletes the value of the `uint256` type that mapped to the given key.
	 * Only the owner can execute this function.
	 */
	function deleteUint(bytes32 _key) external onlyCurrentOwner {
		delete uIntStorage[_key];
	}

	/**
	 * Deletes the value of the `string` type that mapped to the given key.
	 * Only the owner can execute this function.
	 */
	function deleteString(bytes32 _key) external onlyCurrentOwner {
		delete stringStorage[_key];
	}

	/**
	 * Deletes the value of the `address` type that mapped to the given key.
	 * Only the owner can execute this function.
	 */
	function deleteAddress(bytes32 _key) external onlyCurrentOwner {
		delete addressStorage[_key];
	}

	/**
	 * Deletes the value of the `bytes32` type that mapped to the given key.
	 * Only the owner can execute this function.
	 */
	function deleteBytes(bytes32 _key) external onlyCurrentOwner {
		delete bytesStorage[_key];
	}

	/**
	 * Deletes the value of the `bool` type that mapped to the given key.
	 * Only the owner can execute this function.
	 */
	function deleteBool(bytes32 _key) external onlyCurrentOwner {
		delete boolStorage[_key];
	}

	/**
	 * Deletes the value of the `int256` type that mapped to the given key.
	 * Only the owner can execute this function.
	 */
	function deleteInt(bytes32 _key) external onlyCurrentOwner {
		delete intStorage[_key];
	}
}

// File: contracts/src/common/storage/UsingStorage.sol

pragma solidity 0.5.17;




/**
 * Module for contrast handling EternalStorage.
 */
contract UsingStorage is Ownable, IUsingStorage {
	address private _storage;

	/**
	 * Modifier to verify that EternalStorage is set.
	 */
	modifier hasStorage() {
		require(_storage != address(0), "storage is not set");
		_;
	}

	/**
	 * Returns the set EternalStorage instance.
	 */
	function eternalStorage()
		internal
		view
		hasStorage
		returns (EternalStorage)
	{
		return EternalStorage(_storage);
	}

	/**
	 * Returns the set EternalStorage address.
	 */
	function getStorageAddress() external view hasStorage returns (address) {
		return _storage;
	}

	/**
	 * Create a new EternalStorage contract.
	 * This function call will fail if the EternalStorage contract is already set.
	 * Also, only the owner can execute it.
	 */
	function createStorage() external onlyOwner {
		require(_storage == address(0), "storage is set");
		EternalStorage tmp = new EternalStorage();
		_storage = address(tmp);
	}

	/**
	 * Assigns the EternalStorage contract that has already been created.
	 * Only the owner can execute this function.
	 */
	function setStorage(address _storageAddress) external onlyOwner {
		_storage = _storageAddress;
	}

	/**
	 * Delegates the owner of the current EternalStorage contract.
	 * Only the owner can execute this function.
	 */
	function changeOwner(address newOwner) external onlyOwner {
		EternalStorage(_storage).changeOwner(newOwner);
	}
}

// File: contracts/src/lockup/LockupStorage.sol

pragma solidity 0.5.17;



contract LockupStorage is UsingStorage {
	using SafeMath for uint256;

	uint256 private constant BASIS = 100000000000000000000000000000000;

	//AllValue
	function setStorageAllValue(uint256 _value) internal {
		bytes32 key = getStorageAllValueKey();
		eternalStorage().setUint(key, _value);
	}

	function getStorageAllValue() public view returns (uint256) {
		bytes32 key = getStorageAllValueKey();
		return eternalStorage().getUint(key);
	}

	function getStorageAllValueKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_allValue"));
	}

	//Value
	function setStorageValue(
		address _property,
		address _sender,
		uint256 _value
	) internal {
		bytes32 key = getStorageValueKey(_property, _sender);
		eternalStorage().setUint(key, _value);
	}

	function getStorageValue(address _property, address _sender)
		public
		view
		returns (uint256)
	{
		bytes32 key = getStorageValueKey(_property, _sender);
		return eternalStorage().getUint(key);
	}

	function getStorageValueKey(address _property, address _sender)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_value", _property, _sender));
	}

	//PropertyValue
	function setStoragePropertyValue(address _property, uint256 _value)
		internal
	{
		bytes32 key = getStoragePropertyValueKey(_property);
		eternalStorage().setUint(key, _value);
	}

	function getStoragePropertyValue(address _property)
		public
		view
		returns (uint256)
	{
		bytes32 key = getStoragePropertyValueKey(_property);
		return eternalStorage().getUint(key);
	}

	function getStoragePropertyValueKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_propertyValue", _property));
	}

	//InterestPrice
	function setStorageInterestPrice(address _property, uint256 _value)
		internal
	{
		// The previously used function
		// This function is only used in testing
		eternalStorage().setUint(getStorageInterestPriceKey(_property), _value);
	}

	function getStorageInterestPrice(address _property)
		public
		view
		returns (uint256)
	{
		return eternalStorage().getUint(getStorageInterestPriceKey(_property));
	}

	function getStorageInterestPriceKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_interestTotals", _property));
	}

	//LastInterestPrice
	function setStorageLastInterestPrice(
		address _property,
		address _user,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageLastInterestPriceKey(_property, _user),
			_value
		);
	}

	function getStorageLastInterestPrice(address _property, address _user)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastInterestPriceKey(_property, _user)
			);
	}

	function getStorageLastInterestPriceKey(address _property, address _user)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(
				abi.encodePacked("_lastLastInterestPrice", _property, _user)
			);
	}

	//LastSameRewardsAmountAndBlock
	function setStorageLastSameRewardsAmountAndBlock(
		uint256 _amount,
		uint256 _block
	) internal {
		uint256 record = _amount.mul(BASIS).add(_block);
		eternalStorage().setUint(
			getStorageLastSameRewardsAmountAndBlockKey(),
			record
		);
	}

	function getStorageLastSameRewardsAmountAndBlock()
		public
		view
		returns (uint256 _amount, uint256 _block)
	{
		uint256 record = eternalStorage().getUint(
			getStorageLastSameRewardsAmountAndBlockKey()
		);
		uint256 amount = record.div(BASIS);
		uint256 blockNumber = record.sub(amount.mul(BASIS));
		return (amount, blockNumber);
	}

	function getStorageLastSameRewardsAmountAndBlockKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_LastSameRewardsAmountAndBlock"));
	}

	//CumulativeGlobalRewards
	function setStorageCumulativeGlobalRewards(uint256 _value) internal {
		eternalStorage().setUint(
			getStorageCumulativeGlobalRewardsKey(),
			_value
		);
	}

	function getStorageCumulativeGlobalRewards() public view returns (uint256) {
		return eternalStorage().getUint(getStorageCumulativeGlobalRewardsKey());
	}

	function getStorageCumulativeGlobalRewardsKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_cumulativeGlobalRewards"));
	}

	//PendingWithdrawal
	function setStoragePendingInterestWithdrawal(
		address _property,
		address _user,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStoragePendingInterestWithdrawalKey(_property, _user),
			_value
		);
	}

	function getStoragePendingInterestWithdrawal(
		address _property,
		address _user
	) public view returns (uint256) {
		return
			eternalStorage().getUint(
				getStoragePendingInterestWithdrawalKey(_property, _user)
			);
	}

	function getStoragePendingInterestWithdrawalKey(
		address _property,
		address _user
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked("_pendingInterestWithdrawal", _property, _user)
			);
	}

	//DIP4GenesisBlock
	function setStorageDIP4GenesisBlock(uint256 _block) internal {
		eternalStorage().setUint(getStorageDIP4GenesisBlockKey(), _block);
	}

	function getStorageDIP4GenesisBlock() public view returns (uint256) {
		return eternalStorage().getUint(getStorageDIP4GenesisBlockKey());
	}

	function getStorageDIP4GenesisBlockKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_dip4GenesisBlock"));
	}

	//lastStakedInterestPrice
	function setStorageLastStakedInterestPrice(
		address _property,
		address _user,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageLastStakedInterestPriceKey(_property, _user),
			_value
		);
	}

	function getStorageLastStakedInterestPrice(address _property, address _user)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastStakedInterestPriceKey(_property, _user)
			);
	}

	function getStorageLastStakedInterestPriceKey(
		address _property,
		address _user
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked("_lastStakedInterestPrice", _property, _user)
			);
	}

	//lastStakesChangedCumulativeReward
	function setStorageLastStakesChangedCumulativeReward(uint256 _value)
		internal
	{
		eternalStorage().setUint(
			getStorageLastStakesChangedCumulativeRewardKey(),
			_value
		);
	}

	function getStorageLastStakesChangedCumulativeReward()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastStakesChangedCumulativeRewardKey()
			);
	}

	function getStorageLastStakesChangedCumulativeRewardKey()
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(abi.encodePacked("_lastStakesChangedCumulativeReward"));
	}

	//LastCumulativeHoldersRewardPrice
	function setStorageLastCumulativeHoldersRewardPrice(uint256 _holders)
		internal
	{
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardPriceKey(),
			_holders
		);
	}

	function getStorageLastCumulativeHoldersRewardPrice()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardPriceKey()
			);
	}

	function getStorageLastCumulativeHoldersRewardPriceKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("0lastCumulativeHoldersRewardPrice"));
	}

	//LastCumulativeInterestPrice
	function setStorageLastCumulativeInterestPrice(uint256 _interest) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeInterestPriceKey(),
			_interest
		);
	}

	function getStorageLastCumulativeInterestPrice()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastCumulativeInterestPriceKey()
			);
	}

	function getStorageLastCumulativeInterestPriceKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("0lastCumulativeInterestPrice"));
	}

	//LastCumulativeHoldersRewardAmountPerProperty
	function setStorageLastCumulativeHoldersRewardAmountPerProperty(
		address _property,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
				_property
			),
			_value
		);
	}

	function getStorageLastCumulativeHoldersRewardAmountPerProperty(
		address _property
	) public view returns (uint256) {
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
					_property
				)
			);
	}

	function getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
		address _property
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					"0lastCumulativeHoldersRewardAmountPerProperty",
					_property
				)
			);
	}

	//LastCumulativeHoldersRewardPricePerProperty
	function setStorageLastCumulativeHoldersRewardPricePerProperty(
		address _property,
		uint256 _price
	) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardPricePerPropertyKey(_property),
			_price
		);
	}

	function getStorageLastCumulativeHoldersRewardPricePerProperty(
		address _property
	) public view returns (uint256) {
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardPricePerPropertyKey(
					_property
				)
			);
	}

	function getStorageLastCumulativeHoldersRewardPricePerPropertyKey(
		address _property
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					"0lastCumulativeHoldersRewardPricePerProperty",
					_property
				)
			);
	}

	//cap
	function setStorageCap(uint256 _cap) internal {
		eternalStorage().setUint(getStorageCapKey(), _cap);
	}

	function getStorageCap() public view returns (uint256) {
		return eternalStorage().getUint(getStorageCapKey());
	}

	function getStorageCapKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_cap"));
	}

	//CumulativeHoldersRewardCap
	function setStorageCumulativeHoldersRewardCap(uint256 _value) internal {
		eternalStorage().setUint(
			getStorageCumulativeHoldersRewardCapKey(),
			_value
		);
	}

	function getStorageCumulativeHoldersRewardCap()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(getStorageCumulativeHoldersRewardCapKey());
	}

	function getStorageCumulativeHoldersRewardCapKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_cumulativeHoldersRewardCap"));
	}

	//LastCumulativeHoldersPriceCap
	function setStorageLastCumulativeHoldersPriceCap(uint256 _value) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersPriceCapKey(),
			_value
		);
	}

	function getStorageLastCumulativeHoldersPriceCap()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersPriceCapKey()
			);
	}

	function getStorageLastCumulativeHoldersPriceCapKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_lastCumulativeHoldersPriceCap"));
	}

	//InitialCumulativeHoldersRewardCap
	function setStorageInitialCumulativeHoldersRewardCap(
		address _property,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageInitialCumulativeHoldersRewardCapKey(_property),
			_value
		);
	}

	function getStorageInitialCumulativeHoldersRewardCap(address _property)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageInitialCumulativeHoldersRewardCapKey(_property)
			);
	}

	function getStorageInitialCumulativeHoldersRewardCapKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(
				abi.encodePacked(
					"_initialCumulativeHoldersRewardCap",
					_property
				)
			);
	}

	//FallbackInitialCumulativeHoldersRewardCap
	function setStorageFallbackInitialCumulativeHoldersRewardCap(uint256 _value)
		internal
	{
		eternalStorage().setUint(
			getStorageFallbackInitialCumulativeHoldersRewardCapKey(),
			_value
		);
	}

	function getStorageFallbackInitialCumulativeHoldersRewardCap()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageFallbackInitialCumulativeHoldersRewardCapKey()
			);
	}

	function getStorageFallbackInitialCumulativeHoldersRewardCapKey()
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(
				abi.encodePacked("_fallbackInitialCumulativeHoldersRewardCap")
			);
	}
}

// File: contracts/interface/IDev.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IDev {
	function deposit(address _to, uint256 _amount) external returns (bool);

	function depositFrom(
		address _from,
		address _to,
		uint256 _amount
	) external returns (bool);

	function fee(address _from, uint256 _amount) external returns (bool);
}

// File: contracts/interface/IDevMinter.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IDevMinter {
	function mint(address account, uint256 amount) external returns (bool);

	function renounceMinter() external;
}

// File: contracts/interface/IProperty.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IProperty {
	function author() external view returns (address);

	function changeAuthor(address _nextAuthor) external;

	function changeName(string calldata _name) external;

	function changeSymbol(string calldata _symbol) external;

	function withdraw(address _sender, uint256 _value) external;
}

// File: contracts/interface/IPolicy.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IPolicy {
	function rewards(uint256 _lockups, uint256 _assets)
		external
		view
		returns (uint256);

	function holdersShare(uint256 _amount, uint256 _lockups)
		external
		view
		returns (uint256);

	function authenticationFee(uint256 _assets, uint256 _propertyAssets)
		external
		view
		returns (uint256);

	function marketVotingBlocks() external view returns (uint256);

	function policyVotingBlocks() external view returns (uint256);

	function shareOfTreasury(uint256 _supply) external view returns (uint256);

	function treasury() external view returns (address);

	function capSetter() external view returns (address);
}

// File: contracts/interface/IAllocator.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IAllocator {
	function beforeBalanceChange(
		address _property,
		address _from,
		address _to
	) external;

	function calculateMaxRewardsPerBlock() external view returns (uint256);
}

// File: contracts/interface/ILockup.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface ILockup {
	function depositToProperty(address _property, uint256 _amount)
		external
		returns (uint256);

	function depositToPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);

	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external;

	function update() external;

	function withdraw(address _property, uint256 _amount) external;

	function withdrawByPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);

	function calculateCumulativeRewardPrices()
		external
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest,
			uint256 _holdersCap
		);

	function calculateRewardAmount(address _property)
		external
		view
		returns (uint256, uint256);

	/**
	 * caution!!!this function is deprecated!!!
	 * use calculateRewardAmount
	 */
	function calculateCumulativeHoldersRewardAmount(address _property)
		external
		view
		returns (uint256);

	function getPropertyValue(address _property)
		external
		view
		returns (uint256);

	function getAllValue() external view returns (uint256);

	function getValue(address _property, address _sender)
		external
		view
		returns (uint256);

	function calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) external view returns (uint256);

	function calculateWithdrawableInterestAmountByPosition(uint256 _tokenId)
		external
		view
		returns (uint256);

	function cap() external view returns (uint256);

	function updateCap(uint256 _cap) external;

	function devMinter() external view returns (address);

	function sTokensManager() external view returns (address);

	function migrateToSTokens(address _property) external returns (uint256);
}

// File: contracts/interface/IMetricsGroup.sol

// SPDX-License-Identifier: MPL-2.0
pragma solidity >=0.5.17;

interface IMetricsGroup {
	function addGroup(address _addr) external;

	function removeGroup(address _addr) external;

	function isGroup(address _addr) external view returns (bool);

	function totalIssuedMetrics() external view returns (uint256);

	function hasAssets(address _property) external view returns (bool);

	function getMetricsCountPerProperty(address _property)
		external
		view
		returns (uint256);

	function totalAuthenticatedProperties() external view returns (uint256);
}

// File: contracts/src/lockup/Lockup.sol

pragma solidity 0.5.17;

// prettier-ignore















/**
 * A contract that manages the staking of DEV tokens and calculates rewards.
 * Staking and the following mechanism determines that reward calculation.
 *
 * Variables:
 * -`M`: Maximum mint amount per block determined by Allocator contract
 * -`B`: Number of blocks during staking
 * -`P`: Total number of staking locked up in a Property contract
 * -`S`: Total number of staking locked up in all Property contracts
 * -`U`: Number of staking per account locked up in a Property contract
 *
 * Formula:
 * Staking Rewards = M * B * (P / S) * (U / P)
 *
 * Note:
 * -`M`, `P` and `S` vary from block to block, and the variation cannot be predicted.
 * -`B` is added every time the Ethereum block is created.
 * - Only `U` and `B` are predictable variables.
 * - As `M`, `P` and `S` cannot be observed from a staker, the "cumulative sum" is often used to calculate ratio variation with history.
 * - Reward withdrawal always withdraws the total withdrawable amount.
 *
 * Scenario:
 * - Assume `M` is fixed at 500
 * - Alice stakes 100 DEV on Property-A (Alice's staking state on Property-A: `M`=500, `B`=0, `P`=100, `S`=100, `U`=100)
 * - After 10 blocks, Bob stakes 60 DEV on Property-B (Alice's staking state on Property-A: `M`=500, `B`=10, `P`=100, `S`=160, `U`=100)
 * - After 10 blocks, Carol stakes 40 DEV on Property-A (Alice's staking state on Property-A: `M`=500, `B`=20, `P`=140, `S`=200, `U`=100)
 * - After 10 blocks, Alice withdraws Property-A staking reward. The reward at this time is 5000 DEV (10 blocks * 500 DEV) + 3125 DEV (10 blocks * 62.5% * 500 DEV) + 2500 DEV (10 blocks * 50% * 500 DEV).
 */
contract Lockup is ILockup, UsingConfig, LockupStorage {
	using SafeMath for uint256;
	using Decimals for uint256;
	address public devMinter;
	address public sTokensManager;
	struct RewardPrices {
		uint256 reward;
		uint256 holders;
		uint256 interest;
		uint256 holdersCap;
	}
	event Lockedup(address _from, address _property, uint256 _value);
	event UpdateCap(uint256 _cap);

	/**
	 * Initialize the passed address as AddressConfig address and Devminter.
	 */
	constructor(
		address _config,
		address _devMinter,
		address _sTokensManager
	) public UsingConfig(_config) {
		devMinter = _devMinter;
		sTokensManager = _sTokensManager;
	}

	/**
	 * @dev Validates the passed Property has greater than 1 asset.
	 * @param _property property address
	 */
	modifier onlyAuthenticatedProperty(address _property) {
		require(
			IMetricsGroup(config().metricsGroup()).hasAssets(_property),
			"unable to stake to unauthenticated property"
		);
		_;
	}

	/**
	 * @dev Check if the owner of the token is a sender.
	 * @param _tokenId The ID of the staking position
	 */
	modifier onlyPositionOwner(uint256 _tokenId) {
		require(
			IERC721(sTokensManager).ownerOf(_tokenId) == msg.sender,
			"illegal sender"
		);
		_;
	}

	/**
	 * @dev deposit dev token to dev protocol and generate s-token
	 * @param _property target property address
	 * @param _amount staking value
	 * @return tokenId The ID of the created new staking position
	 */
	function depositToProperty(address _property, uint256 _amount)
		external
		onlyAuthenticatedProperty(_property)
		returns (uint256)
	{
		/**
		 * Validates _amount is not 0.
		 */
		require(_amount != 0, "illegal deposit amount");
		/**
		 * Gets the latest cumulative sum of the interest price.
		 */
		(
			uint256 reward,
			uint256 holders,
			uint256 interest,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();
		/**
		 * Saves variables that should change due to the addition of staking.
		 */
		updateValues(
			true,
			_property,
			_amount,
			RewardPrices(reward, holders, interest, holdersCap)
		);
		/**
		 * transfer dev tokens
		 */
		require(
			IERC20(config().token()).transferFrom(
				msg.sender,
				_property,
				_amount
			),
			"dev transfer failed"
		);
		/**
		 * mint s tokens
		 */
		uint256 tokenId = ISTokensManager(sTokensManager).mint(
			msg.sender,
			_property,
			_amount,
			interest
		);
		emit Lockedup(msg.sender, _property, _amount);
		return tokenId;
	}

	/**
	 * @dev deposit dev token to dev protocol and update s-token status
	 * @param _tokenId s-token id
	 * @param _amount staking value
	 * @return bool On success, true will be returned
	 */
	function depositToPosition(uint256 _tokenId, uint256 _amount)
		external
		onlyPositionOwner(_tokenId)
		returns (bool)
	{
		/**
		 * Validates _amount is not 0.
		 */
		require(_amount != 0, "illegal deposit amount");
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		/**
		 * get position information
		 */
		(
			address property,
			uint256 amount,
			uint256 price,
			uint256 cumulativeReward,
			uint256 pendingReward
		) = sTokenManagerInstance.positions(_tokenId);
		/**
		 * Gets the withdrawable amount.
		 */
		(
			uint256 withdrawable,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount(
				property,
				amount,
				price,
				pendingReward
			);
		/**
		 * Saves variables that should change due to the addition of staking.
		 */
		updateValues(true, property, _amount, prices);
		/**
		 * transfer dev tokens
		 */
		require(
			IERC20(config().token()).transferFrom(
				msg.sender,
				property,
				_amount
			),
			"dev transfer failed"
		);
		/**
		 * update position information
		 */
		bool result = sTokenManagerInstance.update(
			_tokenId,
			amount.add(_amount),
			prices.interest,
			cumulativeReward.add(withdrawable),
			pendingReward.add(withdrawable)
		);
		require(result, "failed to update");
		/**
		 * generate events
		 */
		emit Lockedup(msg.sender, property, _amount);
		return true;
	}

	/**
	 * Adds staking.
	 * Only the Dev contract can execute this function.
	 */
	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external onlyAuthenticatedProperty(_property) {
		/**
		 * Validates the sender is Dev contract.
		 */
		require(msg.sender == config().token(), "this is illegal address");

		/**
		 * Validates _value is not 0.
		 */
		require(_value != 0, "illegal lockup value");

		/**
		 * Since the reward per block that can be withdrawn will change with the addition of staking,
		 * saves the undrawn withdrawable reward before addition it.
		 */
		RewardPrices memory prices = updatePendingInterestWithdrawal(
			_property,
			_from
		);

		/**
		 * Saves variables that should change due to the addition of staking.
		 */
		updateValues4Legacy(true, _from, _property, _value, prices);

		emit Lockedup(_from, _property, _value);
	}

	/**
	 * Withdraw staking.(NFT)
	 * Releases staking, withdraw rewards, and transfer the staked and withdraw rewards amount to the sender.
	 */
	function withdrawByPosition(uint256 _tokenId, uint256 _amount)
		external
		onlyPositionOwner(_tokenId)
		returns (bool)
	{
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		/**
		 * get position information
		 */
		(
			address property,
			uint256 amount,
			uint256 price,
			uint256 cumulativeReward,
			uint256 pendingReward
		) = sTokenManagerInstance.positions(_tokenId);
		/**
		 * If the balance of the withdrawal request is bigger than the balance you are staking
		 */
		require(amount >= _amount, "insufficient tokens staked");
		/**
		 * Withdraws the staking reward
		 */
		(uint256 value, RewardPrices memory prices) = _withdrawInterest(
			property,
			amount,
			price,
			pendingReward
		);
		/**
		 * Transfer the staked amount to the sender.
		 */
		if (_amount != 0) {
			IProperty(property).withdraw(msg.sender, _amount);
		}
		/**
		 * Saves variables that should change due to the canceling staking..
		 */
		updateValues(false, property, _amount, prices);
		uint256 cumulative = cumulativeReward.add(value);
		/**
		 * update position information
		 */
		return
			sTokenManagerInstance.update(
				_tokenId,
				amount.sub(_amount),
				prices.interest,
				cumulative,
				0
			);
	}

	/**
	 * Withdraw staking.
	 * Releases staking, withdraw rewards, and transfer the staked and withdraw rewards amount to the sender.
	 */
	function withdraw(address _property, uint256 _amount) external {
		/**
		 * Validates the sender is staking to the target Property.
		 */
		require(
			hasValue(_property, msg.sender, _amount),
			"insufficient tokens staked"
		);

		/**
		 * Withdraws the staking reward
		 */
		RewardPrices memory prices = _withdrawInterest4Legacy(_property);

		/**
		 * Transfer the staked amount to the sender.
		 */
		if (_amount != 0) {
			IProperty(_property).withdraw(msg.sender, _amount);
		}

		/**
		 * Saves variables that should change due to the canceling staking..
		 */
		updateValues4Legacy(false, msg.sender, _property, _amount, prices);
	}

	/**
	 * get cap
	 */
	function cap() external view returns (uint256) {
		return getStorageCap();
	}

	/**
	 * set cap
	 */
	function updateCap(uint256 _cap) external {
		address setter = IPolicy(config().policy()).capSetter();
		require(setter == msg.sender, "illegal access");

		/**
		 * Updates cumulative amount of the holders reward cap
		 */
		(
			,
			uint256 holdersPrice,
			,
			uint256 cCap
		) = calculateCumulativeRewardPrices();

		// TODO: When this function is improved to be called on-chain, the source of `getStorageLastCumulativeHoldersPriceCap` can be rewritten to `getStorageLastCumulativeHoldersRewardPrice`.
		setStorageCumulativeHoldersRewardCap(cCap);
		setStorageLastCumulativeHoldersPriceCap(holdersPrice);
		setStorageCap(_cap);
		emit UpdateCap(_cap);
	}

	/**
	 * Returns the latest cap
	 */
	function _calculateLatestCap(uint256 _holdersPrice)
		private
		view
		returns (uint256)
	{
		uint256 cCap = getStorageCumulativeHoldersRewardCap();
		uint256 lastHoldersPrice = getStorageLastCumulativeHoldersPriceCap();
		uint256 additionalCap = _holdersPrice.sub(lastHoldersPrice).mul(
			getStorageCap()
		);
		return cCap.add(additionalCap);
	}

	/**
	 * Store staking states as a snapshot.
	 */
	function beforeStakesChanged(address _property, RewardPrices memory _prices)
		private
	{
		/**
		 * Gets latest cumulative holders reward for the passed Property.
		 */
		uint256 cHoldersReward = _calculateCumulativeHoldersRewardAmount(
			_prices.holders,
			_property
		);

		/**
		 * Sets `InitialCumulativeHoldersRewardCap`.
		 * Records this value only when the "first staking to the passed Property" is transacted.
		 */
		if (
			getStorageLastCumulativeHoldersRewardPricePerProperty(_property) ==
			0 &&
			getStorageInitialCumulativeHoldersRewardCap(_property) == 0 &&
			getStoragePropertyValue(_property) == 0
		) {
			setStorageInitialCumulativeHoldersRewardCap(
				_property,
				_prices.holdersCap
			);
		}

		/**
		 * Store each value.
		 */
		setStorageLastStakesChangedCumulativeReward(_prices.reward);
		setStorageLastCumulativeHoldersRewardPrice(_prices.holders);
		setStorageLastCumulativeInterestPrice(_prices.interest);
		setStorageLastCumulativeHoldersRewardAmountPerProperty(
			_property,
			cHoldersReward
		);
		setStorageLastCumulativeHoldersRewardPricePerProperty(
			_property,
			_prices.holders
		);
		setStorageCumulativeHoldersRewardCap(_prices.holdersCap);
		setStorageLastCumulativeHoldersPriceCap(_prices.holders);
	}

	/**
	 * Gets latest value of cumulative sum of the reward amount, cumulative sum of the holders reward per stake, and cumulative sum of the stakers reward per stake.
	 */
	function calculateCumulativeRewardPrices()
		public
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest,
			uint256 _holdersCap
		)
	{
		uint256 lastReward = getStorageLastStakesChangedCumulativeReward();
		uint256 lastHoldersPrice = getStorageLastCumulativeHoldersRewardPrice();
		uint256 lastInterestPrice = getStorageLastCumulativeInterestPrice();
		uint256 allStakes = getStorageAllValue();

		/**
		 * Gets latest cumulative sum of the reward amount.
		 */
		(uint256 reward, ) = dry();
		uint256 mReward = reward.mulBasis();

		/**
		 * Calculates reward unit price per staking.
		 * Later, the last cumulative sum of the reward amount is subtracted because to add the last recorded holder/staking reward.
		 */
		uint256 price = allStakes > 0
			? mReward.sub(lastReward).div(allStakes)
			: 0;

		/**
		 * Calculates the holders reward out of the total reward amount.
		 */
		uint256 holdersShare = IPolicy(config().policy()).holdersShare(
			price,
			allStakes
		);

		/**
		 * Calculates and returns each reward.
		 */
		uint256 holdersPrice = holdersShare.add(lastHoldersPrice);
		uint256 interestPrice = price.sub(holdersShare).add(lastInterestPrice);
		uint256 cCap = _calculateLatestCap(holdersPrice);
		return (mReward, holdersPrice, interestPrice, cCap);
	}

	/**
	 * Calculates cumulative sum of the holders reward per Property.
	 * To save computing resources, it receives the latest holder rewards from a caller.
	 */
	function _calculateCumulativeHoldersRewardAmount(
		uint256 _holdersPrice,
		address _property
	) private view returns (uint256) {
		(uint256 cHoldersReward, uint256 lastReward) = (
			getStorageLastCumulativeHoldersRewardAmountPerProperty(_property),
			getStorageLastCumulativeHoldersRewardPricePerProperty(_property)
		);

		/**
		 * `cHoldersReward` contains the calculation of `lastReward`, so subtract it here.
		 */
		uint256 additionalHoldersReward = _holdersPrice.sub(lastReward).mul(
			getStoragePropertyValue(_property)
		);

		/**
		 * Calculates and returns the cumulative sum of the holder reward by adds the last recorded holder reward and the latest holder reward.
		 */
		return cHoldersReward.add(additionalHoldersReward);
	}

	/**
	 * Calculates cumulative sum of the holders reward per Property.
	 * caution!!!this function is deprecated!!!
	 * use calculateRewardAmount
	 */
	function calculateCumulativeHoldersRewardAmount(address _property)
		external
		view
		returns (uint256)
	{
		(, uint256 holders, , ) = calculateCumulativeRewardPrices();
		return _calculateCumulativeHoldersRewardAmount(holders, _property);
	}

	/**
	 * Calculates holders reward and cap per Property.
	 */
	function calculateRewardAmount(address _property)
		external
		view
		returns (uint256, uint256)
	{
		(
			,
			uint256 holders,
			,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();
		uint256 initialCap = _getInitialCap(_property);

		/**
		 * Calculates the cap
		 */
		uint256 capValue = holdersCap.sub(initialCap);
		return (
			_calculateCumulativeHoldersRewardAmount(holders, _property),
			capValue
		);
	}

	function _getInitialCap(address _property) private view returns (uint256) {
		uint256 initialCap = getStorageInitialCumulativeHoldersRewardCap(
			_property
		);
		if (initialCap > 0) {
			return initialCap;
		}

		// Fallback when there is a data past staked.
		if (
			getStorageLastCumulativeHoldersRewardPricePerProperty(_property) >
			0 ||
			getStoragePropertyValue(_property) > 0
		) {
			return getStorageFallbackInitialCumulativeHoldersRewardCap();
		}
		return 0;
	}

	/**
	 * Updates cumulative sum of the maximum mint amount calculated by Allocator contract, the latest maximum mint amount per block,
	 * and the last recorded block number.
	 * The cumulative sum of the maximum mint amount is always added.
	 * By recording that value when the staker last stakes, the difference from the when the staker stakes can be calculated.
	 */
	function update() public {
		/**
		 * Gets the cumulative sum of the maximum mint amount and the maximum mint number per block.
		 */
		(uint256 _nextRewards, uint256 _amount) = dry();

		/**
		 * Records each value and the latest block number.
		 */
		setStorageCumulativeGlobalRewards(_nextRewards);
		setStorageLastSameRewardsAmountAndBlock(_amount, block.number);
	}

	/**
	 * Referring to the values recorded in each storage to returns the latest cumulative sum of the maximum mint amount and the latest maximum mint amount per block.
	 */
	function dry()
		private
		view
		returns (uint256 _nextRewards, uint256 _amount)
	{
		/**
		 * Gets the latest mint amount per block from Allocator contract.
		 */
		uint256 rewardsAmount = IAllocator(config().allocator())
			.calculateMaxRewardsPerBlock();

		/**
		 * Gets the maximum mint amount per block, and the last recorded block number from `LastSameRewardsAmountAndBlock` storage.
		 */
		(
			uint256 lastAmount,
			uint256 lastBlock
		) = getStorageLastSameRewardsAmountAndBlock();

		/**
		 * If the recorded maximum mint amount per block and the result of the Allocator contract are different,
		 * the result of the Allocator contract takes precedence as a maximum mint amount per block.
		 */
		uint256 lastMaxRewards = lastAmount == rewardsAmount
			? rewardsAmount
			: lastAmount;

		/**
		 * Calculates the difference between the latest block number and the last recorded block number.
		 */
		uint256 blocks = lastBlock > 0 ? block.number.sub(lastBlock) : 0;

		/**
		 * Adds the calculated new cumulative maximum mint amount to the recorded cumulative maximum mint amount.
		 */
		uint256 additionalRewards = lastMaxRewards.mul(blocks);
		uint256 nextRewards = getStorageCumulativeGlobalRewards().add(
			additionalRewards
		);

		/**
		 * Returns the latest theoretical cumulative sum of maximum mint amount and maximum mint amount per block.
		 */
		return (nextRewards, rewardsAmount);
	}

	/**
	 * Returns the staker reward as interest.
	 */
	function _calculateInterestAmount(uint256 _amount, uint256 _price)
		private
		view
		returns (
			uint256 amount_,
			uint256 interestPrice_,
			RewardPrices memory prices_
		)
	{
		/**
		 * Gets the latest cumulative sum of the interest price.
		 */
		(
			uint256 reward,
			uint256 holders,
			uint256 interest,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();

		/**
		 * Calculates and returns the latest withdrawable reward amount from the difference.
		 */
		uint256 result = interest >= _price
			? interest.sub(_price).mul(_amount).divBasis()
			: 0;
		return (
			result,
			interest,
			RewardPrices(reward, holders, interest, holdersCap)
		);
	}

	/**
	 * Returns the staker reward as interest.
	 */
	function _calculateInterestAmount4Legacy(address _property, address _user)
		private
		view
		returns (
			uint256 _amount,
			uint256 _interestPrice,
			RewardPrices memory _prices
		)
	{
		/**
		 * Get the amount the user is staking for the Property.
		 */
		uint256 lockedUpPerAccount = getStorageValue(_property, _user);

		/**
		 * Gets the cumulative sum of the interest price recorded the last time you withdrew.
		 */
		uint256 lastInterest = getStorageLastStakedInterestPrice(
			_property,
			_user
		);

		/**
		 * Gets the latest cumulative sum of the interest price.
		 */
		(
			uint256 reward,
			uint256 holders,
			uint256 interest,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();

		/**
		 * Calculates and returns the latest withdrawable reward amount from the difference.
		 */
		uint256 result = interest >= lastInterest
			? interest.sub(lastInterest).mul(lockedUpPerAccount).divBasis()
			: 0;
		return (
			result,
			interest,
			RewardPrices(reward, holders, interest, holdersCap)
		);
	}

	/**
	 * Returns the total rewards currently available for withdrawal. (For calling from inside the contract)
	 */
	function _calculateWithdrawableInterestAmount(
		address _property,
		uint256 _amount,
		uint256 _price,
		uint256 _pendingReward
	) private view returns (uint256 amount_, RewardPrices memory prices_) {
		/**
		 * If the passed Property has not authenticated, returns always 0.
		 */
		if (
			IMetricsGroup(config().metricsGroup()).hasAssets(_property) == false
		) {
			return (0, RewardPrices(0, 0, 0, 0));
		}

		/**
		 * Gets the latest withdrawal reward amount.
		 */
		(
			uint256 amount,
			,
			RewardPrices memory prices
		) = _calculateInterestAmount(_amount, _price);

		/**
		 * Returns the sum of all values.
		 */
		uint256 withdrawableAmount = amount.add(_pendingReward);
		return (withdrawableAmount, prices);
	}

	/**
	 * Returns the total rewards currently available for withdrawal. (For calling from inside the contract)
	 */
	function _calculateWithdrawableInterestAmount4Legacy(
		address _property,
		address _user
	) private view returns (uint256 _amount, RewardPrices memory _prices) {
		/**
		 * If the passed Property has not authenticated, returns always 0.
		 */
		if (
			IMetricsGroup(config().metricsGroup()).hasAssets(_property) == false
		) {
			return (0, RewardPrices(0, 0, 0, 0));
		}

		/**
		 * Gets the reward amount in saved without withdrawal.
		 */
		uint256 pending = getStoragePendingInterestWithdrawal(_property, _user);

		/**
		 * Gets the reward amount of before DIP4.
		 */
		uint256 legacy = __legacyWithdrawableInterestAmount(_property, _user);

		/**
		 * Gets the latest withdrawal reward amount.
		 */
		(
			uint256 amount,
			,
			RewardPrices memory prices
		) = _calculateInterestAmount4Legacy(_property, _user);

		/**
		 * Returns the sum of all values.
		 */
		uint256 withdrawableAmount = amount.add(pending).add(legacy);
		return (withdrawableAmount, prices);
	}

	/**
	 * Returns the total rewards currently available for withdrawal. (For calling from external of the contract)
	 */
	function calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) external view returns (uint256) {
		(uint256 amount, ) = _calculateWithdrawableInterestAmount4Legacy(
			_property,
			_user
		);
		return amount;
	}

	/**
	 * Returns the total rewards currently available for withdrawal. (For calling from external of the contract)
	 */
	function calculateWithdrawableInterestAmountByPosition(uint256 _tokenId)
		external
		view
		returns (uint256)
	{
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		(
			address property,
			uint256 amount,
			uint256 price,
			,
			uint256 pendingReward
		) = sTokenManagerInstance.positions(_tokenId);
		(uint256 result, ) = _calculateWithdrawableInterestAmount(
			property,
			amount,
			price,
			pendingReward
		);
		return result;
	}

	/**
	 * Withdraws staking reward as an interest.
	 */
	function _withdrawInterest(
		address _property,
		uint256 _amount,
		uint256 _price,
		uint256 _pendingReward
	) private returns (uint256 value_, RewardPrices memory prices_) {
		/**
		 * Gets the withdrawable amount.
		 */
		(
			uint256 value,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount(
				_property,
				_amount,
				_price,
				_pendingReward
			);

		/**
		 * Mints the reward.
		 */
		require(
			IDevMinter(devMinter).mint(msg.sender, value),
			"dev mint failed"
		);

		/**
		 * Since the total supply of tokens has changed, updates the latest maximum mint amount.
		 */
		update();

		return (value, prices);
	}

	/**
	 * Withdraws staking reward as an interest.
	 */
	function _withdrawInterest4Legacy(address _property)
		private
		returns (RewardPrices memory _prices)
	{
		/**
		 * Gets the withdrawable amount.
		 */
		(
			uint256 value,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount4Legacy(_property, msg.sender);

		/**
		 * Sets the unwithdrawn reward amount to 0.
		 */
		setStoragePendingInterestWithdrawal(_property, msg.sender, 0);

		/**
		 * Updates the staking status to avoid double rewards.
		 */
		setStorageLastStakedInterestPrice(
			_property,
			msg.sender,
			prices.interest
		);
		__updateLegacyWithdrawableInterestAmount(_property, msg.sender);

		/**
		 * Mints the reward.
		 */
		require(
			IDevMinter(devMinter).mint(msg.sender, value),
			"dev mint failed"
		);

		/**
		 * Since the total supply of tokens has changed, updates the latest maximum mint amount.
		 */
		update();

		return prices;
	}

	/**
	 * Status updates with the addition or release of staking.
	 */
	function updateValues4Legacy(
		bool _addition,
		address _account,
		address _property,
		uint256 _value,
		RewardPrices memory _prices
	) private {
		/**
		 * Updates the staking status to avoid double rewards.
		 */
		setStorageLastStakedInterestPrice(
			_property,
			_account,
			_prices.interest
		);
		updateValues(_addition, _property, _value, _prices);
		/**
		 * Updates the staking value of property by user
		 */
		if (_addition) {
			addValue(_property, _account, _value);
		} else {
			subValue(_property, _account, _value);
		}
	}

	/**
	 * Status updates with the addition or release of staking.
	 */
	function updateValues(
		bool _addition,
		address _property,
		uint256 _value,
		RewardPrices memory _prices
	) private {
		beforeStakesChanged(_property, _prices);
		/**
		 * If added staking:
		 */
		if (_addition) {
			/**
			 * Updates the current staking amount of the protocol total.
			 */
			addAllValue(_value);

			/**
			 * Updates the current staking amount of the Property.
			 */
			addPropertyValue(_property, _value);
			/**
			 * If released staking:
			 */
		} else {
			/**
			 * Updates the current staking amount of the protocol total.
			 */
			subAllValue(_value);

			/**
			 * Updates the current staking amount of the Property.
			 */
			subPropertyValue(_property, _value);
		}

		/**
		 * Since each staking amount has changed, updates the latest maximum mint amount.
		 */
		update();
	}

	/**
	 * Returns the staking amount of the protocol total.
	 */
	function getAllValue() external view returns (uint256) {
		return getStorageAllValue();
	}

	/**
	 * Adds the staking amount of the protocol total.
	 */
	function addAllValue(uint256 _value) private {
		uint256 value = getStorageAllValue();
		value = value.add(_value);
		setStorageAllValue(value);
	}

	/**
	 * Subtracts the staking amount of the protocol total.
	 */
	function subAllValue(uint256 _value) private {
		uint256 value = getStorageAllValue();
		value = value.sub(_value);
		setStorageAllValue(value);
	}

	/**
	 * Returns the user's staking amount in the Property.
	 */
	function getValue(address _property, address _sender)
		external
		view
		returns (uint256)
	{
		return getStorageValue(_property, _sender);
	}

	/**
	 * Adds the user's staking amount in the Property.
	 */
	function addValue(
		address _property,
		address _sender,
		uint256 _value
	) private {
		uint256 value = getStorageValue(_property, _sender);
		value = value.add(_value);
		setStorageValue(_property, _sender, value);
	}

	/**
	 * Subtracts the user's staking amount in the Property.
	 */
	function subValue(
		address _property,
		address _sender,
		uint256 _value
	) private {
		uint256 value = getStorageValue(_property, _sender);
		value = value.sub(_value);
		setStorageValue(_property, _sender, value);
	}

	/**
	 * Returns whether the user is staking in the Property.
	 */
	function hasValue(
		address _property,
		address _sender,
		uint256 _amount
	) private view returns (bool) {
		uint256 value = getStorageValue(_property, _sender);
		return value >= _amount;
	}

	/**
	 * Returns the staking amount of the Property.
	 */
	function getPropertyValue(address _property)
		external
		view
		returns (uint256)
	{
		return getStoragePropertyValue(_property);
	}

	/**
	 * Adds the staking amount of the Property.
	 */
	function addPropertyValue(address _property, uint256 _value) private {
		uint256 value = getStoragePropertyValue(_property);
		value = value.add(_value);
		setStoragePropertyValue(_property, value);
	}

	/**
	 * Subtracts the staking amount of the Property.
	 */
	function subPropertyValue(address _property, uint256 _value) private {
		uint256 value = getStoragePropertyValue(_property);
		uint256 nextValue = value.sub(_value);
		setStoragePropertyValue(_property, nextValue);
	}

	/**
	 * Saves the latest reward amount as an undrawn amount.
	 */
	function updatePendingInterestWithdrawal(address _property, address _user)
		private
		returns (RewardPrices memory _prices)
	{
		/**
		 * Gets the latest reward amount.
		 */
		(
			uint256 withdrawableAmount,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount4Legacy(_property, _user);

		/**
		 * Saves the amount to `PendingInterestWithdrawal` storage.
		 */
		setStoragePendingInterestWithdrawal(
			_property,
			_user,
			withdrawableAmount
		);

		/**
		 * Updates the reward amount of before DIP4 to prevent further addition it.
		 */
		__updateLegacyWithdrawableInterestAmount(_property, _user);

		return prices;
	}

	/**
	 * Returns the reward amount of the calculation model before DIP4.
	 * It can be calculated by subtracting "the last cumulative sum of reward unit price" from
	 * "the current cumulative sum of reward unit price," and multiplying by the staking amount.
	 */
	function __legacyWithdrawableInterestAmount(
		address _property,
		address _user
	) private view returns (uint256) {
		uint256 _last = getStorageLastInterestPrice(_property, _user);
		uint256 price = getStorageInterestPrice(_property);
		uint256 priceGap = price.sub(_last);
		uint256 lockedUpValue = getStorageValue(_property, _user);
		uint256 value = priceGap.mul(lockedUpValue);
		return value.divBasis();
	}

	/**
	 * Updates and treats the reward of before DIP4 as already received.
	 */
	function __updateLegacyWithdrawableInterestAmount(
		address _property,
		address _user
	) private {
		uint256 interestPrice = getStorageInterestPrice(_property);
		if (getStorageLastInterestPrice(_property, _user) != interestPrice) {
			setStorageLastInterestPrice(_property, _user, interestPrice);
		}
	}

	function ___setFallbackInitialCumulativeHoldersRewardCap(uint256 _value)
		external
		onlyOwner
	{
		setStorageFallbackInitialCumulativeHoldersRewardCap(_value);
	}

	/**
	 * migration to nft
	 */
	function migrateToSTokens(address _property)
		external
		returns (uint256 tokenId_)
	{
		/**
		 * Get the amount the user is staking for the Property.
		 */
		uint256 amount = getStorageValue(_property, msg.sender);
		require(amount > 0, "not staked");
		/**
		 * Gets the cumulative sum of the interest price recorded the last time you withdrew.
		 */
		uint256 price = getStorageLastStakedInterestPrice(
			_property,
			msg.sender
		);
		/**
		 * Gets the reward amount in saved without withdrawal.
		 */
		uint256 pending = getStoragePendingInterestWithdrawal(
			_property,
			msg.sender
		);
		/**
		 * Sets the unwithdrawn reward amount to 0.
		 */
		setStoragePendingInterestWithdrawal(_property, msg.sender, 0);
		/**
		 * The amount of the user's investment in the property is set to zero.
		 */
		setStorageValue(_property, msg.sender, 0);
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		/**
		 * mint nft
		 */
		uint256 tokenId = sTokenManagerInstance.mint(
			msg.sender,
			_property,
			amount,
			price
		);
		/**
		 * update position information
		 */
		bool result = sTokenManagerInstance.update(
			tokenId,
			amount,
			price,
			0,
			pending
		);
		require(result, "failed to update");
		return tokenId;
	}
}