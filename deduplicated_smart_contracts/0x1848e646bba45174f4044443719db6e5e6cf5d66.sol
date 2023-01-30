/**
 *Submitted for verification at Etherscan.io on 2019-12-02
*/

pragma solidity ^0.5.4;

/**
 * ERC20 contract interface.
 */
contract ERC20 {
    function totalSupply() public view returns (uint);
    function decimals() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

/**
 * @title Module
 * @dev Interface for a module. 
 * A module MUST implement the addModule() method to ensure that a wallet with at least one module
 * can never end up in a "frozen" state.
 * @author Julien Niset - <julien@argent.xyz>
 */
interface Module {
    function init(BaseWallet _wallet) external;
    function addModule(BaseWallet _wallet, Module _module) external;
    function recoverToken(address _token) external;
}

/**
 * @title BaseWallet
 * @dev Simple modular wallet that authorises modules to call its invoke() method.
 * Based on https://gist.github.com/Arachnid/a619d31f6d32757a4328a428286da186 by 
 * @author Julien Niset - <julien@argent.xyz>
 */
contract BaseWallet {
    address public implementation;
    address public owner;
    mapping (address => bool) public authorised;
    mapping (bytes4 => address) public enabled;
    uint public modules;
    function init(address _owner, address[] calldata _modules) external;
    function authoriseModule(address _module, bool _value) external;
    function enableStaticCall(address _module, bytes4 _method) external;
    function setOwner(address _newOwner) external;
    function invoke(address _target, uint _value, bytes calldata _data) external;
    function() external payable;
}

/**
 * @title ModuleRegistry
 * @dev Registry of authorised modules. 
 * Modules must be registered before they can be authorised on a wallet.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract ModuleRegistry {
    function registerModule(address _module, bytes32 _name) external;
    function deregisterModule(address _module) external;
    function registerUpgrader(address _upgrader, bytes32 _name) external;
    function deregisterUpgrader(address _upgrader) external;
    function recoverToken(address _token) external;
    function moduleInfo(address _module) external view returns (bytes32);
    function upgraderInfo(address _upgrader) external view returns (bytes32);
    function isRegisteredModule(address _module) external view returns (bool);
    function isRegisteredModule(address[] calldata _modules) external view returns (bool);
    function isRegisteredUpgrader(address _upgrader) external view returns (bool);
}

/**
 * @title GuardianStorage
 * @dev Contract storing the state of wallets related to guardians and lock.
 * The contract only defines basic setters and getters with no logic. Only modules authorised
 * for a wallet can modify its state.
 * @author Julien Niset - <julien@argent.xyz>
 * @author Olivier Van Den Biggelaar - <olivier@argent.xyz>
 */
contract GuardianStorage {
    function addGuardian(BaseWallet _wallet, address _guardian) external;
    function revokeGuardian(BaseWallet _wallet, address _guardian) external;
    function guardianCount(BaseWallet _wallet) external view returns (uint256);
    function getGuardians(BaseWallet _wallet) external view returns (address[] memory);
    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool);
    function setLock(BaseWallet _wallet, uint256 _releaseAfter) external;
    function isLocked(BaseWallet _wallet) external view returns (bool);
    function getLock(BaseWallet _wallet) external view returns (uint256);
    function getLocker(BaseWallet _wallet) external view returns (address);
}

/**
 * @title BaseModule
 * @dev Basic module that contains some methods common to all modules.
 * @author Julien Niset - <julien@argent.im>
 */
contract BaseModule is Module {

    // The adddress of the module registry.
    ModuleRegistry internal registry;

    event ModuleCreated(bytes32 name);
    event ModuleInitialised(address wallet);

    constructor(ModuleRegistry _registry, bytes32 _name) public {
        registry = _registry;
        emit ModuleCreated(_name);
    }

    /**
     * @dev Throws if the sender is not the target wallet of the call.
     */
    modifier onlyWallet(BaseWallet _wallet) {
        require(msg.sender == address(_wallet), "BM: caller must be wallet");
        _;
    }

    /**
     * @dev Throws if the sender is not the owner of the target wallet or the module itself.
     */
    modifier onlyWalletOwner(BaseWallet _wallet) {
        require(msg.sender == address(this) || isOwner(_wallet, msg.sender), "BM: must be an owner for the wallet");
        _;
    }

    /**
     * @dev Throws if the sender is not the owner of the target wallet.
     */
    modifier strictOnlyWalletOwner(BaseWallet _wallet) {
        require(isOwner(_wallet, msg.sender), "BM: msg.sender must be an owner for the wallet");
        _;
    }

    /**
     * @dev Inits the module for a wallet by logging an event.
     * The method can only be called by the wallet itself.
     * @param _wallet The wallet.
     */
    function init(BaseWallet _wallet) external onlyWallet(_wallet) {
        emit ModuleInitialised(address(_wallet));
    }

    /**
     * @dev Adds a module to a wallet. First checks that the module is registered.
     * @param _wallet The target wallet.
     * @param _module The modules to authorise.
     */
    function addModule(BaseWallet _wallet, Module _module) external strictOnlyWalletOwner(_wallet) {
        require(registry.isRegisteredModule(address(_module)), "BM: module is not registered");
        _wallet.authoriseModule(address(_module), true);
    }

    /**
    * @dev Utility method enbaling anyone to recover ERC20 token sent to the
    * module by mistake and transfer them to the Module Registry. 
    * @param _token The token to recover.
    */
    function recoverToken(address _token) external {
        uint total = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(address(registry), total);
    }

    /**
     * @dev Helper method to check if an address is the owner of a target wallet.
     * @param _wallet The target wallet.
     * @param _addr The address.
     */
    function isOwner(BaseWallet _wallet, address _addr) internal view returns (bool) {
        return _wallet.owner() == _addr;
    }
}

