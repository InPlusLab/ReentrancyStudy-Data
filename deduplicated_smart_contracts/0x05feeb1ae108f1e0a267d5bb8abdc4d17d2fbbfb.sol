// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";


contract L1T is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;
    bool public swapEnabled;
    bool public tradingEnabled;

    mapping (address => uint256) private _dailySells;
    mapping (address => uint256) private _firstSell;
    mapping (address => bool) private _isPresalers;

    L1TDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public swapTokensAtAmount = 2000000000 * (10**9);
    uint256 public maxDailySell = 200000000000 * 10**9;  // 0.02%
    uint256 public maxDailySellForPresale = 100000000000 * 10**9; // 0.01%

      uint256 public ETHRewardsFee = 3;
    uint256 public liquidityFee = 4;
    uint256 public marketingFee = 4;
    uint256 public devFee = 3;
    uint256 public dPrizeFee = 3;
    uint256 public mPrizeFee = 2;
    uint256 public yPrizeFee = 2;

    uint256 public totalFees = ETHRewardsFee.add(liquidityFee).add(marketingFee).add(dPrizeFee).add(mPrizeFee).add(yPrizeFee);

    address public marketingWallet = 0xb72d8992278A8Aca04e0C6D112F8C2491620E8a4;
    address public devWallet = 0x78D20EB7Cca669D6Eb6C07608020072A40EF2Ac6;
    address public dPrizeWallet = 0x989BC0089a1C6c4E7E813C8AEf7259230d42f8e5;
    address public mPrizeWallet = 0xC9E6A71e46Dcb1f5eD32AC0BE29549765E216BdA;
    address public yPrizeWallet = 0x4c9d95dccBdf3534f4E0594078b6321e875acd7B;
    address public liquidityWallet;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;


    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() ERC20("Lucky1Token", "L1T") {

    	dividendTracker = new L1TDividendTracker();


    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        
        liquidityWallet = owner();

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(devWallet, true);
        excludeFromFees(dPrizeWallet, true);
        excludeFromFees(mPrizeWallet, true);
        excludeFromFees(yPrizeWallet, true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1e11  * (10**9));
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "L1T: The dividend tracker already has that address");

        L1TDividendTracker newDividendTracker = L1TDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "L1T: The new dividend tracker must be owned by the L1T token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "L1T: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "L1T: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setMarketingWallet(address wallet) external onlyOwner{
        marketingWallet = wallet;
    }

    function setDevWallet(address wallet) external onlyOwner{
        devWallet = wallet;
    }
    
    function setLiquidiyWallet(address wallet) external onlyOwner{
        liquidityWallet = wallet;
    }

    function setDailyPrizeWallet(address wallet) external onlyOwner{
        dPrizeWallet = wallet;
    }

    function setMonthlyPrizeWallet(address wallet) external onlyOwner{
        mPrizeWallet = wallet;
    }

    function setYearlyPrizeWallet(address wallet) external onlyOwner{
        yPrizeWallet = wallet;
    }

    function setPresalers(address[] memory presalers) external onlyOwner{
        for(uint256 i = 0; i < presalers.length; i++){
            _isPresalers[presalers[i]] = true;
        }
    }

    function setMaxDailySell(uint256 amount) external onlyOwner{
        maxDailySell = amount * 10**9;
    }

    function setMaxDailySellForPresale(uint256 amount) external onlyOwner{
        maxDailySellForPresale = amount * 10**9;
    }

    function setETHRewardsFee(uint256 value) external onlyOwner{
        ETHRewardsFee = value;
        totalFees = ETHRewardsFee.add(liquidityFee).add(marketingFee).add(dPrizeFee).add(mPrizeFee).add(yPrizeFee);
    }

    function setLiquiditFee(uint256 value) external onlyOwner{
        liquidityFee = value;
        totalFees = ETHRewardsFee.add(liquidityFee).add(marketingFee).add(dPrizeFee).add(mPrizeFee).add(yPrizeFee);
    }

    function setMarketingFee(uint256 value) external onlyOwner{
        marketingFee = value;
        totalFees = ETHRewardsFee.add(liquidityFee).add(marketingFee).add(dPrizeFee).add(mPrizeFee).add(yPrizeFee);
    }

    function setPrizeFees(uint256 _dayFee, uint256 _monthFee, uint256 _yearFee) external onlyOwner{
      dPrizeFee = _dayFee;
      mPrizeFee = _monthFee;
      yPrizeFee = _yearFee;
      totalFees = ETHRewardsFee.add(liquidityFee).add(marketingFee).add(dPrizeFee).add(mPrizeFee).add(yPrizeFee);
    }

    function setSwapEnabled(bool _enabled) external onlyOwner{
        swapEnabled = _enabled;
    }

    function setTradingEnabled(bool _enabled) external onlyOwner{
        tradingEnabled = _enabled;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "L1T: The Uniswap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "L1T: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "L1T: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "L1T: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**9;
    }

    function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            require(tradingEnabled, "Trading not started yet");
        }
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(_isPresalers[from]) {
            if(block.timestamp.sub(_firstSell[from]) < 1 days){
                require(_dailySells[from].add(amount) <= maxDailySellForPresale, "You are exceeding maxDailySellForPresale");
                _dailySells[from] = _dailySells[from].add(amount);
            }
            else{
                _firstSell[from] = block.timestamp;
                require(_dailySells[from].add(amount) <= maxDailySellForPresale, "You are exceeding maxDailySellForPresale");
                _dailySells[from] = amount;
            }
        }

        if(!_isExcludedFromFees[from] && !automatedMarketMakerPairs[from] && !swapping){
            if(block.timestamp.sub(_firstSell[from]) < 1 days){
                require(_dailySells[from].add(amount) <= maxDailySell, "You are exceeding maxDailySell");
                _dailySells[from] = _dailySells[from].add(amount);
            }
            else{
                _firstSell[from] = block.timestamp;
                require(_dailySells[from].add(amount) <= maxDailySell, "You are exceeding maxDailySell");
                _dailySells[from] = amount;
            }
        }

		    uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            swapEnabled &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            contractTokenBalance = swapTokensAtAmount;

            if(marketingFee > 0 || devFee > 0 || liquidityFee > 0){
                uint256 marketingTokens = contractTokenBalance.mul(marketingFee + devFee + liquidityFee).div(totalFees);
                swapAndSendToFee(marketingTokens);
            }

            if(dPrizeFee > 0 || mPrizeFee > 0 || yPrizeFee > 0){
                uint256 prizeTokens = contractTokenBalance.div(totalFees).mul(dPrizeFee + mPrizeFee + yPrizeFee);
                swapAndSendToPrizePools(prizeTokens);
            }

            if(ETHRewardsFee > 0){
                uint256 sellTokens = contractTokenBalance.mul(ETHRewardsFee).div(totalFees);
                swapAndSendDividends(sellTokens);
            }

            swapping = false;
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount.mul(totalFees).div(100);
          if(automatedMarketMakerPairs[to]){
              fees += amount.mul(1).div(100);
          }
        	amount = amount.sub(fees);
          super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}
        }
    }

    function swapAndSendToFee(uint256 tokens) private{
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        if(marketingFee > 0) payable(marketingWallet).transfer(newBalance.div(devFee + marketingFee + liquidityFee).mul(marketingFee));
        if(devFee > 0) payable(devWallet).transfer(newBalance.div(devFee + marketingFee + liquidityFee).mul(devFee));
        if(liquidityFee > 0) payable(liquidityWallet).transfer(newBalance.div(devFee + marketingFee + liquidityFee).mul(liquidityFee));
    }

    function swapAndSendToPrizePools(uint256 tokens) private {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 totalPrize = dPrizeFee.add(mPrizeFee).add(yPrizeFee);
        uint256 transferBalance = (address(this).balance).sub(initialBalance);
        payable(dPrizeWallet).transfer(transferBalance.div(totalPrize).mul(dPrizeFee));
        payable(mPrizeWallet).transfer(transferBalance.div(totalPrize).mul(mPrizeFee));
        payable(yPrizeWallet).transfer(transferBalance.div(totalPrize).mul(yPrizeFee));
    }


    function swapTokensForEth(uint256 tokenAmount) private {


        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapAndSendDividends(uint256 tokens) private{
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 dividends = address(this).balance.sub(initialBalance);
        (bool success,) = address(dividendTracker).call{value: dividends}("");

        if(success) {
   	 		emit SendDividends(tokens, dividends);
        }
    }
}

contract L1TDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor()  DividendPayingToken("L1T_Dividen_Tracker", "L1T_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 200000 * (10**9); //must hold 200,000 tokens
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "L1T_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "L1T_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main L1T contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "L1T_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "L1T_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }



    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}