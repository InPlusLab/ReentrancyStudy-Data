/**

 *Submitted for verification at Etherscan.io on 2019-01-18

*/



pragma solidity ^0.4.25;



contract ERC20Token {

    /* This is a slight change to the ERC20 base standard.

    function totalSupply() constant returns (uint256 supply);

    is replaced with:

    uint256 public totalSupply;

    This automatically creates a getter function for the totalSupply.

    This is moved to the base contract since public getter functions are not

    currently recognised as an implementation of the matching abstract

    function by the compiler.

    */

    /// total amount of tokens

    uint256 public totalSupply;



    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) public view returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success);



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 *

 * Contract source taken from Open Zeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/v1.4.0/contracts/ownership/Ownable.sol

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



library SafeMathLib {

    //

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    //

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b > 0 && a > 0);

        // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        return c;

    }



    //

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    //

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a && c >= b);

        return c;

    }

}



contract StandardToken is ERC20Token {

    using SafeMathLib for uint;



    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;



    //

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    //

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0));

        require(_value > 0 && balances[msg.sender] >= _value);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;

    }



    //

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0));

        require(_value > 0 && balances[_from] >= _value);

        require(allowed[_from][msg.sender] >= _value);



        balances[_to] = balances[_to].add(_value);

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;

    }



    //

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

}



contract YLZT is StandardToken, Ownable {



    string public name = "YLZT";

    string public symbol = "YLZT";

    uint256 public decimals = 18;

    uint256 public INITIAL_SUPPLY = (1) * (10 ** 8) * (10 ** 18);//1



    function YLZT(){

        totalSupply = INITIAL_SUPPLY;

        balances[msg.sender] = totalSupply;

    }



    function() public payable {

        revert();

    }



}