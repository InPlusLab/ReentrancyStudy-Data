/**
 *Submitted for verification at Etherscan.io on 2019-09-24
*/

pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
   /*
   Over solidity version 0.5.0, Cannot assign same function name at constructor;
  function Ownable() public {
  */
  constructor () internal {
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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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
     * @title Secondary
     * @dev A Secondary contract can only be used by its primary account (the one that created it)
     */
    contract Secondary {
        address private _primary;
    
        event PrimaryTransferred(
            address recipient
        );
    
        /**
         * @dev Sets the primary account to the one that is creating the Secondary contract.
         */
        constructor () internal {
            _primary = msg.sender;
            emit PrimaryTransferred(_primary);
        }
    
        /**
         * @dev Reverts if called from any account other than the primary.
         */
        modifier onlyPrimary() {
            require(msg.sender == _primary);
            _;
        }
    
        /**
         * @return the address of the primary.
         */
        function primary() public view returns (address) {
            return _primary;
        }
    
        /**
         * @dev Transfers contract to a new primary.
         * @param recipient The address of new primary.
         */
        function transferPrimary(address recipient) public onlyPrimary {
            require(recipient != address(0));
            _primary = recipient;
            emit PrimaryTransferred(_primary);
        }
    }
    
    // File: node_modules\openzeppelin-solidity\contracts\token\ERC20\IERC20.sol
    /**
     * @title ERC20 interface
     * @dev see https://github.com/ethereum/EIPs/issues/20
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
    
    
    // File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol
    /**
     * @title Standard ERC20 token
     *
     * @dev Implementation of the basic standard token.
     * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
     * Originally based on code by FirstBlood:
     * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
     *
     * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
     * all accounts just by listening to said events. Note that this isn't required by the specification, and other
     * compliant implementations may not do it.
     */
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
    
    
    // File: openzeppelin-solidity\contracts\token\ERC20\ERC20Burnable.sol
    /**
     * @title Burnable Token
     * @dev Token that can be irreversibly burned (destroyed).
     */
    contract ERC20Burnable is ERC20 {
        /**
         * @dev Burns a specific amount of tokens.
         * @param value The amount of token to be burned.
         */
        function burn(uint256 value) public {
            _burn(msg.sender, value);
        }
    
        /**
         * @dev Burns a specific amount of tokens from the target address and decrements allowance
         * @param from address The account whose tokens will be burned.
         * @param value uint256 The amount of token to be burned.
         */
        function burnFrom(address from, uint256 value) public {
            _burnFrom(from, value);
        }
    }
    // File: node_modules\openzeppelin-solidity\contracts\access\Roles.sol
    /**
     * @title Roles
     * @dev Library for managing addresses assigned to a Role.
     */
    library Roles {
        struct Role {
            mapping (address => bool) bearer;
        }
    
        /**
         * @dev give an account access to this role
         */
        function add(Role storage role, address account) internal {
            require(account != address(0));
            require(!has(role, account));
    
            role.bearer[account] = true;
        }
    
        /**
         * @dev remove an account's access to this role
         */
        function remove(Role storage role, address account) internal {
            require(account != address(0));
            require(has(role, account));
    
            role.bearer[account] = false;
        }
    
        /**
         * @dev check if an account has this role
         * @return bool
         */
        function has(Role storage role, address account) internal view returns (bool) {
            require(account != address(0));
            return role.bearer[account];
        }
    }
    
    // File: node_modules\openzeppelin-solidity\contracts\access\roles\MinterRole.sol
    contract MinterRole {
        using Roles for Roles.Role;
    
        event MinterAdded(address indexed account);
        event MinterRemoved(address indexed account);
    
        Roles.Role private _minters;
    
        constructor () internal {
            _addMinter(msg.sender);
        }
    
        modifier onlyMinter() {
            require(isMinter(msg.sender));
            _;
        }
    
        function isMinter(address account) public view returns (bool) {
            return _minters.has(account);
        }
    
        function addMinter(address account) public onlyMinter {
            _addMinter(account);
        }
    
        function renounceMinter() public {
            _removeMinter(msg.sender);
        }
    
        function _addMinter(address account) internal {
            _minters.add(account);
            emit MinterAdded(account);
        }
    
        function _removeMinter(address account) internal {
            _minters.remove(account);
            emit MinterRemoved(account);
        }
    }
    
    // File: openzeppelin-solidity\contracts\token\ERC20\ERC20Mintable.sol
    
    /**
     * @title ERC20Mintable
     * @dev ERC20 minting logic
     */
    contract ERC20Mintable is ERC20, MinterRole {
        /**
         * @dev Function to mint tokens
         * @param to The address that will receive the minted tokens.
         * @param value The amount of tokens to mint.
         * @return A boolean that indicates if the operation was successful.
         */
        function mint(address to, uint256 value) public onlyMinter returns (bool) {
            _mint(to, value);
            return true;
        }
    }
    
    // File: contracts\ERC20Frozenable.sol
    
    
    //truffle-flattener Token.sol
    contract ERC20Frozenable is ERC20Burnable, ERC20Mintable, Ownable {
        mapping (address => bool) private _frozenAccount;
        event FrozenFunds(address target, bool frozen);
    
    
        function frozenAccount(address _address) public view returns(bool isFrozen) {
            return _frozenAccount[_address];
        }
    
        function freezeAccount(address target, bool freeze)  public onlyOwner {
            require(_frozenAccount[target] != freeze, "Same as current");
            _frozenAccount[target] = freeze;
            emit FrozenFunds(target, freeze);
        }
    
        function _transfer(address from, address to, uint256 value) internal {
            require(!_frozenAccount[from], "error - frozen");
            require(!_frozenAccount[to], "error - frozen");
            super._transfer(from, to, value);
        }
    
    }
    
    // File: openzeppelin-solidity\contracts\token\ERC20\ERC20Detailed.sol
    
    /**
     * @title ERC20Detailed token
     * @dev The decimals are only for visualization purposes.
     * All the operations are done using the smallest and indivisible token unit,
     * just as on Ethereum all the operations are done in wei.
     */
    contract ERC20Detailed is IERC20 {
        string private _name;
        string private _symbol;
        uint8 private _decimals;
    
        constructor (string memory name, string memory symbol, uint8 decimals) public {
            _name = name;
            _symbol = symbol;
            _decimals = decimals;
        }
    
        /**
         * @return the name of the token.
         */
        function name() public view returns (string memory) {
            return _name;
        }
    
        /**
         * @return the symbol of the token.
         */
        function symbol() public view returns (string memory) {
            return _symbol;
        }
    
        /**
         * @return the number of decimals of the token.
         */
        function decimals() public view returns (uint8) {
            return _decimals;
        }
    }
    
     /**
      * @title Escrow
      * @dev Base escrow contract, holds funds designated for a payee until they
      * withdraw them.
      * @dev Intended usage: This contract (and derived escrow contracts) should be a
      * standalone contract, that only interacts with the contract that instantiated
      * it. That way, it is guaranteed that all Ether will be handled according to
      * the Escrow rules, and there is no need to check for payable functions or
      * transfers in the inheritance tree. The contract that uses the escrow as its
      * payment method should be its primary, and provide public methods redirecting
      * to the escrow's deposit and withdraw.
      */
    contract Escrow is Secondary {
        using SafeMath for uint256;
    
        event Deposited(address indexed payee, uint256 weiAmount);
        event Withdrawn(address indexed payee, uint256 weiAmount);
    
        mapping(address => uint256) private _deposits;
    
        function depositsOf(address payee) public view returns (uint256) {
            return _deposits[payee];
        }
    
        /**
         * @dev Stores the sent amount as credit to be withdrawn.
         * @param payee The destination address of the funds.
         */
        function deposit(address payee) public onlyPrimary payable {
            uint256 amount = msg.value;
            _deposits[payee] = _deposits[payee].add(amount);
    
            emit Deposited(payee, amount);
        }
    
        /**
         * @dev Withdraw accumulated balance for a payee.
         * @param payee The address whose funds will be withdrawn and transferred to.
         */
        function withdraw(address payee) public onlyPrimary {
            uint256 payment = _deposits[payee];
    
            _deposits[payee] = 0;
    
            payee.transfer(payment);
    
            emit Withdrawn(payee, payment);
        }
    }
    
    /**
     * @title PullPayment
     * @dev Base contract supporting async send for pull payments. Inherit from this
     * contract and use _asyncTransfer instead of send or transfer.
     */
    contract PullPayment {
        Escrow private _escrow;
    
        constructor () internal {
            _escrow = new Escrow();
        }
    
        /**
         * @dev Withdraw accumulated balance.
         * @param payee Whose balance will be withdrawn.
         */
        function withdrawPayments(address payee) public {
            _escrow.withdraw(payee);
        }
    
        /**
         * @dev Returns the credit owed to an address.
         * @param dest The creditor's address.
         */
        function payments(address dest) public view returns (uint256) {
            return _escrow.depositsOf(dest);
        }
    
        /**
         * @dev Called by the payer to store the sent amount as credit to be pulled.
         * @param dest The destination address of the funds.
         * @param amount The amount to transfer.
         */
        function _asyncTransfer(address dest, uint256 amount) internal {
            _escrow.deposit.value(amount)(dest);
        }
    }
    
    contract PaymentSplitter {
        using SafeMath for uint256;
    
        event PayeeAdded(address account, uint256 shares);
        event PaymentReleased(address to, uint256 amount);
        event PaymentReceived(address from, uint256 amount);
    
        uint256 private _totalShares;
        uint256 private _totalReleased;
    
        mapping(address => uint256) private _shares;
        mapping(address => uint256) private _released;
        address[] private _payees;
    
        /**
         * @dev Constructor
         */
        constructor (address[] memory payees, uint256[] memory shares) public payable {
            require(payees.length == shares.length);
            require(payees.length > 0);
    
            for (uint256 i = 0; i < payees.length; i++) {
                _addPayee(payees[i], shares[i]);
            }
        }
    
        /**
         * @dev payable fallback
         */
        function () external payable {
            emit PaymentReceived(msg.sender, msg.value);
        }
    
        /**
         * @return the total shares of the contract.
         */
        function totalShares() public view returns (uint256) {
            return _totalShares;
        }
    
        /**
         * @return the total amount already released.
         */
        function totalReleased() public view returns (uint256) {
            return _totalReleased;
        }
    
        /**
         * @return the shares of an account.
         */
        function shares(address account) public view returns (uint256) {
            return _shares[account];
        }
    
        /**
         * @return the amount already released to an account.
         */
        function released(address account) public view returns (uint256) {
            return _released[account];
        }
    
        /**
         * @return the address of a payee.
         */
        function payee(uint256 index) public view returns (address) {
            return _payees[index];
        }
    
        /**
         * @dev Release one of the payee's proportional payment.
         * @param account Whose payments will be released.
         */
        function release(address account) public {
            require(_shares[account] > 0);
    
            uint256 totalReceived = address(this).balance.add(_totalReleased);
            uint256 payment = totalReceived.mul(_shares[account]).div(_totalShares).sub(_released[account]);
    
            require(payment != 0);
    
            _released[account] = _released[account].add(payment);
            _totalReleased = _totalReleased.add(payment);
    
            account.transfer(payment);
            emit PaymentReleased(account, payment);
        }
    
        /**
         * @dev Add a new payee to the contract.
         * @param account The address of the payee to add.
         * @param shares_ The number of shares owned by the payee.
         */
        function _addPayee(address account, uint256 shares_) private {
            require(account != address(0));
            require(shares_ > 0);
            require(_shares[account] == 0);
    
            _payees.push(account);
            _shares[account] = shares_;
            _totalShares = _totalShares.add(shares_);
            emit PayeeAdded(account, shares_);
        }
    }
    
    contract ConditionalEscrow is Escrow {
        /**
         * @dev Returns whether an address is allowed to withdraw their funds. To be
         * implemented by derived contracts.
         * @param payee The destination address of the funds.
         */
        function withdrawalAllowed(address payee) public view returns (bool);
    
        function withdraw(address payee) public {
            require(withdrawalAllowed(payee));
            super.withdraw(payee);
        }
    }
    
    
    contract RefundEscrow is ConditionalEscrow {
        enum State { Active, Refunding, Closed }
    
        event RefundsClosed();
        event RefundsEnabled();
    
        State private _state;
        address private _beneficiary;
    
        /**
         * @dev Constructor.
         * @param beneficiary The beneficiary of the deposits.
         */
        constructor (address beneficiary) public {
            require(beneficiary != address(0));
            _beneficiary = beneficiary;
            _state = State.Active;
        }
    
        /**
         * @return the current state of the escrow.
         */
        function state() public view returns (State) {
            return _state;
        }
    
        /**
         * @return the beneficiary of the escrow.
         */
        function beneficiary() public view returns (address) {
            return _beneficiary;
        }
    
        /**
         * @dev Stores funds that may later be refunded.
         * @param refundee The address funds will be sent to if a refund occurs.
         */
        function deposit(address refundee) public payable {
            require(_state == State.Active);
            super.deposit(refundee);
        }
    
        /**
         * @dev Allows for the beneficiary to withdraw their funds, rejecting
         * further deposits.
         */
        function close() public onlyPrimary {
            require(_state == State.Active);
            _state = State.Closed;
            emit RefundsClosed();
        }
    
        /**
         * @dev Allows for refunds to take place, rejecting further deposits.
         */
        function enableRefunds() public onlyPrimary {
            require(_state == State.Active);
            _state = State.Refunding;
            emit RefundsEnabled();
        }
    
        /**
         * @dev Withdraws the beneficiary's funds.
         */
        function beneficiaryWithdraw() public {
            require(_state == State.Closed);
            _beneficiary.transfer(address(this).balance);
        }
    
        /**
         * @dev Returns whether refundees can withdraw their deposits (be refunded). The overridden function receives a
         * 'payee' argument, but we ignore it here since the condition is global, not per-payee.
         */
        function withdrawalAllowed(address) public view returns (bool) {
            return _state == State.Refunding;
        }
    }
    // File: contracts\Token.sol
    //truffle-flattener Token.sol
    contract KtuneTokenBlocks is ERC20Frozenable, ERC20Detailed {
    
        constructor()
        ERC20Detailed("K-Tune Token", "KTT", 18)
        public {
        }
    }

/**
 * @title WhitelistableConstraints
 * @dev Contract encapsulating the constraints applicable to a Whitelistable contract.
 */
contract WhitelistableConstraints {

    /**
     * @dev Check if whitelist with specified parameters is allowed.
     * @param _maxWhitelistLength The maximum length of whitelist. Zero means no whitelist.
     * @param _weiWhitelistThresholdBalance The threshold balance triggering whitelist check.
     * @return true if whitelist with specified parameters is allowed, false otherwise
     */
    function isAllowedWhitelist(uint256 _maxWhitelistLength, uint256 _weiWhitelistThresholdBalance)
        public pure returns(bool isReallyAllowedWhitelist) {
        return _maxWhitelistLength > 0 || _weiWhitelistThresholdBalance > 0;
    }
}

/**
 * @title Whitelistable
 * @dev Base contract implementing a whitelist to keep track of investors.
 * The construction parameters allow for both whitelisted and non-whitelisted contracts:
 * 1) maxWhitelistLength = 0 and whitelistThresholdBalance > 0: whitelist disabled
 * 2) maxWhitelistLength > 0 and whitelistThresholdBalance = 0: whitelist enabled, full whitelisting
 * 3) maxWhitelistLength > 0 and whitelistThresholdBalance > 0: whitelist enabled, partial whitelisting
 */
contract Whitelistable is WhitelistableConstraints {

    event LogMaxWhitelistLengthChanged(address indexed caller, uint256 indexed maxWhitelistLength);
    event LogWhitelistThresholdBalanceChanged(address indexed caller, uint256 indexed whitelistThresholdBalance);
    event LogWhitelistAddressAdded(address indexed caller, address indexed subscriber);
    event LogWhitelistAddressRemoved(address indexed caller, address indexed subscriber);

    mapping (address => bool) public whitelist;

    uint256 public whitelistLength;

    uint256 public maxWhitelistLength;

    uint256 public whitelistThresholdBalance;

    constructor(uint256 _maxWhitelistLength, uint256 _whitelistThresholdBalance) internal {
        require(isAllowedWhitelist(_maxWhitelistLength, _whitelistThresholdBalance), "parameters not allowed");

        maxWhitelistLength = _maxWhitelistLength;
        whitelistThresholdBalance = _whitelistThresholdBalance;
    }

    /**
     * @return true if whitelist is currently enabled, false otherwise
     */
    function isWhitelistEnabled() public view returns(bool isReallyWhitelistEnabled) {
        return maxWhitelistLength > 0;
    }

    /**
     * @return true if subscriber is whitelisted, false otherwise
     */
    function isWhitelisted(address _subscriber) public view returns(bool isReallyWhitelisted) {
        return whitelist[_subscriber];
    }

    function setMaxWhitelistLengthInternal(uint256 _maxWhitelistLength) internal {
        require(isAllowedWhitelist(_maxWhitelistLength, whitelistThresholdBalance),
            "_maxWhitelistLength not allowed");
        require(_maxWhitelistLength != maxWhitelistLength, "_maxWhitelistLength equal to current one");

        maxWhitelistLength = _maxWhitelistLength;

        emit LogMaxWhitelistLengthChanged(msg.sender, maxWhitelistLength);
    }

    function setWhitelistThresholdBalanceInternal(uint256 _whitelistThresholdBalance) internal {
        require(isAllowedWhitelist(maxWhitelistLength, _whitelistThresholdBalance),
            "_whitelistThresholdBalance not allowed");
        require(whitelistLength == 0 || _whitelistThresholdBalance > whitelistThresholdBalance,
            "_whitelistThresholdBalance not greater than current one");

        whitelistThresholdBalance = _whitelistThresholdBalance;

        emit LogWhitelistThresholdBalanceChanged(msg.sender, _whitelistThresholdBalance);
    }

    function addToWhitelistInternal(address _subscriber) internal {
        require(_subscriber != address(0), "_subscriber is zero");
        require(!whitelist[_subscriber], "already whitelisted");
        require(whitelistLength < maxWhitelistLength, "max whitelist length reached");

        whitelistLength++;

        whitelist[_subscriber] = true;

        emit LogWhitelistAddressAdded(msg.sender, _subscriber);
    }

    function removeFromWhitelistInternal(address _subscriber, uint256 _balance) internal {
        require(_subscriber != address(0), "_subscriber is zero");
        require(whitelist[_subscriber], "not whitelisted");
        require(_balance <= whitelistThresholdBalance, "_balance greater than whitelist threshold");

        assert(whitelistLength > 0);

        whitelistLength--;

        whitelist[_subscriber] = false;

        emit LogWhitelistAddressRemoved(msg.sender, _subscriber);
    }

    /**
     * @param _subscriber The subscriber for which the balance check is required.
     * @param _balance The balance value to check for allowance.
     * @return true if the balance is allowed for the subscriber, false otherwise
     */
    function isAllowedBalance(address _subscriber, uint256 _balance) public view returns(bool isReallyAllowed) {
        return !isWhitelistEnabled() || _balance <= whitelistThresholdBalance || whitelist[_subscriber];
    }
}

// Abstract base contract
contract KYCBase {
    using SafeMath for uint256;

    mapping (address => bool) public isKycSigner;
    mapping (uint64 => uint256) public alreadyPayed;

    event KycVerified(address indexed signer, address buyerAddress, uint64 buyerId, uint maxAmount);

    constructor(address[] memory kycSigners) internal {
        for (uint i = 0; i < kycSigners.length; i++) {
            isKycSigner[kycSigners[i]] = true;
        }
    }

    // Must be implemented in descending contract to assign tokens to the buyers. Called after the KYC verification is passed
    function releaseTokensTo(address buyer) internal returns(bool);

    // This method can be overridden to enable some sender to buy token for a different address
    function senderAllowedFor(address buyer)
        internal view returns(bool)
    {
        return buyer == msg.sender;
    }

    function buyTokensFor(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        public payable returns (bool)
    {
        require(senderAllowedFor(buyerAddress), "senderAllowedFor");
        return buyImplementation(buyerAddress, buyerId, maxAmount, v, r, s);
    }

    function buyTokens(uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        public payable returns (bool)
    {
        return buyImplementation(msg.sender, buyerId, maxAmount, v, r, s);
    }

    function buyImplementation(
        address buyerAddress,
        uint64 buyerId,
        uint maxAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns (bool)
    {
        // check the signature
        bytes32 hash = sha256(
            abi.encodePacked(
                "Eidoo icoengine authorization",
                this,
                buyerAddress,
                buyerId,
                maxAmount
            )
        );
        address signer = ecrecover(hash, v, r, s);
        if (!isKycSigner[signer]) {
            revert("!isKycSigner");
        } else {
            uint256 totalPayed = alreadyPayed[buyerId].add(msg.value);
            require(totalPayed <= maxAmount, "totalPayed <= maxAmount");
            alreadyPayed[buyerId] = totalPayed;
            emit KycVerified(signer, buyerAddress, buyerId, maxAmount);
            return releaseTokensTo(buyerAddress);
        }
    }

    // No payable fallback function, the tokens must be buyed using the functions buyTokens and buyTokensFor
    /*
    build to fallback function from solidity version over 0.5, have to write external
    now solidity version is 0.5.1
    function () public {
    */
    function () external {
        revert();
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
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title CrowdsaleKYC
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end block, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract CrowdsaleKYC is Pausable, Whitelistable, KYCBase {
    using AddressUtils for address;
    using SafeMath for uint256;

    event LogStartBlockChanged(uint256 indexed startBlock);
    event LogEndBlockChanged(uint256 indexed endBlock);
    event LogMinDepositChanged(uint256 indexed minDeposit);
    event LogTokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 indexed amount, uint256 tokenAmount);
    event AddedSenderAllowed(address semder);
    event RemovedSenderAllowed(address semder);

    // The token being sold
    KtuneTokenBlocks public token;

    // The start and end block where investments are allowed (both inclusive)
    uint256 public startBlock;
    uint256 public endBlock;

    // How many token units a buyer gets per wei
    uint256 public rate;

    // Amount of raised money in wei
    uint256 public raisedFunds;

    // Amount of tokens already sold
    uint256 public soldTokens;

    // Balances in wei deposited by each subscriber
    mapping (address => uint256) public balanceOf;

    // The minimum balance for each subscriber in wei
    uint256 public minDeposit;

    // Senders allowed for buyTokensFor function
    mapping (address => bool) public isAllowedSender;

    modifier beforeStart() {
        require(block.number < startBlock, "already started");
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock, "already ended");
        _;
    }

    constructor(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rate,
        uint256 _minDeposit,
        uint256 maxWhitelistLength,
        uint256 whitelistThreshold,
        address[] memory kycSigner
    )
    Whitelistable(maxWhitelistLength, whitelistThreshold)
    KYCBase(kycSigner) internal
    {
        require(_startBlock >= block.number, "_startBlock is lower than current block.number");
        require(_endBlock >= _startBlock, "_endBlock is lower than _startBlock");
        require(_rate > 0, "_rate is zero");
        require(_minDeposit > 0, "_minDeposit is zero");

        startBlock = _startBlock;
        endBlock = _endBlock;
        rate = _rate;
        minDeposit = _minDeposit;
    }

    //override KYCBase.senderAllowedFor
    function senderAllowedFor(address buyer) internal view returns(bool)
    {
        //revert(appendStr("override KYCBase.senderAllowedFor", toAsciiString(msg.sender), isAllowedSender[buyer]));
        require(buyer == msg.sender, "Buyer address not equal action address");
        return isAllowedSender[msg.sender] == true;
    }

    function addSenderAllowed(address _sender) external onlyOwner {
        isAllowedSender[_sender] = true;
        emit AddedSenderAllowed(_sender);
    }

    function removeSenderAllowed(address _sender) external onlyOwner {
        delete isAllowedSender[_sender];
        emit RemovedSenderAllowed(_sender);
    }

    /*
    * @return true if crowdsale event has started
    */
    function hasStarted() public view returns (bool started) {
        return block.number >= startBlock;
    }

    /*
    * @return true if crowdsale event has ended
    */
    function hasEnded() public view returns (bool ended) {
        return block.number > endBlock;
    }

    /**
     * Change the crowdsale start block number.
     * @param _startBlock The new start block
     */
    function setStartBlock(uint256 _startBlock) external onlyOwner beforeStart {
        require(_startBlock >= block.number, "_startBlock < current block");
        require(_startBlock <= endBlock, "_startBlock > endBlock");
        require(_startBlock != startBlock, "_startBlock == startBlock");

        startBlock = _startBlock;

        emit LogStartBlockChanged(_startBlock);
    }

    /**
     * Change the crowdsale end block number.
     * @param _endBlock The new end block
     */
    function setEndBlock(uint256 _endBlock) external onlyOwner beforeEnd {
        require(_endBlock >= block.number, "_endBlock < current block");
        require(_endBlock >= startBlock, "_endBlock < startBlock");
        require(_endBlock != endBlock, "_endBlock == endBlock");

        endBlock = _endBlock;

        emit LogEndBlockChanged(_endBlock);
    }

    /**
     * Change the minimum deposit for each subscriber. New value shall be lower than previous.
     * @param _minDeposit The minimum deposit for each subscriber, expressed in wei
     */
    function setMinDeposit(uint256 _minDeposit) external onlyOwner beforeEnd {
        require(0 < _minDeposit && _minDeposit < minDeposit, "_minDeposit is not in [0, minDeposit]");

        minDeposit = _minDeposit;

        emit LogMinDepositChanged(minDeposit);
    }

    /**
     * Change the maximum whitelist length. New value shall satisfy the #isAllowedWhitelist conditions.
     * @param maxWhitelistLength The maximum whitelist length
     */
    function setMaxWhitelistLength(uint256 maxWhitelistLength) external onlyOwner beforeEnd {
        setMaxWhitelistLengthInternal(maxWhitelistLength);
    }

    /**
     * Change the whitelist threshold balance. New value shall satisfy the #isAllowedWhitelist conditions.
     * @param whitelistThreshold The threshold balance (in wei) above which whitelisting is required to invest
     */
    function setWhitelistThresholdBalance(uint256 whitelistThreshold) external onlyOwner beforeEnd {
        setWhitelistThresholdBalanceInternal(whitelistThreshold);
    }

    /**
     * Add the subscriber to the whitelist.
     * @param subscriber The subscriber to add to the whitelist.
     */
    function addToWhitelist(address subscriber) external onlyOwner beforeEnd {
        addToWhitelistInternal(subscriber);
    }

    /**
     * Removed the subscriber from the whitelist.
     * @param subscriber The subscriber to remove from the whitelist.
     */
    function removeFromWhitelist(address subscriber) external onlyOwner beforeEnd {
        removeFromWhitelistInternal(subscriber, balanceOf[subscriber]);
    }

    // // fallback function can be used to buy tokens
    // function () external payable whenNotPaused {
    //     buyTokens(msg.sender);
    // }

    // No payable fallback function, the tokens must be buyed using the functions buyTokens and buyTokensFor
    function () external {
        revert("No payable fallback function");
    }

    function uint2str(uint i) internal pure returns (string memory){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    // low level token purchase function
    // function buyTokens(address beneficiary) public payable whenNotPaused {
    function releaseTokensTo(address beneficiary) internal whenNotPaused returns(bool) {
        require(beneficiary != address(0), "beneficiary is zero");
        require(isValidPurchase(beneficiary), "invalid purchase by beneficiary");

        balanceOf[beneficiary] = balanceOf[beneficiary].add(msg.value);

        raisedFunds = raisedFunds.add(msg.value);

        uint256 tokenAmount = calculateTokens(msg.value);

        soldTokens = soldTokens.add(tokenAmount);

        // revert(appendStr("releaseTokensTo", toAsciiString(beneficiary), uint2str(tokenAmount)));

        distributeTokens(beneficiary, tokenAmount);

        //distributeTokens(address(0), 1);

        emit LogTokenPurchase(msg.sender, beneficiary, msg.value, tokenAmount);

        forwardFunds(msg.value);

        return true;
    }

    /**
     * @dev Overrides Whitelistable#isAllowedBalance to add minimum deposit logic.
     */
    function isAllowedBalance(address beneficiary, uint256 balance) public view returns (bool isReallyAllowed) {
        bool hasMinimumBalance = balance >= minDeposit;
        return hasMinimumBalance && super.isAllowedBalance(beneficiary, balance);
    }

    /**
     * @dev Determine if the token purchase is valid or not.
     * @return true if the transaction can buy tokens
     */
    function isValidPurchase(address beneficiary) internal view returns (bool isValid) {
        bool withinPeriod = startBlock <= block.number && block.number <= endBlock;
        bool nonZeroPurchase = msg.value != 0;
        bool isValidBalance = isAllowedBalance(beneficiary, balanceOf[beneficiary].add(msg.value));

        return withinPeriod && nonZeroPurchase && isValidBalance;
    }

    // Calculate the token amount given the invested ether amount.
    // Override to create custom fund forwarding mechanisms
    function calculateTokens(uint256 amount) internal view returns (uint256 tokenAmount) {
        return amount.mul(rate);
    }

    /**
     * @dev Distribute the token amount to the beneficiary.
     * @notice Override to create custom distribution mechanisms
     */
    function distributeTokens(address beneficiary, uint256 tokenAmount) internal {
        token.mint(beneficiary, tokenAmount);
    }

    // Send ether amount to the fund collection wallet.
    // override to create custom fund forwarding mechanisms
    function forwardFunds(uint256 amount) internal;
}

/**
 * @title CappedCrowdsaleKYC
 * @dev Extension of Crowsdale with a max amount of funds raised
 */
contract TokenCappedCrowdsaleKYC is CrowdsaleKYC {
    using SafeMath for uint256;

    // The maximum token cap, should be initialized in derived contract
    uint256 public tokenCap;

    // Overriding Crowdsale#hasEnded to add tokenCap logic
    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        bool capReached = soldTokens >= tokenCap;
        return super.hasEnded() || capReached;
    }

    // Overriding Crowdsale#isValidPurchase to add extra cap logic
    // @return true if investors can buy at the moment
    function isValidPurchase(address beneficiary) internal view returns (bool isValid) {
        uint256 tokenAmount = calculateTokens(msg.value);
        bool withinCap = soldTokens.add(tokenAmount) <= tokenCap;
        return withinCap && super.isValidPurchase(beneficiary);
    }
}

/**
 * @title K-TuneCustomCrowdsaleKYC
 * @dev Extension of TokenCappedCrowdsaleKYC using values specific for K-Tune Custom ICO crowdsale
 */
contract KTuneCustomCrowdsaleKYC is TokenCappedCrowdsaleKYC {
    using AddressUtils for address;
    using SafeMath for uint256;

    event LogKTuneCustomCrowdsaleCreated(
        address sender,
        uint256 indexed startBlock,
        uint256 indexed endBlock,
        address indexed wallet
    );

    // The wallet address or not contract
    address public wallet;

    constructor(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rate,
        uint256 _minDeposit,
        address _token,
        uint256 _tokenMaximumSupply,
        address _wallet,
        address[] memory _kycSigner
    )
    CrowdsaleKYC(
        _startBlock,
        _endBlock,
        _rate,
        _minDeposit,
        1,
        1,
        _kycSigner
    )
    public {
        require(_token.isContract(), "_token is not contract");
        require(_tokenMaximumSupply > 0, "_tokenMaximumSupply is zero");

        token = KtuneTokenBlocks(_token);
        wallet = _wallet;

        // Assume predefined token supply has been minted and calculate the maximum number of tokens that can be sold
        // tokenCap = _tokenMaximumSupply.sub(token.totalSupply());
        tokenCap = _tokenMaximumSupply;

        emit LogKTuneCustomCrowdsaleCreated(msg.sender, startBlock, endBlock, _wallet);
    }

    function grantTokenOwnership(address _client) external onlyOwner returns(bool granted) {
        require(!_client.isContract(), "_client is contract");
        require(hasEnded(), "crowdsale not ended yet");

        // Transfer K-TuneCustomERC20 ownership back to the client
        token.transferOwnership(_client);

        return true;
    }

    /**
     * @dev Overriding Crowdsale#forwardFunds to split net/fee payment.
     */
    function forwardFunds(uint256 amount) internal {
        wallet.transfer(amount);
    }
}