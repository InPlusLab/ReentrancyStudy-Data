/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

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

interface ExchangeRegistry {
    function getExchange(address _token) external view returns (address);
}

/** @title ExchangeView
 *  Utility view contract to get token exchange addresses for multiple token contracts at once.
 */
contract ExchangeView {

    /** @dev Fetch up to 500 exchange addresses.
     *  @param _registry The registry from where to fetch the exchange contracts.
     *  @param _tokenAddresses The addresses of the token contracts to query.
     *  @return exchanges The addresses of the exchanges, if available.
     */
    function getDecimals(address _registry, address[] calldata _tokenAddresses) external view returns (address[500] memory exchanges) {
        ExchangeRegistry registry = ExchangeRegistry(_registry);
        for (uint i = 0; i < _tokenAddresses.length; i++)
            exchanges[i] = registry.getExchange(_tokenAddresses[i]);
    }
    
}