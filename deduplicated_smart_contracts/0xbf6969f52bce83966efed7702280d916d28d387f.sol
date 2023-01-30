pragma solidity 0.5.0;

import "./CrowdliSTO.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

/**
* This contract can be in one of the following states:
* - Active      The contract is open to new payment requests
* - Closed      No new payments will be accepted nor payments can be rejected though refunds can be claimed for payments that had been prior to closing.
*/
contract CrowdliExchangeVault is Ownable, Pausable {

    struct EtherPayment {
        address from;
        uint64 date;
        PaymentStatus status;
        uint weiAmount;
        uint pendingTokens;
        uint mintedTokens;
        uint exchangeRate;
    }

    struct ExchangeOrder {
        uint256 exchangeRate;
        uint64 date;
        address exchangeWallet;
        ExchangeStatus status;
    }
    
    /**
     * Defines the statuses an exchange order can have
     */
    enum ExchangeStatus { Pending, Confirmed }

    /**
    * Defines the statuses an payment can have
    */
    enum PaymentStatus { None, Requested, Accepted, TokensDelivered, Rejected, Refunded, PurchaseFailed }
    
    /**
    * The safe math library for safety math operations provided by Zeppelin
    */
    using SafeMath for uint256;

    /**
    * Holds all exchange orders, each of them containing multiple payments
    */
   	ExchangeOrder[] public exchangeOrders;
   
    /**
    * Holds all ether payments in different states (PaymentStatu
    */
    EtherPayment[] public payments;
    
    /**
     * A dictionary holind the number of requested payment per investor
     */
    mapping(address => uint) public nrRequestedPayments; 
    
    /**
     * A dictionary to lookup the related payments (paymentsIds: uint[]) for a given exchange order (exchangeOrderId: uint)
     */
    mapping(uint => uint[]) private exchangeOrderForPayments; //exchangeOrderId => array of paymentsIds
    
    
    address public paymentConfirmer;
    
    /**
     * Used to process payments once they are confirmed 
     */
    CrowdliSTO private crowdliSTO;
    
     /**
     * Event will be fired whenever payments processing is enabled
     * @param sender The account that has enabled the payment processing
     */
    event PaymentsEnabled(address indexed sender);
    
    /**
     * Event will be fired whenever payments processing is disabled
     * @param sender The account that has disabled the payment processing
     */
    event PaymentsDisabled(address indexed sender);
    event EtherPaymentRefunded(address indexed beneficiary, uint256 weiAmount);
    event EtherPaymentRequested(address indexed beneficiary, uint256 weiAmount, uint paymentIndex);
    event EtherPaymentRejected(address indexed sender, uint etherPaymentIndex);
    event LogGasUsed(address indexed sender, uint indexed value);
    event EtherPaymentPurchaseFailed(address indexed sender, uint indexed etherPaymentIndex);
    event OrderCreated(address indexed sender, uint[] payments);
    event OrderConfirmed(address indexed sender, uint indexed etherPaymentIndex);

	modifier isInInvestmentState() {
         require(crowdliSTO.hasState(CrowdliSTO.States.Investment) || !crowdliSTO.paused(), "bot in state investment");
        _;
    }

    modifier onlyCrowdliSTO() {
        require((msg.sender == address(crowdliSTO)), "Sender should be CrowdliSTO");
        _;
    }
    
    modifier onlyEtherPaymentConfirmer() {
        require((msg.sender == paymentConfirmer), "Sender should be EtherPaymentConfirmer");
        _;
    }
    
    constructor(address _paymentConfirmer) public {
        paymentConfirmer = _paymentConfirmer; 
    }
    
	function setCrowdliSTO(CrowdliSTO _crowdliSTO) external onlyOwner {
    	crowdliSTO = _crowdliSTO;
    }

	function initExchangeVault(address _directorsBoard, address _crowdliSTO) external onlyOwner{
    	crowdliSTO = CrowdliSTO(_crowdliSTO);
    	transferOwnership(_crowdliSTO);
    	addPauser(_directorsBoard);
    	addPauser(_crowdliSTO);
    }
    
    function confirmMintedTokensForPayment(uint paymentId, uint _mintedTokens) external onlyOwner {
        payments[paymentId].mintedTokens = payments[paymentId].mintedTokens.add(_mintedTokens);
    }
    /**
    * @dev The ether provided by the investor will be collected for a new fiat exchange order will be triggered by the owner
    * @dev Since the exact conversion rate that will be used for the fiat exchange is unknown the tokens will be minted AFTER once the order is completed
    */

    function requestPayment() external whenNotPaused payable  {
        uint[] memory tokenStatement = crowdliSTO.calculateTokenStatementEther(msg.sender, msg.value, CrowdliSTO.Currency.ETH, false, 0); 
        // only process if validation code == OK
        require(CrowdliSTO.TokenStatementValidation(tokenStatement[8]) == CrowdliSTO.TokenStatementValidation.OK, crowdliSTO.resolvePaymentError(CrowdliSTO.TokenStatementValidation(tokenStatement[8])));
        
        payments.push(EtherPayment(msg.sender, uint64(now), PaymentStatus.Requested, msg.value, 0, 0, 0));
        nrRequestedPayments[msg.sender] = nrRequestedPayments[msg.sender].add(1);
        emit EtherPaymentRequested(msg.sender, msg.value, payments.length.sub(1));
    }
    
    /**
    * @dev An investor can be subsequently rejected if the AML and PEP checks were negative
    */
    function rejectPayment(uint[] calldata _paymentIds) external onlyEtherPaymentConfirmer {
        for(uint id = 0; id < _paymentIds.length; id++){
        	uint paymentId = _paymentIds[id];
            // we only allow payments that have not been confirmed, rejected or refunded yet
            require(payments[paymentId].status == PaymentStatus.Requested, "Payment must be in state Requested");
    
            // mark ether payment as rejected and therby allowing the investor to claim refund
            payments[paymentId].status = PaymentStatus.Rejected;
            
            nrRequestedPayments[payments[paymentId].from] = nrRequestedPayments[payments[paymentId].from].sub(1);
            // fire an event so the investor can be informed that his payment was rejected
            emit EtherPaymentRejected(payments[paymentId].from, paymentId);
        }
    }

    /**
    * @dev Once an investor has been rejected a refund can be claimed
    */
    function refundPayment(uint index) external {
    
        EtherPayment storage etherPayment = payments[index];
        uint256 depositedValue = etherPayment.weiAmount;

        // only allow refund for payments which have been rejected 
        require((etherPayment.from == msg.sender) || (msg.sender == paymentConfirmer), "Refund are not enabled for sender");
        require(etherPayment.status == PaymentStatus.Rejected , "etherPayment.status should be PaymentStatus.Rejected");
		require(address(this).balance >= depositedValue , "Exchange Vault balance doesn't have enough funds.");
        // mark ether payment status to refunded
        etherPayment.status = PaymentStatus.Refunded;

        // send the ether back to investors address
        msg.sender.transfer(depositedValue);

        emit EtherPaymentRefunded(msg.sender, depositedValue);
    }

    /**
     * @param _exchangeWallet The wallet of the exchange provider where the ether will be sent for FIAT exchange
     */
    function createOrder(address payable _exchangeWallet, uint[] calldata _paymentsToAccept) external whenNotPaused onlyEtherPaymentConfirmer isInInvestmentState {
        require(payments.length > 0, "At least one payment is required to exchange");
        ExchangeOrder memory exchangeOrder = ExchangeOrder(0, uint64(now), _exchangeWallet, ExchangeStatus.Pending);
        exchangeOrders.push(exchangeOrder);
        uint weiAmountForTransfering = 0;
        // iterate through all payments which are not assigned to an exchange order
       	uint[] storage orderForPaymentIds = exchangeOrderForPayments[exchangeOrders.length-1];
        for (uint64 i = 0; i < _paymentsToAccept.length; i++) {
            uint paymentId = _paymentsToAccept[i];
            EtherPayment storage etherPayment = payments[paymentId];
            require(etherPayment.status == PaymentStatus.Requested, "should be in status requested"); 
            etherPayment.status = PaymentStatus.Accepted;
            orderForPaymentIds.push(paymentId);
            processPayment(paymentId);
            weiAmountForTransfering = weiAmountForTransfering.add(etherPayment.weiAmount);
        }
        emit OrderCreated(msg.sender, orderForPaymentIds);
        _exchangeWallet.transfer(weiAmountForTransfering);
    }

	/**
	* buy tokens on behalf of the investor
	*/
	function processPayment(uint _paymentId) internal {
		EtherPayment storage etherPayment = payments[_paymentId];
	    nrRequestedPayments[etherPayment.from] = nrRequestedPayments[etherPayment.from].sub(1);
	    crowdliSTO.processEtherPayment(etherPayment.from, etherPayment.weiAmount, _paymentId);
	    etherPayment.status = PaymentStatus.TokensDelivered;
	    etherPayment.exchangeRate = crowdliSTO.exchangeRate();
    }
    
    function confirmOrder(uint64 _orderIndex, uint256 _exchangeRate) external whenNotPaused onlyEtherPaymentConfirmer {
        require(_orderIndex < exchangeOrders.length, "_orderIndex is too high");
        ExchangeOrder storage exchangeOrder = exchangeOrders[_orderIndex];
        require(exchangeOrder.status != ExchangeStatus.Confirmed, "exchangeOrder.status is confirmed");
        exchangeOrder.exchangeRate = _exchangeRate;
        exchangeOrder.status = ExchangeStatus.Confirmed;
    }
    
    function hasRequestedPayments(address _beneficiary) public view returns(bool) {
        return (nrRequestedPayments[_beneficiary] != 0);
    }    
        
    function getEtherPaymentsCount() external view returns(uint256) {
        return payments.length;
    }
    
    function getExchangeOrdersCount() external view returns(uint256) {
        return exchangeOrders.length;
    }
    
    function getExchangeOrdersToPayments(uint orderId) external view returns (uint[] memory) {
        return exchangeOrderForPayments[orderId];
    }     
    
}
