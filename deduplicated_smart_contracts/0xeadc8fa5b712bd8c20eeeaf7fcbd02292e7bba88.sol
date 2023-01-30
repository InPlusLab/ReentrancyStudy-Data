/**

 *Submitted for verification at Etherscan.io on 2019-03-29

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 * Source: https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.0.0/contracts/ownership/Ownable.sol

 */

contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}



/**

 * @title Owned is extension to Ownable contact, where it allows to maintain

 * two admin addresses.

 */

contract Owned is Ownable {

    address public admin1;

    address public admin2;

    

    /**

     * Modifier to allow only Authorized (owner and admins) access.

     */

    modifier onlyAuthorized {

        require(isOwner() || isAdmin(), "Unauthorised caller");

        _;

    }



    /**

     * @dev renounceOwnership() not supported.

     */

    function renounceOwnership() public {

        revert("Not supported");

    }



    /**

     * @dev Returns true if sender is admin

     * @return bool True when admin otherwise false.

     */

    function isAdmin() internal view returns (bool) {

        return (msg.sender == admin1 || msg.sender == admin2);

    }



    /**

     * @dev To change admin1 address.

     * @param _newAdmin New admin address.

     */

    function changeAdmin1(address _newAdmin) public onlyOwner {

        //addresses are not checked agains 0x0 because owner can

        //add 0x0 as to remove admin

        if(_newAdmin != address(0)) {

            require(_newAdmin != owner() && _newAdmin != admin2);

        }

        admin1 = _newAdmin;

    }



    /**

     * @dev To change admin2 address.

     * @param _newAdmin New admin address.

     */

    function changeAdmin2(address _newAdmin) public onlyOwner {

        //addresses are not checked agains 0x0 because owner can

        //add 0x0 as to remove admin

        if(_newAdmin != address(0)) {

            require(_newAdmin != owner() && _newAdmin != admin1);

        }

        admin2 = _newAdmin;

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }

}



/**

 * @title Proxy

 * @dev Implements delegation of calls to other contracts, with proper

 * forwarding of return values and bubbling of failures.

 * It defines a fallback function that delegates all calls to the address

 * returned by the abstract _implementation() internal function.

 */

contract Proxy {

  /**

   * @dev Fallback function.

   * Implemented entirely in `_fallback`.

   */

  function () payable external {

    _fallback();

  }



  /**

   * @return The Address of the implementation.

   */

  function _implementation() internal view returns (address);



  /**

   * @dev Delegates execution to an implementation contract.

   * This is a low level function that doesn't return to its internal call site.

   * It will return to the external caller whatever the implementation returns.

   * @param implementation Address to delegate.

   */

  function _delegate(address implementation) internal {

    assembly {

      // Copy msg.data. We take full control of memory in this inline assembly

      // block because it will not return to Solidity code. We overwrite the

      // Solidity scratch pad at memory position 0.

      calldatacopy(0, 0, calldatasize)



      // Call the implementation.

      // out and outsize are 0 because we don't know the size yet.

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)



      // Copy the returned data.

      returndatacopy(0, 0, returndatasize)



      switch result

      // delegatecall returns 0 on error.

      case 0 { revert(0, returndatasize) }

      default { return(0, returndatasize) }

    }

  }



  /**

   * @dev Function that is run as the first thing in the fallback function.

   * Can be redefined in derived contracts to add functionality.

   * Redefinitions must call super._willFallback().

   */

  function _willFallback() internal {

  }



  /**

   * @dev fallback implementation.

   * Extracted to enable manual triggering.

   */

  function _fallback() internal {

    _willFallback();

    _delegate(_implementation());

  }

}



/**

 * Utility library of inline functions on addresses

 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.0.0/contracts/utils/Address.sol

 */

library Address {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   * as the code is not actually created until after the constructor finishes.

   * @param account address of the account to check

   * @return whether the target address is a contract

   */

  function isContract(address account) internal view returns (bool) {

    uint256 size;

    // XXX Currently there is no better way to check if there is a contract in an address

    // than to check the size of the code at that address.

    // See https://ethereum.stackexchange.com/a/14016/36603

    // for more details about how this works.

    // TODO Check this again before the Serenity release, because all addresses will be

    // contracts then.

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(account) }

    return size > 0;

  }



}



