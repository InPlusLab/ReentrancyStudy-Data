pragma solidity ^0.5.16;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./MinterRole.sol";


// ----------------------------------------------------------------------------
// Crypto Commonwealth token contract
// Symbol      : CBND
// Name        : Crypto Commonwealth's 1-month Convertible Crypto Bond
// Total supply: 40000000
// Decimals    : 18
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract CBND is Ownable, ERC20, MinterRole, ERC20Detailed {


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor () public ERC20Detailed("Crypto Commonwealth's 1-month Convertible Crypto Bond", "CBND", 18) {
        _mint(msg.sender, 40000000 * (10 ** uint256(decimals())));
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