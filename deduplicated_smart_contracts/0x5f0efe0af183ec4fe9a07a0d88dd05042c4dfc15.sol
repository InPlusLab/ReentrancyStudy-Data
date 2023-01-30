import "./SafeERC20.sol";
import "./Ownable.sol";
import "./PercentageCalculator.sol";
// File: browser/SPDRVestingFlatten.sol

//"SPDX-License-Identifier: MIT"
pragma solidity 0.6.2;





contract VestingAdvisors is Ownable {
    using SafeERC20 for IERC20;
    uint256 public startDate; //6 months after TGE
    uint256 internal constant periodLength = 30 days; 
    uint256[35] public cumulativeAmountsToVest;
    uint256 public totalPercentages;
    IERC20 internal token;

    struct Recipient {
        uint256 withdrawnAmount;
        uint256 withdrawPercentage;
    }

    uint256 public totalRecipients;
    mapping(address => Recipient) public recipients;

    event LogStartDateSet(address setter, uint256 startDate);
    event LogRecipientAdded(address recipient, uint256 withdrawPercentage);
    event LogTokensClaimed(address recipient, uint256 amount);

    /*
     * Note: Percentages will be provided in thousands to represent 3 digits after the decimal point.
     * Ex. 10% = 10000
     */
    modifier onlyValidPercentages(uint256 _percentage) {
        require(
            _percentage <= 100000,
            "Provided percentage should be less than 100%"
        );
        require(
            _percentage > 0,
            "Provided percentage should be greater than 0"
        );
        _;
    }

    /**
     * @param _tokenAddress The address of the SPDR token
     * @param _cumulativeAmountsToVest The cumulative amounts for each vesting period
     */
    constructor(
        address _tokenAddress,
        uint256[35] memory _cumulativeAmountsToVest
    ) public {
        require(
            _tokenAddress != address(0),
            "Token Address can't be zero address"
        );
        token = IERC20(_tokenAddress);
        cumulativeAmountsToVest = _cumulativeAmountsToVest;
    }

    /**
     * @dev Function that sets the start date of the Vesting
     * @param _startDate The start date of the veseting presented as a timestamp
     */
    function setStartDate(uint256 _startDate) public onlyOwner {
        require(_startDate >= now, "Start Date can't be in the past");

        startDate = _startDate;
        emit LogStartDateSet(address(msg.sender), _startDate);
    }

    /**
     * @dev Function add recipient to the vesting contract
     * @param _recipientAddress The address of the recipient
     * @param _withdrawPercentage The percentage that the recipient should receive in each vesting period
     */
    function addRecipient(
        address _recipientAddress,
        uint256 _withdrawPercentage
    ) public onlyOwner onlyValidPercentages(_withdrawPercentage) {
        require(
            _recipientAddress != address(0),
            "Recepient Address can't be zero address"
        );
        require(
            recipients[_recipientAddress].withdrawPercentage == 0,
            "Recipient already has values saved"
        );
        totalPercentages = totalPercentages + _withdrawPercentage;
        require(totalPercentages <= 100000, "Total percentages exceeds 100%");
        totalRecipients++;

        recipients[_recipientAddress] = Recipient(0, _withdrawPercentage);
        emit LogRecipientAdded(_recipientAddress, _withdrawPercentage);
    }

    /**
     * @dev Function add  multiple recipients to the vesting contract
     * @param _recipients Array of recipient addresses. The arrya length should be less than 230, otherwise it will overflow the gas limit
     * @param _withdrawPercentages Corresponding percentages of the recipients
     */
    function addMultipleRecipients(
        address[] memory _recipients,
        uint256[] memory _withdrawPercentages
    ) public onlyOwner {
        require(
            _recipients.length < 230,
            "The recipients array size must be smaller than 230"
        );
        require(
            _recipients.length == _withdrawPercentages.length,
            "The two arryas are with different length"
        );
        for (uint256 i; i < _recipients.length; i++) {
            addRecipient(_recipients[i], _withdrawPercentages[i]);
        }
    }

    /**
     * @dev Function that withdraws all available tokens for the current period
     */
    function claim() public {
        require(startDate != 0, "The vesting hasn't started");
        require(now >= startDate, "The vesting hasn't started");

        (uint256 owedAmount, uint256 calculatedAmount) = calculateAmounts();
        recipients[msg.sender].withdrawnAmount = calculatedAmount;
        token.safeTransfer(msg.sender,owedAmount);
        emit LogTokensClaimed(msg.sender, owedAmount);
    }

    /**
     * @dev Function that returns the amount that the user can withdraw at the current period.
     * @return owedAmount The amount that the user can withdraw at the current period.
     */
    function hasClaim() public view returns (uint256) {
        if (now <= startDate) {
            return 0;
        }

        (uint256 owedAmount, uint256 _) = calculateAmounts();
        return owedAmount;
    }

    function calculateAmounts()
        internal
        view
        returns (uint256 _owedAmount, uint256 _calculatedAmount)
    {
        uint256 period = (now - startDate) / (periodLength);
        if (period >= cumulativeAmountsToVest.length) {
            period = cumulativeAmountsToVest.length - 1;
        }
         _calculatedAmount = PercentageCalculator.div(
            cumulativeAmountsToVest[period],
            recipients[msg.sender].withdrawPercentage
        );
         _owedAmount = _calculatedAmount -
            recipients[msg.sender].withdrawnAmount;

        return (_owedAmount, _calculatedAmount);
    }
}
