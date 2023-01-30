/**

 *Submitted for verification at Etherscan.io on 2019-03-02

*/



pragma solidity 0.5.4;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

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

    function isOwner() public view returns (bool) {

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



// File: contracts/lib/StaticCaller.sol



/*



  << Static Caller >>



*/



pragma solidity 0.5.4;



/**

 * @title StaticCaller

 * @author Wyvern Protocol Developers

 */

contract StaticCaller {



    function staticCall(address target, bytes memory data)

        internal

        view

        returns (bool result)

    {

        assembly {

            result := staticcall(gas, target, add(data, 0x20), mload(data), mload(0x40), 0)

        }

        return result;

    }



    function staticCallUint(address target, bytes memory data)

        internal

        view

        returns (uint ret)

    {

        bool result;

        assembly {

            let size := 0x20

            let free := mload(0x40)

            result := staticcall(gas, target, add(data, 0x20), mload(data), free, size)

            ret := mload(free)

        }

        require(result, "Static call failed");

        return ret;

    }



}



// File: contracts/lib/ReentrancyGuarded.sol



/*



  Simple contract extension to provide a contract-global reentrancy guard on functions.



*/



pragma solidity 0.5.4;



/**

 * @title ReentrancyGuarded

 * @author Wyvern Protocol Developers

 */

contract ReentrancyGuarded {



    bool reentrancyLock = false;



    /* Prevent a contract function from being reentrant-called. */

    modifier reentrancyGuard {

        require(!reentrancyLock, "Reentrancy detected");

        reentrancyLock = true;

        _;

        reentrancyLock = false;

    }



}



// File: contracts/lib/EIP712.sol



/*



  << EIP 712 >>



*/



pragma solidity 0.5.4;



/**

 * @title EIP712

 * @author Wyvern Protocol Developers

 */

contract EIP712 {



    struct EIP712Domain {

        string  name;

        string  version;

        uint256 chainId;

        address verifyingContract;

    }



    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(

        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"

    );



    bytes32 DOMAIN_SEPARATOR;



    function hash(EIP712Domain memory eip712Domain)

        internal

        pure

        returns (bytes32)

    {

        return keccak256(abi.encode(

            EIP712DOMAIN_TYPEHASH,

            keccak256(bytes(eip712Domain.name)),

            keccak256(bytes(eip712Domain.version)),

            eip712Domain.chainId,

            eip712Domain.verifyingContract

        ));

    }



}



// File: contracts/registry/proxy/Proxy.sol



/**

 * @title Proxy

 * @dev Gives the possibility to delegate any call to a foreign implementation.

 */

contract Proxy {



    /**

     * @dev Tells the address of the implementation where every call will be delegated.

     * @return address of the implementation to which it will be delegated

     */

    function implementation() public view returns (address);



    /**

     * @dev Tells the type of proxy (EIP 897)

     * @return Type of proxy, 2 for upgradeable proxy

     */

    function proxyType() public pure returns (uint256 proxyTypeId);



    /**

     * @dev Fallback function allowing to perform a delegatecall to the given implementation.

     * This function will return whatever the implementation call returns

     */

    function () payable external {

        address _impl = implementation();

        require(_impl != address(0), "Proxy implementation required");



        assembly {

            let ptr := mload(0x40)

            calldatacopy(ptr, 0, calldatasize)

            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)

            let size := returndatasize

            returndatacopy(ptr, 0, size)



            switch result

            case 0 { revert(ptr, size) }

            default { return(ptr, size) }

        }

    }

}



// File: contracts/registry/proxy/OwnedUpgradeabilityStorage.sol



/**

 * @title OwnedUpgradeabilityStorage

 * @dev This contract keeps track of the upgradeability owner

 */

contract OwnedUpgradeabilityStorage {



    // Current implementation

    address internal _implementation;



    // Owner of the contract

    address private _upgradeabilityOwner;



    /**

     * @dev Tells the address of the owner

     * @return the address of the owner

     */

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;

    }



    /**

     * @dev Sets the address of the owner

     */

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;

    }



    /**

     * @dev Tells the address of the current implementation

     * @return address of the current implementation

     */

    function implementation() public view returns (address) {

        return _implementation;

    }



    /**

     * @dev Tells the proxy type (EIP 897)

     * @return Proxy type, 2 for forwarding proxy

     */

    function proxyType() public pure returns (uint256 proxyTypeId) {

        return 2;

    }



}



