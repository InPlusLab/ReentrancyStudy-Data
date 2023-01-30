/**
 *
 * MIT License
 *
 * Copyright (c) 2018, TOPEX Developers & OpenZeppelin Project.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

pragma solidity ^0.4.24;

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
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Destructible is Ownable {

  constructor() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    emit Transfer(msg.sender, _to, _value);
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
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /*
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

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
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract TPXToken is MintableToken, Destructible {

  string  public name = 'TOPEX Token';
  string  public symbol = 'TPX';
  uint8   public decimals = 18;
  uint256 public maxSupply = 200000000 ether;    // max allowable minting.
  bool    public transferDisabled = true;         // disable transfer init.

  event Confiscate(address indexed offender, uint256 value);

  // empty constructor
  constructor() public {}

  /*
   * the real reason for quarantined addresses are for those who are
   * mistakenly sent the TPX tokens to the wrong address. We can disable
   * the usage of the TPX tokens here.
   */
  mapping(address => bool) quarantined;           // quarantined addresses
  mapping(address => bool) gratuity;              // locked addresses for owners

  modifier canTransfer() {
    if (msg.sender == owner) {
      _;
    } else {
      require(!transferDisabled);
      require(quarantined[msg.sender] == false);  // default bool is false
      require(gratuity[msg.sender] == false);     // default bool is false
      _;
    }
  }

  /*
   * Allow the transfer of tokens to happen once ICO finished
   */
  function allowTransfers() onlyOwner public returns (bool) {
    transferDisabled = false;
    return true;
  }

  function disallowTransfers() onlyOwner public returns (bool) {
    transferDisabled = true;
    return true;
  }

  function quarantineAddress(address _addr) onlyOwner public returns (bool) {
    quarantined[_addr] = true;
    return true;
  }

  function unQuarantineAddress(address _addr) onlyOwner public returns (bool) {
    quarantined[_addr] = false;
    return true;
  }

  function lockAddress(address _addr) onlyOwner public returns (bool) {
    gratuity[_addr] = true;
    return true;
  }

  function unlockAddress(address _addr) onlyOwner public returns (bool) {
    gratuity[_addr] = false;
    return true;
  }

  /**
   * This is confiscate the money that is sent to the wrong address accidentally.
   * the confiscated value can then be transferred to the righful owner. This is
   * especially important during ICO where some are *still* using Exchanger wallet
   * address, instead of their personal address.
   */
  function confiscate(address _offender) onlyOwner public returns (bool) {
    uint256 all = balances[_offender];
    require(all > 0);
    
    balances[_offender] = balances[_offender].sub(all);
    balances[msg.sender] = balances[msg.sender].add(all);
    emit Confiscate(_offender, all);
    return true;
  }

  /*
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply <= maxSupply);
    return super.mint(_to, _amount);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) canTransfer public returns (bool) {
    return super.approve(_spender, _value);
  }
}

/**
 * The TPXCrowdsale contract.
 * The token is based on ERC20 Standard token, with ERC23 functionality to reclaim
 * other tokens accidentally sent to this contract, as well as to destroy
 * this contract once the ICO has ended.
 */
contract TPXCrowdsale is CanReclaimToken, Destructible {
  using SafeMath for uint256;

  // The token being sold 
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime = 0;
  uint256 public endTime = 0;

  // address where funds are collected
  address public wallet = address(0);

  // amount of raised money in wei
  uint256 public weiRaised = 0;

  // cap for crowdsale
  uint256 public cap = 20000 ether;

  // whitelist backers
  mapping(address => bool) whiteList;

  // addmin list
  mapping(address => bool) adminList;

  // mappig of our days, and rates.
  mapping(uint8 => uint256) daysRates;

  modifier onlyAdmin() { 
    require(adminList[msg.sender] == true || msg.sender == owner);
    _; 
  }
  
  /**
   * eurchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, 
                      uint256 value, uint256 amount);

  constructor(MintableToken _token) public {

    // Token contract address to enter 
    token = _token;
    startTime = 1532952000; 
    endTime = startTime + 79 days;
    // TPX Owner wallet address
    wallet = 0x44f43463C5663C515cD1c3e53B226C335e41D970;

    // set the days lapsed, and rates(tokens per ETH) for the period since startTime.
    daysRates[51] = 7000;
    // 40% bonus 45 days - private sale for whitelisted only!
    daysRates[58] = 6500;
    // 30% bonus first week of ICO -  public crowdsale
    daysRates[65] = 6000;
    // 20% bonus second week of ICO -  public crowdsale
    daysRates[72] = 5500;
    // 10% bonus third week of ICO -  public crowdsale
    daysRates[79] = 5000;
    // 0% bonus fourth week of ICO -  public crowdsale
  }

  function setTokenOwner (address _newOwner) public onlyOwner {
    token.transferOwnership(_newOwner);
  }

  function addWhiteList (address _backer) public onlyAdmin returns (bool res) {
    whiteList[_backer] = true;
    return true;
  }
  
  function addAdmin (address _admin) onlyAdmin public returns (bool res) {
    adminList[_admin] = true;
    return true;
  }

  function isWhiteListed (address _backer) public view returns (bool res) {
    return whiteList[_backer];
  }

  function isAdmin (address _admin) public view returns (bool res) {
    return adminList[_admin];
  }
  
  function totalRaised() public view returns (uint256) {
    return weiRaised;
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(getRate());

    // update state
    weiRaised = weiRaised.add(weiAmount);

    if (tokens > 0) {
      token.mint(beneficiary, tokens);
      emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);      
    }

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    // 73 days of sale.
    bool withinPeriod = (now >= startTime && now <= endTime) || msg.sender == owner;
    bool nonZeroPurchase = msg.value != 0;
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinPeriod && nonZeroPurchase && withinCap;
  }

  function getRate() internal view returns (uint256 rate) {
    uint256 diff = (now - startTime);

    if (diff <= 51 days) {
      require(whiteList[msg.sender] == true);
      return daysRates[51];
    } else if (diff > 51 && diff <= 58 days) {
      return daysRates[58];
    } else if (diff > 58 && diff <= 65 days) {
      return daysRates[65];
    } else if (diff > 65 && diff <= 72 days) {
      return daysRates[72];
    } else if (diff <= 79 days) {
      return daysRates[79];
    } 
    return 0;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return now > endTime || capReached;
  }
}