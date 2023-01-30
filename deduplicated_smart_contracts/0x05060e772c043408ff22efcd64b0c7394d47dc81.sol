/**
 *Submitted for verification at Etherscan.io on 2020-10-28
*/

// File: contracts/lib/IERC20.sol

pragma solidity ^0.5.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/lib/IRewardDistributionRecipient.sol

pragma solidity ^0.5.0;



interface IRewardDistributionRecipient {
    function notifyRewardAmount(uint256 reward) external;

    // Note that this is specific to the Unipool contracts used
    function rewardToken() external view returns (IERC20 token);
}

// File: contracts/RewardsInitiator.sol

pragma solidity 0.5.16;




contract RewardsInitiator {
    string constant private ERROR_TOO_EARLY = "REWARDS_CTRL:TOO_EARLY";

    uint256 constant public earliestStartTime = 1603983600; // 2020-10-29 15:00 UTC

    // Pools
    IRewardDistributionRecipient uniPool = IRewardDistributionRecipient(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IRewardDistributionRecipient bptPool = IRewardDistributionRecipient(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function initiate() external {
        require(block.timestamp >= earliestStartTime, ERROR_TOO_EARLY);

        uint256 uniRewardBalance = uniRewardBalance();
        uniPool.notifyRewardAmount(uniRewardBalance);

        uint256 bptRewardBalance = bptRewardBalance();
        bptPool.notifyRewardAmount(bptRewardBalance);
    }

    function uniRewardBalance() public view returns (uint256) {
        IERC20 uniRewardToken = uniPool.rewardToken();
        return uniRewardToken.balanceOf(address(uniPool));
    }

    function bptRewardBalance() public view returns (uint256) {
        IERC20 bptRewardToken = bptPool.rewardToken();
        return bptRewardToken.balanceOf(address(bptPool));
    }
}