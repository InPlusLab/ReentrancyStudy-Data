/**
 *Submitted for verification at Etherscan.io on 2020-08-02
*/

// File: contracts/interfaces/IBridgeValidators.sol

pragma solidity 0.4.24;

interface IBridgeValidators {
    function isValidator(address _validator) external view returns (bool);
    function requiredSignatures() external view returns (uint256);
    function owner() external view returns (address);
}

// File: contracts/libraries/Message.sol

pragma solidity 0.4.24;


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

    // mload always reads 32 bytes.
    // so we can and have to start reading recipient at offset 20 instead of 32.
    // if we were to read at 32 the address would contain part of value and be corrupted.
    // when reading from offset 20 mload will read 12 bytes (most of them zeros) followed
    // by the 20 recipient address bytes and correctly convert it into an address.
    // this saves some storage/gas over the alternative solution
    // which is padding address to 32 bytes and reading recipient at offset 32.
    // for more details see discussion in:
    // https://github.com/paritytech/parity-bridge/issues/61
    function parseMessage(bytes message)
        internal
        pure
        returns (address recipient, uint256 amount, bytes32 txHash, address contractAddress)
    {
        require(isMessageValid(message));
        assembly {
            recipient := mload(add(message, 20))
            amount := mload(add(message, 52))
            txHash := mload(add(message, 84))
            contractAddress := mload(add(message, 104))
        }
    }

    function isMessageValid(bytes _msg) internal pure returns (bool) {
        return _msg.length == requiredMessageLength();
    }

    function requiredMessageLength() internal pure returns (uint256) {
        return 104;
    }

    function recoverAddressFromSignedMessage(bytes signature, bytes message, bool isAMBMessage)
        internal
        pure
        returns (address)
    {
        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        return ecrecover(hashMessage(message, isAMBMessage), uint8(v), r, s);
    }

    function hashMessage(bytes message, bool isAMBMessage) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        if (isAMBMessage) {
            return keccak256(abi.encodePacked(prefix, uintToString(message.length), message));
        } else {
            string memory msgLength = "104";
            return keccak256(abi.encodePacked(prefix, msgLength, message));
        }
    }

    /**
    * @dev Validates provided signatures, only first requiredSignatures() number
    * of signatures are going to be validated, these signatures should be from different validators.
    * @param _message bytes message used to generate signatures
    * @param _signatures bytes blob with signatures to be validated.
    * First byte X is a number of signatures in a blob,
    * next X bytes are v components of signatures,
    * next 32 * X bytes are r components of signatures,
    * next 32 * X bytes are s components of signatures.
    * @param _validatorContract contract, which conforms to the IBridgeValidators interface,
    * where info about current validators and required signatures is stored.
    * @param isAMBMessage true if _message is an AMB message with arbitrary length.
    */
    function hasEnoughValidSignatures(
        bytes _message,
        bytes _signatures,
        IBridgeValidators _validatorContract,
        bool isAMBMessage
    ) internal view {
        require(isAMBMessage || isMessageValid(_message));
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        uint256 amount;
        assembly {
            amount := and(mload(add(_signatures, 1)), 0xff)
        }
        require(amount >= requiredSignatures);
        bytes32 hash = hashMessage(_message, isAMBMessage);
        address[] memory encounteredAddresses = new address[](requiredSignatures);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            uint8 v;
            bytes32 r;
            bytes32 s;
            uint256 posr = 33 + amount + 32 * i;
            uint256 poss = posr + 32 * amount;
            assembly {
                v := mload(add(_signatures, add(2, i)))
                r := mload(add(_signatures, posr))
                s := mload(add(_signatures, poss))
            }

            address recoveredAddress = ecrecover(hash, v, r, s);
            require(_validatorContract.isValidator(recoveredAddress));
            require(!addressArrayContains(encounteredAddresses, recoveredAddress));
            encounteredAddresses[i] = recoveredAddress;
        }
    }

    function uintToString(uint256 i) internal pure returns (string) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (i != 0) {
            bstr[k--] = bytes1(48 + (i % 10));
            i /= 10;
        }
        return string(bstr);
    }
}

// File: contracts/libraries/ArbitraryMessage.sol

pragma solidity 0.4.24;

