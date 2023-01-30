// SPDX-License-Identifier: MIT
pragma solidity =0.7.4;

import "LibIEtherUSDPrice.sol";

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Ether2USDT is IEtherUSDPrice {
    IUniswapV2Router02 private immutable UniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address private _token = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);  // USDT mainnet

    function etherUSDPrice()
        public
        override
        view
        returns (uint256)
    {
        return UniswapV2Router02.getAmountsOut(1 ether, _path())[1];
    }

    function _path()
        private
        view
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = UniswapV2Router02.WETH();
        path[1] = _token;

        return path;
    }
}

