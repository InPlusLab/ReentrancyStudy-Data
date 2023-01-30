/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IAward {
    function addFreeAward(address _user, uint256 _amount) external;
    function addAward(address _user, uint256 _amount) external;
    function withdraw(uint256 _amount) external;
    function destroy(uint256 amount) external;
}

interface IERC20Token is IERC20 {
    function maxSupply() external view returns (uint256);
    function issue(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}

interface ILPMining {
    function add(address pool, uint256 index, uint256 allocP) external;
    function set(uint256 pid, uint256 allocPoint) external;
    function updateReferenceToken(uint256 pid, uint256 rIndex) external;
    function batchSharePools() external;
    function onTransferLiquidity(address from, address to, uint256 lpAmount) external;
    function claimUserShares(uint pid, address user) external;
    function claimLiquidityShares(address user, address[] calldata tokens, uint256[] calldata balances, uint256[] calldata weights, uint256 amount, bool _add) external;
}

interface IOracle {
    function requestTokenPrice(address token) external returns(uint8 decimal, uint256 price);
}

interface IPool is IERC20 {
    function getCurrentTokens() external view returns (address[] memory);
    function getNormalizedWeight(address token) external view returns (uint);
    function getBalance(address token) external view returns (uint);
}

contract LPMiningV1 is ILPMining, Ownable {

    using SafeMath for uint256;

    struct ShareInfo {
        uint256 tvl;
        uint256 accPoolPerShare;
        uint256 lastRewardBlock;
    }

    struct PoolInfo {
        IPool mPool;
        //reference currency for tvl calculation
        uint256 poolIndex;
        uint256 referIndex;
        uint256 allocPoint;       // How many allocation points assigned to this pool. token to distribute per block.
        uint256 lastTvl;
        uint256 accTokenPerShare;
        uint256 rewardDebt;
        address[] tokens;
        uint256[] balances;
        uint256[] weights;
    }

    struct UserInfo {
        uint256 rewardDebt;
    }

    // pool info
    address[] public pools;
    mapping(address => PoolInfo) public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // top share info
    ShareInfo public shareInfo;

    // contract governors
    mapping(address => bool) private governors;
    modifier onlyGovernor{
        require(governors[_msgSender()], "LPMiningV1: caller is not the governor");
        _;
    }

    IOracle public priceOracle;
    // The block number when Token mining starts.
    uint256 immutable public startBlock;
    // The block number when triple rewards mining ends.
    uint256 immutable public endTripleBlock;
    // The block number when Token mining ends.
    uint256 public endBlock;

    // tokens created per block changed with Token price.
    uint256 public tokenPerBlock = 15 * 10 ** 17;

    // award
    IAward  public award;

    event Initialization(address award, uint256 _tokenPerBlock, uint256 startBlock, uint256 endTripleBlock, uint256 endBlock, address oracle);
    event Add(address mPool, uint256 index, uint256 allocP);
    event Set(uint256 pid, uint256 allocPoint);
    event ReferCurrencyChanged(address pool, uint256 oldIndex, uint256 newIndex);
    event ClaimLiquidityShares(address pool, address user, uint256 rewards);
    event ClaimUserShares(uint pid, address user, uint256 rewards);
    event OnTransferLiquidity(address from, address to, uint256 lpAmount, uint256 fromAwards, uint256 toAwards);

    // init LPMiningV1
    // constructor params
    constructor(
        address _award,
        uint256 _tokenPerBlock,
        uint256 _startBlock,
        uint256 _endTripleBlock,
        uint256 _endBlock,
        address _oracle
    ) public {
        require(_award != address(0), "LPMiningV1: award invalid");
        require(_startBlock < _endTripleBlock && _endTripleBlock < _endBlock, "LPMiningV1: blocks range invalid");
        require(_oracle != address(0), "LPMiningV1: oracle invalid");
        award = IAward(_award);
        tokenPerBlock = _tokenPerBlock;
        endTripleBlock = _endTripleBlock;
        governors[_msgSender()] = true;
        startBlock = _startBlock;
        endBlock = _endBlock;
        shareInfo.lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        priceOracle = IOracle(_oracle);
        emit Initialization(_award, _tokenPerBlock, _startBlock, _endTripleBlock, _endBlock, _oracle);
    }

    function poolIn(address pool) view public returns (bool){
        if (address(poolInfo[pool].mPool) == address(0)) {
            return false;
        }
        return true;
    }

    function indexOfPool(address pool) view public returns (uint256){
        if (poolIn(pool)) {
            return poolInfo[pool].poolIndex;
        }
        return uint256(- 1);
    }

    function setEndBlock(uint256 _endBlock) onlyOwner external{
        endBlock = _endBlock;
    }

    // add pool
    function add(address pool, uint256 index, uint256 allocP) override onlyGovernor external {
        require(!poolIn(pool), "LPMiningV1: pool duplicate");
        require(pools.length.add(1) < uint256(- 1), "LPMiningV1: pools list overflow");
        IPool pPool = IPool(pool);
        require(index < pPool.getCurrentTokens().length, "LPMiningV1: reference token not exist");
        address[] memory tokens = pPool.getCurrentTokens();
        uint256[] memory _balances = new uint256[](tokens.length);
        uint256[] memory _weights = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            _balances[i] = pPool.getBalance(tokens[i]);
            _weights[i] = pPool.getNormalizedWeight(tokens[i]);
        }
        poolInfo[pool] = PoolInfo({
        mPool : pPool,
        poolIndex : pools.length,
        referIndex : index,
        lastTvl : 0,
        allocPoint : allocP,
        accTokenPerShare : 0,
        rewardDebt : 0,
        tokens : tokens,
        balances : _balances,
        weights : _weights
        });
        pools.push(pool);
        updateRewards();
        sharePoolRewards(poolInfo[pool]);
        emit Add(pool, index, allocP);
    }

