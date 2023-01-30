pragma solidity 0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Capped.sol";
import "./Address.sol";

contract CrestSamsaraToken is ERC20, ERC20Detailed, ERC20Capped {
    using Address for address;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 cap) ERC20Capped(cap) ERC20Detailed(name, symbol, decimals) ERC20() public {
        mint(msg.sender, cap);
    }
}
