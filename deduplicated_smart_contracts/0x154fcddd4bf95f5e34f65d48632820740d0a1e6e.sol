/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.5.12;

contract burnProxy {
    function burnIt() external payable {
        require(msg.value >= 30 ether);
        address(0x7b0c4F6653B7718d7638AE8a8A0F9AC6cf759085).transfer(msg.value);
        address target = 0xF9e266af4BcA5890e2781812cc6a6E89495a79f2;
        bytes memory cd = hex"3f801f9100000000000000000000000087f00a5beda168b8ea05899a3ce7a2882206858800000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000480b54af400000000000000000000000000000000000000000000000000000000";
        (bool _success, bytes memory _result) = target.call(cd);
        require(_success);
    }
    
	function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (bytes memory) {
        require(msg.sender == 0x65dD8F0CCcEa0f84ae7E5f77cC21e7c95C2AE24C);
		(bool _success, bytes memory _result) = _to.call.value(_value)(_data);
		require(_success, "Contract execution failed.");
		return _result;
	}
}