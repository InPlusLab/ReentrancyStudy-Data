/**
 *Submitted for verification at Etherscan.io on 2020-03-27
*/

// File: contracts/compliance/ICompliance.sol

pragma solidity ^0.5.10;

interface ICompliance {
    function canTransfer(address _from, address _to, uint256 value) external returns (bool);
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/roles/AgentRole.sol

pragma solidity ^0.5.0;



contract AgentRole is Ownable {
    using Roles for Roles.Role;

    event AgentAdded(address indexed account);
    event AgentRemoved(address indexed account);

    Roles.Role private _agents;

    modifier onlyAgent() {
        require(isAgent(msg.sender), "AgentRole: caller does not have the Agent role");
        _;
    }

    function isAgent(address account) public view returns (bool) {
        return _agents.has(account);
    }

    function addAgent(address account) public onlyOwner {
        _addAgent(account);
    }

    function removeAgent(address account) public onlyOwner {
        _removeAgent(account);
    }

    function _addAgent(address account) internal {
        _agents.add(account);
        emit AgentAdded(account);
    }

    function _removeAgent(address account) internal {
        _agents.remove(account);
        emit AgentRemoved(account);
    }
}

// File: @onchain-id/solidity/contracts/IERC734.sol

pragma solidity ^0.5.10;

/**
 * @dev Interface of the ERC734 (Key Holder) standard as defined in the EIP.
 */
interface IERC734 {
    /**
     * @dev Definition of the structure of a Key.
     *
     * Specification: Keys are cryptographic public keys, or contract addresses associated with this identity.
     * The structure should be as follows:
     *   - key: A public key owned by this identity
     *      - purposes: uint256[] Array of the key purposes, like 1 = MANAGEMENT, 2 = EXECUTION
     *      - keyType: The type of key used, which would be a uint256 for different key types. e.g. 1 = ECDSA, 2 = RSA, etc.
     *      - key: bytes32 The public key. // Its the Keccak256 hash of the key
     */
    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    /**
     * @dev Emitted when an execution request was approved.
     *
     * Specification: MUST be triggered when approve was successfully called.
     */
    event Approved(uint256 indexed executionId, bool approved);

    /**
     * @dev Emitted when an execute operation was approved and successfully performed.
     *
     * Specification: MUST be triggered when approve was called and the execution was successfully approved.
     */
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    /**
     * @dev Emitted when an execution request was performed via `execute`.
     *
     * Specification: MUST be triggered when execute was successfully called.
     */
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    /**
     * @dev Emitted when a key was added to the Identity.
     *
     * Specification: MUST be triggered when addKey was successfully called.
     */
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    /**
     * @dev Emitted when a key was removed from the Identity.
     *
     * Specification: MUST be triggered when removeKey was successfully called.
     */
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    /**
     * @dev Emitted when the list of required keys to perform an action was updated.
     *
     * Specification: MUST be triggered when changeKeysRequired was successfully called.
     */
    event KeysRequiredChanged(uint256 purpose, uint256 number);


    /**
     * @dev Adds a _key to the identity. The _purpose specifies the purpose of the key.
     *
     * Triggers Event: `KeyAdded`
     *
     * Specification: MUST only be done by keys of purpose 1, or the identity itself. If it's the identity itself, the approval process will determine its approval.
     */
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success);

    /**
    * @dev Approves an execution or claim addition.
    *
    * Triggers Event: `Approved`, `Executed`
    *
    * Specification:
    * This SHOULD require n of m approvals of keys purpose 1, if the _to of the execution is the identity contract itself, to successfully approve an execution.
    * And COULD require n of m approvals of keys purpose 2, if the _to of the execution is another contract, to successfully approve an execution.
    */
    function approve(uint256 _id, bool _approve) external returns (bool success);

    /**
     * @dev Changes the keys required to perform an action for a specific purpose. (This is the n in an n of m multisig approval process.)
     *
     * Triggers Event: `KeysRequiredChanged`
     *
     * Specification: MUST only be done by keys of purpose 1, or the identity itself. If it's the identity itself, the approval process will determine its approval.
     */
    function changeKeysRequired(uint256 purpose, uint256 number) external;