library ArbitraryMessage {
    /**
    * @dev Unpacks data fields from AMB message
    * layout of message :: bytes:
    * offset  0              : 32 bytes :: uint256 - message length
    * offset 32              : 32 bytes :: bytes32 - messageId
    * offset 64              : 20 bytes :: address - sender address
    * offset 84              : 20 bytes :: address - executor contract
    * offset 104             : 4 bytes  :: uint32  - gasLimit
    * offset 108             : 1 bytes  :: uint8   - source chain id length (X)
    * offset 109             : 1 bytes  :: uint8   - destination chain id length (Y)
    * offset 110             : 1 bytes  :: bytes1  - dataType
    * (optional) 111         : 32 bytes :: uint256 - gasPrice
    * (optional) 111         : 1 bytes  :: bytes1  - gasPriceSpeed
    * offset 111/143/112     : X bytes  :: bytes   - source chain id
    * offset 111/143/112 + X : Y bytes  :: bytes   - destination chain id

    * NOTE: when message structure is changed, make sure that MESSAGE_PACKING_VERSION from VersionableAMB is updated as well
    * NOTE: assembly code uses calldatacopy, make sure that message is passed as the first argument in the calldata
    * @param _data encoded message
    */
    function unpackData(bytes _data)
        internal
        pure
        returns (
            bytes32 messageId,
            address sender,
            address executor,
            uint32 gasLimit,
            bytes1 dataType,
            uint256[2] chainIds,
            uint256 gasPrice,
            bytes memory data
        )
    {
        // 32 (message id) + 20 (sender) + 20 (executor) + 4 (gasLimit) + 1 (source chain id length) + 1 (destination chain id length) + 1 (dataType)
        uint256 srcdataptr = 32 + 20 + 20 + 4 + 1 + 1 + 1;
        uint256 datasize;

        assembly {
            messageId := mload(add(_data, 32)) // 32 bytes
            sender := and(mload(add(_data, 52)), 0xffffffffffffffffffffffffffffffffffffffff) // 20 bytes

            // executor (20 bytes) + gasLimit (4 bytes) + srcChainIdLength (1 byte) + dstChainIdLength (1 bytes) + dataType (1 byte) + remainder (5 bytes)
            let blob := mload(add(_data, 84))

            // after bit shift left 12 bytes are zeros automatically
            executor := shr(96, blob)
            gasLimit := and(shr(64, blob), 0xffffffff)

            // load source chain id length
            let chainIdLength := byte(24, blob)

            dataType := and(shl(208, blob), 0xFF00000000000000000000000000000000000000000000000000000000000000)
            switch dataType
                case 0x0000000000000000000000000000000000000000000000000000000000000000 {
                    gasPrice := 0
                }
                case 0x0100000000000000000000000000000000000000000000000000000000000000 {
                    gasPrice := mload(add(_data, 111)) // 32
                    srcdataptr := add(srcdataptr, 32)
                }
                case 0x0200000000000000000000000000000000000000000000000000000000000000 {
                    gasPrice := 0
                    srcdataptr := add(srcdataptr, 1)
                }

            // at this moment srcdataptr points to sourceChainId

            // mask for sourceChainId
            // e.g. length X -> (1 << (X * 8)) - 1
            let mask := sub(shl(shl(3, chainIdLength), 1), 1)

            // increase payload offset by length of source chain id
            srcdataptr := add(srcdataptr, chainIdLength)

            // write sourceChainId
            mstore(chainIds, and(mload(add(_data, srcdataptr)), mask))

            // at this moment srcdataptr points to destinationChainId

            // load destination chain id length
            chainIdLength := byte(25, blob)

            // mask for destinationChainId
            // e.g. length X -> (1 << (X * 8)) - 1
            mask := sub(shl(shl(3, chainIdLength), 1), 1)

            // increase payload offset by length of destination chain id
            srcdataptr := add(srcdataptr, chainIdLength)

            // write destinationChainId
            mstore(add(chainIds, 32), and(mload(add(_data, srcdataptr)), mask))

            // at this moment srcdataptr points to payload

            // datasize = message length - payload offset
            datasize := sub(mload(_data), srcdataptr)
        }

        data = new bytes(datasize);
        assembly {
            // 36 = 4 (selector) + 32 (bytes length header)
            srcdataptr := add(srcdataptr, 36)

            // calldataload(4) - offset of first bytes argument in the calldata
            calldatacopy(add(data, 32), add(calldataload(4), srcdataptr), datasize)
        }
    }
}

// File: contracts/interfaces/IUpgradeabilityOwnerStorage.sol

pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {
    function upgradeabilityOwner() external view returns (address);
}

// File: contracts/upgradeable_contracts/Upgradeable.sol

pragma solidity 0.4.24;


contract Upgradeable {
    // Avoid using onlyUpgradeabilityOwner name to prevent issues with implementation from proxy contract
    modifier onlyIfUpgradeabilityOwner() {
        require(msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner());
        /* solcov ignore next */
        _;
    }
}

// File: contracts/upgradeability/EternalStorage.sol

pragma solidity 0.4.24;

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

// File: contracts/upgradeable_contracts/Initializable.sol

pragma solidity 0.4.24;


