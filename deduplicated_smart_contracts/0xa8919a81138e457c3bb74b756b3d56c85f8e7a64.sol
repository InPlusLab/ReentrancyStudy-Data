/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.0;

interface IERC1155 {
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function mint(
    	address _to,
    	uint256 _id,
    	uint256 _quantity,
    	bytes calldata _data
    ) external;
}

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract yTSLAFuelStation {
  IERC1155 public dmc = IERC1155(0x6E91869090a430e6ba6fFa7c585742E56Fed2247);
  IERC20 public ytsla = IERC20(0x5322A3556F979cE2180B30e689a9436fDDCB1021);

    function mint() public {
        require(ytsla.balanceOf(msg.sender) >= 99 ether);
        ytsla.transferFrom(msg.sender, address(this), 99 ether);
        if (dmc.balanceOf(address(this), 11) >= 1) {
            dmc.safeTransferFrom(address(this), msg.sender, 11, 1, "");
        } else {
            dmc.mint(msg.sender, 11, 1, "");
        }
    }
    function redeem() public {
        require(dmc.balanceOf(msg.sender, 11) >= 1);
        dmc.safeTransferFrom(msg.sender, address(this), 11, 1, "");
        ytsla.transfer(msg.sender, 99 ether);
    }
  
  	function onERC1155Received(
		address _operator,
		address, // _from
		uint256, // _id
		uint256, // _amount
		bytes memory // _data
	) public view returns (bytes4) {
		require(msg.sender == address(dmc), "onERC1155BatchReceived:: invalid token address");
		require(_operator == address(this), "onERC1155BatchReceived:: operator must be fuel station contract");

		// Return success
		return this.onERC1155Received.selector;
	}
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    	return
    		interfaceID == 0x01ffc9a7 || // ERC-165 support
    		interfaceID == 0x4e2312e0; // ERC-1155 `ERC1155TokenReceiver` support
    }
}