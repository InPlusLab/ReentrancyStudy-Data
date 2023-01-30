/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


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

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

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
contract Context is Initializable {
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

// File: @openzeppelin/contracts-ethereum-package/contracts/introspection/IERC165.sol

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

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is Initializable, IERC165 {
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

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/IERC721Receiver.sol

pragma solidity ^0.5.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/drafts/Counters.sol

pragma solidity ^0.5.0;


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/introspection/ERC165.sol

pragma solidity ^0.5.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is Initializable, IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    function initialize() public initializer {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721.sol

pragma solidity ^0.5.0;









/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Initializable, Context, ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    function initialize() public initializer {
        ERC165.initialize();

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function _hasBeenInitialized() internal view returns (bool) {
        return supportsInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {_burn} instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This is an internal detail of the `ERC721` contract and its use is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/IERC721Enumerable.sol

pragma solidity ^0.5.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Enumerable is Initializable, IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Enumerable.sol

pragma solidity ^0.5.0;






/**
 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721Enumerable is Initializable, Context, ERC165, ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Constructor function.
     */
    function initialize() public initializer {
        require(ERC721._hasBeenInitialized());
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function _hasBeenInitialized() internal view returns (bool) {
        return supportsInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens.
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {ERC721-_burn} instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/IERC721Metadata.sol

pragma solidity ^0.5.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Metadata is Initializable, IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Metadata.sol

pragma solidity ^0.5.0;






contract ERC721Metadata is Initializable, Context, ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    function initialize(string memory name, string memory symbol) public initializer {
        require(ERC721._hasBeenInitialized());

        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function _hasBeenInitialized() internal view returns (bool) {
        return supportsInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the URI for a given token ID. May return an empty string.
     *
     * If the token's URI is non-empty and a base URI was set (via
     * {_setBaseURI}), it will be added to the token ID's URI as a prefix.
     *
     * Reverts if the token ID does not exist.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // Even if there is a base URI, it is only appended to non-empty token-specific URIs
        if (bytes(_tokenURI).length == 0) {
            return "";
        } else {
            // abi.encodePacked is being used to concatenate strings
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     *
     * Reverts if the token ID does not exist.
     *
     * TIP: if all token IDs share a prefix (e.g. if your URIs look like
     * `http://api.myproject.com/token/<id>`), use {_setBaseURI} to store
     * it and save gas.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI}.
     *
     * _Available since v2.5.0._
     */
    function _setBaseURI(string memory baseURI) internal {
        _baseURI = baseURI;
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a preffix in {tokenURI} to each token's URI, when
    * they are non-empty.
    *
    * _Available since v2.5.0._
    */
    function baseURI() external view returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    uint256[49] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;




contract MinterRole is Initializable, Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {
        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721MetadataMintable.sol

pragma solidity ^0.5.0;





/**
 * @title ERC721MetadataMintable
 * @dev ERC721 minting logic with metadata.
 */
contract ERC721MetadataMintable is Initializable, ERC721, ERC721Metadata, MinterRole {
    function initialize(address sender) public initializer {
        require(ERC721._hasBeenInitialized());
        require(ERC721Metadata._hasBeenInitialized());
        MinterRole.initialize(sender);
    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenURI The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }

    uint256[50] private ______gap;
}

// File: contracts/ERC721Patronage_v1.sol

pragma solidity 0.5.17;






// import "./WildcardSteward_v1.sol";
contract ERC721Patronage_v1 is
    Initializable,
    ERC721,
    ERC721Enumerable,
    ERC721Metadata,
    ERC721MetadataMintable
{
    address public steward;

    function setup(
        address _steward,
        string memory name,
        string memory symbol,
        address minter
    ) public initializer {
        steward = _steward;
        ERC721.initialize();
        ERC721Enumerable.initialize();
        ERC721Metadata.initialize(name, symbol);
        // Initialize the minter and pauser roles, and renounce them
        ERC721MetadataMintable.initialize(address(this));
        _removeMinter(address(this));
        _addMinter(minter);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return (spender == steward);
        /*
          // NOTE: temporarily disabling sending of the tokens independently. A protective messure since it isn't clear to users how this function should work.
          //       Will re-add once a mechanism is agreed on by the community.
          || ERC721._isApprovedOrOwner(spender, tokenId)
          */
    }

    // function transferFrom(address from, address to, uint256 tokenId) public {
    //     if (msg.sender != steward) {
    //         WildcardSteward_v1 stewardContract = WildcardSteward_v1(steward);

    //         // Calculate remaining deposit for the two addresses involved in transfer.
    //         stewardContract._collectPatronagePatron(to);
    //         stewardContract._collectPatronage(tokenId);

    //         // Do not allow someone to transfer a token if their deposit is Zero.
    //         require(stewardContract.deposit(to) > 0, "Recipient needs to have a deposit.");
    //         require(stewardContract.deposit(from) > 0, "Sender deposit has run out.");
    //     }

    //     ERC721.transferFrom(from, to, tokenId);
    // }
}

// File: contracts/interfaces/IERC20Mintable.sol

pragma solidity ^0.5.0;

contract IERC20Mintable {
    function mint(address account, uint256 amount) public returns (bool);
}

// File: contracts/MintManager_v2.sol

pragma solidity 0.5.17;




contract MintManager_v2 is Initializable {
    using SafeMath for uint256;

    address public admin;
    address public steward;
    IERC20Mintable public token;

    modifier onlySteward() {
        require(msg.sender == steward, "Not steward");
        _;
    }

    function initialize(
        address _admin,
        address _steward,
        address _token
    ) public initializer {
        admin = _admin;
        steward = _steward;
        token = IERC20Mintable(_token);
    }

    function tokenMint(
        address receiverOfTokens,
        uint256 time,
        uint256 mintRate
    ) external onlySteward {
        uint256 amountToMintForUser = time.mul(mintRate);
        uint256 amountToMintForTreasury = amountToMintForUser.mul(20).div(100);
        token.mint(receiverOfTokens, amountToMintForUser);
        token.mint(admin, amountToMintForTreasury);
    }
}

// File: contracts/WildcardSteward_v3.sol

pragma solidity 0.5.17;


contract WildcardSteward_v3 is Initializable {
    /*
    This smart contract collects patronage from current owner through a Harberger tax model and 
    takes stewardship of the asset token if the patron can't pay anymore.

    Harberger Tax (COST): 
    - Asset is always on sale.
    - You have to have a price set.
    - Tax (Patronage) is paid to maintain ownership.
    - Steward maints control over ERC721.
    */
    using SafeMath for uint256;
    mapping(uint256 => uint256) public price; //in wei
    ERC721Patronage_v1 public assetToken; // ERC721 NFT.

    mapping(uint256 => uint256) deprecated_totalCollected; // THIS VALUE IS DEPRECATED
    mapping(uint256 => uint256) deprecated_currentCollected; // THIS VALUE IS DEPRECATED
    mapping(uint256 => uint256) deprecated_timeLastCollected; // THIS VALUE IS DEPRECATED.
    mapping(address => uint256) public timeLastCollectedPatron;
    mapping(address => uint256) public deposit;
    mapping(address => uint256) public totalPatronOwnedTokenCost;

    mapping(uint256 => address) public benefactors; // non-profit benefactor
    mapping(address => uint256) public benefactorFunds;

    mapping(uint256 => address) deprecated_currentPatron; // Deprecate This is different to the current token owner.
    mapping(uint256 => mapping(address => bool)) deprecated_patrons; // Deprecate
    mapping(uint256 => mapping(address => uint256)) deprecated_timeHeld; // Deprecate

    mapping(uint256 => uint256) deprecated_timeAcquired; // deprecate

    // 1200% patronage
    mapping(uint256 => uint256) public patronageNumerator;
    uint256 public patronageDenominator;

    enum StewardState {Foreclosed, Owned}
    mapping(uint256 => StewardState) public state;

    address public admin;

    //////////////// NEW variables in v2///////////////////
    mapping(uint256 => uint256) deprecated_tokenGenerationRate; // we can reuse the patronage denominator

    MintManager_v2 public mintManager;
    //////////////// NEW variables in v3 ///////////////////
    uint256 public auctionStartPrice;
    uint256 public auctionEndPrice;
    uint256 public auctionLength;

    mapping(uint256 => address) public artistAddresses; //mapping from tokenID to the artists address
    mapping(uint256 => uint256) public wildcardsPercentages; // mapping from tokenID to the percentage sale cut of wildcards for each token
    mapping(uint256 => uint256) public artistPercentages; // tokenId to artist percetages. To make it configurable. 10 000 = 100%
    mapping(uint256 => uint256) public tokenAuctionBeginTimestamp;

    mapping(address => uint256) public totalPatronTokenGenerationRate; // The total token generation rate for all the tokens of the given address.
    mapping(address => uint256) public totalBenefactorTokenNumerator;
    mapping(address => uint256) public timeLastCollectedBenefactor; // make my name consistent please
    mapping(address => uint256) public benefactorCredit;
    address public withdrawCheckerAdmin;

    /*
    31536000 seconds = 365 days

    divisor = 365 days * 1000000000000
            = 31536000000000000000
    */

    // 11574074074074 = 10^18 / 86400 This is just less (rounded down) than one token a day.
    //       - this can be done since all tokens have the exact same tokenGenerationRate - and hardcoding saves gas.
    uint256 public constant globalTokenGenerationRate = 11574074074074;
    uint256 public constant yearTimePatronagDenominator = 31536000000000000000;

    event Buy(uint256 indexed tokenId, address indexed owner, uint256 price);
    event PriceChange(uint256 indexed tokenId, uint256 newPrice);
    event Foreclosure(address indexed prevOwner, uint256 foreclosureTime);
    event RemainingDepositUpdate(
        address indexed tokenPatron,
        uint256 remainingDeposit
    );

    event AddTokenV3(
        uint256 indexed tokenId,
        uint256 patronageNumerator,
        uint256 unixTimestampOfTokenAuctionStart
    );

    // QUESTION: in future versions, should these two events (CollectPatronage and CollectLoyalty) be combined into one? - they only ever happen at the same time.
    // NOTE: this event is deprecated - it is only here for the upgrade function.
    event CollectPatronage(
        uint256 indexed tokenId,
        address indexed patron,
        uint256 remainingDeposit,
        uint256 amountReceived
    );
    event CollectLoyalty(address indexed patron, uint256 amountRecieved);

    event ArtistCommission(
        uint256 indexed tokenId,
        address artist,
        uint256 artistCommission
    );
    event WithdrawBenefactorFundsWithSafetyDelay(
        address indexed benefactor,
        uint256 withdrawAmount
    );
    event WithdrawBenefactorFunds(
        address indexed benefactor,
        uint256 withdrawAmount
    );
    event UpgradeToV3();
    event ChangeAuctionParameters();

    modifier onlyPatron(uint256 tokenId) {
        require(msg.sender == assetToken.ownerOf(tokenId), "Not patron");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlyReceivingBenefactorOrAdmin(uint256 tokenId) {
        require(
            msg.sender == benefactors[tokenId] || msg.sender == admin,
            "Not benefactor or admin"
        );
        _;
    }

    modifier collectPatronageAndSettleBenefactor(uint256 tokenId) {
        _collectPatronageAndSettleBenefactor(tokenId);
        _;
    }

    modifier collectPatronagePatron(address tokenPatron) {
        _collectPatronagePatron(tokenPatron);
        _;
    }

    modifier youCurrentlyAreNotInDefault(address tokenPatron) {
        require(
            !(deposit[tokenPatron] == 0 &&
                totalPatronOwnedTokenCost[tokenPatron] > 0),
            "no deposit existing tokens"
        );
        _;
    }

    modifier updateBenefactorBalance(address benefactor) {
        _updateBenefactorBalance(benefactor);
        _;
    }

    modifier priceGreaterThanZero(uint256 _newPrice) {
        require(_newPrice > 0, "Price is zero");
        _;
    }
    modifier notNullAddress(address checkAddress) {
        require(checkAddress != address(0), "null address");
        _;
    }
    modifier notSameAddress(address firstAddress, address secondAddress) {
        require(firstAddress != secondAddress, "cannot be same address");
        _;
    }
    modifier validWildcardsPercentage(
        uint256 wildcardsPercentage,
        uint256 tokenID
    ) {
        require(
            wildcardsPercentage >= 50000 &&
                wildcardsPercentage <= (1000000 - artistPercentages[tokenID]), // not sub safemath. Is this okay?
            "wildcards commision not between 5% and 100%"
        );
        _;
    }

    function initialize(
        address _assetToken,
        address _admin,
        address _mintManager,
        address _withdrawCheckerAdmin,
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) public initializer {
        assetToken = ERC721Patronage_v1(_assetToken);
        admin = _admin;
        withdrawCheckerAdmin = _withdrawCheckerAdmin;
        mintManager = MintManager_v2(_mintManager);
        _changeAuctionParameters(
            _auctionStartPrice,
            _auctionEndPrice,
            _auctionLength
        );
    }

    function uintToStr(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        while (_i != 0) {
            bstr[--len] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function listNewTokens(
        uint256[] memory tokens,
        address payable[] memory _benefactors,
        uint256[] memory _patronageNumerator,
        address[] memory _artists,
        uint256[] memory _artistCommission,
        uint256[] memory _releaseDate
    ) public onlyAdmin {
        assert(tokens.length == _benefactors.length);
        assert(tokens.length == _patronageNumerator.length);
        assert(tokens.length == _releaseDate.length);
        assert(_artists.length == _artistCommission.length);

        for (uint8 i = 0; i < tokens.length; ++i) {
            address benefactor = _benefactors[i];
            require(_benefactors[i] != address(0), "null address");
            string memory idString = uintToStr(tokens[i]);
            string memory tokenUriBase = "https://wildcards.xyz/token/";
            string memory tokenUri = string(
                abi.encodePacked(tokenUriBase, idString)
            );
            assetToken.mintWithTokenURI(address(this), tokens[i], tokenUri);
            benefactors[tokens[i]] = _benefactors[i];
            state[tokens[i]] = StewardState.Foreclosed;
            patronageNumerator[tokens[i]] = _patronageNumerator[i];
            // tokenGenerationRate[tokens[i]] = _tokenGenerationRate[i];

            if (_releaseDate[i] < now) {
                tokenAuctionBeginTimestamp[tokens[i]] = now;
            } else {
                tokenAuctionBeginTimestamp[tokens[i]] = _releaseDate[i];
            }

            emit AddTokenV3(
                tokens[i],
                _patronageNumerator[i],
                tokenAuctionBeginTimestamp[tokens[i]]
            );
            // Adding this after the add token emit, so graph can first capture the token before processing the change artist things
            if (_artists.length > i) {
                changeArtistAddressAndCommission(
                    tokens[i],
                    _artists[i],
                    _artistCommission[i]
                );
            }
        }
    }

    function upgradeToV3(
        uint256[] memory tokens,
        address _withdrawCheckerAdmin,
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) public notNullAddress(_withdrawCheckerAdmin) {
        emit UpgradeToV3();
        // This function effectively needs to call both _collectPatronage and _collectPatronagePatron from the v2 contract.
        require(withdrawCheckerAdmin == address(0));
        withdrawCheckerAdmin = _withdrawCheckerAdmin;
        // For each token
        for (uint8 i = 0; i < tokens.length; ++i) {
            uint256 tokenId = tokens[i];
            address currentOwner = assetToken.ownerOf(tokenId);

            uint256 timeSinceTokenLastCollection = now.sub(
                deprecated_timeLastCollected[tokenId]
            );

            // NOTE: for this upgrade we make sure no tokens are foreclosed, or close to foreclosing
            uint256 collection = price[tokenId]
                .mul(timeSinceTokenLastCollection)
                .mul(patronageNumerator[tokenId])
                .div(yearTimePatronagDenominator);

            // set the timeLastCollectedPatron for that tokens owner to 'now'.
            // timeLastCollected[tokenId] = now; // This variable is depricated, no need to update it.
            if (timeLastCollectedPatron[currentOwner] < now) {
                // set subtract patronage owed for the Patron from their deposit.
                deposit[currentOwner] = deposit[currentOwner].sub(
                    patronageOwedPatron(currentOwner)
                );

                timeLastCollectedPatron[currentOwner] = now;
            }

            // Add the amount collected for current token to the benefactorFunds.
            benefactorFunds[benefactors[tokenId]] = benefactorFunds[benefactors[tokenId]]
                .add(collection);

            // Emit an event for the graph to pickup this action (the last time this event will ever be emited)
            emit CollectPatronage(
                tokenId,
                currentOwner,
                deposit[currentOwner],
                collection
            );

            // mint required loyalty tokens
            mintManager.tokenMint(
                currentOwner,
                timeSinceTokenLastCollection, // this should always be > 0
                globalTokenGenerationRate // instead of this -> tokenGenerationRate[tokenId] hard code to save gas
            );
            emit CollectLoyalty(
                currentOwner,
                timeSinceTokenLastCollection.mul(globalTokenGenerationRate)
            ); // OPTIMIZE ME

            // Add the tokens generation rate to the totalPatronTokenGenerationRate of the current owner
            totalPatronTokenGenerationRate[currentOwner] = totalPatronTokenGenerationRate[currentOwner]
                .add(globalTokenGenerationRate);

            address tokenBenefactor = benefactors[tokenId];
            // add the scaled tokens price to the `totalBenefactorTokenNumerator`
            totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
                .add(price[tokenId].mul(patronageNumerator[tokenId]));

            if (timeLastCollectedBenefactor[tokenBenefactor] == 0) {
                timeLastCollectedBenefactor[tokenBenefactor] = now;
            }
        }
        _changeAuctionParameters(
            _auctionStartPrice,
            _auctionEndPrice,
            _auctionLength
        );
    }

    function changeReceivingBenefactor(
        uint256 tokenId,
        address payable _newReceivingBenefactor
    )
        public
        onlyReceivingBenefactorOrAdmin(tokenId)
        updateBenefactorBalance(benefactors[tokenId])
        updateBenefactorBalance(_newReceivingBenefactor)
        notNullAddress(_newReceivingBenefactor)
    {
        address oldBenfactor = benefactors[tokenId];

        require(
            oldBenfactor != _newReceivingBenefactor,
            "cannot be same address"
        );

        // Collect patronage from old and new benefactor before changing totalBenefactorTokenNumerator on both
        uint256 scaledPrice = price[tokenId].mul(patronageNumerator[tokenId]);
        totalBenefactorTokenNumerator[oldBenfactor] = totalBenefactorTokenNumerator[oldBenfactor]
            .sub(scaledPrice);
        totalBenefactorTokenNumerator[_newReceivingBenefactor] = totalBenefactorTokenNumerator[_newReceivingBenefactor]
            .add(scaledPrice);

        benefactors[tokenId] = _newReceivingBenefactor;
        // NB No fund exchanging here please!
    }

    // NB This function is if an organisation loses their keys etc..
    // It will transfer their deposit to their new benefactor address
    // It should only be called once all their tokens also changeReceivingBenefactor
    function changeReceivingBenefactorDeposit(
        address oldBenfactor,
        address payable _newReceivingBenefactor
    )
        public
        onlyAdmin
        notNullAddress(_newReceivingBenefactor)
        notSameAddress(oldBenfactor, _newReceivingBenefactor)
    {
        require(benefactorFunds[oldBenfactor] > 0, "no funds");

        benefactorFunds[_newReceivingBenefactor] = benefactorFunds[_newReceivingBenefactor]
            .add(benefactorFunds[oldBenfactor]);
        benefactorFunds[oldBenfactor] = 0;
    }

    function changeAdmin(address _admin) public onlyAdmin {
        admin = _admin;
    }

    function changeWithdrawCheckerAdmin(address _withdrawCheckerAdmin)
        public
        onlyAdmin
        notNullAddress(_withdrawCheckerAdmin)
    {
        withdrawCheckerAdmin = _withdrawCheckerAdmin;
    }

    function changeArtistAddressAndCommission(
        uint256 tokenId,
        address artistAddress,
        uint256 percentage
    ) public onlyAdmin {
        require(percentage <= 200000, "not more than 20%");
        artistPercentages[tokenId] = percentage;
        artistAddresses[tokenId] = artistAddress;
        emit ArtistCommission(tokenId, artistAddress, percentage);
    }

    function _changeAuctionParameters(
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) internal {
        require(
            _auctionStartPrice >= _auctionEndPrice,
            "auction start < auction end"
        );
        require(_auctionLength >= 86400, "1 day min auction length");

        auctionStartPrice = _auctionStartPrice;
        auctionEndPrice = _auctionEndPrice;
        auctionLength = _auctionLength;
        emit ChangeAuctionParameters();
    }

    function changeAuctionParameters(
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) external onlyAdmin {
        _changeAuctionParameters(
            _auctionStartPrice,
            _auctionEndPrice,
            _auctionLength
        );
    }

    function patronageOwedPatron(address tokenPatron)
        public
        view
        returns (uint256 patronageDue)
    {
        // NOTE: Leaving this code here as a reminder: totalPatronOwnedTokenCost[tokenPatron] has to be zero if timeLastCollectedPatron[tokenPatron] is zero. So effectively this line isn't needed.
        // if (timeLastCollectedPatron[tokenPatron] == 0) return 0;
        return
            totalPatronOwnedTokenCost[tokenPatron]
                .mul(now.sub(timeLastCollectedPatron[tokenPatron]))
                .div(yearTimePatronagDenominator);
    }

    function patronageDueBenefactor(address benefactor)
        public
        view
        returns (uint256 payoutDue)
    {
        // NOTE: Leaving this code here as a reminder: totalBenefactorTokenNumerator[tokenPatron] has to be zero if timeLastCollectedBenefactor[tokenPatron] is zero. So effectively this line isn't needed.
        // if (timeLastCollectedBenefactor[benefactor] == 0) return 0;
        return
            totalBenefactorTokenNumerator[benefactor]
                .mul(now.sub(timeLastCollectedBenefactor[benefactor]))
                .div(yearTimePatronagDenominator);
    }

    function foreclosedPatron(address tokenPatron) public view returns (bool) {
        if (patronageOwedPatron(tokenPatron) >= deposit[tokenPatron]) {
            return true;
        } else {
            return false;
        }
    }

    function foreclosed(uint256 tokenId) public view returns (bool) {
        address tokenPatron = assetToken.ownerOf(tokenId);
        return foreclosedPatron(tokenPatron);
    }

    function depositAbleToWithdraw(address tokenPatron)
        public
        view
        returns (uint256)
    {
        uint256 collection = patronageOwedPatron(tokenPatron);
        if (collection >= deposit[tokenPatron]) {
            return 0;
        } else {
            return deposit[tokenPatron].sub(collection);
        }
    }

    function foreclosureTimePatron(address tokenPatron)
        public
        view
        returns (uint256)
    {
        uint256 pps = totalPatronOwnedTokenCost[tokenPatron].div(
            yearTimePatronagDenominator
        );
        return now.add(depositAbleToWithdraw(tokenPatron).div(pps));
    }

    function foreclosureTime(uint256 tokenId) public view returns (uint256) {
        address tokenPatron = assetToken.ownerOf(tokenId);
        return foreclosureTimePatron(tokenPatron);
    }

    /* actions */
    function _collectLoyaltyPatron(
        address tokenPatron,
        uint256 timeSinceLastMint
    ) internal {
        if (timeSinceLastMint != 0) {
            mintManager.tokenMint(
                tokenPatron,
                timeSinceLastMint,
                totalPatronTokenGenerationRate[tokenPatron]
            );
            emit CollectLoyalty(
                tokenPatron,
                timeSinceLastMint.mul(
                    totalPatronTokenGenerationRate[tokenPatron]
                )
            );
        }
    }

    // TODO: create a version of this function that only collects patronage (and only settles the benefactor if the token forecloses) - is this needed?

    function _collectPatronageAndSettleBenefactor(uint256 tokenId) public {
        address tokenPatron = assetToken.ownerOf(tokenId);
        uint256 newTimeLastCollectedOnForeclosure = _collectPatronagePatron(
            tokenPatron
        );

        address benefactor = benefactors[tokenId];
        // bool tokenForeclosed = newTimeLastCollectedOnForeclosure > 0;
        bool tokenIsOwned = state[tokenId] == StewardState.Owned;
        if (newTimeLastCollectedOnForeclosure > 0 && tokenIsOwned) {
            tokenAuctionBeginTimestamp[tokenId] =
                // The auction starts the second after the last time collected.
                newTimeLastCollectedOnForeclosure +
                1;


                uint256 patronageDueBenefactorBeforeForeclosure
             = patronageDueBenefactor(benefactor);

            _foreclose(tokenId);

            uint256 amountOverCredited = price[tokenId]
                .mul(now.sub(newTimeLastCollectedOnForeclosure))
                .mul(patronageNumerator[tokenId])
                .div(yearTimePatronagDenominator);

            if (amountOverCredited < patronageDueBenefactorBeforeForeclosure) {
                _increaseBenefactorBalance(
                    benefactor,
                    patronageDueBenefactorBeforeForeclosure - amountOverCredited
                );
            } else {
                _decreaseBenefactorBalance(
                    benefactor,
                    amountOverCredited - patronageDueBenefactorBeforeForeclosure
                );
            }

            timeLastCollectedBenefactor[benefactor] = now;
        } else {
            _updateBenefactorBalance(benefactor);
        }
    }

    function safeSend(uint256 _wei, address payable recipient)
        internal
        returns (bool transferSuccess)
    {
        (transferSuccess, ) = recipient.call.gas(2300).value(_wei)("");
    }

    // if credit balance exists,
    // if amount owed > creidt
    // credit zero add amount
    // else reduce credit by certain amount.
    // else if credit balance doesn't exist
    // add amount to balance

    function _updateBenefactorBalance(address benefactor) public {
        uint256 patronageDueBenefactor = patronageDueBenefactor(benefactor);

        if (patronageDueBenefactor > 0) {
            _increaseBenefactorBalance(benefactor, patronageDueBenefactor);
        }

        timeLastCollectedBenefactor[benefactor] = now;
    }

    function _increaseBenefactorBalance(
        address benefactor,
        uint256 patronageDueBenefactor
    ) internal {
        if (benefactorCredit[benefactor] > 0) {
            if (patronageDueBenefactor < benefactorCredit[benefactor]) {
                benefactorCredit[benefactor] = benefactorCredit[benefactor].sub(
                    patronageDueBenefactor
                );
            } else {
                benefactorFunds[benefactor] = patronageDueBenefactor.sub(
                    benefactorCredit[benefactor]
                );
                benefactorCredit[benefactor] = 0;
            }
        } else {
            benefactorFunds[benefactor] = benefactorFunds[benefactor].add(
                patronageDueBenefactor
            );
        }
    }

    function _decreaseBenefactorBalance(
        address benefactor,
        uint256 amountOverCredited
    ) internal {
        if (benefactorFunds[benefactor] > 0) {
            if (amountOverCredited <= benefactorFunds[benefactor]) {
                benefactorFunds[benefactor] = benefactorFunds[benefactor].sub(
                    amountOverCredited
                );
            } else {
                benefactorCredit[benefactor] = amountOverCredited.sub(
                    benefactorFunds[benefactor]
                );
                benefactorFunds[benefactor] = 0;
            }
        } else {
            benefactorCredit[benefactor] = benefactorCredit[benefactor].add(
                amountOverCredited
            );
        }
    }

    function fundsDueForAuctionPeriodAtCurrentRate(address benefactor)
        internal
        view
        returns (uint256)
    {
        return
            totalBenefactorTokenNumerator[benefactor].mul(auctionLength).div(
                yearTimePatronagDenominator
            ); // 365 days * 1000000000000
    }

    function withdrawBenefactorFundsTo(address payable benefactor) public {
        _updateBenefactorBalance(benefactor);

        uint256 availableToWithdraw = benefactorFunds[benefactor];


            uint256 benefactorWithdrawalSafetyDiscount
         = fundsDueForAuctionPeriodAtCurrentRate(benefactor);

        require(
            availableToWithdraw > benefactorWithdrawalSafetyDiscount,
            "no funds"
        );

        // NOTE: no need for safe-maths, above require prevents issues.
        uint256 amountToWithdraw = availableToWithdraw -
            benefactorWithdrawalSafetyDiscount;

        benefactorFunds[benefactor] = benefactorWithdrawalSafetyDiscount;
        if (safeSend(amountToWithdraw, benefactor)) {
            emit WithdrawBenefactorFundsWithSafetyDelay(
                benefactor,
                amountToWithdraw
            );
        } else {
            benefactorFunds[benefactor] = benefactorFunds[benefactor].add(
                amountToWithdraw
            );
        }
    }

    function hasher(
        address benefactor,
        uint256 maxAmount,
        uint256 expiry
    ) public view returns (bytes32) {
        // In ethereum you have to prepend all signature hashes with this message (supposedly to prevent people from)
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abi.encodePacked(benefactor, maxAmount, expiry))
                )
            );
    }

    function withdrawBenefactorFundsToValidated(
        address payable benefactor,
        uint256 maxAmount,
        uint256 expiry,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(
            ecrecover(hash, v, r, s) == withdrawCheckerAdmin,
            "no permission to withdraw"
        );
        require(
            hash == hasher(benefactor, maxAmount, expiry),
            "incorrect hash"
        );
        require(now < expiry, "coupon expired");

        _updateBenefactorBalance(benefactor);

        uint256 availableToWithdraw = benefactorFunds[benefactor];

        if (availableToWithdraw > 0) {
            if (availableToWithdraw > maxAmount) {
                if (safeSend(maxAmount, benefactor)) {
                    benefactorFunds[benefactor] = availableToWithdraw.sub(
                        maxAmount
                    );
                    emit WithdrawBenefactorFunds(
                        benefactor,
                        availableToWithdraw
                    );
                }
            } else {
                if (safeSend(availableToWithdraw, benefactor)) {
                    benefactorFunds[benefactor] = 0;
                    emit WithdrawBenefactorFunds(
                        benefactor,
                        availableToWithdraw
                    );
                }
            }
        }
    }

    function _collectPatronagePatron(address tokenPatron)
        public
        returns (uint256 newTimeLastCollectedOnForeclosure)
    {
        uint256 patronageOwedByTokenPatron = patronageOwedPatron(tokenPatron);

        uint256 timeSinceLastMint;

        if (
            patronageOwedByTokenPatron > 0 &&
            patronageOwedByTokenPatron > deposit[tokenPatron]
        ) {

                uint256 previousCollectionTime
             = timeLastCollectedPatron[tokenPatron];
            newTimeLastCollectedOnForeclosure = previousCollectionTime.add(
                (
                    (now.sub(previousCollectionTime))
                        .mul(deposit[tokenPatron])
                        .div(patronageOwedByTokenPatron)
                )
            );
            timeLastCollectedPatron[tokenPatron] = newTimeLastCollectedOnForeclosure;
            deposit[tokenPatron] = 0;
            timeSinceLastMint = (
                newTimeLastCollectedOnForeclosure.sub(previousCollectionTime)
            );
        } else {
            timeSinceLastMint = now.sub(timeLastCollectedPatron[tokenPatron]);
            timeLastCollectedPatron[tokenPatron] = now;
            deposit[tokenPatron] = deposit[tokenPatron].sub(
                patronageOwedByTokenPatron
            );
        }

        _collectLoyaltyPatron(tokenPatron, timeSinceLastMint);
        emit RemainingDepositUpdate(tokenPatron, deposit[tokenPatron]);
    }

    function depositWei() public payable {
        depositWeiPatron(msg.sender);
    }

    function depositWeiPatron(address patron) public payable {
        require(totalPatronOwnedTokenCost[patron] > 0, "no tokens");
        deposit[patron] = deposit[patron].add(msg.value);
        emit RemainingDepositUpdate(patron, deposit[patron]);
    }

    function _auctionPrice(uint256 tokenId) internal view returns (uint256) {
        uint256 auctionEnd = tokenAuctionBeginTimestamp[tokenId].add(
            auctionLength
        );

        // If it is not brand new and foreclosed, use the foreclosre auction price.
        uint256 _auctionStartPrice;
        if (price[tokenId] != 0 && price[tokenId] > auctionEndPrice) {
            _auctionStartPrice = price[tokenId];
        } else {
            // Otherwise use starting auction price
            _auctionStartPrice = auctionStartPrice;
        }

        if (now >= auctionEnd) {
            return auctionEndPrice;
        } else {
            // startPrice - ( ( (startPrice - endPrice) * howLongThisAuctionBeenGoing ) / auctionLength )
            return
                _auctionStartPrice.sub(
                    (_auctionStartPrice.sub(auctionEndPrice))
                        .mul(now.sub(tokenAuctionBeginTimestamp[tokenId]))
                        .div(auctionLength)
                );
        }
    }

    function buy(
        uint256 tokenId,
        uint256 _newPrice,
        uint256 previousPrice,
        uint256 wildcardsPercentage
    )
        public
        payable
        collectPatronageAndSettleBenefactor(tokenId)
        collectPatronagePatron(msg.sender)
        priceGreaterThanZero(_newPrice)
        youCurrentlyAreNotInDefault(msg.sender)
        validWildcardsPercentage(wildcardsPercentage, tokenId)
    {
        require(state[tokenId] == StewardState.Owned, "token on auction");
        require(
            price[tokenId] == previousPrice,
            "must specify current price accurately"
        );

        _distributePurchaseProceeds(tokenId);

        wildcardsPercentages[tokenId] = wildcardsPercentage;
        uint256 remainingValueForDeposit = msg.value.sub(price[tokenId]);
        deposit[msg.sender] = deposit[msg.sender].add(remainingValueForDeposit);
        transferAssetTokenTo(
            tokenId,
            assetToken.ownerOf(tokenId),
            msg.sender,
            _newPrice
        );
        emit Buy(tokenId, msg.sender, _newPrice);
    }

    function buyAuction(
        uint256 tokenId,
        uint256 _newPrice,
        uint256 wildcardsPercentage
    )
        public
        payable
        collectPatronageAndSettleBenefactor(tokenId)
        collectPatronagePatron(msg.sender)
        priceGreaterThanZero(_newPrice)
        youCurrentlyAreNotInDefault(msg.sender)
        validWildcardsPercentage(wildcardsPercentage, tokenId)
    {
        require(
            state[tokenId] == StewardState.Foreclosed,
            "token not foreclosed"
        );
        require(now >= tokenAuctionBeginTimestamp[tokenId], "not on auction");
        uint256 auctionTokenPrice = _auctionPrice(tokenId);
        uint256 remainingValueForDeposit = msg.value.sub(auctionTokenPrice);

        _distributeAuctionProceeds(tokenId);

        state[tokenId] = StewardState.Owned;

        wildcardsPercentages[tokenId] = wildcardsPercentage;
        deposit[msg.sender] = deposit[msg.sender].add(remainingValueForDeposit);
        transferAssetTokenTo(
            tokenId,
            assetToken.ownerOf(tokenId),
            msg.sender,
            _newPrice
        );
        emit Buy(tokenId, msg.sender, _newPrice);
    }

    function _distributeAuctionProceeds(uint256 tokenId) internal {
        uint256 totalAmount = price[tokenId];
        uint256 artistAmount;
        if (artistPercentages[tokenId] == 0) {
            artistAmount = 0;
        } else {
            artistAmount = totalAmount.mul(artistPercentages[tokenId]).div(
                1000000
            );
            deposit[artistAddresses[tokenId]] = deposit[artistAddresses[tokenId]]
                .add(artistAmount);
        }
        uint256 wildcardsAmount = totalAmount.sub(artistAmount);
        deposit[admin] = deposit[admin].add(wildcardsAmount);
    }

    function _distributePurchaseProceeds(uint256 tokenId) internal {
        uint256 totalAmount = price[tokenId];
        address tokenPatron = assetToken.ownerOf(tokenId);
        // Wildcards percentage calc
        if (wildcardsPercentages[tokenId] == 0) {
            wildcardsPercentages[tokenId] = 50000;
        }
        uint256 wildcardsAmount = totalAmount
            .mul(wildcardsPercentages[tokenId])
            .div(1000000);

        // Artist percentage calc
        uint256 artistAmount;
        if (artistPercentages[tokenId] == 0) {
            artistAmount = 0;
        } else {
            artistAmount = totalAmount.mul(artistPercentages[tokenId]).div(
                1000000
            );
            deposit[artistAddresses[tokenId]] = deposit[artistAddresses[tokenId]]
                .add(artistAmount);
        }

        uint256 previousOwnerProceedsFromSale = totalAmount
            .sub(wildcardsAmount)
            .sub(artistAmount);
        if (
            totalPatronOwnedTokenCost[tokenPatron] ==
            price[tokenId].mul(patronageNumerator[tokenId])
        ) {
            previousOwnerProceedsFromSale = previousOwnerProceedsFromSale.add(
                deposit[tokenPatron]
            );
            deposit[tokenPatron] = 0;
            address payable payableCurrentPatron = address(
                uint160(tokenPatron)
            );
            (bool transferSuccess, ) = payableCurrentPatron
                .call
                .gas(2300)
                .value(previousOwnerProceedsFromSale)("");
            if (!transferSuccess) {
                deposit[tokenPatron] = deposit[tokenPatron].add(
                    previousOwnerProceedsFromSale
                );
            }
        } else {
            deposit[tokenPatron] = deposit[tokenPatron].add(
                previousOwnerProceedsFromSale
            );
        }

        deposit[admin] = deposit[admin].add(wildcardsAmount);
    }

    function changePrice(uint256 tokenId, uint256 _newPrice)
        public
        onlyPatron(tokenId)
        collectPatronageAndSettleBenefactor(tokenId)
    {
        require(state[tokenId] != StewardState.Foreclosed, "foreclosed");
        require(_newPrice != 0, "incorrect price");
        require(_newPrice < 10000 ether, "exceeds max price");

        uint256 oldPriceScaled = price[tokenId].mul(
            patronageNumerator[tokenId]
        );
        uint256 newPriceScaled = _newPrice.mul(patronageNumerator[tokenId]);
        address tokenBenefactor = benefactors[tokenId];

        totalPatronOwnedTokenCost[msg.sender] = totalPatronOwnedTokenCost[msg
            .sender]
            .sub(oldPriceScaled)
            .add(newPriceScaled);

        totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
            .sub(oldPriceScaled)
            .add(newPriceScaled);

        price[tokenId] = _newPrice;
        emit PriceChange(tokenId, price[tokenId]);
    }

    function withdrawDeposit(uint256 _wei)
        public
        collectPatronagePatron(msg.sender)
        returns (uint256)
    {
        _withdrawDeposit(_wei);
    }

    function withdrawBenefactorFunds() public {
        withdrawBenefactorFundsTo(msg.sender);
    }

    function exit() public collectPatronagePatron(msg.sender) {
        _withdrawDeposit(deposit[msg.sender]);
    }

    function _withdrawDeposit(uint256 _wei) internal {
        require(deposit[msg.sender] >= _wei, "withdrawing too much");

        deposit[msg.sender] = deposit[msg.sender].sub(_wei);

        (bool transferSuccess, ) = msg.sender.call.gas(2300).value(_wei)("");
        if (!transferSuccess) {
            revert("withdrawal failed");
        }
    }

    function _foreclose(uint256 tokenId) internal {
        address currentOwner = assetToken.ownerOf(tokenId);
        resetTokenOnForeclosure(tokenId, currentOwner);
        state[tokenId] = StewardState.Foreclosed;

        emit Foreclosure(currentOwner, timeLastCollectedPatron[currentOwner]);
    }

    function transferAssetTokenTo(
        uint256 tokenId,
        address _currentOwner,
        address _newOwner,
        uint256 _newPrice
    ) internal {
        require(_newPrice < 10000 ether, "exceeds max price");

        uint256 scaledOldPrice = price[tokenId].mul(
            patronageNumerator[tokenId]
        );
        uint256 scaledNewPrice = _newPrice.mul(patronageNumerator[tokenId]);

        totalPatronOwnedTokenCost[_newOwner] = totalPatronOwnedTokenCost[_newOwner]
            .add(scaledNewPrice);
        totalPatronTokenGenerationRate[_newOwner] = totalPatronTokenGenerationRate[_newOwner]
            .add(globalTokenGenerationRate);

        address tokenBenefactor = benefactors[tokenId];
        totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
            .add(scaledNewPrice);

        if (_currentOwner != address(this) && _currentOwner != address(0)) {
            totalPatronOwnedTokenCost[_currentOwner] = totalPatronOwnedTokenCost[_currentOwner]
                .sub(scaledOldPrice);

            totalPatronTokenGenerationRate[_currentOwner] = totalPatronTokenGenerationRate[_currentOwner]
                .sub(globalTokenGenerationRate);

            totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
                .sub(scaledOldPrice);
        }

        assetToken.transferFrom(_currentOwner, _newOwner, tokenId);

        price[tokenId] = _newPrice;
    }

    function resetTokenOnForeclosure(uint256 tokenId, address _currentOwner)
        internal
    {
        uint256 scaledPrice = price[tokenId].mul(patronageNumerator[tokenId]);

        totalPatronOwnedTokenCost[_currentOwner] = totalPatronOwnedTokenCost[_currentOwner]
            .sub(scaledPrice);

        totalPatronTokenGenerationRate[_currentOwner] = totalPatronTokenGenerationRate[_currentOwner]
            .sub((globalTokenGenerationRate));

        address tokenBenefactor = benefactors[tokenId];
        totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
            .sub(scaledPrice);

        assetToken.transferFrom(_currentOwner, address(this), tokenId);
    }
}