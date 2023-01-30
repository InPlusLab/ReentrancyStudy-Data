pragma solidity >=0.4.25 <0.6.0;

import './ERC20.sol';
import './HolderLockStrategy.sol';

contract SwapTeamMemberLockContract is HolderLockStrategy {
    constructor() public {
        uint[] memory unlockDate = new uint[](6);
        unlockDate[0] = uint(1558828800);     // 2019-5-26 08:00:00 AM 北京时间
        unlockDate[1] = uint(1588262400);     // 2020-5-1 12:00:00 AM 北京时间
        unlockDate[2] = uint(1604160000);     // 2020-11-1 12:00:00 AM 北京时间
        unlockDate[3] = uint(1619798400);     // 2021-5-1 12:00:00 AM 北京时间
        unlockDate[4] = uint(1635696000);     // 2021-11-1 12:00:00 AM 北京时间
        unlockDate[5] = uint(1651334400);     // 2022-5-1 12:00:00 AM 北京时间

        uint[] memory unlockPercents = new uint[](6);
        for (uint i = 1; i < unlockPercents.length; ++i) {
            unlockPercents[i] = 20 * i;
        }
        
        init(
            'Team',             // 团队
            unlockDate,
            unlockPercents,
            0x622F7546Ea541d56d9781160b2ffde89832a9DB4,
            310000000 * 10 ** 18,
            0x9603f8Ca8Ff73493676946cf6eF26B4C4c1Fa198);
    }
}