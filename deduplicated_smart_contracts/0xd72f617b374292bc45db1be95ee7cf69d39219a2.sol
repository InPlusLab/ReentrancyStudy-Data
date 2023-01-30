/**
 *Submitted for verification at Etherscan.io on 2020-04-25
*/

pragma solidity ^0.4.24;

contract Ownable {
    address public owner;
    address public pendingOwner;
    mapping(address => bool) public managers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetManager(address indexed owner, address indexed newManager);
    event RemoveManager(address indexed owner, address indexed previousManager);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner: non-owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than a manager.
     */
    modifier onlyManager() {
        require(managers[msg.sender], "onlyManager: non-manager");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns true if the user(`account`) is the a manager.
     */
    function isManager(address _account) public view returns (bool) {
        return managers[_account];
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner_`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != owner, "transferOwnership: the same owner.");
        require(pendingOwner != _newOwner, "transferOwnership : the same pendingOwner.");
        pendingOwner = _newOwner;
    }

    /**
     * @dev Accepts ownership of the contract.
     * Can only be called by the settting new owner(`pendingOwner`).
     */
    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "acceptOwnership: only new owner do this.");
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    /**
     * @dev Set a new user(`account`) as a manager.
     * Can only be called by the current owner.
     */
    function setManager(address _account) external onlyOwner {
        require(_account != address(0), "setManager: account cannot be a zero address.");
        require(!isManager(_account), "setManager: Already a manager address.");
        managers[_account] = true;
        emit SetManager(owner, _account);
    }

    /**
     * @dev Remove a previous manager account.
     * Can only be called by the current owner.
     */
    function removeManager(address _account) external onlyOwner {
        require(_account != address(0), "removeManager: _account cannot be a zero address.");
        require(isManager(_account), "removeManager: Not an admin address.");
        managers[_account] = false;
        emit RemoveManager(owner, _account);
    }
}

contract ErrorReporter {

    enum Error {
        NO_ERROR,
        OPAQUE_ERROR, // To be used when reporting errors from upgradeable contracts; the opaque code should be given as `detail` in the `Failure` event
        UNAUTHORIZED,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        DIVISION_BY_ZERO,
        BAD_INPUT,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_TRANSFER_FAILED,
        MARKET_NOT_SUPPORTED,
        SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_RATE_CALCULATION_FAILED,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_OUT_FAILED,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BALANCE,
        INVALID_COLLATERAL_RATIO,
        MISSING_ASSET_PRICE,
        EQUITY_INSUFFICIENT_BALANCE,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        ASSET_NOT_PRICED,
        INVALID_LIQUIDATION_DISCOUNT,
        INVALID_COMBINED_RISK_PARAMETERS,
        ZERO_ORACLE_ADDRESS,
        CONTRACT_PAUSED
    }
}

contract CarefulMath is ErrorReporter {

    /**
    * @dev Multiplies two numbers, returns an error on overflow.
    */
    function mul(uint a, uint b) internal pure returns (Error, uint) {
        if (a == 0) {
            return (Error.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (Error.INTEGER_OVERFLOW, 0);
        } else {
            return (Error.NO_ERROR, c);
        }
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint a, uint b) internal pure returns (Error, uint) {
        if (b == 0) {
            return (Error.DIVISION_BY_ZERO, 0);
        }

        return (Error.NO_ERROR, a / b);
    }

    /**
    * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint a, uint b) internal pure returns (Error, uint) {
        if (b <= a) {
            return (Error.NO_ERROR, a - b);
        } else {
            return (Error.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
    * @dev Adds two numbers, returns an error on overflow.
    */
    function add(uint a, uint b) internal pure returns (Error, uint) {
        uint c = a + b;

        if (c >= a) {
            return (Error.NO_ERROR, c);
        } else {
            return (Error.INTEGER_OVERFLOW, 0);
        }
    }

    /**
    * @dev add a and b and then subtract c
    */
    function addThenSub(uint a, uint b, uint c) internal pure returns (Error, uint) {
        (Error err0, uint sum) = add(a, b);

        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        return sub(sum, c);
    }
}

contract Exponential is CarefulMath {

    // TODO: We may wish to put the result of 10**18 here instead of the expression.
    // Per https://solidity.readthedocs.io/en/latest/contracts.html#constant-state-variables
    // the optimizer MAY replace the expression 10**18 with its calculated value.
    uint constant expScale = 10**18;

    // See TODO on expScale
    uint constant halfExpScale = expScale/2;

    struct Exp {
        uint mantissa;
    }

    uint constant mantissaOne = 10**18;
    uint constant mantissaOneTenth = 10**17;

    /**
    * @dev Creates an exponential from numerator and denominator values.
    *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
    *            or if `denom` is zero.
    */
    function getExp(uint num, uint denom) pure internal returns (Error, Exp memory) {
        (Error err0, uint scaledNumerator) = mul(num, expScale);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (Error err1, uint rational) = div(scaledNumerator, denom);
        if (err1 != Error.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
    * @dev Adds two exponentials, returning a new exponential.
    */
    function addExp(Exp memory a, Exp memory b) pure internal returns (Error, Exp memory) {
        (Error error, uint result) = add(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
    * @dev Subtracts two exponentials, returning a new exponential.
    */
    function subExp(Exp memory a, Exp memory b) pure internal returns (Error, Exp memory) {
        (Error error, uint result) = sub(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
    * @dev Multiply an Exp by a scalar, returning a new Exp.
    */
    function mulScalar(Exp memory a, uint scalar) pure internal returns (Error, Exp memory) {
        (Error err0, uint scaledMantissa) = mul(a.mantissa, scalar);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
    * @dev Divide an Exp by a scalar, returning a new Exp.
    */
    function divScalar(Exp memory a, uint scalar) pure internal returns (Error, Exp memory) {
        (Error err0, uint descaledMantissa) = div(a.mantissa, scalar);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
    * @dev Divide a scalar by an Exp, returning a new Exp.
    */
    function divScalarByExp(uint scalar, Exp divisor) pure internal returns (Error, Exp memory) {
        /*
            We are doing this as:
            getExp(mul(expScale, scalar), divisor.mantissa)

            How it works:
            Exp = a / b;
            Scalar = s;
            `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (Error err0, uint numerator) = mul(expScale, scalar);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
    * @dev Multiplies two exponentials, returning a new exponential.
    */
    function mulExp(Exp memory a, Exp memory b) pure internal returns (Error, Exp memory) {

        (Error err0, uint doubleScaledProduct) = mul(a.mantissa, b.mantissa);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (Error err1, uint doubleScaledProductWithHalfScale) = add(halfExpScale, doubleScaledProduct);
        if (err1 != Error.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (Error err2, uint product) = div(doubleScaledProductWithHalfScale, expScale);
        // The only error `div` can return is Error.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == Error.NO_ERROR);

        return (Error.NO_ERROR, Exp({mantissa: product}));
    }

    /**
      * @dev Divides two exponentials, returning a new exponential.
      *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
      *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
      */
    function divExp(Exp memory a, Exp memory b) pure internal returns (Error, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }

    /**
      * @dev Truncates the given exp to a whole number value.
      *      For example, truncate(Exp{mantissa: 15 * (10**18)}) = 15
      */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / 10**18;
    }

    /**
      * @dev Checks if first Exp is less than second Exp.
      */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa; //TODO: Add some simple tests and this in another PR yo.
    }

    /**
      * @dev Checks if left Exp <= right Exp.
      */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
      * @dev returns true if Exp is exactly zero
      */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }
}

