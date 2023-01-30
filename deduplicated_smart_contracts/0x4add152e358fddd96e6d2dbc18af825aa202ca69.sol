/**
 *Submitted for verification at Etherscan.io on 2019-12-03
*/

// =================================================================================================
//                                    CTOKEN INTERFACE
// =================================================================================================

pragma solidity 0.5.8; // use same version as Compound's contract

/**
 * @dev Interface of the ERC20 standard as defined in the EIP, plus additional
 * functions for cDAI contract interactions. Does not include the optional
 * functions; to access them see {ERC20Detailed}.
 */
interface ICERC20 {
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

    /**
     * @notice Sender supplies assets into the market and receives cTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function mint(uint mintAmount) external returns (uint);

    /**
     * @notice Sender redeems cTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of cTokens to redeem into underlying
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeem(uint redeemTokens) external returns (uint);

    /**
     * @notice Sender redeems cTokens in exchange for a specified amount of underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The amount of underlying to redeem
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeemUnderlying(uint redeemAmount) external returns (uint);
}

// =================================================================================================
//                                    OPEN ZEPPELIN CONTRACTS
// =================================================================================================

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
    constructor() internal {
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



contract FloatifyAccount is Ownable {
    using SafeMath for uint256;
    // =============================================================================================
    //                                    STORAGE VARIABLES
    // =============================================================================================

    // Amount of DAI used to mint cDAI
    // If DAI was sent to the contract but not used to mint cDAI, it will not be counted here
    // Therefore, this value should be updated when the deposit function is called
    uint256 public totalDeposited;

    // Amount of deposited DAI which was redeemed and withdrawn
    // If DAI was sent to the contract and withdrawn without minting cDAI, it will not be counted here
    // Therefore, this value should be updated when the redeemAndWithdraw functions are callled
    uint256 public totalWithdrawn;

    // DAI and CDAI interface variables
    ICERC20 private daiContract; // interface to call functions from DAI contract
    ICERC20 private cdaiContract; // interface to call functions from cDAI contract


    // =============================================================================================
    //                                        EVENTS
    // =============================================================================================

    /**
     * @dev Emitted when cDAI is successfully minted from DAI held by the contract
     */
    event Deposit(uint256 indexed daiAmount);

    /**
     * @dev Emitted on withdrawal of DAI to an external account
     */
    event Withdraw(address indexed destinationAddress, uint256 indexed daiAmount);

     /**
      * @dev Emitted on redemption of cDAI for DAI by specifying cDAI amount
      */
    event RedeemMax(uint256 indexed daiAmount, uint256 indexed cdaiAmount, address indexed withdrawalAddress);

    /**
     * @dev Emitted on redemption of cDAI for DAI by specifying DAI amount
     */
    event RedeemPartial(uint256 indexed daiAmount, uint256 indexed cdaiAmount, address indexed withdrawalAddress);

    // =============================================================================================
    //                                   MAIN OPERATION FUNCTIONS
    // =============================================================================================

    // CONSTRUCTOR FUNCTION AND HELPERS ============================================================
    /**
     * @dev Approve cDAI contract upon deployment, throws error if fails
     */
    constructor() public {

        // Configure the ICERC20 state variables
        address _daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // mainnet DAI address
        address _cdaiAddress = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643; // mainnet cDAI address
        daiContract = ICERC20(_daiAddress);
        cdaiContract = ICERC20(_cdaiAddress);

        // Approve the cDAI contract to spend our DAI balance
        bool daiApprovalResult = daiContract.approve(_cdaiAddress, 2**256-1);
        require(daiApprovalResult, "Failed to approve cDAI contract to spend DAI");
    }


    // DEPOSIT FUNCTION ============================================================================
    /**
     * @notice Deposits all DAI in this contract and mints cDAI to start earning interest
     */
    function deposit() external onlyOwner {
        uint _daiBalance = daiContract.balanceOf(address(this));
        totalDeposited = _daiBalance.add(totalDeposited);
        emit Deposit(_daiBalance);
        require(cdaiContract.mint(_daiBalance) == 0, "Call to mint function failed");
    }