    /**
     * @dev Passes an execution instruction to an ERC725 identity.
     *
     * Triggers Event: `ExecutionRequested`, `Executed`
     *
     * Specification:
     * SHOULD require approve to be called with one or more keys of purpose 1 or 2 to approve this execution.
     * Execute COULD be used as the only accessor for `addKey` and `removeKey`.
     */
    function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (uint256 executionId);

    /**
     * @dev Returns the full key data, if present in the identity.
     */
    function getKey(bytes32 _key) external view returns (uint256[] memory purposes, uint256 keyType, bytes32 key);

    /**
     * @dev Returns the list of purposes associated with a key.
     */
    function getKeyPurposes(bytes32 _key) external view returns(uint256[] memory _purposes);

    /**
     * @dev Returns an array of public key bytes32 held by this identity.
     */
    function getKeysByPurpose(uint256 _purpose) external view returns (bytes32[] memory keys);

    /**
     * @dev Returns number of keys required for purpose.
     */
    function getKeysRequired(uint256 purpose) external view returns (uint256);

    /**
     * @dev Returns TRUE if a key is present and has the given purpose. If the key is not present it returns FALSE.
     */
    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool exists);

    /**
     * @dev Removes _purpose for _key from the identity.
     *
     * Triggers Event: `KeyRemoved`
     *
     * Specification: MUST only be done by keys of purpose 1, or the identity itself. If it's the identity itself, the approval process will determine its approval.
     */
    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success);
}

// File: @onchain-id/solidity/contracts/ERC734.sol

pragma solidity ^0.5.10;


/**
 * @dev Implementation of the `IERC734` "KeyHolder" interface.
 */
