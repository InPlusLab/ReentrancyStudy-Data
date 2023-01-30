pragma solidity ^0.4.18;

/**
 * @title General MultiEventsHistory user.
 *
 */
contract MultiEventsHistoryAdapter {

    /**
    *   @dev It is address of MultiEventsHistory caller assuming we are inside of delegate call.
    */
    function _self() constant internal returns (address) {
        return msg.sender;
    }
}

/// @title Fund Tokens Platform Emitter.
///
/// Contains all the original event emitting function definitions and events.
/// In case of new events needed later, additional emitters can be developed.
/// All the functions is meant to be called using delegatecall.
contract Emitter is MultiEventsHistoryAdapter {

    event Transfer(address indexed from, address indexed to, bytes32 indexed symbol, uint value, string reference);
    event Issue(bytes32 indexed symbol, uint value, address indexed by);
    event Revoke(bytes32 indexed symbol, uint value, address indexed by);
    event OwnershipChange(address indexed from, address indexed to, bytes32 indexed symbol);
    event Approve(address indexed from, address indexed spender, bytes32 indexed symbol, uint value);
    event Recovery(address indexed from, address indexed to, address by);
    event Error(uint errorCode);

    function emitTransfer(address _from, address _to, bytes32 _symbol, uint _value, string _reference) public {
        Transfer(_from, _to, _symbol, _value, _reference);
    }

    function emitIssue(bytes32 _symbol, uint _value, address _by) public {
        Issue(_symbol, _value, _by);
    }

    function emitRevoke(bytes32 _symbol, uint _value, address _by) public {
        Revoke(_symbol, _value, _by);
    }

    function emitOwnershipChange(address _from, address _to, bytes32 _symbol) public {
        OwnershipChange(_from, _to, _symbol);
    }

    function emitApprove(address _from, address _spender, bytes32 _symbol, uint _value) public {
        Approve(_from, _spender, _symbol, _value);
    }

    function emitRecovery(address _from, address _to, address _by) public {
        Recovery(_from, _to, _by);
    }

    function emitError(uint _errorCode) public {
        Error(_errorCode);
    }
}

/**
 * @title Owned contract with safe ownership pass.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn't happen yet.
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public contractOwner;

    /**
     * Contract owner address
     */
    address public pendingContractOwner;

    function Owned() {
        contractOwner = msg.sender;
    }

    /**
    * @dev Owner check modifier
    */
    modifier onlyContractOwner() {
        if (contractOwner == msg.sender) {
            _;
        }
    }

    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can call it
     */
    function destroy() onlyContractOwner {
        suicide(msg.sender);
    }

    /**
     * Prepares ownership pass.
     *
     * Can only be called by current owner.
     *
     * @param _to address of the next owner. 0x0 is not allowed.
     *
     * @return success.
     */
    function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
        if (_to  == 0x0) {
            return false;
        }

        pendingContractOwner = _to;
        return true;
    }

    /**
     * Finalize ownership pass.
     *
     * Can only be called by pending owner.
     *
     * @return success.
     */
    function claimContractOwnership() returns(bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }

        contractOwner = pendingContractOwner;
        delete pendingContractOwner;

        return true;
    }
}

contract ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);
    string public symbol;

    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}


/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned {
    /**
    *  Common result code. Means everything is fine.
    */
    uint constant OK = 1;
    uint constant OWNED_ACCESS_DENIED_ONLY_CONTRACT_OWNER = 8;

    function withdrawnTokens(address[] tokens, address _to) onlyContractOwner returns(uint) {
        for(uint i=0;i<tokens.length;i++) {
            address token = tokens[i];
            uint balance = ERC20Interface(token).balanceOf(this);
            if(balance != 0)
                ERC20Interface(token).transfer(_to,balance);
        }
        return OK;
    }

    function checkOnlyContractOwner() internal constant returns(uint) {
        if (contractOwner == msg.sender) {
            return OK;
        }

        return OWNED_ACCESS_DENIED_ONLY_CONTRACT_OWNER;
    }
}

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract ProxyEventsEmitter {
    function emitTransfer(address _from, address _to, uint _value) public;
    function emitApprove(address _from, address _spender, uint _value) public;
}


