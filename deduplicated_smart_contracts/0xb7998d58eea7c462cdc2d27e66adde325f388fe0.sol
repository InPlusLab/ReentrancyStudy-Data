/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

// File: openzeppelin-solidity/contracts/GSN/Context.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/utils/Address.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol

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

// File: openzeppelin-solidity/contracts/drafts/Counters.sol

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

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

pragma solidity ^0.5.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
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
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

pragma solidity ^0.5.0;








/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721 {
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

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
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
     * Requires the msg.sender to be the owner, approved, or operator
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
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Enumerable.sol

pragma solidity ^0.5.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol

pragma solidity ^0.5.0;





/**
 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {
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
    constructor () public {
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
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
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol

pragma solidity ^0.5.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol

pragma solidity ^0.5.0;





contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Base URI
    string private _baseURI;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

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
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
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
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol

pragma solidity ^0.5.0;




/**
 * @title Full ERC721 Token
 * @dev This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology.
 *
 * See https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }
}

// File: contracts/Strings.sol

pragma solidity 0.5.11;

/**
 * @title Strings
 * @notice Library contract via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
 * @dev Audit certificate : https://github.com/lendroidproject/Rightshare-contracts/blob/master/audit-report.pdf
 */
library Strings {
  function strConcat(string memory a, string memory b, string memory c, string memory d, string memory e) internal pure returns (string memory) {
      bytes memory ba = bytes(a);
      bytes memory bb = bytes(b);
      bytes memory bc = bytes(c);
      bytes memory bd = bytes(d);
      bytes memory be = bytes(e);
      string memory abcde = new string(ba.length + bb.length + bc.length + bd.length + be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < ba.length; i++) babcde[k++] = ba[i];
      for (uint i = 0; i < bb.length; i++) babcde[k++] = bb[i];
      for (uint i = 0; i < bc.length; i++) babcde[k++] = bc[i];
      for (uint i = 0; i < bd.length; i++) babcde[k++] = bd[i];
      for (uint i = 0; i < be.length; i++) babcde[k++] = be[i];
      return string(babcde);
    }

    function strConcat(string memory a, string memory b, string memory c, string memory d) internal pure returns (string memory) {
        return strConcat(a, b, c, d, "");
    }

    function strConcat(string memory a, string memory b, string memory c) internal pure returns (string memory) {
        return strConcat(a, b, c, "", "");
    }

    function strConcat(string memory a, string memory b) internal pure returns (string memory) {
        return strConcat(a, b, "", "", "");
    }

    function uint2str(uint i) internal pure returns (string memory _uintAsString) {
        if (i == 0) {
            return "0";
        }
        uint j = i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    function bool2str(bool b) internal pure returns (string memory _boolAsString) {
        _boolAsString = b ? "1" : "0";
    }

    function address2str(address addr) internal pure returns (string memory addressAsString) {
        bytes32 _bytes = bytes32(uint256(addr));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        addressAsString = string(_string);
    }
}

// File: contracts/TradeableERC721Token.sol

pragma solidity 0.5.11;





/**
 * @title OwnableDelegateProxy
 * @notice Proxy contract to act on behalf of a user account
 * @dev Audit certificate : https://github.com/lendroidproject/Rightshare-contracts/blob/master/audit-report.pdf
 */
contract OwnableDelegateProxy { }

/**
 * @title ProxyRegistry
 * @notice Registry contract to store delegated proxy contracts
 */
contract ProxyRegistry is Ownable {
  using Address for address;
  mapping(address => OwnableDelegateProxy) public proxies;

  /**
    * @notice whitelist a proxyContractAddress for the given owner
    * @param owner address
    * @param proxyContractAddress address of proxy Contract
    */
  function setProxy(address owner, address proxyContractAddress) external onlyOwner {
    require(proxyContractAddress.isContract(), "invalid proxy contract address");
    proxies[owner] = OwnableDelegateProxy(proxyContractAddress);
  }
}

/**
 * @title TradeableERC721Token
 * @notice ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract TradeableERC721Token is ERC721Full, Ownable {
  using Strings for string;

  address proxyRegistryAddress;
  uint256 private _currentTokenId = 0;

  constructor(string memory name, string memory symbol, address registryAddress) ERC721Full(name, symbol) public {
    proxyRegistryAddress = registryAddress;
  }

  /**
    * @notice Allows owner to mint a a token to a given address
    * dev Mints a new token to the given address, increments currentTokenId
    * @param to address of the future owner of the token
    */
  function mintTo(address to) public onlyOwner {
    require(to != address(0));
    uint256 newTokenId = _getNextTokenId();
    _mint(to, newTokenId);
    _incrementTokenId();
  }

  /**
    * @notice Displays the id of the latest token that was minted
    * @return uint256 : latest minted token id
    */
  function currentTokenId() public view returns (uint256) {
    return _currentTokenId;
  }

  /**
    * @notice Displays the id of the next token that will be minted
    * @dev Calculates the next token ID based on value of _currentTokenId
    * @return uint256 : id of the next token
    */
  function _getNextTokenId() private view returns (uint256) {
    return _currentTokenId.add(1);
  }

  /**
    * @notice Increments the value of _currentTokenId
    * @dev Internal function that increases the value of _currentTokenId by 1
    */
  function _incrementTokenId() private  {
    _currentTokenId = _currentTokenId.add(1);
  }

  /**
    * @notice Displays the base api url of the NFT
    * dev This function is overridden by Rights contracts which inherit this contract
    * @return string : an empty string
    */
  function baseTokenURI() public view returns (string memory) {
    return "";
  }

  /**
    * @notice Displays the api uri of a NFT
    * @dev Concatenates the base uri to the given tokenId
    * @param tokenId : uint256 representing the NFT id
    * @return string : api uri
    */
  function tokenURI(uint256 tokenId) external view returns (string memory) {
    return Strings.strConcat(
        baseTokenURI(),
        Strings.uint2str(tokenId)
    );
  }

  /**
     * @notice Tells whether an operator is approved by a given owner.
     * @dev Overrides isApprovedForAll to whitelist user's proxy accounts (useful for sites such as opensea to enable gas-less listings)
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    require(owner != address(0), "owner address cannot be zero");
    require(operator != address(0), "operator address cannot be zero");
    if (proxyRegistryAddress == address(0)) {
      return super.isApprovedForAll(owner, operator);
    }
    // Check if owner has whitelisted proxy contract
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(owner)) == operator) {
        return true;
    }
    return super.isApprovedForAll(owner, operator);
  }
}

// File: contracts/Right.sol

pragma solidity 0.5.11;



/** @title Right
 * @author Lendroid Foundation
 * @notice A smart contract for NFT Rights
 * @dev Audit certificate : https://github.com/lendroidproject/Rightshare-contracts/blob/master/audit-report.pdf
 */
contract Right is TradeableERC721Token {

  string private _apiBaseUrl = "";

  /**
    * @notice Displays the base api url of the Right token
    * @return string : api url
    */
  function baseTokenURI() public view returns (string memory) {
    return _apiBaseUrl;
  }

  /**
    * @notice set the base api url of the Right token
    * @param url : string representing the api url
    */
  function setApiBaseUrl(string calldata url) external onlyOwner {
    _apiBaseUrl = url;
  }

  /**
    * @notice set the registry address that acts as a proxy for the Right token
    * @param registryAddress : address of the proxy registry
    */
  function setProxyRegistryAddress(address registryAddress) external onlyOwner {
    require(registryAddress != address(0), "invalid proxy registry address");
    proxyRegistryAddress = registryAddress;
  }

}

// File: contracts/FRight.sol

pragma solidity 0.5.11;



/** @title FRight
  * @author Lendroid Foundation
  * @notice A smart contract for Frozen Rights
  * @dev Audit certificate : https://github.com/lendroidproject/Rightshare-contracts/blob/master/audit-report.pdf
  */
contract FRight is Right {
  // This stores metadata about a FRight token
  struct Metadata {
    uint256 version; // version of the FRight
    uint256 tokenId; // id of the FRight
    uint256 startTime; // timestamp when the FRight was created
    uint256 endTime; // timestamp until when the FRight is deemed useful
    address baseAssetAddress; // address of original NFT locked in the DAO
    uint256 baseAssetId; // id of original NFT locked in the DAO
    bool isExclusive; // indicates if the FRight is exclusive, aka, has only one IRight
    uint256 maxISupply; // maximum summply of IRights for this FRight
    uint256 circulatingISupply; // circulating summply of IRights for this FRight
  }

  // stores a Metadata struct for each FRight.
  mapping(uint256 => Metadata) public metadata;
  // stores information of original NFTs
  mapping(address => mapping(uint256 => bool)) public isFrozen;

  constructor() TradeableERC721Token("FRight Token", "FRT", address(0)) public {}

  /**
    * @notice Adds metadata about a FRight Token
    * @param version : uint256 representing the version of the FRight
    * @param startTime : uint256 creation timestamp of the FRight
    * @param endTime : uint256 expiry timestamp of the FRight
    * @param baseAssetAddress : address of original NFT
    * @param baseAssetId : id of original NFT
    * @param maxISupply : uint256 indicating maximum summply of IRights
    * @param circulatingISupply : uint256 indicating circulating summply of IRights
    */
  function _updateMetadata(uint256 version, uint256 startTime, uint256 endTime, address baseAssetAddress, uint256 baseAssetId, uint256 maxISupply, uint256 circulatingISupply) private  {
    Metadata storage _meta = metadata[currentTokenId()];
    _meta.tokenId = currentTokenId();
    _meta.version = version;
    _meta.startTime = startTime;
    _meta.endTime = endTime;
    _meta.baseAssetAddress = baseAssetAddress;
    _meta.baseAssetId = baseAssetId;
    _meta.isExclusive = maxISupply == 1;
    _meta.maxISupply = maxISupply;
    _meta.circulatingISupply = circulatingISupply;
  }

  /**
    * @notice Creates a new FRight Token
    * @dev Mints FRight Token, and updates metadata & currentTokenId
    * @param addresses : address array [_to, baseAssetAddress]
    * @param values : uint256 array [endTime, baseAssetId, maxISupply, version]
    * @return uint256 : updated currentTokenId
    */
  function freeze(address[2] calldata addresses, uint256[4] calldata values) external onlyOwner returns (uint256) {
    require(addresses[1].isContract(), "invalid base asset address");
    require(values[0] > block.timestamp, "invalid expiry");
    require(values[1] > 0, "invalid base asset id");
    require(values[2] > 0, "invalid maximum I supply");
    require(values[3] > 0, "invalid version");
    require(!isFrozen[addresses[1]][values[1]], "Asset is already frozen");
    isFrozen[addresses[1]][values[1]] = true;
    mintTo(addresses[0]);
    _updateMetadata(values[3], now, values[0], addresses[1], values[1], values[2], 1);
    return currentTokenId();
  }

  /**
    * @notice Checks if a FRight can be unfrozen
    * @dev Returns true if the FRight either has expired, or has 0 circulating supply of IRights
    * @param tokenId : uint256 representing the FRight id
    * @return bool : indicating if the FRight can be unfrozen
    */
  function isUnfreezable(uint256 tokenId) public view returns (bool) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    return (now >= _meta.endTime) || (_meta.circulatingISupply == 0);
  }

  /**
    * @notice Unfreezes a FRight
    * @dev Deletes the metadata and burns the FRight token
    * @param tokenId : uint256 representing the FRight id
    */
  function unfreeze(address from, uint256 tokenId) external onlyOwner {
    require(isUnfreezable(tokenId), "FRT: token is not unfreezable");
    require(from != address(0), "from address cannot be zero");
    delete isFrozen[metadata[tokenId].baseAssetAddress][metadata[tokenId].baseAssetId];
    delete metadata[tokenId];
    _burn(from, tokenId);
  }

  /**
    * @notice Displays the api uri of a FRight token
    * @dev Reconstructs the uri from the FRight metadata
    * @param tokenId : uint256 representing the FRight id
    * @return string : api uri
    */
  function tokenURI(uint256 tokenId) external view returns (string memory) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    string memory _metadataUri = Strings.strConcat(
        Strings.strConcat(Strings.address2str(_meta.baseAssetAddress), "/", Strings.uint2str(_meta.baseAssetId), "/"),
        Strings.strConcat("f/", Strings.uint2str(_meta.endTime), "/"),
        Strings.strConcat(Strings.bool2str(_meta.isExclusive), "/", Strings.uint2str(_meta.maxISupply), "/"),
        Strings.strConcat(Strings.uint2str(_meta.circulatingISupply) , "/"),
        Strings.uint2str(_meta.version)
    );
    return Strings.strConcat(
        baseTokenURI(),
        _metadataUri
    );
  }

  /**
    * @notice Increment circulating supply of IRights for a FRight
    * @dev Update circulatingISupply of the FRight metadata
    * @param tokenId : uint256 representing the FRight id
    * @param amount : uint256 indicating increment amount
    */
  function incrementCirculatingISupply(uint256 tokenId, uint256 amount) external onlyOwner {
    require(tokenId > 0, "invalid token id");
    require(amount > 0, "amount cannot be zero");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    require(_meta.maxISupply.sub(_meta.circulatingISupply) >= amount, "Circulating I Supply cannot be incremented");
    _meta.circulatingISupply = _meta.circulatingISupply.add(amount);
  }

  /**
    * @notice Decrement circulating supply of IRights for a FRight
    * @dev Decrement circulatingISupply and maxISupply of the FRight metadata
    * @param tokenId : uint256 representing the FRight id
    * @param amount : uint256 indicating decrement amount
    */
  function decrementCirculatingISupply(uint256 tokenId, uint256 amount) external onlyOwner {
    require(tokenId > 0, "invalid token id");
    require(amount > 0, "amount cannot be zero");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    require(_meta.maxISupply.sub(amount) >= _meta.circulatingISupply.sub(amount), "invalid amount");
    _meta.circulatingISupply = _meta.circulatingISupply.sub(amount);
    _meta.maxISupply = _meta.maxISupply.sub(amount);
  }

  /**
    * @notice Displays information about the original NFT of a FRight token
    * @param tokenId : uint256 representing the FRight id
    * @return baseAssetAddress : address of original NFT
    * @return baseAssetId : id of original NFT
    */
  function baseAsset(uint256 tokenId) external view returns (address baseAssetAddress, uint256 baseAssetId) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    baseAssetAddress = _meta.baseAssetAddress;
    baseAssetId = _meta.baseAssetId;
  }

  /**
    * @notice Displays if a IRight can be minted from the given FRight
    * @param tokenId : uint256 representing the FRight id
    * @return bool : indicating if a IRight can be minted
    */
  function isIMintable(uint256 tokenId) external view returns (bool) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    require(!_meta.isExclusive, "cannot mint exclusive iRight");
    if (_meta.maxISupply.sub(_meta.circulatingISupply) > 0) {
      return true;
    }
    return false;
  }

  /**
    * @notice Displays the expiry of a FRight token
    * @param tokenId : uint256 representing the FRight id
    * @return uint256 : expiry as a timestamp
    */
  function endTime(uint256 tokenId) external view returns (uint256) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "FRT: token does not exist");
    return _meta.endTime;
  }
}

