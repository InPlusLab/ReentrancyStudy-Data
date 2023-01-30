/**

 *Submitted for verification at Etherscan.io on 2019-03-12

*/



pragma solidity ^0.5.0;



/**

 * (E)t)h)e)x) House Contract 

 *  This smart-contract is the part of Ethex Lottery fair game.

 *  See latest version at https://github.com/ethex-bet/ethex-lottery 

 *  http://ethex.bet

 */

 

 contract EthexHouse {

     address payable private owner;

     

     constructor() public {

         owner = msg.sender;

     }

     

     modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    

    function payIn() external payable {

    }

    

    function withdraw() external onlyOwner {

        owner.transfer(address(this).balance);

    }

 }