/**

 * @title UpgradeabilityProxy

 * @dev This contract implements a proxy that allows to change the

 * implementation address to which it will delegate.

 * Such a change is called an implementation upgrade.

 */

contract UpgradeabilityProxy is Proxy {

  /**

   * @dev Emitted when the implementation is upgraded.

   * @param implementation Address of the new implementation.

   */

  event Upgraded(address indexed implementation);



  /**

   * @dev Storage slot with the address of the current implementation.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is

   * validated in the constructor.

   */

  bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;



  /**

   * @dev Contract constructor.

   * @param _implementation Address of the initial implementation.

   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.

   * It should include the signature and the parameters of the function to be called, as described in

   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.

   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.

   */

  constructor(address _implementation, bytes _data) public payable {

    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));

    _setImplementation(_implementation);

    if(_data.length > 0) {

      require(_implementation.delegatecall(_data));

    }

  }



  /**

   * @dev Returns the current implementation.

   * @return Address of the current implementation

   */

  function _implementation() internal view returns (address impl) {

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {

      impl := sload(slot)

    }

  }



  /**

   * @dev Upgrades the proxy to a new implementation.

   * @param newImplementation Address of the new implementation.

   */

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);

    emit Upgraded(newImplementation);

  }



  /**

   * @dev Sets the implementation address of the proxy.

   * @param newImplementation Address of the new implementation.

   */

  function _setImplementation(address newImplementation) private {

    require(Address.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");



    bytes32 slot = IMPLEMENTATION_SLOT;



    assembly {

      sstore(slot, newImplementation)

    }

  }

}



/**

 * @title AdminUpgradeabilityProxy

 * @dev This contract combines an upgradeability proxy with an authorization

 * mechanism for administrative tasks.

 * All external functions in this contract must be guarded by the

 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity

 * feature proposal that would enable this to be done automatically.

 */

contract AdminUpgradeabilityProxy is UpgradeabilityProxy {

  /**

   * @dev Emitted when the administration has been transferred.

   * @param previousAdmin Address of the previous admin.

   * @param newAdmin Address of the new admin.

   */

  event AdminChanged(address previousAdmin, address newAdmin);



  /**

   * @dev Storage slot with the admin of the contract.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is

   * validated in the constructor.

   */

  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;



  /**

   * @dev Modifier to check whether the `msg.sender` is the admin.

   * If it is, it will run the function. Otherwise, it will delegate the call

   * to the implementation.

   */

  modifier ifAdmin() {

    if (msg.sender == _admin()) {

      _;

    } else {

      _fallback();

    }

  }



  /**

   * Contract constructor.

   * @param _implementation address of the initial implementation.

   * @param _admin Address of the proxy administrator.

   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.

   * It should include the signature and the parameters of the function to be called, as described in

   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.

   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.

   */

  constructor(address _implementation, address _admin, bytes _data) UpgradeabilityProxy(_implementation, _data) public payable {

    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));



    _setAdmin(_admin);

  }



  /**

   * @return The address of the proxy admin.

   */

  function admin() external view ifAdmin returns (address) {

    return _admin();

  }



  /**

   * @return The address of the implementation.

   */

  function implementation() external view ifAdmin returns (address) {

    return _implementation();

  }



  /**

   * @dev Changes the admin of the proxy.

   * Only the current admin can call this function.

   * @param newAdmin Address to transfer proxy administration to.

   */

  function changeAdmin(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");

    emit AdminChanged(_admin(), newAdmin);

    _setAdmin(newAdmin);

  }



  /**

   * @dev Upgrade the backing implementation of the proxy.

   * Only the admin can call this function.

   * @param newImplementation Address of the new implementation.

   */

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);

  }



  /**

   * @dev Upgrade the backing implementation of the proxy and call a function

   * on the new implementation.

   * This is useful to initialize the proxied contract.

   * @param newImplementation Address of the new implementation.

   * @param data Data to send as msg.data in the low level call.

   * It should include the signature and the parameters of the function to be called, as described in

   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.

   */

  function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {

    _upgradeTo(newImplementation);

    require(newImplementation.delegatecall(data));

  }



  /**

   * @return The admin slot.

   */

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;

    assembly {

      adm := sload(slot)

    }

  }



  /**

   * @dev Sets the address of the proxy admin.

   * @param newAdmin Address of the new proxy admin.

   */

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = ADMIN_SLOT;



    assembly {

      sstore(slot, newAdmin)

    }

  }



  /**

   * @dev Only fall back when the sender is not the admin.

   */

  function _willFallback() internal {

    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");

    super._willFallback();

  }

}



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

    * @return An uint256 representing the amount owned by the passed address.

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

    * @dev Transfer token for a specified address

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

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

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

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

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

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

        emit Approval(account, msg.sender, _allowed[account][msg.sender]);

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

  function pause() public onlyOwner whenNotPaused {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    paused = false;

    emit Unpause();

  }

}