contract Initializable is EternalStorage {
    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {
        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {
        return boolStorage[INITIALIZED];
    }
}

// File: contracts/upgradeable_contracts/InitializableBridge.sol

pragma solidity 0.4.24;


contract InitializableBridge is Initializable {
    bytes32 internal constant DEPLOYED_AT_BLOCK = 0xb120ceec05576ad0c710bc6e85f1768535e27554458f05dcbb5c65b8c7a749b0; // keccak256(abi.encodePacked("deployedAtBlock"))

    function deployedAtBlock() external view returns (uint256) {
        return uintStorage[DEPLOYED_AT_BLOCK];
    }
}

// File: openzeppelin-solidity/contracts/AddressUtils.sol

pragma solidity ^0.4.24;


/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

// File: contracts/upgradeable_contracts/ValidatorStorage.sol

pragma solidity 0.4.24;

contract ValidatorStorage {
    bytes32 internal constant VALIDATOR_CONTRACT = 0x5a74bb7e202fb8e4bf311841c7d64ec19df195fee77d7e7ae749b27921b6ddfe; // keccak256(abi.encodePacked("validatorContract"))
}

// File: contracts/upgradeable_contracts/Validatable.sol

pragma solidity 0.4.24;




contract Validatable is EternalStorage, ValidatorStorage {
    function validatorContract() public view returns (IBridgeValidators) {
        return IBridgeValidators(addressStorage[VALIDATOR_CONTRACT]);
    }

    modifier onlyValidator() {
        require(validatorContract().isValidator(msg.sender));
        /* solcov ignore next */
        _;
    }

    function requiredSignatures() public view returns (uint256) {
        return validatorContract().requiredSignatures();
    }

}

// File: contracts/upgradeable_contracts/Ownable.sol

pragma solidity 0.4.24;



/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable is EternalStorage {
    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

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
        /* solcov ignore next */
        _;
    }

    /**
    * @dev Throws if called by any account other than contract itself or owner.
    */
    modifier onlyRelevantSender() {
        // proxy owner if used through proxy, address(0) otherwise
        require(
            !address(this).call(abi.encodeWithSelector(UPGRADEABILITY_OWNER)) || // covers usage without calling through storage proxy
                msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner() || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        /* solcov ignore next */
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return addressStorage[OWNER];
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/upgradeable_contracts/Sacrifice.sol

pragma solidity 0.4.24;

contract Sacrifice {
    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}

// File: contracts/libraries/Address.sol

pragma solidity 0.4.24;


/**
 * @title Address
 * @dev Helper methods for Address type.
 */
library Address {
    /**
    * @dev Try to send native tokens to the address. If it fails, it will force the transfer by creating a selfdestruct contract
    * @param _receiver address that will receive the native tokens
    * @param _value the amount of native tokens to send
    */
    function safeSendValue(address _receiver, uint256 _value) internal {
        if (!_receiver.send(_value)) {
            (new Sacrifice).value(_value)(_receiver);
        }
    }
}

// File: contracts/upgradeable_contracts/Claimable.sol

pragma solidity 0.4.24;



contract Claimable {
    bytes4 internal constant TRANSFER = 0xa9059cbb; // transfer(address,uint256)

    modifier validAddress(address _to) {
        require(_to != address(0));
        /* solcov ignore next */
        _;
    }

    function claimValues(address _token, address _to) internal {
        if (_token == address(0)) {
            claimNativeCoins(_to);
        } else {
            claimErc20Tokens(_token, _to);
        }
    }

    function claimNativeCoins(address _to) internal {
        uint256 value = address(this).balance;
        Address.safeSendValue(_to, value);
    }

    function claimErc20Tokens(address _token, address _to) internal {
        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        safeTransfer(_token, _to, balance);
    }

    function safeTransfer(address _token, address _to, uint256 _value) internal {
        bytes memory returnData;
        bool returnDataResult;
        bytes memory callData = abi.encodeWithSelector(TRANSFER, _to, _value);
        assembly {
            let result := call(gas, _token, 0x0, add(callData, 0x20), mload(callData), 0, 32)
            returnData := mload(0)
            returnDataResult := mload(0)

            switch result
                case 0 {
                    revert(0, 0)
                }
        }

        // Return data is optional
        if (returnData.length > 0) {
            require(returnDataResult);
        }
    }
}

// File: contracts/upgradeable_contracts/VersionableBridge.sol

pragma solidity 0.4.24;

contract VersionableBridge {
    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (5, 0, 0);
    }

    /* solcov ignore next */
    function getBridgeMode() external pure returns (bytes4);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/upgradeable_contracts/DecimalShiftBridge.sol

pragma solidity 0.4.24;



contract DecimalShiftBridge is EternalStorage {
    using SafeMath for uint256;

    bytes32 internal constant DECIMAL_SHIFT = 0x1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee5; // keccak256(abi.encodePacked("decimalShift"))

    /**
    * @dev Internal function for setting the decimal shift for bridge operations.
    * Decimal shift can be positive, negative, or equal to zero.
    * It has the following meaning: N tokens in the foreign chain are equivalent to N * pow(10, shift) tokens on the home side.
    * @param _shift new value of decimal shift.
    */
    function _setDecimalShift(int256 _shift) internal {
        // since 1 wei * 10**77 > 2**255, it does not make any sense to use higher values
        require(_shift > -77 && _shift < 77);
        uintStorage[DECIMAL_SHIFT] = uint256(_shift);
    }

    /**
    * @dev Returns the value of foreign-to-home decimal shift.
    * @return decimal shift.
    */
    function decimalShift() public view returns (int256) {
        return int256(uintStorage[DECIMAL_SHIFT]);
    }

    /**
    * @dev Converts the amount of home tokens into the equivalent amount of foreign tokens.
    * @param _value amount of home tokens.
    * @return equivalent amount of foreign tokens.
    */
    function _unshiftValue(uint256 _value) internal view returns (uint256) {
        return _shiftUint(_value, -decimalShift());
    }

    /**
    * @dev Converts the amount of foreign tokens into the equivalent amount of home tokens.
    * @param _value amount of foreign tokens.
    * @return equivalent amount of home tokens.
    */
    function _shiftValue(uint256 _value) internal view returns (uint256) {
        return _shiftUint(_value, decimalShift());
    }

    /**
    * @dev Calculates _value * pow(10, _shift).
    * @param _value amount of tokens.
    * @param _shift decimal shift to apply.
    * @return shifted value.
    */
    function _shiftUint(uint256 _value, int256 _shift) private pure returns (uint256) {
        if (_shift == 0) {
            return _value;
        }
        if (_shift > 0) {
            return _value.mul(10**uint256(_shift));
        }
        return _value.div(10**uint256(-_shift));
    }
}

// File: contracts/upgradeable_contracts/BasicBridge.sol

pragma solidity 0.4.24;









contract BasicBridge is
    InitializableBridge,
    Validatable,
    Ownable,
    Upgradeable,
    Claimable,
    VersionableBridge,
    DecimalShiftBridge
{
    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    bytes32 internal constant GAS_PRICE = 0x55b3774520b5993024893d303890baa4e84b1244a43c60034d1ced2d3cf2b04b; // keccak256(abi.encodePacked("gasPrice"))
    bytes32 internal constant REQUIRED_BLOCK_CONFIRMATIONS = 0x916daedf6915000ff68ced2f0b6773fe6f2582237f92c3c95bb4d79407230071; // keccak256(abi.encodePacked("requiredBlockConfirmations"))

    /**
    * @dev Public setter for fallback gas price value. Only bridge owner can call this method.
    * @param _gasPrice new value for the gas price.
    */
    function setGasPrice(uint256 _gasPrice) external onlyOwner {
        _setGasPrice(_gasPrice);
    }

    function gasPrice() external view returns (uint256) {
        return uintStorage[GAS_PRICE];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) external onlyOwner {
        _setRequiredBlockConfirmations(_blockConfirmations);
    }

    function _setRequiredBlockConfirmations(uint256 _blockConfirmations) internal {
        require(_blockConfirmations > 0);
        uintStorage[REQUIRED_BLOCK_CONFIRMATIONS] = _blockConfirmations;
        emit RequiredBlockConfirmationChanged(_blockConfirmations);
    }

    function requiredBlockConfirmations() external view returns (uint256) {
        return uintStorage[REQUIRED_BLOCK_CONFIRMATIONS];
    }

    function claimTokens(address _token, address _to) public onlyIfUpgradeabilityOwner validAddress(_to) {
        claimValues(_token, _to);
    }

    /**
    * @dev Internal function for updating fallback gas price value.
    * @param _gasPrice new value for the gas price, zero gas price is allowed.
    */
    function _setGasPrice(uint256 _gasPrice) internal {
        uintStorage[GAS_PRICE] = _gasPrice;
        emit GasPriceChanged(_gasPrice);
    }
}

// File: contracts/upgradeable_contracts/arbitrary_message/VersionableAMB.sol

pragma solidity 0.4.24;


contract VersionableAMB is VersionableBridge {
    // message format version as a single 4-bytes number padded to 32-bytes
    // value, included into every outgoing relay request
    //
    // the message version should be updated every time when
    // - new field appears
    // - some field removed
    // - fields order is changed
    bytes32 internal constant MESSAGE_PACKING_VERSION = 0x00050000 << 224;

    /**
     * Returns currently used bridge version
     * @return (major, minor, patch) version triple
     */
    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (5, 3, 0);
    }
}

// File: contracts/upgradeable_contracts/arbitrary_message/BasicAMB.sol

pragma solidity 0.4.24;



contract BasicAMB is BasicBridge, VersionableAMB {
    bytes32 internal constant MAX_GAS_PER_TX = 0x2670ecc91ec356e32067fd27b36614132d727b84a1e03e08f412a4f2cf075974; // keccak256(abi.encodePacked("maxGasPerTx"))
    bytes32 internal constant NONCE = 0x7ab1577440dd7bedf920cb6de2f9fc6bf7ba98c78c85a3fa1f8311aac95e1759; // keccak256(abi.encodePacked("nonce"))
    bytes32 internal constant SOURCE_CHAIN_ID = 0x67d6f42a1ed69c62022f2d160ddc6f2f0acd37ad1db0c24f4702d7d3343a4add; // keccak256(abi.encodePacked("sourceChainId"))
    bytes32 internal constant SOURCE_CHAIN_ID_LENGTH = 0xe504ae1fd6471eea80f18b8532a61a9bb91fba4f5b837f80a1cfb6752350af44; // keccak256(abi.encodePacked("sourceChainIdLength"))
    bytes32 internal constant DESTINATION_CHAIN_ID = 0xbbd454018e72a3f6c02bbd785bacc49e46292744f3f6761276723823aa332320; // keccak256(abi.encodePacked("destinationChainId"))
    bytes32 internal constant DESTINATION_CHAIN_ID_LENGTH = 0xfb792ae4ad11102b93f26a51b3749c2b3667f8b561566a4806d4989692811594; // keccak256(abi.encodePacked("destinationChainIdLength"))

    /**
     * Initializes AMB contract
     * @param _sourceChainId chain id of a network where this contract is deployed
     * @param _destinationChainId chain id of a network where all outgoing messages are directed
     * @param _validatorContract address of the validators contract
     * @param _maxGasPerTx maximum amount of gas per one message execution
     * @param _gasPrice default gas price used by oracles for sending transactions in this network
     * @param _requiredBlockConfirmations number of block confirmations oracle will wait before processing passed messages
     * @param _owner address of new bridge owner
     */
    function initialize(
        uint256 _sourceChainId,
        uint256 _destinationChainId,
        address _validatorContract,
        uint256 _maxGasPerTx,
        uint256 _gasPrice,
        uint256 _requiredBlockConfirmations,
        address _owner
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());
        require(AddressUtils.isContract(_validatorContract));

        _setChainIds(_sourceChainId, _destinationChainId);
        addressStorage[VALIDATOR_CONTRACT] = _validatorContract;
        uintStorage[DEPLOYED_AT_BLOCK] = block.number;
        uintStorage[MAX_GAS_PER_TX] = _maxGasPerTx;
        _setGasPrice(_gasPrice);
        _setRequiredBlockConfirmations(_requiredBlockConfirmations);
        setOwner(_owner);
        setInitialize();

        return isInitialized();
    }

    function getBridgeMode() external pure returns (bytes4 _data) {
        return 0x2544fbb9; // bytes4(keccak256(abi.encodePacked("arbitrary-message-bridge-core")))
    }

    function maxGasPerTx() public view returns (uint256) {
        return uintStorage[MAX_GAS_PER_TX];
    }

    function setMaxGasPerTx(uint256 _maxGasPerTx) external onlyOwner {
        uintStorage[MAX_GAS_PER_TX] = _maxGasPerTx;
    }

    /**
     * Internal function for retrieving chain id for the source network
     * @return chain id for the current network
     */
    function sourceChainId() public view returns (uint256) {
        return uintStorage[SOURCE_CHAIN_ID];
    }

    /**
     * Internal function for retrieving chain id for the destination network
     * @return chain id for the destination network
     */
    function destinationChainId() public view returns (uint256) {
        return uintStorage[DESTINATION_CHAIN_ID];
    }

    /**
     * Updates chain ids of used networks
     * @param _sourceChainId chain id for current network
     * @param _destinationChainId chain id for opposite network
     */
    function setChainIds(uint256 _sourceChainId, uint256 _destinationChainId) external onlyOwner {
        _setChainIds(_sourceChainId, _destinationChainId);
    }

    /**
     * Internal function for retrieving current nonce value
     * @return nonce value
     */
    function _nonce() internal view returns (uint64) {
        return uint64(uintStorage[NONCE]);
    }

    /**
     * Internal function for updating nonce value
     * @param _nonce new nonce value
     */
    function _setNonce(uint64 _nonce) internal {
        uintStorage[NONCE] = uint256(_nonce);
    }

    /**
     * Internal function for updating chain ids of used networks
     * @param _sourceChainId chain id for current network
     * @param _destinationChainId chain id for opposite network
     */
    function _setChainIds(uint256 _sourceChainId, uint256 _destinationChainId) internal {
        require(_sourceChainId > 0 && _destinationChainId > 0);
        require(_sourceChainId != _destinationChainId);
        uint256 sourceChainIdLength = 0;
        uint256 destinationChainIdLength = 0;
        uint256 mask = 0xff;

        for (uint256 i = 1; sourceChainIdLength == 0 || destinationChainIdLength == 0; i++) {
            if (sourceChainIdLength == 0 && _sourceChainId & mask == _sourceChainId) {
                sourceChainIdLength = i;
            }
            if (destinationChainIdLength == 0 && _destinationChainId & mask == _destinationChainId) {
                destinationChainIdLength = i;
            }
            mask = (mask << 8) | 0xff;
        }

        uintStorage[SOURCE_CHAIN_ID] = _sourceChainId;
        uintStorage[SOURCE_CHAIN_ID_LENGTH] = sourceChainIdLength;
        uintStorage[DESTINATION_CHAIN_ID] = _destinationChainId;
        uintStorage[DESTINATION_CHAIN_ID_LENGTH] = destinationChainIdLength;
    }

    /**
     * Internal function for retrieving chain id length for the source network
     * @return chain id for the current network
     */
    function _sourceChainIdLength() internal view returns (uint256) {
        return uintStorage[SOURCE_CHAIN_ID_LENGTH];
    }

    /**
     * Internal function for retrieving chain id length for the destination network
     * @return chain id for the destination network
     */
    function _destinationChainIdLength() internal view returns (uint256) {
        return uintStorage[DESTINATION_CHAIN_ID_LENGTH];
    }

    /**
     * Internal function for validating version of the received message
     * @param _messageId id of the received message
     */
    function _isMessageVersionValid(bytes32 _messageId) internal returns (bool) {
        return
            _messageId & 0xffffffff00000000000000000000000000000000000000000000000000000000 == MESSAGE_PACKING_VERSION;
    }

    /**
     * Internal function for validating destination chain id of the received message
     * @param _chainId destination chain id of the received message
     */
    function _isDestinationChainIdValid(uint256 _chainId) internal returns (bool res) {
        return _chainId == sourceChainId();
    }
}

// File: contracts/libraries/Bytes.sol

pragma solidity 0.4.24;

/**
 * @title Bytes
 * @dev Helper methods to transform bytes to other solidity types.
 */
library Bytes {
    /**
    * @dev Converts bytes array to bytes32.
    * Truncates bytes array if its size is more than 32 bytes.
    * NOTE: This function does not perform any checks on the received parameter.
    * Make sure that the _bytes argument has a correct length, not less than 32 bytes.
    * A case when _bytes has length less than 32 will lead to the undefined behaviour,
    * since assembly will read data from memory that is not related to the _bytes argument.
    * @param _bytes to be converted to bytes32 type
    * @return bytes32 type of the firsts 32 bytes array in parameter.
    */
    function bytesToBytes32(bytes _bytes) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(_bytes, 32))
        }
    }

    /**
    * @dev Truncate bytes array if its size is more than 20 bytes.
    * NOTE: Similar to the bytesToBytes32 function, make sure that _bytes is not shorter than 20 bytes.
    * @param _bytes to be converted to address type
    * @return address included in the firsts 20 bytes of the bytes array in parameter.
    */
    function bytesToAddress(bytes _bytes) internal pure returns (address addr) {
        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}

