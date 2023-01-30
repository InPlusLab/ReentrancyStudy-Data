/**
 *Submitted for verification at Etherscan.io on 2019-10-25
*/

/*
|| THE LEXDAO REGISTRY (TLDR) || version 0.1

DEAR MSG.SENDER(S):

/ TLDR is a project in beta.
// Please audit and use at your own risk.
/// Entry into TLDR shall not create an attorney/client relationship.
//// Likewise, TLDR should not be construed as legal advice or replacement for professional counsel.

///// STEAL THIS C0D3SL4W 

|| lexDAO || 
~presented by Open, ESQ LLC_DAO~
< https://mainnet.aragon.org/#/openesquire/ >
*/

pragma solidity 0.5.9;

/***************
OPENZEPPELIN REFERENCE CONTRACTS - SafeMath, ScribeRole, ERC-20 transactional scripts
***************/
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ScribeRole is Context {
    using Roles for Roles.Role;

    event ScribeAdded(address indexed account);
    event ScribeRemoved(address indexed account);

    Roles.Role private _Scribes;

    constructor () internal {
        _addScribe(_msgSender());
    }

    modifier onlyScribe() {
        require(isScribe(_msgSender()), "ScribeRole: caller does not have the Scribe role");
        _;
    }

    function isScribe(address account) public view returns (bool) {
        return _Scribes.has(account);
    }

    function renounceScribe() public {
        _removeScribe(_msgSender());
    }

    function _addScribe(address account) internal {
        _Scribes.add(account);
        emit ScribeAdded(account);
    }

    function _removeScribe(address account) internal {
        _Scribes.remove(account);
        emit ScribeRemoved(account);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

/***************
TLDR CONTRACT
***************/
contract lexDAOregistry is ScribeRole, ERC20 { // TLDR: internet-native market to wrap & enforce common deal patterns with legal & ethereal security
    using SafeMath for uint256;
    
    // lexDAO references for lexDAOscribe (lexScribe) reputation governance fees (¦®)
    address payable public lexDAO;
	
    // lexDAO (LEX) ERC-20 token references for public inspection
    address public lexContractAddress = address(this);
    ERC20 lexContract = ERC20(lexContractAddress); 
    
    string public name = "lexDAO";
    string public symbol = "LEX";
    uint8 public decimals = 18;
	
    // counters for lexScribe lexScriptWrapper and registered DDR (rddr) / DC (rdc)
    uint256 public LSW = 1; // number of lexScriptWrapper enscribed (starting from constructor tldr template)
    uint256 public RDC; // number of rdc
    uint256 public RDDR; // number of rddr
	
    // mapping for lexScribe reputation governance program
    mapping(address => uint256) public reputation; // mapping lexScribe reputation points 
    mapping(address => uint256) public lastActionTimestamp; // mapping Unix timestamp of lexScribe governance actions (cooldown)
    mapping(address => uint256) public lastSuperActionTimestamp; // mapping Unix timestamp of special lexScribe governance actions that require longer cooldown (icedown)
    
    // mapping for stored lexScript wrappers and registered digital dollar retainers (DDR / rddr)
    mapping (uint256 => lexScriptWrapper) public lexScript; // mapping registered lexScript 'wet code' templates
    mapping (uint256 => DC) public rdc; // mapping rdc call numbers for inspection and signature revocation
    mapping (uint256 => DDR) public rddr; // mapping rddr call numbers for inspection and digital dollar payments
	
    struct lexScriptWrapper { // LSW: rddr lexScript templates maintained by lexScribes
        address lexScribe; // lexScribe (0x) address that enscribed lexScript template into TLDR / can make subsequent edits (lexVersion)
        address lexAddress; // (0x) address to receive lexScript wrapper lexFee / adjustable by associated lexScribe
        string templateTerms; // lexScript template terms to wrap rddr with legal security
        uint256 lexID; // number to reference in rddr to import lexScript wrapper terms
        uint256 lexVersion; // version number to mark lexScribe edits
        uint256 lexRate; // fixed, divisible rate for lexFee in ddrToken type per rddr payment made thereunder / e.g., 100 = 1% lexFee on rddr payDDR payment transaction
    }
        
    struct DC { // Digital Covenant lexScript templates maintained by lexScribes
        address signatory; // DC signatory (0x) address
        string templateTerms; // DC templateTerms imported from referenced lexScriptWrapper
        string signatureDetails; // DC may include signatory name or other supplementary info
        uint256 lexID; // lexID number reference to include lexScriptWrapper for legal security 
        uint256 dcNumber; // DC number generated on signed covenant registration / identifies DC for signatory revocation function call
        uint256 timeStamp; // block.timestamp ("now") of DC registration 
        bool revoked; // tracks signatory revocation status on DC
    }
    	
    struct DDR { // Digital Dollar Retainer created on lexScript terms maintained by lexScribes / data for registration 
        address client; // rddr client (0x) address
        address provider; // provider (0x) address that receives ERC-20 payments in exchange for goods or services
        ERC20 ddrToken; // ERC-20 digital token (0x) address used to transfer digital value on ethereum under rddr / e.g., DAI 'digital dollar' - 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359
        string deliverable; // goods or services (deliverable) retained for benefit of ethereum payments
        string governingLawForum; // choice of law and forum for retainer relationship (or similar legal wrapper/context description)
        uint256 lexID; // lexID number reference to include lexScriptWrapper for legal security / default '1' for generalized rddr lexScript template
        uint256 ddrNumber; // rddr number generated on DDR registration / identifies rddr for payDDR function calls
        uint256 timeStamp; // block.timestamp ("now") of registration used to calculate retainerTermination UnixTime
        uint256 retainerTermination; // termination date of rddr in UnixTime / locks payments to provider / after termination, allows withdrawal of remaining escrow digital value by client on payDDR function
        uint256 deliverableRate; // rate for rddr deliverables in digital dollar wei amount / 1 = 1000000000000000000
        uint256 paid; // tracking amount of designated ERC-20 digital value paid under rddr in wei amount for payCap logic
        uint256 payCap; // value cap limit on rddr payments in wei amount 
        bool disputed; // tracks digital dispute status from client or provider / if called, locks remainder of escrow rddr payments for reputable lexScribe resolution
    }
    	
    constructor(string memory tldrTerms, uint256 tldrLexRate, address tldrLexAddress, address payable tldrLexDAO) public { // deploys TLDR contract with designated lexRate / lexAddress (0x) & stores base lexScript template "1" (lexID)
	    address lexScribe = msg.sender; // TLDR summoner is lexScribe
	    reputation[msg.sender] = 3; // sets TLDR summoner lexScribe reputation to '3' max value on construction
	    lexDAO = tldrLexDAO; // lexDAO (0x) address as constructed
	    uint256 lexID = 1; // default lexID for constructor / general rddr reference, 'tldrTerms'
	    uint256 lexVersion = 0; // initialized version of tldrTerms
	    
	        lexScript[lexID] = lexScriptWrapper( // populate default '1' lexScript data for reference in LSW and rddr
                lexScribe,
                tldrLexAddress,
                tldrTerms,
                lexID,
                lexVersion,
                tldrLexRate);
    }
        
    // TLDR Contract Events
    event Enscribed(uint256 indexed lexID, uint256 indexed lexVersion, address indexed lexScribe); // triggered on successful LSW creation / edits to LSW
    event Signed(uint256 indexed lexID, uint256 indexed dcNumber, address indexed signatory); // triggered on successful DC creation / edits to DC 
    event Registered(uint256 indexed ddrNumber, uint256 indexed lexID); // triggered on successful rddr 
    event Paid(uint256 indexed ddrNumber, uint256 indexed lexID); // triggered on successful rddr payments
    
    /***************
    TLDR GOVERNANCE FUNCTIONS
    ***************/   
    // restricts lexScribe TLDR reputation governance function calls to once per day (cooldown)
    modifier cooldown() {
        require(now.sub(lastActionTimestamp[msg.sender]) > 1 days); // enforces cooldown period
        _;
        
	    lastActionTimestamp[msg.sender] = now; // block.timestamp, "now"
    }
        
    // restricts important lexScribe TLDR reputation staking and lexDAO governance function calls to once per 90 days (icedown)
    modifier icedown() {
        require(now.sub(lastSuperActionTimestamp[msg.sender]) > 90 days); // enforces icedown period
        _;
        
	    lastSuperActionTimestamp[msg.sender] = now; // block.timestamp, "now"
    }
    
    // lexDAO can add new lexScribe to maintain TLDR
    function addScribe(address account) public {
        require(msg.sender == lexDAO);
        _addScribe(account);
	    reputation[account] = 1;
    }
    
    // lexDAO can remove lexScribe from TLDR / slash reputation
    function removeScribe(address account) public {
        require(msg.sender == lexDAO);
        _removeScribe(account);
	    reputation[account] = 0;
    }
    
    // lexDAO can update (0x) address receiving reputation governance stakes (¦®) / maintaining lexScribe registry
    function updateLexDAO(address payable newLexDAO) public {
    	require(msg.sender == lexDAO);
        require(newLexDAO != address(0)); // program safety check / newLexDAO cannot be "0" burn address
        
	    lexDAO = newLexDAO; // update lexDAO (0x) address
    }
        
    // lexScribes can stake ether (¦®) value for TLDR reputation and special TLDR function access (TLDR-write privileges, rddr dispute resolution) 
    function stakeETHreputation() payable public onlyScribe icedown {
        require(msg.value == 0.1 ether); // tenth of ether (¦®) fee for staking reputation to lexDAO
        
	    reputation[msg.sender] = 3; // sets / refreshes lexScribe reputation to '3' max value, 'three strikes, you're out'
        
	    address(lexDAO).transfer(msg.value); // forwards staked value (¦®) to designated lexDAO (0x) address
    }
    
    // lexScribes can burn minted LEX value for TLDR reputation 
    function stakeLEXreputation() public onlyScribe icedown { 
	    _burn(_msgSender(), 10000000000000000000); // 10 LEX burned 
        
	    reputation[msg.sender] = 3; // sets / refreshes lexScribe reputation to '3' max value, 'three strikes, you're out'
    }
         
    // public check on lexScribe reputation status
    function isReputable(address x) public view returns (bool) { // returns true if lexScribe is reputable
        return reputation[x] > 0;
    }
        
    // reputable lexScribes can reduce each other's reputation within cooldown period 
    function reduceScribeRep(address reducedLexScribe) cooldown public {
        require(isReputable(msg.sender)); // program governance check / lexScribe must be reputable
        require(msg.sender != reducedLexScribe); // program governance check / cannot reduce own reputation
        
	    reputation[reducedLexScribe] = reputation[reducedLexScribe].sub(1); // reduce referenced lexScribe reputation by "1"
    }
        
    // reputable lexScribes can repair each other's reputation within cooldown period
    function repairScribeRep(address repairedLexScribe) cooldown public {
        require(isReputable(msg.sender)); // program governance check / lexScribe must be reputable
        require(msg.sender != repairedLexScribe); // program governance check / cannot repair own reputation
        require(reputation[repairedLexScribe] < 3); // program governance check / cannot repair fully reputable lexScribe
        require(reputation[repairedLexScribe] > 0); // program governance check / cannot repair disreputable lexScribe / induct non-staked lexScribe
        
	    reputation[repairedLexScribe] = reputation[repairedLexScribe].add(1); // repair reputation by "1"
    }
       
    /***************
    LEXSCRIBE FUNCTIONS
    ***************/
    // reputable lexScribes can register lexScript legal wrappers on TLDR and program ERC-20 lexFees associated with lexID / receive LEX mint, "1"
    function writeLexScript(string memory templateTerms, uint256 lexRate, address lexAddress) public {
        require(isReputable(msg.sender)); // program governance check / lexScribe must be reputable 
	
	    uint256 lexID = LSW.add(1); // reflects new lexScript value for tracking lexScript wrappers
	    uint256 lexVersion = 0; // initalized lexVersion, "0"
	    LSW = LSW.add(1); // counts new entry to LSW 
	    
	        lexScript[lexID] = lexScriptWrapper( // populate lexScript data for rddr / rdc usage
                msg.sender,
                lexAddress,
                templateTerms,
                lexID,
                lexVersion,
                lexRate);
                
        _mint(msg.sender, 1000000000000000000); // mint lexScribe "1" LEX for contribution to TLDR
	
        emit Enscribed(lexID, lexVersion, msg.sender); 
    }
	    
    // lexScribes can update TLDR lexScript wrappers with new templateTerms and (0x) newLexAddress / versions up LSW
    function editLexScript(uint256 lexID, string memory templateTerms, address lexAddress) public {
	    lexScriptWrapper storage lS = lexScript[lexID]; // retrieve LSW data
	
	    require(address(msg.sender) == lS.lexScribe); // program safety check / authorization 
	
	    uint256 lexVersion = lS.lexVersion.add(1); // updates lexVersion 
	    
	        lexScript[lexID] = lexScriptWrapper( // populate updated lexScript data for rddr / rdc usage
                msg.sender,
                lexAddress,
                templateTerms,
                lexID,
                lexVersion,
                lS.lexRate);
                	
        emit Enscribed(lexID, lexVersion, msg.sender);
    }

    /***************
    MARKET FUNCTIONS
    ***************/
    // public can sign and associate (0x) ethereum identity with lexScript digital covenant wrapper 
    function signDC(uint256 lexID, string memory signatureDetails) public { // sign Digital Covenant with (0x) address
	    lexScriptWrapper storage lS = lexScript[lexID]; // retrieve LSW data
	
	    uint256 dcNumber = RDC.add(1); // reflects new rdc value for public inspection and signature revocation
	    bool revoked = false; // initialized value of rdc revocation status, "false"
	    RDC = RDC.add(1); // counts new entry to RDC
	        
	        rdc[dcNumber] = DC( // populate rdc data
                msg.sender,
                lS.templateTerms,
                signatureDetails,
                lexID,
                dcNumber,
                now,
                revoked);
                	
        emit Signed(lexID, dcNumber, msg.sender);
    }
    	
    // registered DC signatories can revoke (0x) signature  
    function revokeDC(uint256 dcNumber) public { // revoke Digital Covenant signature with (0x) address
	    DC storage dc = rdc[dcNumber]; // retrieve rdc data
	
	    require(address(msg.sender) == dc.signatory); // program safety check / authorization
	    
	        rdc[dcNumber] = DC(// update rdc data
                msg.sender,
                "Signature Revoked", // replace Digital Covenant terms with revocation message
                dc.signatureDetails,
                dc.lexID,
                dc.dcNumber,
                now,
                true);
                	
        emit Signed(dc.lexID, dcNumber, msg.sender);
    }
    
    // public can register DDR with TLDR lexScripts (lexID) 
    function registerDDR( // rddr 
    	address client,
    	address provider,
    	ERC20 ddrToken,
    	string memory deliverable,
    	string memory governingLawForum,
        uint256 retainerDuration,
    	uint256 deliverableRate,
    	uint256 payCap,
    	uint256 lexID) public {
    	require(lexID != (0)); // program safety check 
        require(deliverableRate <= payCap); // program safety check / economics
	    require(msg.sender == provider); // program safety check / authorization / provider countersigns client payCap TLDR approval for effective rddr
        
	    uint256 ddrNumber = RDDR.add(1); // reflects new rddr value for inspection and client digital payments
        uint256 retainerTermination = now.add(retainerDuration); // rddr termination date in UnixTime, "now" block.timestamp + retainerDuration
        
	    ddrToken.transferFrom(client, address(this), payCap); // escrows payCap amount in approved ddrToken into TLDR for rddr payments and/or lexScribe resolution
        
	    RDDR = RDDR.add(1); // counts new entry to RDDR
    
            rddr[ddrNumber] = DDR( // populate rddr data 
                client,
                provider,
                ddrToken,
                deliverable,
                governingLawForum,
                lexID,
                ddrNumber,
                now, // block.timestamp, "now"
                retainerTermination,
                deliverableRate,
                0,
                payCap,
                false);
        	 
        emit Registered(lexID, ddrNumber); 
    }
         
    // rddr client can delegate performance management function and beneficiary status (designed for limited grant applications, milestone-watching)
    function delegateDDRclient(uint256 ddrNumber, address clientDelegate) public {
        DDR storage ddr = rddr[ddrNumber]; // retrieve rddr data
        
        require(ddr.disputed == false); // program safety check / status
        require (now <= ddr.retainerTermination); // program safety check / time
        require(msg.sender == ddr.client); // program safety check / authorization
        require(ddr.paid < ddr.payCap); // program safety check / economics
        
        ddr.client = clientDelegate; // update rddr client address to delegate
    }
    
    // rddr parties can initiate dispute and lock escrowed remainder of rddr payCap in TLDR until resolution by reputable lexScribe
    function disputeDDR(uint256 ddrNumber) public {
        DDR storage ddr = rddr[ddrNumber]; // retrieve rddr data
        
	    require(ddr.disputed == false); // program safety check / status
        require (now <= ddr.retainerTermination); // program safety check / time
        require(msg.sender == ddr.client || msg.sender == ddr.provider); // program safety check / authorization
	    require(ddr.paid < ddr.payCap); // program safety check / economics
        
	    ddr.disputed = true; // updates rddr value to reflect dispute status, "true"
    }
    
    // reputable lexScribe can resolve rddr dispute with division of remaining payCap amount in wei / receive 5% fee / receive LEX mint, "1"
    function resolveDDR(uint256 ddrNumber, uint256 clientAward, uint256 providerAward) public {
        DDR storage ddr = rddr[ddrNumber]; // retrieve rddr data
	
	    uint256 ddRemainder = ddr.payCap.sub(ddr.paid); // alias remainder rddr wei amount for rddr resolution reference
	
	    require(clientAward.add(providerAward) == ddRemainder); // program safety check / economics
        require(msg.sender != ddr.client); // program safety check / authorization / client cannot resolve own dispute as lexScribe
        require(msg.sender != ddr.provider); // program safety check / authorization / provider cannot resolve own dispute as lexScribe
        require(isReputable(msg.sender)); // program governance check / resolving lexScribe must be reputable
	    require(balanceOf(msg.sender) >= 5000000000000000000); // program governance check / resolving lexScribe must have at least "5" LEX balance
	
        uint256 resolutionFee = ddRemainder.div(20); // calculates 5% lexScribe dispute resolution fee
	    uint256 resolutionFeeSplit = resolutionFee.div(2); // calculates resolution fee split between client and provider
	
        ddr.ddrToken.transfer(ddr.client, clientAward.sub(resolutionFeeSplit)); // executes ERC-20 award transfer to rddr client
        ddr.ddrToken.transfer(ddr.provider, providerAward.sub(resolutionFeeSplit)); // executes ERC-20 award transfer to rddr provider
    	ddr.ddrToken.transfer(msg.sender, resolutionFee); // executes ERC-20 fee transfer to resolving lexScribe
    	
    	_mint(msg.sender, 1000000000000000000); // mint resolving lexScribe "1" LEX for contribution to TLDR
	
	    ddr.paid = ddr.paid.add(ddRemainder); // tallies remainder to paid wei amount to reflect rddr closure
    }
    
    // pay rddr on TLDR
    function payDDR(uint256 ddrNumber) public { // releases escrowed ddrToken deliverableRate amount to provider (0x) address / lexFee for attached lexID lexAddress
    	DDR storage ddr = rddr[ddrNumber]; // retrieve rddr data
    	lexScriptWrapper storage lS = lexScript[ddr.lexID]; // retrieve LSW data
	
	    require(ddr.disputed == false); // program safety check / dispute status
    	require(now <= ddr.retainerTermination); // program safety check / time
    	require(address(msg.sender) == ddr.client); // program safety check / authorization
    	require(ddr.paid.add(ddr.deliverableRate) <= ddr.payCap); // program safety check / economics
	
    	uint256 lexFee = ddr.deliverableRate.div(lS.lexRate); // derive lexFee from rddr value
	
    	ddr.ddrToken.transfer(ddr.provider, ddr.deliverableRate.sub(lexFee)); // executes ERC-20 transfer to rddr provider in deliverableRate amount
    	ddr.ddrToken.transfer(lS.lexAddress, lexFee); // executes ERC-20 transfer of lexFee to (0x) lexAddress identified in lexID
    	ddr.paid = ddr.paid.add(ddr.deliverableRate); // tracks total ERC-20 wei amount paid under rddr / used to calculate rddr remainder
        
	    emit Paid(ddr.ddrNumber, ddr.lexID); 
    }
    
    // withdraw rddr remainder on TLDR after termination
    function withdrawDDR(uint256 ddrNumber) public { // releases escrowed ddrToken deliverableRate amount to provider (0x) address 
    	DDR storage ddr = rddr[ddrNumber]; // retrieve rddr data
	
    	require(now >= ddr.retainerTermination); // program safety check / time
    	require(address(msg.sender) == ddr.client); // program safety check / authorization
    	
    	uint256 remainder = ddr.payCap.sub(ddr.paid); // derive rddr remainder
    	
    	require(remainder > 0); // program safety check / economics
	
    	ddr.ddrToken.transfer(ddr.client, remainder); // executes ERC-20 transfer to rddr provider in escrow remainder amount
    	
    	ddr.paid = ddr.paid.add(remainder); // tallies remainder to paid wei amount to reflect rddr closure
    }
}