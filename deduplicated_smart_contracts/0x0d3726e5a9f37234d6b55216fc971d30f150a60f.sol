/**

 *Submitted for verification at Etherscan.io on 2018-12-19

*/



pragma solidity 0.4.24;



// File: contracts/ERC677Receiver.sol



contract ERC677Receiver {

  function onTokenTransfer(address _from, uint _value, bytes _data) external returns(bool);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: contracts/ERC677.sol



contract ERC677 is ERC20 {

    event Transfer(address indexed from, address indexed to, uint value, bytes data);



    function transferAndCall(address, uint, bytes) external returns (bool);



}



// File: contracts/IBurnableMintableERC677Token.sol



contract IBurnableMintableERC677Token is ERC677 {

    function mint(address, uint256) public returns (bool);

    function burn(uint256 _value) public;

    function claimTokens(address _token, address _to) public;

}



// File: contracts/IBridgeValidators.sol



interface IBridgeValidators {

    function isValidator(address _validator) public view returns(bool);

    function requiredSignatures() public view returns(uint256);

    function owner() public view returns(address);

}



// File: contracts/libraries/Message.sol



library Message {

    // function uintToString(uint256 inputValue) internal pure returns (string) {

    //     // figure out the length of the resulting string

    //     uint256 length = 0;

    //     uint256 currentValue = inputValue;

    //     do {

    //         length++;

    //         currentValue /= 10;

    //     } while (currentValue != 0);

    //     // allocate enough memory

    //     bytes memory result = new bytes(length);

    //     // construct the string backwards

    //     uint256 i = length - 1;

    //     currentValue = inputValue;

    //     do {

    //         result[i--] = byte(48 + currentValue % 10);

    //         currentValue /= 10;

    //     } while (currentValue != 0);

    //     return string(result);

    // }



    function addressArrayContains(address[] array, address value) internal pure returns (bool) {

        for (uint256 i = 0; i < array.length; i++) {

            if (array[i] == value) {

                return true;

            }

        }

        return false;

    }

    // layout of message :: bytes:

    // offset  0: 32 bytes :: uint256 - message length

    // offset 32: 20 bytes :: address - recipient address

    // offset 52: 32 bytes :: uint256 - value

    // offset 84: 32 bytes :: bytes32 - transaction hash

    // offset 104: 20 bytes :: address - contract address to prevent double spending



    // bytes 1 to 32 are 0 because message length is stored as little endian.

    // mload always reads 32 bytes.

    // so we can and have to start reading recipient at offset 20 instead of 32.

    // if we were to read at 32 the address would contain part of value and be corrupted.

    // when reading from offset 20 mload will read 12 zero bytes followed

    // by the 20 recipient address bytes and correctly convert it into an address.

    // this saves some storage/gas over the alternative solution

    // which is padding address to 32 bytes and reading recipient at offset 32.

    // for more details see discussion in:

    // https://github.com/paritytech/parity-bridge/issues/61

    function parseMessage(bytes message)

        internal

        pure

        returns(address recipient, uint256 amount, bytes32 txHash, address contractAddress)

    {

        require(isMessageValid(message));

        assembly {

            recipient := and(mload(add(message, 20)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

            amount := mload(add(message, 52))

            txHash := mload(add(message, 84))

            contractAddress := mload(add(message, 104))

        }

    }



    function isMessageValid(bytes _msg) internal pure returns(bool) {

        return _msg.length == requiredMessageLength();

    }



    function requiredMessageLength() internal pure returns(uint256) {

        return 104;

    }



    function recoverAddressFromSignedMessage(bytes signature, bytes message) internal pure returns (address) {

        require(signature.length == 65);

        bytes32 r;

        bytes32 s;

        bytes1 v;

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            r := mload(add(signature, 0x20))

            s := mload(add(signature, 0x40))

            v := mload(add(signature, 0x60))

        }

        return ecrecover(hashMessage(message), uint8(v), r, s);

    }



    function hashMessage(bytes message) internal pure returns (bytes32) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n";

        // message is always 84 length

        string memory msgLength = "104";

        return keccak256(abi.encodePacked(prefix, msgLength, message));

    }



    function hasEnoughValidSignatures(

        bytes _message,

        uint8[] _vs,

        bytes32[] _rs,

        bytes32[] _ss,

        IBridgeValidators _validatorContract) internal view {

        require(isMessageValid(_message));

        uint256 requiredSignatures = _validatorContract.requiredSignatures();

        require(_vs.length >= requiredSignatures);

        bytes32 hash = hashMessage(_message);

        address[] memory encounteredAddresses = new address[](requiredSignatures);



        for (uint256 i = 0; i < requiredSignatures; i++) {

            address recoveredAddress = ecrecover(hash, _vs[i], _rs[i], _ss[i]);

            require(_validatorContract.isValidator(recoveredAddress));

            if (addressArrayContains(encounteredAddresses, recoveredAddress)) {

                revert();

            }

            encounteredAddresses[i] = recoveredAddress;

        }

    }

}



// File: contracts/libraries/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  /**

  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

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



}



