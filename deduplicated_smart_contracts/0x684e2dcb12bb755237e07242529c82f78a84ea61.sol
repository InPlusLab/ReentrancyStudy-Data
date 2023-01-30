pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
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
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}

contract WellToken is StandardToken, BurnableToken, Ownable {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 amount);
    event Release();
    event AddressLocked(address indexed _address, uint256 _time);
    event AddressLockedByKYC(address indexed _address);
    event KYCVerified(address indexed _address);
    event TokensRevertedByKYC(address indexed _address, uint256 _amount);
    event SetTechAccount(address indexed _address);

    string public constant name = "WELL Token";

    string public constant symbol = "WELL";

    string public constant standard = "ERC20";

    uint256 public constant decimals = 18;

    uint256 public constant TOKENS_MAXIMUM_SUPPLY = 1500000000 * (10 ** decimals);

    bool public released = false;

    address public tokensWallet;
    address public mintingOracle;
    address public techAccount;

    mapping(address => uint) public lockedAddresses;
    mapping(address => bool) public verifiedKYCAddresses;

    modifier isReleased() {
        require(released || msg.sender == tokensWallet || msg.sender == owner || msg.sender == techAccount);
        require(lockedAddresses[msg.sender] <= now);
        require(verifiedKYCAddresses[msg.sender]);
        _;
    }

    modifier hasAddressLockupPermission() {
        require(msg.sender == owner || msg.sender == techAccount);
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == mintingOracle);
        _;
    }

    constructor() public {
        owner = 0x6c2386fFf587539484c9d65628df7301A4a7Fc10;
        mintingOracle = owner;
        tokensWallet = owner;
        verifiedKYCAddresses[owner] = true;

        techAccount = 0x41D621De050A551F5f0eBb83D1332C75339B61E4;
        verifiedKYCAddresses[techAccount] = true;
        emit SetTechAccount(techAccount);

        balances[tokensWallet] = totalSupply_;
        emit Transfer(0x0, tokensWallet, totalSupply_);
    }

    function lockAddress(address _address, uint256 _time) public hasAddressLockupPermission returns (bool) {
        require(_address != owner && _address != tokensWallet && _address != techAccount);
        require(balances[_address] == 0 && lockedAddresses[_address] == 0 && _time > now);
        lockedAddresses[_address] = _time;

        emit AddressLocked(_address, _time);
        return true;
    }

    function lockAddressByKYC(address _address) public hasAddressLockupPermission returns (bool) {
        require(released);
        require(balances[_address] == 0 && verifiedKYCAddresses[_address]);

        verifiedKYCAddresses[_address] = false;
        emit AddressLockedByKYC(_address);

        return true;
    }

    function verifyKYC(address _address) public hasAddressLockupPermission returns (bool) {
        verifiedKYCAddresses[_address] = true;
        emit KYCVerified(_address);

        return true;
    }

    function revertTokensByKYC(address _address) public hasAddressLockupPermission returns (bool) {
        require(!verifiedKYCAddresses[_address] && balances[_address] > 0);

        uint256 amount = balances[_address];
        balances[tokensWallet] = balances[tokensWallet].add(amount);
        balances[_address] = 0;

        emit Transfer(_address, tokensWallet, amount);
        emit TokensRevertedByKYC(_address, amount);

        return true;
    }

    function release() public onlyOwner returns (bool) {
        require(!released);
        released = true;
        emit Release();
        return true;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint256 _value) public isReleased returns (bool) {
        if (released) {
            verifiedKYCAddresses[_to] = true;
        }

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public isReleased returns (bool) {
        if (released) {
            verifiedKYCAddresses[_to] = true;
        }

        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public isReleased returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public isReleased returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public isReleased returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != owner);
        require(lockedAddresses[newOwner] < now);
        address oldOwner = owner;
        super.transferOwnership(newOwner);

        if (oldOwner != tokensWallet) {
            allowed[tokensWallet][oldOwner] = 0;
            emit Approval(tokensWallet, oldOwner, 0);
        }

        if (owner != tokensWallet) {
            allowed[tokensWallet][owner] = balances[tokensWallet];
            emit Approval(tokensWallet, owner, balances[tokensWallet]);
        }

        verifiedKYCAddresses[newOwner] = true;
        emit KYCVerified(newOwner);
    }

    function changeTechAccountAddress(address _address) public onlyOwner {
        require(_address != address(0) && _address != techAccount);
        require(lockedAddresses[_address] < now);

        techAccount = _address;
        emit SetTechAccount(techAccount);

        verifiedKYCAddresses[_address] = true;
        emit KYCVerified(_address);
    }

    function mint(
        address _to,
        uint256 _amount
    )
    public
    hasMintPermission
    returns (bool)
    {
        totalSupply_ = totalSupply_.add(_amount);
        require(totalSupply_ > 0);
        require(totalSupply_ <= TOKENS_MAXIMUM_SUPPLY);

        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }

    function setMintingOracle(address _address) public hasMintPermission {
        require(_address != address(0) && _address != mintingOracle);

        mintingOracle = _address;
    }

}