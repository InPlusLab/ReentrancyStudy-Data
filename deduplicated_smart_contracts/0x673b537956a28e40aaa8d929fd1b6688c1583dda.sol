/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

pragma solidity >=0.5.6 <0.6.0;

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






/// @title ERC165Interface
/// @dev https://eips.ethereum.org/EIPS/eip-165
interface ERC165Interface {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///      uses less than 30,000 gas.
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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




/// @title WizardPresaleInterface
/// @notice This interface represents the single method that the final tournament and master Wizard contracts
///         will use to import the presale wizards when those contracts have been finalized a released on
///         mainnet. Once all presale Wizards have been absorbed, this temporary pre-sale contract can be
///         destroyed.
contract WizardPresaleInterface {

    // See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md on how
    // to calculate this
    bytes4 public constant _INTERFACE_ID_WIZARDPRESALE = 0x4df71efb;

    /// @notice This function is used to bring a presale Wizard into the final contracts. It can
    ///         ONLY be called by the official gatekeeper contract (as set by the Owner of the presale
    ///         contract). It does a number of things:
    ///            1. Check that the presale Wizard exists, and has not already been absorbed
    ///            2. Transfer the Eth used to create the presale Wizard to the caller
    ///            3. Mark the Wizard as having been absorbed, reclaiming the storage used by the presale info
    ///            4. Return the Wizard information (its owner, minting price, and elemental alignment)
    /// @param id the id of the presale Wizard to be absorbed
    function absorbWizard(uint256 id) external returns (address owner, uint256 power, uint8 affinity);

    /// @notice A convenience function that allows multiple Wizards to be moved to the final contracts
    ///         simultaneously, works the same as the previous function, but in a batch.
    /// @param ids An array of ids indicating which presale Wizards are to be absorbed
    function absorbWizardMulti(uint256[] calldata ids) external
        returns (address[] memory owners, uint256[] memory powers, uint8[] memory affinities);

    function powerToCost(uint256 power) public pure returns (uint256 cost);
    function costToPower(uint256 cost) public pure returns (uint256 power);
}




/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}



/// Utility library of inline functions on address payables.
/// Modified from original by OpenZeppelin.
contract Address {
    /// @notice Returns whether the target address is a contract.
    /// @dev This function will return false if invoked during the constructor of a contract,
    /// as the code is not actually created until after the constructor finishes.
    /// @param account address of the account to check
    /// @return whether the target address is a contract
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) } // solium-disable-line security/no-inline-assembly
        return size > 0;
    }
}


