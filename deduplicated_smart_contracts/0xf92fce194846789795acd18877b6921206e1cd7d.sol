/**

 *Submitted for verification at Etherscan.io on 2018-11-20

*/



pragma solidity 0.4.25;

/**

* PRIWGR TOKEN Contract

* ERC-20 Token Standard Compliant

* @author Fares A. Akel C. [email protected]

*/



/**

 * @title SafeMath by OpenZeppelin

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



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

* @title ERC20 Token minimal interface

*/

contract token {



    function balanceOf(address _owner) public constant returns (uint256 balance);

    //Since some tokens doesn't return a bool on transfer, this general interface

    //doesn't include a return on the transfer fucntion to be widely compatible

    function transfer(address _to, uint256 _value) public;



}



/**

 * Token contract interface for external use

 */

contract ERC20TokenInterface {



    function balanceOf(address _owner) public constant returns (uint256 value);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);



    }





/**

* @title Admin parameters

* @dev Define administration parameters for this contract

*/

contract admined { //This token contract is administered

    //The master address of the contract is called owner since etherscan

    //uses this name to recognize the owner of the contract

    address public owner; //Master address is public

    mapping(address => uint256) public level; //Admin level

    bool public lockSupply; //Mint and Burn Lock flag



    /**

    * @dev Contract constructor

    * define initial administrator

    */

    constructor() public {

        owner = msg.sender; //Set initial owner to contract creator

        level[msg.sender] = 2;

        emit Owned(owner);

    }



    modifier onlyAdmin(uint8 _level) { //A modifier to define admin-only functions

        require(msg.sender == owner || level[msg.sender] >= _level);

        _;

    }



    modifier supplyLock() { //A modifier to lock mint and burn transactions

        require(lockSupply == false);

        _;

    }



   /**

    * @dev Function to set new owner address

    * @param _newOwner The address to transfer administration to

    */

    function transferOwnership(address _newOwner) onlyAdmin(2) public { //owner can be transfered

        require(_newOwner != address(0));

        owner = _newOwner;

        level[_newOwner] = 2;

        emit TransferAdminship(owner);

    }



    function setAdminLevel(address _target, uint8 _level) onlyAdmin(2) public {

        level[_target] = _level;

        emit AdminLevelSet(_target,_level);

    }



   /**

    * @dev Function to set mint and burn locks

    * @param _set boolean flag (true | false)

    */

    function setSupplyLock(bool _set) onlyAdmin(2) public { //Only the admin can set a lock on supply

        lockSupply = _set;

        emit SetSupplyLock(_set);

    }



    //All admin actions have a log for public review

    event SetSupplyLock(bool _set);

    event TransferAdminship(address newAdminister);

    event Owned(address administer);

    event AdminLevelSet(address _target,uint8 _level);



}



/**

* @title Token definition

* @dev Define token paramters including ERC20 ones

*/

contract ERC20Token is ERC20TokenInterface, admined { //Standard definition of a ERC20Token

    using SafeMath for uint256;

    uint256 public totalSupply;

    mapping (address => uint256) balances; //A mapping of all balances per address

    mapping (address => mapping (address => uint256)) allowed; //A mapping of all allowances



    /**

    * @dev Get the balance of an specified address.

    * @param _owner The address to be query.

    */

    function balanceOf(address _owner) public constant returns (uint256 value) {

        return balances[_owner];

    }



    /**

    * @dev transfer token to a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0)); //If you dont want that people destroy token

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    /**

    * @dev transfer token from an address to another specified address using allowance

    * @param _from The address where token comes.

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0)); //If you dont want that people destroy token

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

    * @dev Assign allowance to an specified address to use the owner balance

    * @param _spender The address to be allowed to spend.

    * @param _value The amount to be allowed.

    */

    function approve(address _spender, uint256 _value) public returns (bool success) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0)); //exploit mitigation

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

    * @dev Get the allowance of an specified address to use another address balance.

    * @param _owner The address of the owner of the tokens.

    * @param _spender The address of the allowed spender.

    */

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    /**

    * @dev Burn tokens.

    * @param _burnedAmount amount to burn.

    */

    function burnToken(uint256 _burnedAmount) onlyAdmin(2) supplyLock public {

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);

        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);

        emit Burned(msg.sender, _burnedAmount);

    }





    /**

    * @dev Log Events

    */

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burned(address indexed _target, uint256 _value);

}



/**

* @title Asset

* @dev Initial supply creation

*/

contract Asset is ERC20Token {

    string public name = 'Pri-Sale Wager Token';

    uint8 public decimals = 18;

    string public symbol = 'PRIWGR';

    string public version = '1';



    constructor() public {

        totalSupply = 10000000 * (10**uint256(decimals)); //initial token creation

        balances[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, balances[msg.sender]);

    }



    /**

    * @notice Function to claim ANY token stuck on contract accidentally

    * In case of claim of stuck tokens please contact contract owners

    */

    function claimTokens(token _address, address _to) onlyAdmin(2) public{

        require(_to != address(0));

        uint256 remainder = _address.balanceOf(this); //Check remainder tokens

        _address.transfer(_to,remainder); //Transfer tokens to creator

    }



    /**

    *@dev Function to handle callback calls

    */

    function() public {

        revert();

    }



}