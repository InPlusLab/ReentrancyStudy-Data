pragma solidity ^0.5.16;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

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
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
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
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
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
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
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
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "./ErrorReporter.sol";
import "./Exponential.sol";
import "./WantFaucet.sol";
import "./WanttrollerStorage.sol";
import "./Unitroller.sol";
import "./EIP20Interface.sol";
import "./SafeMath.sol";

contract Wanttroller is WanttrollerV1Storage, WanttrollerErrorReporter {
  using SafeMath for uint256;

  uint constant initialReward = 50e18;

  event WantDropIndex(address account, uint index);
  event CollectRewards(address owner, uint rewardsAmount);
  event AccrueRewards(address owner, uint rewardsAmount);
  
  constructor() public {
    admin = msg.sender;
  }

//--------------------
// Main actions
// -------------------

  /**
   * @notice Redeem rewards earned in wallet and register for next drop 
   */
  function collectRewards() public {
    // Register for next drop, accrue last reward if applicable 
    registerForDrop();

    if (_needsDrip()){
      _dripFaucet();
    }

    // send accrued reward to sender
    EIP20Interface want = EIP20Interface(wantTokenAddress);
    bool success = want.transfer(msg.sender, accruedRewards[msg.sender]);
    require(success, "collectRewards(): Unable to send tokens");
    
    // emit
    emit CollectRewards(msg.sender, accruedRewards[msg.sender]);
    
    // Reset accrued to zero 
    accruedRewards[msg.sender] = 0; 
  }

  /**
   * @notice Register to receive reward in next WantDrop, accrues any rewards from the last drop 
   */
  function registerForDrop() public {
    // If previous drop has finished, start a new drop
    if (isDropOver()) {
      _startNewDrop();
    }

    // Add rewards to balance
    _accrueRewards();
    
    // Update want index
    if (lastDropRegistered[msg.sender] != currentDropIndex) {
      // Store index for account
      lastDropRegistered[msg.sender] = currentDropIndex;
      
      // Bump total registered count for this drop
      uint _numRegistrants = wantDropState[currentDropIndex].numRegistrants;
      wantDropState[currentDropIndex].numRegistrants = _numRegistrants.add(1);
    
      // Add to array of those on drop 
      accountsRegisteredForDrop.push(msg.sender);

      // Emit event
      emit WantDropIndex(msg.sender, currentDropIndex);
    }
    
    // Track sender registered for current drop 
    lastDropRegistered[msg.sender] = currentDropIndex;
  }

  /**
   * @notice Register to receive reward in next WantDrop, accrues any rewards from the last drop, 
   *         sends all rewards to wallet 
   */
  function registerAndCollect() public {
    registerForDrop();
    collectRewards();
  }

//---------------------
// Statuses & getters
//---------------------
  
  /**
   * @notice Gets most current drop index. If current drop has finished, returns next drop index 
   */
  function getCurrentDropIndex() public view returns(uint) {
    if (isDropOver())
      return currentDropIndex.add(1);
    else
      return currentDropIndex;
  }
  
  /**
   * @notice True if registered for most current drop 
   */
  function registeredForNextDrop() public view returns(bool) {
    if (isDropOver())
      return false;
    else if (lastDropRegistered[msg.sender] == currentDropIndex)
      return true;
    else
      return false;
  }

  /**
    * @notice Blocks remaining to register for stake drop
    */
  function blocksRemainingToRegister() public view returns(uint) {
    if (isDropOver() || currentDropIndex == 0){
      return waitblocks; 
    }
    else {
      return currentDropStartBlock.add(waitblocks).sub(block.number);
    }
  }

  /**
   * @notice True if waitblocks have passed since drop registration started 
   */
  function isDropOver() public view returns(bool) {
    // If current block is beyond start + waitblocks, drop registration over
    if (block.number >= currentDropStartBlock.add(waitblocks))
      return true;
    else
      return false;
  }

  function getTotalCurrentDropReward() public view returns(uint) {
    if (isDropOver()) {
      return _nextReward(currentReward);
    }
    else {
      return currentReward;
    }
  }

  /**
   * @notice returns expected drop based on how many registered
   */
  function getExpectedReward() public view returns(uint) {
    if (isDropOver()) {
      return _nextReward(currentReward);
    }
    
    // total reward / num registrants
    (MathError err, Exp memory result) = divScalar(Exp({mantissa: wantDropState[currentDropIndex].totalDrop}), wantDropState[currentDropIndex].numRegistrants ); 
    require(err == MathError.NO_ERROR);
    return result.mantissa;
  }

  /**
   * @notice Gets the sender's total accrued rewards 
   */
  function getRewards() public view returns(uint) {
    uint pendingRewards = _pendingRewards();
     
    if (pendingRewards > 0) { 
      return accruedRewards[msg.sender].add(pendingRewards);
    }
    else {
      return accruedRewards[msg.sender];
    }
  }


  /**
   * @notice Return stakers list for  
   */
  function getAccountsRegisteredForDrop() public view returns(address[] memory) {
    if (isDropOver()){
      address[] memory blank;
      return blank;
    }
    else
      return accountsRegisteredForDrop;
  }

// --------------------------------
// Reward computation and helpers
// --------------------------------
  
  /**
   * @notice Used to compute any pending reward not yet accrued onto a users accruedRewards  
   */
  function _pendingRewards() internal view returns(uint) {
    // Last drop user wanted
    uint _lastDropRegistered = lastDropRegistered[msg.sender];
    
    // If new account, no rewards
    if (_lastDropRegistered == 0) 
      return 0;

    // If drop requested has completed, accrue rewards
    if (_lastDropRegistered < currentDropIndex) {
      // Accrued = accrued + reward for last drop
      return _computeRewardMantissa(_lastDropRegistered);
    }
    else if (isDropOver()) {
      // Accrued = accrued + reward for last drop
      return _computeRewardMantissa(_lastDropRegistered);
    }
    else {
      return 0;
    }
  }
  
  /**
   * @notice Used to add rewards from last drop user was in to their accuedRewards balances 
   */
  function _accrueRewards() internal {
    uint pendingRewards = _pendingRewards();
     
    if (pendingRewards > 0) { 
      accruedRewards[msg.sender] = accruedRewards[msg.sender].add(pendingRewards);
      emit AccrueRewards(msg.sender, pendingRewards);
    }
  }

  /**
   * @notice Compute how much reward each participant in the drop received 
   */
  function _computeRewardMantissa(uint index) internal view returns(uint) {
    WantDrop memory wantDrop = wantDropState[index]; 
    
    // Total Reward / Total participants
    (MathError err, Exp memory reward) = divScalar(Exp({ mantissa: wantDrop.totalDrop }), wantDrop.numRegistrants);
    require(err == MathError.NO_ERROR, "ComputeReward() Division error");
    return reward.mantissa;
  }

//------------------------------
// Drop management
//------------------------------
  /**
   * @notice Sets up state for new drop state and drips from faucet if rewards getting low 
   */
  function _startNewDrop() internal {
    // Bump drop index
    currentDropIndex = currentDropIndex.add(1);
    
    // Update current drop start to now
    currentDropStartBlock = block.number;

    // Compute next drop reward 
    uint nextReward = _nextReward(currentReward);
    
    // Update global for total dropped
    totalDropped = totalDropped.add(nextReward);
    
    // Init next drop state
    wantDropState[currentDropIndex] = WantDrop({ 
      totalDrop:  nextReward,
      numRegistrants: 0
    });
   
    // Clear registrants
    delete accountsRegisteredForDrop; 

    // Update currentReward
    currentReward = nextReward;
  }
  
  /**
   * @notice Compute next drop reward, based on current reward 
   * @param _currentReward the current block reward for reference
   */
  function _nextReward(uint _currentReward) private view returns(uint) {
    if (currentDropIndex == 1) { 
      return initialReward; 
    }
    else {
      (MathError err, Exp memory newRewardExp) = mulExp(Exp({mantissa: discountFactor }), Exp({mantissa: _currentReward }));
      require(err == MathError.NO_ERROR);
      return newRewardExp.mantissa;
    }
  }

//------------------------------
// Receiving from faucet 
//------------------------------
  /**
   * @notice checks if balance is too low and needs to visit the WANT faucet 
   */
  function _needsDrip() internal view returns(bool) {
    EIP20Interface want = EIP20Interface(wantTokenAddress);
    uint curBalance = want.balanceOf(address(this));
    if (curBalance < currentReward || curBalance < accruedRewards[msg.sender]) {
      return true;
    }
    return false;
  }

  /**
   * @notice Receive WANT from the want. Attempts to get about 10x more than it needs to reduce need to call so frequently. 
   */
  function _dripFaucet() internal {
    EIP20Interface want = EIP20Interface(wantTokenAddress);
    uint faucetBlance = want.balanceOf(wantFaucetAddress);

    // Let's bulk drip for the next ~ 25 drops
    (MathError err, Exp memory toDrip) = mulScalar(Exp({ mantissa: currentReward }), 25);
    require(err == MathError.NO_ERROR);
    
    WantFaucet faucet = WantFaucet(wantFaucetAddress);
   
    if (toDrip.mantissa.add(faucetBlance) < accruedRewards[msg.sender]) {
      toDrip.mantissa = accruedRewards[msg.sender];
    }

    // If the facuet is ~empty, empty it 
    if (faucetBlance < toDrip.mantissa) {
      faucet.drip(faucetBlance);
    }
    else {
      faucet.drip(toDrip.mantissa);
    }
   }

///------------------------------------
// Admin functions: require governance
// ------------------------------------
  function _setWantFacuet(address newFacuetAddress) public  {
    require(adminOrInitializing());
    wantFaucetAddress = newFacuetAddress;
  }
  
  function _setWantAddress(address newWantAddress) public {
    require(adminOrInitializing());
    wantTokenAddress = newWantAddress;
  }
  
  function _setDiscountFactor(uint256 newDiscountFactor) public {
    require(adminOrInitializing());
    discountFactor = newDiscountFactor;
  }
  
  function _setWaitBlocks(uint256 newWaitBlocks) public {
    require(adminOrInitializing(), "not an admin");
    waitblocks = newWaitBlocks;
  }
  
  function _setCurrentReward(uint256 _currentReward) public {
    require(adminOrInitializing(), "not an admin");
    currentReward = _currentReward;
  }
  
  function _become(Unitroller unitroller) public {
      require(msg.sender == unitroller.admin(), "only unitroller admin can change brains");
      require(unitroller._acceptImplementation() == 0, "change not authorized"); 
  }

  /**
   * @notice Checks caller is admin, or this contract is becoming the new implementation
   */
  function adminOrInitializing() internal view returns (bool) {
      return msg.sender == admin || msg.sender == wanttrollerImplementation;
  }

  // Used for testing
  function tick() public {
  }
}

