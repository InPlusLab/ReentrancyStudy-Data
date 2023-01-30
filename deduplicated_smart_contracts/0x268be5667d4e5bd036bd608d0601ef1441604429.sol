/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

// File: openzeppelin-solidity/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

// File: localhost/contracts/proxy/Proxy.sol

pragma solidity ^0.5.0;



/**
 * @title Proxy interface for Dinngo exchange contract.
 * @author Ben Huang
 * @dev Referenced the proxy contract from zeppelin-os project.
 * https://github.com/zeppelinos/zos/tree/master/packages/lib
 */
contract Proxy is Ownable {
    using Address for address;

    // keccak256 hash of "dinngo.proxy.implementation"
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x3b2ff02c0f36dba7cc1b20a669e540b974575f04ef71846d482983efb03bebb4;

    event Upgraded(address indexed implementation);

    constructor(address implementation) internal {
        assert(IMPLEMENTATION_SLOT == keccak256("dinngo.proxy.implementation"));
        _setImplementation(implementation);
    }

    /**
     * @notice Upgrade the implementation contract. Can only be triggered
     * by the owner. Emits the Upgraded event.
     * @param implementation The new implementation address.
     */
    function upgrade(address implementation) external onlyOwner {
        _setImplementation(implementation);
        emit Upgraded(implementation);
    }

    /**
     * @notice Return the version information of implementation
     * @return version The version
     */
    function implementationVersion() external view returns (uint256 version){
        (bool ok, bytes memory ret) = _implementation().staticcall(
            abi.encodeWithSignature("version()")
        );
        require(ok);
        assembly {
            version := mload(add(add(ret, 0x20), 0))
        }
        return version;
    }

    /**
     * @dev Set the implementation address in the storage slot.
     * @param implementation The new implementation address.
     */
    function _setImplementation(address implementation) internal {
        require(implementation.isContract(),
            "Implementation address should be a contract address"
        );
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, implementation)
        }
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view returns (address implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            implementation := sload(slot)
        }
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: localhost/contracts/Administrable.sol

pragma solidity ^0.5.0;


/**
 * @title Administrable
 * @dev The administrator structure
 */
/**
 * @title Administrable
 */
contract Administrable {
    using SafeMath for uint256;
    mapping (address => bool) private admins;
    uint256 private _nAdmin;
    uint256 private _nLimit;

    event Activated(address indexed admin);
    event Deactivated(address indexed admin);

    /**
     * @dev The Administrable constructor sets the original `admin` of the contract to the sender
     * account. The initial limit amount of admin is 2.
     */
    constructor() internal {
        _setAdminLimit(2);
        _activateAdmin(msg.sender);
    }

    function isAdmin() public view returns(bool) {
        return admins[msg.sender];
    }

    /**
     * @dev Throws if called by non-admin.
     */
    modifier onlyAdmin() {
        require(isAdmin(), "sender not admin");
        _;
    }

    function activateAdmin(address admin) external onlyAdmin {
        _activateAdmin(admin);
    }

    function deactivateAdmin(address admin) external onlyAdmin {
        _safeDeactivateAdmin(admin);
    }

    function setAdminLimit(uint256 n) external onlyAdmin {
        _setAdminLimit(n);
    }

    function _setAdminLimit(uint256 n) internal {
        require(_nLimit != n, "same limit");
        _nLimit = n;
    }

    /**
     * @notice The Amount of admin should be bounded by _nLimit.
     */
    function _activateAdmin(address admin) internal {
        require(admin != address(0), "invalid address");
        require(_nAdmin < _nLimit, "too many admins existed");
        require(!admins[admin], "already admin");
        admins[admin] = true;
        _nAdmin = _nAdmin.add(1);
        emit Activated(admin);
    }

    /**
     * @notice At least one admin should exists.
     */
    function _safeDeactivateAdmin(address admin) internal {
        require(_nAdmin > 1, "admin should > 1");
        _deactivateAdmin(admin);
    }

    function _deactivateAdmin(address admin) internal {
        require(admins[admin], "not admin");
        admins[admin] = false;
        _nAdmin = _nAdmin.sub(1);
        emit Deactivated(admin);
    }
}

// File: localhost/contracts/DinngoProxy.sol

pragma solidity 0.5.12;





/**
 * @title Dinngo
 * @author Ben Huang
 * @notice Main exchange contract for Dinngo
 */
