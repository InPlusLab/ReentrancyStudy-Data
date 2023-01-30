/**

 *Submitted for verification at Etherscan.io on 2019-02-03

*/



pragma solidity ^0.5.2;





contract ExternalTokenLockerMock {



    // user => amount

    mapping (address => uint) public lockedTokenBalances;



    function lock(uint256 _amount) public {

        lockedTokenBalances[msg.sender] = _amount;

    }

}