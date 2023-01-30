/**
 *Submitted for verification at Etherscan.io on 2020-11-15
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


contract Vault {
    using SafeMathLib for uint;

    IERC20 public token;
    uint public startBlock = 0;
    uint public numTranches = 0;


    struct Tranche {
        uint id;
        address destination;
        uint totalCoins;
        uint currentCoins;
        uint lockPeriodEndBlock;
        uint vestingPeriodEndBlock;
        uint lastWithdrawalBlock;
        uint startBlock;
    }

    mapping (uint => Tranche) public tranches;

    event WithdrawalOccurred(uint trancheId, uint numTokens, uint tokensLeft);
    event TrancheAdded(uint id, address destination, uint totalCoins, uint lockPeriodBlocks, uint vestingPeriodEndBlocks, uint startBlock);

    constructor(address tokenAddr, address[] memory destinations, uint[] memory tokenAllocations, uint[] memory lockPeriods, uint[] memory vestingPeriodEnds, uint[] memory startBlocks) public {
        token = IERC20(tokenAddr);

        for (uint i = 0; i < destinations.length; i++)  {
            uint trancheId = i + 1;
            tranches[trancheId] = Tranche(
                trancheId,
                destinations[i],
                tokenAllocations[i],
                tokenAllocations[i],
                lockPeriods[i],
                vestingPeriodEnds[i],
                startBlocks[i],
                startBlocks[i]
            );
            emit TrancheAdded(trancheId, destinations[i], tokenAllocations[i], lockPeriods[i], vestingPeriodEnds[i], startBlocks[i]);
        }
        numTranches = destinations.length;
    }

    function withdraw(uint trancheId) public {
        Tranche storage tranche = tranches[trancheId];
        require(block.number > tranche.lockPeriodEndBlock, 'Must wait until after lock period');
        require(tranche.currentCoins >  0, 'No coins left to withdraw');
        uint currentWithdrawal = 0;

        // if after vesting period ends, give them the remaining coins
        if (block.number >= tranche.vestingPeriodEndBlock) {
            currentWithdrawal = tranche.currentCoins;
        } else {
            // compute allowed withdrawal
            uint coinsPerBlock = tranche.totalCoins / (tranche.vestingPeriodEndBlock.minus(tranche.startBlock));
            currentWithdrawal = (block.number.minus(tranche.lastWithdrawalBlock)).times(coinsPerBlock);
        }

        // check that we have enough tokens
        // adding this so we don't have to know in advance how many LP tokens we will get
        uint tokenBalance = token.balanceOf(address(this));
        if (currentWithdrawal > tokenBalance) {
            currentWithdrawal = tokenBalance;
        }

        // update struct
        tranche.currentCoins = tranche.currentCoins.minus(currentWithdrawal);
        tranche.lastWithdrawalBlock = block.number;

        // transfer the tokens, brah
        token.transfer(tranche.destination, currentWithdrawal);
        emit WithdrawalOccurred(trancheId, currentWithdrawal, tranche.currentCoins);
    }
}