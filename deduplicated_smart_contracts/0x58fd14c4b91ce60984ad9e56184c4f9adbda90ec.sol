pragma solidity ^0.5.2;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

contract KOL is ERC20, ERC20Detailed, ERC20Burnable {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * (10 ** uint256(DECIMALS));

    constructor(address initialHolder) public ERC20Detailed("KOL Token", "KOL", DECIMALS) {
        _mint(initialHolder, INITIAL_SUPPLY);
    }
}
