/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

pragma solidity ^0.5.0;

/*
 * @dev provides information about the current execution context, including the
 * sender of the transaction and its data. while these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with gsn meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * this contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * this module is used through inheritance. it will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "caller is not beeg");
        _;
    }

    /**
     * @dev returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev leaves the contract without owner. it will not be possible to call
     * `onlyOwner` functions anymore. can only be called by the current owner.
     *
     * smol note: renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev transfers ownership of the contract to a new account (`newOwner`).
     * can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "new beeg is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev interface of the erc20 standard as defined in the eip. does not include
 * the optional functions; to access them see {erc20detailed}.
 */
interface IERC20 {
    /**
     * @dev returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev moves `amount` tokens from the caller's account to `recipient`.
     *
     * returns a boolean value indicating whether the operation succeeded.
     *
     * emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. this is
     * zero by default.
     *
     * this value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * returns a boolean value indicating whether the operation succeeded.
     *
     * rly beeg ting here: be aware that changing an allowance with this method brings
     * the risk that someone may use both the old and the new allowance by
     * unfortunate transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * returns a boolean value indicating whether the operation succeeded.
     *
     * emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title roles
 * @dev library for managing addresses assigned to a role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "smol guy does not have beeg role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

/**
 * @title safemath
 * @dev unsigned math operations with safety checks that revert on error
 */
library SafeMath {

    /**
     * @dev multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // gas optimization: this is cheeper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // see: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "safemath#mul: OVERFLOW");

        return c;
    }

    /**
     * @dev integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // solidity only automatically asserts when dividing by 0
        require(b > 0, "safemath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // there is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "safemath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "safemath#add: OVERFLOW");

        return c;
    }

    /**
     * @dev divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "safemath#mod: DIVISION_BY_ZERO");
        return a % b;
    }

}

/**
 * copyright 2018 zeroex intl.
 * licensed under the apache license, version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * you may obtain a copy of the License at
 *   http://www.apache.org/licenses/LICENSE-2.0
 * unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * see the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * utility library of inline functions on addresses
 */
library Address {

    /**
     * returns whether the target address is a contract
     * @dev this function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // XXX currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // see https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // todo check this again before the serenity release, because all addresses will be
        // contracts then.
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

}

contract CanTransferRole is Context {
    using Roles for Roles.Role;

    event CanTransferAdded(address indexed account);
    event CanTransferRemoved(address indexed account);

    Roles.Role private _canTransfer;

    constructor () internal {
        _addCanTransfer(_msgSender());
    }

    modifier onlyCanTransfer() {
        require(canTransfer(_msgSender()), "cant: caller is too smol");
        _;
    }

    function canTransfer(address account) public view returns (bool) {
        return _canTransfer.has(account);
    }

    function addCanTransfer(address account) public onlyCanTransfer {
        _addCanTransfer(account);
    }

    function renounceCanTransfer() public {
        _removeCanTransfer(_msgSender());
    }

    function _addCanTransfer(address account) internal {
        _canTransfer.add(account);
        emit CanTransferAdded(account);
    }

    function _removeCanTransfer(address account) internal {
        _canTransfer.remove(account);
        emit CanTransferRemoved(account);
    }
}

contract SmolTing is Ownable, MinterRole, CanTransferRole {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;
    uint256 private _totalClaimed;
    string public name = "smol ting";
    string public symbol = "TING";
    uint8 public decimals = 18;

    /**
     * @dev total number of tokens in existence.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // returns the total claimed smol
    // this is just purely used to display the total smol claimed by users on the frontend
    function totalClaimed() public view returns (uint256) {
        return _totalClaimed;
    }

    // add smol claimed
    function addClaimed(uint256 _amount) public onlyCanTransfer {
        _totalClaimed = _totalClaimed.add(_amount);
    }

    // set smol claimed to a custom value, for if we wanna reset the counter anytime
    function setClaimed(uint256 _amount) public onlyCanTransfer {
        require(_amount >= 0, "cannot be negative");
        _totalClaimed = _amount;
    }

    // as this token is non tradable, only minters are allowed to transfer tokens between accounts
    function transfer(address receiver, uint numTokens) public onlyCanTransfer returns (bool) {
        require(numTokens <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender].sub(numTokens);
        _balances[receiver] = _balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // as this token is non tradable, only minters are allowed to transfer tokens between accounts
    function transferFrom(address owner, address buyer, uint numTokens) public onlyCanTransfer returns (bool) {
        require(numTokens <= _balances[owner]);

        _balances[owner] = _balances[owner].sub(numTokens);
        _balances[buyer] = _balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    /**
     * @dev gets the balance of the specified address.
     * @param owner the address to query the balance of.
     * @return a uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function mint(address _to, uint256 _amount) public onlyMinter {
        _mint(_to, _amount);
    }

    function burn(address _account, uint256 value) public onlyCanTransfer {
        require(_balances[_account] >= value, "nope, cannot burn more than address has");
        _burn(_account, value);
    }

    /**
     * @dev internal function that mints an amount of the token and assigns it to
     * an account. this encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account the account that will receive the created tokens.
     * @param value the amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "erc20: mint to the zero address");

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev internal function that burns an amount of the token of a given
     * account.
     * @param account the account whose tokens will be burnt.
     * @param value the amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "erc20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}

/*
* @dev Contract from where the multiplier is taken.
*/
interface SmolMuseum {
    function getBoosterForUser(address _address, uint256 _pid) external view returns (uint256);
}

contract SmolTingPot is Ownable {
    using SafeMath for uint256;

    // info of each user.
    struct UserInfo {
        uint256 amount; // how many tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // we do some fancy math here. basically, any point in time, the amount of TINGs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTingPerShare) - user.rewardDebt
        //
        // whenever a user deposits or withdraws tokens to a pool. Here's what happens:
        //   1. user's pending reward is minted to his/her address.
        //   2. user's `amount` gets updated.
        //   3. user's `lastUpdate` gets updated.
    }

    // info of each pool.
    struct PoolInfo {
        IERC20 token; // address of token contract.
        uint256 tingsPerDay; // the amount of TINGs per day generated for each token staked
        uint256 maxStake; // the maximum amount of tokens which can be staked in this pool
        uint256 lastUpdateTime; // last timestamp that TINGs distribution occurs.
        uint256 accTingPerShare; // accumulated TINGs per share, times 1e12. See below.
    }

    // treasury address.
    address public treasuryAddr;
    // info of each pool.
    PoolInfo[] public poolInfo;
    // info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // record whether the pair has been added.
    mapping(address => uint256) public tokenPID;

    SmolTing public Ting;
    SmolMuseum public Museum;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(SmolTing _tingAddress, SmolMuseum _smolMuseumAddress, address _treasuryAddr) public {
        Ting = _tingAddress;
        Museum = _smolMuseumAddress;
        treasuryAddr = _treasuryAddr;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // add a new token to the pool. can only be called by the owner.
    // XXX DO NOT add the same token more than once. rewards will be messed up if you do.
    function add(IERC20 _token, uint256 _tingsPerDay, uint256 _maxStake) public onlyOwner {
        require(tokenPID[address(_token)] == 0, "smoltingpot:duplicate add.");
        require(address(_token) != address(Ting), "cannot add ting as a pool" );
        poolInfo.push(
            PoolInfo({
                token: _token,
                maxStake: _maxStake,
                tingsPerDay: _tingsPerDay,
                lastUpdateTime: block.timestamp,
                accTingPerShare: 0
            })
        );
        tokenPID[address(_token)] = poolInfo.length;
    }

    // set a new max stake. value must be greater than previous one,
    // to not give an unfair advantage to people who already staked > new max
    function setMaxStake(uint256 pid, uint256 amount) public onlyOwner {
        require(amount >= 0, "max stake cannot be negative");
        poolInfo[pid].maxStake = amount;
    }

    // set the amount of TINGs generated per day for each token staked
    function setTingsPerDay(uint256 pid, uint256 amount) public onlyOwner {
        require(amount >= 0, "hey smol tings per day cannot be negative");
        PoolInfo storage pool = poolInfo[pid];
        uint256 blockTime = block.timestamp;
        uint256 tingReward = blockTime.sub(pool.lastUpdateTime).mul(pool.tingsPerDay);

        pool.accTingPerShare = pool.accTingPerShare.add(tingReward.mul(1e12).div(86400));
        pool.lastUpdateTime = block.timestamp;
        pool.tingsPerDay = amount;
    }

    function _pendingTing(uint256 _pid, address _user) internal view returns (uint256[2] memory) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 blockTime = block.timestamp;
        uint256 accTing = pool.accTingPerShare;

        uint256 tingReward = blockTime.sub(pool.lastUpdateTime).mul(pool.tingsPerDay);
        accTing = accTing.add(tingReward.mul(1e12).div(86400));                    
    
        uint256 pending = user.amount.mul(accTing).div(1e12).sub(user.rewardDebt);
        return [pending, accTing];
    }

    // view function to see pending TINGs on frontend.
    function pendingTing(uint256 _pid, address _user) public view returns (uint256) {
        uint256 pending = _pendingTing(_pid, _user)[0];
        if (Museum.getBoosterForUser(_user, _pid) > 0) pending = pending.mul(Museum.getBoosterForUser(_user, _pid).add(1));
        return pending;
    }


    // view function to calculate the total pending TINGs of address across all pools
    function totalPendingTing(address _user) public view returns (uint256) {
        uint256 total = 0;
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            total = total.add(pendingTing(pid, _user));
        }

        return total;
    }

    // harvest pending TINGs of a list of pools.
    // be careful of beeg gas spending if you try to harvest a big number of pools
    // might be worth it checking in the frontend for the pool IDs with pending ting for this address and only harvest those
    function rugPull(uint256[] memory _pids) public {
        for (uint i=0; i < _pids.length; i++) {
            withdraw(_pids[i], 0, msg.sender);
        }
    }


    // deposit LP tokens to pool for TING allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(_amount.add(user.amount) <= pool.maxStake, "cannot stake beyond max stake value");

        uint256 pending = _pendingTing(_pid, msg.sender)[0];
        uint256 accTing = _pendingTing(_pid, msg.sender)[1];
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(accTing).div(1e12);

        uint256 pendingWithBooster = pending.mul(Museum.getBoosterForUser(msg.sender, _pid).add(1));
        if (pendingWithBooster > 0) {
            Ting.mint(treasuryAddr, pendingWithBooster.div(40)); // 2.5% TING for the treasury (usable to purchase NFTs)
            Ting.mint(msg.sender, pendingWithBooster);
            Ting.addClaimed(pendingWithBooster);
        }

        pool.token.transferFrom(address(msg.sender), address(this), _amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // withdraw tokens from pool.
    function withdraw(uint256 _pid, uint256 _amount, address _staker) public {
        address staker = _staker;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][staker];
        require(user.amount >= _amount, "withdraw: not good");
        require(msg.sender == staker || _amount == 0);

        uint256 pending = _pendingTing(_pid, staker)[0];
        uint256 accTing = _pendingTing(_pid, staker)[1];

        // in case the maxstake has been lowered and address is above maxstake, we force it to withdraw what is above current maxstake
        // user can delay his/her withdraw/harvest to take advantage of a reducing of maxstake,
        // if he/she entered the pool at maxstake before the maxstake reducing occured
        uint256 leftAfterWithdraw = user.amount.sub(_amount);
        if (leftAfterWithdraw > pool.maxStake) {
            _amount = _amount.add(leftAfterWithdraw - pool.maxStake);
        }

        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(accTing).div(1e12);

        uint256 pendingWithBooster = pending.mul(Museum.getBoosterForUser(staker, _pid).add(1));
        if(pendingWithBooster > 0)
        {
            Ting.mint(treasuryAddr, pendingWithBooster.div(40));
            Ting.mint(staker, pendingWithBooster);
            Ting.addClaimed(pendingWithBooster);
        }

        pool.token.transfer(address(staker), _amount);
        emit Withdraw(staker, _pid, _amount);
    }

    // withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "emergncy withdrawal not good");
        uint256 _amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.token.transfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }


    // update dev address by the previous dev.
    function treasury(address _treasuryAddr) public {
        require(msg.sender == treasuryAddr, "must be called from current treasury address");
        treasuryAddr = _treasuryAddr;
    }

    // update Museum address if the booster logic changed.
    function updateSmolMuseumAddress(SmolMuseum _smolMuseumAddress) public onlyOwner{
        Museum = _smolMuseumAddress;
    }
}