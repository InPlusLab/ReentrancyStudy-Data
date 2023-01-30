/**
 *Submitted for verification at Etherscan.io on 2019-06-19
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-19
*/

/* solhint-disable indent*/
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  /Users/rmanzoku/src/github.com/doublejumptokyo/mch-land-contract/contracts/MCHGUMGatewayV8.sol
// flattened :  Wednesday, 19-Jun-19 06:54:11 UTC
library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    /**
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method for registering an interface
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Withdrawable is Ownable {
  function withdrawEther() external onlyOwner {
    msg.sender.transfer(address(this).balance);
  }

  function withdrawToken(IERC20 _token) external onlyOwner {
    require(_token.transfer(msg.sender, _token.balanceOf(address(this))));
  }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => uint256) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    /*
     * 0x80ac58cd ===
     *     bytes4(keccak256('balanceOf(address)')) ^
     *     bytes4(keccak256('ownerOf(uint256)')) ^
     *     bytes4(keccak256('approve(address,uint256)')) ^
     *     bytes4(keccak256('getApproved(uint256)')) ^
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^
     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
     */

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId uint256 ID of the token to query the owner of
     * @return owner address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
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
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

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
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     *
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

contract DJTBase is Withdrawable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;
}
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    /**
     * 0x780e9d63 ===
     *     bytes4(keccak256('totalSupply()')) ^
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
     *     bytes4(keccak256('tokenByIndex(uint256)'))
     */

    /**
     * @dev Constructor function
     */
    constructor () public {
        // register the supported interface to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
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
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead
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
     * @dev Gets the list of token IDs of the requested owner
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
     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
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

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occcupied by
        // lasTokenId, or just over the end of the array if the token was the last one).
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

contract ERC721Mintable is ERC721, MinterRole {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }
}

