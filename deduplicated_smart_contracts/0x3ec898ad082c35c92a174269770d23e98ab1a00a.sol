// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

import { ProtocolAdapter } from "../ProtocolAdapter.sol";


/**
 * @dev KyberStaking contract interface.
 * Only the functions required for KyberAssetAdapter contract are added.
 * The KyberStaking contract is available here
 * github.com/KyberNetwork/smart-contracts/blob/Katalyst/contracts/sol6/Dao/KyberStaking.sol.
 */
interface KyberStaking {
    function getLatestStakerData(address) external view returns (uint256, uint256);
}


/**
 * @dev KyberDAO contract interface.
 * Only the functions required for KyberAssetAdapter contract are added.
 * The KyberDAO contract is available here
 * github.com/KyberNetwork/smart-contracts/blob/Katalyst/contracts/sol6/Dao/KyberDAO.sol.
 */
interface KyberDAO {
    function getCurrentEpochNumber() external view returns (uint32);
    function getPastEpochRewardPercentageInPrecision(
        address,
        uint32
    )
        external
        view
        returns (uint256);
}


/**
 * @dev KyberFeeHandler contract interface.
 * Only the functions required for KyberAssetAdapter contract are added.
 * The KyberFeeHandler contract is available here
 * github.com/KyberNetwork/smart-contracts/blob/Katalyst/contracts/sol6/Dao/KyberFeeHandler.sol.
 */
interface KyberFeeHandler {
    function hasClaimedReward(address, uint32) external view returns (bool);
    function rewardsPerEpoch(uint32) external view returns (uint256);
}


/**
 * @title Asset adapter for KyberDAO protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract KyberAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";

    string public constant override tokenType = "ERC20";

    address internal constant KNC = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant DAO = 0x49bdd8854481005bBa4aCEbaBF6e06cD5F6312e9;
    address internal constant STAKING = 0xECf0bdB7B3F349AbfD68C3563678124c5e8aaea3;
    address internal constant FEE_HANDLER = 0xd3d2b5643e506c6d9B7099E9116D7aAa941114fe;

    uint256 internal constant PRECISION = 1e18;

    /**
     * @return Amount of KNC/ETH locked on the protocol by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account) external view override returns (uint256) {
        if (token == KNC) {
            uint256 stake;
            uint256 delegatedStake;
            (stake, delegatedStake) = KyberStaking(STAKING).getLatestStakerData(account);
            return stake + delegatedStake;
        } else if (token == ETH) {
            uint256 reward = 0;
            uint256 rewardPercentage;
            uint256 rewardsPerEpoch;
            uint32 curEpoch = KyberDAO(DAO).getCurrentEpochNumber();
            for (uint32 i = 0; i < curEpoch; i++) {
                if (!KyberFeeHandler(FEE_HANDLER).hasClaimedReward(account, i)) {
                    rewardPercentage = KyberDAO(DAO).getPastEpochRewardPercentageInPrecision(account, i);
                    if (rewardPercentage > 0) {
                        rewardsPerEpoch = KyberFeeHandler(FEE_HANDLER).rewardsPerEpoch(i);
                        reward += rewardsPerEpoch * rewardPercentage / PRECISION;
                    }
                }
            }
            return reward;
        } else {
            return 0;
        }
    }
}