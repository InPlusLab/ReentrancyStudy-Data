/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity 0.4.26;

library SafeMath {
    /** SafeMath **
    * SafeMath based on the OpenZeppelin framework
    * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function abs128(int128 a) internal pure returns (int128) {
        return a < 0 ? a * -1 : a;
    }
}

contract Accessible {
    /** Access Right Management **
    * Copyright 2019
    * Florian Weigand
    * Synalytix UG, Munich
    * florian(at)synalytix.de
    */

    address public owner;
    mapping(address => bool) public accessAllowed;

    constructor() public {
        owner = msg.sender;
    }

    modifier ownership() {
        require(owner == msg.sender, "Accessible: Only the owner of contract can call this method");
        _;
    }

    modifier accessible() {
        require(accessAllowed[msg.sender], "Accessible: This address has no allowence to access this method");
        _;
    }

    function allowAccess(address _address) public ownership {
        if (_address != address(0)) {
            accessAllowed[_address] = true;
        }
    }

    function denyAccess(address _address) public ownership {
        if (_address != address(0)) {
            accessAllowed[_address] = false;
        }
    }

    function transferOwnership(address _address) public ownership {
        if (_address != address(0)) {
            owner = _address;
        }
    }
}

contract Repaying is Accessible {
    /** Repaying Contract **
    * Idea based on https://ethereum.stackexchange.com/a/38517/55678
    * Stackexchange user: medvedev1088
    * ---------------------
    * ReentrancyGuard based on the OpenZeppelin framework
    * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol
    * ---------------------
    * Copyright 2019 (only modifications)
    * Florian Weigand
    * Synalytix UG, Munich
    * florian(at)synalytix.de
    */

    using SafeMath for uint256;
    uint256 private guardCounter;
    bool stopRepaying = false;
    // the max gas price is set to 65 gwei this is the same as local server max fee setting
    uint256 maxGasPrice = 65000000000;
    // gas consomption of the repayable function
    uint256 additionalGasConsumption = 42492;

    constructor () internal {
        // the counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        guardCounter = 1;
    }

    modifier repayable {
        guardCounter += 1;
        uint256 localCounter = guardCounter;

        // repayable logic with kill swtich
        if(!stopRepaying) {
            uint256 startGas = gasleft();
            _;
            uint256 gasUsed = startGas.sub(gasleft());
            // use maxGasPrice as upper bound for the gas price
            uint256 gasPrice = maxGasPrice.min256(tx.gasprice);
            uint256 repayal = gasPrice.mul(gasUsed.add(additionalGasConsumption));
            msg.sender.transfer(repayal);
        }
        else {
            _;
        }

        // if the counters don't match a reentrance is happening, stop the execution
        require(localCounter == guardCounter, "Repaying: reentrant call detected");
    }

    function() external payable {
        require(msg.data.length == 0, "Repaying: You can only transfer Ether to this contract *without* any data");
    }

    function withdraw(address _address) public ownership {
        require(_address != address(0) && (accessAllowed[_address] || _address == owner),
        "Repaying: Address is not allowed to withdraw the balance");

        _address.transfer(address(this).balance);
    }

    function setMaxGasPrice(uint256 _maxGasPrice) public ownership {
        // define absolute max. with 125 gwei
        maxGasPrice = _maxGasPrice.min256(125000000000);
    }

    function getMaxGasPrice() external view returns (uint256) {
        return maxGasPrice;
    }

    function setAdditionalGasConsumption(uint256 _additionalGasConsumption) public ownership {
        // define absolute max. with 65.000 gas limit
        additionalGasConsumption = _additionalGasConsumption.min256(65000);
    }

    function getAdditionalGasConsumption() external view returns (uint256) {
        return additionalGasConsumption;
    }

    function setStopRepaying(bool _stopRepaying) public ownership {
        stopRepaying = _stopRepaying;
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
    mapping(bytes32 => uint256) public uIntStorage;
    mapping(bytes32 => string) public stringStorage;
    mapping(bytes32 => address) public addressStorage;
    mapping(bytes32 => bytes) public bytesStorage;
    mapping(bytes32 => bool) public boolStorage;
    mapping(bytes32 => int256) public intStorage;

    /**** CRUD for Signature storage ****/
    function getSignature(bytes32 _key) external view returns (uint8 v, bytes32 r, bytes32 s, uint8 revocationReasonId) {
        Signature memory tempSignature = signatureStorage[_key];
        if (tempSignature.isValue) {
            return(tempSignature.v, tempSignature.r, tempSignature.s, tempSignature.revocationReasonId);
        } else {
            return(0, bytes32(0), bytes32(0), 0);
        }
    }

    function setSignature(bytes32 _key, uint8 _v, bytes32 _r, bytes32 _s, uint8 _revocationReasonId) external accessible {
        require(ecrecover(_key, _v, _r, _s) != 0x0, "TrueProfileStorage: Signature does not resolve to valid address");
        Signature memory tempSignature = Signature({
            v: _v,
            r: _r,
            s: _s,
            revocationReasonId: _revocationReasonId,
            isValue: true
        });
        signatureStorage[_key] = tempSignature;
    }

    function deleteSignature(bytes32 _key) external accessible {
        require(signatureStorage[_key].isValue, "TrueProfileStorage: Signature to delete was not found");
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
    function setAddress(bytes32 _key, address _value) external accessible {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) external accessible {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) external accessible {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) external accessible {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) external accessible {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) external accessible {
        intStorage[_key] = _value;
    }

    /**** Delete Methods for additional storage ****/
    function deleteAddress(bytes32 _key) external accessible {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) external accessible {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) external accessible {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) external accessible {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) external accessible {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) external accessible {
        delete intStorage[_key];
    }
}

contract TrueProfileLogic is Repaying {
    /** Logic Contract (updatable) **
    * Copyright 2019
    * Florian Weigand
    * Synalytix UG, Munich
    * florian(at)synalytix.de
    */

    TrueProfileStorage trueProfileStorage;

    constructor(address _trueProfileStorage) public {
        trueProfileStorage = TrueProfileStorage(_trueProfileStorage);
    }

    /**** Signature logic methods ****/

    // add or update TrueProof
    // if not present add to array
    // if present the old TrueProof can be replaced with a new TrueProof
    function addTrueProof(bytes32 _key, uint8 _v, bytes32 _r, bytes32 _s) external repayable accessible {
        require(accessAllowed[ecrecover(_key, _v, _r, _s)], "TrueProfileLogic: Signature creator has no access to this contract");
        // the certifcate is valid, so set the revokationReasonId to 0
        uint8 revokationReasonId = 0;
        trueProfileStorage.setSignature(_key, _v, _r, _s, revokationReasonId);
    }

    // if the TrueProof was issued by error it can be revoked
    // for revocation a reason id needs to be given
    function revokeTrueProof(bytes32 _key, uint8 _revocationReasonId) external repayable accessible {
        require(_revocationReasonId != 0, "TrueProfileLogic: Revocation reason needs to be unequal to 0");

        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 oldRevocationReasonId;
        (v, r, s, oldRevocationReasonId) = trueProfileStorage.getSignature(_key);

        require(v != 0, "TrueProfileLogic: This TrueProof was already revoked");

        // set the revokation reason id to the new value
        trueProfileStorage.setSignature(_key, v, r, s, _revocationReasonId);
    }

    function isValidTrueProof(bytes32 _key) external view returns (bool) {
        // needs to be not revoked AND needs to have a valid signature
        return this.isValidSignatureTrueProof(_key) && this.isNotRevokedTrueProof(_key);
    }

    function isValidSignatureTrueProof(bytes32 _key) external view returns (bool) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 revocationReasonId;
        (v, r, s, revocationReasonId) = trueProfileStorage.getSignature(_key);

        // needs to have a valid signature
        return accessAllowed[ecrecover(_key, v, r, s)];
    }

    function isNotRevokedTrueProof(bytes32 _key) external view returns (bool) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint8 revocationReasonId;
        (v, r, s, revocationReasonId) = trueProfileStorage.getSignature(_key);

        // needs to be not revoked
        return revocationReasonId == 0;
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