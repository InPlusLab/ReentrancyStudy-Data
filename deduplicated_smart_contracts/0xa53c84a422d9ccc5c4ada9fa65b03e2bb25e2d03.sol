/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

pragma solidity ^0.5.11;

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

contract DocumentStore is Ownable {
    string public name;
    string public version = "2.3.0";

    /// A mapping of the document hash to the block number that was issued
    mapping(bytes32 => uint256) documentIssued;
    /// A mapping of the hash of the claim being revoked to the revocation block number
    mapping(bytes32 => uint256) documentRevoked;

    event DocumentIssued(bytes32 indexed document);
    event DocumentRevoked(bytes32 indexed document);

    constructor(string memory _name) public {
        name = _name;
    }

    function issue(bytes32 document) public onlyOwner onlyNotIssued(document) {
        documentIssued[document] = block.number;
        emit DocumentIssued(document);
    }

    function bulkIssue(bytes32[] memory documents) public {
        for (uint256 i = 0; i < documents.length; i++) {
            issue(documents[i]);
        }
    }

    function getIssuedBlock(bytes32 document)
        public
        view
        onlyIssued(document)
        returns (uint256)
    {
        return documentIssued[document];
    }

    function isIssued(bytes32 document) public view returns (bool) {
        return (documentIssued[document] != 0);
    }

    function isIssuedBefore(bytes32 document, uint256 blockNumber)
        public
        view
        returns (bool)
    {
        return
            documentIssued[document] != 0 && documentIssued[document] <= blockNumber;
    }

    function revoke(bytes32 document)
        public
        onlyOwner
        onlyNotRevoked(document)
        returns (bool)
    {
        documentRevoked[document] = block.number;
        emit DocumentRevoked(document);
    }

    function bulkRevoke(bytes32[] memory documents) public {
        for (uint256 i = 0; i < documents.length; i++) {
            revoke(documents[i]);
        }
    }

    function isRevoked(bytes32 document) public view returns (bool) {
        return documentRevoked[document] != 0;
    }

    function isRevokedBefore(bytes32 document, uint256 blockNumber)
        public
        view
        returns (bool)
    {
        return
            documentRevoked[document] <= blockNumber && documentRevoked[document] != 0;
    }

    modifier onlyIssued(bytes32 document) {
        require(
            isIssued(document),
            "Error: Only issued document hashes can be revoked"
        );
        _;
    }

    modifier onlyNotIssued(bytes32 document) {
        require(
            !isIssued(document),
            "Error: Only hashes that have not been issued can be issued"
        );
        _;
    }

    modifier onlyNotRevoked(bytes32 claim) {
        require(!isRevoked(claim), "Error: Hash has been revoked previously");
        _;
    }
}