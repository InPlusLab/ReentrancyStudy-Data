/**
 *Submitted for verification at Etherscan.io on 2019-10-20
*/

pragma solidity ^0.5.12;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

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

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/// @title Admin contract for CheezyExchange. This contract manages fees and
///  imports administrative functions.
contract CheezyExchangeAdmin is Ownable, Pausable, ReentrancyGuard {

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @notice This event is fired when the developer changes the fee applied
    ///  to successful trades. The fee is measured in basis points (hundredths
    ///  of a percent).
    /// @param newSuccessfulTradeFeeInBasisPoints  The new fee applying to
    ///  successful trades (measured in basis points/hundredths of a percent).
    event SuccessfulTradeFeeInBasisPointsUpdated(uint256 newSuccessfulTradeFeeInBasisPoints);

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @notice The amount of fees collected (in wei). This includes both fees to
    ///  the contract owner and fees to any referrers. Storing earnings saves
    ///  gas rather than performing an additional transfer() call on every
    ///  successful trade.
    mapping (address => uint256) public addressToFeeEarnings;

    /// @notice If a trade is successfully fulfilled, this fee applies before
    ///  the remaining funds are sent to the seller. This fee is measured in
    ///  basis points (hundredths of a percent), and is taken out of the total
    ///  value that the seller asked for when creating their order.
    uint256 public successfulTradeFeeInBasisPoints = 375;

    /* ********* */
    /* CONSTANTS */
    /* ********* */

    /// @notice The address of Core CheezeWizards contract, handling the ownership
    ///  and approval logic for any particular wizard.
    address public wizardGuildAddress = 0x0d8c864DA1985525e0af0acBEEF6562881827bd5;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @dev The owner is not capable of changing the address of the
    ///  CheezeWizards Core contract once the contract has been deployed.
    constructor() internal {

    }

    /// @notice Sets the successfulTradeFeeInBasisPoints value (in basis
    ///  points). Any trades that are successfully fulfilled will have this fee
    ///  deducted from amount sent to the seller.
    /// @dev Only callable by the owner.
    /// @dev As this configuration is a basis point, the value to set must be
    ///  less than or equal to 10000.
    /// @param _newSuccessfulTradeFeeInBasisPoints  The
    ///  successfulTradeFeeInBasisPoints value to set (measured in basis
    ///  points).
    function setSuccessfulTradeFeeInBasisPoints(uint256 _newSuccessfulTradeFeeInBasisPoints) external onlyOwner {
        require(_newSuccessfulTradeFeeInBasisPoints <= 10000, 'new successful trade fee must be in basis points (hundredths of a percent), not wei');
        successfulTradeFeeInBasisPoints = _newSuccessfulTradeFeeInBasisPoints;
        emit SuccessfulTradeFeeInBasisPointsUpdated(_newSuccessfulTradeFeeInBasisPoints);
    }

    /// @notice Withdraws the fees that have been earned by either the contract
    ///  owner or referrers.
    /// @notice Only callable by the address that had earned the fees.
    function withdrawFeeEarningsForAddress() external nonReentrant {
        uint256 balance = addressToFeeEarnings[msg.sender];
        require(balance > 0, 'there are no fees to withdraw for this address');
        addressToFeeEarnings[msg.sender] = 0;
        msg.sender.transfer(balance);
    }

    /// @notice Gives the authority for the contract owner to remove any
    ///  additional accounts that have been granted the ability to pause the
    ///  contract
    /// @dev Only callable by the owner.
    /// @param _account  The account to have the ability to pause the contract
    ///  revoked
    function removePauser(address _account) external onlyOwner {
        _removePauser(_account);
    }

    /// @dev By calling 'revert' in the fallback function, we prevent anyone
    ///  from accidentally sending funds directly to this contract.
    function() external payable {
        revert();
    }
}

/// @title Interface for interacting with the CheezeWizards Core contract
///  created by Dapper Labs Inc.
contract WizardGuild {
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);
}

