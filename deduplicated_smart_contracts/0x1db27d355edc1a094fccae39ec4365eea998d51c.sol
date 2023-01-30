/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.8;

interface iENSLoanOwner {
    function controllers(address controller) external view returns (bool);
}

contract UserContract {
    address public owner;
    iENSLoanOwner public ensOwner;

    constructor(
        address _owner,
        address _ensOwner)
        public
    {
        owner = _owner;
        ensOwner = iENSLoanOwner(_ensOwner);
    }

    function transferAsset(
        address asset,
        address payable to,
        uint256 amount)
        public
        returns (uint256 transferAmount)
    {
        require(ensOwner.controllers(msg.sender) || msg.sender == owner);

        bool success;
        if (asset == address(0)) {
            transferAmount = amount == 0 ?
                address(this).balance :
                amount;
            (success, ) = to.call.value(transferAmount)("");
            require(success);
        } else {
            bytes memory data;
            if (amount == 0) {
                (,data) = asset.call(
                    abi.encodeWithSignature(
                        "balanceOf(address)",
                        address(this)
                    )
                );
                assembly {
                    transferAmount := mload(add(data, 32))
                }
            } else {
                transferAmount = amount;
            }
            (success,) = asset.call(
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    to,
                    transferAmount
                )
            );
            require(success);
        }
    }
}