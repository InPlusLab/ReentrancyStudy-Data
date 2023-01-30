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



/// @title sets terms for tokens in ETO

contract ETOTokenTerms is IContractId {



    ////////////////////////

    // Immutable state

    ////////////////////////



    // minimum number of tokens being offered. will set min cap

    uint256 public MIN_NUMBER_OF_TOKENS;

    // maximum number of tokens being offered. will set max cap

    uint256 public MAX_NUMBER_OF_TOKENS;

    // base token price in EUR-T, without any discount scheme

    uint256 public TOKEN_PRICE_EUR_ULPS;

    // maximum number of tokens in whitelist phase

    uint256 public MAX_NUMBER_OF_TOKENS_IN_WHITELIST;

    // equity tokens per share

    uint256 public constant EQUITY_TOKENS_PER_SHARE = 10000;

    // equity tokens decimals (precision)

    uint8 public constant EQUITY_TOKENS_PRECISION = 0; // indivisible





    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        uint256 minNumberOfTokens,

        uint256 maxNumberOfTokens,

        uint256 tokenPriceEurUlps,

        uint256 maxNumberOfTokensInWhitelist

    )

        public

    {

        require(maxNumberOfTokensInWhitelist <= maxNumberOfTokens);

        require(maxNumberOfTokens >= minNumberOfTokens);

        // min cap must be > single share

        require(minNumberOfTokens >= EQUITY_TOKENS_PER_SHARE, "NF_ETO_TERMS_ONE_SHARE");



        MIN_NUMBER_OF_TOKENS = minNumberOfTokens;

        MAX_NUMBER_OF_TOKENS = maxNumberOfTokens;

        TOKEN_PRICE_EUR_ULPS = tokenPriceEurUlps;

        MAX_NUMBER_OF_TOKENS_IN_WHITELIST = maxNumberOfTokensInWhitelist;

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x591e791aab2b14c80194b729a2abcba3e8cce1918be4061be170e7223357ae5c, 0);

    }

}