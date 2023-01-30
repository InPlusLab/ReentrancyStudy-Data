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


interface IWithdrawalOracle {
    function get(address coinAddress) external view returns (bool, uint, uint);
    function set(address coinAddress, bool _isEnabled, uint _currencyAmount, uint _zangllTokenAmount) external;
}

contract WithdrawalOracle is Ownable, IWithdrawalOracle {
    struct CurrencyProportion {
        bool isEnabled;
        uint currencyAmount;
        uint zangllTokenAmount;
    }

    mapping(address => CurrencyProportion) private currencyProportion;

    function set(address coinAddress, bool _isEnabled, uint _currencyAmount, uint _zangllTokenAmount) public onlyOwner {
        currencyProportion[coinAddress] = CurrencyProportion({
            isEnabled: _isEnabled,
            currencyAmount: _currencyAmount,
            zangllTokenAmount: _zangllTokenAmount
        });
    }

    function get(address coinAddress) external view returns (bool, uint, uint) {
        return (currencyProportion[coinAddress].isEnabled,
                currencyProportion[coinAddress].currencyAmount,
                currencyProportion[coinAddress].zangllTokenAmount);
    }
}