pragma solidity 0.5.13;

contract IErc20 {
	function transfer(address to, uint256 value) public returns (bool);
	function balanceOf(address account) public view returns (uint256);
}

contract SethSwapper {
	address payable public receiver = 0x25dde46EC77A801ac887e7D1764B0c8913328348;
	IErc20 public sethProxy = IErc20(0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb);

	function () external payable {
		sethProxy.transfer(msg.sender, msg.value);
	}

	function withdraw() external returns (bytes memory) {
		(bool success,) = receiver.call.value(address(this).balance)("");
		require(success, "receiver.call failed");
	}

	function withdrawUnknownToken(IErc20 token) external {
		require(token != sethProxy, "token == sethProxy");
		token.transfer(receiver, token.balanceOf(address(this)));
	}
}