// File: contracts/upgradeable_contracts/Ownable.sol



/**

 * @title Ownable

 * @dev This contract has an owner address providing basic authorization control

 */

contract Ownable is EternalStorage {

    /**

    * @dev Event to show ownership has been transferred

    * @param previousOwner representing the address of the previous owner

    * @param newOwner representing the address of the new owner

    */

    event OwnershipTransferred(address previousOwner, address newOwner);



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

        emit OwnershipTransferred(owner(), newOwner);

        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;

    }

}



// File: contracts/IOwnedUpgradeabilityProxy.sol



interface IOwnedUpgradeabilityProxy {

    function proxyOwner() public view returns (address);

}



// File: contracts/upgradeable_contracts/OwnedUpgradeability.sol



contract OwnedUpgradeability {



    function upgradeabilityAdmin() public view returns (address) {

        return IOwnedUpgradeabilityProxy(this).proxyOwner();

    }



    // Avoid using onlyProxyOwner name to prevent issues with implementation from proxy contract

    modifier onlyIfOwnerOfProxy() {

        require(msg.sender == upgradeabilityAdmin());

        _;

    }

}



// File: contracts/upgradeable_contracts/Validatable.sol



contract Validatable is EternalStorage {

    function validatorContract() public view returns(IBridgeValidators) {

        return IBridgeValidators(addressStorage[keccak256(abi.encodePacked("validatorContract"))]);

    }



    modifier onlyValidator() {

        require(validatorContract().isValidator(msg.sender));

        _;

    }



    function requiredSignatures() public view returns(uint256) {

        return validatorContract().requiredSignatures();

    }



}



// File: contracts/upgradeable_contracts/BasicBridge.sol



contract BasicBridge is EternalStorage, Validatable, Ownable, OwnedUpgradeability {

    using SafeMath for uint256;



    event GasPriceChanged(uint256 gasPrice);

    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    event DailyLimitChanged(uint256 newLimit);

    event ExecutionDailyLimitChanged(uint256 newLimit);



    function getBridgeInterfacesVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {

        return (2, 2, 0);

    }



    function setGasPrice(uint256 _gasPrice) public onlyOwner {

        require(_gasPrice > 0);

        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;

        emit GasPriceChanged(_gasPrice);

    }



    function gasPrice() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("gasPrice"))];

    }



    function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {

        require(_blockConfirmations > 0);

        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _blockConfirmations;

        emit RequiredBlockConfirmationChanged(_blockConfirmations);

    }



    function requiredBlockConfirmations() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];

    }



    function deployedAtBlock() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))];

    }



    function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = _value;

    }



    function totalSpentPerDay(uint256 _day) public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))];

    }



    function setTotalExecutedPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))] = _value;

    }



    function totalExecutedPerDay(uint256 _day) public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))];

    }



    function minPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("minPerTx"))];

    }



    function maxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("maxPerTx"))];

    }



    function executionMaxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))];

    }



    function setInitialize(bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;

    }



    function isInitialized() public view returns(bool) {

        return boolStorage[keccak256(abi.encodePacked("isInitialized"))];

    }



    function getCurrentDay() public view returns(uint256) {

        return now / 1 days;

    }



    function setDailyLimit(uint256 _dailyLimit) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("dailyLimit"))] = _dailyLimit;

        emit DailyLimitChanged(_dailyLimit);

    }



    function dailyLimit() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("dailyLimit"))];

    }



    function setExecutionDailyLimit(uint256 _dailyLimit) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))] = _dailyLimit;

        emit ExecutionDailyLimitChanged(_dailyLimit);

    }



    function executionDailyLimit() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))];

    }



    function setExecutionMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx < executionDailyLimit());

        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))] = _maxPerTx;

    }



    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx < dailyLimit());

        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;

    }



    function setMinPerTx(uint256 _minPerTx) external onlyOwner {

        require(_minPerTx < dailyLimit() && _minPerTx < maxPerTx());

        uintStorage[keccak256(abi.encodePacked("minPerTx"))] = _minPerTx;

    }



    function withinLimit(uint256 _amount) public view returns(bool) {

        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);

        return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();

    }



    function withinExecutionLimit(uint256 _amount) public view returns(bool) {

        uint256 nextLimit = totalExecutedPerDay(getCurrentDay()).add(_amount);

        return executionDailyLimit() >= nextLimit && _amount <= executionMaxPerTx();

    }



    function claimTokens(address _token, address _to) public onlyIfOwnerOfProxy {

        require(_to != address(0));

        if (_token == address(0)) {

            _to.transfer(address(this).balance);

            return;

        }



        ERC20Basic token = ERC20Basic(_token);

        uint256 balance = token.balanceOf(this);

        require(token.transfer(_to, balance));

    }





    function isContract(address _addr) internal view returns (bool)

    {

        uint length;

        assembly { length := extcodesize(_addr) }

        return length > 0;

    }

}



