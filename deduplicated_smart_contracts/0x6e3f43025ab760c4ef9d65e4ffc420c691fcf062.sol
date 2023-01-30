/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.5.0;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract DelegateRole {
    using Roles for Roles.Role;

    event DelegateAdded(address indexed account);
    event DelegateRemoved(address indexed account);

    Roles.Role private _delegates;

    function _addDelegate(address account) internal {
        _delegates.add(account);
        emit DelegateAdded(account);
    }

    function _removeDelegate(address account) internal {
        _delegates.remove(account);
        emit DelegateRemoved(account);
    }

    function _hasDelegate(address account) internal view returns (bool) {
        return _delegates.has(account);
    }
}

contract AuthorityRole {
    using Roles for Roles.Role;

    event AuthorityAdded(address indexed account);
    event AuthorityRemoved(address indexed account);

    Roles.Role private _authorities;

    function _addAuthority(address account) internal {
        _authorities.add(account);
        emit AuthorityAdded(account);
    }

    function _removeAuthority(address account) internal {
        _authorities.remove(account);
        emit AuthorityRemoved(account);
    }

    function _hasAuthority(address account) internal view returns (bool) {
        return _authorities.has(account);
    }
}

contract Managed {
    address internal _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    
    constructor (address manager) internal {
        _manager = manager;
        emit ManagementTransferred(address(0), _manager);
    }

    
    modifier onlyManager() {
        require(_isManager(msg.sender), "Caller not manager");
        _;
    }

    
    function _isManager(address account) internal view returns (bool) {
        return account == _manager;
    }

    
    function _renounceManagement() internal returns (bool) {
        emit ManagementTransferred(_manager, address(0));
        _manager = address(0);

        return true;
    }

    
    function _transferManagement(address newManager) internal returns (bool) {
        require(newManager != address(0));

        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;

        return true;
    }
}

contract ISRC20Roles {
    function isAuthority(address account) external view returns (bool);
    function removeAuthority(address account) external returns (bool);
    function addAuthority(address account) external returns (bool);

    function isDelegate(address account) external view returns (bool);
    function addDelegate(address account) external returns (bool);
    function removeDelegate(address account) external returns (bool);

    function manager() external view returns (address);
    function isManager(address account) external view returns (bool);
    function transferManagement(address newManager) external returns (bool);
    function renounceManagement() external returns (bool);
}

contract SRC20Roles is ISRC20Roles, DelegateRole, AuthorityRole, Managed, Ownable {
    constructor(address owner, address manager, address rules) public
        Managed(manager)
    {
        _transferOwnership(owner);
        if (rules != address(0)) {
            _addAuthority(rules);
        }
    }

    function addAuthority(address account) external onlyOwner returns (bool) {
        _addAuthority(account);
        return true;
    }

    function removeAuthority(address account) external onlyOwner returns (bool) {
        _removeAuthority(account);
        return true;
    }

    function isAuthority(address account) external view returns (bool) {
        return _hasAuthority(account);
    }

    function addDelegate(address account) external onlyOwner returns (bool) {
        _addDelegate(account);
        return true;
    }

    function removeDelegate(address account) external onlyOwner returns (bool) {
        _removeDelegate(account);
        return true;
    }

    function isDelegate(address account) external view returns (bool) {
        return _hasDelegate(account);
    }

    
    function manager() external view returns (address) {
        return _manager;
    }

    function isManager(address account) external view returns (bool) {
        return _isManager(account);
    }

    function renounceManagement() external onlyManager returns (bool) {
        _renounceManagement();
        return true;
    }

    function transferManagement(address newManager) external onlyManager returns (bool) {
        _transferManagement(newManager);
        return true;
    }
}