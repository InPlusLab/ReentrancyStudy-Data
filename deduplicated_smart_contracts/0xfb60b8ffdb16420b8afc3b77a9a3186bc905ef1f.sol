/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.24;



// File: @gnosis.pm/util-contracts/contracts/Proxy.sol



/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.

/// @author Alan Lu - <[email protected]>

contract Proxied {

    address public masterCopy;

}



/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.

/// @author Stefan George - <[email protected]>

contract Proxy is Proxied {

    /// @dev Constructor function sets address of master copy contract.

    /// @param _masterCopy Master copy address.

    constructor(address _masterCopy)

        public

    {

        require(_masterCopy != 0);

        masterCopy = _masterCopy;

    }



    /// @dev Fallback function forwards all transactions and returns all received return data.

    function ()

        external

        payable

    {

        address _masterCopy = masterCopy;

        assembly {

            calldatacopy(0, 0, calldatasize())

            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch success

            case 0 { revert(0, returndatasize()) }

            default { return(0, returndatasize()) }

        }

    }

}



// File: contracts/Oracles/Oracle.sol



/// @title Abstract oracle contract - Functions to be implemented by oracles

contract Oracle {



    function isOutcomeSet() public view returns (bool);

    function getOutcome() public view returns (int);

}



// File: contracts/Oracles/CentralizedOracle.sol



contract CentralizedOracleData {



    /*

     *  Events

     */

    event OwnerReplacement(address indexed newOwner);

    event OutcomeAssignment(int outcome);



    /*

     *  Storage

     */

    address public owner;

    bytes public ipfsHash;

    bool public isSet;

    int public outcome;



    /*

     *  Modifiers

     */

    modifier isOwner () {

        // Only owner is allowed to proceed

        require(msg.sender == owner);

        _;

    }

}



contract CentralizedOracleProxy is Proxy, CentralizedOracleData {



    /// @dev Constructor sets owner address and IPFS hash

    /// @param _ipfsHash Hash identifying off chain event description

    constructor(address proxied, address _owner, bytes _ipfsHash)

        public

        Proxy(proxied)

    {

        // Description hash cannot be null

        require(_ipfsHash.length == 46);

        owner = _owner;

        ipfsHash = _ipfsHash;

    }

}



/// @title Centralized oracle contract - Allows the contract owner to set an outcome

/// @author Stefan George - <[email protected]>

contract CentralizedOracle is Proxied, Oracle, CentralizedOracleData {



    /*

     *  Public functions

     */

    /// @dev Replaces owner

    /// @param newOwner New owner

    function replaceOwner(address newOwner)

        public

        isOwner

    {

        // Result is not set yet

        require(!isSet);

        owner = newOwner;

        emit OwnerReplacement(newOwner);

    }



    /// @dev Sets event outcome

    /// @param _outcome Event outcome

    function setOutcome(int _outcome)

        public

        isOwner

    {

        // Result is not set yet

        require(!isSet);

        isSet = true;

        outcome = _outcome;

        emit OutcomeAssignment(_outcome);

    }



    /// @dev Returns if winning outcome is set

    /// @return Is outcome set?

    function isOutcomeSet()

        public

        view

        returns (bool)

    {

        return isSet;

    }



    /// @dev Returns outcome

    /// @return Outcome

    function getOutcome()

        public

        view

        returns (int)

    {

        return outcome;

    }

}



// File: contracts/Oracles/CentralizedOracleFactory.sol



/// @title Centralized oracle factory contract - Allows to create centralized oracle contracts

/// @author Stefan George - <[email protected]>

contract CentralizedOracleFactory {



    /*

     *  Events

     */

    event CentralizedOracleCreation(address indexed creator, CentralizedOracle centralizedOracle, bytes ipfsHash);



    /*

     *  Storage

     */

    CentralizedOracle public centralizedOracleMasterCopy;



    /*

     *  Public functions

     */

    constructor(CentralizedOracle _centralizedOracleMasterCopy)

        public

    {

        centralizedOracleMasterCopy = _centralizedOracleMasterCopy;

    }



    /// @dev Creates a new centralized oracle contract

    /// @param ipfsHash Hash identifying off chain event description

    /// @return Oracle contract

    function createCentralizedOracle(bytes ipfsHash)

        public

        returns (CentralizedOracle centralizedOracle)

    {

        centralizedOracle = CentralizedOracle(new CentralizedOracleProxy(centralizedOracleMasterCopy, msg.sender, ipfsHash));

        emit CentralizedOracleCreation(msg.sender, centralizedOracle, ipfsHash);

    }

}