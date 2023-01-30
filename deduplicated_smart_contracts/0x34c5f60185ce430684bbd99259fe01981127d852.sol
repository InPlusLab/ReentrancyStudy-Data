/**

 *Submitted for verification at Etherscan.io on 2019-01-30

*/



pragma solidity >=0.4.0 <0.6.0;



contract Coin {

    address public owners;

    function getOwner(uint index) public view returns (address, uint256);

}



contract Caller {



    function f(uint index) public view returns (address, uint256) {

         Coin c = Coin(0x003FfEFeFBC4a6F34a62A3cA7b7937a880065BCB);

        return c.getOwner(index);

    }

}