/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity ^0.5.0;



contract ActionLogger {

    event Log(string indexed _type, address indexed owner, uint _first, uint _second);



    function logEvent(string memory _type, address _owner, uint _first, uint _second) public {

        emit Log(_type, _owner, _first, _second);

    }

}