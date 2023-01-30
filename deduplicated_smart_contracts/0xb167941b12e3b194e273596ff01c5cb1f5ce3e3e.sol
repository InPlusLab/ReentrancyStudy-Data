/**
 *Submitted for verification at Etherscan.io on 2019-12-08
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

/**
 * @dev contract module that provides the OpenCerts DocumentStore contract to be used
 * to issue and remoke certificates on the blockchain
 */
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

/**
 *
 * DocumentMultiSigWalletCertStore
 * ============
 *
 * Basic multi-signer wallet designed for use in a co-signing environment where 
 * 2 signatures are required to issue and revoke certificates.
 * Typically used in a 2-of-3 signing configuration. Uses ecrecover to allow 
 * for 2 signatures in a single transaction.
 *
 * The first signature is created on the operation hash (see Data Formats) and 
 * passed to sendMultiSig/sendMultiSigToken
 * The signer is determined by verifyMultiSig().
 *
 * The second signature is created by the submitter of the transaction and determined 
 * by msg.signer.
 * 
 * This wallet only allows for three signers that have to be set upon deployment.
 * The signers cannot be changed/removed/added.
 * The wallet also deploys upon construction a DocumentStore contract, the name parameter 
 * is used to label the DocumentStore Contract.
 * 
 * This iteration of the wallet restricts the initiation of the different functions to 
 * specific signers.
 * 
 * Signer Authorisation
 * ====================
 * issueMultiSig & revokeMultiSig & bulkIssueMultiSig & bulkRevokeMultiSig 
 * can only be initiated by the 3rd Signer AKA The Custodian 
 * 
 * changeStoreMultiSig & transferMultiSig can only be initiated by the 2nd Signer
 * AKA The Backup
 *
 * Data Formats
 * ============
 *
 * The signature is created with ethereumjs-util.ecsign(operationHash).
 * Like the eth_sign RPC call, it packs the values as a 65-byte array of [r, s, v].
 * Unlike eth_sign, the message is not prefixed.
 *
 * The operationHash the result of keccak256(prefix, hash, expireTime, sequenceId).
 * For Issue transactions, `prefix` is "ISSUE".
 * For Bulk Issue transactions, `prefix` is "BULKISSUE".
 * For Revoke transaction, `prefix` is "REVOKE".
 * For Bulk Revoke transaction, `prefix` is "BULKREVOKE".
 * For Transfer transaction, 'prefix' is "TRANSFER"
 * For Change transaction, 'prefix' is "Change"
 *
 */
