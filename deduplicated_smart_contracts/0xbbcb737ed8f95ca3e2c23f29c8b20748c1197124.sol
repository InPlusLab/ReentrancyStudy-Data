/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

/**
 *  @authors: [@mtsalenc]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;


interface ArbitrableTokenList {
    
    enum TokenStatus {
        Absent, // The token is not in the registry.
        Registered, // The token is in the registry.
        RegistrationRequested, // The token has a request to be added to the registry.
        ClearingRequested // The token has a request to be removed from the registry.
    }
    
    function getTokenInfo(bytes32) external view returns (string memory, string memory, address, string memory, TokenStatus, uint);
    function queryTokens(bytes32 _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst, address _tokenAddr)
        external
        view
        returns (bytes32[] memory values, bool hasMore);
}

/** @title TokensView
 *  Utility view contract to fetch multiple token information at once.
 */
contract TokensView {
    
    struct Token {
        bytes32 ID;
        string name;
        string ticker;
        address addr;
        string symbolMultihash;
        ArbitrableTokenList.TokenStatus status;
        uint numberOfRequests;
    }
    
    /** @dev Fetch up to 500 token IDs of the first tokens present on the tcr with the address.
     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.
     *  @param _tokenAddresses The address of each token.
     *  @return The IDs of the tokens or 0 if the token is not present.
     */
    function getTokensIDsForAddresses(address _t2crAddress, address[] calldata _tokenAddresses) external view returns (bytes32[500] memory tokenIDs) {
        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);
        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;
        for (uint i = 0; i < _tokenAddresses.length; i++){
            (bytes32[] memory tokenID, ) = t2cr.queryTokens(ZERO_ID, 50, [false, true, false, true, false, true, false, false], true, _tokenAddresses[i]);
            tokenIDs[i] = tokenID[0];
        }
    }
    
    /** @dev Fetch up to 500 tokens information with token IDs.
     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.
     *  @param _tokenIDs The IDs of the tokens we want to query.
     *  @return tokens The tokens information.
     */
    function getTokens(address _t2crAddress, bytes32[] calldata _tokenIDs) 
        external 
        view 
        returns (Token[500] memory tokens)
    {
        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);
        for (uint i = 0; i < _tokenIDs.length; i++){
            (
                string memory tokenName, 
                string memory tokenTicker, 
                address tokenAddress, 
                string memory symbolMultihash, 
                ArbitrableTokenList.TokenStatus status, 
                uint numberOfRequests
            ) = t2cr.getTokenInfo(_tokenIDs[i]);
            
            tokens[i] = Token(
                _tokenIDs[i],
                tokenName,
                tokenTicker,
                tokenAddress,
                symbolMultihash,
                status,
                numberOfRequests
            );
        }

    }
}