/// @title The Inaugural Cheeze Wizards Gate Keeper contract
/// @notice The GateKeeper is responsible for determining which Wizards are allowed to enter into
///         a Tournament. This particular GateKeeper is designed to manage the first, official
///         Cheeze Wizards Tournament! It's much more complicated than a typical GateKeeper
///         implementation because it needs to juggle two additional issues that most GateKeepers
///         don't need to deal with: Importing Wizards from the Presale contract and minting tokens
///         to represent newly conjured Wizards.
contract InauguralGateKeeper is AccessControl, WizardConstants, Address, WizardGuildInterfaceId, TournamentInterfaceId {
    // The Tournament contract.
    TournamentInterface public tournament;

    // The Wizard guild contract.
    // TODO: Replace with the address of the contract once it's deployed.
    WizardGuildInterface public constant WIZARD_GUILD = WizardGuildInterface(address(0x35B7838dd7507aDA69610397A85310AE0abD5034));

    // The Wizard presale contract.
    WizardPresaleInterface public constant WIZARD_PRESALE = WizardPresaleInterface(address(0x2F4Bdafb22bd92AA7b7552d270376dE8eDccbc1E));

    /// @dev The ratio between the cost of a Wizard (in wei) and the power of the Wizard.
    ///      power = cost / MAX_POWER_SCALE
    ///      cost = power * MAX_POWER_SCALE
    uint256 internal constant MAX_POWER_SCALE = 1000;
    uint256 internal tournamentPowerScale;

    function getTournamentPowerScale() external view returns (uint256) {
        return tournamentPowerScale;
    }

    /// @dev The constant conversion factor used for elementalWizardIncrement
    uint256 private constant TENTH_BASIS_POINTS = 100000;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // We pack these values together to save storage costs (and since they are all access together)
    struct WizardCosts {
        /// @dev The cost of Neutral Wizards (in wei).
        uint96 neutralWizardCost;

        /// @dev The cost of the _next_ Elemental Wizard (in wei); increases with each Elemental Wizard
        ///      sold, at the rate defined in `elementalWizardIncrement`
        uint96 elementalWizardCost;

        /// @dev The increment ratio in cost between sequential Elemental Wizards, multiplied by 100k for
        ///      greater granularity (TENTH_BASIS_POINTS)
        uint32 elementalWizardIncrement;
    }

    WizardCosts public wizardCosts;

    /// @param setCooAddress The initial COO address.
    /// @param setCfoAddress The initial CFO address.
    /// @param setNeutralWizardCost The cost of the Neutral Wizards, in wei.
    /// @param setElementalWizardCost The starting cost of the Elemental Wizards, in wei.
    /// @param setElementalWizardIncrement The rate at which the Elemental Wizards cost increases.
    constructor(
        address setCooAddress,
        address payable setCfoAddress,
        uint256 setNeutralWizardCost,
        uint256 setElementalWizardCost,
        uint256 setElementalWizardIncrement)
        public AccessControl(setCooAddress, setCfoAddress)
    {
        wizardCosts = WizardCosts ({
            neutralWizardCost: uint96(setNeutralWizardCost),
            elementalWizardCost: uint96(setElementalWizardCost),
            elementalWizardIncrement: uint32(setElementalWizardIncrement)
        });
    }

    modifier onlyWizardController(uint256 wizardId) {
        require(WIZARD_GUILD.isApprovedOrOwner(msg.sender, wizardId), "Must be Wizard controller");
        _;
    }

    /// @dev The presale contract will be sending Ether directly to this contract,
    ///      so we need it to have a payable fallback.
    function() external payable {
        require(msg.sender == address(WIZARD_PRESALE) || msg.sender == address(tournament), "Don't send funds to GateKeeper");
    }

    /// @notice Registers the address of the Tournament with the GateKeeper. This can't be passed
    ///         into the constructor, because the Tournament itself needs a reference to the GateKeeper
    ///         in its constructor!
    ///
    ///         NOTE: Technically, most of the functions below should have some kind of modifier
    ///               that ensures that the Tournament is set before they are called, but that
    ///               just adds gas. In practice, multiple draft Gatekeeper contracts may be
    ///               deployed, so what matters is that we call this function before sharing
    ///               the address of this contract publicly. No need to enforce that on chain,
    ///               with its associated gas costs!
    function registerTournament(address setTournament) external onlyCOO {
        require(address(tournament) == address(0), "Tournament already registered");
        tournament = TournamentInterface(setTournament);
        require(
            (setTournament != address(0)) &&
            tournament.supportsInterface(_INTERFACE_ID_TOURNAMENT), "Invalid Tournament");

        tournamentPowerScale = tournament.powerScale();
        require(tournamentPowerScale <= MAX_POWER_SCALE, "Power scale too high");
    }

    /// @notice This is it folks, the main event! The way for the world to get new Wizards! Does
    ///         pretty much what it says on the box; let's you conjure a new Wizard with a specified
    ///         elemental affinity. The call must include enough Ether to cover the cost of the new
    ///         Wizard, and any excess is refunded. The power of the Wizard is derived from
    ///         the cost. YOU CAN NOT PAY EXTRA TO RAISE INITIAL POWER LATER. Returns the ID
    ///         of the newly conjured Wizard.
    ///
    ///         While you cannot increase power later, you can conjure some more Wizards!
    /// @param affinity The elemental affinity you want for the Wizard. Valid elements are
    ///        defined in `WizardConstants`, see the constants with names starting `ELEMENT_`.
    ///        ELEMENT_NOTSET is not valid for regular Wizards (unlike Exclusive Wizards).
    function conjureWizard(uint8 affinity) external payable returns (uint256) {
        uint8[] memory affinities = new uint8[](1);

        affinities[0] = affinity;

        uint256[] memory wizardIds = conjureWizardMulti(affinities);

        return wizardIds[0];
    }

    /// @notice A convenience function that allows you to conjure a whole bunch of Wizards at once! You know how
    ///         there's "a pride of lions", "a murder of crows", and "a parliament of owls"? Well, with this
    ///         here function you can conjure yourself "a stench of Cheeze Wizards"!
    /// @dev This function is careful to bundle all of the external calls (_transferRefund() and onERC721Received())
    ///         at the end of the function to limit the risk of reentrancy attacks.
    /// @param affinities The elemental affinities of the Wizards, can mix and match any valid types.
    ///        Valid elements are defined in `WizardConstants`, see the constants with names starting
    ///        `ELEMENT_`. ELEMENT_NOTSET is not valid for regular Wizards (unlike Exclusive Wizards).
    function conjureWizardMulti(uint8[] memory affinities) public payable
            returns (uint256[] memory wizardIds)
    {
        (uint256 totalCost, uint256 contribution, uint88[] memory powers) = _computeWizardPowers(affinities);

        require(msg.value >= totalCost, "Insufficient funds");

        // Mint the requested Wizards in the guild contract, assigning ownership to the sender
        wizardIds = WIZARD_GUILD.mintWizards(powers, affinities, msg.sender);

        // Enter the new Wizards into the Tournament
        tournament.enterWizards.value(contribution)(wizardIds, powers);

        // Ensure the Wizards are being assigned to an ERC-721 aware address (either an external address,
        // or a smart contract that implements onERC721Received()). We must call onERC721Received() for
        // each token minted because it's allowed for an ERC-721 receiving contract to reject the
        // transfer based on the properties of the token.
        if (isContract(msg.sender)) {
            for (uint256 i = 0; i < wizardIds.length; i++) {
                bytes4 transferAccepted = IERC721Receiver(msg.sender).onERC721Received(msg.sender, address(0), wizardIds[i], "");
                require(transferAccepted == _ERC721_RECEIVED, "Contract owner didn't accept ERC721 transfer");
            }
        }

        // NOTE: _transferRefund() is only safe if msg.value >= totalCost. See the require() near the
        //       beginning of the function to feel better about this fact.
        _transferRefund(totalCost);
    }

    /// @notice Allows for the creation of Exclusive Wizards. This can only be done by the COO, who still has
    ///         to pay for the power imbued in these Wizards! Reverts if the owner address is a smart contract
    ///         that is not ERC-721 aware.
    /// @param wizardIds An array of IDs of the Wizards being conjured.
    /// @param powers The power levels of the Wizards, corresponding 1:1 to Wizard IDs.
    /// @param affinities The elemental affinities of the Wizards, corresponding 1:1 to Wizard IDs.
    ///                   Valid elements are defined in `WizardConstants`, see the constants with
    ///                   names starting `ELEMENT_`. ELEMENT_NOTSET is valid for Exclusive Wizards,
    ///                   unlike regular Wizards.
    /// @param owner The recipient address of the newly conjured Cheeze Wizards.
    function conjureExclusiveMulti(
        uint256[] calldata wizardIds,
        uint256[] calldata powers,
        uint8[] calldata affinities,
        address owner
    )
        external payable onlyCOO
    {
        // Ensure the arrays are all of the same length
        require(wizardIds.length == powers.length && powers.length == affinities.length, "Inconsistent parameter lengths");

        uint256 totalCost = 0;
        uint256 contribution = 0;
        uint88[] memory localPowers = new uint88[](powers.length);

        for (uint256 i = 0; i < powers.length; i++) {
            require(affinities[i] <= MAX_ELEMENT, "Invalid affinity");

            require(powers[i] < (1 << 88), "Invalid power level");
            localPowers[i] = uint88(powers[i]);
            uint256 wizardCost = powerToCost(localPowers[i]);

            totalCost += wizardCost;
            contribution += _potContribution(localPowers[i]);
        }

        require(msg.value >= totalCost, "Insufficient funds");

        // Mint the requested Wizards via the guild contract
        WIZARD_GUILD.mintReservedWizards(wizardIds, localPowers, affinities, owner);

        // Enter the new Wizards into the Tournament
        tournament.enterWizards.value(contribution)(wizardIds, localPowers);

        // Ensure the Wizards are being assigned to an ERC-721 aware address (either an external address,
        // or a smart contract that implements onERC721Received()). We must call onERC721Received for
        // each token minted because it's allowed for an ERC-721 receiving contract to reject the
        // transfer based on the properties of the token.
        if (isContract(owner)) {
            for (uint256 i = 0; i < wizardIds.length; i++) {
                bytes4 transferAccepted = IERC721Receiver(owner).onERC721Received(msg.sender, address(0), wizardIds[i], "");
                require(transferAccepted == _ERC721_RECEIVED, "Contract owner didn't accept ERC721 transfer");
            }
        }

        // NOTE: _transferRefund() is only safe if msg.value >= totalCost. See the require() near the
        //       middle of the function to feel better about this fact.
        _transferRefund(totalCost);
    }

    /// @notice Computes the powers, total cost, and prize pot contribution for an array of new Wizards
    ///         based on the provided affinities. This also checks that the affinity values are valid
    ///         for the Tournament, and updates the elementalWizardCost storage variable as relevant.
    function _computeWizardPowers(uint8[] memory affinities) internal
            returns(uint256 totalCost, uint256 contribution, uint88[] memory powers)
    {
        // Cache the Wizard costs in order to reduce the gas costs from reads and writes to storage.
        uint256 neutralWizardCost = wizardCosts.neutralWizardCost;
        uint256 elementalWizardCost = wizardCosts.elementalWizardCost;
        uint256 elementalWizardIncrement = wizardCosts.elementalWizardIncrement;

        totalCost = 0;
        contribution = 0;
        powers = new uint88[](affinities.length);

        for (uint256 i = 0; i < affinities.length; i++) {
            uint8 affinity = affinities[i];
            uint256 wizardCost;

            require(affinity > ELEMENT_NOTSET && affinity <= MAX_ELEMENT, "Invalid affinity");

            // Determine the price of the Wizard
            if (affinity == ELEMENT_NEUTRAL) {
                wizardCost = neutralWizardCost;
            } else {
                wizardCost = elementalWizardCost;

                // Update the cost of the next Elemental Wizard
                // NOTE: This math can't overflow because the total Ether supply in wei is well less than
                //       2^128. Multiplying a valid cost in wei by some number <100k
                //       cannot possibly overflow 256 bits. As cost is calculated
                //       ourselves (rather than user provided) we know it must
                //       be in the valid range.
                elementalWizardCost += (elementalWizardCost * elementalWizardIncrement) / TENTH_BASIS_POINTS;
            }

            powers[i] = costToPower(wizardCost);

            // IMPORTANT! Mathematically, you'd think we could just compute the pot contribution at the
            // end of the loop, but this risks rounding differences between
            // conjuring Wizards individually compared to conjuring them as a stench.
            contribution += _potContribution(powers[i]);
            totalCost += wizardCost;
        }

        // Update the cached elemental cost to storage. Conveniently this costs very little if
        // the value isn't actually changed.
        wizardCosts.elementalWizardCost = uint96(elementalWizardCost);
    }

    /// @notice Absorbs a number of presale Wizards into the final NFT contract, while also entering them into
    ///         the Tournament. Can handle any number of Wizards in a batch BUT THEY MUST ALL HAVE THE SAME OWNER.
    ///         Callable by anyone.
    /// @param wizardIds The IDs of the presale Wizards; note that all Wizards MUST have the same owner.
    function absorbPresaleWizards(uint256[] calldata wizardIds) external {
        // Bulk fetch the Wizards from the presale contract. Note that this will also delete those Wizards from the
        // presale contract, and will also transfer the funds used to purchase those Wizards to this contract.
        // Obviously, a failed require() statement later in this function will undo that transfer and those deletes.
        (
            address[] memory owners,
             uint256[] memory powers,
             uint8[] memory affinities
        ) = WIZARD_PRESALE.absorbWizardMulti(wizardIds);

        uint256 contribution = 0;
        address theOwner = owners[0];
        uint88[] memory localPowers = new uint88[](powers.length);

        for (uint256 i = 0; i < powers.length; i++) {
            require(owners[i] == theOwner, "All Wizards must have same owner");
            localPowers[i] = uint88(powers[i]);
            contribution += _potContribution(localPowers[i]);
        }

        // Mint the requested Wizards in the guild contract
        WIZARD_GUILD.mintReservedWizards(wizardIds, localPowers, affinities, theOwner);

        // Enter the new Wizards into the Tournament
        tournament.enterWizards.value(contribution)(wizardIds, localPowers);
    }

    /// @notice Revive a tired Wizard so they can duel again. The caller must own
    ///         the Wizard.
    /// @param wizardId The ID of the Wizard to revive.
    function revive(uint256 wizardId) external payable onlyWizardController(wizardId) {
        // We don't need to do any validation here, we can let the Tournament decide
        // if the pot contribution amount derived from msg.value represents a valid
        // power level to use for reviving this Wizard.
        uint88 purchasedPower = costToPower(msg.value);
        uint256 potContributionValue = _potContribution(purchasedPower);

        tournament.revive.value(potContributionValue)(wizardId);
    }

    /// @notice Sets the affinity for a Wizard that doesn't already have its elemental affinity chosen.
    ///         As a rule this is only ever expected to apply to Exclusive Wizards, as regular wizards
    ///         have their affinity set when they are conjured.
    function setAffinity(uint256 wizardId, uint8 newAffinity) external onlyWizardController(wizardId) {
        require(newAffinity > ELEMENT_NOTSET && newAffinity <= MAX_ELEMENT, "Must choose a valid affinity");

        // The guild will enforce the Wizard doesn't already have an affinity set.
        WIZARD_GUILD.setAffinity(wizardId, newAffinity);
    }

    /// @notice Determine the power of a Wizard based on their price.
    /// @param cost The price of the Wizard in wei.
    /// @return The power of the Wizard (cast to uint88).
    function costToPower(uint256 cost) public pure returns (uint88 power) {
        return uint88(cost / MAX_POWER_SCALE);
    }

    /// @param power The power of the Wizard.
    /// @return The cost of the Wizard in wei.
    function powerToCost(uint88 power) public pure returns (uint256 cost) {
        return power * MAX_POWER_SCALE;
    }

    /// @notice Computes the number of wei required to be sent to the Tournament
    ///         in order to match a given power level.
    /// @param wizardPower The power level
    /// @return The prize pot contribution necessary to match the given power
    function _potContribution(uint88 wizardPower) internal view returns (uint256) {
        return wizardPower * tournamentPowerScale;
    }

    /// @notice Allows the CFO to withdraw funds from this contract.
    function withdraw() external onlyCFO {
        // All of the pot contributions go directly into the Tournament contract, so
        // we can safely withdraw everything, with no hold-backs.
        msg.sender.transfer(address(this).balance);
    }


    /// @notice Allows the COO to destroy this contract if it's not needed anymore.
    /// @notice Can't be destoryed if the Tournament still exists.
    function destroy() external onlyCOO {
        require(address(this).balance == 0, "Drain the funds first");
        require(address(tournament) == address(0), "Destroy Tournament first");

        selfdestruct(msg.sender);
    }

    /// @notice Allow the COO to destroy the Tournament contract.
    function destroyTournament() external onlyCOO {
        if (address(tournament) != address(0)) {
            require(tournament.isActive() == false, "Tournament active");
            tournament.destroy();
            tournament = TournamentInterface(0);
        }
    }

    /// @notice Utility function that refunds any overpayment to the sender; smart
    ///      enough to only send the excess if the amount we are returning is more than the
    ///      cost of sending it!
    /// @dev Warning! This does not check for underflows (msg.value < actualPrice) - so
    ///      be sure to call this with correct values!
    /// @param actualPrice The actual price owed for the conjured Wizards.
    function _transferRefund(uint256 actualPrice) private {
        uint256 refund = msg.value - actualPrice;

        // Make sure the amount we're trying to refund is less than the actual cost of sending it!
        // See https://github.com/ethereum/wiki/wiki/Subtleties for magic values costs.  We can
        // safely ignore the 25000 additional gas cost for new accounts, as msg.sender is
        // guaranteed to exist at this point!
        if (refund > (tx.gasprice * (9000+700))) {
            msg.sender.transfer(refund);
        }
    }
}