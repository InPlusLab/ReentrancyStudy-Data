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

contract IFreezable {
    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);

    function _freezeAccount(address account) internal;
    function _unfreezeAccount(address account) internal;
    function _isAccountFrozen(address account) internal view returns (bool);
}

contract IPausable {
    event Paused(address account);
    event Unpaused(address account);

    function paused() public view returns (bool);

    function _pause() internal;
    function _unpause() internal;
}

contract IFeatured is IPausable, IFreezable {
    
    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event TokenFrozen();
    event TokenUnfrozen();
    
    uint8 public constant ForceTransfer = 0x01;
    uint8 public constant Pausable = 0x02;
    uint8 public constant AccountBurning = 0x04;
    uint8 public constant AccountFreezing = 0x08;

    function _enable(uint8 features) internal;
    function isEnabled(uint8 feature) public view returns (bool);

    function checkTransfer(address from, address to) external view returns (bool);
    function isAccountFrozen(address account) external view returns (bool);
    function freezeAccount(address account) external;
    function unfreezeAccount(address account) external;
    function isTokenPaused() external view returns (bool);
    function pauseToken() external;
    function unPauseToken() external;
}

contract Pausable is IPausable {
    bool private _paused;

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Freezable is IFreezable {
    mapping (address => bool) private _frozen;

    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);

    
    function _freezeAccount(address account) internal {
        _frozen[account] = true;
        emit AccountFrozen(account);
    }

    
    function _unfreezeAccount(address account) internal {
         _frozen[account] = false;
         emit AccountUnfrozen(account);
    }

    
    function _isAccountFrozen(address account) internal view returns (bool) {
         return _frozen[account];
    }
}

contract Featured is IFeatured, Pausable, Freezable, Ownable {
    uint8 public _enabledFeatures;

    modifier enabled(uint8 feature) {
        require(isEnabled(feature), "Token feature is not enabled");
        _;
    }

    constructor (address owner, uint8 features) public {
        _enable(features);
        _transferOwnership(owner);
    }

    
    function _enable(uint8 features) internal {
        _enabledFeatures = features;
    }

    
    function isEnabled(uint8 feature) public view returns (bool) {
        return _enabledFeatures & feature > 0;
    }

    
    function checkTransfer(address from, address to) external view returns (bool) {
        return !_isAccountFrozen(from) && !_isAccountFrozen(to) && !paused();
    }

    
    function isAccountFrozen(address account) external view returns (bool) {
        return _isAccountFrozen(account);
    }

    
    function freezeAccount(address account)
    external
    enabled(AccountFreezing)
    onlyOwner
    {
        _freezeAccount(account);
    }

    
    function unfreezeAccount(address account)
    external
    enabled(AccountFreezing)
    onlyOwner
    {
        _unfreezeAccount(account);
    }

    
    function isTokenPaused() external view returns (bool) {
        return paused();
    }

    
    function pauseToken()
    external
    enabled(Pausable)
    onlyOwner
    {
        _pause();
    }

    
    function unPauseToken()
    external
    enabled(Pausable)
    onlyOwner
    {
        _unpause();
    }
}