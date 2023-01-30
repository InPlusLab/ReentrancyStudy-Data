pragma solidity 0.6.6;

/**
 * @title ZoraAuthorized
 *
 * The ZoraAuthorized contract is an inherited contract that sets permissions on certain function calls
 * through the onlyAuthorized modifier. Permissions can be managed only by the Owner of the contract.
 */
interface IZoraAuthorized {

    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory);

    function isAuthorized(
        address addressToCheck
    )
        external
        view
        returns (bool);
}