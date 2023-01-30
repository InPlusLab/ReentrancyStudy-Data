/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

/**
 *Submitted for verification at Etherscan.io on 2020-04-21
*/

// File: contracts/interfaces/IERC20.sol

pragma solidity ^0.5.11;


interface IERC20 {
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

// File: contracts/core/diaspore/interfaces/Cosigner.sol

pragma solidity ^0.5.11;


/**
    @dev Defines the interface of a standard RCN cosigner.

    The cosigner is an agent that gives an insurance to the lender in the event of a defaulted loan, the confitions
    of the insurance and the cost of the given are defined by the cosigner.

    The lender will decide what cosigner to use, if any; the address of the cosigner and the valid data provided by the
    agent should be passed as params when the lender calls the "lend" method on the engine.

    When the default conditions defined by the cosigner aligns with the status of the loan, the lender of the engine
    should be able to call the "claim" method to receive the benefit; the cosigner can define aditional requirements to
    call this method, like the transfer of the ownership of the loan.
*/
interface Cosigner {
    /**
        @return the url of the endpoint that exposes the insurance offers.
    */
    function url() external view returns (string memory);

    /**
        @dev Retrieves the cost of a given insurance, this amount should be exact.

        @return the cost of the cosign, in RCN wei
    */
    function cost(
        address engine,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    )
        external view returns (uint256);

    /**
        @dev The engine calls this method for confirmation of the conditions, if the cosigner accepts the liability of
        the insurance it must call the method "cosign" of the engine. If the cosigner does not call that method, or
        does not return true to this method, the operation fails.

        @return true if the cosigner accepts the liability
    */
    function requestCosign(
        address engine,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    )
        external returns (bool);

    /**
        @dev Claims the benefit of the insurance if the loan is defaulted, this method should be only calleable by the
        current lender of the loan.

        @return true if the claim was done correctly.
    */
    function claim(address engine, uint256 index, bytes calldata oracleData) external returns (bool);
}

// File: contracts/interfaces/IERC165.sol

pragma solidity ^0.5.11;


interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// File: contracts/core/diaspore/interfaces/IDebtStatus.sol

pragma solidity ^0.5.11;


interface IDebtStatus {
    enum Status {
        NULL,
        ONGOING,
        PAID,
        DESTROYED, // Deprecated, used in basalt version
        ERROR
    }
}

// File: contracts/core/diaspore/interfaces/Model.sol

pragma solidity ^0.5.11;




/**
    The abstract contract Model defines the whole lifecycle of a debt on the DebtEngine.

    Models can be used without previous approbation, this is meant
    to avoid centralization on the development of RCN; this implies that not all models are secure.
    Models can have back-doors, bugs and they have not guarantee of being autonomous.

    The DebtEngine is meant to be the User of this model,
    so all the methods with the ability to perform state changes should only be callable by the DebtEngine.

    All models should implement the 0xaf498c35 interface.

    @author Agustin Aguilar
*/
contract Model is IERC165, IDebtStatus {

    // ///
    // Events
    // ///

    /**
        @dev This emits when create a new debt.
    */
    event Created(bytes32 indexed _id);

    /**
        @dev This emits when the status of debt change.

        @param _timestamp Timestamp of the registry
        @param _status New status of the registry
    */
    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, Status _status);

    /**
        @dev This emits when the obligation of debt change.

        @param _timestamp Timestamp of the registry
        @param _debt New debt of the registry
    */
    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);

    /**
        @dev This emits when the frequency of debt change.

        @param _timestamp Timestamp of the registry
        @param _frequency New frequency of each installment
    */
    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);

    /**
        @param _timestamp Timestamp of the registry
    */
    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, Status _status);

    /**
        @param _timestamp Timestamp of the registry
        @param _dueTime New dueTime of each installment
    */
    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);

    /**
        @dev This emits when the call addDebt function.

        @param _amount New amount of the debt, old amount plus added
    */
    event AddedDebt(bytes32 indexed _id, uint256 _amount);

    /**
        @dev This emits when the call addPaid function.

        If the registry is fully paid on the call and the amount parameter exceeds the required
            payment amount, the event emits the real amount paid on the payment.

        @param _paid Real amount paid
    */
    event AddedPaid(bytes32 indexed _id, uint256 _paid);

    // Model interface selector
    bytes4 internal constant MODEL_INTERFACE = 0xaf498c35;

    // ///
    // Meta
    // ///

    /**
        @return Identifier of the model
    */
    function modelId() external view returns (bytes32);

    /**
        Returns the address of the contract used as Descriptor of the model

        @dev The descriptor contract should follow the ModelDescriptor.sol scheme

        @return Address of the descriptor
    */
    function descriptor() external view returns (address);

    /**
        If called for any address with the ability to modify the state of the model registries,
            this method should return True.

        @dev Some contracts may check if the DebtEngine is
            an operator to know if the model is operative or not.

        @param operator Address of the target request operator

        @return True if operator is able to modify the state of the model
    */
    function isOperator(address operator) external view returns (bool canOperate);

    /**
        Validates the data for the creation of a new registry, if returns True the
            same data should be compatible with the create method.

        @dev This method can revert the call or return false, and both meant an invalid data.

        @param data Data to validate

        @return True if the data can be used to create a new registry
    */
    function validate(bytes calldata data) external view returns (bool isValid);

    // ///
    // Getters
    // ///

    /**
        Exposes the current status of the registry. The possible values are:

        1: Ongoing - The debt is still ongoing and waiting to be paid
        2: Paid - The debt is already paid and
        4: Error - There was an Error with the registry

        @dev This method should always be called by the DebtEngine

        @param id Id of the registry

        @return The current status value
    */
    function getStatus(bytes32 id) external view returns (Status status);

    /**
        Returns the total paid amount on the registry.

        @dev it should equal to the sum of all real addPaid

        @param id Id of the registry

        @return Total paid amount
    */
    function getPaid(bytes32 id) external view returns (uint256 paid);

    /**
        If the returned amount does not depend on any interactions and only on the model logic,
            the defined flag will be True; if the amount is an estimation of the future debt,
            the flag will be set to False.

        If timestamp equals the current moment, the defined flag should always be True.

        @dev This can be a gas-intensive method to call, consider calling the run method before.

        @param id Id of the registry
        @param timestamp Timestamp of the obligation query

        @return amount Amount pending to pay on the given timestamp
        @return defined True If the amount returned is fixed and can't change
    */
    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256 amount, bool defined);

    /**
        The amount required to fully paid a registry.

        All registries should be payable in a single time, even when it has multiple installments.

        If the registry discounts interest for early payment, those discounts should be
            taken into account in the returned amount.

        @dev This can be a gas-intensive method to call, consider calling the run method before.

        @param id Id of the registry

        @return amount Amount required to fully paid the loan on the current timestamp
    */
    function getClosingObligation(bytes32 id) external view returns (uint256 amount);

    /**
        The timestamp of the next required payment.

        After this moment, if the payment goal is not met the debt will be considered overdue.

            The getObligation method can be used to know the required payment on the future timestamp.

        @param id Id of the registry

        @return timestamp The timestamp of the next due time
    */
    function getDueTime(bytes32 id) external view returns (uint256 timestamp);

    // ///
    // Metadata
    // ///

    /**
        If the loan has multiple installments returns the duration of each installment in seconds,
            if the loan has not installments it should return 1.

        @param id Id of the registry

        @return frequency Frequency of each installment
    */
    function getFrequency(bytes32 id) external view returns (uint256 frequency);

    /**
        If the loan has multiple installments returns the total of installments,
            if the loan has not installments it should return 1.

        @param id Id of the registry

        @return installments Total of installments
    */
    function getInstallments(bytes32 id) external view returns (uint256 installments);

    /**
        The registry could be paid before or after the date, but the debt will always be
            considered overdue if paid after this timestamp.

        This is the estimated final payment date of the debt if it's always paid on each exact dueTime.

        @param id Id of the registry

        @return timestamp Timestamp of the final due time
    */
    function getFinalTime(bytes32 id) external view returns (uint256 timestamp);

    /**
        Similar to getFinalTime returns the expected payment remaining if paid always on the exact dueTime.

        If the model has no interest discounts for early payments,
            this method should return the same value as getClosingObligation.

        @param id Id of the registry

        @return amount Expected payment amount
    */
    function getEstimateObligation(bytes32 id) external view returns (uint256 amount);

    // ///
    // State interface
    // ///

    /**
        Creates a new registry using the provided data and id, it should fail if the id already exists
            or if calling validate(data) returns false or throws.

        @dev This method should only be callable by an operator

        @param id Id of the registry to create
        @param data Data to construct the new registry

        @return success True if the registry was created
    */
    function create(bytes32 id, bytes calldata data) external returns (bool success);

    /**
        If the registry is fully paid on the call and the amount parameter exceeds the required
            payment amount, the method returns the real amount used on the payment.

        The payment taken should always be the same as the requested unless the registry
            is fully paid on the process.

        @dev This method should only be callable by an operator

        @param id If of the registry
        @param amount Amount to pay

        @return real Real amount paid
    */
    function addPaid(bytes32 id, uint256 amount) external returns (uint256 real);

    /**
        Adds a new amount to be paid on the debt model,
            each model can handle the addition of more debt freely.

        @dev This method should only be callable by an operator

        @param id Id of the registry
        @param amount Debt amount to add to the registry

        @return added True if the debt was added
    */
    function addDebt(bytes32 id, uint256 amount) external returns (bool added);

    // ///
    // Utils
    // ///

    /**
        Runs the internal clock of a registry, this is used to compute the last changes on the state.
            It can make transactions cheaper by avoiding multiple calculations when calling views.

        Not all models have internal clocks, a model without an internal clock should always return false.

        Calls to this method should be possible from any address,
            multiple calls to run shouldn't affect the internal calculations of the model.

        @dev If the call had no effect the method would return False,
            that is no sign of things going wrong, and the call shouldn't be wrapped on a require

        @param id If of the registry

        @return effect True if the run performed a change on the state
    */
    function run(bytes32 id) external returns (bool effect);
}

// File: contracts/core/diaspore/interfaces/RateOracle.sol

pragma solidity ^0.5.11;



/**
    @dev Defines the interface of a standard Diaspore RCN Oracle,

    The contract should also implement it's ERC165 interface: 0xa265d8e0

    @notice Each oracle can only support one currency

    @author Agustin Aguilar
*/
contract RateOracle is IERC165 {
    uint256 public constant VERSION = 5;
    bytes4 internal constant RATE_ORACLE_INTERFACE = 0xa265d8e0;

    constructor() internal {}

    /**
        3 or 4 letters symbol of the currency, Ej: ETH
    */
    function symbol() external view returns (string memory);

    /**
        Descriptive name of the currency, Ej: Ethereum
    */
    function name() external view returns (string memory);

    /**
        The number of decimals of the currency represented by this Oracle,
            it should be the most common number of decimal places
    */
    function decimals() external view returns (uint256);

    /**
        The base token on which the sample is returned
            should be the RCN Token address.
    */
    function token() external view returns (address);

    /**
        The currency symbol encoded on a UTF-8 Hex
    */
    function currency() external view returns (bytes32);

    /**
        The name of the Individual or Company in charge of this Oracle
    */
    function maintainer() external view returns (string memory);

    /**
        Returns the url where the oracle exposes a valid "oracleData" if needed
    */
    function url() external view returns (string memory);

    /**
        Returns a sample on how many token() are equals to how many currency()
    */
    function readSample(bytes calldata _data) external returns (uint256 _tokens, uint256 _equivalent);
}

// File: contracts/utils/IsContract.sol

pragma solidity ^0.5.11;


