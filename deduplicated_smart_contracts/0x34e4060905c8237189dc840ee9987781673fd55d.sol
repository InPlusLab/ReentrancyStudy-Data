pragma solidity ^0.5.0;

import "./Owned.sol";
import "./ERC20Detailed.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";


contract GGCToken is ERC20Detailed, ERC20Pausable, ERC20Burnable, Owned {

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
    ERC20Detailed("GG Coin", "GGC", 18)
    public {
        // Mint the initial token
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
     * A function used by the owner of the contract to
     * make more than one token transfer in a single
     * transaction. Unlike the "bulkTransfer()" function,
     * this function transfers the same value to all recipients
     *
     * @param recipients - A list of receiving addresses
     * @param value - The value to be transferred
     */
    function bulkTransferValue(address[] memory recipients, uint256 value)
    public
    onlyOwner {
        
        // Go through each recipient
        for(uint256 rxIndex = 0; rxIndex<recipients.length; rxIndex++) {

            // Transfer the respective amount to the current recipient
            _transfer(msg.sender, recipients[rxIndex], value);
        }
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

    /**
     * Override the default ownership acceptance
     * operation by adding the new owner
     * as a pauser after executing the default
     * operation
     */
    function acceptOwnership()
    public {

        // Remove the current owner as pauser
        if(isPauser(_owner))
            _removePauser(_owner);

        // Make the new owner a pauser
        if(!isPauser(msg.sender))
            _addPauser(msg.sender);

        // Call the default implementation
        super.acceptOwnership();
    }
}