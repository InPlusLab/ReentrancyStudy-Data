pragma solidity ^0.4.24;

import "./ERC20.sol";

contract Isonex is ERC20 {

    // 15M
    uint256 public tokenCap = 15000000 * 10**18;

    bool public tradeable = false;

    address public primaryWallet;
    address public secondaryWallet;

    mapping (address => bool) public whitelist;

    // Conversion rate from IX15 to ETH
    struct Price { uint256 numerator; uint256 denominator; }
    Price public currentPrice;

     // The amount of time that the secondary wallet must wait between price updates
    uint256 public priceUpdateInterval = 1 hours;

    mapping (uint256 => Price) public priceHistory;
    uint256 public currentPriceHistoryIndex = 0;

    // time for each withdrawal is set to the currentPriceHistoryIndex
    struct WithdrawalRequest { uint256 nummberOfTokens; uint256 time; }
    mapping (address => WithdrawalRequest) withdrawalRequests;

    mapping(uint8 => string) restrictionMap;

    constructor (address newSecondaryWallet, uint256 newPriceNumerator) public {
        require(newSecondaryWallet != address(0), "newSecondaryWallet != address(0)");
        require(newPriceNumerator > 0, "newPriceNumerator > 0");
        name = "Isonex";
        symbol = "IX15";
        decimals = 18;
        primaryWallet = msg.sender;
        secondaryWallet = newSecondaryWallet;
        whitelist[primaryWallet] = true;
        whitelist[secondaryWallet] = true;
        currentPrice = Price(newPriceNumerator, 1000);
        currentPriceHistoryIndex = now;

        restrictionMap[1] = "Sender is not whitelisted";
        restrictionMap[2] = "Receiver is not whitelisted";
        restrictionMap[3] = "Trading is not enabled";
    }

    // Primary and Secondary wallets may updated the current price. Secondary wallet has time and change size constrainst
    function updatePrice(uint256 newNumerator) external onlyPrimaryAndSecondaryWallets {
        require(newNumerator > 0, "newNumerator > 0");
        checkSecondaryWalletRestrictions(newNumerator);

        currentPrice.numerator = newNumerator;

        // After the token sale, map time to new Price
        priceHistory[currentPriceHistoryIndex] = currentPrice;
        currentPriceHistoryIndex = now;
        emit PriceUpdated(newNumerator, currentPrice.denominator);
    }

    // secondaryWallet can only increase price by up to 20% and only every priceUpdateInterval
    function checkSecondaryWalletRestrictions (uint256 newNumerator) view private
      onlySecondaryWallet priceUpdateIntervalElapsed ifNewNumeratorGreater(newNumerator) {
        uint256 percentageDiff = safeSub(safeMul(newNumerator, 100) / currentPrice.numerator, 100);
        require(percentageDiff <= 20, "percentageDiff <= 20");
    }

    function updatePriceDenominator(uint256 newDenominator) external onlyPrimaryWallet {
        require(newDenominator > 0, "newDenominator > 0");
        currentPrice.denominator = newDenominator;
        // map time to new Price
        priceHistory[currentPriceHistoryIndex] = currentPrice;
        currentPriceHistoryIndex = now;
        emit PriceUpdated(currentPrice.numerator, newDenominator);
    }

    function processDeposit(address participant, uint numberOfTokens) external onlyPrimaryWallet {
        require(participant != address(0), "participant != address(0)");
        whitelist[participant] = true;
        allocateTokens(participant, numberOfTokens);
        emit Whitelisted(participant);
        emit DepositProcessed(participant, numberOfTokens);
    }

    // When Ether is sent directly to the contract
    function() public payable {
    }

    function allocateTokens(address participant, uint256 numberOfTokens) private {

        // check that token cap is not exceeded
        require(safeAdd(totalSupply, numberOfTokens) <= tokenCap, "Exceeds token cap");

        // increase token supply, assign tokens to participant
        totalSupply = safeAdd(totalSupply, numberOfTokens);
        balances[participant] = safeAdd(balances[participant], numberOfTokens);

        emit Transfer(address(0), participant, numberOfTokens);
    }

    function verifyParticipant(address participant) external onlyPrimaryAndSecondaryWallets {
        whitelist[participant] = true;
        emit Whitelisted(participant);
    }

    function removeFromWhitelist(address participant) external onlyPrimaryAndSecondaryWallets {
        whitelist[participant] = false;
        emit RemovedFromWhitelist(participant);
    }

    function requestWithdrawal(uint256 amountOfTokensToWithdraw) external isTradeable onlyWhitelist {
        require(amountOfTokensToWithdraw > 0, "Amount must be greater than 0");
        address participant = msg.sender;
        require(balanceOf(participant) >= amountOfTokensToWithdraw, "Not enough balance");
        require(withdrawalRequests[participant].nummberOfTokens == 0, "Outstanding withdrawal request must be processed");
        balances[participant] = safeSub(balanceOf(participant), amountOfTokensToWithdraw);
        withdrawalRequests[participant] = WithdrawalRequest({nummberOfTokens: amountOfTokensToWithdraw, time: currentPriceHistoryIndex});
        emit WithdrawalRequested(participant, amountOfTokensToWithdraw);
    }

    function withdraw() external {
        address participant = msg.sender;
        uint256 nummberOfTokens = withdrawalRequests[participant].nummberOfTokens;
        require(nummberOfTokens > 0, "Missing withdrawal request");
        uint256 requestTime = withdrawalRequests[participant].time;
        Price storage price = priceHistory[requestTime];
        require(price.numerator > 0, 'Please wait for the next price update');
        uint256 etherAmount = safeMul(nummberOfTokens, price.denominator) / price.numerator;
        require(address(this).balance >= etherAmount, "Not enough Ether in the smart contract.");

        withdrawalRequests[participant].nummberOfTokens = 0;
        // Move the Isonex tokens to the primary wallet
        balances[primaryWallet] = safeAdd(balances[primaryWallet], nummberOfTokens);
        // Send ether from the contract wallet to the participant
        participant.transfer(etherAmount);
        emit Withdrew(participant, etherAmount, nummberOfTokens);
    }

    function checkWithdrawValue(uint256 amountTokensToWithdraw) public constant returns (uint256 etherValue) {
        require(amountTokensToWithdraw > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amountTokensToWithdraw, "Not enough balance");
        uint256 withdrawValue = safeMul(amountTokensToWithdraw, currentPrice.denominator) / currentPrice.numerator;
        require(address(this).balance >= withdrawValue, "Not enough balance in contract");
        return withdrawValue;
    }

    // allow the primaryWallet or secondaryWallet to add Ether to the contract
    function addLiquidity() external onlyPrimaryAndSecondaryWallets payable {
        require(msg.value > 0, "Amount must be greater than 0");
        emit LiquidityAdded(msg.value);
    }

    // allow the primaryWallet or secondaryWallet to remove Ether from contract
    function removeLiquidity(uint256 amount) external onlyPrimaryAndSecondaryWallets {
        require(amount <= address(this).balance, "amount <= address(this).balance");
        primaryWallet.transfer(amount);
        emit LiquidityRemoved(amount);
    }

    function changePrimaryWallet(address newPrimaryWallet) external onlyPrimaryWallet {
        require(newPrimaryWallet != address(0), "newPrimaryWallet != address(0)");
        primaryWallet = newPrimaryWallet;
    }

    function changeSecondaryWallet(address newSecondaryWallet) external onlyPrimaryWallet {
        require(newSecondaryWallet != address(0), "newSecondaryWallet != address(0)");
        secondaryWallet = newSecondaryWallet;
    }

    function changePriceUpdateInterval(uint256 newPriceUpdateInterval) external onlyPrimaryWallet {
        priceUpdateInterval = newPriceUpdateInterval;
    }

    function enableTrading() external onlyPrimaryWallet {
        tradeable = true;
    }

    function claimTokens(address _token) external onlyPrimaryWallet {
        require(_token != address(0), "_token != address(0)");
        ERC20Interface token = ERC20Interface(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(primaryWallet, balance);
    }

    // override transfer and transferFrom to add is tradeable modifier
    function transfer(address _to, uint256 _value) public notRestricted(msg.sender, _to, _value) returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public notRestricted(_from, _to, _value) returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    function pendingWithdrawalAmount() external constant returns (uint256) {
        return withdrawalRequests[msg.sender].nummberOfTokens;
    }

    function pendingWithdrawalRateNumerator() external constant returns (uint256) {
        return priceHistory[withdrawalRequests[msg.sender].time].numerator;
    }

    function isInWhitelist(address participant) external constant onlyPrimaryWallet returns (bool) {
        return whitelist[participant];
    }

    function amIWhitelisted() external constant returns (bool) {
        return whitelist[msg.sender];
    }

    // returns a restriction code,
    // where 0 success
    function detectTransferRestriction(address from, address to, uint256 value) public view returns (uint8) {
        if (whitelist[from] == false) {
            return 1;
        }
        if (whitelist[to] == false) {
            return 2;
        }
        if (!(tradeable || msg.sender == primaryWallet)) {
            return 3;
        }
        return 0;
    }

    function messageForTransferRestriction (uint8 restrictionCode) public view returns (string){
        if (bytes(restrictionMap[restrictionCode]).length == 0 ){
            return "Invalid restriction code";
        }

        return restrictionMap[restrictionCode];
    }

    // Events

    event PriceUpdated(uint256 numerator, uint256 denominator);
    event DepositProcessed(address indexed participant, uint256 numberOfTokens);
    event Whitelisted(address indexed participant);
    event RemovedFromWhitelist(address indexed participant);
    event WithdrawalRequested(address indexed participant, uint256 numberOfTokens);
    event Withdrew(address indexed participant, uint256 etherAmount, uint256 numberOfTokens);
    event LiquidityAdded(uint256 ethAmount);
    event LiquidityRemoved(uint256 ethAmount);
    event UserDeposited(address indexed participant, address indexed beneficiary, uint256 ethValue, uint256 numberOfTokens);

    // Modifiers

    modifier onlyWhitelist {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    modifier onlyPrimaryWallet {
        require(msg.sender == primaryWallet, "Unauthorized");
        _;
    }

    modifier onlySecondaryWallet {
        if (msg.sender == secondaryWallet)
		_;
    }

    modifier onlyPrimaryAndSecondaryWallets {
        require(msg.sender == secondaryWallet || msg.sender == primaryWallet, "Unauthorized");
        _;
    }

    modifier priceUpdateIntervalElapsed {
        require(safeSub(now, priceUpdateInterval) >= currentPriceHistoryIndex, "Price update interval");
        _;
    }

    modifier ifNewNumeratorGreater (uint256 newNumerator) {
        if (newNumerator > currentPrice.numerator)
        _;
    }

    modifier isTradeable { // exempt primaryWallet to allow dev allocations
        require(tradeable || msg.sender == primaryWallet, "Trading is currently disabled");
        _;
    }

    modifier notRestricted (address from, address to, uint256 value) {
        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(restrictionCode == 0, messageForTransferRestriction(restrictionCode));
        _;
    }
}