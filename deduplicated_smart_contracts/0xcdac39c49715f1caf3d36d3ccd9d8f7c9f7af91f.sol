/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

pragma solidity ^0.5.0;


contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}


contract WETH9Interface {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function deposit() public payable;
    function withdraw(uint wad) public;

    function totalSupply() public view returns (uint);
    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}


/**
 * @title Uniswap ETH-WETH Exchange Liquidity Adder
 * @author Roger Wu (@Roger-Wu)
 * @dev Help add ETH to Uniswap's ETH-WETH exchange in one transaction.
 * @notice Do not send WETH or UNI token to this contract.
 */
contract UniswapWethLiquidityAdder {
    // Uniswap V1 ETH-WETH Exchange Address
    address public uniswapWethExchangeAddress = 0xA2881A90Bf33F03E7a3f803765Cd2ED5c8928dFb;
    address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    WETH9Interface weth = WETH9Interface(wethAddress);
    UniswapExchangeInterface uniswapWethExchange = UniswapExchangeInterface(uniswapWethExchangeAddress);

    constructor() public {
        // approve the exchange to transfer WETH from this contract
        weth.approve(uniswapWethExchangeAddress, 2**256-1);
    }

    function () external payable {
        addLiquidity();
    }

    /// @dev This function will
    /// 1. receive ETH,
    /// 2. fetch the price of WETH/ETH from Uniswap's ETH-WETH exchange,
    /// 3. wrap part of the ETH to WETH (the amount is dependent on the price),
    /// 4. add ETH and WETH to the exchange and get liquidity tokens,
    /// 5. transfer the liquidity tokens to msg.sender.
    /// notice: There may be a few weis stuck in this contract.
    function addLiquidity() public payable returns (uint256 liquidity) {
        // If no ETH is received, do nothing.
        if (msg.value == 0) {
            return 0;
        }

        // Get the amount of ETH now in this contract.
        uint256 totalEth = address(this).balance;

        // Get the amount of ETH and WETH in the liquidity pool.
        uint256 ethInPool = uniswapWethExchangeAddress.balance;
        uint256 wethInPool = weth.balanceOf(uniswapWethExchangeAddress);
        uint256 sumEthWethInPool = ethInPool + wethInPool; // should never overflow

        // Compute the amount of ETH and WETH we will add to the pool.
        uint256 ethToAdd;
        uint256 wethToAdd;
        if (sumEthWethInPool == 0) {
            // If no liquidity in the exchange, set ethToAdd:wethToAdd = 1:1.
            wethToAdd = totalEth / 2;
            ethToAdd = totalEth - wethToAdd;
        } else {
            // If there's liquidity in the exchange, set ethToAdd:wethToAdd = ethInPool:wethInPool.

            // Problem:
            //     What's the maximum value of ETH and WETH we can add to the pool?
            // Notice:
            //     In the following comments, '/' stands for a normal division, not an integer division.
            // Solution:
            //     Let `ethToAdd` be the amount of weis we are adding to the pool.
            //     Then we are actually solving this:
            //         Find maximum non-negative integer `ethToAdd` s.t.
            //         ethToAdd + wethToAdd <= totalEth
            //         wethToAdd = floor(ethToAdd * wethInPool / ethInPool) + 1    (from Uniswap's contract)
            //     Let x = ethToAdd
            //         A = wethInPool
            //         B = ethInPool
            //         C = totalEth
            //     Then
            //            x + floor(x * A / B) + 1 <= C
            //         => floor(x * A / B) <= C - x - 1
            //         => x * A / B < C - x - 1 + 1
            //         => x + x * A / B < C
            //         => x < C * B / (A + B)
            //         => max int x = ceil(C * B / (A + B)) - 1
            //     So max ethToAdd = ceil(totalEth * ethInPool / (wethInPool + ethInPool)) - 1
            // Notes:
            //     1. ceil(a / b) = floor((a + b - 1) / b) if a, b are integers.
            //     2. We don't use SafeMath here because it's almost impossible to overflow
            //        when computing `ethBalance * ethBalance` and `ethBalance * wethBalance`
            //        because the amount of ETH and WETH should be much less than 2**128.
            //        It saves some gas not using SafeMath.
            ethToAdd = (totalEth * ethInPool + sumEthWethInPool - 1) / sumEthWethInPool - 1;
            wethToAdd = ethToAdd * wethInPool / ethInPool + 1;
        }

        // Wrap ETH.
        weth.deposit.value(wethToAdd)();

        // Add liquidity to ETH-WETH pool.
        uint256 liquidityMinted = uniswapWethExchange.addLiquidity.value(ethToAdd)(1, 2**256-1, 2**256-1);

        // Transfer liquidity token to msg.sender.
        require(uniswapWethExchange.transfer(msg.sender, liquidityMinted));

        return liquidityMinted;
    }
}