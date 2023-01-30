pragma solidity ^0.5.9;

import "./LibBytes.sol";
import "./IPropertyValidator.sol";

interface IGodsUnchainedCollectable {

    /// @dev Returns the delegate id of a particular collectable given its token id
    /// @param tokenId The id of the card to query.
    /// @return delegateId The delegateId of the given collectable.
    function collectables(uint256 tokenId)
        external
        view
        returns (uint32 delegateId);
}

contract GodsUnchainedCollectableValidator is
    IPropertyValidator
{
    IGodsUnchainedCollectable internal GODS_UNCHAINED_COLLECTABLE; // solhint-disable-line var-name-mixedcase

    using LibBytes for bytes;

    constructor(address _godsUnchainedCollectable)
        public
    {
        GODS_UNCHAINED_COLLECTABLE = IGodsUnchainedCollectable(_godsUnchainedCollectable);
    }

    /// @dev Checks that the given collectable (encoded as assetData) has the delegateId encoded in `propertyData`.
    ///      Reverts if the collectable doesn't match the specified delegateId.
    /// @param tokenId The ERC721 tokenId of the card to check.
    /// @param propertyData Encoded delegate_ID that the card is expected to have.
    function checkBrokerAsset(
        uint256 tokenId,
        bytes calldata propertyData
    )
        external
        view
    {
        (uint32 expectedDelegateId) = abi.decode(
            propertyData,
            (uint32)
        );

        // Validate collectable properties.
        (uint32 delegateId) = GODS_UNCHAINED_COLLECTABLE.collectables(tokenId);
        require(delegateId == expectedDelegateId, "GodsUnchainedCollectableValidator/DELEGATE_ID_MISMATCH");
    }
}