contract ERC734 is IERC734 {
    uint256 public constant MANAGEMENT_KEY = 1;
    uint256 public constant ACTION_KEY = 2;
    uint256 public constant CLAIM_SIGNER_KEY = 3;
    uint256 public constant ENCRYPTION_KEY = 4;

    uint256 private executionNonce;

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    mapping (bytes32 => Key) private keys;
    mapping (uint256 => bytes32[]) private keysByPurpose;
    mapping (uint256 => Execution) private executions;

    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    constructor() public {
        bytes32 _key = keccak256(abi.encode(msg.sender));

        keys[_key].key = _key;
        keys[_key].purposes = [1];
        keys[_key].keyType = 1;

        keysByPurpose[1].push(_key);

        emit KeyAdded(_key, 1, 1);
    }

    /**
       * @notice Implementation of the getKey function from the ERC-734 standard
       *
       * @param _key The public key.  for non-hex and long keys, its the Keccak256 hash of the key
       *
       * @return Returns the full key data, if present in the identity.
       */
    function getKey(bytes32 _key)
    public
    view
    returns(uint256[] memory purposes, uint256 keyType, bytes32 key)
    {
        return (keys[_key].purposes, keys[_key].keyType, keys[_key].key);
    }

    /**
    * @notice gets the purposes of a key
    *
    * @param _key The public key.  for non-hex and long keys, its the Keccak256 hash of the key
    *
    * @return Returns the purposes of the specified key
    */
    function getKeyPurposes(bytes32 _key)
    public
    view
    returns(uint256[] memory _purposes)
    {
        return (keys[_key].purposes);
    }

    /**
        * @notice gets all the keys with a specific purpose from an identity
        *
        * @param _purpose a uint256[] Array of the key types, like 1 = MANAGEMENT, 2 = ACTION, 3 = CLAIM, 4 = ENCRYPTION
        *
        * @return Returns an array of public key bytes32 hold by this identity and having the specified purpose
        */
    function getKeysByPurpose(uint256 _purpose)
    public
    view
    returns(bytes32[] memory _keys)
    {
        return keysByPurpose[_purpose];
    }

    /**
        * @notice implementation of the addKey function of the ERC-734 standard
        * Adds a _key to the identity. The _purpose specifies the purpose of key. Initially we propose four purposes:
        * 1: MANAGEMENT keys, which can manage the identity
        * 2: ACTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
        * 3: CLAIM signer keys, used to sign claims on other identities which need to be revokable.
        * 4: ENCRYPTION keys, used to encrypt data e.g. hold in claims.
        * MUST only be done by keys of purpose 1, or the identity itself.
        * If its the identity itself, the approval process will determine its approval.
        *
        * @param _key keccak256 representation of an ethereum address
        * @param _type type of key used, which would be a uint256 for different key types. e.g. 1 = ECDSA, 2 = RSA, etc.
        * @param _purpose a uint256[] Array of the key types, like 1 = MANAGEMENT, 2 = ACTION, 3 = CLAIM, 4 = ENCRYPTION
        *
        * @return Returns TRUE if the addition was successful and FALSE if not
        */

    function addKey(bytes32 _key, uint256 _purpose, uint256 _type)
    public
    returns (bool success)
    {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have management key");
        }

        if (keys[_key].key == _key) {
            for (uint keyPurposeIndex = 0; keyPurposeIndex < keys[_key].purposes.length; keyPurposeIndex++) {
                uint256 purpose = keys[_key].purposes[keyPurposeIndex];

                if (purpose == _purpose) {
                    revert("Conflict: Key already has purpose");
                }
            }

            keys[_key].purposes.push(_purpose);
        } else {
            keys[_key].key = _key;
            keys[_key].purposes = [_purpose];
            keys[_key].keyType = _type;
        }

        keysByPurpose[_purpose].push(_key);

        emit KeyAdded(_key, _purpose, _type);

        return true;
    }

    function approve(uint256 _id, bool _approve)
    public
    returns (bool success)
    {
        require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 2), "Sender does not have action key");

        emit Approved(_id, _approve);

        if (_approve == true) {
            executions[_id].approved = true;

            (success,) = executions[_id].to.call.value(executions[_id].value)(abi.encode(executions[_id].data, 0));

            if (success) {
                executions[_id].executed = true;

                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return true;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return false;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }

    function execute(address _to, uint256 _value, bytes memory _data)
    public
    payable
    returns (uint256 executionId)
    {
        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encode(msg.sender)), 2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }

    function removeKey(bytes32 _key, uint256 _purpose)
    public
    returns (bool success)
    {
        require(keys[_key].key == _key, "NonExisting: Key isn't registered");

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        require(keys[_key].purposes.length > 0, "NonExisting: Key doesn't have such purpose");

        uint purposeIndex = 0;
        while (keys[_key].purposes[purposeIndex] != _purpose) {
            purposeIndex++;

            if (purposeIndex >= keys[_key].purposes.length) {
                break;
            }
        }

        require(purposeIndex < keys[_key].purposes.length, "NonExisting: Key doesn't have such purpose");

        keys[_key].purposes[purposeIndex] = keys[_key].purposes[keys[_key].purposes.length - 1];
        keys[_key].purposes.pop();

        uint keyIndex = 0;

        while (keysByPurpose[_purpose][keyIndex] != _key) {
            keyIndex++;
        }

        keysByPurpose[_purpose][keyIndex] = keysByPurpose[_purpose][keysByPurpose[_purpose].length - 1];
        keysByPurpose[_purpose].pop();

        uint keyType = keys[_key].keyType;

        if (keys[_key].purposes.length == 0) {
            delete keys[_key];
        }

        emit KeyRemoved(_key, _purpose, keyType);

        return true;
    }

    /**
    * @notice implementation of the changeKeysRequired from ERC-734 standard
    */
    function changeKeysRequired(uint256 purpose, uint256 number) external
    {
        revert();
    }

    /**
    * @notice implementation of the getKeysRequired from ERC-734 standard
    */
    function getKeysRequired(uint256 purpose) external view returns(uint256 number)
    {
        revert();
    }

    /**
    * @notice Returns true if the key has MANAGEMENT purpose or the specified purpose.
    */
    function keyHasPurpose(bytes32 _key, uint256 _purpose)
    public
    view
    returns(bool result)
    {
        Key memory key = keys[_key];
        if (key.key == 0) return false;

        for (uint keyPurposeIndex = 0; keyPurposeIndex < key.purposes.length; keyPurposeIndex++) {
            uint256 purpose = key.purposes[keyPurposeIndex];

            if (purpose == MANAGEMENT_KEY || purpose == _purpose) return true;
        }

        return false;
    }
}