contract DocumentMultiSigWalletCertStore {
    // Events
    event Issued(address msgSender, address otherSigner, bytes32 operation, bytes32 hash);
    
    event BulkIssue(address msgSender, address otherSigner, bytes32 operation, bytes32[] hashes);
        
    event Revoked(address msgSender, address otherSigner, bytes32 operation, bytes32 hash);
    
    event BulkRevoke(address msgSender, address otherSigner, bytes32 operation, bytes32[] hashes);
        
    event Transferred(address msgSender, address otherSigner, address newOwner);
    
    event Change(address msgSender, address otherSigner, address newStore);

    // Public fields
    address[] public signers; // The addresses that can co-sign transactions on the wallet
    DocumentStore public documentStore; //DocumentStore Contract
    
    /**
     * Constructor
     * ============
     * 
     * Deploys a new DocumentMultiSigWalletCertStore contract that also deplots a
     * documentStore contract
     * 
     * Takes in an array of 3 signers that will be used to approve transactions
     * Takes in a string that will be used to label the DocumentStore Contract
     * 
     */
    constructor(address[] memory _signers, string memory _name) public {
        if (_signers.length != 3) {
            // Number of signers submitted is not 3
            revert();
        }
        signers = _signers;
        
        documentStore = new DocumentStore(_name);
    }

    // Internal fields
    uint constant SEQUENCE_ID_WINDOW_SIZE = 10;
    uint[10] recentSequenceIds;

    /**
     * Determine if an address is a signer on this wallet
     * @param signer address to check
     * returns boolean indicating whether address is signer or not
     */
    function isSigner(address signer) public view returns (bool) {
        // Iterate through all signers on the wallet and checks if the signer passed in is one of them
        for (uint i = 0; i < signers.length; i++) {
            if (signers[i] == signer) {
                return true; //Signer passed in is a signer on the wallet
            }
        }
        return false; //Signer passed in is NOT a signer on the wallet
    }

    /**
     * Modifier that will execute internal code block only if the sender is an authorized signer on this wallet
     */
    modifier onlySigner {
        if (!isSigner(msg.sender)) {
            revert(); //Senders is not a signer
        }
        _;
    }
    
    /**
     * Modifier that will execute internal code block only if the sender is the Custodian
     */
    modifier onlyCustodian {
        if (!(msg.sender == signers[2])) {
            revert(); //Senders is not a signer
        }
        _;
    }
    
    /**
     * Modifier that will execute internal code block only if the sender is the Backup
     */
    modifier onlyBackup {
        if (!(msg.sender == signers[1])) {
            revert(); //Senders is not a signer
        }
        _;
    }
    
    /**
     * Modifier that will execute internal code block only if the sender is an initiator
     */
    modifier onlyInitiators {
        if ((msg.sender != signers[1]) && (msg.sender != signers[2])) {
            revert(); //Senders is not a signer
        }
        _;
    }

    /**
     * Fallback function. Is called when a transaction is received without calling a method
     */
    function() external {
        revert(); // Reject any accidental Ether transfer
    }
    
    /**
     * Execute a multi-signature issue transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
     * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
     *
     * @param hash the certificate batch's hash that will be appended to the blockchain
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * @param signature second signer's signature
     */
    function issueMultiSig(
        bytes32 hash,
        uint expireTime,
        uint sequenceId,
        bytes memory signature
        ) public onlyCustodian {
            bytes32 operationHash = keccak256(abi.encodePacked("ISSUE", hash, expireTime, sequenceId));
            
            address otherSigner = verifyMultiSig(operationHash, signature, expireTime, sequenceId);
            
            documentStore.issue(hash);
            
            emit Issued(msg.sender, otherSigner, operationHash, hash);
        }
        
    /**
     * Execute a multi-signature bulk issue transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
     * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
     *
     * @param hashes an array of certificate batch hashes that will be appended to the blockchain
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * @param signature second signer's signature
     */
    function bulkIssueMultiSig(
        bytes32[] memory hashes,
        uint expireTime,
        uint sequenceId,
        bytes memory signature
        ) public onlyCustodian {
            bytes32 operationHash = keccak256(abi.encodePacked("BULKISSUE", hashes, expireTime, sequenceId));
            
            address otherSigner = verifyMultiSig(operationHash, signature, expireTime, sequenceId);
            
            documentStore.bulkIssue(hashes);
            
            emit BulkIssue(msg.sender, otherSigner, operationHash, hashes);
        }
        
    /**
     * Execute a multi-signature revoke transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
     * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
     *
     * @param hash the certificate's hash that will be revoked on the blockchain
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * @param signature second signer's signature
     */
    function revokeMultiSig(
        bytes32 hash,
        uint expireTime,
        uint sequenceId,
        bytes memory signature
        ) public onlyCustodian {
            bytes32 operationHash = keccak256(abi.encodePacked("REVOKE", hash, expireTime, sequenceId));
            
            address otherSigner = verifyMultiSig(operationHash, signature, expireTime, sequenceId);
            
            documentStore.revoke(hash);
            
            emit Revoked(msg.sender, otherSigner, operationHash, hash);
        }
        
     /**
     * Execute a multi-signature bulk revoke transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
     * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
     *
     * @param hashes an array of certificate hashes that will be revoked on the blockchain
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * @param signature second signer's signature
     */
    function bulkRevokeMultiSig(
        bytes32[] memory hashes,
        uint expireTime,
        uint sequenceId,
        bytes memory signature
        ) public onlyCustodian {
            bytes32 operationHash = keccak256(abi.encodePacked("BULKREVOKE", hashes, expireTime, sequenceId));
            
            address otherSigner = verifyMultiSig(operationHash, signature, expireTime, sequenceId);
            
            documentStore.bulkRevoke(hashes);
            
            emit BulkRevoke(msg.sender, otherSigner, operationHash, hashes);
        }
    
    /**
     * Execute a multi-signature transfer transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
     * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
     * This transaction transfers the ownership of the certificate store to a new owner.
     *
     * @param newOwner the new owner's address
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * @param signature second signer's signature
     */    
    function transferMultiSig(
        address newOwner,
        uint expireTime,
        uint sequenceId,
        bytes memory signature
        ) public onlyBackup {
            bytes32 operationHash = keccak256(abi.encodePacked("TRANSFER", newOwner, expireTime, sequenceId));
            
            address otherSigner = verifyMultiSig(operationHash, signature, expireTime, sequenceId);
            
            documentStore.transferOwnership(newOwner);
            
            emit Transferred(msg.sender, otherSigner, newOwner);
        }
    
    /**
     * Execute a multi-signature change transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
     * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
     * This transaction changes the address of the DocumentStore on this wallet contract.
     *
     * @param newStore the new owner's address
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * @param signature second signer's signature
     */  
    function changeStoreMultiSig(
        address newStore,
        uint expireTime,
        uint sequenceId,
        bytes memory signature
        ) public onlyBackup {
            bytes32 operationHash = keccak256(abi.encodePacked("CHANGE", newStore, expireTime, sequenceId));
            
            address otherSigner = verifyMultiSig(operationHash, signature, expireTime, sequenceId);
            
            documentStore = DocumentStore(newStore);
            
            emit Change(msg.sender, otherSigner, newStore);
        }
        
    /**
     * Do common multisig verification for both Issue and Revoke transactions
     *
     * @param operationHash keccak256(prefix, hash, expireTime, sequenceId)
     * @param signature second signer's signature
     * @param expireTime the number of seconds since 1970 for which this transaction is valid
     * @param sequenceId the unique sequence id obtainable from getNextSequenceId
     * returns address that has created the signature
     */
    function verifyMultiSig(
        bytes32 operationHash,
        bytes memory signature,
        uint expireTime,
        uint sequenceId
        ) private returns (address) {
    
            address otherSigner = recoverAddressFromSignature(operationHash, signature);
            
            // Verify that the transaction has not expired
            if (expireTime < block.timestamp) {
                // Transaction expired
                revert();
            }
    
            // Try to insert the sequence ID. Will revert if the sequence id was invalid
            tryInsertSequenceId(sequenceId);
        
            if (!isSigner(otherSigner)) {
                // Other signer not on this wallet or operation does not match arguments
                revert();
            }
            if (otherSigner == msg.sender) {
                // Cannot approve own transaction
                revert();
            }
        
            return otherSigner;
        }
    
    /**
     * Gets signer's address using ecrecover
     * @param operationHash see Data Formats
     * @param signature see Data Formats
     * returns address recovered from the signature
     */
    function recoverAddressFromSignature(
        bytes32 operationHash,
        bytes memory signature
        ) private pure returns (address) {
            if (signature.length != 65) {
            revert();
            }
        // We need to unpack the signature, which is given as an array of 65 bytes (like eth.sign)
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := and(mload(add(signature, 65)), 255)
        }
        if (v < 27) {
            v += 27; // Ethereum versions are 27 or 28 as opposed to 0 or 1 which is submitted by some signing libs
        }
        return ecrecover(operationHash, v, r, s);
    }
        
    /**
     * Verify that the sequence id has not been used before and inserts it. Throws if the sequence ID was not accepted.
     * We collect a window of up to 10 recent sequence ids, and allow any sequence id that is not in the window and
     * greater than the minimum element in the window.
     * @param sequenceId to insert into array of stored ids
     */
    function tryInsertSequenceId(uint sequenceId) private onlyInitiators {
        // Keep a pointer to the lowest value element in the window
        uint lowestValueIndex = 0;
        for (uint i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
            if (recentSequenceIds[i] == sequenceId) {
                // This sequence ID has been used before. Disallow!
                revert();
            }
            if (recentSequenceIds[i] < recentSequenceIds[lowestValueIndex]) {
                lowestValueIndex = i;
            }
        }
        if (sequenceId < recentSequenceIds[lowestValueIndex]) {
            // The sequence ID being used is lower than the lowest value in the window
            // so we cannot accept it as it may have been used before
            revert();
        }
        if (sequenceId > (recentSequenceIds[lowestValueIndex] + 10000)) {
            // Block sequence IDs which are much higher than the lowest value
            // This prevents people blocking the contract by using very large sequence IDs quickly
            revert();
        }
        recentSequenceIds[lowestValueIndex] = sequenceId;
    }
    
    /**
     * Gets the next available sequence ID for signing when using executeAndConfirm
     * returns the sequenceId one higher than the highest currently stored
     */
    function getNextSequenceId() public view returns (uint) {
        uint highestSequenceId = 0;
        for (uint i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
            if (recentSequenceIds[i] > highestSequenceId) {
                highestSequenceId = recentSequenceIds[i];
            }
        }
    return highestSequenceId + 1;
    }
}