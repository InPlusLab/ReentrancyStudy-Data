/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

pragma solidity ^0.5.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/*
 * @dev provides information about the current execution context, including the
 * sender of the transaction and its data. while these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with gsn meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * this contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * this module is used through inheritance. it will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "ownable: caller is not the owner");
        _;
    }

    /**
     * @dev returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev leaves the contract without owner. it will not be possible to call
     * `onlyOwner` functions anymore. can only be called by the current owner.
     *
     * smol note: renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev transfers ownership of the contract to a new account (`newOwner`).
     * can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title roles
 * @dev library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "roles: account is the zero address");
        return role.bearer[account];
    }
}

contract CanTransferRole is Context {
    using Roles for Roles.Role;

    event CanTransferAdded(address indexed account);
    event CanTransferRemoved(address indexed account);

    Roles.Role private _canTransfer;

    constructor () internal {
        _addCanTransfer(_msgSender());
    }

    modifier onlyCanTransfer() {
        require(canTransfer(_msgSender()), "cant: smol caller is not beeg");
        _;
    }

    function canTransfer(address account) public view returns (bool) {
        return _canTransfer.has(account);
    }

    function addCanTransfer(address account) public onlyCanTransfer {
        _addCanTransfer(account);
    }

    function renounceCanTransfer() public {
        _removeCanTransfer(_msgSender());
    }

    function _addCanTransfer(address account) internal {
        _canTransfer.add(account);
        emit CanTransferAdded(account);
    }

    function _removeCanTransfer(address account) internal {
        _canTransfer.remove(account);
        emit CanTransferRemoved(account);
    }
}

interface SmolTingPot {
    function withdraw(uint256 _pid, uint256 _amount, address _address) external;
}

contract SmolMuseum is Ownable, CanTransferRole  {
    
    SmolTingPot public smolTingPot;

	//Mapping data of booster of a user in a pool
	mapping(uint256 => mapping(address => uint256)) public boosterInfo;
	
	constructor(SmolTingPot _smolTingPotAddr) public {
        smolTingPot = _smolTingPotAddr;
    }
    
    function getBoosterForUser(address _address, uint256 _pid)  public view returns (uint256) {
        return boosterInfo[_pid][_address];
    }
	
	function setBoosterForUser(address _address, uint256 _pid, uint256 _booster) public onlyOwner {
	    smolTingPot.withdraw(_pid, 0, _address);
        boosterInfo[_pid][_address] = _booster;
    }
    
}