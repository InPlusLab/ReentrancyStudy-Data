/**

 *Submitted for verification at Etherscan.io on 2019-06-10

*/



pragma solidity ^0.5.1;



interface ERC20 {

    function balanceOf(address _owner) external view returns (uint balance);    

}



contract GetTokenBalances {

    

    function getTenTokenBalance(ERC20 token, uint numHolders, address[] calldata holders) external view returns (uint[] memory) {

        

        uint [] memory resBalances = new uint[](numHolders);

        

        for (uint i = 0; i < numHolders; i++) {

            resBalances[i] = token.balanceOf(holders[i]);

        }

        

        return resBalances;

    }

    

}