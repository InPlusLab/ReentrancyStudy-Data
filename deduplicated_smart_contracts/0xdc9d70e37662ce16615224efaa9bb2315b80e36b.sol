/**
 *Submitted for verification at Etherscan.io on 2021-09-07
*/

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol



pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol



pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol



pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol



pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol



pragma solidity ^0.8.0;


/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol



pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File: @chainlink/contracts/src/v0.8/VRFRequestIDBase.sol


pragma solidity ^0.8.0;

contract VRFRequestIDBase {

  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}
// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol


pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );

  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );

  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );

  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;

  function name()
    external
    view
    returns (
      string memory tokenName
    );

  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );

  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

}

// File: @chainlink/contracts/src/v0.8/VRFConsumerBase.sol


pragma solidity ^0.8.0;



/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



// File: @openzeppelin/contracts/token/ERC1155/ERC1155.sol



pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol



pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol



// File: contracts/LootDungeon.sol


pragma solidity ^0.8.0;








contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract LootDungeon is ERC1155, VRFConsumerBase, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    /**
     * LOOT
     */
    uint256 public constant GENESIS_CARD = 0;
    uint256 public constant ESCAPE_CARD = 1;
    uint256 public constant FERRYMAN_CARD = 2;
    uint256 public constant RAT_MEAT = 3;
    uint256 public constant RAT_CARD = 4;
    uint256 public constant SKELETON_BONES = 5;
    uint256 public constant SKELETON_CARD = 6;
    uint256 public constant MINOTAUR_HORNS = 7;
    uint256 public constant MINOTAUR_CARD = 8;
    uint256 public constant SUCCUBUS_WINGS = 9;
    uint256 public constant SUCCUBUS_CARD = 10;
    uint256 public constant DEMON_HEAD = 11;
    uint256 public constant DEMON_CARD = 12;
    uint256 public constant DRAGON_EYE = 13;
    uint256 public constant DRAGON_CARD = 14;

    struct Monster {
        string name;
        uint256 id;
        uint256 hp;
        uint256 armor;
        uint256 attack;
        uint256 agility;
        uint256 dexterity;
        uint256 guaranteedDrop;
        uint256 luckyDrop;
    }

    struct Item {
        uint256 hp;
        uint256 armor;
        uint256 attack;
        uint256 agility;
        uint256 dexterity;
    }

    struct BattleRoundResult {
        bool hasNextRound;
        bool won;
        int256 playerHp;
        int256 monsterHp;
    }

    uint256 public constant RAT_ID = 1;
    uint256 public constant SKELETON_ID = 2;
    uint256 public constant MINOTAUR_ID = 3;
    uint256 public constant SUCCUBUS_ID = 4;
    uint256 public constant DEMON_ID = 5;
    uint256 public constant DRAGON_ID = 6;

    Monster Rat =
        Monster("Sewer Rat", RAT_ID, 10, 0, 5, 4, 3, RAT_MEAT, RAT_CARD);
    Monster Skeleton =
        Monster(
            "Skeleton Warrior",
            SKELETON_ID,
            12,
            1,
            7,
            4,
            2,
            SKELETON_BONES,
            SKELETON_CARD
        );
    Monster Minotaur =
        Monster(
            "Minotaur Archer",
            MINOTAUR_ID,
            16,
            2,
            10,
            7,
            7,
            MINOTAUR_HORNS,
            MINOTAUR_CARD
        );
    Monster Succubus =
        Monster(
            "Succubus",
            SUCCUBUS_ID,
            10,
            2,
            20,
            12,
            5,
            SUCCUBUS_WINGS,
            SUCCUBUS_CARD
        );
    Monster Demon =
        Monster("Demon", DEMON_ID, 15, 4, 15, 5, 20, DEMON_HEAD, DEMON_CARD);
    Monster Dragon =
        Monster(
            "Fire Dragon",
            DRAGON_ID,
            30,
            5,
            25,
            0,
            0,
            DRAGON_EYE,
            DRAGON_CARD
        );

    Monster[6] public monsterArray;

    uint256 private constant DICE_PRECISION = 2**128;
    uint256 private constant ROLL_IN_PROGRESS = DICE_PRECISION + 1;

    uint256 public constant LOOT_TIME_LOCK = 1 days;

    uint256 public constant LUCKY_DROP_CHANCE_1_IN = 10;

    uint8 public constant ESCAPE_NFT_UNCLAIMABLE = 0;
    uint8 public constant ESCAPE_NFT_READY_TO_CLAIM = 1;
    uint8 public constant ESCAPE_NFT_CLAIMED = 2;

    uint8 public constant FERRYMAN_NFT_UNCLAIMABLE = 0;
    uint8 public constant FERRYMAN_NFT_READY_TO_CLAIM = 1;
    uint8 public constant FERRYMAN_NFT_CLAIMED = 2;

    mapping(uint256 => uint256) public remainingMonsterCount;

    bytes32 private s_keyHash;
    uint256 private s_fee;
    bool private isTestNetwork;

    uint256 public escapePrice = 0.04 ether;
    uint256 public battlePrice = 0.02 ether;
    uint256 public ferrymanCurrentPrice = 0.05 ether;
    uint256 public ferrymanPriceIncreasePerAttempt = 0.005 ether;

    Item public basePlayerStats = Item(10, 0, 2, 1, 1);
    bool public lockSettings = false;
    uint256 public maxRoundsPerBattle = 7;

    address public proxyRegistryAddress;
    address public lootAddress; // 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7;

    mapping(uint256 => address) public lootOwners;
    mapping(uint256 => uint256) public lootTimeLock;
    mapping(uint256 => uint256) public tokenIdToEnterDungeonRollResult;
    mapping(uint256 => Monster) private tokenIdEncounteredMonster;
    mapping(address => uint8) private escapeNftClaimedState;
    mapping(address => uint8) private ferrymanCardClaimedState;
    mapping(uint256 => uint256) public agreedFerrymanPrice;

    mapping(uint256 => uint256) public tokenIdToMonsterBattleRollResult;
    mapping(bytes32 => uint256) private requestIdToTokenId;

    event EnteredDungeon(
        uint256 indexed tokenId,
        address indexed playerAddress,
        uint256 indexed encounteredMonster
    );

    event StartedBattle(uint256 indexed tokenId, address indexed playerAddress);

    event VrfResponseArrived(uint256 indexed tokenId);

    event WonBattle(uint256 indexed tokenId, address indexed playerAddress);

    event BribedTheFerryman(
        uint256 indexed tokenId,
        address indexed playerAddress
    );

    constructor(
        address vrfCoordinator,
        address link,
        bytes32 keyHash,
        uint256 fee,
        address _proxyRegistryAddress,
        address _lootAddress,
        bool _isTestNetwork
    )
        ERC1155("https://lootdungeon.app/api/item/{id}")
        VRFConsumerBase(vrfCoordinator, link)
    {
        s_keyHash = keyHash;
        s_fee = fee;

        remainingMonsterCount[Rat.id] = 2000;
        remainingMonsterCount[Skeleton.id] = 1000;
        remainingMonsterCount[Minotaur.id] = 700;
        remainingMonsterCount[Succubus.id] = 350;
        remainingMonsterCount[Demon.id] = 100;
        remainingMonsterCount[Dragon.id] = 50;

        monsterArray[0] = Rat;
        monsterArray[1] = Skeleton;
        monsterArray[2] = Minotaur;
        monsterArray[3] = Succubus;
        monsterArray[4] = Demon;
        monsterArray[5] = Dragon;

        proxyRegistryAddress = _proxyRegistryAddress;
        lootAddress = _lootAddress;

        isTestNetwork = _isTestNetwork;

        _mint(msg.sender, GENESIS_CARD, 5, "");

        // Mint one of each NFT
        _mint(msg.sender, ESCAPE_CARD, 1, "");
        _mint(msg.sender, FERRYMAN_CARD, 1, "");
        _mint(msg.sender, RAT_MEAT, 1, "");
        _mint(msg.sender, RAT_CARD, 1, "");
        _mint(msg.sender, SKELETON_BONES, 1, "");
        _mint(msg.sender, SKELETON_CARD, 1, "");
        _mint(msg.sender, MINOTAUR_HORNS, 1, "");
        _mint(msg.sender, MINOTAUR_CARD, 1, "");
        _mint(msg.sender, SUCCUBUS_WINGS, 1, "");
        _mint(msg.sender, SUCCUBUS_CARD, 1, "");
        _mint(msg.sender, DEMON_HEAD, 1, "");
        _mint(msg.sender, DEMON_CARD, 1, "");
        _mint(msg.sender, DRAGON_EYE, 1, "");
        _mint(msg.sender, DRAGON_CARD, 1, "");
    }

    modifier onlyIfEnoughLink() {
        if (isTestNetwork == false) {
            require(
                LINK.balanceOf(address(this)) >= s_fee,
                "Not enough LINK to pay fee"
            );
        }
        _;
    }

    modifier onlyLootBagOwner(uint256 tokenId) {
        require(
            lootOwners[tokenId] == _msgSender(),
            "You do not have permissions to use this loot bag"
        );
        _;
    }

    modifier onlyIfNotLocked() {
        require(lockSettings == false, "The contract settings are locked");
        _;
    }

    modifier onlyLootBagOwnerBeforeTimelock(uint256 tokenId) {
        require(lootOwners[tokenId] == _msgSender());
        require(block.timestamp <= lootTimeLock[tokenId]);
        _;
    }

    modifier onlyIfBattleFinished(uint256 tokenId) {
        require(
            tokenIdToMonsterBattleRollResult[tokenId] != uint256(0x0),
            "You have not started the battle yet"
        );

        require(
            tokenIdToMonsterBattleRollResult[tokenId] != ROLL_IN_PROGRESS,
            "Waiting for VRF to supply a random number"
        );

        _;
    }

    function hasEnoughLink() public view returns (bool) {
        return LINK.balanceOf(address(this)) >= s_fee;
    }

    function getLootOwner(uint256 tokenId) public view returns (address) {
        return lootOwners[tokenId];
    }

    function _getRolledMonster(uint256 rollResult)
        internal
        view
        returns (Monster memory)
    {
        uint256 totalMonsters = getRemainingMonsterCount();
        require(totalMonsters > 0, "All monsters have been slayed.");

        uint256 boundedResult = rollResult.sub(1).mod(totalMonsters);

        uint256 cap = 0;
        for (uint256 i = 0; i < monsterArray.length; i++) {
            Monster memory currMonster = monsterArray[i];

            cap += remainingMonsterCount[currMonster.id];
            if (boundedResult < cap) {
                return currMonster;
            }
        }

        revert("Shouldnt get to this point x__x");
    }

    function getEncounteredMonster(uint256 tokenId)
        public
        view
        returns (Monster memory)
    {
        require(
            hasEnteredTheDungeon(tokenId),
            "You are not in the dungeon yet"
        );

        return tokenIdEncounteredMonster[tokenId];
    }

    function getRemainingMonsterCount() public view returns (uint256) {
        uint256 totalMonsters = 0;

        for (uint256 i = 0; i < monsterArray.length; i++) {
            totalMonsters += remainingMonsterCount[monsterArray[i].id];
        }

        return totalMonsters;
    }

    function hasEnteredTheDungeon(uint256 tokenId) public view returns (bool) {
        return tokenIdToEnterDungeonRollResult[tokenId] != uint256(0x0);
    }

    function hasFinishedBattle(uint256 tokenId) public view returns (bool) {
        return
            tokenIdToMonsterBattleRollResult[tokenId] != uint256(0x0) &&
            tokenIdToMonsterBattleRollResult[tokenId] != ROLL_IN_PROGRESS;
    }

    function hasStartedBattle(uint256 tokenId) public view returns (bool) {
        return tokenIdToMonsterBattleRollResult[tokenId] != uint256(0x0);
    }

    /**
     * Requires the owner of the loot bag to approve the transfer first.
     */
    function enterTheDungeon(uint256 tokenId) external nonReentrant {
        require(
            getRemainingMonsterCount() > 0,
            "All monsters have been slayed"
        );

        IERC721 lootContract = IERC721(lootAddress);

        // If the contract is not already the owner of the loot bag, transfer it to this contract.
        if (lootContract.ownerOf(tokenId) != address(this)) {
            lootContract.transferFrom(_msgSender(), address(this), tokenId);
            lootOwners[tokenId] = _msgSender();
            lootTimeLock[tokenId] = block.timestamp + LOOT_TIME_LOCK;
            agreedFerrymanPrice[tokenId] = ferrymanCurrentPrice;
            ferrymanCurrentPrice += ferrymanPriceIncreasePerAttempt;
        }

        require(
            lootOwners[tokenId] == _msgSender(),
            "You do not own this loot bag"
        );
        require(
            hasEnteredTheDungeon(tokenId) == false,
            "You are already in the dungeon"
        );

        _monsterEncounter(
            tokenId,
            _pseudorandom(string(abi.encodePacked(tokenId)), true)
        );
    }

    function _monsterEncounter(uint256 tokenId, uint256 randomness) internal {
        uint256 rollResult = randomness.mod(DICE_PRECISION).add(1); // Add 1 to distinguish from not-rolled state in edge-case (rng = 0)
        tokenIdToEnterDungeonRollResult[tokenId] = rollResult;

        Monster memory rolledMonster = _getRolledMonster(rollResult);
        tokenIdEncounteredMonster[tokenId] = rolledMonster;
        remainingMonsterCount[rolledMonster.id] = remainingMonsterCount[
            rolledMonster.id
        ].sub(1);

        emit EnteredDungeon(tokenId, _msgSender(), rolledMonster.id);
    }

    function escapeFromDungeon(uint256 tokenId)
        external
        payable
        onlyLootBagOwner(tokenId)
        nonReentrant
    {
        require(
            hasEnteredTheDungeon(tokenId),
            "You have not entered the dungeon yet"
        );
        require(
            hasStartedBattle(tokenId) == false,
            "You can't escape from a battle that already started"
        );
        require(
            msg.value >= escapePrice,
            "The amount of eth paid is not enough to escape from this battle"
        );
        Monster memory currMonster = tokenIdEncounteredMonster[tokenId];
        remainingMonsterCount[currMonster.id] = remainingMonsterCount[
            currMonster.id
        ].add(1);
        _exitDungeon(tokenId);

        // If it's the first escape, allow claiming escape NFT
        if (escapeNftClaimedState[_msgSender()] == ESCAPE_NFT_UNCLAIMABLE) {
            escapeNftClaimedState[_msgSender()] = ESCAPE_NFT_READY_TO_CLAIM;
        }
    }

    function _exitDungeon(uint256 tokenId) internal {
        address ogOwner = lootOwners[tokenId];
        lootOwners[tokenId] = address(0x0);
        tokenIdToEnterDungeonRollResult[tokenId] = uint256(0x0);
        tokenIdToMonsterBattleRollResult[tokenId] = uint256(0x0);
        lootTimeLock[tokenId] = uint256(0x0);
        agreedFerrymanPrice[tokenId] = uint256(0x0);

        IERC721 lootContract = IERC721(lootAddress);
        lootContract.transferFrom(address(this), ogOwner, tokenId);
    }

    function battleMonster(uint256 tokenId)
        external
        payable
        onlyIfEnoughLink
        onlyLootBagOwner(tokenId)
        nonReentrant
        returns (bytes32 requestId)
    {
        require(
            hasEnteredTheDungeon(tokenId),
            "You have not entered the dungeon yet"
        );
        require(
            hasStartedBattle(tokenId) == false,
            "The battle already started"
        );
        require(
            msg.value >= battlePrice,
            "The amount of eth paid is not enough to fight this battle"
        );

        if (isTestNetwork) {
            requestId = 0;
        } else {
            requestId = requestRandomness(s_keyHash, s_fee);
        }
        requestIdToTokenId[requestId] = tokenId;
        tokenIdToMonsterBattleRollResult[tokenId] = ROLL_IN_PROGRESS;

        if (isTestNetwork) {
            fulfillRandomness(requestId, tokenId);
        }

        emit StartedBattle(tokenId, _msgSender());

        return requestId;
    }

    function checkBattleResultsNoCache(
        uint256 tokenId,
        uint256 round,
        int256 lastRoundPlayerHp,
        int256 lastRoundMonsterHp
    )
        public
        view
        onlyIfBattleFinished(tokenId)
        returns (BattleRoundResult memory)
    {
        Item memory playerBaseStats = getStats(tokenId);
        return
            checkBattleResults(
                tokenId,
                round,
                lastRoundPlayerHp,
                lastRoundMonsterHp,
                playerBaseStats
            );
    }

    function checkBattleResults(
        uint256 tokenId,
        uint256 round,
        int256 lastRoundPlayerHp,
        int256 lastRoundMonsterHp,
        Item memory playerBaseStats
    )
        public
        view
        onlyIfBattleFinished(tokenId)
        returns (BattleRoundResult memory)
    {
        if (round > maxRoundsPerBattle - 1) {
            // Player wins by forfeit
            return
                BattleRoundResult(
                    false,
                    true,
                    lastRoundPlayerHp,
                    lastRoundMonsterHp
                );
        }

        bool hasNextRound = true;
        bool won = false;

        uint256 monsterDamage = _getMonsterDamage(
            tokenId,
            round,
            playerBaseStats
        );
        uint256 playerDamage = _getPlayerDamage(
            tokenId,
            round,
            playerBaseStats
        );

        int256 monsterHp = lastRoundMonsterHp - int256(monsterDamage);
        int256 playerHp = lastRoundPlayerHp - int256(playerDamage);

        if (playerHp <= 0 || monsterHp <= 0) {
            hasNextRound = false;
        }

        if (playerHp > 0 && monsterHp <= 0) {
            won = true;
        }

        return BattleRoundResult(hasNextRound, won, playerHp, monsterHp);
    }

    function _getMonsterDamage(
        uint256 tokenId,
        uint256 round,
        Item memory playerStats
    ) internal view returns (uint256 damage) {
        uint256 randomSeed = tokenIdToMonsterBattleRollResult[tokenId];
        Monster memory currMonster = tokenIdEncounteredMonster[tokenId];

        uint256 playerAccuracyRoll = _pseudorandom(
            string(abi.encodePacked(randomSeed, "player", round)),
            false
        ).mod(20).add(1);

        // Player miss
        if (playerAccuracyRoll + playerStats.dexterity < currMonster.agility) {
            return 0;
        }

        uint256 playerAttackRoll = _pseudorandom(
            string(abi.encodePacked(randomSeed, "playerAttack", round)),
            false
        ).mod(playerStats.attack).add(1);

        if (playerAttackRoll > currMonster.armor) {
            return playerAttackRoll.sub(currMonster.armor);
        }

        return 0;
    }

    function _getPlayerDamage(
        uint256 tokenId,
        uint256 round,
        Item memory playerStats
    ) internal view returns (uint256 damage) {
        uint256 randomSeed = tokenIdToMonsterBattleRollResult[tokenId];
        Monster memory currMonster = tokenIdEncounteredMonster[tokenId];

        uint256 monsterAccuracyRoll = _pseudorandom(
            string(abi.encodePacked(randomSeed, "monster", round)),
            false
        ).mod(20).add(1);

        // Monster miss
        if (monsterAccuracyRoll + currMonster.dexterity < playerStats.agility) {
            return 0;
        }

        uint256 monsterAttackRoll = _pseudorandom(
            string(abi.encodePacked(randomSeed, "monsterAttack", round)),
            false
        ).mod(currMonster.attack).add(1);

        if (monsterAttackRoll > playerStats.armor) {
            return monsterAttackRoll.sub(playerStats.armor);
        }

        return 0;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        uint256 tokenId = requestIdToTokenId[requestId];
        uint256 rollResult = randomness.mod(DICE_PRECISION).add(1); // Add 1 to distinguish from not-rolled state in edge-case (rng = 0)
        tokenIdToMonsterBattleRollResult[tokenId] = rollResult;
        emit VrfResponseArrived(tokenId);
    }

    function claimDrops(uint256 tokenId)
        external
        onlyLootBagOwner(tokenId)
        onlyIfBattleFinished(tokenId)
        nonReentrant
    {
        Item memory playerBaseStats = getStats(tokenId);
        Monster memory currMonster = tokenIdEncounteredMonster[tokenId];
        bool hasNextRound = true;
        bool won = false;
        int256 playerHp = int256(playerBaseStats.hp);
        int256 monsterHp = int256(currMonster.hp);
        uint256 round = 0;

        while (hasNextRound) {
            BattleRoundResult memory result = checkBattleResults(
                tokenId,
                round,
                playerHp,
                monsterHp,
                playerBaseStats
            );
            hasNextRound = result.hasNextRound;
            won = result.won;
            playerHp = result.playerHp;
            monsterHp = result.monsterHp;
            round++;
        }

        if (won) {
            emit WonBattle(tokenId, _msgSender());

            _mintMonsterLoot(tokenId);
            return _exitDungeon(tokenId);
        }

        revert("You cannot claim rewards if you did not win the battle");
    }

    function _mintMonsterLoot(uint256 tokenId) internal {
        Monster memory currMonster = tokenIdEncounteredMonster[tokenId];
        uint256 randomSeed = tokenIdToMonsterBattleRollResult[tokenId];

        uint256 luckyDropRoll = _pseudorandom(
            string(abi.encodePacked(randomSeed, "luckyDrop")),
            false
        ).mod(LUCKY_DROP_CHANCE_1_IN).add(1);

        _mint(_msgSender(), currMonster.guaranteedDrop, 1, "");

        if (luckyDropRoll <= 1) {
            _mint(_msgSender(), currMonster.luckyDrop, 1, "");
        }
    }

    function bribeFerryman(uint256 tokenId)
        external
        payable
        onlyLootBagOwnerBeforeTimelock(tokenId)
        onlyIfBattleFinished(tokenId)
        nonReentrant
    {
        require(
            msg.value >= agreedFerrymanPrice[tokenId],
            "The amount of eth paid is not enough to bribe the ferryman"
        );

        // If it's the first ferryman, allow claiming ferryman NFT
        if (
            ferrymanCardClaimedState[_msgSender()] == FERRYMAN_NFT_UNCLAIMABLE
        ) {
            ferrymanCardClaimedState[
                _msgSender()
            ] = FERRYMAN_NFT_READY_TO_CLAIM;
        }

        emit BribedTheFerryman(tokenId, _msgSender());

        _exitDungeon(tokenId);
    }

    function claimEscapeCard() external {
        require(canClaimEscapeCard(), "Escape NFT not ready to be claimed");
        escapeNftClaimedState[_msgSender()] = ESCAPE_NFT_CLAIMED;

        _mint(_msgSender(), ESCAPE_CARD, 1, "");
    }

    function claimFerrymanCard() external {
        require(
            canClaimFerrymanCard(),
            "Ferryman Card not ready to be claimed"
        );
        ferrymanCardClaimedState[_msgSender()] = FERRYMAN_NFT_CLAIMED;

        _mint(_msgSender(), FERRYMAN_CARD, 1, "");
    }

    function canClaimEscapeCard() public view returns (bool) {
        return escapeNftClaimedState[_msgSender()] == ESCAPE_NFT_READY_TO_CLAIM;
    }

    function canClaimFerrymanCard() public view returns (bool) {
        return
            ferrymanCardClaimedState[_msgSender()] ==
            FERRYMAN_NFT_READY_TO_CLAIM;
    }

    function _pseudorandom(string memory input, bool varyEachBlock)
        internal
        view
        returns (uint256)
    {
        bytes32 blockComponent = 0;
        if (!isTestNetwork && varyEachBlock) {
            // Remove randomness in tests
            blockComponent = blockhash(block.number);
        }
        return uint256(keccak256(abi.encodePacked(input, blockComponent)));
    }

    function _lootOgRandom(string memory input)
        internal
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    /**
     * WEAPON: Atk
     * CHEST: Armor
     * HEAD: HP
     * WAIST: HP
     * FOOT: AGI
     * HAND: DEX
     * NECK: Random
     * RING: Random
     */
    function getStats(uint256 tokenId) public view returns (Item memory) {
        uint256 hpBonus = (_lootOgRandom(
            string(abi.encodePacked("HEAD", toString(tokenId)))
        ) % 21) +
            (_lootOgRandom(
                string(abi.encodePacked("WAIST", toString(tokenId)))
            ) % 21);

        uint256 armorBonus = _lootOgRandom(
            string(abi.encodePacked("CHEST", toString(tokenId)))
        ) % 21;

        uint256 attackBonus = _lootOgRandom(
            string(abi.encodePacked("WEAPON", toString(tokenId)))
        ) % 21;

        uint256 agiBonus = _lootOgRandom(
            string(abi.encodePacked("FOOT", toString(tokenId)))
        ) % 21;

        uint256 dexBonus = _lootOgRandom(
            string(abi.encodePacked("HAND", toString(tokenId)))
        ) % 21;

        uint256 neckBonus = _lootOgRandom(
            string(abi.encodePacked("NECK", toString(tokenId)))
        ) % 21;

        uint256 ringBonus = _lootOgRandom(
            string(abi.encodePacked("RING", toString(tokenId)))
        ) % 21;

        if (neckBonus < 4) {
            dexBonus += ringBonus / 3 + 1;
        } else if (neckBonus < 8) {
            agiBonus += ringBonus / 3 + 1;
        } else if (neckBonus < 12) {
            hpBonus += ringBonus / 3 + 1;
        } else if (neckBonus < 16) {
            attackBonus += ringBonus / 4 + 1;
        } else {
            armorBonus += ringBonus / 5 + 1;
        }

        return
            Item(
                basePlayerStats.hp + hpBonus / 2,
                basePlayerStats.armor + armorBonus / 4,
                basePlayerStats.attack + attackBonus / 2,
                basePlayerStats.agility + agiBonus / 2,
                basePlayerStats.dexterity + dexBonus / 2
            );
    }

    // OpenSea stuff
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        return owner() == _owner && _isOwnerOrProxy(_operator);
    }

    function _isOwnerOrProxy(address _address) internal view returns (bool) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return
            owner() == _address ||
            address(proxyRegistry.proxies(owner())) == _address;
    }

    function setProxyRegistryAddress(address _proxyRegistryAddress)
        public
        onlyOwner
    {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    // Withdraw stuff
    function withdrawEth() external onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function withdrawToken(address _tokenContract, uint256 amount)
        external
        onlyOwner
    {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(owner(), amount);
    }

    function withdrawLoot(uint256 tokenId) external onlyOwner {
        require(
            block.timestamp >= lootTimeLock[tokenId],
            "Can't withdraw time-locked loot"
        );

        IERC721 lootContract = IERC721(lootAddress);
        lootOwners[tokenId] = address(0x0);
        tokenIdToEnterDungeonRollResult[tokenId] = uint256(0x0);
        tokenIdToMonsterBattleRollResult[tokenId] = uint256(0x0);
        lootTimeLock[tokenId] = uint256(0x0);
        lootContract.transferFrom(address(this), owner(), tokenId);
    }

    // Adjust params
    function setEscapePrice(uint256 newPrice)
        external
        onlyOwner
        onlyIfNotLocked
    {
        escapePrice = newPrice;
    }

    function setBattlePrice(uint256 newPrice)
        external
        onlyOwner
        onlyIfNotLocked
    {
        battlePrice = newPrice;
    }

    function setFerrymanPrice(uint256 newPrice, uint256 newIncrease)
        external
        onlyOwner
        onlyIfNotLocked
    {
        ferrymanCurrentPrice = newPrice;
        ferrymanPriceIncreasePerAttempt = newIncrease;
    }

    function setLinkFee(uint256 newFee) external onlyOwner {
        s_fee = newFee;
    }

    function adjustPlayerStats(Item memory newStats)
        external
        onlyOwner
        onlyIfNotLocked
    {
        basePlayerStats = newStats;
    }

    function adjustMonster(Monster memory adjustedMonster, uint256 monsterIndex)
        external
        onlyOwner
        onlyIfNotLocked
    {
        monsterArray[monsterIndex] = adjustedMonster;
    }

    function adjustMaxRounds(uint256 maxRounds)
        external
        onlyOwner
        onlyIfNotLocked
    {
        maxRoundsPerBattle = maxRounds;
    }

    function setUri(string memory newUri) external onlyOwner {
        _setURI(newUri);
    }

    function lockFromAdditionalChanges() external onlyOwner onlyIfNotLocked {
        lockSettings = true;
    }

    // Lib
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}