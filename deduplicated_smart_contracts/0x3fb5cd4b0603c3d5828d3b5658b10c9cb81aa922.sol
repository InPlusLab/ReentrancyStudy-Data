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
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

import { Ownable } from "../../core/Ownable.sol";


struct PoolInfo {
    address swap;       // stableswap contract address.
    address deposit;    // deposit contract address.
    uint256 totalCoins; // Number of coins used in stableswap contract.
    string name;        // Pool name ("... Pool").
}


/**
 * @title Registry for Curve contracts.
 * @dev Implements two getters - getSwapAndTotalCoins(address) and getName(address).
 * @notice Call getSwapAndTotalCoins(token) and getName(address) function and get address,
 * coins number, and name of stableswap contract for the given token address.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CurveRegistry is Ownable {

    mapping (address => PoolInfo) internal poolInfo_;

    function setPoolsInfo(
        address[] memory tokens,
        PoolInfo[] memory poolsInfo
    )
        external
        onlyOwner
    {
        uint256 length = tokens.length;
        for (uint256 i = 0; i < length; i++) {
            setPoolInfo(tokens[i], poolsInfo[i]);
        }
    }

    function setPoolInfo(
        address token,
        PoolInfo memory poolInfo
    )
        internal
    {
        poolInfo_[token] = poolInfo;
    }

    function getPoolInfo(address token) external view returns (PoolInfo memory) {
        return poolInfo_[token];
    }
}

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
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;


abstract contract Ownable {

    modifier onlyOwner {
        require(msg.sender == owner_, "O: only owner");
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == pendingOwner_, "O: only pending owner");
        _;
    }

    address private owner_;
    address private pendingOwner_;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @notice Initializes owner variable with msg.sender address.
     */
    constructor() {
        owner_ = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Sets pending owner to the desired address.
     * The function is callable only by the owner.
     */
    function proposeOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "O: empty newOwner");
        require(newOwner != owner_, "O: equal to owner_");
        require(newOwner != pendingOwner_, "O: equal to pendingOwner_");
        pendingOwner_ = newOwner;
    }

    /**
     * @notice Transfers ownership to the pending owner.
     * The function is callable only by the pending owner.
     */
    function acceptOwnership() external onlyPendingOwner {
        emit OwnershipTransferred(owner_, msg.sender);
        owner_ = msg.sender;
        delete pendingOwner_;
    }

    /**
     * @return Owner of the contract.
     */
    function owner() external view returns (address) {
        return owner_;
    }

    /**
     * @return Pending owner of the contract.
     */
    function pendingOwner() external view returns (address) {
        return pendingOwner_;
    }
}

