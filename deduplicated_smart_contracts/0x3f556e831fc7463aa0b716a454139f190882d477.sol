// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import {Ownable} from "../../vendor/Ownable.sol";
import {GelatoBytes} from "../../lib/GelatoBytes.sol";

/// @title PriceOracleResolver
/// @notice Contract with convenience methods to retrieve oracle addresses or to mock test.
/// @dev Can be used to:
///  - Query oracle address for Gelato Condition payloads on frontend
///  - Test Conditions by using `getMockPrice(address _test)` as `oraclePayload`
contract PriceOracleResolver is Ownable {
    using GelatoBytes for bytes;

    mapping(string => address) public oracle;
    mapping(string => bytes) public oraclePayload;
    mapping(address => uint256) public mockPrice;

    /// @notice Adds a new Oracle address
    /// @dev Only owner can call this, but existing oracle entries are immutable
    /// @param _oracle The descriptor of the oracle e.g. ETH/USD-Maker-v1
    /// @param _oracleAddress The address of the oracle contract
    /// @param _oraclePayload The payload with function selector for the oracle request.
    function addOracle(
        string memory _oracle,
        address _oracleAddress,
        bytes calldata _oraclePayload
    ) external onlyOwner {
        require(
            oracle[_oracle] == address(0),
            "PriceOracleResolver.addOracle: set"
        );
        oracle[_oracle] = _oracleAddress;
        oraclePayload[_oracle] = _oraclePayload;
    }

    /// @notice Function that allows easy oracle data testing in production.
    /// @dev Your mock prices cannot be overriden by someone else.
    /// @param _mockPrice The mock data you want to test against.
    function setMockPrice(uint256 _mockPrice) public {
        mockPrice[msg.sender] = _mockPrice;
    }

    /// @notice Use with setMockPrice for easy testing in production.
    /// @dev Encode oracle=PriceOracleResolver and oraclePayload=getMockPrice(tester)
    ///  to test your Conditions or Actions that make dynamic calls to price oracles.
    /// @param _tester The msg.sender during setMockPrice.
    /// @return The tester's mockPrice.
    function getMockPrice(address _tester) external view returns (uint256) {
        return mockPrice[_tester];
    }

    /// @notice A generelized getter for a price supplied by an oracle contract.
    /// @dev The oracle returndata must be formatted as a single uint256.
    /// @param _oracle The descriptor of our oracle e.g. ETH/USD-Maker-v1
    /// @return The uint256 oracle price
    function getPrice(string memory _oracle) external view returns (uint256) {
        address oracleAddr = oracle[_oracle];
        if (oracleAddr == address(0))
            revert("PriceOracleResolver.getPrice: no oracle");
        (bool success, bytes memory returndata) = oracleAddr.staticcall(
            oraclePayload[_oracle]
        );
        if (!success)
            returndata.revertWithError("PriceOracleResolver.getPrice:");
        return abi.decode(returndata, (uint256));
    }
}