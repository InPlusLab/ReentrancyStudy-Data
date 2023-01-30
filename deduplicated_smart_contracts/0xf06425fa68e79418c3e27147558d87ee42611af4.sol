pragma solidity ^0.5.7;

import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
import "./Pausable.sol";
import "./Permitted.sol";

/*solium-disable-next-line*/
contract FlowCoin is ERC20Detailed("Flow", "FLOW", 18), ERC20Burnable, Pausable, Permitted {

    bool public finalized;

    event Burn(address indexed burner, uint256 amount);

    modifier requireNotFinalized() {
        require(
            false == finalized,
            ERROR_NOT_ALLOWED
        );
        _;
    }

    constructor(address _permissionsManagement)
        public
        Permitted(_permissionsManagement)
    {}

    function finalize()
        public
        requirePermission(CAN_FINALIZE)
        requireNotFinalized
        returns (bool)
    {
        finalized = true;
    }

    /**
    * @dev Function to mint coins
    * @param to The address that will receive the minted tokens.
    * @param value The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address to, uint256 value)
        public
        requirePermission(CAN_MINT_COINS)
        requireNotFinalized
        returns (bool)
    {
        _mint(to, value);
        return true;
    }

    /**
    * @dev Called by a pauser to pause, triggers stopped state.
    */
    function pause() public requirePermission(CAN_PAUSE_COINS) whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public requirePermission(CAN_PAUSE_COINS) whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function transfer(address to, uint256 value)
        public
        whenNotPaused
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value)
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue)
        public
        whenNotPaused
        returns (bool)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue)
        public
        whenNotPaused
        returns (bool)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function _burn(address account, uint256 value)
        internal
        requireNotFinalized
    {
        super._burn(account, value);
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
    function _burnFrom(address account, uint256 value)
        internal
        requireNotFinalized
    {
        emit Burn(msg.sender, value);
        if (
            false == hasPermission(msg.sender, CAN_BURN_COINS)
        ) {
            super._burnFrom(account, value);
        } else {
            _burn(account, value);
        }
    }

}

