/**

 *Submitted for verification at Etherscan.io on 2018-10-06

*/



pragma solidity ^0.4.0;



contract SimpleStorage

{

    uint storedData;

    

    function set(uint x) public

    {

        storedData = x;

    }



    function get() public view returns (uint)

    {

        return storedData;

    }

}