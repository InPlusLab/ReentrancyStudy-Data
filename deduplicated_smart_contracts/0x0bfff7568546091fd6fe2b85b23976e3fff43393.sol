// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {Governable} from "../lib/Governable.sol";
import {IDistributionLogic} from "./interface/IDistributionLogic.sol";
import {DistributionStorage} from "./DistributionStorage.sol";
import {IBeacon} from "../lib/upgradable/interface/IBeacon.sol";
import {BeaconStorage} from "../lib/upgradable/BeaconStorage.sol";
import {Pausable} from "../lib/Pausable.sol";

/**
 * @title DistributionProxy
 * @author MirrorXYZ
 */
contract DistributionProxy is
    BeaconStorage,
    Governable,
    DistributionStorage,
    Pausable
{
    constructor(
        address beacon_,
        address owner_,
        address team_,
        address token_,
        bytes32 rootNode_,
        address ensRegistry_,
        address treasury_
    )
        BeaconStorage(beacon_)
        Governable(owner_)
        DistributionStorage(rootNode_, ensRegistry_)
        Pausable(true)
    {
        // Initialize the logic, supplying initialization calldata.
        team = team_;
        token = token_;
        treasury = treasury_;
    }

    fallback() external payable {
        address logic = IBeacon(beacon).logic();

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), logic, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {Ownable} from "../lib/Ownable.sol";
import {IGovernable} from "../lib/interface/IGovernable.sol";

contract Governable is Ownable, IGovernable {
    // ============ Mutable Storage ============

    // Mirror governance contract.
    address public override governor;

    // ============ Modifiers ============

    modifier onlyGovernance() {
        require(isOwner() || isGovernor(), "caller is not governance");
        _;
    }

    modifier onlyGovernor() {
        require(isGovernor(), "caller is not governor");
        _;
    }

    // ============ Constructor ============

    constructor(address owner_) Ownable(owner_) {}

    // ============ Administration ============

    function changeGovernor(address governor_) public override onlyGovernance {
        governor = governor_;
    }

    // ============ Utility Functions ============

    function isGovernor() public view override returns (bool) {
        return msg.sender == governor;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IDistributionLogic {
    function version() external returns (uint256);

    function distribute(address tributary, uint256 contribution) external;

    function claim(address claimant) external;

    function claimable(address claimant) external view returns (uint256);

    function increaseAwards(address member, uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {IENS} from "../interface/IENS.sol";
import {IDistributionStorage} from "./interface/IDistributionStorage.sol";

/**
 * @title DistributionStorage
 * @author MirrorXYZ
 */
contract DistributionStorage is IDistributionStorage {
    // ============ Immutable Storage ============

    // The node of the root name (e.g. namehash(mirror.xyz))
    bytes32 public immutable rootNode;
    /**
     * The address of the public ENS registry.
     * @dev Dependency-injectable for testing purposes, but otherwise this is the
     * canonical ENS registry at 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e.
     */
    IENS public immutable ensRegistry;

    // ============ Mutable Storage ============

    // The address for Mirror team and investors.
    address team;
    // The address of the governance token that this contract is allowed to mint.
    address token;
    // The address that is allowed to distribute.
    address treasury;
    // The amount that has been contributed to the treasury.
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public awards;
    // The number of rewards that are created per 1 ETH contribution to the treasury.
    uint256 contributionsFactor = 1000;
    // The amount that has been claimed per address.
    mapping(address => uint256) public claimed;
    // The block number that an address last claimed
    mapping(address => uint256) public lastClaimed;
    // The block number that an address registered
    mapping(address => uint256) public override registered;
    // Banned accounts
    mapping(address => bool) public banned;
    // The percentage of tokens issued that are taken by the Mirror team.
    uint256 teamRatio = 40;
    uint256 public registrationReward = 100 * 1e18;
    uint256 public registeredMembers;

    struct DistributionEpoch {
        uint256 startBlock;
        uint256 claimablePerBlock;
    }

    DistributionEpoch[] public epochs;
    uint256 numEpochs = 0;

    constructor(bytes32 rootNode_, address ensRegistry_) {
        rootNode = rootNode_;
        ensRegistry = IENS(ensRegistry_);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IBeacon {
    /// @notice Logic for this contract.
    function logic() external view returns (address);

    /// @notice Emitted when the logic is updated.
    event Update(address oldLogic, address newLogic);

    /// @notice Updates logic address.
    function update(address newLogic) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

contract BeaconStorage {
    /// @notice Holds the address of the upgrade beacon
    address internal immutable beacon;

    constructor(address beacon_) {
        beacon = beacon_;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IPausable {
    /// @notice Emitted when the pause is triggered by `account`.
    event Paused(address account);

    /// @notice Emitted when the pause is lifted by `account`.
    event Unpaused(address account);

    function paused() external returns (bool);
}

contract Pausable is IPausable {
    bool public override paused;

    // Modifiers

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    /// @notice Initializes the contract in unpaused state.
    constructor(bool paused_) {
        paused = paused_;
    }

    // ============ Internal Functions ============

    function _pause() internal whenNotPaused {
        paused = true;

        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        paused = false;

        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

contract Ownable {
    address public owner;
    address private nextOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // modifiers

    modifier onlyOwner() {
        require(isOwner(), "caller is not the owner.");
        _;
    }

    modifier onlyNextOwner() {
        require(isNextOwner(), "current owner must set caller as next owner.");
        _;
    }

    /**
     * @dev Initialize contract by setting transaction submitter as initial owner.
     */
    constructor(address owner_) {
        owner = owner_;
        emit OwnershipTransferred(address(0), owner);
    }

    /**
     * @dev Initiate ownership transfer by setting nextOwner.
     */
    function transferOwnership(address nextOwner_) external onlyOwner {
        require(nextOwner_ != address(0), "Next owner is the zero address.");

        nextOwner = nextOwner_;
    }

    /**
     * @dev Cancel ownership transfer by deleting nextOwner.
     */
    function cancelOwnershipTransfer() external onlyOwner {
        delete nextOwner;
    }

    /**
     * @dev Accepts ownership transfer by setting owner.
     */
    function acceptOwnership() external onlyNextOwner {
        delete nextOwner;

        owner = msg.sender;

        emit OwnershipTransferred(owner, msg.sender);
    }

    /**
     * @dev Renounce ownership by setting owner to zero address.
     */
    function renounceOwnership() external onlyOwner {
        owner = address(0);

        emit OwnershipTransferred(owner, address(0));
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * @dev Returns true if the caller is the next owner.
     */
    function isNextOwner() public view returns (bool) {
        return msg.sender == nextOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IGovernable {
    function changeGovernor(address governor_) external;

    function isGovernor() external view returns (bool);

    function governor() external view returns (address);
}

//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IENS {
    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);

    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IDistributionStorage {
    function registered(address claimant) external view returns (uint256);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 2000
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}