pragma solidity ^0.5.16;

import "./ErrorReporter.sol";
import "./WanttrollerStorage.sol";
/**
 * @title WanttrollerCore
 * @dev Storage for the wanttroller is at this address, while execution is delegated to the `wanttrollerImplementation`.
 */
contract Unitroller is UnitrollerAdminStorage, WanttrollerErrorReporter {

    /**
      * @notice Emitted when pendingWanttrollerImplementation is changed
      */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
      * @notice Emitted when pendingWanttrollerImplementation is accepted, which means wanttroller implementation is updated
      */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
      * @notice Emitted when pendingAdmin is changed
      */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
      * @notice Emitted when pendingAdmin is accepted, which means admin is updated
      */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() public {
        // Set admin to caller
        admin = msg.sender;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) public returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_OWNER_CHECK);
        }

        address oldPendingImplementation = pendingWanttrollerImplementation;

        pendingWanttrollerImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingWanttrollerImplementation);

        return uint(Error.NO_ERROR);
    }

    /**
    * @notice Accepts new implementation of wanttroller. msg.sender must be pendingImplementation
    * @dev Admin function for new implementation to accept it's role as implementation
    * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
    */
    function _acceptImplementation() public returns (uint) {
        // Check caller is pendingImplementation and pendingImplementation ≠ address(0)
        if (msg.sender != pendingWanttrollerImplementation || pendingWanttrollerImplementation == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK);
        }

        // Save current values for inclusion in log
        address oldImplementation = wanttrollerImplementation;
        address oldPendingImplementation = pendingWanttrollerImplementation;

        wanttrollerImplementation = pendingWanttrollerImplementation;

        pendingWanttrollerImplementation = address(0);

        emit NewImplementation(oldImplementation, wanttrollerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingWanttrollerImplementation);

        return uint(Error.NO_ERROR);
    }


    function _transferOwnership(address newAdmin) public returns (uint) {
        // Check caller = admin
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }
        emit NewAdmin(admin, newAdmin);
        admin = newAdmin;

        return uint(Error.NO_ERROR);
    }

    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _setPendingAdmin(address newPendingAdmin) public returns (uint) {
        // Check caller = admin
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return uint(Error.NO_ERROR);
    }

    /**
      * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
      * @dev Admin function for pending admin to accept role and update admin
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _acceptAdmin() public returns (uint) {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return uint(Error.NO_ERROR);
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    function () payable external {
        // delegate all other functions to current implementation
        (bool success, ) = wanttrollerImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize)

              switch success
              case 0 { revert(free_mem_ptr, returndatasize) }
              default { return(free_mem_ptr, returndatasize) }
        }
    }
}

pragma solidity ^0.5.16;

/**
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */
interface EIP20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    /**
      * @notice Get the total number of tokens in circulation
      * @return The supply of tokens
      */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gets the balance of the specified address
     * @param owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transfer(address dst, uint256 amount) external returns (bool success);

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);

    /**
      * @notice Approve `spender` to transfer up to `amount` from `src`
      * @dev This will overwrite the approval amount for `spender`
      *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
      * @param spender The address of the account which may transfer tokens
      * @param amount The number of tokens that are approved (-1 means infinite)
      * @return Whether or not the approval succeeded
      */
    function approve(address spender, uint256 amount) external returns (bool success);

    /**
      * @notice Get the current allowance from `owner` for `spender`
      * @param owner The address of the account which owns the tokens to be spent
      * @param spender The address of the account which may transfer tokens
      * @return The number of tokens allowed to be spent (-1 means infinite)
      */
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

