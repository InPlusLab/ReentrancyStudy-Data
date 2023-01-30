/**

 *Submitted for verification at Etherscan.io on 2019-04-23

*/



pragma solidity ^0.4.19;



contract Ownable {

  address public owner;



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

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));      

    owner = newOwner;

  }



}



library AddressUtils {

  function isContract(address addr) internal view returns (bool) {

    uint256 size;

    assembly { size := extcodesize(addr) }

    return size > 0;

  }

}



interface ERC165ReceiverInterface {

  function tokensReceived(address _from, address _to, uint _amount, bytes _data) external returns (bool);

}



contract supportERC165Basic {

	bytes4 constant InvalidID = 0xffffffff;

  bytes4 constant ERC165ID = 0x01ffc9a7;

	

	function transfer_erc165(address to, uint256 value, bytes _data) public returns (bool);



  function doesContractImplementInterface(address _contract, bytes4 _interfaceId) internal view returns (bool) {

      uint256 success;

      uint256 result;



      (success, result) = noThrowCall(_contract, ERC165ID);

      if ((success==0)||(result==0)) {

          return false;

      }

  

      (success, result) = noThrowCall(_contract, InvalidID);

      if ((success==0)||(result!=0)) {

          return false;

      }



      (success, result) = noThrowCall(_contract, _interfaceId);

      if ((success==1)&&(result==1)) {

          return true;

      }

      return false;

  }



  function noThrowCall(address _contract, bytes4 _interfaceId) constant internal returns (uint256 success, uint256 result) {

      bytes4 erc165ID = ERC165ID;



      assembly {

              let x := mload(0x40)               // Find empty storage location using "free memory pointer"

              mstore(x, erc165ID)                // Place signature at begining of empty storage

              mstore(add(x, 0x04), _interfaceId) // Place first argument directly next to signature



              success := staticcall(

                                  30000,         // 30k gas

                                  _contract,     // To addr

                                  x,             // Inputs are stored at location x

                                  0x20,          // Inputs are 32 bytes long

                                  x,             // Store output over input (saves space)

                                  0x20)          // Outputs are 32 bytes long



              result := mload(x)                 // Load the result

      }

  }	

}





contract ERC20Basic is supportERC165Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  using AddressUtils for address;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



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

	

    /** Support ERC165 */

    if (_to.isContract()) {

      ERC165ReceiverInterface i;

      if(doesContractImplementInterface(_to, i.tokensReceived.selector)) {

        ERC165ReceiverInterface app= ERC165ReceiverInterface(_to);

        app.tokensReceived(msg.sender, _to, _value, "");

      }

	  }

    return true;

  }

  

  /**

  * transfer with ERC165 interface

  **/

  function transfer_erc165(address _to, uint256 _value, bytes _data) public returns (bool) {

    //transfer(_to, _value);



    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    // SafeMath.sub will throw if there is not enough balance.

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

      

    // Support ERC165

    //don't need to check??

    if (!_to.isContract()) revert();

    

    ERC165ReceiverInterface i;

    if(!doesContractImplementInterface(_to, i.tokensReceived.selector)) revert(); 

    ERC165ReceiverInterface app= ERC165ReceiverInterface(_to);

    app.tokensReceived(msg.sender, _to, _value, _data);

    

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

    Transfer(_from, _to, _value);

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

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

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

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



contract kinwa is StandardToken, Ownable {

  string public name = "KINWA Token";

  string public symbol = "KINWA";

  uint public decimals = 8;

    

  function kinwa() public {

    owner = msg.sender;

	

    totalSupply_= 100 * 10 ** (8+9);  //100 Billion

	  balances[owner] = totalSupply_;

	

	  Transfer(address(0), owner, totalSupply_);

  }



}