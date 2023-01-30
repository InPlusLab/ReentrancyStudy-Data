/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

/*! SPDX-License-Identifier: MIT License */

pragma solidity 0.6.8;

interface IEtherChain {
    function drawPool() external;
    function pool_last_draw() view external returns(uint40);
}

contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns(address payable) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address payable _new_owner) public onlyOwner {
        require(_new_owner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, _new_owner);
        _owner = _new_owner;
    }
}

contract ReOwner is Ownable {
    IEtherChain public etherChain;

    constructor() public {
        etherChain = IEtherChain(0xFa85069E3D1Ca1B09945CF11d2365386b1E4430A);
    }

    receive() payable external {}

    function drawPool() external onlyOwner {
        require(etherChain.pool_last_draw() + 1 days < block.timestamp); 

        etherChain.drawPool();
    }

    function withdraw() external onlyOwner {
        owner().transfer(address(this).balance);
    }
}