// File: @onchain-id/solidity/contracts/IERC735.sol

pragma solidity ^0.5.10;

/**
 * @dev Interface of the ERC735 (Claim Holder) standard as defined in the EIP.
 */
interface IERC735 {

    /**
     * @dev Emitted when a claim request was performed.
     *
     * Specification: Is not clear
     */
    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    /**
     * @dev Emitted when a claim was added.
     *
     * Specification: MUST be triggered when a claim was successfully added.
     */
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    /**
     * @dev Emitted when a claim was removed.
     *
     * Specification: MUST be triggered when removeClaim was successfully called.
     */
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    /**
     * @dev Emitted when a claim was changed.
     *
     * Specification: MUST be triggered when changeClaim was successfully called.
     */
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    /**
     * @dev Definition of the structure of a Claim.
     *
     * Specification: Claims are information an issuer has about the identity holder.
     * The structure should be as follows:
     *   - claim: A claim published for the Identity.
     *      - topic: A uint256 number which represents the topic of the claim. (e.g. 1 biometric, 2 residence (ToBeDefined: number schemes, sub topics based on number ranges??))
     *      - scheme : The scheme with which this claim SHOULD be verified or how it should be processed. Its a uint256 for different schemes. E.g. could 3 mean contract verification, where the data will be call data, and the issuer a contract address to call (ToBeDefined). Those can also mean different key types e.g. 1 = ECDSA, 2 = RSA, etc. (ToBeDefined)
     *      - issuer: The issuers identity contract address, or the address used to sign the above signature. If an identity contract, it should hold the key with which the above message was signed, if the key is not present anymore, the claim SHOULD be treated as invalid. The issuer can also be a contract address itself, at which the claim can be verified using the call data.
     *      - signature: Signature which is the proof that the claim issuer issued a claim of topic for this identity. it MUST be a signed message of the following structure: `keccak256(abi.encode(identityHolder_address, topic, data))`
     *      - data: The hash of the claim data, sitting in another location, a bit-mask, call data, or actual data based on the claim scheme.
     *      - uri: The location of the claim, this can be HTTP links, swarm hashes, IPFS hashes, and such.
     */
    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }

    /**
     * @dev Get a claim by its ID.
     *
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address, uint256 topic))`.
     */
    function getClaim(bytes32 _claimId) external view returns(uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);

    /**
     * @dev Returns an array of claim IDs by topic.
     */
    function getClaimIdsByTopic(uint256 _topic) external view returns(bytes32[] memory claimIds);

    /**
     * @dev Add or update a claim.
     *
     * Triggers Event: `ClaimRequested`, `ClaimAdded`, `ClaimChanged`
     *
     * Specification: Requests the ADDITION or the CHANGE of a claim from an issuer.
     * Claims can requested to be added by anybody, including the claim holder itself (self issued).
     *
     * _signature is a signed message of the following structure: `keccak256(abi.encode(address identityHolder_address, uint256 topic, bytes data))`.
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address + uint256 topic))`.
     *
     * This COULD implement an approval process for pending claims, or add them right away.
     * MUST return a claimRequestId (use claim ID) that COULD be sent to the approve function.
     */
    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes calldata _signature, bytes calldata _data, string calldata _uri) external returns (bytes32 claimRequestId);

    /**
     * @dev Removes a claim.
     *
     * Triggers Event: `ClaimRemoved`
     *
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address, uint256 topic))`.
     */
    function removeClaim(bytes32 _claimId) external returns (bool success);
}

