pragma solidity >=0.4.25 <0.6.0;

import './HolderLockStrategy.sol';

contract FundLockContract is HolderLockStrategy {
    constructor() public {
        uint[] memory unlockDate = new uint[](6);
        unlockDate[0] = uint(1558828800);     // 2019-5-26 08:00:00 AM 北京时间
        unlockDate[1] = uint(1651334400);     // 2022-5-1 12:00:00 AM 北京时间
        unlockDate[2] = uint(1667232000);     // 2022-11-1 12:00:00 AM 北京时间
        unlockDate[3] = uint(1682870400);     // 2023-5-1 12:00:00 AM 北京时间
        unlockDate[4] = uint(1698768000);     // 2023-11-1 12:00:00 AM 北京时间
        unlockDate[5] = uint(1714492800);     // 2024-5-1 12:00:00 AM 北京时间
        
        uint[] memory unlockPercents = new uint[](6);
        for (uint i = 0; i < unlockPercents.length; ++i) {
            unlockPercents[i] = 20 * i;
        }
        
        init(
            'Funds',             // 基金会
            unlockDate,
            unlockPercents,
            0x5F432F600222dC0c91bac3887659B2a67A8f99e5,
            930000000 * 10 ** 18,
            0x9603f8Ca8Ff73493676946cf6eF26B4C4c1Fa198);
    }
}