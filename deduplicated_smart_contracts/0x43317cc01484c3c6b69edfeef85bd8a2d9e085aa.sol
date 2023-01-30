/**

 *Submitted for verification at Etherscan.io on 2019-03-11

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't h4old

        return c;

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



  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





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

   * @dev Allows the current owner to relinquish control of the contract.

   */

//   function renounceOwnership() public onlyOwner {

//     emit OwnershipRenounced(owner);

//     owner = address(0);

//   }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



contract Freezing is Ownable {

  event Freeze();

  event Unfreeze();

  event Freeze(address to);

  event UnfreezeOf(address to);

  event TransferAccessOn();

  event TransferAccessOff();



  bool public freezed = false;

  

  mapping (address => bool) public freezeOf;

  mapping (address => bool) public transferAccess;



  modifier whenNotFreeze() {

    require(!freezed);

    _;

  }



  modifier whenFreeze() {

    require(freezed);

    _;

  }



  modifier whenNotFreezeOf(address _account) {

    require(!freezeOf[_account]);

    _;

  }



  modifier whenFreezeOf(address _account) {

    require(freezeOf[_account]);

    _;

  }

  

  modifier onTransferAccess(address _account) {

      require(transferAccess[_account]);

      _;

  }

  

  modifier offTransferAccess(address _account) {

      require(!transferAccess[_account]);

      _;

  }



  function freeze() onlyOwner whenNotFreeze public {

    freezed = true;

    emit Freeze();

  }



  function unfreeze() onlyOwner whenFreeze public {

    freezed = false;

    emit Unfreeze();

  }

  

  function freezeOf(address _account) onlyOwner whenNotFreeze public {

    freezeOf[_account] = true;

    emit Freeze(_account);

  }



  function unfreezeOf(address _account) onlyOwner whenFreeze public  {

    freezeOf[_account] = false;

    emit UnfreezeOf(_account);

  }

  

  function transferAccessOn(address _account) onlyOwner offTransferAccess(_account) public {

      transferAccess[_account] = true;

      emit TransferAccessOn();

  }

  

  function transferAccessOff(address _account) onlyOwner onTransferAccess(_account) public {

      transferAccess[_account] = false;

      emit TransferAccessOff();

  }

  

}





/**

 * @title ERC20Basic 

 * @dev Simpler version of ERC20 interface 

 * @dev see https://github.com/ethereum/EIPs/issues/20 

 */ 

contract ERC20Basic {

     uint public totalSupply;

     function balanceOf(address who) public constant returns (uint); 

     function transfer(address to, uint value) public ; 

     event Transfer(address indexed from, address indexed to, uint value); 

    

} 



/** 

 * @title ERC20 interface 

 * @dev see https://github.com/ethereum/EIPs/issues/20 

 */



contract BasicToken is ERC20Basic, Freezing {

  using SafeMath for uint;



  mapping(address => uint) balances;



  /**

   * @dev Fix for the ERC20 short address attack.

   */

  modifier onlyPayloadSize(uint size) {

     require(msg.data.length >= size + 4);

     _;

  }

  

  function transfer(address _to, uint _value) 

    public 

    onlyPayloadSize(2 * 32)

    whenNotFreeze

    whenNotFreezeOf(msg.sender)

    whenNotFreezeOf(_to)

  {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

  }

  

  function accsessAccountTransfer(address _to, uint _value) 

    public 

    onlyPayloadSize(2 * 32)

    onTransferAccess(msg.sender)

  {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

  }



  function balanceOf(address _owner) public constant returns (uint balance) {

    return balances[_owner];

  }



}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;



  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    onlyPayloadSize(3 * 32)

    whenNotFreeze

    whenNotFreezeOf(_from)

    whenNotFreezeOf(_to)

    returns (bool)

  {

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

  function allowance(

    address _owner,

    address _spender

   )

    public

    view

    returns (uint256)

  {

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

  function increaseApproval(

    address _spender,

    uint _addedValue

  )

    public

    returns (bool)

  {

    allowed[msg.sender][_spender] = (

      allowed[msg.sender][_spender].add(_addedValue));

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

  function decreaseApproval(

    address _spender,

    uint _subtractedValue

  )

    public

    returns (bool)

  {

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

 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120

 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol

 */

contract MintableToken is StandardToken {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;





  modifier canMint() {

    require(!mintingFinished);

    _;

  }



  modifier hasMintPermission() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Function to mint tokens

   * @param _to The address that will receive the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(

    address _to,

    uint256 _amount

  )

    hasMintPermission

    canMint

    public

    returns (bool)

  {

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



contract PolestarToken is MintableToken {

    using SafeMath for uint256;

    

    string public name = 'PolestarToken';

    string public symbol = 'PST';

    uint8 public decimals = 18;

    

}