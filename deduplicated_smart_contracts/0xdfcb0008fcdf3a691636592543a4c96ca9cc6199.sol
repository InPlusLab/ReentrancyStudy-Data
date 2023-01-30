/**

 *Submitted for verification at Etherscan.io on 2019-06-04

*/



pragma solidity 0.4.25;



/// @title uniquely identifies deployable (non-abstract) platform contract

/// @notice cheap way of assigning implementations to knownInterfaces which represent system services

///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces

///         EIP820 still in the making

/// @dev ids are generated as follows keccak256("neufund-platform:<contract name>")

///      ids roughly correspond to ABIs

contract IContractId {

    /// @param id defined as above

    /// @param version implementation version

    function contractId() public pure returns (bytes32 id, uint256 version);

}



/// @title sets the contraints of the eto

contract ETOTermsConstraints is IContractId {





    ////////////////////////

    // Types

    ////////////////////////

    enum OfferingDocumentType {

        Memorandum,

        Prospectus

    }



    enum OfferingDocumentSubType {

        Regular,

        Lean

    }



    enum AssetType {

        Security,

        VMA // Vermögensanlage

    }



    ////////////////////////

    // Immutable state

    ////////////////////////



    // min duration from setting the date to ETO start

    uint256 public constant DATE_TO_WHITELIST_MIN_DURATION = 7 days;



    // duration constraints

    uint256 public constant MIN_WHITELIST_DURATION = 0 days;

    uint256 public constant MAX_WHITELIST_DURATION = 30 days;

    uint256 public constant MIN_PUBLIC_DURATION = 0 days;

    uint256 public constant MAX_PUBLIC_DURATION = 60 days;



    // minimum length of whole offer

    uint256 public constant MIN_OFFER_DURATION = 1 days;

    // quarter should be enough for everyone

    uint256 public constant MAX_OFFER_DURATION = 90 days;



    uint256 public constant MIN_SIGNING_DURATION = 14 days;

    uint256 public constant MAX_SIGNING_DURATION = 60 days;



    uint256 public constant MIN_CLAIM_DURATION = 7 days;

    uint256 public constant MAX_CLAIM_DURATION = 30 days;



    // defines wether transfers are allowed after the eto ends

    bool public CAN_SET_TRANSFERABILITY;



    // defines wether a nominee is needed in the investment structure

    bool public HAS_NOMINEE;



    // minimum ticket size for this investment type

    uint256 public MIN_TICKET_SIZE_EUR_ULPS;

    // maximum ticket size for this investment type, 0 means unlimited

    uint256 public MAX_TICKET_SIZE_EUR_ULPS;

    // minimum total investment amount this investment type

    uint256 public MIN_INVESTMENT_AMOUNT_EUR_ULPS;

    // maximum total investment amount this investment type, 0 means unlimited

    uint256 public MAX_INVESTMENT_AMOUNT_EUR_ULPS;



    // public name

    string public NAME;



    // spec of the required offering document

    OfferingDocumentType public OFFERING_DOCUMENT_TYPE;

    OfferingDocumentSubType public OFFERING_DOCUMENT_SUB_TYPE;



    // jurisdiction in which the ETO will be conducted

    string public JURISDICTION;



    // legal type of asset that will be used

    AssetType public ASSET_TYPE;



    // address of the offering operator, will receive platform share from ETOCommitment

    address public TOKEN_OFFERING_OPERATOR;





    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        bool canSetTransferability,

        bool hasNominee,

        uint256 minTicketSizeEurUlps,

        uint256 maxTicketSizeEurUlps,

        uint256 minInvestmentAmountEurUlps,

        uint256 maxInvestmentAmountEurUlps,

        string name,

        OfferingDocumentType offeringDocumentType,

        OfferingDocumentSubType offeringDocumentSubType,

        string jurisdiction,

        AssetType assetType,

        address tokenOfferingOperator

    )

        public

    {   

        require(maxTicketSizeEurUlps == 0 || minTicketSizeEurUlps<=maxTicketSizeEurUlps);

        require(maxInvestmentAmountEurUlps == 0 || minInvestmentAmountEurUlps<=maxInvestmentAmountEurUlps);

        require(maxInvestmentAmountEurUlps == 0 || minTicketSizeEurUlps<=maxInvestmentAmountEurUlps);

        require(assetType != AssetType.VMA || !canSetTransferability);

        require(tokenOfferingOperator != address(0x0));



        CAN_SET_TRANSFERABILITY = canSetTransferability;

        HAS_NOMINEE = hasNominee;

        MIN_TICKET_SIZE_EUR_ULPS = minTicketSizeEurUlps;

        MAX_TICKET_SIZE_EUR_ULPS = maxTicketSizeEurUlps;

        MIN_INVESTMENT_AMOUNT_EUR_ULPS = minInvestmentAmountEurUlps;

        MAX_INVESTMENT_AMOUNT_EUR_ULPS = maxInvestmentAmountEurUlps;

        NAME = name;

        OFFERING_DOCUMENT_TYPE = offeringDocumentType;

        OFFERING_DOCUMENT_SUB_TYPE = offeringDocumentSubType;

        JURISDICTION = jurisdiction;

        ASSET_TYPE = assetType;

        TOKEN_OFFERING_OPERATOR = tokenOfferingOperator;

    }



    //

    // Implements IContractId

    //

    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0xce2be4f5f23c4a6f67ed925fce56afa57c9c8b274b4dfca8d0b1104aa4a6b53a, 0);

    }



}