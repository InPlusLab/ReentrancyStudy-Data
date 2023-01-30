/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity 0.5.11;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
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

/**
 * @title PayableOwnable
 * @dev The PayableOwnable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * PayableOwnable is extended from open-zeppelin Ownable smart contract, with the difference of making the owner
 * a payable address.
 */
contract PayableOwnable {
    address payable internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address payable) {
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
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/// @dev - Top Up Billing model - Total Limit
/// A business that allows their customers to purchase various items or services using Credits.
/// -------------------------------------------------------------------------------------------
/// The business allow their customers to subscribe to a top up billing model. The top-up billing model works as follows:
/// 1. The customer can purchase 100 Credits from the business for 10$.
/// 2. The customer can start spending the 100 Credits for using different services or purchasing different items from the business.
/// 3. When the customer¡¯s Credits drops at 25 units, the business is allowed to charge 7.50$ for 75 Credits, therefore ¡®topping up¡¯ to 100 Credits again.
/// -------------------------------------------------------------------------------------------
/// Total Limit
/// The customer specifies that the maximum amount that (s)he is willing to spend in total in this top up billing model is 100$.
/// This means that the business can trigger the top up payment and pull PMA from the customer account only up until 100$ in PMA.
/// The customer can increase/decrease the top up limit at any point.
contract TopUpPullPayment is PayableOwnable {
    using SafeMath for uint256;

    /// ===============================================================================================================
    ///                                      Events
    /// ===============================================================================================================
    event LogExecutorAdded(address executor);
    event LogExecutorRemoved(address executor);
    event LogSmartContractActorFunded(string actorRole, address payable actor, uint256 timestamp);

    event LogPaymentRegistered(
        address customerAddress,
        bytes32 paymentID,
        bytes32 businessID
    );
    event LogPaymentCancelled(
        address customerAddress,
        bytes32 paymentID,
        bytes32 businessID
    );
    event LogPullPaymentExecuted(
        address customerAddress,
        bytes32 paymentID,
        bytes32 businessID,
        uint256 amountInPMA,
        uint256 conversionRate
    );

    event LogTotalLimitUpdated(
        address customerAddress,
        bytes32 paymentID,
        uint256 oldLimit,
        uint256 newLimit
    );

    /// ===============================================================================================================
    ///                                      Constants
    /// ===============================================================================================================
    uint256 constant internal RATE_CALCULATION_NUMBER = 10 ** 26;    /// Check `calculatePMAFromFiat()` for more details
    uint256 constant internal OVERFLOW_LIMITER_NUMBER = 10 ** 20;    /// 1e^20 - Prevent numeric overflows

    uint256 constant internal FUNDING_AMOUNT = 0.5 ether;                           /// Amount to transfer to owner/executor
    uint256 constant internal MINIMUM_AMOUNT_OF_ETH_FOR_OPERATORS = 0.15 ether;     /// min amount of ETH for owner/executor
    bytes32 constant internal EMPTY_BYTES32 = "";

    /// ===============================================================================================================
    ///                                      Members
    /// ===============================================================================================================
    IERC20 public token;
    mapping(address => bool) public executors;
    mapping(bytes32 => TopUpPayment) public pullPayments;

    struct TopUpPayment {
        bytes32[2] paymentIDs;                  /// [0] paymentID / [1] businessID
        string currency;                        /// 3-letter abbr i.e. 'EUR' / 'USD' etc.
        address customerAddress;                /// wallet address of customer
        address treasuryAddress;                /// address which pma tokens will be transfer to on execution
        address executorAddress;                /// address that can execute the pull payment
        uint256 initialConversionRate;          /// conversion rate for first payment execution
        uint256 initialPaymentAmountInCents;    /// initial payment amount in fiat in cents
        uint256 topUpAmountInCents;             /// payment amount in fiat in cents
        uint256 startTimestamp;                 /// when subscription starts - in seconds
        uint256 lastPaymentTimestamp;           /// timestamp of last payment
        uint256 cancelTimestamp;                /// timestamp the payment was cancelled
        uint256 totalLimit;                     /// total limit that the customer is willing to pay
        uint256 totalSpent;                     /// total amount spent by the customer
    }

    /// ===============================================================================================================
    ///                                      Modifiers
    /// ===============================================================================================================
    modifier isValidAddress(address _address) {
        require(_address != address(0), "Invalid address - ZERO_ADDRESS provided.");
        _;
    }
    modifier isValidString(string memory _string) {
        require(bytes(_string).length > 0, "Invalid string - is empty.");
        _;
    }
    modifier isValidNumber(uint256 _number) {
        require(_number > 0, "Invalid number - Must be higher than zero.");
        require(_number <= OVERFLOW_LIMITER_NUMBER, "Invalid number - Must be lower than the overflow limit.");
        _;
    }
    modifier isValidByte32(bytes32 _text) {
        require(_text != EMPTY_BYTES32, "Invalid byte32 value.");
        _;
    }
    modifier isValidNewTotalLimit(bytes32 _paymentID, uint256 _newAmount) {
        require(_newAmount >= pullPayments[_paymentID].totalSpent, "New total amount is less than the amount spent.");
        _;
    }
    modifier isExecutor() {
        require(executors[msg.sender], "msg.sender not an executor.");
        _;
    }
    modifier executorExists(address _executor) {
        require(executors[_executor], "Executor does not exists.");
        _;
    }
    modifier executorDoesNotExists(address _executor) {
        require(!executors[_executor], "Executor already exists.");
        _;
    }
    modifier isPullPaymentExecutor(bytes32 _paymentID) {
        require(pullPayments[_paymentID].executorAddress == msg.sender, "msg.sender not allowed to execute this payment.");
        _;
    }
    modifier isCustomer(bytes32 _paymentID) {
        require(pullPayments[_paymentID].customerAddress == msg.sender, "msg.sender not allowed to update this payment.");
        _;
    }
    modifier paymentExists(bytes32 _paymentID) {
        require(pullPayments[_paymentID].paymentIDs[0] != "", "Pull Payment does not exists.");
        _;
    }
    modifier paymentDoesNotExist(bytes32 _paymentID) {
        require(pullPayments[_paymentID].paymentIDs[0] == "", "Pull Payment exists already.");
        _;
    }
    modifier paymentNotCancelled(bytes32 _paymentID) {
        require(pullPayments[_paymentID].cancelTimestamp == 0, "Payment is cancelled");
        _;
    }
    modifier isWithinTheTotalLimits(bytes32 _paymentID) {
        require(pullPayments[_paymentID].totalSpent.add(pullPayments[_paymentID].topUpAmountInCents) <= pullPayments[_paymentID].totalLimit, "Total limit reached.");
        _;
    }

    /// ===============================================================================================================
    ///                                      Constructor
    /// ===============================================================================================================
    /// @dev Contract constructor - sets the token address that the contract facilitates.
    /// @param _token Token Address.
    constructor(address _token)
    public {
        require(_token != address(0), "Invalid address for token - ZERO_ADDRESS provided.");
        token = IERC20(_token);
    }
    // @notice Will receive any eth sent to the contract
    function() external payable {
    }

    /// ===============================================================================================================
    ///                                      Public Functions - Owner Only
    /// ===============================================================================================================
    /// @dev Adds a new executor. - can be executed only by the owner.
    ///     When adding a new executor 0.5 ETH is transferred to allow the executor to pay for gas.
    ///     The balance of the owner is also checked and if funding is needed 0.5 ETH is transferred.
    /// @param _executor - address of the executor which cannot be zero address.
    function addExecutor(address payable _executor)
    external
    onlyOwner
    isValidAddress(_executor)
    executorDoesNotExists(_executor)
    {
        executors[_executor] = true;
        if (isFundingNeeded(_executor)) {
            _executor.transfer(FUNDING_AMOUNT);
            emit LogSmartContractActorFunded("executor", _executor, now);
        }

        if (isFundingNeeded(owner())) {
            owner().transfer(FUNDING_AMOUNT);
            emit LogSmartContractActorFunded("owner", owner(), now);
        }
        emit LogExecutorAdded(_executor);
    }
    /// @dev Removes a new executor. - can be executed only by the owner.
    ///     The balance of the owner is checked and if funding is needed 0.5 ETH is transferred.
    /// @param _executor - address of the executor which cannot be zero address.
    function removeExecutor(address payable _executor)
    external
    onlyOwner
    isValidAddress(_executor)
    executorExists(_executor)
    {
        executors[_executor] = false;
        if (isFundingNeeded(owner())) {
            owner().transfer(FUNDING_AMOUNT);
            emit LogSmartContractActorFunded("owner", owner(), now);
        }
        emit LogExecutorRemoved(_executor);
    }

    /// ===============================================================================================================
    ///                                      Public Functions - Executors Only
    /// ===============================================================================================================
    /// @dev Registers a new top up pull payment to the PumaPay Top Up Pull Payment Contract - The registration can be executed only
    ///     by one of the executors of the PumaPay Pull Payment Contract and the
    ///     PumaPay Pull Payment Contract checks that the pull payment has been singed by the customer of the account.
    ///     The total limits are set on registration and the total and time based amount spent are set to 0.
    ///     The initial payment amount for the top up payment is being executed on the registration of the pull payment.
    ///     On registration the initial payment is executed.
    ///     The balance of the executor (msg.sender) is checked and if funding is needed 0.5 ETH is transferred.
    ///     Emits 'LogPaymentRegistered' with customer address, pull payment executor address and paymentID.
    ///     Emits 'LogPullPaymentExecuted' with customer address, paymentID, businessID, amount in PMA and conversion rate.
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155
    /// @param r - R output of ECDSA signature.
    /// @param s - S output of ECDSA signature.
    /// @param _paymentIDs  - [0] paymentID, [1] businessID
    /// @param _addresses   - [0] customer, [1] pull payment executor, [2] treasury
    /// @param _numbers     - [0] initial conversion rate, [1] initial payment amount in cents,
    ///                       [2] top up amount in cents, [3] start timestamp, [4] total limit
    /// @param _currency - currency of the payment / 3-letter abbr i.e. 'EUR'.
    function registerTopUpPayment(
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32[2] calldata _paymentIDs,
        address[3] calldata _addresses,
        uint256[5] calldata _numbers,
        string calldata _currency
    )
    external
    isExecutor()
    paymentDoesNotExist(_paymentIDs[0])
    isValidString(_currency)
    {
        require(_paymentIDs[0] != EMPTY_BYTES32, "PaymentID - Invalid byte32 value.");
        require(_paymentIDs[1] != EMPTY_BYTES32, "BusinessID - Invalid byte32 value.");

        require(_addresses[0] != address(0), "Invalid customer address - ZERO_ADDRESS provided.");
        require(_addresses[1] != address(0), "Invalid pull payment executor address - ZERO_ADDRESS provided.");
        require(_addresses[2] != address(0), "Invalid treasury address - ZERO_ADDRESS provided.");

        require(_numbers[0] > 0, "Invalid initial conversion rate number - Must be higher than zero.");
        require(_numbers[1] > 0, "Invalid initial payment amount in cents number - Must be higher than zero.");
        require(_numbers[2] > 0, "Invalid top up amount in cents number - Must be higher than zero.");
        require(_numbers[3] > 0, "Invalid start timestamp number - Must be higher than zero.");
        require(_numbers[4] > 0, "Invalid total limit number - Must be higher than zero.");

        require(_numbers[0] <= OVERFLOW_LIMITER_NUMBER, "Invalid initial conversion rate number - Must be lower than the overflow limit.");
        require(_numbers[1] <= OVERFLOW_LIMITER_NUMBER, "Invalid initial payment amount in cents number - Must be lower than the overflow limit.");
        require(_numbers[2] <= OVERFLOW_LIMITER_NUMBER, "Invalid top up amount in cents number - Must be lower than the overflow limit.");
        require(_numbers[3] <= OVERFLOW_LIMITER_NUMBER, "Invalid start timestamp number - Must be lower than the overflow limit.");
        require(_numbers[4] <= OVERFLOW_LIMITER_NUMBER, "Invalid total limit number - Must be lower than the overflow limit.");

        pullPayments[_paymentIDs[0]].paymentIDs[0] = _paymentIDs[0];
        pullPayments[_paymentIDs[0]].paymentIDs[1] = _paymentIDs[1];
        pullPayments[_paymentIDs[0]].currency = _currency;
        pullPayments[_paymentIDs[0]].customerAddress = _addresses[0];
        pullPayments[_paymentIDs[0]].executorAddress = _addresses[1];
        pullPayments[_paymentIDs[0]].treasuryAddress = _addresses[2];

        pullPayments[_paymentIDs[0]].initialConversionRate = _numbers[0];
        pullPayments[_paymentIDs[0]].initialPaymentAmountInCents = _numbers[1];
        pullPayments[_paymentIDs[0]].topUpAmountInCents = _numbers[2];
        pullPayments[_paymentIDs[0]].startTimestamp = _numbers[3];
        pullPayments[_paymentIDs[0]].totalLimit = _numbers[4];

        require(isValidRegistration(
                v,
                r,
                s,
                pullPayments[_paymentIDs[0]]
            ),
            "Invalid pull payment registration - ECRECOVER_FAILED."
        );

        executePullPaymentOnRegistration(
            [_paymentIDs[0], _paymentIDs[1]],
            [_addresses[0], _addresses[2]],
            [_numbers[1], _numbers[0]]
        );

        if (isFundingNeeded(msg.sender)) {
            msg.sender.transfer(FUNDING_AMOUNT);
            emit LogSmartContractActorFunded("executor", msg.sender, now);
        }

        emit LogPaymentRegistered(_addresses[0], _paymentIDs[0], _paymentIDs[1]);
    }

    /// @dev Executes a specific top up pull payment based on the payment ID - The pull payment should exist and the payment request
    ///     should be valid in terms of whether it can be executed i.e. it is within the total limit.
    ///     For the execution we calculate the amount in PMA using the conversion rate specified when calling the method.
    ///     From the 'conversionRate' and the 'topUpAmountInCents' we calculate the amount of PMA that
    ///     the business need to receive in their treasuryAddress.
    ///     The smart contract transfers from the customer account to the treasury wallet the amount in PMA.
    ///     After execution we set the last payment timestamp to NOW and we increase the total spent amount with the top up amount.
    ///     Emits 'LogPullPaymentExecuted' with customer address, msg.sender as the pull payment executor address and the paymentID.
    /// @param _paymentID - ID of the payment.
    /// @param _conversionRate - conversion rate with which the payment needs to take place
    function executeTopUpPayment(bytes32 _paymentID, uint256 _conversionRate)
    external
    paymentExists(_paymentID)
    paymentNotCancelled(_paymentID)
    isPullPaymentExecutor(_paymentID)
    isValidNumber(_conversionRate)
    isWithinTheTotalLimits(_paymentID)
    returns (bool)
    {
        TopUpPayment storage payment = pullPayments[_paymentID];

        uint256 conversionRate = _conversionRate;
        uint256 amountInPMA = calculatePMAFromFiat(payment.topUpAmountInCents, conversionRate);

        payment.lastPaymentTimestamp = now;
        payment.totalSpent += payment.topUpAmountInCents;

        require(token.transferFrom(payment.customerAddress, payment.treasuryAddress, amountInPMA));

        emit LogPullPaymentExecuted(
            payment.customerAddress,
            payment.paymentIDs[0],
            payment.paymentIDs[1],
            amountInPMA,
            conversionRate
        );
        return true;
    }

    /// @dev Cancels a top up pull payment - The cancellation needs can be executed only by one of the
    ///     executors of the PumaPay Pull Payment Contract and the PumaPay Pull Payment Contract checks
    ///     that the pull payment's paymentID and businessID have been singed by the customer address.
    ///     This method sets the cancellation of the pull payment in the pull payments array for this pull payment executor specified.
    ///     The balance of the executor (msg.sender) is checked and if funding is needed 0.5 ETH is transferred.
    ///     Emits 'LogPaymentCancelled' with pull payment executor address and paymentID.
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155
    /// @param r - R output of ECDSA signature.
    /// @param s - S output of ECDSA signature.
    /// @param _paymentID - ID of the payment.
    function cancelTopUpPayment(
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 _paymentID
    )
    external
    isExecutor()
    paymentExists(_paymentID)
    paymentNotCancelled(_paymentID)
    {
        require(isValidCancellation(v, r, s, _paymentID), "Invalid cancellation - ECRECOVER_FAILED.");
        pullPayments[_paymentID].cancelTimestamp = now;
        if (isFundingNeeded(msg.sender)) {
            msg.sender.transfer(FUNDING_AMOUNT);
            emit LogSmartContractActorFunded("executor", msg.sender, now);
        }
        emit LogPaymentCancelled(
            pullPayments[_paymentID].customerAddress,
            _paymentID,
            pullPayments[_paymentID].paymentIDs[1]
        );
    }

    /// @dev Method that updates the total limit for the top up payment
    /// @param _paymentID - the ID of the payment for which total limit will be updated
    /// @param _newLimit - new total limit in FIAT cents
    function updateTotalLimit(bytes32 _paymentID, uint256 _newLimit)
    external
    isCustomer(_paymentID)
    isValidNumber(_newLimit)
    isValidNewTotalLimit(_paymentID, _newLimit)
    {
        uint256 oldLimit = pullPayments[_paymentID].totalLimit;
        pullPayments[_paymentID].totalLimit = _newLimit;

        emit LogTotalLimitUpdated(msg.sender, _paymentID, oldLimit, _newLimit);
    }

    /// @dev method that retrieves the limits specified on the top up payment
    /// @param _paymentID - ID of the payment
    function retrieveLimits(bytes32 _paymentID)
    external
    view
    returns (uint256 totalLimit, uint256 totalSpent)
    {
        return (pullPayments[_paymentID].totalLimit, pullPayments[_paymentID].totalSpent);
    }

    /// ===============================================================================================================
    ///                                      Internal Functions
    /// ===============================================================================================================
    /// @dev The initial payment of the top up happens on registration. We calculate the amount of PMA that needs to be
    ///     needs to be transferred from the customer to the treasury wallet, using the rate for the initial payment signed
    ///     by the customer. The last payment timestamp is updated and a "LogPullPaymentExecuted" event is emitted.
    /// @param _paymentIDs - [0] paymentID, [1] businessID
    /// @param _addresses -   [0] customer, [1] treasury
    /// @param _paymentAmounts - [0] initial payment in cents, [1] conversion rate
    function executePullPaymentOnRegistration(
        bytes32[2] memory _paymentIDs,
        address[2] memory _addresses,
        uint256[2] memory _paymentAmounts
    )
    internal
    {
        TopUpPayment storage payment = pullPayments[_paymentIDs[0]];
        uint256 amountInPMA = calculatePMAFromFiat(_paymentAmounts[0], _paymentAmounts[1]);

        payment.lastPaymentTimestamp = now;

        require(token.transferFrom(_addresses[0], _addresses[1], amountInPMA));

        emit LogPullPaymentExecuted(
            _addresses[0],
            _paymentIDs[0],
            _paymentIDs[1],
            amountInPMA,
            _paymentAmounts[1]
        );
    }

    /// @dev Calculates the PMA Rate for the fiat currency specified - The rate is set every 10 minutes by our PMA server
    ///     for the currencies specified in the smart contract.
    ///     RATE CALCULATION EXAMPLE
    ///     ------------------------
    ///     RATE ==> 1 PMA = 0.01 USD$
    ///     1 USD$ = 1/0.01 PMA = 100 PMA
    ///     Start the calculation from one ether - PMA Token has 18 decimals
    ///     Multiply by the DECIMAL_FIXER (1e+10) to fix the multiplication of the rate
    ///     Multiply with the fiat amount in cents
    ///     Divide by the Rate of PMA to Fiat in cents
    ///     Divide by the FIAT_TO_CENT_FIXER to fix the _topUpAmountInCents
    ///     ---------------------------------------------------------------------------------------------------------------
    ///     To save on gas, we have 'pre-calculated' the equation below and have set a constant in its place.
    ///     ONE_ETHER.mul(DECIMAL_FIXER).div(FIAT_TO_CENT_FIXER) = RATE_CALCULATION_NUMBER
    ///     ONE_ETHER = 10^18           |
    ///     DECIMAL_FIXER = 10^10       |   => 10^18 * 10^10 / 100 ==> 10^26  => RATE_CALCULATION_NUMBER = 10^26
    ///     FIAT_TO_CENT_FIXER = 100    |
    ///     NOTE: The aforementioned value is linked to the OVERFLOW_LIMITER_NUMBER which is set to 10^20.
    ///     ---------------------------------------------------------------------------------------------------------------
    /// @param _topUpAmountInCents - payment amount in fiat CENTS so that is always integer
    /// @param _conversionRate - conversion rate with which the payment needs to take place
    /// NOTE: No modifiers needed to check the uint256 values since we are checking both of them on the caller method
    function calculatePMAFromFiat(uint256 _topUpAmountInCents, uint256 _conversionRate)
    internal
    pure
    returns (uint256) {
        return RATE_CALCULATION_NUMBER.mul(_topUpAmountInCents).div(_conversionRate);
    }

    /// @dev Checks if a registration request is valid by comparing the v, r, s params
    ///     and the hashed params with the customer address.
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155
    /// @param r - R output of ECDSA signature.
    /// @param s - S output of ECDSA signature.
    /// @param _pullPayment - pull payment to be validated.
    /// @return bool - if the v, r, s params with the hashed params match the customer address
    function isValidRegistration(
        uint8 v,
        bytes32 r,
        bytes32 s,
        TopUpPayment memory _pullPayment
    )
    internal
    pure
    returns (bool)
    {
        return ecrecover(
            keccak256(
                abi.encodePacked(
                    _pullPayment.paymentIDs[0],
                    _pullPayment.paymentIDs[1],
                    _pullPayment.currency,
                    _pullPayment.treasuryAddress,
                    _pullPayment.initialConversionRate,
                    _pullPayment.initialPaymentAmountInCents,
                    _pullPayment.topUpAmountInCents,
                    _pullPayment.startTimestamp,
                    _pullPayment.totalLimit
                )
            ),
            v, r, s) == _pullPayment.customerAddress;
    }

    /// @dev Checks if a cancellation request is valid by comparing the v, r, s params
    ///     and the hashed params with the customer address.
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155
    /// @param r - R output of ECDSA signature.
    /// @param s - S output of ECDSA signature.
    /// @param _paymentID - ID of the pull payment to be cancelled.
    /// @return bool - if the v, r, s params with the hashed params match the customer address
    function isValidCancellation(
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 _paymentID
    )
    internal
    view
    returns (bool){
        return ecrecover(
            keccak256(
                abi.encodePacked(
                    pullPayments[_paymentID].paymentIDs[0],
                    pullPayments[_paymentID].paymentIDs[1]
                )
            ),
            v, r, s) == pullPayments[_paymentID].customerAddress;
    }

    /// @dev Checks if the address of an owner/executor needs to be funded.
    ///     The minimum amount the owner/executors should always have is 0.15 ETH
    /// @param _address - address of owner/executors that the balance is checked against.
    /// @return bool    - whether the address needs more ETH.
    function isFundingNeeded(address _address)
    internal
    view
    returns (bool) {
        return address(_address).balance <= MINIMUM_AMOUNT_OF_ETH_FOR_OPERATORS;
    }
}