// File: contracts/upgradeable_contracts/BasicForeignBridge.sol



contract BasicForeignBridge is EternalStorage, Validatable {

    using SafeMath for uint256;

    /// triggered when relay of deposit from HomeBridge is complete

    event RelayedMessage(address recipient, uint value, bytes32 transactionHash);

    function executeSignatures(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {

        Message.hasEnoughValidSignatures(message, vs, rs, ss, validatorContract());

        address recipient;

        uint256 amount;

        bytes32 txHash;

        address contractAddress;

        (recipient, amount, txHash, contractAddress) = Message.parseMessage(message);

        if (messageWithinLimits(amount)) {

            require(contractAddress == address(this));

            require(!relayedMessages(txHash));

            setRelayedMessages(txHash, true);

            require(onExecuteMessage(recipient, amount));

            emit RelayedMessage(recipient, amount, txHash);

        } else {

            onFailedMessage(recipient, amount, txHash);

        }

    }



    function onExecuteMessage(address, uint256) internal returns(bool){

        // has to be defined

    }



    function setRelayedMessages(bytes32 _txHash, bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))] = _status;

    }



    function relayedMessages(bytes32 _txHash) public view returns(bool) {

        return boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))];

    }



    function messageWithinLimits(uint256) internal view returns(bool) {

        return true;

    }



    function onFailedMessage(address, uint256, bytes32) internal {

    }

}



// File: contracts/upgradeable_contracts/erc20_to_native/ForeignBridgeErcToNative.sol



contract ForeignBridgeErcToNative is BasicBridge, BasicForeignBridge {

    event RelayedMessage(address recipient, uint value, bytes32 transactionHash);



    function initialize(

        address _validatorContract,

        address _erc20token,

        uint256 _requiredBlockConfirmations,

        uint256 _gasPrice,

        uint256 _maxPerTx,

        uint256 _homeDailyLimit,

        uint256 _homeMaxPerTx,

        address _owner

    ) public returns(bool) {

        require(!isInitialized());

        require(_validatorContract != address(0) && isContract(_validatorContract));

        require(_requiredBlockConfirmations != 0);

        require(_gasPrice > 0);

        require(_homeMaxPerTx < _homeDailyLimit);

        require(_owner != address(0));

        addressStorage[keccak256(abi.encodePacked("validatorContract"))] = _validatorContract;

        setErc20token(_erc20token);

        uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))] = block.number;

        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;

        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;

        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;

        uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))] = _homeDailyLimit;

        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))] = _homeMaxPerTx;

        setOwner(_owner);

        setInitialize(true);

        return isInitialized();

    }



    function upgradeToV220(address _newOwner) public onlyIfOwnerOfProxy {

        require(!boolStorage[keccak256(abi.encodePacked("isUpgradedToV220"))]);

        setOwner(_newOwner);

        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = 100000 ether;

        uintStorage[keccak256(abi.encodePacked("executionDailyLimit"))] = 1000000 ether;

        emit ExecutionDailyLimitChanged(1000000 ether);

        uintStorage[keccak256(abi.encodePacked("executionMaxPerTx"))] = 100000 ether;

        boolStorage[keccak256("isUpgradedToV220")] = true;

    }



    function getBridgeMode() public pure returns(bytes4 _data) {

        return bytes4(keccak256(abi.encodePacked("erc-to-native-core")));

    }



    function claimTokens(address _token, address _to) public onlyIfOwnerOfProxy {

        require(_token != address(erc20token()));

        super.claimTokens(_token, _to);

    }



    function erc20token() public view returns(ERC20Basic) {

        return ERC20Basic(addressStorage[keccak256(abi.encodePacked("erc20token"))]);

    }



    function onExecuteMessage(address _recipient, uint256 _amount) internal returns(bool) {

        setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(_amount));

        return erc20token().transfer(_recipient, _amount);

    }



    function setErc20token(address _token) private {

        require(_token != address(0) && isContract(_token));

        addressStorage[keccak256(abi.encodePacked("erc20token"))] = _token;

    }



    function messageWithinLimits(uint256 _amount) internal view returns(bool) {

        return withinExecutionLimit(_amount);

    }



    function onFailedMessage(address, uint256, bytes32) internal {

        revert();

    }

}