pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./BPool.sol";
import "./ILatestAnswerGetter.sol";
import "./BNum.sol";

/** @title BalancerSharedPoolPriceProvider
 * @notice Price provider for a balancer pool token
 * It calculates the price using Chainlink as an external price source and the pool's tokens balances using the weigthed arithmetic mean formula.
 * If there is a price deviation, instead of the balances, it uses a weighted geometric mean with the token's weights and constant value function V.
 */

contract BalancerSharedPoolPriceProvider is BNum {
    BPool public pool;
    address[] public tokens;
    uint256[] public weights;
    bool[] public isPeggedToEth;
    uint8[] public decimals;
    ILatestAnswerGetter[] public tokenPriceProviders;
    uint256 public immutable priceDeviation;
    uint256 internal immutable K;
    uint256 internal immutable powerPrecision;
    uint256[][] internal approximationMatrix;

    /**
     * BalancerSharedPoolPriceProvider constructor.
     * @param _pool Balancer pool address.
     * @param _isPeggedToEth For each token, true if it is pegged to eth (token order determined by pool.getFinalTokens()).
     * @param _decimals Number of decimals for each token (token order determined by pool.getFinalTokens()).
     * @param _tokenPriceProviders Chainlinkprice aggregators for each token (token order determined by pool.getFinalTokens()).
     * @param _priceDeviation Threshold of spot prices deviation: 10ˆ16 represents a 1% deviation.
     * @param _K //Constant K = 1 / (w1ˆw1 * .. * wn^wn)
     * @param _powerPrecision //Precision for power math function.
     * @param _approximationMatrix //Approximation matrix for gas optimization.
     */
    constructor(
        BPool _pool,
        bool[] memory _isPeggedToEth,
        uint8[] memory _decimals,
        ILatestAnswerGetter[] memory _tokenPriceProviders,
        uint256 _priceDeviation,
        uint256 _K,
        uint256 _powerPrecision,
        uint256[][] memory _approximationMatrix
    ) public {
        pool = _pool;
        //Get token list
        tokens = pool.getFinalTokens(); //This already checks for pool finalized
        //Get token normalizsed weights
        for (uint256 i = 0; i < tokens.length; i++) {
            weights.push(pool.getNormalizedWeight(tokens[i]));
        }
        isPeggedToEth = _isPeggedToEth;
        decimals = _decimals;
        tokenPriceProviders = _tokenPriceProviders;
        priceDeviation = _priceDeviation;
        K = _K;
        powerPrecision = _powerPrecision;
        approximationMatrix = _approximationMatrix;
    }

    /**
     * Returns the token balance in ethers by multiplying its balance with its price in ethers.
     * @param index Token index.
     */
    function getEthBalanceByToken(uint256 index)
        internal
        view
        returns (uint256)
    {
        uint256 pi = isPeggedToEth[index]
            ? BONE
            : uint256(tokenPriceProviders[index].latestAnswer());
        uint256 missingDecimals = 18 - decimals[index];
        uint256 bi = bmul(
            pool.getBalance(tokens[index]),
            BONE * 10**(missingDecimals)
        );
        return bmul(bi, pi);
    }

    /**
     * Using the matrix approximation, returns a near base and exponentiation result, for num ^ weights[index]
     * @param index Token index.
     * @param num Base to approximate.
     */
    function getClosestBaseAndExponetation(uint256 index, uint256 num)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 k = index + 1;
        for (uint256 i = 0; i < approximationMatrix.length; i++) {
            if (approximationMatrix[i][0] >= num) {
                return (approximationMatrix[i][0], approximationMatrix[i][k]);
            }
        }
        return (0, 0);
    }

    /**
     * Returns true if there is a price deviation.
     * @param ethTotals Balance of each token in ethers.
     */
    function hasDeviation(uint256[] memory ethTotals)
        internal
        view
        returns (bool)
    {
        //Check for a price deviation
        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 o = i + 1; o < tokens.length; o++) {
                uint256 price_deviation = bdiv(
                    bdiv(ethTotals[i], weights[i]),
                    bdiv(ethTotals[o], weights[o])
                );
                if (
                    price_deviation > (BONE + priceDeviation) ||
                    price_deviation < (BONE - priceDeviation)
                ) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Calculates the price of the pool token using the formula of weigthed arithmetic mean.
     * @param ethTotals Balance of each token in ethers.
     */
    function getArithmeticMean(uint256[] memory ethTotals)
        internal
        view
        returns (uint256)
    {
        uint256 totalEth = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            totalEth = badd(totalEth, ethTotals[i]);
        }
        return bdiv(totalEth, pool.totalSupply());
    }

    /**
     * Returns the weigthed token balance in ethers by calculating the balance in eth of the token to the power of its weight.
     * @param index Token index.
     */
    function getWeightedEthBalanceByToken(uint256 index, uint256 ethTotal)
        internal
        view
        returns (uint256)
    {
        uint256 weight = weights[index];
        (uint256 base, uint256 result) = getClosestBaseAndExponetation(
            index,
            ethTotal
        );
        if (base == 0 || ethTotal < MAX_BPOW_BASE) {
            return bpowApprox(ethTotal, weight, BPOW_PRECISION);
        } else {
            return
                bmul(
                    result,
                    bpowApprox(bdiv(ethTotal, base), weight, powerPrecision)
                );
        }
    }

    /**
     * Calculates the price of the pool token using the formula of weighted geometric mean.
     * @param ethTotals Balance of each token in ethers.
     */
    function getWeightedGeometricMean(uint256[] memory ethTotals)
        internal
        view
        returns (uint256)
    {
        uint256 mult = BONE;
        for (uint256 i = 0; i < tokens.length; i++) {
            mult = bmul(mult, getWeightedEthBalanceByToken(i, ethTotals[i]));
        }
        return bdiv(bmul(mult, K), pool.totalSupply());
    }

    /**
     * Returns the pool's token price.
     * It calculates the price using Chainlink as an external price source and the pool's tokens balances using the weigthed arithmetic mean formula.
     * If there is a price deviation, instead of the balances, it uses a weighted geometric mean with the token's weights and constant value function V.
     */
    function latestAnswer() external view returns (uint256) {
        //Ge token balances in eth
        uint256[] memory ethTotals = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            ethTotals[i] = getEthBalanceByToken(i);
        }

        if (hasDeviation(ethTotals)) {
            //Calculte the weighted geometric mean
            return getWeightedGeometricMean(ethTotals);
        } else {
            //Calculte the weigthed arithmetic mean
            return getArithmeticMean(ethTotals);
        }
    }

    /**
     * Returns all tokens.
     */
    function getTokens() external view returns (address[] memory) {
        return tokens;
    }

    /**
     * Returns all tokens's weights.
     */
    function getWeights() external view returns (uint256[] memory) {
        return weights;
    }
}
