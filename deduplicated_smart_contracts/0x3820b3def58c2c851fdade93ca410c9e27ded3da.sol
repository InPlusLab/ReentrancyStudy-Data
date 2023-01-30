/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

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

// File: @openzeppelin/contracts/access/Roles.sol

pragma solidity ^0.5.0;

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

// File: @openzeppelin/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;



contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
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

// File: @openzeppelin/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    // counter to allow mutex lock with only one SSTORE operation
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
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// File: 0.5-contracts/normal_deployment/racing/RacingAdmins.sol

pragma solidity ^0.5.8;



contract RacingAdmins is Context {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _admins;

    constructor () internal {
        _addAdmin(_msgSender());
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAdmin(address account) public onlyAdmin {
        _removeAdmin(account);
    }

    function _addAdmin(address account) internal {
        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }
}

// File: 0.5-contracts/normal_deployment/racing/RacingFeeReceiver.sol

pragma solidity ^0.5.8;


contract RacingFeeReceiver is RacingAdmins {
    address payable private _feeWallet;

    event FeeWalletTransferred(address indexed previousFeeWallet, address indexed newFeeWallet);

    /**
     * @dev Returns the address of the current fee receiver.
     */
    function feeWallet() public view returns (address payable) {
        return _feeWallet;
    }

    /**
     * @dev Throws if called by any account other than the fee receiver wallet.
     */
    modifier onlyFeeWallet() {
        require(isFeeWallet(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current fee receiver wallet.
     */
    function isFeeWallet() public view returns (bool) {
        return _msgSender() == _feeWallet;
    }

    /**
     * @dev Leaves the contract without fee receiver wallet.
     *
     * NOTE: Renouncing will leave the contract without an fee receiver wallet.
     * It means that fee will be transferred to the zero address.
     */
    function renounceFeeWallet() public onlyAdmin {
        emit FeeWalletTransferred(_feeWallet, address(0));
        _feeWallet = address(0);
    }

    /**
     * @dev Transfers address of the fee receiver to a new address (`newFeeWallet`).
     * Can only be called by admins.
     */
    function transferFeeWalletOwnership(address payable newFeeWallet) public onlyAdmin {
        _transferFeeWalletOwnership(newFeeWallet);
    }

    /**
     * @dev Transfers address of the fee receiver to a new address (`newFeeWallet`).
     */
    function _transferFeeWalletOwnership(address payable newFeeWallet) internal {
        require(newFeeWallet != address(0), "Ownable: new owner is the zero address");
        emit FeeWalletTransferred(_feeWallet, newFeeWallet);
        _feeWallet = newFeeWallet;
    }
}

// File: 0.5-contracts/normal_deployment/racing/RacingStorage.sol

pragma solidity ^0.5.8;



contract RacingStorage is RacingFeeReceiver, ReentrancyGuard {
    // --
    // Permanent Storage Variables
    // --

    mapping(bytes32 => Race) public Races; // The race mapping structure.
    mapping(uint256 => address) public Owner_Horse; // Owner of the Horse ID.
    mapping(uint256 => uint256) public Horse_Active_Races; // Number of races the horse is registered for.
    mapping(bytes32 => bool) public ID_Saved; // Returns whether or not the race ID is present on storage already.
    mapping(uint256 => uint256) public Position_To_Payment; // Returns the percentage of the payment depending on horse's position in a race.
    mapping(address => bool) public Is_Authorized; // Returns whether an address is authorized or not.
    mapping(bytes32 => string) public Cancelled_Races; // Returns a cancelled race and its reason to be cancelled.
    mapping(bytes32 => bool) public Has_Zed_Claimed; // Returns whether or not winnings for a race have been claimed for Zed.

    address BB; // Blockchain Brain
    address Core; // Core contract.

    struct Race {
        string Track_Name; // Name of the track or event.
        bytes32 Race_ID; // Key provided for Race ID.
        uint256 Length; // Length of the track (m).
        uint256 Horses_Registered; // Current number of horses registered.
        uint256 Unix_Start; // Timestamp the race starts.
        uint256 Entrance_Fee; // Entrance fee for a particular race (10^18).
        uint256 Prize_Pool; // Total bets in the prize pool (10^18).
        uint256 Horses_Allowed; // Total number of horses allowed for a race.
        uint256[] Horses; // List of Horse IDs on Race.
        State Race_State; // Current state of the race.
        mapping(uint256 => Horse) Lineup; // Mapping of the Horse ID => Horse struct.
        mapping(uint256 => uint256) Gate_To_ID; // Mapping of the Gate # => Horse ID.
        mapping(uint256 => bool) Is_Gate_Taken; // Whether or not a gate number has been taken.
    }

    struct Horse {
        uint256 Gate; // Gate this horse is currently at.
        uint256 Total_Bet; // Total amount bet on this horse.
        uint256 Final_Position; // Final position of the horse (1 to Horses allowed in race).
        mapping(address => uint256) Bet_Placed; // Amount a specific address bet on this horse.
        mapping(address => bool) Bet_Claimed; // Whether or not that specific address claimed their bet.
    }

    enum State {Null, Registration, Betting, Final, Fail_Safe}
}

// File: 0.5-contracts/normal_deployment/racing/RacingArena.sol

pragma solidity ^0.5.8;




contract RacingArena is RacingStorage, Pausable {
    using SafeMath for uint256;

    // --
    // Events
    // --

    event BetPlaced(
        bytes32 indexed _raceId,
        address indexed _bettor,
        uint256 _betAmount,
        uint256 indexed _horseID
    );

    event PrizeClaimed(
        bytes32 indexed _raceId,
        address indexed _bettor,
        uint256 _claimAmount,
        uint256 indexed _horseID
    );

    event HorseRegistered(
        bytes32 indexed _raceId,
        address indexed _horseOwner,
        uint256 indexed _horseID,
        uint256 _gateNumber
    );

    event HorseTransferredIn(address indexed _horseOwner, uint256[] _horseIDs);

    event HorseTransferredOut(address indexed _horseOwner, uint256[] _horseIDs);

    event RaceCreated(
        bytes32 indexed _raceId,
        string _name,
        uint256 _length,
        uint256 _registrationFee
    );

    event RaceScheduled(
        bytes32 indexed _raceId,
        uint256 _unixStart,
        string _name
    );

    event RaceFull(bytes32 indexed _raceId);

    event ResultsPosted(
        bytes32 indexed _raceId,
        uint256 _firstPlaceHorseID,
        uint256 _secondPlaceHorseID,
        uint256 _thirdPlaceHorseID
    );

    event RaceCancelled(
        bytes32 indexed _raceId,
        string _reason,
        address _canceller
    );

    // --
    // Admin Functions
    // --

    // Admin creates upcoming races, specifying the track name, the track length, and the entrance fee.
    function createRace(
        bytes32 _raceId,
        string memory _name,
        uint256 _horsesAllowed,
        uint256 _entranceFee,
        uint256 _length
    ) public onlyAdmin() nonReentrant() whenNotPaused() {
        // Pre-check and struct inialization.
        require(_entranceFee > 0, "Entrance fee lower than zero");
        require(!ID_Saved[_raceId], "Race ID exists");

        Race memory race;
        race.Race_ID = _raceId;
        race.Track_Name = _name;
        race.Horses_Allowed = _horsesAllowed;
        race.Entrance_Fee = _entranceFee;
        race.Length = _length;
        race.Race_State = State.Registration;

        Races[_raceId] = race;
        ID_Saved[_raceId] = true;

        // Event trigger.
        emit RaceCreated(_raceId, _name, _length, _entranceFee);
    }

    // Admin can schedule a race when it's full (12 horses).
    function scheduleRace(bytes32 _raceId, uint256 _startTime)
        public
        onlyAdmin()
        nonReentrant()
    {
        // Prechecks.
        Race storage race = Races[_raceId];

        require(
            race.Horses_Registered == race.Horses_Allowed,
            "Not enough horses registered"
        );
        require(
            race.Race_State == State.Registration,
            "Race is not in registration state"
        );
        require(
            _startTime > now + 5 minutes,
            "Start time doesnt meet criteria"
        );

        // State changes.
        race.Unix_Start = _startTime;
        race.Race_State = State.Betting; // State transition from Registration -> Betting.

        emit RaceScheduled(_raceId, _startTime, race.Track_Name);
    }

    function initSetup(address _core, address _bb)
        public
        onlyAdmin()
    {
        Position_To_Payment[1] = 60;
        Position_To_Payment[2] = 20;
        Position_To_Payment[3] = 10;

        BB = _bb;
        Core = _core;
    }

    function setBbAddress(address _bb)
        public
        onlyAdmin()
    {
        BB = _bb;
    }

    // Admin posts the result of the race, enabling bettors to claim their winnings.
    /*
    @dev Receives results for a given race, removes 1 active race from the given horses.
    Transitions race state and sends funds to one of the owner addresses as well.
    @param _raceId Race ID we're going to post the results to.
    @param _results List of of horse IDs that participated on the race in position order.
    */
    function postResults(bytes32 _raceId, uint256[12] memory _results)
        public
        onlyAdmin()
        nonReentrant()
    {
        Race storage race = Races[_raceId];

        // Pre-checks
        require(
            race.Race_State == State.Betting,
            "Race is not on betting state"
        );
        require(race.Unix_Start <= now + 1 minutes, "Mismatch on unix start");

        race.Race_State = State.Final; // State transition from Betting -> Final.

        for (uint256 k = 0; k < race.Horses_Allowed; k++) {
            require(race.Lineup[_results[k]].Gate != 0, "ID not registered");
        }

        // Update the Race struct. Active race reduced.
        for (uint256 j = 0; j < race.Horses_Allowed; j++) {
            race.Lineup[_results[j]].Final_Position = j + 1;
            Horse_Active_Races[_results[j]]--;
        }

        // Duplication post-check.
        for (uint256 i = 0; i < race.Horses_Allowed; i++) {
            require(
                race.Lineup[_results[i]].Final_Position == i + 1,
                "ID not submitted properly"
            );
        }

        // Sends funds to one of Zed's accounts.
        feeWallet().transfer(race.Prize_Pool.mul(10).div(100));

        emit ResultsPosted(_raceId, _results[0], _results[1], _results[2]);
    }

    function cancelRace(bytes32 _raceId, string memory _reason)
        public
        onlyAdmin()
        nonReentrant()
    {
        Race storage race = Races[_raceId];

        // Pre-checks.
        require(
            race.Race_State == State.Registration ||
                race.Race_State == State.Betting,
            "Race not on regs or betting state"
        );

        race.Race_State = State.Fail_Safe;

        Cancelled_Races[_raceId] = _reason;

        // Loops through the IDs on a race by index and removes them out of an active race.
        for (uint256 i = 0; i < race.Horses_Registered; i++) {
            Horse_Active_Races[race.Horses[i]]--;
        }

        emit RaceCancelled(_raceId, _reason, msg.sender);
    }

    // --
    // Public Functions
    // --

    // Bulk transfers horses into race contract.
    // Limit of 15.
    function bulkTransferIn(uint256[] memory _horseIDs) public nonReentrant() {
        require(_horseIDs.length < 16, "Only 15 horses allowed per transfer");

        for (uint8 i = 0; i < _horseIDs.length; i++) {
            Owner_Horse[_horseIDs[i]] = msg.sender;
            ERC721(Core).safeTransferFrom(
                msg.sender,
                address(this),
                _horseIDs[i]
            );
        }

        emit HorseTransferredIn(msg.sender, _horseIDs);
    }

    // Bulk transfers horses out of race contract.
    // Limit of 15.
    function bulkTransferOut(uint256[] memory _horseIDs) public nonReentrant() {
        require(_horseIDs.length < 16, "Only 15 horses allowed per transfer");

        for (uint8 i = 0; i < _horseIDs.length; i++) {
            require(
                Owner_Horse[_horseIDs[i]] == msg.sender,
                "Caller is not the owner."
            );
            require(
                Horse_Active_Races[_horseIDs[i]] == 0,
                "Horse currently active in a race."
            );

            Owner_Horse[_horseIDs[i]] = address(0);

            ERC721(Core).safeTransferFrom(
                address(this),
                msg.sender,
                _horseIDs[i]
            );
        }

        emit HorseTransferredOut(msg.sender, _horseIDs);
    }

    // Registers a horse for the selected race. Enacts transfer of the entrance fee, and transfer of the ERC-721 horse.
    function registerHorse(
        bytes32 _raceId,
        uint256 _horseID,
        uint256 _gateNumber
    ) public payable nonReentrant() whenNotPaused() {
        Race storage race = Races[_raceId];

        // Pre-checks.
        require(msg.value >= race.Entrance_Fee, "Entrance fee not met");
        require(
            race.Race_State == State.Registration,
            "Race not accepting registrations"
        );
        require(
            race.Horses_Registered < race.Horses_Allowed,
            "Max number of horses for race"
        );
        require(_gateNumber >= 1, "Gate number lower than 1.");
        require(
            _gateNumber <= race.Horses_Allowed,
            "Gate number greater than max"
        );
        require(!race.Is_Gate_Taken[_gateNumber], "Gate number already taken");
        require(
            Horse_Active_Races[_horseID] < 3,
            "Horse currently active in 3 races"
        );
        require(
            race.Lineup[_horseID].Gate == 0,
            "Horse already registered for this race"
        );
        require(
            ERC721(Core).ownerOf(_horseID) == address(this),
            "Racing contract not owner of horse."
        );

        // Insert a new Horse struct with the appropriate information.
        Horse_Active_Races[_horseID]++;
        race.Horses_Registered++;
        race.Lineup[_horseID] = Horse(_gateNumber, 0, 0);
        race.Gate_To_ID[_gateNumber] = _horseID;

        // Mark gate number as taken.
        race.Is_Gate_Taken[_gateNumber] = true;

        // Handle accounting of the registration fee as a bet on their horse.
        race.Prize_Pool += race.Entrance_Fee;
        race.Lineup[_horseID].Total_Bet += race.Entrance_Fee;
        race.Lineup[_horseID].Bet_Placed[msg.sender] += race.Entrance_Fee;
        race.Horses.push(_horseID);

        if (race.Horses_Registered == race.Horses_Allowed) {
            emit RaceFull(_raceId);
        }

        emit HorseRegistered(_raceId, msg.sender, _horseID, _gateNumber);
        emit BetPlaced(_raceId, msg.sender, race.Entrance_Fee, _horseID);
    }

    // function placeBet(bytes32 _raceId, uint _horseID, uint _amount) public nonReentrant() {
    //     Race storage race = Races[_raceId];

    //     // Pre-checks.
    //     require(race.Race_State == State.Betting, "Bets are not allowed");
    //     require(race.Unix_Start > now - 5 minutes, "The betting period has ended.");
    //     require(race.Lineup[_horseID].Gate != 0, "Horse not registered for this race.");
    //     require(_amount % 1 ether == 0, "Bet should have no remainder");

    //     // Transfer bet and update Race struct.
    //     require(ERC20(DAI).transferFrom(msg.sender, address(this), _amount), "Caller lacks funds, or contract lacks approval for the bet.");

    //     race.Prize_Pool += _amount;
    //     race.Lineup[_horseID].Total_Bet += _amount;
    //     race.Lineup[_horseID].Bet_Placed[msg.sender] += _amount;

    //     emit BetPlaced(_raceId, msg.sender, _amount, _horseID);
    // }

    function claimWinningsHelper(bytes32 _raceId, uint256 _horseID)
        public
        nonReentrant()
    {
        Race storage race = Races[_raceId];

        address horseOwner = Owner_Horse[_horseID];

        // Pre-checks.
        // For now only the owner is able to claim the winnings for a horse.
        require(msg.sender == horseOwner, "Not horse owner");
        require(race.Race_State == State.Final, "Race still running");
        require(
            !race.Lineup[_horseID].Bet_Claimed[horseOwner],
            "Winnings have already been claimed"
        );

        race.Lineup[_horseID].Bet_Claimed[horseOwner] = true;

        uint256 horsePosition = race.Lineup[_horseID].Final_Position;

        // Limit is race's prize pool.
        uint256 toTransfer = race
            .Prize_Pool
            .mul(Position_To_Payment[horsePosition])
            .div(100);

        msg.sender.transfer(toTransfer);

        emit PrizeClaimed(_raceId, horseOwner, toTransfer, _horseID);
    }

    // function reclaimBetHelper(bytes32 _raceId, uint _horseID, address payable _bettor) public nonReentrant() {
    //     Race storage race = Races[_raceId];

    //     // Pre-checks.
    //     require(race.Race_State == State.Fail_Safe, "Contract not in fail safe mode");
    //     require(!race.Lineup[_horseID].Bet_Claimed[_bettor], "Bet already reclaimed");
    //     race.Lineup[_horseID].Bet_Claimed[_bettor] = true;

    //     // Reclaim bet.
    //     uint bet = race.Lineup[_horseID].Bet_Placed[_bettor];

    //     _bettor.transfer(bet);

    //     // ? Add an event.
    // }

    function onERC721Received(address, address, uint256, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    // Small helper function for retreieving the Horse ID based off Gate # (1 - 12, no 0 element).
    function getHorseID(bytes32 _raceId, uint256 _gate)
        public
        view
        returns (uint256)
    {
        return Races[_raceId].Gate_To_ID[_gate];
    }

    // Small helper function for retreieving more detailed information about a horse (for Retrieval purposes) based off Gate # (1 - 12, no 0 element).
    function getHorseInfo(bytes32 _raceId, uint256 _gate)
        public
        view
        returns (uint256, uint256)
    {
        Race storage race = Races[_raceId];

        return (
            race.Gate_To_ID[_gate],
            race.Lineup[race.Gate_To_ID[_gate]].Final_Position
        );
    }

    // Small helper function for personal bet information based off Gate # (1 - 12, no 0 element).
    function getBetInfo(bytes32 _raceId, uint256 _gate, address _bettor)
        public
        view
        returns (uint256, uint256, uint256, bool, uint256)
    {
        Race storage race = Races[_raceId];

        return (
            race.Prize_Pool,
            race.Lineup[race.Gate_To_ID[_gate]].Total_Bet,
            race.Lineup[race.Gate_To_ID[_gate]].Bet_Placed[_bettor],
            race.Lineup[race.Gate_To_ID[_gate]].Bet_Claimed[_bettor],
            race.Lineup[race.Gate_To_ID[_gate]].Final_Position
        );
    }

    function getHorsesInRace(bytes32 _raceId)
        public
        view
        returns (uint256[] memory)
    {
        Race storage race = Races[_raceId];

        return race.Horses;
    }

    function getCoreAddress()
        public
        view
        returns (address)
    {
        return Core;
    }

    function getBBAddress()
        public
        view
        returns (address)
    {
        return BB;
    }

    /*  RESTRICTED  */
    function changePaymentAllocation(uint256 _position, uint256 _percentage)
        public
        onlyAdmin()
    {
        Position_To_Payment[_position] = _percentage;
    }

    function() external payable {}
}

interface ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId)
        external
        payable;
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external
        payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function getApproved(uint256 _tokenId) external view returns (address);
    function setApprovalForAll(address _to, bool _approved) external;
}