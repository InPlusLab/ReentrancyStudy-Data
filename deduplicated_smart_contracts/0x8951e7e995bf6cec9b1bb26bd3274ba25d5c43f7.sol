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

import { ERC20 } from "../../ERC20.sol";
import { TokenMetadata, Component } from "../../Structs.sol";
import { TokenAdapter } from "../TokenAdapter.sol";


/**
 * @dev Basset struct.
 * The Basset struct is available here
 * github.com/mstable/mStable-contracts/blob/master/contracts/masset/shared/MassetStructs.sol.
 */
struct Basset {
    address addr;
    uint8 status;
    bool isTransferFeeCharged;
    uint256 ratio;
    uint256 maxWeight;
    uint256 vaultBalance;
}
//
//
///**
// * @dev BassetStatus enum.
// * The BassetStatus enum is available here
// * github.com/mstable/mStable-contracts/blob/master/contracts/masset/shared/MassetStructs.sol.
// */
//enum BassetStatus {
//    Default,
//    Normal,
//    BrokenBelowPeg,
//    BrokenAbovePeg,
//    Blacklisted,
//    Liquidating,
//    Liquidated,
//    Failed
//}


/**
 * @dev BasketManager contract interface.
 * Only the functions required for MassetTokenAdapter contract are added.
 * The BasketManager contract is available here
 * github.com/mstable/mStable-contracts/blob/master/contracts/masset/BasketManager.sol.
 */
interface BasketManager {
    function getBassets() external view returns (Basset[] memory, uint256);
}


/**
 * @dev ForgeValidator contract interface.
 * Only the functions required for MassetTokenAdapter contract are added.
 * The ForgeValidator contract is available here
 * github.com/mstable/mStable-contracts/blob/master/contracts/masset/forge-validator/ForgeValidator.sol.
 */
interface ForgeValidator {
    function calculateRedemptionMulti(
        uint256,
        Basset[] calldata
    )
    external
    view
    returns (bool, string memory, uint256[] memory);
}


/**
 * @title Token adapter for Masset.
 * @dev Implementation of TokenAdapter interface.
 */
contract MstableTokenAdapter is TokenAdapter {

    address internal constant BASKET_MANAGER = 0x66126B4aA2a1C07536Ef8E5e8bD4EfDA1FdEA96D;
    address internal constant FORGE_VALIDATOR = 0xbB90D06371030fFa150E463621c22950b212eaa1;


    /**
     * @return TokenMetadata struct with ERC20-style token info.
     * @dev Implementation of TokenAdapter interface function.
     */
    function getMetadata(address token) external view override returns (TokenMetadata memory) {
        return TokenMetadata({
            token: token,
            name: ERC20(token).name(),
            symbol: ERC20(token).symbol(),
            decimals: ERC20(token).decimals()
        });
    }

    /**
     * @return Array of Component structs with underlying tokens rates for the given token.
     * @dev Implementation of TokenAdapter interface function.
     */
    function getComponents(address) external view override returns (Component[] memory) {
        (Basset[] memory bassets, uint256 length) = BasketManager(BASKET_MANAGER).getBassets();
        uint256[] memory underlyingAmounts;
        (, , underlyingAmounts) = ForgeValidator(FORGE_VALIDATOR).calculateRedemptionMulti(
            1e18,
            bassets
        );

        Component[] memory underlyingTokens = new Component[](length);
        for (uint256 i = 0; i < length; i++) {
            underlyingTokens[i] = Component({
                token: bassets[i].addr,
                tokenType: "ERC20",
                rate: underlyingAmounts[i]
            });
        }

        return underlyingTokens;
    }
}