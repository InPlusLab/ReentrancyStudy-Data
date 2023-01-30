/**

 *Submitted for verification at Etherscan.io on 2019-03-18

*/



pragma solidity 0.4.24;



// File: contracts/IBridgeValidators.sol



interface IBridgeValidators {

    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner) public returns(bool);

    function isValidator(address _validator) public view returns(bool);

    function requiredSignatures() public view returns(uint256);

    function owner() public view returns(address);

}



// File: contracts/IForeignBridge.sol



contract IForeignBridge {



  function initialize(

        address _validatorContract,

        address _erc20token,

        uint256 _requiredBlockConfirmations,

        uint256 _gasPrice,

        uint256 _maxPerTx,

        uint256 _homeDailyLimit,

        uint256 _homeMaxPerTx,

        address _owner

    ) public returns(bool);

  

}



// File: contracts/upgradeability/EternalStorage.sol



/**

 * @title EternalStorage

 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.

 */

contract EternalStorage {



    mapping(bytes32 => uint256) internal uintStorage;

    mapping(bytes32 => string) internal stringStorage;

    mapping(bytes32 => address) internal addressStorage;

    mapping(bytes32 => bytes) internal bytesStorage;

    mapping(bytes32 => bool) internal boolStorage;

    mapping(bytes32 => int256) internal intStorage;





    mapping(bytes32 => uint256[]) internal uintArrayStorage;

    mapping(bytes32 => string[]) internal stringArrayStorage;

    mapping(bytes32 => address[]) internal addressArrayStorage;

    //mapping(bytes32 => bytes[]) internal bytesArrayStorage;

    mapping(bytes32 => bool[]) internal boolArrayStorage;

    mapping(bytes32 => int256[]) internal intArrayStorage;

    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;

}



// File: contracts/upgradeability/UpgradeabilityOwnerStorage.sol



/**

 * @title UpgradeabilityOwnerStorage

 * @dev This contract keeps track of the upgradeability owner

 */

contract UpgradeabilityOwnerStorage {

    // Owner of the contract

    address private _upgradeabilityOwner;



    /**

    * @dev Tells the address of the owner

    * @return the address of the owner

    */

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;

    }



    /**

    * @dev Sets the address of the owner

    */

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;

    }

}



// File: contracts/upgradeability/Proxy.sol



/**

 * @title Proxy

 * @dev Gives the possibility to delegate any call to a foreign implementation.

 */

contract Proxy {



  /**

  * @dev Tells the address of the implementation where every call will be delegated.

  * @return address of the implementation to which it will be delegated

  */

    function implementation() public view returns (address);



    function setImplementation(address _newImplementation) external;



  /**

  * @dev Fallback function allowing to perform a delegatecall to the given implementation.

  * This function will return whatever the implementation call returns

  */

    function () payable public {

        address _impl = implementation();

        require(_impl != address(0));



        address _innerImpl;

        bytes4 sig;

        address thisAddress = address(this);

        if (_impl.call(0x5c60da1b)) { // bytes(keccak256("implementation()"))

            _innerImpl = Proxy(_impl).implementation();

            this.setImplementation(_innerImpl);

            sig = 0xd784d426; // bytes4(keccak256("setImplementation(address)"))

        }



        assembly {

            /*

                0x40 is the "free memory slot", meaning a pointer to next slot of empty memory. mload(0x40)

                loads the data in the free memory slot, so `ptr` is a pointer to the next slot of empty

                memory. It's needed because we're going to write the return data of delegatecall to the

                free memory slot.

            */

            let ptr := mload(0x40)

            /*

                `calldatacopy` is copy calldatasize bytes from calldata

                First argument is the destination to which data is copied(ptr)

                Second argument specifies the start position of the copied data.

                    Since calldata is sort of its own unique location in memory,

                    0 doesn't refer to 0 in memory or 0 in storage - it just refers to the zeroth byte of calldata.

                    That's always going to be the zeroth byte of the function selector.

                Third argument, calldatasize, specifies how much data will be copied.

                    calldata is naturally calldatasize bytes long (same thing as msg.data.length)

            */

            calldatacopy(ptr, 0, calldatasize)

            /*

                delegatecall params explained:

                gas: the amount of gas to provide for the call. `gas` is an Opcode that gives

                    us the amount of gas still available to execution



                _impl: address of the contract to delegate to



                ptr: to pass copied data



                calldatasize: loads the size of `bytes memory data`, same as msg.data.length



                0, 0: These are for the `out` and `outsize` params. Because the output could be dynamic,

                        these are set to 0, 0 so the output data will not be written to memory. The output

                        data will be read using `returndatasize` and `returdatacopy` instead.



                result: This will be 0 if the call fails and 1 if it succeeds

            */

            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)

            /*



            */

            /*

                ptr current points to the value stored at 0x40,

                because we assigned it like ptr := mload(0x40).

                Because we use 0x40 as a free memory pointer,

                we want to make sure that the next time we want to allocate memory,

                we aren't overwriting anything important.

                So, by adding ptr and returndatasize,

                we get a memory location beyond the end of the data we will be copying to ptr.

                We place this in at 0x40, and any reads from 0x40 will now read from free memory

            */

            mstore(0x40, add(ptr, returndatasize))

            /*

                `returndatacopy` is an Opcode that copies the last return data to a slot. `ptr` is the

                    slot it will copy to, 0 means copy from the beginning of the return data, and size is

                    the amount of data to copy.

                `returndatasize` is an Opcode that gives us the size of the last return data. In this case, that is the size of the data returned from delegatecall

            */

            returndatacopy(ptr, 0, returndatasize)



            let retdatasize := returndatasize



            switch sig

            case 0 {}

            default {

                let x := mload(0x40)

                mstore(x, sig)

                mstore(add(x, 0x04), _impl)

                let success := call(gas, thisAddress, 0, x, 0x24, x, 0x0)

            }



            /*

                if `result` is 0, revert.

                if `result` is 1, return `size` amount of data from `ptr`. This is the data that was

                copied to `ptr` from the delegatecall return data

            */

            switch result

            case 0 { revert(ptr, retdatasize) }

            default { return(ptr, retdatasize) }

        }

    }

}



