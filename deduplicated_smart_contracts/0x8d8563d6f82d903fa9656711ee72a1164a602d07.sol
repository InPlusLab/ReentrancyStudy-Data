/**
 *Submitted for verification at Etherscan.io on 2020-02-21
*/

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;


contract TokenLike {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
}

contract iTokenLike is TokenLike {
    function loanTokenAddress() public view returns (address);
    function tokenPrice() public view returns (uint256);
    function totalAssetSupply() public view returns (uint256);
    function totalAssetBorrow() public view returns (uint256);
    function supplyInterestRate() public view returns (uint256);
    function avgBorrowInterestRate() public view returns (uint256);
    function nextBorrowInterestRateWithOption(
        uint256 borrowAmount,
        bool useFixedInterestModel)
        public
        view
        returns (uint256);
}

contract OracleLike {
    function getTradeData(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        public
        view
        returns (
            uint256 sourceToDestRate,
            uint256 sourceToDestPrecision,
            uint256 destTokenAmount
        );
}

contract DAppHelper {

    address public constant vaultContract = 0x8B3d70d628Ebd30D4A2ea82DB95bA2e906c71633;

    function assetRates(
        address oracleAddress,
        address usdTokenAddress,
        address[] memory tokens,
        uint256[] memory amounts)
        public
        view
        returns (
            uint256[] memory rates
        )
    {
        OracleLike oracle = OracleLike(oracleAddress);
        rates = new uint256[](tokens.length);

        for (uint256 i=0; i < tokens.length; i++) {
            (rates[i],,) = oracle.getTradeData(
                tokens[i],
                usdTokenAddress,
                amounts[i]
            );
        }
    }

    function reserveDetails(
        address[] memory tokenAddresses)
        public
        view
        returns (
            uint256[] memory totalAssetSupply,
            uint256[] memory totalAssetBorrow,
            uint256[] memory supplyInterestRate,
            uint256[] memory borrowInterestRate,
            uint256[] memory torqueBorrowInterestRate,
            uint256[] memory vaultBalance
        )
    {
        totalAssetSupply = new uint256[](tokenAddresses.length);
        totalAssetBorrow = new uint256[](tokenAddresses.length);
        supplyInterestRate = new uint256[](tokenAddresses.length);
        borrowInterestRate = new uint256[](tokenAddresses.length);
        torqueBorrowInterestRate = new uint256[](tokenAddresses.length);
        vaultBalance = new uint256[](tokenAddresses.length);

        for (uint256 i=0; i < tokenAddresses.length; i++) {
            iTokenLike token = iTokenLike(tokenAddresses[i]);
            totalAssetSupply[i] = token.totalAssetSupply();
            totalAssetBorrow[i] = token.totalAssetBorrow();
            supplyInterestRate[i] = token.supplyInterestRate();
            borrowInterestRate[i] = token.avgBorrowInterestRate();
            torqueBorrowInterestRate[i] = token.nextBorrowInterestRateWithOption(0,true);
            vaultBalance[i] = TokenLike(token.loanTokenAddress()).balanceOf(vaultContract);
        }
    }
}