pragma solidity ^0.4.18;

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function allowance(address owner, address spender) public constant returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

// ERC223
contract ContractReceiver {
  function tokenFallback(address from, uint value) public;
}

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal pure returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}



/**
 * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
 *
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath {

  /* Actual balances of token holders */
  mapping(address => uint) balances;

  /* approve() allowances */
  mapping (address => mapping (address => uint)) allowed;

  /**
   *
   * Fix for the ERC20 short address attack
   *
   * http://vessenes.com/the-erc20-short-address-attack-explained/
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length != size + 4) {
       revert();
     }
     _;
  }

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);

    if (isContract(_to)) {
      ContractReceiver rx = ContractReceiver(_to);
      rx.tokenFallback(msg.sender, _value);
    }

    return true;
  }

  // ERC223 fetch contract size (must be nonzero to be a contract)
  function isContract( address _addr ) view private returns (bool) {
    uint length;
    _addr = _addr;
    assembly { length := extcodesize(_addr) }
    return (length > 0);
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * Atomic increment of approved spending
   *
   * Works around https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   */
  function addApproval(address _spender, uint _addedValue)
  onlyPayloadSize(2 * 32)
  public returns (bool success) {
      uint oldValue = allowed[msg.sender][_spender];
      allowed[msg.sender][_spender] = safeAdd(oldValue, _addedValue);
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  /**
   * Atomic decrement of approved spending.
   *
   * Works around https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   */
  function subApproval(address _spender, uint _subtractedValue)
  onlyPayloadSize(2 * 32)
  public returns (bool success) {

      uint oldVal = allowed[msg.sender][_spender];

      if (_subtractedValue > oldVal) {
          allowed[msg.sender][_spender] = 0;
      } else {
          allowed[msg.sender][_spender] = safeSub(oldVal, _subtractedValue);
      }
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

}



contract BurnableToken is StandardToken {

  address public constant BURN_ADDRESS = 0;

  /** How many tokens we burned */
  event Burned(address burner, uint burnedAmount);

  /**
   * Burn extra tokens from a balance.
   *
   */
  function burn(uint burnAmount) public {
    address burner = msg.sender;
    balances[burner] = safeSub(balances[burner], burnAmount);
    totalSupply = safeSub(totalSupply, burnAmount);
    Burned(burner, burnAmount);
  }
}





/**
 * Upgrade agent interface inspired by Lunyr.
 *
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 */
contract UpgradeAgent {

  uint public originalSupply;

  /** Interface marker */
  function isUpgradeAgent() public pure returns (bool) {
    return true;
  }

  function upgradeFrom(address _from, uint256 _value) public;

}


/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 */
contract UpgradeableToken is StandardToken {

  /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
  address public upgradeMaster;

  /** The next contract where the tokens will be migrated. */
  UpgradeAgent public upgradeAgent;

  /** How many tokens we have upgraded by now. */
  uint256 public totalUpgraded;

  /**
   * Upgrade states.
   *
   * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
   * - WaitingForAgent: Token allows upgrade, but we don&#39;t have a new agent yet
   * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
   * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
   *
   */
  enum UpgradeState {
    Unknown, 
    NotAllowed, 
    WaitingForAgent, 
    ReadyToUpgrade, 
    Upgrading
  }

  /**
   * Somebody has upgraded some of his tokens.
   */
  event Upgrade(address indexed _from, address indexed _to, uint256 _value);

  /**
   * New upgrade agent available.
   */
  event UpgradeAgentSet(address agent);

  /**
   * Do not allow construction without upgrade master set.
   */
  function UpgradeableToken(address _upgradeMaster) public {
    upgradeMaster = _upgradeMaster;
  }

  /**
   * Allow the token holder to upgrade some of their tokens to a new contract.
   */
  function upgrade(uint256 value) public {

      UpgradeState state = getUpgradeState();
      if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
        // Called in a bad state
        revert();
      }

      // Validate input value.
      if (value == 0) revert();

      balances[msg.sender] = safeSub(balances[msg.sender], value);

      // Take tokens out from circulation
      totalSupply = safeSub(totalSupply, value);
      totalUpgraded = safeAdd(totalUpgraded, value);

      // Upgrade agent reissues the tokens
      upgradeAgent.upgradeFrom(msg.sender, value);
      Upgrade(msg.sender, upgradeAgent, value);
  }

  /**
   * Set an upgrade agent that handles
   */
  function setUpgradeAgent(address agent) external {

      if(!canUpgrade()) {
        // The token is not yet in a state that we could think upgrading
        revert();
      }

      if (agent == 0x0) revert();
      // Only a master can designate the next agent
      if (msg.sender != upgradeMaster) revert();
      // Upgrade has already begun for an agent
      if (getUpgradeState() == UpgradeState.Upgrading) revert();

      upgradeAgent = UpgradeAgent(agent);

      // Bad interface
      if(!upgradeAgent.isUpgradeAgent()) revert();
      // Make sure that token supplies match in source and target
      if (upgradeAgent.originalSupply() != totalSupply) revert();

      UpgradeAgentSet(upgradeAgent);
  }

  /**
   * Get the state of the token upgrade.
   */
  function getUpgradeState() public constant returns(UpgradeState) {
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

  /**
   * Change the upgrade master.
   *
   * This allows us to set a new owner for the upgrade mechanism.
   */
  function setUpgradeMaster(address master) public {
      if (master == 0x0) revert();
      if (msg.sender != upgradeMaster) revert();
      upgradeMaster = master;
  }

  /**
   * Child contract can enable to provide the condition when the upgrade can begun.
   */
  function canUpgrade() public pure returns(bool) {
     return true;
  }

}


contract SQDFiniteToken is BurnableToken, UpgradeableToken {

  string public name;
  string public symbol;
  uint8 public decimals;
  address public owner;

  mapping(address => uint) public previligedBalances;

  modifier onlyOwner() {
    if(msg.sender != owner) revert();
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  function SQDFiniteToken(address _owner, string _name, string _symbol, uint _totalSupply, uint8 _decimals) UpgradeableToken(_owner) public {
    uint calculatedSupply = _totalSupply * 10 ** uint(_decimals);
    name = _name;
    symbol = _symbol;
    totalSupply = calculatedSupply;
    decimals = _decimals;

    // Allocate initial balance to the owner
    balances[_owner] = calculatedSupply;

    // save the owner
    owner = _owner;
  }

  // privileged transfer
  function transferPrivileged(address _to, uint _value) onlyOwner public returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    previligedBalances[_to] = safeAdd(previligedBalances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  // get priveleged balance
  function getPrivilegedBalance(address _owner) public constant returns (uint balance) {
    return previligedBalances[_owner];
  }

  // admin only can transfer from the privileged accounts
  function transferFromPrivileged(address _from, address _to, uint _value) onlyOwner public returns (bool success) {
    uint availablePrevilegedBalance = previligedBalances[_from];

    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    previligedBalances[_from] = safeSub(availablePrevilegedBalance, _value);
    Transfer(_from, _to, _value);
    return true;
  }
}

contract InitialSaleSQD {
    address public beneficiary;
    uint public preICOSaleStart;
    uint public ICOSaleStart;
    uint public ICOSaleEnd;

    uint public preICOPrice; // price of 10^-8 SQD in Wei
    uint public ICOPrice; // price of 10^-8 SQD in Wei
    
    uint public amountRaised;
    uint public incomingTokensTransactions;

    SQDFiniteToken public tokenReward;

    event TokenFallback( address indexed from,
                         uint256 value);

    modifier onlyOwner() {
        if(msg.sender != beneficiary) revert();
        _;
    }

    function InitialSaleSQD(
        uint _preICOStart,
        uint _ICOStart,
        uint _ICOEnd,
        uint _preICOPrice,
        uint _ICOPrice,
        SQDFiniteToken addressOfTokenUsedAsReward
    ) public {
        beneficiary = msg.sender;
        preICOSaleStart = _preICOStart;
        ICOSaleStart = _ICOStart;
        ICOSaleEnd = _ICOEnd;
        preICOPrice = _preICOPrice;
        ICOPrice = _ICOPrice;
        tokenReward = SQDFiniteToken(addressOfTokenUsedAsReward);
    }

    function () payable public {
        if (now < preICOSaleStart) revert();
        if (now >= ICOSaleEnd) revert();

        uint price = preICOPrice;
        if (now >= ICOSaleStart) {
            price = ICOPrice;
        }

        uint amount = msg.value;
        if (amount < price) revert();

        amountRaised += amount;

        uint payoutPerPrice = 10 ** uint(tokenReward.decimals() - 8);
        uint units = amount / price;
        uint tokensToSend = units * payoutPerPrice;

        tokenReward.transfer(msg.sender, tokensToSend);
    }

    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            beneficiary = newOwner;
        }
    }

    function WithdrawETH(uint amount) onlyOwner public {
        beneficiary.transfer(amount);
    }

    function WithdrawAllETH() onlyOwner public {
        beneficiary.transfer(amountRaised);
    }

    function WithdrawTokens(uint amount) onlyOwner public {
        tokenReward.transfer(beneficiary, amount);
    }

    function ChangeCost(uint _preICOPrice, uint _ICOPrice) onlyOwner public {
        preICOPrice = _preICOPrice;
        ICOPrice = _ICOPrice;
    }

    function ChangePreICOStart(uint _start) onlyOwner public {
        preICOSaleStart = _start;
    }

    function ChangeICOStart(uint _start) onlyOwner public {
        ICOSaleStart = _start;
    }

    function ChangeICOEnd(uint _end) onlyOwner public {
        ICOSaleEnd = _end;
    }

    // ERC223
    // function in contract &#39;ContractReceiver&#39;
    function tokenFallback(address from, uint value) public {
        incomingTokensTransactions += 1;
        TokenFallback(from, value);
    }
}