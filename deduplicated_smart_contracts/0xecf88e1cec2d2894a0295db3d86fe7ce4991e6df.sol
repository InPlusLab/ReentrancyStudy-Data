/**

 *Submitted for verification at Etherscan.io on 2019-05-13

*/



pragma solidity ^0.5.0;



contract SaverLogger {

    event Repay(uint indexed cdpId, address indexed owner, uint collateralAmount, uint daiAmount);

    event Boost(uint indexed cdpId, address indexed owner, uint daiAmount, uint collateralAmount);



    function LogRepay(uint _cdpId, address _owner, uint _collateralAmount, uint _daiAmount) public {

        emit Repay(_cdpId, _owner, _collateralAmount, _daiAmount);

    }



    function LogBoost(uint _cdpId, address _owner, uint _daiAmount, uint _collateralAmount) public {

        emit Boost(_cdpId, _owner, _daiAmount, _collateralAmount);

    }

}