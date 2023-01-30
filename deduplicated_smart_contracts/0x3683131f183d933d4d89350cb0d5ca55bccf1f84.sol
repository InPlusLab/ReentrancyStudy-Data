/**

 *Submitted for verification at Etherscan.io on 2019-05-29

*/



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.5.2;



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

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



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.5.2;







/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://eips.ethereum.org/EIPS/eip-20

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    /**

     * @dev Total number of tokens in existence

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev Gets the balance of the specified address.

     * @param owner The address to query the balance of.

     * @return A uint256 representing the amount owned by the passed address.

     */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

     * @dev Transfer token to a specified address

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);

        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));

        return true;

    }



    /**

     * @dev Transfer token for a specified addresses

     * @param from The address to transfer from.

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Approve an address to spend another addresses' tokens.

     * @param owner The address that owns the tokens.

     * @param spender The address that will spend the tokens.

     * @param value The number of tokens that can be spent.

     */

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));

        require(owner != address(0));



        _allowed[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);

        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));

    }

}



// File: registry/contracts/Registry.sol



pragma solidity >=0.4.25 <0.6.0;





interface RegistryClone {

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) external;

}



contract Registry {

    struct AttributeData {

        uint256 value;

        bytes32 notes;

        address adminAddr;

        uint256 timestamp;

    }

    

    // never remove any storage variables

    address public owner;

    address public pendingOwner;

    bool initialized;



    // Stores arbitrary attributes for users. An example use case is an ERC20

    // token that requires its users to go through a KYC/AML check - in this case

    // a validator can set an account's "hasPassedKYC/AML" attribute to 1 to indicate

    // that account can use the token. This mapping stores that value (1, in the

    // example) as well as which validator last set the value and at what time,

    // so that e.g. the check can be renewed at appropriate intervals.

    mapping(address => mapping(bytes32 => AttributeData)) attributes;

    // The logic governing who is allowed to set what attributes is abstracted as

    // this accessManager, so that it may be replaced by the owner as needed

    bytes32 constant WRITE_PERMISSION = keccak256("canWriteTo-");

    mapping(bytes32 => RegistryClone[]) subscribers;



    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );

    event SetAttribute(address indexed who, bytes32 attribute, uint256 value, bytes32 notes, address indexed adminAddr);

    event SetManager(address indexed oldManager, address indexed newManager);

    event StartSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);

    event StopSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);



    // Allows a write if either a) the writer is that Registry's owner, or

    // b) the writer is writing to attribute foo and that writer already has

    // the canWriteTo-foo attribute set (in that same Registry)

    function confirmWrite(bytes32 _attribute, address _admin) internal view returns (bool) {

        bytes32 attr =  WRITE_PERMISSION ^ _attribute;

        bytes32 kesres = bytes32(keccak256(abi.encodePacked(attr)));

        return (_admin == owner || hasAttribute(_admin, kesres));

    }



    // Writes are allowed only if the accessManager approves

    function setAttribute(address _who, bytes32 _attribute, uint256 _value, bytes32 _notes) public {

        require(confirmWrite(_attribute, msg.sender));

        attributes[_who][_attribute] = AttributeData(_value, _notes, msg.sender, block.timestamp);

        emit SetAttribute(_who, _attribute, _value, _notes, msg.sender);



        RegistryClone[] storage targets = subscribers[_attribute];

        uint256 index = targets.length;

        while (index --> 0) {

            targets[index].syncAttributeValue(_who, _attribute, _value);

        }

    }



    function subscribe(bytes32 _attribute, RegistryClone _syncer) external onlyOwner {

        subscribers[_attribute].push(_syncer);

        emit StartSubscription(_attribute, _syncer);

    }



    function unsubscribe(bytes32 _attribute, uint256 _index) external onlyOwner {

        uint256 length = subscribers[_attribute].length;

        require(_index < length);

        emit StopSubscription(_attribute, subscribers[_attribute][_index]);

        subscribers[_attribute][_index] = subscribers[_attribute][length - 1];

        subscribers[_attribute].length = length - 1;

    }



    function subscriberCount(bytes32 _attribute) public view returns (uint256) {

        return subscribers[_attribute].length;

    }



    function setAttributeValue(address _who, bytes32 _attribute, uint256 _value) public {

        require(confirmWrite(_attribute, msg.sender));

        attributes[_who][_attribute] = AttributeData(_value, "", msg.sender, block.timestamp);

        emit SetAttribute(_who, _attribute, _value, "", msg.sender);

        RegistryClone[] storage targets = subscribers[_attribute];

        uint256 index = targets.length;

        while (index --> 0) {

            targets[index].syncAttributeValue(_who, _attribute, _value);

        }

    }



    // Returns true if the uint256 value stored for this attribute is non-zero

    function hasAttribute(address _who, bytes32 _attribute) public view returns (bool) {

        return attributes[_who][_attribute].value != 0;

    }





    // Returns the exact value of the attribute, as well as its metadata

    function getAttribute(address _who, bytes32 _attribute) public view returns (uint256, bytes32, address, uint256) {

        AttributeData memory data = attributes[_who][_attribute];

        return (data.value, data.notes, data.adminAddr, data.timestamp);

    }



    function getAttributeValue(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].value;

    }



    function getAttributeAdminAddr(address _who, bytes32 _attribute) public view returns (address) {

        return attributes[_who][_attribute].adminAddr;

    }



    function getAttributeTimestamp(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].timestamp;

    }



    function syncAttribute(bytes32 _attribute, uint256 _startIndex, address[] calldata _addresses) external {

        RegistryClone[] storage targets = subscribers[_attribute];

        uint256 index = targets.length;

        while (index --> _startIndex) {

            RegistryClone target = targets[index];

            for (uint256 i = _addresses.length; i --> 0; ) {

                address who = _addresses[i];

                target.syncAttributeValue(who, _attribute, attributes[who][_attribute].value);

            }

        }

    }



    function reclaimEther(address payable _to) external onlyOwner {

        _to.transfer(address(this).balance);

    }



    function reclaimToken(ERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(address(this));

        token.transfer(_to, balance);

    }



   /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyOwner() {

        require(msg.sender == owner, "only Owner");

        _;

    }



    /**

    * @dev Modifier throws if called by any account other than the pendingOwner.

    */

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);

        _;

    }



    /**

    * @dev Allows the current owner to set the pendingOwner address.

    * @param newOwner The address to transfer ownership to.

    */

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;

    }



    /**

    * @dev Allows the pendingOwner address to finalize the transfer.

    */

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);

        owner = pendingOwner;

        pendingOwner = address(0);

    }

}