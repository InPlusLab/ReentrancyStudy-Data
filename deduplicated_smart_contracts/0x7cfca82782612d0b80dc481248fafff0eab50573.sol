/**

 *Submitted for verification at Etherscan.io on 2019-01-18

*/



pragma solidity 0.5.2;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

     /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;

        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);

        return c;

    }

}



contract ERC20 {

  function totalSupply()public view returns(uint total_Supply);

  function balanceOf(address _owner)public view returns(uint256 balance);

  function allowance(address _owner, address _spender)public view returns(uint remaining);

  function transferFrom(address _from, address _to, uint _amount)public returns(bool ok);

  function approve(address _spender, uint _amount)public returns(bool ok);

  function transfer(address _to, uint _amount)public returns(bool ok);

  event Transfer(address indexed _from, address indexed _to, uint _amount);

  event Approval(address indexed _owner, address indexed _spender, uint _amount);

}





contract BEECASHBACKHOME is ERC20

{

  using SafeMath for uint256;

  string public constant symbol = "CBH";

  string public constant name = "Bee Cashback Home";

  uint public constant decimals = 18;

  uint256 _totalSupply = 50000000 * 10 ** 18; // 50 Million Total Supply including 18 decimal



  // Owner of this contract

  address public owner;



  // Balances for each account

  mapping(address => uint256) balances;



  // Owner of account approves the transfer of an amount to another account

  mapping(address => mapping(address => uint256)) allowed;



  // Functions with this modifier can only be executed by the owner

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  // Constructor

  constructor() public {

    owner = msg.sender;

    balances[owner] = _totalSupply;

    emit Transfer(address(0), owner, _totalSupply);

  }



  // what is the total supply of the ech tokens

  function totalSupply() public view returns(uint256 total_Supply) {

    total_Supply = _totalSupply;

  }

  // What is the balance of a particular account?

  function balanceOf(address _owner)public view returns(uint256 balance) {

    return balances[_owner];

  }



  // Transfer the balance from owner's account to another account

  function transfer(address _to, uint256 _amount)public returns(bool ok) {

    require(_to != address(0));

    require(balances[msg.sender] >= _amount && _amount >= 0);

    balances[msg.sender] = (balances[msg.sender]).sub(_amount);

    balances[_to] = (balances[_to]).add(_amount);

    emit Transfer(msg.sender, _to, _amount);

    return true;

  }



  // Send _value amount of tokens from address _from to address _to

  // The transferFrom method is used for a withdraw workflow, allowing contracts to send

  // tokens on your behalf, for example to "deposit" to a contract address and/or to charge

  // fees in sub-currencies; the command should fail unless the _from account has

  // deliberately authorized the sender of the message via some mechanism; we propose

  // these standardized APIs for approval:

  function transferFrom(address _from, address _to, uint256 _amount)public returns(bool ok) {

    require(_to != address(0));

    require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);

    balances[_from] = (balances[_from]).sub(_amount);

    allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);

    balances[_to] = (balances[_to]).add(_amount);

    emit Transfer(_from, _to, _amount);

    return true;

  }



  // Allow _spender to withdraw from your account, multiple times, up to the _value amount.

  // If this function is called again it overwrites the current allowance with _value.

  function approve(address _spender, uint256 _amount)public returns(bool ok) {

    require(_spender != address(0));

    allowed[msg.sender][_spender] = _amount;

    emit Approval(msg.sender, _spender, _amount);

    return true;

  }



  function allowance(address _owner, address _spender)public view returns(uint256 remaining) {

    require(_owner != address(0) && _spender != address(0));

    return allowed[_owner][_spender];

  }



  //In case the ownership needs to be transferred

  function transferOwnership(address newOwner) external onlyOwner

  {

    uint256 ownBalance = balances[owner];

    require(newOwner != address(0));

    balances[newOwner] = (balances[newOwner]).add(balances[owner]);

    balances[owner] = 0;

    owner = newOwner;

    emit Transfer(msg.sender, newOwner, ownBalance);

  }









}