// File: contracts/upgradeability/UpgradeabilityStorage.sol



/**

 * @title UpgradeabilityStorage

 * @dev This contract holds all the necessary state variables to support the upgrade functionality

 */

contract UpgradeabilityStorage {

    // Version name of the current implementation

    uint256 internal _version;



    // Address of the current implementation

    address internal _implementation;



    /**

    * @dev Tells the version name of the current implementation

    * @return string representing the name of the current version

    */

    function version() public view returns (uint256) {

        return _version;

    }



    /**

    * @dev Tells the address of the current implementation

    * @return address of the current implementation

    */

    function implementation() public view returns (address) {

        return _implementation;

    }



    function setImplementation(address _newImplementation) external {

        require(msg.sender == address(this));

        _implementation = _newImplementation;

    }

}



// File: contracts/upgradeability/UpgradeabilityProxy.sol



/**

 * @title UpgradeabilityProxy

 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded

 */

contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {

    /**

    * @dev This event will be emitted every time the implementation gets upgraded

    * @param version representing the version name of the upgraded implementation

    * @param implementation representing the address of the upgraded implementation

    */

    event Upgraded(uint256 version, address indexed implementation);



    /**

    * @dev Upgrades the implementation address

    * @param version representing the version name of the new implementation to be set

    * @param implementation representing the address of the new implementation to be set

    */

    function _upgradeTo(uint256 version, address implementation) internal {

        require(_implementation != implementation);

        require(version > _version);

        _version = version;

        _implementation = implementation;

        emit Upgraded(version, implementation);

    }

}



// File: contracts/upgradeability/OwnedUpgradeabilityProxy.sol



/**

 * @title OwnedUpgradeabilityProxy

 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities

 */

contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {

  /**

  * @dev Event to show ownership has been transferred

  * @param previousOwner representing the address of the previous owner

  * @param newOwner representing the address of the new owner

  */

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);



    /**

    * @dev the constructor sets the original owner of the contract to the sender account.

    */

    constructor() public {

        setUpgradeabilityOwner(msg.sender);

    }



    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());

        _;

    }



    /**

    * @dev Tells the address of the proxy owner

    * @return the address of the proxy owner

    */

    function proxyOwner() public view returns (address) {

        return upgradeabilityOwner();

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param newOwner The address to transfer ownership to.

    */

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {

        require(newOwner != address(0));

        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);

        setUpgradeabilityOwner(newOwner);

    }



    /**

    * @dev Allows the upgradeability owner to upgrade the current version of the proxy.

    * @param version representing the version name of the new implementation to be set.

    * @param implementation representing the address of the new implementation to be set.

    */

    function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {

        _upgradeTo(version, implementation);

    }



    /**

    * @dev Allows the upgradeability owner to upgrade the current version of the proxy and call the new implementation

    * to initialize whatever is needed through a low level call.

    * @param version representing the version name of the new implementation to be set.

    * @param implementation representing the address of the new implementation to be set.

    * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function

    * signature of the implementation to be called with the needed payload

    */

    function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {

        upgradeTo(version, implementation);

        require(address(this).call.value(msg.value)(data));

    }

}



