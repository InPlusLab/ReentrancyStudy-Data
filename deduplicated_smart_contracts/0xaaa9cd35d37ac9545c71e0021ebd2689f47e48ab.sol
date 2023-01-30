/**

 *Submitted for verification at Etherscan.io on 2019-04-07

*/



pragma solidity ^0.5.6;



interface GeneralERC20 {

	function transfer(address to, uint256 value) external;

	function transferFrom(address from, address to, uint256 value) external;

	function approve(address spender, uint256 value) external;

	function balanceOf(address spender) external view returns (uint);

}



library SafeERC20 {

	function checkSuccess()

		private

		pure

		returns (bool)

	{

		uint256 returnValue = 0;



		assembly {

			// check number of bytes returned from last function call

			switch returndatasize



			// no bytes returned: assume success

			case 0x0 {

				returnValue := 1

			}



			// 32 bytes returned: check if non-zero

			case 0x20 {

				// copy 32 bytes into scratch space

				returndatacopy(0x0, 0x0, 0x20)



				// load those bytes into returnValue

				returnValue := mload(0x0)

			}



			// not sure what was returned: don't mark as success

			default { }

		}



		return returnValue != 0;

	}



	function transfer(address token, address to, uint256 amount) internal {

		GeneralERC20(token).transfer(to, amount);

		require(checkSuccess());

	}



	function transferFrom(address token, address from, address to, uint256 amount) internal {

		GeneralERC20(token).transferFrom(from, to, amount);

		require(checkSuccess());

	}



	function approve(address token, address spender, uint256 amount) internal {

		GeneralERC20(token).approve(spender, amount);

		require(checkSuccess());

	}

}





contract IdentityFactory {

	event LogDeployed(address addr, uint256 salt);



	address public relayer;

	constructor(address relayerAddr) public {

		relayer = relayerAddr;

	}



	function deploy(bytes memory code, uint256 salt) public {

		address addr;

		assembly { addr := create2(0, add(code, 0x20), mload(code), salt) }

		require(addr != address(0), "FAILED_DEPLOYING");

		emit LogDeployed(addr, salt);

	}



	function deployAndFund(bytes memory code, uint256 salt, address tokenAddr, uint256 tokenAmount) public {

		require(msg.sender == relayer, "ONLY_RELAYER");

		address addr;

		assembly { addr := create2(0, add(code, 0x20), mload(code), salt) }

		require(addr != address(0), "FAILED_DEPLOYING");

		SafeERC20.transfer(tokenAddr, addr, tokenAmount);

		emit LogDeployed(addr, salt);

	}

}