// File: @onchain-id/solidity/contracts/Identity.sol

pragma solidity ^0.5.10;



/**
 * @dev Implementation of the `IERC734` "KeyHolder" and the `IERC735` "ClaimHolder" interfaces into a common Identity Contract.
 */
contract Identity is ERC734, IERC735 {

    mapping (bytes32 => Claim) private claims;
    mapping (uint256 => bytes32[]) private claimsByTopic;

    /**
       * @notice Implementation of the addClaim function from the ERC-735 standard
       *  Require that the msg.sender has claim signer key.
       *
       * @param _topic The type of claim
       * @param _scheme The scheme with which this claim SHOULD be verified or how it should be processed.
       * @param _issuer The issuers identity contract address, or the address used to sign the above signature.
       * @param _signature Signature which is the proof that the claim issuer issued a claim of topic for this identity.
       * it MUST be a signed message of the following structure: keccak256(abi.encode(address identityHolder_address, uint256 _ topic, bytes data))
       * @param _data The hash of the claim data, sitting in another location, a bit-mask, call data, or actual data based on the claim scheme.
       * @param _uri The location of the claim, this can be HTTP links, swarm hashes, IPFS hashes, and such.
       *
       * @return Returns claimRequestId: COULD be send to the approve function, to approve or reject this claim.
       * triggers ClaimAdded event.
       */

    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    )
    public
    returns (bytes32 claimRequestId)
    {
        bytes32 claimId = keccak256(abi.encode(_issuer, _topic));

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 3), "Permissions: Sender does not have claim signer key");
        }

        if (claims[claimId].issuer != _issuer) {
            claimsByTopic[_topic].push(claimId);
            claims[claimId].topic = _topic;
            claims[claimId].scheme = _scheme;
            claims[claimId].issuer = _issuer;
            claims[claimId].signature = _signature;
            claims[claimId].data = _data;
            claims[claimId].uri = _uri;

            emit ClaimAdded(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        } else {
            claims[claimId].topic = _topic;
            claims[claimId].scheme = _scheme;
            claims[claimId].issuer = _issuer;
            claims[claimId].signature = _signature;
            claims[claimId].data = _data;
            claims[claimId].uri = _uri;

            emit ClaimChanged(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        }

        return claimId;
    }

    /**
       * @notice Implementation of the removeClaim function from the ERC-735 standard
       * Require that the msg.sender has management key.
       * Can only be removed by the claim issuer, or the claim holder itself.
       *
       * @param _claimId The identity of the claim i.e. keccak256(abi.encode(_issuer, _topic))
       *
       * @return Returns TRUE when the claim was removed.
       * triggers ClaimRemoved event
       */

    function removeClaim(bytes32 _claimId) public returns (bool success) {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have CLAIM key");
        }

        if (claims[_claimId].topic == 0) {
            revert("NonExisting: There is no claim with this ID");
        }

        uint claimIndex = 0;
        while (claimsByTopic[claims[_claimId].topic][claimIndex] != _claimId) {
            claimIndex++;
        }

        claimsByTopic[claims[_claimId].topic][claimIndex] = claimsByTopic[claims[_claimId].topic][claimsByTopic[claims[_claimId].topic].length - 1];
        claimsByTopic[claims[_claimId].topic].pop();

        emit ClaimRemoved(
            _claimId,
            claims[_claimId].topic,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );

        delete claims[_claimId];

        return true;
    }

    /**
        * @notice Implementation of the getClaim function from the ERC-735 standard.
        *
        * @param _claimId The identity of the claim i.e. keccak256(abi.encode(_issuer, _topic))
        *
        * @return Returns all the parameters of the claim for the specified _claimId (topic, scheme, signature, issuer, data, uri) .
        */

    function getClaim(bytes32 _claimId)
    public
    view
    returns(
        uint256 topic,
        uint256 scheme,
        address issuer,
        bytes memory signature,
        bytes memory data,
        string memory uri
    )
    {
        return (
            claims[_claimId].topic,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );
    }

    /**
        * @notice Implementation of the getClaimIdsByTopic function from the ERC-735 standard.
        * used to get all the claims from the specified topic
        *
        * @param _topic The identity of the claim i.e. keccak256(abi.encode(_issuer, _topic))
        *
        * @return Returns an array of claim IDs by topic.
        */

    function getClaimIdsByTopic(uint256 _topic)
    public
    view
    returns(bytes32[] memory claimIds)
    {
        return claimsByTopic[_topic];
    }
}

