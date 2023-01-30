// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.6;

interface IAMB {
  function messageSender() external view returns (address);
  function messageSourceChainId() external view returns (uint256);
  function messageId() external view returns (bytes32);
}