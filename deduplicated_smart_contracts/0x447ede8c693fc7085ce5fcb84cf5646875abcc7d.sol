/**

 *Submitted for verification at Etherscan.io on 2019-06-06

*/



pragma solidity 0.5.8;



/**

 * @title SafeMath 

 * @dev Unsigned math operations with safety checks that revert on error.

 */

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, revert on overflow.

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

     * @dev Integer division of two unsigned integers truncating the quotient, revert on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtract two unsigned integers, revert on underflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Add two unsigned integers, revert on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }

}



/**

 * @title ERC20 interface

 * @dev See https://eips.ethereum.org/EIPS/eip-20

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



contract Ownable {

    address internal _owner;

    address private _pendingOwner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @return The address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @return The address of the pending owner.

     */

    function pendingOwner() public view returns (address) {

        return _pendingOwner;

    }

    

    /**

     * @dev Revert if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: the caller must be owner");

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: cannot transfer control of the contract to the zero address");

        _pendingOwner = newOwner;

    }



    /**

     * @dev Receive control of the contract.

     */

    function receiveOwnership() public {

        require(msg.sender == _pendingOwner, "Ownable: the caller must be pending owner");

        emit OwnershipTransferred(_owner, _pendingOwner);

        _owner = _pendingOwner;

        _pendingOwner = address(0);  

    }

}



/**

 * @title Standard ERC20 token

 * @dev Implementation of the basic standard token.

 */

contract StandardToken is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowed;



    uint256 internal _totalSupply;

    

    /**

     * @dev Total number of tokens in existence.

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev Get the balance of the specified address.

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

     * @dev Transfer token to a specified address.

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

     * @dev Transfer token for a specified address.

     * @param from The address to transfer from.

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0), "StandardToken: cannot transfer tokens to the zero address");



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Approve an address to spend another addresses' tokens.

     * @param owner The address that owns the tokens.

     * @param spender The address that will spend the tokens.

     * @param value The number of tokens that can be spent.

     */

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0), "StandardToken: cannot approve to the zero address");

        require(owner != address(0), "StandardToken: setter cannot be the zero address");



        _allowed[owner][spender] = value;

        emit Approval(owner, spender, value);

    }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

    event Pause();

    event Unpause();



    bool public paused = false;



    /**

    * @dev Modifier to make a function callable only when the contract is not paused.

    */

    modifier whenNotPaused() {

        require(!paused, "Pausable: only when the contract is not paused");

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(paused, "Pausable: only when the contract is paused");

        _;

    }



    /**

     * @dev Called by the owner to pause, triggers stopped state.

     */

    function pause() public onlyOwner whenNotPaused {

        paused = true;

        emit Pause();

    }



    /**

     * @dev Called by the owner to unpause, returns to normal state.

     */

    function unpause() public onlyOwner whenPaused {

        paused = false;

        emit Unpause();

    }

}



/**

 * @title PausableToken

 * @dev Rewrite ERC-20 specification that lets owner Pause all trading.

 */

contract PausableToken is StandardToken, Pausable {



    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

        return super.transferFrom(_from, _to, _value);

    }



    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {

        return super.approve(_spender, _value);

    }



    function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(_spender, _addedValue);

    }



    function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(_spender, _subtractedValue);

    }

}



/**

 * @title blackListToken

 * @dev This contract implements some blacklist operations.

 */

contract blackListToken is PausableToken {

    mapping(address=>bool) internal _isBlackList;



    event AddToBlackList(address indexed target);

    event RemoveFromBlackList(address indexed target);



    /**

     * @dev Return whether the specified address is on the blacklist.

     * @param account A specified address.

     */

    function isBlackList(address account) public view returns(bool) {

        return _isBlackList[account];

    }



    /**

     * @dev Add the specified address to the blacklist.

     * @param account A specified address.

     */

    function addToBlackList(address account) public onlyOwner {

        _isBlackList[account] = true;

        emit AddToBlackList(account);

    }



    /**

     * @dev Remove the specified address from the blacklist.

     * @param account A specified address.

     */

    function removeFromBlackList(address account) public onlyOwner {

        _isBlackList[account] = false;

        emit RemoveFromBlackList(account);

    }



    /**

     * @dev Rewrite the transfer function to check if the address is on the blacklist.

     */

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(!_isBlackList[msg.sender], "blackListToken: msg.sender is on the blacklist");

        require(!_isBlackList[_to], "blackListToken: the target address is on the blacklist");

        return super.transfer(_to, _value);

    }



    /**

     * @dev Rewrite the transferFrom function to check if the address is on the blacklist.

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(!_isBlackList[msg.sender], "blackListToken: msg.sender is on the blacklist");

        require(!_isBlackList[_from], "blackListToken: the source address is on the blacklist");

        require(!_isBlackList[_to], "blackListToken: the target address is on the blacklist");

        return super.transferFrom(_from, _to, _value);

    }   

}



/**

 * @title BurnableToken

 * @dev Implement the function of ERC20 token burning.

 */

contract BurnableToken is PausableToken, blackListToken {



    event Burn(address indexed burner, uint256 value);



    /**

     * @dev Burn a specific amount of tokens.

     * @param _value The amount of token to be burned.

     */

    function burn(uint256 _value) public returns (bool) {

        require(_value <= _balances[msg.sender], "BurnableToken: not enough token balance");

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        _balances[msg.sender] = _balances[msg.sender].sub(_value);

        _totalSupply = _totalSupply.sub(_value);

        emit Burn(msg.sender, _value);

        emit Transfer(msg.sender, address(0), _value);

        return true;

    }

}



/**

 * @title MintableToken

 * @dev Implement the function of ERC20 token minting.

 */

contract MintableToken is StandardToken, blackListToken {



    /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address to, uint256 value) public onlyOwner returns (bool) {

        require(to != address(0), "MintableToken: cannot mint to the zero address");

        require(!_isBlackList[to], "MintableToken: the target address is on the blacklist");

        _totalSupply = _totalSupply.add(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(address(0), to, value);

        return true;

    }

}



contract DUSDToken is BurnableToken, MintableToken {



    string public constant name = "Digital USD";

    string public constant symbol = "DUSD";

    uint8 public constant decimals = 18;



    bool public initialized = false;

    bool public destructible = false;



    /**

     * @dev Set '_owner' to a speicified address.

     * This owner just used for the 'kill' function.

     */

    constructor() public {

        destructible = true;

        _owner = 0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1;

    }



    /**

     * @dev Set the owner of contract and the initial total of token.

     *      Contract only can initialized once 

     */

    function initialize() public {

        require(!initialized, "DUSDToken: already initialized");

        _owner = 0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1;

        _totalSupply = 1e28;

        _balances[_owner] = _totalSupply;

        emit Transfer(address(0), _owner, _totalSupply);

        initialized = true;

    } 



    /**

     * @dev Owner can call this function to destroy this contract.

     */

    function kill() public onlyOwner {

        require(destructible, "DUSDToken: only DUSDToken contract can destroy");

        selfdestruct(msg.sender);

    }

}