/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

pragma solidity 0.5.11;


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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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

contract MultiTransfer is IERC721 {

    function transferBatch(
        address from,
        address to,
        uint256 start,
        uint256 end
    )
        public
    {
        for (uint i = start; i < end; i++) {
            transferFrom(from, to, i);
        }
    }

    function transferAllFrom(
        address from,
        address to,
        uint256[] memory tokenIDs
    )
        public
    {
        for (uint i = 0; i < tokenIDs.length; i++) {
            transferFrom(from, to, tokenIDs[i]);
        }
    }

    function safeTransferBatch(
        address from,
        address to,
        uint256 start,
        uint256 end
    )
        public
    {
        for (uint i = start; i < end; i++) {
            safeTransferFrom(from, to, i);
        }
    }

    function safeTransferAllFrom(
        address from,
        address to,
        uint256[] memory tokenIDs
    )
        public
    {
        for (uint i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(from, to, tokenIDs[i]);
        }
    }

}

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

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

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
     * This function is deprecated.
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

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
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

contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

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
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
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

contract BatchToken is ERC721Metadata {

    using SafeMath for uint256;

    struct Batch {
        uint48 userID;
        uint16 size;
    }

    mapping(uint48 => address) public userIDToAddress;
    mapping(address => uint48) public addressToUserID;

    uint256 public batchSize;
    uint256 public nextBatch;
    uint256 public tokenCount;

    uint48[] internal ownerIDs;
    uint48[] internal approvedIDs;

    mapping(uint => Batch) public batches;

    uint48 internal userCount = 1;

    mapping(address => uint) internal _balances;

    uint256 internal constant MAX_LENGTH = uint(2**256 - 1);

    constructor(
        uint256 _batchSize,
        string memory name,
        string memory symbol
    )
        public
        ERC721Metadata(name, symbol)
    {
        batchSize = _batchSize;
        ownerIDs.length = MAX_LENGTH;
        approvedIDs.length = MAX_LENGTH;
    }

    function _getUserID(address to)
        internal
        returns (uint48)
    {
        if (to == address(0)) {
            return 0;
        }
        uint48 uID = addressToUserID[to];
        if (uID == 0) {
            require(
                userCount + 1 > userCount,
                "BT: must not overflow"
            );
            uID = userCount++;
            userIDToAddress[uID] = to;
            addressToUserID[to] = uID;
        }
        return uID;
    }

    function _batchMint(
        address to,
        uint16 size
    )
        internal
        returns (uint)
    {
        require(
            to != address(0),
            "BT: must not be null"
        );

        require(
            size > 0 && size <= batchSize,
            "BT: size must be within limits"
        );

        uint256 start = nextBatch;
        uint48 uID = _getUserID(to);
        batches[start] = Batch({
            userID: uID,
            size: size
        });
        uint256 end = start.add(size);
        for (uint256 i = start; i < end; i++) {
            emit Transfer(address(0), to, i);
        }
        nextBatch = nextBatch.add(batchSize);
        _balances[to] = _balances[to].add(size);
        tokenCount = tokenCount.add(size);
        return start;
    }

    function getBatchStart(uint256 tokenId) public view returns (uint) {
        return tokenId.div(batchSize).mul(batchSize);
    }

    function getBatch(uint256 index) public view returns (uint48 userID, uint16 size) {
        return (batches[index].userID, batches[index].size);
    }

    // Overridden ERC721 functions
    // @OZ: please stop making variables/functions private

    function ownerOf(uint256 tokenId)
        public
        view
        returns (address)
    {
        uint48 uID = ownerIDs[tokenId];
        if (uID == 0) {
            uint256 start = getBatchStart(tokenId);
            Batch memory b = batches[start];

            require(
                start + b.size > tokenId,
                "BT: token does not exist"
            );

            uID = b.userID;
            require(
                uID != 0,
                "BT: bad batch owner"
            );
        }
        return userIDToAddress[uID];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
    {
        require(
            ownerOf(tokenId) == from,
            "BT: transfer of token that is not own"
        );

        require(
            to != address(0),
            "BT: transfer to the zero address"
        );

        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "BT: caller is not owner nor approved"
        );

        _cancelApproval(tokenId);
        _balances[from] = _balances[from].sub(1);
        _balances[to] = _balances[to].add(1);
        ownerIDs[tokenId] = _getUserID(to);
        emit Transfer(from, to, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "BT: caller is not owner nor approved"
        );

        _cancelApproval(tokenId);
        address owner = ownerOf(tokenId);
        _balances[owner] = _balances[owner].sub(1);
        ownerIDs[tokenId] = 0;
        tokenCount = tokenCount.sub(1);
        emit Transfer(owner, address(0), tokenId);
    }

    function _cancelApproval(uint256 tokenId) internal {
        if (approvedIDs[tokenId] != 0) {
            approvedIDs[tokenId] = 0;
        }
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);

        require(
            to != owner,
            "BT: approval to current owner"
        );

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "BT: approve caller is not owner nor approved for all"
        );

        approvedIDs[tokenId] = _getUserID(to);
        emit Approval(owner, to, tokenId);
    }

    function _exists(uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return ownerOf(tokenId) != address(0);
    }

    function getApproved(uint256 tokenId)
        public
        view
        returns (address)
    {
        require(
            _exists(tokenId),
            "BT: approved query for nonexistent token"
        );

        return userIDToAddress[approvedIDs[tokenId]];
    }

    function totalSupply()
        public
        view
        returns (uint)
    {
        return tokenCount;
    }

    function balanceOf(address _owner)
        public
        view
        returns (uint256)
    {
        return _balances[_owner];
    }

}

