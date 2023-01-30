/**

 *Submitted for verification at Etherscan.io on 2019-05-22

*/



pragma solidity >=0.4.22 <0.6.0;

interface ERC20 {

    function balanceOf(address owner) external view returns (uint256);

}

contract BalanceOracle {

    

    function exploreBalances(address[] calldata users) external view returns(uint256[] memory balances) {

        balances = new uint256[](users.length);

        for(uint i = 0; i < users.length; i++) {

            balances[i] = users[i].balance;

        }

    }

    

    function erc20Balances(address _token, address[] calldata users) external view returns(uint256[] memory balances) {

        ERC20 erc20 = ERC20(_token);

        balances = new uint256[](users.length);

        for(uint i = 0; i < users.length; i++) {

            balances[i] = erc20.balanceOf(users[i]);

        }

    }

}