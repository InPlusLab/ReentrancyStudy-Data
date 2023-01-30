/**

 *Submitted for verification at Etherscan.io on 2019-06-01

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



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address internal _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Revert if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "The caller must be owner");

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allow the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Cannot transfer control of the contract to the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

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

     * @param owner The address which owns the funds.

     * @param spender The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

     * @dev Transfer tokens to a specified address.

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

     * @param from The address which you want to send tokens from.

     * @param to The address which you want to transfer to.

     * @param value The amount of tokens to be transferred.

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

     * @dev Transfer tokens for a specified address.

     * @param from The address to transfer from.

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0), "Cannot transfer to the zero address");



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

        require(spender != address(0), "Cannot approve to the zero address");

        require(owner != address(0), "Setter cannot be the zero address");



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

        require(!paused, "Only when the contract is not paused");

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(paused, "Only when the contract is paused");

        _;

    }



    /**

     * @dev Called by the owner to pause, trigger stopped state.

     */

    function pause() public onlyOwner whenNotPaused {

        paused = true;

        emit Pause();

    }



    /**

     * @dev Called by the owner to unpause, return to normal state.

     */

    function unpause() public onlyOwner whenPaused {

        paused = false;

        emit Unpause();

    }

}



/**

 * @title PausableToken

 * @dev ERC20 modified with pausable transfers.

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



    function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(_spender, _addedValue);

    }



    function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(_spender, _subtractedValue);

    }

}

/**

 *  @title FreezableToken

 */

contract FreezableToken is PausableToken {

    mapping(address=>bool) internal _frozenAccount;



    event FrozenAccount(address indexed target, bool frozen);



    /**

     * @dev Return whether the specified address is frozen.

     * @param account A specified address.

     */

    function frozenAccount(address account) public view returns(bool){

        return _frozenAccount[account];

    }



    /**

     * @dev Check if the specified address is frozen. Require the specified address not to be frozen.

     * @param account A specified address.

     */

    function frozenCheck(address account) internal view {

        require(!frozenAccount(account), "Address has been frozen");

    }



    /**

     * @dev Modify the frozen status of the specified address.

     * @param account A specified address.

     * @param frozen Frozen status, true: freeze, false: unfreeze.

     */

    function freeze(address account, bool frozen) public onlyOwner {

  	    _frozenAccount[account] = frozen;

  	    emit FrozenAccount(account, frozen);

    }



    /**

     * @dev Rewrite the transfer function to check if the address participating is frozen.

     */

    function transfer(address _to, uint256 _value) public returns (bool) {

        frozenCheck(msg.sender);

        frozenCheck(_to);

        return super.transfer(_to, _value);

    }



    /**

     * @dev Rewrite the transferFrom function to check if the address participating is frozen.

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        frozenCheck(msg.sender);

        frozenCheck(_from);

        frozenCheck(_to);

        return super.transferFrom(_from, _to, _value);

    }   

}



contract AICCToken is FreezableToken {

    string public constant name = "AICloudChain"; // name of Token.

    string public constant symbol = "AICC"; // symbol of Token.

    uint8 public constant decimals = 18;

    uint256 private constant INIT_TOTALSUPPLY = 30000000;



    mapping (address => uint256) public releaseTime;

    mapping (address => uint256) public lockAmount;



    event LockToken(address indexed beneficiary, uint256 releaseTime, uint256 releaseAmount);

    event ReleaseToken(address indexed user, uint256 releaseAmount);



    /**

     * @dev Constructor.

     */

    constructor() public {

        _totalSupply = INIT_TOTALSUPPLY * 10 ** uint256(decimals);

        _owner = 0x06C7B9Ce4f2Fee058DE2A79F75DEC55092C229Aa;

        _balances[_owner] = _totalSupply;

        emit Transfer(address(0), _owner, _totalSupply);

    }



    /**

     * @dev Send the tokens to the beneficiary and lock it, and the timestamp and quantity of lock can be set by owner.

     * @param _beneficiary A specified address.

     * @param _releaseTime The timestamp of release token.

     * @param _releaseAmount The amount of release token.

     */

    function lockToken(address _beneficiary, uint256 _releaseTime, uint256 _releaseAmount) public onlyOwner returns(bool) {

        require(lockAmount[_beneficiary] == 0, "The address has been locked");

        require(_beneficiary != address(0), "The target address cannot be the zero address");

        require(_releaseAmount > 0, "The amount must be greater than 0");

        require(_releaseTime > now, "The time must be greater than current time");

        frozenCheck(_beneficiary);

        lockAmount[_beneficiary] = _releaseAmount;

        releaseTime[_beneficiary] = _releaseTime;

        _balances[_owner] = _balances[_owner].sub(_releaseAmount); // Remove this part of the locked tokens from the owner.

        emit LockToken(_beneficiary, _releaseTime, _releaseAmount);

        return true;

    }



    /**

     * @dev Implement the basic functions of releasing tokens.

     */

    function releaseToken(address _owner) public whenNotPaused returns(bool) {

        frozenCheck(_owner);

        uint256 amount = releasableAmount(_owner);

        require(amount > 0, "No releasable tokens");

        _balances[_owner] = _balances[_owner].add(amount);

        lockAmount[_owner] = 0;

        emit ReleaseToken(_owner, amount);

        return true;

    }



    /**

     * @dev Get the amount of current timestamp that can be released.

     * @param addr A specified address.

     */

    function releasableAmount(address addr) public view returns(uint256) {

        if(lockAmount[addr] != 0 && now > releaseTime[addr]) {

            return lockAmount[addr];

        } else {

            return 0;

        }

     }

    

    /**

     * @dev Rewrite the transfer function to automatically unlock the locked tokens.

     */

    function transfer(address to, uint256 value) public returns (bool) {

        if(releasableAmount(msg.sender) > 0) {

            releaseToken(msg.sender);

        }

        return super.transfer(to, value);

    }



    /**

     * @dev Rewrite the transferFrom function to automatically unlock the locked tokens.

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        if(releasableAmount(from) > 0) {

            releaseToken(from);

        }

        return super.transferFrom(from, to, value);

    }



    /**

     * @dev Transfer tokens to multiple addresses.

     */

    function batchTransfer(address[] memory addressList, uint256[] memory amountList) public onlyOwner returns (bool) {

        uint256 length = addressList.length;

        require(addressList.length == amountList.length, "Inconsistent array length");

        require(length > 0 && length <= 150, "Invalid number of transfer objects");

        uint256 amount;

        for (uint256 i = 0; i < length; i++) {

            frozenCheck(addressList[i]);

            require(amountList[i] > 0, "The transfer amount cannot be 0");

            require(addressList[i] != address(0), "Cannot transfer to the zero address");

            amount = amount.add(amountList[i]);

            _balances[addressList[i]] = _balances[addressList[i]].add(amountList[i]);

            emit Transfer(msg.sender, addressList[i], amountList[i]);

        }

        require(_balances[msg.sender] >= amount, "Not enough tokens to transfer");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        return true;

    }

}