library String {

    /**
     * @dev Converts a `uint256` to a `string`.
     * via OraclizeAPI - MIT licence
     * https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
     */
    function fromUint(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }

    bytes constant alphabet = "0123456789abcdef";

    function fromAddress(address _addr) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0F))];
        }
        return string(str);
    }

}

contract ImmutableToken {

    string public constant baseURI = "https://api.immutable.com/asset/";

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return string(abi.encodePacked(
            baseURI,
            String.fromAddress(address(this)),
            "/",
            String.fromUint(tokenId)
        ));
    }

}

contract InscribableToken {

    mapping(bytes32 => bytes32) public properties;

    event ClassPropertySet(
        bytes32 indexed key,
        bytes32 value
    );

    event TokenPropertySet(
        uint indexed id,
        bytes32 indexed key,
        bytes32 value
    );

    function _setProperty(
        uint _id,
        bytes32 _key,
        bytes32 _value
    )
        internal
    {
        properties[getTokenKey(_id, _key)] = _value;
        emit TokenPropertySet(_id, _key, _value);
    }

    function getProperty(
        uint _id,
        bytes32 _key
    )
        public
        view
        returns (bytes32 _value)
    {
        return properties[getTokenKey(_id, _key)];
    }

    function _setClassProperty(
        bytes32 _key,
        bytes32 _value
    )
        internal
    {
        emit ClassPropertySet(_key, _value);
        properties[getClassKey(_key)] = _value;
    }

    function getTokenKey(
        uint _tokenId,
        bytes32 _key
    )
        public
        pure
        returns (bytes32)
    {
        // one prefix to prevent collisions
        return keccak256(abi.encodePacked(uint(1), _tokenId, _key));
    }

    function getClassKey(bytes32 _key)
        public
        pure
        returns (bytes32)
    {
        // zero prefix to prevent collisions
        return keccak256(abi.encodePacked(uint(0), _key));
    }

    function getClassProperty(bytes32 _key)
        public
        view
        returns (bytes32)
    {
        return properties[getClassKey(_key)];
    }

}

contract ICards is IERC721 {

    struct Batch {
        uint48 userID;
        uint16 size;
    }

    function batches(uint index) public view returns (uint48 userID, uint16 size);

    function userIDToAddress(uint48 id) public view returns (address);

    function getDetails(
        uint tokenId
    )
        public
        view
        returns (
        uint16 proto,
        uint8 quality
    );

    function setQuality(
        uint tokenId,
        uint8 quality
    ) public;

    function mintCards(
        address to,
        uint16[] memory _protos,
        uint8[] memory _qualities
    )
        public
        returns (uint);

    function mintCard(
        address to,
        uint16 _proto,
        uint8 _quality
    )
        public
        returns (uint);

    function burn(uint tokenId) public;

    function batchSize()
        public
        view
        returns (uint);
}

