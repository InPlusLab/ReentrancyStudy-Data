pragma solidity ^0.5.4;

import "./AuctionityLibrary_V1.sol";

/// @title Pausable
/// @dev Base contract which allows children to implement an emergency stop mechanism.

contract AuctionityPausable_V1 is AuctionityLibrary_V1 {
    event LogPaused_V1(bool paused);

    /// @notice constructor, default is false, no incidence if called by proxy
    constructor() public {
        paused = false;
    }

    /// @notice delegate receive of get Paused
    /// @return _isPaused bool
    function delegatedReceiveGetPaused_V1()
        public
        payable
        returns (bool _isPaused)
    {
        return getPaused_V1();
    }

    /// @notice verify if is paused
    /// @return _isPaused bool
    function getPaused_V1() public returns (bool _isPaused) {
        if (delegatedSendIsContractOwner_V1() == true) {
            return false;
        }
        return paused;
    }

    /// @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused_V1() {
        require(!delegatedSendGetPaused_V1(), "Contrat is paused");
        _;
    }

    /// @dev Modifier to make a function callable only when the contract is paused.
    modifier whenPaused_V1() {
        require(delegatedSendGetPaused_V1(), "Contrat is not paused");
        _;
    }

    /// @notice called by the owner to pause, triggers stopped state
    /// @param _paused bool
    function setPaused_V1(bool _paused) public {
        require(delegatedSendIsContractOwner_V1(), "Not Contract owner");
        paused = _paused;
        emit LogPaused_V1(_paused);
    }
}
