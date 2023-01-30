/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^0.5;
pragma experimental ABIEncoderV2;

interface IExchange {
    struct Order {
        address makerAddress;
        address takerAddress;
        address feeRecipientAddress;
        address senderAddress;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        uint256 makerFee;
        uint256 takerFee;
        uint256 expirationTimeSeconds;
        uint256 salt;
        bytes makerAssetData;
        bytes takerAssetData;
        bytes makerFeeAssetData;
        bytes takerFeeAssetData;
    }

    struct OrderInfo {
        uint8 orderStatus;
        bytes32 orderHash;
        uint256 orderTakerAssetFilledAmount;
    }

    function getOrderInfo(Order calldata order)
        external
        view
        returns (OrderInfo memory orderInfo);
}

interface IERC20BridgeSampler {

    /// @dev Query native orders and sample sell orders on multiple DEXes at once.
    /// @param orders Native orders to query.
    /// @param sources Address of each DEX. Passing in an unknown DEX will throw.
    /// @param takerToken The taker token.
    /// @param makerToken The maker token.
    /// @param takerTokenAmounts Taker sell amount for each sample.
    /// @return orderInfos `OrderInfo`s for each order in `orders`.
    /// @return makerTokenAmountsBySource Maker amounts bought for each source at
    ///         each taker token amount. First indexed by source index, then sample
    ///         index.
    function queryOrdersAndSampleSells(
        IExchange.Order[] calldata orders,
        address[] calldata sources,
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (
            IExchange.OrderInfo[] memory orderInfos,
            uint256[][] memory makerTokenAmountsBySource
        );

    /// @dev Query native orders and sample buy orders on multiple DEXes at once.
    /// @param orders Native orders to query.
    /// @param sources Address of each DEX. Passing in an unknown DEX will throw.
    /// @param takerToken The taker token.
    /// @param makerToken The maker token.
    /// @param makerTokenAmounts Maker sell amount for each sample.
    /// @return orderInfos `OrderInfo`s for each order in `orders`.
    /// @return takerTokenAmountsBySource Taker amounts sold for each source at
    ///         each maker token amount. First indexed by source index, then sample
    ///         index.
    function queryOrdersAndSampleBuys(
        IExchange.Order[] calldata orders,
        address[] calldata sources,
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (
            IExchange.OrderInfo[] memory orderInfos,
            uint256[][] memory makerTokenAmountsBySource
        );
}

contract IEth2Dai {
    function getBuyAmount(
        address buyToken,
        address payToken,
        uint256 payAmount
    )
        external
        view
        returns (uint256 buyAmount);

    function getPayAmount(
        address payToken,
        address buyToken,
        uint256 buyAmount
    )
        external
        view
        returns (uint256 payAmount);
}

contract IKyberNetwork {
    function getExpectedRate(
        address fromToken,
        address toToken,
        uint256 fromAmount
    )
        public
        view
        returns (uint256 expectedRate, uint256 slippageRate);
}

contract IERC20Token {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /// @dev send `value` token to `to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Always true if the call has enough gas to complete execution
    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    /// @dev Query total supply of token
    /// @return Total supply of token
    function totalSupply()
        external
        view
        returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function decimals()
        external
        view
        returns (uint8);
}

contract IUniswapExchange {
    function getEthToTokenInputPrice(
        uint256 ethSold
    )
        external
        view
        returns (uint256 tokensBought);

    function getEthToTokenOutputPrice(
        uint256 tokensBought
    )
        external
        view
        returns (uint256 ethSold);

    function getTokenToEthInputPrice(
        uint256 tokensSold
    )
        external
        view
        returns (uint256 ethBought);

    function getTokenToEthOutputPrice(
        uint256 ethBought
    )
        external
        view
        returns (uint256 tokensSold);
}

interface IUniswapExchangeFactory {

    /// @dev Get the exchange for a token.
    /// @param tokenAddress The address of the token contract.
    function getExchange(address tokenAddress)
        external
        view
        returns (IUniswapExchange);
}

contract ERC20BridgeSampler is
    IERC20BridgeSampler
{
    address constant public EXCHANGE_ADDRESS = 0x080bf510FCbF18b91105470639e9561022937712; // V2
    address constant public ETH2DAI_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;
    address constant public UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address constant public KYBER_NETWORK_PROXY_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address constant public WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant public KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function queryOrdersAndSampleSells(
        IExchange.Order[] memory orders,
        address[] memory sources,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (
            IExchange.OrderInfo[] memory orderInfos,
            uint256[][] memory makerTokenAmountsBySource
        )
    {
        orderInfos = queryOrders(orders);
        makerTokenAmountsBySource = sampleSells(
            sources,
            takerToken,
            makerToken,
            takerTokenAmounts
        );
    }

    function queryOrdersAndSampleBuys(
        IExchange.Order[] memory orders,
        address[] memory sources,
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (
            IExchange.OrderInfo[] memory orderInfos,
            uint256[][] memory makerTokenAmountsBySource
        )
    {
        orderInfos = queryOrders(orders);
        makerTokenAmountsBySource = sampleBuys(
            sources,
            takerToken,
            makerToken,
            makerTokenAmounts
        );
    }

    function queryOrders(IExchange.Order[] memory orders)
        public
        view
        returns (IExchange.OrderInfo[] memory orderInfos)
    {
        uint256 numOrders = orders.length;
        orderInfos = new IExchange.OrderInfo[](numOrders);
        for (uint256 i = 0; i < numOrders; i++) {
            orderInfos[i] = IExchange(EXCHANGE_ADDRESS).getOrderInfo(orders[i]);
        }
    }

    function sampleSells(
        address[] memory sources,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[][] memory makerTokenAmountsBySource)
    {
        uint256 numSources = sources.length;
        makerTokenAmountsBySource = new uint256[][](numSources);
        for (uint256 i = 0; i < numSources; i++) {
            makerTokenAmountsBySource[i] = _sampleSellSource(
                sources[i],
                takerToken,
                makerToken,
                takerTokenAmounts
            );
        }
    }

    function sampleBuys(
        address[] memory sources,
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[][] memory takerTokenAmountsBySource)
    {
        uint256 numSources = sources.length;
        takerTokenAmountsBySource = new uint256[][](numSources);
        for (uint256 i = 0; i < numSources; i++) {
            takerTokenAmountsBySource[i] = _sampleBuySource(
                sources[i],
                takerToken,
                makerToken,
                makerTokenAmounts
            );
        }
    }

    function sampleSellFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        address _takerToken = takerToken == WETH_ADDRESS ? KYBER_ETH_ADDRESS : takerToken;
        address _makerToken = makerToken == WETH_ADDRESS ? KYBER_ETH_ADDRESS : makerToken;
        uint256 takerTokenDecimals = IERC20Token(takerToken).decimals();
        uint256 makerTokenDecimals = IERC20Token(makerToken).decimals();
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (uint256 rate,) = IKyberNetwork(KYBER_NETWORK_PROXY_ADDRESS).getExpectedRate(
                _takerToken,
                _makerToken,
                takerTokenAmounts[i]
            );
            makerTokenAmounts[i] =
                rate *
                takerTokenAmounts[i] *
                makerTokenDecimals /
                (10 ** 18 * takerTokenDecimals);
        }
    }

    function sampleSellFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            makerTokenAmounts[i] = IEth2Dai(ETH2DAI_ADDRESS).getBuyAmount(
                makerToken,
                takerToken,
                takerTokenAmounts[i]
            );
        }
    }

