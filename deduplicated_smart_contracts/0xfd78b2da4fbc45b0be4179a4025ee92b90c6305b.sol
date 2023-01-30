/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.4.24;



/**

 * @title Utility contract to allow pausing and unpausing of certain functions

 */

contract Pausable {



    event Pause(uint256 _timestammp);

    event Unpause(uint256 _timestamp);



    bool public paused = false;



    /**

    * @notice Modifier to make a function callable only when the contract is not paused.

    */

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");

        _;

    }



    /**

    * @notice Modifier to make a function callable only when the contract is paused.

    */

    modifier whenPaused() {

        require(paused, "Contract is not paused");

        _;

    }



   /**

    * @notice Called by the owner to pause, triggers stopped state

    */

    function _pause() internal whenNotPaused {

        paused = true;

        /*solium-disable-next-line security/no-block-members*/

        emit Pause(now);

    }



    /**

    * @notice Called by the owner to unpause, returns to normal state

    */

    function _unpause() internal whenPaused {

        paused = false;

        /*solium-disable-next-line security/no-block-members*/

        emit Unpause(now);

    }



}



/**

 * @title Interface that every module contract should implement

 */

interface IModule {



    /**

     * @notice This function returns the signature of configure function

     */

    function getInitFunction() external pure returns (bytes4);



    /**

     * @notice Return the permission flags that are associated with a module

     */

    function getPermissions() external view returns(bytes32[]);



    /**

     * @notice Used to withdraw the fee by the factory owner

     */

    function takeFee(uint256 _amount) external returns(bool);



}



/**

 * @title Interface for all security tokens

 */

interface ISecurityToken {



