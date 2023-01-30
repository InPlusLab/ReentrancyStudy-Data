/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;


contract ZoraProxyStorage {

    address public implementation;
    address public admin;

    modifier onlyAdmin() {
        require(
            admin == msg.sender,
            "ZoraProxyStorage: only admin"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
contract ZoraProxy is ZoraProxyStorage {

    /* ============ Constructor ============ */
    constructor(
        address _implementation,
        address _admin
    )
        public
    {
        implementation = _implementation;
        admin = _admin;
    }

    function setAdmin(
        address _admin
    )
        public
        onlyAdmin
    {
        admin = _admin;
    }

    function setImplementation(
        address _implementation
    )
        public
        onlyAdmin
    {
        implementation = _implementation;
    }

    fallback() external payable {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let target := sload(0)
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

}