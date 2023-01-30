/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

/**
Author: Authereum Labs, Inc.
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


/**
 * @title Owned
 * @author Authereum Labs, Inc.
 * @dev Basic contract to define an owner.
 */
contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /// @dev Throws if the sender is not the owner
    modifier onlyOwner {
        require(msg.sender == owner, "O: Must be owner");
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
        require(_newOwner != address(0), "O: Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

/**
 * @title AuthereumProxy
 * @author Authereum Labs, Inc.
 * @dev The Authereum Proxy.
 */
contract AuthereumProxy {

    // We do not include a name or a version for this contract as this
    // is a simple proxy. Including them here would overwrite the declaration
    // of these variables in the implementation.

    /// @dev Storage slot with the address of the current implementation.
    /// @notice This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
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

        assembly {
            // Load the implementation address from the IMPLEMENTATION_SLOT
            let impl := sload(IMPLEMENTATION_SLOT)

            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, impl, 0, calldatasize, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }
}

contract AuthereumEnsManager {
    function register(string calldata _label, address _owner) external {}
}

/**
 * @title AuthereumProxyFactory
 * @author Authereum Labs, Inc.
 * @dev A factory that creates Authereum Proxies.
 */
contract AuthereumProxyFactory is Owned {

    string constant public name = "Authereum Proxy Factory";
    string constant public version = "2020070100";

    bytes private initCode;
    address private authereumEnsManagerAddress;
    
    AuthereumEnsManager authereumEnsManager;

    event InitCodeChanged(bytes initCode);
    event AuthereumEnsManagerChanged(address indexed authereumEnsManager);

    /// @dev Constructor
    /// @param _initCode Init code of the AuthereumProxy and constructor
    /// @param _authereumEnsManagerAddress Address for the Authereum ENS Manager contract
    constructor(bytes memory _initCode, address _authereumEnsManagerAddress) public {
        initCode = _initCode;
        authereumEnsManagerAddress =  _authereumEnsManagerAddress;
        authereumEnsManager = AuthereumEnsManager(authereumEnsManagerAddress);
        emit InitCodeChanged(initCode);
        emit AuthereumEnsManagerChanged(authereumEnsManagerAddress);
    }

    /**
     * Setters
     */

    /// @dev Setter for the proxy initCode
    /// @param _initCode Init code of the AuthereumProxy and constructor
    function setInitCode(bytes memory _initCode) public onlyOwner {
        initCode = _initCode;
        emit InitCodeChanged(initCode);
    }

    /// @dev Setter for the Authereum ENS Manager address
    /// @param _authereumEnsManagerAddress Address of the new Authereum ENS Manager
    function setAuthereumEnsManager(address _authereumEnsManagerAddress) public onlyOwner {
        authereumEnsManagerAddress = _authereumEnsManagerAddress;
        authereumEnsManager = AuthereumEnsManager(authereumEnsManagerAddress);
        emit AuthereumEnsManagerChanged(authereumEnsManagerAddress);
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
    function getAuthereumEnsManager() public view returns (address) {
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
        bytes32 create2Salt= _getCreate2Salt(_salt, _initData);

        // Create proxy
        assembly {
            addr := create2(0, add(_initCode, 0x20), mload(_initCode), create2Salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        // Loop through initializations of each version of the logic contract
        bool success;
        for (uint256 i = 0; i < _initData.length; i++) {
            require(_initData[i].length != 0, "APF: Empty initialization data");
            (success,) = addr.call(_initData[i]);
            require(success, "APF: Unsuccessful account initialization");
        }

        // Set ENS name
        authereumEnsManager.register(_label, addr);

        return AuthereumProxy(addr);
    }

    /// @dev Generate a salt out of a uint256 value and the init data
    /// @param _salt A uint256 value to add randomness to the account creation
    /// @param _initData Array of initialize data
    function _getCreate2Salt(uint256 _salt, bytes[] memory _initData) internal pure returns (bytes32) {
        bytes32 _initDataHash = keccak256(abi.encode(_initData));
        return keccak256(abi.encodePacked(_salt, _initDataHash)); 
    }
}