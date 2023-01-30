/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

/**
Author: Authereum Labs, Inc.
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


/**
 * @title Owned
 * @author Authereum Labs, Inc.
 * @dev Basic contract to define an owner.
 */
contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /// @dev Throws if the sender is not the owner
    modifier onlyOwner {
        require(msg.sender == owner, "O: Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /// @dev Return the ownership status of an address
    /// @param _potentialOwner Address being checked
    /// @return True if the _potentialOwner is the owner
    function isOwner(address _potentialOwner) external view returns (bool) {
        return owner == _potentialOwner;
    }

    /// @dev Lets the owner transfer ownership of the contract to a new owner
    /// @param _newOwner The new owner
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "O: Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

interface ILoginKeyTransactionValidator {
    /// @dev Reverts if the transaction is invalid
    /// @param _transactions Arrays of transaction data ([to, value, gasLimit, data],[...],...)
    /// @param _validationData Data used by the LoginKeyTransactionValidator and is signed in the 
    ///        login key attestation
    /// @param _relayerAddress Address that called the account contract
    function validateTransactions(
        bytes[] calldata _transactions,
        bytes calldata _validationData,
        address _relayerAddress
    ) external;

    /// @dev Called after a transaction is executed to record information about the transaction
    ///      and perform any post-execution validation
    /// @param _transactions Arrays of transaction data ([to, value, gasLimit, data],[...],...)
    /// @param _validationData Data used by the LoginKeyTransactionValidator and is signed in the 
    ///        login key attestation
    /// @param _relayerAddress Address that called the account contract
    function transactionsDidExecute(
        bytes[] calldata _transactions,
        bytes calldata _validationData,
        address _relayerAddress
    ) external;
}

/**
 * @title AuthereumLoginKeyValidator
 * @author Authereum Labs, Inc.
 * @dev This contract used to validate Login Key transactions. Its address is included in the
 *      loginKeyRestrictionsData that is a part of the data signed for a loginKeyAttestationSignature.
 */
contract AuthereumLoginKeyValidator is Owned, ILoginKeyTransactionValidator {

    string constant public name = "Authereum Login Key Validator";
    string constant public version = "2020070100";

    /**
     * Events
     */

    event RelayerAdded(address indexed relayer);
    event RelayerRemoved(address indexed relayer);

    /**
     * State
     */

    mapping(address => bool) public relayerIsAllowed;

    /// @dev Returns true and an empty string if transactions are valid and false and an error
    ///      message if it's invalid.
    /// @dev validateTransaction MUST return an error message if `success` is `false`
    //  @param _transactions The encoded transactions being executed
    /// @param _validationData The encoded data containing the expiration time
    /// @param _relayerAddress The address calling the account contract
    function validateTransactions(
        bytes[] calldata,
        bytes calldata _validationData,
        address _relayerAddress
    )
        external
    {
        uint256 loginKeyExpirationTime = abi.decode(_validationData, (uint256));

        // Check that loginKey is not expired
        require(loginKeyExpirationTime > now, "LKV: Login key is expired");

        // Check that _relayerAddress is an Authereum relayer
        require(relayerIsAllowed[_relayerAddress], "LKV: Invalid relayer");
    }

    /// @dev Called after a transaction is executed to record information about the transaction
    ///      for validation such as value transferred
    //  @param _transactions The encoded transactions being executed
    //  @param _validationData The encoded data containing the expiration time
    //  @param _relayerAddress The address calling the account contract
    function transactionsDidExecute(
        bytes[] calldata,
        bytes calldata,
        address
    )
        external
    { }

    /// @dev Allow an array of relayers
    /// @param _newRelayers The list of relayers to be allowed
    function addRelayers(address[] calldata _newRelayers) external onlyOwner {
        for (uint256 i = 0; i < _newRelayers.length; i++) {
            address relayer = _newRelayers[i];
            require(relayerIsAllowed[relayer] == false, "LKV: Relayer has already been added");
            relayerIsAllowed[relayer] = true;
            emit RelayerAdded(relayer);
        }
    }

    /// @dev Remove a relayer from the allowlist
    /// @param _relayersToRemove The list of relayers to remove from the allowlist
    function removeRelayers(address[] calldata _relayersToRemove) external onlyOwner {
        for (uint256 i = 0; i < _relayersToRemove.length; i++) {
            address relayer = _relayersToRemove[i];
            require(relayerIsAllowed[relayer] == true, "LKV: Address is not a relayer");
            relayerIsAllowed[relayer] = false;
            emit RelayerRemoved(relayer);
        }
    }
}