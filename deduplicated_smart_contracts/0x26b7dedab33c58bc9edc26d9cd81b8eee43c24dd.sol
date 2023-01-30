/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity 0.4.25;



/// @title makes modern ERC223 contracts compatible with the legacy implementation

/// @dev should be used for all receivers of tokens sent by ICBMEtherToken and NEU

contract ERC223LegacyCallbackCompat {



    ////////////////////////

    // Public functions

    ////////////////////////



    function onTokenTransfer(address wallet, uint256 amount, bytes data)

        public

    {

        tokenFallback(wallet, amount, data);

    }



    function tokenFallback(address wallet, uint256 amount, bytes data)

        public;



}



/// @title known contracts of the platform

/// should be returned by contractId() method of IContradId.sol. caluclated like so: keccak256("neufund-platform:Neumark")

/// @dev constants are kept in CODE not in STORAGE so they are comparatively cheap

contract KnownContracts {



    ////////////////////////

    // Constants

    ////////////////////////



    // keccak256("neufund-platform:FeeDisbursalController")

    bytes32 internal constant FEE_DISBURSAL_CONTROLLER = 0xfc72936b568fd5fc632b76e8feac0b717b4db1fce26a1b3b623b7fb6149bd8ae;



}



/// @title known interfaces (services) of the platform

/// "known interface" is a unique id of service provided by the platform and discovered via Universe contract

///  it does not refer to particular contract/interface ABI, particular service may be delivered via different implementations

///  however for a few contracts we commit platform to particular implementation (all ICBM Contracts, Universe itself etc.)

/// @dev constants are kept in CODE not in STORAGE so they are comparatively cheap

contract KnownInterfaces {



    ////////////////////////

    // Constants

    ////////////////////////



    // NOTE: All interface are set to the keccak256 hash of the

    // CamelCased interface or singleton name, i.e.

    // KNOWN_INTERFACE_NEUMARK = keccak256("Neumark")



    // EIP 165 + EIP 820 should be use instead but it seems they are far from finished

    // also interface signature should be build automatically by solidity. otherwise it is a pure hassle



    // neumark token interface and sigleton keccak256("Neumark")

    bytes4 internal constant KNOWN_INTERFACE_NEUMARK = 0xeb41a1bd;



    // ether token interface and singleton keccak256("EtherToken")

    bytes4 internal constant KNOWN_INTERFACE_ETHER_TOKEN = 0x8cf73cf1;



    // euro token interface and singleton keccak256("EuroToken")

    bytes4 internal constant KNOWN_INTERFACE_EURO_TOKEN = 0x83c3790b;



    // identity registry interface and singleton keccak256("IIdentityRegistry")

    bytes4 internal constant KNOWN_INTERFACE_IDENTITY_REGISTRY = 0x0a72e073;



    // currency rates oracle interface and singleton keccak256("ITokenExchangeRateOracle")

    bytes4 internal constant KNOWN_INTERFACE_TOKEN_EXCHANGE_RATE_ORACLE = 0xc6e5349e;



    // fee disbursal interface and singleton keccak256("IFeeDisbursal")

    bytes4 internal constant KNOWN_INTERFACE_FEE_DISBURSAL = 0xf4c848e8;



    // platform portfolio holding equity tokens belonging to NEU holders keccak256("IPlatformPortfolio");

    bytes4 internal constant KNOWN_INTERFACE_PLATFORM_PORTFOLIO = 0xaa1590d0;



    // token exchange interface and singleton keccak256("ITokenExchange")

    bytes4 internal constant KNOWN_INTERFACE_TOKEN_EXCHANGE = 0xddd7a521;



    // service exchanging euro token for gas ("IGasTokenExchange")

    bytes4 internal constant KNOWN_INTERFACE_GAS_EXCHANGE = 0x89dbc6de;



    // access policy interface and singleton keccak256("IAccessPolicy")

    bytes4 internal constant KNOWN_INTERFACE_ACCESS_POLICY = 0xb05049d9;



    // euro lock account (upgraded) keccak256("LockedAccount:Euro")

    bytes4 internal constant KNOWN_INTERFACE_EURO_LOCK = 0x2347a19e;



    // ether lock account (upgraded) keccak256("LockedAccount:Ether")

    bytes4 internal constant KNOWN_INTERFACE_ETHER_LOCK = 0x978a6823;



    // icbm euro lock account keccak256("ICBMLockedAccount:Euro")

    bytes4 internal constant KNOWN_INTERFACE_ICBM_EURO_LOCK = 0x36021e14;



    // ether lock account (upgraded) keccak256("ICBMLockedAccount:Ether")

    bytes4 internal constant KNOWN_INTERFACE_ICBM_ETHER_LOCK = 0x0b58f006;



    // ether token interface and singleton keccak256("ICBMEtherToken")

    bytes4 internal constant KNOWN_INTERFACE_ICBM_ETHER_TOKEN = 0xae8b50b9;



    // euro token interface and singleton keccak256("ICBMEuroToken")

    bytes4 internal constant KNOWN_INTERFACE_ICBM_EURO_TOKEN = 0xc2c6cd72;



    // ICBM commitment interface interface and singleton keccak256("ICBMCommitment")

    bytes4 internal constant KNOWN_INTERFACE_ICBM_COMMITMENT = 0x7f2795ef;



    // ethereum fork arbiter interface and singleton keccak256("IEthereumForkArbiter")

    bytes4 internal constant KNOWN_INTERFACE_FORK_ARBITER = 0x2fe7778c;



    // Platform terms interface and singletong keccak256("PlatformTerms")

    bytes4 internal constant KNOWN_INTERFACE_PLATFORM_TERMS = 0x75ecd7f8;



    // for completness we define Universe service keccak256("Universe");

    bytes4 internal constant KNOWN_INTERFACE_UNIVERSE = 0xbf202454;



    // ETO commitment interface (collection) keccak256("ICommitment")

    bytes4 internal constant KNOWN_INTERFACE_COMMITMENT = 0xfa0e0c60;



    // Equity Token Controller interface (collection) keccak256("IEquityTokenController")

    bytes4 internal constant KNOWN_INTERFACE_EQUITY_TOKEN_CONTROLLER = 0xfa30b2f1;



    // Equity Token interface (collection) keccak256("IEquityToken")

    bytes4 internal constant KNOWN_INTERFACE_EQUITY_TOKEN = 0xab9885bb;



    // Payment tokens (collection) keccak256("PaymentToken")

    bytes4 internal constant KNOWN_INTERFACE_PAYMENT_TOKEN = 0xb2a0042a;

}



