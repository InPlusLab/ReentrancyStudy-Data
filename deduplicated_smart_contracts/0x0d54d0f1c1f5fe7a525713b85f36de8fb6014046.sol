/**
 *Submitted for verification at Etherscan.io on 2019-11-03
*/

pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

 // @author Authereum, Inc.

/**
 * @title Owned
 * @author Authereum, Inc.
 * @dev Basic contract to define an owner.
 */

contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /// @dev Throws if the sender is not the owner
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /// @dev Return the ownership status of an address
    /// @param _potentialOwner Address being checked
    /// @return True if the _potentialOwner is the owner
    function isOwner(address _potentialOwner) external view returns (bool) {
        return owner == _potentialOwner;
    }

    /// @dev Lets the owner transfer ownership of the contract to a new owner
    /// @param _newOwner The new owner
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}
/**
 * @title AuthereumProxy
 * @author Authereum, Inc.
 * @dev The Authereum Proxy.
 */

contract AuthereumProxy {
    string constant public authereumProxyVersion = "2019102500";

    /// @dev Storage slot with the address of the current implementation.
    /// @notice This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted 
    /// @notice by 1, and is validated in the constructor.
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @dev Set the implementation in the constructor
    /// @param _logic Address of the logic contract
    constructor(address _logic) public payable {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _logic)
        }
    }

    /// @dev Fallback function
    /// @notice A payable fallback needs to be implemented in the implementation contract
    /// @notice This is a low level function that doesn't return to its internal call site.
    /// @notice It will return to the external caller whatever the implementation returns.
    function () external payable {
        if (msg.data.length == 0) return;
        address _implementation = implementation();

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, _implementation, 0, calldatasize, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    /// @dev Returns the current implementation.
    /// @return Address of the current implementation
    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}
contract AuthereumEnsManager {
    function register(string calldata _label, address _owner) external {}
}
/**
 * @title AuthereumProxyFactory
 * @author Authereum, Inc.
 * @dev A factory that creates Authereum Proxies.
 */

contract AuthereumProxyFactory is Owned {
    string constant public authereumProxyFactoryVersion = "2019102500";
    bytes private initCode;
    address private authereumEnsManagerAddress;
    
    AuthereumEnsManager authereumEnsManager;

    /// @dev Constructor
    /// @param _implementation Address of the Authereum implementation
    /// @param _authereumEnsManagerAddress Address for the Authereum ENS Manager contract
    constructor(address _implementation, address _authereumEnsManagerAddress) public {
        initCode = abi.encodePacked(type(AuthereumProxy).creationCode, uint256(_implementation));
        authereumEnsManagerAddress =  _authereumEnsManagerAddress;
        authereumEnsManager = AuthereumEnsManager(authereumEnsManagerAddress);
    }

    /**
     *  Getters
     */

    /// @dev Getter for the proxy initCode
    /// @return Init code
    function getInitCode() public view returns (bytes memory) {
        return initCode;
    }

    /// @dev Getter for the private authereumEnsManager variable
    /// @return Authereum Ens Manager
    function getAuthereumEnsManagerAddress() public view returns (address) {
        return authereumEnsManagerAddress;
    }

    /// @dev Create an Authereum Proxy and iterate through initialize data
    /// @notice The bytes[] _initData is an array of initialize functions. 
    /// @notice This is used when a user creates an account e.g. on V5, but V1,2,3, 
    /// @notice etc. have state vars that need to be included.
    /// @param _salt A uint256 value to add randomness to the account creation
    /// @param _label Label for the user's Authereum ENS subdomain
    /// @param _initData Array of initialize data
    function createProxy(
        uint256 _salt, 
        string memory _label,
        bytes[] memory _initData
    ) 
        public 
        onlyOwner
        returns (AuthereumProxy)
    {
        address payable addr;
        bytes memory _initCode = initCode;
        bytes32 salt = _getSalt(_salt, msg.sender);

        // Create proxy
        assembly {
            addr := create2(0, add(_initCode, 0x20), mload(_initCode), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        // Loop through initializations of each version of the logic contract
        bool success;
        for (uint256 i = 0; i < _initData.length; i++) {
            if(_initData.length > 0) {
                (success,) = addr.call(_initData[i]);
                require(success);
            }
        }

        // Set ENS name
        authereumEnsManager.register(_label, addr);

        return AuthereumProxy(addr);
    }

    /// @dev Generate a salt out of a uint256 value and the sender
    /// @param _salt A uint256 value to add randomness to the account creation
    /// @param _sender Sender of the transaction
    function _getSalt(uint256 _salt, address _sender) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_salt, _sender)); 
    }
}