/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

/**
Author: Authereum Labs, Inc.
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * This contract is from openzeppelin-solidity 2.4.0
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract IERC1271 {
    function isValidSignature(
        bytes32 _messageHash,
        bytes memory _signature
    ) public view returns (bytes4 magicValue);

    function isValidSignature(
        bytes memory _data,
        bytes memory _signature
    ) public view returns (bytes4 magicValue);
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 *
 * This contract is from openzeppelin-solidity 2.4.0
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);
}

/**
    Note: The ERC-165 identifier for this interface is 0x4e2312e0.
*/
interface IERC1155TokenReceiver {
    /**
        @notice Handle the receipt of a single ERC1155 token type.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
        This function MUST return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` (i.e. 0xf23a6e61) if it accepts the transfer.
        This function MUST revert if it rejects the transfer.
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being transferred
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    /**
        @notice Handle the receipt of multiple ERC1155 token types.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
        This function MUST return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` (i.e. 0xbc197c81) if it accepts the transfer(s).
        This function MUST revert if it rejects the transfer(s).
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the batch transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _ids       An array containing ids of each token being transferred (order and length must match _values array)
        @param _values    An array containing amounts of each token being transferred (order and length must match _ids array)
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    */
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}

interface IERC1820ImplementerInterface {
    /// @notice Indicates whether the contract implements the interface `interfaceHash` for the address `addr` or not.
    /// @param interfaceHash keccak256 hash of the name of the interface
    /// @param addr Address for which the contract will implement the interface
    /// @return ERC1820_ACCEPT_MAGIC only if the contract implements `interfaceHash` for the address `addr`.
    function canImplementInterfaceForAddress(bytes32 interfaceHash, address addr) external view returns(bytes32);
}

contract IERC777TokensRecipient {
    /// @dev Notify a send or mint (if from is 0x0) of amount tokens from the from address to the
    ///      to address by the operator address.
    /// @param operator Address which triggered the balance increase (through sending or minting).
    /// @param from Holder whose tokens were sent (or 0x0 for a mint).
    /// @param to Recipient of the tokens.
    /// @param amount Number of tokens the recipient balance is increased by.
    /// @param data Information provided by the holder.
    /// @param operatorData Information provided by the operator.
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;
}

contract IAuthereumAccount is IERC1271, IERC721Receiver, IERC1155TokenReceiver, IERC1820ImplementerInterface, IERC777TokensRecipient {
    function () external payable;
    function name() external view returns (string memory);
    function version() external view returns (string memory);
    function implementation() external view returns (address);
    function lastInitializedVersion() external returns (uint256);
    function authKeys(address _authKey) external returns (bool);
    function nonce() external returns (uint256);
    function numAuthKeys() external returns (uint256);
    function getChainId() external pure returns (uint256);
    function addAuthKey(address _authKey) external;
    function upgradeToAndCall(address _newImplementation, bytes calldata _data) external;
    function removeAuthKey(address _authKey) external;
    function isValidAuthKeySignature(bytes32 _messageHash, bytes calldata _signature) external view returns (bool);
    function isValidLoginKeySignature(bytes32 _messageHash, bytes calldata _signature) external view returns (bool);
    function executeMultipleTransactions(bytes[] calldata _transactions) external returns (bytes[] memory);
    function executeMultipleMetaTransactions(bytes[] calldata _transactions) external returns (bytes[] memory);

    function executeMultipleAuthKeyMetaTransactions(
        bytes[] calldata _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes calldata _transactionMessageHashSignature
    ) external returns (bytes[] memory);

    function executeMultipleLoginKeyMetaTransactions(
        bytes[] calldata _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        bytes calldata _loginKeyRestrictionsData,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes calldata _transactionMessageHashSignature,
        bytes calldata _loginKeyAttestationSignature
    ) external returns (bytes[] memory);
}

/**
 * @title AuthereumRecoveryModule
 * @author Authereum Labs, Inc.
 * @dev This contract facilitates the recovery of Authereum accounts.
 * @dev This contract may be added as a module for an Authereum account. The Authereum
 * @dev account may set one or more recovery addresses and specify a recovery delay period.
 * @dev A recovery address may start the recovery process at any time and specify a new auth
 * @dev key to be added to the Authereum account. During the recovery delay period, the
 * @dev recovery process can be cancelled by the Authereum account. After the recovery delay
 * @dev period, any address can complete the recovery process which will add the new auth key
 * @dev to the Authereum account.
 */