pragma solidity ^0.5.16;

/**
  * @title Careful Math
  * @author Compound
  * @notice Derived from OpenZeppelin's SafeMath library
  *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
  */
contract CarefulMath {

    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    /**
    * @dev Multiplies two numbers, returns an error on overflow.
    */
    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
    * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
    */
    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
    * @dev Adds two numbers, returns an error on overflow.
    */
    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
    * @dev add a and b and then subtract c
    */
    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}
pragma solidity ^0.5.16;

contract WanttrollerErrorReporter {
    enum Error {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        UNAUTHORIZED
    }   

    enum FailureInfo {
      ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
      ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
      SET_PENDING_ADMIN_OWNER_CHECK,
      SET_PAUSE_GUARDIAN_OWNER_CHECK,
      SET_IMPLEMENTATION_OWNER_CHECK,
      SET_PENDING_IMPLEMENTATION_OWNER_CHECK
    }   

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event Failure(uint error, uint info, uint detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);
        return uint(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}


pragma solidity ^0.5.16;
import "./Exponential.sol";
import "./EIP20Interface.sol";
import "./SafeMath.sol";
contract WantFaucet is Exponential {
  using SafeMath for uint256;

  // Min time between drips 
  uint dripInterval = 200;

  address admin;
  address teamWallet; 

  address wantAddress;

  uint constant teamFactor = 0.01e18;

  constructor(address _admin, address _teamWallet, address _wantAddress) public {
    admin = _admin;
    teamWallet = _teamWallet;
    wantAddress = _wantAddress;
  }

  function setAdmin(address _admin) public {
    require(msg.sender == admin);
    admin = _admin;
  }

  function drip(uint amount) public {
    EIP20Interface want = EIP20Interface(wantAddress);
    require(msg.sender == admin, "drip(): Only admin may call this function");
    
    // Compute team amount: 1%
    (MathError err, Exp memory teamAmount) = mulExp(Exp({ mantissa: amount }), Exp({ mantissa: teamFactor }));
    require(err == MathError.NO_ERROR);
    
    // Check balance requested for withdrawal 
    require(amount.add(teamAmount.mantissa) < want.balanceOf(address(this)), "Insufficent balance for drip");
    
    // Transfer team amount
    bool success = want.transfer(teamWallet, teamAmount.mantissa); 
    require(success, "collectRewards(): Unable to send team tokens");
 
    // Transfer admin amount 
    success = want.transfer(admin, amount); 
    require(success, "collectRewards(): Unable to send admin tokens");
  }
}

pragma solidity ^0.5.16;
import "./Exponential.sol";
contract UnitrollerAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Unitroller
    */
    address public wanttrollerImplementation;

    /**
    * @notice Pending brains of Unitroller
    */
    address public pendingWanttrollerImplementation;
}
contract WanttrollerV1Storage is UnitrollerAdminStorage, Exponential {
  struct WantDrop {
    /// @notice Total accounts requesting piece of drop 
    uint numRegistrants;
    
    /// @notice Total amount to be dropped
    uint totalDrop;
  }

  // @notice Total amount dropped
  uint public totalDropped;
  
  // @notice Min time between drops
  uint public waitblocks = 200; 

  // @notice Tracks beginning of this drop 
  uint public currentDropStartBlock;
  
  // @notice Tracks the index of the current drop
  uint public currentDropIndex;
  
  /// @notice Store total registered and total reward for that drop 
  mapping(uint => WantDrop) public wantDropState;

  /// @notice Any WANT rewards accrued but not yet collected 
  mapping(address => uint) public accruedRewards;
  
  /// @notice Track the last drop this account was part of 
  mapping(address => uint) public lastDropRegistered;

  address wantTokenAddress;

  address[] public accountsRegisteredForDrop;

  /// @notice Stores the current amount of drop being awarded
  uint public currentReward;
  
  /// @notice Each time rewards are distributed next rewards reduced by applying this factor
  uint public discountFactor = 0.9995e18;

  // Store faucet address 
  address public wantFaucetAddress;
}

pragma solidity ^0.5.16;

import "./CarefulMath.sol";

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract Exponential is CarefulMath {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    /**
     * @dev Creates an exponential from numerator and denominator values.
     *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
     *            or if `denom` is zero.
     */
    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
     * @dev Adds two exponentials, returning a new exponential.
     */
    function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Subtracts two exponentials, returning a new exponential.
     */
    function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Multiply an Exp by a scalar, returning a new Exp.
     */
    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    /**
     * @dev Divide an Exp by a scalar, returning a new Exp.
     */
    function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
     * @dev Divide a scalar by an Exp, returning a new Exp.
     */
    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {
        /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)

          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
     * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
     */
    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    /**
     * @dev Multiplies two exponentials, returning a new exponential.
     */
    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    /**
     * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
     */
    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    /**
     * @dev Multiplies three exponentials, returning a new exponential.
     */
    function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    /**
     * @dev Divides two exponentials, returning a new exponential.
     *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
     *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
     */
    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

