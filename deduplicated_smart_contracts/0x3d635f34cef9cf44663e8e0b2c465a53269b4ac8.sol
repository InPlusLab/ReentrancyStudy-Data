pragma solidity ^0.5.7;

import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";
import "./LockupContract.sol";
import "./IERC20Mintable.sol";

/*solium-disable-next-line*/
contract BlobCoin is LockupContract, IERC20Mintable, ERC20Detailed("Blob Coin", "BLOB", 18), ERC20Burnable {

    event Burn(address indexed burner, uint256 amount);

    constructor(address _management)
    public
    LockupContract(_management)
    {}

    /**
    * @dev Function to mint coins
    * @param to The address that will receive the minted tokens.
    * @param value The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address to, uint256 value)
    public
    requirePermission(CAN_MINT_COINS)
    returns (bool)
    {
        _mint(to, value);
        return true;
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account
    * or by address with permission CAN_BURN_COINS. Uses the
    * internal burn function.
    * Emits an Burn event (reflecting the burned amount).
    * Emits an Approval event (reflecting the reduced allowance).
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burned.
    */
    function _burnFrom(address account, uint256 value) internal {
        emit Burn(msg.sender, value);
        if (
            false == hasPermission(msg.sender, CAN_BURN_COINS)
        ) {
            super._burnFrom(account, value);
        } else {
            _burn(account, value);
        }
    }

    /**
    * @dev  Overridden Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(
            isTransferAllowed(from, value, balanceOf(from)) == true,
            ERROR_WRONG_AMOUNT
        );
        return super._transfer(from, to, value);
    }
}
