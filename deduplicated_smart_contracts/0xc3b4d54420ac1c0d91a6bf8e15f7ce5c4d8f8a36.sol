// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IArchToken.sol";
import "./lib/ReentrancyGuard.sol";

/**
 * @title Multisend
 * @dev Allows the sender to perform batch transfers of ARCH tokens
 */
contract Multisend is ReentrancyGuard {

    /// @notice ARCH token
    IArchToken public token;

    /**
     * @notice Construct a new Multisend contract
     * @param _token Address of ARCH token
     */
    constructor(IArchToken _token) {
        token = _token;
    }

    /**
     * @notice Batches multiple transfers
     * @dev Must approve this contract for `totalAmount` before calling
     * @param totalAmount Total amount to be transferred
     * @param recipients Array of accounts to receive transfers
     * @param amounts Array of amounts to send to accounts via transfers
     */
    function batchTransfer(
        uint256 totalAmount,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external nonReentrant {
        _batchTransfer(totalAmount, recipients, amounts);
    }

    /**
     * @notice Batches multiple transfers with approval provided by permit function
     * @param totalAmount Total amount to be transferred
     * @param recipients Array of accounts to receive transfers
     * @param amounts Array of amounts to send to accounts via transfers
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function batchTransferWithPermit(
        uint256 totalAmount,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {
        token.permit(msg.sender, address(this), totalAmount, deadline, v, r, s);
        _batchTransfer(totalAmount, recipients, amounts);
    }

    /**
     * @notice Internal implementation of batch transfer
     * @param totalAmount Total amount to be transferred
     * @param recipients Array of accounts to receive transfers
     * @param amounts Array of amounts to send to accounts via transfers
     */
    function _batchTransfer(
        uint256 totalAmount,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) internal {
        require(token.allowance(msg.sender, address(this)) >= totalAmount, "Multisend::_batchTransfer: allowance too low");
        require(token.balanceOf(msg.sender) >= totalAmount, "Multisend::_batchTransfer: sender balance too low");
        require(recipients.length == amounts.length, "Multisend::_batchTransfer: recipients length != amounts length");
        uint256 amountTransferred = 0;
        for (uint256 i; i < recipients.length; i++) {
            bool success = token.transferFrom(msg.sender, recipients[i], amounts[i]);
            require(success, "Multisend::_batchTransfer: failed to transfer tokens");
            amountTransferred = amountTransferred + amounts[i];
        }
        require(amountTransferred == totalAmount, "Multisend::_batchTransfer: total != transferred amount");
    }
}