// File: contracts/registry/proxy/OwnedUpgradeabilityProxy.sol



/**

 * @title OwnedUpgradeabilityProxy

 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities

 */

contract OwnedUpgradeabilityProxy is Proxy, OwnedUpgradeabilityStorage {

    /**

     * @dev Event to show ownership has been transferred

     * @param previousOwner representing the address of the previous owner

     * @param newOwner representing the address of the new owner

     */

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);



    /**

     * @dev This event will be emitted every time the implementation gets upgraded

     * @param implementation representing the address of the upgraded implementation

     */

    event Upgraded(address indexed implementation);



    /**

     * @dev Upgrades the implementation address

     * @param implementation representing the address of the new implementation to be set

     */

    function _upgradeTo(address implementation) internal {

        require(_implementation != implementation, "Proxy already uses this implementation");

        _implementation = implementation;

        emit Upgraded(implementation);

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner(), "Only the proxy owner can call this method");

        _;

    }



    /**

     * @dev Tells the address of the proxy owner

     * @return the address of the proxy owner

     */

    function proxyOwner() public view returns (address) {

        return upgradeabilityOwner();

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {

        require(newOwner != address(0), "New owner cannot be the null address");

        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);

        setUpgradeabilityOwner(newOwner);

    }



    /**

     * @dev Allows the upgradeability owner to upgrade the current implementation of the proxy.

     * @param implementation representing the address of the new implementation to be set.

     */

    function upgradeTo(address implementation) public onlyProxyOwner {

        _upgradeTo(implementation);

    }



    /**

     * @dev Allows the upgradeability owner to upgrade the current implementation of the proxy

     * and delegatecall the new implementation for initialization.

     * @param implementation representing the address of the new implementation to be set.

     * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function

     * signature of the implementation to be called with the needed payload

     */

    function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {

        upgradeTo(implementation);

        (bool success,) = address(this).delegatecall(data);

        require(success, "Call failed after proxy upgrade");

    }

}



// File: contracts/registry/OwnableDelegateProxy.sol



/*



  OwnableDelegateProxy



*/



pragma solidity 0.5.4;





/**

 * @title OwnableDelegateProxy

 * @author Wyvern Protocol Developers

 */

contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {



    constructor(address owner, address initialImplementation, bytes memory data)

        public

    {

        setUpgradeabilityOwner(owner);

        _upgradeTo(initialImplementation);

        (bool success,) = initialImplementation.delegatecall(data);

        require(success, "OwnableDelegateProxy failed implementation");

    }



}



// File: contracts/registry/ProxyRegistryInterface.sol



/*



  Proxy registry interface.



*/



pragma solidity 0.5.4;





/**

 * @title ProxyRegistryInterface

 * @author Wyvern Protocol Developers

 */

interface ProxyRegistryInterface {



    function delegateProxyImplementation() external returns (address);



    function proxies(address owner) external returns (OwnableDelegateProxy);



}



// File: contracts/registry/ProxyRegistry.sol



/*



  Proxy registry; keeps a mapping of AuthenticatedProxy contracts and mapping of contracts authorized to access them.  

  

  Abstracted away from the Exchange (a) to reduce Exchange attack surface and (b) so that the Exchange contract can be upgraded without users needing to transfer assets to new proxies.



*/



pragma solidity 0.5.4;









/**

 * @title ProxyRegistry

 * @author Wyvern Protocol Developers

 */

