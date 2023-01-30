/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

pragma solidity ^0.5.0;
interface IApprovalProxy {
  function setApprovalForAll(address _owner, address _spender, bool _approved) external;
  function isApprovedForAll(address _owner, address _spender, bool _original) external view returns (bool);
}
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "role already has the account");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "role dosen't have the account");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        return role.bearer[account];
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @title ERC-165 Standard Interface Detection
/// @dev See https://eips.ethereum.org/EIPS/eip-165
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function toHex(address account) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(account));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }
}
interface IERC173 /* is ERC165 */ {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    function owner() external view returns (address);

    /// @notice Set the address of the new owner of the contract
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

contract ERC173 is IERC173, ERC165  {
    address private _owner;

    constructor() public {
        _registerInterface(0x7f5828d0);
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Must be owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner() {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        address previousOwner = owner();
	_owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}

contract Operatable is ERC173 {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    Roles.Role private operators;

    constructor() public {
        operators.add(msg.sender);
        _paused = false;
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender), "Must be operator");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOperator() {
        _transferOwnership(_newOwner);
    }

    function isOperator(address account) public view returns (bool) {
        return operators.has(account);
    }

    function addOperator(address account) public onlyOperator() {
        operators.add(account);
        emit OperatorAdded(account);
    }

    function removeOperator(address account) public onlyOperator() {
        operators.remove(account);
        emit OperatorRemoved(account);
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOperator() whenNotPaused() {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOperator() whenPaused() {
        _paused = false;
        emit Unpaused(msg.sender);
    }

}

contract OwnableDelegateProxy { }
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
    function set(address _owner, address _spender) external {
        proxies[_owner] = OwnableDelegateProxy(_spender);
    }
}

contract CJOApprovalProxyV1 is IApprovalProxy, Operatable {
    using Address for address;

    Roles.Role private approvableContracts;
    Roles.Role private preapprovedContracts;
    mapping (address => mapping (address => bool)) private _expresslyNotApprovalSpender;
    mapping (address => mapping (address => bool)) private _contractApprovals;

    ProxyRegistry public openSeaProxyRegistry;
    mapping (address => bool) private openSeaDisabled;

    event UpdateApprovableContracts (address spender, bool approved);
    event UpdatePreapprovedContracts (address spender, bool approved);

    modifier onlyContract(address _spender) {
        require(_spender.isContract(), "_spender must be contract");
        _;
    }

    constructor() public {}

    function setApprovalForAll(address _owner, address _spender, bool _approved) public onlyContract(_spender) onlyOperator() {
        require(isApprovableContract(_spender), "_spender must belong to approvable role");
        _expresslyNotApprovalSpender[_owner][_spender] = !_approved;
    }

    function isApprovedForAll(address _owner, address _spender, bool _original) public view returns (bool) {
        if (approvalToOpenSea(_owner, _spender)) {
            return true;
        }
        if (_spender.isContract()) {
            if (!isApprovableContract(_spender)) {
                return false;
            }
            if (isPreapprovedContract(_spender)) {
                return !_expresslyNotApprovalSpender[_owner][_spender];
            }
        }
        return _original;
    }

    // OpenSea
    function setOpenSeaProxyRegistry(address _openSeaProxyRegistry) public onlyOperator() {
        openSeaProxyRegistry = ProxyRegistry(_openSeaProxyRegistry);
    }

    function enableOpenSea() public {
        openSeaDisabled[msg.sender] = false;
    }

    function disableOpenSea() public {
        openSeaDisabled[msg.sender] = true;
    }
    
    function getOpenSeaSpender(address _owner) public view returns (address) {
        return address(openSeaProxyRegistry.proxies(_owner));
    }

    function approvalToOpenSea(address _owner, address _spender) public view returns (bool) {
        if (address(openSeaProxyRegistry) == address(0x0)) {
            return false;
        }
        if (openSeaDisabled[_owner]) {
            return false;
        }
        return (getOpenSeaSpender(_owner) == _spender);
    }

    // Approvable list
    function setApprovableContracts(address _spender, bool _approvable) public onlyOperator() onlyContract(_spender) {
        emit UpdateApprovableContracts(_spender, _approvable);
        if (_approvable) {
            approvableContracts.add(_spender);
        } else {
            require(!isPreapprovedContract(_spender), "_spender must not be preapproval");
            approvableContracts.remove(_spender);
        }
    }

    function isApprovableContract(address _spender) public view returns (bool) {
        return approvableContracts.has(_spender);
    }

    function setPreapprovedContracts(address _spender, bool _approval) public onlyOperator() onlyContract(_spender) {
        require(isApprovableContract(_spender), "_spender must not be approvable");
        emit UpdatePreapprovedContracts(_spender, _approval);
        if (_approval) {
            preapprovedContracts.add(_spender);
        } else {
            preapprovedContracts.remove(_spender);
        }
    }

    function isPreapprovedContract(address _spender) public view returns (bool) {
        return preapprovedContracts.has(_spender);
    }

}