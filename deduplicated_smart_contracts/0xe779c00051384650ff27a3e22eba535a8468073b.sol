/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity >=0.6.11;

//SPDX-License-Identifier: UNLICENSED

//certo v20050101006c060 noima (c) all rights reserved 2020
contract BaseCertoChainContract {
    address payable creator;
    address payable owner;

    bool public isSealed;

    constructor() public {
        creator = msg.sender;
        owner = msg.sender;
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account, "not allowed");
        _;
    }

    modifier onlyIfNotSealed() //semantic when sealed is not possible to change sensible data
    {
        if (isSealed) revert("sealed");
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


contract DocumentCertoChainContract is BaseCertoChainContract {
    //string  public  Description ; //Description the description is in the trasaction log

    bytes32 public FileHash; //SecuritySeal HASH
    bytes32 public DescriptionHash; //SecuritySeal HASH
    int256 public FileData; //SecuritySeal DATA format AAMMDD

    address public NextOwner;
    address public PrevOwner;

    constructor(
        string memory _Description,
        bytes32 _DescriptionHash,
        bytes32 _FileHash,
        int256 _FileData
    ) public {
        NextOwner = address(this);
        //Description=_Description; the description is in the trasaction log

        FileHash = _FileHash;
        DescriptionHash = _DescriptionHash;
        FileData = _FileData;

        emit EventNote(address(this), _Description);
        emit EventReady(address(this), "constructor");
    }

    function setNextOwner(address _NextOwner)
        public
        onlyBy(creator)
        onlyIfNotSealed()
    {
        NextOwner = _NextOwner;
        emit EventNewOwner(address(this));
    }

    function setPrevOwner(address _PrevOwner)
        public
        onlyBy(creator)
        onlyIfNotSealed()
    {
        PrevOwner = _PrevOwner;
        emit EventNewPrevOwner(address(this));
    }

    event EventNewOwner(address self);
    event EventNewPrevOwner(address self);

    event EventNote(address self, string note); // trace a note in the logs
}


contract TagCertoChainContract is BaseCertoChainContract {
    bool public isActive;

    function constructorx(address payable _owner) public {
        owner = (_owner);
        emit EventReady(address(this), "constructor");
    }

    constructor(
        address payable _owner,
        bytes32 signaturehash,
        bytes32 signaturemaskR,
        bytes32 signaturemaskS,
        uint8 signaturemaskV
    ) public {
        owner = (_owner);
        SignatureMaskR = signaturemaskR;
        SignatureMaskS = signaturemaskS;
        SignatureMaskV = signaturemaskV;
        SignatureHash = signaturehash;
        emit EventReady(address(this), "constructor");
    }

    function ActivateTag(address Target) public onlyBy(owner) {
        TargetDocument = Target;
        emit EventReady(address(this), "ActivateTag");
    }

    function SignTag(
        bytes32 signaturehash,
        bytes32 signaturemaskR,
        bytes32 signaturemaskS,
        uint8 signaturemaskV
    ) public onlyBy(owner) {
        SignatureMaskR = signaturemaskR;
        SignatureMaskS = signaturemaskS;
        SignatureMaskV = signaturemaskV;
        SignatureHash = signaturehash;
        emit EventReady(address(this), "SignTag");
    }

    function VerifyTag(bytes8 signaturepinS)
        public
        view
        returns (string memory)
    {
        bytes32 signatureR;
        bytes32 signatureS;
        bytes32 signatureSpad;
        signatureSpad = signaturepinS;
        signatureR = SignatureMaskR;
        signatureS = SignatureMaskS | (signatureSpad);
        //emit EventReady(address(this),"VerifyTag");
        if (
            ecrecover(SignatureHash, SignatureMaskV, signatureR, signatureS) ==
            creator
        ) {
            return "OK IS TAG VALID";
        } else {
            return "NOT A VALID TAG";
        }

        // return signatureS;
    }

    function RecoverSigner(
        bytes32 msgHash,
        bytes32 signaturepinR,
        bytes32 signaturepinS
    ) public view returns (address) {
        bytes32 signatureR;
        bytes32 signatureS;
        signatureR = SignatureMaskR | signaturepinR;
        signatureS = SignatureMaskS | signaturepinS;

        return ecrecover(msgHash, SignatureMaskV, signatureR, signatureS);
    }

    address public TargetDocument;
    bytes32 public SignatureMaskR;
    bytes32 public SignatureMaskS;
    uint8 public SignatureMaskV;

    bytes32 public SignatureHash;
}