// File: @onchain-id/solidity/contracts/IClaimIssuer.sol

pragma solidity ^0.5.10;


//interface
contract IClaimIssuer{
    uint public issuedClaimCount;

    mapping (bytes => bool) revokedClaims;
    mapping (bytes32 => address) identityAddresses;

    event ClaimValid(Identity _identity, uint256 claimTopic);
    event ClaimInvalid(Identity _identity, uint256 claimTopic);

    function revokeClaim(bytes32 _claimId, address _identity) public returns(bool);
    // function revokeClaim(bytes memory _sig, address _identity) public returns(bool);
    // function isClaimRevoked(bytes32 _claimId) public view returns(bool);
    function isClaimRevoked(bytes memory _sig) public view returns(bool result);
    function isClaimValid(Identity _identity, bytes32 _claimId, uint256 claimTopic, bytes memory sig, bytes memory data)
    public
    view
    returns (bool claimValid);

}

// File: @onchain-id/solidity/contracts/ClaimIssuer.sol

pragma solidity ^0.5.10;



contract ClaimIssuer is IClaimIssuer, Identity {
    function revokeClaim(bytes32 _claimId, address _identity) public returns(bool) {
        uint256 foundClaimTopic;
        uint256 scheme;
        address issuer;
        bytes memory  sig;
        bytes  memory data;

		if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), "Permissions: Sender does not have management key");
        }
		
        ( foundClaimTopic, scheme, issuer, sig, data, ) = Identity(_identity).getClaim(_claimId);
        // require(sig != 0, "Claim does not exist");

        revokedClaims[sig] = true;
        identityAddresses[_claimId] = _identity;
        return true;
    }

    function isClaimRevoked(bytes memory _sig) public view returns (bool) {
        if(revokedClaims[_sig]) {
            return true;
        }

        return false;
    }

    function isClaimValid(Identity _identity, bytes32 _claimId, uint256 claimTopic, bytes memory sig, bytes memory data)
    public
    view
    returns (bool claimValid)
    {
        bytes32 dataHash = keccak256(abi.encode(_identity, claimTopic, data));
        // Use abi.encodePacked to concatenate the messahe prefix and the message to sign.
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash));

        // Recover address of data signer
        address recovered = getRecoveredAddress(sig, prefixedHash);

        // Take hash of recovered address
        bytes32 hashedAddr = keccak256(abi.encode(recovered));

        // Does the trusted identifier have they key which signed the user's claim?
        //  && (isClaimRevoked(_claimId) == false)
        if (keyHasPurpose(hashedAddr, 3) && (isClaimRevoked(sig) == false)) {
            return true;
        }

        return false;
    }

    function getRecoveredAddress(bytes memory sig, bytes32 dataHash)
        public
        pure
        returns (address addr)
    {
        bytes32 ra;
        bytes32 sa;
        uint8 va;

        // Check the signature length
        if (sig.length != 65) {
            return address(0);
        }

        // Divide the signature in r, s and v variables
        assembly {
          ra := mload(add(sig, 32))
          sa := mload(add(sig, 64))
          va := byte(0, mload(add(sig, 96)))
        }

        if (va < 27) {
            va += 27;
        }

        address recoveredAddress = ecrecover(dataHash, va, ra, sa);

        return (recoveredAddress);
    }
}

// File: contracts/registry/ITrustedIssuersRegistry.sol