contract AuthereumRecoveryModule {
    using SafeMath for uint256;

    string constant public name = "Authereum Recovery Module";
    string constant public version = "2020070100";

    /**
     * Events
     */

    event RecoveryAddressAdded (
        address indexed accountContract,
        address indexed recoveryAddress,
        uint256 indexed recoveryDelay
    );

    event RecoveryAddressRemoved (
        address indexed accountContract,
        address indexed recoveryAddress
    );

    event RecoveryStarted (
        address indexed accountContract,
        address indexed recoveryAddress,
        address indexed newAuthKey,
        uint256 startTime,
        uint256 recoveryDelay
    );

    event RecoveryCancelled (
        address indexed accountContract,
        address indexed recoveryAddress,
        address indexed newAuthKey
    );

    event RecoveryCompleted (
        address indexed accountContract,
        address indexed recoveryAddress,
        address indexed newAuthKey
    );

    /**
     * State
     */

    struct RecoveryAccount {
        bool active;
        uint256 delay;
    }

    struct RecoveryAttempt {
        uint256 startTime;
        address newAuthKey;
    }

    mapping(address => mapping(address => RecoveryAccount)) public recoveryAccounts;
    mapping(address => mapping(address => RecoveryAttempt)) public recoveryAttempts;

    /**
     * Modifiers
     */

    modifier isRecoveryAddress(address _accountContract, address _recoveryAddress) {
        require(recoveryAccounts[_accountContract][_recoveryAddress].active, "ARM: Inactive recovery account");
        _;
    }

    modifier onlyWhenRegisteredModule {
        require(IAuthereumAccount(msg.sender).authKeys(address(this)), "ARM: Recovery module not registered to account");
        _;
    }

    /**
     *  Public functions
     */

    /// @dev Add a recovery address
    /// @dev Called by the Authereum account
    /// @param _recoveryAddress The address that can recover the account
    /// @param _recoveryDelay The delay required between starting and completing recovery
    function addRecoveryAccount(address _recoveryAddress, uint256 _recoveryDelay) external onlyWhenRegisteredModule {
        require(_recoveryAddress != address(0), "ARM: Recovery address cannot be address(0)");
        require(_recoveryAddress != msg.sender, "ARM: Cannot add self as recovery account");
        require(recoveryAccounts[msg.sender][_recoveryAddress].active == false, "ARM: Recovery address has already been added");
        recoveryAccounts[msg.sender][_recoveryAddress] = RecoveryAccount(true, _recoveryDelay);

        emit RecoveryAddressAdded(msg.sender, _recoveryAddress, _recoveryDelay);
    }

    /// @dev Remove a recovery address
    /// @dev Called by the Authereum account
    /// @param _recoveryAddress The address that can recover the account
    function removeRecoveryAccount(address _recoveryAddress) external {
        require(recoveryAccounts[msg.sender][_recoveryAddress].active == true, "ARM: Recovery address is already inactive");
        delete recoveryAccounts[msg.sender][_recoveryAddress];

        RecoveryAttempt storage recoveryAttempt = recoveryAttempts[msg.sender][_recoveryAddress];
        if (recoveryAttempt.startTime != 0) {
            emit RecoveryCancelled(msg.sender, _recoveryAddress, recoveryAttempt.newAuthKey);
        }
        delete recoveryAttempts[msg.sender][_recoveryAddress];

        emit RecoveryAddressRemoved(msg.sender, _recoveryAddress);
    }

    /// @dev Start the recovery process
    /// @dev Called by the recovery address
    /// @param _accountContract Address of the Authereum account being recovered
    /// @param _newAuthKey The address of the Auth Key being added to the Authereum account
    function startRecovery(address _accountContract, address _newAuthKey) external isRecoveryAddress(_accountContract, msg.sender) {
        require(recoveryAttempts[_accountContract][msg.sender].startTime == 0, "ARM: Recovery is already in process");
        require(_newAuthKey != address(0), "ARM: Auth Key cannot be address(0)");

        recoveryAttempts[_accountContract][msg.sender] = RecoveryAttempt(now, _newAuthKey);

        uint256 recoveryDelay = recoveryAccounts[_accountContract][msg.sender].delay;
        emit RecoveryStarted(_accountContract, msg.sender, _newAuthKey, now, recoveryDelay);
    }

    /// @dev Cancel the recovery process
    /// @dev Called by the recovery address
    /// @param _accountContract Address of the Authereum account being recovered
    function cancelRecovery(address _accountContract) external isRecoveryAddress(_accountContract, msg.sender) {
        RecoveryAttempt memory recoveryAttempt = recoveryAttempts[_accountContract][msg.sender];

        require(recoveryAttempt.startTime != 0, "ARM: Recovery attempt does not exist");

        delete recoveryAttempts[_accountContract][msg.sender];

        emit RecoveryCancelled(_accountContract, msg.sender, recoveryAttempt.newAuthKey);
    }

    /// @dev Complete the recovery process
    /// @dev Called by any address
    /// @param _accountContract Address of the Authereum account being recovered
    /// @param _recoveryAddress The address that can recover the account
    function completeRecovery(address payable _accountContract, address _recoveryAddress) external isRecoveryAddress(_accountContract, _recoveryAddress) {
        RecoveryAccount memory recoveryAccount = recoveryAccounts[_accountContract][_recoveryAddress];
        RecoveryAttempt memory recoveryAttempt = recoveryAttempts[_accountContract][_recoveryAddress];

        require(recoveryAttempt.startTime != 0, "ARM: Recovery attempt does not exist");
        require(recoveryAttempt.startTime.add(recoveryAccount.delay) < now, "ARM: Recovery attempt delay period has not completed");

        delete recoveryAttempts[_accountContract][_recoveryAddress];
        IAuthereumAccount(_accountContract).addAuthKey(recoveryAttempt.newAuthKey);

        emit RecoveryCompleted(_accountContract, _recoveryAddress, recoveryAttempt.newAuthKey);
    }
}