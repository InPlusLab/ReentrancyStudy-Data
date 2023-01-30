/**
 *Submitted for verification at Etherscan.io on 2019-09-19
*/

pragma solidity ^0.5.0;

contract IUniswapExchange {
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
}


contract IKyberNetwork {
    function getExpectedRate(address src, address dest, uint srcQty) external view
    returns (uint expectedRate, uint slippageRate);
}

contract IOasisExchange {

    function getBuyAmount(address buy_gem, address pay_gem, uint pay_amt) public view returns (uint fill_amt);
}

contract ETHDAIPrice {
    function getPrice() external view returns(uint256) {
        IUniswapExchange uniswap = IUniswapExchange(0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14);
        uint ethtdai_uniswap = uniswap.getEthToTokenInputPrice(1000000000000000000);
        
        IKyberNetwork kyber = IKyberNetwork(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
        (uint ethdai_kyber, uint slippageRate) = kyber.getExpectedRate(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, 10);
        
        IOasisExchange oasis = IOasisExchange(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);
        uint ethdai_oasis = oasis.getBuyAmount(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 1000000000000000000);
        
        return (ethdai_kyber + ethtdai_uniswap + ethdai_oasis) / 3;
        
    }
}