    // WITHDRAWAL PROCESS FUNCTIONS ================================================================
    // There are two supported flows:
    //        1. Redeem everything:
    //                a. Specify address to withdraw to
    //                b. Get the cDAI balance of this contract
    //                c. Call redeem() with the balance from step 1b
    //                d. Withdraw DAI to the address specified in step 1a
    //        2. Redeem a specified amount of DAI
    //                a. Specify address to withdraw to and an amount of DAI to withdraw
    //                b. Call redeemUnderlying() with the amount of DAI specified in step 2a
    //                c. Withdraw DAI to the address specified in step 2a

    /**
     * @notice Withdraws all DAI from this contract to a specified address
     * @dev We keep this as `public onlyOwner` in case there is ever a need to Withdraw DAI without
     * depositing it in Compound first
     * @param _withdrawalAddress Address to send DAI to
     */
    function withdraw(address _withdrawalAddress) public onlyOwner {
        require(_withdrawalAddress != address(0), "Cannot withdraw to the zero address");
        uint256 _daiBalance = daiContract.balanceOf(address(this));
        emit Withdraw(_withdrawalAddress, _daiBalance);
        require(daiContract.transfer(_withdrawalAddress, _daiBalance), "Withrawal of DAI failed");
    }

    /**
     * @notice Redeems all cDAI held by this contract for DAI and sends it to a specified address
     * @dev This corresponds to flow 1 above
     * @param _withdrawalAddress Address to send DAI to
     */
    function redeemAndWithdrawMax(address _withdrawalAddress) external onlyOwner {
        // 1a. Destination address specified as an input
        require(_withdrawalAddress != address(0), "Cannot withdraw to the zero address");
        // 1b. Get the cDAI balance of this contract
        uint256 _cdaiBalance = cdaiContract.balanceOf(address(this));
        // 1c. Call redeem() with the balance from step 1b
        // EXTERNAL CONTRACT CALL -- state updates must happen after this call
        //   This is bad practice, but because (1) this function is onlyOwner, and (2) we
        //   trust the DAI and cDAI contracts to be secure, the risk is mitigated
        require(cdaiContract.redeem(_cdaiBalance) == 0, "Redemption of all cDAI for DAI failed");
        uint256 _daiBalance = daiContract.balanceOf(address(this));
        emit RedeemMax(_daiBalance, _cdaiBalance, _withdrawalAddress);
        totalWithdrawn = _daiBalance.add(totalWithdrawn); // right after this line we withdraw the full DAI balance
        // 1d. Withdraw all DAI to the address specified in step 1a
        withdraw(_withdrawalAddress);
    }

    /**
     * @notice Takes an amount of DAI and redeems the equivalent amount of cDAI
     * @dev This corresponds to flow 2 above
     * @param _withdrawalAddress Address to send DAI to
     * @param _daiAmount Amount of DAI to redeem
     */
    function redeemAndWithdrawPartial(address _withdrawalAddress, uint256 _daiAmount) external onlyOwner {
        // 2a. Address to withdraw to and amount of DAI to withdraw specified as inputs
        require(_withdrawalAddress != address(0), "Cannot withdraw to the zero address");
        // 2b. Call redeemUnderlying() with the amount of DAI specified in step 2a
        uint256 _initialCdaiBalance = cdaiContract.balanceOf(address(this));
        require(cdaiContract.redeemUnderlying(_daiAmount) == 0, "Redemption of some cDAI for DAI failed");
        uint256 _finalCdaiBalance = cdaiContract.balanceOf(address(this));
        // EXTERNAL CONTRACT CALL -- state updates must happen after this call
        //   This is bad practice, but because (1) this function is onlyOwner, and (2) we
        //   trust the DAI and cDAI contracts to be secure, the risk is mitigated
        uint256 _daiBalance = daiContract.balanceOf(address(this));
        uint256 _cdaiBalance = _initialCdaiBalance.sub(_finalCdaiBalance);
        emit RedeemPartial(_daiAmount, _cdaiBalance, _withdrawalAddress);
        totalWithdrawn = _daiBalance.add(totalWithdrawn); // right after this line we withdraw the full DAI balance
        // 2c. Withdraw all DAI to the address specified in step 2a
        withdraw(_withdrawalAddress);
    }

}