// File: contracts/IRight.sol

pragma solidity 0.5.11;



/** @title IRight
  * @author Lendroid Foundation
  * @notice A smart contract for Interim Rights
  * @dev Audit certificate : https://github.com/lendroidproject/Rightshare-contracts/blob/master/audit-report.pdf
  */
contract IRight is Right {
  // This stores metadata about a IRight token
  struct Metadata {
    uint256 version; // version of the IRight
    uint256 parentId; // id of the FRight
    uint256 tokenId; // id of the IRight
    uint256 startTime; // timestamp when the IRight was created
    uint256 endTime; // timestamp until when the IRight is deemed useful
    address baseAssetAddress; // address of original NFT locked in the DAO
    uint256 baseAssetId; // id of original NFT locked in the DAO
    bool isExclusive; // indicates if the IRight is exclusive, aka, is the only IRight for the FRight
  }

  // stores a `Metadata` struct for each IRight.
  mapping(uint256 => Metadata) public metadata;

  constructor() TradeableERC721Token("IRight Token", "IRT", address(0)) public {}

  /**
    * @notice Adds metadata about a IRight Token
    * @param version : uint256 representing the version of the IRight
    * @param parentId : uint256 representing the id of the FRight
    * @param startTime : uint256 creation timestamp of the IRight
    * @param endTime : uint256 expiry timestamp of the IRight
    * @param baseAssetAddress : address of original NFT
    * @param baseAssetId : id of original NFT
    * @param isExclusive : bool indicating exclusivity of IRight
    */
  function _updateMetadata(uint256 version, uint256 parentId, uint256 startTime, uint256 endTime, address baseAssetAddress, uint256 baseAssetId, bool isExclusive) private  {
    Metadata storage _meta = metadata[currentTokenId()];
    _meta.tokenId = currentTokenId();
    _meta.version = version;
    _meta.parentId = parentId;
    _meta.startTime = startTime;
    _meta.endTime = endTime;
    _meta.baseAssetAddress = baseAssetAddress;
    _meta.baseAssetId = baseAssetId;
    _meta.isExclusive = isExclusive;
  }

  /**
    * @notice Creates a new IRight Token
    * @dev Mints IRight Token, and updates metadata & currentTokenId
    * @param addresses : address array [_to, baseAssetAddress]
    * @param isExclusive : boolean indicating exclusivity of the FRight Token
    * @param values : uint256 array [parentId, endTime, baseAssetId, version]
    */
  function issue(address[2] calldata addresses, bool isExclusive, uint256[4] calldata values) external onlyOwner {
    require(addresses[1].isContract(), "invalid base asset address");
    require(values[0] > 0, "invalid parent id");
    require(values[1] > block.timestamp, "invalid expiry");
    require(values[2] > 0, "invalid base asset id");
    require(values[3] > 0, "invalid version");
    mintTo(addresses[0]);
    _updateMetadata(values[3], values[0], now, values[1], addresses[1], values[2], isExclusive);
  }

  /**
    * @notice Revokes a IRight
    * @dev Deletes the metadata and burns the IRight token
    * @param from : address of the IRight owner
    * @param tokenId : uint256 representing the IRight id
    */
  function revoke(address from, uint256 tokenId) external onlyOwner {
    require(tokenId > 0, "invalid token id");
    require(from != address(0), "from address cannot be zero");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "IRT: token does not exist");
    delete metadata[tokenId];
    _burn(from, tokenId);
  }

  /**
    * @notice Displays the api uri of a IRight token
    * @dev Reconstructs the uri from the FRight metadata
    * @param tokenId : uint256 representing the IRight id
    * @return string : api uri
    */
  function tokenURI(uint256 tokenId) external view returns (string memory) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "IRT: token does not exist");
    string memory _metadataUri = Strings.strConcat(
        Strings.strConcat("i/", Strings.address2str(_meta.baseAssetAddress), "/", Strings.uint2str(_meta.baseAssetId), "/"),
        Strings.strConcat(Strings.uint2str(_meta.endTime), "/"),
        Strings.strConcat(Strings.bool2str(_meta.isExclusive), "/"),
        Strings.uint2str(_meta.version)
    );
    return Strings.strConcat(
        baseTokenURI(),
        _metadataUri
    );
  }

  /**
    * @notice Displays the FRight id of a IRight token
    * @param tokenId : uint256 representing the FRight id
    * @return uint256 : parentId from the IRights metadata
    */
  function parentId(uint256 tokenId) external view returns (uint256) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "IRT: token does not exist");
    return _meta.parentId;
  }

  /**
    * @notice Displays information about the original NFT of a IRight token
    * @param tokenId : uint256 representing the IRight id
    * @return baseAssetAddress : address of original NFT
    * @return baseAssetId : id of original NFT
    */
  function baseAsset(uint256 tokenId) external view returns (address baseAssetAddress, uint256 baseAssetId) {
    require(tokenId > 0, "invalid token id");
    Metadata storage _meta = metadata[tokenId];
    require(_meta.tokenId == tokenId, "IRT: token does not exist");
    baseAssetAddress = _meta.baseAssetAddress;
    baseAssetId = _meta.baseAssetId;
  }

}