// File: contracts/upgradeable_contracts/arbitrary_message/MessageProcessor.sol

pragma solidity 0.4.24;



contract MessageProcessor is EternalStorage {
    bytes32 internal constant MESSAGE_SENDER = 0x7b58b2a669d8e0992eae9eaef641092c0f686fd31070e7236865557fa1571b5b; // keccak256(abi.encodePacked("messageSender"))
    bytes32 internal constant MESSAGE_ID = 0xe34bb2103dc34f2c144cc216c132d6ffb55dac57575c22e089161bbe65083304; // keccak256(abi.encodePacked("messageId"))
    bytes32 internal constant MESSAGE_SOURCE_CHAIN_ID = 0x7f0fcd9e49860f055dd0c1682d635d309ecb5e3011654c716d9eb59a7ddec7d2; // keccak256(abi.encodePacked("messageSourceChainId"))

    /**
    * @dev Returns a status of the message that came from the other side.
    * @param _messageId id of the message from the other side that triggered a call.
    * @return true if call executed successfully.
    */
    function messageCallStatus(bytes32 _messageId) external view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageCallStatus", _messageId))];
    }

    /**
    * @dev Sets a status of the message that came from the other side.
    * @param _messageId id of the message from the other side that triggered a call.
    * @param _status execution status, true if executed successfully.
    */
    function setMessageCallStatus(bytes32 _messageId, bool _status) internal {
        boolStorage[keccak256(abi.encodePacked("messageCallStatus", _messageId))] = _status;
    }

    /**
    * @dev Returns a data hash of the failed message that came from the other side.
    * NOTE: dataHash was used previously to identify outgoing message before AMB message id was introduced.
    * It is kept for backwards compatibility with old mediators contracts.
    * @param _messageId id of the message from the other side that triggered a call.
    * @return keccak256 hash of message data.
    */
    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32) {
        return bytes32(uintStorage[keccak256(abi.encodePacked("failedMessageDataHash", _messageId))]);
    }

    /**
    * @dev Sets a data hash of the failed message that came from the other side.
    * NOTE: dataHash was used previously to identify outgoing message before AMB message id was introduced.
    * It is kept for backwards compatibility with old mediators contracts.
    * @param _messageId id of the message from the other side that triggered a call.
    * @param data of the processed message.
    */
    function setFailedMessageDataHash(bytes32 _messageId, bytes data) internal {
        uintStorage[keccak256(abi.encodePacked("failedMessageDataHash", _messageId))] = uint256(keccak256(data));
    }

    /**
    * @dev Returns a receiver address of the failed message that came from the other side.
    * @param _messageId id of the message from the other side that triggered a call.
    * @return receiver address.
    */
    function failedMessageReceiver(bytes32 _messageId) external view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("failedMessageReceiver", _messageId))];
    }

    /**
    * @dev Sets a sender address of the failed message that came from the other side.
    * @param _messageId id of the message from the other side that triggered a call.
    * @param _receiver address of the receiver.
    */
    function setFailedMessageReceiver(bytes32 _messageId, address _receiver) internal {
        addressStorage[keccak256(abi.encodePacked("failedMessageReceiver", _messageId))] = _receiver;
    }

    /**
    * @dev Returns a sender address of the failed message that came from the other side.
    * @param _messageId id of the message from the other side that triggered a call.
    * @return sender address on the other side.
    */
    function failedMessageSender(bytes32 _messageId) external view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("failedMessageSender", _messageId))];
    }

    /**
    * @dev Sets a sender address of the failed message that came from the other side.
    * @param _messageId id of the message from the other side that triggered a call.
    * @param _sender address of the sender on the other side.
    */
    function setFailedMessageSender(bytes32 _messageId, address _sender) internal {
        addressStorage[keccak256(abi.encodePacked("failedMessageSender", _messageId))] = _sender;
    }

    /**
    * @dev Returns an address of the sender on the other side for the currently processed message.
    * Can be used by executors for getting other side caller address.
    * @return address of the sender on the other side.
    */
    function messageSender() external view returns (address) {
        return addressStorage[MESSAGE_SENDER];
    }

    /**
    * @dev Sets an address of the sender on the other side for the currently processed message.
    * @param _sender address of the sender on the other side.
    */
    function setMessageSender(address _sender) internal {
        addressStorage[MESSAGE_SENDER] = _sender;
    }

    /**
    * @dev Returns an id of the currently processed message.
    * @return id of the message that originated on the other side.
    */
    function messageId() public view returns (bytes32) {
        return bytes32(uintStorage[MESSAGE_ID]);
    }

    /**
    * @dev Returns an id of the currently processed message.
    * NOTE: transactionHash was used previously to identify incoming message before AMB message id was introduced.
    * It is kept for backwards compatibility with old mediators contracts, although it doesn't return txHash anymore.
    * @return id of the message that originated on the other side.
    */
    function transactionHash() external view returns (bytes32) {
        return messageId();
    }

    /**
    * @dev Sets a message id of the currently processed message.
    * @param _messageId id of the message that originated on the other side.
    */
    function setMessageId(bytes32 _messageId) internal {
        uintStorage[MESSAGE_ID] = uint256(_messageId);
    }

    /**
    * @dev Returns an originating chain id of the currently processed message.
    * @return source chain id of the message that originated on the other side.
    */
    function messageSourceChainId() external view returns (uint256) {
        return uintStorage[MESSAGE_SOURCE_CHAIN_ID];
    }

    /**
    * @dev Returns an originating chain id of the currently processed message.
    * @return source chain id of the message that originated on the other side.
    */
    function setMessageSourceChainId(uint256 _sourceChainId) internal returns (uint256) {
        uintStorage[MESSAGE_SOURCE_CHAIN_ID] = _sourceChainId;
    }

    /**
    * @dev Processes received message. Makes a call to the message executor,
    * sets dataHash, receive, sender variables for failed messages.
    * @param _sender sender address on the other side.
    * @param _executor address of an executor.
    * @param _messageId id of the processed message.
    * @param _gasLimit gas limit for a call to executor.
    * @param _sourceChainId source chain id is of the received message.
    * @param _data calldata for a call to executor.
    */
    function processMessage(
        address _sender,
        address _executor,
        bytes32 _messageId,
        uint256 _gasLimit,
        bytes1, /* dataType */
        uint256, /* gasPrice */
        uint256 _sourceChainId,
        bytes memory _data
    ) internal {
        bool status = _passMessage(_sender, _executor, _data, _gasLimit, _messageId, _sourceChainId);

        setMessageCallStatus(_messageId, status);
        if (!status) {
            setFailedMessageDataHash(_messageId, _data);
            setFailedMessageReceiver(_messageId, _executor);
            setFailedMessageSender(_messageId, _sender);
        }
        emitEventOnMessageProcessed(_sender, _executor, _messageId, status);
    }

    /**
    * @dev Makes a call to the message executor.
    * @param _sender sender address on the other side.
    * @param _contract address of an executor contract.
    * @param _data calldata for a call to executor.
    * @param _gas gas limit for a call to executor.
    * @param _messageId id of the processed message.
    * @param _sourceChainId source chain id is of the received message.
    */
    function _passMessage(
        address _sender,
        address _contract,
        bytes _data,
        uint256 _gas,
        bytes32 _messageId,
        uint256 _sourceChainId
    ) internal returns (bool) {
        setMessageSender(_sender);
        setMessageId(_messageId);
        setMessageSourceChainId(_sourceChainId);
        bool status = _contract.call.gas(_gas)(_data);
        setMessageSender(address(0));
        setMessageId(bytes32(0));
        setMessageSourceChainId(0);
        return status;
    }

    /* solcov ignore next */
    function emitEventOnMessageProcessed(address sender, address executor, bytes32 messageId, bool status) internal;
}

