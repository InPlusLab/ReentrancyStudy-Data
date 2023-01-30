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



/// @title sets duration of states in ETO

contract ETODurationTerms is IContractId {



    ////////////////////////

    // Immutable state

    ////////////////////////



    // duration of Whitelist state

    uint32 public WHITELIST_DURATION;



    // duration of Public state

    uint32 public PUBLIC_DURATION;



    // time for Nominee and Company to sign Investment Agreement offchain and present proof on-chain

    uint32 public SIGNING_DURATION;



    // time for Claim before fee payout from ETO to NEU holders

    uint32 public CLAIM_DURATION;



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        uint32 whitelistDuration,

        uint32 publicDuration,

        uint32 signingDuration,

        uint32 claimDuration

    )

        public

    {

        WHITELIST_DURATION = whitelistDuration;

        PUBLIC_DURATION = publicDuration;

        SIGNING_DURATION = signingDuration;

        CLAIM_DURATION = claimDuration;

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x5fb50201b453799d95f8a80291b940f1c543537b95bff2e3c78c2e36070494c0, 0);

    }

}