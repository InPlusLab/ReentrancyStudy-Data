/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity ^0.6.0;


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
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

//https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
interface IERC900 {
    event Staked(address indexed addr, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed addr, uint256 amount, uint256 total, bytes data);

    function stake(uint256 amount, bytes calldata data) external;
    function stakeFor(address addr, uint256 amount, bytes calldata data) external;
    function unstake(uint256 amount, bytes calldata data) external;
    function totalStakedFor(address addr) external view returns (uint256);
    function totalStaked() external view returns (uint256);
    function token() external view returns (address);
    function supportsHistory() external pure returns (bool);

    // optional
    //function lastStakedFor(address addr) public view returns (uint256);
    //function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256);
    //function totalStakedAt(uint256 blockNumber) public view returns (uint256);
}

interface IDistributable {
    function distribute() external payable;
}

interface IDistributableERC20 {
    function distribute(uint256 amount) external;
}

/**
 * An IERC900 staking contract
 */
contract Staking is IERC900, IDistributable {
    using SafeMath for uint256;

    uint256 PRECISION;

    event Profit(uint256 amount);

    uint256 public bond_value;
    //just for info
    uint256 public investor_count;

    uint256 private _total_staked;
    // the amount of dust left to distribute after the bond value has been updated
    uint256 public to_distribute;
    mapping(address => uint256) private _bond_value_addr;
    mapping(address => uint256) private _stakes;

    /// @dev handle to access ERC20 token token contract to make transfers
    IERC20 private _token;

    constructor(address token_address, uint256 decimals) public {
        _token = IERC20(token_address);
        PRECISION = 10**decimals;
    }
    
    /**
        @dev Stakes a certain amount of tokens, this MUST transfer the given amount from the addr
        @param amount Amount of ERC20 token to stake
        @param data Additional data as per the EIP900
    */
    function stake(uint256 amount, bytes calldata data) external override {
        //transfer the ERC20 token from the addr, he must have set an allowance of {amount} tokens
        require(_token.transferFrom(msg.sender, address(this), amount), "ERC20 token transfer failed, did you forget to create an allowance?");
        _stakeFor(msg.sender, amount, data);
    }

    /**
        @dev Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
        @param addr Address who will own the stake afterwards
        @param amount Amount of ERC20 token to stake
        @param data Additional data as per the EIP900
    */
    function stakeFor(address addr, uint256 amount, bytes calldata data) external override {
        //transfer the ERC20 token from the addr, he must have set an allowance of {amount} tokens
        require(_token.transferFrom(msg.sender, address(this), amount), "ERC20 token transfer failed, did you forget to create an allowance?");
        //create the stake for this amount
        _stakeFor(addr, amount, data);
    }

    /**
        @dev Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the addr, if unstaking is currently not possible the function MUST revert
        @param amount Amount of ERC20 token to remove from the stake
        @param data Additional data as per the EIP900
    */
    function unstake(uint256 amount, bytes calldata data) external override {
        _unstake(amount, data);
        //make the transfer
        require(_token.transfer(msg.sender, amount),"ERC20 token transfer failed");
    }

     /**
        @dev Withdraws rewards (basically unstake then restake)
        @param amount Amount of ERC20 token to remove from the stake
    */
    function withdraw(uint256 amount) external {
        _unstake(amount, "0x");
        _stakeFor(msg.sender, amount, "0x");
    }

    /**
        @dev Called by contracts to distribute dividends
        Updates the bond value
    */
    function distribute() external payable override virtual {
        _distribute(msg.value);
    }

    /**
        @dev Called by contracts to distribute dividends
        Updates the bond value
    */
    function _distribute(uint256 amount) internal {
        //cant distribute when no stakers
        require(_total_staked > 0, "cant distribute when no stakers");
        //take into account the dust
        uint256 temp_to_distribute = to_distribute.add(amount);
        uint256 total_bonds = _total_staked.div(PRECISION);
        uint256 bond_increase = temp_to_distribute.div(total_bonds);
        uint256 distributed_total = total_bonds.mul(bond_increase);
        bond_value = bond_value.add(bond_increase);
        //collect the dust
        to_distribute = temp_to_distribute.sub(distributed_total);
        emit Profit(amount);
    }

    /**
        @dev Returns the current total of tokens staked for an address
        @param addr address owning the stake
        @return the total of staked tokens of this address
    */
    function totalStakedFor(address addr) external view override returns (uint256) {
        return _stakes[addr];
    }
    
    /**
        @dev Returns the current total of tokens staked
        @return the total of staked tokens
    */
    function totalStaked() external view override returns (uint256) {
        return _total_staked;
    }

    /**
        @dev Address of the token being used by the staking interface
        @return ERC20 token token address
    */
    function token() external view override returns (address) {
        return address(_token);
    }

    /**
        @dev MUST return true if the optional history functions are implemented, otherwise false
        We dont want this
    */
    function supportsHistory() external pure override returns (bool) {
        return false;
    }

    /**
        @dev Returns how much ETH the user can withdraw currently
        @param addr Address of the user to check reward for
        @return the amount of ETH addr will perceive if he unstakes now
    */
    function getReward(address addr) public view returns (uint256) {
        return _getReward(addr,_stakes[addr]);
    }

    /**
        @dev Returns how much ETH the user can withdraw currently
        @param addr Address of the user to check reward for
        @param amount Number of stakes
        @return the amount of ETH addr will perceive if he unstakes now
    */
    function _getReward(address addr, uint256 amount) internal view returns (uint256) {
        return amount.mul(bond_value.sub(_bond_value_addr[addr])).div(PRECISION);
    }

    /**
        @dev Internally unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the addr, if unstaking is currently not possible the function MUST revert
        @param amount Amount of ERC20 token to remove from the stake
        @param data Additional data as per the EIP900
    */
    function _unstake(uint256 amount, bytes memory data) internal {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= _stakes[msg.sender], "You dont have enough staked");
        uint256 to_reward = _getReward(msg.sender, amount);
        _total_staked = _total_staked.sub(amount);
        _stakes[msg.sender] = _stakes[msg.sender].sub(amount);
        if(_stakes[msg.sender] == 0) {
            investor_count--;
        }
        //take into account dust error during payment too
        if(address(this).balance >= to_reward) {
            msg.sender.transfer(to_reward);
        } else {
            //we cant pay the dust error, just void the balance
            msg.sender.transfer(address(this).balance);
        }
        
        emit Unstaked(msg.sender, amount, _total_staked, data);
    }

    /**
        @dev Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
        @param addr Address who will own the stake afterwards
        @param amount Amount of ERC20 token to stake
        @param data Additional data as per the EIP900
    */
    function _stakeFor(address addr, uint256 amount, bytes memory data) internal {
        require(amount > 0, "Amount must be greater than zero");
        require(addr != address(0));
        _total_staked = _total_staked.add(amount);
        if(_stakes[addr] == 0) {
            investor_count++;
        }

        uint256 accumulated_reward = getReward(addr);
        _stakes[addr] = _stakes[addr].add(amount);
        
        uint256 new_bond_value = accumulated_reward.div(_stakes[addr].div(PRECISION));
        _bond_value_addr[addr] = bond_value.sub(new_bond_value);
        emit Staked(msg.sender, amount, _total_staked, data);
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
* Allows a contract to have admin rights on changing some config values
*/
abstract contract Configurable is Ownable {

    event ConfigChanged(bytes32 name, uint256 new_value);
    // config
	mapping(bytes32 => uint256) public config;

    constructor() public
    Ownable() {
    }

    /**
        @dev Sets a config value
		@param name Name of the value
        @param new_value The value to write in the config
    */
    function setConfigValue(bytes32 name, uint256 new_value) public virtual
    onlyOwner() {
        config[name] = new_value;
        emit ConfigChanged(name, new_value);
    }
}

/**
 * An IERC900 staking contract
 */
contract TribeStaking is Staking, Configurable {
    using SafeMath for uint256;

    IDistributable public KnightsAddress;
    address payable public PlincAddress;

    constructor(address tribe_address, address knights_address, address payable plinc_address) public
    Staking(tribe_address, 18)
    Configurable()
    {
        KnightsAddress = IDistributable(knights_address);
        PlincAddress = plinc_address;
        //plinc and dev shares permill
        config["PLINC_SHARE"] = 20;
        config["DEV_SHARE"] = 200;
    }
    /**
        @dev Called by contracts to distribute dividends
        Updates the bond value
    */
    function distribute() external payable override {
        uint256 total = msg.value;
        //compute plinc and dev net share and send it directly
        uint256 plinc = msg.value.div(1000).mul(config["PLINC_SHARE"]);
        uint256 dev = msg.value.div(1000).mul(config["DEV_SHARE"]);
        KnightsAddress.distribute{value : dev}();
        PlincAddress.transfer(plinc);
        //distribute to stakers
        super._distribute(total.sub(plinc).sub(dev));
    }
}