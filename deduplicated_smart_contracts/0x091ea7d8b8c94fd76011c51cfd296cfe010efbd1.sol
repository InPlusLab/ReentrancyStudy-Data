/**
 *Submitted for verification at Etherscan.io on 2019-07-25
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
    function queryTokens(bytes32 _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst, address _tokenAddr)
        external
        view
        returns (bytes32[] memory values, bool hasMore);
}

interface ExchangeRegistry {
    function getExchange(address _tokenContract) external view returns (address);
}

interface AddressRegistry {
    function queryAddresses(address _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst)
        external
        view
        returns (address[] memory values, bool hasMore);
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
        address exchange;
    }
    
    /** @dev Fetch up to 100 token information with badges.
     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.
     *  @param _exchangeRegistry The address of the registry contract for exchanges.
     *  @param _badgeContract The address of badge contract to query.
     *  @return tokens The tokens information.
     */
    function getTokensInfo(
        address _t2crAddress, 
        address _exchangeRegistry, 
        address _badgeContract
    ) 
        public 
        view 
        returns (Token[100] memory tokens)
    {
        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);
        ExchangeRegistry exchangeRegistry = ExchangeRegistry(_exchangeRegistry);
        AddressRegistry addressRegistry = AddressRegistry(_badgeContract);
        (address[] memory _tokenAddresses,) = addressRegistry.queryAddresses(
            0x0000000000000000000000000000000000000000, 
            100, 
            [false, true, false, true, false, true, false, false], 
            true
        );
        bytes32[100] memory _tokenIDs = getTokensIDsForAddresses(_t2crAddress, _tokenAddresses);
        
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
                numberOfRequests,
                exchangeRegistry.getExchange(tokenAddress)
            );
        }
    }
    
    
    /** @dev Fetch up to 100 token IDs of the first tokens present on the tcr with the address.
     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.
     *  @param _tokenAddresses The address of each token.
     *  @return The IDs of the tokens or 0 if the token is not present.
     */
    function getTokensIDsForAddresses(address _t2crAddress, address[] memory _tokenAddresses) internal view returns (bytes32[100] memory tokenIDs) {
        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);
        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;
        for (uint i = 0; i < 100; i++){
            (bytes32[] memory tokenID, ) = t2cr.queryTokens(ZERO_ID, 0, [false, true, false, true, false, true, false, false], true, _tokenAddresses[i]);
            tokenIDs[i] = tokenID[0];
        }
    }
}