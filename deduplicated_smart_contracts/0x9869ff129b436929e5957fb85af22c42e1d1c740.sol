/**

 *Submitted for verification at Etherscan.io on 2019-02-15

*/



/*

This file is TopTenCoinToken Contract

*/



pragma solidity ^0.5.1;



/**

 * @title ERC20Basic

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title SafeMath

 */

library SafeMath {



  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return a * b;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal pure  returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }



}



/**

 * @title Basic token

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



/**

 * @title Standard ERC20 token

 */

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) allowed;



  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 The amout of tokens to be transfered

   */

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    uint256 _allowance = allowed[_from][msg.sender];



    balances[_to] = balances[_to].add(_value);

    balances[_from] = balances[_from].sub(_value);

    allowed[_from][msg.sender] = _allowance.sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {



    require((_value == 0) || (allowed[msg.sender][_spender] == 0));



    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifing the amount of tokens still available for the spender.

   */

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }



}



/**

 * @title Ownable

 */

contract Ownable {



  address public owner;



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor () public {

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

    owner = newOwner;

  }



}



/**

 * @title Mintable token

 */

contract MintableToken is StandardToken, Ownable {



  event MintFinished();



  bool public mintingFinished = false;



  modifier canMint() {

    require(!mintingFinished);

    _;

  }



  /**

   * @dev Function to mint tokens

   * @param _to The address that will recieve the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {

    totalSupply = totalSupply.add(_amount);

    balances[_to] = balances[_to].add(_amount);

    emit Transfer(address(0), _to, _amount);

    return true;

  }



  /**

   * @dev Function to stop minting new tokens.

   * @return A boolean that indicates if the operation was successful.

   */

  function finishMinting() public onlyOwner returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }



}



contract TopTenCoinToken is MintableToken {



    string public constant name = "Top Ten Coin";



    string public constant symbol = "TPT";



    uint32 public constant decimals = 8;



}