// File: contracts/RightsDao.sol

pragma solidity 0.5.11;









/** @title RightsDao
 * @author Lendroid Foundation
 * @notice DAO that handles NFTs, FRights, and IRights
 * @dev Audit certificate : https://github.com/lendroidproject/Rightshare-contracts/blob/master/audit-report.pdf
 */
contract RightsDao is Ownable, IERC721Receiver {

  using Address for address;
  using SafeMath for uint256;

  int128 constant CONTRACT_TYPE_RIGHT_F = 1;
  int128 constant CONTRACT_TYPE_RIGHT_I = 2;

  // stores contract addresses of FRight and IRight
  mapping(int128 => address) public contracts;

  // stores addresses that have been whitelisted to perform freeze calls
  mapping(address => bool) public isWhitelisted;

  // stores whether freeze calls require caller to be whitelisted
  bool public whitelistedFreezeActivated = true;

  // stores latest current version of FRight
  uint256 public currentFVersion = 1;
  // stores latest current version of IRight
  uint256 public currentIVersion = 1;

  constructor(address fRightContractAddress, address iRightContractAddress) public {
    require(fRightContractAddress.isContract(), "invalid fRightContractAddress");
    require(iRightContractAddress.isContract(), "invalid iRightContractAddress");
    contracts[CONTRACT_TYPE_RIGHT_F] = fRightContractAddress;
    contracts[CONTRACT_TYPE_RIGHT_I] = iRightContractAddress;
  }

  function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
    return this.onERC721Received.selector;
  }

  /**
    * @notice Internal function to record if freeze calls must be made only by whitelisted accounts
    * @dev set whitelistedFreezeActivated value as true or false
    * @param activate : bool indicating the toggle value
    */
  function _toggleWhitelistedFreeze(bool activate) internal {
    if (activate) {
      require(!whitelistedFreezeActivated, "whitelisted freeze is already activated");
    }
    else {
      require(whitelistedFreezeActivated, "whitelisted freeze is already deactivated");
    }
    whitelistedFreezeActivated = activate;
  }

  /**
    * @notice Allows the owner to specify that freeze calls require sender to be whitelisted
    * @dev set whitelistedFreezeActivated value as true
    */
  function activateWhitelistedFreeze() external onlyOwner {
    _toggleWhitelistedFreeze(true);
  }

  /**
    * @notice Allows the owner to specify that freeze calls do not require sender to be whitelisted
    * @dev set whitelistedFreezeActivated value as true
    */
  function deactivateWhitelistedFreeze() external onlyOwner {
    _toggleWhitelistedFreeze(false);
  }

  /**
    * @notice Allows owner to add / remove given address to / from whitelist
    * @param addr : given address
    * @param status : bool indicating whitelist status of given address
    */
  function toggleWhitelistStatus(address addr, bool status) external onlyOwner {
    require(addr != address(0), "invalid address");
    isWhitelisted[addr] = status;
  }

  /**
    * @notice Allows owner to increment the current f version
    * @dev Increment currentFVersion by 1
    */
  function incrementCurrentFVersion() external onlyOwner {
    currentFVersion = currentFVersion.add(1);
  }

  /**
    * @notice Allows owner to increment the current i version
    * @dev Increment currentIVersion by 1
    */
  function incrementCurrentIVersion() external onlyOwner {
    currentIVersion = currentIVersion.add(1);
  }

  /**
    * @notice Allows owner to set the base api url of F or I Right token
    * @dev Set base url of the server API representing the metadata of a Right Token
    * @param rightType type of Right contract
    * @param url API base url
    */
  function setRightApiBaseUrl(int128 rightType, string calldata url) external onlyOwner {
    require((rightType == CONTRACT_TYPE_RIGHT_F) || (rightType == CONTRACT_TYPE_RIGHT_I), "invalid contract type");
    if (rightType == CONTRACT_TYPE_RIGHT_F) {
      FRight(contracts[rightType]).setApiBaseUrl(url);
    }
    else {
      IRight(contracts[rightType]).setApiBaseUrl(url);
    }
  }

  /**
    * @notice Allows owner to set the proxy registry address of F or I Right token
    * @dev Set proxy registry address of the Right Token
    * @param rightType type of Right contract
    * @param proxyRegistryAddress address of the Right's Proxy Registry
    */
  function setRightProxyRegistry(int128 rightType, address proxyRegistryAddress) external onlyOwner {
    require((rightType == CONTRACT_TYPE_RIGHT_F) || (rightType == CONTRACT_TYPE_RIGHT_I), "invalid contract type");
    if (rightType == CONTRACT_TYPE_RIGHT_F) {
      FRight(contracts[rightType]).setProxyRegistryAddress(proxyRegistryAddress);
    }
    else {
      IRight(contracts[rightType]).setProxyRegistryAddress(proxyRegistryAddress);
    }
  }

  /**
    * @notice Freezes a given NFT Token
    * @dev Send the NFT to this contract, mint 1 FRight Token and 1 IRight Token
    * @param baseAssetAddress : address of the NFT
    * @param baseAssetId : id of the NFT
    * @param expiry : timestamp until which the NFT is locked in the dao
    * @param values : uint256 array [maxISupply, f_version, i_version]
    */
  function freeze(address baseAssetAddress, uint256 baseAssetId, uint256 expiry, uint256[3] calldata values) external {
    if (whitelistedFreezeActivated) {
      require(isWhitelisted[msg.sender], "sender is not whitelisted");
    }
    require(values[0] > 0, "invalid maximum I supply");
    require(expiry > block.timestamp, "expiry should be in the future");
    require((values[1] > 0) && (values[1] <= currentFVersion), "invalid f version");
    require((values[2] > 0) && (values[2] <= currentIVersion), "invalid i version");
    uint256 fRightId = FRight(contracts[CONTRACT_TYPE_RIGHT_F]).freeze([msg.sender, baseAssetAddress], [expiry, baseAssetId, values[0], values[1]]);
    // set exclusivity of IRights for the NFT
    bool isExclusive = values[0] == 1;
    IRight(contracts[CONTRACT_TYPE_RIGHT_I]).issue([msg.sender, baseAssetAddress], isExclusive, [fRightId, expiry, baseAssetId, values[2]]);
    ERC721(baseAssetAddress).safeTransferFrom(msg.sender, address(this), baseAssetId);
  }

  /**
    * @notice Issues a IRight for a given FRight
    * @dev Check if IRight can be minted, Mint 1 IRight, Increment FRight.circulatingISupply by 1
    * @param values : uint256 array [fRightId, expiry, i_version]
    */
  function issueI(uint256[3] calldata values) external {
    require(values[1] > block.timestamp, "expiry should be in the future");
    require((values[2] > 0) && (values[2] <= currentIVersion), "invalid i version");
    require(FRight(contracts[CONTRACT_TYPE_RIGHT_F]).isIMintable(values[0]), "cannot mint iRight");
    require(msg.sender == FRight(contracts[CONTRACT_TYPE_RIGHT_F]).ownerOf(values[0]), "sender is not the owner of fRight");
    uint256 fEndTime = FRight(contracts[CONTRACT_TYPE_RIGHT_F]).endTime(values[0]);
    require(values[1] <= fEndTime, "expiry cannot exceed fRight expiry");
    (address baseAssetAddress, uint256 baseAssetId) = FRight(contracts[CONTRACT_TYPE_RIGHT_F]).baseAsset(values[0]);
    IRight(contracts[CONTRACT_TYPE_RIGHT_I]).issue([msg.sender, baseAssetAddress], false, [values[0], values[1], baseAssetId, values[2]]);
    FRight(contracts[CONTRACT_TYPE_RIGHT_F]).incrementCirculatingISupply(values[0], 1);
  }

  /**
    * @notice Revokes a given IRight. The IRight can be revoked at any time.
    * @dev Burn the IRight token. If the corresponding FRight exists, decrement its circulatingISupply by 1
    * @param iRightId : id of the IRight token
    */
  function revokeI(uint256 iRightId) external {
    require(msg.sender == IRight(contracts[CONTRACT_TYPE_RIGHT_I]).ownerOf(iRightId), "sender is not the owner of iRight");
    (address baseAssetAddress, uint256 baseAssetId) = IRight(contracts[CONTRACT_TYPE_RIGHT_I]).baseAsset(iRightId);
    bool isBaseAssetFrozen = FRight(contracts[CONTRACT_TYPE_RIGHT_F]).isFrozen(baseAssetAddress, baseAssetId);
    if (isBaseAssetFrozen) {
      uint256 fRightId = IRight(contracts[CONTRACT_TYPE_RIGHT_I]).parentId(iRightId);
      FRight(contracts[CONTRACT_TYPE_RIGHT_F]).decrementCirculatingISupply(fRightId, 1);
    }
    IRight(contracts[CONTRACT_TYPE_RIGHT_I]).revoke(msg.sender, iRightId);
  }

  /**
    * @notice Unfreezes a given FRight. The FRight can be unfrozen if either it has expired or it has nil issued IRights
    * @dev Burn the FRight token for a given token Id, and return the original NFT back to the caller
    * @param fRightId : id of the FRight token
    */
  function unfreeze(uint256 fRightId) external {
    require(FRight(contracts[CONTRACT_TYPE_RIGHT_F]).isUnfreezable(fRightId), "fRight is unfreezable");
    (address baseAssetAddress, uint256 baseAssetId) = FRight(contracts[CONTRACT_TYPE_RIGHT_F]).baseAsset(fRightId);
    FRight(contracts[CONTRACT_TYPE_RIGHT_F]).unfreeze(msg.sender, fRightId);
    ERC721(baseAssetAddress).transferFrom(address(this), msg.sender, baseAssetId);
  }

}