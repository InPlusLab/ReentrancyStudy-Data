pragma solidity ^0.5.4;

import "./AuctionityLibrary_V1.sol";

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract AuctionityProxy_V1 is AuctionityLibrary_V1 {
    /// @notice init contract by calling `_auctionityProxyUpdate.initProxyContract_V1(auctionityProxyUpdate,_ownable)`,
    /// adding the first delegate functions and set _ownable as the contract responsible for
    /// contract ownership.
    /// @param _auctionityProxyUpdate address : contract proxyUpdate
    /// @param _ownable address : contract ownable
    constructor(address _auctionityProxyUpdate, address _ownable) public {
        /// @dev encode initProxyContract_V1 selector with parametters
        bytes memory _calldata = abi.encodeWithSelector(
            bytes4(keccak256("initProxyContract_V1(address,address)")),
            _auctionityProxyUpdate,
            _ownable
        );

        /// @dev deletatecall initProxyContract_V1 to _auctionityProxyUpdate
        /// @return return the delegtecall return, or the eventual revert
        assembly {
            let result := delegatecall(
                gas,
                _auctionityProxyUpdate,
                add(_calldata, 0x20),
                mload(_calldata),
                0,
                0
            )
            let size := returndatasize
            returndatacopy(_calldata, 0, size)
            if eq(result, 0) {
                revert(_calldata, size)
            }
        }
    }

    // @notice Fallback payable proxy function
    /// @return return the _callDelegated_V1 return, or the eventual revert
    function() external payable {
        uint returnPtr;
        uint returnSize;

        (returnPtr, returnSize) = _callDelegated_V1(
            msg.data,
            proxyFallbackContract
        );

        assembly {
            return(returnPtr, returnSize)
        }

    }
}
