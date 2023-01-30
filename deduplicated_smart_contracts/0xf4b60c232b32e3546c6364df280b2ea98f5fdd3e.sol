/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity 0.5.12;

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract BalanceQuerier {
    function getBalances(
        address user,
        address[] memory assetIds
    )
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory balances = new uint256[](assetIds.length);
        for(uint256 i; i < assetIds.length; i++) {
            address assetId = assetIds[i];
            balances[i] = ERC20(assetId).balanceOf(user);
        }

        return balances;
    }
}