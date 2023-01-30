pragma solidity 0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Capped.sol";
import "./Address.sol";

contract RebirthToken is ERC20, ERC20Detailed, ERC20Capped {
    event TransferExtend(address indexed from, address indexed to, uint256 value, string custom);
    using Address for address;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 cap) ERC20Capped(cap) ERC20Detailed(name, symbol, decimals) ERC20() public {
        mint(msg.sender, cap);
    }

}
