/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

/**
 *  @authors: [@mtsalenc]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity 0.5.11;
pragma experimental ABIEncoderV2;


interface IArbitrableTokenList {
    
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
    function tokenCount() external view returns (uint);
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
        IArbitrableTokenList.TokenStatus status;
        uint decimals;
    }
    
    /** @dev Fetch up to 500 token IDs of the first tokens present on the tcr with the address.
     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.
     *  @param _tokenAddresses The address of each token.
     *  @return The IDs of the tokens or 0 if the token is not present.
     */
    function getTokensIDsForAddresses(address _t2crAddress, address[] calldata _tokenAddresses) external view returns (bytes32[500] memory tokenIDs) {
        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);
        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;
        for (uint i = 0; i < _tokenAddresses.length; i++){
            (bytes32[] memory tokenID, ) = t2cr.queryTokens(ZERO_ID, 50, [false, true, false, true, false, true, false, false], true, _tokenAddresses[i]);
            tokenIDs[i] = tokenID[0];
        }
    }
    
    /** @dev Fetch up token information with token IDs. If a token contract does not implement the decimals() function, its decimals field will be 0.
     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.
     *  @param _tokenIDs The IDs of the tokens we want to query.
     *  @return tokens The tokens information.
     */
    function getTokens(address _t2crAddress, bytes32[] calldata _tokenIDs, uint[2] calldata _cursorCount) 
        external 
        view 
        returns (Token[] memory tokens)
    {
        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);
        tokens = new Token[](_cursorCount[1]);
        for (uint i = _cursorCount[0]; i < t2cr.tokenCount() && _cursorCount[1] - i > 0 ; i++){
            string[] memory strings = new string[](3); // name, ticker and symbolMultihash.
            address tokenAddress;
            IArbitrableTokenList.TokenStatus status;
            (
                strings[0], 
                strings[1], 
                tokenAddress, 
                strings[2], 
                status, 
            ) = t2cr.getTokenInfo(_tokenIDs[i]);
            
            tokens[i] = Token(
                _tokenIDs[i],
                strings[0],
                strings[1],
                tokenAddress,
                strings[2],
                status,
                0
            );
            uint decimals;
            
            assembly {
                let x := mload(0x40)   // Find empty storage location using "free memory pointer"
                mstore(x, 0x313ce567)  // Set the signature to the first call parameter. 0x313ce567 === bytes4(keccak256("decimals()")
                pop(staticcall(
                    30000,              // 30k gas
                    _t2crAddress,       // The call target.
                    x,                  // Inputs are stored at location x
                    0x04,               // Input is 4 bytes long
                    decimals,           // Store output
                    0x20                // The output length
                )) 
            }
            tokens[i].decimals = decimals;
        }

    }
}