// File: contracts/upgradeability/EternalStorageProxy.sol



/**

 * @title EternalStorageProxy

 * @dev This proxy holds the storage of the token contract and delegates every call to the current implementation set.

 * Besides, it allows to upgrade the token's behaviour towards further implementations, and provides basic

 * authorization control functionalities

 */

contract EternalStorageProxy is OwnedUpgradeabilityProxy, EternalStorage {}



// File: contracts/upgradeable_contracts/EternalOwnable.sol



/**

 * @title EternalOwnable

 * @dev This contract has an owner address providing basic authorization control

 */

contract EternalOwnable is EternalStorage {

    /**

    * @dev Event to show ownership has been transferred

    * @param previousOwner representing the address of the previous owner

    * @param newOwner representing the address of the new owner

    */

    event EternalOwnershipTransferred(address previousOwner, address newOwner);



    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyOwner() {

        require(msg.sender == owner());

        _;

    }



    /**

    * @dev Tells the address of the owner

    * @return the address of the owner

    */

    function owner() public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("owner"))];

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param newOwner the address to transfer ownership to.

    */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        setOwner(newOwner);

    }



    /**

    * @dev Sets a new owner address

    */

    function setOwner(address newOwner) internal {

        emit EternalOwnershipTransferred(owner(), newOwner);

        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;

    }

}



// File: contracts/upgradeable_contracts/factories/BasicBridgeFactory.sol



contract BasicBridgeFactory is EternalStorage, EternalOwnable {



    function getBridgeFactoryVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {

        return (2, 2, 0);

    }



    function bridgeValidatorsImplementation() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsImplementation"))];

    }



    function setBridgeValidatorsImplementation(address _bridgeValidatorsImplementation) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("bridgeValidatorsImplementation"))] = _bridgeValidatorsImplementation;

    }



    function requiredSignatures() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("requiredSignatures"))];

    }



    function setRequiredSignatures(uint256 _requiredSignatures) public onlyOwner {

        require(initialValidators().length >= _requiredSignatures);

        uintStorage[keccak256(abi.encodePacked("requiredSignatures"))] = _requiredSignatures;

    }



    function initialValidators() public view returns(address[]) {

        return addressArrayStorage[keccak256(abi.encodePacked("initialValidators"))];

    }



    function setInitialValidators(address[] _initialValidators) public onlyOwner {

        require(_initialValidators.length >= requiredSignatures());

        addressArrayStorage[keccak256(abi.encodePacked("initialValidators"))] = _initialValidators;

    }



    function bridgeValidatorsOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsOwner"))];

    }



    function setBridgeValidatorsOwner(address _bridgeValidatorsOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("bridgeValidatorsOwner"))] = _bridgeValidatorsOwner;

    }



    function bridgeValidatorsProxyOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsProxyOwner"))];

    }



    function setBridgeValidatorsProxyOwner(address _bridgeValidatorsProxyOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("bridgeValidatorsProxyOwner"))] = _bridgeValidatorsProxyOwner;

    }



    function requiredBlockConfirmations() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];

    }



    function setRequiredBlockConfirmations(uint256 _requiredBlockConfirmations) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;

    }



    function gasPrice() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("gasPrice"))];

    }



    function setGasPrice(uint256 _gasPrice) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;

    }



    function homeDailyLimit() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("homeDailyLimit"))];

    }



    function setHomeDailyLimit(uint256 _homeDailyLimit) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("homeDailyLimit"))] = _homeDailyLimit;

    }



    function homeMaxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("homeMaxPerTx"))];

    }



    function setHomeMaxPerTx(uint256 _homeMaxPerTx) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("homeMaxPerTx"))] = _homeMaxPerTx;

    }



    function foreignMaxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("foreignMaxPerTx"))];

    }



    function setForeignMaxPerTx(uint256 _foreignMaxPerTx) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("foreignMaxPerTx"))] = _foreignMaxPerTx;

    }



    function setInitialize(bool _status) internal { 

        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status; 

    }



    function isInitialized() public view returns(bool) { 

        return boolStorage[keccak256(abi.encodePacked("isInitialized"))]; 

    }

}



// File: contracts/upgradeable_contracts/factories/ForeignBridgeFactory.sol



