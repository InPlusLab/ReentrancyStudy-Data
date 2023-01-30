/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity 0.4.20;

contract Accessible {
    /** Access Right Management **
    * Copyright 2019
    * Florian Weigand
    * Synalytix UG, Munich
    * florian(at)synalytix.de
    */

    address      public owner;
    mapping(address => bool)     public accessAllowed;

    function Accessible() public {
        owner = msg.sender;
    }

    modifier ownership() {
        require(owner == msg.sender);
        _;
    }

    modifier accessible() {
        require(accessAllowed[msg.sender]);
        _;
    }

    function allowAccess(address _address) ownership public {
        if (_address != address(0)) {
            accessAllowed[_address] = true;
        }
    }

    function denyAccess(address _address) ownership public {
        if (_address != address(0)) {
            accessAllowed[_address] = false;
        }
    }

    function transferOwnership(address _address) ownership public {
        if (_address != address(0)) {
            owner = _address;
        }
    }
}

contract TrueProfileStorage is Accessible {
    /** Data Storage Contract **
    * Copyright 2019
    * Florian Weigand
    * Synalytix UG, Munich
    * florian(at)synalytix.de
    */

    /**** signature struct ****/
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 revocationReasonId;
        bool isValue;
    }

    /**** signature storage ****/
    mapping(bytes32 => Signature)   public signatureStorage;

    /**** general storage of non-struct data which might
    be needed for further development of main contract ****/
    mapping(bytes32 => uint256)     public uIntStorage;
    mapping(bytes32 => string)      public stringStorage;
    mapping(bytes32 => address)     public addressStorage;
    mapping(bytes32 => bytes)       public bytesStorage;
    mapping(bytes32 => bool)        public boolStorage;
    mapping(bytes32 => int256)      public intStorage;

    /**** CRUD for Signature storage ****/
    function getSignature(bytes32 _key) external view returns (uint8 v, bytes32 r, bytes32 s, uint8 revocationReasonId) {
        Signature memory tempSignature = signatureStorage[_key];
        if (tempSignature.isValue) {
            return(tempSignature.v, tempSignature.r, tempSignature.s, tempSignature.revocationReasonId);
        } else {
            return(0, bytes32(0), bytes32(0), 0);
        }
    }

    function setSignature(bytes32 _key, uint8 _v, bytes32 _r, bytes32 _s, uint8 _revocationReasonId) accessible external {
        require(ecrecover(_key, _v, _r, _s) != 0x0);
        Signature memory tempSignature = Signature({
            v: _v,
            r: _r,
            s: _s,
            revocationReasonId: _revocationReasonId,
            isValue: true
        });
        signatureStorage[_key] = tempSignature;
    }

    function deleteSignature(bytes32 _key) accessible external {
        require(signatureStorage[_key].isValue);
        Signature memory tempSignature = Signature({
            v: 0,
            r: bytes32(0),
            s: bytes32(0),
            revocationReasonId: 0,
            isValue: false
        });
        signatureStorage[_key] = tempSignature;
    }

    /**** Get Methods for additional storage ****/
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Set Methods for additional storage ****/
    function setAddress(bytes32 _key, address _value) accessible external {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) accessible external {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) accessible external {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) accessible external {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) accessible external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) accessible external {
        intStorage[_key] = _value;
    }

    /**** Delete Methods for additional storage ****/
    function deleteAddress(bytes32 _key) accessible external {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) accessible external {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) accessible external {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) accessible external {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) accessible external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) accessible external {
        delete intStorage[_key];
    }
}

contract TrueProfileLogic is Accessible {
    /** Logic Contract (updatable) **
    * Copyright 2019
    * Florian Weigand
    * Synalytix UG, Munich
    * florian(at)synalytix.de
    */

    TrueProfileStorage trueProfileStorage;

    function TrueProfileLogic(address _trueProfileStorage) public {
        trueProfileStorage = TrueProfileStorage(_trueProfileStorage);
    }

    /**** Signature logic methods ****/

    // add or update TrueProof
    // if not present add to array
    // if present the old TrueProof can be replaced with a new TrueProof
    function addTrueProof(bytes32 _key, uint8 _v, bytes32 _r, bytes32 _s) accessible external {
        require(accessAllowed[ecrecover(_key, _v, _r, _s)]);
        // the certifcate is valid, so set the revokationReasonId to 0
        uint8 revokationReasonId = 0;
        trueProfileStorage.setSignature(_key, _v, _r, _s, revokationReasonId);
    }

    // if the TrueProof was issued by error it can be revoked
    // for revocation a reason id needs to be given
    function revokeTrueProof(bytes32 _key, uint8 _revocationReasonId) accessible external {
        require(_revocationReasonId != 0);

        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 oldRevocationReasonId;
        (v, r, s, oldRevocationReasonId) = trueProfileStorage.getSignature(_key);

        require(v != 0);

        // set the revokation reason id to the new value
        trueProfileStorage.setSignature(_key, v, r, s, _revocationReasonId);
    }

    function isValidTrueProof(bytes32 _key) external view returns (bool) {
        // needs to be not revoked AND needs to have a valid signature
        if (this.isValidSignatureTrueProof(_key) && this.isNotRevokedTrueProof(_key)) {
            return true;
        } else {
            return false;   
        }
    }

    function isValidSignatureTrueProof(bytes32 _key) external view returns (bool) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 revocationReasonId;
        (v, r, s, revocationReasonId) = trueProfileStorage.getSignature(_key);

        // needs to have a valid signature
        if (accessAllowed[ecrecover(_key, v, r, s)]) {
            return true;
        } else {
            return false;   
        }
    }

    function isNotRevokedTrueProof(bytes32 _key) external view returns (bool) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 revocationReasonId;
        (v, r, s, revocationReasonId) = trueProfileStorage.getSignature(_key);

        // needs to be not revoked
        if (revocationReasonId == 0) {
            return true;
        } else {
            return false;
        }
    }

    function getSignature(bytes32 _key) external view returns (uint8 v, bytes32 r, bytes32 s, uint8 revocationReasonId) {
        return trueProfileStorage.getSignature(_key);
    }

    function getRevocationReasonId(bytes32 _key) external view returns (uint8) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 revocationReasonId;
        (v, r, s, revocationReasonId) = trueProfileStorage.getSignature(_key);

        return revocationReasonId;
    }
}