library IsContract {
    function isContract(address _addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}

// File: contracts/utils/SafeMath.sol

pragma solidity ^0.5.11;


library SafeMath {
    using SafeMath for uint256;

    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        require(x >= y, "Sub overflow");
        return x - y;
    }

    function mult(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z/x == y, "Mult overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        return x / y;
    }

    function multdiv(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {
        require(z != 0, "div by zero");
        return x.mult(y) / z;
    }
}

// File: contracts/commons/ERC165.sol

pragma solidity ^0.5.11;



/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {
    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
    /**
    * 0x01ffc9a7 ===
    *   bytes4(keccak256('supportsInterface(bytes4)'))
    */

    /**
    * @dev a mapping of interface id to whether or not it's supported
    */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
    * @dev A contract implementing SupportsInterfaceWithLookup
    * implement ERC165 itself
    */
    constructor()
        internal
    {
        _registerInterface(_InterfaceId_ERC165);
    }

    /**
    * @dev implement supportsInterface(bytes4) using a lookup table
    */
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    /**
    * @dev internal method for registering an interface
    */
    function _registerInterface(bytes4 interfaceId)
        internal
    {
        require(interfaceId != 0xffffffff, "Can't register 0xffffffff");
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: contracts/commons/ERC721Base.sol

pragma solidity ^0.5.11;





interface URIProvider {
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}


contract ERC721Base is ERC165 {
    using SafeMath for uint256;
    using IsContract for address;

    mapping(uint256 => address) private _holderOf;

    // Owner to array of assetId
    mapping(address => uint256[]) private _assetsOf;
    // AssetId to index on array in _assetsOf mapping
    mapping(uint256 => uint256) private _indexOfAsset;

    mapping(address => mapping(address => bool)) private _operators;
    mapping(uint256 => address) private _approval;

    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant ERC721_RECEIVED_LEGACY = 0xf0b9e5ba;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    bytes4 private constant ERC_721_INTERFACE = 0x80ac58cd;
    bytes4 private constant ERC_721_METADATA_INTERFACE = 0x5b5e139f;
    bytes4 private constant ERC_721_ENUMERATION_INTERFACE = 0x780e9d63;

    constructor(
        string memory name,
        string memory symbol
    ) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(ERC_721_INTERFACE);
        _registerInterface(ERC_721_METADATA_INTERFACE);
        _registerInterface(ERC_721_ENUMERATION_INTERFACE);
    }

    // ///
    // ERC721 Metadata
    // ///

    /// ERC-721 Non-Fungible Token Standard, optional metadata extension
    /// See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
    /// Note: the ERC-165 identifier for this interface is 0x5b5e139f.

    event SetURIProvider(address _uriProvider);

    string private _name;
    string private _symbol;

    URIProvider private _uriProvider;

    // @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory) {
        return _name;
    }

    // @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    *  3986. The URI may point to a JSON file that conforms to the "ERC721
    *  Metadata JSON Schema".
    */
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_holderOf[_tokenId] != address(0), "Asset does not exist");
        URIProvider provider = _uriProvider;
        return address(provider) == address(0) ? "" : provider.tokenURI(_tokenId);
    }

    function _setURIProvider(URIProvider _provider) internal returns (bool) {
        emit SetURIProvider(address(_provider));
        _uriProvider = _provider;
        return true;
    }

    // ///
    // ERC721 Enumeration
    // ///

    ///  ERC-721 Non-Fungible Token Standard, optional enumeration extension
    ///  See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
    ///  Note: the ERC-165 identifier for this interface is 0x780e9d63.

    uint256[] private _allTokens;

    /**
     * @dev Gets the total of assets stored by the contract
     *      Warning: this method can consume all the gas of the transaction, it should not be
     *               called from another contract, it should only be used in external calls
     * @return an array with total assets
     */
    function allTokens() external view returns (uint256[] memory) {
        return _allTokens;
    }

    /**
     * @dev Gets the total of assets of the owner
     *      Warning: this method can consume all the gas of the transaction, it should not be
     *               called from another contract, it should only be used in external calls
     * @param _owner the address of owner
     * @return an array with total assets of owner
     */
    function assetsOf(address _owner) external view returns (uint256[] memory) {
        return _assetsOf[_owner];
    }

    /**
     * @dev Gets the total amount of assets stored by the contract
     * @return uint256 representing the total amount of assets
     */
    function totalSupply() external view returns (uint256) {
        return _allTokens.length;
    }

    /**
    * @notice Enumerate valid NFTs
    * @dev Throws if `_index` >= `totalSupply()`.
    * @param _index A counter less than `totalSupply()`
    * @return The token identifier for the `_index` of the NFT,
    *  (sort order not specified)
    */
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < _allTokens.length, "Index out of bounds");
        return _allTokens[_index];
    }

    /**
    * @notice Enumerate NFTs assigned to an owner
    * @dev Throws if `_index` >= `balanceOf(_owner)` or if
    *  `_owner` is the zero address, representing invalid NFTs.
    * @param _owner An address where we are interested in NFTs owned by them
    * @param _index A counter less than `balanceOf(_owner)`
    * @return The token identifier for the `_index` of the NFT assigned to `_owner`,
    *   (sort order not specified)
    */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_owner != address(0), "0x0 Is not a valid owner");
        require(_index < _balanceOf(_owner), "Index out of bounds");
        return _assetsOf[_owner][_index];
    }

    //
    // Asset-centric getter functions
    //

    /**
     * @dev Queries what address owns an asset. This method does not throw.
     * In order to check if the asset exists, use the `exists` function or check if the
     * return value of this call is `0`.
     * @return uint256 the assetId
     */
    function ownerOf(uint256 _assetId) external view returns (address) {
        return _ownerOf(_assetId);
    }

    function _ownerOf(uint256 _assetId) internal view returns (address) {
        return _holderOf[_assetId];
    }

    //
    // Holder-centric getter functions
    //
    /**
     * @dev Gets the balance of the specified address
     * @param _owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address _owner) external view returns (uint256) {
        return _balanceOf(_owner);
    }

    function _balanceOf(address _owner) internal view returns (uint256) {
        return _assetsOf[_owner].length;
    }

    //
    // Authorization getters
    //

    /**
     * @dev Query whether an address has been authorized to move any assets on behalf of someone else
     * @param _operator the address that might be authorized
     * @param _assetHolder the address that provided the authorization
     * @return bool true if the operator has been authorized to move any assets
     */
    function isApprovedForAll(
        address _operator,
        address _assetHolder
    ) external view returns (bool) {
        return _isApprovedForAll(_operator, _assetHolder);
    }

    function _isApprovedForAll(
        address _operator,
        address _assetHolder
    ) internal view returns (bool) {
        return _operators[_assetHolder][_operator];
    }

    /**
     * @dev Query what address has been particularly authorized to move an asset
     * @param _assetId the asset to be queried for
     * @return bool true if the asset has been approved by the holder
     */
    function getApproved(uint256 _assetId) external view returns (address) {
        return _getApproved(_assetId);
    }

    function _getApproved(uint256 _assetId) internal view returns (address) {
        return _approval[_assetId];
    }

    /**
     * @dev Query if an operator can move an asset.
     * @param _operator the address that might be authorized
     * @param _assetId the asset that has been `approved` for transfer
     * @return bool true if the asset has been approved by the holder
     */
    function isAuthorized(address _operator, uint256 _assetId) external view returns (bool) {
        return _isAuthorized(_operator, _assetId);
    }

    function _isAuthorized(address _operator, uint256 _assetId) internal view returns (bool) {
        require(_operator != address(0), "0x0 is an invalid operator");
        address owner = _ownerOf(_assetId);

        return _operator == owner || _isApprovedForAll(_operator, owner) || _getApproved(_assetId) == _operator;
    }

    //
    // Authorization
    //

    /**
     * @dev Authorize a third party operator to manage (send) msg.sender's asset
     * @param _operator address to be approved
     * @param _authorized bool set to true to authorize, false to withdraw authorization
     */
    function setApprovalForAll(address _operator, bool _authorized) external {
        if (_operators[msg.sender][_operator] != _authorized) {
            _operators[msg.sender][_operator] = _authorized;
            emit ApprovalForAll(msg.sender, _operator, _authorized);
        }
    }

    /**
     * @dev Authorize a third party operator to manage one particular asset
     * @param _operator address to be approved
     * @param _assetId asset to approve
     */
    function approve(address _operator, uint256 _assetId) external {
        address holder = _ownerOf(_assetId);
        require(msg.sender == holder || _isApprovedForAll(msg.sender, holder), "msg.sender can't approve");
        if (_getApproved(_assetId) != _operator) {
            _approval[_assetId] = _operator;
            emit Approval(holder, _operator, _assetId);
        }
    }

    //
    // Internal Operations
    //

    function _addAssetTo(address _to, uint256 _assetId) private {
        // Store asset owner
        _holderOf[_assetId] = _to;

        // Store index of the asset
        uint256 length = _balanceOf(_to);
        _assetsOf[_to].push(_assetId);
        _indexOfAsset[_assetId] = length;

        // Save main enumerable
        _allTokens.push(_assetId);
    }

    function _transferAsset(address _from, address _to, uint256 _assetId) private {
        uint256 assetIndex = _indexOfAsset[_assetId];
        uint256 lastAssetIndex = _balanceOf(_from).sub(1);

        if (assetIndex != lastAssetIndex) {
            // Replace current asset with last asset
            uint256 lastAssetId = _assetsOf[_from][lastAssetIndex];
            // Insert the last asset into the position previously occupied by the asset to be removed
            _assetsOf[_from][assetIndex] = lastAssetId;
            _indexOfAsset[lastAssetId] = assetIndex;
        }

        // Resize the array
        _assetsOf[_from][lastAssetIndex] = 0;
        _assetsOf[_from].length--;

        // Change owner
        _holderOf[_assetId] = _to;

        // Update the index of positions of the asset
        uint256 length = _balanceOf(_to);
        _assetsOf[_to].push(_assetId);
        _indexOfAsset[_assetId] = length;
    }

    function _clearApproval(address _holder, uint256 _assetId) private {
        if (_approval[_assetId] != address(0)) {
            _approval[_assetId] = address(0);
            emit Approval(_holder, address(0), _assetId);
        }
    }

    //
    // Supply-altering functions
    //

    function _generate(uint256 _assetId, address _beneficiary) internal {
        require(_holderOf[_assetId] == address(0), "Asset already exists");

        _addAssetTo(_beneficiary, _assetId);

        emit Transfer(address(0), _beneficiary, _assetId);
    }

    //
    // Transaction related operations
    //

    modifier onlyAuthorized(uint256 _assetId) {
        require(_isAuthorized(msg.sender, _assetId), "msg.sender Not authorized");
        _;
    }

    modifier isCurrentOwner(address _from, uint256 _assetId) {
        require(_ownerOf(_assetId) == _from, "Not current owner");
        _;
    }

    modifier addressDefined(address _target) {
        require(_target != address(0), "Target can't be 0x0");
        _;
    }

    /**
     * @dev Alias of `safeTransferFrom(from, to, assetId, '')`
     *
     * @param _from address that currently owns an asset
     * @param _to address to receive the ownership of the asset
     * @param _assetId uint256 ID of the asset to be transferred
     */
    function safeTransferFrom(address _from, address _to, uint256 _assetId) external {
        return _doTransferFrom(
            _from,
            _to,
            _assetId,
            "",
            true
        );
    }

    /**
     * @dev Securely transfers the ownership of a given asset from one address to
     * another address, calling the method `onNFTReceived` on the target address if
     * there's code associated with it
     *
     * @param _from address that currently owns an asset
     * @param _to address to receive the ownership of the asset
     * @param _assetId uint256 ID of the asset to be transferred
     * @param _userData bytes arbitrary user information to attach to this transfer
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _assetId,
        bytes calldata _userData
    ) external {
        return _doTransferFrom(
            _from,
            _to,
            _assetId,
            _userData,
            true
        );
    }

    /**
     * @dev Transfers the ownership of a given asset from one address to another address
     * Warning! This function does not attempt to verify that the target address can send
     * tokens.
     *
     * @param _from address sending the asset
     * @param _to address to receive the ownership of the asset
     * @param _assetId uint256 ID of the asset to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _assetId) external {
        return _doTransferFrom(
            _from,
            _to,
            _assetId,
            "",
            false
        );
    }

    /**
     * Internal function that moves an asset from one holder to another
     */
    function _doTransferFrom(
        address _from,
        address _to,
        uint256 _assetId,
        bytes memory _userData,
        bool _doCheck
    )
        internal
        onlyAuthorized(_assetId)
        addressDefined(_to)
        isCurrentOwner(_from, _assetId)
    {
        address holder = _holderOf[_assetId];
        _clearApproval(holder, _assetId);
        _transferAsset(holder, _to, _assetId);

        if (_doCheck && _to.isContract()) {
            // Call dest contract
            // Perform check with the new safe call
            // onERC721Received(address,address,uint256,bytes)
            (bool success, bytes4 result) = _noThrowCall(
                _to,
                abi.encodeWithSelector(
                    ERC721_RECEIVED,
                    msg.sender,
                    holder,
                    _assetId,
                    _userData
                )
            );

            if (!success || result != ERC721_RECEIVED) {
                // Try legacy safe call
                // onERC721Received(address,uint256,bytes)
                (success, result) = _noThrowCall(
                    _to,
                    abi.encodeWithSelector(
                        ERC721_RECEIVED_LEGACY,
                        holder,
                        _assetId,
                        _userData
                    )
                );

                require(
                    success && result == ERC721_RECEIVED_LEGACY,
                    "Contract rejected the token"
                );
            }
        }

        emit Transfer(holder, _to, _assetId);
    }

    //
    // Utilities
    //

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract),
     * relaxing the requirement on the return value
     * @param _contract The contract that receives the ERC721
     * @param _data The call data
     * @return True if the call not reverts and the result of the call
     */
    function _noThrowCall(
        address _contract,
        bytes memory _data
    ) internal returns (bool success, bytes4 result) {
        bytes memory returnData;
        (success, returnData) = _contract.call(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (bytes4));
    }
}

// File: contracts/interfaces/IERC173.sol

pragma solidity ^0.5.11;


/// @title ERC-173 Contract Ownership Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
contract IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    //// function owner() external view returns (address);

    /// @notice Set the address of the new owner of the contract
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

// File: contracts/commons/Ownable.sol

pragma solidity ^0.5.11;



contract Ownable is IERC173 {
    address internal _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0x0), msg.sender);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    /**
        @dev Transfers the ownership of the contract.

        @param _newOwner Address of the new owner
    */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}

// File: contracts/core/diaspore/DebtEngine.sol

pragma solidity ^0.5.11;