    function set(uint256 pid, uint256 allocPoint) override onlyGovernor external {
        require(pid < pools.length, "LPMiningV1: pool not exist");
        PoolInfo storage info = poolInfo[pools[pid]];
        poolInfo[pools[pid]].allocPoint = allocPoint;
        updateRewards();
        sharePoolRewards(info);
        emit Set(pid, allocPoint);
    }

    // add governor
    function addGovernor(address governor) onlyOwner external {
        governors[governor] = true;
    }
    // remove governor
    function removeGovernor(address governor) onlyOwner external {
        governors[governor] = false;
    }

    function updateOracle(address oracle) onlyGovernor external {
        require(oracle != address(0), "LPMiningV1: oracle invalid");
        priceOracle = IOracle(oracle);
    }

    // batch share pool rewards
    function batchSharePools() override external {
        updateRewards();
        for (uint i = 0; i < pools.length; i = i.add(1)) {
            sharePoolRewards(poolInfo[pools[i]]);
        }
    }

    // update award
    function updateAward(address _award) external onlyOwner {
        require(_award != address(0), "LPMiningV1: award invalid");
        award = IAward(_award);
    }

    // update Reference token index
    function updateReferenceToken(uint256 pid, uint256 rIndex) override onlyGovernor external {
        require(pid < pools.length, "LPMiningV1: pool not exist");
        address pool = pools[pid];
        require(rIndex < IPool(pool).getCurrentTokens().length, "LPMiningV1: reference token not exist");
        PoolInfo storage info = poolInfo[pool];
        uint256 old = info.referIndex;
        info.referIndex = rIndex;
        updateRewards();
        sharePoolRewards(info);
        emit ReferCurrencyChanged(pool, old, rIndex);
    }

    function claimUserShares(uint pid, address user) override external {
        require(pid < pools.length, "LPMiningV1: pool not exist");
        uint256 rewards = calUserRewards(pid, user, 0, true);
        if (rewards > 0) {
            award.addAward(user, rewards);
        }
        emit ClaimUserShares(pid, user, rewards);
    }

    function claimLiquidityShares(address user, address[] calldata tokens, uint256[] calldata balances, uint256[] calldata weights, uint256 amount, bool _add) override external {
        uint256 pid = indexOfPool(msg.sender);
        if (pid != uint256(- 1)) {
            PoolInfo storage pool = poolInfo[msg.sender];
            pool.tokens = tokens;
            pool.balances = balances;
            pool.weights = weights;
            uint256 rewards = calUserRewards(pid, user, amount, _add);
            if (rewards > 0) {
                award.addAward(user, rewards);
            }
            emit ClaimLiquidityShares(msg.sender, user, rewards);
        }
    }

    // View function to see  pool and user's pending Token on frontend.
    function pendingShares(uint256 pid, address user) public view returns (uint256) {
        PoolInfo memory info = poolInfo[pools[pid]];
        UserInfo memory uinfo = userInfo[pid][user];
        if (info.mPool.totalSupply() == 0 || shareInfo.tvl == 0 || shareInfo.lastRewardBlock >= block.number) {
            return 0;
        }

        uint256 accPoolPerShare = shareInfo.accPoolPerShare;
        uint256 multiplier = getMultiplier(shareInfo.lastRewardBlock, block.number);
        uint256 rewards = multiplier.mul(tokenPerBlock).mul(1e18).div(shareInfo.tvl);
        accPoolPerShare = accPoolPerShare.add(rewards);

        uint256 accTokenPerShare = info.accTokenPerShare;
        rewards = accPoolPerShare.mul(info.lastTvl).sub(info.rewardDebt).div(info.mPool.totalSupply());
        accTokenPerShare = accTokenPerShare.add(rewards);
        return accTokenPerShare.mul(info.mPool.balanceOf(user)).sub(uinfo.rewardDebt).div(1e18);
    }

