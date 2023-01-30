/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.7.4;

library SafeMathLib {
  function times(uint a, uint b) public pure returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b, 'Overflow detected');
    return c;
  }

  function minus(uint a, uint b) public pure returns (uint) {
    require(b <= a, 'Underflow detected');
    return a - b;
  }

  function plus(uint a, uint b) public pure returns (uint) {
    uint c = a + b;
    require(c>=a && c>=b, 'Overflow detected');
    return c;
  }

}

interface IUniswapRouter {

    event LiquidityAdded(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

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


/**
 * @title Auction
 */

contract Auction {
    using SafeMathLib for uint;

    struct Tranche {
        uint blockIssued;
        uint weiPerToken;
        uint totalTokens;
        uint currentTokens;
    }

    uint256 public poolBalance;
    address public management;
    uint256 public decayPerBlock;
    uint256 public lastTokensPerWei;
    uint256 public priceFloor;
    uint256 public trancheNumber = 1;
    uint256 public totalTokensOffered;
    uint256 public totalTokensSold = 0;

    uint256 public initialPrice = 0;
    uint256 public initialTrancheSize = 0;
    uint256 public minimumPrice = 0;
    uint256 public startBlock = 0;

    bytes32 public siteHash;

    address payable public safeAddress;
    IERC20 public token;
    IUniswapRouter public uniswap;
    Tranche public currentTranche;

    event PurchaseOccurred(address purchaser, uint weiSpent, uint tokensAcquired, uint tokensLeftInTranche, uint weiReturned, uint trancheNumber, uint timestamp);
    event LiquidityPushed(uint amountToken, uint amountETH, uint liquidity);

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Auction: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier managementOnly() {
        require (msg.sender == management, 'Only management may call this');
        _;
    }

    constructor(address mgmt,
                address tokenAddr,
                address uniswapRouter,
                uint auctionStartBlock,
                uint tokensForSale,
                uint firstTranchePricePerToken,
                uint firstTrancheSize,
                uint initialDecay,
                uint minPrice,
                address payable safeAddr) {
        management = mgmt;
        token = IERC20(tokenAddr);
        uniswap = IUniswapRouter(uniswapRouter);
        startBlock = auctionStartBlock > 0 ? auctionStartBlock : block.number;
        totalTokensOffered = tokensForSale;
        initialPrice = firstTranchePricePerToken;
        initialTrancheSize = firstTrancheSize;
        currentTranche = Tranche(startBlock, firstTranchePricePerToken, firstTrancheSize, firstTrancheSize);
        decayPerBlock = initialDecay;
        safeAddress = safeAddr;
        minimumPrice = minPrice;
    }

    /**
     * @dev default function
     * gas ~
     */
    receive() external payable {
        buy(currentTranche.weiPerToken);
    }

    function withdrawTokens() public managementOnly {
        uint balance = token.balanceOf(address(this));
        token.transfer(management, balance);
    }

    function setSiteHash(bytes32 newHash) public managementOnly {
        siteHash = newHash;
    }

    function pushLiquidity() public managementOnly {
        uint tokenBalance = token.balanceOf(address(this));
        uint minToken = tokenBalance / 2;
        uint ethBalance = address(this).balance;
        uint deadline = block.timestamp + 1 hours;
        token.approve(address(uniswap), tokenBalance);
        // this will take all the eth and refund excess tokens
        (uint amountToken, uint amountETH, uint liquidity) = uniswap.addLiquidityETH{value: ethBalance}(address(token), tokenBalance, minToken, ethBalance, safeAddress, deadline);
        emit LiquidityPushed(amountToken, amountETH, liquidity);
    }

    function getBuyPrice() public view returns (uint) {
        if (block.number < currentTranche.blockIssued) {
            return 0;
        }
        // linear time decay
        uint distanceBlocks = block.number.minus(currentTranche.blockIssued);
        uint decay = decayPerBlock.times(distanceBlocks);
        uint proposedPrice;
        if (currentTranche.weiPerToken < decay.plus(minimumPrice)) {
            proposedPrice = minimumPrice;
        } else {
            proposedPrice = currentTranche.weiPerToken.minus(decay);
        }
        return proposedPrice;
    }

    /**
     * @dev Buy tokens
     * gas ~
     */
    function buy(uint maxPrice) public payable lock {
        require(msg.value > 0, 'Auction: must send ether to buy');
        require(block.number >= startBlock, 'Auction: not started yet');
        // buyPrice = wei / 1e18 tokens
        uint weiPerToken = getBuyPrice();

        require(weiPerToken <= maxPrice, 'Auction: price too high');
        // buyAmount = wei * tokens / wei = tokens
        uint buyAmountTokens = (msg.value * 1 ether) / weiPerToken;
        uint leftOverTokens = 0;
        uint weiReturned = 0;
        uint trancheNumReported = trancheNumber;

        // if they bought more than the tranche has...
        if (buyAmountTokens >= currentTranche.currentTokens) {
            // compute the excess amount of tokens
            uint excessTokens = buyAmountTokens - currentTranche.currentTokens;
            // weiReturned / msg.value = excessTokens / buyAmountTokens
            weiReturned = msg.value.times(excessTokens) / buyAmountTokens;
            // send the excess ether back
            // re-entrance blocked by the lock modifier
            msg.sender.transfer(weiReturned);
            // now they are only buying the remaining
            buyAmountTokens = currentTranche.currentTokens;

            // double the tokens offered
            uint nextTrancheTokens = currentTranche.totalTokens.times(2);
            uint tokensLeftInOffering = totalTokensOffered.minus(totalTokensSold).minus(buyAmountTokens);

            // if we are not offering enough tokens to cover the next tranche doubling, this is the last tranche
            if (nextTrancheTokens > tokensLeftInOffering) {
                nextTrancheTokens = tokensLeftInOffering;
            }

            // double the price per token
            currentTranche.weiPerToken = weiPerToken.times(2);

            // set the new tranche token amounts
            currentTranche.totalTokens = nextTrancheTokens;
            currentTranche.currentTokens = currentTranche.totalTokens;

            // double the decay per block and reset the block issued
            currentTranche.blockIssued = block.number;
            decayPerBlock = decayPerBlock.times(2);

            // increment tranche index
            trancheNumber = trancheNumber.plus(1);

        } else {
            currentTranche.currentTokens = currentTranche.currentTokens.minus(buyAmountTokens);
            leftOverTokens = currentTranche.currentTokens;
        }

        // send the tokens! re-entrance not possible here because of Token design, but will be possible with ERC-777
        token.transfer(msg.sender, buyAmountTokens);

        // bookkeeping: count the tokens sold
        totalTokensSold = totalTokensSold.plus(buyAmountTokens);
        emit PurchaseOccurred(msg.sender, msg.value.minus(weiReturned), buyAmountTokens, leftOverTokens, weiReturned, trancheNumReported, block.timestamp);
    }

}