// File: contracts/upgradeable_contracts/arbitrary_message/MessageDelivery.sol

pragma solidity 0.4.24;






contract MessageDelivery is BasicAMB, MessageProcessor {
    using SafeMath for uint256;

    /**
    * @dev Requests message relay to the opposite network
    * @param _contract executor address on the other side
    * @param _data calldata passed to the executor on the other side
    * @param _gas gas limit used on the other network for executing a message
    */
    function requireToPassMessage(address _contract, bytes _data, uint256 _gas) public returns (bytes32) {
        // it is not allowed to pass messages while other messages are processed
        require(messageId() == bytes32(0));

        require(_gas >= getMinimumGasUsage(_data) && _gas <= maxGasPerTx());

        bytes32 _messageId;
        bytes memory header = _packHeader(_contract, _gas);
        _setNonce(_nonce() + 1);

        assembly {
            _messageId := mload(add(header, 32))
        }

        bytes memory eventData = abi.encodePacked(header, _data);

        emitEventOnMessageRequest(_messageId, eventData);
        return _messageId;
    }

    /**
    * @dev Returns a lower limit on gas limit for the particular message data
    * @param _data calldata passed to the executor on the other side
    */
    function getMinimumGasUsage(bytes _data) public pure returns (uint256 gas) {
        // From Ethereum Yellow Paper
        // 68 gas is paid for every non-zero byte of data or code for a transaction
        // Starting from Istanbul hardfork, 16 gas is paid (EIP-2028)
        return _data.length.mul(16);
    }

    /**
    * @dev Packs message header into a single bytes blob
    * @param _contract executor address on the other side
    * @param _gas gas limit used on the other network for executing a message
    */
    function _packHeader(address _contract, uint256 _gas) internal view returns (bytes memory header) {
        uint256 srcChainId = sourceChainId();
        uint256 srcChainIdLength = _sourceChainIdLength();
        uint256 dstChainId = destinationChainId();
        uint256 dstChainIdLength = _destinationChainIdLength();

        bytes32 mVer = MESSAGE_PACKING_VERSION;
        uint256 nonce = _nonce();

        // Bridge id is recalculated every time again and again, since it is still cheaper than using SLOAD opcode (800 gas)
        bytes32 bridgeId = keccak256(abi.encodePacked(srcChainId, address(this))) &
            0x00000000ffffffffffffffffffffffffffffffffffffffff0000000000000000;
        // 79 = 4 + 20 + 8 + 20 + 20 + 4 + 1 + 1 + 1
        header = new bytes(79 + srcChainIdLength + dstChainIdLength);

        // In order to save the gas, the header is packed in the reverse order.
        // With such approach, it is possible to store right-aligned values without any additional bit shifts.
        assembly {
            let ptr := add(header, mload(header)) // points to the last word of header
            mstore(ptr, dstChainId)
            mstore(sub(ptr, dstChainIdLength), srcChainId)

            mstore(add(header, 79), 0x00)
            mstore(add(header, 78), dstChainIdLength)
            mstore(add(header, 77), srcChainIdLength)
            mstore(add(header, 76), _gas)
            mstore(add(header, 72), _contract)
            mstore(add(header, 52), caller)

            mstore(add(header, 32), or(mVer, or(bridgeId, nonce)))
        }
    }

    /* solcov ignore next */
    function emitEventOnMessageRequest(bytes32 messageId, bytes encodedData) internal;
}