    function sampleBuyFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            takerTokenAmounts[i] = IEth2Dai(ETH2DAI_ADDRESS).getPayAmount(
                takerToken,
                makerToken,
                makerTokenAmounts[i]
            );
        }
    }

    function sampleSellFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        IUniswapExchange takerTokenExchange = takerToken == WETH_ADDRESS ?
            IUniswapExchange(0) :
            IUniswapExchangeFactory(UNISWAP_EXCHANGE_FACTORY_ADDRESS).getExchange(takerToken);
        IUniswapExchange makerTokenExchange = makerToken == WETH_ADDRESS ?
            IUniswapExchange(0) :
            IUniswapExchangeFactory(UNISWAP_EXCHANGE_FACTORY_ADDRESS).getExchange(makerToken);
        for (uint256 i = 0; i < numSamples; i++) {
            if (makerToken == WETH_ADDRESS) {
                makerTokenAmounts[i] = takerTokenExchange.getTokenToEthInputPrice(
                    takerTokenAmounts[i]
                );
            } else if (takerToken == WETH_ADDRESS) {
                makerTokenAmounts[i] = makerTokenExchange.getEthToTokenInputPrice(
                    takerTokenAmounts[i]
                );
            } else {
                uint256 ethBought = takerTokenExchange.getTokenToEthInputPrice(
                    takerTokenAmounts[i]
                );
                makerTokenAmounts[i] = makerTokenExchange.getEthToTokenInputPrice(
                    ethBought
                );
            }
        }
    }

    function sampleBuyFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        IUniswapExchange takerTokenExchange = takerToken == WETH_ADDRESS ?
            IUniswapExchange(0) :
            IUniswapExchangeFactory(UNISWAP_EXCHANGE_FACTORY_ADDRESS).getExchange(takerToken);
        IUniswapExchange makerTokenExchange = makerToken == WETH_ADDRESS ?
            IUniswapExchange(0) :
            IUniswapExchangeFactory(UNISWAP_EXCHANGE_FACTORY_ADDRESS).getExchange(makerToken);
        for (uint256 i = 0; i < numSamples; i++) {
            if (makerToken == WETH_ADDRESS) {
                takerTokenAmounts[i] = takerTokenExchange.getTokenToEthOutputPrice(
                    makerTokenAmounts[i]
                );
            } else if (takerToken == WETH_ADDRESS) {
                takerTokenAmounts[i] = makerTokenExchange.getEthToTokenOutputPrice(
                    makerTokenAmounts[i]
                );
            } else {
                uint256 ethSold = makerTokenExchange.getEthToTokenOutputPrice(
                    makerTokenAmounts[i]
                );
                takerTokenAmounts[i] = takerTokenExchange.getTokenToEthOutputPrice(
                    ethSold
                );
            }
        }
    }

    function _sampleSellSource(
        address source,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        private
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        if (source == ETH2DAI_ADDRESS) {
            return sampleSellFromEth2Dai(takerToken, makerToken, takerTokenAmounts);
        }
        if (source == UNISWAP_EXCHANGE_FACTORY_ADDRESS) {
            return sampleSellFromUniswap(takerToken, makerToken, takerTokenAmounts);
        }
        if (source == KYBER_NETWORK_PROXY_ADDRESS) {
            return sampleSellFromKyberNetwork(takerToken, makerToken, takerTokenAmounts);
        }
        revert("UNSUPPORTED_SOURCE");
    }

    function _sampleBuySource(
        address source,
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        private
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        if (source == ETH2DAI_ADDRESS) {
            return sampleBuyFromEth2Dai(takerToken, makerToken, makerTokenAmounts);
        }
        if (source == UNISWAP_EXCHANGE_FACTORY_ADDRESS) {
            return sampleBuyFromUniswap(takerToken, makerToken, takerTokenAmounts);
        }
        revert("UNSUPPORTED_SOURCE");
    }
}