contract DebtEngine is ERC721Base, Ownable, IDebtStatus {
    using IsContract for address;

    event Created(
        bytes32 indexed _id,
        uint256 _nonce,
        bytes _data
    );

    event Created2(
        bytes32 indexed _id,
        uint256 _salt,
        bytes _data
    );

    event Created3(
        bytes32 indexed _id,
        uint256 _salt,
        bytes _data
    );

    event Paid(
        bytes32 indexed _id,
        address _sender,
        address _origin,
        uint256 _requested,
        uint256 _requestedTokens,
        uint256 _paid,
        uint256 _tokens
    );

    event ReadedOracleBatch(
        address _oracle,
        uint256 _count,
        uint256 _tokens,
        uint256 _equivalent
    );

    event ReadedOracle(
        bytes32 indexed _id,
        uint256 _tokens,
        uint256 _equivalent
    );

    event PayBatchError(
        bytes32 indexed _id,
        address _targetOracle
    );

    event Withdrawn(
        bytes32 indexed _id,
        address _sender,
        address _to,
        uint256 _amount
    );

    event Error(
        bytes32 indexed _id,
        address _sender,
        uint256 _value,
        uint256 _gasLeft,
        uint256 _gasLimit,
        bytes _callData
    );

    event ErrorRecover(
        bytes32 indexed _id,
        address _sender,
        uint256 _value,
        uint256 _gasLeft,
        uint256 _gasLimit,
        bytes32 _result,
        bytes _callData
    );

    IERC20 public token;

    mapping(bytes32 => Debt) public debts;
    mapping(address => uint256) public nonces;

    struct Debt {
        bool error;
        uint128 balance;
        Model model;
        address creator;
        address oracle;
    }

    constructor (
        IERC20 _token
    ) public ERC721Base("RCN Debt Record", "RDR") {
        token = _token;

        // Sanity checks
        require(address(_token).isContract(), "Token should be a contract");
    }

    function setURIProvider(URIProvider _provider) external onlyOwner {
        _setURIProvider(_provider);
    }

    function create(
        Model _model,
        address _owner,
        address _oracle,
        bytes calldata _data
    ) external returns (bytes32 id) {
        uint256 nonce = nonces[msg.sender]++;
        id = keccak256(
            abi.encodePacked(
                uint8(1),
                address(this),
                msg.sender,
                nonce
            )
        );

        debts[id] = Debt({
            error: false,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created({
            _id: id,
            _nonce: nonce,
            _data: _data
        });
    }

    function create2(
        Model _model,
        address _owner,
        address _oracle,
        uint256 _salt,
        bytes calldata _data
    ) external returns (bytes32 id) {
        id = keccak256(
            abi.encodePacked(
                uint8(2),
                address(this),
                msg.sender,
                _model,
                _oracle,
                _salt,
                _data
            )
        );

        debts[id] = Debt({
            error: false,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created2({
            _id: id,
            _salt: _salt,
            _data: _data
        });
    }

    function create3(
        Model _model,
        address _owner,
        address _oracle,
        uint256 _salt,
        bytes calldata _data
    ) external returns (bytes32 id) {
        id = keccak256(
            abi.encodePacked(
                uint8(3),
                address(this),
                msg.sender,
                _salt
            )
        );

        debts[id] = Debt({
            error: false,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created3({
            _id: id,
            _salt: _salt,
            _data: _data
        });
    }

    function buildId(
        address _creator,
        uint256 _nonce
    ) external view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                uint8(1),
                address(this),
                _creator,
                _nonce
            )
        );
    }

    function buildId2(
        address _creator,
        address _model,
        address _oracle,
        uint256 _salt,
        bytes calldata _data
    ) external view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                uint8(2),
                address(this),
                _creator,
                _model,
                _oracle,
                _salt,
                _data
            )
        );
    }

    function buildId3(
        address _creator,
        uint256 _salt
    ) external view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                uint8(3),
                address(this),
                _creator,
                _salt
            )
        );
    }

    function pay(
        bytes32 _id,
        uint256 _amount,
        address _origin,
        bytes calldata _oracleData
    ) external returns (uint256 paid, uint256 paidToken) {
        Debt storage debt = debts[_id];
        // Paid only required amount
        paid = _safePay(_id, debt.model, _amount);
        require(paid <= _amount, "Paid can't be more than requested");

        RateOracle oracle = RateOracle(debt.oracle);
        if (address(oracle) != address(0)) {
            // Convert
            (uint256 tokens, uint256 equivalent) = oracle.readSample(_oracleData);
            emit ReadedOracle(_id, tokens, equivalent);
            paidToken = _toToken(paid, tokens, equivalent);
        } else {
            paidToken = paid;
        }

        // Pull tokens from payer
        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling payment tokens");

        // Add balance to the debt
        uint256 newBalance = paidToken.add(debt.balance);
        require(newBalance < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(newBalance);

        // Emit pay event
        emit Paid({
            _id: _id,
            _sender: msg.sender,
            _origin: _origin,
            _requested: _amount,
            _requestedTokens: 0,
            _paid: paid,
            _tokens: paidToken
        });
    }

    function payToken(
        bytes32 id,
        uint256 amount,
        address origin,
        bytes calldata oracleData
    ) external returns (uint256 paid, uint256 paidToken) {
        Debt storage debt = debts[id];
        // Read storage
        RateOracle oracle = RateOracle(debt.oracle);

        uint256 equivalent;
        uint256 tokens;
        uint256 available;

        // Get available <currency> amount
        if (address(oracle) != address(0)) {
            (tokens, equivalent) = oracle.readSample(oracleData);
            emit ReadedOracle(id, tokens, equivalent);
            available = _fromToken(amount, tokens, equivalent);
        } else {
            available = amount;
        }

        // Call addPaid on model
        paid = _safePay(id, debt.model, available);
        require(paid <= available, "Paid can't exceed available");

        // Convert back to required pull amount
        if (address(oracle) != address(0)) {
            paidToken = _toToken(paid, tokens, equivalent);
            require(paidToken <= amount, "Paid can't exceed requested");
        } else {
            paidToken = paid;
        }

        // Pull tokens from payer
        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling tokens");

        // Add balance to the debt
        // WARNING: Reusing variable **available**
        available = paidToken.add(debt.balance);
        require(available < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(available);

        // Emit pay event
        emit Paid({
            _id: id,
            _sender: msg.sender,
            _origin: origin,
            _requested: 0,
            _requestedTokens: amount,
            _paid: paid,
            _tokens: paidToken
        });
    }

    function payBatch(
        bytes32[] calldata _ids,
        uint256[] calldata _amounts,
        address _origin,
        address _oracle,
        bytes calldata _oracleData
    ) external returns (uint256[] memory paid, uint256[] memory paidTokens) {
        uint256 count = _ids.length;
        require(count == _amounts.length, "_ids and _amounts should have the same length");

        uint256 tokens;
        uint256 equivalent;
        if (_oracle != address(0)) {
            (tokens, equivalent) = RateOracle(_oracle).readSample(_oracleData);
            emit ReadedOracleBatch(_oracle, count, tokens, equivalent);
        }

        paid = new uint256[](count);
        paidTokens = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            uint256 amount = _amounts[i];
            (paid[i], paidTokens[i]) = _pay(_ids[i], _oracle, amount, tokens, equivalent);

            emit Paid({
                _id: _ids[i],
                _sender: msg.sender,
                _origin: _origin,
                _requested: amount,
                _requestedTokens: 0,
                _paid: paid[i],
                _tokens: paidTokens[i]
            });
        }
    }

    function payTokenBatch(
        bytes32[] calldata _ids,
        uint256[] calldata _tokenAmounts,
        address _origin,
        address _oracle,
        bytes calldata _oracleData
    ) external returns (uint256[] memory paid, uint256[] memory paidTokens) {
        uint256 count = _ids.length;
        require(count == _tokenAmounts.length, "_ids and _amounts should have the same length");

        uint256 tokens;
        uint256 equivalent;
        if (_oracle != address(0)) {
            (tokens, equivalent) = RateOracle(_oracle).readSample(_oracleData);
            emit ReadedOracleBatch(_oracle, count, tokens, equivalent);
        }

        paid = new uint256[](count);
        paidTokens = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            uint256 tokenAmount = _tokenAmounts[i];
            (paid[i], paidTokens[i]) = _pay(
                _ids[i],
                _oracle,
                _oracle != address(0) ? _fromToken(tokenAmount, tokens, equivalent) : tokenAmount,
                tokens,
                equivalent
            );
            require(paidTokens[i] <= tokenAmount, "Paid can't exceed requested");

            emit Paid({
                _id: _ids[i],
                _sender: msg.sender,
                _origin: _origin,
                _requested: 0,
                _requestedTokens: tokenAmount,
                _paid: paid[i],
                _tokens: paidTokens[i]
            });
        }
    }

    /**
        Internal method to pay a loan, during a payment batch context

        @param _id Pay identifier
        @param _oracle Address of the Oracle contract, if the loan does not use any oracle, this field should be 0x0.
        @param _amount Amount to pay, in currency
        @param _tokens How many tokens
        @param _equivalent How much currency _tokens equivales

        @return paid and paidTokens, similar to external pay
    */
    function _pay(
        bytes32 _id,
        address _oracle,
        uint256 _amount,
        uint256 _tokens,
        uint256 _equivalent
    ) internal returns (uint256 paid, uint256 paidToken){
        Debt storage debt = debts[_id];

        if (_oracle != debt.oracle) {
            emit PayBatchError(
                _id,
                _oracle
            );

            return (0,0);
        }

        // Paid only required amount
        paid = _safePay(_id, debt.model, _amount);
        require(paid <= _amount, "Paid can't be more than requested");

        // Get token amount to use as payment
        paidToken = _oracle != address(0) ? _toToken(paid, _tokens, _equivalent) : paid;

        // Pull tokens from payer
        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling payment tokens");

        // Add balance to debt
        uint256 newBalance = paidToken.add(debt.balance);
        require(newBalance < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(newBalance);
    }

    function _safePay(
        bytes32 _id,
        Model _model,
        uint256 _available
    ) internal returns (uint256) {
        require(_model != Model(0), "Debt does not exist");

        (bool success, bytes32 paid) = _safeGasCall(
            address(_model),
            abi.encodeWithSelector(
                _model.addPaid.selector,
                _id,
                _available
            )
        );

        if (success) {
            if (debts[_id].error) {
                emit ErrorRecover({
                    _id: _id,
                    _sender: msg.sender,
                    _value: 0,
                    _gasLeft: gasleft(),
                    _gasLimit: block.gaslimit,
                    _result: paid,
                    _callData: msg.data
                });

                delete debts[_id].error;
            }

            return uint256(paid);
        } else {
            emit Error({
                _id: _id,
                _sender: msg.sender,
                _value: msg.value,
                _gasLeft: gasleft(),
                _gasLimit: block.gaslimit,
                _callData: msg.data
            });
            debts[_id].error = true;
        }
    }

    /**
        Converts an amount in the rate currency to an amount in token

        @param _amount Amount to convert in rate currency
        @param _tokens How many tokens
        @param _equivalent How much currency _tokens equivales

        @return Amount in tokens
    */
    function _toToken(
        uint256 _amount,
        uint256 _tokens,
        uint256 _equivalent
    ) internal pure returns (uint256 _result) {
        require(_tokens != 0 && _equivalent != 0, "Oracle provided invalid rate");
        uint256 aux = _tokens.mult(_amount);
        _result = aux / _equivalent;
        if (aux % _equivalent > 0) {
            _result = _result.add(1);
        }
    }

    /**
        Converts an amount in token to the rate currency

        @param _amount Amount to convert in token
        @param _tokens How many tokens
        @param _equivalent How much currency _tokens equivales

        @return Amount in rate currency
    */
    function _fromToken(
        uint256 _amount,
        uint256 _tokens,
        uint256 _equivalent
    ) internal pure returns (uint256) {
        require(_tokens != 0 && _equivalent != 0, "Oracle provided invalid rate");
        return _amount.mult(_equivalent) / _tokens;
    }

    function run(bytes32 _id) external returns (bool) {
        Debt storage debt = debts[_id];
        require(debt.model != Model(0), "Debt does not exist");

        (bool success, bytes32 result) = _safeGasCall(
            address(debt.model),
            abi.encodeWithSelector(
                debt.model.run.selector,
                _id
            )
        );

        if (success) {
            if (debt.error) {
                emit ErrorRecover({
                    _id: _id,
                    _sender: msg.sender,
                    _value: 0,
                    _gasLeft: gasleft(),
                    _gasLimit: block.gaslimit,
                    _result: result,
                    _callData: msg.data
                });

                delete debt.error;
            }

            return result == bytes32(uint256(1));
        } else {
            emit Error({
                _id: _id,
                _sender: msg.sender,
                _value: 0,
                _gasLeft: gasleft(),
                _gasLimit: block.gaslimit,
                _callData: msg.data
            });
            debt.error = true;
        }
    }

    function withdraw(bytes32 _id, address _to) external returns (uint256 amount) {
        require(_to != address(0x0), "_to should not be 0x0");
        require(_isAuthorized(msg.sender, uint256(_id)), "Sender not authorized");
        Debt storage debt = debts[_id];
        amount = debt.balance;
        debt.balance = 0;
        require(token.transfer(_to, amount), "Error sending tokens");
        emit Withdrawn({
            _id: _id,
            _sender: msg.sender,
            _to: _to,
            _amount: amount
        });
    }

    function withdrawPartial(bytes32 _id, address _to, uint256 _amount) external returns (bool success) {
        require(_to != address(0x0), "_to should not be 0x0");
        require(_isAuthorized(msg.sender, uint256(_id)), "Sender not authorized");
        Debt storage debt = debts[_id];
        require(debt.balance >= _amount, "Debt balance is not enought");
        debt.balance = uint128(uint256(debt.balance).sub(_amount));
        require(token.transfer(_to, _amount), "Error sending tokens");
        emit Withdrawn({
            _id: _id,
            _sender: msg.sender,
            _to: _to,
            _amount: _amount
        });
        success = true;
    }

    function withdrawBatch(bytes32[] calldata _ids, address _to) external returns (uint256 total) {
        require(_to != address(0x0), "_to should not be 0x0");
        bytes32 target;
        uint256 balance;
        for (uint256 i = 0; i < _ids.length; i++) {
            target = _ids[i];
            if (_isAuthorized(msg.sender, uint256(target))) {
                balance = debts[target].balance;
                debts[target].balance = 0;
                total += balance;
                emit Withdrawn({
                    _id: target,
                    _sender: msg.sender,
                    _to: _to,
                    _amount: balance
                });
            }
        }
        require(token.transfer(_to, total), "Error sending tokens");
    }

    function getStatus(bytes32 _id) external view returns (Status) {
        Debt storage debt = debts[_id];
        if (debt.error) {
            return Status.ERROR;
        } else {
            (bool success, uint256 result) = _safeGasStaticCall(
                address(debt.model),
                abi.encodeWithSelector(
                    debt.model.getStatus.selector,
                    _id
                )
            );
            return success ? Status(result) : Status.ERROR;
        }
    }

    function _safeGasStaticCall(
        address _contract,
        bytes memory _data
    ) internal view returns (bool success, uint256 result) {
        bytes memory returnData;
        uint256 _gas = (block.gaslimit * 80) / 100;

        (success, returnData) = _contract.staticcall.gas(gasleft() < _gas ? gasleft() : _gas)(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (uint256));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract),
     * relaxing the requirement on the return value
     * @param _contract The contract that receives the call
     * @param _data The call data
     * @return True if the call not reverts and the result of the call
     */
    function _safeGasCall(
        address _contract,
        bytes memory _data
    ) internal returns (bool success, bytes32 result) {
        bytes memory returnData;
        uint256 _gas = (block.gaslimit * 80) / 100;

        (success, returnData) = _contract.call.gas(gasleft() < _gas ? gasleft() : _gas)(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (bytes32));
    }
}

// File: contracts/core/diaspore/interfaces/LoanApprover.sol

pragma solidity ^0.5.11;



/**
    A contract implementing LoanApprover is able to approve loan requests using callbacks,
    to approve a loan the contract should respond the callbacks the result of
    one designated value XOR keccak256("approve-loan-request")

    keccak256("approve-loan-request"): 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a

    To receive calls on the callbacks, the contract should also implement the following ERC165 interfaces:

    approveRequest: 0x76ba6009
    settleApproveRequest: 0xcd40239e
    LoanApprover: 0xbbfa4397
*/
contract LoanApprover is IERC165 {
    /**
        Request the approve of a loan created using requestLoan, if the borrower is this contract,
        to approve the request the contract should return:

        _futureDebt XOR 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a

        @param _futureDebt ID of the loan to approve

        @return _futureDebt XOR keccak256("approve-loan-request"), if the approve is accepted
    */
    function approveRequest(bytes32 _futureDebt) external returns (bytes32);

    /**
        Request the approve of a loan being settled, the contract can be called as borrower or creator.
        To approve the request the contract should return:

        _id XOR 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a

        @param _requestData All the parameters of the loan request
        @param _loanData Data to feed to the Model
        @param _isBorrower True if this contract is the borrower, False if the contract is the creator
        @param _id loanManager.requestSignature(_requestDatam _loanData)

        @return _id XOR keccak256("approve-loan-request"), if the approve is accepted
    */
    function settleApproveRequest(
        bytes calldata _requestData,
        bytes calldata _loanData,
        bool _isBorrower,
        uint256 _id
    )
        external returns (bytes32);
}

// File: contracts/core/diaspore/interfaces/LoanCallback.sol

pragma solidity ^0.5.11;


interface LoanCallback {
    function scheme() external view returns (string memory);

    function onLent(
        bytes32 _id,
        address _lender,
        bytes calldata _data
    ) external returns (bool);

    function acceptsLoan(
        address _engine,
        bytes32 _id,
        address _lender,
        bytes calldata _data
    ) external view returns (bool);
}

// File: contracts/utils/ImplementsInterface.sol

pragma solidity ^0.5.11;


library ImplementsInterface {
    bytes4 constant InvalidID = 0xffffffff;
    bytes4 constant ERC165ID = 0x01ffc9a7;

    function implementsMethod(address _contract, bytes4 _interfaceId) internal view returns (bool) {
        (uint256 success, uint256 result) = _noThrowImplements(_contract, ERC165ID);
        if ((success==0)||(result==0)) {
            return false;
        }

        (success, result) = _noThrowImplements(_contract, InvalidID);
        if ((success==0)||(result!=0)) {
            return false;
        }

        (success, result) = _noThrowImplements(_contract, _interfaceId);
        if ((success==1)&&(result==1)) {
            return true;
        }

        return false;
    }

    function _noThrowImplements(
        address _contract,
        bytes4 _interfaceId
    ) private view returns (uint256 success, uint256 result) {
        bytes4 erc165ID = ERC165ID;
        assembly {
            let x := mload(0x40)               // Find empty storage location using "free memory pointer"
            mstore(x, erc165ID)                // Place signature at begining of empty storage
            mstore(add(x, 0x04), _interfaceId) // Place first argument directly next to signature

            success := staticcall(
                                30000,         // 30k gas
                                _contract,     // To addr
                                x,             // Inputs are stored at location x
                                0x24,          // Inputs are 32 bytes long
                                x,             // Store output over input (saves space)
                                0x20)          // Outputs are 32 bytes long

            result := mload(x)                 // Load the result
        }
    }
}

