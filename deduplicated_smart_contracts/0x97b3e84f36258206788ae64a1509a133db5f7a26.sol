/**
 *Submitted for verification at Etherscan.io on 2019-09-19
*/

pragma solidity ^0.5.10;

contract DenshiJitsuin {
    /// "60f91998: sign(uint256,bytes32,address,bytes)
    bytes4 SIGN_METHOD_HASH = 0x60f91998;
    
    struct Signature {
        bool isSigned;
        bytes32 hash;
    }

    // mapping(documentId => mapping(signer => Signature))
    mapping(uint256 => mapping(address => Signature)) private _signatures; 
    // mapping(documentId => mapping(index => signer)
    mapping(uint256 => mapping(uint256 => address)) private _documentSigners;
    // mapping(documentId => signerCount)
    mapping(uint256 => uint256) private _documentSignerCount;

    constructor() public {}

    /// @dev Sign on a specified document.
    /// @dev _signer should be matched against the msg.sender or an address recovered from _sig
    /// @param _documentId Document's ID
    /// @param _documentHash SHA256 hash of the document's content
    /// @param _signer Account address who is signing to the document
    /// @param _sig ECDSA signature (for meta transaction)
    /// @return bool true if the method succeeded
    function sign(uint256 _documentId, bytes32 _documentHash, address _signer, bytes calldata _sig) external returns (bool) {
        if(_signatures[_documentId][_signer].isSigned) {
            return true;
        } else {
            address signer = msg.sender == _signer ? msg.sender : recover(keccak256(abi.encodePacked(SIGN_METHOD_HASH, _documentId, _documentHash)), _sig);
            require(signer == _signer);
            _signatures[_documentId][_signer] = Signature(true, _documentHash);
            _documentSigners[_documentId][_documentSignerCount[_documentId]] = _signer;
            _documentSignerCount[_documentId]++;
            return true;
        }
    }
    
    /// @dev Get status if a specified signer has signed on a specified document or not.
    /// @dev It also returns document hash sent by the signer at the timing of sigining.
    /// @param _documentId Document's ID
    /// @param _signer Account address to inspect its signature on the document
    /// @return bool true if the method succeeded
    function getSignature(uint256 _documentId, address _signer) external view returns (bool, bytes32) {
        Signature memory _signature = _signatures[_documentId][_signer];
        return (_signature.isSigned, _signature.hash);
    }
    
    /// @dev Get a signer address at the specified document and index
    /// @param _documentId Document's ID
    /// @param _index Index number of signer on the document
    /// @return address Signer address
    function getSigner(uint256 _documentId, uint256 _index) external view returns (address) {
        return _documentSigners[_documentId][_index];
    }
    
    /// @dev Get the number of signers on the specified document
    /// @param _documentId Document's ID
    /// @return uint256 Number of signers
    function getSignerCount(uint256 _documentId) external view returns (uint256) {
        return _documentSignerCount[_documentId];
    }

    function recover(bytes32 _hash, bytes memory _sig) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        //Check the signature length
        if (_sig.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }
}