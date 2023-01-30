pragma solidity ^0.5.8;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./MinterRole.sol";


// ----------------------------------------------------------------------------
// Crypto Commonwealth token contract
// Symbol      : COMM
// Name        : Crypto Commonwealth
// Total supply: 1000000000
// Decimals    : 18
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract COMM is Ownable, ERC20, MinterRole, ERC20Detailed {


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor () public ERC20Detailed("Crypto Commonwealth", "COMM", 18) {
        _mint(msg.sender, 1000000000 * (10 ** uint256(decimals())));
    }


    // ------------------------------------------------------------------------
    // @dev Function to mint tokens
    // @param to The address that will receive the minted tokens.
    // @param value The amount of tokens to mint.
    // @return A boolean that indicates if the operation was successful.
    // ------------------------------------------------------------------------
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }

    // ------------------------------------------------------------------------
    //@dev Destroys `amount` tokens from the caller.
    //See {ERC20-_burn}.
    // ------------------------------------------------------------------------
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function() external payable {
        revert();
    }
}