contract Math {



    ////////////////////////

    // Internal functions

    ////////////////////////



    // absolute difference: |v1 - v2|

    function absDiff(uint256 v1, uint256 v2)

        internal

        pure

        returns(uint256)

    {

        return v1 > v2 ? v1 - v2 : v2 - v1;

    }



    // divide v by d, round up if remainder is 0.5 or more

    function divRound(uint256 v, uint256 d)

        internal

        pure

        returns(uint256)

    {

        return add(v, d/2) / d;

    }



    // computes decimal decimalFraction 'frac' of 'amount' with maximum precision (multiplication first)

    // both amount and decimalFraction must have 18 decimals precision, frac 10**18 represents a whole (100% of) amount

    // mind loss of precision as decimal fractions do not have finite binary expansion

    // do not use instead of division

    function decimalFraction(uint256 amount, uint256 frac)

        internal

        pure

        returns(uint256)

    {

        // it's like 1 ether is 100% proportion

        return proportion(amount, frac, 10**18);

    }



    // computes part/total of amount with maximum precision (multiplication first)

    // part and total must have the same units

    function proportion(uint256 amount, uint256 part, uint256 total)

        internal

        pure

        returns(uint256)

    {

        return divRound(mul(amount, part), total);

    }



    //

    // Open Zeppelin Math library below

    //



    function mul(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function sub(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



    function min(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        return a < b ? a : b;

    }



    function max(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        return a > b ? a : b;

    }

}



/// @title provides subject to role checking logic

contract IAccessPolicy {



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice We don't make this function constant to allow for state-updating access controls such as rate limiting.

    /// @dev checks if subject belongs to requested role for particular object

    /// @param subject address to be checked against role, typically msg.sender

    /// @param role identifier of required role

    /// @param object contract instance context for role checking, typically contract requesting the check

    /// @param verb additional data, in current AccessControll implementation msg.sig

    /// @return if subject belongs to a role

    function allowed(

        address subject,

        bytes32 role,

        address object,

        bytes4 verb

    )

        public

        returns (bool);

}



/// @title enables access control in implementing contract

/// @dev see AccessControlled for implementation

contract IAccessControlled {



    ////////////////////////

    // Events

    ////////////////////////



    /// @dev must log on access policy change

    event LogAccessPolicyChanged(

        address controller,

        IAccessPolicy oldPolicy,

        IAccessPolicy newPolicy

    );



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @dev allows to change access control mechanism for this contract

    ///     this method must be itself access controlled, see AccessControlled implementation and notice below

    /// @notice it is a huge issue for Solidity that modifiers are not part of function signature

    ///     then interfaces could be used for example to control access semantics

    /// @param newPolicy new access policy to controll this contract

    /// @param newAccessController address of ROLE_ACCESS_CONTROLLER of new policy that can set access to this contract

    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)

        public;



    function accessPolicy()

        public

        constant

        returns (IAccessPolicy);



}



contract StandardRoles {



    ////////////////////////

    // Constants

    ////////////////////////



    // @notice Soldity somehow doesn't evaluate this compile time

    // @dev role which has rights to change permissions and set new policy in contract, keccak256("AccessController")

    bytes32 internal constant ROLE_ACCESS_CONTROLLER = 0xac42f8beb17975ed062dcb80c63e6d203ef1c2c335ced149dc5664cc671cb7da;

}



/// @title Granular code execution permissions

/// @notice Intended to replace existing Ownable pattern with more granular permissions set to execute smart contract functions

///     for each function where 'only' modifier is applied, IAccessPolicy implementation is called to evaluate if msg.sender belongs to required role for contract being called.

///     Access evaluation specific belong to IAccessPolicy implementation, see RoleBasedAccessPolicy for details.

/// @dev Should be inherited by a contract requiring such permissions controll. IAccessPolicy must be provided in constructor. Access policy may be replaced to a different one

///     by msg.sender with ROLE_ACCESS_CONTROLLER role

contract AccessControlled is IAccessControlled, StandardRoles {



    ////////////////////////

    // Mutable state

    ////////////////////////



    IAccessPolicy private _accessPolicy;



    ////////////////////////

    // Modifiers

    ////////////////////////



    /// @dev limits function execution only to senders assigned to required 'role'

    modifier only(bytes32 role) {

        require(_accessPolicy.allowed(msg.sender, role, this, msg.sig));

        _;

    }



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(IAccessPolicy policy) internal {

        require(address(policy) != 0x0);

        _accessPolicy = policy;

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    //

    // Implements IAccessControlled

    //



    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)

        public

        only(ROLE_ACCESS_CONTROLLER)

    {

        // ROLE_ACCESS_CONTROLLER must be present

        // under the new policy. This provides some

        // protection against locking yourself out.

        require(newPolicy.allowed(newAccessController, ROLE_ACCESS_CONTROLLER, this, msg.sig));



        // We can now safely set the new policy without foot shooting.

        IAccessPolicy oldPolicy = _accessPolicy;

        _accessPolicy = newPolicy;



        // Log event

        emit LogAccessPolicyChanged(msg.sender, oldPolicy, newPolicy);

    }



    function accessPolicy()

        public

        constant

        returns (IAccessPolicy)

    {

        return _accessPolicy;

    }

}



contract IsContract {



    ////////////////////////

    // Internal functions

    ////////////////////////



    function isContract(address addr)

        internal

        constant

        returns (bool)

    {

        uint256 size;

        // takes 700 gas

        assembly { size := extcodesize(addr) }

        return size > 0;

    }

}



/// @title standard access roles of the Platform

/// @dev constants are kept in CODE not in STORAGE so they are comparatively cheap

contract AccessRoles {



    ////////////////////////

    // Constants

    ////////////////////////



    // NOTE: All roles are set to the keccak256 hash of the

    // CamelCased role name, i.e.

    // ROLE_LOCKED_ACCOUNT_ADMIN = keccak256("LockedAccountAdmin")



    // May issue (generate) Neumarks

    bytes32 internal constant ROLE_NEUMARK_ISSUER = 0x921c3afa1f1fff707a785f953a1e197bd28c9c50e300424e015953cbf120c06c;



    // May burn Neumarks it owns

    bytes32 internal constant ROLE_NEUMARK_BURNER = 0x19ce331285f41739cd3362a3ec176edffe014311c0f8075834fdd19d6718e69f;



    // May create new snapshots on Neumark

    bytes32 internal constant ROLE_SNAPSHOT_CREATOR = 0x08c1785afc57f933523bc52583a72ce9e19b2241354e04dd86f41f887e3d8174;



    // May enable/disable transfers on Neumark

    bytes32 internal constant ROLE_TRANSFER_ADMIN = 0xb6527e944caca3d151b1f94e49ac5e223142694860743e66164720e034ec9b19;



    // may reclaim tokens/ether from contracts supporting IReclaimable interface

    bytes32 internal constant ROLE_RECLAIMER = 0x0542bbd0c672578966dcc525b30aa16723bb042675554ac5b0362f86b6e97dc5;



    // represents legally platform operator in case of forks and contracts with legal agreement attached. keccak256("PlatformOperatorRepresentative")

    bytes32 internal constant ROLE_PLATFORM_OPERATOR_REPRESENTATIVE = 0xb2b321377653f655206f71514ff9f150d0822d062a5abcf220d549e1da7999f0;



    // allows to deposit EUR-T and allow addresses to send and receive EUR-T. keccak256("EurtDepositManager")

    bytes32 internal constant ROLE_EURT_DEPOSIT_MANAGER = 0x7c8ecdcba80ce87848d16ad77ef57cc196c208fc95c5638e4a48c681a34d4fe7;



    // allows to register identities and change associated claims keccak256("IdentityManager")

    bytes32 internal constant ROLE_IDENTITY_MANAGER = 0x32964e6bc50f2aaab2094a1d311be8bda920fc4fb32b2fb054917bdb153a9e9e;



    // allows to replace controller on euro token and to destroy tokens without withdraw kecckak256("EurtLegalManager")

    bytes32 internal constant ROLE_EURT_LEGAL_MANAGER = 0x4eb6b5806954a48eb5659c9e3982d5e75bfb2913f55199877d877f157bcc5a9b;



    // allows to change known interfaces in universe kecckak256("UniverseManager")

    bytes32 internal constant ROLE_UNIVERSE_MANAGER = 0xe8d8f8f9ea4b19a5a4368dbdace17ad71a69aadeb6250e54c7b4c7b446301738;



    // allows to exchange gas for EUR-T keccak("GasExchange")

    bytes32 internal constant ROLE_GAS_EXCHANGE = 0x9fe43636e0675246c99e96d7abf9f858f518b9442c35166d87f0934abef8a969;



    // allows to set token exchange rates keccak("TokenRateOracle")

    bytes32 internal constant ROLE_TOKEN_RATE_ORACLE = 0xa80c3a0c8a5324136e4c806a778583a2a980f378bdd382921b8d28dcfe965585;



    // allows to disburse to the fee disbursal contract keccak("Disburser")

    bytes32 internal constant ROLE_DISBURSER = 0xd7ea6093d11d866c9e8449f8bffd9da1387c530ee40ad54f0641425bb0ca33b7;



    // allows to manage feedisbursal controller keccak("DisbursalManager")

    bytes32 internal constant ROLE_DISBURSAL_MANAGER = 0x677f87f7b7ef7c97e42a7e6c85c295cf020c9f11eea1e49f6bf847d7aeae1475;



}



contract IBasicToken {



    ////////////////////////

    // Events

    ////////////////////////



    event Transfer(

        address indexed from,

        address indexed to,

        uint256 amount

    );



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @dev This function makes it easy to get the total number of tokens

    /// @return The total number of tokens

    function totalSupply()

        public

        constant

        returns (uint256);



    /// @param owner The address that's balance is being requested

    /// @return The balance of `owner` at the current block

    function balanceOf(address owner)

        public

        constant

        returns (uint256 balance);



    /// @notice Send `amount` tokens to `to` from `msg.sender`

    /// @param to The address of the recipient

    /// @param amount The amount of tokens to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address to, uint256 amount)

        public

        returns (bool success);



}



/// @title allows deriving contract to recover any token or ether that it has balance of

/// @notice note that this opens your contracts to claims from various people saying they lost tokens and they want them back

///     be ready to handle such claims

/// @dev use with care!

///     1. ROLE_RECLAIMER is allowed to claim tokens, it's not returning tokens to original owner

///     2. in derived contract that holds any token by design you must override `reclaim` and block such possibility.

///         see ICBMLockedAccount as an example

contract Reclaimable is AccessControlled, AccessRoles {



    ////////////////////////

    // Constants

    ////////////////////////



    IBasicToken constant internal RECLAIM_ETHER = IBasicToken(0x0);



    ////////////////////////

    // Public functions

    ////////////////////////



    function reclaim(IBasicToken token)

        public

        only(ROLE_RECLAIMER)

    {

        address reclaimer = msg.sender;

        if(token == RECLAIM_ETHER) {

            reclaimer.transfer(address(this).balance);

        } else {

            uint256 balance = token.balanceOf(this);

            require(token.transfer(reclaimer, balance));

        }

    }

}



contract ITokenMetadata {



    ////////////////////////

    // Public functions

    ////////////////////////



    function symbol()

        public

        constant

        returns (string);



    function name()

        public

        constant

        returns (string);



    function decimals()

        public

        constant

        returns (uint8);

}



/// @title adds token metadata to token contract

/// @dev see Neumark for example implementation

contract TokenMetadata is ITokenMetadata {



    ////////////////////////

    // Immutable state

    ////////////////////////



    // The Token's name: e.g. DigixDAO Tokens

    string private NAME;



    // An identifier: e.g. REP

    string private SYMBOL;



    // Number of decimals of the smallest unit

    uint8 private DECIMALS;



    // An arbitrary versioning scheme

    string private VERSION;



    ////////////////////////

    // Constructor

    ////////////////////////



    /// @notice Constructor to set metadata

    /// @param tokenName Name of the new token

    /// @param decimalUnits Number of decimals of the new token

    /// @param tokenSymbol Token Symbol for the new token

    /// @param version Token version ie. when cloning is used

    constructor(

        string tokenName,

        uint8 decimalUnits,

        string tokenSymbol,

        string version

    )

        public

    {

        NAME = tokenName;                                 // Set the name

        SYMBOL = tokenSymbol;                             // Set the symbol

        DECIMALS = decimalUnits;                          // Set the decimals

        VERSION = version;

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    function name()

        public

        constant

        returns (string)

    {

        return NAME;

    }



    function symbol()

        public

        constant

        returns (string)

    {

        return SYMBOL;

    }



    function decimals()

        public

        constant

        returns (uint8)

    {

        return DECIMALS;

    }



    function version()

        public

        constant

        returns (string)

    {

        return VERSION;

    }

}



/// @title controls spending approvals

/// @dev TokenAllowance observes this interface, Neumark contract implements it

contract MTokenAllowanceController {



    ////////////////////////

    // Internal functions

    ////////////////////////



    /// @notice Notifies the controller about an approval allowing the

    ///  controller to react if desired

    /// @param owner The address that calls `approve()`

    /// @param spender The spender in the `approve()` call

    /// @param amount The amount in the `approve()` call

    /// @return False if the controller does not authorize the approval

    function mOnApprove(

        address owner,

        address spender,

        uint256 amount

    )

        internal

        returns (bool allow);



    /// @notice Allows to override allowance approved by the owner

    ///         Primary role is to enable forced transfers, do not override if you do not like it

    ///         Following behavior is expected in the observer

    ///         approve() - should revert if mAllowanceOverride() > 0

    ///         allowance() - should return mAllowanceOverride() if set

    ///         transferFrom() - should override allowance if mAllowanceOverride() > 0

    /// @param owner An address giving allowance to spender

    /// @param spender An address getting  a right to transfer allowance amount from the owner

    /// @return current allowance amount

    function mAllowanceOverride(

        address owner,

        address spender

    )

        internal

        constant

        returns (uint256 allowance);

}



/// @title controls token transfers

/// @dev BasicSnapshotToken observes this interface, Neumark contract implements it

contract MTokenTransferController {



    ////////////////////////

    // Internal functions

    ////////////////////////



    /// @notice Notifies the controller about a token transfer allowing the

    ///  controller to react if desired

    /// @param from The origin of the transfer

    /// @param to The destination of the transfer

    /// @param amount The amount of the transfer

    /// @return False if the controller does not authorize the transfer

    function mOnTransfer(

        address from,

        address to,

        uint256 amount

    )

        internal

        returns (bool allow);



}



/// @title controls approvals and transfers

/// @dev The token controller contract must implement these functions, see Neumark as example

/// @dev please note that controller may be a separate contract that is called from mOnTransfer and mOnApprove functions

contract MTokenController is MTokenTransferController, MTokenAllowanceController {

}



contract TrustlessTokenController is

    MTokenController

{

    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements MTokenController

    //



    function mOnTransfer(

        address /*from*/,

        address /*to*/,

        uint256 /*amount*/

    )

        internal

        returns (bool allow)

    {

        return true;

    }



    function mOnApprove(

        address /*owner*/,

        address /*spender*/,

        uint256 /*amount*/

    )

        internal

        returns (bool allow)

    {

        return true;

    }

}



contract IERC20Allowance {



    ////////////////////////

    // Events

    ////////////////////////



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 amount

    );



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @dev This function makes it easy to read the `allowed[]` map

    /// @param owner The address of the account that owns the token

    /// @param spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens of owner that spender is allowed

    ///  to spend

    function allowance(address owner, address spender)

        public

        constant

        returns (uint256 remaining);



    /// @notice `msg.sender` approves `spender` to spend `amount` tokens on

    ///  its behalf. This is a modified version of the ERC20 approve function

    ///  to be a little bit safer

    /// @param spender The address of the account able to transfer the tokens

    /// @param amount The amount of tokens to be approved for transfer

    /// @return True if the approval was successful

    function approve(address spender, uint256 amount)

        public

        returns (bool success);



    /// @notice Send `amount` tokens to `to` from `from` on the condition it

    ///  is approved by `from`

    /// @param from The address holding the tokens being transferred

    /// @param to The address of the recipient

    /// @param amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function transferFrom(address from, address to, uint256 amount)

        public

        returns (bool success);



}



contract IERC20Token is IBasicToken, IERC20Allowance {



}



contract IERC677Callback {



    ////////////////////////

    // Public functions

    ////////////////////////



    // NOTE: This call can be initiated by anyone. You need to make sure that

    // it is send by the token (`require(msg.sender == token)`) or make sure

    // amount is valid (`require(token.allowance(this) >= amount)`).

    function receiveApproval(

        address from,

        uint256 amount,

        address token, // IERC667Token

        bytes data

    )

        public

        returns (bool success);



}



contract IERC677Allowance is IERC20Allowance {



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice `msg.sender` approves `spender` to send `amount` tokens on

    ///  its behalf, and then a function is triggered in the contract that is

    ///  being approved, `spender`. This allows users to use their tokens to

    ///  interact with contracts in one function call instead of two

    /// @param spender The address of the contract able to transfer the tokens

    /// @param amount The amount of tokens to be approved for transfer

    /// @return True if the function call was successful

    function approveAndCall(address spender, uint256 amount, bytes extraData)

        public

        returns (bool success);



}



contract IERC677Token is IERC20Token, IERC677Allowance {

}



/// @title internal token transfer function

/// @dev see BasicSnapshotToken for implementation

contract MTokenTransfer {



    ////////////////////////

    // Internal functions

    ////////////////////////



    /// @dev This is the actual transfer function in the token contract, it can

    ///  only be called by other functions in this contract.

    /// @param from The address holding the tokens being transferred

    /// @param to The address of the recipient

    /// @param amount The amount of tokens to be transferred

    /// @dev  reverts if transfer was not successful

    function mTransfer(

        address from,

        address to,

        uint256 amount

    )

        internal;

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is

    MTokenTransfer,

    MTokenTransferController,

    IBasicToken,

    Math

{



    ////////////////////////

    // Mutable state

    ////////////////////////



    mapping(address => uint256) internal _balances;



    uint256 internal _totalSupply;



    ////////////////////////

    // Public functions

    ////////////////////////



    /**

    * @dev transfer token for a specified address

    * @param to The address to transfer to.

    * @param amount The amount to be transferred.

    */

    function transfer(address to, uint256 amount)

        public

        returns (bool)

    {

        mTransfer(msg.sender, to, amount);

        return true;

    }



    /// @dev This function makes it easy to get the total number of tokens

    /// @return The total number of tokens

    function totalSupply()

        public

        constant

        returns (uint256)

    {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner)

        public

        constant

        returns (uint256 balance)

    {

        return _balances[owner];

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements MTokenTransfer

    //



    function mTransfer(address from, address to, uint256 amount)

        internal

    {

        require(to != address(0));

        require(mOnTransfer(from, to, amount));



        _balances[from] = sub(_balances[from], amount);

        _balances[to] = add(_balances[to], amount);

        emit Transfer(from, to, amount);

    }

}



/// @title token spending approval and transfer

/// @dev implements token approval and transfers and exposes relevant part of ERC20 and ERC677 approveAndCall

///     may be mixed in with any basic token (implementing mTransfer) like BasicSnapshotToken or MintableSnapshotToken to add approval mechanism

///     observes MTokenAllowanceController interface

///     observes MTokenTransfer

contract TokenAllowance is

    MTokenTransfer,

    MTokenAllowanceController,

    IERC20Allowance,

    IERC677Token

{



    ////////////////////////

    // Mutable state

    ////////////////////////



    // `allowed` tracks rights to spends others tokens as per ERC20

    // owner => spender => amount

    mapping (address => mapping (address => uint256)) private _allowed;



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor()

        internal

    {

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    //

    // Implements IERC20Token

    //



    /// @dev This function makes it easy to read the `allowed[]` map

    /// @param owner The address of the account that owns the token

    /// @param spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens of _owner that _spender is allowed

    ///  to spend

    function allowance(address owner, address spender)

        public

        constant

        returns (uint256 remaining)

    {

        uint256 override = mAllowanceOverride(owner, spender);

        if (override > 0) {

            return override;

        }

        return _allowed[owner][spender];

    }



    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on

    ///  its behalf. This is a modified version of the ERC20 approve function

    ///  where allowance per spender must be 0 to allow change of such allowance

    /// @param spender The address of the account able to transfer the tokens

    /// @param amount The amount of tokens to be approved for transfer

    /// @return True or reverts, False is never returned

    function approve(address spender, uint256 amount)

        public

        returns (bool success)

    {

        // Alerts the token controller of the approve function call

        require(mOnApprove(msg.sender, spender, amount));



        // To change the approve amount you first have to reduce the addresses`

        //  allowance to zero by calling `approve(_spender,0)` if it is not

        //  already 0 to mitigate the race condition described here:

        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

        require((amount == 0 || _allowed[msg.sender][spender] == 0) && mAllowanceOverride(msg.sender, spender) == 0);



        _allowed[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;

    }



    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it

    ///  is approved by `_from`

    /// @param from The address holding the tokens being transferred

    /// @param to The address of the recipient

    /// @param amount The amount of tokens to be transferred

    /// @return True if the transfer was successful, reverts in any other case

    function transferFrom(address from, address to, uint256 amount)

        public

        returns (bool success)

    {

        uint256 allowed = mAllowanceOverride(from, msg.sender);

        if (allowed == 0) {

            // The standard ERC 20 transferFrom functionality

            allowed = _allowed[from][msg.sender];

            // yes this will underflow but then we'll revert. will cost gas however so don't underflow

            _allowed[from][msg.sender] -= amount;

        }

        require(allowed >= amount);

        mTransfer(from, to, amount);

        return true;

    }



    //

    // Implements IERC677Token

    //



    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on

    ///  its behalf, and then a function is triggered in the contract that is

    ///  being approved, `_spender`. This allows users to use their tokens to

    ///  interact with contracts in one function call instead of two

    /// @param spender The address of the contract able to transfer the tokens

    /// @param amount The amount of tokens to be approved for transfer

    /// @return True or reverts, False is never returned

    function approveAndCall(

        address spender,

        uint256 amount,

        bytes extraData

    )

        public

        returns (bool success)

    {

        require(approve(spender, amount));



        success = IERC677Callback(spender).receiveApproval(

            msg.sender,

            amount,

            this,

            extraData

        );

        require(success);



        return true;

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements default MTokenAllowanceController

    //



    // no override in default implementation

    function mAllowanceOverride(

        address /*owner*/,

        address /*spender*/

    )

        internal

        constant

        returns (uint256)

    {

        return 0;

    }

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 */

contract StandardToken is

    IERC20Token,

    BasicToken,

    TokenAllowance

{



}



/// @title uniquely identifies deployable (non-abstract) platform contract

/// @notice cheap way of assigning implementations to knownInterfaces which represent system services

///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces

///         EIP820 still in the making

/// @dev ids are generated as follows keccak256("neufund-platform:<contract name>")

///      ids roughly correspond to ABIs

contract IContractId {

    /// @param id defined as above

    /// @param version implementation version

    function contractId() public pure returns (bytes32 id, uint256 version);

}



/// @title current ERC223 fallback function

/// @dev to be used in all future token contract

/// @dev NEU and ICBMEtherToken (obsolete) are the only contracts that still uses IERC223LegacyCallback

contract IERC223Callback {



    ////////////////////////

    // Public functions

    ////////////////////////



    function tokenFallback(address from, uint256 amount, bytes data)

        public;



}



contract IERC223Token is IERC20Token, ITokenMetadata {



    /// @dev Departure: We do not log data, it has no advantage over a standard

    ///     log event. By sticking to the standard log event we

    ///     stay compatible with constracts that expect and ERC20 token.



    // event Transfer(

    //    address indexed from,

    //    address indexed to,

    //    uint256 amount,

    //    bytes data);





    /// @dev Departure: We do not use the callback on regular transfer calls to

    ///     stay compatible with constracts that expect and ERC20 token.



    // function transfer(address to, uint256 amount)

    //     public

    //     returns (bool);



    ////////////////////////

    // Public functions

    ////////////////////////



    function transfer(address to, uint256 amount, bytes data)

        public

        returns (bool);

}



contract IWithdrawableToken {



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice withdraws from a token holding assets

    /// @dev amount of asset should be returned to msg.sender and corresponding balance burned

    function withdraw(uint256 amount)

        public;

}



contract EtherToken is

    IsContract,

    IContractId,

    AccessControlled,

    StandardToken,

    TrustlessTokenController,

    IWithdrawableToken,

    TokenMetadata,

    IERC223Token,

    Reclaimable

{

    ////////////////////////

    // Constants

    ////////////////////////



    string private constant NAME = "Ether Token";



    string private constant SYMBOL = "ETH-T";



    uint8 private constant DECIMALS = 18;



    ////////////////////////

    // Events

    ////////////////////////



    event LogDeposit(

        address indexed to,

        uint256 amount

    );



    event LogWithdrawal(

        address indexed from,

        uint256 amount

    );



    event LogWithdrawAndSend(

        address indexed from,

        address indexed to,

        uint256 amount

    );



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(IAccessPolicy accessPolicy)

        AccessControlled(accessPolicy)

        StandardToken()

        TokenMetadata(NAME, DECIMALS, SYMBOL, "")

        Reclaimable()

        public

    {

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    /// deposit msg.value of Ether to msg.sender balance

    function deposit()

        public

        payable

    {

        depositPrivate();

        emit Transfer(address(0), msg.sender, msg.value);

    }



    /// @notice convenience function to deposit and immediately transfer amount

    /// @param transferTo where to transfer after deposit

    /// @param amount total amount to transfer, must be <= balance after deposit

    /// @param data erc223 data

    /// @dev intended to deposit from simple account and invest in ETO

    function depositAndTransfer(address transferTo, uint256 amount, bytes data)

        public

        payable

    {

        depositPrivate();

        transfer(transferTo, amount, data);

    }



    /// withdraws and sends 'amount' of ether to msg.sender

    function withdraw(uint256 amount)

        public

    {

        withdrawPrivate(amount);

        msg.sender.transfer(amount);

    }



    /// @notice convenience function to withdraw and transfer to external account

    /// @param sendTo address to which send total amount

    /// @param amount total amount to withdraw and send

    /// @dev function is payable and is meant to withdraw funds on accounts balance and token in single transaction

    /// @dev BEWARE that msg.sender of the funds is Ether Token contract and not simple account calling it.

    /// @dev  when sent to smart conctract funds may be lost, so this is prevented below

    function withdrawAndSend(address sendTo, uint256 amount)

        public

        payable

    {

        // must send at least what is in msg.value to being another deposit function

        require(amount >= msg.value, "NF_ET_NO_DEPOSIT");

        if (amount > msg.value) {

            uint256 withdrawRemainder = amount - msg.value;

            withdrawPrivate(withdrawRemainder);

        }

        emit LogWithdrawAndSend(msg.sender, sendTo, amount);

        sendTo.transfer(amount);

    }



    //

    // Implements IERC223Token

    //



    function transfer(address to, uint256 amount, bytes data)

        public

        returns (bool)

    {

        BasicToken.mTransfer(msg.sender, to, amount);



        // Notify the receiving contract.

        if (isContract(to)) {

            // in case of re-entry (1) transfer is done (2) msg.sender is different

            IERC223Callback(to).tokenFallback(msg.sender, amount, data);

        }

        return true;

    }



    //

    // Overrides Reclaimable

    //



    /// @notice allows EtherToken to reclaim tokens wrongly sent to its address

    /// @dev as EtherToken by design has balance of Ether (native Ethereum token)

    ///     such reclamation is not allowed

    function reclaim(IBasicToken token)

        public

    {

        // forbid reclaiming ETH hold in this contract.

        require(token != RECLAIM_ETHER);

        Reclaimable.reclaim(token);

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x75b86bc24f77738576716a36431588ae768d80d077231d1661c2bea674c6373a, 0);

    }





    ////////////////////////

    // Private functions

    ////////////////////////



    function depositPrivate()

        private

    {

        _balances[msg.sender] = add(_balances[msg.sender], msg.value);

        _totalSupply = add(_totalSupply, msg.value);

        emit LogDeposit(msg.sender, msg.value);

    }



    function withdrawPrivate(uint256 amount)

        private

    {

        require(_balances[msg.sender] >= amount);

        _balances[msg.sender] = sub(_balances[msg.sender], amount);

        _totalSupply = sub(_totalSupply, amount);

        emit LogWithdrawal(msg.sender, amount);

        emit Transfer(msg.sender, address(0), amount);

    }

}



contract IEthereumForkArbiter {



    ////////////////////////

    // Events

    ////////////////////////



    event LogForkAnnounced(

        string name,

        string url,

        uint256 blockNumber

    );



    event LogForkSigned(

        uint256 blockNumber,

        bytes32 blockHash

    );



    ////////////////////////

    // Public functions

    ////////////////////////



    function nextForkName()

        public

        constant

        returns (string);



    function nextForkUrl()

        public

        constant

        returns (string);



    function nextForkBlockNumber()

        public

        constant

        returns (uint256);



    function lastSignedBlockNumber()

        public

        constant

        returns (uint256);



    function lastSignedBlockHash()

        public

        constant

        returns (bytes32);



    function lastSignedTimestamp()

        public

        constant

        returns (uint256);



}



/**

 * @title legally binding smart contract

 * @dev General approach to paring legal and smart contracts:

 * 1. All terms and agreement are between two parties: here between smart conctract legal representation and platform investor.

 * 2. Parties are represented by public Ethereum addresses. Platform investor is and address that holds and controls funds and receives and controls Neumark token

 * 3. Legal agreement has immutable part that corresponds to smart contract code and mutable part that may change for example due to changing regulations or other externalities that smart contract does not control.

 * 4. There should be a provision in legal document that future changes in mutable part cannot change terms of immutable part.

 * 5. Immutable part links to corresponding smart contract via its address.

 * 6. Additional provision should be added if smart contract supports it

 *  a. Fork provision

 *  b. Bugfixing provision (unilateral code update mechanism)

 *  c. Migration provision (bilateral code update mechanism)

 *

 * Details on Agreement base class:

 * 1. We bind smart contract to legal contract by storing uri (preferably ipfs or hash) of the legal contract in the smart contract. It is however crucial that such binding is done by smart contract legal representation so transaction establishing the link must be signed by respective wallet ('amendAgreement')

 * 2. Mutable part of agreement may change. We should be able to amend the uri later. Previous amendments should not be lost and should be retrievable (`amendAgreement` and 'pastAgreement' functions).

 * 3. It is up to deriving contract to decide where to put 'acceptAgreement' modifier. However situation where there is no cryptographic proof that given address was really acting in the transaction should be avoided, simplest example being 'to' address in `transfer` function of ERC20.

 *

**/

contract IAgreement {



    ////////////////////////

    // Events

    ////////////////////////



    event LogAgreementAccepted(

        address indexed accepter

    );



    event LogAgreementAmended(

        address contractLegalRepresentative,

        string agreementUri

    );



    /// @dev should have access restrictions so only contractLegalRepresentative may call

    function amendAgreement(string agreementUri) public;



    /// returns information on last amendment of the agreement

    /// @dev MUST revert if no agreements were set

    function currentAgreement()

        public

        constant

        returns

        (

            address contractLegalRepresentative,

            uint256 signedBlockTimestamp,

            string agreementUri,

            uint256 index

        );



    /// returns information on amendment with index

    /// @dev MAY revert on non existing amendment, indexing starts from 0

    function pastAgreement(uint256 amendmentIndex)

        public

        constant

        returns

        (

            address contractLegalRepresentative,

            uint256 signedBlockTimestamp,

            string agreementUri,

            uint256 index

        );



    /// returns the number of block at wchich `signatory` signed agreement

    /// @dev MUST return 0 if not signed

    function agreementSignedAtBlock(address signatory)

        public

        constant

        returns (uint256 blockNo);



    /// returns number of amendments made by contractLegalRepresentative

    function amendmentsCount()

        public

        constant

        returns (uint256);

}



/**

 * @title legally binding smart contract

 * @dev read IAgreement for details

**/

contract Agreement is

    IAgreement,

    AccessControlled,

    AccessRoles

{



    ////////////////////////

    // Type declarations

    ////////////////////////



    /// @notice agreement with signature of the platform operator representative

    struct SignedAgreement {

        address contractLegalRepresentative;

        uint256 signedBlockTimestamp;

        string agreementUri;

    }



    ////////////////////////

    // Immutable state

    ////////////////////////



    IEthereumForkArbiter private ETHEREUM_FORK_ARBITER;



    ////////////////////////

    // Mutable state

    ////////////////////////



    // stores all amendments to the agreement, first amendment is the original

    SignedAgreement[] private _amendments;



    // stores block numbers of all addresses that signed the agreement (signatory => block number)

    mapping(address => uint256) private _signatories;



    ////////////////////////

    // Modifiers

    ////////////////////////



    /// @notice logs that agreement was accepted by platform user

    /// @dev intended to be added to functions that if used make 'accepter' origin to enter legally binding agreement

    modifier acceptAgreement(address accepter) {

        acceptAgreementInternal(accepter);

        _;

    }



    modifier onlyLegalRepresentative(address legalRepresentative) {

        require(mCanAmend(legalRepresentative));

        _;

    }



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(IAccessPolicy accessPolicy, IEthereumForkArbiter forkArbiter)

        AccessControlled(accessPolicy)

        internal

    {

        require(forkArbiter != IEthereumForkArbiter(0x0));

        ETHEREUM_FORK_ARBITER = forkArbiter;

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    function amendAgreement(string agreementUri)

        public

        onlyLegalRepresentative(msg.sender)

    {

        SignedAgreement memory amendment = SignedAgreement({

            contractLegalRepresentative: msg.sender,

            signedBlockTimestamp: block.timestamp,

            agreementUri: agreementUri

        });

        _amendments.push(amendment);

        emit LogAgreementAmended(msg.sender, agreementUri);

    }



    function ethereumForkArbiter()

        public

        constant

        returns (IEthereumForkArbiter)

    {

        return ETHEREUM_FORK_ARBITER;

    }



    function currentAgreement()

        public

        constant

        returns

        (

            address contractLegalRepresentative,

            uint256 signedBlockTimestamp,

            string agreementUri,

            uint256 index

        )

    {

        require(_amendments.length > 0);

        uint256 last = _amendments.length - 1;

        SignedAgreement storage amendment = _amendments[last];

        return (

            amendment.contractLegalRepresentative,

            amendment.signedBlockTimestamp,

            amendment.agreementUri,

            last

        );

    }



    function pastAgreement(uint256 amendmentIndex)

        public

        constant

        returns

        (

            address contractLegalRepresentative,

            uint256 signedBlockTimestamp,

            string agreementUri,

            uint256 index

        )

    {

        SignedAgreement storage amendment = _amendments[amendmentIndex];

        return (

            amendment.contractLegalRepresentative,

            amendment.signedBlockTimestamp,

            amendment.agreementUri,

            amendmentIndex

        );

    }



    function agreementSignedAtBlock(address signatory)

        public

        constant

        returns (uint256 blockNo)

    {

        return _signatories[signatory];

    }



    function amendmentsCount()

        public

        constant

        returns (uint256)

    {

        return _amendments.length;

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    /// provides direct access to derived contract

    function acceptAgreementInternal(address accepter)

        internal

    {

        if(_signatories[accepter] == 0) {

            require(_amendments.length > 0);

            _signatories[accepter] = block.number;

            emit LogAgreementAccepted(accepter);

        }

    }



    //

    // MAgreement Internal interface (todo: extract)

    //



    /// default amend permission goes to ROLE_PLATFORM_OPERATOR_REPRESENTATIVE

    function mCanAmend(address legalRepresentative)

        internal

        returns (bool)

    {

        return accessPolicy().allowed(legalRepresentative, ROLE_PLATFORM_OPERATOR_REPRESENTATIVE, this, msg.sig);

    }

}



/// @title granular token controller based on MSnapshotToken observer pattern

contract ITokenController {



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice see MTokenTransferController

    /// @dev additionally passes broker that is executing transaction between from and to

    ///      for unbrokered transfer, broker == from

    function onTransfer(address broker, address from, address to, uint256 amount)

        public

        constant

        returns (bool allow);



    /// @notice see MTokenAllowanceController

    function onApprove(address owner, address spender, uint256 amount)

        public

        constant

        returns (bool allow);



    /// @notice see MTokenMint

    function onGenerateTokens(address sender, address owner, uint256 amount)

        public

        constant

        returns (bool allow);



    /// @notice see MTokenMint

    function onDestroyTokens(address sender, address owner, uint256 amount)

        public

        constant

        returns (bool allow);



    /// @notice controls if sender can change controller to newController

    /// @dev for this to succeed TYPICALLY current controller must be already migrated to a new one

    function onChangeTokenController(address sender, address newController)

        public

        constant

        returns (bool);



    /// @notice overrides spender allowance

    /// @dev may be used to implemented forced transfers in which token controller may override approved allowance

    ///      with any > 0 value and then use transferFrom to execute such transfer

    ///      This by definition creates non-trustless token so do not implement this call if you do not need trustless transfers!

    ///      Implementer should not allow approve() to be executed if there is an overrride

    //       Implemented should return allowance() taking into account override

    function onAllowance(address owner, address spender)

        public

        constant

        returns (uint256 allowanceOverride);

}



/// @title hooks token controller to token contract and allows to replace it

contract ITokenControllerHook {



    ////////////////////////

    // Events

    ////////////////////////



    event LogChangeTokenController(

        address oldController,

        address newController,

        address by

    );



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice replace current token controller

    /// @dev please note that this process is also controlled by existing controller

    function changeTokenController(address newController)

        public;



    /// @notice returns current controller

    function tokenController()

        public

        constant

        returns (address currentController);



}



contract EuroToken is

    Agreement,

    IERC677Token,

    StandardToken,

    IWithdrawableToken,

    ITokenControllerHook,

    TokenMetadata,

    IERC223Token,

    IsContract,

    IContractId

{

    ////////////////////////

    // Constants

    ////////////////////////



    string private constant NAME = "Euro Token";



    string private constant SYMBOL = "EUR-T";



    uint8 private constant DECIMALS = 18;



    ////////////////////////

    // Mutable state

    ////////////////////////



    ITokenController private _tokenController;



    ////////////////////////

    // Events

    ////////////////////////



    /// on each deposit (increase of supply) of EUR-T

    /// 'by' indicates account that executed the deposit function for 'to' (typically bank connector)

    event LogDeposit(

        address indexed to,

        address by,

        uint256 amount,

        bytes32 reference

    );



    // proof of requested deposit initiated by token holder

    event LogWithdrawal(

        address indexed from,

        uint256 amount

    );



    // proof of settled deposit

    event LogWithdrawSettled(

        address from,

        address by, // who settled

        uint256 amount, // settled amount, after fees, negative interest rates etc.

        uint256 originalAmount, // original amount withdrawn

        bytes32 withdrawTxHash, // hash of withdraw transaction

        bytes32 reference // reference number of withdraw operation at deposit manager

    );



    /// on destroying the tokens without withdraw (see `destroyTokens` function below)

    event LogDestroy(

        address indexed from,

        address by,

        uint256 amount

    );



    ////////////////////////

    // Modifiers

    ////////////////////////



    modifier onlyIfDepositAllowed(address to, uint256 amount) {

        require(_tokenController.onGenerateTokens(msg.sender, to, amount));

        _;

    }



    modifier onlyIfWithdrawAllowed(address from, uint256 amount) {

        require(_tokenController.onDestroyTokens(msg.sender, from, amount));

        _;

    }



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        IAccessPolicy accessPolicy,

        IEthereumForkArbiter forkArbiter,

        ITokenController tokenController

    )

        Agreement(accessPolicy, forkArbiter)

        StandardToken()

        TokenMetadata(NAME, DECIMALS, SYMBOL, "")

        public

    {

        require(tokenController != ITokenController(0x0));

        _tokenController = tokenController;

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice deposit 'amount' of EUR-T to address 'to', attaching correlating `reference` to LogDeposit event

    /// @dev deposit may happen only in case 'to' can receive transfer in token controller

    ///     by default KYC is required to receive deposits

    function deposit(address to, uint256 amount, bytes32 reference)

        public

        only(ROLE_EURT_DEPOSIT_MANAGER)

        onlyIfDepositAllowed(to, amount)

        acceptAgreement(to)

    {

        require(to != address(0));

        _balances[to] = add(_balances[to], amount);

        _totalSupply = add(_totalSupply, amount);

        emit LogDeposit(to, msg.sender, amount, reference);

        emit Transfer(address(0), to, amount);

    }



    /// @notice runs many deposits within one transaction

    /// @dev deposit may happen only in case 'to' can receive transfer in token controller

    ///     by default KYC is required to receive deposits

    function depositMany(address[] to, uint256[] amount, bytes32[] reference)

        public

    {

        require(to.length == amount.length);

        require(to.length == reference.length);

        for (uint256 i = 0; i < to.length; i++) {

            deposit(to[i], amount[i], reference[i]);

        }

    }



    /// @notice withdraws 'amount' of EUR-T by burning required amount and providing a proof of whithdrawal

    /// @dev proof is provided in form of log entry. based on that proof deposit manager will make a bank transfer

    ///     by default controller will check the following: KYC and existence of working bank account

    function withdraw(uint256 amount)

        public

        onlyIfWithdrawAllowed(msg.sender, amount)

        acceptAgreement(msg.sender)

    {

        destroyTokensPrivate(msg.sender, amount);

        emit LogWithdrawal(msg.sender, amount);

    }



    /// @notice issued by deposit manager when withdraw request was settled. typicaly amount that could be settled will be lower

    ///         than amount withdrawn: banks charge negative interest rates and various fees that must be deduced

    ///         reference number is attached that may be used to identify withdraw operation at deposit manager

    function settleWithdraw(address from, uint256 amount, uint256 originalAmount, bytes32 withdrawTxHash, bytes32 reference)

        public

        only(ROLE_EURT_DEPOSIT_MANAGER)

    {

        emit LogWithdrawSettled(from, msg.sender, amount, originalAmount, withdrawTxHash, reference);

    }



    /// @notice this method allows to destroy EUR-T belonging to any account

    ///     note that EURO is fiat currency and is not trustless, EUR-T is also

    ///     just internal currency of Neufund platform, not general purpose stable coin

    ///     we need to be able to destroy EUR-T if ordered by authorities

    function destroy(address owner, uint256 amount)

        public

        only(ROLE_EURT_LEGAL_MANAGER)

    {

        destroyTokensPrivate(owner, amount);

        emit LogDestroy(owner, msg.sender, amount);

    }



    //

    // Implements ITokenControllerHook

    //



    function changeTokenController(address newController)

        public

    {

        require(_tokenController.onChangeTokenController(msg.sender, newController));

        _tokenController = ITokenController(newController);

        emit LogChangeTokenController(_tokenController, newController, msg.sender);

    }



    function tokenController()

        public

        constant

        returns (address)

    {

        return _tokenController;

    }



    //

    // Implements IERC223Token

    //

    function transfer(address to, uint256 amount, bytes data)

        public

        returns (bool success)

    {

        return ierc223TransferInternal(msg.sender, to, amount, data);

    }



    /// @notice convenience function to deposit and immediately transfer amount

    /// @param depositTo which account to deposit to and then transfer from

    /// @param transferTo where to transfer after deposit

    /// @param depositAmount amount to deposit

    /// @param transferAmount total amount to transfer, must be <= balance after deposit

    /// @dev intended to deposit from bank account and invest in ETO

    function depositAndTransfer(

        address depositTo,

        address transferTo,

        uint256 depositAmount,

        uint256 transferAmount,

        bytes data,

        bytes32 reference

    )

        public

        returns (bool success)

    {

        deposit(depositTo, depositAmount, reference);

        return ierc223TransferInternal(depositTo, transferTo, transferAmount, data);

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0xfb5c7e43558c4f3f5a2d87885881c9b10ff4be37e3308579c178bf4eaa2c29cd, 0);

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements MTokenController

    //



    function mOnTransfer(

        address from,

        address to,

        uint256 amount

    )

        internal

        acceptAgreement(from)

        returns (bool allow)

    {

        address broker = msg.sender;

        if (broker != from) {

            // if called by the depositor (deposit and send), ignore the broker flag

            bool isDepositor = accessPolicy().allowed(msg.sender, ROLE_EURT_DEPOSIT_MANAGER, this, msg.sig);

            // this is not very clean but alternative (give brokerage rights to all depositors) is maintenance hell

            if (isDepositor) {

                broker = from;

            }

        }

        return _tokenController.onTransfer(broker, from, to, amount);

    }



    function mOnApprove(

        address owner,

        address spender,

        uint256 amount

    )

        internal

        acceptAgreement(owner)

        returns (bool allow)

    {

        return _tokenController.onApprove(owner, spender, amount);

    }



    function mAllowanceOverride(

        address owner,

        address spender

    )

        internal

        constant

        returns (uint256)

    {

        return _tokenController.onAllowance(owner, spender);

    }



    //

    // Observes MAgreement internal interface

    //



    /// @notice euro token is legally represented by separate entity ROLE_EURT_LEGAL_MANAGER

    function mCanAmend(address legalRepresentative)

        internal

        returns (bool)

    {

        return accessPolicy().allowed(legalRepresentative, ROLE_EURT_LEGAL_MANAGER, this, msg.sig);

    }



    ////////////////////////

    // Private functions

    ////////////////////////



    function destroyTokensPrivate(address owner, uint256 amount)

        private

    {

        require(_balances[owner] >= amount);

        _balances[owner] = sub(_balances[owner], amount);

        _totalSupply = sub(_totalSupply, amount);

        emit Transfer(owner, address(0), amount);

    }



    /// @notice internal transfer function that checks permissions and calls the tokenFallback

    function ierc223TransferInternal(address from, address to, uint256 amount, bytes data)

        private

        returns (bool success)

    {

        BasicToken.mTransfer(from, to, amount);



        // Notify the receiving contract.

        if (isContract(to)) {

            // in case of re-entry (1) transfer is done (2) msg.sender is different

            IERC223Callback(to).tokenFallback(from, amount, data);

        }

        return true;

    }

}



/// @title set terms of Platform (investor's network) of the ETO

contract PlatformTerms is Math, IContractId {



    ////////////////////////

    // Constants

    ////////////////////////



    // fraction of fee deduced on successful ETO (see Math.sol for fraction definition)

    uint256 public constant PLATFORM_FEE_FRACTION = 3 * 10**16;

    // fraction of tokens deduced on succesful ETO

    uint256 public constant TOKEN_PARTICIPATION_FEE_FRACTION = 2 * 10**16;

    // share of Neumark reward platform operator gets

    // actually this is a divisor that splits Neumark reward in two parts

    // the results of division belongs to platform operator, the remaining reward part belongs to investor

    uint256 public constant PLATFORM_NEUMARK_SHARE = 2; // 50:50 division

    // ICBM investors whitelisted by default

    bool public constant IS_ICBM_INVESTOR_WHITELISTED = true;



    // minimum ticket size Platform accepts in EUR ULPS

    uint256 public constant MIN_TICKET_EUR_ULPS = 100 * 10**18;

    // maximum ticket size Platform accepts in EUR ULPS

    // no max ticket in general prospectus regulation

    // uint256 public constant MAX_TICKET_EUR_ULPS = 10000000 * 10**18;



    // min duration from setting the date to ETO start

    uint256 public constant DATE_TO_WHITELIST_MIN_DURATION = 7 days;

    // token rate expires after

    uint256 public constant TOKEN_RATE_EXPIRES_AFTER = 4 hours;



    // duration constraints

    uint256 public constant MIN_WHITELIST_DURATION = 0 days;

    uint256 public constant MAX_WHITELIST_DURATION = 30 days;

    uint256 public constant MIN_PUBLIC_DURATION = 0 days;

    uint256 public constant MAX_PUBLIC_DURATION = 60 days;



    // minimum length of whole offer

    uint256 public constant MIN_OFFER_DURATION = 1 days;

    // quarter should be enough for everyone

    uint256 public constant MAX_OFFER_DURATION = 90 days;



    uint256 public constant MIN_SIGNING_DURATION = 14 days;

    uint256 public constant MAX_SIGNING_DURATION = 60 days;



    uint256 public constant MIN_CLAIM_DURATION = 7 days;

    uint256 public constant MAX_CLAIM_DURATION = 30 days;



    // time after which claimable tokens become recycleable in fee disbursal pool

    uint256 public constant DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION = 4 * 365 days;



    ////////////////////////

    // Public Function

    ////////////////////////



    // calculates investor's and platform operator's neumarks from total reward

    function calculateNeumarkDistribution(uint256 rewardNmk)

        public

        pure

        returns (uint256 platformNmk, uint256 investorNmk)

    {

        // round down - platform may get 1 wei less than investor

        platformNmk = rewardNmk / PLATFORM_NEUMARK_SHARE;

        // rewardNmk > platformNmk always

        return (platformNmk, rewardNmk - platformNmk);

    }



    function calculatePlatformTokenFee(uint256 tokenAmount)

        public

        pure

        returns (uint256)

    {

        // mind tokens having 0 precision

        return proportion(tokenAmount, TOKEN_PARTICIPATION_FEE_FRACTION, 10**18);

    }



    function calculatePlatformFee(uint256 amount)

        public

        pure

        returns (uint256)

    {

        return decimalFraction(amount, PLATFORM_FEE_FRACTION);

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x95482babc4e32de6c4dc3910ee7ae62c8e427efde6bc4e9ce0d6d93e24c39323, 1);

    }

}



/// @title serialization of basic types from/to bytes

contract Serialization {



    ////////////////////////

    // Internal functions

    ////////////////////////

    function decodeAddress(bytes b)

        internal

        pure

        returns (address a)

    {

        require(b.length == 20);

        assembly {

            // load memory area that is address "carved out" of 64 byte bytes. prefix is zeroed

            a := and(mload(add(b, 20)), 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

        }

    }



    function decodeAddressUInt256(bytes b)

        internal

        pure

        returns (address a, uint256 i)

    {

        require(b.length == 52);

        assembly {

            // load memory area that is address "carved out" of 64 byte bytes. prefix is zeroed

            a := and(mload(add(b, 20)), 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

            i := mload(add(b, 52))

        }

    }

}



/// @title old ERC223 callback function

/// @dev as used in Neumark and ICBMEtherToken

contract IERC223LegacyCallback {



    ////////////////////////

    // Public functions

    ////////////////////////



    function onTokenTransfer(address from, uint256 amount, bytes data)

        public;



}



/// @title disburse payment token amount to snapshot token holders

/// @dev payment token received via ERC223 Transfer

contract IFeeDisbursal is IERC223Callback {

    // TODO: declare interface

    function claim() public;



    function recycle() public;

}



/// @title granular fee disbursal controller

contract IFeeDisbursalController is

    IContractId

{





    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice check whether claimer can accept disbursal offer

    function onAccept(address /*token*/, address /*proRataToken*/, address claimer)

        public

        constant

        returns (bool allow);



    /// @notice check whether claimer can reject disbursal offer

    function onReject(address /*token*/, address /*proRataToken*/, address claimer)

        public

        constant

        returns (bool allow);



    /// @notice check wether this disbursal can happen

    function onDisburse(address token, address disburser, uint256 amount, address proRataToken, uint256 recycleAfterPeriod)

        public

        constant

        returns (bool allow);



    /// @notice check wether this recycling can happen

    function onRecycle(address token, address /*proRataToken*/, address[] investors, uint256 until)

        public

        constant

        returns (bool allow);



    /// @notice check wether the disbursal controller may be changed

    function onChangeFeeDisbursalController(address sender, IFeeDisbursalController newController)

        public

        constant

        returns (bool);



}



/// @title access to snapshots of a token

/// @notice allows to implement complex token holder rights like revenue disbursal or voting

/// @notice snapshots are series of values with assigned ids. ids increase strictly. particular id mechanism is not assumed

contract ITokenSnapshots {



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice Total amount of tokens at a specific `snapshotId`.

    /// @param snapshotId of snapshot at which totalSupply is queried

    /// @return The total amount of tokens at `snapshotId`

    /// @dev reverts on snapshotIds greater than currentSnapshotId()

    /// @dev returns 0 for snapshotIds less than snapshotId of first value

    function totalSupplyAt(uint256 snapshotId)

        public

        constant

        returns(uint256);



    /// @dev Queries the balance of `owner` at a specific `snapshotId`

    /// @param owner The address from which the balance will be retrieved

    /// @param snapshotId of snapshot at which the balance is queried

    /// @return The balance at `snapshotId`

    function balanceOfAt(address owner, uint256 snapshotId)

        public

        constant

        returns (uint256);



    /// @notice upper bound of series of snapshotIds for which there's a value in series

    /// @return snapshotId

    function currentSnapshotId()

        public

        constant

        returns (uint256);

}



/// @title describes layout of claims in 256bit records stored for identities

/// @dev intended to be derived by contracts requiring access to particular claims

contract IdentityRecord {



    ////////////////////////

    // Types

    ////////////////////////



    /// @dev here the idea is to have claims of size of uint256 and use this struct

    ///     to translate in and out of this struct. until we do not cross uint256 we

    ///     have binary compatibility

    struct IdentityClaims {

        bool isVerified; // 1 bit

        bool isSophisticatedInvestor; // 1 bit

        bool hasBankAccount; // 1 bit

        bool accountFrozen; // 1 bit

        // uint252 reserved

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    /// translates uint256 to struct

    function deserializeClaims(bytes32 data) internal pure returns (IdentityClaims memory claims) {

        // for memory layout of struct, each field below word length occupies whole word

        assembly {

            mstore(claims, and(data, 0x1))

            mstore(add(claims, 0x20), div(and(data, 0x2), 0x2))

            mstore(add(claims, 0x40), div(and(data, 0x4), 0x4))

            mstore(add(claims, 0x60), div(and(data, 0x8), 0x8))

        }

    }

}





/// @title interface storing and retrieve 256bit claims records for identity

/// actual format of record is decoupled from storage (except maximum size)

contract IIdentityRegistry {



    ////////////////////////

    // Events

    ////////////////////////



    /// provides information on setting claims

    event LogSetClaims(

        address indexed identity,

        bytes32 oldClaims,

        bytes32 newClaims

    );



    ////////////////////////

    // Public functions

    ////////////////////////



    /// get claims for identity

    function getClaims(address identity) public constant returns (bytes32);



    /// set claims for identity

    /// @dev odlClaims and newClaims used for optimistic locking. to override with newClaims

    ///     current claims must be oldClaims

    function setClaims(address identity, bytes32 oldClaims, bytes32 newClaims) public;

}



contract NeumarkIssuanceCurve {



    ////////////////////////

    // Constants

    ////////////////////////



    // maximum number of neumarks that may be created

    uint256 private constant NEUMARK_CAP = 1500000000000000000000000000;



    // initial neumark reward fraction (controls curve steepness)

    uint256 private constant INITIAL_REWARD_FRACTION = 6500000000000000000;



    // stop issuing new Neumarks above this Euro value (as it goes quickly to zero)

    uint256 private constant ISSUANCE_LIMIT_EUR_ULPS = 8300000000000000000000000000;



    // approximate curve linearly above this Euro value

    uint256 private constant LINEAR_APPROX_LIMIT_EUR_ULPS = 2100000000000000000000000000;

    uint256 private constant NEUMARKS_AT_LINEAR_LIMIT_ULPS = 1499832501287264827896539871;



    uint256 private constant TOT_LINEAR_NEUMARKS_ULPS = NEUMARK_CAP - NEUMARKS_AT_LINEAR_LIMIT_ULPS;

    uint256 private constant TOT_LINEAR_EUR_ULPS = ISSUANCE_LIMIT_EUR_ULPS - LINEAR_APPROX_LIMIT_EUR_ULPS;



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice returns additional amount of neumarks issued for euroUlps at totalEuroUlps

    /// @param totalEuroUlps actual curve position from which neumarks will be issued

    /// @param euroUlps amount against which neumarks will be issued

    function incremental(uint256 totalEuroUlps, uint256 euroUlps)

        public

        pure

        returns (uint256 neumarkUlps)

    {

        require(totalEuroUlps + euroUlps >= totalEuroUlps);

        uint256 from = cumulative(totalEuroUlps);

        uint256 to = cumulative(totalEuroUlps + euroUlps);

        // as expansion is not monotonic for large totalEuroUlps, assert below may fail

        // example: totalEuroUlps=1.999999999999999999999000000e+27 and euroUlps=50

        assert(to >= from);

        return to - from;

    }



    /// @notice returns amount of euro corresponding to burned neumarks

    /// @param totalEuroUlps actual curve position from which neumarks will be burned

    /// @param burnNeumarkUlps amount of neumarks to burn

    function incrementalInverse(uint256 totalEuroUlps, uint256 burnNeumarkUlps)

        public

        pure

        returns (uint256 euroUlps)

    {

        uint256 totalNeumarkUlps = cumulative(totalEuroUlps);

        require(totalNeumarkUlps >= burnNeumarkUlps);

        uint256 fromNmk = totalNeumarkUlps - burnNeumarkUlps;

        uint newTotalEuroUlps = cumulativeInverse(fromNmk, 0, totalEuroUlps);

        // yes, this may overflow due to non monotonic inverse function

        assert(totalEuroUlps >= newTotalEuroUlps);

        return totalEuroUlps - newTotalEuroUlps;

    }



    /// @notice returns amount of euro corresponding to burned neumarks

    /// @param totalEuroUlps actual curve position from which neumarks will be burned

    /// @param burnNeumarkUlps amount of neumarks to burn

    /// @param minEurUlps euro amount to start inverse search from, inclusive

    /// @param maxEurUlps euro amount to end inverse search to, inclusive

    function incrementalInverse(uint256 totalEuroUlps, uint256 burnNeumarkUlps, uint256 minEurUlps, uint256 maxEurUlps)

        public

        pure

        returns (uint256 euroUlps)

    {

        uint256 totalNeumarkUlps = cumulative(totalEuroUlps);

        require(totalNeumarkUlps >= burnNeumarkUlps);

        uint256 fromNmk = totalNeumarkUlps - burnNeumarkUlps;

        uint newTotalEuroUlps = cumulativeInverse(fromNmk, minEurUlps, maxEurUlps);

        // yes, this may overflow due to non monotonic inverse function

        assert(totalEuroUlps >= newTotalEuroUlps);

        return totalEuroUlps - newTotalEuroUlps;

    }



    /// @notice finds total amount of neumarks issued for given amount of Euro

    /// @dev binomial expansion does not guarantee monotonicity on uint256 precision for large euroUlps

    ///     function below is not monotonic

    function cumulative(uint256 euroUlps)

        public

        pure

        returns(uint256 neumarkUlps)

    {

        // Return the cap if euroUlps is above the limit.

        if (euroUlps >= ISSUANCE_LIMIT_EUR_ULPS) {

            return NEUMARK_CAP;

        }

        // use linear approximation above limit below

        // binomial expansion does not guarantee monotonicity on uint256 precision for large euroUlps

        if (euroUlps >= LINEAR_APPROX_LIMIT_EUR_ULPS) {

            // (euroUlps - LINEAR_APPROX_LIMIT_EUR_ULPS) is small so expression does not overflow

            return NEUMARKS_AT_LINEAR_LIMIT_ULPS + (TOT_LINEAR_NEUMARKS_ULPS * (euroUlps - LINEAR_APPROX_LIMIT_EUR_ULPS)) / TOT_LINEAR_EUR_ULPS;

        }



        // Approximate cap-cap��(1-1/D)^n using the Binomial expansion

        // http://galileo.phys.virginia.edu/classes/152.mf1i.spring02/Exponential_Function.htm

        // Function[imax, -CAP*Sum[(-IR*EUR/CAP)^i/Factorial[i], {i, imax}]]

        // which may be simplified to

        // Function[imax, -CAP*Sum[(EUR)^i/(Factorial[i]*(-d)^i), {i, 1, imax}]]

        // where d = cap/initial_reward

        uint256 d = 230769230769230769230769231; // NEUMARK_CAP / INITIAL_REWARD_FRACTION

        uint256 term = NEUMARK_CAP;

        uint256 sum = 0;

        uint256 denom = d;

        do assembly {

            // We use assembler primarily to avoid the expensive

            // divide-by-zero check solc inserts for the / operator.

            term  := div(mul(term, euroUlps), denom)

            sum   := add(sum, term)

            denom := add(denom, d)

            // sub next term as we have power of negative value in the binomial expansion

            term  := div(mul(term, euroUlps), denom)

            sum   := sub(sum, term)

            denom := add(denom, d)

        } while (term != 0);

        return sum;

    }



    /// @notice find issuance curve inverse by binary search

    /// @param neumarkUlps neumark amount to compute inverse for

    /// @param minEurUlps minimum search range for the inverse, inclusive

    /// @param maxEurUlps maxium search range for the inverse, inclusive

    /// @dev in case of approximate search (no exact inverse) upper element of minimal search range is returned

    /// @dev in case of many possible inverses, the lowest one will be used (if range permits)

    /// @dev corresponds to a linear search that returns first euroUlp value that has cumulative() equal or greater than neumarkUlps

    function cumulativeInverse(uint256 neumarkUlps, uint256 minEurUlps, uint256 maxEurUlps)

        public

        pure

        returns (uint256 euroUlps)

    {

        require(maxEurUlps >= minEurUlps);

        require(cumulative(minEurUlps) <= neumarkUlps);

        require(cumulative(maxEurUlps) >= neumarkUlps);

        uint256 min = minEurUlps;

        uint256 max = maxEurUlps;



        // Binary search

        while (max > min) {

            uint256 mid = (max + min) / 2;

            uint256 val = cumulative(mid);

            // exact solution should not be used, a late points of the curve when many euroUlps are needed to

            // increase by one nmkUlp this will lead to  "indeterministic" inverse values that depend on the initial min and max

            // and further binary division -> you can land at any of the euro value that is mapped to the same nmk value

            // with condition below removed, binary search will point to the lowest eur value possible which is good because it cannot be exploited even with 0 gas costs

            /* if (val == neumarkUlps) {

                return mid;

            }*/

            // NOTE: approximate search (no inverse) must return upper element of the final range

            //  last step of approximate search is always (min, min+1) so new mid is (2*min+1)/2 => min

            //  so new min = mid + 1 = max which was upper range. and that ends the search

            // NOTE: when there are multiple inverses for the same neumarkUlps, the `max` will be dragged down

            //  by `max = mid` expression to the lowest eur value of inverse. works only for ranges that cover all points of multiple inverse

            if (val < neumarkUlps) {

                min = mid + 1;

            } else {

                max = mid;

            }

        }

        // NOTE: It is possible that there is no inverse

        //  for example curve(0) = 0 and curve(1) = 6, so

        //  there is no value y such that curve(y) = 5.

        //  When there is no inverse, we must return upper element of last search range.

        //  This has the effect of reversing the curve less when

        //  burning Neumarks. This ensures that Neumarks can always

        //  be burned. It also ensure that the total supply of Neumarks

        //  remains below the cap.

        return max;

    }



    function neumarkCap()

        public

        pure

        returns (uint256)

    {

        return NEUMARK_CAP;

    }



    function initialRewardFraction()

        public

        pure

        returns (uint256)

    {

        return INITIAL_REWARD_FRACTION;

    }

}



/// @title advances snapshot id on demand

/// @dev see Snapshot folder for implementation examples ie. DailyAndSnapshotable contract

contract ISnapshotable {



    ////////////////////////

    // Events

    ////////////////////////



    /// @dev should log each new snapshot id created, including snapshots created automatically via MSnapshotPolicy

    event LogSnapshotCreated(uint256 snapshotId);



    ////////////////////////

    // Public functions

    ////////////////////////



    /// always creates new snapshot id which gets returned

    /// however, there is no guarantee that any snapshot will be created with this id, this depends on the implementation of MSnaphotPolicy

    function createSnapshot()

        public

        returns (uint256);



    /// upper bound of series snapshotIds for which there's a value

    function currentSnapshotId()

        public

        constant

        returns (uint256);

}



/// @title Abstracts snapshot id creation logics

/// @dev Mixin (internal interface) of the snapshot policy which abstracts snapshot id creation logics from Snapshot contract

/// @dev to be implemented and such implementation should be mixed with Snapshot-derived contract, see EveryBlock for simplest example of implementation and StandardSnapshotToken

contract MSnapshotPolicy {



    ////////////////////////

    // Internal functions

    ////////////////////////



    // The snapshot Ids need to be strictly increasing.

    // Whenever the snaspshot id changes, a new snapshot will be created.

    // As long as the same snapshot id is being returned, last snapshot will be updated as this indicates that snapshot id didn't change

    //

    // Values passed to `hasValueAt` and `valuteAt` are required

    // to be less or equal to `mCurrentSnapshotId()`.

    function mAdvanceSnapshotId()

        internal

        returns (uint256);



    // this is a version of mAdvanceSnapshotId that does not modify state but MUST return the same value

    // it is required to implement ITokenSnapshots interface cleanly

    function mCurrentSnapshotId()

        internal

        constant

        returns (uint256);



}



/// @title creates new snapshot id on each day boundary

/// @dev snapshot id is unix timestamp of current day boundary

contract Daily is MSnapshotPolicy {



    ////////////////////////

    // Constants

    ////////////////////////



    // Floor[2**128 / 1 days]

    uint256 private MAX_TIMESTAMP = 3938453320844195178974243141571391;



    ////////////////////////

    // Constructor

    ////////////////////////



    /// @param start snapshotId from which to start generating values, used to prevent cloning from incompatible schemes

    /// @dev start must be for the same day or 0, required for token cloning

    constructor(uint256 start) internal {

        // 0 is invalid value as we are past unix epoch

        if (start > 0) {

            uint256 base = dayBase(uint128(block.timestamp));

            // must be within current day base

            require(start >= base);

            // dayBase + 2**128 will not overflow as it is based on block.timestamp

            require(start < base + 2**128);

        }

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    function snapshotAt(uint256 timestamp)

        public

        constant

        returns (uint256)

    {

        require(timestamp < MAX_TIMESTAMP);



        return dayBase(uint128(timestamp));

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements MSnapshotPolicy

    //



    function mAdvanceSnapshotId()

        internal

        returns (uint256)

    {

        return mCurrentSnapshotId();

    }



    function mCurrentSnapshotId()

        internal

        constant

        returns (uint256)

    {

        // disregard overflows on block.timestamp, see MAX_TIMESTAMP

        return dayBase(uint128(block.timestamp));

    }



    function dayBase(uint128 timestamp)

        internal

        pure

        returns (uint256)

    {

        // Round down to the start of the day (00:00 UTC) and place in higher 128bits

        return 2**128 * (uint256(timestamp) / 1 days);

    }

}



/// @title creates snapshot id on each day boundary and allows to create additional snapshots within a given day

/// @dev snapshots are encoded in single uint256, where high 128 bits represents a day number (from unix epoch) and low 128 bits represents additional snapshots within given day create via ISnapshotable

contract DailyAndSnapshotable is

    Daily,

    ISnapshotable

{



    ////////////////////////

    // Mutable state

    ////////////////////////



    uint256 private _currentSnapshotId;



    ////////////////////////

    // Constructor

    ////////////////////////



    /// @param start snapshotId from which to start generating values

    /// @dev start must be for the same day or 0, required for token cloning

    constructor(uint256 start)

        internal

        Daily(start)

    {

        if (start > 0) {

            _currentSnapshotId = start;

        }

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    //

    // Implements ISnapshotable

    //



    function createSnapshot()

        public

        returns (uint256)

    {

        uint256 base = dayBase(uint128(block.timestamp));



        if (base > _currentSnapshotId) {

            // New day has started, create snapshot for midnight

            _currentSnapshotId = base;

        } else {

            // within single day, increase counter (assume 2**128 will not be crossed)

            _currentSnapshotId += 1;

        }



        // Log and return

        emit LogSnapshotCreated(_currentSnapshotId);

        return _currentSnapshotId;

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements MSnapshotPolicy

    //



    function mAdvanceSnapshotId()

        internal

        returns (uint256)

    {

        uint256 base = dayBase(uint128(block.timestamp));



        // New day has started

        if (base > _currentSnapshotId) {

            _currentSnapshotId = base;

            emit LogSnapshotCreated(base);

        }



        return _currentSnapshotId;

    }



    function mCurrentSnapshotId()

        internal

        constant

        returns (uint256)

    {

        uint256 base = dayBase(uint128(block.timestamp));



        return base > _currentSnapshotId ? base : _currentSnapshotId;

    }

}



/// @title Reads and writes snapshots

/// @dev Manages reading and writing a series of values, where each value has assigned a snapshot id for access to historical data

/// @dev may be added to any contract to provide snapshotting mechanism. should be mixed in with any of MSnapshotPolicy implementations to customize snapshot creation mechanics

///     observes MSnapshotPolicy

/// based on MiniMe token

contract Snapshot is MSnapshotPolicy {



    ////////////////////////

    // Types

    ////////////////////////



    /// @dev `Values` is the structure that attaches a snapshot id to a

    ///  given value, the snapshot id attached is the one that last changed the

    ///  value

    struct Values {



        // `snapshotId` is the snapshot id that the value was generated at

        uint256 snapshotId;



        // `value` at a specific snapshot id

        uint256 value;

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    function hasValue(

        Values[] storage values

    )

        internal

        constant

        returns (bool)

    {

        return values.length > 0;

    }



    /// @dev makes sure that 'snapshotId' between current snapshot id (mCurrentSnapshotId) and first snapshot id. this guarantees that getValueAt returns value from one of the snapshots.

    function hasValueAt(

        Values[] storage values,

        uint256 snapshotId

    )

        internal

        constant

        returns (bool)

    {

        require(snapshotId <= mCurrentSnapshotId());

        return values.length > 0 && values[0].snapshotId <= snapshotId;

    }



    /// gets last value in the series

    function getValue(

        Values[] storage values,

        uint256 defaultValue

    )

        internal

        constant

        returns (uint256)

    {

        if (values.length == 0) {

            return defaultValue;

        } else {

            uint256 last = values.length - 1;

            return values[last].value;

        }

    }



    /// @dev `getValueAt` retrieves value at a given snapshot id

    /// @param values The series of values being queried

    /// @param snapshotId Snapshot id to retrieve the value at

    /// @return Value in series being queried

    function getValueAt(

        Values[] storage values,

        uint256 snapshotId,

        uint256 defaultValue

    )

        internal

        constant

        returns (uint256)

    {

        require(snapshotId <= mCurrentSnapshotId());



        // Empty value

        if (values.length == 0) {

            return defaultValue;

        }



        // Shortcut for the out of bounds snapshots

        uint256 last = values.length - 1;

        uint256 lastSnapshot = values[last].snapshotId;

        if (snapshotId >= lastSnapshot) {

            return values[last].value;

        }

        uint256 firstSnapshot = values[0].snapshotId;

        if (snapshotId < firstSnapshot) {

            return defaultValue;

        }

        // Binary search of the value in the array

        uint256 min = 0;

        uint256 max = last;

        while (max > min) {

            uint256 mid = (max + min + 1) / 2;

            // must always return lower indice for approximate searches

            if (values[mid].snapshotId <= snapshotId) {

                min = mid;

            } else {

                max = mid - 1;

            }

        }

        return values[min].value;

    }



    /// @dev `setValue` used to update sequence at next snapshot

    /// @param values The sequence being updated

    /// @param value The new last value of sequence

    function setValue(

        Values[] storage values,

        uint256 value

    )

        internal

    {

        // TODO: simplify or break into smaller functions



        uint256 currentSnapshotId = mAdvanceSnapshotId();

        // Always create a new entry if there currently is no value

        bool empty = values.length == 0;

        if (empty) {

            // Create a new entry

            values.push(

                Values({

                    snapshotId: currentSnapshotId,

                    value: value

                })

            );

            return;

        }



        uint256 last = values.length - 1;

        bool hasNewSnapshot = values[last].snapshotId < currentSnapshotId;

        if (hasNewSnapshot) {



            // Do nothing if the value was not modified

            bool unmodified = values[last].value == value;

            if (unmodified) {

                return;

            }



            // Create new entry

            values.push(

                Values({

                    snapshotId: currentSnapshotId,

                    value: value

                })

            );

        } else {



            // We are updating the currentSnapshotId

            bool previousUnmodified = last > 0 && values[last - 1].value == value;

            if (previousUnmodified) {

                // Remove current snapshot if current value was set to previous value

                delete values[last];

                values.length--;

                return;

            }



            // Overwrite next snapshot entry

            values[last].value = value;

        }

    }

}



/// @title represents link between cloned and parent token

/// @dev when token is clone from other token, initial balances of the cloned token

///     correspond to balances of parent token at the moment of parent snapshot id specified

/// @notice please note that other tokens beside snapshot token may be cloned

contract IClonedTokenParent is ITokenSnapshots {



    ////////////////////////

    // Public functions

    ////////////////////////





    /// @return address of parent token, address(0) if root

    /// @dev parent token does not need to clonable, nor snapshottable, just a normal token

    function parentToken()

        public

        constant

        returns(IClonedTokenParent parent);



    /// @return snapshot at wchich initial token distribution was taken

    function parentSnapshotId()

        public

        constant

        returns(uint256 snapshotId);

}



/// @title token with snapshots and transfer functionality

/// @dev observes MTokenTransferController interface

///     observes ISnapshotToken interface

///     implementes MTokenTransfer interface

contract BasicSnapshotToken is

    MTokenTransfer,

    MTokenTransferController,

    IClonedTokenParent,

    IBasicToken,

    Snapshot

{

    ////////////////////////

    // Immutable state

    ////////////////////////



    // `PARENT_TOKEN` is the Token address that was cloned to produce this token;

    //  it will be 0x0 for a token that was not cloned

    IClonedTokenParent private PARENT_TOKEN;



    // `PARENT_SNAPSHOT_ID` is the snapshot id from the Parent Token that was

    //  used to determine the initial distribution of the cloned token

    uint256 private PARENT_SNAPSHOT_ID;



    ////////////////////////

    // Mutable state

    ////////////////////////



    // `balances` is the map that tracks the balance of each address, in this

    //  contract when the balance changes the snapshot id that the change

    //  occurred is also included in the map

    mapping (address => Values[]) internal _balances;



    // Tracks the history of the `totalSupply` of the token

    Values[] internal _totalSupplyValues;



    ////////////////////////

    // Constructor

    ////////////////////////



    /// @notice Constructor to create snapshot token

    /// @param parentToken Address of the parent token, set to 0x0 if it is a

    ///  new token

    /// @param parentSnapshotId at which snapshot id clone was created, set to 0 to clone at upper bound

    /// @dev please not that as long as cloned token does not overwrite value at current snapshot id, it will refer

    ///     to parent token at which this snapshot still may change until snapshot id increases. for that time tokens are coupled

    ///     this is prevented by parentSnapshotId value of parentToken.currentSnapshotId() - 1 being the maxiumum

    ///     see SnapshotToken.js test to learn consequences coupling has.

    constructor(

        IClonedTokenParent parentToken,

        uint256 parentSnapshotId

    )

        Snapshot()

        internal

    {

        PARENT_TOKEN = parentToken;

        if (parentToken == address(0)) {

            require(parentSnapshotId == 0);

        } else {

            if (parentSnapshotId == 0) {

                require(parentToken.currentSnapshotId() > 0);

                PARENT_SNAPSHOT_ID = parentToken.currentSnapshotId() - 1;

            } else {

                PARENT_SNAPSHOT_ID = parentSnapshotId;

            }

        }

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    //

    // Implements IBasicToken

    //



    /// @dev This function makes it easy to get the total number of tokens

    /// @return The total number of tokens

    function totalSupply()

        public

        constant

        returns (uint256)

    {

        return totalSupplyAtInternal(mCurrentSnapshotId());

    }



    /// @param owner The address that's balance is being requested

    /// @return The balance of `owner` at the current block

    function balanceOf(address owner)

        public

        constant

        returns (uint256 balance)

    {

        return balanceOfAtInternal(owner, mCurrentSnapshotId());

    }



    /// @notice Send `amount` tokens to `to` from `msg.sender`

    /// @param to The address of the recipient

    /// @param amount The amount of tokens to be transferred

    /// @return True if the transfer was successful, reverts in any other case

    function transfer(address to, uint256 amount)

        public

        returns (bool success)

    {

        mTransfer(msg.sender, to, amount);

        return true;

    }



    //

    // Implements ITokenSnapshots

    //



    function totalSupplyAt(uint256 snapshotId)

        public

        constant

        returns(uint256)

    {

        return totalSupplyAtInternal(snapshotId);

    }



    function balanceOfAt(address owner, uint256 snapshotId)

        public

        constant

        returns (uint256)

    {

        return balanceOfAtInternal(owner, snapshotId);

    }



    function currentSnapshotId()

        public

        constant

        returns (uint256)

    {

        return mCurrentSnapshotId();

    }



    //

    // Implements IClonedTokenParent

    //



    function parentToken()

        public

        constant

        returns(IClonedTokenParent parent)

    {

        return PARENT_TOKEN;

    }



    /// @return snapshot at wchich initial token distribution was taken

    function parentSnapshotId()

        public

        constant

        returns(uint256 snapshotId)

    {

        return PARENT_SNAPSHOT_ID;

    }



    //

    // Other public functions

    //



    /// @notice gets all token balances of 'owner'

    /// @dev intended to be called via eth_call where gas limit is not an issue

    function allBalancesOf(address owner)

        external

        constant

        returns (uint256[2][])

    {

        /* very nice and working implementation below,

        // copy to memory

        Values[] memory values = _balances[owner];

        do assembly {

            // in memory structs have simple layout where every item occupies uint256

            balances := values

        } while (false);*/



        Values[] storage values = _balances[owner];

        uint256[2][] memory balances = new uint256[2][](values.length);

        for(uint256 ii = 0; ii < values.length; ++ii) {

            balances[ii] = [values[ii].snapshotId, values[ii].value];

        }



        return balances;

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    function totalSupplyAtInternal(uint256 snapshotId)

        internal

        constant

        returns(uint256)

    {

        Values[] storage values = _totalSupplyValues;



        // If there is a value, return it, reverts if value is in the future

        if (hasValueAt(values, snapshotId)) {

            return getValueAt(values, snapshotId, 0);

        }



        // Try parent contract at or before the fork

        if (address(PARENT_TOKEN) != 0) {

            uint256 earlierSnapshotId = PARENT_SNAPSHOT_ID > snapshotId ? snapshotId : PARENT_SNAPSHOT_ID;

            return PARENT_TOKEN.totalSupplyAt(earlierSnapshotId);

        }



        // Default to an empty balance

        return 0;

    }



    // get balance at snapshot if with continuation in parent token

    function balanceOfAtInternal(address owner, uint256 snapshotId)

        internal

        constant

        returns (uint256)

    {

        Values[] storage values = _balances[owner];



        // If there is a value, return it, reverts if value is in the future

        if (hasValueAt(values, snapshotId)) {

            return getValueAt(values, snapshotId, 0);

        }



        // Try parent contract at or before the fork

        if (PARENT_TOKEN != address(0)) {

            uint256 earlierSnapshotId = PARENT_SNAPSHOT_ID > snapshotId ? snapshotId : PARENT_SNAPSHOT_ID;

            return PARENT_TOKEN.balanceOfAt(owner, earlierSnapshotId);

        }



        // Default to an empty balance

        return 0;

    }



    //

    // Implements MTokenTransfer

    //



    /// @dev This is the actual transfer function in the token contract, it can

    ///  only be called by other functions in this contract.

    /// @param from The address holding the tokens being transferred

    /// @param to The address of the recipient

    /// @param amount The amount of tokens to be transferred

    /// @return True if the transfer was successful, reverts in any other case

    function mTransfer(

        address from,

        address to,

        uint256 amount

    )

        internal

    {

        // never send to address 0

        require(to != address(0));

        // block transfers in clone that points to future/current snapshots of parent token

        require(parentToken() == address(0) || parentSnapshotId() < parentToken().currentSnapshotId());

        // Alerts the token controller of the transfer

        require(mOnTransfer(from, to, amount));



        // If the amount being transfered is more than the balance of the

        //  account the transfer reverts

        uint256 previousBalanceFrom = balanceOf(from);

        require(previousBalanceFrom >= amount);



        // First update the balance array with the new value for the address

        //  sending the tokens

        uint256 newBalanceFrom = previousBalanceFrom - amount;

        setValue(_balances[from], newBalanceFrom);



        // Then update the balance array with the new value for the address

        //  receiving the tokens

        uint256 previousBalanceTo = balanceOf(to);

        uint256 newBalanceTo = previousBalanceTo + amount;

        assert(newBalanceTo >= previousBalanceTo); // Check for overflow

        setValue(_balances[to], newBalanceTo);



        // An event to make the transfer easy to find on the blockchain

        emit Transfer(from, to, amount);

    }

}



/// @title token generation and destruction

/// @dev internal interface providing token generation and destruction, see MintableSnapshotToken for implementation

contract MTokenMint {



    ////////////////////////

    // Internal functions

    ////////////////////////



    /// @notice Generates `amount` tokens that are assigned to `owner`

    /// @param owner The address that will be assigned the new tokens

    /// @param amount The quantity of tokens generated

    /// @dev reverts if tokens could not be generated

    function mGenerateTokens(address owner, uint256 amount)

        internal;



    /// @notice Burns `amount` tokens from `owner`

    /// @param owner The address that will lose the tokens

    /// @param amount The quantity of tokens to burn

    /// @dev reverts if tokens could not be destroyed

    function mDestroyTokens(address owner, uint256 amount)

        internal;

}



/// @title basic snapshot token with facitilites to generate and destroy tokens

/// @dev implementes MTokenMint, does not expose any public functions that create/destroy tokens

contract MintableSnapshotToken is

    BasicSnapshotToken,

    MTokenMint

{



    ////////////////////////

    // Constructor

    ////////////////////////



    /// @notice Constructor to create a MintableSnapshotToken

    /// @param parentToken Address of the parent token, set to 0x0 if it is a

    ///  new token

    constructor(

        IClonedTokenParent parentToken,

        uint256 parentSnapshotId

    )

        BasicSnapshotToken(parentToken, parentSnapshotId)

        internal

    {}



    /// @notice Generates `amount` tokens that are assigned to `owner`

    /// @param owner The address that will be assigned the new tokens

    /// @param amount The quantity of tokens generated

    function mGenerateTokens(address owner, uint256 amount)

        internal

    {

        // never create for address 0

        require(owner != address(0));

        // block changes in clone that points to future/current snapshots of patent token

        require(parentToken() == address(0) || parentSnapshotId() < parentToken().currentSnapshotId());



        uint256 curTotalSupply = totalSupply();

        uint256 newTotalSupply = curTotalSupply + amount;

        require(newTotalSupply >= curTotalSupply); // Check for overflow



        uint256 previousBalanceTo = balanceOf(owner);

        uint256 newBalanceTo = previousBalanceTo + amount;

        assert(newBalanceTo >= previousBalanceTo); // Check for overflow



        setValue(_totalSupplyValues, newTotalSupply);

        setValue(_balances[owner], newBalanceTo);



        emit Transfer(0, owner, amount);

    }



    /// @notice Burns `amount` tokens from `owner`

    /// @param owner The address that will lose the tokens

    /// @param amount The quantity of tokens to burn

    function mDestroyTokens(address owner, uint256 amount)

        internal

    {

        // block changes in clone that points to future/current snapshots of patent token

        require(parentToken() == address(0) || parentSnapshotId() < parentToken().currentSnapshotId());



        uint256 curTotalSupply = totalSupply();

        require(curTotalSupply >= amount);



        uint256 previousBalanceFrom = balanceOf(owner);

        require(previousBalanceFrom >= amount);



        uint256 newTotalSupply = curTotalSupply - amount;

        uint256 newBalanceFrom = previousBalanceFrom - amount;

        setValue(_totalSupplyValues, newTotalSupply);

        setValue(_balances[owner], newBalanceFrom);



        emit Transfer(owner, 0, amount);

    }

}



/*

    Copyright 2016, Jordi Baylina

    Copyright 2017, Remco Bloemen, Marcin Rudolf



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <http://www.gnu.org/licenses/>.

 */

/// @title StandardSnapshotToken Contract

/// @author Jordi Baylina, Remco Bloemen, Marcin Rudolf

/// @dev This token contract's goal is to make it easy for anyone to clone this

///  token using the token distribution at a given block, this will allow DAO's

///  and DApps to upgrade their features in a decentralized manner without

///  affecting the original token

/// @dev It is ERC20 compliant, but still needs to under go further testing.

/// @dev Various contracts are composed to provide required functionality of this token, different compositions are possible

///     MintableSnapshotToken provides transfer, miniting and snapshotting functions

///     TokenAllowance provides approve/transferFrom functions

///     TokenMetadata adds name, symbol and other token metadata

/// @dev This token is still abstract, Snapshot, BasicSnapshotToken and TokenAllowance observe interfaces that must be implemented

///     MSnapshotPolicy - particular snapshot id creation mechanism

///     MTokenController - controlls approvals and transfers

///     see Neumark as an example

/// @dev implements ERC223 token transfer

contract StandardSnapshotToken is

    MintableSnapshotToken,

    TokenAllowance

{

    ////////////////////////

    // Constructor

    ////////////////////////



    /// @notice Constructor to create a MiniMeToken

    ///  is a new token

    /// param tokenName Name of the new token

    /// param decimalUnits Number of decimals of the new token

    /// param tokenSymbol Token Symbol for the new token

    constructor(

        IClonedTokenParent parentToken,

        uint256 parentSnapshotId

    )

        MintableSnapshotToken(parentToken, parentSnapshotId)

        TokenAllowance()

        internal

    {}

}



contract Neumark is

    AccessControlled,

    AccessRoles,

    Agreement,

    DailyAndSnapshotable,

    StandardSnapshotToken,

    TokenMetadata,

    IERC223Token,

    NeumarkIssuanceCurve,

    Reclaimable,

    IsContract

{



    ////////////////////////

    // Constants

    ////////////////////////



    string private constant TOKEN_NAME = "Neumark";



    uint8  private constant TOKEN_DECIMALS = 18;



    string private constant TOKEN_SYMBOL = "NEU";



    string private constant VERSION = "NMK_1.0";



    ////////////////////////

    // Mutable state

    ////////////////////////



    // disable transfers when Neumark is created

    bool private _transferEnabled = false;



    // at which point on curve new Neumarks will be created, see NeumarkIssuanceCurve contract

    // do not use to get total invested funds. see burn(). this is just a cache for expensive inverse function

    uint256 private _totalEurUlps;



    ////////////////////////

    // Events

    ////////////////////////



    event LogNeumarksIssued(

        address indexed owner,

        uint256 euroUlps,

        uint256 neumarkUlps

    );



    event LogNeumarksBurned(

        address indexed owner,

        uint256 euroUlps,

        uint256 neumarkUlps

    );



    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        IAccessPolicy accessPolicy,

        IEthereumForkArbiter forkArbiter

    )

        AccessRoles()

        Agreement(accessPolicy, forkArbiter)

        StandardSnapshotToken(

            IClonedTokenParent(0x0),

            0

        )

        TokenMetadata(

            TOKEN_NAME,

            TOKEN_DECIMALS,

            TOKEN_SYMBOL,

            VERSION

        )

        DailyAndSnapshotable(0)

        NeumarkIssuanceCurve()

        Reclaimable()

        public

    {}



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice issues new Neumarks to msg.sender with reward at current curve position

    ///     moves curve position by euroUlps

    ///     callable only by ROLE_NEUMARK_ISSUER

    function issueForEuro(uint256 euroUlps)

        public

        only(ROLE_NEUMARK_ISSUER)

        acceptAgreement(msg.sender)

        returns (uint256)

    {

        require(_totalEurUlps + euroUlps >= _totalEurUlps);

        uint256 neumarkUlps = incremental(_totalEurUlps, euroUlps);

        _totalEurUlps += euroUlps;

        mGenerateTokens(msg.sender, neumarkUlps);

        emit LogNeumarksIssued(msg.sender, euroUlps, neumarkUlps);

        return neumarkUlps;

    }



    /// @notice used by ROLE_NEUMARK_ISSUER to transer newly issued neumarks

    ///     typically to the investor and platform operator

    function distribute(address to, uint256 neumarkUlps)

        public

        only(ROLE_NEUMARK_ISSUER)

        acceptAgreement(to)

    {

        mTransfer(msg.sender, to, neumarkUlps);

    }



    /// @notice msg.sender can burn their Neumarks, curve is rolled back using inverse

    ///     curve. as a result cost of Neumark gets lower (reward is higher)

    function burn(uint256 neumarkUlps)

        public

        only(ROLE_NEUMARK_BURNER)

    {

        burnPrivate(neumarkUlps, 0, _totalEurUlps);

    }



    /// @notice executes as function above but allows to provide search range for low gas burning

    function burn(uint256 neumarkUlps, uint256 minEurUlps, uint256 maxEurUlps)

        public

        only(ROLE_NEUMARK_BURNER)

    {

        burnPrivate(neumarkUlps, minEurUlps, maxEurUlps);

    }



    function enableTransfer(bool enabled)

        public

        only(ROLE_TRANSFER_ADMIN)

    {

        _transferEnabled = enabled;

    }



    function createSnapshot()

        public

        only(ROLE_SNAPSHOT_CREATOR)

        returns (uint256)

    {

        return DailyAndSnapshotable.createSnapshot();

    }



    function transferEnabled()

        public

        constant

        returns (bool)

    {

        return _transferEnabled;

    }



    function totalEuroUlps()

        public

        constant

        returns (uint256)

    {

        return _totalEurUlps;

    }



    function incremental(uint256 euroUlps)

        public

        constant

        returns (uint256 neumarkUlps)

    {

        return incremental(_totalEurUlps, euroUlps);

    }



    //

    // Implements IERC223Token with IERC223Callback (onTokenTransfer) callback

    //



    // old implementation of ERC223 that was actual when ICBM was deployed

    // as Neumark is already deployed this function keeps old behavior for testing

    function transfer(address to, uint256 amount, bytes data)

        public

        returns (bool)

    {

        // it is necessary to point out implementation to be called

        BasicSnapshotToken.mTransfer(msg.sender, to, amount);



        // Notify the receiving contract.

        if (isContract(to)) {

            IERC223LegacyCallback(to).onTokenTransfer(msg.sender, amount, data);

        }

        return true;

    }



    ////////////////////////

    // Internal functions

    ////////////////////////



    //

    // Implements MTokenController

    //



    function mOnTransfer(

        address from,

        address, // to

        uint256 // amount

    )

        internal

        acceptAgreement(from)

        returns (bool allow)

    {

        // must have transfer enabled or msg.sender is Neumark issuer

        return _transferEnabled || accessPolicy().allowed(msg.sender, ROLE_NEUMARK_ISSUER, this, msg.sig);

    }



    function mOnApprove(

        address owner,

        address, // spender,

        uint256 // amount

    )

        internal

        acceptAgreement(owner)

        returns (bool allow)

    {

        return true;

    }



    ////////////////////////

    // Private functions

    ////////////////////////



    function burnPrivate(uint256 burnNeumarkUlps, uint256 minEurUlps, uint256 maxEurUlps)

        private

    {

        uint256 prevEuroUlps = _totalEurUlps;

        // burn first in the token to make sure balance/totalSupply is not crossed

        mDestroyTokens(msg.sender, burnNeumarkUlps);

        _totalEurUlps = cumulativeInverse(totalSupply(), minEurUlps, maxEurUlps);

        // actually may overflow on non-monotonic inverse

        assert(prevEuroUlps >= _totalEurUlps);

        uint256 euroUlps = prevEuroUlps - _totalEurUlps;

        emit LogNeumarksBurned(msg.sender, euroUlps, burnNeumarkUlps);

    }

}



/// @title disburse payment token amount to snapshot token holders

/// @dev payment token received via ERC223 Transfer

contract IPlatformPortfolio is IERC223Callback {

    // TODO: declare interface

}



contract ITokenExchangeRateOracle {

    /// @notice provides actual price of 'numeratorToken' in 'denominatorToken'

    ///     returns timestamp at which price was obtained in oracle

    function getExchangeRate(address numeratorToken, address denominatorToken)

        public

        constant

        returns (uint256 rateFraction, uint256 timestamp);



    /// @notice allows to retreive multiple exchange rates in once call

    function getExchangeRates(address[] numeratorTokens, address[] denominatorTokens)

        public

        constant

        returns (uint256[] rateFractions, uint256[] timestamps);

}



/// @title root of trust and singletons + known interface registry

/// provides a root which holds all interfaces platform trust, this includes

/// singletons - for which accessors are provided

/// collections of known instances of interfaces

/// @dev interfaces are identified by bytes4, see KnownInterfaces.sol

contract Universe is

    Agreement,

    IContractId,

    KnownInterfaces

{

    ////////////////////////

    // Events

    ////////////////////////



    /// raised on any change of singleton instance

    /// @dev for convenience we provide previous instance of singleton in replacedInstance

    event LogSetSingleton(

        bytes4 interfaceId,

        address instance,

        address replacedInstance

    );



    /// raised on add/remove interface instance in collection

    event LogSetCollectionInterface(

        bytes4 interfaceId,

        address instance,

        bool isSet

    );



    ////////////////////////

    // Mutable state

    ////////////////////////



    // mapping of known contracts to addresses of singletons

    mapping(bytes4 => address) private _singletons;



    // mapping of known interfaces to collections of contracts

    mapping(bytes4 =>

        mapping(address => bool)) private _collections; // solium-disable-line indentation



    // known instances

    mapping(address => bytes4[]) private _instances;





    ////////////////////////

    // Constructor

    ////////////////////////



    constructor(

        IAccessPolicy accessPolicy,

        IEthereumForkArbiter forkArbiter

    )

        Agreement(accessPolicy, forkArbiter)

        public

    {

        setSingletonPrivate(KNOWN_INTERFACE_ACCESS_POLICY, accessPolicy);

        setSingletonPrivate(KNOWN_INTERFACE_FORK_ARBITER, forkArbiter);

    }



    ////////////////////////

    // Public methods

    ////////////////////////



    /// get singleton instance for 'interfaceId'

    function getSingleton(bytes4 interfaceId)

        public

        constant

        returns (address)

    {

        return _singletons[interfaceId];

    }



    function getManySingletons(bytes4[] interfaceIds)

        public

        constant

        returns (address[])

    {

        address[] memory addresses = new address[](interfaceIds.length);

        uint256 idx;

        while(idx < interfaceIds.length) {

            addresses[idx] = _singletons[interfaceIds[idx]];

            idx += 1;

        }

        return addresses;

    }



    /// checks of 'instance' is instance of interface 'interfaceId'

    function isSingleton(bytes4 interfaceId, address instance)

        public

        constant

        returns (bool)

    {

        return _singletons[interfaceId] == instance;

    }



    /// checks if 'instance' is one of instances of 'interfaceId'

    function isInterfaceCollectionInstance(bytes4 interfaceId, address instance)

        public

        constant

        returns (bool)

    {

        return _collections[interfaceId][instance];

    }



    function isAnyOfInterfaceCollectionInstance(bytes4[] interfaceIds, address instance)

        public

        constant

        returns (bool)

    {

        uint256 idx;

        while(idx < interfaceIds.length) {

            if (_collections[interfaceIds[idx]][instance]) {

                return true;

            }

            idx += 1;

        }

        return false;

    }



    /// gets all interfaces of given instance

    function getInterfacesOfInstance(address instance)

        public

        constant

        returns (bytes4[] interfaces)

    {

        return _instances[instance];

    }



    /// sets 'instance' of singleton with interface 'interfaceId'

    function setSingleton(bytes4 interfaceId, address instance)

        public

        only(ROLE_UNIVERSE_MANAGER)

    {

        setSingletonPrivate(interfaceId, instance);

    }



    /// convenience method for setting many singleton instances

    function setManySingletons(bytes4[] interfaceIds, address[] instances)

        public

        only(ROLE_UNIVERSE_MANAGER)

    {

        require(interfaceIds.length == instances.length);

        uint256 idx;

        while(idx < interfaceIds.length) {

            setSingletonPrivate(interfaceIds[idx], instances[idx]);

            idx += 1;

        }

    }



    /// set or unset 'instance' with 'interfaceId' in collection of instances

    function setCollectionInterface(bytes4 interfaceId, address instance, bool set)

        public

        only(ROLE_UNIVERSE_MANAGER)

    {

        setCollectionPrivate(interfaceId, instance, set);

    }



    /// set or unset 'instance' in many collections of instances

    function setInterfaceInManyCollections(bytes4[] interfaceIds, address instance, bool set)

        public

        only(ROLE_UNIVERSE_MANAGER)

    {

        uint256 idx;

        while(idx < interfaceIds.length) {

            setCollectionPrivate(interfaceIds[idx], instance, set);

            idx += 1;

        }

    }



    /// set or unset array of collection

    function setCollectionsInterfaces(bytes4[] interfaceIds, address[] instances, bool[] set_flags)

        public

        only(ROLE_UNIVERSE_MANAGER)

    {

        require(interfaceIds.length == instances.length);

        require(interfaceIds.length == set_flags.length);

        uint256 idx;

        while(idx < interfaceIds.length) {

            setCollectionPrivate(interfaceIds[idx], instances[idx], set_flags[idx]);

            idx += 1;

        }

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x8b57bfe21a3ef4854e19d702063b6cea03fa514162f8ff43fde551f06372fefd, 0);

    }



    ////////////////////////

    // Getters

    ////////////////////////



    function accessPolicy() public constant returns (IAccessPolicy) {

        return IAccessPolicy(_singletons[KNOWN_INTERFACE_ACCESS_POLICY]);

    }



    function forkArbiter() public constant returns (IEthereumForkArbiter) {

        return IEthereumForkArbiter(_singletons[KNOWN_INTERFACE_FORK_ARBITER]);

    }



    function neumark() public constant returns (Neumark) {

        return Neumark(_singletons[KNOWN_INTERFACE_NEUMARK]);

    }



    function etherToken() public constant returns (IERC223Token) {

        return IERC223Token(_singletons[KNOWN_INTERFACE_ETHER_TOKEN]);

    }



    function euroToken() public constant returns (IERC223Token) {

        return IERC223Token(_singletons[KNOWN_INTERFACE_EURO_TOKEN]);

    }



    function etherLock() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_ETHER_LOCK];

    }



    function euroLock() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_EURO_LOCK];

    }



    function icbmEtherLock() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_ICBM_ETHER_LOCK];

    }



    function icbmEuroLock() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_ICBM_EURO_LOCK];

    }



    function identityRegistry() public constant returns (address) {

        return IIdentityRegistry(_singletons[KNOWN_INTERFACE_IDENTITY_REGISTRY]);

    }



    function tokenExchangeRateOracle() public constant returns (address) {

        return ITokenExchangeRateOracle(_singletons[KNOWN_INTERFACE_TOKEN_EXCHANGE_RATE_ORACLE]);

    }



    function feeDisbursal() public constant returns (address) {

        return IFeeDisbursal(_singletons[KNOWN_INTERFACE_FEE_DISBURSAL]);

    }



    function platformPortfolio() public constant returns (address) {

        return IPlatformPortfolio(_singletons[KNOWN_INTERFACE_PLATFORM_PORTFOLIO]);

    }



    function tokenExchange() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_TOKEN_EXCHANGE];

    }



    function gasExchange() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_GAS_EXCHANGE];

    }



    function platformTerms() public constant returns (address) {

        return _singletons[KNOWN_INTERFACE_PLATFORM_TERMS];

    }



    ////////////////////////

    // Private methods

    ////////////////////////



    function setSingletonPrivate(bytes4 interfaceId, address instance)

        private

    {

        require(interfaceId != KNOWN_INTERFACE_UNIVERSE, "NF_UNI_NO_UNIVERSE_SINGLETON");

        address replacedInstance = _singletons[interfaceId];

        // do nothing if not changing

        if (replacedInstance != instance) {

            dropInstance(replacedInstance, interfaceId);

            addInstance(instance, interfaceId);

            _singletons[interfaceId] = instance;

        }



        emit LogSetSingleton(interfaceId, instance, replacedInstance);

    }



    function setCollectionPrivate(bytes4 interfaceId, address instance, bool set)

        private

    {

        // do nothing if not changing

        if (_collections[interfaceId][instance] == set) {

            return;

        }

        _collections[interfaceId][instance] = set;

        if (set) {

            addInstance(instance, interfaceId);

        } else {

            dropInstance(instance, interfaceId);

        }

        emit LogSetCollectionInterface(interfaceId, instance, set);

    }



    function addInstance(address instance, bytes4 interfaceId)

        private

    {

        if (instance == address(0)) {

            // do not add null instance

            return;

        }

        bytes4[] storage current = _instances[instance];

        uint256 idx;

        while(idx < current.length) {

            // instancy has this interface already, do nothing

            if (current[idx] == interfaceId)

                return;

            idx += 1;

        }

        // new interface

        current.push(interfaceId);

    }



    function dropInstance(address instance, bytes4 interfaceId)

        private

    {

        if (instance == address(0)) {

            // do not drop null instance

            return;

        }

        bytes4[] storage current = _instances[instance];

        uint256 idx;

        uint256 last = current.length - 1;

        while(idx <= last) {

            if (current[idx] == interfaceId) {

                // delete element

                if (idx < last) {

                    // if not last element move last element to idx being deleted

                    current[idx] = current[last];

                }

                // delete last element

                current.length -= 1;

                return;

            }

            idx += 1;

        }

    }

}



/// @title granular fee disbursal contract

contract FeeDisbursal is

    IERC223Callback,

    IERC677Callback,

    IERC223LegacyCallback,

    ERC223LegacyCallbackCompat,

    Serialization,

    Math,

    KnownContracts,

    KnownInterfaces,

    IContractId

{



    ////////////////////////

    // Events

    ////////////////////////



    event LogDisbursalCreated(

        address indexed proRataToken,

        address indexed token,

        uint256 amount,

        uint256 recycleAfterDuration,

        address disburser,

        uint256 index

    );



    event LogDisbursalAccepted(

        address indexed claimer,

        address token,

        address proRataToken,

        uint256 amount,

        uint256 nextIndex

    );



    event LogDisbursalRejected(

        address indexed claimer,

        address token,

        address proRataToken,

        uint256 amount,

        uint256 nextIndex

    );



    event LogFundsRecycled(

        address indexed proRataToken,

        address indexed token,

        uint256 amount,

        address by

    );



    event LogChangeFeeDisbursalController(

        address oldController,

        address newController,

        address by

    );



    ////////////////////////

    // Types

    ////////////////////////

    struct Disbursal {

        // snapshop ID of the pro-rata token, which will define which amounts to disburse against

        uint256 snapshotId;

        // amount of tokens to disburse

        uint256 amount;

        // timestamp after which claims to this token can be recycled

        uint128 recycleableAfterTimestamp;

        // timestamp on which token were disbursed

        uint128 disbursalTimestamp;

        // contract sending the disbursal

        address disburser;

    }



    ////////////////////////

    // Constants

    ////////////////////////

    uint256 constant UINT256_MAX = 2**256 - 1;





    ////////////////////////

    // Immutable state

    ////////////////////////

    Universe private UNIVERSE;



    // must be cached - otherwise default func runs out of gas

    address private ICBM_ETHER_TOKEN;



    ////////////////////////

    // Mutable state

    ////////////////////////



    // controller instance

    IFeeDisbursalController private _feeDisbursalController;

    // map disbursable token address to pro rata token adresses to a list of disbursal events of that token

    mapping (address => mapping(address => Disbursal[])) private _disbursals;

    // mapping to track what disbursals have already been paid out to which user

    // disbursable token address => pro rata token address => user address => next disbursal index to be claimed

    mapping (address => mapping(address => mapping(address => uint256))) _disbursalProgress;





    ////////////////////////

    // Constructor

    ////////////////////////

    constructor(Universe universe, IFeeDisbursalController controller)

        public

    {

        require(universe != address(0x0));

        (bytes32 controllerContractId, ) = controller.contractId();

        require(controllerContractId == FEE_DISBURSAL_CONTROLLER);

        UNIVERSE = universe;

        ICBM_ETHER_TOKEN = universe.getSingleton(KNOWN_INTERFACE_ICBM_ETHER_TOKEN);

        _feeDisbursalController = controller;

    }



    ////////////////////////

    // Public functions

    ////////////////////////



    /// @notice get the disbursal at a given index for a given token

    /// @param token address of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param index until what index to claim to

    function getDisbursal(address token, address proRataToken, uint256 index)

        public

        constant

    returns (

        uint256 snapshotId,

        uint256 amount,

        uint256 recycleableAfterTimestamp,

        uint256 disburseTimestamp,

        address disburser

    )

    {

        Disbursal storage disbursal = _disbursals[token][proRataToken][index];

        snapshotId = disbursal.snapshotId;

        amount = disbursal.amount;

        recycleableAfterTimestamp = disbursal.recycleableAfterTimestamp;

        disburseTimestamp = disbursal.disbursalTimestamp;

        disburser = disbursal.disburser;

    }



    /// @notice get disbursals for current snapshot id of the proRataToken that cannot be claimed yet

    /// @param token address of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @return array of (snapshotId, amount, index) ordered by index. full disbursal information can be retrieved via index

    function getNonClaimableDisbursals(address token, address proRataToken)

        public

        constant

    returns (uint256[3][] memory disbursals)

    {

        uint256 len = _disbursals[token][proRataToken].length;

        if (len == 0) {

            return;

        }

        // count elements with current snapshot id

        uint256 snapshotId = ITokenSnapshots(proRataToken).currentSnapshotId();

        uint256 ii = len;

        while(_disbursals[token][proRataToken][ii-1].snapshotId == snapshotId && --ii > 0) {}

        disbursals = new uint256[3][](len-ii);

        for(uint256 jj = 0; jj < len - ii; jj += 1) {

            disbursals[jj][0] = snapshotId;

            disbursals[jj][1] = _disbursals[token][proRataToken][ii+jj].amount;

            disbursals[jj][2] = ii+jj;

        }

    }



    /// @notice get count of disbursals for given token

    /// @param token address of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    function getDisbursalCount(address token, address proRataToken)

        public

        constant

        returns (uint256)

    {

        return _disbursals[token][proRataToken].length;

    }



    /// @notice accepts the token disbursal offer and claim offered tokens, to be called by an investor

    /// @param token address of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param until until what index to claim to, noninclusive, use 2**256 to accept all disbursals

    function accept(address token, ITokenSnapshots proRataToken, uint256 until)

        public

    {

        // only allow verified and active accounts to claim tokens

        require(_feeDisbursalController.onAccept(token, proRataToken, msg.sender), "NF_ACCEPT_REJECTED");

        (uint256 claimedAmount, , uint256 nextIndex) = claimPrivate(token, proRataToken, msg.sender, until);



        // do the actual token transfer

        if (claimedAmount > 0) {

            IERC223Token ierc223Token = IERC223Token(token);

            assert(ierc223Token.transfer(msg.sender, claimedAmount, ""));

        }

        // log

        emit LogDisbursalAccepted(msg.sender, token, proRataToken, claimedAmount, nextIndex);

    }



    /// @notice accepts disbursals of multiple tokens and receives them, to be called an investor

    /// @param tokens addresses of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    function acceptMultipleByToken(address[] tokens, ITokenSnapshots proRataToken)

        public

    {

        uint256[2][] memory claimed = new uint256[2][](tokens.length);

        // first gather the funds

        uint256 i;

        for (i = 0; i < tokens.length; i += 1) {

            // only allow verified and active accounts to claim tokens

            require(_feeDisbursalController.onAccept(tokens[i], proRataToken, msg.sender), "NF_ACCEPT_REJECTED");

            (claimed[i][0], ,claimed[i][1]) = claimPrivate(tokens[i], proRataToken, msg.sender, UINT256_MAX);

        }

        // then perform actual transfers, after all state changes are done, to prevent re-entry

        for (i = 0; i < tokens.length; i += 1) {

            if (claimed[i][0] > 0) {

                // do the actual token transfer

                IERC223Token ierc223Token = IERC223Token(tokens[i]);

                assert(ierc223Token.transfer(msg.sender, claimed[i][0], ""));

            }

            // always log, even empty amounts

            emit LogDisbursalAccepted(msg.sender, tokens[i], proRataToken, claimed[i][0], claimed[i][1]);

        }

    }



    /// @notice accepts disbursals for single token against many pro rata tokens

    /// @param token address of the disbursable token

    /// @param proRataTokens addresses of the tokens used to determine the user pro rata amount, must be a snapshottoken

    /// @dev this should let save a lot on gas by eliminating multiple transfers and some checks

    function acceptMultipleByProRataToken(address token, ITokenSnapshots[] proRataTokens)

        public

    {

        uint256 i;

        uint256 fullAmount;

        for (i = 0; i < proRataTokens.length; i += 1) {

            require(_feeDisbursalController.onAccept(token, proRataTokens[i], msg.sender), "NF_ACCEPT_REJECTED");

            (uint256 amount, , uint256 nextIndex) = claimPrivate(token, proRataTokens[i], msg.sender, UINT256_MAX);

            fullAmount += amount;

            // emit here, that's how we avoid second loop and storing particular claims

            emit LogDisbursalAccepted(msg.sender, token, proRataTokens[i], amount, nextIndex);

        }

        if (fullAmount > 0) {

            // and now why this method exits - one single transfer of token from many distributions

            IERC223Token ierc223Token = IERC223Token(token);

            assert(ierc223Token.transfer(msg.sender, fullAmount, ""));

        }

    }



    /// @notice rejects disbursal of token which leads to recycle and disbursal of rejected amount

    /// @param token address of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param until until what index to claim to, noninclusive, use 2**256 to reject all disbursals

    function reject(address token, ITokenSnapshots proRataToken, uint256 until)

        public

    {

        // only allow verified and active accounts to claim tokens

        require(_feeDisbursalController.onReject(token, address(0), msg.sender), "NF_REJECT_REJECTED");

        (uint256 claimedAmount, , uint256 nextIndex) = claimPrivate(token, proRataToken, msg.sender, until);

        // what was rejected will be recycled

        if (claimedAmount > 0) {

            PlatformTerms terms = PlatformTerms(UNIVERSE.platformTerms());

            disburse(token, this, claimedAmount, proRataToken, terms.DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION());

        }

        // log

        emit LogDisbursalRejected(msg.sender, token, proRataToken, claimedAmount, nextIndex);

    }



    /// @notice check how many tokens of a certain kind can be claimed by an account

    /// @param token address of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param claimer address of the claimer that would receive the funds

    /// @param until until what index to claim to, noninclusive, use 2**256 to reject all disbursals

    /// @return (amount that can be claimed, total disbursed amount, time to recycle of first disbursal, first disbursal index)

    function claimable(address token, ITokenSnapshots proRataToken, address claimer, uint256 until)

        public

        constant

    returns (uint256 claimableAmount, uint256 totalAmount, uint256 recycleableAfterTimestamp, uint256 firstIndex)

    {

        firstIndex = _disbursalProgress[token][proRataToken][claimer];

        if (firstIndex < _disbursals[token][proRataToken].length) {

            recycleableAfterTimestamp = _disbursals[token][proRataToken][firstIndex].recycleableAfterTimestamp;

        }

        // we don't do to a verified check here, this serves purely to check how much is claimable for an address

        (claimableAmount, totalAmount,) = claimablePrivate(token, proRataToken, claimer, until, false);

    }



    /// @notice check how much fund for each disbursable tokens can be claimed by claimer

    /// @param tokens addresses of the disbursable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param claimer address of the claimer that would receive the funds

    /// @return array of (amount that can be claimed, total disbursed amount, time to recycle of first disbursal, first disbursal index)

    /// @dev claimbles are returned in the same order as tokens were specified

    function claimableMutipleByToken(address[] tokens, ITokenSnapshots proRataToken, address claimer)

        public

        constant

    returns (uint256[4][] claimables)

    {

        claimables = new uint256[4][](tokens.length);

        for (uint256 i = 0; i < tokens.length; i += 1) {

            claimables[i][3] = _disbursalProgress[tokens[i]][proRataToken][claimer];

            if (claimables[i][3] < _disbursals[tokens[i]][proRataToken].length) {

                claimables[i][2] = _disbursals[tokens[i]][proRataToken][claimables[i][3]].recycleableAfterTimestamp;

            }

            (claimables[i][0], claimables[i][1], ) = claimablePrivate(tokens[i], proRataToken, claimer, UINT256_MAX, false);

        }

    }



    /// @notice check how many tokens can be claimed against many pro rata tokens

    /// @param token address of the disbursable token

    /// @param proRataTokens addresses of the tokens used to determine the user pro rata amount, must be a snapshottoken

    /// @param claimer address of the claimer that would receive the funds

    /// @return array of (amount that can be claimed, total disbursed amount, time to recycle of first disbursal, first disbursal index)

    function claimableMutipleByProRataToken(address token, ITokenSnapshots[] proRataTokens, address claimer)

        public

        constant

    returns (uint256[4][] claimables)

    {

        claimables = new uint256[4][](proRataTokens.length);

        for (uint256 i = 0; i < proRataTokens.length; i += 1) {

            claimables[i][3] = _disbursalProgress[token][proRataTokens[i]][claimer];

            if (claimables[i][3] < _disbursals[token][proRataTokens[i]].length) {

                claimables[i][2] = _disbursals[token][proRataTokens[i]][claimables[i][3]].recycleableAfterTimestamp;

            }

            (claimables[i][0], claimables[i][1], ) = claimablePrivate(token, proRataTokens[i], claimer, UINT256_MAX, false);

        }

    }



    /// @notice recycle a token for multiple investors

    /// @param token address of the recyclable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param investors list of investors we want to recycle tokens for

    /// @param until until what index to recycle to

    function recycle(address token, ITokenSnapshots proRataToken, address[] investors, uint256 until)

        public

    {

        require(_feeDisbursalController.onRecycle(token, proRataToken, investors, until), "");

        // cycle through all investors collect the claimable and recycleable funds

        // also move the _disbursalProgress pointer

        uint256 totalClaimableAmount = 0;

        for (uint256 i = 0; i < investors.length; i += 1) {

            (uint256 claimableAmount, ,uint256 nextIndex) = claimablePrivate(token, ITokenSnapshots(proRataToken), investors[i], until, true);

            totalClaimableAmount += claimableAmount;

            _disbursalProgress[token][proRataToken][investors[i]] = nextIndex;

        }



        // skip disbursal if amount == 0

        if (totalClaimableAmount > 0) {

            // now re-disburse, we're now the disburser

            PlatformTerms terms = PlatformTerms(UNIVERSE.platformTerms());

            disburse(token, this, totalClaimableAmount, proRataToken, terms.DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION());

        }



        // log

        emit LogFundsRecycled(proRataToken, token, totalClaimableAmount, msg.sender);

    }



    /// @notice check how much we can recycle for multiple investors

    /// @param token address of the recyclable token

    /// @param proRataToken address of the token used to determine the user pro rata amount, must be a snapshottoken

    /// @param investors list of investors we want to recycle tokens for

    /// @param until until what index to recycle to

    function recycleable(address token, ITokenSnapshots proRataToken, address[] investors, uint256 until)

        public

        constant

    returns (uint256)

    {

        // cycle through all investors collect the claimable and recycleable funds

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < investors.length; i += 1) {

            (uint256 claimableAmount,,) = claimablePrivate(token, proRataToken, investors[i], until, true);

            totalAmount += claimableAmount;

        }

        return totalAmount;

    }



    /// @notice get current controller

    function feeDisbursalController()

        public

        constant

        returns (IFeeDisbursalController)

    {

        return _feeDisbursalController;

    }



    /// @notice update current controller

    function changeFeeDisbursalController(IFeeDisbursalController newController)

        public

    {

        require(_feeDisbursalController.onChangeFeeDisbursalController(msg.sender, newController), "NF_CHANGING_CONTROLLER_REJECTED");

        address oldController = address(_feeDisbursalController);

        _feeDisbursalController = newController;

        emit LogChangeFeeDisbursalController(oldController, address(newController), msg.sender);

    }



    /// @notice implementation of tokenfallback, calls the internal disburse function



    function tokenFallback(address wallet, uint256 amount, bytes data)

        public

    {

        tokenFallbackPrivate(msg.sender, wallet, amount, data);

    }



    /// @notice legacy callback used by ICBMLockedAccount: approve and call pattern

    function receiveApproval(address from, uint256 amount, address tokenAddress, bytes data)

        public

        returns (bool success)

    {

        // sender must be token

        require(msg.sender == tokenAddress);

        // transfer assets

        IERC20Token token = IERC20Token(tokenAddress);

        // this needs a special permission in case of ICBM Euro Token

        require(token.transferFrom(from, address(this), amount));



        // now in case we convert from icbm token

        // migrate previous asset token depends on token type, unfortunatelly deposit function differs so we have to cast. this is weak...

        if (tokenAddress == ICBM_ETHER_TOKEN) {

            // after EtherToken withdraw, deposit ether into new token

            IWithdrawableToken(tokenAddress).withdraw(amount);

            token = IERC20Token(UNIVERSE.etherToken());

            EtherToken(token).deposit.value(amount)();

        }

        if(tokenAddress == UNIVERSE.getSingleton(KNOWN_INTERFACE_ICBM_EURO_TOKEN)) {

            IWithdrawableToken(tokenAddress).withdraw(amount);

            token = IERC20Token(UNIVERSE.euroToken());

            // this requires EuroToken DEPOSIT_MANAGER role

            EuroToken(token).deposit(this, amount, 0x0);

        }

        tokenFallbackPrivate(address(token), from, amount, data);

        return true;

    }



    //

    // IContractId Implementation

    //



    function contractId()

        public

        pure

        returns (bytes32 id, uint256 version)

    {

        return (0x2e1a7e4ac88445368dddb31fe43d29638868837724e9be8ffd156f21a971a4d7, 0);

    }



    //

    // Payable default function to receive ether during migration

    //

    function ()

        public

        payable

    {

        require(msg.sender == ICBM_ETHER_TOKEN);

    }





    ////////////////////////

    // Private functions

    ////////////////////////



    function tokenFallbackPrivate(address token, address wallet, uint256 amount, bytes data)

        private

    {

        ITokenSnapshots proRataToken;

        PlatformTerms terms = PlatformTerms(UNIVERSE.platformTerms());

        uint256 recycleAfterDuration = terms.DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION();

        if (data.length == 20) {

            proRataToken = ITokenSnapshots(decodeAddress(data));

        }

        else if (data.length == 52) {

            address proRataTokenAddress;

            (proRataTokenAddress, recycleAfterDuration) = decodeAddressUInt256(data);

            proRataToken = ITokenSnapshots(proRataTokenAddress);

        } else {

            // legacy ICBMLockedAccount compat mode which does not send pro rata token address and we assume NEU

            proRataToken = UNIVERSE.neumark();

        }

        disburse(token, wallet, amount, proRataToken, recycleAfterDuration);

    }



    /// @notice create a new disbursal

    /// @param token address of the token to disburse

    /// @param disburser address of the actor disbursing (e.g. eto commitment)

    /// @param amount amount of the disbursable tokens

    /// @param proRataToken address of the token that defines the pro rata

    function disburse(address token, address disburser, uint256 amount, ITokenSnapshots proRataToken, uint256 recycleAfterDuration)

        private

    {

        require(

            _feeDisbursalController.onDisburse(token, disburser, amount, address(proRataToken), recycleAfterDuration), "NF_DISBURSAL_REJECTED");



        uint256 snapshotId = proRataToken.currentSnapshotId();

        uint256 proRataTokenTotalSupply = proRataToken.totalSupplyAt(snapshotId);

        // if token disburses itself we cannot disburse full total supply

        if (token == address(proRataToken)) {

            proRataTokenTotalSupply -= proRataToken.balanceOfAt(address(this), snapshotId);

        }

        require(proRataTokenTotalSupply > 0, "NF_NO_DISBURSE_EMPTY_TOKEN");

        uint256 recycleAfter = add(block.timestamp, recycleAfterDuration);

        assert(recycleAfter<2**128);



        Disbursal[] storage disbursals = _disbursals[token][proRataToken];

        // try to merge with an existing disbursal

        bool merged = false;

        for ( uint256 i = disbursals.length - 1; i != UINT256_MAX; i-- ) {

            // we can only merge if we have the same snapshot id

            // we can break here, as continuing down the loop the snapshot ids will decrease

            Disbursal storage disbursal = disbursals[i];

            if ( disbursal.snapshotId < snapshotId) {

                break;

            }

            // the existing disbursal must be the same on number of params so we can merge

            // disbursal.snapshotId is guaranteed to == proRataToken.currentSnapshotId()

            if ( disbursal.disburser == disburser ) {

                merged = true;

                disbursal.amount += amount;

                disbursal.recycleableAfterTimestamp = uint128(recycleAfter);

                disbursal.disbursalTimestamp = uint128(block.timestamp);

                break;

            }

        }



        // create a new disbursal entry

        if (!merged) {

            disbursals.push(Disbursal({

                recycleableAfterTimestamp: uint128(recycleAfter),

                disbursalTimestamp: uint128(block.timestamp),

                amount: amount,

                snapshotId: snapshotId,

                disburser: disburser

            }));

        }

        emit LogDisbursalCreated(proRataToken, token, amount, recycleAfterDuration, disburser, merged ? i : disbursals.length - 1);

    }





    /// @notice claim a token for an claimer, returns the amount of tokens claimed

    /// @param token address of the disbursable token

    /// @param claimer address of the claimer that will receive the funds

    /// @param until until what index to claim to

    function claimPrivate(address token, ITokenSnapshots proRataToken, address claimer, uint256 until)

        private

    returns (uint256 claimedAmount, uint256 totalAmount, uint256 nextIndex)

    {

        (claimedAmount, totalAmount, nextIndex) = claimablePrivate(token, proRataToken, claimer, until, false);



        // mark claimer disbursal progress

        _disbursalProgress[token][proRataToken][claimer] = nextIndex;

    }



    /// @notice get the amount of tokens that can be claimed by a given claimer

    /// @param token address of the disbursable token

    /// @param claimer address of the claimer that will receive the funds

    /// @param until until what index to claim to, use UINT256_MAX for all

    /// @param onlyRecycleable show only disbursable funds that can be recycled

    /// @return a tuple of (amount claimed, total amount disbursed, next disbursal index to be claimed)

    function claimablePrivate(address token, ITokenSnapshots proRataToken, address claimer, uint256 until, bool onlyRecycleable)

        private

        constant

        returns (uint256 claimableAmount, uint256 totalAmount, uint256 nextIndex)

    {

        nextIndex = min(until, _disbursals[token][proRataToken].length);

        uint256 currentIndex = _disbursalProgress[token][proRataToken][claimer];

        uint256 currentSnapshotId = proRataToken.currentSnapshotId();

        for (; currentIndex < nextIndex; currentIndex += 1) {

            Disbursal storage disbursal = _disbursals[token][proRataToken][currentIndex];

            uint256 snapshotId = disbursal.snapshotId;

            // do not pay out claims from the current snapshot

            if ( snapshotId == currentSnapshotId )

                break;

            // in case of just determining the recyclable amount of tokens, break when we

            // cross this time, this also assumes disbursal.recycleableAfterTimestamp in each disbursal is the same or increases

            // in case it decreases, recycle will not be possible until 'blocking' disbursal also expires

            if ( onlyRecycleable && disbursal.recycleableAfterTimestamp > block.timestamp )

                break;

            // add to total amount

            totalAmount += disbursal.amount;

            // add claimable amount

            claimableAmount += calculateClaimableAmount(claimer, disbursal.amount, token, proRataToken, snapshotId);

        }

        return (claimableAmount, totalAmount, currentIndex);

    }



    function calculateClaimableAmount(address claimer, uint256 disbursalAmount, address token, ITokenSnapshots proRataToken, uint256 snapshotId)

        private

        constant

        returns (uint256)

    {

        uint256 proRataClaimerBalance = proRataToken.balanceOfAt(claimer, snapshotId);

        // if no balance then continue

        if (proRataClaimerBalance == 0) {

            return 0;

        }

        // compute pro rata amount

        uint256 proRataTokenTotalSupply = proRataToken.totalSupplyAt(snapshotId);

        // if we disburse token that is pro rata token (downround) then remove what fee disbursal holds from total supply

        if (token == address(proRataToken)) {

            proRataTokenTotalSupply -= proRataToken.balanceOfAt(address(this), snapshotId);

        }

        // using round HALF_UP we risks rounding errors to accumulate and overflow balance at the last claimer

        // example: disbursalAmount = 3, total supply = 2 and two claimers with 1 pro rata token balance

        // with HALF_UP first claims 2 and seconds claims2 but balance is 1 at that point

        // thus we round down here saving tons of gas by not doing additional bookkeeping

        // consequence: small amounts of disbursed funds will be left in the contract

        return mul(disbursalAmount, proRataClaimerBalance) / proRataTokenTotalSupply;

    }

}