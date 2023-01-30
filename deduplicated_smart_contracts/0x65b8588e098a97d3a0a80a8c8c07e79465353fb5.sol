/**

 *Submitted for verification at Etherscan.io on 2019-03-24

*/



pragma solidity 0.5.6;

/**

 * TOKEN Contract

 * ERC-20 Token Standard Compliant

 */



/**

 * @title SafeMath by OpenZeppelin

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



}



/**

 * @title ERC20 Token minimal interface

 */

interface extToken {



    function balanceOf(address _owner) external returns(uint256 balance);



    function transfer(address _to, uint256 _value) external returns(bool success);



}



/**

 * Token contract declaration

 */

contract ERC20TokenInterface {



    function balanceOf(address _owner) public view returns(uint256 value);



    function transfer(address _to, uint256 _value) public returns(bool success);



    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);



    function approve(address _spender, uint256 _value) public returns(bool success);



    function allowance(address _owner, address _spender) public view returns(uint256 remaining);



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

    bool public lockSupply; //Burn Lock flag

    bool public lockTransfer; //Transfer Lock flag

    address public allowedAddress; //An address that can override lock condition



    /**

     * @dev Contract constructor

     * define initial administrator

     */

    constructor() public {

        owner = 0xb4549c4CBbB5003beEb2b70098E6f5AD4CE4c2e6; //Set initial owner to contract creator

        level[0xb4549c4CBbB5003beEb2b70098E6f5AD4CE4c2e6] = 2;

        emit Owned(owner);

    }



    /**

     * @dev Function to set an allowed address

     * @param _to The address to give privileges.

     */

    function setAllowedAddress(address _to) onlyAdmin(2) public {

        allowedAddress = _to;

        emit AllowedSet(_to);

    }



    modifier onlyAdmin(uint8 _level) { //A modifier to define admin-only functions

        require(msg.sender == owner || level[msg.sender] >= _level);

        _;

    }



    modifier supplyLock() { //A modifier to lock burn transactions

        require(lockSupply == false);

        _;

    }



    modifier transferLock() { //A modifier to lock transactions

        require(lockTransfer == false || allowedAddress == msg.sender);

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

        emit AdminLevelSet(_target, _level);

    }



    /**

     * @dev Function to set burn locks

     * @param _set boolean flag (true | false)

     */

    function setSupplyLock(bool _set) onlyAdmin(2) public { //Only the admin can set a lock on supply

        lockSupply = _set;

        emit SetSupplyLock(_set);

    }



    /**

     * @dev Function to set global transfer lock

     * @param _set boolean flag (true | false)

     */

    function setTransferLock(bool _set) onlyAdmin(2) public { //Only the admin can set a lock on transfers

        lockTransfer = _set;

        emit SetTransferLock(_set);

    }



    //All admin actions have a log for public review

    event AllowedSet(address _to);

    event SetSupplyLock(bool _set);

    event SetTransferLock(bool _set);

    event TransferAdminship(address newAdminister);

    event Owned(address administer);

    event AdminLevelSet(address _target, uint8 _level);



}



/**

 * @title Token definition

 * @dev Define token paramters including ERC20 ones

 */

contract ERC20Token is ERC20TokenInterface, admined { //Standard definition of a ERC20Token

    using SafeMath

    for uint256;

    uint256 public totalSupply;

    mapping(address => uint256) balances; //A mapping of all balances per address

    mapping(address => mapping(address => uint256)) allowed; //A mapping of all allowances

    mapping(address => bool) frozen; //A mapping of frozen accounts



    /**

     * @dev Get the balance of an specified address.

     * @param _owner The address to be query.

     */

    function balanceOf(address _owner) public view returns(uint256 value) {

        return balances[_owner];

    }



    /**

     * @dev transfer token to a specified address

     * @param _to The address to transfer to.

     * @param _value The amount to be transferred.

     */

    function transfer(address _to, uint256 _value) transferLock public returns(bool success) {

        require(frozen[msg.sender] == false);

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

    function transferFrom(address _from, address _to, uint256 _value) transferLock public returns(bool success) {

        require(frozen[_from] == false);

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

    function approve(address _spender, uint256 _value) public returns(bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * @dev Get the allowance of an specified address to use another address balance.

     * @param _owner The address of the owner of the tokens.

     * @param _spender The address of the allowed spender.

     */

    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {

        return allowed[_owner][_spender];

    }



    /**

     * @dev Burn token of an specified address.

     * @param _burnedAmount amount to burn.

     */

    function burnToken(uint256 _burnedAmount) onlyAdmin(2) supplyLock public {

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);

        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);

        emit Burned(msg.sender, _burnedAmount);

    }



    /**

     * @dev Frozen account.

     * @param _target The address to being frozen.

     * @param _flag The status of the frozen

     */

    function setFrozen(address _target, bool _flag) onlyAdmin(2) public {

        frozen[_target] = _flag;

        emit FrozenStatus(_target, _flag);

    }





    /**

     * @dev Log Events

     */

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burned(address indexed _target, uint256 _value);

    event FrozenStatus(address _target, bool _flag);

}



/**

 * @title Asset

 * @dev Initial supply creation

 */

contract Asset is ERC20Token {

    string public name = 'ORIGIN Foundation Token';

    uint8 public decimals = 18;

    string public symbol = 'ORIGIN';

    string public version = '1';



    constructor() public {

        totalSupply = 100000000000 * (10 ** uint256(decimals)); //initial token creation

        balances[0xb4549c4CBbB5003beEb2b70098E6f5AD4CE4c2e6] = totalSupply;

        emit Transfer(address(0), 0xb4549c4CBbB5003beEb2b70098E6f5AD4CE4c2e6, balances[0xb4549c4CBbB5003beEb2b70098E6f5AD4CE4c2e6]);

    }



    /**

     * @notice Function to claim ANY token stuck on contract accidentally

     * In case of claim of stuck tokens please contact contract owners

     */

    function claimExtTokens(extToken _address, address _to) onlyAdmin(2) public {

        require(_to != address(0));

        uint256 remainder = _address.balanceOf(address(this)); //Check remainder tokens

        _address.transfer(_to, remainder); //Transfer tokens to creator

    }



    /**

     *@dev Function to handle callback calls

     */

    function () external {

        revert();

    }



}