/**

 *Submitted for verification at Etherscan.io on 2018-12-14

*/



pragma solidity ^0.4.25;



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

  function transferOwnership(address newOwner) onlyOwner external {

    require(newOwner != address(0));

    // OwnershipTransferred(owner, newOwner);

   emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



library Locklist {

  

  struct List {

    mapping(address => bool) registry;

  }

  

  function add(List storage list, address _addr)

    internal

  {

    list.registry[_addr] = true;

  }



  function remove(List storage list, address _addr)

    internal

  {

    list.registry[_addr] = false;

  }



  function check(List storage list, address _addr)

    view

    internal

    returns (bool)

  {

    return list.registry[_addr];

  }

}



contract Locklisted is Ownable  {



  Locklist.List private _list;

  

  modifier onlyLocklisted() {

    require(Locklist.check(_list, msg.sender) == true);

    _;

  }



  event AddressAdded(address _addr);

  event AddressRemoved(address _addr);

  

  function LocklistedAddress()

  public

  {

    Locklist.add(_list, msg.sender);

  }



  function LocklistAddressenable(address _addr) onlyOwner

    public

  {

    Locklist.add(_list, _addr);

    emit AddressAdded(_addr);

  }



  function LocklistAddressdisable(address _addr) onlyOwner

    public

  {

    Locklist.remove(_list, _addr);

   emit AddressRemoved(_addr);

  }

  

  function LocklistAddressisListed(address _addr) public view  returns (bool)  {

      return Locklist.check(_list, _addr);

  }

}



interface IERC20 {

  

  function balanceOf(address _owner) public view returns (uint256);

  function allowance(address _owner, address _spender) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}













contract StandardToken is IERC20, Locklisted {



  mapping (address => mapping (address => uint256)) internal allowed;

   

  using SafeMath for uint256;

  uint256 public totalSupply;



  mapping(address => uint256) balances;



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(!LocklistAddressisListed(_to));

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

  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(!LocklistAddressisListed(_to));

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

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }



  /**

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   */

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

   emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {

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

 * @title Mintable token

 * @dev Simple ERC20 Token example, with mintable token creation

 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120

 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol

 */



contract MintableToken is Ownable, StandardToken {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();

  

  string public constant name = "Vertex Market";

  string public constant symbol = "VTEX";

  uint8 public constant decimals = 5;  // 18 is the most common number of decimal places

  bool public mintingFinished = false;

  

  // This notifies clients about the amount burnt

   event Burn(address indexed from, uint256 value);



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

    require(!LocklistAddressisListed(_to));

    totalSupply = totalSupply.add(_amount);

    require(totalSupply <= 30000000000000);

    balances[_to] = balances[_to].add(_amount);

    emit  Mint(_to, _amount);

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

  

  function burn(uint256 _value) onlyOwner public {

    require(_value <= balances[msg.sender]);

    address burner = msg.sender;

    balances[burner] = balances[burner].sub(_value);

    totalSupply = totalSupply.sub(_value);

    Burn(burner, _value);

}

  



}









//Change and check days and discounts

contract Vertex_Token is  MintableToken {

    using SafeMath for uint256;



    // The token being sold

    MintableToken  token;



   



    

    // total supply of tokens

    function totalTokenSupply()  internal returns (uint256) {

        return token.totalSupply();

    }

}