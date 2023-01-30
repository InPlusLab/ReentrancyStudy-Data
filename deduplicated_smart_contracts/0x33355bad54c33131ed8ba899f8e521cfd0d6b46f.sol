/**

 *Submitted for verification at Etherscan.io on 2019-02-14

*/



pragma solidity 0.5.1;

pragma experimental ABIEncoderV2;

contract IERC20Token {

    function balanceOf(address _owner)

        external

        view

        returns (uint256);



}

contract BatchBalanceInfo {

    struct BalanceInfo {

        uint256 balance;

        address owner;

    }

    function getBalance(address tokenAddress, address owner)

        public

        view

        returns (BalanceInfo memory balanceInfo)

    {

        balanceInfo.balance = IERC20Token(tokenAddress).balanceOf(owner);

        balanceInfo.owner = owner;

        return balanceInfo;

    }

    function getBalanceInfos(address tokenAddress, address[] memory owners)

        public

        view

        returns (BalanceInfo[] memory)

    {

        uint256 ownersLength = owners.length;

        BalanceInfo[] memory balanceInfos = new BalanceInfo[](ownersLength);

        for (uint256 i = 0; i != ownersLength; i++) {

            balanceInfos[i] = getBalance(tokenAddress, owners[i]);

        }

        return balanceInfos;

    }

}