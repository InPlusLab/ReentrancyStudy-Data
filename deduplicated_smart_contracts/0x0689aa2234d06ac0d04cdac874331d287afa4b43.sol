// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Proxy.sol";

contract TransparentProxy is Proxy {
    // /////////////////////// CONSTRUCTOR //////////////////////////////////////////////////////////////////////

    constructor(
        address implementationAddress,
        bytes memory data,
        address adminAddress
    ) public {
        _setImplementation(implementationAddress, data);
        _setAdmin(adminAddress);
    }

    // ///////////////////// EXTERNAL ///////////////////////////////////////////////////////////////////////////

    function changeImplementation(
        address newImplementation,
        bytes calldata data
    ) external ifAdmin {
        _setImplementation(newImplementation, data);
    }

    function proxyAdmin() external ifAdmin returns (address) {
        return _admin();
    }

    // Transfer of adminship on the other hand is only visible to the admin of the Proxy
    function changeProxyAdmin(address newAdmin) external ifAdmin {
        uint256 disabled;
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            disabled := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6102
            )
        }
        require(disabled == 0, "changeAdmin has been disabled");

        _setAdmin(newAdmin);
    }

    // to be used if EIP-173 needs to be implemented in the implementation contract so that change of admin can be constrained
    // in a way that OwnershipTransfered is trigger all the time
    function disableChangeProxyAdmin() external ifAdmin {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6102,
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            )
        }
    }

    // /////////////////////// MODIFIERS ////////////////////////////////////////////////////////////////////////

    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    // ///////////////////////// INTERNAL //////////////////////////////////////////////////////////////////////

    function _admin() internal view returns (address adminAddress) {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            adminAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            )
        }
    }

    function _setAdmin(address newAdmin) internal {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                newAdmin
            )
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// EIP-1967
abstract contract Proxy {
    // /////////////////////// EVENTS ///////////////////////////////////////////////////////////////////////////

    event ProxyImplementationUpdated(
        address indexed previousImplementation,
        address indexed newImplementation
    );

    // /////////////////////// CONSTRUCTOR //////////////////////////////////////////////////////////////////////

    function _setImplementation(address newImplementation, bytes memory data)
        internal
    {
        address previousImplementation;
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            previousImplementation := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
        }

        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            sstore(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                newImplementation
            )
        }

        emit ProxyImplementationUpdated(
            previousImplementation,
            newImplementation
        );

        if (data.length > 0) {
            (bool success, ) = newImplementation.delegatecall(data);
            if (!success) {
                assembly {
                    // This assembly ensure the revert contains the exact string data
                    let returnDataSize := returndatasize()
                    returndatacopy(0, 0, returnDataSize)
                    revert(0, returnDataSize)
                }
            }
        }
    }

    // ///////////////////// EXTERNAL ///////////////////////////////////////////////////////////////////////////

    receive() external payable {
        _fallback();
    }

    fallback() external payable {
        _fallback();
    }

    // ///////////////////////// INTERNAL //////////////////////////////////////////////////////////////////////

    function _fallback() internal {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            let implementationAddress := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                gas(),
                implementationAddress,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }
}

