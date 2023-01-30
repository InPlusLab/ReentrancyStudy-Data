/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

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
}

/** @title TokensView
 *  Utility view contract to fetch multiple token information at once.
 */
contract TokensView {
    
    struct Token {
        string name;
        string ticker;
        address addr;
        string symbolMultihash;
        ArbitrableTokenList.TokenStatus status;
        uint numberOfRequests;
    }
    
    /** @dev Fetch token information with token IDs.
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