    function onTransferLiquidity(address from, address to, uint256 lpAmount) override external {
        uint256 pid = indexOfPool(msg.sender);
        if (pid != uint256(- 1)) {
            uint256 fromAwards = calUserRewards(pid, from, lpAmount, false);
            uint256 toAwards = calUserRewards(pid, to, lpAmount, true);
            if (fromAwards > 0) {
                if (Address.isContract(from)) {
                    award.destroy(fromAwards);
                } else {
                    award.addAward(from, fromAwards);
                }
            }
            if (toAwards > 0) {
                if (Address.isContract(to)) {
                    award.destroy(toAwards);
                } else {
                    award.addAward(to, toAwards);
                }
            }
            emit OnTransferLiquidity(from, to, lpAmount, fromAwards, toAwards);
        }
    }

    //cal pending rewards per tvl of pools
    function updateRewards() private {
        if (shareInfo.tvl > 0 && block.number > shareInfo.lastRewardBlock) {
            uint256 multiplier = getMultiplier(shareInfo.lastRewardBlock, block.number);
            uint256 rewards = multiplier.mul(tokenPerBlock).mul(1e18).div(shareInfo.tvl);
            shareInfo.accPoolPerShare = shareInfo.accPoolPerShare.add(rewards);
        }
        shareInfo.lastRewardBlock = block.number > startBlock ? block.number : startBlock;
    }

    //cal pending rewards for given pool
    function sharePoolRewards(PoolInfo storage info) private {
        _sharePoolRewards(info, 0, true);
    }

    //cal pending rewards for given pool
    function _sharePoolRewards(PoolInfo storage info, uint256 lpAmount, bool _add) private {
        uint newTotalLiquidity = info.mPool.totalSupply();
        uint lastTotalLiquidity = _add ? newTotalLiquidity.sub(lpAmount) : newTotalLiquidity.add(lpAmount);
        if (lastTotalLiquidity > 0) {
            uint256 rewards = shareInfo.accPoolPerShare.mul(info.lastTvl).sub(info.rewardDebt).div(lastTotalLiquidity);
            info.accTokenPerShare = info.accTokenPerShare.add(rewards);
        }
        uint256 newTvl = getPoolTvl(info);
        info.rewardDebt = shareInfo.accPoolPerShare.mul(newTvl);
        shareInfo.tvl = shareInfo.tvl.add(newTvl).sub(info.lastTvl);
        info.lastTvl = newTvl;
    }

    // cal user shares
    function calUserRewards(uint256 pid, address user, uint256 lpAmount, bool _add) private returns (uint256){
        updateRewards();
        PoolInfo storage info = poolInfo[pools[pid]];
        _sharePoolRewards(info, lpAmount, _add);

        UserInfo storage user_info = userInfo[pid][user];
        uint256 newAmount = info.mPool.balanceOf(user);
        uint256 lastAmount = _add ? newAmount.sub(lpAmount) : newAmount.add(lpAmount);
        uint256 shares = info.accTokenPerShare.mul(lastAmount).sub(user_info.rewardDebt).div(1e18);
        user_info.rewardDebt = newAmount.mul(info.accTokenPerShare);
        return shares;
    }

    function getPoolTvl(PoolInfo memory info) private returns (uint256){
        address baseToken = info.tokens[info.referIndex];
        uint256 balance = info.balances[info.referIndex];
        uint256 nw = info.weights[info.referIndex];
        uint256 totalBalance = bdiv(balance, nw);
        (uint8 decimal, uint256 price) = priceOracle.requestTokenPrice(baseToken);
        require(price > 0, "LPMiningV1: token price invalid");
        uint256 divisor = 10 ** uint256(decimal);
        return totalBalance.mul(price).mul(info.allocPoint).div(divisor);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= endBlock) {
            if (_to <= endTripleBlock) {
                return _to.sub(_from).mul(3);
            } else if (_from < endTripleBlock) {
                return endTripleBlock.sub(_from).mul(3).add(_to.sub(endTripleBlock));
            }
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            if (_from < endTripleBlock) {
                return endTripleBlock.sub(_from).mul(3).add(endBlock.sub(endTripleBlock));
            }
            return endBlock.sub(_from);
        }
    }

    function bdiv(uint a, uint b) internal pure returns (uint){
        require(b != 0, "ERR_DIV_ZERO");
        uint c0 = a * 1e18;
        require(a == 0 || c0 / a == 1e18, "ERR_DIV_INTERNAL");
        // bmul overflow
        uint c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL");
        //  badd require
        uint c2 = c1 / b;
        return c2;
    }
}