contract DinngoProxy is Ownable, Administrable, Proxy {
    uint256 public processTime;

    mapping (address => mapping (address => uint256)) public balances;
    mapping (bytes32 => uint256) public orderFills;
    mapping (uint256 => address payable) public userID_Address;
    mapping (uint256 => address) public tokenID_Address;
    mapping (address => uint256) public nonces;
    mapping (address => uint256) public ranks;
    mapping (address => uint256) public lockTimes;

    address public walletOwner;
    address public DGOToken;
    uint8 public eventConf;

    uint256 constant public version = 2;

    /**
     * @dev User ID 0 is the management wallet.
     * Token ID 0 is ETH (address 0). Token ID 1 is DGO.
     * @param _walletOwner The fee wallet owner
     * @param _dinngoToken The contract address of DGO
     * @param _impl The implementation contract address
     */
    constructor(
        address payable _walletOwner,
        address _dinngoToken,
        address _impl
    ) Proxy(_impl) public {
        processTime = 90 days;
        walletOwner = _walletOwner;
        tokenID_Address[0] = address(0);
        ranks[address(0)] = 1;
        tokenID_Address[1] = _dinngoToken;
        ranks[_dinngoToken] = 1;
        DGOToken = _dinngoToken;
        eventConf = 0xff;
    }

    function setEvent(uint8 conf) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("setEvent(uint8)", conf)
        );
        require(ok);
    }

    /**
     * @notice Add the address to the user list. Event AddUser will be emitted
     * after execution.
     * @dev Record the user list to map the user address to a specific user ID, in
     * order to compact the data size when transferring user address information
     * @param id The user id to be assigned
     * @param user The user address to be added
     */
    function addUser(uint256 id, address user) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("addUser(uint256,address)", id, user)
        );
        require(ok);
    }

    /**
     * @notice Remove the address from the user list.
     * @dev The user rank is set to 0 to remove the user.
     * @param user The user address to be removed
     */
    function removeUser(address user) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("remove(address)", user)
        );
        require(ok);
    }

    /**
     * @notice Update the rank of user. Can only be called by admin.
     * @param user The user address
     * @param rank The rank to be assigned
     */
    function updateUserRank(address user, uint256 rank) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("updateRank(address,uint256)", user, rank)
        );
        require(ok);
    }

    /**
     * @notice Add the token to the token list. Event AddToken will be emitted
     * after execution.
     * @dev Record the token list to map the token contract address to a specific
     * token ID, in order to compact the data size when transferring token contract
     * address information
     * @param id The token id to be assigned
     * @param token The token contract address to be added
     */
    function addToken(uint256 id, address token) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("addToken(uint256,address)", id, token)
        );
        require(ok);
    }

    /**
     * @notice Remove the token from the token list.
     * @dev The token rank is set to 0 to remove the token.
     * @param token The token contract address to be removed.
     */
    function removeToken(address token) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("remove(address)", token)
        );
        require(ok);
    }

    /**
     * @notice Update the rank of token. Can only be called by owner.
     * @param token The token contract address.
     * @param rank The rank to be assigned.
     */
    function updateTokenRank(address token, uint256 rank) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("updateRank(address,uint256)", token, rank)
        );
        require(ok);
    }

    function activateAdmin(address admin) external onlyOwner {
        _activateAdmin(admin);
    }

    function deactivateAdmin(address admin) external onlyOwner {
        _safeDeactivateAdmin(admin);
    }

    /**
     * @notice Force-deactivate allows owner to deactivate admin even there will be
     * no admin left. Should only be executed under emergency situation.
     */
    function forceDeactivateAdmin(address admin) external onlyOwner {
        _deactivateAdmin(admin);
    }

    function setAdminLimit(uint256 n) external onlyOwner {
        _setAdminLimit(n);
    }

    /**
     * @notice The deposit function for ether. The ether that is sent with the function
     * call will be deposited. The first time user will be added to the user list.
     * Event Deposit will be emitted after execution.
     */
    function deposit() external payable {
        (bool ok,) = _implementation().delegatecall(abi.encodeWithSignature("deposit()"));
        require(ok);
    }

    /**
     * @notice The deposit function for tokens. The first time user will be added to
     * the user list. Event Deposit will be emitted after execution.
     * @param token Address of the token contract to be deposited
     * @param amount Amount of the token to be depositied
     */
    function depositToken(address token, uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("depositToken(address,uint256)", token, amount)
        );
        require(ok);
    }

    /**
     * @notice The withdraw function for ether. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param amount The amount to be withdrawn.
     */
    function withdraw(uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );
        require(ok);
    }

    /**
     * @notice The withdraw function for tokens. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param token The token contract address to be withdrawn.
     * @param amount The token amount to be withdrawn.
     */
    function withdrawToken(address token, uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("withdrawToken(address,uint256)", token, amount)
        );
        require(ok);
    }

    /**
     * @notice The function to extract the fee from the fee account. This function can
     * only be triggered by the income wallet owner.
     * @param amount The amount to be extracted
     */
    function extractFee(uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("extractFee(uint256)", amount)
        );
        require(ok);
    }

    /**
     * @notice The function to extract the fee from the fee account. This function can
     * only be triggered by the income wallet owner.
     * @param token The token to be extracted
     * @param amount The amount to be extracted
     */
    function extractTokenFee(address token, uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("extractTokenFee(address,uint256)", token, amount)
        );
        require(ok);
    }

    /**
     * @notice The function to get the balance from fee account.
     * @param token The token of the balance to be queried
     */
    function getWalletBalance(address token) external returns (uint256 balance) {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("getWalletBalance(address)", token)
        );
        require(ok);
        balance = abi.decode(ret, (uint256));
    }

    /**
     * @notice The function to change the owner of fee wallet.
     * @param newOwner The new wallet owner to be assigned
     */
    function changeWalletOwner(address newOwner) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("changeWalletOwner(address)", newOwner)
        );
        require(ok);
    }

    /**
     * @notice The withdraw function that can only be triggered by owner.
     * Event Withdraw will be emitted after execution.
     * @param withdrawal The serialized withdrawal data
     */
    function withdrawByAdmin(bytes calldata withdrawal, bytes calldata signature) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("withdrawByAdmin(bytes,bytes)", withdrawal, signature)
        );
        require(ok, string(ret));
    }

    /**
     * @notice The transfer function that can only be triggered by owner.
     * Event Transfer will be emitted afer execution.
     * @param transferral The serialized transferral data.
     */
    function transferByAdmin(bytes calldata transferral, bytes calldata signature) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("transferByAdmin(bytes,bytes)", transferral, signature)
        );
        require(ok, string(ret));
    }

    /**
     * @notice The settle function for orders. First order is taker order and the followings
     * are maker orders.
     * @param orders The serialized orders.
     */
    function settle(bytes calldata orders, bytes calldata signature) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("settle(bytes,bytes)", orders, signature)
        );
        require(ok, string(ret));
    }

    /**
     * @notice The migrate function that can only be triggered by admin.
     * @param migration The serialized migration data
     */
    function migrateByAdmin(bytes calldata migration, bytes calldata signature) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("migrateByAdmin(bytes,bytes)", migration, signature)
        );
        require(ok, string(ret));
    }

    /**
     * @notice The migration handler
     * @param user The user address to receive the migrated amount.
     * @param token The token address to be migrated.
     * @param amount The amount to be migrated.
     */
    function migrateTo(address user, address token, uint256 amount) payable external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("migrateTo(address,address,uint256)", user, token, amount)
        );
        require(ok);
    }

    /**
     * @notice Announce lock of the sender
     */
    function lock() external {
        (bool ok,) = _implementation().delegatecall(abi.encodeWithSignature("lock()"));
        require(ok);
    }

    /**
     * @notice Unlock the sender
     */
    function unlock() external {
        (bool ok,) = _implementation().delegatecall(abi.encodeWithSignature("unlock()"));
        require(ok);
    }

    /**
     * @notice Change the processing time of locking the user address
     */
    function changeProcessTime(uint256 time) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("changeProcessTime(uint256)", time)
        );
        require(ok);
    }

    /**
     * @notice Get hash from the transferral parameters.
     */
    function getTransferralHash(
        address from,
        uint8 config,
        uint32 nonce,
        address[] calldata tos,
        uint16[] calldata tokenIDs,
        uint256[] calldata amounts,
        uint256[] calldata fees
    ) external view returns (bytes32 hash) {
        (bool ok, bytes memory ret) = _implementation().staticcall(
            abi.encodeWithSignature(
                "getTransferralHash(address,uint8,uint32,address[],uint16[],uint256[],uint256[])",
                from, config, nonce, tos, tokenIDs, amounts, fees
            )
        );
        require(ok);
        hash = abi.decode(ret, (bytes32));
    }
}