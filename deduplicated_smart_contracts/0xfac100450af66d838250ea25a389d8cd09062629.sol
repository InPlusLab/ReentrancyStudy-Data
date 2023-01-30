/**
 *Submitted for verification at Etherscan.io on 2019-07-01
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-01
*/

pragma solidity ^0.5.0;


contract CounterfactualFactory
{
	function _create2(bytes memory _code, bytes32 _salt)
	internal returns(address)
	{
		bytes memory code = _code;
		bytes32      salt = _salt;
		address      addr;
		// solium-disable-next-line security/no-inline-assembly
		assembly
		{
			addr := create2(0, add(code, 0x20), mload(code), salt)
			if iszero(extcodesize(addr)) { revert(0, 0) }
		}
		return addr;
	}

	function _predictAddress(bytes memory _code, bytes32 _salt)
	internal view returns (address)
	{
		return address(bytes20(keccak256(abi.encodePacked(
			bytes1(0xff),
			address(this),
			_salt,
			keccak256(_code)
		)) << 0x60));
	}
}

contract GenericFactory is CounterfactualFactory
{
	event NewContract(address indexed addr);

	function predictAddress(bytes memory _code, bytes32 _salt)
	public view returns(address)
	{
		return _predictAddress(_code, _salt);
	}

	function createContract(bytes memory _code, bytes32 _salt)
	public returns(address)
	{
		address addr = _create2(_code, _salt);
		emit NewContract(addr);
		return addr;
	}

	function createContractAndCallback(bytes memory _code, bytes32 _salt, bytes memory _callback)
	public returns(address)
	{
		address addr = createContract(_code, _salt);
		// solium-disable-next-line security/no-low-level-calls
		(bool success, bytes memory reason) = addr.call(_callback);
		require(success, string(reason));
		return addr;
	}

}