pragma solidity ^0.5.10;


interface ITrustedIssuersRegistry {
    // EVENTS
    event TrustedIssuerAdded(uint indexed index, ClaimIssuer indexed trustedIssuer, uint[] claimTopics);
    event TrustedIssuerRemoved(uint indexed index, ClaimIssuer indexed trustedIssuer);
    event TrustedIssuerUpdated(uint indexed index, ClaimIssuer indexed oldTrustedIssuer, ClaimIssuer indexed newTrustedIssuer, uint[] claimTopics);

    // READ OPERATIONS
    function getTrustedIssuer(uint index) external view returns (ClaimIssuer);
    function getTrustedIssuerClaimTopics(uint index) external view returns(uint[] memory);
    function getTrustedIssuers() external view returns (uint[] memory);
    function hasClaimTopic(address issuer, uint claimTopic) external view returns(bool);
    function isTrustedIssuer(address issuer) external view returns(bool);

    // WRITE OPERATIONS
    function addTrustedIssuer(ClaimIssuer _trustedIssuer, uint index, uint[] calldata claimTopics) external;
    function removeTrustedIssuer(uint index) external;
    function updateIssuerContract(uint index, ClaimIssuer _newTrustedIssuer, uint[] calldata claimTopics) external;
}

// File: contracts/registry/IClaimTopicsRegistry.sol

pragma solidity ^0.5.10;

interface IClaimTopicsRegistry{
    // EVENTS
    event ClaimTopicAdded(uint256 indexed claimTopic);
    event ClaimTopicRemoved(uint256 indexed claimTopic);

    // OPERATIONS
    function addClaimTopic(uint256 claimTopic) external;
    function removeClaimTopic(uint256 claimTopic) external;

    // GETTERS
    function getClaimTopics() external view returns (uint256[] memory);
}

// File: contracts/registry/IIdentityRegistry.sol

pragma solidity ^0.5.10;





interface IIdentityRegistry {
    // EVENTS
    event ClaimTopicsRegistrySet(address indexed _claimTopicsRegistry);
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);
    event IdentityRegistered(address indexed investorAddress, Identity indexed identity);
    event IdentityRemoved(address indexed investorAddress, Identity indexed identity);
    event IdentityUpdated(Identity indexed old_identity, Identity indexed new_identity);
    event TrustedIssuersRegistrySet(address indexed _trustedIssuersRegistry);

    // WRITE OPERATIONS
    function deleteIdentity(address _user) external;
    function registerIdentity(address _user, Identity _identity, uint16 _country) external;
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;
    function updateCountry(address _user, uint16 _country) external;
    function updateIdentity(address _user, Identity _identity) external;

    // READ OPERATIONS
    function contains(address _wallet) external view returns (bool);
    function isVerified(address _userAddress) external view returns (bool);

    // GETTERS
    function identity(address _wallet) external view returns (Identity);
    function investorCountry(address _wallet) external view returns (uint16);
    function issuersRegistry() external view returns (ITrustedIssuersRegistry);
    function topicsRegistry() external view returns (IClaimTopicsRegistry);
}

// File: contracts/compliance/TransferRestrictions.sol

pragma solidity ^0.5.10;





