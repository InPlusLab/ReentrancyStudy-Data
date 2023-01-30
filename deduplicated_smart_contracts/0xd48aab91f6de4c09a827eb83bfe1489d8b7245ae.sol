pragma solidity >=0.4.21 <0.6.0;

import "./TokenStorage.sol";
import "./SafeMath.sol";
import "./AddressUtils.sol";
import "./ERC20.sol";
import './Ownable.sol';

/**
* @title Token_V0
* @notice A basic ERC20 token with modular data storage
*/
contract Token_V0 is ERC20, Ownable{
    using SafeMath for uint256;

    string public constant name = 'RoboAi Coin R2R';
    string public constant symbol = 'R2R';
    uint8 public constant decimals = 18;

    event Lock(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    /**
     * @dev Records data of all the tokens unlocked
     */
    event Unlock(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );

    string internal constant ALREADY_LOCKED = "Tokens already locked";
    string internal constant NOT_LOCKED = "No tokens locked";
    string internal constant AMOUNT_ZERO = "Amount can not be 0";

    /** Events */
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    TokenStorage dataStore;
    address dataStoreAddress;

    constructor(address storeAddress) public {
        dataStore = TokenStorage(storeAddress);
        dataStoreAddress = storeAddress;
    }

    /** Modifiers **/

    /** Functions **/

    function totalSupply() public view returns(uint256) {
        return(dataStore.getTotalSupply());
    }

    function balanceOf(address account) public view returns (uint256) {
        return dataStore.getBalance(account);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return dataStore.getAllowance(owner, spender);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(dataStore.getAllowance(sender, msg.sender) >= amount, "AllowanceError: The spender does not hve the required allowance to spend token holder's tokens");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, dataStore.getAllowance(sender, msg.sender).sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(dataStore.getBalance(sender) >= amount, "Insufficient Funds");

        dataStore.subBalance(sender, amount);
        dataStore.addBalance(recipient, amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        dataStore.setAllowance(owner, spender, value);
        emit Approval(owner, spender, value);
    }

    // Mintable Functionality
    function mintToken(address recipient, uint256 value) public onlyOwner{
        dataStore.addTotalSupply(value);
        dataStore.addBalance(recipient, value);
        emit Mint(recipient, value);
    }

    function burnToken(uint256 value) public{
        address sender = msg.sender;
        dataStore.subBalance(sender, value);
        dataStore.subTotalSupply(value);
        emit Burn(msg.sender, value);
    }


    // Lockable Functionality according to EIP1132
    /**
    * @dev Locks a specified amount of tokens against an address,
    *      for a specified reason and time
    * @param _reason The reason to lock tokens
    * @param _amount Number of tokens to be locked
    * @param _time Lock time in seconds
    */
    function lock(bytes32 _reason, uint256 _amount, uint256 _time)
    public
    returns (bool)
    {
        uint256 validUntil = block.timestamp.add(_time);

        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(msg.sender, _reason);

        require(tokensAlreadyLocked == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        dataStore.addLockReason(msg.sender, _reason);

        _transfer(msg.sender, dataStore, _amount);

        dataStore.addLockedToken(msg.sender, _reason, _amount, validUntil);

        emit Lock(msg.sender, _reason, _amount, validUntil);
        return true;
    }


    /**
     * @dev Transfers and Locks a specified amount of tokens,
     *      for a specified reason and time
     * @param _to adress to which tokens are to be transfered
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be transfered and locked
     * @param _time Lock time in seconds
     */
    function transferWithLock(address _to, bytes32 _reason, uint256 _amount, uint256 _time)
    public
    returns (bool)
    {
        uint256 validUntil = block.timestamp.add(_time);

        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(_to, _reason);

        require(tokensAlreadyLocked == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);
        require(_to != address(0), "ERC20: transfer to the zero address");

        dataStore.addLockReason(_to, _reason);

        _transfer(msg.sender, dataStore, _amount);

        dataStore.addLockedToken(_to, _reason, _amount, validUntil);

        emit Lock(_to, _reason, _amount, validUntil);
        return true;
    }


    /**
    * @dev Returns tokens locked for a specified address for a
    *      specified reason
    *
    * @param _of The address whose tokens are locked
    * @param _reason The reason to query the lock tokens for
    */
    function tokensLocked(address _of, bytes32 _reason)
    public
    view
    returns (uint256 amount)
    {
        return dataStore.getLockedTokenAmount(_of, _reason);
    }


    /**
    * @dev Returns tokens locked for a specified address for a
    *      specified reason at a specific time
    *
    * @param _of The address whose tokens are locked
    * @param _reason The reason to query the lock tokens for
    * @param _time The timestamp to query the lock tokens for
    */
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
    public
    view
    returns (uint256 amount)
    {
        amount = dataStore.getLockedTokensAtTime(_of, _reason, _time);
    }


    /**
 * @dev Returns total tokens held by an address (locked + transferable)
 * @param _of The address to query the total balance of
 */
    function totalBalanceOf(address _of)
    public
    view
    returns (uint256 amount)
    {
        amount = balanceOf(_of);
        amount = amount + dataStore.getTotalLockedTokens(_of);
    }


    /**
    * @dev Extends lock for a specified reason and time
    * @param _reason The reason to lock tokens
    * @param _time Lock extension time in seconds
    */
    function extendLock(bytes32 _reason, uint256 _time)
    public
    returns (bool)
    {
        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(msg.sender, _reason);
        require(tokensAlreadyLocked > 0, NOT_LOCKED);

        (uint256 amount, uint256 validity) = dataStore.extendTokenLock(msg.sender, _reason, _time);

        emit Lock(msg.sender, _reason, amount, validity);
        return true;
    }


    /**
  * @dev Increase number of tokens locked for a specified reason
  * @param _reason The reason to lock tokens
  * @param _amount Number of tokens to be increased
  */
    function increaseLockAmount(bytes32 _reason, uint256 _amount)
    public
    returns (bool)
    {
        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(msg.sender, _reason);
        require(tokensAlreadyLocked > 0, NOT_LOCKED);
        _transfer(msg.sender, dataStore, _amount);
        (uint256 amount, uint256 validity) = dataStore.increaseLockAmount(msg.sender, _reason, _amount);

        emit Lock(msg.sender, _reason, amount, validity);
        return true;
    }


    /**
    * @dev Returns unlockable tokens for a specified address for a specified reason
    * @param _of The address to query the the unlockable token count of
    * @param _reason The reason to query the unlockable tokens for
    */
    function tokensUnlockable(address _of, bytes32 _reason)
    public
    view
    returns (uint256 amount)
    {
        return dataStore.getUnlockable(_of, _reason);
    }


    /**
    * @dev Unlocks the unlockable tokens of a specified address
    * @param _of Address of user, claiming back unlockable tokens
    */
    function unlock(address _of)
    public
    returns (uint256 unlockableTokens)
    {
        uint256 lockedTokens;
        uint256 numLockReasons = dataStore.getNumberOfLockReasons(_of);
        for (uint256 i = 0; i < numLockReasons; i++) {
            bytes32 reason = dataStore.getLockReason(_of, i);
            lockedTokens = tokensUnlockable(_of, reason);
            if (lockedTokens > 0) {
                unlockableTokens += lockedTokens;
                dataStore.setClaimed(_of, reason);
                emit Unlock(_of, reason, lockedTokens);
            }
        }

        if (unlockableTokens > 0)
            _transfer(dataStore, _of, unlockableTokens);
    }


    /**
    * @dev Gets the unlockable tokens of a specified address
    * @param _of The address to query the the unlockable token count of
    */
    function getUnlockableTokens(address _of)
    public
    view
    returns (uint256 unlockableTokens)
    {
        uint256 numLockReasons = dataStore.getNumberOfLockReasons(_of);
        for (uint256 i = 0; i < numLockReasons; i++) {
            bytes32 reason = dataStore.getLockReason(_of, i);
            unlockableTokens = unlockableTokens + tokensUnlockable(_of, reason);
        }
    }
}