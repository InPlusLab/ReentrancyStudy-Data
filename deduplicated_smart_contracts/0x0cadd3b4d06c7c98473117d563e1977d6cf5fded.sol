/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^0.5.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma experimental ABIEncoderV2;




/**
 * @title Etherclear
 * @dev The Etherclear contract is meant to serve as a transition step for funds between a sender
 * and a recipient, where the sender can take the funds back if they cancel the payment,
 * and the recipient can only retrieve the funds in a specified amount of time, using
 * a passphrase communicated privately by the sender.
 *
 * The usage of the contract is as follows:
 *
 * 1) The sender generates a passphrase, and passes keccak256(passphrase,recipient_address) to the
 * contract, along with a hold time. This registers a payment ID (which must be unique), and
 * marks the start of the holding time window.
 * 2) The sender communicates this passphrase to the recipient over a secure channel.
 * 3) Before the holding time has passed, the recipient can send the passphrase to the contract to withdraw the funds.
 * 4) After the holding time has passed, the recipient is no longer able to withdraw the funds, regardless
 * of whether they have the passphrase or not.
 *
 * At any time, the sender can cancel the payment if they provide the payment ID, which
 * will initiate a transfer of funds back to the sender.
 * The sender is expected to cancel the payment if they have made a mistake in specifying
 * the recipient's address, the recipient does not claim the funds, or if the holding period has expired and the
 * funds need to be retrieved.
 *
 * The sender is expected to pay a baseFee and paymentFee up front when creating a payment.
 * The baseFee is in ether, and is required to cover free cancellation (by the sender) or fund retrieval (by the
 * recipient), through an external relayer service.
 * The paymentFee is taken in the same asset type the sender is sending. It will be refunded to the sender if the
 * payment is cancelled.
 *
 * TODO: Currently, the payment ID is a truncated version of the passphrase hash that is used to ensure knowledge of the
 * passphrase. They will be left as separate entities for now in case they need to be constructed differently.
 *
 * NOTE: the hold time functionality is not very secure for small time periods since it uses now (block.timestamp). It is meant to be an additional security measure, and should not be relied upon in the case of an
 attack. The current known tolerance is 900 seconds:
 * https://github.com/ethereum/wiki/blob/c02254611f218f43cbb07517ca8e5d00fd6d6d75/Block-Protocol-2.0.md
 *
 * Some parts are modified from https://github.com/forkdelta/smart_contract/blob/master/contracts/ForkDelta.sol
*/

/*
 * This is used as an interface to provide functionality when setting up the contract with ENS.
*/
contract ReverseRegistrar {
    function setName(string memory name) public returns (bytes32);
}