/// @title Interface for interacting with the BasicTournament contract created
///  by Dapper Labs Inc.
contract BasicTournament {
    function getWizard(uint256 wizardId) public view returns(
        uint256 affinity,
        uint256 power,
        uint256 maxPower,
        uint256 nonce,
        bytes32 currentDuel,
        bool ascending,
        uint256 ascensionOpponent,
        bool molded,
        bool ready
    );
    function giftPower(uint256 sendingWizardId, uint256 receivingWizardId) external;
}

/// @title Convenience contract for CheezyExchange to retrieve Tournament Times
///  from a basic tournament contract.
/// @notice Unfortunately, the CheezeWizard's official contracts do not have a
///  getter function for checking whether we are in a fight window, etc. Since
///  CheezyExchange power transfers can only occur duringFightWindow, we had to
///  re-write all of the CheezeWizards TournamentTime logic simply to get a
///  getter function for checking whether we are duringFightWindow.
contract CheezyExchangeTournamentTime {

    /// @notice The following struct was copied directly from CheezeWizards
    ///  TournamentTimeAbstract contract in order to replicate much of its
    ///  functionality.
    // The data needed to check if we are in a given Window
    struct WindowParameters {
        // The block number that the first window of this type begins
        uint48 firstWindowStartBlock;

        // A copy of the pause ending block, copied into this storage slot to
        // save gas
        uint48 pauseEndedBlock;

        // The length of an entire "session" (see above for definitions), ALL
        // windows repeat with a period of one session.
        uint32 sessionDuration;

        // The duration of this window
        uint32 windowDuration;
    }

    /// @notice The following function was copied directly from CheezeWizards
    ///  TournamentTimeAbstract contract in order to replicate much of its
    ///  functionality.
    // An internal convenience function that checks to see if we are currently
    // in the Window defined by the WindowParameters struct passed as an
    // argument.
    function _isInWindow(WindowParameters memory localParams) internal view returns (bool) {
        // We are never "in a window" if the contract is paused
        if (block.number < localParams.pauseEndedBlock) {
            return false;
        }

        // If we are before the first window of this type, we are obviously NOT
        // in this window!
        if (block.number < localParams.firstWindowStartBlock) {
            return false;
        }

        // Use modulus to figure out how far we are past the beginning of the
        // most recent window
        // of this type
        uint256 windowOffset = (block.number - localParams.firstWindowStartBlock) % localParams.sessionDuration;

        // If we are in the window, we will be within duration of the start of
        // the most recent window
        return windowOffset < localParams.windowDuration;
    }

    /// @notice A getter function for determining whether we are currently in a
    ///  fightWindow for a given tournament
    /// @param _basicTournamentAddress  The address of the tournament in
    ///  question
    /// @return  Whether or not we are in a fightWindow for this tournament
    function _isInFightWindowForTournament(address _basicTournamentAddress) internal view returns (bool){
        uint256 tournamentStartBlock;
        uint256 pauseEndedBlock;
        uint256 admissionDuration;
        uint256 duelTimeoutDuration;
        uint256 ascensionWindowDuration;
        uint256 fightWindowDuration;
        uint256 cullingWindowDuration;
        (
            tournamentStartBlock,
            pauseEndedBlock,
            admissionDuration,
            ,
            duelTimeoutDuration,
            ,
            ascensionWindowDuration,
            ,
            fightWindowDuration,
            ,
            ,
            ,
            cullingWindowDuration
        ) = IBasicTournamentTimeParams(_basicTournamentAddress).getTimeParameters();
        uint256 firstSessionStartBlock = uint256(tournamentStartBlock) + uint256(admissionDuration);
        uint256 sessionDuration = uint256(ascensionWindowDuration) + uint256(fightWindowDuration) + uint256(duelTimeoutDuration) + uint256(cullingWindowDuration);

        return _isInWindow(WindowParameters({
            firstWindowStartBlock: uint48(uint256(firstSessionStartBlock) + uint256(ascensionWindowDuration)),
            pauseEndedBlock: uint48(pauseEndedBlock),
            sessionDuration: uint32(sessionDuration),
            windowDuration: uint32(fightWindowDuration)
        }));
    }
}

