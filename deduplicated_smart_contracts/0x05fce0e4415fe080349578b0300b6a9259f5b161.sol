/**

 *Submitted for verification at Etherscan.io on 2018-12-15

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

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

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}

contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant public returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}





/*  ERC 20 token */

contract StandardToken is Token {



    function transfer(address _to, uint256 _value) public returns (bool success) {

      if (balances[msg.sender] >= _value && _value > 0) {

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

      } else {

        return false;

      }

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

        balances[_to] += _value;

        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;

      } else {

        return false;

      }

    }



    function balanceOf(address _owner) constant public returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract PLAASlock is Ownable, StandardToken {

  using SafeMath for uint256;

  mapping (address => uint256) allocations;

  uint256 public  unlockDate = 1576418602; //Enter the Unlock Date(GNU epoch Timestamp)

  StandardToken public PLS;

  uint256 public constant exponent = 10**18; // 10**(number of decimals in the token)

  event TransferredToken(address indexed to, uint256 value);

  event FailedTransfer(address indexed to, uint256 value);

 

 

  



  constructor() public{

    PLS = StandardToken(0x8d9626315e8025b81c3bdb926db4c51dde237f52); // Enter Token Smart Contract Address

   

    allocations[0x09074cA496b17dAb0E1D359aa90cE7Ad5dbE3a93] = 12216000;  //The beneficiary address along with number of tokens to be locked.

    

  }

   function isActive() constant public returns (bool) {

    return (

        tokensAvailable() > 0 // Tokens must be available to send

    );

  }

   //below function can be used when you want to send every recipeint with different number of tokens

 

  

  

  function tokensAvailable() constant public returns (uint256) {

    return PLS.balanceOf(this);

  }

  

 

  

  function changeUnlockDate(uint256 _unlockDate) public onlyOwner{

      

      if(now> _unlockDate) revert();

      

       unlockDate = _unlockDate;

      

  }

  function unlock() external {

    if(now < unlockDate) revert();

    uint256 entitled = allocations[msg.sender];

    allocations[msg.sender] = 0;

    if(!StandardToken(PLS).transfer(msg.sender, entitled * exponent)) revert();

  }

 function destroy() onlyOwner public{

    uint256 balance = tokensAvailable();

    require (balance > 0);

    PLS.transfer(owner(), balance);

    selfdestruct(owner());

  }



}