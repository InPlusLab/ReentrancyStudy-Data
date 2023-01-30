pragma solidity ^0.5.4;

import "./AuctionityLibrary_V1.sol";

/// @title Auctionity chainId library
contract AuctionityChainId_V1 is AuctionityLibrary_V1 {
    /// @notice getter of ethereum network id
    /// @return ethereum network id
    function getEthereumChainId_V1() public view returns (uint8) {
        return ethereumChainId;
    }

    /// @notice getter of auctionity network id
    /// @return auctionity network id
    function getAuctionityChainId_V1() public view returns (uint8) {
        return auctionityChainId;
    }

    /// @notice setter of ethereum network id
    /// @param _ethereumChainId uint8 : ethereum network id
    function setEthereumChainId_V1(uint8 _ethereumChainId) public {
        require(
            delegatedSendIsContractOwner_V1(),
            "setEthereumChainId Contract owner"
        );
        ethereumChainId = _ethereumChainId;
    }

    /// @notice setter of auctionity network id
    /// @param _auctionityChainId uint8 : auctionity network id
    function setAuctionityChainId_V1(uint8 _auctionityChainId) public {
        require(
            delegatedSendIsContractOwner_V1(),
            "setAuctionityChainId Contract owner"
        );
        auctionityChainId = _auctionityChainId;
    }

}