contract ERC721Pausable is ERC721, Pausable {
    function approve(address to, uint256 tokenId) public whenNotPaused {
        super.approve(to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public whenNotPaused {
        super.setApprovalForAll(to, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public whenNotPaused {
        super.transferFrom(from, to, tokenId);
    }
}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
     */

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
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token
     * Reverts if the token ID does not exist
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead
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

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }
}

contract LandSectorAsset is ERC721Full, ERC721Mintable, ERC721Pausable {


  uint256 public constant SHARE_RATE_DECIMAL = 10**18;

  uint16 public constant LEGENDARY_RARITY = 5;
  uint16 public constant EPIC_RARITY = 4;
  uint16 public constant RARE_RARITY = 3;
  uint16 public constant UNCOMMON_RARITY = 2;
  uint16 public constant COMMON_RARITY = 1;

  uint16 public constant NO_LAND = 0;

  string public tokenURIPrefix = "https://www.mycryptoheroes.net/metadata/land/";

  mapping(uint16 => uint256) private landTypeToTotalVolume;
  mapping(uint16 => uint256) private landTypeToSectorSupplyLimit;
  mapping(uint16 => mapping(uint16 => uint256)) private landTypeAndRarityToSectorSupply;
  mapping(uint16 => uint256[]) private landTypeToLandSectorList;
  mapping(uint16 => uint256) private landTypeToLandSectorIndex;
  mapping(uint16 => mapping(uint16 => uint256)) private landTypeAndRarityToLandSectorCount;
  mapping(uint16 => uint256) private rarityToSectorVolume;

  mapping(uint256 => bool) private allowed;

  event MintEvent(
    address indexed assetOwner,
    uint256 tokenId,
    uint256 at,
    bytes32 indexed eventHash
  );

  constructor() public ERC721Full("MyCryptoHeroes:Land", "MCHL") {
    rarityToSectorVolume[5] = 100;
    rarityToSectorVolume[4] = 20;
    rarityToSectorVolume[3] = 5;
    rarityToSectorVolume[2] = 2;
    rarityToSectorVolume[1] = 1;
    landTypeToTotalVolume[NO_LAND] = 0;
  }

  function setSupplyAndSector(
    uint16 _landType,
    uint256 _totalVolume,
    uint256 _sectorSupplyLimit,
    uint256 legendarySupply,
    uint256 epicSupply,
    uint256 rareSupply,
    uint256 uncommonSupply,
    uint256 commonSupply
  ) external onlyMinter {
    require(_landType != 0, "landType 0 is noland");
    require(_totalVolume != 0, "totalVolume must not be 0");
    require(getMintedSectorCount(_landType) == 0, "This LandType already exists");
    require(
      legendarySupply.mul(rarityToSectorVolume[LEGENDARY_RARITY])
      .add(epicSupply.mul(rarityToSectorVolume[EPIC_RARITY]))
      .add(rareSupply.mul(rarityToSectorVolume[RARE_RARITY]))
      .add(uncommonSupply.mul(rarityToSectorVolume[UNCOMMON_RARITY]))
      .add(commonSupply.mul(rarityToSectorVolume[COMMON_RARITY]))
      == _totalVolume
    );
    require(
      legendarySupply
      .add(epicSupply)
      .add(rareSupply)
      .add(uncommonSupply)
      .add(commonSupply)
      == _sectorSupplyLimit
    );
    landTypeToTotalVolume[_landType] = _totalVolume;
    landTypeToSectorSupplyLimit[_landType] = _sectorSupplyLimit;
    landTypeAndRarityToSectorSupply[_landType][LEGENDARY_RARITY] = legendarySupply;
    landTypeAndRarityToSectorSupply[_landType][EPIC_RARITY] = epicSupply;
    landTypeAndRarityToSectorSupply[_landType][RARE_RARITY] = rareSupply;
    landTypeAndRarityToSectorSupply[_landType][UNCOMMON_RARITY] = uncommonSupply;
    landTypeAndRarityToSectorSupply[_landType][COMMON_RARITY] = commonSupply;
  }

  function approve(address _to, uint256 _tokenId) public {
    require(allowed[_tokenId]);
    super.approve(_to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    require(allowed[_tokenId]);
    super.transferFrom(_from, _to, _tokenId);
  }

  function unLockToken(uint256 _tokenId) public onlyMinter {
    allowed[_tokenId] = true;
  }

  function setTokenURIPrefix(string calldata _tokenURIPrefix) external onlyMinter {
    tokenURIPrefix = _tokenURIPrefix;
  }

  function isAlreadyMinted(uint256 _tokenId) public view returns (bool) {
    return _exists(_tokenId);
  }

  function isValidLandSector(uint256 _tokenId) public view returns (bool) {
    uint16 rarity = getRarity(_tokenId);
    if (!(rarityToSectorVolume[rarity] > 0)) {
      return false;
    }
    uint16 landType = getLandType(_tokenId);
    if (!(landTypeToTotalVolume[landType] > 0)) {
      return false;
    }
    uint256 serial = _tokenId % 10000;
    if (serial == 0) {
      return false;
    }
    if (serial > landTypeAndRarityToSectorSupply[landType][rarity]) {
      return false;
    }
    return true;
  }

  function canTransfer(uint256 _tokenId) public view returns (bool) {
    return allowed[_tokenId];
  }

  function getTotalVolume(uint16 _landType) public view returns (uint256) {
    return landTypeToTotalVolume[_landType];
  }

  function getSectorSupplyLimit(uint16 _landType) public view returns (uint256) {
    return landTypeToSectorSupplyLimit[_landType];
  }

  function getLandType(uint256 _landSector) public view returns (uint16) {
    uint16 _landType = uint16((_landSector.div(10000)) % 1000);
    return _landType;
  }

  function getRarity(uint256 _landSector) public view returns (uint16) {
    return uint16(_landSector.div(10**7));
  }

  function getMintedSectorCount(uint16 _landType) public view returns (uint256) {
    return landTypeToLandSectorIndex[_landType];
  }

  function getMintedSectorCountByRarity(uint16 _landType, uint16 _rarity) public view returns (uint256) {
    return landTypeAndRarityToLandSectorCount[_landType][_rarity];
  }

  function getSectorSupplyByRarity(uint16 _landType, uint16 _rarity) public view returns (uint256) {
    return landTypeAndRarityToSectorSupply[_landType][_rarity];
  }

  function getMintedSectorList(uint16 _landType) public view returns (uint256[] memory) {
    return landTypeToLandSectorList[_landType];
  }

  function getSectorVolumeByRarity(uint16 _rarity) public view returns (uint256) {
    return rarityToSectorVolume[_rarity];
  }

  function getShareRateWithDecimal(uint256 _landSector) public view returns (uint256, uint256) {
    return (
      getSectorVolumeByRarity(getRarity(_landSector))
        .mul(SHARE_RATE_DECIMAL)
        .div(getTotalVolume(getLandType(_landSector))),
      SHARE_RATE_DECIMAL
    );
  }

  function mintLandSector(address _owner, uint256 _landSector, bytes32 _eventHash) public onlyMinter {
    require(!isAlreadyMinted(_landSector));
    require(isValidLandSector(_landSector));
    uint16 _landType = getLandType(_landSector);
    require(landTypeToLandSectorIndex[_landType] < landTypeToSectorSupplyLimit[_landType]);
    uint16 rarity = getRarity(_landSector);
    require(landTypeAndRarityToLandSectorCount[_landType][rarity] < landTypeAndRarityToSectorSupply[_landType][rarity], "supply over");
    _mint(_owner, _landSector);
    landTypeToLandSectorList[_landType].push(_landSector);
    landTypeToLandSectorIndex[_landType]++;
    landTypeAndRarityToLandSectorCount[_landType][rarity]++;

    emit MintEvent(
      _owner,
      _landSector,
      block.timestamp,
      _eventHash
    );
  }

  function tokenURI(uint256 _tokenId) public view returns (string memory) {
    bytes32 tokenIdBytes;
    if (_tokenId == 0) {
      tokenIdBytes = "0";
    } else {
      uint256 value = _tokenId;
      while (value > 0) {
        tokenIdBytes = bytes32(uint256(tokenIdBytes) / (2 ** 8));
        tokenIdBytes |= bytes32(((value % 10) + 48) * 2 ** (8 * 31));
        value /= 10;
      }
    }

    bytes memory prefixBytes = bytes(tokenURIPrefix);
    bytes memory tokenURIBytes = new bytes(prefixBytes.length + tokenIdBytes.length);

    uint8 i;
    uint8 index = 0;

    for (i = 0; i < prefixBytes.length; i++) {
      tokenURIBytes[index] = prefixBytes[i];
      index++;
    }

    for (i = 0; i < tokenIdBytes.length; i++) {
      tokenURIBytes[index] = tokenIdBytes[i];
      index++;
    }

    return string(tokenURIBytes);
  }
}
/* solhint-enable indent*/

contract MCHLandPool is Ownable, Pausable, ReentrancyGuard {
  using SafeMath for uint256;


  LandSectorAsset public landSectorAsset;

  mapping(uint16 => uint256) private landTypeToTotalAmount;
  mapping(uint256 => uint256) private landSectorToWithdrawnAmount;
  mapping(address => bool) private allowedAddresses;

  event EthAddedToPool(
    uint16 indexed landType,
    address txSender,
    address indexed purchaseBy,
    uint256 value,
    uint256 at
  );

  event WithdrawEther(
    uint256 indexed landSector,
    address indexed lord,
    uint256 value,
    uint256 at
  );

  event AllowedAddressSet(
    address allowedAddress,
    bool allowedStatus
  );

  constructor(address _landSectorAssetAddress) public {
    landSectorAsset = LandSectorAsset(_landSectorAssetAddress);
  }

  function setLandSectorAssetAddress(address _landSectorAssetAddress) external onlyOwner() {
    landSectorAsset = LandSectorAsset(_landSectorAssetAddress);
  }

  function setAllowedAddress(address _address, bool desired) external onlyOwner() {
    allowedAddresses[_address] = desired;
    emit AllowedAddressSet(
      _address,
      desired
    );
  }

  function addEthToLandPool(uint16 _landType, address _purchaseBy) external payable whenNotPaused() nonReentrant() {
    require(landSectorAsset.getTotalVolume(_landType) > 0);
    require(allowedAddresses[msg.sender]);
    landTypeToTotalAmount[_landType] += msg.value;

    emit EthAddedToPool(
      _landType,
      msg.sender,
      _purchaseBy,
      msg.value,
      block.timestamp
    );
  }

  function withdrawMyAllRewards() external whenNotPaused() nonReentrant() {
    require(getWithdrawableBalance(msg.sender) > 0);

    uint256 withdrawValue;
    uint256 balance = landSectorAsset.balanceOf(msg.sender);
    
    for (uint256 i=balance; i > 0; i--) {
      uint256 landSector = landSectorAsset.tokenOfOwnerByIndex(msg.sender, i-1);
      uint256 tmpAmount = getLandSectorWithdrawableBalance(landSector);
      withdrawValue += tmpAmount;
      landSectorToWithdrawnAmount[landSector] += tmpAmount;

      emit WithdrawEther(
        landSector,
        msg.sender,
        tmpAmount,
        block.timestamp
      );
    }
    msg.sender.transfer(withdrawValue);
  }

  function withdrawMyReward(uint256 _landSector) external whenNotPaused() nonReentrant() {
    require(landSectorAsset.ownerOf(_landSector) == msg.sender);
    uint256 withdrawableAmount = getLandSectorWithdrawableBalance(_landSector);
    require(withdrawableAmount > 0);

    landSectorToWithdrawnAmount[_landSector] += withdrawableAmount;
    msg.sender.transfer(withdrawableAmount);

    emit WithdrawEther(
      _landSector,
      msg.sender,
      withdrawableAmount,
      block.timestamp
    );
  }

  function getAllowedAddress(address _address) public view returns (bool) {
    return allowedAddresses[_address];
  }

  function getTotalEthBackAmountPerLandType(uint16 _landType) public view returns (uint256) {
    return landTypeToTotalAmount[_landType];
  }

  function getLandSectorWithdrawnAmount(uint256 _landSector) public view returns (uint256) {
    return landSectorToWithdrawnAmount[_landSector];
  }

  function getLandSectorWithdrawableBalance(uint256 _landSector) public view returns (uint256) {
    require(landSectorAsset.isValidLandSector(_landSector));
    uint16 _landType = landSectorAsset.getLandType(_landSector);
    (uint256 shareRate, uint256 decimal) = landSectorAsset.getShareRateWithDecimal(_landSector);
    uint256 maxAmount = landTypeToTotalAmount[_landType]
      .mul(shareRate)
      .div(decimal);
    return maxAmount.sub(landSectorToWithdrawnAmount[_landSector]);
  }

  function getWithdrawableBalance(address _lordAddress) public view returns (uint256) {
    uint256 balance = landSectorAsset.balanceOf(_lordAddress);
    uint256 withdrawableAmount;

    for (uint256 i=balance; i > 0; i--) {
      uint256 landSector = landSectorAsset.tokenOfOwnerByIndex(_lordAddress, i-1);
      withdrawableAmount += getLandSectorWithdrawableBalance(landSector);
    }

    return withdrawableAmount;
  }
}
/* solhint-enable indent*/

contract MCHGUMGatewayV8 is DJTBase {

  struct Campaign {
    uint256 since;
    uint256 until;
    uint8 purchaseType;
  }

  Campaign public campaign;

  mapping(uint256 => bool) public payableOptions;
  address public validater;

  LandSectorAsset public landSectorAsset;
  MCHLandPool public landPool;
  uint256 public landPercentage;

  event Sold(
    address indexed user,
    address indexed referrer,
    uint8 purchaseType,
    uint256 grossValue,
    uint256 referralValue,
    uint256 landValue,
    uint256 netValue,
    uint16 indexed landType
  );

  event CampaignUpdated(
    uint256 since,
    uint256 until,
    uint8 purchaseType
  );

  event LandPercentageUpdated(
    uint256 landPercentage
  );

  constructor(
              address _validater,
              address _landSectorAssetAddress,
              address _landPoolAddress
  ) public payable {
    validater = _validater;
    landSectorAsset = LandSectorAsset(_landSectorAssetAddress);
    landPool = MCHLandPool(_landPoolAddress);

    campaign = Campaign(0, 0, 0);
    landPercentage = 30;

    payableOptions[0.05 ether] = true;
    payableOptions[0.1 ether] = true;
    payableOptions[0.5 ether] = true;
    payableOptions[1 ether] = true;
    payableOptions[5 ether] = true;
    payableOptions[10 ether] = true;
  }

  function setValidater(address _varidater) external onlyOwner() {
    validater = _varidater;
  }

  function setPayableOption(uint256 _option, bool desired) external onlyOwner() {
    payableOptions[_option] = desired;
  }

  function setCampaign(uint256 _since, uint256 _until, uint8 _purchaseType) external onlyOwner() {
    campaign = Campaign(_since, _until, _purchaseType);
    emit CampaignUpdated(_since, _until, _purchaseType);
  }

  function setLandSectorAssetAddress(address _landSectorAssetAddress) external onlyOwner() {
    landSectorAsset = LandSectorAsset(_landSectorAssetAddress);
  }

  function setLandPoolAddress(address payable _landPoolAddress) external onlyOwner() {
    landPool = MCHLandPool(_landPoolAddress);
  }

  function updateLandPercentage(uint256 _newLandPercentage) external onlyOwner() {
    landPercentage = _newLandPercentage;
    emit LandPercentageUpdated(
      landPercentage
    );
  }

  function buyGUM(
                  address payable _referrer,
                  uint256 _referralPercentage,
                  uint16 _landType,
                  bytes calldata _signature
                  ) external payable whenNotPaused() {

    require(_referralPercentage + landPercentage <= 100, "Invalid percentages");
    require(payableOptions[msg.value], "Invalid msg.value");
    require(validateSig(encodeData(msg.sender, _referrer, _referralPercentage, _landType), _signature), "Invalid signature");

    uint256 referralValue = _referrerBack(_referrer, _referralPercentage);
    uint256 landValue = _landPoolBack(_landType);
    uint256 netValue = msg.value.sub(referralValue).sub(landValue);

    emit Sold(
      msg.sender,
      _referrer,
      getPurchaseType(block.number),
      msg.value,
      referralValue,
      landValue,
      netValue,
      _landType
    );
  }

  function getPurchaseType(uint256 _block) public view returns (uint8) {
    // Define purchaseType
    // enum PurchaseType {
    //   PURCHASE_NORMAL = 0;
    //   PURCHASE_ETH_BACK = 1;
    // }
    if(campaign.until < _block) {
      return 0;
    }
    if(campaign.since > _block) {
      return 0;
    }
    return campaign.purchaseType;
  }

  function _landPoolBack(uint16 _landType) internal returns (uint256) {
    if(_landType == 0) {
      return 0;
    }
    require(landSectorAsset.getTotalVolume(_landType) != 0, "Invalid _landType");

    uint256 landValue;
    landValue = msg.value.mul(landPercentage).div(100);
    landPool.addEthToLandPool.value(landValue)(_landType, msg.sender);
    return landValue;
  }

  function _referrerBack(address payable _referrer, uint256 _referralPercentage) internal returns (uint256) {
    if(_referrer == address(0x0) || _referrer == msg.sender) {
      return 0;
    }

    uint256 referralValue;
    referralValue = msg.value.mul(_referralPercentage).div(100);
    _referrer.transfer(referralValue);
    return referralValue;
  }

  function encodeData(address _sender, address _referrer, uint256 _referralPercentage, uint16 _landType) public pure returns (bytes32) {
    return keccak256(abi.encode(
                                _sender,
                                _referrer,
                                _referralPercentage,
                                _landType
                                )
                     );
  }

  function validateSig(bytes32 _message, bytes memory _signature) public view returns (bool) {
    require(validater != address(0), "validater must be setted");
    address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(_message), _signature);
    return (signer == validater);
  }

  function kill() external onlyOwner() {
    selfdestruct(msg.sender);
  }
}
/* solhint-enable indent*/