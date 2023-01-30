/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

// File: contracts\lib\Ownable.sol

pragma solidity 0.5.9;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public _owner;

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
        require(isOwner(), "Only owner is able call this function!");
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

// File: contracts\StarEthRateInterface.sol

pragma solidity 0.5.9;

interface StarEthRateInterface {
    function decimalCorrectionFactor() external returns (uint256);
    function starEthRate() external returns (uint256);
}

// File: contracts\StarEthRate.sol

pragma solidity 0.5.9;



/**
 * @title StarEthRate - STAR/ETH rate contract
 * @author Markus Waas - <markus@starbase.co>
 */
contract StarEthRate is Ownable, StarEthRateInterface {
    uint256 public decimalCorrectionFactor;
    uint256 public starEthRate;

    event decimalCorrectionFactorSet(uint256 decimalCorrectionFactor);
    event StarEthRateSet(uint256 starEthRate);

    constructor(
        uint256 _decimalCorrectionFactor,
        uint256 _initialStarEthRate
    ) public {
        require(
            _decimalCorrectionFactor > 0,
            'Please pass a decimalCorrectionFactor above 0!'
        );
        require(_initialStarEthRate > 0, 'Please pass a starEthRate above 0!');

        decimalCorrectionFactor = _decimalCorrectionFactor;
        starEthRate = _initialStarEthRate;
    }

    function setDecimalCorrectionFactor(
        uint256 _newDecimalCorrectionFactor
    ) public onlyOwner {
        require(
            _newDecimalCorrectionFactor > 0,
            'Please pass a decimalCorrectionFactor above 0!'
        );

        decimalCorrectionFactor = _newDecimalCorrectionFactor;
        emit decimalCorrectionFactorSet(_newDecimalCorrectionFactor);
    }

    function setStarEthRate(uint256 _newStarEthRate) public onlyOwner {
        require(_newStarEthRate > 0, 'Please pass a starEthRate above 0!');

        starEthRate = _newStarEthRate;
        emit StarEthRateSet(_newStarEthRate);
    }

    function setStarEthRateAndDecimalCorrectionFactor(
        uint256 _newDecimalCorrectionFactor,
        uint256 _newStarEthRate
    ) public onlyOwner {
        setDecimalCorrectionFactor(_newDecimalCorrectionFactor);
        setStarEthRate(_newStarEthRate);
    }
}