    // Standard ERC20 interface

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    //transfer, transferFrom must respect the result of verifyTransfer

    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);



    /**

     * @notice Mints new tokens and assigns them to the target _investor.

     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)

     * @param _investor Address the tokens will be minted to

     * @param _value is the amount of tokens that will be minted to the investor

     */

    function mint(address _investor, uint256 _value) external returns (bool success);



    /**

     * @notice Mints new tokens and assigns them to the target _investor.

     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)

     * @param _investor Address the tokens will be minted to

     * @param _value is The amount of tokens that will be minted to the investor

     * @param _data Data to indicate validation

     */

    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);



    /**

     * @notice Used to burn the securityToken on behalf of someone else

     * @param _from Address for whom to burn tokens

     * @param _value No. of tokens to be burned

     * @param _data Data to indicate validation

     */

    function burnFromWithData(address _from, uint256 _value, bytes _data) external;



    /**

     * @notice Used to burn the securityToken

     * @param _value No. of tokens to be burned

     * @param _data Data to indicate validation

     */

    function burnWithData(uint256 _value, bytes _data) external;



    event Minted(address indexed _to, uint256 _value);

    event Burnt(address indexed _burner, uint256 _value);



    // Permissions this to a Permission module, which has a key of 1

    // If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway

    // this allows individual modules to override this logic if needed (to not allow ST owner all permissions)

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);



    /**

     * @notice Returns module list for a module type

     * @param _module Address of the module

     * @return bytes32 Name

     * @return address Module address

     * @return address Module factory address

     * @return bool Module archived

     * @return uint8 Module type

     * @return uint256 Module index

     * @return uint256 Name index



     */

    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);



    /**

     * @notice Returns module list for a module name

     * @param _name Name of the module

     * @return address[] List of modules with this name

     */

    function getModulesByName(bytes32 _name) external view returns (address[]);



    /**

     * @notice Returns module list for a module type

     * @param _type Type of the module

     * @return address[] List of modules with this type

     */

    function getModulesByType(uint8 _type) external view returns (address[]);



    /**

     * @notice Queries totalSupply at a specified checkpoint

     * @param _checkpointId Checkpoint ID to query as of

     */

    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);



    /**

     * @notice Queries balance at a specified checkpoint

     * @param _investor Investor to query balance for

     * @param _checkpointId Checkpoint ID to query as of

     */

    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);



    /**

     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy

     */

    function createCheckpoint() external returns (uint256);



    /**

     * @notice Gets length of investors array

     * NB - this length may differ from investorCount if the list has not been pruned of zero-balance investors

     * @return Length

     */

    function getInvestors() external view returns (address[]);



    /**

     * @notice returns an array of investors at a given checkpoint

     * NB - this length may differ from investorCount as it contains all investors that ever held tokens

     * @param _checkpointId Checkpoint id at which investor list is to be populated

     * @return list of investors

     */

    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);



    /**

     * @notice generates subset of investors

     * NB - can be used in batches if investor list is large

     * @param _start Position of investor to start iteration from

     * @param _end Position of investor to stop iteration at

     * @return list of investors

     */

    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);

    

    /**

     * @notice Gets current checkpoint ID

     * @return Id

     */

    function currentCheckpointId() external view returns (uint256);



    /**

    * @notice Gets an investor at a particular index

    * @param _index Index to return address from

    * @return Investor address

    */

    function investors(uint256 _index) external view returns (address);



   /**

    * @notice Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.

    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.

    * @param _tokenContract Address of the ERC20Basic compliance token

    * @param _value Amount of POLY to withdraw

    */

    function withdrawERC20(address _tokenContract, uint256 _value) external;



    /**

    * @notice Allows owner to approve more POLY to one of the modules

    * @param _module Module address

    * @param _budget New budget

    */

    function changeModuleBudget(address _module, uint256 _budget) external;



    /**

     * @notice Changes the tokenDetails

     * @param _newTokenDetails New token details

     */

    function updateTokenDetails(string _newTokenDetails) external;



    /**

    * @notice Allows the owner to change token granularity

    * @param _granularity Granularity level of the token

    */

    function changeGranularity(uint256 _granularity) external;



    /**

    * @notice Removes addresses with zero balances from the investors list

    * @param _start Index in investors list at which to start removing zero balances

    * @param _iters Max number of iterations of the for loop

    * NB - pruning this list will mean you may not be able to iterate over investors on-chain as of a historical checkpoint

    */

    function pruneInvestors(uint256 _start, uint256 _iters) external;



    /**

     * @notice Freezes all the transfers

     */

    function freezeTransfers() external;



    /**

     * @notice Un-freezes all the transfers

     */

    function unfreezeTransfers() external;



    /**

     * @notice Ends token minting period permanently

     */

    function freezeMinting() external;



    /**

     * @notice Mints new tokens and assigns them to the target investors.

     * Can only be called by the STO attached to the token or by the Issuer (Security Token contract owner)

     * @param _investors A list of addresses to whom the minted tokens will be delivered

     * @param _values A list of the amount of tokens to mint to corresponding addresses from _investor[] list

     * @return Success

     */

    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);



    /**

     * @notice Function used to attach a module to the security token

     * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it

     * @dev to control restrictions on transfers.

     * @dev You are allowed to add a new moduleType if:

     * @dev - there is no existing module of that type yet added

     * @dev - the last member of the module list is replacable

     * @param _moduleFactory is the address of the module factory to be added

     * @param _data is data packed into bytes used to further configure the module (See STO usage)

     * @param _maxCost max amount of POLY willing to pay to module. (WIP)

     */

    function addModule(

        address _moduleFactory,

        bytes _data,

        uint256 _maxCost,

        uint256 _budget

    ) external;



    /**

    * @notice Archives a module attached to the SecurityToken

    * @param _module address of module to archive

    */

    function archiveModule(address _module) external;



    /**

    * @notice Unarchives a module attached to the SecurityToken

    * @param _module address of module to unarchive

    */

    function unarchiveModule(address _module) external;



    /**

    * @notice Removes a module attached to the SecurityToken

    * @param _module address of module to archive

    */

    function removeModule(address _module) external;



    /**

     * @notice Used by the issuer to set the controller addresses

     * @param _controller address of the controller

     */

    function setController(address _controller) external;



    /**

     * @notice Used by a controller to execute a forced transfer

     * @param _from address from which to take tokens

     * @param _to address where to send tokens

     * @param _value amount of tokens to transfer

     * @param _data data to indicate validation

     * @param _log data attached to the transfer by controller to emit in event

     */

    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;



    /**

     * @notice Used by a controller to execute a foced burn

     * @param _from address from which to take tokens

     * @param _value amount of tokens to transfer

     * @param _data data to indicate validation

     * @param _log data attached to the transfer by controller to emit in event

     */

    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;



    /**

     * @notice Used by the issuer to permanently disable controller functionality

     * @dev enabled via feature switch "disableControllerAllowed"

     */

     function disableController() external;



     /**

     * @notice Used to get the version of the securityToken

     */

     function getVersion() external view returns(uint8[]);



     /**

     * @notice Gets the investor count

     */

     function getInvestorCount() external view returns(uint256);



     /**

      * @notice Overloaded version of the transfer function

      * @param _to receiver of transfer

      * @param _value value of transfer

      * @param _data data to indicate validation

      * @return bool success

      */

     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);



     /**

      * @notice Overloaded version of the transferFrom function

      * @param _from sender of transfer

      * @param _to receiver of transfer

      * @param _value value of transfer

      * @param _data data to indicate validation

      * @return bool success

      */

     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);



     /**

      * @notice Provides the granularity of the token

      * @return uint256

      */

     function granularity() external view returns(uint256);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title Storage for Module contract

 * @notice Contract is abstract

 */

