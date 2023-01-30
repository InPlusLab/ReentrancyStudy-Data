/**
 *Submitted for verification at Etherscan.io on 2019-09-01
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

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

// File: truffle/contracts/ECDSA.sol

/*
**  Blockdemy Certifications | A library to recover signature addresses with ECDSA
**  Authors: Blockchain Academy M¨¦xico @blockdemy, Ernesto Garc¨ªa @ernestognw
**  22-July-2019
**  blockchainacademy.mx
*/


pragma solidity ^0.5.1;

library ECDSA {
    /**
    * @dev Recovers the address of who signed the hash sent to the function
    * @param _fingerprint bytes32. Is the sha3 hash of document. Generated with web3.
    * @param _signature bytes. Signature of the sha3 fingerprint of the file.
    */
    function recoverAddress(bytes32 _fingerprint, bytes memory _signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        require(_signature.length == 65, "Invalid signature");

        // Divide the signature in r, s and v variables with inline assembly.
        assembly {
          r := mload(add(_signature, 0x20))
          s := mload(add(_signature, 0x40))
          v := byte(0, mload(add(_signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
          v += 27;
        }
        
        require(v == 27 || v == 28, "Invalid signature");
        return ecrecover(toEthSignedMessageHash(_fingerprint), v, r, s);
    }
    
    /**
    * toEthSignedMessageHash
    * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:" and hash the result
    * @param _fingerprint bytes32. Is the sha3 hash of document. Generated with web3.
    */
    function toEthSignedMessageHash(bytes32 _fingerprint) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _fingerprint)
        );
    } 
}

// File: truffle/contracts/Certifications.sol

/*
**  Blockdemy Certifications | A contract to store digital documents certifications
**  Authors: Blockchain Academy M¨¦xico @blockdemy, Ernesto Garc¨ªa @ernestognw
**  22-July-2019
**  blockchainacademy.mx
*/

pragma solidity 0.5.1;



contract Certifications is Ownable {
    using ECDSA for bytes32;
    
    mapping(bytes32 => Certificate) public fingerprints; 
    
    struct Certificate {
        address owner;
        mapping(address => bytes) signatures;
        uint issued;
        uint expires;
        bool exists;
    }
    
    constructor() public {}
    
    /**
    * @dev Certificate a document fingerprint into blockchain
    * @param _fingerprint bytes32. Is the sha3 hash of document. Generated with web3.
    * @param _owner address. The address of who is being certificated. The owner of document.
    * @param _issued uint. The unix miliseconds date of certificate issuing.
    * @param _expires uint. The unix miliseconds date of certificate expiration.
    */
    function addCertificate(
        bytes32 _fingerprint,
        address _owner,
        uint _issued,
        uint _expires
    ) onlyOwner() public returns(bool) {
        require(_issued < _expires, "Issuing date can not be less than expiring date");
        require(_expires > now, "This certificate has already expired");
        require(!fingerprints[_fingerprint].exists, "File has already been certified");
        fingerprints[_fingerprint].owner = _owner;
        fingerprints[_fingerprint].issued = _issued;
        fingerprints[_fingerprint].expires = _expires;
        fingerprints[_fingerprint].exists = true;
        return true;
    }
    
    /**
    * @dev Function to sign a previously generated certificate
    * @param _signer address. The address of who is signing the certificate.
    * @param _fingerprint bytes32. Is the sha3 hash of document. Generated with web3.
    * @param _signature bytes. Signature of the sha3 fingerprint of the file.
    */
    function addSignatureToCertificate(address _signer, bytes32 _fingerprint, bytes memory _signature) onlyOwner() public returns(bool) {
       address signer = _fingerprint.recoverAddress(_signature);
       require(fingerprints[_fingerprint].exists, "Certificate does not exists");
       require(_signer == signer, "Signature does not corresponds to signer");
       fingerprints[_fingerprint].signatures[_signer] = _signature;
       return true;
    }
    
    /**
    * @dev Returns the corresponding signature to a certificate and signer, used to verify signatures
    * @param _signer address. The address of who supposedly signed the certificate.
    * @param _fingerprint bytes32. Is the sha3 hash of document. Generated with web3.
    */
    function getSignature(address _signer, bytes32 _fingerprint) public view returns(bytes memory) {
        return fingerprints[_fingerprint].signatures[_signer];
    }
}