/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity 0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract.
    */
    constructor(address _owner) public {
        owner = _owner == address(0) ? msg.sender : _owner;
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
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
    * @dev confirm ownership by a new owner
    */
    function confirmOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

/**
 * @title IERC20Token - ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value)  public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)  public returns (bool success);
    function approve(address _spender, uint256 _value)  public returns (bool success);
    function allowance(address _owner, address _spender)  public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
    /**
    * @dev constructor
    */
    constructor() public {
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20Token - ERC20 base implementation
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Token is IERC20Token, SafeMath {
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}

/**
 * @title ITokenEventListener
 * @dev Interface which should be implemented by token listener
 */
interface ITokenEventListener {
    /**
     * @dev Function is called after token transfer/transferFrom
     * @param _from Sender address
     * @param _to Receiver address
     * @param _value Amount of tokens
     */
    function onTokenTransfer(address _from, address _to, uint256 _value) external;
}

/**
 * @title ManagedToken
 * @dev ERC20 compatible token with issue and destroy facilities
 * @dev All transfers can be monitored by token event listener
 */
contract ManagedToken is ERC20Token, Ownable {
    uint256 public totalIssue;                                                  //Total token issue
    bool public allowTransfers = false;                                         //Default not transfer
    bool public issuanceFinished = false;                                       //Finished issuance

    ITokenEventListener public eventListener;                                   //Listen events

    event AllowTransfersChanged(bool _newState);                                //Event:
    event Issue(address indexed _to, uint256 _value);                           //Event: Issue
    event Destroy(address indexed _from, uint256 _value);                       //Event:
    event IssuanceFinished(bool _issuanceFinished);                             //Event: Finished issuance

    //Modifier: Allow all transfer if not any condition
    modifier transfersAllowed() {
        require(allowTransfers);
        _;
    }

    //Modifier: Allow continue to issue
    modifier canIssue() {
        require(!issuanceFinished);
        _;
    }

    /**
     * @dev ManagedToken constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owner Owner of contract(address can be 0x0)
     */
    constructor(address _listener, address _owner) public Ownable(_owner) {
        if(_listener != address(0)) {
            eventListener = ITokenEventListener(_listener);
        }
    }

    /**
     * @dev Enable/disable token transfers. Can be called only by owners
     * @param _allowTransfers True - allow False - disable
     */
    function setAllowTransfers(bool _allowTransfers) external onlyOwner {
        allowTransfers = _allowTransfers;

        //Call event
        emit AllowTransfersChanged(_allowTransfers);
    }

    /**
     * @dev Set/remove token event listener
     * @param _listener Listener address (Contract must implement ITokenEventListener interface)
     */
    function setListener(address _listener) public onlyOwner {
        if(_listener != address(0)) {
            eventListener = ITokenEventListener(_listener);
        } else {
            delete eventListener;
        }
    }

    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool) {
        bool success = super.transfer(_to, _value);
        /* if(hasListener() && success) {
            eventListener.onTokenTransfer(msg.sender, _to, _value);
        } */
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool) {
        bool success = super.transferFrom(_from, _to, _value);

        //If has Listenser and transfer success
        /* if(hasListener() && success) {
            //Call event listener
            eventListener.onTokenTransfer(_from, _to, _value);
        } */
        return success;
    }

    function hasListener() internal view returns(bool) {
        if(eventListener == address(0)) {
            return false;
        }
        return true;
    }

    /**
     * @dev Issue tokens to specified wallet
     * @param _to Wallet address
     * @param _value Amount of tokens
     */
    function issue(address _to, uint256 _value) external onlyOwner canIssue {
        totalIssue = safeAdd(totalIssue, _value);
        require(totalSupply >= totalIssue, "Total issue is not greater total of supply");
        balances[_to] = safeAdd(balances[_to], _value);
        //Call event
        emit Issue(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

    /**
     * @dev Destroy tokens on specified address (Called byallowance owner or token holder)
     * @dev Fund contract address must be in the list of owners to burn token during refund
     * @param _from Wallet address
     * @param _value Amount of tokens to destroy
     */
    function destroy(address _from, uint256 _value) external onlyOwner {
        require(balances[_from] >= _value, "Value of destroy is not greater balance of address wallet");

        totalIssue = safeSub(totalIssue, _value);
        balances[_from] = safeSub(balances[_from], _value);

        emit Transfer(_from, address(0), _value);
        //Call event
        emit Destroy(_from, _value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From OpenZeppelin StandardToken.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From OpenZeppelin StandardToken.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Finish token issuance
     * @return True if success
     */
    function setAllowIssuance(bool _issuanceFinished) public onlyOwner returns (bool) {
        issuanceFinished = _issuanceFinished;
        //Call event
        emit IssuanceFinished(_issuanceFinished);
        return true;
    }
}

/**
 * @title LockTransfer
 * @dev Limit transfers for certain period of time
 */
contract LockTransfer is ManagedToken {
    bool public isLimitTimeTransfer = false;                        //Enable/Disable limit transfer for certain period of time
    uint256 public limitTimeTransferEndDate;                        //End of time for limit transfer

    event TransfersEnabled();

    /**
     * @dev LockTransfer constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owner Owner
     */
    constructor(
        address _listener,
        address _owner
    ) public ManagedToken(_listener, _owner)
    {
    }   

    /**
     * @dev Check if transfer is available at now
     */
    modifier checkLimitTimeTransfer()  {
        if(isLimitTimeTransfer){
            if(now > limitTimeTransferEndDate){
                isLimitTimeTransfer = false;
            }else{
                require(false, "Transfer is locking.");
            }
        }
        _;
    }     

    /**
     * @dev Enable/Disable transfer limit manually. Can be called only by owner
     */
    function setAllowLimitTimeTransfer(bool _isLimitTimeTransfer) public onlyOwner {
        isLimitTimeTransfer = _isLimitTimeTransfer;
    }

    function setLimitTimeTransferEndDate(uint256 _limitTimeTransferEndDateSecond) public onlyOwner {
        isLimitTimeTransfer = true;
        limitTimeTransferEndDate = _limitTimeTransferEndDateSecond + now;
    }
}

/**
 * @title TransferLimitedToken
 * @dev Token with ability to limit transfers within wallets included in limitedWallets list for certain period of time
 */
contract TransferLimitedToken is LockTransfer {
    uint256 public constant LIMIT_TRANSFERS_PERIOD = 365 days;

    mapping(address => bool) public limitedWallets;
    address public limitedWalletsManager;

    bool public isLimitEnabled = false;                             //Enable or Disable limit with limited Wallets
    bool public isLimitWithTime = false;                            //Enable or Disable limited wallets with time
    uint256 public limitEndDate;                                    //End of time for limited wallets

    event TransfersEnabled();

    /**
     * @dev TransferLimitedToken constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owner Owners list
     * @param _limitedWalletsManager Address used to add/del wallets from limitedWallets
     */
    constructor(
        address _listener,
        address _owner,
        address _limitedWalletsManager
    ) public LockTransfer(_listener, _owner)
    {
        limitedWalletsManager = _limitedWalletsManager;
    }   

    modifier onlyManager() {
        require(msg.sender == limitedWalletsManager || msg.sender == owner);
        _;
    }

    /** uint256 public constant LIMIT_TRANSFERS_PERIOD = 365 days;
     * @dev Check if transfer between addresses is available
     * @param _from From address
     * @param _to To address
     */
    modifier canTransfer(address _from, address _to)  {
        if(isLimitEnabled){
            if(limitedWallets[_from] || limitedWallets[_to]){
                if(isLimitWithTime){
                    if(now > limitEndDate){
                        isLimitEnabled = false;                        
                    }else{
                        require(false, "Wallet is limited in period time.");
                    }
                }else{
                    require(false, "Wallet is limited.");
                }
            }
        }
        _;
    }     

    /**
      Begin: Set params by manager
      _limitEndDateSecond is total of seconds for limit
    */
    function setLimitEndDate(uint256 _limitEndDateSecond) external onlyManager {
        isLimitEnabled = true;
        limitEndDate = now + _limitEndDateSecond;
    }

    function setLimitInAYear() external onlyManager {
        isLimitEnabled = true;
        limitEndDate = now + LIMIT_TRANSFERS_PERIOD;
    }

    function changeLimitedWalletsManager(address _limitedWalletsManager) external onlyOwner{
        limitedWalletsManager = _limitedWalletsManager;
    }
     /**
      End: Set params by manager
    */

    /**
     * @dev Add address to limitedWallets
     * @dev Can be called only by manager
     */
    function addLimitedWalletAddress(address _wallet) public onlyManager {
        limitedWallets[_wallet] = true;
    }

    /**
     * @dev Del address from limitedWallets
     * @dev Can be called only by manager
     */
    function delLimitedWalletAddress(address _wallet) public onlyManager {
        limitedWallets[_wallet] = false;
    }

    /**
     * @dev Enable/Disable transfer limit manually. Can be called only by manager
     */
    function setAllowLimitedWallet(bool _isLimitEnabled) public onlyManager {
        isLimitEnabled = _isLimitEnabled;
    }

    /**
     * @dev Set time period for transfer limit manually. Can be called only by manager
     */
    function setAllowLimitedWalletWithTime(bool _isLimitWithTime) public onlyManager {
        isLimitWithTime = _isLimitWithTime;
    }

    function transfer(address _to, uint256 _value) public canTransfer(msg.sender, _to) checkLimitTimeTransfer  returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from, _to) checkLimitTimeTransfer returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public canTransfer(msg.sender, _spender) checkLimitTimeTransfer returns (bool) {
        return super.approve(_spender,_value);
    }    
}


/**
 * Char Token Contract
 * @title Char
 */
contract Char is TransferLimitedToken {
    bool public isLock = false;                                                 //Lock system
    uint256 public lockTotal;                                                   //Total token is lock
    uint256 public unlockTotal;                                                 //Total token is unlock
    uint256 public lockEndTime;                                                 //Time end of lock

    uint256 public LOCK_WITH_FOUR_WEEKS = 28 days;
    uint256 public LOCK_WITH_EIGHT_WEEKS = 56 days;
    uint256 public LOCK_WITH_TWELVE_WEEKS = 84 days;
    uint256 public LOCK_WITH_ONE_YEAR = 365 days;

    /**
     * @dev Char constructor
     */
    constructor() public TransferLimitedToken(msg.sender, msg.sender, msg.sender) {
        name = "Char";
        symbol = "Char";
        decimals = 18;
        totalIssue = 0;
        totalSupply = 5000000000 ether;                                         //The maximum number of tokens is unchanged and totals will decrease after issue
        lockTotal = 0 ether;                                                    //Total tokens to lock
        unlockTotal = 5000000000 ether;                                         //Total tokens to lock
    }

    function issue(address _to, uint256 _value) external onlyOwner canIssue {
        totalIssue = safeAdd(totalIssue, _value);
        require(totalSupply >= totalIssue, "Total issue is not greater total of supply");

        if(isLock){
            if(now > lockEndTime){
                isLock = false;
            }else{
                require(totalIssue <= unlockTotal, "totalIssue is required less than value of unlockTotal.");            
            }
        }
        
        balances[_to] = safeAdd(balances[_to], _value);
        //Call event
        emit Issue(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

    function setLock(bool _isLock) external onlyOwner {
        isLock = _isLock;
    }

    /**
        Set total of token to lock for certain period of tim
     */
    function setLockTotal(uint256 _lockTotal) external onlyOwner {
        lockTotal = _lockTotal;
        unlockTotal = safeSub(totalSupply, lockTotal);
    }

    /**
        Set time to end lock token
     */
    function setLockEndTime(uint256 _lockEndTimeSecond) external onlyOwner {
        isLock = true;
        lockEndTime = _lockEndTimeSecond + now;
    }

    /**
        Set lock a part of token in four weeks 
    */
    function setLockFourWeeks() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_FOUR_WEEKS + now;
    }

    /**
        Set lock a part of token in eight weeks
     */
    function setLockEightWeeks() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_EIGHT_WEEKS + now;
    }

    /**
        Set lock a part of token in twelve weeks
     */
    function setLockTwelveWeeks() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_TWELVE_WEEKS + now;
    }

    /**
        Set lock a part of token in a year
     */
    function setLockAYear() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_ONE_YEAR + now;
    }

}