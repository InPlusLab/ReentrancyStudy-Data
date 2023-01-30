/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.3;


interface IBZx {
    function oracleAddresses(
        address oracleAddress)
        external
        view
        returns (address);
}

interface IBZxOracle {
    function getTradeData(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        external
        view
        returns (uint256 sourceToDestRate, uint256 sourceToDestPrecision, uint256 destTokenAmount);
}

contract BZxOraclePriceFeed {
    function getTradeData(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        public
        view
        returns (uint256 sourceToDestRate, uint256 sourceToDestPrecision, uint256 destTokenAmount)
    {
        address oracleAddress = IBZx(0x1Cf226E9413AddaF22412A2E182F9C0dE44AF002).oracleAddresses(0x4c1974e5FF413C6E061aE217040795AaA1748e8B);

        (sourceToDestRate, sourceToDestPrecision, destTokenAmount) = IBZxOracle(oracleAddress).getTradeData(
            sourceTokenAddress,
            destTokenAddress,
            sourceTokenAmount
        );
    }
}