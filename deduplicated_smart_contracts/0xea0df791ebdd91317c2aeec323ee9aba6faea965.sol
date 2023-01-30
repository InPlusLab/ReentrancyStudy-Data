/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity 0.5.2;







contract Medianizer {

    function read() external returns (bytes32);

}





contract Test {

    Medianizer public medianizer;

    

    bytes32 public q;

    uint public w;

    

    function get() public {

        q = medianizer.read();

    }

    

    function set(address _m) public {

        medianizer = Medianizer(_m);

    }

}