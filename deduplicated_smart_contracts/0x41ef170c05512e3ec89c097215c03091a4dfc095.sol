// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Strings.sol";

library Colors {
  using Strings for uint256;

  struct Color {
    uint256 hue;
    uint256 saturation;
    uint256 lightness;
  }

  function fromSeedWithMinMax(string memory seed, uint256 hMin, uint256 hMax, uint256 sMin, uint256 sMax, uint256 lMin, uint256 lMax) public pure returns (Color memory) {
    return
      Color(
        valueFromSeed(string(abi.encodePacked("H", seed)), hMin, hMax),
        valueFromSeed(string(abi.encodePacked("S", seed)), sMin, sMax),
        valueFromSeed(string(abi.encodePacked("L", seed)), lMin, lMax)
      );
  }

  function toHSLString(Color memory color) public pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          "hsl(",
          color.hue.toString(),
          ",",
          color.saturation.toString(),
          "%,",
          color.lightness.toString(),
          "%)"
        )
      );
  }

  function valueFromSeed(string memory seed, uint256 from, uint256 to) public pure returns (uint256) {
    if (to <= from) return from;
    return (uint256(keccak256(abi.encodePacked(seed))) % (to - from)) + from;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200,
    "details": {
      "yul": false
    }
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}