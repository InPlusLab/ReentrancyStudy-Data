/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.2;

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

pragma solidity ^0.5.2;

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

pragma solidity ^0.5.2;

contract Ownable {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.2;

contract DJCoin is Ownable {

    using SafeMath for uint256;

    event LogBurn(uint256 indexed epoch, uint256 decayrate, uint256 totalSupply);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    string public constant name = "DJ Coin";
    string public constant symbol = "DJM";
    uint256 public constant decimals = 4;

    uint256 private constant DECIMALS = 4;
    uint256 private constant MAX_UINT256 = ~uint256(0); //(2^256) - 1
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 210000000 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0); //(2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;
    mapping (address => mapping (address => uint256)) private _allowedFragments;
   
    
    uint256 public lastMintedtime;
    uint256 public totalParticipants = 0;
    uint256 public tokensPerBlock = 1*10**DECIMALS;
    address public tokencontractAddress = address(this);
    
    constructor() public {
        _owner = msg.sender;
        
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_owner] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        emit Transfer(address(0x0), _owner, _totalSupply);
       
        lastMintedtime = now;
    }


    function burn(uint256 epoch, uint256 decayrate) external onlyOwner returns (uint256)
    {
        uint256 _remainrate = 10000; //0.25%->decayrate=25
        _remainrate = _remainrate.sub(decayrate);


        _totalSupply = _totalSupply.mul(_remainrate);
        _totalSupply = _totalSupply.sub(_totalSupply.mod(10000));
        _totalSupply = _totalSupply.div(10000);

        
        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        emit LogBurn(epoch, decayrate, _totalSupply);
        return _totalSupply;
    }

    

    function totalSupply() public view returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256)
    {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function transfer(address to, uint256 value) public  validRecipient(to) returns (bool)
    {
        uint256 decayvalue = value.mul(25); //2.5%->25/1000
        decayvalue = decayvalue.sub(decayvalue.mod(1000));
        decayvalue = decayvalue.div(1000);
        
        uint256 gonValue = value.mul(_gonsPerFragment);
        uint256 leftgonValue = value.sub(decayvalue);
        leftgonValue = leftgonValue.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(leftgonValue);
        
        _totalSupply = _totalSupply.sub(decayvalue);
        
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender) public view returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function transferFrom(address from, address to, uint256 value) public validRecipient(to) returns (bool)
    {
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);
        
        uint256 decayvalue = value.mul(25); //2.5%->25/1000
        decayvalue = decayvalue.sub(decayvalue.mod(1000));
        decayvalue = decayvalue.div(1000);
        
        uint256 gonValue = value.mul(_gonsPerFragment);
        uint256 leftgonValue = value.sub(decayvalue);
        leftgonValue = leftgonValue.mul(_gonsPerFragment);
        
        _totalSupply = _totalSupply.sub(decayvalue);
        
        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(leftgonValue);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
    
    function changetokensPerBlock(uint256 _newtokensPerBlock) external returns (bool) {
        tokensPerBlock = _newtokensPerBlock*10**DECIMALS;
        return true;
    }
    
}