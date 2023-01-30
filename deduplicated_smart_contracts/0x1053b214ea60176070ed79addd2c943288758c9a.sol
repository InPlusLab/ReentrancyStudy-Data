/**

 *Submitted for verification at Etherscan.io on 2018-11-27

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



contract ShareholderRights is IContractId {



    ////////////////////////

    // Types

    ////////////////////////



    enum VotingRule {

        // nominee has no voting rights

        NoVotingRights,

        // nominee votes yes if token holders do not say otherwise

        Positive,

        // nominee votes against if token holders do not say otherwise

        Negative,

        // nominee passes the vote as is giving yes/no split

        Proportional

    }



    ////////////////////////

    // Constants state

    ////////////////////////



    bytes32 private constant EMPTY_STRING_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;



    ////////////////////////

    // Immutable state

    ////////////////////////



    // a right to drag along (or be dragged) on exit

    bool public constant HAS_DRAG_ALONG_RIGHTS = true;

    // a right to tag along

    bool public constant HAS_TAG_ALONG_RIGHTS = true;

    // information is fundamental right that cannot be removed

    bool public constant HAS_GENERAL_INFORMATION_RIGHTS = true;

    // voting Right

    VotingRule public GENERAL_VOTING_RULE;

    // voting rights in tag along

    VotingRule public TAG_ALONG_VOTING_RULE;

    // liquidation preference multiplicator as decimal fraction

    uint256 public LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC;

    // founder's vesting

    bool public HAS_FOUNDERS_VESTING;

    // duration of general voting

    uint256 public GENERAL_VOTING_DURATION;

    // duration of restricted act votings (like exit etc.)

    uint256 public RESTRICTED_ACT_VOTING_DURATION;

    // offchain time to finalize and execute voting;

    uint256 public VOTING_FINALIZATION_DURATION;

    // quorum of tokenholders for the vote to count as decimal fraction

    uint256 public TOKENHOLDERS_QUORUM_FRAC = 10**17; // 10%

    // number of tokens voting / total supply must be more than this to count the vote

    uint256 public VOTING_MAJORITY_FRAC = 10**17; // 10%

    // url (typically IPFS hash) to investment agreement between nominee and company

    string public INVESTMENT_AGREEMENT_TEMPLATE_URL;



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        VotingRule generalVotingRule,

        VotingRule tagAlongVotingRule,

        uint256 liquidationPreferenceMultiplierFrac,

        bool hasFoundersVesting,

        uint256 generalVotingDuration,

        uint256 restrictedActVotingDuration,

        uint256 votingFinalizationDuration,

        uint256 tokenholdersQuorumFrac,

        uint256 votingMajorityFrac,

        string investmentAgreementTemplateUrl

    )

        public

    {

        // todo: revise requires

        require(uint(generalVotingRule) < 4);

        require(uint(tagAlongVotingRule) < 4);

        // quorum < 100%

        require(tokenholdersQuorumFrac < 10**18);

        require(keccak256(abi.encodePacked(investmentAgreementTemplateUrl)) != EMPTY_STRING_HASH);



        GENERAL_VOTING_RULE = generalVotingRule;

        TAG_ALONG_VOTING_RULE = tagAlongVotingRule;

        LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC = liquidationPreferenceMultiplierFrac;

        HAS_FOUNDERS_VESTING = hasFoundersVesting;

        GENERAL_VOTING_DURATION = generalVotingDuration;

        RESTRICTED_ACT_VOTING_DURATION = restrictedActVotingDuration;

        VOTING_FINALIZATION_DURATION = votingFinalizationDuration;

        TOKENHOLDERS_QUORUM_FRAC = tokenholdersQuorumFrac;

        VOTING_MAJORITY_FRAC = votingMajorityFrac;

        INVESTMENT_AGREEMENT_TEMPLATE_URL = investmentAgreementTemplateUrl;

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x7f46caed28b4e7a90dc4db9bba18d1565e6c4824f0dc1b96b3b88d730da56e57, 0);

    }

}