/**

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 **/

contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);

    }



    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);

    }



    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);

    }



    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);

    }

}



/**

 * @title EUSD Token contract.

 * @dev This contract is only deployed and used as implementation for

 * AdminUpgradeabilityProxy contract. This contract will not hold any funds.

 */

contract EUSD_v1 is Owned, ERC20Pausable {



    using SafeMath for uint;



    //ERC20 token variables

    string public name;

    string public symbol;

    uint8 public decimals;



    struct MintHold {

        address user;

        uint tokenAmount;

        uint releaseTimeStamp;

    }



    MintHold[] public mintHoldArray;

    bool internal initialized = false;

    mapping (address => bool) public frozenAccount;



    //Events

    event AccountFrozen(address indexed account);

    event AccountUnfrozen(address indexed account);



    constructor() public {

        initialize();

        pause();

    }



    /**

     * @dev Transfer allowed only when not Paused and `to`

     * and accounts are not frozen.

     * @param _to Account to transfer token from msg.sender.

     * @param _value Number of tokens to transfer.

     * @return bool Returns the transaction status.

     */

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(

            ! frozenAccount[msg.sender] &&

            ! frozenAccount[_to],

            "address frozen"

        );



        super.transfer(_to, _value);

    }



    /**

     * @dev Transfer from allowed only when not Paused and `from`

     * `to` and `msg.sender` are not frozen.

     * @param _from Account from tokens to be taken.

     * @param _to Account to send the tokens.

     * @param _value Number of tokens.

     * @return bool Returns the transaction status.

     */

    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

        public returns (bool)

    {

        require(

            ! frozenAccount[msg.sender] &&

            ! frozenAccount[_from] &&

            ! frozenAccount[_to],

            "address frozen"

        );



        super.transferFrom(_from, _to, _value);

    }



    /**

     * @dev Freeze an account from sending & receiving tokens.

     * @param _account Account to freeze.

     */

    function freezeAccount(address _account) public onlyAuthorized {

        require(! frozenAccount[_account], "address already frozen");

        frozenAccount[_account] = true;

        emit AccountFrozen(_account);

    }



    /**

     * @dev UnFreeze an account for sending & receiving tokens

     * @param _account Account to Unfreeze.

     */

    function unFreezeAccount(address _account) public onlyAuthorized {

        require(frozenAccount[_account], "address already unfrozen");

        frozenAccount[_account] = false;

        emit AccountUnfrozen(_account);

    }



    /**

     * @dev Mint the number of tokens to the given account.

     * The Owner can mint instantly, however, Admin's mint request will

     * be on hold for 12 hours.

     * Only Owner and Admin allowed to call this function.

     * @param _to Mint and send the tokens to this address.

     * @param _amount Number of tokens to mint.

     * @return bool Return the transaction status.

     */

    function mint(address _to, uint256 _amount)

        public

        onlyAuthorized

        whenNotPaused

        returns (bool)

    {

        require(! frozenAccount[_to], "address frozen");

        require(_amount > 0);



        if(isOwner()) {

            _mint(_to, _amount);

        } else if(isAdmin()) {

            mintHoldArray.push(MintHold(_to, _amount, now.add(12 hours)));

        }



        return true;

    }



    /**

     * @dev Release the hold mint request present at index.

     * @param _index Index of the request to process

     * @return bool Returns transaction status.

     */

    function releaseMintAtIndex(uint _index)

        public

        onlyAuthorized

        whenNotPaused

        returns (bool)

    {

        _mintAndRemoveFromMintHold(_index);

        return true;

    }



    /**

     * @dev Release the hold mint tokens.

     * Only Owner and Admins allowed to call this function.

     * @param _operations Number of hold mint requests to process

     * @return bool Returns transaction status

     */

    function releaseMint(uint _operations)

        public

        onlyAuthorized

        whenNotPaused

        returns (bool)

    {

        require(_operations <= mintHoldArray.length);

        for(uint i = 0; i < _operations; i++) {

            _mintAndRemoveFromMintHold(i);

        }



        return true;

    }



    /**

     * @dev Mint and remove from the mintHoldArray.

     * @param _index Index of the hold request to process.

     */

    function _mintAndRemoveFromMintHold(uint _index) private {

        require(_index < mintHoldArray.length);

        if(

            mintHoldArray[_index].releaseTimeStamp < now &&

            ! frozenAccount[mintHoldArray[_index].user]

        ) {

            _mint(mintHoldArray[_index].user, mintHoldArray[_index].tokenAmount);

            _removeFromMintHold(_index);

        }

    }



    /**

     * @dev Remove the given index item from mintHoldArray

     * @param _index Index of the item to be removed

     */

    function _removeFromMintHold(uint _index) private {

        require(_index < mintHoldArray.length);

        mintHoldArray[_index] = mintHoldArray[mintHoldArray.length.sub(1)];

        mintHoldArray.length--;

    }



    /**

     * @dev To cancel existing hold mint request.

     * @param _index Index of the request to be cancelled.

     * @return bool Returns the transaction status.

     */

    function cancelHoldMint(uint _index) public onlyOwner returns(bool) {

        _removeFromMintHold(_index);

        return true;

    }



    /**

     * @dev Reclaiming tokens from any users.

     * This is for government regulation purpose.

     * @param _user User from which tokens to be reclaimed.

     * @param _tokens Number of tokens to reclaim.

     * @return bool Returns transaction status

     */

    function reclaimTokens(

        address _user,

        uint _tokens

    ) public onlyAuthorized whenNotPaused returns(bool) {

        require(_user != address(0), "Invalid address");

        _transfer(_user, owner(), _tokens);

        return true;

    }



    /**

     * @dev Burn tokens from any user's wallet.

     * Only owner allowed to burn.

     * @param _from Users's address whose tokens to be burned.

     * @param _value Number of tokens to be burned.

     */

    function burnFrom(address _from, uint _value) public onlyOwner {

        _burn(_from, _value);

    }



    /**

     * @dev Returns the number of mint hold transactions present.

     * @return uint Number of transaction.

     */

    function totalMintHoldTransactions() public view returns(uint) {

        return mintHoldArray.length;

    }



    /**

     * @dev only called from EUSD implementation.

     */

    function initialize() private {

        initialize("EstateUSD", "EUSD", 18, owner(), owner(), owner());

    }



    /**

     * @dev Initialize the contract once with the given parameters.

     * This is to initialize in the Proxy.

     */

    function initialize(

        string memory _name,

        string memory _symbol,

        uint8 _decimals,

        address _owner,

        address _admin1,

        address _admin2

    ) public {

        require(!initialized);

        require(_owner != address(0));



        name = _name;

        symbol = _symbol;

        decimals = _decimals;

        _transferOwnership(_owner);

        admin1 = _admin1;

        admin2 = _admin2;

        initialized = true;

    }

}