/**
 *Submitted for verification at Etherscan.io on 2019-09-19
*/

pragma solidity ^0.5.0;

contract ERC20 {
    function balanceOf(address holder) external view returns (uint256);
}


contract IKyberNetwork {
    function getExpectedRate(address src, address dest, uint srcQty) external view
    returns (uint expectedRate, uint slippageRate);
}

contract IOasisExchange {

    function getBuyAmount(address buy_gem, address pay_gem, uint pay_amt) public view returns (uint fill_amt);
}

contract ETHDAIPrice {
    function getMedianPrice() external view returns(uint256) {

        ERC20 dai = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
        uint uniswapdaiBalance = dai.balanceOf(0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14);
        uint ethtdai_uniswap = uniswapdaiBalance / 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14.balance;
        
        IKyberNetwork kyber = IKyberNetwork(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
        (uint ethdai_kyber, uint slippageRate) = kyber.getExpectedRate(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, 10);
        
        IOasisExchange oasis = IOasisExchange(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);
        uint ethdai_oasis = oasis.getBuyAmount(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 1000000000000000000);

                
        if (ethdai_kyber <= ethtdai_uniswap && ethtdai_uniswap <= ethdai_oasis || ethdai_kyber >= ethtdai_uniswap && ethtdai_uniswap >= ethdai_oasis) { return ethtdai_uniswap; }
        if (ethtdai_uniswap <= ethdai_kyber && ethdai_kyber <= ethdai_oasis || ethtdai_uniswap >= ethdai_kyber && ethdai_kyber >= ethdai_oasis) { return ethdai_kyber; }
        if (ethtdai_uniswap <= ethdai_oasis && ethdai_oasis <= ethdai_kyber || ethtdai_uniswap >= ethdai_oasis && ethdai_oasis >= ethdai_kyber) { return ethdai_oasis; }
        
    }
}