library StorageWrite {

    using SafeMath for uint256;

    function _getStorageArraySlot(uint _dest, uint _index) internal view returns (uint result) {
        uint slot = _getArraySlot(_dest, _index);
        assembly { result := sload(slot) }
    }

    function _getArraySlot(uint _dest, uint _index) internal pure returns (uint slot) {
        assembly {
            let free := mload(0x40)
            mstore(free, _dest)
            slot := add(keccak256(free, 32), _index)
        }
    }

    function _setArraySlot(uint _dest, uint _index, uint _value) internal {
        uint slot = _getArraySlot(_dest, _index);
        assembly { sstore(slot, _value) }
    }

    function _loadSlots(
        uint _slot,
        uint _offset,
        uint _perSlot,
        uint _length
    )
        internal
        view
        returns (uint[] memory slots)
    {
        uint slotCount = _slotCount(_offset, _perSlot, _length);
        slots = new uint[](slotCount);
        // top and tail the slots
        uint firstPos = _pos(_offset, _perSlot); // _offset.div(_perSlot);
        slots[0] = _getStorageArraySlot(_slot, firstPos);
        if (slotCount > 1) {
            uint lastPos = _pos(_offset.add(_length), _perSlot); // .div(_perSlot);
            slots[slotCount-1] = _getStorageArraySlot(_slot, lastPos);
        }
    }

    function _pos(uint items, uint perPage) internal pure returns (uint) {
        return items / perPage;
    }

    function _slotCount(uint _offset, uint _perSlot, uint _length) internal pure returns (uint) {
        uint start = _offset / _perSlot;
        uint end = (_offset + _length) / _perSlot;
        return (end - start) + 1;
    }

    function _saveSlots(uint _slot, uint _offset, uint _size, uint[] memory _slots) internal {
        uint offset = _offset.div((256/_size));
        for (uint i = 0; i < _slots.length; i++) {
            _setArraySlot(_slot, offset + i, _slots[i]);
        }
    }

    function _write(uint[] memory _slots, uint _offset, uint _size, uint _index, uint _value) internal pure {
        uint perSlot = 256 / _size;
        uint initialOffset = _offset % perSlot;
        uint slotPosition = (initialOffset + _index) / perSlot;
        uint withinSlot = ((_index + _offset) % perSlot) * _size;
        // evil bit shifting magic
        for (uint q = 0; q < _size; q += 8) {
            _slots[slotPosition] |= ((_value >> q) & 0xFF) << (withinSlot + q);
        }
    }

    function repeatUint16(uint _slot, uint _offset, uint _length, uint16 _item) internal {
        uint[] memory slots = _loadSlots(_slot, _offset, 16, _length);
        for (uint i = 0; i < _length; i++) {
            _write(slots, _offset, 16, i, _item);
        }
        _saveSlots(_slot, _offset, 16, slots);
    }

    function uint16s(uint _slot, uint _offset, uint16[] memory _items) internal {
        uint[] memory slots = _loadSlots(_slot, _offset, 16, _items.length);
        for (uint i = 0; i < _items.length; i++) {
            _write(slots, _offset, 16, i, _items[i]);
        }
        _saveSlots(_slot, _offset, 16, slots);
    }

    function uint8s(uint _slot, uint _offset, uint8[] memory _items) internal {
        uint[] memory slots = _loadSlots(_slot, _offset, 32, _items.length);
        for (uint i = 0; i < _items.length; i++) {
            _write(slots, _offset, 8, i, _items[i]);
        }
        _saveSlots(_slot, _offset, 8, slots);
    }

}

