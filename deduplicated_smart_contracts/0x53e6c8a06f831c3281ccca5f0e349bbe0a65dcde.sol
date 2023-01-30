/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

pragma solidity 0.7.6;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract CRVDisperse {
    function transferMany(uint256 _inputAmount, address[] calldata _recipients, uint256[] calldata _outputAmounts) external {
        require (msg.sender == 0xc420C9d507D0E038BD76383AaADCAd576ed0073c);
        if (_inputAmount > 0) {
            IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52).transferFrom(msg.sender, address(this), _inputAmount);
        }
        for (uint i; i < _recipients.length; i++) {
            IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52).transfer(_recipients[i], _outputAmounts[i]);
        }
    }
}