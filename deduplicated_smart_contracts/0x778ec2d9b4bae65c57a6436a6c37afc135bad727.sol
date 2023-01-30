/**
 *Submitted for verification at Etherscan.io on 2019-12-09
*/

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       Owned.sol
version:    1.1
author:     Anton Jurisevic
            Dominic Romanowski

date:       2018-2-26

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

An Owned contract, to be inherited by other contracts.
Requires its owner to be explicitly set in the constructor.
Provides an onlyOwner access modifier.

To change owner, the current owner must nominate the next owner,
who then has to accept the nomination. The nomination can be
cancelled before it is accepted by the new owner by having the
previous owner change the nomination (setting it to 0).

-----------------------------------------------------------------
*/

pragma solidity 0.4.25;

/**
 * @title A contract with an owner.
 * @notice Contract ownership can be transferred by first nominating the new owner,
 * who must then accept the ownership, which prevents accidental incorrect ownership transfers.
 */
contract Owned {
    address public owner;
    address public nominatedOwner;

    /**
     * @dev Owned Constructor
     */
    constructor(address _owner)
        public
    {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    /**
     * @notice Nominate a new owner of this contract.
     * @dev Only the current owner may nominate a new owner.
     */
    function nominateNewOwner(address _owner)
        external
        onlyOwner
    {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    /**
     * @notice Accept the nomination to be owner.
     */
    function acceptOwnership()
        external
    {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner
    {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


/**
 * @title DappMaintenance contract.
 * @dev When the Synthetix system is on maintenance (upgrade, release...etc) the dApps also need
 * to be put on maintenance so no transactions can be done. The DappMaintenance contract is here to keep a state of
 * the dApps which indicates if yes or no, they should be up or down.
 */
contract DappMaintenance is Owned  {
    bool public isPausedMintr = false;
    bool public isPausedSX = false;

    /**
     * @dev Constructor
     */
    constructor(address _owner)
        Owned(_owner)
        public
    {}

    function setMaintenanceModeAll(bool isPaused)
        external
        onlyOwner
    {
        isPausedMintr = isPaused;
        isPausedSX = isPaused;
        emit MintrMaintenance(isPaused);
        emit SXMaintenance(isPaused);
    }

    function setMaintenanceModeMintr(bool isPaused)
        external
        onlyOwner
    {
        isPausedMintr = isPaused;
        emit MintrMaintenance(isPausedMintr);
    }

    function setMaintenanceModeSX(bool isPaused)
        external
        onlyOwner
    {
        isPausedSX = isPaused;
        emit SXMaintenance(isPausedSX);
    }

    event MintrMaintenance(bool isPaused);
    event SXMaintenance(bool isPaused);
}