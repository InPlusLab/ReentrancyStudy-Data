/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity 0.5.11;


/**
 * @title Sale contract interface
 * @notice This interface declares functions of Sale contract deployed at 0x9C666C69595c278063278a604FF12c70691AB234 address
 */
interface ISale {
    function updateRate(uint256 newRate) external;
    function withdraw() external;
    function withdraw(address payable to) external;
    function transferOwnership(address _owner) external;
    function futureRate() external view returns (uint256, uint256);
}


/**
 * @title Rate updater for Sale contract
 * @author SmartDec
 * @notice This contract adds updater role for calling Sale contract's updateRate() function
 */
contract Updater {

    ISale public sale;
    address public updater;
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangedUpdater(address indexed previousUpdater, address indexed newUpdater);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyUpdater() {
        require(msg.sender == updater, "This function is callable only by updater");
        _;
    }

    constructor(ISale _sale, address _updater) public {
        require(address(_sale) != address(0), "Invalid _sale address");
        require(_updater != address(0), "Invalid _updater address");

        sale = _sale;
        updater = _updater;
        owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Withdraws Ether from Sale contract to `msg.sender` address
     */
    function withdraw() external onlyOwner {
        sale.withdraw(msg.sender);
    }

    /**
     * @notice Withdraws Ether from Sale contract to `to` address
     * @param to withdrawn Ether receiver
     */
    function withdraw(address payable to) external onlyOwner {
        sale.withdraw(to);
    }

    /**
     * @notice Transfers Sale contract ownership from this contract
     * @param newSaleOwner new owner address
     */
    function transferSaleOwnership(address newSaleOwner) external onlyOwner {
        require(newSaleOwner != address(0));

        sale.transferOwnership(newSaleOwner);
    }

    /**
     * @notice Transfers THIS contract ownership to the desired address
     * @param _owner new owner address
     */
    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0));

        emit OwnershipTransferred(owner, _owner);

        owner = _owner;
    }

    /**
     * @notice Transfers updater role
     * @param _updater new updater address
     */
    function changeUpdater(address _updater) external onlyOwner {
        require(_updater != address(0), "Invalid _updater address");

        emit ChangedUpdater(updater, _updater);

        updater = _updater;
    }

    /**
     * @notice Changes rate in Sale contract, callable only by owner
     * @param newRate new rate set in Sale contract
     */
    function updateRateByOwner(uint256 newRate) external onlyOwner {
        sale.updateRate(newRate);
    }

    /**
     * @notice Changes rate in Sale contract, callable only by updater
     * @notice New rate cannot be more than 1% higher than previous one
     * @param newRate new rate set in Sale contract
     */
    function updateRateByUpdater(uint256 newRate) external onlyUpdater {
        (uint256 rate, uint256 timePriorToApply) = sale.futureRate();
        require(timePriorToApply == 0, "New rate hasn't been applied yet");
        uint256 newRateMultiplied = newRate * 100;
        require(newRateMultiplied / 100 == newRate, "Integer overflow");
        // No need to check previous rate for overflow as newRate is checked
        // uint256 rateMultiplied = rate * 100;
        // require(rateMultiplied / 100 == rate, "Integer overflow");
        require(newRate * 99 <= rate * 100, "New rate is too high");

        sale.updateRate(newRate);
    }
}