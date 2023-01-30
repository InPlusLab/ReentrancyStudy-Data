/**
 *Submitted for verification at Etherscan.io on 2021-03-03
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

interface IERC1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 value, bytes calldata _data) external;
    function balanceOf(address _owner, uint256 _id) external view returns(uint256);
}

interface IERC20 {
    function balanceOf(address _who) external returns (uint256);
}

library Math {
    function add(uint a, uint b) internal pure returns (uint c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}
    function sub(uint a, uint b) internal pure returns (uint c) {require((c = a - b) <= a, "BoringMath: Underflow");}
    function mul(uint a, uint b) internal pure returns (uint c) {require(a == 0 || (c = a * b)/b == a, "BoringMath: Mul Overflow");}
}

contract NFTSale {
    using Math for uint256;

    IERC1155 public nft;
    uint256  public price = 0.2 ether;
    uint256  public id;
    address  payable public multisig;
    uint256  public start;
    
    event Buy(address buyer, uint256 amount);

    constructor(address payable _multisig, uint256 _start) public {
        multisig = _multisig;
        start = _start;
        nft = IERC1155(0x13bAb10a88fc5F6c77b87878d71c9F1707D2688A);
        id = 36;
    }

    function buy(uint256 amount) public payable {
        require(msg.sender == tx.origin, "no contracts");
        require(block.timestamp >= start, "early");
        require(amount <= supply(), "ordered too many");
        require(msg.value == price.mul(amount), "wrong amount");

        nft.safeTransferFrom(address(this), msg.sender, id, amount, new bytes(0x0));
        
        multisig.transfer(address(this).balance);
        
        emit Buy(msg.sender, amount);
    }
    
    function supply() public view returns(uint256) {
        return nft.balanceOf(address(this), id);
    }
    
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

}