/// @title Fund Tokens Platform.
///
/// Platform uses MultiEventsHistory contract to keep events, so that in case it needs to be redeployed
/// at some point, all the events keep appearing at the same place.
///
/// Every asset is meant to be used through a proxy contract. Only one proxy contract have access
/// rights for a particular asset.
///
/// Features: transfers, allowances, supply adjustments, lost wallet access recovery.
///
/// Note: all the non constant functions return false instead of throwing in case if state change
/// didn't happen yet.
/// BMCPlatformInterface compatibility
contract ATxPlatform is Object, Emitter {

    uint constant ATX_PLATFORM_SCOPE = 80000;
    uint constant ATX_PLATFORM_PROXY_ALREADY_EXISTS = ATX_PLATFORM_SCOPE + 1;
    uint constant ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF = ATX_PLATFORM_SCOPE + 2;
    uint constant ATX_PLATFORM_INVALID_VALUE = ATX_PLATFORM_SCOPE + 3;
    uint constant ATX_PLATFORM_INSUFFICIENT_BALANCE = ATX_PLATFORM_SCOPE + 4;
    uint constant ATX_PLATFORM_NOT_ENOUGH_ALLOWANCE = ATX_PLATFORM_SCOPE + 5;
    uint constant ATX_PLATFORM_ASSET_ALREADY_ISSUED = ATX_PLATFORM_SCOPE + 6;
    uint constant ATX_PLATFORM_CANNOT_ISSUE_FIXED_ASSET_WITH_INVALID_VALUE = ATX_PLATFORM_SCOPE + 7;
    uint constant ATX_PLATFORM_CANNOT_REISSUE_FIXED_ASSET = ATX_PLATFORM_SCOPE + 8;
    uint constant ATX_PLATFORM_SUPPLY_OVERFLOW = ATX_PLATFORM_SCOPE + 9;
    uint constant ATX_PLATFORM_NOT_ENOUGH_TOKENS = ATX_PLATFORM_SCOPE + 10;
    uint constant ATX_PLATFORM_INVALID_NEW_OWNER = ATX_PLATFORM_SCOPE + 11;
    uint constant ATX_PLATFORM_ALREADY_TRUSTED = ATX_PLATFORM_SCOPE + 12;
    uint constant ATX_PLATFORM_SHOULD_RECOVER_TO_NEW_ADDRESS = ATX_PLATFORM_SCOPE + 13;
    uint constant ATX_PLATFORM_ASSET_IS_NOT_ISSUED = ATX_PLATFORM_SCOPE + 14;
    uint constant ATX_PLATFORM_INVALID_INVOCATION = ATX_PLATFORM_SCOPE + 15;

    using SafeMath for uint;

    /// @title Structure of a particular asset.
    struct Asset {
        uint owner;                       // Asset's owner id.
        uint totalSupply;                 // Asset's total supply.
        string name;                      // Asset's name, for information purposes.
        string description;               // Asset's description, for information purposes.
        bool isReissuable;                // Indicates if asset have dynamic or fixed supply.
        uint8 baseUnit;                   // Proposed number of decimals.
        mapping(uint => Wallet) wallets;  // Holders wallets.
        mapping(uint => bool) partowners; // Part-owners of an asset; have less access rights than owner
    }

    /// @title Structure of an asset holder wallet for particular asset.
    struct Wallet {
        uint balance;
        mapping(uint => uint) allowance;
    }

    /// @title Structure of an asset holder.
    struct Holder {
        address addr;                    // Current address of the holder.
        mapping(address => bool) trust;  // Addresses that are trusted with recovery proocedure.
    }

    /// @dev Iterable mapping pattern is used for holders.
    /// @dev This is an access address mapping. Many addresses may have access to a single holder.
    uint public holdersCount;
    mapping(uint => Holder) public holders;
    mapping(address => uint) holderIndex;

    /// @dev List of symbols that exist in a platform
    bytes32[] public symbols;

    /// @dev Asset symbol to asset mapping.
    mapping(bytes32 => Asset) public assets;

    /// @dev Asset symbol to asset proxy mapping.
    mapping(bytes32 => address) public proxies;

    /// @dev Co-owners of a platform. Has less access rights than a root contract owner
    mapping(address => bool) public partowners;

    /// @dev Should use interface of the emitter, but address of events history.
    address public eventsHistory;

    /// @dev Emits Error if called not by asset owner.
    modifier onlyOwner(bytes32 _symbol) {
        if (isOwner(msg.sender, _symbol)) {
            _;
        }
    }

    /// @dev UNAUTHORIZED if called not by one of symbol's partowners or owner
    modifier onlyOneOfOwners(bytes32 _symbol) {
        if (hasAssetRights(msg.sender, _symbol)) {
            _;
        }
    }

    /// @dev UNAUTHORIZED if called not by one of partowners or contract's owner
    modifier onlyOneOfContractOwners() {
        if (contractOwner == msg.sender || partowners[msg.sender]) {
            _;
        }
    }

    /// @dev Emits Error if called not by asset proxy.
    modifier onlyProxy(bytes32 _symbol) {
        if (proxies[_symbol] == msg.sender) {
            _;
        }
    }

    /// @dev Emits Error if _from doesn't trust _to.
    modifier checkTrust(address _from, address _to) {
        if (isTrusted(_from, _to)) {
            _;
        }
    }

    function() payable public {
        revert();
    }

    /// @notice Trust an address to perform recovery procedure for the caller.
    ///
    /// @return success.
    function trust() external returns (uint) {
        uint fromId = _createHolderId(msg.sender);
        // Should trust to another address.
        if (msg.sender == contractOwner) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        // Should trust to yet untrusted.
        if (isTrusted(msg.sender, contractOwner)) {
            return _error(ATX_PLATFORM_ALREADY_TRUSTED);
        }

        holders[fromId].trust[contractOwner] = true;
        return OK;
    }

    /// @notice Revoke trust to perform recovery procedure from an address.
    ///
    /// @return success.
    function distrust() external checkTrust(msg.sender, contractOwner) returns (uint) {
        holders[getHolderId(msg.sender)].trust[contractOwner] = false;
        return OK;
    }

    /// @notice Adds a co-owner of a contract. Might be more than one co-owner
    ///
    /// @dev Allowed to only contract onwer
    ///
    /// @param _partowner a co-owner of a contract
    ///
    /// @return result code of an operation
    function addPartOwner(address _partowner) external onlyContractOwner returns (uint) {
        partowners[_partowner] = true;
        return OK;
    }

    /// @notice emoves a co-owner of a contract
    ///
    /// @dev Should be performed only by root contract owner
    ///
    /// @param _partowner a co-owner of a contract
    ///
    /// @return result code of an operation
    function removePartOwner(address _partowner) external onlyContractOwner returns (uint) {
        delete partowners[_partowner];
        return OK;
    }

    /// @notice Sets EventsHstory contract address.
    ///
    /// @dev Can be set only by owner.
    ///
    /// @param _eventsHistory MultiEventsHistory contract address.
    ///
    /// @return success.
    function setupEventsHistory(address _eventsHistory) external onlyContractOwner returns (uint errorCode) {
        eventsHistory = _eventsHistory;
        return OK;
    }

    /// @notice Adds a co-owner for an asset with provided symbol.
    /// @dev Should be performed by a contract owner or its co-owners
    ///
    /// @param _symbol asset's symbol
    /// @param _partowner a co-owner of an asset
    ///
    /// @return errorCode result code of an operation
    function addAssetPartOwner(bytes32 _symbol, address _partowner) external onlyOneOfOwners(_symbol) returns (uint) {
        uint holderId = _createHolderId(_partowner);
        assets[_symbol].partowners[holderId] = true;
        Emitter(eventsHistory).emitOwnershipChange(0x0, _partowner, _symbol);
        return OK;
    }

    /// @notice Removes a co-owner for an asset with provided symbol.
    /// @dev Should be performed by a contract owner or its co-owners
    ///
    /// @param _symbol asset's symbol
    /// @param _partowner a co-owner of an asset
    ///
    /// @return errorCode result code of an operation
    function removeAssetPartOwner(bytes32 _symbol, address _partowner) external onlyOneOfOwners(_symbol) returns (uint) {
        uint holderId = getHolderId(_partowner);
        delete assets[_symbol].partowners[holderId];
        Emitter(eventsHistory).emitOwnershipChange(_partowner, 0x0, _symbol);
        return OK;
    }

    function massTransfer(address[] addresses, uint[] values, bytes32 _symbol) external onlyOneOfOwners(_symbol) returns (uint errorCode, uint count) {
        require(addresses.length == values.length);
        require(_symbol != 0x0);

        uint senderId = _createHolderId(msg.sender);

        uint success = 0;
        for (uint idx = 0; idx < addresses.length && msg.gas > 110000; ++idx) {
            uint value = values[idx];

            if (value == 0) {
                _error(ATX_PLATFORM_INVALID_VALUE);
                continue;
            }

            if (_balanceOf(senderId, _symbol) < value) {
                _error(ATX_PLATFORM_INSUFFICIENT_BALANCE);
                continue;
            }

            if (msg.sender == addresses[idx]) {
                _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
                continue;
            }

            uint holderId = _createHolderId(addresses[idx]);

            _transferDirect(senderId, holderId, value, _symbol);
            Emitter(eventsHistory).emitTransfer(msg.sender, addresses[idx], _symbol, value, "");

            ++success;
        }

        return (OK, success);
    }

    /// @notice Provides a cheap way to get number of symbols registered in a platform
    ///
    /// @return number of symbols
    function symbolsCount() public view returns (uint) {
        return symbols.length;
    }

    /// @notice Check asset existance.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset existance.
    function isCreated(bytes32 _symbol) public view returns (bool) {
        return assets[_symbol].owner != 0;
    }

    /// @notice Returns asset decimals.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset decimals.
    function baseUnit(bytes32 _symbol) public view returns (uint8) {
        return assets[_symbol].baseUnit;
    }

    /// @notice Returns asset name.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset name.
    function name(bytes32 _symbol) public view returns (string) {
        return assets[_symbol].name;
    }

    /// @notice Returns asset description.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset description.
    function description(bytes32 _symbol) public view returns (string) {
        return assets[_symbol].description;
    }

    /// @notice Returns asset reissuability.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset reissuability.
    function isReissuable(bytes32 _symbol) public view returns (bool) {
        return assets[_symbol].isReissuable;
    }

    /// @notice Returns asset owner address.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset owner address.
    function owner(bytes32 _symbol) public view returns (address) {
        return holders[assets[_symbol].owner].addr;
    }

    /// @notice Check if specified address has asset owner rights.
    ///
    /// @param _owner address to check.
    /// @param _symbol asset symbol.
    ///
    /// @return owner rights availability.
    function isOwner(address _owner, bytes32 _symbol) public view returns (bool) {
        return isCreated(_symbol) && (assets[_symbol].owner == getHolderId(_owner));
    }

    /// @notice Checks if a specified address has asset owner or co-owner rights.
    ///
    /// @param _owner address to check.
    /// @param _symbol asset symbol.
    ///
    /// @return owner rights availability.
    function hasAssetRights(address _owner, bytes32 _symbol) public view returns (bool) {
        uint holderId = getHolderId(_owner);
        return isCreated(_symbol) && (assets[_symbol].owner == holderId || assets[_symbol].partowners[holderId]);
    }

    /// @notice Returns asset total supply.
    ///
    /// @param _symbol asset symbol.
    ///
    /// @return asset total supply.
    function totalSupply(bytes32 _symbol) public view returns (uint) {
        return assets[_symbol].totalSupply;
    }

    /// @notice Returns asset balance for a particular holder.
    ///
    /// @param _holder holder address.
    /// @param _symbol asset symbol.
    ///
    /// @return holder balance.
    function balanceOf(address _holder, bytes32 _symbol) public view returns (uint) {
        return _balanceOf(getHolderId(_holder), _symbol);
    }

    /// @notice Returns asset balance for a particular holder id.
    ///
    /// @param _holderId holder id.
    /// @param _symbol asset symbol.
    ///
    /// @return holder balance.
    function _balanceOf(uint _holderId, bytes32 _symbol) public view returns (uint) {
        return assets[_symbol].wallets[_holderId].balance;
    }

    /// @notice Returns current address for a particular holder id.
    ///
    /// @param _holderId holder id.
    ///
    /// @return holder address.
    function _address(uint _holderId) public view returns (address) {
        return holders[_holderId].addr;
    }

    function checkIsAssetPartOwner(bytes32 _symbol, address _partowner) public view returns (bool) {
        require(_partowner != 0x0);
        uint holderId = getHolderId(_partowner);
        return assets[_symbol].partowners[holderId];
    }

    /// @notice Sets Proxy contract address for a particular asset.
    ///
    /// Can be set only once for each asset, and only by contract owner.
    ///
    /// @param _proxyAddress Proxy contract address.
    /// @param _symbol asset symbol.
    ///
    /// @return success.
    function setProxy(address _proxyAddress, bytes32 _symbol) public onlyOneOfContractOwners returns (uint) {
        if (proxies[_symbol] != 0x0) {
            return ATX_PLATFORM_PROXY_ALREADY_EXISTS;
        }
        proxies[_symbol] = _proxyAddress;
        return OK;
    }

    /// @notice Returns holder id for the specified address.
    ///
    /// @param _holder holder address.
    ///
    /// @return holder id.
    function getHolderId(address _holder) public view returns (uint) {
        return holderIndex[_holder];
    }

    /// @notice Transfers asset balance between holders wallets.
    ///
    /// @dev Can only be called by asset proxy.
    ///
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @param _symbol asset symbol.
    /// @param _reference transfer comment to be included in a Transfer event.
    /// @param _sender transfer initiator address.
    ///
    /// @return success.
    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference, address _sender) onlyProxy(_symbol) public returns (uint) {
        return _transfer(getHolderId(_sender), _createHolderId(_to), _value, _symbol, _reference, getHolderId(_sender));
    }

    /// @notice Issues new asset token on the platform.
    ///
    /// Tokens issued with this call go straight to contract owner.
    /// Each symbol can be issued only once, and only by contract owner.
    ///
    /// @param _symbol asset symbol.
    /// @param _value amount of tokens to issue immediately.
    /// @param _name name of the asset.
    /// @param _description description for the asset.
    /// @param _baseUnit number of decimals.
    /// @param _isReissuable dynamic or fixed supply.
    ///
    /// @return success.
    function issueAsset(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable) public returns (uint) {
        return issueAssetToAddress(_symbol, _value, _name, _description, _baseUnit, _isReissuable, msg.sender);
    }

    /// @notice Issues new asset token on the platform.
    ///
    /// Tokens issued with this call go straight to contract owner.
    /// Each symbol can be issued only once, and only by contract owner.
    ///
    /// @param _symbol asset symbol.
    /// @param _value amount of tokens to issue immediately.
    /// @param _name name of the asset.
    /// @param _description description for the asset.
    /// @param _baseUnit number of decimals.
    /// @param _isReissuable dynamic or fixed supply.
    /// @param _account address where issued balance will be held
    ///
    /// @return success.
    function issueAssetToAddress(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable, address _account) public onlyOneOfContractOwners returns (uint) {
        // Should have positive value if supply is going to be fixed.
        if (_value == 0 && !_isReissuable) {
            return _error(ATX_PLATFORM_CANNOT_ISSUE_FIXED_ASSET_WITH_INVALID_VALUE);
        }
        // Should not be issued yet.
        if (isCreated(_symbol)) {
            return _error(ATX_PLATFORM_ASSET_ALREADY_ISSUED);
        }
        uint holderId = _createHolderId(_account);
        uint creatorId = _account == msg.sender ? holderId : _createHolderId(msg.sender);

        symbols.push(_symbol);
        assets[_symbol] = Asset(creatorId, _value, _name, _description, _isReissuable, _baseUnit);
        assets[_symbol].wallets[holderId].balance = _value;
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: n/a after HF 4;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitIssue(_symbol, _value, _address(holderId));
        return OK;
    }

    /// @notice Issues additional asset tokens if the asset have dynamic supply.
    ///
    /// Tokens issued with this call go straight to asset owner.
    /// Can only be called by asset owner.
    ///
    /// @param _symbol asset symbol.
    /// @param _value amount of additional tokens to issue.
    ///
    /// @return success.
    function reissueAsset(bytes32 _symbol, uint _value) public onlyOneOfOwners(_symbol) returns (uint) {
        // Should have positive value.
        if (_value == 0) {
            return _error(ATX_PLATFORM_INVALID_VALUE);
        }
        Asset storage asset = assets[_symbol];
        // Should have dynamic supply.
        if (!asset.isReissuable) {
            return _error(ATX_PLATFORM_CANNOT_REISSUE_FIXED_ASSET);
        }
        // Resulting total supply should not overflow.
        if (asset.totalSupply + _value < asset.totalSupply) {
            return _error(ATX_PLATFORM_SUPPLY_OVERFLOW);
        }
        uint holderId = getHolderId(msg.sender);
        asset.wallets[holderId].balance = asset.wallets[holderId].balance.add(_value);
        asset.totalSupply = asset.totalSupply.add(_value);
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: n/a after HF 4;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitIssue(_symbol, _value, _address(holderId));

        _proxyTransferEvent(0, holderId, _value, _symbol);

        return OK;
    }

    /// @notice Destroys specified amount of senders asset tokens.
    ///
    /// @param _symbol asset symbol.
    /// @param _value amount of tokens to destroy.
    ///
    /// @return success.
    function revokeAsset(bytes32 _symbol, uint _value) public returns (uint) {
        // Should have positive value.
        if (_value == 0) {
            return _error(ATX_PLATFORM_INVALID_VALUE);
        }
        Asset storage asset = assets[_symbol];
        uint holderId = getHolderId(msg.sender);
        // Should have enough tokens.
        if (asset.wallets[holderId].balance < _value) {
            return _error(ATX_PLATFORM_NOT_ENOUGH_TOKENS);
        }
        asset.wallets[holderId].balance = asset.wallets[holderId].balance.sub(_value);
        asset.totalSupply = asset.totalSupply.sub(_value);
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: n/a after HF 4;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitRevoke(_symbol, _value, _address(holderId));
        _proxyTransferEvent(holderId, 0, _value, _symbol);
        return OK;
    }

    /// @notice Passes asset ownership to specified address.
    ///
    /// Only ownership is changed, balances are not touched.
    /// Can only be called by asset owner.
    ///
    /// @param _symbol asset symbol.
    /// @param _newOwner address to become a new owner.
    ///
    /// @return success.
    function changeOwnership(bytes32 _symbol, address _newOwner) public onlyOwner(_symbol) returns (uint) {
        if (_newOwner == 0x0) {
            return _error(ATX_PLATFORM_INVALID_NEW_OWNER);
        }

        Asset storage asset = assets[_symbol];
        uint newOwnerId = _createHolderId(_newOwner);
        // Should pass ownership to another holder.
        if (asset.owner == newOwnerId) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        address oldOwner = _address(asset.owner);
        asset.owner = newOwnerId;
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: n/a after HF 4;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitOwnershipChange(oldOwner, _newOwner, _symbol);
        return OK;
    }

    /// @notice Check if specified holder trusts an address with recovery procedure.
    ///
    /// @param _from truster.
    /// @param _to trustee.
    ///
    /// @return trust existance.
    function isTrusted(address _from, address _to) public view returns (bool) {
        return holders[getHolderId(_from)].trust[_to];
    }

    /// @notice Perform recovery procedure.
    ///
    /// Can be invoked by contract owner if he is trusted by sender only.
    ///
    /// This function logic is actually more of an addAccess(uint _holderId, address _to).
    /// It grants another address access to recovery subject wallets.
    /// Can only be called by trustee of recovery subject.
    ///
    /// @param _from holder address to recover from.
    /// @param _to address to grant access to.
    ///
    /// @return success.
    function recover(address _from, address _to) checkTrust(_from, msg.sender) public onlyContractOwner returns (uint errorCode) {
        // We take current holder address because it might not equal _from.
        // It is possible to recover from any old holder address, but event should have the current one.
        address from = holders[getHolderId(_from)].addr;
        holders[getHolderId(_from)].addr = _to;
        holderIndex[_to] = getHolderId(_from);
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: revert this transaction too;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitRecovery(from, _to, msg.sender);
        return OK;
    }

    /// @notice Sets asset spending allowance for a specified spender.
    ///
    /// @dev Can only be called by asset proxy.
    ///
    /// @param _spender holder address to set allowance to.
    /// @param _value amount to allow.
    /// @param _symbol asset symbol.
    /// @param _sender approve initiator address.
    ///
    /// @return success.
    function proxyApprove(address _spender, uint _value, bytes32 _symbol, address _sender) public onlyProxy(_symbol) returns (uint) {
        return _approve(_createHolderId(_spender), _value, _symbol, _createHolderId(_sender));
    }

    /// @notice Returns asset allowance from one holder to another.
    ///
    /// @param _from holder that allowed spending.
    /// @param _spender holder that is allowed to spend.
    /// @param _symbol asset symbol.
    ///
    /// @return holder to spender allowance.
    function allowance(address _from, address _spender, bytes32 _symbol) public view returns (uint) {
        return _allowance(getHolderId(_from), getHolderId(_spender), _symbol);
    }

    /// @notice Prforms allowance transfer of asset balance between holders wallets.
    ///
    /// @dev Can only be called by asset proxy.
    ///
    /// @param _from holder address to take from.
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @param _symbol asset symbol.
    /// @param _reference transfer comment to be included in a Transfer event.
    /// @param _sender allowance transfer initiator address.
    ///
    /// @return success.
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference, address _sender) public onlyProxy(_symbol) returns (uint) {
        return _transfer(getHolderId(_from), _createHolderId(_to), _value, _symbol, _reference, getHolderId(_sender));
    }

    /// @notice Transfers asset balance between holders wallets.
    ///
    /// @param _fromId holder id to take from.
    /// @param _toId holder id to give to.
    /// @param _value amount to transfer.
    /// @param _symbol asset symbol.
    function _transferDirect(uint _fromId, uint _toId, uint _value, bytes32 _symbol) internal {
        assets[_symbol].wallets[_fromId].balance = assets[_symbol].wallets[_fromId].balance.sub(_value);
        assets[_symbol].wallets[_toId].balance = assets[_symbol].wallets[_toId].balance.add(_value);
    }

    /// @notice Transfers asset balance between holders wallets.
    ///
    /// @dev Performs sanity checks and takes care of allowances adjustment.
    ///
    /// @param _fromId holder id to take from.
    /// @param _toId holder id to give to.
    /// @param _value amount to transfer.
    /// @param _symbol asset symbol.
    /// @param _reference transfer comment to be included in a Transfer event.
    /// @param _senderId transfer initiator holder id.
    ///
    /// @return success.
    function _transfer(uint _fromId, uint _toId, uint _value, bytes32 _symbol, string _reference, uint _senderId) internal returns (uint) {
        // Should not allow to send to oneself.
        if (_fromId == _toId) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }
        // Should have positive value.
        if (_value == 0) {
            return _error(ATX_PLATFORM_INVALID_VALUE);
        }
        // Should have enough balance.
        if (_balanceOf(_fromId, _symbol) < _value) {
            return _error(ATX_PLATFORM_INSUFFICIENT_BALANCE);
        }
        // Should have enough allowance.
        if (_fromId != _senderId && _allowance(_fromId, _senderId, _symbol) < _value) {
            return _error(ATX_PLATFORM_NOT_ENOUGH_ALLOWANCE);
        }

        _transferDirect(_fromId, _toId, _value, _symbol);
        // Adjust allowance.
        if (_fromId != _senderId) {
            assets[_symbol].wallets[_fromId].allowance[_senderId] = assets[_symbol].wallets[_fromId].allowance[_senderId].sub(_value);
        }
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: n/a after HF 4;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitTransfer(_address(_fromId), _address(_toId), _symbol, _value, _reference);
        _proxyTransferEvent(_fromId, _toId, _value, _symbol);
        return OK;
    }

    /// @notice Ask asset Proxy contract to emit ERC20 compliant Transfer event.
    ///
    /// @param _fromId holder id to take from.
    /// @param _toId holder id to give to.
    /// @param _value amount to transfer.
    /// @param _symbol asset symbol.
    function _proxyTransferEvent(uint _fromId, uint _toId, uint _value, bytes32 _symbol) internal {
        if (proxies[_symbol] != 0x0) {
            // Internal Out Of Gas/Throw: revert this transaction too;
            // Call Stack Depth Limit reached: n/a after HF 4;
            // Recursive Call: safe, all changes already made.
            ProxyEventsEmitter(proxies[_symbol]).emitTransfer(_address(_fromId), _address(_toId), _value);
        }
    }

    /// @notice Returns holder id for the specified address, creates it if needed.
    ///
    /// @param _holder holder address.
    ///
    /// @return holder id.
    function _createHolderId(address _holder) internal returns (uint) {
        uint holderId = holderIndex[_holder];
        if (holderId == 0) {
            holderId = ++holdersCount;
            holders[holderId].addr = _holder;
            holderIndex[_holder] = holderId;
        }
        return holderId;
    }

    /// @notice Sets asset spending allowance for a specified spender.
    ///
    /// Note: to revoke allowance, one needs to set allowance to 0.
    ///
    /// @param _spenderId holder id to set allowance for.
    /// @param _value amount to allow.
    /// @param _symbol asset symbol.
    /// @param _senderId approve initiator holder id.
    ///
    /// @return success.
    function _approve(uint _spenderId, uint _value, bytes32 _symbol, uint _senderId) internal returns (uint) {
        // Asset should exist.
        if (!isCreated(_symbol)) {
            return _error(ATX_PLATFORM_ASSET_IS_NOT_ISSUED);
        }
        // Should allow to another holder.
        if (_senderId == _spenderId) {
            return _error(ATX_PLATFORM_CANNOT_APPLY_TO_ONESELF);
        }

        // Double Spend Attack checkpoint
        if (assets[_symbol].wallets[_senderId].allowance[_spenderId] != 0 && _value != 0) {
            return _error(ATX_PLATFORM_INVALID_INVOCATION);
        }

        assets[_symbol].wallets[_senderId].allowance[_spenderId] = _value;

        // Internal Out Of Gas/Throw: revert this transaction too;
        // Call Stack Depth Limit reached: revert this transaction too;
        // Recursive Call: safe, all changes already made.
        Emitter(eventsHistory).emitApprove(_address(_senderId), _address(_spenderId), _symbol, _value);
        if (proxies[_symbol] != 0x0) {
            // Internal Out Of Gas/Throw: revert this transaction too;
            // Call Stack Depth Limit reached: n/a after HF 4;
            // Recursive Call: safe, all changes already made.
            ProxyEventsEmitter(proxies[_symbol]).emitApprove(_address(_senderId), _address(_spenderId), _value);
        }
        return OK;
    }

    /// @notice Returns asset allowance from one holder to another.
    ///
    /// @param _fromId holder id that allowed spending.
    /// @param _toId holder id that is allowed to spend.
    /// @param _symbol asset symbol.
    ///
    /// @return holder to spender allowance.
    function _allowance(uint _fromId, uint _toId, bytes32 _symbol) internal view returns (uint) {
        return assets[_symbol].wallets[_fromId].allowance[_toId];
    }

    /// @dev Emits Error event with specified error message.
    /// Should only be used if no state changes happened.
    /// @param _errorCode code of an error
    function _error(uint _errorCode) internal returns (uint) {
        Emitter(eventsHistory).emitError(_errorCode);
        return _errorCode;
    }
}