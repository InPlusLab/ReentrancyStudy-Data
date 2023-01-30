/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.4.25;

contract ComplianceService {

    function check(address _token,address _spender,address _from,address _to,uint256 _amount) public view returns (uint8);

}

contract DefaultService is ComplianceService {


    constructor()public{

    }

    function check(address _token,address _spender,address _from,address _to,uint256 _amount) public view returns (uint8){
        return 0;
    }

}