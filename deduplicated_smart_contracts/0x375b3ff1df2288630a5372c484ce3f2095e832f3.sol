pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/token/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: zeppelin-solidity/contracts/token/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: zeppelin-solidity/contracts/token/CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */

contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: contracts/FKX.sol

/**
 * @title FKX
 */
contract FKX is CappedToken(FKX.TOKEN_SUPPLY) {

  using SafeMath for uint256;

  string public constant name = "Knoxstertoken";
  string public constant symbol = "FKX";
  uint8 public constant decimals = 18;
  string public constant version = "1.0";
  uint256 public constant TOKEN_SUPPLY  = 150000000 * (10 ** uint256(decimals)); // 150 Million FKX

}

// File: contracts/FKXTokenTimeLock.sol

/**
 * @title FKXTokenTimeLock
 * @dev FKXTokenTimeLock is a token holder contract that will allow multiple
 * beneficiaries to extract the tokens after a given release time. It is a modification of the  
 * OpenZeppenlin TokenTimeLock to allow for one token lock smart contract for many beneficiaries. 
 */
contract FKXTokenTimeLock is Ownable {

  /*
   * Array with beneficiary lock indexes. 
   */
  address[] public lockIndexes;

  /**
   * Encapsulates information abount a beneficiary&#39;s token time lock.
   */
  struct TokenTimeLockVault {
      /**
       * Amount of locked tokens.
       */
      uint256 amount;

      /**
       * Timestamp when token release is enabled.
       */
      uint256 releaseTime;

      /**
       * Lock array index.
       */
      uint256 arrayIndex;
  }

  // ERC20 basic token contract being held.
  FKX public token;

  // All beneficiaries&#39; token time locks.
  mapping(address => TokenTimeLockVault) public tokenLocks;

  function FKXTokenTimeLock(FKX _token) public {
    token = _token;
  }

  function lockTokens(address _beneficiary, uint256 _releaseTime, uint256 _tokens) external onlyOwner  {
    require(_releaseTime > now);
    require(_tokens > 0);

    TokenTimeLockVault storage lock = tokenLocks[_beneficiary];
    lock.amount = _tokens;
    lock.releaseTime = _releaseTime;
    lock.arrayIndex = lockIndexes.length;
    lockIndexes.push(_beneficiary);

    LockEvent(_beneficiary, _tokens, _releaseTime);
  }

  function exists(address _beneficiary) external onlyOwner view returns (bool) {
    TokenTimeLockVault memory lock = tokenLocks[_beneficiary];
    return lock.amount > 0;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    TokenTimeLockVault memory lock = tokenLocks[msg.sender];

    require(now >= lock.releaseTime);

    require(lock.amount > 0);

    delete tokenLocks[msg.sender];

    lockIndexes[lock.arrayIndex] = 0x0;

    UnlockEvent(msg.sender);

    assert(token.transfer(msg.sender, lock.amount));   
  }

  /**
   * @notice Transfers tokens held by timelock to all beneficiaries.
   * @param from the start lock index
   * @param to the end lock index
   */
  function releaseAll(uint from, uint to) external onlyOwner returns (bool) {
    require(from >= 0);
    require(to <= lockIndexes.length);
    for (uint i = from; i < to; i++) {
      address beneficiary = lockIndexes[i];
      if (beneficiary == 0x0) { //Skip any previously removed locks
        continue;
      }
      
      TokenTimeLockVault memory lock = tokenLocks[beneficiary];
      
      if (!(now >= lock.releaseTime && lock.amount > 0)) { // Skip any locks that are not due to be release
        continue;
      }

      delete tokenLocks[beneficiary];

      lockIndexes[lock.arrayIndex] = 0x0;
      
      UnlockEvent(beneficiary);

      assert(token.transfer(beneficiary, lock.amount));
    }
    return true;
  }

  /**
   * Logged when tokens were time locked.
   *
   * @param beneficiary beneficiary to receive tokens once they are unlocked
   * @param amount amount of locked tokens
   * @param releaseTime unlock time
   */
  event LockEvent(address indexed beneficiary, uint256 amount, uint256 releaseTime);

  /**
   * Logged when tokens were unlocked and sent to beneficiary.
   *
   * @param beneficiary beneficiary to receive tokens once they are unlocked
   */
  event UnlockEvent(address indexed beneficiary);
  
}

// File: contracts/FKXSale.sol

/**
 * @title FKXSale
 * @dev FKXSale smart contracat used to mint and distrubute FKX tokens and lock up FKX tokens in the FKXTokenTimeLock smart contract.
 * Inheritance:
 * Ownable - lets FKXSale be ownable
 *
 */
contract FKXSale is Ownable {

  FKX public token;

  FKXTokenTimeLock public tokenLock;

  function FKXSale() public {

    token =  new FKX();

    tokenLock = new FKXTokenTimeLock(token);

  }

  /**
  * @dev Finalizes the sale and  token minting
  */
  function finalize() public onlyOwner {
    // Disable minting of FKX
    token.finishMinting();
  }

  /**
  * @dev Allocates tokens and bonus tokens to early-bird contributors.
  * @param beneficiary wallet
  * @param baseTokens amount of tokens to be received by beneficiary
  * @param bonusTokens amount of tokens to be locked up to beneficiary
  * @param releaseTime when to unlock bonus tokens
  */
  function mintBaseLockedTokens(address beneficiary, uint256 baseTokens, uint256 bonusTokens, uint256 releaseTime) public onlyOwner {
    require(beneficiary != 0x0);
    require(baseTokens > 0);
    require(bonusTokens > 0);
    require(releaseTime > now);
    require(!tokenLock.exists(beneficiary));
    
    // Mint base tokens to beneficiary
    token.mint(beneficiary, baseTokens);

    // Mint beneficiary&#39;s bonus tokens to the token time lock
    token.mint(tokenLock, bonusTokens);

    // Time lock the tokens
    tokenLock.lockTokens(beneficiary, releaseTime, bonusTokens);
  }

  /**
  * @dev Allocates bonus tokens to advisors, founders and company.
  * @param beneficiary wallet
  * @param tokens amount of tokens to be locked up to beneficiary
  * @param releaseTime when to unlock bonus tokens
  */
  function mintLockedTokens(address beneficiary, uint256 tokens, uint256 releaseTime) public onlyOwner {
    require(beneficiary != 0x0);
    require(tokens > 0);
    require(releaseTime > now);
    require(!tokenLock.exists(beneficiary));

    // Mint beneficiary&#39;s bonus tokens to the token time lock
    token.mint(tokenLock, tokens);

    // Time lock the tokens
    tokenLock.lockTokens(beneficiary, releaseTime, tokens);
  }

  /**
  * @dev Allocates tokens to beneficiary.
  * @param beneficiary wallet
  * @param tokens amount of tokens to be received by beneficiary
  */
  function mintTokens(address beneficiary, uint256 tokens) public onlyOwner {
    require(beneficiary != 0x0);
    require(tokens > 0);
    
    // Mint tokens to beneficiary
    token.mint(beneficiary, tokens);
  }

  /**
  * @dev Release locked tokens to all beneficiaries if they are due.
  * @param from the start lock index
  * @param to the end lock index
  */
  function releaseAll(uint from, uint to) public onlyOwner returns (bool) {
    tokenLock.releaseAll(from, to);

    return true;
  }


}