/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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


/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

//------------------------------------------------------------------------------
//
//   Copyright 2018-2019 Fetch.AI Limited
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//------------------------------------------------------------------------------
contract NativeToEthMigration is Ownable {
    using SafeMath for uint256;

    struct Swap {
        bytes32 fetTxHash;
        address ethAddress;
        uint256 amount;
    }

    struct Records {
        uint256 migFETAmountSealed;
        uint256 migFETAmountEpoch;
        uint256 sealedSwpId;
        uint256 numSuccMigrationsSealed;
        uint128 numSuccMigrationsEpoch;
        uint128 epochLength;
    }

    // swap id => swap
    mapping(uint256 => Swap) public swaps;
    // fet tx hash => swapID
    mapping(bytes32 => uint256) public processedFetTxs;
    mapping(address => bool) public delegates;
    ERC20 public token;
    Records public records;
    uint256 public pausedSinceSwapId;

    /* Simple length check. Length of FET addresses seem to be either 49 or
        50 bytes. Adding a slight margin to this. A proper checksum validation would require a base58
        decoder.*/
    modifier isFetchAddress(string memory _address) {
        require(bytes(_address).length > 47, "Address too short");
        require(bytes(_address).length < 52, "Address too long");
        _;
    }

    /* Only callable by owner or delegate */
    modifier onlyDelegate() {
        require(isOwner() || delegates[msg.sender], "Caller is neither owner nor delegate");
        _;
    }

    event Migration(uint256 indexed swapID, bytes32 indexed fetTxHash, address indexed ethAddress, string fetAddress, uint256 amount);
    event PauseSince(uint256 swapID);
    event EpochSealed(uint256 sealedSwpId);
    event ChangeDelegate(address delegate, bool isDelegate);
    event TokenWithdrawal(address targetAddress, uint256 amount);
    event DeleteContract();

    /*******************
    Contract start
    *******************/
    /**
     * @param ERC20Address address of the ERC20 contract
     * @param epochLength length of an epoch. Etch contract uses 64
     */
    constructor(address ERC20Address, uint128 epochLength) public {
        token = ERC20(ERC20Address);
        pausedSinceSwapId = 2**255;
        // keep possible epochLengths small enough to ensure migFETAmountEpoch can never overflow
        require(epochLength <= 256, "Epoch length too high");
        records.epochLength = epochLength;
    }

    function _updateMigrationStatusAtSeal()
    internal
    {
        records.sealedSwpId = records.sealedSwpId.add(records.epochLength);
        records.numSuccMigrationsSealed = records.numSuccMigrationsSealed.add(records.numSuccMigrationsEpoch);
        records.migFETAmountSealed = records.migFETAmountSealed.add(records.migFETAmountEpoch);

        records.numSuccMigrationsEpoch = 0;
        records.migFETAmountEpoch = 0;

        emit EpochSealed(records.sealedSwpId);
    }

    function _updateMigrationStatus(uint256 amount)
    internal
    {
        require(records.numSuccMigrationsEpoch + 1 <= records.epochLength, "Number of successful swaps in epoch exceeds predefined epoch length");

        // could safe a little gas by not increasing this here if _updateMigrationStatusAtSeal() is
        // but savings don't seem to justify reduced readibility
        records.numSuccMigrationsEpoch += 1;
        records.migFETAmountEpoch += amount;

        if (records.numSuccMigrationsEpoch == records.epochLength){
            _updateMigrationStatusAtSeal();
        }
    }

    /**
     * @notice Record a swap and transfer the erc20 tokens.
     */
    function migrate(uint256 swapID,
                     bytes32 fetTxHash,
                     address ethAddress,
                     string calldata fetAddress,
                     uint256 amount,
                     uint256 expirationBlock)
    external
    onlyDelegate()
    isFetchAddress(fetAddress)
    {
        require(block.number <= expirationBlock, "Transaction expired");
        // boundary checks
        require(swapID < pausedSinceSwapId, "Contract is paused since earlier swap_id");
        require(swapID >= records.sealedSwpId, "SwapId is below sealedSwpId");
        require(swapID < records.sealedSwpId.add(records.epochLength), "SwapId is out of epoch range");
        // input checks
        require(swaps[swapID].ethAddress == address(0), "Swap already recorded");
        require(ethAddress != address(0), "null ethAddress");
        require(fetTxHash != "", "null fetTxHash");
        require((processedFetTxs[fetTxHash] == 0) && (fetTxHash != swaps[0].fetTxHash), "fetTxHash already recorded for a swap");

        processedFetTxs[fetTxHash] = swapID;
        // not storing the fetAddress on-chain: no simple way to slice the first 32 bytes out of the
        // address and can be easily derived from the fetTxHash. Does get logged in the event.
        swaps[swapID] = Swap({fetTxHash: fetTxHash,
                              ethAddress: ethAddress,
                              amount: amount});

        _updateMigrationStatus(amount);

        require(token.transfer(ethAddress, amount));

        emit Migration(swapID, fetTxHash, ethAddress, fetAddress, amount);
    }

    /**
     * @notice Manually seal the epoch
     * @dev Only required if some swaps in the epoch have been rejected
     */
    function sealEpoch(uint256 newEpochSwapID,
                       uint128 expectedNumberOfSuccessfulMigrationInEpoch,
                       uint256 expectedMigratedFetAmountInEpoch)
    external
    onlyDelegate()
    {
        require(records.sealedSwpId.add(records.epochLength) == newEpochSwapID, "Unexpected swapID for epoch sealing");
        require(records.numSuccMigrationsEpoch == expectedNumberOfSuccessfulMigrationInEpoch, "Unexpected number of successful migrations in epoch");
        require(records.migFETAmountEpoch == expectedMigratedFetAmountInEpoch, "Unexpected amount of migrated FET in epoch");

        require(newEpochSwapID <= pausedSinceSwapId, "Contract is paused since earlier swap_id");
        _updateMigrationStatusAtSeal();
    }

    /**
     * @notice Pause the migrate method, not allowing new migrations
     * @param swapID disallow migrations with a swapID >= swapID
     * @dev Delegate only
     */
    function pauseSince(uint256 swapID)
    external
    onlyDelegate()
    {
        pausedSinceSwapId = swapID;
        emit PauseSince(swapID);
    }

    /**
     * @notice Add or remove a delegate address that is allowed to confirm and reject transactions
     * @param _address address of the delegate
     * @param isDelegate whether to add or remove the address from the delegates set
     * @dev Owner only
     */
    function setDelegate(address _address, bool isDelegate)
    external
    onlyOwner()
    {
        delegates[_address] = isDelegate;
        emit ChangeDelegate(_address, isDelegate);
    }

    /**
     * @notice Withdraw token balance
     * @param amount amount to withdraw
     * @param targetAddress address to send the tokens to
     * @dev to topup the contract simply send tokens to the contract address
     */
    function withDrawTokens(uint256 amount, address payable targetAddress)
    external
    onlyOwner()
    {
        require(token.transfer(targetAddress, amount));
        emit TokenWithdrawal(targetAddress, amount);
    }

    /**
     * @notice Delete the contract, transfers the remaining token and ether balance to the specified
       payoutAddress
     * @param payoutAddress address to transfer the balances to. Ensure that this is able to handle ERC20 tokens
     * @dev owner only
     */
    function deleteContract(address payable payoutAddress)
    external
    onlyOwner()
    {
        uint256 contractBalance = token.balanceOf(address(this));
        require(token.transfer(payoutAddress, contractBalance));
        emit DeleteContract();
        selfdestruct(payoutAddress);
    }
}