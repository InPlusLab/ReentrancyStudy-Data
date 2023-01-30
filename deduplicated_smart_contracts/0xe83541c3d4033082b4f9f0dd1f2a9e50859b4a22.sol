/**

 *Submitted for verification at Etherscan.io on 2018-10-25

*/



pragma solidity ^0.4.24;



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



contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



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



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

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



  /**

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





contract AddressesFilterFeature is Ownable {



  mapping(address => bool) public allowedAddresses;



  function addAllowedAddress(address allowedAddress) public onlyOwner {

    allowedAddresses[allowedAddress] = true;

  }



  function removeAllowedAddress(address allowedAddress) public onlyOwner {

    allowedAddresses[allowedAddress] = false;

  }



}



contract MintableToken is AddressesFilterFeature, StandardToken {



  event Mint(address indexed to, uint256 amount);



  event MintFinished();



  bool public mintingFinished = false;



  address public saleAgent;



  mapping (address => uint) public initialBalances;



  uint public vestingPercent;



  uint public constant percentRate = 100;



  uint256 public constant maxCapOfTokens = 5 * 10**9 * 10**18;



  uint public constant lockPeriodForTMwallet = 6 * 30 * 24 * 60 * 60; //6 months

  uint public lockPeriodEndForTMwallet;

  



  address tm_wallet   = 0x22bdc72e45780ce240b729c1354da27dfa861f5e;

  address com_wallet  = 0x20190bf6F8C8c74067420C11A0448A61C80d5D2B;

  address adv1_wallet = 0xa965C07e210f22175E48975d6e7617cedB7e173A;

  address adv2_wallet = 0x34ef96c150e6d317bd8ebaade2e26c04643f44f7;

  address adv3_wallet = 0x0950823c0f99967ae4ab69bb2c5d75a82006e68b;

  address adv4_wallet = 0x4f89aacc3915132ece2e0fef02036c0f33879ea8;

  address dev_wallet  = 0x2CA7608fF0b552fCB66714D9F7587245b4a393eC;





  modifier notLocked(address _from, uint _value) {

    if(!(_from == owner || _from == saleAgent || allowedAddresses[_from])) {

      require(mintingFinished);

      if (_from == tm_wallet) {

        require ( now > lockPeriodEndForTMwallet);

      } else 

      if((vestingPercent <= percentRate) && (vestingPercent != 0)) {

        uint minLockedBalance = initialBalances[_from].mul(vestingPercent).div(percentRate);

        require(minLockedBalance <= balances[_from].sub(_value));

      }

    }

    _;

  }



  constructor () public {

    lockPeriodEndForTMwallet = now + lockPeriodForTMwallet;

  }



  function setVestingPercent(uint newVestingPercent) public {

    require(msg.sender == saleAgent || msg.sender == owner);

    vestingPercent = newVestingPercent;

  }



  function setSaleAgent(address newSaleAgnet) public {

    require(msg.sender == saleAgent || msg.sender == owner);

    saleAgent = newSaleAgnet;

  }



  function mint(address _to, uint256 _amount) public returns (bool) {

    require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);

    require(totalSupply.add(_amount) <= maxCapOfTokens);

    

    totalSupply = totalSupply.add(_amount);

    balances[_to] = balances[_to].add(_amount);



    initialBalances[_to] = balances[_to];



    emit Mint(_to, _amount);

    emit Transfer(address(0), _to, _amount);

    return true;

  }



  /**

   * @dev Function to stop minting new tokens.

   * @return True if the operation was successful.

   */

  function finishMinting() public returns (bool) {

    require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);



    // mint 900M MAKE tokens to tm_wallet

    mint(tm_wallet, 900000000 * 10**18);

    

    //advisors amounts

    mint(com_wallet,         1 * 10**18);

    mint(adv1_wallet,  1000000 * 10**18);

    mint(adv2_wallet, 35000000 * 10**18);

    mint(adv3_wallet, 15000000 * 10**18);

    mint(adv4_wallet,  9800000 * 10**18);





    mintingFinished = true;

    emit MintFinished();

    return true;

  }



  function transfer(address _to, uint256 _value) public notLocked(msg.sender, _value)  returns (bool) {

    return super.transfer(_to, _value);

  }



  function transferFrom(address from, address to, uint256 value) public notLocked(from, value) returns (bool) {

    return super.transferFrom(from, to, value);

  }



}



contract ReceivingContractCallback {



  function tokenFallback(address _from, uint _value) public;



}



contract MAKEToken is MintableToken {



  string public constant name = "MAKEtoken";



  string public constant symbol = "MAKE";



  uint32 public constant decimals = 18;



  mapping(address => bool)  public registeredCallbacks;



  function transfer(address _to, uint256 _value) public returns (bool) {

    return processCallback(super.transfer(_to, _value), msg.sender, _to, _value);

  }



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    return processCallback(super.transferFrom(_from, _to, _value), _from, _to, _value);

  }



  function registerCallback(address callback) public onlyOwner {

    registeredCallbacks[callback] = true;

  }



  function deregisterCallback(address callback) public onlyOwner {

    registeredCallbacks[callback] = false;

  }



  function processCallback(bool result, address from, address to, uint value) internal returns(bool) {

    if (result && registeredCallbacks[to]) {

      ReceivingContractCallback targetCallback = ReceivingContractCallback(to);

      targetCallback.tokenFallback(from, value);

    }

    return result;

  }



}