interface ILendFMe {
	
	function collateralRatio() external view returns (uint);
	
	function getCollateralMarketsLength() external view returns (uint);
	function collateralMarkets(uint marketIndex) external view returns (address);
	function markets(address asset) external view returns (bool, uint, address, uint, uint, uint, uint, uint, uint);
	function assetPrices(address asset) external view returns (uint);
	
	function supplyBalances(address account, address asset) external view returns (uint, uint);
	function borrowBalances(address account, address asset) external view returns (uint, uint);
}

contract LendfMeData is Ownable, Exponential {
    
    address public owner;
    
    ILendFMe public lendfMe;
    address public assetScalar;
    uint public blockPaused = 9900772;
    
    struct Market {
        bool isSupported;
        uint blockNumber;
        address interestRateModel;

        uint totalSupply;
        uint supplyRateMantissa;
        uint supplyIndex;

        uint totalBorrows;
        uint borrowRateMantissa;
        uint borrowIndex;
    }
    
    struct Balance {
        uint principal;
        uint interestIndex;
    }

    constructor(address _lendfMe, address asset) public {
        lendfMe = ILendFMe(_lendfMe);
        assetScalar = asset;
        owner = msg.sender;
        managers[msg.sender] = true;
    }
    
    function setLendfMe(address _lendfMe) public onlyManager {
        lendfMe = ILendFMe(_lendfMe);
    }
    
    function setAssetScalar(address _asset) public onlyManager {
        assetScalar = _asset;
    }
    
    function setBlockPaused(uint _blockPaused) public onlyManager {
        blockPaused = _blockPaused;
    }

    function calculateInterestIndex(uint startingInterestIndex, uint interestRateMantissa, uint blockStart, uint blockEnd) pure public returns (Error, uint) {

        // Get the block delta
        (Error err0, uint blockDelta) = sub(blockEnd, blockStart);
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        // Scale the interest rate times number of blocks
        // Note: Doing Exp construction inline to avoid `CompilerError: Stack too deep, try removing local variables.`
        (Error err1, Exp memory blocksTimesRate) = mulScalar(Exp({mantissa: interestRateMantissa}), blockDelta);
        if (err1 != Error.NO_ERROR) {
            return (err1, 0);
        }

        // Add one to that result (which is really Exp({mantissa: expScale}) which equals 1.0)
        (Error err2, Exp memory onePlusBlocksTimesRate) = addExp(blocksTimesRate, Exp({mantissa: mantissaOne}));
        if (err2 != Error.NO_ERROR) {
            return (err2, 0);
        }

        // Then scale that accumulated interest by the old interest index to get the new interest index
        (Error err3, Exp memory newInterestIndexExp) = mulScalar(onePlusBlocksTimesRate, startingInterestIndex);
        if (err3 != Error.NO_ERROR) {
            return (err3, 0);
        }

        // Finally, truncate the interest index. This works only if interest index starts large enough
        // that is can be accurately represented with a whole number.
        return (Error.NO_ERROR, truncate(newInterestIndexExp));
    }

    function calculateBalance(uint startingBalance, uint interestIndexStart, uint interestIndexEnd) pure public returns (Error, uint) {
        if (startingBalance == 0) {
            // We are accumulating interest on any previous balance; if there's no previous balance, then there is
            // nothing to accumulate.
            return (Error.NO_ERROR, 0);
        }
        (Error err0, uint balanceTimesIndex) = mul(startingBalance, interestIndexEnd);
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        return div(balanceTimesIndex, interestIndexStart);
    }

    function getSupplyBalance(address account, address asset, uint blockEnd) view public returns (uint) {
        Error err;
        uint newSupplyIndex;
        uint userSupplyCurrent;

        Market memory market;
        (, market.blockNumber, , , , , , market.borrowRateMantissa, market.borrowIndex) = lendfMe.markets(asset);
        Balance memory supplyBalance;
        (supplyBalance.principal, supplyBalance.interestIndex) = lendfMe.borrowBalances(account, asset);

        // Calculate the newSupplyIndex, needed to calculate user's supplyCurrent
        (err, newSupplyIndex) = calculateInterestIndex(market.supplyIndex, market.supplyRateMantissa, market.blockNumber, blockEnd);
        require(err == Error.NO_ERROR);

        // Use newSupplyIndex and stored principal to calculate the accumulated balance
        (err, userSupplyCurrent) = calculateBalance(supplyBalance.principal, supplyBalance.interestIndex, newSupplyIndex);
        require(err == Error.NO_ERROR);

        return userSupplyCurrent;
    }
    
    function getSupplyBalance(address account, address asset) view public returns (uint) {
        return getSupplyBalance(account, asset, blockPaused);
    }
    
    function getBorrowBalance(address account, address asset, uint blockEnd) view public returns (uint) {
        Error err;
        uint newBorrowIndex;
        uint userBorrowCurrent;

        Market memory market;
        (, market.blockNumber, , , , , , market.borrowRateMantissa, market.borrowIndex) = lendfMe.markets(asset);
        Balance memory borrowBalance;
        (borrowBalance.principal, borrowBalance.interestIndex) = lendfMe.borrowBalances(account, asset);

        // Calculate the newBorrowIndex, needed to calculate user's borrowCurrent
        (err, newBorrowIndex) = calculateInterestIndex(market.borrowIndex, market.borrowRateMantissa, market.blockNumber, blockEnd);
        require(err == Error.NO_ERROR);

        // Use newBorrowIndex and stored principal to calculate the accumulated balance
        (err, userBorrowCurrent) = calculateBalance(borrowBalance.principal, borrowBalance.interestIndex, newBorrowIndex);
        require(err == Error.NO_ERROR);

        return userBorrowCurrent;
    }
    
    function getBorrowBalance(address account, address asset) view public returns (uint) {
        return getBorrowBalance(account, asset, blockPaused);
    }

    
    struct AccountValueLocalVars {
        address assetAddress;
        uint collateralMarketsLength;

        uint newSupplyIndex;
        uint userSupplyCurrent;
        Exp supplyTotalValue;
        Exp sumSupplies;

        uint newBorrowIndex;
        uint userBorrowCurrent;
        Exp borrowTotalValue;
        Exp sumBorrows;
    }
    
    function calculateAccountValuesInternal(address userAddress) public view returns (Error, uint, uint) {
        
        AccountValueLocalVars memory localResults; // Re-used for all intermediate results
        localResults.sumSupplies = Exp({mantissa: 0});
        localResults.sumBorrows = Exp({mantissa: 0});
        Error err; // Re-used for all intermediate errors
        localResults.collateralMarketsLength = lendfMe.getCollateralMarketsLength();
        Market memory currentMarket;
        Balance memory supplyBalance;
        Balance memory borrowBalance;

        for (uint i = 0; i < localResults.collateralMarketsLength; i++) {
            localResults.assetAddress = lendfMe.collateralMarkets(i);
            (
                , 
                currentMarket.blockNumber, 
                , 
                , currentMarket.supplyRateMantissa, 
                currentMarket.supplyIndex, 
                , currentMarket.borrowRateMantissa, 
                currentMarket.borrowIndex
            ) = lendfMe.markets(localResults.assetAddress);
            (supplyBalance.principal, supplyBalance.interestIndex) = lendfMe.supplyBalances(userAddress, localResults.assetAddress);
            (borrowBalance.principal, borrowBalance.interestIndex) = lendfMe.borrowBalances(userAddress, localResults.assetAddress);

            if (supplyBalance.principal > 0) {
                // We calculate the newSupplyIndex and user¡¯s supplyCurrent (includes interest)
                (err, localResults.newSupplyIndex) = calculateInterestIndex(currentMarket.supplyIndex, currentMarket.supplyRateMantissa, currentMarket.blockNumber, blockPaused);
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }

                (err, localResults.userSupplyCurrent) = calculateBalance(supplyBalance.principal, supplyBalance.interestIndex, localResults.newSupplyIndex);
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }

                // We have the user's supply balance with interest so let's multiply by the asset price to get the total value
                (err, localResults.supplyTotalValue) = getPriceForAssetAmount(localResults.assetAddress, localResults.userSupplyCurrent); // supplyCurrent * oraclePrice = supplyValueInEth
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }

                // Add this to our running sum of supplies
                (err, localResults.sumSupplies) = addExp(localResults.supplyTotalValue, localResults.sumSupplies);
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }
            }

            if (borrowBalance.principal > 0) {
                // We perform a similar actions to get the user's borrow balance
                (err, localResults.newBorrowIndex) = calculateInterestIndex(currentMarket.borrowIndex, currentMarket.borrowRateMantissa, currentMarket.blockNumber, blockPaused);
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }

                (err, localResults.userBorrowCurrent) = calculateBalance(borrowBalance.principal, borrowBalance.interestIndex, localResults.newBorrowIndex);
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }

                // In the case of borrow, we multiply the borrow value by the collateral ratio
                (err, localResults.borrowTotalValue) = getPriceForAssetAmount(localResults.assetAddress, localResults.userBorrowCurrent); // ( borrowCurrent* oraclePrice * collateralRatio) = borrowTotalValueInEth
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }

                // Add this to our running sum of borrows
                (err, localResults.sumBorrows) = addExp(localResults.borrowTotalValue, localResults.sumBorrows);
                if (err != Error.NO_ERROR) {
                    return (err, 0, 0);
                }
            }
        }
        
        return (Error.NO_ERROR, localResults.sumSupplies.mantissa, localResults.sumBorrows.mantissa);
    }

    function calculateAccountValues(address userAddress) public view returns (uint, uint) {
        (Error err, uint supplyValue, uint borrowValue) = calculateAccountValuesInternal(userAddress);
        if (err != Error.NO_ERROR) {

            return (0, 0);
        }

        return (supplyValue, borrowValue);
    }
    
    
    function getAccountLiquidity(address account) public view returns (int) {
        (Error err, Exp memory accountLiquidity, Exp memory accountShortfall) = calculateAccountLiquidity(account);
        require(err == Error.NO_ERROR);

        if (isZeroExp(accountLiquidity)) {
            return -1 * int(truncate(accountShortfall));
        } else {
            return int(truncate(accountLiquidity));
        }
    }
    
    function calculateAccountLiquidity(address userAddress) internal view returns (Error, Exp memory, Exp memory) {
        Error err;
        uint sumSupplyValuesMantissa;
        uint sumBorrowValuesMantissa;
        (err, sumSupplyValuesMantissa, sumBorrowValuesMantissa) = calculateAccountValuesInternal(userAddress);
        if (err != Error.NO_ERROR) {
            return(err, Exp({mantissa: 0}), Exp({mantissa: 0}));
        }

        Exp memory result;
        
        Exp memory sumSupplyValuesFinal = Exp({mantissa: sumSupplyValuesMantissa});
        Exp memory sumBorrowValuesFinal; // need to apply collateral ratio

        (err, sumBorrowValuesFinal) = mulExp(Exp({mantissa: lendfMe.collateralRatio()}), Exp({mantissa: sumBorrowValuesMantissa}));
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
        }

        // if sumSupplies < sumBorrows, then the user is under collateralized and has account shortfall.
        // else the user meets the collateral ratio and has account liquidity.
        if (lessThanExp(sumSupplyValuesFinal, sumBorrowValuesFinal)) {
            // accountShortfall = borrows - supplies
            (err, result) = subExp(sumBorrowValuesFinal, sumSupplyValuesFinal);
            assert(err == Error.NO_ERROR); // Note: we have checked that sumBorrows is greater than sumSupplies directly above, therefore `subExp` cannot fail.

            return (Error.NO_ERROR, Exp({mantissa: 0}), result);
        } else {
            // accountLiquidity = supplies - borrows
            (err, result) = subExp(sumSupplyValuesFinal, sumBorrowValuesFinal);
            assert(err == Error.NO_ERROR); // Note: we have checked that sumSupplies is greater than sumBorrows directly above, therefore `subExp` cannot fail.

            return (Error.NO_ERROR, result, Exp({mantissa: 0}));
        }
    }
    
    
    function getPriceForAssetAmount(address asset, uint assetAmount) internal view returns (Error, Exp memory)  {
        (Error err, Exp memory assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }

        if (isZeroExp(assetPrice)) {
            return (Error.MISSING_ASSET_PRICE, Exp({mantissa: 0}));
        }

        return mulScalar(assetPrice, assetAmount); // assetAmountWei * oraclePrice = assetValueInEth
    }

    function fetchAssetPrice(address asset) internal view returns (Error, Exp memory) {
        return (Error.NO_ERROR, Exp({mantissa: lendfMe.assetPrices(asset)}));
    }

    function assetPrices(address asset) public view returns (uint) {
        (Error err, Exp memory result) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return 0;
        }
        return result.mantissa;
    }
    
    function getUSDForEth(uint ethValue) view public returns (uint) {
        (, uint USDValue) = div(ethValue, lendfMe.assetPrices(assetScalar));
        return USDValue;
    }
    
    function getAssetUSDForValue(address asset, uint amount) view public returns (uint) {
        uint balanceUSD;
        (, balanceUSD) = mul(amount, lendfMe.assetPrices(asset));
        return getUSDForEth(balanceUSD);
    }
    
    function getUSD(address asset, uint amount) view public returns (uint) {
        return getAssetUSDForValue(asset, amount);
    }
    
    function getSupplyBalanceUSD(address account, address asset) view public returns (uint) {
        uint amount = getSupplyBalance(account, asset);
        return getUSD(asset, amount);
    }
    
    function getBorrowBalanceUSD(address account, address asset) view public returns (uint) {
        uint amount = getBorrowBalance(account, asset);
        return getUSD(asset, amount);
    }
    
    function calculateAccountUSD(address account) view public returns (uint, uint) {
        (uint supplyValue, uint borrowValue) = calculateAccountValues(account);
        return (getUSDForEth(supplyValue), getUSDForEth(borrowValue));
    }
    
    function getLiquidity(address account) public view returns (int) {
        (uint supplyValue, uint borrowValue) = calculateAccountValues(account);
        return int(getUSDForEth(supplyValue) - getUSDForEth(borrowValue));
    }
}