contract IBasicTournamentTimeParams{
    function getTimeParameters() external view returns (
        uint256 tournamentStartBlock,
        uint256 pauseEndedBlock,
        uint256 admissionDuration,
        uint256 revivalDuration,
        uint256 duelTimeoutDuration,
        uint256 ascensionWindowStart,
        uint256 ascensionWindowDuration,
        uint256 fightWindowStart,
        uint256 fightWindowDuration,
        uint256 resolutionWindowStart,
        uint256 resolutionWindowDuration,
        uint256 cullingWindowStart,
        uint256 cullingWindowDuration
    );
}

/// @title Main contract for CheezyExchange. This contract manages the creation,
///  editing, and fulfillment of trades of CheezeWizard power only, not the NFT
///  itself.
/// @notice Consider each CheezeWizard NFT as a vessel that holds power. This
///  contract allows a seller to list their Wizard's power for a specified
///  price. If a buyer accepts their order, then they pay the specified price
///  multiplied by the amount of power that the Wizard has, and all of the
///  wizard's power is transferred from the seller's wizard to the buyer's
///  wizard. This leaves the seller's wizard with no power, but the seller
///  still possesses the wizard NFT.
/// @notice Power is tournament-specific. Multiple CheezeWizard tournaments can
///  exist, even at the same time. A single wizard can be entered into
///  multiple tournaments at once, and can have different power levels in each
///  tournament. This contract contains a different orderbook for each
///  tournament. This means that this contract can simultaneously accept orders
///  for multiple tournaments at the same time, even for the same wizard.
contract CheezyExchange is CheezyExchangeAdmin, CheezyExchangeTournamentTime {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to
    // avoid overflows/underflows.
    using SafeMath for uint256;

	/* ********** */
    /* DATA TYPES */
    /* ********** */

    /// @notice The main Order struct. The struct fits into two 256-bit words
    ///  due to Solidity's rules for struct packing, saving gas.
    struct Order {
        // The tokenId for the seller's wizard. This is the wizard that will
        // relinquish its power if an order is fulfilled.
        uint256 wizardId;
        // An order creator specifies how much wei they are willing to sell
        // their wizard's power for. Note that this price is per-power, so
        // the buyer will actually have to pay this price multiplied by the
        // amount of power that the wizard has.
        uint128 pricePerPower;
        // The address of the creator of the order, the seller, the owner
        // of the wizard whose power will be relinquished.
		address makerAddress;
        // The address of the tournament that this order pertains to. Note that
        // each Wizard has an independent power value for each tournament, and
        // call sell each one separately, so orders can exist simultaneously
        // for the same wizard for different tournaments.
		address basicTournamentAddress;
        // We save the dev fee at the time of order creation. This prevents an
        // attack where the dev could frontrun an order acceptance with a
        // change to the dev fee.
        uint16 savedSuccessfulTradeFeeInBasisPoints;
    }

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @notice This event is fired a user creates an order selling their wizard's
    ///  power, but not the NFT itself.
    /// @param wizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param pricePerPower  An order creator specifies how much wei they are
    ///  willing to sell their wizard's power for. Note that this price is
    ///  per-power, so the buyer will actually have to pay this price
    ///  multiplied by the amount of power that the wizard has.
    /// @param makerAddress  The address of the creator of the order, the
    ///  seller, the owner of the wizard whose power will be relinquished.
    /// @param basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    /// @param savedSuccessfulTradeFeeInBasisPoints  We save the dev fee at the
    ///  time of order creation. This prevents an attack where the dev could
    ///  frontrun an order acceptance with a change to the dev fee.
    event CreateSellOrder(
    	uint256 wizardId,
        uint256 pricePerPower,
		address makerAddress,
        address basicTournamentAddress,
        uint256 savedSuccessfulTradeFeeInBasisPoints
    );

    /// @notice This event is fired a user updates an existing order to have a
    ///  different pricePerPower. It saves a small amount of gas to only change
    ///  that one part of the oder.
    /// @param wizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param oldPricePerPower  This is the old pricePerPower, the price that
    ///  is being replaced in this update() call. An order creator specifies
    ///  how much wei they are willing to sell their wizard's power for. Note
    ///  that this price is per-power, so the buyer will actually have to pay
    ///  this price multiplied by the amount of power that the wizard has.
    /// @param newPricePerPower  This is the new pricePerPower, the price that
    ///  will now be valid after this update() call. An order creator specifies
    ///  how much wei they are willing to sell their wizard's power for. Note
    ///  that this price is per-power, so the buyer will actually have to pay
    ///  this price multiplied by the amount of power that the wizard has.
    /// @param makerAddress  The address of the creator of the order, the
    ///  seller, the owner of the wizard whose power will be relinquished.
    /// @param basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    /// @param savedSuccessfulTradeFeeInBasisPoints  We save the dev fee at the
    ///  time of order creation. This prevents an attack where the dev could
    ///  frontrun an order acceptance with a change to the dev fee.
    event UpdateSellOrder(
    	uint256 wizardId,
        uint256 oldPricePerPower,
        uint256 newPricePerPower,
		address makerAddress,
        address basicTournamentAddress,
        uint256 savedSuccessfulTradeFeeInBasisPoints
    );

    /// @notice This event is fired a user cancels an existing order. It is also
    ///  fired when a user calls createSellOrder() for a wizard that already
    ///  has a (potentially invalid) order on the books.
    /// @dev The reason that this contract emits the CancelSellOrder event
    ///  when a user calls createSellOrder() for a wizard that already
    ///  has a (potentially invalid) order on the books is illustrated by the
    ///  following scenario: if Alice creates an order for Wizard1 on this
    ///  contract, but then sells Wizard1 to Bob, then this contract will still
    ///  have an order on the books for Wizard1. However, this contract will
    ///  not allow that order to be fulfilled, since the owner of Wizard1 has
    ///  changed, and this contract will only view an order as valid if the
    ///  wizard is still owned by the original order creator. Thus, if Bob is
    ///  now trying to create a sell order for Wizard1, we need to delete
    ///  Alice's old order.
    /// @param wizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param pricePerPower  An order creator specifies how much wei they are
    ///  willing to sell their wizard's power for. Note that this price is
    ///  per-power, so the buyer will actually have to pay this price
    ///  multiplied by the amount of power that the wizard has.
    /// @param makerAddress  The address of the creator of the order, the
    ///  seller, the owner of the wizard whose power will be relinquished.
    /// @param basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    /// @param savedSuccessfulTradeFeeInBasisPoints  We save the dev fee at the
    ///  time of order creation. This prevents an attack where the dev could
    ///  frontrun an order acceptance with a change to the dev fee.
    event CancelSellOrder(
    	uint256 wizardId,
        uint256 pricePerPower,
		address makerAddress,
        address basicTournamentAddress,
        uint256 savedSuccessfulTradeFeeInBasisPoints
    );

    /// @notice This event is fired a buyer successfully fills a seller's order.
    /// @param makerWizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param takerWizardId  The tokenId for the buyer's wizard. This is the
    ///  wizard that will receive its power if an order is fulfilled.
    /// @param pricePerPower  An order creator specifies how much wei they are
    ///  willing to sell their wizard's power for. Note that this price is
    ///  per-power, so the buyer will actually have to pay this price
    ///  multiplied by the amount of power that the wizard has.
    /// @param makerAddress  The address of the creator of the order, the
    ///  seller, the owner of the wizard whose power will be relinquished.
    /// @param takerAddress  The address of the fulfiller of the order, the
    ///  buyer, the owner of the wizard who will receive power.
    /// @param basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    /// @param savedSuccessfulTradeFeeInBasisPoints  We save the dev fee at the
    ///  time of order creation. This prevents an attack where the dev could
    ///  frontrun an order acceptance with a change to the dev fee.
    event FillSellOrder(
    	uint256 makerWizardId,
        uint256 takerWizardId,
        uint256 pricePerPower,
		address makerAddress,
        address takerAddress,
        address basicTournamentAddress,
        uint256 savedSuccessfulTradeFeeInBasisPoints
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @notice A mapping that tracks current order structs, indexed first by
    ///  tournament address and then by wizardId.
    /// @dev This contract is generalized to accept orders for multiple
    ///  cheezewizard tournaments, potentially simultaneously, potentially even
    ///  for the same wizard. This is because power is tournament-specific, so
    ///  the same wizard can have different amounts of power in different
    ///  tournaments.
    mapping(address => mapping(uint256 => Order)) internal orderForWizardIdAndTournamentAddress;

    /// @notice A simple ticker keeping track of the pricePerPower of the last
    ///  successful sale for this particular tournament. This could be useful
    ///  for displaying on a frontend UI as a guide for new orders, or the
    ///  current state of the market.
    mapping(address => uint256) public lastSuccessfulPricePerPowerForTournamentAddress;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @notice After calling approve() in the CheezeWizards Core contract
    ///  (called WizardGuild.sol), a seller can post an order to sell the power
    ///  of one of their wizards for a particular tournament (found in the
    ///  contract BasicTournament.sol). Note that this only sells the wizard's
    ///  power, but the seller will retain the NFT itself.
    /// @dev The reason that this contract emits the CancelSellOrder event
    ///  when a user calls createSellOrder() for a wizard that already
    ///  has a (potentially invalid) order on the books is illustrated by the
    ///  following scenario: if Alice creates an order for Wizard1 on this
    ///  contract, but then sells Wizard1 to Bob, then this contract will still
    ///  have an order on the books for Wizard1. However, this contract will
    ///  not allow that order to be fulfilled, since the owner of Wizard1 has
    ///  changed, and this contract will only view an order as valid if the
    ///  wizard is still owned by the original order creator. Thus, if Bob is
    ///  now trying to create a sell order for Wizard1, we need to delete
    ///  Alice's old order.
    /// @param _wizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param _pricePerPower  An order creator specifies how much wei they are
    ///  willing to sell their wizard's power for. Note that this price is
    ///  per-power, so the buyer will actually have to pay this price
    ///  multiplied by the amount of power that the wizard has.
    /// @param _basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    function createSellOrder(uint256 _wizardId, uint256 _pricePerPower, address _basicTournamentAddress) external whenNotPaused nonReentrant {
        require(WizardGuild(wizardGuildAddress).ownerOf(_wizardId) == msg.sender, 'only the owner of the wizard can create a sell order');
        require(WizardGuild(wizardGuildAddress).isApprovedOrOwner(address(this), _wizardId), 'you must call the approve() function on WizardGuild before you can create a sell order');
        require(_pricePerPower <= uint256(~uint128(0)), 'you cannot specify a _pricePerPower greater than uint128_max');

        // Fetch wizard's stats from BasicTournament contract
        bool molded;
        bool ready;
        ( , , , , , , , molded, ready) = BasicTournament(_basicTournamentAddress).getWizard(_wizardId);
        require(molded == false, 'you cannot sell the power from a molded wizard');
        require(ready == true, 'you cannot sell the power from a wizard that is not ready');

        Order memory previousOrder = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];

        // Check if an order already exists for this wizard within this
        // tournament
        if(previousOrder.makerAddress != address(0)){
            // If an order already exists, delete it before we create a new one
            emit CancelSellOrder(
                uint256(previousOrder.wizardId),
                uint256(previousOrder.pricePerPower),
                previousOrder.makerAddress,
                previousOrder.basicTournamentAddress,
                uint256(previousOrder.savedSuccessfulTradeFeeInBasisPoints)
            );
            delete orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];
        }

        // Save the new order to storage
        Order memory order = Order({
            wizardId: uint256(_wizardId),
            pricePerPower: uint128(_pricePerPower),
            makerAddress: msg.sender,
            basicTournamentAddress: _basicTournamentAddress,
            savedSuccessfulTradeFeeInBasisPoints: uint16(successfulTradeFeeInBasisPoints)
        });
        orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId] = order;
        emit CreateSellOrder(
            _wizardId,
            _pricePerPower,
            msg.sender,
            _basicTournamentAddress,
            successfulTradeFeeInBasisPoints
        );
    }

    /// @notice A seller/maker calls this function to update the pricePerPower
    ///  of an order that they already have stored in this contract. This saves
    ///  some gas for the seller by allowing them to just update the
    ///  pricePerPower parameter of their order.
    /// @param _wizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param _newPricePerPower  An order creator specifies how much wei they
    ///  are willing to sell their wizard's power for. Note that this price is
    ///  per-power, so the buyer will actually have to pay this price
    ///  multiplied by the amount of power that the wizard has.
    /// @param _basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    function updateSellOrder(uint256 _wizardId, uint256 _newPricePerPower, address _basicTournamentAddress) external whenNotPaused nonReentrant {
        require(WizardGuild(wizardGuildAddress).ownerOf(_wizardId) == msg.sender, 'only the owner of the wizard can update a sell order');
        require(WizardGuild(wizardGuildAddress).isApprovedOrOwner(address(this), _wizardId), 'you must call the approve() function on WizardGuild before you can update a sell order');
        require(_newPricePerPower <= uint256(~uint128(0)), 'you cannot specify a _newPricePerPower greater than uint128_max');

        // Fetch order
        Order storage order = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];

        // Check that order is not from a previous owner
        require(msg.sender == order.makerAddress, 'you can only update a sell order that you created');

        // Emit event
        emit UpdateSellOrder(
            _wizardId,
            uint256(order.pricePerPower),
            _newPricePerPower,
            msg.sender,
            _basicTournamentAddress,
            uint256(order.savedSuccessfulTradeFeeInBasisPoints)
        );

        // Update price
        order.pricePerPower = uint128(_newPricePerPower);
    }

    /// @notice A seller/maker calls this function to cancel an existing order
    ///  that they have posted to this contract.
    /// @dev Unlike the other Order functions, this function can be called even
    ///  if the contract is paused, so that users can clear out their orderbook
    ///  if they would like.
    /// @param _wizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param _basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    function cancelSellOrder(uint256 _wizardId, address _basicTournamentAddress) external nonReentrant {
        require(WizardGuild(wizardGuildAddress).ownerOf(_wizardId) == msg.sender, 'only the owner of the wizard can cancel a sell order');

        // Wait until after emitting event to delete order so that event data
        // can be pulled from soon-to-be-deleted order
        Order memory order = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];
        emit CancelSellOrder(
            uint256(order.wizardId),
            uint256(order.pricePerPower),
            msg.sender,
            _basicTournamentAddress,
            uint256(order.savedSuccessfulTradeFeeInBasisPoints)
        );

        // Delete order
        delete orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];
    }

    /// @notice A buyer/taker calls this function to complete an order, paying
    ///  pricePerPower multiplied by the makerWizard's current power in order
    ///  to transfer the makerWizard's power to the takerWizard.
    /// @dev The buyer/taker must send enough wei along with this function call
    ///  to cover pricePerPower multiplied by the makerWizard's current power.
    /// @param _makerWizardId  The tokenId for the seller's wizard. This is the
    ///  wizard that will relinquish its power if an order is fulfilled.
    /// @param _takerWizardId  The tokenId for the buyer's wizard. This is the
    ///  wizard that will receive its power if an order is fulfilled.
    /// @param _basicTournamentAddress  The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately, so
    ///  orders can exist simultaneously for the same wizard for different
    ///  tournaments.
    /// @param _referrer  This address gets half of the successful trade fees.
    ///  This encourages third party developers to develop their own front-end
    ///  UI's for this contract in order to receive half of the rewards.
    function fillSellOrder(uint256 _makerWizardId, uint256 _takerWizardId, address _basicTournamentAddress, address _referrer) external payable whenNotPaused nonReentrant {
        require(WizardGuild(wizardGuildAddress).ownerOf(_takerWizardId) == msg.sender, 'you can only purchase power for a wizard that you own');
        Order memory order = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_makerWizardId];
        require(WizardGuild(wizardGuildAddress).ownerOf(_makerWizardId) == order.makerAddress, 'an order is only valid while the order creator owns the wizard');

        // Fetch wizard's stats from BasicTournament contract
        uint256 power;
        bool molded;
        bool ready;
        ( , power, , , , , , molded, ready) = BasicTournament(_basicTournamentAddress).getWizard(_makerWizardId);
        require(molded == false, 'you cannot sell the power from a molded wizard');
        require(ready == true, 'you cannot sell the power from a wizard that is not ready');

        // Update the global ticker for the last successful pricePerPower sale
        // price
        lastSuccessfulPricePerPowerForTournamentAddress[_basicTournamentAddress] = uint256(order.pricePerPower);

        // Calculate seller proceeds and contractCreator fees
        uint256 priceToFillOrder = (uint256(order.pricePerPower)).mul(power);
        require(msg.value >= priceToFillOrder, 'you did not send enough wei to fulfill this order');
        uint256 sellerProceeds = _computeSellerProceeds(priceToFillOrder, uint256(order.savedSuccessfulTradeFeeInBasisPoints));
        uint256 fees = priceToFillOrder.sub(sellerProceeds);
        uint256 excess = (msg.value).sub(priceToFillOrder);

        // Save the seller's address before we delete the order
        address payable orderMakerAddress = address(uint160(order.makerAddress));

        // Emit event
        emit FillSellOrder(
            uint256(order.wizardId),
            _takerWizardId,
            uint256(order.pricePerPower),
            address(order.makerAddress),
            msg.sender,
            order.basicTournamentAddress,
            uint256(order.savedSuccessfulTradeFeeInBasisPoints)
        );

        // Delete the order prior to sending any funds
        delete orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_makerWizardId];

        // Transfer Power from maker wizard to taker wizard
        BasicTournament(_basicTournamentAddress).giftPower(_makerWizardId, _takerWizardId);

        // Send proceeds to seller/maker
        orderMakerAddress.transfer(sellerProceeds);

        // Store fees earned by contract creator in contract until creator calls
        // withdrawsEarnings()
        // This prevents a halting condition that would occur if one of the fee
        // earners rejects incoming transfers
        if(_referrer != address(0)){
            uint256 halfOfFees = fees.div(uint256(2));
            addressToFeeEarnings[_referrer] = addressToFeeEarnings[_referrer].add(halfOfFees);
            addressToFeeEarnings[owner()] = addressToFeeEarnings[owner()].add(halfOfFees);
        } else {
            addressToFeeEarnings[owner()] = addressToFeeEarnings[owner()].add(fees);
        }

        // Send any excess wei back to buyer/taker
        if(excess > 0){
            msg.sender.transfer(excess);
        }
    }

    /// @notice A simple getter function to return an order for a given wizard
    ///  and tournament address.
    /// @dev The reason that we cannot simply use Solidity's automatically
    ///  created getter functions is that the orders are stored in a nested
    ///  mapping, which messes with Solidity's automatically created getters.
    /// @param _wizardId The id of the wizard NFT whose order we would like to
    ///  see the details of.
    /// @param _basicTournamentAddress The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately.
    /// @return The values from the Order struct, returned in tuple-form.
    function getOrder(uint256 _wizardId, address _basicTournamentAddress) external view returns (uint256 wizardId, uint256 pricePerPower, address makerAddress, address basicTournamentAddress, uint256 savedSuccessfulTradeFeeInBasisPoints){
        Order memory order = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];
        return (uint256(order.wizardId), uint256(order.pricePerPower), address(order.makerAddress), address(order.basicTournamentAddress), uint256(order.savedSuccessfulTradeFeeInBasisPoints));
    }

    /// @notice A convenience function providing the caller with the current
    ///  amount needed (in wei) to fulfill this order.
    /// @param _wizardId The id of the wizard NFT whose order we would like to
    ///  see the details of.
    /// @param _basicTournamentAddress The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately.
    /// @return The amount needed (in wei) to fulfill this order
    function getCurrentPriceForOrder(uint256 _wizardId, address _basicTournamentAddress) external view returns (uint256){
        Order memory order = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];
        uint256 power;
        ( , power, , , , , , , ) = BasicTournament(_basicTournamentAddress).getWizard(_wizardId);
        uint256 price = power.mul(uint256(order.pricePerPower));
        return price;
    }

    /// @notice A convenience function checking whether the order is currently
    ///  valid. Note that an order can become invalid for a period of time, but
    ///  then become valid again (for example, during the time that a wizard
    ///  is dueling).
    /// @param _wizardId The id of the wizard NFT whose order we would like to
    ///  see the details of.
    /// @param _basicTournamentAddress The address of the tournament that this
    ///  order pertains to. Note that each Wizard has an independent power
    ///  value for each tournament, and call sell each one separately.
    /// @return Whether the order is currently valid or not.
    function getIsOrderCurrentlyValid(uint256 _wizardId, address _basicTournamentAddress) external view returns (bool){
        Order memory order = orderForWizardIdAndTournamentAddress[_basicTournamentAddress][_wizardId];
        if(order.makerAddress == address(0)){
            // Order is not valid if order does not exist
            return false;
        } else {

            if(WizardGuild(wizardGuildAddress).ownerOf(_wizardId) != order.makerAddress){
                // Order is not valid if order's creator no longer owns wizard
                return false;
            }
            bool molded;
            bool ready;
            ( , , , , , , , molded, ready) = BasicTournament(_basicTournamentAddress).getWizard(_wizardId);
            if(molded == true || ready == false){
                // Order is not valid if makerWizard is molded or is dueling
                return false;
            } else {
                return true;
            }
        }
    }

    /// @notice A getter function for determining whether we are currently in a
    ///  fightWindow for a given tournament
    /// @param _basicTournamentAddress  The address of the tournament in
    ///  question
    /// @return  Whether or not we are in a fightWindow for this tournament
    function getIsInFightWindow(address _basicTournamentAddress) external view returns (bool){
        return _isInFightWindowForTournament(_basicTournamentAddress);
    }

    /// @notice Computes the seller proceeds given a total value sent,
    ///  and the successfulTradeFee in percentage basis points that was saved
    ///  at the time of the order's creation.
    /// @dev 10000 is not a magic number, but is the maximum number of basis
    ///  points that can exist (with basis points being hundredths of a
    ///  percent).
    /// @param _totalValueIncludingFees The amount of ether (in wei) that was
    ///  sent to complete the trade
    /// @param _successfulTradeFeeInBasisPoints The percentage (in basis points)
    ///  of that total amount that will be taken as a fee if the trade is
    ///  successfully completed.
    /// @return The amount of ether (in wei) that will be sent to the seller if
    ///  the trade is successfully completed
    function _computeSellerProceeds(uint256 _totalValueIncludingFees, uint256 _successfulTradeFeeInBasisPoints) internal pure returns (uint256) {
    	return (_totalValueIncludingFees.mul(uint256(10000).sub(_successfulTradeFeeInBasisPoints))).div(uint256(10000));
    }

    /// @dev By calling 'revert' in the fallback function, we prevent anyone from
    ///  accidentally sending funds directly to this contract.
    function() external payable {
        revert();
    }
}