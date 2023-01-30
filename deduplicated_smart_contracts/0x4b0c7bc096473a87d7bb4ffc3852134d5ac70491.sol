/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity ^0.6.11;

//SPDX-License-Identifier: UNLICENSED

//certo v20070101001c061 noima (c) all right reserved 2020
contract BaseCertoChainContract {
    address payable creator;
    address payable owner;

    bool public isSealed;

    constructor() public {
        creator = msg.sender;
        owner = msg.sender;
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account,"not allowed");
        _;
    }

    modifier onlyIfNotSealed() //semantic when sealed is not possible to change sensible data
    {
        if (isSealed) revert("sealed contract");
        _;
    }

    function kill() public onlyBy(owner) {
        selfdestruct(owner);
    }

    function setCreator(address payable _creator) public onlyBy(creator) {
        creator = _creator;
        emit EventReady(address(this), "setCreator");
    }

    function setOwner(address payable _owner) public onlyBy(owner) {
        owner = _owner;
        emit EventReady(address(this), "SetOwner");
    }

    function setSealed() public onlyBy(owner) {
        isSealed = true;
        emit EventSealed(address(this));
    } //seal down contract not reversible

    event EventSealed(address self); //invoked when contract is sealed
    event EventSetCreator(address self); //invoked when we change creator
    event EventSetOwner(address self); //invoked when we change owner
    event EventReady(address self, string method); //invoked when we have done the method action
}

/// @title  A Proof Of  existence smart contract
/// @author Mauro G. Cordioli ezlab
/// @notice Check the details ad https://certo.legal/scv61
contract ProofCertoChainContract is BaseCertoChainContract {
    mapping(bytes32 => bool) private CertoLedger;

    function NotarizeProof(bytes32 hashproof)
        public
        onlyBy(creator)
        onlyIfNotSealed()
    {
        CertoLedger[hashproof] = true;
    }

    function NotarizeProofNote(bytes32 hashproof, string memory note)
        public
        onlyBy(creator)
        onlyIfNotSealed()
    {
        CertoLedger[hashproof] = true;
        emit EventProof(address(this), hashproof, note); // trace a note in the logs
    }

    function CheckProofByHashReturnsTrueIFOk(bytes32 hashproof)
        public
        view
        returns (bool)
    {
        return CertoLedger[hashproof];
    } 

    mapping(bytes32 => uint256) private CertoLedgerTimestamp;

    /// @notice Notarize the hash and return the unixtime stamp of the correspinging block
    /// @param hashproof The sha256 hash to timestamp
    /// @return unixtepoch imestamp of notarization
    function NotarizeProofTimeStamp(bytes32 hashproof)
        public
        onlyBy(creator)
        onlyIfNotSealed()
        returns (uint256)
    {
        uint256 ts = CertoLedgerTimestamp[hashproof];
        if (ts == 0) {
            ts = block.timestamp;
            CertoLedgerTimestamp[hashproof] = ts;
        }
        return ts;
    }

    function CheckProofTimeStampByHashReturnsNonZeroUnixEpochIFOk(
        bytes32 hashproof
    ) public view returns (uint256) {
        return CertoLedgerTimestamp[hashproof];
    }

    string public Description; //Contract Purpose HASH
    int256 public constant Version = 0x03003b00;

    constructor(string memory _Description) public {
        Description = _Description;

        emit EventReady(address(this), "constructor");
    }

    event EventProof(address self, bytes32 hashproof, string note); // trace a note in the logs
}