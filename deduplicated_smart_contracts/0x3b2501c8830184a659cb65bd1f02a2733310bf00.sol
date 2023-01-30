pragma solidity 0.4.19;


contract DeusETH {
    using SafeMath for uint256;

    struct Citizen {
        uint8 state; // 1 - living tokens, 0 - dead tokens
        address holder;
        uint8 branch;
        bool isExist;
    }

    //max token supply
    uint256 public cap = 50;

    //2592000 - it is 1 month
    uint256 public timeWithoutUpdate = 2592000;

    //token price
    uint256 public rate = 1 ether;

    // amount of raised money in wei for FundsKeeper
    uint256 public weiRaised;

    // address where funds are collected
    address public fundsKeeper;

    //address of Episode Manager
    address public episodeManager;
    bool public managerSet = false;

    address public owner;

    bool public started = false;
    bool public gameOver = false;
    bool public gameOverByUser = false;

    uint256 public totalSupply = 0;
    uint256 public livingSupply = 0;

    mapping(uint256 => Citizen) public citizens;

    //using for userFinalize
    uint256 public timestamp = 0;

    event TokenState(uint256 indexed id, uint8 state);
    event TokenHolder(uint256 indexed id, address holder);
    event TokenBranch(uint256 indexed id, uint8 branch);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyEpisodeManager() {
        require(msg.sender == episodeManager);
        _;
    }

    function DeusETH(address _fundsKeeper) public {
        require(_fundsKeeper != address(0));
        owner = msg.sender;
        fundsKeeper = _fundsKeeper;
        timestamp = now;
    }

    // fallback function not use to buy token
    function () external payable {
        revert();
    }

    function setEpisodeManager(address _episodeManager) public onlyOwner {
        require(!managerSet);
        episodeManager = _episodeManager;
        managerSet = true;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function livingSupply() public view returns (uint256) {
        return livingSupply;
    }

    // low level token purchase function
    function buyTokens(uint256 _id, address _holder) public payable {
        require(!started);
        require(!gameOver);
        require(!gameOverByUser);
        require(_id > 0 && _id <= cap);
        require(citizens[_id].isExist == false);
        require(_holder != address(0));

        require(msg.value == rate);

        uint256 weiAmount = msg.value;

        // update weiRaised
        weiRaised = weiRaised.add(weiAmount);

        totalSupply = totalSupply.add(1);
        livingSupply = livingSupply.add(1);

        createCitizen(_id, _holder);
        timestamp = now;
        TokenHolder(_id, _holder);
        TokenState(_id, 1);
        TokenBranch(_id, 1);

        forwardFunds();
    }

    function changeState(uint256 _id, uint8 _state) public onlyEpisodeManager returns (bool) {
        require(started);
        require(!gameOver);
        require(!gameOverByUser);
        require(_id > 0 && _id <= cap);
        require(_state <= 1);
        require(citizens[_id].state != _state);

        citizens[_id].state = _state;
        TokenState(_id, _state);
        timestamp = now;
        if (_state == 0) {
            livingSupply--;
        } else {
            livingSupply++;
        }

        return true;
    }

    function changeHolder(uint256 _id, address _newholder) public returns (bool) {
        require(!gameOver);
        require(!gameOverByUser);
        require(_id > 0 && _id <= cap);
        require(citizens[_id].holder == msg.sender);
        require(_newholder != address(0));
        citizens[_id].holder = _newholder;
        TokenHolder(_id, _newholder);
        return true;
    }

    function changeBranch(uint256 _id, uint8 _branch) public onlyEpisodeManager returns (bool) {
        require(started);
        require(!gameOver);
        require(!gameOverByUser);
        require(_id > 0 && _id <= cap);
        require(_branch > 0);
        citizens[_id].branch = _branch;
        TokenBranch(_id, _branch);
        return true;
    }

    function start() public onlyOwner {
        started = true;
    }

    function finalize() public onlyOwner {
        require(!gameOverByUser);
        gameOver = true;
    }

    function userFinalize() public {
        require(now > (timestamp + timeWithoutUpdate));
        require(!gameOver);
        gameOverByUser = true;
    }

    function checkGameOver() public view returns (bool) {
        return gameOver;
    }

    function checkGameOverByUser() public view returns (bool) {
        return gameOverByUser;
    }

    function changeOwner(address _newOwner) public onlyOwner returns (bool) {
        require(_newOwner != address(0));
        owner = _newOwner;
        return true;
    }

    function getState(uint256 _id) public view returns (uint256) {
        require(_id > 0 && _id <= cap);
        return citizens[_id].state;
    }

    function getHolder(uint256 _id) public view returns (address) {
        require(_id > 0 && _id <= cap);
        return citizens[_id].holder;
    }

    function getNowTokenPrice() public view returns (uint256) {
        return rate;
    }

    function forwardFunds() internal {
        fundsKeeper.transfer(msg.value);
    }

    function createCitizen(uint256 _id, address _holder) internal returns (uint256) {
        require(!started);
        require(_id > 0 && _id <= cap);
        require(_holder != address(0));
        citizens[_id].state = 1;
        citizens[_id].holder = _holder;
        citizens[_id].branch = 1;
        citizens[_id].isExist = true;
        return _id;
    }
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}