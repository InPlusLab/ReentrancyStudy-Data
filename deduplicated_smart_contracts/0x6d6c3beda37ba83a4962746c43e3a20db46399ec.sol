/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity >=0.5.6 <0.6.0;


/// @title ERC165Interface
/// @dev https://eips.ethereum.org/EIPS/eip-165
interface ERC165Interface {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///      uses less than 30,000 gas.
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


/// @title Shared constants used throughout the Cheeze Wizards contracts
contract WizardConstants {
    // Wizards normally have their affinity set when they are first created,
    // but for example Exclusive Wizards can be created with no set affinity.
    // In this case the affinity can be set by the owner.
    uint8 internal constant ELEMENT_NOTSET = 0; //000
    // A neutral Wizard has no particular strength or weakness with specific
    // elements.
    uint8 internal constant ELEMENT_NEUTRAL = 1; //001
    // The fire, water and wind elements are used both to reflect an affinity
    // of Elemental Wizards for a specific element, and as the moves a
    // Wizard can make during a duel.
    // Note that if these values change then `moveMask` and `moveDelta` in
    // ThreeAffinityDuelResolver would need to be updated accordingly.
    uint8 internal constant ELEMENT_FIRE = 2; //010
    uint8 internal constant ELEMENT_WATER = 3; //011
    uint8 internal constant ELEMENT_WIND = 4; //100
    uint8 internal constant MAX_ELEMENT = ELEMENT_WIND;
}




contract ERC1654 {

    /// @dev bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 public constant ERC1654_VALIDSIGNATURE = 0x1626ba7e;

    /// @dev Should return whether the signature provided is valid for the provided data
    /// @param hash 32-byte hash of the data that is signed
    /// @param _signature Signature byte array associated with _data
    ///  MUST return the bytes4 magic value 0x1626ba7e when function passes.
    ///  MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
    ///  MUST allow external calls
    function isValidSignature(
        bytes32 hash,
        bytes calldata _signature)
        external
        view
        returns (bytes4);
}








/**
 * @title IERC165
 * @dev https://eips.ethereum.org/EIPS/eip-165
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


contract WizardGuildInterfaceId {
    bytes4 internal constant _INTERFACE_ID_WIZARDGUILD = 0x41d4d437;
}

/// @title The public interface of the Wizard Guild
/// @notice The methods listed in this interface (including the inherited ERC-721 interface),
///         make up the public interface of the Wizard Guild contract. Any contracts that wish
///         to make use of Cheeze Wizard NFTs (such as Cheeze Wizards Tournaments!) should use
///         these methods to ensure they are working correctly with the base NFTs.
contract WizardGuildInterface is IERC721, WizardGuildInterfaceId {

    /// @notice Returns the information associated with the given Wizard
    ///         owner - The address that owns this Wizard
    ///         innatePower - The innate power level of this Wizard, set when minted and entirely
    ///               immutable
    ///         affinity - The Elemental Affinity of this Wizard. For most Wizards, this is set
    ///               when they are minted, but some exclusive Wizards are minted with an affinity
    ///               of 0 (ELEMENT_NOTSET). A Wizard with an NOTSET affinity should NOT be able
    ///               to participate in Tournaments. Once the affinity of a Wizard is set to a non-zero
    ///               value, it can never be changed again.
    ///         metadata - A 256-bit hash of the Wizard's metadata, which is stored off chain. This
    ///               contract doesn't specify format of this hash, nor the off-chain storage mechanism
    ///               but, let's be honest, it's probably an IPFS SHA-256 hash.
    ///
    ///         NOTE: Series zero Wizards have one of four Affinities:  Neutral (1), Fire (2), Water (3)
    ///               or Air (4, sometimes called "Wind" in the code). Future Wizard Series may have
    ///               additional Affinities, and clients of this API should be prepared for that
    ///               eventuality.
    function getWizard(uint256 id) external view returns (address owner, uint88 innatePower, uint8 affinity, bytes32 metadata);

    /// @notice Sets the affinity for a Wizard that doesn't already have its elemental affinity chosen.
    ///         Only usable for Exclusive Wizards (all non-Exclusives must have their affinity chosen when
    ///         conjured.) Even Exclusives can't change their affinity once it's been chosen.
    ///
    ///         NOTE: This function can only be called by the series minter, and (therefore) only while the
    ///         series is open. A Wizard that has no affinity when a series is closed will NEVER have an Affinity.
    ///         BTW- This implies that a minter is responsible for either never minting ELEMENT_NOTSET
    ///         Wizards, or having some public mechanism for a Wizard owner to set the Affinity after minting.
    /// @param wizardId The id of the wizard
    /// @param newAffinity The new affinity of the wizard
    function setAffinity(uint256 wizardId, uint8 newAffinity) external;

    /// @notice A function to be called that conjures a whole bunch of Wizards at once! You know how
    ///         there's "a pride of lions", "a murder of crows", and "a parliament of owls"? Well, with this
    ///         here function you can conjure yourself "a stench of Cheeze Wizards"!
    ///
    ///         Unsurprisingly, this method can only be called by the registered minter for a Series.
    /// @param powers the power level of each wizard
    /// @param affinities the Elements of the wizards to create
    /// @param owner the address that will own the newly created Wizards
    function mintWizards(
        uint88[] calldata powers,
        uint8[] calldata affinities,
        address owner
        ) external returns (uint256[] memory wizardIds);

    /// @notice A function to be called that conjures a series of Wizards in the reserved ID range.
    /// @param wizardIds the ID values to use for each Wizard, must be in the reserved range of the current Series
    /// @param affinities the Elements of the wizards to create
    /// @param powers the power level of each wizard
    /// @param owner the address that will own the newly created Wizards
    function mintReservedWizards(
        uint256[] calldata wizardIds,
        uint88[] calldata powers,
        uint8[] calldata affinities,
        address owner
        ) external;

    /// @notice Sets the metadata values for a list of Wizards. The metadata for a Wizard can only be set once,
    ///         can only be set by the COO or Minter, and can only be set while the Series is still open. Once
    ///         a Series is closed, the metadata is locked forever!
    /// @param wizardIds the ID values of the Wizards to apply metadata changes to.
    /// @param metadata the raw metadata values for each Wizard. This contract does not define how metadata
    ///         should be interpreted, but it is likely to be a 256-bit hash of a complete metadata package
    ///         accessible via IPFS or similar.
    function setMetadata(uint256[] calldata wizardIds, bytes32[] calldata metadata) external;

    /// @notice Returns true if the given "spender" address is allowed to manipulate the given token
    ///         (either because it is the owner of that token, has been given approval to manage that token)
    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

    /// @notice Verifies that a given signature represents authority to control the given Wizard ID,
    ///         reverting otherwise. It handles three cases:
    ///             - The simplest case: The signature was signed with the private key associated with
    ///               an external address that is the owner of this Wizard.
    ///             - The signature was generated with the private key associated with an external address
    ///               that is "approved" for working with this Wizard ID. (See the Wizard Guild and/or
    ///               the ERC-721 spec for more information on "approval".)
    ///             - The owner or approval address (as in cases one or two) is a smart contract
    ///               that conforms to ERC-1654, and accepts the given signature as being valid
    ///               using its own internal logic.
    ///
    ///        NOTE: This function DOES NOT accept a signature created by an address that was given "operator
    ///               status" (as granted by ERC-721's setApprovalForAll() functionality). Doing so is
    ///               considered an extreme edge case that can be worked around where necessary.
    /// @param wizardId The Wizard ID whose control is in question
    /// @param hash The message hash we are authenticating against
    /// @param sig the signature data; can be longer than 65 bytes for ERC-1654
    function verifySignature(uint256 wizardId, bytes32 hash, bytes calldata sig) external view;

    /// @notice Convenience function that verifies signatures for two wizards using equivalent logic to
    ///         verifySignature(). Included to save on cross-contract calls in the common case where we
    ///         are verifying the signatures of two Wizards who wish to enter into a Duel.
    /// @param wizardId1 The first Wizard ID whose control is in question
    /// @param wizardId2 The second Wizard ID whose control is in question
    /// @param hash1 The message hash we are authenticating against for the first Wizard
    /// @param hash2 The message hash we are authenticating against for the first Wizard
    /// @param sig1 the signature data corresponding to the first Wizard; can be longer than 65 bytes for ERC-1654
    /// @param sig2 the signature data corresponding to the second Wizard; can be longer than 65 bytes for ERC-1654
    function verifySignatures(
        uint256 wizardId1,
        uint256 wizardId2,
        bytes32 hash1,
        bytes32 hash2,
        bytes calldata sig1,
        bytes calldata sig2) external view;
}





// We use a contract and multiple inheritance to expose this constant.
// It's the best that Solidity offers at the moment.
contract DuelResolverInterfaceId {
    /// @notice The erc165 interface ID
    bytes4 internal constant _INTERFACE_ID_DUELRESOLVER = 0x41fc4f1e;
}

/// @notice An interface for contracts that resolve duels between Cheeze Wizards. Abstracting this out
///         into its own interface and instance allows for different tournaments to use
///         different duel mechanics while keeping the core tournament logic unchanged.
contract DuelResolverInterface is DuelResolverInterfaceId, ERC165Interface {
    /// @notice Indicates if the given move set is a valid input for this duel resolver.
    ///         It's important that this method is called before a move set is committed to
    ///         because resolveDuel() will abort if it the moves are invalid, making it
    ///         impossible to resolve the duel.
    function isValidMoveSet(bytes32 moveSet) public pure returns(bool);

    /// @notice Indicates that a particular affinity is a valid input for this duel resolver.
    ///         Should be called before a Wizard is entered into a tournament. As a rule, Wizard
    ///         Affinities don't change, so there's not point in checking for each duel.
    ///
    /// @dev    This method should _only_ return false for affinities that are
    ///         known to cause problems with your duel resolver. If your resolveDuel() function
    ///         can safely work with any affinity value (even if it just ignores the values that
    ///         it doesn't know about), it should return true.
    function isValidAffinity(uint256 affinity) external pure returns(bool);

    /// @notice Resolves the duel between two Cheeze Wizards given their chosen move sets, their
    ///         powers, and each Wizard's affinity. It is the responsibility of the Tournament contract
    ///         to ensure that ALL Wizards in a Tournament have an affinity value that is compatible with
    ///         the logic of this DuelResolver. It must also ensure that both move sets are valid before
    ///         those move sets are locked in, otherwise the duel can never be resolved!
    ///
    ///         Returns the amount of power to be transferred from the first Wizard to the second Wizard
    ///         (which will be a negative number if the second Wizard wins the duel), zero in the case of
    ///         a tie.
    /// @param moveSet1 The move set for the first Wizard. The interpretation and therefore valid
    ///                 values for this are determined by the individual duel resolver.
    /// @param moveSet2 The move set for the second Wizard.
    function resolveDuel(
        bytes32 moveSet1,
        bytes32 moveSet2,
        uint256 power1,
        uint256 power2,
        uint256 affinity1,
        uint256 affinity2)
        public pure returns(int256);
}





/// @title Contract that manages addresses and access modifiers for certain operations.
/// @author Dapper Labs Inc. (https://www.dapperlabs.com)
contract AccessControl {

    /// @dev The address of the master administrator account that has the power to
    ///      update itself and all of the other administrator addresses.
    ///      The CEO account is not expected to be used regularly, and is intended to
    ///      be stored offline (i.e. a hardware device kept in a safe).
    address public ceoAddress;

    /// @dev The address of the "day-to-day" operator of various privileged
    ///      functions inside the smart contract. Although the CEO has the power
    ///      to replace the COO, the CEO address doesn't actually have the power
    ///      to do "COO-only" operations. This is to discourage the regular use
    ///      of the CEO account.
    address public cooAddress;

    /// @dev The address that is allowed to move money around. Kept separate from
    ///      the COO because the COO address typically lives on an internet-connected
    ///      computer.
    address payable public cfoAddress;

    // Events to indicate when access control role addresses are updated.
    event CEOTransferred(address previousCeo, address newCeo);
    event COOTransferred(address previousCoo, address newCoo);
    event CFOTransferred(address previousCfo, address newCfo);

    /// @dev The AccessControl constructor sets the `ceoAddress` to the sender account. Also
    ///      initializes the COO and CFO to the passed values (CFO is optional and can be address(0)).
    /// @param newCooAddress The initial COO address to set
    /// @param newCfoAddress The initial CFO to set (optional)
    constructor(address newCooAddress, address payable newCfoAddress) public {
        _setCeo(msg.sender);
        setCoo(newCooAddress);

        if (newCfoAddress != address(0)) {
            setCfo(newCfoAddress);
        }
    }

    /// @notice Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress, "Only CEO");
        _;
    }

    /// @notice Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress, "Only COO");
        _;
    }

    /// @notice Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress, "Only CFO");
        _;
    }

    function checkControlAddress(address newController) internal view {
        require(newController != address(0) && newController != ceoAddress, "Invalid CEO address");
    }

    /// @notice Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param newCeo The address of the new CEO
    function setCeo(address newCeo) external onlyCEO {
        checkControlAddress(newCeo);
        _setCeo(newCeo);
    }

    /// @dev An internal utility function that updates the CEO variable and emits the
    ///      transfer event. Used from both the public setCeo function and the constructor.
    function _setCeo(address newCeo) private {
        emit CEOTransferred(ceoAddress, newCeo);
        ceoAddress = newCeo;
    }

    /// @notice Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param newCoo The address of the new COO
    function setCoo(address newCoo) public onlyCEO {
        checkControlAddress(newCoo);
        emit COOTransferred(cooAddress, newCoo);
        cooAddress = newCoo;
    }

    /// @notice Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param newCfo The address of the new CFO
    function setCfo(address payable newCfo) public onlyCEO {
        checkControlAddress(newCfo);
        emit CFOTransferred(cfoAddress, newCfo);
        cfoAddress = newCfo;
    }
}



/// @title TournamentTimeAbstract - abstract contract for controlling time for Cheeze Wizards.
/// @notice Time is important in Cheeze Wizards, and there are a variety of different ways of
/// slicing up time that we should clarify here at the outset:
///
///  1. The tournament is split into three major PHASES:
///      - The first Phase is the Admission Phase. During this time, Wizards can be entered into
///        the tournament with their admission fee, and will be given a power level commensurate
///        with that fee. Their power level can not exceed the base power level encoded into the NFT.
///        No duels take place during this phase.
///      - The second Phase is the Revival Phase. During this time, new Wizards can enter the tournament,
///        eliminated Wizards can be revived, and the dueling commences!
///      - The third phase is the Elimination Phase. It's all duels, all the time. No new Wizards can enter,
///        all eliminations are _final_. It's at this time that the Blue Mold begins to grow, forcing
///        Wizards to engage in battle or be summarily eliminated.
///      - Collectively the phases where Wizards can enter the tournament (i.e. Admission Phase and
///        Revival Phase) are the Enter Phases.
///      - Collectively the phases where Wizards can duel (i.e. Revival Phase and Elimination Phase)
///        are the Battle Phases.
///
///  2. During the Battle Phases, where Wizards can duel, we break time up into a series of repeating WINDOWS:
///      - The first Window is the Ascension Window. During the Elimination Phase, Ascension Windows are critically
///        important: Any Wizard which is in danger of being eliminated by the next Blue Mold power increase
///        can attempt to Ascend during this time. If multiple Wizards attempt to Ascend, they are paired
///        off into Duels to Exhaustion: A one-time, winner-takes-all battle that sees one Wizard triumphant
///        and the other Wizard eliminated from the tournament. If an odd number of Wizards attempt to Ascend,
///        the last Wizard to attempt to Ascend remains in the Ascension Chamber where they _must_ accept the
///        first duel challenge offered to them in the following Fight Window. During the Revival Phase, the time
///        slice which would be an Ascension Windows is counted as more or less nothing.
///      - The second Window is the Fight Window. This is where all the fun happens! Wizards challenge Wizards,
///        and their duels result in power transfers. But beware! If your power level drops to zero (or below
///        the Blue Mold level), you will be eliminated during the Elimination Phase!
///      - The third Window is the Resolution Window. This is a period of time after the Fight Window equal
///        to the maximum length of a duel. During the Resolution Window, the only action that most Wizards
///        can take is to reveal moves for duels initiated during the Fight Window. However, this is also the
///        time slice during which a successfully Ascending Wizard is able to power up!
///      - The fourth Window is the Culling Window. During the Elimination Phase, the Culling Window is used
///        to permanently remove all Wizards who have been reduced to zero power (are tired), or who have fallen below
///        the power level of the inexorable Blue Mold.
///
///      Note that since Wizards can't ascend or be culled during Revival Phase, the Ascension and Culling windows
///        during Revival Phase don't have any utility/meaning until the Revival Phase is over.
///
/// 3. A complete sequence of four Windows is called a SESSION. During the official Cheeze Wizard tournament,
///    we will set the Session length to as close to 8 hours as possible (while still using blocks as time
///    keeping mechanism), ensuring three Sessions per day. Other Tournaments may have very different time limits.
///
/// A Handy Diagram!
///        ...--|--asc.--|------fight------|--res--|-----cull------|--asc.--|------fight------|--res--|-----cull--...
///        .....|^^^^^^^^^^^^^^^^^^ 1 session ^^^^^^^^^^^^^^^^^^^^^|...
contract TournamentTimeAbstract is AccessControl {

    event Paused(uint256 pauseEndedBlock);

    /// @dev We pack these parameters into a struct to save storage costs.
    struct TournamentTimeParameters {
        // The block height at which the tournament begins. Starts in the Admission Phase.
        uint48 tournamentStartBlock;

        // The block height after which the pause will end.
        uint48 pauseEndedBlock;

        // The duration (in blocks) of the Admission Phase.
        uint32 admissionDuration;

        // The duration (in blocks) of the Revival Phase; the Elimination Phase has no time limit.
        uint32 revivalDuration;

        // The maximum duration (in blocks) between the second commit in a normal duel and when it times out.
        // Ascension Duels always time out at the end of the Resolution Phase following the Fight or Ascension
        // Window in which they were initiated.
        uint32 duelTimeoutDuration;
    }

    TournamentTimeParameters internal tournamentTimeParameters;

    // Returns all the time related variables that are stored internally.
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
        uint256 cullingWindowDuration) {
        return (
            uint256(tournamentTimeParameters.tournamentStartBlock),
            uint256(tournamentTimeParameters.pauseEndedBlock),
            uint256(tournamentTimeParameters.admissionDuration),
            uint256(tournamentTimeParameters.revivalDuration),
            uint256(tournamentTimeParameters.duelTimeoutDuration),
            uint256(ascensionWindowParameters.firstWindowStartBlock),
            uint256(ascensionWindowParameters.windowDuration),
            uint256(fightWindowParameters.firstWindowStartBlock),
            uint256(fightWindowParameters.windowDuration),
            uint256(resolutionWindowParameters.firstWindowStartBlock),
            uint256(resolutionWindowParameters.windowDuration),
            uint256(cullingWindowParameters.firstWindowStartBlock),
            uint256(cullingWindowParameters.windowDuration));
    }

    // This probably looks insane, but there is a method to our madness!
    //
    // Checking which window we are in is something that happens A LOT, especially during duels.
    // The naive way of checking this is gas intensive, as it either involves data stored in
    // multiple storage slots, or by performing a number of computations for each check. By caching all
    // of the data needed to compute if we're in a window in a single struct means that
    // we can do the check cost effectively using a single SLOAD. Unfortunately, different windows need different
    // data, so we end up storing A LOT of duplicate data. This is a classic example of
    // optimizing for one part of the code (fast checking if we're in a window) at the expense of another
    // part of the code (overall storage footprint and deployment gas cost). In
    // the common case this is a significant improvement in terms of gas usage, over the
    // course of an entire Tournament.

    // The data needed to check if we are in a given Window
    struct WindowParameters {
        // The block number that the first window of this type begins
        uint48 firstWindowStartBlock;

        // A copy of the pause ending block, copied into this storage slot to save gas
        uint48 pauseEndedBlock;

        // The length of an entire "session" (see above for definitions), ALL windows
        // repeat with a period of one session.
        uint32 sessionDuration;

        // The duration of this window
        uint32 windowDuration;
    }

    WindowParameters internal ascensionWindowParameters;
    WindowParameters internal fightWindowParameters;
    WindowParameters internal resolutionWindowParameters;
    WindowParameters internal cullingWindowParameters;


    // Another struct, with another copy of some of the same parameters as above. This time we are
    // collecting everything related to computing the power of the Blue Mold into one place.
    struct BlueMoldParameters {
        uint48 blueMoldStartBlock;
        uint32 sessionDuration;
        uint32 moldDoublingDuration;
        uint88 blueMoldBasePower;
    }

    BlueMoldParameters internal blueMoldParameters;

    function getBlueMoldParameters() external view returns (uint256, uint256, uint256, uint256) {
        return (
            blueMoldParameters.blueMoldStartBlock,
            blueMoldParameters.sessionDuration,
            blueMoldParameters.moldDoublingDuration,
            blueMoldParameters.blueMoldBasePower
        );
    }

    constructor(
        address _cooAddress,
        uint40 tournamentStartBlock,
        uint32 admissionDuration,
        uint32 revivalDuration,
        uint24 ascensionDuration,
        uint24 fightDuration,
        uint24 cullingDuration,
        uint24 duelTimeoutDuration,
        uint88 blueMoldBasePower,
        uint24 sessionsBetweenMoldDoubling
    )
    internal AccessControl(_cooAddress, address(0)) {
        require(tournamentStartBlock > block.number, "Invalid start time");

        // Even if you want to have a very fast Tournament, a timeout of fewer than 20 blocks
        // is asking for trouble. We would always recommend a value >100.
        require(duelTimeoutDuration >= 20, "Timeout too short");

        // Rather than checking all of these inputs against zero, we just multiply them all together and exploit
        // the fact that if any of them are zero, their product will also be zero.
        // Theoretically, you can find five non-zero numbers that multiply to zero because of overflow.
        // However, at least one of those numbers would need to be >50 bits long which is not the case here.
        // Note: BasicTournament.revive() depends on blueMoldBasePower always being
        // positive, so if this constraint somehow ever changes, that function
        // will need to be verified for correctness.
        // sessionsBetweenMoldDoubling must be > 0 so that the mold doubles!
        require(
            (uint256(admissionDuration) *
            uint256(revivalDuration) *
            uint256(ascensionDuration) *
            uint256(fightDuration) *
            uint256(cullingDuration) *
            uint256(blueMoldBasePower) *
            uint256(sessionsBetweenMoldDoubling)) != 0,
            "Constructor arguments must be non-0");

        // The Fight Window needs to be at least twice as long as the Duel Timeout. Necessary to
        // ensure there is enough time to challenge an Ascending Wizard.
        require(fightDuration >= uint256(duelTimeoutDuration) * 2, "Fight window too short");

        // Make sure the Culling Window is at least as big as a Fight Window
        require(cullingDuration >= duelTimeoutDuration, "Culling window too short");
        // The sum of 4 uint24 values is always less than uint32. So it won't overflow.
        uint32 sessionDuration = ascensionDuration + fightDuration + duelTimeoutDuration + cullingDuration;

        // Make sure that the end of the Revival Phase coincides with the start of a
        // new session. Many of our calculations depend on this fact!
        require((revivalDuration % sessionDuration) == 0, "Revival/Session length mismatch");

        tournamentTimeParameters = TournamentTimeParameters({
            tournamentStartBlock: uint48(tournamentStartBlock),
            pauseEndedBlock: uint48(0),
            admissionDuration: admissionDuration,
            revivalDuration: revivalDuration,
            duelTimeoutDuration: duelTimeoutDuration
        });

        // tournamentStartBlock is 40 bits, admissionDuration is 32 bits,
        // so firstSessionStartBlock is less than 41 bits, which protects the calculations
        // of the firstWindowStartBlock as below from overflow.
        uint256 firstSessionStartBlock = uint256(tournamentStartBlock) + uint256(admissionDuration);

        // NOTE: ascension windows don't begin until after the Revival Phase is over
        ascensionWindowParameters = WindowParameters({
            firstWindowStartBlock: uint48(firstSessionStartBlock + revivalDuration),
            pauseEndedBlock: uint48(0),
            sessionDuration: sessionDuration,
            windowDuration: ascensionDuration
        });

        fightWindowParameters = WindowParameters({
            firstWindowStartBlock: uint48(firstSessionStartBlock + ascensionDuration),
            pauseEndedBlock: uint48(0),
            sessionDuration: sessionDuration,
            windowDuration: fightDuration
        });

        resolutionWindowParameters = WindowParameters({
            firstWindowStartBlock: uint48(firstSessionStartBlock + ascensionDuration + fightDuration),
            pauseEndedBlock: uint48(0),
            sessionDuration: sessionDuration,
            windowDuration: duelTimeoutDuration
        });

        cullingWindowParameters = WindowParameters({
            // NOTE: The first Culling Window only occurs after the first Revival Phase is over.
            firstWindowStartBlock: uint48(firstSessionStartBlock + revivalDuration + ascensionDuration + fightDuration + duelTimeoutDuration),
            pauseEndedBlock: uint48(0),
            sessionDuration: sessionDuration,
            windowDuration: cullingDuration
        });

        blueMoldParameters = BlueMoldParameters({
            blueMoldStartBlock: uint48(firstSessionStartBlock + revivalDuration),
            sessionDuration: sessionDuration,
            // uint24 * uint25
            moldDoublingDuration: uint32(sessionsBetweenMoldDoubling) * uint32(sessionDuration),
            blueMoldBasePower: blueMoldBasePower
        });
    }

    /// @notice Returns true if the current block is in the Revival Phase
    function _isRevivalPhase() internal view returns (bool) {
        // Copying the structure into memory once saves gas. Each access to a member variable
        // counts as a new read!
        TournamentTimeParameters memory localParams = tournamentTimeParameters;

        if (block.number < localParams.pauseEndedBlock) {
            return false;
        }

        return ((block.number >= localParams.tournamentStartBlock + localParams.admissionDuration) &&
            (block.number < localParams.tournamentStartBlock + localParams.admissionDuration + localParams.revivalDuration));
    }

    /// @notice Returns true if the current block is in the Elimination Phase
    function _isEliminationPhase() internal view returns (bool) {
        // Copying the structure into memory once saves gas. Each access to a member variable
        // counts as a new read!
        TournamentTimeParameters memory localParams = tournamentTimeParameters;

        if (block.number < localParams.pauseEndedBlock) {
            return false;
        }

        return (block.number >= localParams.tournamentStartBlock + localParams.admissionDuration + localParams.revivalDuration);
    }

    /// @dev Returns true if the current block is a valid time to enter a Wizard into the Tournament. As in,
    ///      it's either the Admission Phase or the Revival Phase.
    function _isEnterPhase() internal view returns (bool) {
        // Copying the structure into memory once saves gas. Each access to a member variable
        // counts as a new read!
        TournamentTimeParameters memory localParams = tournamentTimeParameters;

        if (block.number < localParams.pauseEndedBlock) {
            return false;
        }

        return ((block.number >= localParams.tournamentStartBlock) &&
            (block.number < localParams.tournamentStartBlock + localParams.admissionDuration + localParams.revivalDuration));
    }

    // An internal convenience function that checks to see if we are currently in the Window
    // defined by the WindowParameters struct passed as an argument.
    function _isInWindow(WindowParameters memory localParams) internal view returns (bool) {
        // We are never "in a window" if the contract is paused
        if (block.number < localParams.pauseEndedBlock) {
            return false;
        }

        // If we are before the first window of this type, we are obviously NOT in this window!
        if (block.number < localParams.firstWindowStartBlock) {
            return false;
        }

        // Use modulus to figure out how far we are past the beginning of the most recent window
        // of this type
        uint256 windowOffset = (block.number - localParams.firstWindowStartBlock) % localParams.sessionDuration;

        // If we are in the window, we will be within duration of the start of the most recent window
        return windowOffset < localParams.windowDuration;
    }

    /// @notice Requires the current block is in an Ascension Window
    function checkAscensionWindow() internal view {
        require(_isInWindow(ascensionWindowParameters), "Only during Ascension Window");
    }

    /// @notice Requires the current block is in a Fight Window
    function checkFightWindow() internal view {
        require(_isInWindow(fightWindowParameters), "Only during Fight Window");
    }

    /// @notice Requires the current block is in a Resolution Window
    function checkResolutionWindow() internal view {
        require(_isInWindow(resolutionWindowParameters), "Only during Resolution Window");
    }

    /// @notice Requires the current block is in a Culling Window
    function checkCullingWindow() internal view {
        require(_isInWindow(cullingWindowParameters), "Only during Culling Window");
    }

    /// @notice Returns the block number when an Ascension Battle initiated in the current block
    ///         should time out. This is always the end of the upcoming Resolution Window.
    ///
    ///         NOTE: This function is only designed to be called during an Ascension or
    ///               Fight Window, after we have entered the Elimination Phase.
    ///               Behaviour at other times is not defined.
    function _ascensionDuelTimeout() internal view returns (uint256) {
        WindowParameters memory localParams = cullingWindowParameters;

        // The end of the next Resolution Window is the same as the start of the next
        // Culling Window.

        // First we count the number of COMPLETE sessions that will have passed between
        // the start of the first Culling Window and the block one full session duration
        // past the current block height. We are looking into the future to ensure that
        // we with any negative values.
        uint256 sessionCount = (block.number + localParams.sessionDuration -
            localParams.firstWindowStartBlock) / localParams.sessionDuration;

        return localParams.firstWindowStartBlock + sessionCount * localParams.sessionDuration;
    }

    /// @notice Returns true if there is at least one full duel timeout duration between
    ///         now and the end of the current Fight Window. To be used to ensure that
    ///         someone challenging an Ascending Wizard is given the Ascending Wizard
    ///         enough time to respond.
    ///
    ///         NOTE: This function is only designed to be called during a Fight Window,
    ///               after we have entered the Elimination Phase.
    ///               Behaviour at other times is not defined.
    function canChallengeAscendingWizard() internal view returns (bool) {
        // We start by computing the start on the next Resolution Window, using the same
        // logic as in _ascensionDuelTimeout().
        WindowParameters memory localParams = resolutionWindowParameters;

        uint256 sessionCount = (block.number + localParams.sessionDuration -
            localParams.firstWindowStartBlock) / localParams.sessionDuration;

        uint256 resolutionWindowStart = localParams.firstWindowStartBlock + sessionCount * localParams.sessionDuration;

        // Remember that the Resolution Window has the same duration as the duel time out
        return resolutionWindowStart - localParams.windowDuration > block.number;
    }

    /// @notice Returns the power level of the Blue Mold at the current block.
    function _blueMoldPower() internal view returns (uint256) {
        BlueMoldParameters memory localParams = blueMoldParameters;

        if (block.number <= localParams.blueMoldStartBlock) {
            return localParams.blueMoldBasePower;
        } else {
            uint256 moldDoublings = (block.number - localParams.blueMoldStartBlock) / localParams.moldDoublingDuration;

            // In the initialization function, we cap the maximum Blue Mold base power to a value under 1 << 88
            // (which is the maximum Wizard power level, and would result in all Wizards INSTANTLY being moldy!)
            // Here, we cap the number of "mold doublings" to 88. This ensures that the mold power
            // can't overflow, while also ensuring that, even if blueMoldBasePower starts at 1
            // that it will exceed the max power of any Wizard. This guarantees that the tournament
            // will ALWAYS terminate.
            if (moldDoublings > 88) {
                moldDoublings = 88;
            }

            return localParams.blueMoldBasePower << moldDoublings;
        }
    }


    modifier duringEnterPhase() {
        require(_isEnterPhase(), "Only during Enter Phases");
        _;
    }

    modifier duringRevivalPhase() {
        require(_isRevivalPhase(), "Only during Revival Phases");
        _;
    }

    modifier duringAscensionWindow() {
        checkAscensionWindow();
        _;
    }

    modifier duringFightWindow() {
        checkFightWindow();
        _;
    }

    modifier duringResolutionWindow() {
        checkResolutionWindow();
        _;
    }

    modifier duringCullingWindow() {
        checkCullingWindow();
        _;
    }

    /// @notice Pauses the Tournament, starting immediately, for a duration specified in blocks.
    /// This function can be called if the Tournament is already paused, but only to extend the pause
    /// period until at most `(block.number + sessionDuration)`. In other words, the Tournament can't be
    /// paused indefinitely unless this function is called periodically, at least once every session length.
    ///
    /// NOTE: This function is reasonably expensive and inefficient because it has to update so many storage
    ///       variables. This is done intentionally because pausing should be rare and it's far more important
    ///       to optimize the hot paths (which are the modifiers above).
    ///
    /// @param pauseDuration the number of blocks to pause for. CAN NOT exceed the length of one Session.
    function pause(uint256 pauseDuration) external onlyCOO {
        uint256 sessionDuration = ascensionWindowParameters.sessionDuration;

        // Require all pauses be less than one session in length
        require(pauseDuration <= sessionDuration, "Invalid pause duration");

        // Figure out when our pause will be done
        uint48 newPauseEndedBlock = uint48(block.number + pauseDuration);
        uint48 tournamentExtensionAmount = uint48(pauseDuration);

        if (block.number < tournamentTimeParameters.pauseEndedBlock) {
            // If we are already paused, we need to adjust the tournamentExtension
            // amount to reflect that we are only extending the pause amount, not
            // setting it anew
            require(tournamentTimeParameters.pauseEndedBlock < newPauseEndedBlock);

            tournamentExtensionAmount = uint48(newPauseEndedBlock - tournamentTimeParameters.pauseEndedBlock);
        }

        // We now need to update all of the various structures where we cached time information
        // to make sure they reflect the new information
        tournamentTimeParameters.tournamentStartBlock += tournamentExtensionAmount;
        tournamentTimeParameters.pauseEndedBlock = newPauseEndedBlock;

        ascensionWindowParameters.firstWindowStartBlock += tournamentExtensionAmount;
        ascensionWindowParameters.pauseEndedBlock = newPauseEndedBlock;

        fightWindowParameters.firstWindowStartBlock += tournamentExtensionAmount;
        fightWindowParameters.pauseEndedBlock = newPauseEndedBlock;

        resolutionWindowParameters.firstWindowStartBlock += tournamentExtensionAmount;
        resolutionWindowParameters.pauseEndedBlock = newPauseEndedBlock;

        cullingWindowParameters.firstWindowStartBlock += tournamentExtensionAmount;
        cullingWindowParameters.pauseEndedBlock = newPauseEndedBlock;

        blueMoldParameters.blueMoldStartBlock += tournamentExtensionAmount;

        emit Paused(newPauseEndedBlock);
    }

    function isPaused() external view returns (bool) {
        return block.number < tournamentTimeParameters.pauseEndedBlock;
    }
}





// This is kind of a hacky way to expose this constant, but it's the best that Solidity offers!
contract TournamentInterfaceId {
    bytes4 internal constant _INTERFACE_ID_TOURNAMENT = 0xbd059098;
}

/// @title Tournament interface, known to GateKeeper
contract TournamentInterface is TournamentInterfaceId, ERC165Interface {

    // function enter(uint256 tokenId, uint96 power, uint8 affinity) external payable;
    function revive(uint256 wizardId) external payable;

    function enterWizards(uint256[] calldata wizardIds, uint88[] calldata powers) external payable;

    // Returns true if the Tournament is currently running and active.
    function isActive() external view returns (bool);

    function powerScale() external view returns (uint256);

    function destroy() external;
}



/// @title A basic Cheeze Wizards Tournament
/// @notice This contract mediates a Tournament between any number of Cheeze Wizards with
///         the following features:
///               - All Wizards who enter the Tournament are required to provide a contribution
///                 to the Big Cheeze prize pool that is directly proportional to their power
///                 level. There is no way for some Wizards to have a power level that is disproportionate
///                 to their pot contribution amount; not even for the Tournament creators.
///               - All Tournaments created with this contract follow the time constraints set out in the
///                 TournamentTimeAbstract contract. While different Tournament instances might run more
///                 quickly or more slowly than others, the basic cadence of the Tournament is consistent
///                 across all instances.
///               - The Tournament contract is designed such that, once the contract is set up, that
///                 all participants can trustlessly enjoy the Tournament without fear of being ripped
///                 off by the organizers. Some care needs to be taken _before_ you enter your Wizard
///                 in the Tournament (including ensuring that you are actually entering into a copy
///                 of this Tournament contract that hasn't been modified!), but once your Wizard has
///                 been entered, you can have confidence that the rules of the contest will be followed
///                 correctly, without fear of manipulation or fraud on the part of the contest creators.
contract BasicTournament is TournamentInterface, TournamentTimeAbstract, WizardConstants,
    DuelResolverInterfaceId {

    // A Duel officially starts (both commits are locked in on-chain)
    event DuelStart(
        bytes32 duelId,
        uint256 wizardId1,
        uint256 wizardId2,
        uint256 timeoutBlock,
        bool isAscensionBattle,
        bytes32 commit1,
        bytes32 commit2
    );

    // A Duel resolves normally, powers are post-resolution values
    event DuelEnd(
        bytes32 duelId,
        uint256 wizardId1,
        uint256 wizardId2,
        bytes32 moveSet1,
        bytes32 moveSet2,
        uint256 power1,
        uint256 power2
    );

    // A Wizard challenges its opponent with the commitment of its moves.
    event OneSidedCommitAdded(
        uint256 committingWizardId,
        uint256 otherWizardId,
        uint256 committingWizardNonce,
        uint256 otherWizardNonce,
        bytes32 commitment
    );

    // A Wizard cancelled the commitment against its opponent.
    event OneSidedCommitCancelled(
        uint256 wizardId
    );

    // A Wizard revealed its own moves for a Duel.
    event OneSidedRevealAdded(
        bytes32 duelId,
        uint256 committingWizardId,
        uint256 otherWizardId
    );

    // A Duel times out, powers are post-resolution values
    event DuelTimeOut(bytes32 duelId, uint256 wizardId1, uint256 wizardId2, uint256 power1, uint256 power2);

    // A Wizard has been formally eliminated. Note that Elimination can only happen in the Elimination phase, and
    // is NOT necessarily associated with a Wizard going to power zero.
    event WizardElimination(uint256 wizardId);

    // A Wizard in the "danger zone" has opted to try to Ascend
    event AscensionStart(uint256 wizardId);

    // A Wizard tried to Ascend when someone was in the Ascension Chamber; locked into a fight with each other.
    event AscensionPairUp(uint256 wizardId1, uint256 wizardId2);

    // A Wizard in the Ascension Chamber wasn't challenged during the Fight Window, their power triples!
    event AscensionComplete(uint256 wizardId, uint256 power);

    // A Wizard is challenging the ascending Wizard with the commitment of its moves.
    event AscensionChallenged(uint256 ascendingWizardId, uint256 challengingWizardId, bytes32 commitment);

    // A Wizard has been revived; power is the revival amount chosen (above Blue Mold level, below maxPower)
    event Revive(uint256 wizId, uint256 power);

    uint8 internal constant REASON_COMPLETE_ASCENSION = 1;
    uint8 internal constant REASON_RESOLVE_ONE_SIDED_ASCENSION_BATTLE = 2;
    uint8 internal constant REASON_GIFT_POWER = 3;
    // One Wizard sent all of its power to another. "sendingWizId" has zero power after this
    // reason is a enum type to distinguish between the different reasons that caused the power transfer.
    //   1: The power transfer was caused by the completeAscension function.
    //        An ascending wizard did not respond to a challenge, and loses all its power to the challenging wizard
    //   2: The power transfer was caused by the resolveOneSidedAscensionBattle function.
    //        A wizard in an ascension pair up did not commit moves during the fight window,
    //        and the other wizard who did commit moves will take all of the non-committing wizard’s power
    //   3: The power transfer was caused by the giftPower function.
    //        The controller of a wizard elected to call a function that donates all of their wizard’s power
    //        to another wizard of their choosing
    event PowerTransferred(uint256 sendingWizId, uint256 receivingWizId, uint256 amountTransferred, uint8 reason);

    // The winner (or one of the winners) has claimed their portion of the prize.
    event PrizeClaimed(uint256 claimingWinnerId, uint256 prizeAmount);

    // Used to prefix signed data blobs to prevent from signing a transaction
    byte internal constant EIP191_PREFIX = byte(0x19);
    byte internal constant EIP191_VERSION_DATA = byte(0);

    /// @dev The ratio between the cost of a Wizard (in wei) and the power of the wizard.
    ///      power = cost / powerScale
    ///      cost = power * powerScale
    /// @dev Note the "cost" here is the cost for the GateKeeper to mint a wizard in Tournament, not the
    ///      cost for a user to acquire a certain power of wizard.
    ///      GateKeeper has a hardcoded MAX_POWER_SCALE, which is 1000, so Tournament's powerScale is usually
    ///      lower than MAX_POWER_SCALE in order for the GateKeeper to be profitable. Also see the comments on the
    ///      powerScale_ argument in Tournament's constructor function.
    uint256 public powerScale;

    /// @dev The maximum power level attainable by a Wizard
    uint88 internal constant MAX_POWER = uint88(-1);

    // Address of the GateKeeper, likely to be a smart contract, but we don't care if it is
    // TODO: Update this address once the Gate Keeper is deployed.
    address public constant GATE_KEEPER = address(0x68132EB4BfD84b2D6A23ec4fB1B106F5C8574F2D);

    // The Wizard Guild contract. This is a variable so subclasses can modify it for
    // testing, but by default it cannot change from this default.
    // TODO: Update this address once the Wizard Guild is deployed.
    WizardGuildInterface public constant WIZARD_GUILD = WizardGuildInterface(address(0x0d8c864DA1985525e0af0acBEEF6562881827bd5));

    // The Duel Resolver contract
    DuelResolverInterface public duelResolver;

    /// @notice Power and other data while the Wizard is participating in the Tournament
    /// @dev fits into two words
    struct BattleWizard {
        /// @notice the wizards current power
        uint88 power;

        /// @notice the highest power a Wizard ever reached during a tournament
        uint88 maxPower;

        /// @notice a nonce value incremented when the Wizard's power level changes
        uint32 nonce;

        /// @notice a cached copy of the affinity of the Wizard - how handy!
        uint8 affinity;

        /// @notice The "id" of the Duel the Wizard is currently engaged in (which is actually
        ///         the hash of the duel's parameters, see _beginDuel().)
        bytes32 currentDuel;
    }

    mapping(uint256 => BattleWizard) internal wizards;

    /// @notice The total number of Wizards in this tournament. Goes up as new Wizards are entered
    ///         (during the Enter Phases), and goes down as Wizards get eliminated. We know we can
    ///         look for winners once this gets down to 5 or less!
    uint256 internal remainingWizards;

    function getRemainingWizards() external view returns(uint256) {
        return remainingWizards;
    }

    /// @notice A structure used to keep track of one-sided commitments that have been made on chain.
    ///         We anticipate most duels will make use of the doubleCommitment mechanism (because it
    ///         uses less gas), but that requires a trusted intermediary, so we provide one-sided commitments
    ///         for fully trustless interactions.
    struct SingleCommitment {
        uint256 opponentId;
        bytes32 commitmentHash;
    }

    // Key is Wizard ID, value is their selected opponent and their commitment hash
    mapping(uint256 => SingleCommitment) internal pendingCommitments;

    /// @notice A mapping that keeps track of one-sided reveals that have been made on chain. Like one-sided
    ///         commits, we expect one-sided reveals to be rare. But not quite as rare! If a player takes too
    ///         long to submit their reveal, their opponent will want to do a one-sided reveal to win the duel!
    ///         First key is Duel ID, second key is Wizard ID, value is the revealed moveset. (This structure
    ///         might seem odd if you aren't familiar with how Solidity handles storage-based mappings. If you
    ///         are confused, it's worth looking into; it's non-obvious, but quite efficient and clever!)
    mapping(bytes32 => mapping(uint256 => bytes32)) internal revealedMoves;

    // There can be at most 1 ascending Wizard at a time, who's ID is stored in this variable. If a second
    // Wizard tries to ascend when someone is already in the chamber, we make 'em fight!
    uint256 internal ascendingWizardId;

    function getAscendingWizardId() external view returns (uint256) {
        return ascendingWizardId;
    }

    // If there is a Wizard in the growth chamber when a second Wizard attempts to ascend, those two
    // Wizards are paired off into an Ascension Battle. This dictionary keeps track of the IDs of these
    // paired off Wizards. Wizard 1's ID maps to Wizard 2, and vice versa. (This means that each Ascension
    // Battle requires the storage of two words, which is kinda lame... ¯\_(ツ)_/¯ )
    mapping(uint256 => uint256) internal ascensionOpponents;

    // If there are an odd number of Wizards that attempt to ascend, one of them will be left in the
    // Ascension Chamber when the Fighting Window starts. ANY Wizard can challenge them, and they MUST
    // accept! This structure stores the commitment from the first challenger (if there is one).
    //
    // NOTE: The fields in this version of the structure are used subtly different than in the pending
    // commitments mapping. In pendingCommitments, the opponentId is the ID of the person you want to fight
    // and the commitmentHash is the commitment of YOUR moves. In the ascensionCommitment variable, the
    // opponentId is the Wizard that has challenged the ascending Wizard, and the commitmentHash is their
    // own moves. It makes sense in context, but it is technically a semantic switch worth being explicit about.
    SingleCommitment internal ascensionCommitment;

    struct Duel {
        uint128 timeout;
        bool isAscensionBattle;
    }

    /// @notice All of the currently active Duels, keyed by Duel ID
    mapping(bytes32 => Duel) internal duels;

    constructor(
        address cooAddress_,
        address duelResolver_,
        // Note the InauguralGateKeeper defines the MAX_POWER_SCALE to be 1000. And the power scale here is supposed to be
        // less than MAX_POWER_SCALE in order for the GateKeeper to be profitable.
        // For example, If the Tournament uses 500 as the powerScale_, then 50% of the ether sent with the conjureWizard call will
        // go to the GateKeeper and the other 50% will be forwarded to the Tournament.
        // That means, with 500 as the powerScale_ of the Tournament, if a user calls GateKeeper's conjureWizard with 1 ether,
        // then 0.5 ether will be forwarded to the Tournament contract as the pot prize to mint a wizard with 1000 power,
        // and 0.5 ether will be retained in the GateKeeper contract as its earning.
        // So using 1000 as the powerScale_ of the Tournament would make the GateKeeper unprofitable.
        uint256 powerScale_,
        uint40 tournamentStartBlock_,
        uint32 admissionDuration_,
        uint32 revivalDuration_,
        uint24 ascensionDuration_,
        uint24 fightDuration_,
        uint24 cullingDuration_,
        uint88 blueMoldBasePower_,
        uint24 sessionsBetweenMoldDoubling_,
        uint24 duelTimeoutBlocks_
    )
        public
        TournamentTimeAbstract(
            cooAddress_,
            tournamentStartBlock_,
            admissionDuration_,
            revivalDuration_,
            ascensionDuration_,
            fightDuration_,
            cullingDuration_,
            duelTimeoutBlocks_,
            blueMoldBasePower_,
            sessionsBetweenMoldDoubling_
        )
    {
        duelResolver = DuelResolverInterface(duelResolver_);
        require(
            duelResolver_ != address(0) &&
            duelResolver.supportsInterface(_INTERFACE_ID_DUELRESOLVER));

        powerScale = powerScale_;
    }

    /// @notice We allow this contract to accept any payments. All Eth sent in this way
    ///         automatically becomes part of the prize pool. This is useful in cases
    ///         where the Tournament organizers want to "seed the pot" with more funds
    ///         than are contributed by the players.
    function() external payable {}

    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///      uses less than 30,000 gas.
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return
            interfaceId == this.supportsInterface.selector || // ERC165
            interfaceId == _INTERFACE_ID_TOURNAMENT; // Tournament
    }

    /// @notice Returns true if the Tournament is currently active.
    ///
    ///         NOTE: This will return false (not active) either before the Tournament
    ///               begins (before any Wizards enter), or after it is over (after all
    ///               Wizards have been eliminated.) It also considers a Tournament inactive
    ///               if 200 * blueWallDoubling blocks have passed. (After 100 doublings
    ///               ALL of the Wizards will have succumbed to the Blue Wall, and another
    ///               100 doublings should be enough time for the winners to withdraw their
    ///               winnings. Anything left after that is fair game for the GateKeeper to take.)
    function isActive() public view returns (bool) {
        uint256 maximumTournamentLength = blueMoldParameters.moldDoublingDuration * 200;

        if (block.number > blueMoldParameters.blueMoldStartBlock + maximumTournamentLength) {
            return false;
        } else {
            return remainingWizards != 0;
        }
    }


    // NOTE: This might seem a like a slightly odd pattern. Typical smart contract code
    //       (including other smart contracts that are part of Cheeze Wizards) would
    //       just include the require() statement in the modifier itself instead of
    //       creating an additional function.
    //
    //       Unfortunately, this contract is very close to the maximum size limit
    //       for Ethereum (which is 24576 bytes, as per EIP-170). Modifiers work by
    //       more-or-less copy-and-pasting the code in them into the functions they
    //       decorate. It turns out that copying these modifiers (especially the
    //       contents of checkController() into every function that uses them adds
    //       up to a very large amount of space. By defining the modifier to be
    //       no more than a function call, we can save several KBs of contract size
    //       at a very small gas cost (an internal branch is just 10 gas)).

    function checkGateKeeper() internal view {
        require(msg.sender == GATE_KEEPER, "Only GateKeeper can call");
    }


    // Modifier for functions only exposed to the GateKeeper
    modifier onlyGateKeeper() {
        checkGateKeeper();
        _;
    }

    function checkExists(uint256 wizardId) internal view {
        require(wizards[wizardId].maxPower != 0, "Wizard does not exist");
    }

    // Modifier to ensure a specific Wizard is currently entered into the Tournament
    modifier exists(uint256 wizardId) {
        checkExists(wizardId);
        _;
    }

    function checkController(uint256 wizardId) internal view {
        require(wizards[wizardId].maxPower != 0, "Wizard does not exist");
        require(WIZARD_GUILD.isApprovedOrOwner(msg.sender, wizardId), "Must be Wizard controller");
    }

    // Modifier for functions that only the owner (or an approved operator) should be able to call
    // Also checks that the Wizard exists!
    modifier onlyWizardController(uint256 wizardId) {
        checkController(wizardId);
        _;
    }

    /// @notice A function to get the current state of the Wizard, includes the computed properties:
    ///         ascending (is this Wizard in the ascension chamber), ascensionOpponent (the ID of
    ///         an ascensionChallenger, if any) molded (this Wizard's power below the Blue Mold power
    ///         level), and ready (see the isReady() method for definition). You can tell if a Wizard
    ///         is in a battle by checking "currentDuel" against 0.
    function getWizard(uint256 wizardId) public view exists(wizardId) returns(
        uint256 affinity,
        uint256 power,
        uint256 maxPower,
        uint256 nonce,
        bytes32 currentDuel,
        bool ascending,
        uint256 ascensionOpponent,
        bool molded,
        bool ready
    ) {
        BattleWizard memory wizard = wizards[wizardId];

        affinity = wizard.affinity;
        power = wizard.power;
        maxPower = wizard.maxPower;
        nonce = wizard.nonce;
        currentDuel = wizard.currentDuel;

        ascending = ascendingWizardId == wizardId;
        ascensionOpponent = ascensionOpponents[wizardId];
        molded = _blueMoldPower() > wizard.power;
        ready = _isReady(wizardId, wizard);
    }

    /// @notice A finger printing function to capture the important state data about a Wizard into
    ///         a secure hash. This is especially useful during sales and trading to be sure that the Wizard's
    ///         state hasn't changed materially between the time the trade/purchase decision was made and
    ///         when the actual transfer is executed on-chain.
    function wizardFingerprint(uint256 wizardId) external view returns (bytes32) {
        (uint256 affinity,
        uint256 power,
        uint256 maxPower,
        uint256 nonce,
        bytes32 currentDuel,
        bool ascending,
        uint256 ascensionOpponent,
        bool molded,
        ) = getWizard(wizardId);

        uint256 pendingOpponent = pendingCommitments[wizardId].opponentId;

        // Includes all Wizard state (including computed properties) plus the Wizard ID
        // TODO: remove all pending commitment code
        return keccak256(
            abi.encodePacked(
                wizardId,
                affinity,
                power,
                maxPower,
                nonce,
                currentDuel,
                ascending,
                ascensionOpponent,
                molded,
                pendingOpponent
            ));
    }

    /// @notice Returns true if a Wizard is "ready", meaning it can participate in a battle, ascension, or power
    ///         transfer. A "ready" Wizard is not ascending, not battling, not moldy, hasn't committed to an ascension
    ///         battle, and has a valid affinity.
    function isReady(uint256 wizardId) public view exists(wizardId) returns (bool) {
        BattleWizard memory wizard = wizards[wizardId];

        return _isReady(wizardId, wizard);
    }

    /// @notice An internal version of the isReady function that leverages a BattleWizard struct
    ///         that is already in memory
    function _isReady(uint256 wizardId, BattleWizard memory wizard) internal view returns (bool) {
        // IMPORTANT NOTE: oneSidedCommit() needs to recreate 90% of this logic, because it needs to check to
        //     see if a Wizard is ready, but it allows the Wizard to have an ascension opponent. If you make any
        //     changes to this function, you should double check that the same edit doesn't need to be made
        //     to oneSidedCommit().
        return ((wizardId != ascendingWizardId) &&
            (ascensionOpponents[wizardId] == 0) &&
            (ascensionCommitment.opponentId != wizardId) &&
            (_blueMoldPower() <= wizard.power) &&
            (wizard.affinity != ELEMENT_NOTSET) &&
            (wizard.currentDuel == 0));
    }

    /// @notice The function called by the GateKeeper to enter wizards into the tournament. Only the GateKeeper can
    ///         call this function, meaning that the GateKeeper gets to decide who can enter. However! The Tournament
    ///         enforces that ALL Wizards that are entered into the Tournament have paid the same pro-rata share of
    ///         the prize pool as matches their starting power. Additionally, the starting power for each Wizard
    ///         in the Tournament can't exceed the innate power of the Wizard when it was created. This is done to
    ///         ensure the Tournament is possible.
    /// @param wizardIds The IDs of the Wizards to enter into the Tournament, can be length 1.
    /// @param powers The list of powers for each of the Wizards (one-to-one mapping by index).
    function enterWizards(uint256[] calldata wizardIds, uint88[] calldata powers) external payable duringEnterPhase onlyGateKeeper {
        require(wizardIds.length == powers.length, "Mismatched parameter lengths");

        uint256 totalCost = 0;

        for (uint256 i = 0; i < wizardIds.length; i++) {
            uint256 wizardId = wizardIds[i];
            uint88 power = powers[i];

            require(wizards[wizardId].maxPower == 0, "Wizard already in tournament");

            (, uint88 innatePower, uint8 affinity, ) = WIZARD_GUILD.getWizard(wizardId);

            require(power > 0 && power <= innatePower, "Invalid power");

            wizards[wizardId] = BattleWizard({
                power: power,
                maxPower: power,
                nonce: 0,
                affinity: affinity,
                currentDuel: 0
            });

            totalCost += power * powerScale;
        }

        remainingWizards += wizardIds.length;

        require(msg.value >= totalCost, "Insufficient funds");
    }

    /// @dev Brings a tired Wizard back to fightin' strength. Can only be used during the revival
    ///      phase. The buy-back can be to any power level between the Blue Wall power (at the low end)
    ///      and the previous max power achieved by this Wizard in this tournament. This does mean a revival
    ///      can bring a Wizard back above their innate power! The contribution into the pot MUST be equivalent
    ///      to the cost that would be needed to bring in a new Wizard at the same power level. Can only
    ///      be called by the GateKeeper to allow the GateKeeper to manage the pot contribution rate and
    ///      potentially apply other rules or requirements to revival.
    function revive(uint256 wizardId) external payable exists(wizardId) duringRevivalPhase onlyGateKeeper {
        BattleWizard storage wizard = wizards[wizardId];

        uint88 maxPower = wizard.maxPower;
        uint88 revivalPower = uint88(msg.value / powerScale);

        require((revivalPower > _blueMoldPower()) && (revivalPower <= maxPower), "Invalid power level");
        require(wizard.power == 0, "Can only revive tired Wizards");

        // There is no scenario in which a Wizard can be "not ready" and have a zero power.
        // require(isReady(wizardId), "Can't revive a busy Wizard");

        wizard.power = revivalPower;
        wizard.nonce += 1;

        emit Revive(wizardId, revivalPower);
    }

    /// @notice Updates the cached value of a Wizard's affinity with the value from the Wizard Guild.
    ///         Only useful for Exclusive Wizards that initially have no elemental affinity, and which
    ///         is then selected by the owner. When the Wizard enters the Tournament it might not have
    ///         it's affinity set yet, and this will copy the affinity from the Guild contract if it's
    ///         been updated. Can be called by anyone since it can't be abused.
    /// @param wizardId The id of the Wizard to update
    function updateAffinity(uint256 wizardId) external exists(wizardId) {
        (, , uint8 newAffinity, ) = WIZARD_GUILD.getWizard(wizardId);
        BattleWizard storage wizard = wizards[wizardId];
        require(wizard.affinity == ELEMENT_NOTSET, "Affinity already updated");
        wizard.affinity = newAffinity;
    }

    function startAscension(uint256 wizardId) external duringAscensionWindow onlyWizardController(wizardId) {
        BattleWizard memory wizard = wizards[wizardId];

        require(_isReady(wizardId, wizard), "Can't ascend a busy wizard!");

        require(wizard.power < _blueMoldPower() * 2, "Not eligible for ascension");

        if (ascendingWizardId != 0) {
            // there is already a Wizard ascending! Pair up the incoming Wizard with the
            // Wizard in the Ascension Chamber and make them fight it out!
            ascensionOpponents[ascendingWizardId] = wizardId;
            ascensionOpponents[wizardId] = ascendingWizardId;

            emit AscensionPairUp(ascendingWizardId, wizardId);

            // Empty out the Ascension Chamber for the next Ascension
            ascendingWizardId = 0;
        } else {
            // the chamber is empty, get in!
            ascendingWizardId = wizardId;

            emit AscensionStart(wizardId);
        }
    }

    function _checkChallenge(uint256 challengerId, uint256 recipientId) internal view {
        require(pendingCommitments[challengerId].opponentId == 0, "Pending battle already exists");
        require(recipientId > 0, "No Wizard is ascending");
        require(challengerId != recipientId, "Cannot duel oneself!");
    }

    /// @notice Any live Wizard can challenge an ascending Wizard during the fight phase. They must
    ///         provide a commitment of their moves (which is totally reasonable, since they know
    ///         exactly who they will be fighting!)
    function challengeAscending(uint256 wizardId, bytes32 commitment) external duringFightWindow onlyWizardController(wizardId) {
        require(ascensionCommitment.opponentId == 0, "Wizard already challenged");

        _checkChallenge(wizardId, ascendingWizardId);

        // Ascension Battles MUST come well before the end of the fight window to give the
        // ascending Wizard a chance to respond with their own commitment.
        require(canChallengeAscendingWizard(), "Challenge too late");

        BattleWizard memory wizard = wizards[wizardId];

        require(_isReady(wizardId, wizard), "Wizard not ready");
        // We don't need to call isReady() on the ascendingWizard: It's definitionally ready for a challenge!

        // Store a pending commitment that the ascending Wizard can accept
        ascensionCommitment = SingleCommitment({opponentId: wizardId, commitmentHash: commitment});
        emit AscensionChallenged(ascendingWizardId, wizardId, commitment);
    }

    /// @notice Allows the Ascending Wizard to respond to an ascension commitment with their own move commitment,
    //          thereby starting an Ascension Battle.
    function acceptAscensionChallenge(bytes32 commitment) external duringFightWindow onlyWizardController(ascendingWizardId) {
        uint256 challengerId = ascensionCommitment.opponentId;
        require(challengerId != 0, "No challenge to accept");

        if (challengerId < ascendingWizardId) {
            _beginDuel(challengerId, ascendingWizardId, ascensionCommitment.commitmentHash, commitment, true);
        } else {
            _beginDuel(ascendingWizardId, challengerId, commitment, ascensionCommitment.commitmentHash, true);
        }

        // The duel has begun! THERE CAN BE ONLY ONE!!!
        delete ascensionCommitment;
        delete ascendingWizardId;
    }

    /// @notice Completes the Ascension for the Wizard in the Ascension Chamber. Note that this can only be called
    ///         during a Resolution Window, and a Wizard can only enter the Ascension Chamber during the Ascension Window,
    ///         and there is _always_ a Fight Window between the Ascension Window and the Resolution Window. In other
    ///         words, there is a always a chance for a challenger to battle the Ascending Wizard before the
    ///         ascension can complete.
    function completeAscension() external duringResolutionWindow {
        require(ascendingWizardId != 0, "No Wizard to ascend");

        BattleWizard storage ascendingWiz = wizards[ascendingWizardId];

        if (ascensionCommitment.opponentId != 0) {
            // Someone challenged the ascending Wizard, but the ascending Wizard didn't fight!
            // You. Are. Outtahere!
            _transferPower(ascendingWizardId, ascensionCommitment.opponentId, REASON_COMPLETE_ASCENSION);
        }
        else {
            // Oh lucky day! The Wizard survived a complete fight cycle without any challengers
            // coming along! Let's just triple their power.
            //
            // A note to the naive: THIS WILL NEVER ACTUALLY HAPPEN.
            _updatePower(ascendingWiz, ascendingWiz.power * 3);
            ascendingWiz.nonce += 1;
        }

        emit AscensionComplete(ascendingWizardId, ascendingWiz.power);

        ascendingWizardId = 0;
    }

    function oneSidedCommit(uint256 committingWizardId, uint256 otherWizardId, bytes32 commitment)
            external duringFightWindow onlyWizardController(committingWizardId) exists(otherWizardId)
    {
        _checkChallenge(committingWizardId, otherWizardId);

        bool isAscensionBattle = false;

        if ((ascensionOpponents[committingWizardId] != 0) || (ascensionOpponents[otherWizardId] != 0)) {
            require(
                (ascensionOpponents[committingWizardId] == otherWizardId) &&
                (ascensionOpponents[otherWizardId] == committingWizardId), "Must resolve Ascension Battle");

            isAscensionBattle = true;
        }

        BattleWizard memory committingWiz = wizards[committingWizardId];
        BattleWizard memory otherWiz = wizards[otherWizardId];

        // Ideally, we'd use the isReady() function here, but it will return false if the caller has an
        // ascension opponent, which, of course, our Wizards just might!
        require(
            (committingWizardId != ascendingWizardId) &&
            (ascensionCommitment.opponentId != committingWizardId) &&
            (_blueMoldPower() <= committingWiz.power) &&
            (committingWiz.affinity != ELEMENT_NOTSET) &&
            (committingWiz.currentDuel == 0), "Wizard not ready");

        require(
            (otherWizardId != ascendingWizardId) &&
            (ascensionCommitment.opponentId != otherWizardId) &&
            (_blueMoldPower() <= otherWiz.power) &&
            (otherWiz.affinity != ELEMENT_NOTSET) &&
            (otherWiz.currentDuel == 0), "Wizard not ready.");

        SingleCommitment memory otherCommitment = pendingCommitments[otherWizardId];

        if (otherCommitment.opponentId == 0) {
            // The other Wizard does not currently have any pending commitments, we will store a
            // pending commitment so that the other Wizard can pick it up later.
            pendingCommitments[committingWizardId] = SingleCommitment({opponentId: otherWizardId, commitmentHash: commitment});

            emit OneSidedCommitAdded(
                committingWizardId,
                otherWizardId,
                committingWiz.nonce,
                otherWiz.nonce,
                commitment);
        } else if (otherCommitment.opponentId == committingWizardId) {
            // We've found a matching commitment! Be sure to order them correctly...
            if (committingWizardId < otherWizardId) {
                _beginDuel(committingWizardId, otherWizardId, commitment, otherCommitment.commitmentHash, isAscensionBattle);
            } else {
                _beginDuel(otherWizardId, committingWizardId, otherCommitment.commitmentHash, commitment, isAscensionBattle);
            }

            delete pendingCommitments[otherWizardId];

            if (isAscensionBattle) {
                delete ascensionOpponents[committingWizardId];
                delete ascensionOpponents[otherWizardId];
            }
        }
        else {
            revert("Opponent has a pending challenge");
        }
    }

    function cancelCommitment(uint256 wizardId) external onlyWizardController(wizardId) {
        require(ascensionOpponents[wizardId] == 0, "Can't cancel Ascension Battle");

        // Only emit the event when pendingCommitment exists.
        if (pendingCommitments[wizardId].opponentId != 0) {
            emit OneSidedCommitCancelled(wizardId);
        }

        delete pendingCommitments[wizardId];
    }

    /// @notice Commits two Wizards into a duel with a single transaction. Both Wizards must be "ready"
    ///      (not ascending, not battling, not moldy, and having a valid affinity), and it must be during a
    ///      Fight Window.
    /// @dev A note on implementation: Each duel is identified by a hash that combines both Wizard IDs,
    ///      both Wizard nonces, and both commits. Just the IDs and nonces are sufficient to ensure a unique
    ///      identifier of the duel, but by including the commits in the hash, we don't need to store the commits
    ///      on-chain (which is pretty expensive, given that they each take up 32 bytes). This does mean that
    ///      the duel resolution functions require the caller to pass in both commits in order to be resolved, but
    ///      the commit data is publicly available. Overall, this results in a pretty significant gas savings.
    ///
    ///      Earlier versions of this function provided convenience functionality, such as checking to see if a
    ///      Wizard was ready to ascend, or needed to be removed from a timed-out duel before starting this duel.
    ///      Each of those checks took more gas, required more code, and ultimately just tested conditions that are
    ///      trivial to check off-chain (where code is cheap and gas is for cars). This results in clearer
    ///      on-chain code, and very little extra effort off-chain.
    /// @param wizardId1 The id of the 1st wizard
    /// @param wizardId2 The id of the 2nd wizard
    /// @param commit1 The commitment hash of the 1st Wizard's moves
    /// @param commit2 The commitment hash of the 2nd Wizard's moves
    /// @param sig1 The signature corresponding to wizard1
    /// @param sig2 The signature corresponding to wizard2
    function doubleCommit(
        uint256 wizardId1,
        uint256 wizardId2,
        bytes32 commit1,
        bytes32 commit2,
        bytes calldata sig1,
        bytes calldata sig2) external duringFightWindow returns (bytes32 duelId) {

        // Ideally, we'd use the exists() modifiers instead of this code, but doing so runs over
        // Solidity's stack limit
        checkExists(wizardId1);
        checkExists(wizardId2);

        // The Wizard IDs must be strictly in ascending order so that we don't treat a battle between
        // "wizard 3 and wizard 5" as different than the battle between "wizard 5 and wizard 3".
        // This also ensures that a Wizards isn't trying to duel itself!
        require(wizardId1 < wizardId2, "Wizard IDs must be ordered");

        bool isAscensionBattle = false;

        if ((ascensionOpponents[wizardId1] != 0) || (ascensionOpponents[wizardId2] != 0)) {
            require(
                (ascensionOpponents[wizardId1] == wizardId2) &&
                (ascensionOpponents[wizardId2] == wizardId1), "Must resolve Ascension Battle");

            isAscensionBattle = true;

            // We can safely delete the ascensionOpponents values now because either this function
            // will culminate in a committed duel, or it will revert entirely. It also lets us
            // use the _isReady() convenience function (which treats a Wizard with a non-zero
            // ascension opponent as not ready).
            delete ascensionOpponents[wizardId1];
            delete ascensionOpponents[wizardId2];
        }

        // Get in-memory copies of the wizards
        BattleWizard memory wiz1 = wizards[wizardId1];
        BattleWizard memory wiz2 = wizards[wizardId2];

        require(_isReady(wizardId1, wiz1) && _isReady(wizardId2, wiz2), "Wizard not ready");

        // Check that the signatures match the duel data and commitments
        bytes32 signedHash1 = _signedHash(wizardId1, wizardId2, wiz1.nonce, wiz2.nonce, commit1);
        bytes32 signedHash2 = _signedHash(wizardId1, wizardId2, wiz1.nonce, wiz2.nonce, commit2);
        WIZARD_GUILD.verifySignatures(wizardId1, wizardId2, signedHash1, signedHash2, sig1, sig2);

        // If both signatures have passed, we can begin the duel!
        duelId = _beginDuel(wizardId1, wizardId2, commit1, commit2, isAscensionBattle);

        // Remove any potential commitments so that they won't be reused
        delete pendingCommitments[wizardId1];
        delete pendingCommitments[wizardId2];
    }

    /// @notice An internal utility function that computes the hash that is used for the commitment signature
    ///         from each Wizard.
    function _signedHash(uint256 wizardId1, uint256 wizardId2, uint32 nonce1, uint32 nonce2, bytes32 commit)
        internal view returns(bytes32)
    {
        return keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            wizardId1,
            wizardId2,
            nonce1,
            nonce2,
            commit
        ));
    }

    /// @notice The internal utility function to create the duel structure on chain, requires Commitments
    ///         from both Wizards.
    function _beginDuel(uint256 wizardId1, uint256 wizardId2, bytes32 commit1, bytes32 commit2, bool isAscensionBattle)
            internal returns (bytes32 duelId)
    {
        // Get a reference to the Wizard objects in storage
        BattleWizard storage wiz1 = wizards[wizardId1];
        BattleWizard storage wiz2 = wizards[wizardId2];

        // Compute a unique ID for this battle, this ID can't be reused because we strictly increase
        // the nonce for each Wizard whenever a battle is recreated. (Includes the contract address
        // to avoid replay attacks between different tournaments).
        duelId = keccak256(
            abi.encodePacked(
            this,
            wizardId1,
            wizardId2,
            wiz1.nonce,
            wiz2.nonce,
            commit1,
            commit2
        ));

        // Store the duel ID in each Wizard, to mark the fact that they are fighting
        wiz1.currentDuel = duelId;
        wiz2.currentDuel = duelId;

        // Keep track of the timeout for this duel
        uint256 duelTimeout;

        if (isAscensionBattle) {
            // Ascension Battles always last for a while after the current fight window to ensure
            // both sides have a well-defined timeframe for revealing their moves (Ascension Battles)
            // are inherently more asynchronous than normal battles.
            duelTimeout = _ascensionDuelTimeout();
        } else {
            // Normal battles just timeout starting .... NOW!
            duelTimeout = block.number + tournamentTimeParameters.duelTimeoutDuration;
        }

        duels[duelId] = Duel({timeout: uint128(duelTimeout), isAscensionBattle: isAscensionBattle});

        emit DuelStart(duelId, wizardId1, wizardId2, duelTimeout, isAscensionBattle, commit1, commit2);
    }

    /// @notice Reveals the moves for one of the Wizards in a duel. This should be called rarely, but
    ///         is necessary in order to resolve a duel where one player is unwilling or unable to reveal
    ///         their moves (also useful if a coordinating intermediary is unavailable or unwanted for some reason).
    ///         It's worth noting that this method doesn't check any signatures or filter on msg.sender because
    ///         it is cryptographically impossible for someone to submit a moveset and salt that matches the
    ///         commitment (which was signed, don't forget!).
    ///
    ///         Note: This function doesn't need exists(wizardId) because an eliminated Wizard would have
    ///               currentDuel == 0
    /// @param committingWizardId The Wizard whose moves are being revealed
    /// @param commit A copy of the commitment used previously, not stored on-chain to save gas
    /// @param moveSet The revealed move set
    /// @param salt The salt used to secure the commitment hash
    /// @param otherWizardId The other Wizard in this battle
    /// @param otherCommit The other Wizard's commitment, not stored on-chain to save gas
    function oneSidedReveal(
        uint256 committingWizardId,
        bytes32 commit,
        bytes32 moveSet,
        bytes32 salt,
        uint256 otherWizardId,
        bytes32 otherCommit) external
    {
        BattleWizard memory wizard = wizards[committingWizardId];
        BattleWizard memory otherWizard = wizards[otherWizardId];

        bytes32 duelId = wizard.currentDuel;

        require(duelId != 0, "Wizard not dueling");

        // Check that the passed data matches the duel hash
        bytes32 computedDuelId;

        // Make sure we compute the duel ID with the Wizards sorted in ascending order
        if (committingWizardId < otherWizardId) {
            computedDuelId = keccak256(
                abi.encodePacked(
                this,
                committingWizardId,
                otherWizardId,
                wizard.nonce,
                otherWizard.nonce,
                commit,
                otherCommit
            ));
        } else {
            computedDuelId = keccak256(
                abi.encodePacked(
                this,
                otherWizardId,
                committingWizardId,
                otherWizard.nonce,
                wizard.nonce,
                otherCommit,
                commit
            ));
        }

        require(computedDuelId == duelId, "Invalid duel data");

        // Confirm that the revealed data matches the commitment
        require(keccak256(abi.encodePacked(moveSet, salt)) == commit, "Moves don't match commitment");

        // We need to verify that the provided moveset is valid here. Otherwise the duel resolution will
        // fail later, and the duel can never be resolved. We treat a _valid_ commit/reveal of an _invalid_
        // moveset as being equivalent of not providing a reveal (which is subject to automatic loss). I mean,
        // you really should have known better!
        require(duelResolver.isValidMoveSet(moveSet), "Invalid moveset");

        if (revealedMoves[duelId][otherWizardId] != 0) {
            // We have the revealed moves for the other Wizard also, we can resolve the duel now
            if (committingWizardId < otherWizardId) {
                _resolveDuel(duelId, committingWizardId, otherWizardId, moveSet, revealedMoves[duelId][otherWizardId]);
            } else {
                _resolveDuel(duelId, otherWizardId, committingWizardId, revealedMoves[duelId][otherWizardId], moveSet);
            }
        }
        else {
            require(block.number < duels[duelId].timeout, "Duel expired");
            // Store our revealed moves for later resolution
            revealedMoves[duelId][committingWizardId] = moveSet;
            emit OneSidedRevealAdded(duelId, committingWizardId, otherWizardId);
        }
    }

    /// @notice Reveals the moves for both Wizards at once, saving lots of gas and lowering the number
    ///         of required transactions. As with oneSidedReveal(), no authentication is required other
    ///         than matching the reveals to the commits. It is not an error if oneSidedReveal is called
    ///         and then doubleReveal, although we do ignore the previous one-sided reveal if it exists.
    ///         The _resolvedDuel utility function will clean up any cached revealedMoves for BOTH Wizards.
    ///
    ///         NOTE: As with the doubleCommit() method, the Wizards must be provided in _strict_ ascending
    ///         order for this function to work correctly.
    ///
    ///         NOTE: This function will fail if _either_ of the Wizards have submitted an invalid moveset.
    ///         The correct way of handling this situation is to use oneSidedReveal() (if one moveset is valid
    ///         and the other is not) and then let the Battle timeout, or -- if both movesets are invalid --
    ///         don't do any reveals and let the Battle timeout.
    ///
    ///         Note: This function doesn't need exists(wizardId1) exists(wizardId2) because an
    ///               eliminated Wizard would have currentDuel == 0
    /// @param wizardId1 The id of the 1st wizard
    /// @param wizardId2 The id of the 2nd wizard
    /// @param commit1 A copy of the 1st Wizard's commitment, not stored on-chain to save gas
    /// @param commit2 A copy of the 2nd Wizard's commitment, not stored on-chain to save gas
    /// @param moveSet1 The plaintext reveal (moveset) of the 1st wizard
    /// @param moveSet2 The plaintext reveal (moveset) of the 2nd wizard
    /// @param salt1 The secret salt of the 1st wizard
    /// @param salt2 The secret salt of the 2nd wizard
    function doubleReveal(
        uint256 wizardId1,
        uint256 wizardId2,
        bytes32 commit1,
        bytes32 commit2,
        bytes32 moveSet1,
        bytes32 moveSet2,
        bytes32 salt1,
        bytes32 salt2) external
    {
        // Get a reference to the Wizard objects in storage
        BattleWizard storage wiz1 = wizards[wizardId1];
        BattleWizard storage wiz2 = wizards[wizardId2];

        // In order to match the duel ID generated by the commit functions, the Wizard IDs must be strictly
        // in ascending order. However! We don't actually check that here because that just wastes gas
        // to perform a check that the duel ID comparison below will have to do anyway. But, we're leaving
        // this commented out here as a reminder...
        // require(wizardId1 < wizardId2, "Wizard IDs must be ordered");

        // Confirm that the duel data passed into the function matches the duel ID in the Wizard
        bytes32 duelId = keccak256(
            abi.encodePacked(
            this,
            wizardId1,
            wizardId2,
            wiz1.nonce,
            wiz2.nonce,
            commit1,
            commit2
        ));

        // NOTE: We don't actually need to check the currentDuel field of the other Wizard because
        // we trust the hash function.
        require(wiz1.currentDuel == duelId, "Invalid duel data");

        // Confirm that the reveals match the commitments
        require(
            (keccak256(abi.encodePacked(moveSet1, salt1)) == commit1) &&
            (keccak256(abi.encodePacked(moveSet2, salt2)) == commit2), "Moves don't match commitment");

        // Resolve the duel!
        _resolveDuel(duelId, wizardId1, wizardId2, moveSet1, moveSet2);
    }

    /// @notice An utility function to resolve a duel once both movesets have been revealed.
    function _resolveDuel(bytes32 duelId, uint256 wizardId1, uint256 wizardId2, bytes32 moveSet1, bytes32 moveSet2) internal {
        Duel memory duelInfo = duels[duelId];

        require(block.number < duelInfo.timeout, "Duel expired");

        // Get a reference to the Wizard objects in storage
        BattleWizard storage wiz1 = wizards[wizardId1];
        BattleWizard storage wiz2 = wizards[wizardId2];

        int256 battlePower1 = wiz1.power;
        int256 battlePower2 = wiz2.power;

        int256 moldPower = int256(_blueMoldPower());

        if (duelInfo.isAscensionBattle) {
            // In Ascension Battles, if one Wizard is more powerful than the other Wizard by
            // more than double the current blue mold level, we cap the at-risk power of that
            // more powerful Wizard to match the power level of the weaker wizard. This probably
            // isn't clear, so here are some examples. In all of these examples, the second wizard
            // is more powerful than the first, but the logic is equivalent in both directions.
            // In each case, we assume the blue mold level is 100. (The non-intuitive lines are
            // marked with an arrow.)
            //
            //  power1   |   power2   |   battlePower2
            //   100     |    100     |     100
            //   100     |    200     |     200
            //   100     |    300     |     300
            //   100     |    301     |     100  <==
            //   199     |    200     |     200
            //   199     |    300     |     300
            //   199     |    399     |     399
            //   199     |    400     |     199  <==
            //
            // This technique is necessary to achieve three somewhat conflicting goals
            // simultaneously:
            //    - Anyone should be able to battle an ascending Wizard, regardless of the
            //      power differential
            //    - Your probability of winning an Ascension Battle should be proportional to
            //      the amount of power you put at risk
            //    - A Wizard that is Ascending should be _guaranteed_ that, if they manage to
            //      win the Ascension Battle, they will have enough power to escape the next
            //      Blue Mold increase. (And if they lose, at least they had a fair shot.)
            //
            // Note that although a very powerful Wizard becomes less likely to win under this
            // scheme (because they aren't using their entire power in this battle), they are
            // putting much less power at risk (while the ascending Wizard is risking EVERYTHING).
            if (battlePower1 > battlePower2 + 2*moldPower) {
                battlePower1 = battlePower2;
            } else if (battlePower2 > battlePower1 + 2*moldPower) {
                battlePower2 = battlePower1;
            }
        }

        int256 powerDiff = duelResolver.resolveDuel(
            moveSet1,
            moveSet2,
            uint256(battlePower1),
            uint256(battlePower2),
            wiz1.affinity,
            wiz2.affinity);

        // A duel resolver should never return a negative value with a magnitude greater than the
        // first wizard's power, or a positive value with a magnitude greater than the second
        // wizard's power. We enforce that here to be safe (since it is an external contract).
        if (powerDiff < -battlePower1) {
            powerDiff = -battlePower1;
        } else if (powerDiff > battlePower2) {
            powerDiff = battlePower2;
        }

        // Given the checks above, both of these values will resolve to >= 0
        battlePower1 += powerDiff;
        battlePower2 -= powerDiff;

        if (duelInfo.isAscensionBattle) {
            // In an Ascension Battle, we always transfer 100% of the power-at-risk. Give it
            // to the Wizard with the highest power after the battle (which might not be the
            // Wizard who got the higher score!)
            if (battlePower1 >= battlePower2) {
                // NOTE! The comparison above is very carefully chosen: In the case of a
                // tie in the power level after the battle (exceedingly unlikely, but possible!)
                // we want the win to go to the Wizard with the lower ID. Since all of the duel
                // functions require the wizards to be strictly ascending ID order, that's
                // wizardId1, which means we want a tie to land in this leg of the if-else statement.
                powerDiff += battlePower2;
            } else {
                powerDiff -= battlePower1;
            }
        }

        // We now apply the power differential to the _actual_ Wizard powers (and not just
        // the power-at-risk).
        int256 power1 = wiz1.power + powerDiff;
        int256 power2 = wiz2.power - powerDiff;

        // We now check to see if either of the wizards ended up under the blue mold level.
        // If so, we transfer ALL of the rest of the power from the weaker Wizard to the winner.
        if (power1 < moldPower) {
            power2 += power1;
            power1 = 0;
        }
        else if (power2 < moldPower) {
            power1 += power2;
            power2 = 0;
        }

        _updatePower(wiz1, power1);
        _updatePower(wiz2, power2);

        // unlock wizards
        wiz1.currentDuel = 0;
        wiz2.currentDuel = 0;

        // Increment the Wizard nonces
        wiz1.nonce += 1;
        wiz2.nonce += 1;

        // Clean up old data
        delete duels[duelId];
        delete revealedMoves[duelId][wizardId1];
        delete revealedMoves[duelId][wizardId2];

        // emit event
        emit DuelEnd(duelId, wizardId1, wizardId2, moveSet1, moveSet2, wiz1.power, wiz2.power);
    }

    /// @notice Utility function to update the power on a Wizard, ensuring it doesn't overflow
    ///         a uint88 and also updates maxPower as appropriate.
    // solium-disable-next-line security/no-assign-params
    function _updatePower(BattleWizard storage wizard, int256 newPower) internal {
        if (newPower > MAX_POWER) {
            newPower = MAX_POWER;
        }

        wizard.power = uint88(newPower);

        if (wizard.maxPower < newPower) {
            wizard.maxPower = uint88(newPower);
        }
    }

    /// @notice Utility function to transfer all power from sending Wizard to receiving Wizard
    /// and emit a PowerTransferred event
    function _transferPower(uint256 sendingWizardId, uint256 receivingWizardId, uint8 reason) internal {
        BattleWizard storage sendingWiz = wizards[sendingWizardId];
        BattleWizard storage receivingWiz = wizards[receivingWizardId];

        _updatePower(receivingWiz, receivingWiz.power + sendingWiz.power);

        emit PowerTransferred(sendingWizardId, receivingWizardId, sendingWiz.power, reason);

        sendingWiz.power = 0;
        // update the nonces to reflect the state change and invalidate any pending commitments
        sendingWiz.nonce += 1;
        receivingWiz.nonce += 1;
    }

    /// @notice used for when wizards locked in an ascension battle but one wizard didn't submit their commit
    function resolveOneSidedAscensionBattle(uint256 wizardId) external duringResolutionWindow {
        uint256 opponentId = ascensionOpponents[wizardId];
        require(opponentId != 0, "No opponent");

        SingleCommitment memory commit = pendingCommitments[wizardId];
        require(commit.opponentId == opponentId, "No commit");

        _transferPower(opponentId, wizardId, REASON_RESOLVE_ONE_SIDED_ASCENSION_BATTLE);

        // clean up state
        delete pendingCommitments[wizardId];
        delete ascensionOpponents[wizardId];
        delete ascensionOpponents[opponentId];
    }

    /// @notice Resolves a duel that has timed out. This can only happen if one or both players
    ///         didn't reveal their moves. If both don't reveal, there is no power transfer, if one
    ///         revealed, they win ALL the power.
    ///
    ///         Note: This function doesn't need exists(wizardId1) exists(wizardId2) because an
    ///               eliminated Wizard would have currentDuel == 0
    function resolveTimedOutDuel(uint256 wizardId1, uint256 wizardId2) external {
        // This check is required in order to prevent attackers from wiping out wizards in a timed out duels.
        require(wizardId1 != wizardId2, "Same Wizard");
        BattleWizard storage wiz1 = wizards[wizardId1];
        BattleWizard storage wiz2 = wizards[wizardId2];

        bytes32 duelId = wiz1.currentDuel;

        require(duelId != 0 && wiz2.currentDuel == duelId);
        require(block.number >= duels[duelId].timeout);

        int256 allPower = wiz1.power + wiz2.power;

        if (revealedMoves[duelId][wizardId1] != 0) {
            // The first Wizard revealed their moves, but the second one didn't (otherwise it
            // would have been resolved). Transfer all of the power from two to one.
            _updatePower(wiz1, allPower);
            wiz2.power = 0;
        } else if (revealedMoves[duelId][wizardId2] != 0) {
            // The second Wizard revealed, so it drains the first.
            _updatePower(wiz2, allPower);
            wiz1.power = 0;
        }
        // NOTE: If neither Wizard did a reveal, we just end the battle with no power transfer.

        // unlock wizards
        wiz1.currentDuel = 0;
        wiz2.currentDuel = 0;

        // Increment the Wizard nonces
        wiz1.nonce += 1;
        wiz2.nonce += 1;

        // Clean up old data
        delete duels[duelId];
        delete revealedMoves[duelId][wizardId1];
        delete revealedMoves[duelId][wizardId2];

        // emit event
        emit DuelTimeOut(duelId, wizardId1, wizardId2, wiz1.power, wiz2.power);
    }

    /// @notice Transfer the power of one Wizard to another. The caller has to be the owner
    ///         or have approval of the sending Wizard. Both Wizards must be ready (not moldy,
    ///         ascending or in a duel), and we limit power transfers to happen during Fight
    ///         Windows (this is important so that power transfers don't interfere with Culling
    ///         or Ascension operations).
    /// @param sendingWizardId The Wizard to transfer power from. After the transfer,
    ///        this Wizard will have no power.
    /// @param receivingWizardId The Wizard to transfer power to.
    function giftPower(uint256 sendingWizardId, uint256 receivingWizardId) external
        onlyWizardController(sendingWizardId) exists(receivingWizardId) duringFightWindow
    {
        require(sendingWizardId != receivingWizardId);
        require(isReady(sendingWizardId) && isReady(receivingWizardId));

        _transferPower(sendingWizardId, receivingWizardId, REASON_GIFT_POWER);
    }

    /// @notice A function that will permanently remove eliminated Wizards from the smart contract.
    ///
    ///         The way that this (and cullMoldedWithMolded()) works isn't entirely obvious, so please settle
    ///         down for story time!
    ///
    ///         The "obvious" solution to eliminating Wizards from the Tournament is to simply delete
    ///         them from the wizards mapping when they are beaten into submission (Oh! Sorry! Marketing
    ///         team says I should say "tired".) But we can't do this during the revival phase, because
    ///         maybe that player wants to revive their Wizard. What's more is that when the Blue Mold
    ///         starts, there is no on-chain event that fires when the Blue Mold power level doubles
    ///         (which can also lead to Wizard elimination).
    ///
    ///         The upshot is that we could have a bunch of Wizards sitting around in the wizards mapping
    ///         that are below the Blue Mold level, possibly even with a power level of zero. If we can't
    ///         get rid of them somehow, we can't know when the Tournament is over (which would make for
    ///         a pretty crappy tournament, huh?).
    ///
    ///         The next obvious solution? If a Wizard is below the Blue Mold level, just let anyone come
    ///         along and delete that sucker. Whoa, there, Cowboy! Maybe you should think it through for
    ///         a minute before you jump to any conclusions. Give it a minute, you'll see what I mean.
    ///
    ///         Yup. I knew you'd see it. If we start deleting ALL the Wizards below the Blue Mold level,
    ///         there's a not-so-rare edge case where the last two or three or ten Wizards decide not
    ///         to fight each other, and they all get molded. Eek! Another great way to make for a crappy
    ///         tournament! No winner!
    ///
    ///         So, if we do end up with ALL of the Wizards molded, how do we resolve the Tournament? Our
    ///         solution is to let the 5 most powerful molded Wizards split the pot pro-rata (so, if you have
    ///         60% of the total power represented in the 5 winning Wizards, you get 60% of the pot.)
    ///
    ///         But this puts us in a bit of a pickle. How can we delete a molded Wizard if it might just
    ///         be a winner?!
    ///
    ///         Simple! If someone wants to permanently remove a Wizard from the tournament, they just have
    ///         to pass in a reference to _another_ Wizard (or Wizards) that _prove_ that the Wizard they
    ///         want to eliminate can't possibly be the winner.
    ///
    ///         This function handles the simpler of the two cases: If the caller can point to a Wizard
    ///         that is _above_ the Blue Mold level, then _any_ Wizard that is below the Blue
    ///         mold level can be safely eliminated.
    ///
    ///         Note that there are no restrictions on who can cull moldy Wizards. Anyone can call, so
    ///         long as they have the necessary proof!
    /// @param wizardIds A list of moldy Wizards to permanently remove from the Tournament
    /// @param survivor The ID of a surviving Wizard, as proof that it's safe to remove those moldy folks
    function cullMoldedWithSurvivor(uint256[] calldata wizardIds, uint256 survivor) external
        exists(survivor) duringCullingWindow
    {
        uint256 moldLevel = _blueMoldPower();

        require(wizards[survivor].power >= moldLevel, "Survivor isn't alive");

        for (uint256 i = 0; i < wizardIds.length; i++) {
            uint256 wizardId = wizardIds[i];
            if (wizards[wizardId].maxPower != 0 && wizards[wizardId].power < moldLevel) {
                _deleteWizard(wizardId);
            }
        }
    }

    /// @notice Another function to remove eliminated Wizards from the smart contract.
    ///
    ///         Well, partner, it's good to see you back again. I hope you've recently read the comments
    ///         on cullMoldedWithSurvivor() because that'll provide you with some much needed context here.
    ///
    ///         This function handles the other case, what if there IS no unmolded Wizard to point to, how do
    ///         you cull the excess moldy Wizards to pare it down to the five final survivors that should split
    ///         the pot?
    ///
    ///         Well, the answer is much the same as before, only instead of pointing to a single example of
    ///         a Wizard that has a better claim to the pot, we require that the caller provides a reference
    ///         to FIVE other Wizards who have a better claim to the pot.
    ///
    ///         It would be pretty easy to write this function in a way that was very expensive, so in order
    ///         to save ourselves a lot of gas, we require that the list of Wizards is in strictly descending
    ///         order of power (if two wizards have identical power levels, we consider the one with the
    ///         lower ID as being more powerful).
    ///
    ///         We also require that the first (i.e. most powerful) Wizard in the list is moldy, even though
    ///         it's not going to be eliminated! This may not seem strictly necessary, but it makes the
    ///         logic simpler (because then we can just assume that ALL the Wizards are moldy, without any
    ///         further checks). If it isn't moldy, the caller should just use the cullMoldedWithSurvivor()
    ///         method instead!
    ///
    ///         "Oh ho!" you say, taking great pleasure in your clever insight. "How can you be so sure that
    ///         the first five Wizards passed in as 'leaders' are _actually_ the five most powerful molded
    ///         Wizards?" Well, my dear friend... you are right: We can't!
    ///
    ///         However it turns out that's actually fine! If the caller (for some reason) decides to start the list
    ///         with the Wizards ranked 6-10 in the Tournament, they can do it that and we'd never know the
    ///         difference.... Except that's not actually a problem, because they'd still only be able to remove
    ///         molded Wizards ranked 11th or higher, all of which are due for removal anyway. (It's the same
    ///         argument that we don't actually know -- inside this function -- if there's a non-molded Wizard;
    ///         it's still safe to allow the caller to eliminate molded Wizards ranked 6th or higher.)
    /// @param moldyWizardIds A list of moldy Wizards, in strictly decreasing power order. Entries 5+ in this list
    ///         will be permanently removed from the Tournament
    function cullMoldedWithMolded(uint256[] calldata moldyWizardIds) external duringCullingWindow {
        require(moldyWizardIds.length > 0, "Empty ids");

        uint256 currentId;
        uint256 currentPower;
        uint256 previousId = moldyWizardIds[0];
        uint256 previousPower = wizards[previousId].power;

        // It's dumb to call this function with fewer than 5 wizards, but nothing bad will happen
        // so we don't waste gas preventing it.
        // require(moldyWizardsIds.length > 5, "No wizards to eliminate");

        require(previousPower < _blueMoldPower(), "Not moldy");
        // The power of a dueling molded Wizard isn't finalized. So shouldn't be used for culling other wizards.
        require(wizards[previousId].currentDuel == 0, "Dueling");

        for (uint256 i = 1; i < moldyWizardIds.length; i++) {
            currentId = moldyWizardIds[i];
            checkExists(currentId);
            currentPower = wizards[currentId].power;

            // Confirm that this new Wizard has a worse claim on the prize than the previous Wizard
            require(
                (currentPower < previousPower) ||
                ((currentPower == previousPower) && (currentId > previousId)),
                "Wizards not strictly ordered");

            if (i >= 5) {
                _deleteWizard(currentId);
            } else {
                // Preventing a dueling molded wizards from culling other wizards.
                require(wizards[currentId].currentDuel == 0, "Dueling");
            }

            previousId = currentId;
            previousPower = currentPower;
        }
    }

    // @notice Utility function to delete a wizard from storage.
    //         It makes sure the wizard is not current dueling,
    //         because deleting a dueling wizard will lock the other wizard forever.
    function _deleteWizard(uint256 wizardId) internal {
        require(wizards[wizardId].currentDuel == 0, "Wizard is dueling");
        delete wizards[wizardId];
        remainingWizards--;
        emit WizardElimination(wizardId);
    }

    /// @notice One last culling function that simply removes Wizards with zero power. They can't
    ///         even get a cut of the final pot... (Worth noting: Culling Windows are only available
    ///         during the Elimination Phase, so even Wizards that go to zero can't be removed during
    ///         the Revival Phase.)
    function cullTiredWizards(uint256[] calldata wizardIds) external duringCullingWindow {
        for (uint256 i = 0; i < wizardIds.length; i++) {
            uint256 wizardId = wizardIds[i];
            if (wizards[wizardId].maxPower != 0 && wizards[wizardId].power == 0) {
                _deleteWizard(wizardId);
            }
        }
    }

    /// @notice This is a pretty important function! When the Tournament has a single remaining Wizard left
    ///         we can send them ALL of the funds in this smart contract. Notice that we don't actually check
    ///         to see if the claimant is moldy: If there is a single remaining Wizard in the Tournament, they
    ///         get to take the pot, regardless of the mold level.
    function claimTheBigCheeze(uint256 claimingWinnerId) external duringCullingWindow onlyWizardController(claimingWinnerId) {
        require(remainingWizards == 1, "Keep fighting!");

        // They did it! They were the final survivor. They get all the money!
        emit PrizeClaimed(claimingWinnerId, address(this).balance);

        remainingWizards = 0;
        delete wizards[claimingWinnerId];

        msg.sender.transfer(address(this).balance);
    }

    /// @notice A function that allows one of the 5 most powerful Wizards to claim their pro-rata share of
    ///         the pot if the Tournament ends with all Wizards succumbing to the Blue Mold. Note that
    ///         all but five of the Moldy Wizards need to first be eliminated with cullMoldedWithMolded().
    ///
    ///         It might seem like it would be tricky to split the pot one player at a time. Imagine that
    ///         there are just three winners, with power levels 20, 30, and 50. If the third player claims
    ///         first, they will get 50% of the (remaining) pot, but if they claim last, they will get
    ///         100% of the remaining pot! If you run some examples, you'll see that by decreasing the pot
    ///         size by a value exactly proportional to the power of the removed Wizard, everyone gets
    ///         the same amount of winnings, regardless of the order in which they claim (plus or minus
    ///         a wei or two due to rounding).
    /// @param claimingWinnerId The Wizard who's share is currently being claimed
    /// @param allWinners The complete set of all remaining Wizards in the tournament. This set MUST
    ///                   be ordered by ascending ID.
    function claimSharedWinnings(uint256 claimingWinnerId, uint256[] calldata allWinners)
        external duringCullingWindow onlyWizardController(claimingWinnerId)
    {
        require(remainingWizards <= 5, "Too soon to claim");
        require(remainingWizards == allWinners.length, "Must provide all winners");
        require(wizards[claimingWinnerId].power != 0, "No cheeze for you!");

        uint256 moldLevel = _blueMoldPower();
        uint256 totalPower = 0;
        uint256 lastWizard = 0;

        // Check to see that all of the remaining Wizards are molded and not yet eliminated,
        // assuming they are, keep track of the total power level of the remaining entrants
        for (uint256 i = 0; i < allWinners.length; i++) {
            uint256 wizardId = allWinners[i];
            uint256 wizardPower = wizards[wizardId].power;

            require(wizardId > lastWizard, "Winners not unique and ordered");
            require(wizards[wizardId].maxPower != 0, "Wizard already eliminated");
            require(wizardPower < moldLevel, "Wizard not moldy");

            lastWizard = wizardId;
            totalPower += wizardPower;
        }

        uint256 claimingWinnerShare = address(this).balance * wizards[claimingWinnerId].power / totalPower;

        // Be sure to delete their claim on the prize before sending them the balance!
        delete wizards[claimingWinnerId];
        remainingWizards--;

        emit PrizeClaimed(claimingWinnerId, claimingWinnerShare);

        msg.sender.transfer(claimingWinnerShare);
    }

    /// @notice Allows the GateKeeper to destroy this contract if it's not needed anymore.
    function destroy() external onlyGateKeeper {
        require(isActive() == false);

        selfdestruct(msg.sender);
    }
}