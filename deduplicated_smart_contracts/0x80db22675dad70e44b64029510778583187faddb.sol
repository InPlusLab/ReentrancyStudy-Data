/**
 *Submitted for verification at Etherscan.io on 2019-09-03
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
contract Model is IERC165 {
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
    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

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
    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

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

    uint256 public constant STATUS_ONGOING = 1;
    uint256 public constant STATUS_PAID = 2;
    uint256 public constant STATUS_ERROR = 4;

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
    function getStatus(bytes32 id) external view returns (uint256 status);

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








contract DebtEngine is ERC721Base, Ownable {
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

    function getStatus(bytes32 _id) external view returns (uint256) {
        Debt storage debt = debts[_id];
        if (debt.error) {
            return 4;
        } else {
            (bool success, uint256 result) = _safeGasStaticCall(
                address(debt.model),
                abi.encodeWithSelector(
                    debt.model.getStatus.selector,
                    _id
                )
            );
            return success ? result : 4;
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