// File: contracts/upgradeable_contracts/MessageRelay.sol

pragma solidity 0.4.24;


contract MessageRelay is EternalStorage {
    function relayedMessages(bytes32 _txHash) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))];
    }

    function setRelayedMessages(bytes32 _txHash, bool _status) internal {
        boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))] = _status;
    }
}

// File: contracts/upgradeable_contracts/arbitrary_message/BasicForeignAMB.sol

pragma solidity 0.4.24;






contract BasicForeignAMB is BasicAMB, MessageRelay, MessageDelivery {
    /**
    * @dev Validates provided signatures and relays a given message
    * @param _data bytes to be relayed
    * @param _signatures bytes blob with signatures to be validated
    */
    function executeSignatures(bytes _data, bytes _signatures) external {
        Message.hasEnoughValidSignatures(_data, _signatures, validatorContract(), true);

        bytes32 messageId;
        address sender;
        address executor;
        uint32 gasLimit;
        bytes1 dataType;
        uint256[2] memory chainIds;
        uint256 gasPrice;
        bytes memory data;

        (messageId, sender, executor, gasLimit, dataType, chainIds, gasPrice, data) = ArbitraryMessage.unpackData(
            _data
        );
        require(_isMessageVersionValid(messageId));
        require(_isDestinationChainIdValid(chainIds[1]));
        require(!relayedMessages(messageId));
        setRelayedMessages(messageId, true);
        processMessage(sender, executor, messageId, gasLimit, dataType, gasPrice, chainIds[0], data);
    }

    /**
    * @dev Internal function for updating fallback gas price value.
    * @param _gasPrice new value for the gas price, zero gas price is not allowed.
    */
    function _setGasPrice(uint256 _gasPrice) internal {
        require(_gasPrice > 0);
        super._setGasPrice(_gasPrice);
    }
}

// File: contracts/upgradeable_contracts/arbitrary_message/ForeignAMB.sol

pragma solidity 0.4.24;


contract ForeignAMB is BasicForeignAMB {
    event UserRequestForAffirmation(bytes32 indexed messageId, bytes encodedData);
    event RelayedMessage(address indexed sender, address indexed executor, bytes32 indexed messageId, bool status);

    function emitEventOnMessageRequest(bytes32 messageId, bytes encodedData) internal {
        emit UserRequestForAffirmation(messageId, encodedData);
    }

    function emitEventOnMessageProcessed(address sender, address executor, bytes32 messageId, bool status) internal {
        emit RelayedMessage(sender, executor, messageId, status);
    }
}