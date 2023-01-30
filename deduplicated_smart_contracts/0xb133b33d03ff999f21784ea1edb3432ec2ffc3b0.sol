/**
 *Submitted for verification at Etherscan.io on 2020-11-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
}

interface ISwapPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IMasterchef {
    function poolInfo(uint i) external view returns (address, uint, uint, uint);
}

contract AAAAQuery3 {
    address public owner;
    address public masterchef;

    // Info of each pool.
    struct PoolInfo {
        uint id;
        address lpToken;       // Address of LP token contract.
        uint allocPoint;       // How many allocation points assigned to this pool. CAKEs to distribute per block.
        uint lastRewardBlock;  // Last block number that CAKEs distribution occurs.
        uint accPerShare;  // Accumulated CAKEs per share, times 1e12. See below.
        address lpToken0;
        address lpToken1;
        uint lpToken0Decimals;
        uint lpToken1Decimals;
        string lpToken0Symbol;
        string lpToken1Symbol;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    function initialize (address _masterchef) external {
        require(msg.sender == owner, "FORBIDDEN");
        masterchef = _masterchef;
    }

    function getPoolInfo(uint i) public view returns (PoolInfo memory info){
        info.id = i;
        (info.lpToken, info.allocPoint, info.lastRewardBlock, info.accPerShare) = IMasterchef(masterchef).poolInfo(i);
        info.lpToken0 = ISwapPair(info.lpToken).token0();
        info.lpToken1 = ISwapPair(info.lpToken).token1();
        info.lpToken0Decimals = IERC20(info.lpToken0).decimals();
        info.lpToken1Decimals = IERC20(info.lpToken1).decimals();
        info.lpToken0Symbol = IERC20(info.lpToken0).symbol();
        info.lpToken1Symbol = IERC20(info.lpToken1).symbol();
        return info;
    }

    function getPoolInfoList(uint count) public view returns (PoolInfo[] memory list){
        list = new PoolInfo[](count);
        if(count > 0) {
            for(uint i = 1; i < count; i++) {
                list[i] = getPoolInfo(i);
            }
        }
        return list;
    }

}