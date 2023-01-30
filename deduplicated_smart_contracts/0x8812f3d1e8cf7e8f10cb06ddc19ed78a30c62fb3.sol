/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

pragma solidity 0.5.8;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
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
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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

// File: contracts/file_verification_v2.sol

contract Verification is Ownable {
    // Struct for each certificate
    struct Certificate {
        uint256 time;
        bytes32 pdfHash;
        bytes32 originHash;
    }

    // mapping that stores all the versions of a certificate, indexed by the hash of the first pdf
    mapping(bytes32 => bytes32[]) public versions;

    // events
    event CertificateCreated(bytes32 indexed _pdfHash, bytes32 indexed _originHash, address indexed _sender, uint256 _time);
    event CertificateUpdated(bytes32 indexed _pdfHash, bytes32 indexed _originHash, address indexed _sender, uint256 _time);

    // Create a certificate
    function createCert(bytes32 _pdfHash) public onlyOwner returns (bool) {
        require(_pdfHash != bytes32(0));

        // Making sure that we don't push the same hash multiple times
        require(versions[_pdfHash].length == 0);

        versions[_pdfHash].push(_pdfHash);
        emit CertificateCreated(_pdfHash, _pdfHash, msg.sender, block.timestamp);
        return true;
    }

    // Update the Certificate
    function updateCert(bytes32 _pdfHash, bytes32 _newPdfHash) public onlyOwner returns (bool) {
        require(_pdfHash != bytes32(0));
        require(_newPdfHash != bytes32(0));
        require(versions[_pdfHash].length != 0);
        versions[_pdfHash].push(_newPdfHash);
        emit CertificateUpdated(_newPdfHash, _pdfHash, msg.sender, block.timestamp);
        return true;
    }

    // View the record by `originHash`
    function viewRecord(bytes32 _originHash) public view returns (bytes32[] memory copy) {
        require(_originHash != bytes32(0));
        copy = versions[_originHash];
    }
}