pragma solidity ^0.5.0;

import "./Owned.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";

contract OXToken is ERC20Detailed, ERC20Mintable, ERC20Pausable, ERC20Burnable, Owned {

    /**
     * The token constructor. Invoked when the contract
     * is deployed. Initializes the token name, symbol
     * and number of decimals in the Detailed contract.
     * Also mints the initial amount of tokens specified
     * as a parameter. The deploying address is set as
     * the owner, minter and pauser.
     *
     * @param initialSupply - The initial amount of
     *                        tokens to be minted
     */
    constructor(uint256 initialSupply)
    ERC20Detailed("betbox coin", "OX", 18)
    public {

        // Mint the initial tokens
        _mint(msg.sender, initialSupply);
    }

    /**
     * Overrides the default behavior of the transfer
     * function defined in ERC20Pausable by requiring
     * that the contract is either unpaused or being
     * invoked by the contract owner
     *
     * @param to - The receiving address
     * @param value - The amount of tokens to be sent
     * @return bool - A success indicator
     */
    function transfer(address to, uint256 value)
    public
    returns (bool) {

        require(!paused() || isOwner(), "Must either be unpaused or invoked by owner");

        // Transfer the tokens
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * A function used by the owner of the contract to
     * make more than one token transfer in a single
     * transaction. Used to speed-up the process of
     * distributing tokens. Fails if not invoked by
     * the owner of the contract
     *
     * @param recipients - A list of receiving addresses
     * @param values - A list of amounts to be sent
     */
    function bulkTransfer(address[] memory recipients, uint256[] memory values)
    public
    onlyOwner {

        // Make sure there are as many recipients as values to transfer
        require(recipients.length == values.length, "There must be exactly one value for each recipient");

        // Go through each recipient
        for(uint256 rxIndex = 0; rxIndex<recipients.length; rxIndex++) {

            // Transfer the respective amount to the current recipient
            _transfer(msg.sender, recipients[rxIndex], values[rxIndex]);
        }
    }

    /**
     * Used by the owner to remove minters. By default,
     * the ERC20Mintable contract allows minters to
     * renounce their position, but does not give the
     * owner the ability to remove rogue minters
     *
     * @param minter - The address of the minter
     *                 to be removed
     */
    function removeMinter(address minter)
    public
    onlyOwner {

        // Remove the requested minter
        _removeMinter(minter);
    }

    /**
     * Used by the owner to remove pausers. By default,
     * the ERC20Pausable contract allows pausers to
     * renounce their position, but does not give the
     * owner the ability to remove rogue pausers
     *
     * @param pauser - The address of the pauser
     *                 to be removed
     */
    function removePauser(address pauser)
    public
    onlyOwner {

        // Remove the requested pauser
        _removePauser(pauser);
    }

}