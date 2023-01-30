/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity ^0.5.16;

contract Erc20 {
    function balanceOf(address owner) view external returns(uint256);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}

contract iErc20 is Erc20 {
    function tokenPrice() view external returns(uint256);
    function burn(address receiver, uint256 burnAmount) external returns(uint256); 
}

contract FulcrumEmergencyEjection {
    Erc20 constant USDC = Erc20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    iErc20 constant iUSDC = iErc20(0xF013406A0B1d544238083DF0B93ad0d2cBE0f65f);

    function corona(uint256 dustAmount, uint256 userBalance) external returns(uint256 outAmount) {
        uint256 USDCAmount = USDC.balanceOf(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        if (USDCAmount > dustAmount) {
            uint256 iUSDCTokenPrice = iUSDC.tokenPrice();
            uint256 availableBurnAmount = USDCAmount * 1e18 / iUSDCTokenPrice;
            availableBurnAmount = userBalance < availableBurnAmount ? userBalance : availableBurnAmount;
            iUSDC.transferFrom(msg.sender, address(this), availableBurnAmount);
            return iUSDC.burn(msg.sender, availableBurnAmount);
        }
        return 0;
    }
}