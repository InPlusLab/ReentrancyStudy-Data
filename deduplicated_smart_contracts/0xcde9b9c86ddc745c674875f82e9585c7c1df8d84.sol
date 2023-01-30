/**
 *Submitted for verification at Etherscan.io on 2020-04-26
*/

pragma solidity ^0.5.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
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

    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    function mint(address account, uint256 amount) public returns (bool);

    function burn(uint256 amount) public returns (bool);
}


contract Staking is Ownable {
    using SafeMath for uint256;
    uint256 private minStake;
    uint256 private pool;
    address private EGRAddress;
    address public messenger;
    mapping(address => uint256) userStake;
    mapping(address => uint256) nextWithdrawDate;

    constructor(address _EGRAddress, uint256 _minStake) public {
        EGRAddress = _EGRAddress;
        minStake = _minStake;
    }

    struct Stakers {
        address staker;
        uint256 index;
    }

    mapping(address => Stakers) private stakers;
    address[] private stakersRecords;

    event minStakeChanged(uint256 _from, uint256 _to, uint256 _now);
    event rewards(
        address user,
        uint256 reward,
        uint256 userStake,
        uint256 pool,
        uint256 rewardAmount,
        uint256 time
    );
    event userStaked(address _sender, uint256 _amount, uint256 time);
    event userWidthdrawStake(address _sender, uint256 _amount, uint256 time);
    event widthdrawFromPool(address _sender, uint256 _amount, uint256 time);

    function stake(uint256 _EGRValueInWei) public returns (bool) {
        require(
            _EGRValueInWei > minStake,
            "Amount must be greater than minimum stake"
        );
        IERC20 egorasEGR = IERC20(EGRAddress);
        require(
            egorasEGR.allowance(msg.sender, address(this)) >= _EGRValueInWei,
            "Non-sufficient funds"
        );
        require(
            egorasEGR.balanceOf(msg.sender) >= _EGRValueInWei,
            "Non-sufficient funds"
        );
        require(
            egorasEGR.transferFrom(msg.sender, address(this), _EGRValueInWei),
            "Fail to tranfer fund"
        );
        userStake[msg.sender] = userStake[msg.sender].add(_EGRValueInWei);
        pool = pool.add(_EGRValueInWei);
        if (stakers[msg.sender].staker == address(0)) {
            stakers[msg.sender].staker = msg.sender;
            stakers[msg.sender].index = stakersRecords.push(msg.sender) - 1;
            nextWithdrawDate[msg.sender] = block.timestamp.add(30 days);
        }
        emit userStaked(msg.sender, _EGRValueInWei, now);
        return true;
    }

    function getstakers() public view returns (address[] memory) {
        return stakersRecords;
    }

    function getStake() public view returns (uint256 _stakedAmount) {
        return userStake[msg.sender];
    }

    function getMinStake() public view returns (uint256 _minStake) {
        return minStake;
    }

    function getPool() public view returns (uint256 _pool) {
        return pool;
    }

    function getUserStakeBalance(address _user)
        internal
        view
        returns (uint256)
    {
        uint256 percentage = userStake[_user].div(pool);
        uint256 userBalanceShare = percentage.mul(pool);
        return userBalanceShare;
    }

    function getUserRemainingStake(address _user)
        public
        view
        returns (uint256 _stakedAmount)
    {
        return getUserStakeBalance(_user);
    }

    function getUserInitialStake(address _user)
        public
        view
        returns (uint256 _stakedAmount)
    {
        return userStake[_user];
    }

    function setMinStake(uint256 _newMinStake) public returns (bool) {
        require(_newMinStake > 0, "Amount must be greater than zero");
        uint256 currentMinStake = minStake;
        minStake = _newMinStake;
        emit minStakeChanged(currentMinStake, _newMinStake, now);
    }

    function widthdrawStake() public returns (bool) {
        require(withdrawable(msg.sender), "Not yet time");
        require(
            getUserStakeBalance(msg.sender) > 0,
            "Amount must be greater than zero"
        );
        IERC20 egorasEGR = IERC20(EGRAddress);
        uint256 percentage = userStake[msg.sender].div(pool);
        uint256 userBalanceShare = percentage.mul(pool);

        require(
            egorasEGR.balanceOf(address(this)) >= userBalanceShare,
            "Non-sufficient funds"
        );
        require(
            egorasEGR.transfer(msg.sender, userBalanceShare),
            "Unable to transfer funds"
        );
        pool = pool.sub(userBalanceShare);
        userStake[msg.sender] = 0;

        uint256 stakerToDelete = stakers[msg.sender].index;
        address lastIndex = stakersRecords[stakersRecords.length - 1];
        stakersRecords[stakerToDelete] = lastIndex;
        delete stakers[msg.sender];
        stakersRecords.length--;
        emit userWidthdrawStake(msg.sender, userBalanceShare, now);
        return true;
    }

    function widthdraw(uint256 _amount) public onlyOwner returns (bool) {
        require(_amount > 0, "Amount must be greater than zero");
        IERC20 egorasEGR = IERC20(EGRAddress);
        require(
            egorasEGR.balanceOf(address(this)) >= _amount,
            "Non-sufficient funds"
        );
        require(
            egorasEGR.transfer(msg.sender, _amount),
            "Unable to transfer funds"
        );
        pool = pool.sub(_amount);
        emit widthdrawFromPool(msg.sender, _amount, now);
        return true;
    }

    function rewardStakers(uint256 _amount) public onlyOwner returns (bool) {
        IERC20 iERC20 = IERC20(EGRAddress);
        for (uint256 i = 0; i < stakersRecords.length; i++) {
            address user = stakersRecords[i];
            uint256 userStakeAmount = userStake[user];
            uint256 percentage = userStakeAmount.mul(10**18).div(pool);
            uint256 reward = percentage.mul(_amount).div(10**18);
            require(iERC20.mint(user, reward), "Unable to mint token");
            emit rewards(user, reward, userStakeAmount, pool, _amount, now);
        }

        return true;
    }

    function withdrawable(address user) public view returns (bool) {
        if (block.timestamp >= nextWithdrawDate[user]) return true;
        else return false;
    }

    function getUserNextWithdrawDate(address user)
        public
        view
        returns (uint256 _nextWithdrawDate)
    {
        return nextWithdrawDate[user];
    }
}