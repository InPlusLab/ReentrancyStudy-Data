/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @kyber.network/utils-sc/contracts/IERC20Ext.sol

pragma solidity 0.6.6;



/**
 * @dev Interface extending ERC20 standard to include decimals() as
 *      it is optional in the OpenZeppelin IERC20 interface.
 */
interface IERC20Ext is IERC20 {
    /**
     * @dev This function is required as Kyber requires to interact
     *      with token.decimals() with many of its operations.
     */
    function decimals() external view returns (uint8 digits);
}

// File: @kyber.network/utils-sc/contracts/Utils.sol

pragma solidity 0.6.6;



/**
 * @title Kyber utility file
 * mostly shared constants and rate calculation helpers
 * inherited by most of kyber contracts.
 * previous utils implementations are for previous solidity versions.
 */
contract Utils {
    /// Declared constants below to be used in tandem with
    /// getDecimalsConstant(), for gas optimization purposes
    /// which return decimals from a constant list of popular
    /// tokens.
    IERC20Ext internal constant ETH_TOKEN_ADDRESS = IERC20Ext(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    IERC20Ext internal constant USDT_TOKEN_ADDRESS = IERC20Ext(
        0xdAC17F958D2ee523a2206206994597C13D831ec7
    );
    IERC20Ext internal constant DAI_TOKEN_ADDRESS = IERC20Ext(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    IERC20Ext internal constant USDC_TOKEN_ADDRESS = IERC20Ext(
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    );
    IERC20Ext internal constant WBTC_TOKEN_ADDRESS = IERC20Ext(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    IERC20Ext internal constant KNC_TOKEN_ADDRESS = IERC20Ext(
        0xdd974D5C2e2928deA5F71b9825b8b646686BD200
    );
    uint256 public constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20Ext => uint256) internal decimals;

    /// @dev Sets the decimals of a token to storage if not already set, and returns
    ///      the decimals value of the token. Prefer using this function over
    ///      getDecimals(), to avoid forgetting to set decimals in local storage.
    /// @param token The token type
    /// @return tokenDecimals The decimals of the token
    function getSetDecimals(IERC20Ext token) internal returns (uint256 tokenDecimals) {
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }
    }

    /// @dev Get the balance of a user
    /// @param token The token type
    /// @param user The user's address
    /// @return The balance
    function getBalance(IERC20Ext token, address user) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    /// @dev Get the decimals of a token, read from the constant list, storage,
    ///      or from token.decimals(). Prefer using getSetDecimals when possible.
    /// @param token The token type
    /// @return tokenDecimals The decimals of the token
    function getDecimals(IERC20Ext token) internal view returns (uint256 tokenDecimals) {
        // return token decimals if has constant value
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        // handle case where token decimals is not a declared decimal constant
        tokenDecimals = decimals[token];
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        return (tokenDecimals > 0) ? tokenDecimals : token.decimals();
    }

    function calcDestAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    /// @dev save storage access by declaring token decimal constants
    /// @param token The token type
    /// @return token decimals
    function getDecimalsConstant(IERC20Ext token) internal pure returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return ETH_DECIMALS;
        } else if (token == USDT_TOKEN_ADDRESS) {
            return 6;
        } else if (token == DAI_TOKEN_ADDRESS) {
            return 18;
        } else if (token == USDC_TOKEN_ADDRESS) {
            return 6;
        } else if (token == WBTC_TOKEN_ADDRESS) {
            return 8;
        } else if (token == KNC_TOKEN_ADDRESS) {
            return 18;
        } else {
            return 0;
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

// File: contracts/sol6/IConversionRates.sol

pragma solidity 0.6.6;



interface IConversionRates {

    function recordImbalance(
        IERC20Ext token,
        int buyAmount,
        uint256 rateUpdateBlock,
        uint256 currentBlock
    ) external;

    function getRate(
        IERC20Ext token,
        uint256 currentBlockNumber,
        bool buy,
        uint256 qty
    ) external view returns(uint256);
}

// File: contracts/sol6/IKyberSanity.sol

pragma solidity 0.6.6;


interface IKyberSanity {
    function getSanityRate(IERC20Ext src, IERC20Ext dest) external view returns (uint256);
}

// File: contracts/sol6/IKyberReserve.sol

pragma solidity 0.6.6;



interface IKyberReserve {
    function trade(
        IERC20Ext srcToken,
        uint256 srcAmount,
        IERC20Ext destToken,
        address payable destAddress,
        uint256 conversionRate,
        bool validate
    ) external payable returns (bool);

    function getConversionRate(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcQty,
        uint256 blockNumber
    ) external view returns (uint256);
}

// File: contracts/sol6/helpers/KyberRateQueryReserves.sol

pragma solidity 0.6.6;






interface IKyberReserveExt is IKyberReserve {
    function conversionRatesContract() external view returns (IConversionRates);
    function sanityRatesContract() external view returns (IKyberSanity);
}

contract KyberRateQueryReserves is Utils {

    function getRatesWithEth(
        IKyberReserveExt reserve,
        IERC20Ext[] calldata tokens,
        uint256 weiAmount
    )
        external view returns(uint256[] memory sellRates, uint256[] memory buyRates)
    {
        uint256 numTokens = tokens.length;

        buyRates = new uint256[](numTokens);
        sellRates = new uint256[](numTokens);
        for (uint256 i = 0; i < numTokens; i++) {
            (buyRates[i], sellRates[i], , , ) = getRateWithEth(reserve, tokens[i], weiAmount);
        }
    }

    function getRatesWithToken(
        IKyberReserveExt reserve,
        IERC20Ext[] calldata tokens,
        uint256 tweiAmount
    )
        external view 
        returns(uint256[] memory sellRates, uint256[] memory buyRates)
    {
        uint256 numTokens = tokens.length;

        buyRates = new uint256[](numTokens);
        sellRates = new uint256[](numTokens);
        for (uint256 i = 0; i < numTokens; i++) {
            (buyRates[i], sellRates[i], ,  , ) = getRateWithToken(reserve, tokens[i], tweiAmount);
        }
    }

    function getReserveRates(
        IKyberReserveExt reserve,
        IERC20Ext[] calldata srcs,
        IERC20Ext[] calldata dests
    )
        external view returns(uint256[] memory pricingRates, uint256[] memory sanityRates)
    {
        require(srcs.length == dests.length, "srcs length != dests");

        pricingRates = new uint256[](srcs.length);
        sanityRates = new uint256[](srcs.length);
        IKyberSanity sanityRateContract;
        IConversionRates conversionRateContract;

        try reserve.sanityRatesContract() returns (IKyberSanity sanityContract) {
            sanityRateContract = sanityContract;
        } catch {
            revert("no sanityRate contract");
        }

        try reserve.conversionRatesContract() returns (IConversionRates ratesContract) {
            conversionRateContract = ratesContract;
        } catch {
            revert("no conversionRate contract");
        }

        for (uint256 i = 0 ; i < srcs.length ; i++) {

            if (reserve.sanityRatesContract() != IKyberSanity(0x0)) {
                sanityRates[i] = reserve.sanityRatesContract().getSanityRate(srcs[i], dests[i]);
            }

            pricingRates[i] = reserve.conversionRatesContract().getRate(
                srcs[i] == ETH_TOKEN_ADDRESS ? dests[i] : srcs[i],
                block.number,
                srcs[i] == ETH_TOKEN_ADDRESS ? true : false,
                0);
        }
    }

    function getRateWithEth(IKyberReserveExt reserve, IERC20Ext token, uint256 weiAmount)
        public view 
        returns(
            uint256 reserveSellRate,
            uint256 reserveBuyRate,
            uint256 pricingSellRate,
            uint256 pricingBuyRate,
            uint256 tweiAmount
        )
    {
        IConversionRates conversionRate = reserve.conversionRatesContract();

        reserveBuyRate = IKyberReserveExt(reserve).getConversionRate(
                    ETH_TOKEN_ADDRESS,
                    token,
                    weiAmount,
                    block.number
                );

        pricingBuyRate = conversionRate.getRate(token, block.number, true, weiAmount);

        tweiAmount = calcDestAmount(
            ETH_TOKEN_ADDRESS, 
            token, 
            weiAmount, 
            reserveBuyRate == 0 ? pricingBuyRate : reserveBuyRate);

        reserveSellRate = reserve.getConversionRate(
                    token,
                    ETH_TOKEN_ADDRESS,
                    tweiAmount,
                    block.number
                );
                
        pricingSellRate = conversionRate.getRate(token, block.number, false, tweiAmount);
    }

    function getRateWithToken(IKyberReserveExt reserve, IERC20Ext token, uint256 tweiAmount)
        public view 
        returns(
            uint256 reserveBuyRate, 
            uint256 reserveSellRate, 
            uint256 pricingBuyRate,
            uint256 pricingSellRate,
            uint256 weiAmount
        ) 
    {
        IConversionRates conversionRate = reserve.conversionRatesContract();

        reserveSellRate = IKyberReserveExt(reserve).getConversionRate(
                token,
                ETH_TOKEN_ADDRESS,
                tweiAmount,
                block.number
            );

        pricingSellRate = conversionRate.getRate(token, block.number, false, tweiAmount);

        weiAmount = calcDestAmount(
                token, 
                ETH_TOKEN_ADDRESS, 
                tweiAmount,
                reserveSellRate == 0 ? pricingSellRate : reserveSellRate
            );

        reserveBuyRate = IKyberReserveExt(reserve).getConversionRate(
                ETH_TOKEN_ADDRESS,
                token,
                weiAmount,
                block.number
            );

        pricingBuyRate = conversionRate.getRate(token, block.number, true, weiAmount);
    }
}