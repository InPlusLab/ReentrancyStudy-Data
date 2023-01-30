/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

/**
 *  @authors: [@mtsalenc]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity 0.5.10;


interface TokenDecimals {
    function decimals() external view returns (uint);
}

/** @title TokensDecimalsView
 *  Utility view contract to fetch decimals from multiple token contracts at once.
 */
contract TokensDecimalsView {
    
    /** @dev Fetch up to 500 tokens decimals.
     *  @param _tokenAddresses The addresses of the token contracts to query.
     *  @return tokens The number of decimal places of each contract.
     */
    function getDecimals(address[] calldata _tokenAddresses) external view returns (uint[500] memory decimals) {
        for (uint i = 0; i < _tokenAddresses.length; i++) {
            TokenDecimals token = TokenDecimals(_tokenAddresses[i]);
            decimals[i] = token.decimals();
        }
    }
}