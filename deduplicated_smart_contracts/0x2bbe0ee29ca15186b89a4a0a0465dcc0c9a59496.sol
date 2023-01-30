/**
 *Submitted for verification at Etherscan.io on 2020-06-29
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

// File: original_contracts/Partner.sol

pragma solidity 0.5.11;




contract Partner is Ownable {
    using SafeMath for uint256;

    enum ChangeType { _, FEE, WALLET }

    struct ChangeRequest {
        uint256 fee;
        address payable wallet;
        bool completed;
        uint256 requestedBlockNumber;
    }

    mapping(uint256 => ChangeRequest) private _typeVsChangeRequest;

    string private _referralId;

    address payable private _feeWallet;

    //It should be in percentage. For 1% it should be 100
    uint256 private _fee;

    //Paraswap share in the fee. For 20% it should 2000
    //It means 20% of 1% fee charged
    uint256 private _paraswapShare;

    //Partner share in the fee. For 80% it should be 8000
    uint256 private _partnerShare;

    //Number of blocks after which change request can be fulfilled
    uint256 private _timelock;

    uint256 private _maxFee;

    event FeeWalletChanged(address indexed feeWallet);
    event FeeChanged(uint256 fee);

    event ChangeRequested(
        ChangeType changeType,
        uint256 fee,
        address wallet,
        uint256 requestedBlockNumber
    );
    event ChangeRequestCancelled(
        ChangeType changeType,
        uint256 fee,
        address wallet,
        uint256 requestedBlockNumber
    );
    event ChangeRequestFulfilled(
        ChangeType changeType,
        uint256 fee,
        address wallet,
        uint256 requestedBlockNumber,
        uint256 fulfilledBlockNumber
    );

    constructor(
        string memory referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner,
        uint256 timelock,
        uint256 maxFee
    )
        public
    {
        _referralId = referralId;
        _feeWallet = feeWallet;
        _fee = fee;
        _paraswapShare = paraswapShare;
        _partnerShare = partnerShare;
        _timelock = timelock;
        _maxFee = maxFee;
        transferOwnership(owner);
    }

    function getReferralId() external view returns(string memory) {
        return _referralId;
    }

    function getFeeWallet() external view returns(address payable) {
        return _feeWallet;
    }

    function getFee() external view returns(uint256) {
        return _fee;
    }

    function getPartnerShare() external view returns(uint256) {
        return _partnerShare;
    }

    function getParaswapShare() external view returns(uint256) {
        return _paraswapShare;
    }

    function getTimeLock() external view returns(uint256) {
        return _timelock;
    }

    function getMaxFee() external view returns(uint256) {
        return _maxFee;
    }

    function getChangeRequest(
        ChangeType changeType
    )
        external
        view
        returns(
            uint256,
            address,
            bool,
            uint256
        )
    {
        ChangeRequest memory changeRequest = _typeVsChangeRequest[uint256(changeType)];

        return(
            changeRequest.fee,
            changeRequest.wallet,
            changeRequest.completed,
            changeRequest.requestedBlockNumber
        );
    }

    function changeFeeRequest(uint256 fee) external onlyOwner {
        require(fee <= _maxFee, "Invalid fee passed!!");
        ChangeRequest storage changeRequest = _typeVsChangeRequest[uint256(ChangeType.FEE)];
        require(
            changeRequest.requestedBlockNumber == 0 || changeRequest.completed,
            "Previous fee change request pending"
        );

        changeRequest.fee = fee;
        changeRequest.requestedBlockNumber = block.number;
        emit ChangeRequested(
            ChangeType.FEE,
            fee,
            address(0),
            block.number
        );
    }

    function changeWalletRequest(address payable wallet) external onlyOwner {
        require(wallet != address(0), "Invalid fee wallet passed!!");
        ChangeRequest storage changeRequest = _typeVsChangeRequest[uint256(ChangeType.WALLET)];

        require(
            changeRequest.requestedBlockNumber == 0 || changeRequest.completed,
            "Previous fee change request pending"
        );

        changeRequest.wallet = wallet;
        changeRequest.requestedBlockNumber = block.number;
        emit ChangeRequested(
            ChangeType.WALLET,
            0,
            wallet,
            block.number
        );
    }

    function confirmChangeRequest(ChangeType changeType) external onlyOwner {
        ChangeRequest storage changeRequest = _typeVsChangeRequest[uint256(changeType)];

        require(
            changeRequest.requestedBlockNumber > 0 && !changeRequest.completed,
            "Invalid request"
        );

        require(
            changeRequest.requestedBlockNumber.add(_timelock) <= block.number,
            "Request is in waiting period"
        );

        changeRequest.completed = true;

        if(changeType == ChangeType.FEE) {
            _fee = changeRequest.fee;
        }

        else {
            _feeWallet = changeRequest.wallet;
        }

        emit ChangeRequestFulfilled(
            changeType,
            changeRequest.fee,
            changeRequest.wallet,
            changeRequest.requestedBlockNumber,
            block.number
        );
    }

    function cancelChangeRequest(ChangeType changeType) external onlyOwner {
        ChangeRequest storage changeRequest = _typeVsChangeRequest[uint256(changeType)];

        require(
            changeRequest.requestedBlockNumber > 0 && !changeRequest.completed,
            "Invalid request"
        );
        changeRequest.completed = true;

        emit ChangeRequestCancelled(
            changeType,
            changeRequest.fee,
            changeRequest.wallet,
            changeRequest.requestedBlockNumber
        );

    }

}