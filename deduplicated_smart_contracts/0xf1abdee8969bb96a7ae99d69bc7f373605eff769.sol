/**
 *Submitted for verification at Etherscan.io on 2021-09-14
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-27
 */

// SPDX-License-Identifier: MIT

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






/**
 * @dev Required interface of an ERC721 compliant contract.
 */
 interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `ennemyId` token is transferred from `from` to `to`.
     */
     event Transfer(address indexed from, address indexed to, uint256 indexed ennemyId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `ennemyId` token.
     */
     event Approval(address indexed owner, address indexed approved, uint256 indexed ennemyId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
     event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
     function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `ennemyId` token.
     *
     * Requirements:
     *
     * - `ennemyId` must exist.
     */
     function ownerOf(uint256 ennemyId) external view returns (address owner);

    /**
     * @dev Safely transfers `ennemyId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `ennemyId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
     function safeTransferFrom(
        address from,
        address to,
        uint256 ennemyId
        ) external;

    /**
     * @dev Transfers `ennemyId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `ennemyId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
     function transferFrom(
        address from,
        address to,
        uint256 ennemyId
        ) external;

    /**
     * @dev Gives permission to `to` to transfer `ennemyId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `ennemyId` must exist.
     *
     * Emits an {Approval} event.
     */
     function approve(address to, uint256 ennemyId) external;

    /**
     * @dev Returns the account approved for `ennemyId` token.
     *
     * Requirements:
     *
     * - `ennemyId` must exist.
     */
     function getApproved(uint256 ennemyId) external view returns (address operator);

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
     * @dev Safely transfers `ennemyId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `ennemyId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
     function safeTransferFrom(
        address from,
        address to,
        uint256 ennemyId,
        bytes calldata data
        ) external;
 }




/**
 * @dev String operations.
 */
 library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
     function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
     function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
     function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




/*
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














/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
 interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `ennemyId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
     function onERC721Received(
        address operator,
        address from,
        uint256 ennemyId,
        bytes calldata data
        ) external returns (bytes4);
 }







/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
 interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
     function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
     function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `ennemyId` token.
     */
     function tokenURI(uint256 ennemyId) external view returns (string memory);
 }





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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
        ) private pure returns (bytes memory) {
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


/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
 contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
     constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
     function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
     function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
     function ownerOf(uint256 ennemyId) public view virtual override returns (address) {
        address owner = _owners[ennemyId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
     function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
     function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
     function tokenURI(uint256 ennemyId) public view virtual override returns (string memory) {
        require(_exists(ennemyId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, ennemyId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `ennemyId`. Empty
     * by default, can be overriden in child contracts.
     */
     function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
     function approve(address to, uint256 ennemyId) public virtual override {
        address owner = ERC721.ownerOf(ennemyId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
            );

        _approve(to, ennemyId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
     function getApproved(uint256 ennemyId) public view virtual override returns (address) {
        require(_exists(ennemyId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[ennemyId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
     function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
     function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
     function transferFrom(
        address from,
        address to,
        uint256 ennemyId
        ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), ennemyId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, ennemyId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
     function safeTransferFrom(
        address from,
        address to,
        uint256 ennemyId
        ) public virtual override {
        safeTransferFrom(from, to, ennemyId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
     function safeTransferFrom(
        address from,
        address to,
        uint256 ennemyId,
        bytes memory _data
        ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), ennemyId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, ennemyId, _data);
    }

    /**
     * @dev Safely transfers `ennemyId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `ennemyId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
     function _safeTransfer(
        address from,
        address to,
        uint256 ennemyId,
        bytes memory _data
        ) internal virtual {
        _transfer(from, to, ennemyId);
        require(_checkOnERC721Received(from, to, ennemyId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `ennemyId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
     function _exists(uint256 ennemyId) internal view virtual returns (bool) {
        return _owners[ennemyId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `ennemyId`.
     *
     * Requirements:
     *
     * - `ennemyId` must exist.
     */
     function _isApprovedOrOwner(address spender, uint256 ennemyId) internal view virtual returns (bool) {
        require(_exists(ennemyId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(ennemyId);
        return (spender == owner || getApproved(ennemyId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `ennemyId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `ennemyId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
     function _safeMint(address to, uint256 ennemyId) internal virtual {
        _safeMint(to, ennemyId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
     function _safeMint(
        address to,
        uint256 ennemyId,
        bytes memory _data
        ) internal virtual {
        _mint(to, ennemyId);
        require(
            _checkOnERC721Received(address(0), to, ennemyId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
            );
    }

    /**
     * @dev Mints `ennemyId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `ennemyId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
     function _mint(address to, uint256 ennemyId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(ennemyId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, ennemyId);

        _balances[to] += 1;
        _owners[ennemyId] = to;

        emit Transfer(address(0), to, ennemyId);
    }

    /**
     * @dev Destroys `ennemyId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `ennemyId` must exist.
     *
     * Emits a {Transfer} event.
     */
     function _burn(uint256 ennemyId) internal virtual {
        address owner = ERC721.ownerOf(ennemyId);

        _beforeTokenTransfer(owner, address(0), ennemyId);

        // Clear approvals
        _approve(address(0), ennemyId);

        _balances[owner] -= 1;
        delete _owners[ennemyId];

        emit Transfer(owner, address(0), ennemyId);
    }

    /**
     * @dev Transfers `ennemyId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `ennemyId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
     function _transfer(
        address from,
        address to,
        uint256 ennemyId
        ) internal virtual {
        require(ERC721.ownerOf(ennemyId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, ennemyId);

        // Clear approvals from the previous owner
        _approve(address(0), ennemyId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[ennemyId] = to;

        emit Transfer(from, to, ennemyId);
    }

    /**
     * @dev Approve `to` to operate on `ennemyId`
     *
     * Emits a {Approval} event.
     */
     function _approve(address to, uint256 ennemyId) internal virtual {
        _tokenApprovals[ennemyId] = to;
        emit Approval(ERC721.ownerOf(ennemyId), to, ennemyId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param ennemyId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
     function _checkOnERC721Received(
        address from,
        address to,
        uint256 ennemyId,
        bytes memory _data
        ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, ennemyId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `ennemyId` will be
     * transferred to `to`.
     * - When `from` is zero, `ennemyId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `ennemyId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 ennemyId
        ) internal virtual {}
 }







/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
 interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
     function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
     function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 ennemyId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
     function tokenByIndex(uint256 index) external view returns (uint256);
 }


/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
 abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
     function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
     function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
     function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
     function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `ennemyId` will be
     * transferred to `to`.
     * - When `from` is zero, `ennemyId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `ennemyId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 ennemyId
        ) internal virtual override {
        super._beforeTokenTransfer(from, to, ennemyId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(ennemyId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, ennemyId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(ennemyId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, ennemyId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param ennemyId uint256 ID of the token to be added to the tokens list of the given address
     */
     function _addTokenToOwnerEnumeration(address to, uint256 ennemyId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = ennemyId;
        _ownedTokensIndex[ennemyId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param ennemyId uint256 ID of the token to be added to the tokens list
     */
     function _addTokenToAllTokensEnumeration(uint256 ennemyId) private {
        _allTokensIndex[ennemyId] = _allTokens.length;
        _allTokens.push(ennemyId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param ennemyId uint256 ID of the token to be removed from the tokens list of the given address
     */
     function _removeTokenFromOwnerEnumeration(address from, uint256 ennemyId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[ennemyId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastennemyId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastennemyId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastennemyId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[ennemyId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param ennemyId uint256 ID of the token to be removed from the tokens list
     */
     function _removeTokenFromAllTokensEnumeration(uint256 ennemyId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[ennemyId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastennemyId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastennemyId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastennemyId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[ennemyId];
        _allTokens.pop();
    }
}


contract BattleForLootCraft is ERC721Enumerable, ReentrancyGuard, Ownable {


    string[] private nature = [
    "Water",
    "Paper",
    "Sand",
    "Salt",
    "Coral",
    "Dirt",
    "Glass",
    "Wood",
    "Clay",
    "Amber",
    "Berry",
    "Mushroom",
    "Chrysanthemum",
    "Rope",
    "Horn",
    "Leather",
    "Sponge",
    "Leaves",
    "Grass",
    "Wool",
    "Milk",
    "Lily",
    "Orchid",
    "Rock",
    "Dandelion",
    "Moon Dust",
    "Thorn",
    "Rose",
    "Silk",
    "Tulip",
    "Pearl",
    "Shell",
    "Iris"
    ];
    
    string[] private mineral = [
    "Amethyst",
    "Antimatter",
    "Silver",
    "Sulfur",
    "Opal",
    "Agate",
    "Andesite",
    "Coal",
    "Copper",
    "Diamond",
    "Emerald",
    "Tin",
    "Iron",
    "Granite",
    "Gravel",
    "Garnet",
    "Lapis",
    "Marble",
    "Black Matter",
    "Meteorite",
    "Obsidian",
    "Jade",
    "Gold",
    "Platinum",
    "Quartz",
    "Ruby",
    "Saphire",
    "Tanzanite",
    "Titanium",
    "Topaz",
    "Zinc",
    "Zircon",
    "Crystal",
    "Steel"
    ];
    
    string[] private monster = [
    "Skeleton Bone",
    "Vampire Blood",
    "Demon Wing",
    "Dragon Skin",
    "Golem Heart",
    "Feather",
    "Egg",
    "Fox Tail",
    "Dragon Blood",
    "Globlin Blood",
    "Venom",
    "Giant's Tooth",
    "Giant's Eye",
    "Giant's Nail",
    "Giant's Blood",
    "Goblin Nail",
    "Shaman Orb",
    "Elemental Core",
    "Dragon Tooth",
    "Magician Orb",
    "Reaper Horn",
    "Dragon Scale",
    "Dragon Claw",
    "Gnoll Eye",
    "Ghoul Tears",
    "Dragon Egg",
    "Dragon Eye",
    "Golem Core",
    "Salamander Dust"
    ];
    
    string[] private prefixes = [
    "Ancient",
    "Robust",
    "Sacred",
    "Enchanted",
    "Mysterious",
    "Great",
    "Precious",
    "Rare",
    "Bright",
    "Dark",
    "Holy",
    "Demonic",
    "Pure",
    "Perfect",
    "Shiny"
    ];
    
    string[] private quantity = [
    "x1",
    "x2",
    "x3",
    "x4",
    "x5"
    ];
    

    string[] private ennemies = [
    "Ghoul",
    "Vampire",
    "Gnoll",
    "Shaman",
    "Golem",
    "Demon",
    "Mummy",
    "Undead",
    "Thief",
    "Devil",
    "Reaper",
    "Skeleton",
    "Orc",
    "Elf",
    "Elemental",
    "Magician",
    "Archer"
    ];

    string[] private level = [
    "lv. 1",
    "lv. 2",
    "lv. 3",
    "lv. 4",
    "lv. 5"
    ];

    function compare(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));

    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function getNature1(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2NATURE", nature);
    }
    
    function getNature2(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2NATURE2", nature);
    }
    
    function getNature3(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2NATURE3", nature);
    }
    
    function getMineral1(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2MINERAL", mineral);
    }
    
    function getMineral2(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2MINERAL2", mineral);
    }
    
    function getMineral3(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2MINERAL3", mineral);
    }
    
    function getMonster1(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2MONSTER", monster);
    }
    
    function getMonster2(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2MONSTER2", monster);
    }
    
    function getMonster3(uint256 ennemyId) public view returns (string memory) {
        return pluck(ennemyId, "V2MONSTER3", monster);
    }
    
    function getEnnemies(uint256 ennemyId) public view returns (string memory) {
        return pluckEnnemies(ennemyId, "V2ENNEMIES1", ennemies);
    }
    
    function getEnnemyName(uint256 ennemyId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("V2ENNEMIES1", toString(ennemyId))));
        return string(abi.encodePacked(ennemies[rand % ennemies.length]));
    }
    
    function getEnnemiesStrength(uint256 ennemyId) public view returns (uint256) {
        uint256 strength = calcEnnemiesStrength(ennemyId, "V2ENNEMIES1");
        strength *= calcEnnemiesQuantity(ennemyId, "V2ENNEMIES1");
        strength *= calcEnnemiesLevel(ennemyId, "V2ENNEMIES1");
        return strength; //2 to 100
    }

    function getLootStrength(uint256 lootId, uint256 ennemyId) public pure returns (uint256) {
        //Since we can't calc loot rarity here, we just throw a dice with combination of loot and ennemy :(.
        //Will be updated on V3
        uint256 strength = random(string(abi.encodePacked("V2LOOTCALC1", toString(lootId), toString(ennemyId))));
        //Return a strength between 1 to 40.
        strength = strength % 40;
        if (strength < 1) {
            return 1;
        } else {
            return strength;
        }
    }
    
    function randomizeBattle(uint256 ennemyId, uint256 lootId) internal view returns (bool) {
        uint256 range;
        uint256 ennemiesStrength = getEnnemiesStrength(ennemyId); //76
        uint256 lootStrength = getLootStrength(lootId, ennemyId); //8
        uint256 rand = random(string(abi.encodePacked(toString(lootId), toString(ennemyId)))); //12981
        if (lootStrength >= ennemiesStrength) {
            range = 2;
        } else {
            range = ennemiesStrength - lootStrength;
        }
        uint256 battleRand = rand % range;
        if (battleRand >= range - 1) {
            return true;
        } else {
            return false;
        }
    }
    
    function play(uint256 ennemyId, uint256 lootId) public view returns (string memory) {
        if (battle(ennemyId, lootId)) {
            return string(abi.encodePacked("VICTORY - You defeated ", getEnnemies(ennemyId)));
        } else {
            return string(abi.encodePacked("DEFEAT - You lost your battle against ", getEnnemies(ennemyId)));
        }
    }
    
    function battle(uint256 ennemyId, uint256 lootId) public view returns (bool) {
        return randomizeBattle(ennemyId, lootId);
    }

    function pluck(uint256 ennemyId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(ennemyId))));
        string memory output = string(abi.encodePacked(sourceArray[rand % sourceArray.length], " ", quantity[rand % quantity.length]));
        uint256 greatnessMin = 18;
        if (getEnnemiesStrength(ennemyId) > 199) {
            greatnessMin = 8;
        } else if (getEnnemiesStrength(ennemyId) > 99) {
            greatnessMin = 10;
        } else if (getEnnemiesStrength(ennemyId) > 49) {
            greatnessMin = 14;
        }
        
        uint256 greatness = rand % 21;
        if (greatness > greatnessMin) {
            output = string(abi.encodePacked(prefixes[rand % prefixes.length], " ", output));
        }
    
        return output;
    }

    function pluckEnnemies(uint256 ennemyId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(ennemyId))));
        string memory output = string(abi.encodePacked(sourceArray[rand % sourceArray.length], " ", level[rand % level.length]));
        uint256 greatness = rand % 21;
        if (greatness > 18) {
            output = string(abi.encodePacked(prefixes[rand % prefixes.length], " ", output));
        }
        output = string(abi.encodePacked(quantity[rand % quantity.length], " ", output));
    
        return output;
    }

    function calcEnnemiesStrength(uint256 ennemyId, string memory keyPrefix) internal pure returns (uint256) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(ennemyId))));
        uint256 greatness = rand % 21;
        if (greatness > 18) {
            return 4;
        }
        return 2;
    }

    function calcEnnemiesQuantity(uint256 ennemyId, string memory keyPrefix) internal view returns (uint256) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(ennemyId))));
        if (compare(quantity[rand % quantity.length], "x1")) { return 1; }
        else if (compare(quantity[rand % quantity.length], "x2")) { return 2; }
        else if (compare(quantity[rand % quantity.length], "x3")) { return 3; }
        else if (compare(quantity[rand % quantity.length], "x4")) { return 4; }
        else if (compare(quantity[rand % quantity.length], "x5")) { return 5; }
        else { return 1; }
    }

    function calcEnnemiesLevel(uint256 ennemyId, string memory keyPrefix) internal view returns (uint256) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(ennemyId))));
        if (compare(level[rand % level.length], "lv. 1")) { return 1; }
        else if (compare(level[rand % level.length], "lv. 2")) { return 2; }
        else if (compare(level[rand % level.length], "lv. 3")) { return 3; }
        else if (compare(level[rand % level.length], "lv. 4")) { return 4; }
        else if (compare(level[rand % level.length], "lv. 5")) { return 5; }
        else { return 1; }
    }

    function getItemRarity(uint256 ennemyId, string memory keyPrefix) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(ennemyId))));
        uint256 greatnessMin = 18;
        if (getEnnemiesStrength(ennemyId) > 199) {
            greatnessMin = 8;
        } else if (getEnnemiesStrength(ennemyId) > 99) {
            greatnessMin = 10;
        } else if (getEnnemiesStrength(ennemyId) > 49) {
            greatnessMin = 14;
        }
        uint256 greatness = rand % 21;
        if (greatness > greatnessMin && rand % quantity.length == quantity.length - 1) {
            return ' style="fill: #b246f6;">';
        } else if (greatness > greatnessMin) {
            return ' style="fill: #eeba57;">';
        }
        return '>';
    }

    function getEnnemyRarity(uint256 ennemyId) public view returns (string memory) {
        if (getEnnemiesStrength(ennemyId) > 199) {
            return ' style="fill: #b246f6">';
        } else if (getEnnemiesStrength(ennemyId) > 99) {
            return ' style="fill: #eeba57">';
        }
        return '>';
    }

    function tokenURI(uint256 ennemyId) override public view returns (string memory) {
        string[39] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; font-weight: normal } .sansserif {font-family: sans-serif!important;}</style><rect width="100%" height="100%" fill="#1a1433" />';
        parts[1] = '<text font-size="30" font-weight="bold" font-family="sans-serif" fill="#FFFFFF"><tspan x="10" y="40">Battle!</tspan><tspan x="110" y="40" font-size="10" font-weight="normal"> for Loot Craft</tspan></text><text x="10" y="60" class="base sansserif" style="fill: #64D98A;">VICTORY';
        parts[2] = '</text><text x="10" y="80" class="base sansserif">You defeated </text><text class="base sansserif" x="100" y="80" ';
        parts[3] = getEnnemyRarity(ennemyId);
        parts[4] = getEnnemies(ennemyId);
        parts[5] = '</text><text x="10" y="100" class="base sansserif">';
        parts[6] = "";
        parts[7] = "";
        parts[9] = "Loot Craft Bag #";
        parts[10] = toString(ennemyId);
        parts[11] = ' : </text><text x="50" y="140" class="base"';
        parts[12] = getItemRarity(ennemyId, "V2NATURE");
        parts[13] = getNature1(ennemyId);

        parts[14] = '</text><text x="50" y="160" class="base"';
        parts[15] = getItemRarity(ennemyId, "V2NATURE2");
        parts[16] = getNature2(ennemyId);
        
        parts[17] = '</text><text x="50" y="180" class="base"';
        parts[18] = getItemRarity(ennemyId, "V2NATURE3");
        parts[19] = getNature3(ennemyId);

        parts[20] = '</text><text x="50" y="200" class="base"';
        parts[21] = getItemRarity(ennemyId, "V2MINERAL");
        parts[22] = getMineral1(ennemyId);

        parts[23] = '</text><text x="50" y="220" class="base"';
        parts[24] = getItemRarity(ennemyId, "V2MINERAL2");
        parts[25] = getMineral2(ennemyId);
        
        parts[26] = '</text><text x="50" y="240" class="base"';
        parts[27] = getItemRarity(ennemyId, "V2MINERAL3");
        parts[28] = getMineral3(ennemyId);

        parts[29] = '</text><text x="50" y="260" class="base"';
        parts[30] = getItemRarity(ennemyId, "V2MONSTER");
        parts[31] = getMonster1(ennemyId);

        parts[32] = '</text><text x="50" y="280" class="base"';
        parts[33] = getItemRarity(ennemyId, "V2MONSTER2");
        parts[34] = getMonster2(ennemyId);
        
        parts[35] = '</text><text x="50" y="300" class="base"';
        parts[36] = getItemRarity(ennemyId, "V2MONSTER3");
        parts[37] = getMonster3(ennemyId);
        parts[38] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16]));
        output = string(abi.encodePacked(output, parts[17], parts[18], parts[19], parts[20], parts[21], parts[22], parts[23], parts[24]));
        output = string(abi.encodePacked(output, parts[25], parts[26], parts[27], parts[28], parts[29], parts[30], parts[31], parts[32]));
        output = string(abi.encodePacked(output, parts[33], parts[34], parts[35], parts[36], parts[37], parts[38]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Bag #', toString(ennemyId), '", "description": "Battle for Loot Craft : Battle ennemies to win randomized resources to craft new items. Stats, images, and other functionality are intentionally omitted for others to interpret.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }
    
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claim(uint256 ennemyId, uint256 lootId) public payable nonReentrant {
        require(ennemyId > 0 && ennemyId < 8889, "Ennemy ID is invalid");
        require(battle(ennemyId, lootId), play(ennemyId, lootId));
        require(msg.value>=10000000000000000, "You must send minimum value to claim this Bag (0.01 E) !");
        _safeMint(_msgSender(), ennemyId);
    }
    
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

constructor() ERC721("Battle! for Loot - Earn Loot Craft", "CRAFT") Ownable() {}
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}