// File: contracts/utils/BytesUtils.sol

pragma solidity ^0.5.11;


contract BytesUtils {
    function readBytes32(bytes memory data, uint256 index) internal pure returns (bytes32 o) {
        require(data.length / 32 > index, "Reading bytes out of bounds");
        assembly {
            o := mload(add(data, add(32, mul(32, index))))
        }
    }

    function read(bytes memory data, uint256 offset, uint256 length) internal pure returns (bytes32 o) {
        require(data.length >= offset + length, "Reading bytes out of bounds");
        assembly {
            o := mload(add(data, add(32, offset)))
            let lb := sub(32, length)
            if lb { o := div(o, exp(2, mul(lb, 8))) }
        }
    }

    function decode(
        bytes memory _data,
        uint256 _la
    ) internal pure returns (bytes32 _a) {
        require(_data.length >= _la, "Reading bytes out of bounds");
        assembly {
            _a := mload(add(_data, 32))
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
        }
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb
    ) internal pure returns (bytes32 _a, bytes32 _b) {
        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c) {
        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c, bytes32 _d) {
        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld,
        uint256 _le
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c, bytes32 _d, bytes32 _e) {
        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := add(o, _ld)
            _e := mload(o)
            l := sub(32, _le)
            if l { _e := div(_e, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld,
        uint256 _le,
        uint256 _lf
    ) internal pure returns (
        bytes32 _a,
        bytes32 _b,
        bytes32 _c,
        bytes32 _d,
        bytes32 _e,
        bytes32 _f
    ) {
        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := add(o, _ld)
            _e := mload(o)
            l := sub(32, _le)
            if l { _e := div(_e, exp(2, mul(l, 8))) }
            o := add(o, _le)
            _f := mload(o)
            l := sub(32, _lf)
            if l { _f := div(_f, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

}

// File: contracts/core/diaspore/LoanManager.sol

pragma solidity ^0.5.11;












contract LoanManager is BytesUtils, IDebtStatus {
    using ImplementsInterface for address;
    using IsContract for address;
    using SafeMath for uint256;

    uint256 public constant GAS_CALLBACK = 300000;

    DebtEngine public debtEngine;
    IERC20 public token;

    mapping(bytes32 => Request) public requests;
    mapping(bytes32 => bool) public canceledSettles;

    event Requested(
        bytes32 indexed _id,
        uint128 _amount,
        address _model,
        address _creator,
        address _oracle,
        address _borrower,
        address _callback,
        uint256 _salt,
        bytes _loanData,
        uint256 _expiration
    );

    event Approved(bytes32 indexed _id);
    event Lent(bytes32 indexed _id, address _lender, uint256 _tokens);
    event Cosigned(bytes32 indexed _id, address _cosigner, uint256 _cost);
    event Canceled(bytes32 indexed _id, address _canceler);
    event ReadedOracle(address _oracle, uint256 _tokens, uint256 _equivalent);

    event ApprovedRejected(bytes32 indexed _id, bytes32 _response);
    event ApprovedError(bytes32 indexed _id, bytes32 _response);

    event ApprovedByCallback(bytes32 indexed _id);
    event ApprovedBySignature(bytes32 indexed _id);

    event CreatorByCallback(bytes32 indexed _id);
    event BorrowerByCallback(bytes32 indexed _id);
    event CreatorBySignature(bytes32 indexed _id);
    event BorrowerBySignature(bytes32 indexed _id);

    event SettledLend(bytes32 indexed _id, address _lender, uint256 _tokens);
    event SettledCancel(bytes32 indexed _id, address _canceler);

    constructor(DebtEngine _debtEngine) public {
        debtEngine = _debtEngine;
        token = debtEngine.token();
        require(address(token) != address(0), "Error loading token");
    }

    // uint256 getters(legacy)
    function getBorrower(uint256 _id) external view returns (address) { return requests[bytes32(_id)].borrower; }
    function getCreator(uint256 _id) external view returns (address) { return requests[bytes32(_id)].creator; }
    function getOracle(uint256 _id) external view returns (address) { return requests[bytes32(_id)].oracle; }
    function getCosigner(uint256 _id) external view returns (address) { return requests[bytes32(_id)].cosigner; }
    function getCurrency(uint256 _id) external view returns (bytes32) {
        address oracle = requests[bytes32(_id)].oracle;
        return oracle == address(0) ? bytes32(0x0) : RateOracle(oracle).currency();
    }
    function getAmount(uint256 _id) external view returns (uint256) { return requests[bytes32(_id)].amount; }
    function getExpirationRequest(uint256 _id) external view returns (uint256) { return requests[bytes32(_id)].expiration; }
    function getApproved(uint256 _id) external view returns (bool) { return requests[bytes32(_id)].approved; }
    function getModel(uint256 _id) external view returns (address) { return requests[bytes32(_id)].model; }
    function getDueTime(uint256 _id) external view returns (uint256) { return Model(requests[bytes32(_id)].model).getDueTime(bytes32(_id)); }
    function getClosingObligation(uint256 _id) external view returns (uint256) { return Model(requests[bytes32(_id)].model).getClosingObligation(bytes32(_id)); }
    function getLoanData(uint256 _id) external view returns (bytes memory) { return requests[bytes32(_id)].loanData; }
    function getStatus(uint256 _id) external view returns (Status) {
        Request storage request = requests[bytes32(_id)];
        return request.open ? Status.NULL : debtEngine.getStatus(bytes32(_id));
    }
    function ownerOf(uint256 _id) external view returns (address) {
        return debtEngine.ownerOf(_id);
    }

    // bytes32 getters
    function getBorrower(bytes32 _id) external view returns (address) { return requests[_id].borrower; }
    function getCreator(bytes32 _id) external view returns (address) { return requests[_id].creator; }
    function getOracle(bytes32 _id) external view returns (address) { return requests[_id].oracle; }
    function getCosigner(bytes32 _id) external view returns (address) { return requests[_id].cosigner; }
    function getCurrency(bytes32 _id) external view returns (bytes32) {
        address oracle = requests[_id].oracle;
        return oracle == address(0) ? bytes32(0x0) : RateOracle(oracle).currency();
    }
    function getAmount(bytes32 _id) external view returns (uint256) { return requests[_id].amount; }
    function getExpirationRequest(bytes32 _id) external view returns (uint256) { return requests[_id].expiration; }
    function getApproved(bytes32 _id) external view returns (bool) { return requests[_id].approved; }
    function getModel(bytes32 _id) external view returns (address) { return requests[_id].model; }
    function getDueTime(bytes32 _id) external view returns (uint256) { return Model(requests[_id].model).getDueTime(bytes32(_id)); }
    function getClosingObligation(bytes32 _id) external view returns (uint256) { return Model(requests[_id].model).getClosingObligation(bytes32(_id)); }
    function getLoanData(bytes32 _id) external view returns (bytes memory) { return requests[_id].loanData; }
    function getStatus(bytes32 _id) external view returns (Status) {
        Request storage request = requests[_id];
        return request.open ? Status.NULL : debtEngine.getStatus(bytes32(_id));
    }
    function ownerOf(bytes32 _id) external view returns (address) {
        return debtEngine.ownerOf(uint256(_id));
    }

    function getCallback(bytes32 _id) external view returns (address) { return requests[_id].callback; }

    struct Request {
        bool open;
        bool approved;
        uint64 expiration;
        uint128 amount;
        address cosigner;
        address model;
        address creator;
        address oracle;
        address borrower;
        address callback;
        uint256 salt;
        bytes loanData;
    }

    function calcId(
        uint128 _amount,
        address _borrower,
        address _creator,
        address _model,
        address _oracle,
        address _callback,
        uint256 _salt,
        uint64 _expiration,
        bytes memory _data
    ) public view returns (bytes32) {
        uint256 internalSalt = _buildInternalSalt(
            _amount,
            _borrower,
            _creator,
            _callback,
            _salt,
            _expiration
        );

        return keccak256(
            abi.encodePacked(
                uint8(2),
                debtEngine,
                address(this),
                _model,
                _oracle,
                internalSalt,
                _data
            )
        );
    }

    function buildInternalSalt(
        uint128 _amount,
        address _borrower,
        address _creator,
        address _callback,
        uint256 _salt,
        uint64 _expiration
    ) external pure returns (uint256) {
        return _buildInternalSalt(
            _amount,
            _borrower,
            _creator,
            _callback,
            _salt,
            _expiration
        );
    }

    function internalSalt(bytes32 _id) external view returns (uint256) {
        Request storage request = requests[_id];
        require(request.borrower != address(0), "Request does not exist");
        return _internalSalt(request);
    }

    function _internalSalt(Request memory _request) internal pure returns (uint256) {
        return _buildInternalSalt(
            _request.amount,
            _request.borrower,
            _request.creator,
            _request.callback,
            _request.salt,
            _request.expiration
        );
    }

    function requestLoan(
        uint128 _amount,
        address _model,
        address _oracle,
        address _borrower,
        address _callback,
        uint256 _salt,
        uint64 _expiration,
        bytes calldata _loanData
    ) external returns (bytes32 id) {
        require(_borrower != address(0), "The request should have a borrower");
        require(Model(_model).validate(_loanData), "The loan data is not valid");

        id = calcId(
            _amount,
            _borrower,
            msg.sender,
            _model,
            _oracle,
            _callback,
            _salt,
            _expiration,
            _loanData
        );

        require(!canceledSettles[id], "The debt was canceled");

        require(requests[id].borrower == address(0), "Request already exist");

        bool approved = msg.sender == _borrower;

        requests[id] = Request({
            open: true,
            approved: approved,
            cosigner: address(0),
            amount: _amount,
            model: _model,
            creator: msg.sender,
            oracle: _oracle,
            borrower: _borrower,
            callback: _callback,
            salt: _salt,
            loanData: _loanData,
            expiration: _expiration
        });

        emit Requested(
            id,
            _amount,
            _model,
            msg.sender,
            _oracle,
            _borrower,
            _callback,
            _salt,
            _loanData,
            _expiration
        );

        if (!approved) {
            // implements: 0x76ba6009 = approveRequest(bytes32)
            if (_borrower.isContract() && _borrower.implementsMethod(0x76ba6009)) {
                approved = _requestContractApprove(id, _borrower);
                requests[id].approved = approved;
            }
        }

        if (approved) {
            emit Approved(id);
        }
    }

    function _requestContractApprove(
        bytes32 _id,
        address _borrower
    ) internal returns (bool approved) {
        // bytes32 expected = _id XOR keccak256("approve-loan-request");
        bytes32 expected = _id ^ 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a;
        (bool success, bytes32 result) = _safeCall(
            _borrower,
            abi.encodeWithSelector(
                0x76ba6009,
                _id
            )
        );

        approved = success && result == expected;

        // Emit events if approve was rejected or failed
        if (approved) {
            emit ApprovedByCallback(_id);
        } else {
            if (!success) {
                emit ApprovedError(_id, result);
            } else {
                emit ApprovedRejected(_id, result);
            }
        }
    }

    function approveRequest(
        bytes32 _id
    ) external returns (bool) {
        Request storage request = requests[_id];
        require(msg.sender == request.borrower, "Only borrower can approve");
        if (!request.approved) {
            request.approved = true;
            emit Approved(_id);
        }
        return true;
    }

    function registerApproveRequest(
        bytes32 _id,
        bytes calldata _signature
    ) external returns (bool approved) {
        Request storage request = requests[_id];
        address borrower = request.borrower;

        if (!request.approved) {
            if (borrower.isContract() && borrower.implementsMethod(0x76ba6009)) {
                approved = _requestContractApprove(_id, borrower);
            } else {
                bytes32 _hash = keccak256(
                    abi.encodePacked(
                        _id,
                        "sign approve request"
                    )
                );

                address signer = ecrecovery(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            _hash
                        )
                    ),
                    _signature
                );

                if (borrower == signer) {
                    emit ApprovedBySignature(_id);
                    approved = true;
                }
            }
        }

        // Check request.approved again, protect against reentrancy
        if (approved && !request.approved) {
            request.approved = true;
            emit Approved(_id);
        }
    }

    function lend(
        bytes32 _id,
        bytes memory _oracleData,
        address _cosigner,
        uint256 _cosignerLimit,
        bytes memory _cosignerData,
        bytes memory _callbackData
    ) public returns (bool) {
        Request storage request = requests[_id];
        require(request.open, "Request is no longer open");
        require(request.approved, "The request is not approved by the borrower");
        require(request.expiration > now, "The request is expired");

        request.open = false;

        uint256 tokens = _currencyToToken(request.oracle, request.amount, _oracleData);
        require(
            token.transferFrom(
                msg.sender,
                request.borrower,
                tokens
            ),
            "Error sending tokens to borrower"
        );

        emit Lent(_id, msg.sender, tokens);

        // Generate the debt
        require(
            debtEngine.create2(
                Model(request.model),
                msg.sender,
                request.oracle,
                _internalSalt(request),
                request.loanData
            ) == _id,
            "Error creating the debt"
        );

        // Call the cosigner
        if (_cosigner != address(0)) {
            uint256 auxSalt = request.salt;
            request.cosigner = address(uint256(_cosigner) + 2);
            request.salt = _cosignerLimit; // Risky ?
            require(
                Cosigner(_cosigner).requestCosign(
                    address(this),
                    uint256(_id),
                    _cosignerData,
                    _oracleData
                ),
                "Cosign method returned false"
            );
            require(request.cosigner == _cosigner, "Cosigner didn't callback");
            request.salt = auxSalt;
        }

        // Call the loan callback
        address callback = request.callback;
        if (callback != address(0)) {
            require(LoanCallback(callback).onLent.gas(GAS_CALLBACK)(_id, msg.sender, _callbackData), "Rejected by loan callback");
        }

        return true;
    }

    function cancel(bytes32 _id) external returns (bool) {
        Request storage request = requests[_id];

        require(request.open, "Request is no longer open or not requested");
        require(
            request.creator == msg.sender || request.borrower == msg.sender,
            "Only borrower or creator can cancel a request"
        );

        delete request.loanData;
        delete requests[_id];
        canceledSettles[_id] = true;

        emit Canceled(_id, msg.sender);

        return true;
    }

    function cosign(uint256 _id, uint256 _cost) external returns (bool) {
        Request storage request = requests[bytes32(_id)];
        require(request.cosigner != address(0), "Cosigner 0x0 is not valid");
        require(request.expiration > now, "Request is expired");
        require(request.cosigner == address(uint256(msg.sender) + 2), "Cosigner not valid");
        request.cosigner = msg.sender;
        if (_cost != 0){
            require(request.salt >= _cost, "Cosigner cost exceeded");
            require(token.transferFrom(debtEngine.ownerOf(_id), msg.sender, _cost), "Error paying cosigner");
        }
        emit Cosigned(bytes32(_id), msg.sender, _cost);
        return true;
    }

    // ///
    // Offline requests
    // ///

    uint256 private constant L_AMOUNT = 16;
    uint256 private constant O_AMOUNT = 0;
    uint256 private constant O_MODEL = L_AMOUNT;
    uint256 private constant L_MODEL = 20;
    uint256 private constant O_ORACLE = O_MODEL + L_MODEL;
    uint256 private constant L_ORACLE = 20;
    uint256 private constant O_BORROWER = O_ORACLE + L_ORACLE;
    uint256 private constant L_BORROWER = 20;
    uint256 private constant O_SALT = O_BORROWER + L_BORROWER;
    uint256 private constant L_SALT = 32;
    uint256 private constant O_EXPIRATION = O_SALT + L_SALT;
    uint256 private constant L_EXPIRATION = 8;
    uint256 private constant O_CREATOR = O_EXPIRATION + L_EXPIRATION;
    uint256 private constant L_CREATOR = 20;
    uint256 private constant O_CALLBACK = O_CREATOR + L_CREATOR;
    uint256 private constant L_CALLBACK = 20;

    function encodeRequest(
        uint128 _amount,
        address _model,
        address _oracle,
        address _borrower,
        address _callback,
        uint256 _salt,
        uint64 _expiration,
        address _creator,
        bytes calldata _loanData
    ) external view returns (bytes memory requestData, bytes32 id) {
        requestData = abi.encodePacked(
            _amount,
            _model,
            _oracle,
            _borrower,
            _salt,
            _expiration,
            _creator,
            _callback
        );

        uint256 innerSalt = _buildInternalSalt(
            _amount,
            _borrower,
            _creator,
            _callback,
            _salt,
            _expiration
        );

        id = debtEngine.buildId2(
            address(this),
            _model,
            _oracle,
            innerSalt,
            _loanData
        );
    }

    function settleLend(
        bytes memory _requestData,
        bytes memory _loanData,
        address _cosigner,
        uint256 _maxCosignerCost,
        bytes memory _cosignerData,
        bytes memory _oracleData,
        bytes memory _creatorSig,
        bytes memory _borrowerSig,
        bytes memory _callbackData
    ) public returns (bytes32 id) {
        // Validate request
        require(uint256(read(_requestData, O_EXPIRATION, L_EXPIRATION)) > now, "Loan request is expired");

        // Get id
        uint256 innerSalt;
        (id, innerSalt) = _buildSettleId(_requestData, _loanData);

        require(requests[id].borrower == address(0), "Request already exist");

        // Transfer tokens to borrower
        uint256 tokens = _currencyToToken(_requestData, _oracleData);
        require(
            token.transferFrom(
                msg.sender,
                address(uint256(read(_requestData, O_BORROWER, L_BORROWER))),
                tokens
            ),
            "Error sending tokens to borrower"
        );

        // Generate the debt
        require(
            _createDebt(
                _requestData,
                _loanData,
                innerSalt
            ) == id,
            "Error creating debt registry"
        );

        emit SettledLend(id, msg.sender, tokens);

        // Save the request info
        requests[id] = Request({
            open: false,
            approved: true,
            cosigner: _cosigner,
            amount: uint128(uint256(read(_requestData, O_AMOUNT, L_AMOUNT))),
            model: address(uint256(read(_requestData, O_MODEL, L_MODEL))),
            creator: address(uint256(read(_requestData, O_CREATOR, L_CREATOR))),
            oracle: address(uint256(read(_requestData, O_ORACLE, L_ORACLE))),
            borrower: address(uint256(read(_requestData, O_BORROWER, L_BORROWER))),
            callback: address(uint256(read(_requestData, O_CALLBACK, L_CALLBACK))),
            salt: _cosigner != address(0) ? _maxCosignerCost : uint256(read(_requestData, O_SALT, L_SALT)),
            loanData: _loanData,
            expiration: uint64(uint256(read(_requestData, O_EXPIRATION, L_EXPIRATION)))
        });

        Request storage request = requests[id];

        // Validate signatures
        _validateSettleSignatures(id, _requestData, _loanData, _creatorSig, _borrowerSig);

        // Call the cosigner
        if (_cosigner != address(0)) {
            request.cosigner = address(uint256(_cosigner) + 2);
            require(Cosigner(_cosigner).requestCosign(address(this), uint256(id), _cosignerData, _oracleData), "Cosign method returned false");
            require(request.cosigner == _cosigner, "Cosigner didn't callback");
            request.salt = uint256(read(_requestData, O_SALT, L_SALT));
        }

        // Call the loan callback
        address callback = address(uint256(read(_requestData, O_CALLBACK, L_CALLBACK)));
        if (callback != address(0)) {
            require(LoanCallback(callback).onLent.gas(GAS_CALLBACK)(id, msg.sender, _callbackData), "Rejected by loan callback");
        }
    }

    function settleCancel(
        bytes calldata _requestData,
        bytes calldata _loanData
    ) external returns (bool) {
        (bytes32 id, ) = _buildSettleId(_requestData, _loanData);
        require(
            msg.sender == address(uint256(read(_requestData, O_BORROWER, L_BORROWER))) ||
            msg.sender == address(uint256(read(_requestData, O_CREATOR, L_CREATOR))),
            "Only borrower or creator can cancel a settle"
        );
        canceledSettles[id] = true;
        emit SettledCancel(id, msg.sender);

        return true;
    }

    function _validateSettleSignatures(
        bytes32 _id,
        bytes memory _requestData,
        bytes memory _loanData,
        bytes memory _creatorSig,
        bytes memory _borrowerSig
    ) internal {
        require(!canceledSettles[_id], "Settle was canceled");

        // bytes32 expected = uint256(_id) XOR keccak256("approve-loan-request");
        bytes32 expected = _id ^ 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a;
        address borrower = address(uint256(read(_requestData, O_BORROWER, L_BORROWER)));
        address creator = address(uint256(read(_requestData, O_CREATOR, L_CREATOR)));
        bytes32 _hash;

        if (borrower.isContract()) {
            require(
                LoanApprover(borrower).settleApproveRequest(_requestData, _loanData, true, uint256(_id)) == expected,
                "Borrower contract rejected the loan"
            );

            emit BorrowerByCallback(_id);
        } else {
            _hash = keccak256(
                abi.encodePacked(
                    _id,
                    "sign settle lend as borrower"
                )
            );
            require(
                borrower == ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _borrowerSig),
                "Invalid borrower signature"
            );

            emit BorrowerBySignature(_id);
        }

        if (borrower != creator) {
            if (creator.isContract()) {
                require(
                    LoanApprover(creator).settleApproveRequest(_requestData, _loanData, false, uint256(_id)) == expected,
                    "Creator contract rejected the loan"
                );

                emit CreatorByCallback(_id);
            } else {
                _hash = keccak256(
                    abi.encodePacked(
                        _id,
                        "sign settle lend as creator"
                    )
                );
                require(
                    creator == ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _creatorSig),
                    "Invalid creator signature"
                );

                emit CreatorBySignature(_id);
            }
        }
    }

    function _currencyToToken(
        bytes memory _requestData,
        bytes memory _oracleData
    ) internal returns (uint256) {
        return _currencyToToken(
            address(uint256(read(_requestData, O_ORACLE, L_ORACLE))),
            uint256(read(_requestData, O_AMOUNT, L_AMOUNT)),
            _oracleData
        );
    }

    function _createDebt(
        bytes memory _requestData,
        bytes memory _loanData,
        uint256 _innerSalt
    ) internal returns (bytes32) {
        return debtEngine.create2(
            Model(address(uint256(read(_requestData, O_MODEL, L_MODEL)))),
            msg.sender,
            address(uint256(read(_requestData, O_ORACLE, L_ORACLE))),
            _innerSalt,
            _loanData
        );
    }

    function _buildSettleId(
        bytes memory _requestData,
        bytes memory _loanData
    ) internal view returns (bytes32 id, uint256 innerSalt) {
        (
            uint128 amount,
            address model,
            address oracle,
            address borrower,
            uint256 salt,
            uint64 expiration,
            address creator
        ) = _decodeSettle(_requestData);

        innerSalt = _buildInternalSalt(
            amount,
            borrower,
            creator,
            address(uint256(read(_requestData, O_CALLBACK, L_CALLBACK))),
            salt,
            expiration
        );

        id = debtEngine.buildId2(
            address(this),
            model,
            oracle,
            innerSalt,
            _loanData
        );
    }

    function _buildInternalSalt(
        uint128 _amount,
        address _borrower,
        address _creator,
        address _callback,
        uint256 _salt,
        uint64 _expiration
    ) internal pure returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    _amount,
                    _borrower,
                    _creator,
                    _callback,
                    _salt,
                    _expiration
                )
            )
        );
    }

    function _decodeSettle(
        bytes memory _data
    ) internal pure returns (
        uint128 amount,
        address model,
        address oracle,
        address borrower,
        uint256 salt,
        uint64 expiration,
        address creator
    ) {
        (
            bytes32 _amount,
            bytes32 _model,
            bytes32 _oracle,
            bytes32 _borrower,
            bytes32 _salt,
            bytes32 _expiration
        ) = decode(_data, L_AMOUNT, L_MODEL, L_ORACLE, L_BORROWER, L_SALT, L_EXPIRATION);

        amount = uint128(uint256(_amount));
        model = address(uint256(_model));
        oracle = address(uint256(_oracle));
        borrower = address(uint256(_borrower));
        salt = uint256(_salt);
        expiration = uint64(uint256(_expiration));
        creator = address(uint256(read(_data, O_CREATOR, L_CREATOR)));
    }

    function ecrecovery(bytes32 _hash, bytes memory _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := and(mload(add(_sig, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(_hash, v, r, s);
    }

    function _currencyToToken(
        address _oracle,
        uint256 _amount,
        bytes memory _oracleData
    ) internal returns (uint256) {
        if (_oracle == address(0)) return _amount;
        (uint256 tokens, uint256 equivalent) = RateOracle(_oracle).readSample(_oracleData);

        emit ReadedOracle(_oracle, tokens, equivalent);

        return tokens.mult(_amount) / equivalent;
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract),
     * relaxing the requirement on the return value
     * @param _contract The borrower contract that receives the approveRequest(bytes32) call
     * @param _data The call data
     * @return True if the call not reverts and the result of the call
     */
    function _safeCall(
        address _contract,
        bytes memory _data
    ) internal returns (bool success, bytes32 result) {
        bytes memory returnData;
        (success, returnData) = _contract.call(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (bytes32));
    }
}

// File: contracts/core/diaspore/cosigner/interfaces/CollateralAuctionCallback.sol

pragma solidity ^0.5.11;


interface CollateralAuctionCallback {
    function auctionClosed(
        uint256 _id,
        uint256 _leftover,
        uint256 _received,
        bytes calldata _data
    ) external;
}

// File: contracts/core/diaspore/cosigner/interfaces/CollateralHandler.sol

pragma solidity ^0.5.11;


interface CollateralHandler {
    function handle(
        uint256 _entryId,
        uint256 _amount,
        bytes calldata _data
    ) external returns (uint256 surplus);
}

// File: contracts/commons/ReentrancyGuard.sol

pragma solidity ^0.5.11;


contract ReentrancyGuard {
    uint256 private _reentrantFlag;

    uint256 private constant FLAG_LOCKED = 1;
    uint256 private constant FLAG_UNLOCKED = 2;

    constructor() public {
        _reentrantFlag = FLAG_UNLOCKED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_reentrantFlag != FLAG_LOCKED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _reentrantFlag = FLAG_LOCKED;
        _;
        _reentrantFlag = FLAG_UNLOCKED;
    }
}

// File: contracts/commons/Fixed224x32.sol

pragma solidity ^0.5.11;



library Fixed224x32 {
    uint256 private constant BASE = 4294967296; // 2 ** 32
    uint256 private constant DEC_BITS = 32;
    uint256 private constant INT_BITS = 224;

    using Fixed224x32 for bytes32;
    using SafeMath for uint256;

    function from(
        uint256 _num
    ) internal pure returns (bytes32) {
        return bytes32(_num.mult(BASE));
    }

    function raw(
        uint256 _raw
    ) internal pure returns (bytes32) {
        return bytes32(_raw);
    }

    function toUint256(
        bytes32 _a
    ) internal pure returns (uint256) {
        return uint256(_a) >> DEC_BITS;
    }

    function add(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {
        return bytes32(uint256(_a).add(uint256(_b)));
    }

    function sub(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {
        return bytes32(uint256(_a).sub(uint256(_b)));
    }

    function mul(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {
        uint256 a = uint256(_a);
        uint256 b = uint256(_b);

        return bytes32((a.mult(b) >> DEC_BITS));
    }

    function floor(
        bytes32 _a
    ) internal pure returns (bytes32) {
        return (_a >> DEC_BITS) << DEC_BITS;
    }

    function ceil(
        bytes32 _a
    ) internal pure returns (bytes32) {
        uint256 rawDec = uint256(_a << INT_BITS);
        if (rawDec != 0) {
            uint256 diff = BASE.sub(rawDec >> INT_BITS);
            return bytes32(uint256(_a).add(diff));
        }

        return _a;
    }

    function div(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {
        uint256 a = uint256(_a);
        uint256 b = uint256(_b);

        return bytes32((a.mult(BASE)) / b);
    }

    function gt(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {
        return uint256(_a) > uint256(_b);
    }

    function gte(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {
        return uint256(_a) >= uint256(_b);
    }

    function lt(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {
        return uint256(_a) < uint256(_b);
    }

    function lte(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {
        return uint256(_a) <= uint256(_b);
    }

    function eq(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {
        return _a == _b;
    }
}

// File: contracts/utils/SafeERC20.sol

pragma solidity ^0.5.11;



/**
* @dev Library to perform safe calls to standard method for ERC20 tokens.
*
* Why Transfers: transfer methods could have a return value (bool), throw or revert for insufficient funds or
* unathorized value.
*
* Why Approve: approve method could has a return value (bool) or does not accept 0 as a valid value (BNB token).
* The common strategy used to clean approvals.
*
* We use the Solidity call instead of interface methods because in the case of transfer, it will fail
* for tokens with an implementation without returning a value.
* Since versions of Solidity 0.4.22 the EVM has a new opcode, called RETURNDATASIZE.
* This opcode stores the size of the returned data of an external call. The code checks the size of the return value
* after an external call and reverts the transaction in case the return data is shorter than expected
*
* Source: https://github.com/nachomazzara/SafeERC20/blob/master/contracts/libs/SafeERC20.sol
* Author: Ignacio Mazzara
*/
library SafeERC20 {
    /**
    * @dev Transfer token for a specified address
    * @param _token erc20 The address of the ERC20 contract
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {
        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            // Insufficient funds
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        // Fail if the new balance its not equal than previous balance sub _value
        return prevBalance - _value == _token.balanceOf(address(this));
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _token erc20 The address of the ERC20 contract
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {
        uint256 prevBalance = _token.balanceOf(_from);

        if (
          prevBalance < _value || // Insufficient funds
          _token.allowance(_from, address(this)) < _value // Insufficient allowance
        ) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        // Fail if the new balance its not equal than previous balance sub _value
        return prevBalance - _value == _token.balanceOf(_from);
    }

   /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * @param _token erc20 The address of the ERC20 contract
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   * @return bool whether the approve was successful or not
   */
    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {
        address(_token).call(
            abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        // Fail if the new allowance its not equal than _value
        return _token.allowance(address(this), _spender) == _value;
    }

   /**
   * @dev Clear approval
   * Note that if 0 is not a valid value it will be set to 1.
   * @param _token erc20 The address of the ERC20 contract
   * @param _spender The address which will spend the funds.
   */
    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {
        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}

// File: contracts/core/diaspore/utils/DiasporeUtils.sol

pragma solidity ^0.5.11;









library DiasporeUtils {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function oracle(
        LoanManager _manager,
        bytes32 _id
    ) internal view returns (RateOracle) {
        return RateOracle(_manager.getOracle(_id));
    }

    function safePayToken(
        LoanManager _manager,
        bytes32 _id,
        uint256 _amount,
        address _sender,
        bytes memory _oracleData
    ) internal returns (uint256 paid, uint256 tokens) {
        IERC20 token = IERC20(_manager.token());
        DebtEngine engine = DebtEngine(_manager.debtEngine());
        require(token.safeApprove(address(engine), _amount), "Error approve debt engine");

        uint256 prevBalance = token.balanceOf(address(this));

        (paid, tokens) = engine.payToken(
            _id,
            _amount,
            _sender,
            _oracleData
        );

        require(token.clearApprove(address(engine)), "Error clear approve");
        require(prevBalance.sub(token.balanceOf(address(this))) <= tokens, "Debt engine pulled too many tokens");
    }
}

// File: contracts/core/diaspore/utils/OracleUtils.sol

pragma solidity ^0.5.11;




library OracleUtils {
    using OracleUtils for OracleUtils.Sample;
    using OracleUtils for RateOracle;
    using SafeMath for uint256;

    struct Sample {
        uint256 tokens;
        uint256 equivalent;
    }

    function read(
        RateOracle _oracle,
        bytes memory data
    ) internal returns (Sample memory s) {
        if (address(_oracle) == address(0)) {
            s.tokens = 1;
            s.equivalent = 1;
        } else {
            (
                s.tokens,
                s.equivalent
            ) = _oracle.readSample(data);
        }
    }

    /*
        @dev Will fail with oracles that required oracle data
    */
    function read(
        RateOracle _oracle
    ) internal returns (Sample memory s) {
        s = _oracle.read("");
    }

    /*
        @dev Will fail if the oracle changes the contract state
    */
    function readStatic(
        RateOracle _oracle,
        bytes memory data
    ) internal view returns (Sample memory s) {
        if (address(_oracle) == address(0)) {
            s.tokens = 1;
            s.equivalent = 1;
        } else {
            (
                bool success,
                bytes memory returnData
            ) = address(_oracle).staticcall(
                abi.encodeWithSelector(
                    _oracle.readSample.selector,
                    data
                )
            );

            require(success, "oracle-utils: error static reading oracle");

            (
                s.tokens,
                s.equivalent
            ) = abi.decode(returnData, (uint256, uint256));
        }
    }

    /*
        @dev Will fail with oracles that required oracle data and
            if the oracle changes the contract state
    */
    function readStatic(
        RateOracle _oracle
    ) internal view returns (Sample memory s) {
        s = _oracle.readStatic("");
    }

    function encode(
        uint256 _tokens,
        uint256 _equivalent
    ) internal pure returns (Sample memory s) {
        s.tokens = _tokens;
        s.equivalent = _equivalent;
    }

    function toTokens(
        Sample memory _sample,
        uint256 _base
    ) internal pure returns (
        uint256 tokens
    ) {
        tokens = _sample.toTokens(_base, false);
    }

    function toTokens(
        Sample memory _sample,
        uint256 _base,
        bool ceil
    ) internal pure returns (
        uint256 tokens
    ) {
        if (_sample.tokens == 1 && _sample.equivalent == 1) {
            tokens = _base;
        } else {
            uint256 mul = _base.mult(_sample.tokens);
            tokens = mul.div(_sample.equivalent);
            if (ceil && mul % tokens != 0) {
                tokens = tokens.add(1);
            }
        }
    }

    function toBase(
        Sample memory _sample,
        uint256 _tokens
    ) internal pure returns (
        uint256 base
    ) {
        base = _sample.toBase(_tokens, false);
    }

    function toBase(
        Sample memory _sample,
        uint256 _tokens,
        bool ceil
    ) internal pure returns (
        uint256 base
    ) {
        if (_sample.tokens == 1 && _sample.equivalent == 1) {
            base = _tokens;
        } else {
            uint256 mul = _tokens.mult(_sample.equivalent);
            base = mul.div(_sample.tokens);
            if (ceil && mul % base != 0) {
                base = base.add(1);
            }
        }
    }
}

// File: contracts/utils/SafeCast.sol

pragma solidity ^0.5.11;


library SafeCast {
    function toUint128(uint256 _a) internal pure returns (uint128) {
        require(_a < 2 ** 128, "cast overflow");
        return uint128(_a);
    }

    function toUint256(int256 _i) internal pure returns (uint256) {
        require(_i >= 0, "cast to unsigned must be positive");
        return uint256(_i);
    }

    function toInt256(uint256 _i) internal pure returns (int256) {
        require(_i < 2 ** 255, "cast overflow");
        return int256(_i);
    }

    function toUint32(uint256 _i) internal pure returns (uint32) {
        require(_i < 2 ** 32, "cast overdlow");
        return uint32(_i);
    }
}

// File: contracts/utils/Math.sol

pragma solidity ^0.5.11;


library Math {
    function min(int256 _a, int256 _b) internal pure returns (int256) {
        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function max(int256 _a, int256 _b) internal pure returns (int256) {
        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }
}

// File: contracts/core/diaspore/cosigner/CollateralAuction.sol

pragma solidity ^0.5.11;











/**
    @title ERC-20 Dutch auction
    @author Agustin Aguilar <agustin@ripiocredit.network> & Victor Fage <victor.fage@ripiocredit.network>
    @notice Auctions tokens in exchange for `baseToken` using a Dutch auction scheme,
        the owner of the contract is the sole beneficiary of all the auctions.
        Auctions follow two linear functions to determine the exchange rate that
        are determined by the provided `reference` rate.
    @dev If the auction token matches the requested `baseToken`,
        the auction has a fixed rate of 1:1
*/
contract CollateralAuction is ReentrancyGuard, Ownable {
    using IsContract for address payable;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeCast for uint256;

    uint256 private constant DELTA_TO_MARKET = 10 minutes;
    uint256 private constant DELTA_FINISH = 1 days;

    IERC20 public baseToken;
    Auction[] public auctions;

    struct Auction {
        IERC20 fromToken;    // Token that we are intending to sell
        uint64 startTime;    // Start time of the auction
        uint32 limitDelta;   // Limit time until all collateral is offered
        uint256 startOffer;  // Start offer of `fromToken` for the requested `amount`
        uint256 amount;      // Amount that we need to receive of `baseToken`
        uint256 limit;       // Limit of how much are willing to spend of `fromToken`
    }

    event CreatedAuction(
        uint256 indexed _id,
        IERC20 _fromToken,
        uint256 _startOffer,
        uint256 _refOffer,
        uint256 _amount,
        uint256 _limit
    );

    event Take(
        uint256 indexed _id,
        address _taker,
        uint256 _selling,
        uint256 _requesting
    );

    constructor(IERC20 _baseToken) public {
        baseToken = _baseToken;
        // Auction IDs start at 1
        auctions.length++;
    }

    /**
        @notice Returns the size of the auctions array

        @dev The auction with ID 0 is invalid, thus the value
            returned by this method is the total number of auctions + 1

        @return The size of the auctions array
    */
    function getAuctionsLength() external view returns (uint256) {
        return auctions.length;
    }

    /**
        @notice Creates a new auction that starts immediately, any address
            can start an auction, but the beneficiary of all auctions is the
            owner of the contract

        @param _fromToken Token to be sold in exchange for `baseToken`
        @param _start Initial offer of `fromToken` for the requested `_amount` of base,
            should be below the market reference
        @param _ref Reference or "market" offer of `fromToken` for the requested `_amount` of base,
            it should be estimated with the current exchange rate, the real offered amount reaches
            this value after 10 minutes
        @param _limit Maximum amount of `fromToken` to exchange for the requested `_amount` of base,
            after this limit is reached, the requested `_amount` starts to reduce
        @param _amount Amount requested in exchange for `fromToken` until `_limit is reached`

        @return The ID of the created auction
    */
    function create(
        IERC20 _fromToken,
        uint256 _start,
        uint256 _ref,
        uint256 _limit,
        uint256 _amount
    ) external nonReentrant() returns (uint256 id) {
        require(_start < _ref, "auction: offer should be below refence offer");
        require(_ref <= _limit, "auction: reference offer should be below or equal to limit");

        // Calculate how much time takes the auction to offer all the `_limit` tokens
        // in exchange for the requested base `_amount`, this delta defines the linear
        // function of the first half of the auction
        uint32 limitDelta = ((_limit - _start).mult(DELTA_TO_MARKET) / (_ref - _start)).toUint32();

        // Pull tokens for the auction, the full `_limit` is pulled
        // any exceeding tokens will be returned at the end of the auction
        require(_fromToken.safeTransferFrom(msg.sender, address(this), _limit), "auction: error pulling _fromToken");

        // Create and store the auction
        id = auctions.push(Auction({
            fromToken: _fromToken,
            startTime: uint64(_now()),
            limitDelta: limitDelta,
            startOffer: _start,
            amount: _amount,
            limit: _limit
        })) - 1;

        emit CreatedAuction(
            id,
            _fromToken,
            _start,
            _ref,
            _amount,
            _limit
        );
    }

    /**
        @notice Takes an ongoing auction, exchanging the requested `baseToken`
            for offered `fromToken`. The `baseToken` are transfered to the owner
            address and a callback to the owner is called for further processing of the tokens

        @dev In the context of a collateral auction, the tokens are used to pay a loan.
            If the oracle of the loan requires `oracleData`, such oracle data should be included
            on the `_data` field

        @dev The taker of the auction may request a callback to it's own address, this is
            intended to allow the taker to use the newly received `fromToken` and perform
            arbitrage with a dex before providing the requested `baseToken`

        @param _id ID of the auction to take
        @param _data Arbitrary data field that's passed to the owner
        @param _callback Requests a callback for the taker of the auction,
            that may be used to perform arbitrage
    */
    function take(
        uint256 _id,
        bytes calldata _data,
        bool _callback
    ) external nonReentrant() {
        Auction memory auction = auctions[_id];
        require(auction.amount != 0, "auction: does not exists");
        IERC20 fromToken = auction.fromToken;

        // Load the current rate of the auction
        // how much `fromToken` is being sold and how much
        // `baseToken` is requested
        (uint256 selling, uint256 requesting) = _offer(auction);
        address owner = _owner;

        // Any non-offered `fromToken` is going
        // to be returned to the owner
        uint256 leftOver = auction.limit - selling;

        // Delete auction entry
        delete auctions[_id];

        // Send the auctioned tokens to the sender
        // this is done first, because the sender may be doing arbitrage
        // and for that, it needs the tokens that's going to sell
        require(fromToken.safeTransfer(msg.sender, selling), "auction: error sending tokens");

        // If a callback is requested, we ping the sender so it can perform arbitrage
        if (_callback) {
            /* solium-disable-next-line */
            (bool success, ) = msg.sender.call(abi.encodeWithSignature("onTake(address,uint256,uint256)", fromToken, selling, requesting));
            require(success, "auction: error during callback onTake()");
        }

        // Swap tokens for base, send base directly to the owner
        require(baseToken.transferFrom(msg.sender, owner, requesting), "auction: error pulling tokens");

        // Send any leftOver tokens
        require(fromToken.safeTransfer(owner, leftOver), "auction: error sending leftover tokens");

        // Callback to owner to process the closed auction
        CollateralAuctionCallback(owner).auctionClosed(
            _id,
            leftOver,
            requesting,
            _data
        );

        emit Take(
            _id,
            msg.sender,
            selling,
            requesting
        );
    }

    /**
        @notice Calculates the current offer of an auction if it were to be taken,
            how much `baseTokens` are being requested for how much `baseToken`

        @param _id ID of the auction

        @return How much is being requested and how much is being offered
    */
    function offer(
        uint256 _id
    ) external view returns (uint256 selling, uint256 requesting) {
        return _offer(auctions[_id]);
    }

    /**
        @notice Returns the current timestamp

        @dev Used for unit testing

        @return The current Unix timestamp
    */
    function _now() internal view returns (uint256) {
        return now;
    }

    /**
        @notice Calculates the current offer of an auction, with the auction
            in memory

        @dev If `fromToken` and `baseToken` are the same token, the auction
            rate is fixed as 1:1

        @param _auction Aunction in memory

        @return How much is being requested and how much is being offered
    */
    function _offer(
        Auction memory _auction
    ) private view returns (uint256, uint256) {
        if (_auction.fromToken == baseToken) {
            // if the offered token is the same as the base token
            // the auction is skipped, and the requesting and selling amount are the same
            uint256 min = Math.min(_auction.limit, _auction.amount);
            return (min, min);
        } else {
            // Calculate selling and requesting amounts
            // for the current timestamp
            return (_selling(_auction), _requesting(_auction));
        }
    }

    /**
        @notice Calculates how much `fromToken` is being sold, within the defined `_limit`
            the auction starts at `startOffer` and the offer it's increased linearly until
            reaching `reference` offer (after 10 minutes). Then the linear function continues
            until all the collateral is being offered

        @param _auction Auction in memory

        @return How much `fromToken` is being offered
    */
    function _selling(
        Auction memory _auction
    ) private view returns (uint256 _amount) {
        uint256 deltaTime = _now() - _auction.startTime;

        if (deltaTime < _auction.limitDelta) {
            uint256 deltaAmount = _auction.limit - _auction.startOffer;
            _amount = _auction.startOffer.add(deltaAmount.mult(deltaTime) / _auction.limitDelta);
        } else {
            _amount = _auction.limit;
        }
    }

    /**
        @notice Calculates how much `baseToken` is being requested, before offering
            all the `_limit` `fromToken` the total `_amount` of `baseToken` is requested.
            After all the `fromToken` is being offered, the auction switches and the requested
            `baseToken` goes down linearly, until reaching 1 after 24 hours

        @dev If the auction is not taken after the requesting amount can reaches 1, the second part
            of the auction restarts and the initial amount of `baseToken` is requested, the process
            repeats until the auction is taken

        @param _auction Auction in memory

        @return How much `baseToken` are being requested
    */
    function _requesting(
        Auction memory _auction
    ) private view returns (uint256 _amount) {
        uint256 ogDeltaTime = _now() - _auction.startTime;

        if (ogDeltaTime > _auction.limitDelta) {
            uint256 deltaTime = ogDeltaTime - _auction.limitDelta;
            return _auction.amount.sub(_auction.amount.mult(deltaTime % DELTA_FINISH) / DELTA_FINISH);
        } else {
            return _auction.amount;
        }
    }
}

// File: contracts/core/diaspore/cosigner/CollateralLib.sol

pragma solidity ^0.5.11;






/**
    @title Loan collateral simulator
    @author Agustin Aguilar <agustin@ripiocredit.network> & Victor Fage <victor.fage@ripiocredit.network>
    @notice Implements schemes and rules for a generic collateralization,
        and liquidations for under-collateralized entries
    @dev `debt` and `collateral` may not be in the same currency,
        in such a case, an oracle is used to compare both
    @dev `base` and `tokens` calls to Oracle are inverted, in this context
        the `tokens` value provided by the Oracle corresponds to the `base` tokens value
*/
library CollateralLib {
    using CollateralLib for CollateralLib.Entry;
    using OracleUtils for OracleUtils.Sample;
    using OracleUtils for RateOracle;
    using Fixed224x32 for bytes32;

    struct Entry {
        bytes32 debtId;
        uint256 amount;
        RateOracle oracle;
        IERC20 token;
        uint96 liquidationRatio;
        uint96 balanceRatio;
    }

    /**
        @notice Builds a Collateral struct with the provided data.

        @dev The library is only compatible with Oracles that don't require `oracleData`,
            this condition is not validated at this stage

        @param _oracle Oracle for the collateral
        @param _token Token used as collateral
        @param _debtId Debt ID tied to the collateral
        @param _amount Amount of `_token` provided as collateral
        @param _liquidationRatio collateral/debt ratio that triggers a liquidation
        @param _balanceRatio collateral/debt ratio aimed during collateral liquidation

        @return The new Collateral Entry in memory
    */
    function create(
        RateOracle _oracle,
        IERC20 _token,
        bytes32 _debtId,
        uint256 _amount,
        uint96 _liquidationRatio,
        uint96 _balanceRatio
    ) internal pure returns (Entry memory _col) {
        require(_liquidationRatio < _balanceRatio, "collateral-lib: _liquidationRatio should be below _balanceRatio");
        require(_liquidationRatio > 2 ** 32, "collateral-lib: _liquidationRatio should be above one");
        require(address(_token) != address(0), "collateral-lib: _token can't be address zero");

        _col.oracle = _oracle;
        _col.token = _token;
        _col.debtId = _debtId;
        _col.amount = _amount;
        _col.liquidationRatio = _liquidationRatio;
        _col.balanceRatio = _balanceRatio;
    }

    /**
        @notice Calculates the value of a given collateral in `base` tokens
            by reading the oracle and applying the convertion rate
            to the collateral amount

        @param _col Collateral entry in memory

        @return The vaule of the collateral amount in `base` tokens
    */
    function toBase(
        Entry memory _col
    ) internal view returns (uint256) {
        return _col.oracle
            .readStatic()
            .toTokens(_col.amount);
    }

    /**
        @dev Returns the collateral/debt ratio between the collateral
            and the provided `_debt` value.

        @param _col Collateral entry in memory
        @param _debt Current total debt in `base`

        @return Fixed224x32 with collateral ratio
    */
    function ratio(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (bytes32) {
        bytes32 dividend = Fixed224x32.from(_col.toBase());
        bytes32 divisor = Fixed224x32.from(_debt);

        return dividend.div(divisor);
    }

    /**
        @notice Returns the amount of collateral that has to be sold
            in order to make the ratio reach `balanceRatio` for a given debt

        @dev Assumes that the collateral can be sold at the rate provided by the oracle,
            the result is an estimation

        @param _col Collateral entry in memory
        @param _debt Current total debt in `base`

        @return The amount required to be bought and an estimation of the expected
            used collateral
    */
    function balance(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (uint256 _sell, uint256 _buy) {
        // Read oracle
        OracleUtils.Sample memory sample = _col.oracle.readStatic();

        // Create fixed point variables
        bytes32 liquidationRatio = Fixed224x32.raw(_col.liquidationRatio);
        uint256 base = sample.toTokens(_col.amount);
        bytes32 baseRaw = Fixed224x32.from(base);
        bytes32 debt = Fixed224x32.from(_debt);

        // Calculate target limit to reach
        bytes32 limit = debt.mul(liquidationRatio);

        // If current collateral is above limit
        // balance is not needed
        if (limit.lt(baseRaw)) {
            return (0, 0);
        }

        // Load balance ratio to fixed point
        bytes32 balanceRatio = Fixed224x32.raw(_col.balanceRatio);

        // Calculate diff between current collateral and the limit needed
        bytes32 diff = debt.mul(balanceRatio).sub(baseRaw);
        _buy = diff.div(balanceRatio.sub(Fixed224x32.from(1))).toUint256();

        // Estimate how much collateral has to be sold to obtain
        // the required amount to buy
        _sell = sample.toBase(_buy);

        // If the amount to be sold is above the total collateral of the entry
        // the entry is under-collateralized and all the collateral must be sold
        if (_sell > _col.amount) {
            return (_col.amount, base);
        }

        return (_sell, _buy);
    }

    /**
        @dev Calculates how much collateral can be withdawn before
            reaching the liquidation ratio.

        @param _col Collateral entry in memory
        @param _debt Current total debt in `base`

        @return The amount of collateral that can be withdawn without
            reaching the liquidation ratio (in `tokens`)
    */
    function canWithdraw(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (uint256) {
        if (_debt == 0) {
            return _col.amount;
        }
        OracleUtils.Sample memory sample = _col.oracle.readStatic();

        // Load values and turn it into fixed point
        bytes32 base = Fixed224x32.from(sample.toTokens(_col.amount));
        bytes32 liquidationRatio = Fixed224x32.raw(_col.liquidationRatio);

        // Calculate _debt collateral liquidation limit
        bytes32 limit = Fixed224x32.from(_debt).mul(liquidationRatio);

        // If base is below limit, we can't withdraw collateral
        // (we need to liquidate collateral)
        if (base.lte(limit)) {
            return 0;
        }

        // Return remaining to reach liquidation
        return sample.toBase(base.sub(limit.ceil()).toUint256());
    }

    /**
        @dev Defines if a collateral entry got under the liquidation threshold.

        @param _col Collateral entry in memory
        @param _debt Current total debt in `base`

        @return `true` if the collateral entry has to be liquidated.
    */
    function inLiquidation(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (bool) {
        // If debt is zero the collateral can't be
        // in liquidation
        if (_debt == 0) {
            return false;
        }

        // Compare the liquidation ratio with the real collateral/debt ratio
        return _col.ratio(_debt).lt(Fixed224x32.raw(_col.liquidationRatio));
    }
}

// File: contracts/core/diaspore/cosigner/Collateral.sol

pragma solidity ^0.5.11;




















/**
    @title Loan collateral handler
    @author Victor Fage <victor.fage@ripiocredit.network> & Agustin Aguilar <agustin@ripiocredit.network>
    @notice Handles the creation, activation and liquidation trigger
        of collateral guarantees for RCN loans.
*/
contract Collateral is ReentrancyGuard, Ownable, Cosigner, ERC721Base, CollateralAuctionCallback, IDebtStatus {
    using CollateralLib for CollateralLib.Entry;
    using OracleUtils for OracleUtils.Sample;
    using OracleUtils for RateOracle;
    using DiasporeUtils for LoanManager;
    using Fixed224x32 for bytes32;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint32;

    event Created(
        uint256 indexed _entryId,
        bytes32 indexed _debtId,
        RateOracle _oracle,
        IERC20 _token,
        uint256 _amount,
        uint96 _liquidationRatio,
        uint96 _balanceRatio
    );

    event Deposited(
        uint256 indexed _entryId,
        uint256 _amount
    );

    event Withdraw(
        uint256 indexed _entryId,
        address _to,
        uint256 _amount
    );

    event Started(
        uint256 indexed _entryId
    );

    event ClaimedLiquidation(
        uint256 indexed _entryId,
        uint256 indexed _auctionId,
        uint256 _marketValue,
        uint256 _debt,
        uint256 _required
    );

    event ClaimedExpired(
        uint256 indexed _entryId,
        uint256 indexed _auctionId,
        uint256 _marketValue,
        uint256 _obligation,
        uint256 _obligationTokens,
        uint256 _dueTime
    );

    event ClosedAuction(
        uint256 indexed _entryId,
        uint256 _received,
        uint256 _leftover
    );

    event Redeemed(
        uint256 indexed _entryId,
        address _to
    );

    event BorrowCollateral(
        uint256 indexed _entryId,
        CollateralHandler _handler,
        uint256 _newAmount
    );

    event SetUrl(
        string _url
    );

    // All collateral entries
    CollateralLib.Entry[] public entries;

    // Maps a RCN Debt to a collateral entry
    // only after the collateral is cosigned
    mapping(bytes32 => uint256) public debtToEntry;

    // URL With collateral offers
    string private iurl;

    // Fixed for all collaterals, defined
    // during the contract creation
    LoanManager public loanManager;
    IERC20 public loanManagerToken;

    // Liquidation auctions
    CollateralAuction public auction;
    mapping(uint256 => uint256) public entryToAuction;
    mapping(uint256 => uint256) public auctionToEntry;

    /**
        @notice Assign:
            The loan manager contract
            The loan manager token contract
            The auction contract
            The name of ERC721 standard
            The symbol of ERC721 standard

        @dev Add empty entry, to validate the on index 0
    */
    constructor(
        LoanManager _loanManager,
        CollateralAuction _auction
    ) public ERC721Base("RCN Collateral Cosigner", "RCC") {
        loanManager = _loanManager;
        loanManagerToken = loanManager.token();
        // Invalid entry of index 0
        entries.length ++;
        // Create auction contract
        auction = _auction;
    }

    /**
        @notice Returns the total number of created collaterals

        @dev Includes inactive, empty and finalized entries
            and the entry zero, which is considered `invalid`

        @return The number of collateral entries
    */
    function getEntriesLength() external view returns (uint256) {
        return entries.length;
    }

    /**
        @notice Creates a collateral entry, pulls the amount of collateral
            from the function caller and mints an ERC721 that represents the collateral.

        @dev The `token` of the collateral is defined by the provided `oracle`
            `liquidationRatio` and `balanceRatio` should be encoded as Fixed64x32 numbers (e.g.: 1 == 2 ** 32)

        @param _owner The owner of the entry(ERC721 token)
        @param _debtId Id of the RCN debt
        @param _oracle The oracle that provides the rate between `loanManagerToken` and entry `token`
            If the oracle its the address 0 the entry token it's `loanManagerToken`
            otherwise the token it's provided by `oracle.token()`
        @param _amount The amount provided as collateral, in `token`
        @param _liquidationRatio collateral/debt ratio that triggers the execution of the margin call, encoded as Fixed64x32
        @param _balanceRatio Target collateral/debt ratio expected after a margin call execution, encoded as Fixed64x32

        @return The id of the new collateral entry and ERC721 token
    */
    function create(
        address _owner,
        bytes32 _debtId,
        RateOracle _oracle,
        uint256 _amount,
        uint96 _liquidationRatio,
        uint96 _balanceRatio
    ) external nonReentrant() returns (uint256 entryId) {
        require(_owner != address(0x0), "collateral: _owner should not be address 0");
        // Check status of loan, should be open
        require(loanManager.getStatus(_debtId) == Status.NULL, "collateral: loan request should be open");

        // Use the token provided by the oracle
        // if no oracle is provided, the token is assumed to be `loanManagerToken`
        IERC20 token = _oracle == RateOracle(0) ? loanManagerToken : IERC20(_oracle.token());

        // Create the entry, and push on entries array
        entryId = entries.push(
            CollateralLib.create(
                _oracle,
                token,
                _debtId,
                _amount,
                _liquidationRatio,
                _balanceRatio
            )
        ) - 1;

        // Pull the ERC20 tokens
        require(token.safeTransferFrom(_owner, address(this), _amount), "collateral: error pulling tokens from owner");

        // Generate the ERC721 Token
        _generate(entryId, _owner);

        // Emit the collateral creation event
        emit Created(
            entryId,
            _debtId,
            _oracle,
            token,
            _amount,
            _liquidationRatio,
            _balanceRatio
        );
    }

    /**
        @notice Deposits collateral into an entry

        @dev Deposits are disabled if the entry is being auctioned,
            any address can deposit collateral on any entry

        @param _entryId The ID of the collateral entry
        @param _amount The amount to be deposited
    */
    function deposit(
        uint256 _entryId,
        uint256 _amount
    ) external nonReentrant() {
        require(_amount != 0, "collateral: The amount of deposit should not be 0");

        // Deposits disabled during collateral auctions
        require(!inAuction(_entryId), "collateral: can't deposit during auction");

        // Load entry from storage
        CollateralLib.Entry storage entry = entries[_entryId];

        // Pull the ERC20 tokens
        require(entry.token.safeTransferFrom(msg.sender, address(this), _amount), "collateral: error pulling tokens");

        // Register the deposit of amount on the entry
        entry.amount = entry.amount.add(_amount);

        // Emit the deposit event
        emit Deposited(_entryId, _amount);
    }

    /**
        @notice Withdraw collateral from an entry,
            the withdrawal amount is determined by the `liquidationRatio` and the current debt,
            if the collateral is not attached to a debt, all the collateral can be withdrawn

        @dev Withdrawals are disabled if the entry is being auctioned

        @param _entryId The ID of the collateral entry
        @param _to The beneficiary of the withdrawn tokens
        @param _amount The amount to be withdrawn
        @param _oracleData Arbitrary data field requested by the
            collateral entry oracle, may be required to retrieve the rate
    */
    function withdraw(
        uint256 _entryId,
        address _to,
        uint256 _amount,
        bytes calldata _oracleData
    ) external nonReentrant() onlyAuthorized(_entryId) {
        require(_amount != 0, "collateral: The amount of withdraw not be 0");

        // Withdrawals are disabled during collateral auctions
        require(!inAuction(_entryId), "collateral: can't withdraw during auction");

        // Read entry from storage
        CollateralLib.Entry storage entry = entries[_entryId];
        bytes32 debtId = entry.debtId;
        uint256 entryAmount = entry.amount;

        // Check if the entry was cosigned
        if (debtToEntry[debtId] != 0) {
            // Check if the requested amount can be withdrew
            require(
                _amount <= entry.canWithdraw(_debtInTokens(debtId, _oracleData)),
                "collateral: withdrawable collateral is not enough"
            );
        }

        // Reduce the amount of collateral of the entry
        require(entryAmount >= _amount, "collateral: withdrawable collateral is not enough");
        entry.amount = entryAmount.sub(_amount);

        // Send the amount of ERC20 tokens to `_to`
        require(entry.token.safeTransfer(_to, _amount), "collateral: error sending tokens");

        // Emit the withdrawal event
        emit Withdraw(_entryId, _to, _amount);
    }

    /**
        @notice Takes the collateral funds of an entry, can only be called
            if the loan status is `ERROR (4)`, intended to be a recovery mechanism
            if the loan model fails

        @param _entryId The ID of the collateral entry
        @param _to The receiver of the tokens
    */
    function redeem(
        uint256 _entryId,
        address _to
    ) external nonReentrant() onlyOwner {
        // Read entry from storage
        CollateralLib.Entry storage entry = entries[_entryId];

        // Check status, should be `ERROR` (4)
        require(loanManager.getStatus(entry.debtId) == Status.ERROR, "collateral: the debt should be in status error");
        emit Redeemed(_entryId, _to);

        // Load amount and token
        uint256 amount = entry.amount;
        IERC20 token = entry.token;

        // Clear entry and debtToEntry storage
        delete debtToEntry[entry.debtId];
        delete entries[_entryId];

        // Send the amount of ERC20 tokens to `_to`
        require(token.safeTransfer(_to, amount), "collateral: error sending tokens");
    }

    /**
        @notice Borrows collateral, with the condition of increasing
            the collateral/debt ratio before the end of the call

        @dev Intended to be used to pay the loan using the collateral

        @param _entryId Id of the collateral entry
        @param _handler Contract handler of the collateral
        @param _data Arbitrary bytes array for the handler
        @param _oracleData Arbitrary data field requested by the
            collateral entry oracle, may be required to retrieve the rate
    */
    function borrowCollateral(
        uint256 _entryId,
        CollateralHandler _handler,
        bytes calldata _data,
        bytes calldata _oracleData
    ) external nonReentrant() onlyAuthorized(_entryId) {
        // Read entry
        CollateralLib.Entry storage entry = entries[_entryId];
        bytes32 debtId = entry.debtId;

        // Get original collateral/debt ratio
        bytes32 ogRatio = entry.ratio(_debtInTokens(debtId, _oracleData));

        // Send all colleteral to handler
        uint256 lent = entry.amount;
        entry.amount = 0;
        require(entry.token.safeTransfer(address(_handler), lent), "collateral: error sending tokens");

        // Callback to the handler
        uint256 surplus = _handler.handle(_entryId, lent, _data);

        // Expect to pull back any exceeding collateral
        require(entry.token.safeTransferFrom(address(_handler), address(this), surplus), "collateral: error pulling tokens");
        entry.amount = surplus;

        // Read collateral/debt ratio, should be better than previus one
        // or the loan has to be fully paid
        if (loanManager.getStatus(entry.debtId) != Status.PAID) {
            bytes32 afRatio = entry.ratio(_debtInTokens(debtId, _oracleData));
            require(afRatio.gt(ogRatio), "collateral: ratio should increase");
        }

        // Emit borrow colateral event
        emit BorrowCollateral(_entryId, _handler, surplus);
    }

    /**
        @notice Closes and finishes a liquidation auction, the bought tokens used to
            pay the maximun amount of debt possible, any exceeding amount is sent to the
            collateral owner. Exceeding collateral is deposited back on the entry

        @dev This method is an internal callback and it only accepts calls from
            the auction contract

        @param _id Id of the auction
        @param _leftover Exceeding collateral to be deposited on the entry
        @param _received Bought tokens to be used in the payment of the debt
        @param _data Arbitrary data for the *loan* oracle, that may be required
            to perform the payment (the loan oracle may differ from the collateral oracle)
    */
    function auctionClosed(
        uint256 _id,
        uint256 _leftover,
        uint256 _received,
        bytes calldata _data
    ) external nonReentrant() {
        // This method is an internal callback and should only
        // be called by the auction contract
        require(msg.sender == address(auction), "collateral: caller should be the auctioner");

        // Load the collateral ID associated with the auction ID
        uint256 entryId = auctionToEntry[_id];

        // A collateral associated with this ID should exists
        require(entryId != 0, "collateral: entry does not exists");

        // Read the collateral entry from storage
        CollateralLib.Entry storage entry = entries[entryId];

        // Delete auction entry
        delete entryToAuction[entryId];
        delete auctionToEntry[_id];

        // Use received to pay loan
        // `_data` should contain the `oracleData` for the loan
        (, uint256 paidTokens) = loanManager.safePayToken(
            entry.debtId,
            _received,
            address(this),
            _data
        );

        // If we have exceeding tokens
        // send them to the owner of the collateral
        if (paidTokens < _received) {
            require(
                loanManagerToken.safeTransfer(
                    _ownerOf(entryId),
                    _received - paidTokens
                ),
                "collateral: error sending tokens"
            );
        }

        // Return leftover collateral to the collateral entry
        entry.amount = _leftover;

        // Emit closed auction event
        emit ClosedAuction(
            entryId,
            _received,
            _leftover
        );
    }

    // ///
    // Cosigner methods
    // ///

    /**
        @notice Sets the url that provides metadata
            about the collateral entries

        @param _url New url
    */
    function setUrl(string calldata _url) external nonReentrant() onlyOwner {
        iurl = _url;
        emit SetUrl(_url);
    }

    /**
        @notice Returns the cost of the cosigner

        @dev This cosigner does not have any risk or maintenance cost, so its free

        @return 0, because it's free
    */
    function cost(
        address,
        uint256,
        bytes calldata,
        bytes calldata
    ) external view returns (uint256) {
        return 0;
    }

    /**
        @notice Returns an URL that points to metadata
            about the collateral entries

        @return An URL string
    */
    function url() external view returns (string memory) {
        return iurl;
    }

    /**
        @notice Request the consignment of a debt, this process finishes
            the attachment of the collateral to the debt

        @dev The collateral/debt ratio must not be below the liquidation ratio,
            this is intended to avoid front-running and removing the collateral

        @param _debtId Id of the debt
        @param _data Bytes array, must contain the collateral ID on the first 32 bytes
        @param _oracleData Arbitrary data for the *loan* oracle, that may be required
            to perform the payment (the loan oracle may differ from the collateral oracle)

        @return `true` If the consignment was successful
    */
    function requestCosign(
        address,
        uint256 _debtId,
        bytes calldata _data,
        bytes calldata _oracleData
    ) external nonReentrant() returns (bool) {
        bytes32 debtId = bytes32(_debtId);

        // Validate debtId, can't be zero
        require(_debtId != 0, "collateral: invalid debtId");

        LoanManager _loanManager = loanManager;
        // Only the loanManager can request consignments
        require(address(_loanManager) == msg.sender, "collateral: only the loanManager can request cosign");

        // Load entryId from provided `_data`
        uint256 entryId = abi.decode(_data, (uint256));

        // Validate that the `entryId` corresponds to the `debtId`
        CollateralLib.Entry storage entry = entries[entryId];
        require(entry.debtId == debtId, "collateral: incorrect debtId or the entry does not exists");

        // Validate that the loan is collateralized
        require(
            !entry.inLiquidation(_debtInTokens(debtId, _oracleData)),
            "collateral: entry not collateralized"
        );

        // Save entryId, attach the entry to the debt
        debtToEntry[debtId] = entryId;

        // Callback loanManager and cosign
        require(_loanManager.cosign(_debtId, 0), "collateral: error during cosign");

        // Emit the `Started` event
        emit Started(entryId);

        // Returning `true` signals the `loanManager`
        // that the consignment was accepted
        return true;
    }

    /**
        @notice Trigger the liquidation of collateral because of overdue payment or
            under-collateralized position, the liquidation is not instantaneous and happens through an auction process

        @dev There are two liquidation triggering conditions:
            Payment of the debt has expired, the liquidation is triggered to pay the total amount
                of overdue debt
            The `collateral / debt` ratio is below the `liquidationRatio`, the liquidation is
                triggered to balance the ratio up to `balanceRatio`

        @param _debtId Id of the debt
        @param _oracleData Arbitrary data for the *loan* oracle, that may be required
            to perform the payment (the loan oracle may differ from the collateral oracle)

        @return true If a liquidation was triggered
    */
    function claim(
        address,
        uint256 _debtId,
        bytes calldata _oracleData
    ) external nonReentrant() returns (bool) {
        bytes32 debtId = bytes32(_debtId);
        uint256 entryId = debtToEntry[debtId];
        require(entryId != 0, "collateral: collateral not found for debtId");

        return _claimLiquidation(entryId, debtId, _oracleData) ||
            _claimExpired(entryId, debtId, _oracleData);
    }

    function canClaim(uint256 _debtId, bytes calldata _oracleData) external view returns (bool) {
        bytes32 debtId = bytes32(_debtId);
        uint256 entryId = debtToEntry[debtId];
        require(entryId != 0, "collateral: collateral not found for debtId");

        if (inAuction(entryId))
            return false;

        CollateralLib.Entry memory entry = entries[entryId];

        LoanManager _loanManager = loanManager;
        uint256 debt = _loanManager.getClosingObligation(debtId);

        if (debt != 0)
            debt = _loanManager
                .oracle(debtId)
                .readStatic(_oracleData)
                .toTokens(debt);

        return entry.inLiquidation(debt) || now > Model(loanManager.getModel(debtId)).getDueTime(debtId);
    }

    /**
        @notice Checks if a collateral entry is in the process of being auctioned

        @param _entryId Id of the collateral entry

        @return `true` if the collateral entry is being auctioned
    */
    function inAuction(uint256 _entryId) public view returns (bool) {
        return entryToAuction[_entryId] != 0;
    }

    /**
        @notice Validates if a collateral entry is under-collateralized and triggers a liquidation
            if that's the case. The liquidation tries to sell enough collateral to pay the debt
            and make the collateral/debt ratio reach `balanceRatio`

        @param _entryId Id of the collateral entry
        @param _debtId Id of the debt
        @param _oracleData Arbitrary data field requested by the
            collateral entry oracle, may be required to retrieve the rate

        @return `true` if a liquidation was triggered
    */
    function _claimLiquidation(
        uint256 _entryId,
        bytes32 _debtId,
        bytes memory _oracleData
    ) internal returns (bool) {
        // Read entry from storage
        CollateralLib.Entry memory entry = entries[_entryId];

        // Check if collateral needs liquidation
        uint256 debt = _debtInTokens(_debtId, _oracleData);
        if (entry.inLiquidation(debt)) {
            // Calculate how much collateral has to be sold
            // to balance the collateral/debt ratio
            (uint256 marketValue, uint256 required) = entry.balance(debt);

            // Trigger an auction
            uint256 auctionId = _triggerAuction(
                _entryId,
                required,
                marketValue
            );

            emit ClaimedLiquidation(
                _entryId,
                auctionId,
                marketValue,
                debt,
                required
            );

            return true;
        }
    }

    /**
        @notice Validates if the debt attached to a collateral has overdue payments, and
            triggers a liquidation to pay the arrear debt, an extra 5% is requested to
            account for accrued interest during the auction

        @param _entryId Id of the collateral entry
        @param _debtId Id of the debt
        @param _oracleData Arbitrary data field requested by the
            collateral entry oracle, may be required to retrieve the rate

        @return `true` if a liquidation was triggered
    */
    function _claimExpired(
        uint256 _entryId,
        bytes32 _debtId,
        bytes memory _oracleData
    ) internal returns (bool) {
        // Check if debt is expired
        Model model = Model(loanManager.getModel(_debtId));
        uint256 dueTime = model.getDueTime(_debtId);
        uint256 _now = block.timestamp;

        if (_now > dueTime) {
            // Determine the arrear debt to pay
            (uint256 obligation,) = model.getObligation(_debtId, uint64(_now));

            // Add 5% extra to account for accrued interest during the auction
            obligation = obligation.mult(105).div(100);

            // Valuate the debt amount in loanManagerToken
            uint256 obligationTokens = _toToken(_debtId, obligation, _oracleData);

            // Determine how much collateral should be sold at the
            // current market value to cover the `obligationTokens`
            uint256 marketValue = entries[_entryId].oracle.read().toBase(obligationTokens);

            // Trigger an auction
            uint256 auctionId = _triggerAuction(
                _entryId,
                obligationTokens,
                marketValue
            );

            emit ClaimedExpired(
                _entryId,
                auctionId,
                marketValue,
                obligation,
                obligationTokens,
                dueTime
            );

            return true;
        }
    }

    /**
        @notice Calculates the value of an amount in the debt currency in
            `loanManagerToken`, using the rate provided by the oracle of the debt

        @param _debtId Id of the debt
        @param _amount Amount to valuate provided in the currency of the loan
        @param _data Arbitrary data field requested by the
            collateral entry oracle, may be required to retrieve the rate

        @return Value of `_amount` in `loanManagerToken`
    */
    function _toToken(
        bytes32 _debtId,
        uint256 _amount,
        bytes memory _data
    ) internal returns (uint256) {
        if (_amount == 0)
            return 0;

        return loanManager
            .oracle(_debtId)
            .read(_data)
            .toTokens(_amount, true);
    }

    /**
        @notice Calculates how much `loanManagerToken` has to be paid in order
            to fully pay the total amount of the debt, at the current timestamp

        @param debtId Id of the debt
        @param _data Arbitrary data field requested by the
            collateral entry oracle, may be required to retrieve the rate

        @return The total amount required to be paid, in `loanManagerToken` tokens
    */
    function _debtInTokens(
        bytes32 debtId,
        bytes memory _data
    ) internal returns (uint256 debtInTokens) {
        LoanManager _loanManager = loanManager;
        debtInTokens = _loanManager.getClosingObligation(debtId);

        if (debtInTokens != 0)
            debtInTokens = _loanManager
                .oracle(debtId)
                .read(_data)
                .toTokens(debtInTokens);
    }

    /**
        @notice Triggers a collateral auction with the objetive of buying a requested
            `_targetAmount` and using it to pay the debt

        @dev Only one auction per collateral entry can exist at the same time

        @param _entryId Id of the collateral entry
        @param _targetAmount Requested amount on `loanManagerToken`
        @param _marketValue Current value of the `_targetAmount` on collateral tokens,
            provided by the oracle of the entry. The auction reaches this rate after 10 minutes

        @return The ID of the created auction
    */
    function _triggerAuction(
        uint256 _entryId,
        uint256 _targetAmount,
        uint256 _marketValue
    ) internal returns (uint256 _auctionId) {
        // TODO: Maybe we can update the auction keeping the price?
        require(!inAuction(_entryId), "collateral: auction already exists");

        CollateralLib.Entry storage entry = entries[_entryId];

        // The initial offer is 5% below the current market offer
        // provided by the oracle, the market offer should be reached after 10 minutes
        uint256 initialOffer = _marketValue.mult(95).div(100);

        // Read storage
        CollateralAuction _auction = auction;
        uint256 _amount = entry.amount;
        IERC20 _token = entry.token;

        // Set the entry balance to zero
        delete entry.amount;

        // Approve auction contract
        require(_token.safeApprove(address(_auction), _amount), "collateral: error approving auctioneer");

        // Start auction
        _auctionId = _auction.create(
            _token,          // Token we are selling
            initialOffer,    // Initial offer of tokens
            _marketValue,    // Market reference offer provided by the Oracle
            _amount,         // The maximun amount of token that we can sell
            _targetAmount    // How much base tokens are needed
        );

        // Clear approve
        require(_token.clearApprove(address(_auction)), "collateral: error clearing approve");

        // Save Auction ID
        entryToAuction[_entryId] = _auctionId;
        auctionToEntry[_auctionId] = _entryId;
    }
}