contract ModuleStorage {



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress) public {

        securityToken = _securityToken;

        factory = msg.sender;

        polyToken = IERC20(_polyAddress);

    }

    

    address public factory;



    address public securityToken;



    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";



    IERC20 public polyToken;



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

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

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

 * @title Interface that any module contract should implement

 * @notice Contract is abstract

 */

contract Module is IModule, ModuleStorage {



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress) public

    ModuleStorage(_securityToken, _polyAddress)

    {

    }



    //Allows owner, factory or permissioned delegate

    modifier withPerm(bytes32 _perm) {

        bool isOwner = msg.sender == Ownable(securityToken).owner();

        bool isFactory = msg.sender == factory;

        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");

        _;

    }



    modifier onlyOwner {

        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");

        _;

    }



    modifier onlyFactory {

        require(msg.sender == factory, "Sender is not factory");

        _;

    }



    modifier onlyFactoryOwner {

        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");

        _;

    }



    modifier onlyFactoryOrOwner {

        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");

        _;

    }



    /**

     * @notice used to withdraw the fee by the factory owner

     */

    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {

        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");

        return true;

    }



}



/**

 * @title Interface to be implemented by all Transfer Manager modules

 * @dev abstract contract

 */

contract ITransferManager is Module, Pausable {



    //If verifyTransfer returns:

    //  FORCE_VALID, the transaction will always be valid, regardless of other TM results

    //  INVALID, then the transfer should not be allowed regardless of other TM results

    //  VALID, then the transfer is valid for this TM

    //  NA, then the result from this TM is ignored

    enum Result {INVALID, NA, VALID, FORCE_VALID}



    function verifyTransfer(address _from, address _to, uint256 _amount, bytes _data, bool _isTransfer) public returns(Result);



    function unpause() public onlyOwner {

        super._unpause();

    }



    function pause() public onlyOwner {

        super._pause();

    }

}



/**

 * @title Transfer Manager module for core transfer validation functionality

 */