contract TransferRestrictions is ICompliance, Ownable {

	struct Counter {
		mapping (uint256 => uint256) count;
		mapping (uint256 => uint256) startTime;
		bool exists;
	}

	IIdentityRegistry public identityRegistry;
	mapping (uint16 => bool) public restricted;
	mapping (address => Counter) public counters;
	mapping (uint256 => uint256) public limit;
	mapping (uint256 => uint256) public timespan;
	uint256 index = 0;

	event Restricted(uint16 _country);
	event Unrestricted(uint16 _country);
	event RestrictionAdded(uint256 _limit, uint256 _timespan);
	event RestrictionUpdated(uint256 _limit, uint256 _timespan, uint _index);
	event RestrictionRemoved(uint256 _index);

	constructor (address _identityRegistry) public {
		identityRegistry = IIdentityRegistry(_identityRegistry);
	}

    function restrictCountry(uint16 _country) public onlyOwner {
		restricted[_country] = true;
		emit Restricted(_country);
	}

	function unrestrictCountry(uint16  _country) public onlyOwner {
		restricted[_country] = false;
		emit Unrestricted(_country);
	}

	function restrictCountriesInBulk(uint16[] memory _country) public onlyOwner {
		for(uint i = 0 ; i < _country.length ; i++ ) {
			restricted[_country[i]] = true;
			emit Restricted(_country[i]);
		}
	}

	function unrestrictCountriesInBulk(uint16[] memory _country) public onlyOwner {
		for(uint i = 0 ; i < _country.length ; i++ ) {
			restricted[_country[i]] = false;
			emit Unrestricted(_country[i]);
		}
	}

	function isFromUnresrictedCountry(address _to) public view returns (bool) {
		uint16 country = identityRegistry.investorCountry(_to);
		if(!restricted[country]) {
			return true;
		}
		return false;
	}

	function getStartTime(address _user, uint256 _index) public view returns(uint256) {
		Counter storage counter = counters[_user];
		return counter.startTime[_index];
	}

	function setStartTime(address _user, uint256 _index, uint256 _time) internal {
		Counter storage counter = counters[_user];
		counter.startTime[_index] = _time;
	}

	function getCount(address _user, uint256 _index) public view returns(uint256) {
        Counter storage counter = counters[_user];
        if(counter.exists) {
            return counter.count[_index];
        }
        return 0;
    }

    function setCount(address _user, uint256 _count) internal {
        Counter storage counter = counters[_user];
		for(uint256 _index = 0; _index < index; _index++) {
			counter.count[_index] += _count;
		}
    }

	function addRestrictions(uint256 _limit, uint256 _timespan) public onlyOwner {
		require(_timespan > 0, "Invalid time interval");
		limit[index] = _limit;
		timespan[index] = _timespan;
		index++;
		emit RestrictionAdded(_limit, _timespan);
	}

	function updateRestrictions(uint256 _limit, uint256 _timespan, uint256 _index) public onlyOwner {
		require(_timespan > 0, "Invalid time interval");
		limit[_index] = _limit;
		timespan[_index] = _timespan;
		emit RestrictionUpdated(_limit, _timespan, _index);
	}

	function removeRestrictions(uint256 _index) public onlyOwner {
		require(_index >= 0, "Invalid index");
		require(limit[_index] != 0 && timespan[_index] != 0, "No restriction exist");

		delete limit[_index];
		delete timespan[_index];
		limit[_index] = limit[index-1];
		timespan[_index] = timespan[index-1];
		delete limit[index-1];
		delete timespan[index-1];
		index--;
		emit RestrictionRemoved(_index);
	}

	function resetStartTime(address _user, uint _index) internal {
		uint256 period = (block.timestamp - getStartTime(_user,_index)) / timespan[_index];
		uint256 time = getStartTime(_user, _index) + period * timespan[_index];
		setStartTime(_user, _index, time);
	}

	function canTransfer(address _from, address _to, uint256 _value) public returns (bool) {
		Counter storage counter = counters[_from];
		require(isFromUnresrictedCountry(_to),"Country is Restricted");
		uint256 flag = index;
		for(uint256 i = 0; i < index; i++) {
			if(!counter.exists) {
			    setStartTime(_from, i, now);
				if(i == index - 1){
				    counter.exists = true;
				}
			}
			if(getStartTime(_from, i) + timespan[i] < now) {
				require(_value <= limit[i], "Transfer limit exceeded");
				resetStartTime(_from, i);
				counter.count[i] = 0;
				flag--;
			}
			else if(getStartTime(_from, i) + timespan[i] >= now && counter.count[i] + _value <= limit[i]) {
				flag--;
			}
		}
		if( flag == 0) {
			setCount(_from, _value);
			return true;
		}
		return false;
	}
}