contract Cards is Ownable, MultiTransfer, BatchToken, ImmutableToken, InscribableToken {

    uint16 private constant MAX_UINT16 = 2**16 - 1;

    uint16[] public cardProtos;
    uint8[] public cardQualities;

    struct Season {
        uint16 high;
        uint16 low;
    }

    struct Proto {
        bool locked;
        bool exists;
        uint8 god;
        uint8 cardType;
        uint8 rarity;
        uint8 mana;
        uint8 attack;
        uint8 health;
        uint8 tribe;
    }

    event ProtoUpdated(
        uint16 indexed id
    );

    event SeasonStarted(
        uint16 indexed id,
        string name,
        uint16 indexed low,
        uint16 indexed high
    );

    event QualityChanged(
        uint256 indexed tokenId,
        uint8 quality,
        address factory
    );

    event CardsMinted(
        uint256 indexed start,
        address to,
        uint16[] protos,
        uint8[] qualities
    );

    // Value of index proto = season
    uint16[] public protoToSeason;

    address public propertyManager;

    // Array containing all protos
    Proto[] public protos;

    // Array containing all seasons
    Season[] public seasons;

    // Map whether a season is tradeable or not
    mapping(uint256 => bool) public seasonTradable;

    // Map whether a factory has been authorised or not
    mapping(address => mapping(uint256 => bool)) public factoryApproved;

    // Whether a factory is approved to create a particular mythic
    mapping(uint16 => mapping(address => bool)) public mythicApproved;

    // Whether a mythic is tradable
    mapping(uint16 => bool) public mythicTradable;

    // Map whether a mythic exists or not
    mapping(uint16 => bool) public mythicCreated;

    uint16 public constant MYTHIC_THRESHOLD = 65000;

    constructor(
        uint256 _batchSize,
        string memory _name,
        string memory _symbol
    )
        public
        BatchToken(_batchSize, _name, _symbol)
    {
        cardProtos.length = MAX_LENGTH;
        cardQualities.length = MAX_LENGTH;
        protoToSeason.length = MAX_LENGTH;
        protos.length = MAX_LENGTH;
        propertyManager = msg.sender;
    }

    /**
     * @dev Mint a card with an owner, proto and quality.
     * Can only be called from the proto's season minter(s)
     *
     * @param to Address where newly minted card will be sent to
     * @param _proto Specified proto of new card (caller must be valid factory in season)
     * @param _quality Specified quality of new card (no validation)
     */
    function mintCard(
        address to,
        uint16 _proto,
        uint8 _quality
    )
        external
        returns (uint id)
    {
        id = _batchMint(to, 1);
        _validateProto(_proto);
        cardProtos[id] = _proto;
        cardQualities[id] = _quality;

        uint16[] memory ps = new uint16[](1);
        ps[0] = _proto;

        uint8[] memory qs = new uint8[](1);
        qs[0] = _quality;

        emit CardsMinted(id, to, ps, qs);
        return id;
    }

    /**
     * @dev Mint cards with an owner, proto and quality.
     * Can only be called from the protos' season minter(s).
     *
     *
     * @param to Address where newly minted card will be sent to
     * @param _protos Array of specified protos of new cards (caller must be valid factory in season)
     * @param _qualities Array of specified qualities of new cards (no validation)
     */
    function mintCards(
        address to,
        uint16[] calldata _protos,
        uint8[] calldata _qualities
    )
        external
        returns (uint)
    {
        require(
            _protos.length > 0,
            "Core: must be some protos"
        );

        require(
            _protos.length == _qualities.length,
            "Core: must be the same number of protos/qualities"
        );

        uint256 start = _batchMint(to, uint16(_protos.length));
        _validateAndSaveDetails(start, _protos, _qualities);

        emit CardsMinted(start, to, _protos, _qualities);

        return start;
    }

    /**
     * @dev Add a valid factory to a season. Factories are able to mint cards.
     * Factories cannot mind a card if the season is already tradeable.
     * Can only be called by owner().
     * 
     * @param _factory The address of the season's factory
     * @param _season The season to add the minter to
     */
    function addFactory(
        address _factory,
        uint256 _season
    )
        public
        onlyOwner
    {
        require(
            seasons.length >= _season,
            "Core: season must exist"
        );

        require(
            _season > 0,
            "Core: season must not be 0"
        );

        require(
            !factoryApproved[_factory][_season],
            "Core: this factory is already approved"
        );

        require(
            !seasonTradable[_season],
            "Core: season must not be tradable"
        );

        factoryApproved[_factory][_season] = true;
    }

    function approveForMythic(
        address _factory,
        uint16 _mythic
    )
        public
        onlyOwner
    {
        require(
            _mythic >= MYTHIC_THRESHOLD,
            "not a mythic"
        );

        require(
            !mythicApproved[_mythic][_factory],
            "Core: this factory is already approved for this mythic"
        );

        mythicApproved[_mythic][_factory] = true;
    }

    /**
     * @dev Enable trading for a certan mythic.
     * Can only be called by owner().
     *
     * @param _mythic The proto of the mythic to enable trading for.
     */
    function makeMythicTradable(
        uint16 _mythic
    )
        public
        onlyOwner
    {
        require(
            _mythic >= MYTHIC_THRESHOLD,
            "Core: not a mythic"
        );

        require(
            !mythicTradable[_mythic],
            "Core: must not be tradable already"
        );

        mythicTradable[_mythic] = true;
    }

    /**
     * @dev Unlock trading for an entire season of cards.
     * Can only be called by owner().
     * 
     * @param _season The season to enable trading for.
     */
    function unlockTrading(
        uint256 _season
    )
        public
        onlyOwner
    {
        require(
            _season > 0 && _season <= seasons.length,
            "Core: must be a current season"
        );

        require(
            !seasonTradable[_season],
            "Core: season must not be tradable"
        );

        seasonTradable[_season] = true;
    }

    /**
     * @dev Transfer cards to another address. Trading must be unlocked to transfer.
     * Can be called by the owner or an approved spender.
     * 
     * @param from The owner of the card
     * @param to The recipient of the card to send to
     * @param tokenId The id of the card you'd like to transfer
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
    {
        require(
            isTradable(tokenId),
            "Core: not yet tradable"
        );

        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev Burn a card forever.
     * Can only be called IF the card is not tradeable and from owner().
     * 
     * @param _tokenId The id of the card to burn
     */
    function burn(uint256 _tokenId) public {
        require(
            isTradable(_tokenId),
            "Core: not yet tradable"
        );

        super.burn(_tokenId);
    }

    /**
     * @dev Burn multiple cards forever.
     * Can only be called IF the card is not tradeable and from owner().
     * 
     * @param tokenIDs The id sof the cards to burn
     */
    function burnAll(uint256[] memory tokenIDs) public {
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            burn(tokenIDs[i]);
        }
    }

    /**
     * @dev Retrieve the proto and quality for a particular card represented by it's token id
     *
     * @param tokenId the id of the card you'd like to retrieve details for
     * @return proto The proto of the specified card
     * @return quality The quality of the specified card
     */
    function getDetails(
        uint256 tokenId
    )
        public
        view
        returns (uint16 proto, uint8 quality)
    {
        return (cardProtos[tokenId], cardQualities[tokenId]);
    }

    /**
     * @dev Check if the card is tradeable or not.
     * Once it's tradeable it cannot be burned, revoked or further minted.
     * 
     * @param _tokenId The id of the card to check against
     * @return A boolean of the status (true/false)
     */
    function isTradable(uint256 _tokenId) public view returns (bool) {
        uint16 proto = cardProtos[_tokenId];
        if (proto >= MYTHIC_THRESHOLD) {
            return mythicTradable[proto];
        }
        return seasonTradable[protoToSeason[proto]];
    }

    /**
     * @dev Create a new season with a range of protos.
     * Cannot overlap with other seasons or start at 0.
     * 
     * @param name The name of the season
     * @param low The starting proto range of the season
     * @param high The ending proto range of the season
     * @return An integer of the season's id
     */
    function startSeason(
        string memory name,
        uint16 low,
        uint16 high
    )
        public
        onlyOwner
        returns (uint)
    {
        require(
            low > 0,
            "Core: must not be zero proto"
        );

        require(
            high > low,
            "Core: must be a valid range"
        );

        require(
            seasons.length == 0 || low > seasons[seasons.length - 1].high,
            "Core: seasons cannot overlap"
        );

        require(
            MYTHIC_THRESHOLD > high,
            "Core: cannot go into mythic territory"
        );

        // seasons start at 1
        uint16 id = uint16(seasons.push(Season({ high: high, low: low })));

        uint256 cp;
        assembly { cp := protoToSeason_slot }
        StorageWrite.repeatUint16(cp, low, (high - low) + 1, id);

        emit SeasonStarted(id, name, low, high);

        return id;
    }

    /**
     * @dev Update the properties of a proto.
     * Can only be called if proto unlocked and by owner().
     *
     * @param _ids An array of the ids to update
     * @param _gods An array of the corresponding gods to update
     * @param _cardTypes An array of the corresponding card types to update
     * @param _rarities An array of the corresponding rarities to update
     * @param _manas An array of the corresponding manas to update
     * @param _attacks An array of the corresponding attacks to update
     * @param _healths An array of the corresponding healths to update
     * @param _tribes An array of the corresponding tribes to update    
     */
    function updateProtos(
        uint16[] memory _ids,
        uint8[] memory _gods,
        uint8[] memory _cardTypes,
        uint8[] memory _rarities,
        uint8[] memory _manas,
        uint8[] memory _attacks,
        uint8[] memory _healths,
        uint8[] memory _tribes
    ) public onlyOwner {
        for (uint256 i = 0; i < _ids.length; i++) {
            uint16 id = _ids[i];

            require(
                id > 0,
                "Core: proto must not be zero"
            );

            Proto memory proto = protos[id];
            require(
                !proto.locked,
                "Core: proto is locked"
            );

            protos[id] = Proto({
                locked: false,
                exists: true,
                god: _gods[i],
                cardType: _cardTypes[i],
                rarity: _rarities[i],
                mana: _manas[i],
                attack: _attacks[i],
                health: _healths[i],
                tribe: _tribes[i]
            });
            emit ProtoUpdated(id);
        }
    }

    /**
     * @dev Lock a proto forever.
     * Once this occurs the properties of a card cannot be changed.
     * Can only be called by owner().
     *
     * @param _ids The ids of the protos to lock
     */
    function lockProtos(uint16[] memory _ids) public onlyOwner {
        require(
            _ids.length > 0,
            "Cards: must lock some"
        );

        for (uint256 i = 0; i < _ids.length; i++) {
            uint16 id = _ids[i];
            require(
                id > 0,
                "Cards: proto must not be zero"
            );

            Proto storage proto = protos[id];

            require(
                !proto.locked,
                "Cards: proto is locked"
            );

            require(
                proto.exists,
                "Cards: proto must exist"
            );

            proto.locked = true;
            emit ProtoUpdated(id);
        }
    }

    /**
     * @dev Set/update the quality of a card.
     * Can only be called by the factory minter of a season.
     *
     * @param _tokenId The id of the token to update
     * @param _quality The quality of token to update
     */
    function setQuality(
        uint256 _tokenId,
        uint8 _quality
    )
        public
    {
        uint16 proto = cardProtos[_tokenId];
        // wont' be able to change mythic season
        uint256 season = protoToSeason[proto];

        require(
            factoryApproved[msg.sender][season],
            "Core: factory can't change quality of this season"
        );

        cardQualities[_tokenId] = _quality;
        emit QualityChanged(_tokenId, _quality, msg.sender);
    }

    function setPropertyManager(
        address _manager
    )
        public 
        onlyOwner 
    {
        propertyManager = _manager;
    }

    function setProperty(
        uint256 _id, 
        bytes32 _key, 
        bytes32 _value
    ) 
        public 
    {
        require(
            msg.sender == propertyManager,
            "Core: must be property manager"
        );

        _setProperty(_id, _key, _value);
    }

    function setClassProperty(
        bytes32 _key, 
        bytes32 _value
    ) 
        public 
    {
        require(
            msg.sender == propertyManager,
            "Core: must be property manager"
        );

        _setClassProperty(_key, _value);
    }

    function _validateAndSaveDetails(
        uint256 start,
        uint16[] memory _protos,
        uint8[] memory _qualities
    )
        internal
    {
        _validateProtos(_protos);

        uint256 cp;
        assembly { cp := cardProtos_slot }
        StorageWrite.uint16s(cp, start, _protos);
        uint256 cq;
        assembly { cq := cardQualities_slot }
        StorageWrite.uint8s(cq, start, _qualities);
    }

    function _validateProto(uint16 proto) internal {
        if (proto >= MYTHIC_THRESHOLD) {
            _checkCanCreateMythic(proto);
        } else {

            uint256 season = protoToSeason[proto];

            require(
                season != 0,
                "Core: must have season set"
            );

            require(
                factoryApproved[msg.sender][season],
                "Core: must be approved factory for this season"
            );
        }
    }

    function _validateProtos(
        uint16[] memory _protos
    )
        internal 
    {
        uint16 maxProto = 0;
        uint16 minProto = MAX_UINT16;
        for (uint256 i = 0; i < _protos.length; i++) {
            uint16 proto = _protos[i];
            if (proto >= MYTHIC_THRESHOLD) {
                _checkCanCreateMythic(proto);
            } else {
                if (proto > maxProto) {
                    maxProto = proto;
                }
                if (minProto > proto) {
                    minProto = proto;
                }
            }
        }

        if (maxProto != 0) {
            uint256 season = protoToSeason[maxProto];
            // cards must be from the same season
            require(
                season != 0,
                "Core: must have season set"
            );

            require(
                season == protoToSeason[minProto],
                "Core: can only create cards from the same season"
            );

            require(
                factoryApproved[msg.sender][season],
                "Core: must be approved factory for this season"
            );
        }
    }

    function _checkCanCreateMythic(uint16 proto) internal {
        require(
            mythicApproved[proto][msg.sender],
            "Core: not approved to create this mythic"
        );

        require(
            !mythicCreated[proto],
            "Core: mythic has already been created"
        );

        mythicCreated[proto] = true;
    }

}

contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

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

contract CardOwnershipTwo is ERC721Enumerable {

    function transferFrom(address from, address to, uint id) public {
        super.transferFrom(from, to, id);
    }

}

contract Governable {

    event Pause();
    event Unpause();

    address public governor;
    bool public paused = false;

    constructor() public {
        governor = msg.sender;
    }

    function setGovernor(address _gov) public onlyGovernor {
        governor = _gov;
    }

    modifier onlyGovernor {
        require(msg.sender == governor);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyGovernor whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyGovernor whenPaused public {
        paused = false;
        emit Unpause();
    }

}

contract CardBase is Governable {

    struct Card {
        uint16 proto;
        uint16 purity;
    }

    function getCard(uint id) public view returns (uint16 proto, uint16 purity) {
        Card memory card = cards[id];
        return (card.proto, card.purity);
    }

    function getShine(uint16 purity) public pure returns (uint8) {
        return uint8(purity / 1000);
    }

    Card[] public cards;
    
}

contract CardProto is CardBase {

    event NewProtoCard(
        uint16 id, uint8 season, uint8 god, 
        Rarity rarity, uint8 mana, uint8 attack, 
        uint8 health, uint8 cardType, uint8 tribe, bool packable
    );

    struct Limit {
        uint64 limit;
        bool exists;
    }

    // limits for mythic cards
    mapping(uint16 => Limit) public limits;

    // can only set limits once
    function setLimit(uint16 id, uint64 limit) public onlyGovernor {
        Limit memory l = limits[id];
        require(!l.exists);
        limits[id] = Limit({
            limit: limit,
            exists: true
        });
    }

    function getLimit(uint16 id) public view returns (uint64 limit, bool set) {
        Limit memory l = limits[id];
        return (l.limit, l.exists);
    }

    // could make these arrays to save gas
    // not really necessary - will be update a very limited no of times
    mapping(uint8 => bool) public seasonTradable;
    mapping(uint8 => bool) public seasonTradabilityLocked;
    uint8 public currentSeason;

    function makeTradable(uint8 season) public onlyGovernor {
        seasonTradable[season] = true;
    }

    function makeUntradable(uint8 season) public onlyGovernor {
        require(!seasonTradabilityLocked[season]);
        seasonTradable[season] = false;
    }

    function makePermanantlyTradable(uint8 season) public onlyGovernor {
        require(seasonTradable[season]);
        seasonTradabilityLocked[season] = true;
    }

    function isTradable(uint16 proto) public view returns (bool) {
        return seasonTradable[protos[proto].season];
    }

    function nextSeason() public onlyGovernor {
        //Seasons shouldn't go to 0 if there is more than the uint8 should hold, the governor should know this ¯\_(ツ)_/¯ -M
        require(currentSeason <= 255); 

        currentSeason++;
        mythic.length = 0;
        legendary.length = 0;
        epic.length = 0;
        rare.length = 0;
        common.length = 0;
    }

    enum Rarity {
        Common,
        Rare,
        Epic,
        Legendary, 
        Mythic
    }

    uint8 constant SPELL = 1;
    uint8 constant MINION = 2;
    uint8 constant WEAPON = 3;
    uint8 constant HERO = 4;

    struct ProtoCard {
        bool exists;
        uint8 god;
        uint8 season;
        uint8 cardType;
        Rarity rarity;
        uint8 mana;
        uint8 attack;
        uint8 health;
        uint8 tribe;
    }

    // there is a particular design decision driving this:
    // need to be able to iterate over mythics only for card generation
    // don't store 5 different arrays: have to use 2 ids
    // better to bear this cost (2 bytes per proto card)
    // rather than 1 byte per instance

    uint16 public protoCount;
    
    mapping(uint16 => ProtoCard) protos;

    uint16[] public mythic;
    uint16[] public legendary;
    uint16[] public epic;
    uint16[] public rare;
    uint16[] public common;

    function addProtos(
        uint16[] memory externalIDs, uint8[] memory gods, Rarity[] memory rarities, uint8[] memory manas, uint8[] memory attacks, 
        uint8[] memory healths, uint8[] memory cardTypes, uint8[] memory tribes, bool[] memory packable
    ) public onlyGovernor returns(uint16) {

        for (uint i = 0; i < externalIDs.length; i++) {

            ProtoCard memory card = ProtoCard({
                exists: true,
                god: gods[i],
                season: currentSeason,
                cardType: cardTypes[i],
                rarity: rarities[i],
                mana: manas[i],
                attack: attacks[i],
                health: healths[i],
                tribe: tribes[i]
            });

            _addProto(externalIDs[i], card, packable[i]);
        }
        
    }

    function addProto(
        uint16 externalID, uint8 god, Rarity rarity, uint8 mana, uint8 attack, uint8 health, uint8 cardType, uint8 tribe, bool packable
    ) public onlyGovernor returns(uint16) {
        ProtoCard memory card = ProtoCard({
            exists: true,
            god: god,
            season: currentSeason,
            cardType: cardType,
            rarity: rarity,
            mana: mana,
            attack: attack,
            health: health,
            tribe: tribe
        });

        _addProto(externalID, card, packable);
    }

    function addWeapon(
        uint16 externalID, uint8 god, Rarity rarity, uint8 mana, uint8 attack, uint8 durability, bool packable
    ) public onlyGovernor returns(uint16) {

        ProtoCard memory card = ProtoCard({
            exists: true,
            god: god,
            season: currentSeason,
            cardType: WEAPON,
            rarity: rarity,
            mana: mana,
            attack: attack,
            health: durability,
            tribe: 0
        });

        _addProto(externalID, card, packable);
    }

    function addSpell(uint16 externalID, uint8 god, Rarity rarity, uint8 mana, bool packable) public onlyGovernor returns(uint16) {

        ProtoCard memory card = ProtoCard({
            exists: true,
            god: god,
            season: currentSeason,
            cardType: SPELL,
            rarity: rarity,
            mana: mana,
            attack: 0,
            health: 0,
            tribe: 0
        });

        _addProto(externalID, card, packable);
    }

    function addMinion(
        uint16 externalID, uint8 god, Rarity rarity, uint8 mana, uint8 attack, uint8 health, uint8 tribe, bool packable
    ) public onlyGovernor returns(uint16) {

        ProtoCard memory card = ProtoCard({
            exists: true,
            god: god,
            season: currentSeason,
            cardType: MINION,
            rarity: rarity,
            mana: mana,
            attack: attack,
            health: health,
            tribe: tribe
        });

        _addProto(externalID, card, packable);
    }

    function _addProto(uint16 externalID, ProtoCard memory card, bool packable) internal {

        require(!protos[externalID].exists);

        card.exists = true;

        protos[externalID] = card;

        protoCount++;

        emit NewProtoCard(
            externalID, currentSeason, card.god, 
            card.rarity, card.mana, card.attack, 
            card.health, card.cardType, card.tribe, packable
        );

        if (packable) {
            Rarity rarity = card.rarity;
            if (rarity == Rarity.Common) {
                common.push(externalID);
            } else if (rarity == Rarity.Rare) {
                rare.push(externalID);
            } else if (rarity == Rarity.Epic) {
                epic.push(externalID);
            } else if (rarity == Rarity.Legendary) {
                legendary.push(externalID);
            } else if (rarity == Rarity.Mythic) {
                mythic.push(externalID);
            } else {
                require(false);
            }
        }
    }

    function getProto(uint16 id) public view returns(
        bool exists, uint8 god, uint8 season, uint8 cardType, Rarity rarity, uint8 mana, uint8 attack, uint8 health, uint8 tribe
    ) {
        ProtoCard memory proto = protos[id];
        return (
            proto.exists,
            proto.god,
            proto.season,
            proto.cardType,
            proto.rarity,
            proto.mana,
            proto.attack,
            proto.health,
            proto.tribe
        );
    }

    function getRandomCard(Rarity rarity, uint16 random) public view returns (uint16) {
        // modulo bias is fine - creates rarity tiers etc
        // will obviously revert is there are no cards of that type: this is expected - should never happen
        if (rarity == Rarity.Common) {
            return common[random % common.length];
        } else if (rarity == Rarity.Rare) {
            return rare[random % rare.length];
        } else if (rarity == Rarity.Epic) {
            return epic[random % epic.length];
        } else if (rarity == Rarity.Legendary) {
            return legendary[random % legendary.length];
        } else if (rarity == Rarity.Mythic) {
            // make sure a mythic is available
            uint16 id;
            uint64 limit;
            bool set;
            for (uint i = 0; i < mythic.length; i++) {
                id = mythic[(random + i) % mythic.length];
                (limit, set) = getLimit(id);
                if (set && limit > 0){
                    return id;
                }
            }
            // if not, they get a legendary :(
            return legendary[random % legendary.length];
        }
        require(false);
        return 0;
    }

    // can never adjust tradable cards
    // each season gets a 'balancing beta'
    // totally immutable: season, rarity
    function replaceProto(
        uint16 index, uint8 god, uint8 cardType, uint8 mana, uint8 attack, uint8 health, uint8 tribe
    ) public onlyGovernor {
        ProtoCard memory pc = protos[index];
        require(!seasonTradable[pc.season]);
        protos[index] = ProtoCard({
            exists: true,
            god: god,
            season: pc.season,
            cardType: cardType,
            rarity: pc.rarity,
            mana: mana,
            attack: attack,
            health: health,
            tribe: tribe
        });
    }

}

contract CardIntegrationTwo is CardOwnershipTwo, CardProto {
    
    address[] public packs;

    event CardCreated(uint indexed id, uint16 proto, uint16 purity, address owner);

    function addPack(address approved) public onlyGovernor {
        packs.push(approved);
    }

    modifier onlyApprovedPacks {
        require(_isApprovedPack());
        _;
    }

    function _isApprovedPack() private view returns (bool) {
        for (uint i = 0; i < packs.length; i++) {
            if (msg.sender == address(packs[i])) {
                return true;
            }
        }
        return false;
    }

    function createCard(address owner, uint16 proto, uint16 purity) public returns (uint) {
        // if (card.rarity == Rarity.Mythic) {
        //     uint64 limit;
        //     bool exists;
        //     (limit, exists) = getLimit(proto);
        //     require(!exists || limit > 0);
        //     limits[proto].limit--;
        // }
        return _createCard(owner, proto, purity);
    }

    function _createCard(address owner, uint16 proto, uint16 purity) internal returns (uint) {
        
        Card memory card = Card({
            proto: proto,
            purity: purity
        });

        uint id = cards.push(card) - 1;

        _mint(owner, id);

        emit CardCreated(id, proto, purity, owner);

        return id;
    }

}

contract BaseMigration {

    function convertPurity(uint16 purity) public pure returns (uint8) {
        return uint8(4 - (purity / 1000));
    }

    function convertProto(uint16 proto) public view returns (uint16) {
        if (proto >= 1 && proto <= 377) {
            return proto;
        }
        // first phoenix
        if (proto == 380) {
            return 400;
        }
        // light's bidding
        if (proto == 381) {
            return 401;
        }
        // chimera
        if (proto == 394) {
            return 402;
        }
        // etherbots
        (bool found, uint index) = getEtherbotsIndex(proto);
        if (found) {
            return uint16(380 + index);
        }
        // hyperion
        if (proto == 378) {
            return 65000;
        }
        // prometheus
        if (proto == 379) {
            return 65001;
        }
        // atlas
        if (proto == 383) {
            return 65002;
        }
        // tethys
        if (proto == 384) {
            return 65003;
        }
        require(false, "unrecognised proto");
    }

    uint16[] internal ebs = [400, 413, 414, 421, 427, 428, 389, 415, 416, 422, 424, 425, 426, 382, 420, 417];

    function getEtherbotsIndex(uint16 proto) public view returns (bool, uint16) {
        for (uint16 i = 0; i < ebs.length; i++) {
            if (ebs[i] == proto) {
                return (true, i);
            }
        }
        return (false, 0);
    }

}

contract EtherbotsMigration is BaseMigration {

    // The old cards contract
    CardIntegrationTwo public oldCards;

    // The new cards contract to migrate to
    Cards public newCards;

    // Keep track of migrated cards
    mapping (uint => bool) public hasMigrated;

    constructor(address _oldCardsAddress, address _newCardsAddress) public {
        oldCards = CardIntegrationTwo(_oldCardsAddress);
        newCards = Cards(_newCardsAddress);
    }

    event Migrated(
        uint tokenId,
        address owner,
        uint16 proto,
        uint8 quality
    );

    /**
     * @dev Migrate multiple tokens at once.
     *
     * @param _tokenIds List of tokens to migrate
     */
    function migrateMultiple(
        uint[] memory _tokenIds
    )
        public
    {
        for (uint i = 0; i < _tokenIds.length; i++) {
            migrate(_tokenIds[i]);
        }
    }

    /**
     * @dev Migrate Etherbot cards from the old Cards contract to the new one.
     *
     * @param _tokenId The id of the Etherbots card
     */
    function migrate(
        uint _tokenId
    ) public {

        address originalOwner = oldCards.ownerOf(_tokenId);

        require(
            hasMigrated[_tokenId] == false,
            "Etherbots Migration: has already migrated Etherbot"
        );

        (uint16 proto, uint16 purity) = oldCards.getCard(_tokenId);

        uint16 convertedProto = convertProto(proto);
        uint8 convertedQuality = convertPurity(purity);

        hasMigrated[_tokenId] = true;

        newCards.mintCard(originalOwner, convertedProto, convertedQuality);

        emit Migrated(_tokenId, originalOwner, convertedProto, convertedQuality);
    }
}