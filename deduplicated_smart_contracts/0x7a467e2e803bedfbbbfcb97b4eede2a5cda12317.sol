/**
 *Submitted for verification at Etherscan.io on 2019-06-23
*/

pragma solidity ^0.5.0;

library SafeERC20Detailed {

    function safeDecimals(address token) internal returns (uint256 decimals) {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSignature("decimals()"));

        if (!success) {
            (success, data) = address(token).call(abi.encodeWithSignature("Decimals()"));
        }

        if (!success) {
            (success, data) = address(token).call(abi.encodeWithSignature("DECIMALS()"));
        }

        if (!success) {
            return 18;
        }

        assembly {
            decimals := mload(add(data, 32))
        }
    }

    function safeSymbol(address token) internal returns(bytes32 symbol) {

        (bool success, bytes memory data) = token.call(abi.encodeWithSignature("symbol()"));

        if (!success) {
            (success, data) = token.call(abi.encodeWithSignature("Symbol()"));
        }

        if (!success) {
            (success, data) = token.call(abi.encodeWithSignature("SYMBOL()"));
        }

        if (!success) {
            return 0;
        }

        uint256 dataLength = data.length;
        assembly {
            symbol := mload(add(data, dataLength))
        }
    }
}

contract SafeAllowanceIERC20 {
    function allowance(address spender, address who) public returns(uint256);
}

contract Approved {

    using SafeERC20Detailed for address;

    function allowances(
        address source,
        address[] calldata tokens,
        address[] calldata spenders
    )
        external
        returns(
            uint256[] memory results,
            uint256[] memory decimals,
            bytes32[] memory symbols
        )
    {
        require(tokens.length == spenders.length, "Invalid argument array lengths");

        results = new uint256[](tokens.length);
        decimals = new uint256[](tokens.length);
        symbols = new bytes32[](tokens.length);

        for (uint i = 0; i < tokens.length; i++) {

            results[i] = SafeAllowanceIERC20(tokens[i]).allowance(source, spenders[i]);
            decimals[i] = tokens[i].safeDecimals();
            symbols[i] = tokens[i].safeSymbol();
        }
    }
}