/**
 * @title RelayerModule
 * @dev Base module containing logic to execute transactions signed by eth-less accounts and sent by a relayer. 
 * @author Julien Niset - <julien@argent.im>
 */
contract RelayerModule is Module {

    uint256 constant internal BLOCKBOUND = 10000;

    mapping (address => RelayerConfig) public relayer; 

    struct RelayerConfig {
        uint256 nonce;
        mapping (bytes32 => bool) executedTx;
    }

    event TransactionExecuted(address indexed wallet, bool indexed success, bytes32 signedHash);

    /**
     * @dev Throws if the call did not go through the execute() method.
     */
    modifier onlyExecute {
        require(msg.sender == address(this), "RM: must be called via execute()");
        _;
    }

    /* ***************** Abstract method ************************* */

    /**
    * @dev Gets the number of valid signatures that must be provided to execute a
    * specific relayed transaction.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @return The number of required signatures.
    */
    function getRequiredSignatures(BaseWallet _wallet, bytes memory _data) internal view returns (uint256);

    /**
    * @dev Validates the signatures provided with a relayed transaction.
    * The method MUST throw if one or more signatures are not valid.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @param _signHash The signed hash representing the relayed transaction.
    * @param _signatures The signatures as a concatenated byte array.
    */
    function validateSignatures(BaseWallet _wallet, bytes memory _data, bytes32 _signHash, bytes memory _signatures) internal view returns (bool);

    /* ************************************************************ */

    /**
    * @dev Executes a relayed transaction.
    * @param _wallet The target wallet.
    * @param _data The data for the relayed transaction
    * @param _nonce The nonce used to prevent replay attacks.
    * @param _signatures The signatures as a concatenated byte array.
    * @param _gasPrice The gas price to use for the gas refund.
    * @param _gasLimit The gas limit to use for the gas refund.
    */
    function execute(
        BaseWallet _wallet,
        bytes calldata _data, 
        uint256 _nonce, 
        bytes calldata _signatures, 
        uint256 _gasPrice,
        uint256 _gasLimit
    )
        external
        returns (bool success)
    {
        uint startGas = gasleft();
        bytes32 signHash = getSignHash(address(this), address(_wallet), 0, _data, _nonce, _gasPrice, _gasLimit);
        require(checkAndUpdateUniqueness(_wallet, _nonce, signHash), "RM: Duplicate request");
        require(verifyData(address(_wallet), _data), "RM: the wallet authorized is different then the target of the relayed data");
        uint256 requiredSignatures = getRequiredSignatures(_wallet, _data);
        if((requiredSignatures * 65) == _signatures.length) {
            if(verifyRefund(_wallet, _gasLimit, _gasPrice, requiredSignatures)) {
                if(requiredSignatures == 0 || validateSignatures(_wallet, _data, signHash, _signatures)) {
                    // solium-disable-next-line security/no-call-value
                    (success,) = address(this).call(_data);
                    refund(_wallet, startGas - gasleft(), _gasPrice, _gasLimit, requiredSignatures, msg.sender);
                }
            }
        }
        emit TransactionExecuted(address(_wallet), success, signHash); 
    }

    /**
    * @dev Gets the current nonce for a wallet.
    * @param _wallet The target wallet.
    */
    function getNonce(BaseWallet _wallet) external view returns (uint256 nonce) {
        return relayer[address(_wallet)].nonce;
    }

    /**
    * @dev Generates the signed hash of a relayed transaction according to ERC 1077.
    * @param _from The starting address for the relayed transaction (should be the module)
    * @param _to The destination address for the relayed transaction (should be the wallet)
    * @param _value The value for the relayed transaction
    * @param _data The data for the relayed transaction
    * @param _nonce The nonce used to prevent replay attacks.
    * @param _gasPrice The gas price to use for the gas refund.
    * @param _gasLimit The gas limit to use for the gas refund.
    */
    function getSignHash(
        address _from,
        address _to, 
        uint256 _value, 
        bytes memory _data, 
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit
    ) 
        internal 
        pure
        returns (bytes32) 
    {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(byte(0x19), byte(0), _from, _to, _value, _data, _nonce, _gasPrice, _gasLimit))
        ));
    }

    /**
    * @dev Checks if the relayed transaction is unique.
    * @param _wallet The target wallet.
    * @param _nonce The nonce
    * @param _signHash The signed hash of the transaction
    */
    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {
        if(relayer[address(_wallet)].executedTx[_signHash] == true) {
            return false;
        }
        relayer[address(_wallet)].executedTx[_signHash] = true;
        return true;
    }

    /**
    * @dev Checks that a nonce has the correct format and is valid. 
    * It must be constructed as nonce = {block number}{timestamp} where each component is 16 bytes.
    * @param _wallet The target wallet.
    * @param _nonce The nonce
    */
    function checkAndUpdateNonce(BaseWallet _wallet, uint256 _nonce) internal returns (bool) {
        if(_nonce <= relayer[address(_wallet)].nonce) {
            return false;
        }   
        uint256 nonceBlock = (_nonce & 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000) >> 128;
        if(nonceBlock > block.number + BLOCKBOUND) {
            return false;
        }
        relayer[address(_wallet)].nonce = _nonce;
        return true;    
    }

    /**
    * @dev Recovers the signer at a given position from a list of concatenated signatures.
    * @param _signedHash The signed hash
    * @param _signatures The concatenated signatures.
    * @param _index The index of the signature to recover.
    */
    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        // we jump 32 (0x20) as the first slot of bytes contains the length
        // we jump 65 (0x41) per signature
        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28); 
        return ecrecover(_signedHash, v, r, s);
    }

    /**
    * @dev Refunds the gas used to the Relayer. 
    * For security reasons the default behavior is to not refund calls with 0 or 1 signatures. 
    * @param _wallet The target wallet.
    * @param _gasUsed The gas used.
    * @param _gasPrice The gas price for the refund.
    * @param _gasLimit The gas limit for the refund.
    * @param _signatures The number of signatures used in the call.
    * @param _relayer The address of the Relayer.
    */
    function refund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _gasLimit, uint _signatures, address _relayer) internal {
        uint256 amount = 29292 + _gasUsed; // 21000 (transaction) + 7620 (execution of refund) + 672 to log the event + _gasUsed
        // only refund if gas price not null, more than 1 signatures, gas less than gasLimit
        if(_gasPrice > 0 && _signatures > 1 && amount <= _gasLimit) {
            if(_gasPrice > tx.gasprice) {
                amount = amount * tx.gasprice;
            }
            else {
                amount = amount * _gasPrice;
            }
            _wallet.invoke(_relayer, amount, "");
        }
    }

    /**
    * @dev Returns false if the refund is expected to fail.
    * @param _wallet The target wallet.
    * @param _gasUsed The expected gas used.
    * @param _gasPrice The expected gas price for the refund.
    */
    function verifyRefund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _signatures) internal view returns (bool) {
        if(_gasPrice > 0 
            && _signatures > 1 
            && (address(_wallet).balance < _gasUsed * _gasPrice || _wallet.authorised(address(this)) == false)) {
            return false;
        }
        return true;
    }

    /**
    * @dev Checks that the wallet address provided as the first parameter of the relayed data is the same
    * as the wallet passed as the input of the execute() method. 
    @return false if the addresses are different.
    */
    function verifyData(address _wallet, bytes memory _data) private pure returns (bool) {
        require(_data.length >= 36, "RM: Invalid dataWallet");
        address dataWallet;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            //_data = {length:32}{sig:4}{_wallet:32}{...}
            dataWallet := mload(add(_data, 0x24))
        }
        return dataWallet == _wallet;
    }

    /**
    * @dev Parses the data to extract the method signature. 
    */
    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {
        require(_data.length >= 4, "RM: Invalid functionPrefix");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }
}

