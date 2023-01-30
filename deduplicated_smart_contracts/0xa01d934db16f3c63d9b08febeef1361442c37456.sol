/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.5.6;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IOperationalWallet2 {
    function setTrustedToggler(address _trustedToggler) external;
    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external;
    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool);
}


contract OperationalWallet2 is Ownable, IOperationalWallet2 {
    address private trustedToggler;
    mapping(address => bool) private trustedWithdrawers;

    function setTrustedToggler(address _trustedToggler) public onlyOwner {
        trustedToggler = _trustedToggler; // this should be a booking factory
    }

    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external {
        require(isOwner() || msg.sender == trustedToggler);
        trustedWithdrawers[_withdrawer] = isEnabled;
    }

    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool) {
        require(isOwner() || trustedWithdrawers[msg.sender]);
        return IERC20(coin).transfer(to, amount);
    }
}