// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./EVT.sol";
import "./Address.sol";

contract EVTMaster is Ownable {
    using SafeMath for uint256;
    using Address for address;

    EVT public rewardToken;
    address public lpMiningContract;

    uint256 private _lastMintTime;
    uint256 private _totalStaked = 0;
    uint256 private _platformFees = 0;
    uint256 private _mintedCurrentLevel = 0;
    uint256 private _mintedByLP = 0;
    uint256 private _mintedByStaking = 0;
    uint256 private _currentLevel = 0;

    uint256 constant MIN_INVEST = 10000000000000000;
    uint256 constant REWARD_INTERVAL = 1 days;

    uint256 constant REF_REWARD_PERCENT = 10;

    uint256 constant UNSTAKE_FEE = 10;

    uint256 constant MAX_MINT_BY_LP = 800000 ether;
    uint256 constant MAX_MINT_BY_STAKING = 2000000 ether;

    uint256[8] public levelChangeTime;

    uint256[] public LEVEL_LIMIT = [
        700000 ether,
        600000 ether,
        500000 ether,
        400000 ether,
        300000 ether,
        200000 ether,
        100000 ether,
        0
    ];

    uint256[] public LEVEL_YIELD = [
        93,
        78,
        64,
        50,
        37,
        24,
        11,
        0
    ];

    // Info of each user.
    struct User {
        uint256 investment;
        uint256 lastClaim;
        address referrer;
        uint256 referralReward;
        uint256 totalReferrals;
        address addr;
        bool exists;
    }

    mapping(address => User) private _users;

    event Operation(
        string _type,
        address indexed _user,
        address indexed _referrer,
        uint256 amount,
        uint256 timestamp
    );

    event LevelChanged(uint256 newLevel, uint256 timestamp);
    event NewReferral(
        address indexed _user,
        address referral,
        uint256 timestamp
    );
    event ReferralReward(
        address indexed _referrer,
        address indexed _user,
        uint256 amount,
        uint256 timestamp
    );
    event ClaimStaked(
        address indexed _user,
        address indexed _referrer,
        uint256 amount,
        uint256 timestamp
    );
    event ClaimReferral(address indexed _user, uint256 _amount);

    constructor(EVT _rewardToken) {
        User storage user = _users[msg.sender];
        user.exists = true;
        user.addr = msg.sender;
        user.totalReferrals = 1;
        user.referrer = msg.sender;
        user.lastClaim = block.timestamp;

        _lastMintTime = block.timestamp;
        rewardToken = _rewardToken;
    }

    function setLPContract(address _address) public onlyOwner {
        lpMiningContract = _address;
    }

    receive() external payable {
        if (msg.sender == owner() || msg.value < MIN_INVEST) {
            _refund();
        } else {
            _stake(msg.sender, address(0x0), msg.value);
        }
    }

    function stake() public payable {
        stake(address(0x0));
    }

    function stake(address _referrer) public payable {
        if (msg.sender == owner() || msg.value < MIN_INVEST) {
            _refund();
        } else {
            _stake(msg.sender, _referrer, msg.value);
        }
    }

    function _refund() private {
        _mintTokens();
        safeSendValue(msg.sender, msg.value);
    }

    function _stake(
        address _address,
        address _referrer,
        uint256 _amount
    ) private {
        require(_amount >= MIN_INVEST, 'Too low value');
        require(_address != owner(), "Owner can't stake");
        _mintTokens();

        address referrer = _referrer == address(0x0) ? owner() : _referrer;
        if (!_users[referrer].exists) {
            referrer = owner();
        }

        User storage user = _users[_address];
        if (!user.exists) {
            user.exists = true;
            user.addr = _address;
            user.referrer = referrer;
            user.investment = _amount;
            user.lastClaim = block.timestamp;

            _users[referrer].totalReferrals = _users[referrer]
                .totalReferrals
                .add(1);

            emit NewReferral(referrer, user.addr, block.timestamp);
        } else {
            _claimStaked(_address);
            user.investment = user.investment.add(_amount);
        }
        _totalStaked = _totalStaked.add(_amount);
        _platformFees = _platformFees.add(_amount.mul(UNSTAKE_FEE));
        emit Operation('stake', user.addr, user.referrer, _amount, block.timestamp);
    }

    function unstake(uint256 _amount) public {
        require(msg.sender != owner(), "Owner can't unstake");
        _mintTokens();

        User storage user = _users[msg.sender];

        require(user.exists, 'Invalid User');

        _claimStaked(msg.sender);

        emit Operation('unstake', user.addr, user.referrer, _amount, block.timestamp);

        _totalStaked = _totalStaked.sub(_amount);
        user.investment = user.investment.sub(
            _amount,
            'EVTMaster::unstake: Insufficient funds'
        );
        _amount = _amount.mul(uint256(100).sub(UNSTAKE_FEE)).div(100);

        safeSendValue(msg.sender, _amount);
    }

    function unstake() public {
        unstake(_users[msg.sender].investment);
    }

    function claimStaked() public {
        _mintTokens();
        _claimStaked(msg.sender);
    }

    function claimReferralReward() public {
        _mintTokens();
        User storage user = _users[msg.sender];
        uint256 refReward = user.referralReward;
        user.referralReward = 0;
        safeTokenTransfer(user.addr, refReward);
        emit ClaimReferral(user.addr, refReward);
    }

    function _mintTokens() internal returns (uint256 mintedAmount) {
        uint256 timePassed = block.timestamp.sub(_lastMintTime);
        if (timePassed == 0) {
            return 0;
        }
        if (_totalStaked != 0) {
            uint256 toMint = _totalStaked
                .mul(timePassed)
                .div(REWARD_INTERVAL)
                .mul(LEVEL_YIELD[_currentLevel])
                .div(100);
            // Add ref percent
            toMint = toMint.add(toMint.mul(REF_REWARD_PERCENT).div(100));
            if (_mintedByStaking.add(toMint) > MAX_MINT_BY_STAKING) {
                toMint = MAX_MINT_BY_STAKING.sub(_mintedByStaking);
            }
            mintedAmount = safeMint(address(this), toMint);
            _mintedByStaking = _mintedByStaking.add(mintedAmount);
        }
        _lastMintTime = block.timestamp;
    }

    function _claimStaked(address _address) internal {
        require(_address != owner(), "Owner can't unstake");
        User storage user = _users[_address];

        require(user.exists, 'Invalid User');

        uint256 reward = pendingReward(msg.sender);

        user.lastClaim = block.timestamp;

        uint256 referralReward = reward.mul(REF_REWARD_PERCENT).div(100);

        safeTokenTransfer(user.addr, reward);

        _users[user.referrer].referralReward = _users[user.referrer]
            .referralReward
            .add(referralReward);

        emit ClaimStaked(user.addr, user.referrer, reward, block.timestamp);
        emit ReferralReward(user.referrer, user.referrer, referralReward, block.timestamp);
    }

    function pendingReward() public view returns (uint256) {
        return pendingReward(msg.sender);
    }

    function pendingReward(address _address)
        public
        view
        returns (uint256 reward)
    {
        User memory user = _users[_address];
        uint256 lastClaim = user.lastClaim;
        for (uint256 lvl = 0; lvl <= _currentLevel; ++lvl) {
            uint256 time = (levelChangeTime[lvl] == 0)
                ? block.timestamp
                : levelChangeTime[lvl];
            if (_users[_address].lastClaim >= time) {
                continue;
            }
            reward = reward.add(
                user
                    .investment
                    .mul(time.sub(lastClaim))
                    .div(REWARD_INTERVAL)
                    .mul(LEVEL_YIELD[lvl])
                    .div(100)
            );
            if (time == block.timestamp) {
                break;
            }
            lastClaim = time;
        }
    }

    // Function for owner to withdraw staking fees
    function withdrawFees() public onlyOwner returns (uint256) {
        return withdrawFees(payable(owner()), _platformFees);
    }

    // Function for owner to withdraw staking fees
    function withdrawFees(address payable _address, uint256 _amount)
        public
        onlyOwner
        returns (uint256)
    {
        _platformFees = _platformFees.sub(_amount, 'Not enough fees!');
        return safeSendValue(_address, _amount);
    }

    // View function in order to optimize web UI
    function stats() view public returns (
        uint256 currentLevel,
        uint256 currentLevelYield,
        uint256 currentLevelSupply,
        uint256 mintedCurrentLevel,
        uint256 totalEVT,
        uint256 totalStaked,
        uint256 mintedByStaking,
        uint256 mintedByLP
    ) {
        currentLevel = _currentLevel;
        currentLevelYield = LEVEL_YIELD[_currentLevel];
        currentLevelSupply = LEVEL_LIMIT[_currentLevel];
        mintedCurrentLevel = _mintedCurrentLevel;
        mintedByStaking = _mintedByStaking;
        mintedByLP = _mintedByLP;
        totalStaked = _totalStaked;
        totalEVT = rewardToken.totalSupply();
    }

    // View function in order to optimize web UI
    function userInfo() view public returns (
        uint256, uint256, address, uint256, uint256, uint256, uint256, uint256
    ) {
        return userInfo(msg.sender);
    }

    // View function in order to optimize web UI
    function userInfo(address _address) view public returns (
        uint256 investment,
        uint256 lastClaim,
        address referrer,
        uint256 referralReward,
        uint256 totalReferrals,
        uint256 pendingRewards,
        uint256 tokenBalance,
        uint256 balance
    ) {
        investment = _users[_address].investment;
        lastClaim = _users[_address].lastClaim;
        referrer = _users[_address].referrer;
        referralReward = _users[_address].referralReward;
        totalReferrals = _users[_address].totalReferrals;
        pendingRewards = pendingReward(_address);
        tokenBalance = rewardToken.balanceOf(_address);
        balance = _address.balance;
    }

    // Don't care about rewards and stats (emergency only, in case if unexpected error occurs)
    function emergencyWithdraw(address payable _user, uint256 _amount) public returns (uint256) {
        _users[msg.sender].investment = _users[_user].investment.sub(_amount);
        _totalStaked = _totalStaked.sub(_amount);

        return safeSendValue(_user, _amount.mul(uint256(100).sub(UNSTAKE_FEE)).div(100));
    }

    // Don't care about rewards and stats (emergency only, in case if unexpected error occurs)
    function emergencyWithdraw(address payable _user) public returns (uint256) {
        return emergencyWithdraw(_user, _users[_user].investment);
    }

    // Mint EVT for LP stakers
    // This is done through EVTMaster to keep traking minting levels
    function mintFromLP(uint256 _amount) public returns (uint256 mintedAmount) {
        require(msg.sender == lpMiningContract, 'Not the LP Master');
        _mintTokens();
        if (_amount >= MAX_MINT_BY_LP.sub(_mintedByLP)) {
            _amount = MAX_MINT_BY_LP.sub(_mintedByLP);
        }
        mintedAmount = safeMint(msg.sender, _amount);
        _mintedByLP = _mintedByLP.add(mintedAmount);
    }

    // Safe token transfer function to avoid rounding errors to cause ETH being locked
    function safeTokenTransfer(address _to, uint256 _amount) internal returns (uint256) {
        uint256 balance = rewardToken.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }

        rewardToken.transfer(_to, _amount);
        return _amount;
    }

    // Safe token mint function to avoid rounding and max supply errors to cause ETH being locked
    function safeMint(address _to, uint256 _amount) internal returns (uint256) {
        uint256 canBeMinted = rewardToken.maxSupply().sub(rewardToken.totalSupply());
        if (_amount > canBeMinted) {
            _amount = canBeMinted;
        }

        _mintedCurrentLevel = _mintedCurrentLevel.add(_amount);

        rewardToken.mint(_to, _amount);

        if (
            _mintedCurrentLevel >= LEVEL_LIMIT[_currentLevel] &&
            _currentLevel < (LEVEL_LIMIT.length - 1)
        ) {
            levelChangeTime[_currentLevel] = block.timestamp;
            _currentLevel++;
            _mintedCurrentLevel = 0;
            emit LevelChanged(_currentLevel, block.timestamp);
        }

        return _amount;
    }

    function safeSendValue(address payable _to, uint256 _amount) internal returns (uint256) {
        if (_amount > address(this).balance) {
            _amount = address(this).balance;
        }
        _to.transfer(_amount);
        return _amount;
    }
}
