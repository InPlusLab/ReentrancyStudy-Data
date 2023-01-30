/**
MFPH
Version 1.0 - 6 Sept 2019
All rights reserved.
*/

pragma solidity ^0.5.10;

// Importing the base tools for secure ERC20 construction
// Open Zeppelin is a suite of audited smart contracts that are commonly used
import './ERC20.sol';
import './SafeMath.sol';

// Importing adjacent solidity files referenced in this contract
import './ownable.sol';
import './blacklistable.sol';
import "./pausable.sol";


/**
 * @title MFPH
 * @dev ERC20 Stablecoin Token honored in value to be 1 PH
 */
contract MFPH_v1 is Ownable, ERC20, Pausable, Blacklistable {
    using SafeMath for uint256;
// This prevents some overflow math errors for numbers with too many digits

//  Listing the necessary variables and their types below
    string public name;
    string public symbol;
    uint8 public decimals;
    string public currency;
    address public MFMinter;
    bool internal initialized;

// Mappings are hashtables in Solidity
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MFMinterChanged(address indexed newMFMinter);

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _currency,
        uint8 _decimals,
        address _MFMinter,
        address _pauser,
        address _blacklister,
        address _owner
    ) public {
        require(!initialized);
        require(_MFMinter != address(0));
        require(_pauser != address(0));
        require(_blacklister != address(0));
        require(_owner != address(0));
// These make sure that there is a valid nonzero address set for each of these parameters

        name = _name;
        symbol = _symbol;
        currency = _currency;
        decimals = _decimals;
        MFMinter = _MFMinter;
        pauser = _pauser;
        blacklister = _blacklister;
        // this is solidity convention to initialize variables
        setOwner(_owner);
        initialized = true;
    }

    /**
     * @dev Throws exception if called by any account other than a minter
    */
    modifier onlyMinters() {
        require(minters[msg.sender] == true);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint. Must be less than or equal to the minterAllowance of the caller.
     * @return A boolean that indicates if the operation was successful.
    */
    //  Make sure only the individuals with the permissions can call the minting function
    function mint(address _to, uint256 _amount) whenNotPaused onlyMinters notBlacklisted(msg.sender) notBlacklisted(_to) public returns (bool) {
        require(_to != address(0));
        require(_amount > 0);

        uint256 mintingAllowedAmount = minterAllowed[msg.sender];
        require(_amount <= mintingAllowedAmount);

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(address(0x0), _to, _amount);
        return true;
    }

    /**
     * @dev Throws if called by any account other than the MFMinter
    */
    modifier onlyMFMinter() {
        require(msg.sender == MFMinter);
        _;
    }

    /**
     * @dev Get minter allowance for an account
     * @param minter The address of the minter
    */
    function minterAllowance(address minter) public view returns (uint256) {
        return minterAllowed[minter];
    }

    /**
     * @dev Checks if account is a minter
     * @param account The address to check
    */
    function isMinter(address account) public view returns (bool) {
        return minters[account];
    }

    /**
     * @dev Get allowed amount for an account
     * @param owner address The account owner
     * @param spender address The account spender
    */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    /**
     * @dev Get totalSupply of token
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev Get token balance of an account
     * @param account address The account
    */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /**
     * @dev Adds blacklisted check to approve
     * @return True if the operation was successful.
    */
    function approve(address _spender, uint256 _value) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_spender) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     * @return bool success
    */
    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused notBlacklisted(_to) notBlacklisted(msg.sender) notBlacklisted(_from) public returns (bool) {
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
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     * These two functions allow the token to be transacted from one address to another
     * @return bool success
    */
    function transfer(address _to, uint256 _value) whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_to) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Function to add/update a new minter
     * @param minter The address of the minter
     * This should be used carefully to only have a finite set of individuals who can create tokens.
     * @param minterAllowedAmount The minting amount allowed for the minter
     * @return True if the operation was successful.
    */
    function configureMinter(address minter, uint256 minterAllowedAmount) whenNotPaused onlyMFMinter public returns (bool) {
        minters[minter] = true;
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    /**
     * @dev Function to remove a minter
     * @param minter The address of the minter to remove
     * @return True if the operation was successful.
    */
    function removeMinter(address minter) onlyMFMinter public returns (bool) {
        minters[minter] = false;
        minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    /**
     * @dev allows a minter to burn some of its own tokens
     * Validates that caller is a minter and that sender is not blacklisted
     * amount is less than or equal to the minter's account balance
     * @param _amount uint256 the amount of tokens to be burned
    */
    function burn(uint256 _amount) whenNotPaused onlyMinters notBlacklisted(msg.sender) public {
        uint256 balance = balances[msg.sender];
        require(_amount > 0);
        require(balance >= _amount);
//  This burn should be called when individuals want to cash out the ERC20 token for real dollars
//  Thus, we can retire the supply after the correct value of money or real services is provided
        totalSupply_ = totalSupply_.sub(_amount);
        balances[msg.sender] = balance.sub(_amount);
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

// In case anything goes wrong, we can update which address may be the MFMinter
    function updateMFMinter(address _newMFMinter) onlyOwner public {
        require(_newMFMinter != address(0));
        MFMinter = _newMFMinter;
        emit MFMinterChanged(MFMinter);
    }
}
