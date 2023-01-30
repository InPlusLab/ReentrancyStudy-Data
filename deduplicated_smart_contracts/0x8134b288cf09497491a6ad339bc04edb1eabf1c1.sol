/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface StakeUIHelperI {
  struct AssetUIData {
    uint256 stakeTokenTotalSupply;
    uint256 stakeCooldownSeconds;
    uint256 stakeUnstakeWindow;
    uint128 distributionPerSecond;
    uint256 stakeTokenUserBalance;
    uint256 underlyingTokenUserBalance;
    uint256 userCooldown;
    uint256 userIncentivesToClaim;
    uint256 userPermitNonce;
  }

  function getStkAaveData(address user) external view returns (AssetUIData memory);

  function getStkBptData(address user) external view returns (AssetUIData memory);

  function getUserUIData(address user)
    external
    view
    returns (AssetUIData memory, AssetUIData memory);
}

interface IStakedToken {
  struct AssetData {
    uint128 emissionPerSecond;
    uint128 lastUpdateTimestamp;
    uint256 index;
  }

  function totalSupply() external view returns (uint256);

  function COOLDOWN_SECONDS() external view returns (uint256);

  function UNSTAKE_WINDOW() external view returns (uint256);

  function assets(address asset) external view returns (AssetData memory);

  function balanceOf(address user) external view returns (uint256);

  function getTotalRewardsBalance(address user) external view returns (uint256);

  function stakersCooldowns(address user) external view returns (uint256);
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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

interface IERC20WithNonce is IERC20 {
  function _nonces(address user) external view returns (uint256);
}

contract StakeUIHelper is StakeUIHelperI {
  address immutable AAVE;
  IStakedToken immutable STAKED_AAVE;

  address immutable BPT;
  IStakedToken immutable STAKED_BPT;

  constructor(
    address aave,
    IStakedToken stkAave,
    address bpt,
    IStakedToken stkBpt
  ) public {
    AAVE = aave;
    STAKED_AAVE = stkAave;
    BPT = bpt;
    STAKED_BPT = stkBpt;
  }

  function _getStakedAssetData(
    IStakedToken stakeToken,
    address underlyingToken,
    address user,
    bool isNonceAvailable
  ) internal view returns (AssetUIData memory) {
    AssetUIData memory data;

    data.stakeTokenTotalSupply = stakeToken.totalSupply();
    data.stakeCooldownSeconds = stakeToken.COOLDOWN_SECONDS();
    data.stakeUnstakeWindow = stakeToken.UNSTAKE_WINDOW();
    data.distributionPerSecond = stakeToken.assets(address(STAKED_AAVE)).emissionPerSecond;

    if (user != address(0)) {
      data.underlyingTokenUserBalance = IERC20(underlyingToken).balanceOf(user);
      data.stakeTokenUserBalance = stakeToken.balanceOf(user);
      data.userIncentivesToClaim = stakeToken.getTotalRewardsBalance(user);
      data.userCooldown = stakeToken.stakersCooldowns(user);
      data.userPermitNonce = isNonceAvailable ? IERC20WithNonce(underlyingToken)._nonces(user) : 0;
    }
    return data;
  }

  function getStkAaveData(address user) public override view returns (AssetUIData memory) {
    return _getStakedAssetData(STAKED_AAVE, AAVE, user, true);
  }

  function getStkBptData(address user) public override view returns (AssetUIData memory) {
    return _getStakedAssetData(STAKED_BPT, BPT, user, false);
  }

  function getUserUIData(address user)
    external
    override
    view
    returns (AssetUIData memory, AssetUIData memory)
  {
    return (getStkAaveData(user), getStkBptData(user));
  }
}