/**
 * @title OnlyOwnerModule
 * @dev Module that extends BaseModule and RelayerModule for modules where the execute() method
 * must be called with one signature frm the owner.
 * @author Julien Niset - <julien@argent.im>
 */
contract OnlyOwnerModule is BaseModule, RelayerModule {

    // *************** Implementation of RelayerModule methods ********************* //

    // Overrides to use the incremental nonce and save some gas
    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {
        return checkAndUpdateNonce(_wallet, _nonce);
    }

    function validateSignatures(BaseWallet _wallet, bytes memory _data, bytes32 _signHash, bytes memory _signatures) internal view returns (bool) {
        address signer = recoverSigner(_signHash, _signatures, 0);
        return isOwner(_wallet, signer); // "OOM: signer must be owner"
    }

    function getRequiredSignatures(BaseWallet _wallet, bytes memory _data) internal view returns (uint256) {
        return 1;
    }
}

/**
 * @title NftTransfer
 * @dev Module to transfer NFTs (ERC721),
 * @author Olivier VDB - <olivier@argent.xyz>
 */
contract NftTransfer is BaseModule, RelayerModule, OnlyOwnerModule {

    bytes32 constant NAME = "NftTransfer";

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    // The Guardian storage 
    GuardianStorage public guardianStorage;
    // The address of the CryptoKitties contract
    address public ckAddress;

    // *************** Events *************************** //

    event NonFungibleTransfer(address indexed wallet, address indexed nftContract, uint256 indexed tokenId, address to, bytes data);    

    // *************** Modifiers *************************** //

    /**
     * @dev Throws if the wallet is locked.
     */
    modifier onlyWhenUnlocked(BaseWallet _wallet) {
        // solium-disable-next-line security/no-block-members
        require(!guardianStorage.isLocked(_wallet), "NT: wallet must be unlocked");
        _;
    }

    // *************** Constructor ********************** //

    constructor(
        ModuleRegistry _registry,
        GuardianStorage _guardianStorage,
        address _ckAddress
    )
        BaseModule(_registry, NAME)
        public
    {
        guardianStorage = _guardianStorage;
        ckAddress = _ckAddress;
    }

    // *************** External/Public Functions ********************* //

    /**
     * @dev Inits the module for a wallet by setting up the onERC721Received
     * static call redirection from the wallet to the module.
     * @param _wallet The target wallet.
     */
    function init(BaseWallet _wallet) external onlyWallet(_wallet) {
        _wallet.enableStaticCall(address(this), ERC721_RECEIVED);
    }

    /**
     * @notice Handle the receipt of an NFT
     * @dev An ERC721 smart contract calls this function on the recipient contract
     * after a `safeTransfer`. If the recipient is a BaseWallet, the call to onERC721Received 
     * will be forwarded to the method onERC721Received of the present module. 
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external 
        returns (bytes4)
    {
        return ERC721_RECEIVED;
    }

    /**
    * @dev lets the owner transfer NFTs from a wallet.
    * @param _wallet The target wallet.
    * @param _nftContract The ERC721 address.
    * @param _to The recipient.
    * @param _tokenId The NFT id
    * @param _safe Whether to execute a safe transfer or not
    * @param _data The data to pass with the transfer.
    */
function transferNFT(
        BaseWallet _wallet,
        address _nftContract,
        address _to,
        uint256 _tokenId,
        bool _safe,
        bytes calldata _data
    )
        external
        onlyWalletOwner(_wallet)
        onlyWhenUnlocked(_wallet)
    {
        bytes memory methodData;
        if(_nftContract == ckAddress) {
            methodData = abi.encodeWithSignature("transfer(address,uint256)", _to, _tokenId);
        } else {
           if(_safe) {
               methodData = abi.encodeWithSignature(
                   "safeTransferFrom(address,address,uint256,bytes)", address(_wallet), _to, _tokenId, _data);
           } else {
               require(isERC721(_nftContract, _tokenId), "NT: Non-compliant NFT contract");
               methodData = abi.encodeWithSignature(
                   "transferFrom(address,address,uint256)", address(_wallet), _to, _tokenId);
           }
        }
        _wallet.invoke(_nftContract, 0, methodData);
        emit NonFungibleTransfer(address(_wallet), _nftContract, _tokenId, _to, _data);
    }

    // *************** Internal Functions ********************* //

    /**
    * @dev Check whether a given contract complies with ERC721.
    * @param _nftContract The contract to check.
    * @param _tokenId The tokenId to use for the check.
    * @return true if the contract is an ERC721, false otherwise.
    */
    function isERC721(address _nftContract, uint256 _tokenId) internal returns (bool) {
        // solium-disable-next-line security/no-low-level-calls
        (bool success, bytes memory result) = _nftContract.call(abi.encodeWithSignature('supportsInterface(bytes4)', 0x80ac58cd));
        if(success && result[0] != 0x0) return true;

        // solium-disable-next-line security/no-low-level-calls
        (success, result) = _nftContract.call(abi.encodeWithSignature('supportsInterface(bytes4)', 0x6466353c));
        if(success && result[0] != 0x0) return true;

        // solium-disable-next-line security/no-low-level-calls
        (success,) = _nftContract.call(abi.encodeWithSignature('ownerOf(uint256)', _tokenId));
        return success;
    }

}