contract ForeignBridgeFactory is BasicBridgeFactory {



    event ForeignBridgeDeployed(address indexed _foreignBridge, address indexed _foreignValidators, uint256 _blockNumber);



    function initialize(address _owner,

            address _bridgeValidatorsImplementation,

            uint256 _requiredSignatures,

            address[] _initialValidators,

            address _bridgeValidatorsOwner,

            address _foreignBridgeErcToErcImplementation,

            uint256 _requiredBlockConfirmations,

            uint256 _gasPrice,

            uint256 _foreignMaxPerTx,

            uint256 _homeDailyLimit,

            uint256 _homeMaxPerTx,

            address _foreignBridgeOwner,

            address _foreignProxyOwner) public returns(bool) {



        require(!isInitialized());

        require(_owner != address(0));

        require(_bridgeValidatorsImplementation != address(0));

        require(_requiredSignatures >= 1);

        require(_bridgeValidatorsOwner != address(0));

        require(_foreignBridgeErcToErcImplementation != address(0));

        require(_requiredBlockConfirmations != 0);

        require(_gasPrice > 0);

        require(_foreignMaxPerTx >= 0);

        require(_homeMaxPerTx < _homeDailyLimit);

        require(_foreignBridgeOwner != address(0));

        require(_foreignProxyOwner != address(0));

        require(_initialValidators.length >= _requiredSignatures);



        setOwner(msg.sender); // set just to have access to the setters.

        setBridgeValidatorsImplementation(_bridgeValidatorsImplementation);

        setInitialValidators(_initialValidators);

        setRequiredSignatures(_requiredSignatures);

        setBridgeValidatorsOwner(_bridgeValidatorsOwner);

        setBridgeValidatorsProxyOwner(_foreignProxyOwner);

        setForeignBridgeErcToErcImplementation(_foreignBridgeErcToErcImplementation);

        setRequiredBlockConfirmations(_requiredBlockConfirmations);

        setGasPrice(_gasPrice);

        setForeignMaxPerTx(_foreignMaxPerTx);

        setHomeDailyLimit(_homeDailyLimit);

        setHomeMaxPerTx(_homeMaxPerTx);

        setForeignBridgeOwner(_foreignBridgeOwner);

        setForeignBridgeProxyOwner(_foreignProxyOwner);

        setInitialize(true);

        setOwner(_owner); // set to the real owner.

        return isInitialized();

    }



    function deployForeignBridge(address _erc20Token) public onlyOwner {

        // deploy new EternalStorageProxy

        EternalStorageProxy proxy = new EternalStorageProxy();

        // connect it to the static BridgeValidators implementation

        proxy.upgradeTo(1, bridgeValidatorsImplementation());

        // cast proxy as IBridgeValidators

        IBridgeValidators bridgeValidators = IBridgeValidators(proxy);

        // initialize bridgeValidators

        bridgeValidators.initialize(requiredSignatures(), initialValidators(), bridgeValidatorsOwner());

        // transfer proxy upgradeability admin

        proxy.transferProxyOwnership(bridgeValidatorsProxyOwner());

        // deploy new EternalStorageProxy

        proxy = new EternalStorageProxy();

        // connect it to the static ForeignBridgeErcToErc implementation

        proxy.upgradeTo(1, foreignBridgeErcToErcImplementation());

        // cast proxy as IForeignBridge

        IForeignBridge foreignBridge = IForeignBridge(proxy);

        // initialize foreignBridge

        foreignBridge.initialize(bridgeValidators, _erc20Token, requiredBlockConfirmations(), gasPrice(), foreignMaxPerTx(), homeDailyLimit(), homeMaxPerTx(), foreignBridgeOwner());

        // transfer proxy upgradeability admin

        proxy.transferProxyOwnership(foreignBridgeProxyOwner());

        // emit event

        emit ForeignBridgeDeployed(foreignBridge, bridgeValidators, block.number);

    }



    function foreignBridgeErcToErcImplementation() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("foreignBridgeErcToErcImplementation"))];

    }



    function setForeignBridgeErcToErcImplementation(address _foreignBridgeErcToErcImplementation) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("foreignBridgeErcToErcImplementation"))] = _foreignBridgeErcToErcImplementation;

    }



    function foreignBridgeOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("foreignBridgeOwner"))];

    }



    function setForeignBridgeOwner(address _foreignBridgeOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("foreignBridgeOwner"))] = _foreignBridgeOwner;

    }



    function foreignBridgeProxyOwner() public view returns(address) {

        return addressStorage[keccak256(abi.encodePacked("foreignBridgeProxyOwner"))];

    }



    function setForeignBridgeProxyOwner(address _foreignBridgeProxyOwner) public onlyOwner {

        addressStorage[keccak256(abi.encodePacked("foreignBridgeProxyOwner"))] = _foreignBridgeProxyOwner;

    }

}