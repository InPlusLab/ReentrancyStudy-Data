pragma solidity 0.4.18;

import "./ERC20Interface.sol";
import "./ConversionRates.sol";

/// @title EnhancedStepFunctions contract - new ConversionRates contract with step function enhancement
/// Removed qty step function overhead
/// Also fixed following issues:
/// https://github.com/KyberNetwork/smart-contracts/issues/291
/// https://github.com/KyberNetwork/smart-contracts/issues/241
/// https://github.com/KyberNetwork/smart-contracts/issues/240


contract EnhancedStepFunctions is ConversionRates {

    uint constant internal MAX_STEPS_IN_FUNCTION = 16;
    int constant internal MAX_IMBALANCE = 2 ** 254;
    uint constant internal POW_2_128 = 2 ** 128;

    function EnhancedStepFunctions(address _admin) public ConversionRates(_admin)
        { } // solhint-disable-line no-empty-blocks

    function setImbalanceStepFunction(
        ERC20 token,
        int128[] xBuy,
        int128[] yBuy,
        int128[] xSell,
        int128[] ySell
    )
        public
        onlyOperator
    {
        require(xBuy.length + 1 == yBuy.length);
        require(xSell.length + 1 == ySell.length);
        require(yBuy.length <= MAX_STEPS_IN_FUNCTION);
        require(ySell.length <= MAX_STEPS_IN_FUNCTION);
        require(tokenData[token].listed);

        if (xBuy.length > 1) {
            // verify qty are increasing
            for(uint i = 0; i < xBuy.length - 1; i++) {
                require(xBuy[i] < xBuy[i + 1]);
            }
        }

        if (xSell.length > 1) {
            // verify qty are increasing
            for(i = 0; i < xSell.length - 1; i++) {
                require(xSell[i] < xSell[i + 1]);
            }
        }

        int[] memory buyArray = new int[](yBuy.length);
        for(i = 0; i < yBuy.length; i++) {
            int128 xBuyVal = (i == yBuy.length - 1) ? 0 : xBuy[i];
            buyArray[i] = encodeStepFunctionData(xBuyVal, yBuy[i]);
        }

        int[] memory sellArray = new int[](ySell.length);
        for(i = 0; i < ySell.length; i++) {
            int128 xSellVal = (i == ySell.length - 1) ? 0 : xSell[i];
            sellArray[i] = encodeStepFunctionData(xSellVal, ySell[i]);
        }

        int[] memory emptyArr = new int[](0);
        tokenData[token].buyRateImbalanceStepFunction = StepFunction(buyArray, emptyArr);
        tokenData[token].sellRateImbalanceStepFunction = StepFunction(sellArray, emptyArr);
    }

    /* solhint-disable code-complexity */
    function getStepFunctionData(ERC20 token, uint command, uint param) public view returns(int) {
        if (command == 8) return int(tokenData[token].buyRateImbalanceStepFunction.x.length - 1);

        int stepXValue;
        int stepYValue;

        if (command == 9) {
            (stepXValue, stepYValue) = decodeStepFunctionData(tokenData[token].buyRateImbalanceStepFunction.x[param]);
            return stepXValue;
        }

        if (command == 10) return int(tokenData[token].buyRateImbalanceStepFunction.x.length);
        if (command == 11) {
            (stepXValue, stepYValue) = decodeStepFunctionData(tokenData[token].buyRateImbalanceStepFunction.x[param]);
            return stepYValue;
        }

        if (command == 12) return int(tokenData[token].sellRateImbalanceStepFunction.x.length - 1);
        if (command == 13) {
            (stepXValue, stepYValue) = decodeStepFunctionData(tokenData[token].sellRateImbalanceStepFunction.x[param]);
            return stepXValue;
        }

        if (command == 14) return int(tokenData[token].sellRateImbalanceStepFunction.x.length);
        if (command == 15) {
            (stepXValue, stepYValue) = decodeStepFunctionData(tokenData[token].sellRateImbalanceStepFunction.x[param]);
            return stepYValue;
        }

        revert();
    }

    /* solhint-disable function-max-lines */
    function getRate(ERC20 token, uint currentBlockNumber, bool buy, uint qty) public view returns(uint) {
        // check if trade is enabled
        if (!tokenData[token].enabled) return 0;
        if (tokenControlInfo[token].minimalRecordResolution == 0) return 0; // token control info not set

        // get rate update block
        bytes32 compactData = tokenRatesCompactData[tokenData[token].compactDataArrayIndex];

        uint updateRateBlock = getLast4Bytes(compactData);
        if (currentBlockNumber >= updateRateBlock + validRateDurationInBlocks) return 0; // rate is expired
        // check imbalance
        int totalImbalance;
        int blockImbalance;
        (totalImbalance, blockImbalance) = getImbalance(token, updateRateBlock, currentBlockNumber);

        // calculate actual rate
        int imbalanceQty;
        int extraBps;
        int8 rateUpdate;
        uint rate;

        if (buy) {
            // start with base rate
            rate = tokenData[token].baseBuyRate;

            // add rate update
            rateUpdate = getRateByteFromCompactData(compactData, token, true);
            extraBps = int(rateUpdate) * 10;
            rate = addBps(rate, extraBps);

            // compute token qty
            qty = getTokenQty(token, qty, rate);
            imbalanceQty = int(qty);

            // add imbalance overhead
            extraBps = executeStepFunction(
                tokenData[token].buyRateImbalanceStepFunction, 
                totalImbalance, 
                totalImbalance + imbalanceQty
            );
            rate = addBps(rate, extraBps);
            totalImbalance += imbalanceQty;
        } else {
            // start with base rate
            rate = tokenData[token].baseSellRate;

            // add rate update
            rateUpdate = getRateByteFromCompactData(compactData, token, false);
            extraBps = int(rateUpdate) * 10;
            rate = addBps(rate, extraBps);

            // compute token qty
            imbalanceQty = -1 * int(qty);

            // add imbalance overhead
            extraBps = executeStepFunction(
                tokenData[token].sellRateImbalanceStepFunction, 
                totalImbalance + imbalanceQty, 
                totalImbalance
            );
            rate = addBps(rate, extraBps);
            totalImbalance += imbalanceQty;
        }

        if (abs(totalImbalance) >= getMaxTotalImbalance(token)) return 0;
        if (abs(blockImbalance + imbalanceQty) >= getMaxPerBlockImbalance(token)) return 0;

        return rate;
    }

    // Override function getImbalance to fix #240
    function getImbalance(ERC20 token, uint rateUpdateBlock, uint currentBlock)
        internal view
        returns(int totalImbalance, int currentBlockImbalance)
    {
        int resolution = int(tokenControlInfo[token].minimalRecordResolution);

        (totalImbalance, currentBlockImbalance) =
            getImbalanceSinceRateUpdate(
                token,
                rateUpdateBlock,
                currentBlock);

        if (!checkMultOverflow(totalImbalance, resolution)) {
            totalImbalance *= resolution;
        } else {
            totalImbalance = MAX_IMBALANCE;
        }

        if (!checkMultOverflow(currentBlockImbalance, resolution)) {
            currentBlockImbalance *= resolution;
        } else {
            currentBlockImbalance = MAX_IMBALANCE;
        }
    }

    function getImbalancePerToken(ERC20 token, uint rateUpdateBlock, uint currentBlock)
        public view
        returns(int totalImbalance, int currentBlockImbalance)
    {
        return getImbalance(token, rateUpdateBlock, currentBlock);
    }

    function executeStepFunction(StepFunction storage f, int from, int to) internal view returns(int) {

        uint len = f.x.length;

        if (len == 0 || from == to) { return 0; }

        int fromVal = from; // avoid modifying function parameters
        int change = 0; // amount change from initial amount when applying bps for each step
        int stepXValue;
        int stepYValue;

        for(uint ind = 0; ind < len - 1; ind++) {
            (stepXValue, stepYValue) = decodeStepFunctionData(f.x[ind]);
            if (stepXValue <= fromVal) { continue; }
            // from here, from < stepXValue,
            // if from < to <= stepXValue, take [from, to] and return, else take [from, stepXValue]
            if (stepXValue >= to) {
                change += (to - fromVal) * stepYValue;
                return change / (to - from);
            } else {
                change += (stepXValue - fromVal) * stepYValue;
                fromVal = stepXValue;
            }
        }

        (stepXValue, stepYValue) = decodeStepFunctionData(f.x[len - 1]);
        change += (to - fromVal) * stepYValue;

        return change / (to - from);
    }

    // first 128 bits is value for x, next 128 bits is value for y
    function encodeStepFunctionData(int128 x, int128 y) internal pure returns(int data) {
        data = int(uint(y) & (POW_2_128 - 1));
        data |= int((uint(x) & (POW_2_128 - 1)) * POW_2_128);
    }

    function decodeStepFunctionData(int val) internal pure returns (int x, int y) {
        y = int(int128(uint(val) & (POW_2_128 - 1)));
        x = int(int128((uint(val) / POW_2_128) & (POW_2_128 - 1)));
    }

    function checkMultOverflow(int x, int y) internal pure returns(bool) {
        if (y == 0) return false;
        return (((x*y) / y) != x);
    }
}