contract Etherclear {
    // TODO: think about adding a ERC223 fallback method.

    // NOTE: PaymentClosed has the same signature
    // because we want to look for payments
    // from the latest block backwards, and
    // we want to terminate the search for
    // past events as soon as possible when doing so.
    event PaymentOpened(
        uint txnId,
        uint holdTime,
        uint openTime,
        uint closeTime,
        address token,
        uint sendAmount,
        uint paymentFee,
        address indexed sender,
        address indexed recipient,
        bytes codeHash
    );
    event PaymentClosed(
        uint txnId,
        uint holdTime,
        uint openTime,
        uint closeTime,
        address token,
        uint sendAmount,
        uint paymentFee,
        address indexed sender,
        address indexed recipient,
        bytes codeHash,
        uint state
    );

    // A Payment starts in the OPEN state.
    // Once it is COMPLETED or CANCELLED, it cannot be changed further.
    enum PaymentState {OPEN, COMPLETED, CANCELLED}
    // Used when receiving signed messages to cancel or complete
    // a payment.
    enum CompletePaymentRequestType {CANCEL, RETRIEVE}

    // A Payment is created each time a sender wants to
    // send an amount to a recipient.
    struct Payment {
        // timestamps are in epoch seconds
        uint holdTime;
        uint paymentOpenTime;
        uint paymentCloseTime;
        // Token contract address, 0 is Ether.
        address token;
        uint sendAmount;
        // This fee is tracked because it is refunded
        // if the user cancels the payment.
        uint paymentFee;
        address payable sender;
        address payable recipient;
        bytes codeHash;
        PaymentState state;
    }

    ReverseRegistrar reverseRegistrar;

    // EIP-712 code uses the examples provided at
    // https://medium.com/metamask/eip712-is-coming-what-to-expect-and-how-to-use-it-bb92fd1a7a26
    // TODO: the salt and verifyingContract still need to be changed.
    // This struct and the associated typed signature are used for both
    // cancelling and retrieving payments.
    struct CompletePaymentRequest {
        uint txnId;
        address sender;
        address recipient;
        // Passphrase doesn't matter if the request type is CANCEL.
        string passphrase;
        // CompletePaymentRequestType
        uint requestType;
    }

    // Payments are looked up with a uint UUID generated within the contract.
    mapping(uint => Payment) openPayments;

    // This contract's owner (gives ability to set fees and designate fee account).
    address payable public owner;
    // The account that fees will be withdrawn to
    address payable public feeAccount;
    // The fees are represented with a percentage times 1 ether.
    // The baseFee is to cover feeless retrieval
    // The paymentFee is to cover development costs
    uint public baseFee;
    uint public paymentFee;
    // mapping of token addresses to mapping of account balances (token=0 means Ether)
    mapping(address => mapping(address => uint)) public tokenBalances;

    // Mapping of token addresses to payment fee balances.
    // Kept separate from the tokenBalances map to ensure the
    // payment balance is not accidentally withdrawn by the owner.
    mapping(address => uint) public paymentFeeBalances;
    // Base fee balance (in wei). Kept separate from paymentFee so that
    // paymentFee balance can be withdrawn independently.
    uint public baseFeeBalance;

    // NOTE: We do not lock the cancel payment functionality, so that users
    // will still be able to withdraw funds from payments they created.
    // Failsafe to lock the create payments functionality for both ether and tokens.
    bool public createPaymentEnabled;
    // Failsafe to lock the retrieval (withdraw) functionality.
    bool public retrieveFundsEnabled;

    address constant verifyingContract = 0x1C56346CD2A2Bf3202F771f50d3D14a367B48070;
    bytes32 constant salt = 0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558;
    string private constant COMPLETE_PAYMENT_REQUEST_TYPE = "CompletePaymentRequest(uint256 txnId,address sender,address recipient,string passphrase,uint256 requestType)";
    string private constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        abi.encodePacked(EIP712_DOMAIN_TYPE)
    );
    bytes32 private constant COMPLETE_PAYMENT_REQUEST_TYPEHASH = keccak256(
        abi.encodePacked(COMPLETE_PAYMENT_REQUEST_TYPE)
    );
    bytes32 private DOMAIN_SEPARATOR;
    // The chainId is public because it differs between
    // contract instances
    uint256 public chainId;

    function hashCompletePaymentRequest(CompletePaymentRequest memory request)
        private
        view
        returns (bytes32 hash)
    {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        COMPLETE_PAYMENT_REQUEST_TYPEHASH,
                        request.txnId,
                        request.sender,
                        request.recipient,
                        keccak256(bytes(request.passphrase)),
                        request.requestType
                    )
                )
            )
        );
    }

    // Used to test the sign and recover functionality.
    function getSignerForPaymentCompleteRequest(
        uint256 txnId,
        address sender,
        address recipient,
        string memory passphrase,
        uint requestType,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public view returns (address result) {
        CompletePaymentRequest memory request = CompletePaymentRequest(
            txnId,
            sender,
            recipient,
            passphrase,
            requestType
        );
        address signer = ecrecover(
            hashCompletePaymentRequest(request),
            sigV,
            sigR,
            sigS
        );
        return signer;
    }

    constructor(uint256 _chainId) public {
        owner = msg.sender;
        feeAccount = msg.sender;
        baseFee = 0.001 ether;
        paymentFee = 0.005 ether;
        createPaymentEnabled = true;
        retrieveFundsEnabled = true;
        chainId = _chainId;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("Etherclear"),
                keccak256("1"),
                chainId,
                verifyingContract,
                salt
            )
        );
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner is allowed to use this function."
        );
        _;
    }

    modifier onlyOwnerOrFeeAccount {
        require(
            msg.sender == owner || msg.sender == feeAccount,
            "Only the contract owner or the fee account is allowed to use this function."
        );
        _;
    }

    /*
    * SetENS sets the name of the reverse record so that it points to this contract address.
    */
    function setENS(address reverseRegistrarAddr, string memory name)
        public
        onlyOwner
    {
        reverseRegistrar = ReverseRegistrar(reverseRegistrarAddr);
        reverseRegistrar.setName(name);

    }

    // Payment fees are always withdrawn to the owner's account
    function withdrawPaymentFees(address token) external onlyOwner {
        uint total = paymentFeeBalances[token];
        paymentFeeBalances[token] = 0;
        if (token == address(0)) {
            owner.transfer(total);
        } else {
            require(
                IERC20(token).transfer(owner, total),
                "Could not successfully withdraw fees for token"
            );
        }
    }

    // Base fees are always withdrawn to the fee account.
    function withdrawBaseFees() external onlyOwnerOrFeeAccount {
        uint total = baseFeeBalance;
        baseFeeBalance = 0;
        feeAccount.transfer(total);
    }

    function setFeeAccount(address payable account) external onlyOwner {
        feeAccount = account;
    }

    function setContractOwner(address payable account) external onlyOwner {
        owner = account;
    }

    function viewTokenBalance(address token, address user)
        external
        view
        returns (uint balance)
    {
        return tokenBalances[token][user];
    }

    function viewPaymentFeeBalance(address token)
        external
        view
        returns (uint balance)
    {
        return paymentFeeBalances[token];
    }

    // TODO: change these methods so that the payment and base fee can only be
    // decreased (once a suitable starting fee is reached).
    function setBaseFee(uint newFee) external onlyOwner {
        baseFee = newFee;
    }

    function setPaymentFee(uint newFee) external onlyOwner {
        paymentFee = newFee;
    }

    function disableRetrieveFunds(bool disabled) public onlyOwner {
        retrieveFundsEnabled = !disabled;
    }

    function disableCreatePayment(bool disabled) public onlyOwner {
        createPaymentEnabled = !disabled;
    }

    function getPaymentInfo(uint paymentID)
        external
        view
        returns (
            uint holdTime,
            uint paymentOpenTime,
            uint paymentCloseTime,
            address token,
            uint sendAmount,
            uint paymentFeeTotal,
            address sender,
            address recipient,
            bytes memory codeHash,
            uint state
        )
    {
        Payment memory txn = openPayments[paymentID];
        return (
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.paymentFee,
            txn.sender,
            txn.recipient,
            txn.codeHash,
            uint(txn.state)
        );
    }

    function cancelPaymentAsSender(uint txnId) external {
        // Check txn sender and state.
        Payment memory txn = openPayments[txnId];
        require(
            txn.sender == msg.sender,
            "Payment sender does not match message sender."
        );
        require(
            txn.state == PaymentState.OPEN,
            "Payment must be open to cancel."
        );
        cancelPayment(txnId);
    }

    // Cancels the payment and returns the funds to the payment's sender.
    // Assumes that checks have already been done on any external calls.
    function cancelPayment(uint txnId) private {
        // Check txn sender and state.
        Payment memory txn = openPayments[txnId];

        // Update txn state.
        txn.paymentCloseTime = now;
        txn.state = PaymentState.CANCELLED;

        delete openPayments[txnId];

        // Return funds to sender.
        if (txn.token == address(0)) {
            tokenBalances[address(0)][txn.sender] = SafeMath.sub(
                tokenBalances[address(0)][txn.sender],
                txn.sendAmount
            );
            // Refund paymentFee
            tokenBalances[address(0)][address(this)] = SafeMath.sub(
                tokenBalances[address(0)][address(this)],
                txn.paymentFee
            );
            txn.sender.transfer(SafeMath.add(txn.sendAmount, txn.paymentFee));
        } else {
            // The txn.paymentFee will be refunded in this method from the contract balance.
            withdrawToken(
                txn.token,
                txn.sender,
                txn.sender,
                txn.sendAmount,
                txn.paymentFee
            );
        }

        emit PaymentClosed(
            txnId,
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.paymentFee,
            txn.sender,
            txn.recipient,
            txn.codeHash,
            uint(txn.state)
        );
    }

    /**
* This function handles deposits of ERC-20 tokens to the contract.
* Does not allow Ether.
* If token transfer fails, payment is reverted and remaining gas is refunded.
* Additionally, includes a fee which must be accounted for when approving the amount.
* Note: Remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.
* @param token Ethereum contract address of the token or 0 for Ether
* @param originalAmount uint of the amount of the token the user wishes to deposit
* @param feeAmount uint total amount of the fee charged by the contract
*/
    function transferToken(
        address token,
        address user,
        uint originalAmount,
        uint feeAmount
    ) internal {
        require(
            token != address(0),
            "Cannot call transferToken for transferring ether"
        );

        // Mark the user's token balance with the original amount
        tokenBalances[token][user] = SafeMath.add(
            tokenBalances[token][user],
            originalAmount
        );

        // Mark the paymentFee in the contract account
        tokenBalances[token][address(this)] = SafeMath.add(
            tokenBalances[token][address(this)],
            feeAmount
        );

        // TODO: use depositingTokenFlag in the ERC223 fallback function,
        // after implementing ERC223 or ERC777 interface. This is similar
        // to the ForkDelta contract implementation
        // (see https://github.com/forkdelta/smart_contract/blob/master/contracts/ForkDelta.sol)
        //depositingTokenFlag = true;

        // TODO: may want to require / revert if allowed balance from approve
        // is less than necessary amount.

        // TODO: not sure if this require message is actually visible in VM executions.
        require(
            IERC20(token).transferFrom(
                user,
                address(this),
                SafeMath.add(originalAmount, feeAmount)
            ),
            "Could not successfully transfer token"
        );
        //depositingTokenFlag = false;
    }

    // We don't increment any balances for userTo,
    // because the funds are sent outside of the contract.
    // The amount and paymentFeeRefund is transferred to userTo.
    function withdrawToken(
        address token,
        address userFrom,
        address userTo,
        uint amount,
        uint paymentFeeRefund
    ) internal {
        require(
            token != address(0),
            "Cannot call withdrawToken function for withdrawing ether"
        );
        // The paymentFeeRefund should be 0 when funds are being retrieved,
        // so this becomes just the amount.
        uint totalAmount = SafeMath.add(amount, paymentFeeRefund);

        require(
            tokenBalances[token][userFrom] >= amount,
            "userFrom contract balance is not sufficient"
        );
        require(
            tokenBalances[token][address(this)] >= paymentFeeRefund,
            "Contract balance is not sufficient"
        );

        // Update contract's token balance (from refunding the paymentFee)
        // For retrieving funds, the balance should be moved to the
        // fee account beforehand.
        tokenBalances[token][address(this)] = SafeMath.sub(
            tokenBalances[token][address(this)],
            paymentFeeRefund
        );
        // Update userFrom's contract balance
        tokenBalances[token][userFrom] = SafeMath.sub(
            tokenBalances[token][userFrom],
            amount
        );

        require(
            IERC20(token).transfer(userTo, totalAmount),
            "Could not successfully transfer token"
        );
    }

    function createPayment(
        uint amount,
        address payable recipient,
        uint holdTime,
        bytes calldata codeHash
    ) external payable {
        return createTokenPayment(
            address(0),
            amount,
            recipient,
            holdTime,
            codeHash
        );

    }

    function getPaymentId(address recipient, bytes memory codeHash)
        public
        pure
        returns (uint result)
    {
        bytes memory txnIdBytes = abi.encodePacked(
            keccak256(abi.encodePacked(codeHash, recipient))
        );
        uint txnId = sliceUint(txnIdBytes);
        return txnId;
    }
    // Creates a new payment with the msg.sender as sender.
    // Takes a base fee in ETH, as well as a payment fee in either ETH or the token used.
    //
    // We assume here that an approve() call has already been made for
    // the total amount passed to this function.
    //
    // Note that the amount passed into this function for token
    // transactions is the original amount sent in the payment.
    // However, the paymentFee must be included when making the approve call.
    // So the total amount for approval must be >= (original amount + paymentFeePercentage * original amount).
    function createTokenPayment(
        address token,
        uint amount,
        address payable recipient,
        uint holdTime,
        bytes memory codeHash
    ) public payable {
        // Check amount and fee, make sure to truncate fee.
        require(
            createPaymentEnabled,
            "The create payments functionality is currently disabled"
        );
        uint paymentFeeTotal = uint(
            SafeMath.mul(paymentFee, amount) / (1 ether)
        );
        if (token == address(0)) {
            require(
                msg.value >= (
                    SafeMath.add(SafeMath.add(amount, baseFee), paymentFeeTotal)
                ),
                "Message value is not enough to cover amount and fees"
            );
        } else {
            require(
                msg.value >= baseFee,
                "Message value is not enough to cover base fee"
            );
            // We don't check for a minimum when taking the paymentFee here. We already
            // assume that the sendAmount + paymentFeeAmount total has been approved for
            // transfer beforehand.
            // TODO: may want to confirm this
        }

        // Check payment ID.
        // TODO: should other components be included in the hash? This isn't secure
        // if someone uses a bad codeHash. But they could mess up other components anyway,
        // unless a UUID was generated in the contract, which is expensive.
        uint txnId = getPaymentId(recipient, codeHash);
        // If txnId already exists, don't overwrite.
        require(
            openPayments[txnId].sender == address(0),
            "Payment ID must be unique. Use a different passphrase hash."
        );

        // Create payments.
        Payment memory txn = Payment(
            holdTime,
            now,
            0,
            token,
            amount,
            paymentFeeTotal,
            msg.sender,
            recipient,
            codeHash,
            PaymentState.OPEN
        );

        openPayments[txnId] = txn;

        // Take fees; mark ether or token balances.
        if (token == address(0)) {
            // Mark sender's ether balance with the specified amount
            tokenBalances[address(0)][msg.sender] = SafeMath.add(
                tokenBalances[address(0)][msg.sender],
                amount
            );

            // Mark the paymentFee in the contract account
            tokenBalances[address(0)][address(this)] = SafeMath.add(
                tokenBalances[address(0)][address(this)],
                paymentFeeTotal
            );

            // Mark the baseFee and any leftover ether
            baseFeeBalance = SafeMath.add(
                baseFeeBalance,
                SafeMath.sub(msg.value, SafeMath.add(amount, paymentFeeTotal))
            );

        } else {
            // Mark the baseFee and any leftover ether
            baseFeeBalance = SafeMath.add(baseFeeBalance, msg.value);

            // Transfer tokens; mark sender's balance; mark paymentFee
            transferToken(token, msg.sender, amount, paymentFeeTotal);
        }

        emit PaymentOpened(
            txnId,
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.paymentFee,
            txn.sender,
            txn.recipient,
            txn.codeHash
        );

    }

    // Meant to be called by anyone, on behalf of the recipient
    // or sender of a payment, in order to retrieve funds or
    // cancel the payment, respectively.
    // Will only work if the correct signature is passed in.
    function completePaymentAsProxy(
        uint256 txnId,
        address sender,
        address recipient,
        string memory passphrase,
        uint requestType,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public {
        CompletePaymentRequest memory request = CompletePaymentRequest(
            txnId,
            sender,
            recipient,
            passphrase,
            requestType
        );
        address signer = ecrecover(
            hashCompletePaymentRequest(request),
            sigV,
            sigR,
            sigS
        );

        require(
            requestType == uint(
                CompletePaymentRequestType.CANCEL
            ) || requestType == uint(CompletePaymentRequestType.RETRIEVE),
            "requestType must be 0 (CANCEL) or 1 (RETRIEVE)"
        );

        if (requestType == uint(CompletePaymentRequestType.RETRIEVE)) {
            require(
                recipient == signer,
                "The message recipient must be the same as the signer of the message"
            );
            Payment memory txn = openPayments[txnId];
            require(
                txn.recipient == recipient,
                "The payment's recipient must be the same as signer of the message"
            );
            retrieveFunds(txn, txnId, passphrase);
        } else {
            require(
                sender == signer,
                "The message sender must be the same as the signer of the message"
            );
            Payment memory txn = openPayments[txnId];
            require(
                txn.sender == sender,
                "The payment's sender must be the same as signer of the message"
            );
            cancelPayment(txnId);
        }
    }

    // Meant to be called by the recipient.
    function retrieveFundsAsRecipient(uint txnId, string memory code) public {
        Payment memory txn = openPayments[txnId];

        // Check recipient
        require(
            txn.recipient == msg.sender,
            "Message sender must match payment recipient"
        );
        retrieveFunds(txn, txnId, code);
    }

    // Sends funds to a payment recipient.
    // Internal ONLY, because it does not do any checks with msg.sender,
    // and leaves that for calling functions.
    // TODO: find a more secure way to implement the recipient check.
    function retrieveFunds(Payment memory txn, uint txnId, string memory code)
        private
    {
        require(
            retrieveFundsEnabled,
            "The retrieve funds functionality is currently disabled."
        );
        require(
            txn.state == PaymentState.OPEN,
            "Payment must be open to retrieve funds"
        );
        // TODO: make sure this is secure.
        bytes memory actualHash = abi.encodePacked(
            keccak256(abi.encodePacked(code, txn.recipient))
        );
        // Check codeHash
        require(
            sliceUint(actualHash) == sliceUint(txn.codeHash),
            "Passphrase is not correct"
        );

        // Check holdTime
        require(
            (txn.paymentOpenTime + txn.holdTime) > now,
            "Hold time has already expired"
        );

        // Update state.
        txn.paymentCloseTime = now;
        txn.state = PaymentState.COMPLETED;

        delete openPayments[txnId];

        // Transfer either ether or tokens.
        if (txn.token == address(0)) {
            // Pay out retrieved funds based on payment amount
            // TODO: recipient must be valid!
            txn.recipient.transfer(txn.sendAmount);
            tokenBalances[address(0)][txn.sender] = SafeMath.sub(
                tokenBalances[address(0)][txn.sender],
                txn.sendAmount
            );

            // Mark paymentFee transfer from contract to fee account,
            // since transaction executed successfully.
            tokenBalances[address(0)][address(this)] = SafeMath.sub(
                tokenBalances[address(0)][address(this)],
                txn.paymentFee
            );
            paymentFeeBalances[address(0)] = SafeMath.add(
                paymentFeeBalances[address(0)],
                txn.paymentFee
            );

        } else {
            // Mark paymentFee transfer from contract to fee account,
            // since transaction executed successfully.
            tokenBalances[txn.token][address(this)] = SafeMath.sub(
                tokenBalances[txn.token][address(this)],
                txn.paymentFee
            );
            paymentFeeBalances[txn.token] = SafeMath.add(
                paymentFeeBalances[txn.token],
                txn.paymentFee
            );

            // We set paymentFeeRefund to 0, nothing is refunded from the contract balance.
            withdrawToken(
                txn.token,
                txn.sender,
                txn.recipient,
                txn.sendAmount,
                0
            );

        }

        emit PaymentClosed(
            txnId,
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.paymentFee,
            txn.sender,
            txn.recipient,
            txn.codeHash,
            uint(txn.state)
        );

    }

    // Utility function to go from bytes -> uint
    // This is apparently not reversible.
    function sliceUint(bytes memory bs) public pure returns (uint) {
        uint start = 0;
        if (bs.length < start + 32) {
            return 0;
        }
        uint x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return x;
    }

}