contract GeneralTransferManagerStorage {



    //Address from which issuances come

    address public issuanceAddress = address(0);



    //Address which can sign whitelist changes

    address public signingAddress = address(0);



    bytes32 public constant WHITELIST = "WHITELIST";

    bytes32 public constant FLAGS = "FLAGS";



    //from and to timestamps that an investor can send / receive tokens respectively

    struct TimeRestriction {

        //the moment when the sale lockup period ends and the investor can freely sell or transfer away their tokens

        uint64 canSendAfter;

        //the moment when the purchase lockup period ends and the investor can freely purchase or receive from others

        uint64 canReceiveAfter;

        uint64 expiryTime;

        uint8 canBuyFromSTO;

        uint8 added;

    }



    // Allows all TimeRestrictions to be offset

    struct Defaults {

        uint64 canSendAfter;

        uint64 canReceiveAfter;

    }



    // Offset to be applied to all timings (except KYC expiry)

    Defaults public defaults;



    // List of all addresses that have been added to the GTM at some point

    address[] public investors;



    // An address can only send / receive tokens once their corresponding uint256 > block.number

    // (unless allowAllTransfers == true or allowAllWhitelistTransfers == true)

    mapping (address => TimeRestriction) public whitelist;

    // Map of used nonces by customer

    mapping(address => mapping(uint256 => bool)) public nonceMap;



    //If true, there are no transfer restrictions, for any addresses

    bool public allowAllTransfers = false;

    //If true, time lock is ignored for transfers (address must still be on whitelist)

    bool public allowAllWhitelistTransfers = false;

    //If true, time lock is ignored for issuances (address must still be on whitelist)

    bool public allowAllWhitelistIssuances = true;

    //If true, time lock is ignored for burn transactions

    bool public allowAllBurnTransfers = false;



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

 * @title Transfer Manager module for core transfer validation functionality

 */

contract GeneralTransferManager is GeneralTransferManagerStorage, ITransferManager {



    using SafeMath for uint256;



    // Emit when Issuance address get changed

    event ChangeIssuanceAddress(address _issuanceAddress);

    // Emit when there is change in the flag variable called allowAllTransfers

    event AllowAllTransfers(bool _allowAllTransfers);

    // Emit when there is change in the flag variable called allowAllWhitelistTransfers

    event AllowAllWhitelistTransfers(bool _allowAllWhitelistTransfers);

    // Emit when there is change in the flag variable called allowAllWhitelistIssuances

    event AllowAllWhitelistIssuances(bool _allowAllWhitelistIssuances);

    // Emit when there is change in the flag variable called allowAllBurnTransfers

    event AllowAllBurnTransfers(bool _allowAllBurnTransfers);

    // Emit when there is change in the flag variable called signingAddress

    event ChangeSigningAddress(address _signingAddress);

    // Emit when investor details get modified related to their whitelisting

    event ChangeDefaults(uint64 _defaultCanSendAfter, uint64 _defaultCanReceiveAfter);



    // _canSendAfter is the time from which the _investor can send tokens

    // _canReceiveAfter is the time from which the _investor can receive tokens

    // if allowAllWhitelistIssuances is TRUE, then _canReceiveAfter is ignored when receiving tokens from the issuance address

    // if allowAllWhitelistTransfers is TRUE, then _canReceiveAfter and _canSendAfter is ignored when sending or receiving tokens

    // in any case, any investor sending or receiving tokens, must have a _expiryTime in the future

    event ModifyWhitelist(

        address indexed _investor,

        uint256 _dateAdded,

        address indexed _addedBy,

        uint256 _canSendAfter,

        uint256 _canReceiveAfter,

        uint256 _expiryTime,

        bool _canBuyFromSTO

    );



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress)

    public

    Module(_securityToken, _polyAddress)

    {

    }



    /**

     * @notice This function returns the signature of configure function

     */

    function getInitFunction() public pure returns (bytes4) {

        return bytes4(0);

    }



    /**

     * @notice Used to change the default times used when canSendAfter / canReceiveAfter are zero

     * @param _defaultCanSendAfter default for zero canSendAfter

     * @param _defaultCanReceiveAfter default for zero canReceiveAfter

     */

    function changeDefaults(uint64 _defaultCanSendAfter, uint64 _defaultCanReceiveAfter) public withPerm(FLAGS) {

        /* 0 values are also allowed as they represent that the Issuer

           does not want a default value for these variables.

           0 is also the default value of these variables */

        defaults.canSendAfter = _defaultCanSendAfter;

        defaults.canReceiveAfter = _defaultCanReceiveAfter;

        emit ChangeDefaults(_defaultCanSendAfter, _defaultCanReceiveAfter);

    }



    /**

     * @notice Used to change the Issuance Address

     * @param _issuanceAddress new address for the issuance

     */

    function changeIssuanceAddress(address _issuanceAddress) public withPerm(FLAGS) {

        // address(0x0) is also a valid value and in most cases, the address that issues tokens is 0x0.

        issuanceAddress = _issuanceAddress;

        emit ChangeIssuanceAddress(_issuanceAddress);

    }



    /**

     * @notice Used to change the Sigining Address

     * @param _signingAddress new address for the signing

     */

    function changeSigningAddress(address _signingAddress) public withPerm(FLAGS) {

        /* address(0x0) is also a valid value as an Issuer might want to

           give this permission to nobody (except their own address).

           0x0 is also the default value */

        signingAddress = _signingAddress;

        emit ChangeSigningAddress(_signingAddress);

    }



    /**

     * @notice Used to change the flag

            true - It refers there are no transfer restrictions, for any addresses

            false - It refers transfers are restricted for all addresses.

     * @param _allowAllTransfers flag value

     */

    function changeAllowAllTransfers(bool _allowAllTransfers) public withPerm(FLAGS) {

        allowAllTransfers = _allowAllTransfers;

        emit AllowAllTransfers(_allowAllTransfers);

    }



    /**

     * @notice Used to change the flag

            true - It refers that time lock is ignored for transfers (address must still be on whitelist)

            false - It refers transfers are restricted for all addresses.

     * @param _allowAllWhitelistTransfers flag value

     */

    function changeAllowAllWhitelistTransfers(bool _allowAllWhitelistTransfers) public withPerm(FLAGS) {

        allowAllWhitelistTransfers = _allowAllWhitelistTransfers;

        emit AllowAllWhitelistTransfers(_allowAllWhitelistTransfers);

    }



    /**

     * @notice Used to change the flag

            true - It refers that time lock is ignored for issuances (address must still be on whitelist)

            false - It refers transfers are restricted for all addresses.

     * @param _allowAllWhitelistIssuances flag value

     */

    function changeAllowAllWhitelistIssuances(bool _allowAllWhitelistIssuances) public withPerm(FLAGS) {

        allowAllWhitelistIssuances = _allowAllWhitelistIssuances;

        emit AllowAllWhitelistIssuances(_allowAllWhitelistIssuances);

    }



    /**

     * @notice Used to change the flag

            true - It allow to burn the tokens

            false - It deactivate the burning mechanism.

     * @param _allowAllBurnTransfers flag value

     */

    function changeAllowAllBurnTransfers(bool _allowAllBurnTransfers) public withPerm(FLAGS) {

        allowAllBurnTransfers = _allowAllBurnTransfers;

        emit AllowAllBurnTransfers(_allowAllBurnTransfers);

    }



    /**

     * @notice Default implementation of verifyTransfer used by SecurityToken

     * If the transfer request comes from the STO, it only checks that the investor is in the whitelist

     * If the transfer request comes from a token holder, it checks that:

     * a) Both are on the whitelist

     * b) Seller's sale lockup period is over

     * c) Buyer's purchase lockup is over

     * @param _from Address of the sender

     * @param _to Address of the receiver

    */

    function verifyTransfer(address _from, address _to, uint256 /*_amount*/, bytes /* _data */, bool /* _isTransfer */) public returns(Result) {

        if (!paused) {

            if (allowAllTransfers) {

                //All transfers allowed, regardless of whitelist

                return Result.VALID;

            }

            if (allowAllBurnTransfers && (_to == address(0))) {

                return Result.VALID;

            }

            if (allowAllWhitelistTransfers) {

                //Anyone on the whitelist can transfer, regardless of time

                return (_onWhitelist(_to) && _onWhitelist(_from)) ? Result.VALID : Result.NA;

            }



            (uint64 adjustedCanSendAfter, uint64 adjustedCanReceiveAfter) = _adjustTimes(whitelist[_from].canSendAfter, whitelist[_to].canReceiveAfter);

            if (_from == issuanceAddress) {

                // Possible STO transaction, but investor not allowed to purchased from STO

                if ((whitelist[_to].canBuyFromSTO == 0) && _isSTOAttached()) {

                    return Result.NA;

                }

                // if allowAllWhitelistIssuances is true, so time stamp ignored

                if (allowAllWhitelistIssuances) {

                    return _onWhitelist(_to) ? Result.VALID : Result.NA;

                } else {

                    return (_onWhitelist(_to) && (adjustedCanReceiveAfter <= uint64(now))) ? Result.VALID : Result.NA;

                }

            }



            //Anyone on the whitelist can transfer provided the blocknumber is large enough

            /*solium-disable-next-line security/no-block-members*/

            return ((_onWhitelist(_from) && (adjustedCanSendAfter <= uint64(now))) &&

                (_onWhitelist(_to) && (adjustedCanReceiveAfter <= uint64(now)))) ? Result.VALID : Result.NA; /*solium-disable-line security/no-block-members*/

        }

        return Result.NA;

    }



    /**

    * @notice Adds or removes addresses from the whitelist.

    * @param _investor is the address to whitelist

    * @param _canSendAfter the moment when the sale lockup period ends and the investor can freely sell or transfer away their tokens

    * @param _canReceiveAfter the moment when the purchase lockup period ends and the investor can freely purchase or receive from others

    * @param _expiryTime is the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO is used to know whether the investor is restricted investor or not.

    */

    function modifyWhitelist(

        address _investor,

        uint256 _canSendAfter,

        uint256 _canReceiveAfter,

        uint256 _expiryTime,

        bool _canBuyFromSTO

    )

        public

        withPerm(WHITELIST)

    {

        _modifyWhitelist(_investor, _canSendAfter, _canReceiveAfter, _expiryTime, _canBuyFromSTO);

    }



    /**

    * @notice Adds or removes addresses from the whitelist.

    * @param _investor is the address to whitelist

    * @param _canSendAfter is the moment when the sale lockup period ends and the investor can freely sell his tokens

    * @param _canReceiveAfter is the moment when the purchase lockup period ends and the investor can freely purchase tokens from others

    * @param _expiryTime is the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO is used to know whether the investor is restricted investor or not.

    */

    function _modifyWhitelist(

        address _investor,

        uint256 _canSendAfter,

        uint256 _canReceiveAfter,

        uint256 _expiryTime,

        bool _canBuyFromSTO

    )

        internal

    {

        require(_investor != address(0), "Invalid investor");

        uint8 canBuyFromSTO = 0;

        if (_canBuyFromSTO) {

            canBuyFromSTO = 1;

        }

        if (whitelist[_investor].added == uint8(0)) {

            investors.push(_investor);

        }

        require(

            uint64(_canSendAfter) == _canSendAfter &&

            uint64(_canReceiveAfter) == _canReceiveAfter &&

            uint64(_expiryTime) == _expiryTime,

            "uint64 overflow"

        );

        whitelist[_investor] = TimeRestriction(uint64(_canSendAfter), uint64(_canReceiveAfter), uint64(_expiryTime), canBuyFromSTO, uint8(1));

        emit ModifyWhitelist(_investor, now, msg.sender, _canSendAfter, _canReceiveAfter, _expiryTime, _canBuyFromSTO);

    }



    /**

    * @notice Adds or removes addresses from the whitelist.

    * @param _investors List of the addresses to whitelist

    * @param _canSendAfters An array of the moment when the sale lockup period ends and the investor can freely sell his tokens

    * @param _canReceiveAfters An array of the moment when the purchase lockup period ends and the investor can freely purchase tokens from others

    * @param _expiryTimes An array of the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO An array of boolean values

    */

    function modifyWhitelistMulti(

        address[] _investors,

        uint256[] _canSendAfters,

        uint256[] _canReceiveAfters,

        uint256[] _expiryTimes,

        bool[] _canBuyFromSTO

    ) public withPerm(WHITELIST) {

        require(_investors.length == _canSendAfters.length, "Mismatched input lengths");

        require(_canSendAfters.length == _canReceiveAfters.length, "Mismatched input lengths");

        require(_canReceiveAfters.length == _expiryTimes.length, "Mismatched input lengths");

        require(_canBuyFromSTO.length == _canReceiveAfters.length, "Mismatched input length");

        for (uint256 i = 0; i < _investors.length; i++) {

            _modifyWhitelist(_investors[i], _canSendAfters[i], _canReceiveAfters[i], _expiryTimes[i], _canBuyFromSTO[i]);

        }

    }



    /**

    * @notice Adds or removes addresses from the whitelist - can be called by anyone with a valid signature

    * @param _investor is the address to whitelist

    * @param _canSendAfter is the moment when the sale lockup period ends and the investor can freely sell his tokens

    * @param _canReceiveAfter is the moment when the purchase lockup period ends and the investor can freely purchase tokens from others

    * @param _expiryTime is the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO is used to know whether the investor is restricted investor or not.

    * @param _validFrom is the time that this signature is valid from

    * @param _validTo is the time that this signature is valid until

    * @param _nonce nonce of signature (avoid replay attack)

    * @param _v issuer signature

    * @param _r issuer signature

    * @param _s issuer signature

    */

    function modifyWhitelistSigned(

        address _investor,

        uint256 _canSendAfter,

        uint256 _canReceiveAfter,

        uint256 _expiryTime,

        bool _canBuyFromSTO,

        uint256 _validFrom,

        uint256 _validTo,

        uint256 _nonce,

        uint8 _v,

        bytes32 _r,

        bytes32 _s

    ) public {

        /*solium-disable-next-line security/no-block-members*/

        require(_validFrom <= now, "ValidFrom is too early");

        /*solium-disable-next-line security/no-block-members*/

        require(_validTo >= now, "ValidTo is too late");

        require(!nonceMap[_investor][_nonce], "Already used signature");

        nonceMap[_investor][_nonce] = true;

        bytes32 hash = keccak256(

            abi.encodePacked(this, _investor, _canSendAfter, _canReceiveAfter, _expiryTime, _canBuyFromSTO, _validFrom, _validTo, _nonce)

        );

        _checkSig(hash, _v, _r, _s);

        _modifyWhitelist(_investor, _canSendAfter, _canReceiveAfter, _expiryTime, _canBuyFromSTO);

    }



    /**

     * @notice Used to verify the signature

     */

    function _checkSig(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal view {

        //Check that the signature is valid

        //sig should be signing - _investor, _canSendAfter, _canReceiveAfter & _expiryTime and be signed by the issuer address

        address signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);

        require(signer == Ownable(securityToken).owner() || signer == signingAddress, "Incorrect signer");

    }



    /**

     * @notice Internal function used to check whether the investor is in the whitelist or not

            & also checks whether the KYC of investor get expired or not

     * @param _investor Address of the investor

     */

    function _onWhitelist(address _investor) internal view returns(bool) {

        return (whitelist[_investor].expiryTime >= uint64(now)); /*solium-disable-line security/no-block-members*/

    }



    /**

     * @notice Internal function use to know whether the STO is attached or not

     */

    function _isSTOAttached() internal view returns(bool) {

        bool attached = ISecurityToken(securityToken).getModulesByType(3).length > 0;

        return attached;

    }



    /**

     * @notice Internal function to adjust times using default values

     */

    function _adjustTimes(uint64 _canSendAfter, uint64 _canReceiveAfter) internal view returns(uint64, uint64) {

        uint64 adjustedCanSendAfter = _canSendAfter;

        uint64 adjustedCanReceiveAfter = _canReceiveAfter;

        if (_canSendAfter == 0) {

            adjustedCanSendAfter = defaults.canSendAfter;

        }

        if (_canReceiveAfter == 0) {

            adjustedCanReceiveAfter = defaults.canReceiveAfter;

        }

        return (adjustedCanSendAfter, adjustedCanReceiveAfter);

    }



    /**

     * @dev Returns list of all investors

     */

    function getInvestors() external view returns(address[]) {

        return investors;

    }



    /**

     * @dev Returns list of all investors data

     */

    function getAllInvestorsData() external view returns(address[], uint256[], uint256[], uint256[], bool[]) {

        (uint256[] memory canSendAfters, uint256[] memory canReceiveAfters, uint256[] memory expiryTimes, bool[] memory canBuyFromSTOs)

          = _investorsData(investors);

        return (investors, canSendAfters, canReceiveAfters, expiryTimes, canBuyFromSTOs);



    }



    /**

     * @dev Returns list of specified investors data

     */

    function getInvestorsData(address[] _investors) external view returns(uint256[], uint256[], uint256[], bool[]) {

        return _investorsData(_investors);

    }



    function _investorsData(address[] _investors) internal view returns(uint256[], uint256[], uint256[], bool[]) {

        uint256[] memory canSendAfters = new uint256[](_investors.length);

        uint256[] memory canReceiveAfters = new uint256[](_investors.length);

        uint256[] memory expiryTimes = new uint256[](_investors.length);

        bool[] memory canBuyFromSTOs = new bool[](_investors.length);

        for (uint256 i = 0; i < _investors.length; i++) {

            canSendAfters[i] = whitelist[_investors[i]].canSendAfter;

            canReceiveAfters[i] = whitelist[_investors[i]].canReceiveAfter;

            expiryTimes[i] = whitelist[_investors[i]].expiryTime;

            if (whitelist[_investors[i]].canBuyFromSTO == 0) {

                canBuyFromSTOs[i] = false;

            } else {

                canBuyFromSTOs[i] = true;

            }

        }

        return (canSendAfters, canReceiveAfters, expiryTimes, canBuyFromSTOs);

    }



    /**

     * @notice Return the permissions flag that are associated with general trnasfer manager

     */

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](2);

        allPermissions[0] = WHITELIST;

        allPermissions[1] = FLAGS;

        return allPermissions;

    }



}