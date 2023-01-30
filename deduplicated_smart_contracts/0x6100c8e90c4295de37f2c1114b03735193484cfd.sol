/**
 *Submitted for verification at Etherscan.io on 2019-12-20
*/

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interfaces/SyscoinERC20I.sol

pragma solidity ^0.5.13;


contract SyscoinERC20I is IERC20 {
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/token/SyscoinERC20Manager.sol

pragma solidity ^0.5.13;




contract SyscoinERC20Manager is Initializable {

    using SafeMath for uint;
    using SafeMath for uint8;

    // Lock constants
    uint private constant MIN_LOCK_VALUE = 10; // 0.1 token
    uint private constant SUPERBLOCK_SUBMITTER_LOCK_FEE = 10000; // 10000 = 0.01%
    uint private constant MIN_CANCEL_DEPOSIT = 3000000000000000000; // 3 eth
    uint private constant CANCEL_TRANSFER_TIMEOUT = 3600; // 1 hour in seconds
    uint private constant CANCEL_MINT_TIMEOUT = 907200; // 1.5 weeks in seconds
    // Variables set by constructor

    // Contract to trust for tx included in a syscoin block verification.
    // Only syscoin txs relayed from trustedRelayerContract will be accepted.
    address public trustedRelayerContract;


    mapping(uint32 => uint256) public assetBalances;
    // Syscoin transactions that were already processed by processTransaction()
    mapping(uint => bool) private syscoinTxHashesAlreadyProcessed;

    uint32 bridgeTransferIdCount;
    
    enum BridgeTransferStatus { Uninitialized, Ok, CancelRequested, CancelChallenged, CancelOk }
    
    struct BridgeTransfer {
        uint timestamp;
        uint value;
        address erc20ContractAddress;
        address tokenFreezerAddress;
        uint32 assetGUID;
        BridgeTransferStatus status;           
    }

    mapping(uint32 => BridgeTransfer) private bridgeTransfers;
    mapping(uint32 => uint) private deposits;

    // network that the stored blocks belong to
    enum Network { MAINNET, TESTNET, REGTEST }
    Network private net;

    event TokenUnfreeze(address receipient, uint value);
    event TokenUnfreezeFee(address receipient, uint value);
    event TokenFreeze(address freezer, uint value, uint32 bridgetransferid);
    event CancelTransferRequest(address canceller, uint32 bridgetransferid);
    event CancelTransferSucceeded(address canceller, uint32 bridgetransferid);
    event CancelTransferFailed(address canceller, uint32 bridgetransferid);
    function contains(uint value) private view returns (bool) {
        return syscoinTxHashesAlreadyProcessed[value];
    }

    function insert(uint value) private returns (bool) {
        if (contains(value))
            return false; // already there
        syscoinTxHashesAlreadyProcessed[value] = true;
        return true;
    }
    
    function init(Network _network, address _trustedRelayerContract) public initializer {
        net = _network;
        trustedRelayerContract = _trustedRelayerContract;
        bridgeTransferIdCount = 0;
    }

    modifier onlyTrustedRelayer() {
        require(msg.sender == trustedRelayerContract, "Call must be from trusted relayer");
        _;
    }

    modifier minimumValue(address erc20ContractAddress, uint value) {
        uint256 decimals = SyscoinERC20I(erc20ContractAddress).decimals();
        require(
            value >= (uint256(10) ** decimals).div(MIN_LOCK_VALUE),
            "Value must be bigger or equal MIN_LOCK_VALUE"
        );
        _;
    }

    function requireMinimumValue(uint8 decimalsIn, uint value) private pure {
        uint256 decimals = uint256(decimalsIn);
        require(value > 0, "Value must be positive");
        require(
            value >= (uint256(10) ** decimals).div(MIN_LOCK_VALUE),
            "Value must be bigger or equal MIN_LOCK_VALUE"
        );
        
    }

    function wasSyscoinTxProcessed(uint txHash) public view returns (bool) {
        return contains(txHash);
    }

    function processTransaction(
        uint txHash,
        uint value,
        address destinationAddress,
        address superblockSubmitterAddress,
        address erc20ContractAddress,
        uint32 assetGUID,
        uint8 precision
    ) public onlyTrustedRelayer {
        SyscoinERC20I erc20 = SyscoinERC20I(erc20ContractAddress);
        uint8 nLocalPrecision = erc20.decimals();
        // see issue #372 on syscoin
        if(nLocalPrecision > precision){
            value *= uint(10)**(uint(nLocalPrecision - precision));
        }else if(nLocalPrecision < precision){
            value /= uint(10)**(uint(precision - nLocalPrecision));
        }
        requireMinimumValue(nLocalPrecision, value);
        // Add tx to the syscoinTxHashesAlreadyProcessed and Check tx was not already processed
        require(insert(txHash), "TX already processed");


        assetBalances[assetGUID] = assetBalances[assetGUID].sub(value);

        uint superblockSubmitterFee = value.div(SUPERBLOCK_SUBMITTER_LOCK_FEE);
        uint userValue = value.sub(superblockSubmitterFee);

        // pay the fee
        erc20.transfer(superblockSubmitterAddress, superblockSubmitterFee);
        emit TokenUnfreezeFee(superblockSubmitterAddress, superblockSubmitterFee);

        // get your token
        erc20.transfer(destinationAddress, userValue);
        emit TokenUnfreeze(destinationAddress, userValue);
    }
    
    function cancelTransferRequest(uint32 bridgeTransferId) public payable {
        // lookup state by bridgeTransferId
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransferId];
        // ensure state is Ok
        require(bridgeTransfer.status == BridgeTransferStatus.Ok,
            "#SyscoinERC20Manager cancelTransferRequest(): Status of bridge transfer must be Ok");
        // ensure msg.sender is same as tokenFreezerAddress
        // we don't have to do this but we do it anyway so someone can't accidentily cancel a transfer they did not make
        require(msg.sender == bridgeTransfer.tokenFreezerAddress, "#SyscoinERC20Manager cancelTransferRequest(): Only msg.sender is allowed to cancel");
        // if freezeBurnERC20 was called less than 1.5 weeks ago then return error
        // 0.5 week buffer since only 1 week of blocks are allowed to pass before cannot mint on sys
        require((block.timestamp - bridgeTransfer.timestamp) > (net == Network.MAINNET? CANCEL_MINT_TIMEOUT: 36000), "#SyscoinERC20Manager cancelTransferRequest(): Transfer must be at least 1.5 week old");
        // ensure min deposit paid
        require(msg.value >= MIN_CANCEL_DEPOSIT,
            "#SyscoinERC20Manager cancelTransferRequest(): Cancel deposit incorrect");
        deposits[bridgeTransferId] = msg.value;
        // set height for cancel time begin to enforce a delay to wait for challengers
        bridgeTransfer.timestamp = block.timestamp;
        // set state of bridge transfer to CancelRequested
        bridgeTransfer.status = BridgeTransferStatus.CancelRequested;
        emit CancelTransferRequest(msg.sender, bridgeTransferId);
    }

    function cancelTransferSuccess(uint32 bridgeTransferId) public {
        // lookup state by bridgeTransferId
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransferId];
        // ensure state is CancelRequested to avoid people trying to claim multiple times 
        // and that it has to be on an active cancel request
        require(bridgeTransfer.status == BridgeTransferStatus.CancelRequested,
            "#SyscoinERC20Manager cancelTransferSuccess(): Status must be CancelRequested");
        // check if timeout period passed (atleast 1 hour of blocks have to have passed)
        require((block.timestamp - bridgeTransfer.timestamp) > CANCEL_TRANSFER_TIMEOUT, "#SyscoinERC20Manager cancelTransferSuccess(): 1 hour timeout is required");
        // refund erc20 to the tokenFreezerAddress
        SyscoinERC20I erc20 = SyscoinERC20I(bridgeTransfer.erc20ContractAddress);
        assetBalances[bridgeTransfer.assetGUID] = assetBalances[bridgeTransfer.assetGUID].sub(bridgeTransfer.value);
        erc20.transfer(bridgeTransfer.tokenFreezerAddress, bridgeTransfer.value);
        // pay back deposit
        address payable tokenFreezeAddressPayable = address(uint160(bridgeTransfer.tokenFreezerAddress));
        tokenFreezeAddressPayable.transfer(deposits[bridgeTransferId]);
        delete deposits[bridgeTransferId];
        // set state of bridge transfer to CancelOk
        bridgeTransfer.status = BridgeTransferStatus.CancelOk;
        emit CancelTransferSucceeded(bridgeTransfer.tokenFreezerAddress, bridgeTransferId);
    }

    function processCancelTransferFail(uint32 bridgeTransferId, address payable challengerAddress)
        public
        onlyTrustedRelayer
    {
        // lookup state by bridgeTransferId
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransferId];
        // ensure state is CancelRequested
        require(bridgeTransfer.status == BridgeTransferStatus.CancelRequested,
            "#SyscoinERC20Manager cancelTransferSuccess(): Status must be CancelRequested to Fail the transfer");
        // pay deposit to challenger
        challengerAddress.transfer(deposits[bridgeTransferId]);
        delete deposits[bridgeTransferId];
        // set state of bridge transfer to CancelChallenged
        bridgeTransfer.status = BridgeTransferStatus.CancelChallenged;
        emit CancelTransferFailed(bridgeTransfer.tokenFreezerAddress, bridgeTransferId);
    }

    // keyhash or scripthash for syscoinWitnessProgram
    function freezeBurnERC20(
        uint value,
        uint32 assetGUID,
        address erc20ContractAddress,
        uint8 precision,
        bytes memory syscoinAddress
    )
        public
        minimumValue(erc20ContractAddress, value)
        returns (bool)
    {
        require(syscoinAddress.length > 0, "syscoinAddress cannot be zero");
        require(assetGUID > 0, "Asset GUID must not be 0");
        

        SyscoinERC20I erc20 = SyscoinERC20I(erc20ContractAddress);
        require(precision == erc20.decimals(), "Decimals were not provided with the correct value");
        erc20.transferFrom(msg.sender, address(this), value);
        assetBalances[assetGUID] = assetBalances[assetGUID].add(value);

        // store some state needed for potential bridge transfer cancellation
        // create bridgeTransferId mapping structure with status + height + value + erc20ContractAddress + assetGUID + tokenFreezerAddress
        bridgeTransferIdCount++;
        bridgeTransfers[bridgeTransferIdCount] = BridgeTransfer({
            status: BridgeTransferStatus.Ok,
            value: value,
            erc20ContractAddress: erc20ContractAddress,
            assetGUID: assetGUID,
            timestamp: block.timestamp,
            tokenFreezerAddress: msg.sender
        });
        emit TokenFreeze(msg.sender, value, bridgeTransferIdCount);
        return true;
    }

    // @dev - Returns the bridge transfer data for the supplied bridge transfer ID
    //
    function getBridgeTransfer(uint32 bridgeTransferId) external view returns (
        uint _timestamp,
        uint _value,
        address _erc20ContractAddress,
        address _tokenFreezerAddress,
        uint32 _assetGUID,
        BridgeTransferStatus _status
    ) {
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransferId];
        return (
            bridgeTransfer.timestamp,
            bridgeTransfer.value,
            bridgeTransfer.erc20ContractAddress,
            bridgeTransfer.tokenFreezerAddress,
            bridgeTransfer.assetGUID,
            bridgeTransfer.status
        );
    }
}