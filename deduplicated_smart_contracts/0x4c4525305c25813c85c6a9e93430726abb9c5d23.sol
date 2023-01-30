/**
 *Submitted for verification at Etherscan.io on 2020-01-17
*/

pragma solidity ^0.5.13;

interface RNGOracle {
  function modulusRequest(uint256 _modulus, uint256 _betmask, bytes32 _seed, uint256 _callbackGasLimit) external returns (bytes32 queryId);
  function queryWallet(address _user) external view returns (uint256);
  // function addQueryBalance() external payable; (use this in the ABI to add balance)
}

interface DDN {
  function transfer(address _to, uint256 _tokens) external returns (bool);
  function balanceOf(address _user) external view returns (uint256);
  function dividendsOf(address _user) external view returns (uint256);
  function buy() external payable returns (uint256);
  function reinvest() external returns (uint256);
}

interface PYRO {
  function transfer(address _to, uint256 _tokens) external returns (bool);
  function balanceOf(address _user) external view returns (uint256);
}

contract WheelOfDDN {
  using SafeMath for uint;

  // Modifiers
  modifier noActiveBet(address _user) {
    require(betStatus[_user] == false);
    _;
  }

  modifier gameActive() {
    require(gamePaused == false);
    _;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  modifier autoReinvest() {
    if (ddn.dividendsOf(address(this)) > 0.1 ether) {
      reinvest();
    }
    _;
  }

  // Events
  event BetPlaced(address indexed player, bytes32 queryId);
  event BetResolved(address indexed player, bytes32 indexed queryId, uint256 betAmount, uint256 roll, uint256 bracket, uint256 win, bool stakeBet, uint256 pyro);
  event BetFailed(address indexed player, bytes32 indexed queryId, uint256 betAmount, bool stakeBet);
  event Stake(address indexed player, uint256 tokens);
  event Withdraw(address indexed player, uint256 tokens);

  address admin;
  bool public gamePaused = false;

  uint8[10] brackets = [1, 3, 6, 12, 24, 40, 56, 68, 76, 80];

  uint256 constant internal constantFactor = 1e44;
  uint256 internal globalFactor = 1e22;
  uint256 internal nonStakeTokens;
  uint256 internal CALLBACK_GAS_LIMIT = 300000;

  struct BetInfo {
    address user;
    uint256 tokens;
    bool stakeBet;
  }

  mapping(bytes32 => BetInfo) private betInfo;
  mapping(address => uint256) internal personalFactorLedger_;
  mapping(address => uint256) internal balanceLedger_;
  mapping(address => bool) internal betStatus;
  mapping(bytes32 => bool) internal queryStatus;
  mapping(address => bytes32) internal lastQuery;

  DDN private ddn;
  RNGOracle private oracle;
  PYRO private pyro;


  constructor(address _oracleAddress, address _DDN_address, address _PYRO_address)
    public
  {
    admin = msg.sender;
    oracle = RNGOracle(_oracleAddress);
    ddn = DDN(_DDN_address);
    pyro = PYRO(_PYRO_address);
  }


  function stake()
    external
    payable
    autoReinvest
    noActiveBet(msg.sender)
  {
    require(msg.value > 0);
    _stake(msg.sender, ddn.buy.value(msg.value)());
  }

  function placeBet()
    external
    payable
    autoReinvest
    noActiveBet(msg.sender)
  {
    require(msg.value > 0);
    _initSpin(msg.sender, ddn.buy.value(msg.value)(), false);
  }


  function tokenCallback(address _from, uint256 _tokens, bytes calldata _data)
    external
    autoReinvest
    noActiveBet(_from)
    returns (bool)
  {
    require(msg.sender == address(ddn));
    require(_tokens > 0);
    if (_data.length == 0) {
      _stake(_from, _tokens);
    } else {
      _initSpin(_from, _tokens, false);
    }
    return true;
  }


  function stakeSpin(uint256 _tokens)
    external
    autoReinvest
    noActiveBet(msg.sender)
  {
    address _user = msg.sender;
    require(stakeOf(_user) >= _tokens);
    // User cannot bet more than 5% of available pool
    if (_tokens > betPool(_user) / 20) {
      _tokens = betPool(_user) / 20;
    }
    _initSpin(_user, _tokens, true);
  }


  function modulusCallback(bytes32 _queryId, uint256, uint256 _result)
    external
  {
    require(msg.sender == address(oracle));
    _executeSpin(_queryId, _result);
  }


  function queryFailed(bytes32 _queryId)
    external
  {
    if (_queryId == bytes32(0x0)) {
      _queryId = lastQuery[msg.sender];
    } else {
      require(msg.sender == address(oracle));
    }
    require(!queryStatus[_queryId]);
    BetInfo memory _betInfo = betInfo[_queryId];
    address _user = _betInfo.user;
    uint256 _tokens = _betInfo.tokens;
    bool _stakeBet = _betInfo.stakeBet;
    require(betStatus[_user]);
    if (!_stakeBet) {
      nonStakeTokens = nonStakeTokens.sub(_tokens);
      ddn.transfer(_user, _tokens);
    }
    betStatus[_user] = false;
    queryStatus[_queryId] = true;
    emit BetFailed(_user, _queryId, _tokens, _stakeBet);
  }


  function getBalance()
    public
    view
    returns (uint256)
  {
    return ddn.balanceOf(address(this)) - nonStakeTokens;
  }


  function withdraw(uint256 _tokens)
    public
    autoReinvest
    noActiveBet(msg.sender)
  {
    address _user = msg.sender;
    uint256 _withdrawable = _tokens;
    if (_withdrawable > stakeOf(_user)) {
      _withdrawable = stakeOf(_user);
    }
    require(_withdrawable > 0);
    ddn.transfer(_user, _withdrawable);
    balanceLedger_[_user] = stakeOf(_user).sub(_withdrawable);
    personalFactorLedger_[_user] = constantFactor / globalFactor;
    emit Withdraw(_user, _withdrawable);
  }


  function withdrawAll()
    external
    noActiveBet(msg.sender)
  {
    withdraw(stakeOf(msg.sender));
  }


  function stakeOf(address _user)
    public
    view
    returns (uint256)
  {
    // Balance ledger * personal factor * globalFactor / constantFactor
    return balanceLedger_[_user].mul(personalFactorLedger_[_user]).mul(globalFactor) / constantFactor;
  }


  function betPool(address _user)
    public
    view
    returns (uint256)
  {
    // Balance of contract minus balance of the user
    return getBalance().sub(stakeOf(_user));
  }


  function allInfoFor(address _user) public view returns (uint256 bankroll, uint256 userQueryBalance, uint256 userBalance, uint256 userStake) {
    return (getBalance(), oracle.queryWallet(_user), ddn.balanceOf(_user), stakeOf(_user));
  }


  // Internal Functions


  function _stake(address _user, uint256 _amount)
    internal
    gameActive
  {
    balanceLedger_[_user] = stakeOf(_user).add(_amount);
    personalFactorLedger_[_user] = constantFactor / globalFactor;
    emit Stake(_user, _amount);
  }


  function _initSpin(address _user, uint256 _betAmount, bool _stakeSpin)
    internal
    gameActive
  {
    bytes32 _queryId = oracle.modulusRequest(80, 1, keccak256(abi.encodePacked(_user, block.number)), CALLBACK_GAS_LIMIT);
    BetInfo memory _betInfo = BetInfo({
      user: _user,
      tokens: _betAmount,
      stakeBet: _stakeSpin
    });
    betInfo[_queryId] = _betInfo;
    emit BetPlaced(_user, _queryId);
    if (!_stakeSpin) {
      nonStakeTokens += _betAmount;
    }
    betStatus[_user] = true;
    lastQuery[_user] = _queryId;
  }


  function _executeSpin(bytes32 _queryId, uint256 _result)
    internal
    gameActive
  {
    require(!queryStatus[_queryId]);
    BetInfo memory _betInfo = betInfo[_queryId];
    address _user = _betInfo.user;
    uint256 _tokens = _betInfo.tokens;
    bool _stakeBet = _betInfo.stakeBet;

    require(betStatus[_user]);

    uint256 _userStake = stakeOf(_user);

    // max bet is 5% of the stake (of everyone else)
    // max win is 4x, 4x5 = 20% of the bankroll monkaS
    require(betPool(_user) > 0);
    if (_tokens > betPool(_user) / 20) {
      _tokens = betPool(_user) / 20;
    }

    if (_stakeBet) {
      require(_tokens <= _userStake);
    }

    uint256 _bracket;
    uint256 _return;
    (_bracket, _return) = _calculateReturn(_result, _tokens);

    if (_return > _tokens) {  // win
      uint256 _won = _return - _tokens;
      _houseLose(_user, _won);
      if (_stakeBet) {
        // scenario 1.1: stake bet win
        personalFactorLedger_[_user] = constantFactor / globalFactor;
        balanceLedger_[_user] = _userStake.add(_won);
      } else {
        // scenario 1.2: direct bet win
        personalFactorLedger_[_user] = constantFactor / globalFactor;
        balanceLedger_[_user] = _userStake; // user stake is unchanged despite global win
        ddn.transfer(_user, _return);
      }
    } else {                 // lose
      uint256 _lost = _tokens - _return;
      _houseWin(_user, _lost);
      if (_stakeBet) {
        // scenario 2.1: stake bet lose
        _userStake = _userStake.sub(_tokens);
        _userStake = _userStake.add(_return);
        balanceLedger_[_user] = _userStake;
        personalFactorLedger_[_user] = constantFactor / globalFactor;
      } else {
        // scenario 2.2: direct bet lose
        personalFactorLedger_[_user] = constantFactor / globalFactor;
        balanceLedger_[_user] = _userStake; // user stake is unchanged despite global loss
        if (_return > 0) {
          ddn.transfer(_user, _return);
        }
      }
    }

    if (!_stakeBet) {
      nonStakeTokens = nonStakeTokens.sub(_betInfo.tokens);
      if (_betInfo.tokens > _tokens) {
        ddn.transfer(_user, _betInfo.tokens - _tokens);
      }
    }

    uint256 _userPyro = pyro.balanceOf(_user);
    uint256 _bonusPyro = pyro.balanceOf(address(this));
    uint256 _pyroReward = _return * 25; // 25:1 PYRO per DDN won
    _pyroReward = _bonusPyro > _pyroReward ? _pyroReward : _bonusPyro;
    if (_pyroReward > 0) {
      pyro.transfer(_user, _pyroReward);
      _pyroReward = pyro.balanceOf(_user).sub(_userPyro);
    }

    betStatus[_user] = false;
    queryStatus[_queryId] = true;
    emit BetResolved(_user, _queryId, _tokens, _result, _bracket, _return, _stakeBet, _pyroReward);
  }


  function _calculateReturn(uint256 _result, uint256 _tokens)
    internal
    view
    returns (uint256 bracket, uint256 win)
  {
    for (uint256 i = 0; i < brackets.length; i++) {
      if (brackets[i] > _result) {
        bracket = i;
        break;
      }
    }
    if (bracket == 0) { win = _tokens * 5; } // Grand Jackpot 5x
    else if (bracket == 1) { win = _tokens * 3; } // Jackpot 3x
    else if (bracket == 2) { win = _tokens * 2; } // Grand Prize 2x
    else if (bracket == 3) { win = _tokens * 3 / 2; } // Major Prize 1.5x
    else if (bracket == 4) { win = _tokens * 5 / 4; } // Minor Prize 1.25x
    else if (bracket == 5) { win = _tokens * 21 / 20; } // Tiny Prize 1.05x
    else if (bracket == 6) { win = _tokens * 4 / 5; } // Minor Loss 0.8x
    else if (bracket == 7) { win = _tokens * 11 / 20; } // Major Loss 0.55x
    else if (bracket == 8) { win = _tokens / 4; } // Grand Loss 0.25x
    else { win = 0; } // Total Loss 0x
  }


  function _houseLose(address _user, uint256 _tokens)
    internal
  {
    uint256 globalDecrease = globalFactor.mul(_tokens) / betPool(_user);
    globalFactor = globalFactor.sub(globalDecrease);
  }


  function _houseWin(address _user, uint256 _tokens)
    internal
  {
    uint256 globalIncrease = globalFactor.mul(_tokens) / betPool(_user);
    globalFactor = globalFactor.add(globalIncrease);
  }


  function reinvest()
    public
  {
    uint256 _tokens = ddn.reinvest();
    // Increase amount of ddn everyone owns
    uint256 globalIncrease = globalFactor.mul(_tokens) / getBalance();
    globalFactor = globalFactor.add(globalIncrease);
  }


  // emergency  /  dev functions


  /*
    panicButton and refundUser are here incase of an emergency, or launch of a new contract
    The game will be frozen, and all token holders will be refunded
  */

  function setCallbackGas(uint256 _newLimit)
    public
    onlyAdmin
  {
    CALLBACK_GAS_LIMIT = _newLimit;
  }


  function panicButton()
    public
    onlyAdmin
  {
    if (gamePaused) {
      gamePaused = false;
    } else {
      gamePaused = true;
    }
  }


  function refundUser(address _user)
    public
    onlyAdmin
  {
    uint256 _tokens = stakeOf(_user);
    if (_tokens > ddn.balanceOf(address(this))) {
      _tokens = ddn.balanceOf(address(this));
    }
    balanceLedger_[_user] = balanceLedger_[_user].sub(_tokens);
    personalFactorLedger_[_user] = constantFactor / globalFactor;
    ddn.transfer(_user, _tokens);
    emit Withdraw(_user, _tokens);
  }


  function withdrawAllPYRO()
    public
    onlyAdmin
  {
    pyro.transfer(address(0x0E7b52B895E3322eF341004DC6CB5C63e1d9b1c5), pyro.balanceOf(address(this)));
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}