contract ProxyRegistry is Ownable, ProxyRegistryInterface {



    /* DelegateProxy implementation contract. Must be initialized. */

    address public delegateProxyImplementation;



    /* Authenticated proxies by user. */

    mapping(address => OwnableDelegateProxy) public proxies;



    /* Contracts pending access. */

    mapping(address => uint) public pending;



    /* Contracts allowed to call those proxies. */

    mapping(address => bool) public contracts;



    /* Delay period for adding an authenticated contract.

       This mitigates a particular class of potential attack on the Wyvern DAO (which owns this registry) - if at any point the value of assets held by proxy contracts exceeded the value of half the WYV supply (votes in the DAO),

       a malicious but rational attacker could buy half the Wyvern and grant themselves access to all the proxy contracts. A delay period renders this attack nonthreatening - given two weeks, if that happened, users would have

       plenty of time to notice and transfer their assets.

    */

    uint public DELAY_PERIOD = 2 weeks;



    /**

     * Start the process to enable access for specified contract. Subject to delay period.

     *

     * @dev ProxyRegistry owner only

     * @param addr Address to which to grant permissions

     */

    function startGrantAuthentication (address addr)

        public

        onlyOwner

    {

        require(!contracts[addr] && pending[addr] == 0, "Contract is already allowed in registry, or pending");

        pending[addr] = now;

    }



    /**

     * End the process to enable access for specified contract after delay period has passed.

     *

     * @dev ProxyRegistry owner only

     * @param addr Address to which to grant permissions

     */

    function endGrantAuthentication (address addr)

        public

        onlyOwner

    {

        require(!contracts[addr] && pending[addr] != 0 && ((pending[addr] + DELAY_PERIOD) < now), "Contract is no longer pending or has already been approved by registry");

        pending[addr] = 0;

        contracts[addr] = true;

    }



    /**

     * Revoke access for specified contract. Can be done instantly.

     *

     * @dev ProxyRegistry owner only

     * @param addr Address of which to revoke permissions

     */    

    function revokeAuthentication (address addr)

        public

        onlyOwner

    {

        contracts[addr] = false;

    }



    /**

     * Register a proxy contract with this registry

     *

     * @dev Must be called by the user which the proxy is for, creates a new AuthenticatedProxy

     * @return New AuthenticatedProxy contract

     */

    function registerProxy()

        public

        returns (OwnableDelegateProxy proxy)

    {

        return registerProxyFor(msg.sender);

    }



    /**

     * Register a proxy contract with this registry, overriding any existing proxy

     *

     * @dev Must be called by the user which the proxy is for, creates a new AuthenticatedProxy

     * @return New AuthenticatedProxy contract

     */

    function registerProxyOverride()

        public

        returns (OwnableDelegateProxy proxy)

    {

        proxy = new OwnableDelegateProxy(msg.sender, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", msg.sender, address(this)));

        proxies[msg.sender] = proxy;

        return proxy;

    }



    /**

     * Register a proxy contract with this registry

     *

     * @dev Can be called by any user

     * @return New AuthenticatedProxy contract

     */

    function registerProxyFor(address user)

        public

        returns (OwnableDelegateProxy proxy)

    {

        require(proxies[user] == OwnableDelegateProxy(0), "User already has a proxy");

        proxy = new OwnableDelegateProxy(user, delegateProxyImplementation, abi.encodeWithSignature("initialize(address,address)", user, address(this)));

        proxies[user] = proxy;

        return proxy;

    }



    /**

     * Transfer access

     */

    function transferAccessTo(address from, address to)

        public

    {

        OwnableDelegateProxy proxy = proxies[from];



        /* CHECKS */

        require(OwnableDelegateProxy(msg.sender) == proxy, "Proxy transfer can only be called by the proxy");

        require(proxies[to] == OwnableDelegateProxy(0), "Proxy transfer has existing proxy as destination");



        /* EFFECTS */

        delete proxies[from];

        proxies[to] = proxy;

    }



}



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



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



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



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



// File: contracts/registry/TokenRecipient.sol



/*



  Token recipient. Modified very slightly from the example on http://ethereum.org/dao (just to index log parameters).



*/



pragma solidity 0.5.4;





/**

 * @title TokenRecipient

 * @author Wyvern Protocol Developers

 */

contract TokenRecipient {

    event ReceivedEther(address indexed sender, uint amount);

    event ReceivedTokens(address indexed from, uint256 value, address indexed token, bytes extraData);



    /**

     * @dev Receive tokens and generate a log event

     * @param from Address from which to transfer tokens

     * @param value Amount of tokens to transfer

     * @param token Address of token

     * @param extraData Additional data to log

     */

    function receiveApproval(address from, uint256 value, address token, bytes memory extraData) public {

        ERC20 t = ERC20(token);

        require(t.transferFrom(from, address(this), value), "ERC20 token transfer failed");

        emit ReceivedTokens(from, value, token, extraData);

    }



    /**

     * @dev Receive Ether and generate a log event

     */

    function () payable external {

        emit ReceivedEther(msg.sender, msg.value);

    }

}



// File: contracts/registry/AuthenticatedProxy.sol



/* 



  Proxy contract to hold access to assets on behalf of a user (e.g. ERC20 approve) and execute calls under particular conditions.



*/



pragma solidity 0.5.4;









/**

 * @title AuthenticatedProxy

 * @author Wyvern Protocol Developers

 */

contract AuthenticatedProxy is TokenRecipient, OwnedUpgradeabilityStorage {



    /* Whether initialized. */

    bool initialized = false;



    /* Address which owns this proxy. */

    address public user;



    /* Associated registry with contract authentication information. */

    ProxyRegistry public registry;



    /* Whether access has been revoked. */

    bool public revoked;



    /* Delegate call could be used to atomically transfer multiple assets owned by the proxy contract with one order. */

    enum HowToCall { Call, DelegateCall }



    /* Event fired when the proxy access is revoked or unrevoked. */

    event Revoked(bool revoked);



    /**

     * Initialize an AuthenticatedProxy

     *

     * @param addrUser Address of user on whose behalf this proxy will act

     * @param addrRegistry Address of ProxyRegistry contract which will manage this proxy

     */

    function initialize (address addrUser, ProxyRegistry addrRegistry)

        public

    {

        require(!initialized, "Authenticated proxy already initialized");

        initialized = true;

        user = addrUser;

        registry = addrRegistry;

    }



    /**

     * Set the revoked flag (allows a user to revoke ProxyRegistry access)

     *

     * @dev Can be called by the user only

     * @param revoke Whether or not to revoke access

     */

    function setRevoke(bool revoke)

        public

    {

        require(msg.sender == user, "Authenticated proxy can only be revoked by its user");

        revoked = revoke;

        emit Revoked(revoke);

    }



    /**

     * Execute a message call from the proxy contract

     *

     * @dev Can be called by the user, or by a contract authorized by the registry as long as the user has not revoked access

     * @param dest Address to which the call will be sent

     * @param howToCall Which kind of call to make

     * @param data Calldata to send

     * @return Result of the call (success or failure)

     */

    function proxy(address dest, HowToCall howToCall, bytes memory data)

        public

        returns (bool result)

    {

        require(msg.sender == user || (!revoked && registry.contracts(msg.sender)), "Authenticated proxy can only be called by its user, or by a contract authorized by the registry as long as the user has not revoked access");

        bytes memory ret;

        if (howToCall == HowToCall.Call) {

            (result, ret) = dest.call(data);

        } else if (howToCall == HowToCall.DelegateCall) {

            (result, ret) = dest.delegatecall(data);

        }

        return result;

    }



    /**

     * Execute a message call and assert success

     * 

     * @dev Same functionality as `proxy`, just asserts the return value

     * @param dest Address to which the call will be sent

     * @param howToCall What kind of call to make

     * @param data Calldata to send

     */

    function proxyAssert(address dest, HowToCall howToCall, bytes memory data)

        public

    {

        require(proxy(dest, howToCall, data), "Proxy assertion failed");

    }



}



// File: contracts/exchange/ExchangeCore.sol



/*



  << Exchange Core >>



*/



pragma solidity 0.5.4;















/**

 * @title ExchangeCore

 * @author Wyvern Protocol Developers

 */

contract ExchangeCore is ReentrancyGuarded, StaticCaller, EIP712 {



    /* Struct definitions. */



    /* A signature, convenience struct. */

    struct Sig {

        /* v parameter */

        uint8 v;

        /* r parameter */

        bytes32 r;

        /* s parameter */

        bytes32 s;

    }



    /* An order, convenience struct. */

    struct Order {

        /* Order maker address. */

        address maker;

        /* Order static target. */

        address staticTarget;

        /* Order static selector. */

        bytes4 staticSelector;

        /* Order static extradata. */

        bytes staticExtradata;

        /* Order maximum fill factor. */

        uint maximumFill;

        /* Order listing timestamp. */

        uint listingTime;

        /* Order expiration timestamp - 0 for no expiry. */

        uint expirationTime;

        /* Order salt to prevent duplicate hashes. */

        uint salt;

    }



    /* A call, convenience struct. */

    struct Call {

        /* Target */

        address target;

        /* How to call */

        AuthenticatedProxy.HowToCall howToCall;

        /* Calldata */

        bytes data;

    }



    /* Constants */



    /* Order typehash for EIP 712 compatibility. */

    bytes32 constant ORDER_TYPEHASH = keccak256(

        "Order(address maker,address staticTarget,bytes4 staticSelector,bytes staticExtradata,uint256 maximumFill,uint256 listingTime,uint256 expirationTime,uint256 salt)"

    );



    /* Variables */



    /* Trusted proxy registry contract. */

    ProxyRegistryInterface public registry;



    /* Order fill status, by maker address then by hash. */

    mapping(address => mapping(bytes32 => uint)) public fills;



    /* Orders verified by on-chain approval.

       Alternative to ECDSA signatures so that smart contracts can place orders directly.

       By maker address, then by hash. */

    mapping(address => mapping(bytes32 => bool)) public approved;



    /* Events */



    event OrderApproved     (bytes32 indexed hash, address indexed maker, address staticTarget, bytes4 staticSelector, bytes staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired);

    event OrderFillChanged  (bytes32 indexed hash, address indexed maker, uint newFill);

    event OrdersMatched     (bytes32 firstHash, bytes32 secondHash, address indexed firstMaker, address indexed secondMaker, uint newFirstFill, uint newSecondFill, bytes32 indexed metadata);



    /* Functions */



    function hashOrder(Order memory order)

        internal

        pure

        returns (bytes32 hash)

    {

        /* Per EIP 712. */

        return keccak256(abi.encode(

            ORDER_TYPEHASH,

            order.maker,

            order.staticTarget,

            order.staticSelector,

            keccak256(order.staticExtradata),

            order.maximumFill,

            order.listingTime,

            order.expirationTime,

            order.salt

        ));

    }



    function hashToSign(bytes32 orderHash)

        internal

        view

        returns (bytes32 hash)

    {

        /* Calculate the string a user must sign. */

        return keccak256(abi.encodePacked(

            "\x19\x01",

            DOMAIN_SEPARATOR,

            orderHash

        ));

    }



    function exists(address what)

        internal

        view

        returns (bool)

    {

        uint size;

        assembly {

            size := extcodesize(what)

        }

        return size > 0;

    }



    function validateOrderParameters(Order memory order, bytes32 hash)

        internal

        view

        returns (bool)

    {

        /* Order must be listed and not be expired. */

        if (order.listingTime > block.timestamp || order.expirationTime <= block.timestamp) {

            return false;

        }



        /* Order must not have already been completely filled. */

        if (fills[order.maker][hash] >= order.maximumFill) {

            return false;

        }



        /* Order static target must exist. */

        if (!exists(order.staticTarget)) {

            return false;

        }



        return true;

    }



    function validateOrderAuthorization(bytes32 hash, address maker, Sig memory sig)

        internal

        view

        returns (bool)

    {

        /* Memoized authentication. If order has already been partially filled, order must be authenticated. */

        if (fills[maker][hash] > 0) {

            return true;

        }



        /* Order authentication. Order must be either: */



        /* (a): sent by maker */

        if (maker == msg.sender) {

            return true;

        }



        /* (b): previously approved */

        if (approved[maker][hash]) {

            return true;

        }

    

        /* (c): ECDSA-signed by maker. */

        if (ecrecover(hashToSign(hash), sig.v, sig.r, sig.s) == maker) {

            return true;

        }



        return false;

    }



    function encodeStaticCall(Order memory order, Call memory call, Order memory counterorder, Call memory countercall, address matcher, uint value, uint fill)

        internal

        pure

        returns (bytes memory)

    {

        /* This array wrapping is necessary to preserve static call target function stack space. */

        address[5] memory addresses = [order.maker, call.target, counterorder.maker, countercall.target, matcher];

        AuthenticatedProxy.HowToCall[2] memory howToCalls = [call.howToCall, countercall.howToCall];

        uint[6] memory uints = [value, order.maximumFill, order.listingTime, order.expirationTime, counterorder.listingTime, fill];

        return abi.encodeWithSelector(order.staticSelector, order.staticExtradata, addresses, howToCalls, uints, call.data, countercall.data);

    }



    function executeStaticCall(Order memory order, Call memory call, Order memory counterorder, Call memory countercall, address matcher, uint value, uint fill)

        internal

        view

        returns (uint)

    {

        return staticCallUint(order.staticTarget, encodeStaticCall(order, call, counterorder, countercall, matcher, value, fill));

    }



    function executeCall(address maker, Call memory call)

        internal

        returns (bool)

    {

        /* Assert target exists. */

        require(exists(call.target), "Call target does not exist");



        /* Retrieve delegate proxy contract. */

        OwnableDelegateProxy delegateProxy = registry.proxies(maker);



        /* Assert existence. */

        require(delegateProxy != OwnableDelegateProxy(0), "Delegate proxy does not exist for maker");



        /* Assert implementation. */

        require(delegateProxy.implementation() == registry.delegateProxyImplementation(), "Incorrect delegate proxy implementation for maker");

      

        /* Typecast. */

        AuthenticatedProxy proxy = AuthenticatedProxy(address(delegateProxy));

  

        /* Execute order. */

        return proxy.proxy(call.target, call.howToCall, call.data);

    }



    function approveOrderHash(bytes32 hash)

        internal

    {

        /* CHECKS */



        /* Assert order has not already been approved. */

        require(!approved[msg.sender][hash], "Order has already been approved");



        /* EFFECTS */



        /* Mark order as approved. */

        approved[msg.sender][hash] = true;

    }



    function approveOrder(Order memory order, bool orderbookInclusionDesired)

        internal

    {

        /* CHECKS */



        /* Assert sender is authorized to approve order. */

        require(order.maker == msg.sender, "Sender is not the maker of the order and thus not authorized to approve it");



        /* Calculate order hash. */

        bytes32 hash = hashOrder(order);



        /* Approve order hash. */

        approveOrderHash(hash);



        /* Log approval event. */

        emit OrderApproved(hash, order.maker, order.staticTarget, order.staticSelector, order.staticExtradata, order.maximumFill, order.listingTime, order.expirationTime, order.salt, orderbookInclusionDesired);

    }



    function setOrderFill(bytes32 hash, uint fill)

        internal

    {

        /* CHECKS */



        /* Assert fill is not already set. */

        require(fills[msg.sender][hash] != fill, "Fill is already set to the desired value");



        /* EFFECTS */



        /* Mark order as accordingly filled. */

        fills[msg.sender][hash] = fill;



        /* Log order fill change event. */

        emit OrderFillChanged(hash, msg.sender, fill);

    }



    function atomicMatch(Order memory firstOrder, Sig memory firstSig, Call memory firstCall, Order memory secondOrder, Sig memory secondSig, Call memory secondCall, bytes32 metadata)

        internal

        reentrancyGuard

    {

        /* CHECKS */



        /* Calculate first order hash. */

        bytes32 firstHash = hashOrder(firstOrder);



        /* Check first order validity. */

        require(validateOrderParameters(firstOrder, firstHash), "First order has invalid parameters");



        /* Check first order authorization. */

        require(validateOrderAuthorization(firstHash, firstOrder.maker, firstSig), "First order failed authorization");



        /* Calculate second order hash. */

        bytes32 secondHash = hashOrder(secondOrder);



        /* Check second order validity. */

        require(validateOrderParameters(secondOrder, secondHash), "Second order has invalid parameters");



        /* Check second order authorization. */

        require(validateOrderAuthorization(secondHash, secondOrder.maker, secondSig), "Second order failed authorization");



        /* Prevent self-matching (possibly unnecessary, but safer). */

        require(firstHash != secondHash, "Self-matching orders is prohibited");



        /* INTERACTIONS */



        /* Transfer any msg.value.

           This is the first "asymmetric" part of order matching: if an order requires Ether, it must be the first order. */

        if (msg.value > 0) {

            address(uint160(firstOrder.maker)).transfer(msg.value);

        }



        /* Execute first call, assert success.

           This is the second "asymmetric" part of order matching: execution of the second order can depend on state changes in the first order, but not vice-versa. */

        assert(executeCall(firstOrder.maker, firstCall));



        /* Execute second call, assert success. */

        assert(executeCall(secondOrder.maker, secondCall));



        /* Static calls must happen after the effectful calls so that they can check the resulting state. */



        /* Fetch previous first order fill. */

        uint previousFirstFill = fills[firstOrder.maker][firstHash];



        /* Fetch previous second order fill. */

        uint previousSecondFill = fills[secondOrder.maker][secondHash];



        /* Execute first order static call, assert success, capture returned new fill. */

        uint firstFill = executeStaticCall(firstOrder, firstCall, secondOrder, secondCall, msg.sender, msg.value, previousFirstFill);



        /* Execute second order static call, assert success, capture returned new fill. */

        uint secondFill = executeStaticCall(secondOrder, secondCall, firstOrder, firstCall, msg.sender, uint(0), previousSecondFill);



        /* EFFECTS */



        /* Update first order fill, if necessary. */

        if (firstOrder.maker != msg.sender) {

            if (firstFill != previousFirstFill) {

                fills[firstOrder.maker][firstHash] = firstFill;

            }

        }



        /* Update second order fill, if necessary. */

        if (secondOrder.maker != msg.sender) {

            if (secondFill != previousSecondFill) {

                fills[secondOrder.maker][secondHash] = secondFill;

            }

        }



        /* LOGS */



        /* Log match event. */

        emit OrdersMatched(firstHash, secondHash, firstOrder.maker, secondOrder.maker, firstFill, secondFill, metadata);

    }



}



// File: contracts/exchange/Exchange.sol



/*



  << Exchange >>



*/



pragma solidity 0.5.4;





/**

 * @title Exchange

 * @author Wyvern Protocol Developers

 */

contract Exchange is ExchangeCore {



    /* Public ABI-encodable method wrappers. */



    function hashOrder_(address maker, address staticTarget, bytes4 staticSelector, bytes memory staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt)

        public

        pure

        returns (bytes32 hash)

    {

        return hashOrder(Order(maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt));

    }



    function hashToSign_(bytes32 orderHash)

        external

        view

        returns (bytes32 hash)

    {

        return hashToSign(orderHash);

    }



    function validateOrderParameters_(address maker, address staticTarget, bytes4 staticSelector, bytes memory staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt)

        public

        view

        returns (bool)

    {

        Order memory order = Order(maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt);

        return validateOrderParameters(order, hashOrder(order));

    }



    function validateOrderAuthorization_(bytes32 hash, address maker, uint8 v, bytes32 r, bytes32 s)

        external

        view

        returns (bool)

    {

        return validateOrderAuthorization(hash, maker, Sig(v, r, s));

    }



    function approveOrderHash_(bytes32 hash)

        external

    {

        return approveOrderHash(hash);

    }



    function approveOrder_(address maker, address staticTarget, bytes4 staticSelector, bytes memory staticExtradata, uint maximumFill, uint listingTime, uint expirationTime, uint salt, bool orderbookInclusionDesired)

        public

    {

        return approveOrder(Order(maker, staticTarget, staticSelector, staticExtradata, maximumFill, listingTime, expirationTime, salt), orderbookInclusionDesired);

    }



    function setOrderFill_(bytes32 hash, uint fill)

        external

    {

        return setOrderFill(hash, fill);

    }



    function atomicMatch_(uint[14] memory uints, bytes4[2] memory staticSelectors,

        bytes memory firstExtradata, bytes memory firstCalldata, bytes memory secondExtradata, bytes memory secondCalldata,

        uint8[4] memory howToCallsVs, bytes32[5] memory rssMetadata)

        public

        payable

    {

        return atomicMatch(

            Order(address(uints[0]), address(uints[1]), staticSelectors[0], firstExtradata, uints[2], uints[3], uints[4], uints[5]),

            Sig(howToCallsVs[0], rssMetadata[0], rssMetadata[1]),

            Call(address(uints[6]), AuthenticatedProxy.HowToCall(howToCallsVs[1]), firstCalldata),

            Order(address(uints[7]), address(uints[8]), staticSelectors[1], secondExtradata, uints[9], uints[10], uints[11], uints[12]),

            Sig(howToCallsVs[2], rssMetadata[2], rssMetadata[3]),

            Call(address(uints[13]), AuthenticatedProxy.HowToCall(howToCallsVs[3]), secondCalldata),

            rssMetadata[4]

        );

    }



}



// File: contracts/WyvernExchange.sol



/*



  << Wyvern Exchange >>



*/



pragma solidity 0.5.4;





/**

 * @title WyvernExchange

 * @author Wyvern Protocol Developers

 */

contract WyvernExchange is Exchange {



    string public constant name = "Wyvern Exchange";

  

    string public constant version = "3.0";



    string public constant codename = "Ancalagon";



    /**

     */

    constructor (uint chainId, ProxyRegistryInterface registryAddr) public {

        DOMAIN_SEPARATOR = hash(EIP712Domain({

            name: "Wyvern Exchange",

            version: "3",

            chainId: chainId,

            verifyingContract: address(this)

        }));

        registry = registryAddr;

    }



}