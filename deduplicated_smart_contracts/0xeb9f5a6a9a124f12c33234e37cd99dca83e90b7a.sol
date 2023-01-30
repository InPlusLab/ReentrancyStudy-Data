/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

// File: contracts/governance/dmg/SafeBitMath.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

library SafeBitMath {

    function safe64(uint n, string memory errorMessage) internal pure returns (uint64) {
        require(n < 2 ** 64, errorMessage);
        return uint64(n);
    }

    function safe128(uint n, string memory errorMessage) internal pure returns (uint128) {
        require(n < 2 ** 128, errorMessage);
        return uint128(n);
    }

    function add128(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        return add128(a, b, "");
    }

    function sub128(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
        return sub128(a, b, "");
    }

}

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/protocol/interfaces/IOwnableOrGuardian.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


/**
 * NOTE:    THE STATE VARIABLES IN THIS CONTRACT CANNOT CHANGE NAME OR POSITION BECAUSE THIS CONTRACT IS USED IN
 *          UPGRADEABLE CONTRACTS.
 */
contract IOwnableOrGuardian is Initializable {

    // *************************
    // ***** Events
    // *************************

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianTransferred(address indexed previousGuardian, address indexed newGuardian);

    // *************************
    // ***** Modifiers
    // *************************

    modifier onlyOwnerOrGuardian {
        require(
            msg.sender == _owner || msg.sender == _guardian,
            "OwnableOrGuardian: UNAUTHORIZED_OWNER_OR_GUARDIAN"
        );
        _;
    }

    modifier onlyOwner {
        require(
            msg.sender == _owner,
            "OwnableOrGuardian: UNAUTHORIZED"
        );
        _;
    }
    // *********************************************
    // ***** State Variables DO NOT CHANGE OR MOVE
    // *********************************************

    // ******************************
    // ***** DO NOT CHANGE OR MOVE
    // ******************************
    address internal _owner;
    address internal _guardian;
    // ******************************
    // ***** DO NOT CHANGE OR MOVE
    // ******************************

    // ******************************
    // ***** Misc Functions
    // ******************************

    function owner() external view returns (address) {
        return _owner;
    }

    function guardian() external view returns (address) {
        return _guardian;
    }

    // ******************************
    // ***** Admin Functions
    // ******************************

    function initialize(
        address __owner,
        address __guardian
    )
    public
    initializer {
        _transferOwnership(__owner);
        _transferGuardian(__guardian);
    }

    function transferOwnership(
        address __owner
    )
    public
    onlyOwner {
        require(
            __owner != address(0),
            "OwnableOrGuardian::transferOwnership: INVALID_OWNER"
        );
        _transferOwnership(__owner);
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferGuardian(
        address __guardian
    )
    public
    onlyOwner {
        require(
            __guardian != address(0),
            "OwnableOrGuardian::transferGuardian: INVALID_OWNER"
        );
        _transferGuardian(__guardian);
    }

    function renounceGuardian() public onlyOwnerOrGuardian {
        _transferGuardian(address(0));
    }

    // ******************************
    // ***** Internal Functions
    // ******************************

    function _transferOwnership(
        address __owner
    )
    internal {
        address previousOwner = _owner;
        _owner = __owner;
        emit OwnershipTransferred(previousOwner, __owner);
    }

    function _transferGuardian(
        address __guardian
    )
    internal {
        address previousGuardian = _guardian;
        _guardian = __guardian;
        emit GuardianTransferred(previousGuardian, __guardian);
    }

}

// File: contracts/governance/dmg/IDMGToken.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.13;

interface IDMGToken {

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    // *************************
    // ***** Functions
    // *************************

    function getPriorVotes(address account, uint blockNumber) external view returns (uint128);

    function getCurrentVotes(address account) external view returns (uint128);

    function delegates(address delegator) external view returns (address);

    function burn(uint amount) external returns (bool);

    function approveBySig(
        address spender,
        uint rawAmount,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

// File: contracts/external/asset_introducers/AssetIntroducerData.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;




contract AssetIntroducerData is Initializable, IOwnableOrGuardian {

    // *************************
    // ***** Constants
    // *************************

    // *************************
    // ***** V1 State Variables
    // *************************

    /// For preventing reentrancy attacks
    uint64 internal _guardCounter;

    AssetIntroducerStateV1 internal _assetIntroducerStateV1;

    ERC721StateV1 internal _erc721StateV1;

    VoteStateV1 internal _voteStateV1;

    // *************************
    // ***** Data Structures
    // *************************

    enum AssetIntroducerType {
        PRINCIPAL, AFFILIATE
    }

    struct AssetIntroducerStateV1 {
        /// The timestamp at which this contract was initialized
        uint64 initTimestamp;

        /// True if the DMM Foundation purchased its token for the bootstrapped pool, false otherwise.
        bool isDmmFoundationSetup;

        /// Total amount of DMG locked in this contract
        uint128 totalDmgLocked;

        /// For calculating the results of off-chain signature requests
        bytes32 domainSeparator;

        /// Address of the DMG token
        address dmg;

        /// Address of the DMM Controller
        address dmmController;

        /// Address of the DMM token valuator, which gets the USD value of a token
        address underlyingTokenValuator;

        /// Address of the implementation for the discount
        address assetIntroducerDiscount;

        /// Address of the implementation for the staking purchaser contract. Used to buy NFTs at a steep discount by
        /// staking mTokens.
        address stakingPurchaser;

        /// Mapping from NFT ID to the asset introducer struct.
        mapping(uint => AssetIntroducer) idToAssetIntroducer;

        /// Mapping from country code to asset introducer type to token IDs
        mapping(bytes3 => mapping(uint8 => uint[])) countryCodeToAssetIntroducerTypeToTokenIdsMap;

        /// A mapping from the country code to asset introducer type to the cost needed to buy one. The cost is represented
        /// in USD (with 18 decimals) and is purchased using DMG, so a conversion is needed using Chainlink.
        mapping(bytes3 => mapping(uint8 => uint96)) countryCodeToAssetIntroducerTypeToPriceUsd;

        /// The dollar amount that has actually been deployed by the asset introducer
        mapping(uint => mapping(address => uint)) tokenIdToUnderlyingTokenToWithdrawnAmount;

        /// Mapping for the count of each user's off-chain signed messages. 0-indexed.
        mapping(address => uint) ownerToNonceMap;
    }

    struct ERC721StateV1 {
        /// Total number of NFTs created
        uint64 totalSupply;

        /// The proxy address created by OpenSea, which is used to enable a smoother trading experience
        address openSeaProxyRegistry;

        /// The last token ID in the linked list.
        uint lastTokenId;

        /// The base URI for getting NFT information by token ID.
        string baseURI;

        /// Mapping of all token IDs. Works as a linked list such that previous key --> next value. The 0th key in the
        /// list is LINKED_LIST_GUARD.
        mapping(uint => uint) allTokens;

        /// Mapping from NFT ID to owner address.
        mapping(uint256 => address) idToOwnerMap;

        /// Mapping from NFT ID to approved address.
        mapping(uint256 => address) idToSpenderMap;

        /// Mapping from owner to an operator that can spend all of owner's NFTs.
        mapping(address => mapping(address => bool)) ownerToOperatorToIsApprovedMap;

        /// Mapping from owner address to all owned token IDs. Works as a linked list such that previous key --> next value.
        /// The 0th key in the list is LINKED_LIST_GUARD.
        mapping(address => mapping(uint => uint)) ownerToTokenIds;

        /// Mapping from owner address to a count of all owned NFTs.
        mapping(address => uint32) ownerToTokenCount;

        /// Mapping from an interface to whether or not it's supported.
        mapping(bytes4 => bool) interfaceIdToIsSupportedMap;
    }

    /// Used for storing information about voting
    struct VoteStateV1 {
        /// Taken from the DMG token implementation
        mapping(address => mapping(uint64 => Checkpoint)) ownerToCheckpointIndexToCheckpointMap;
        /// Taken from the DMG token implementation
        mapping(address => uint64) ownerToCheckpointCountMap;
    }

    /// Tightly-packed, this data structure is 2 slots; 64 bytes
    struct AssetIntroducer {
        bytes3 countryCode;
        AssetIntroducerType introducerType;
        /// True if the asset introducer has been purchased yet, false if it hasn't and is thus
        bool isOnSecondaryMarket;
        /// True if the asset introducer can withdraw tokens from mToken deposits, false if it cannot yet. This value
        /// must only be changed to `true` via governance vote
        bool isAllowedToWithdrawFunds;
        /// 1-based index at which the asset introducer was created. Used for optics
        uint16 serialNumber;
        uint96 dmgLocked;
        /// How much this asset introducer can manage
        uint96 dollarAmountToManage;
        uint tokenId;
    }

    /// Used for tracking delegation and number of votes each user has at a given block height.
    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    /// Used to prevent the "stack too deep" error and make code more readable
    struct DmgApprovalStruct {
        address spender;
        uint rawAmount;
        uint nonce;
        uint expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct DiscountStruct {
        uint64 initTimestamp;
    }

    // *************************
    // ***** Modifiers
    // *************************

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;

        _;

        require(
            localCounter == _guardCounter,
            "AssetIntroducerData: REENTRANCY"
        );
    }

    /// Enforces that an NFT has NOT been sold to a user yet
    modifier requireIsPrimaryMarketNft(uint __tokenId) {
        require(
            !_assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_SECONDARY_MARKET"
        );

        _;
    }

    /// Enforces that an NFT has been sold to a user
    modifier requireIsSecondaryMarketNft(uint __tokenId) {
        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_PRIMARY_MARKET"
        );

        _;
    }

    modifier requireIsValidNft(uint __tokenId) {
        require(
            _erc721StateV1.idToOwnerMap[__tokenId] != address(0),
            "AssetIntroducerData: INVALID_NFT"
        );

        _;
    }

    modifier requireIsNftOwner(uint __tokenId) {
        require(
            _erc721StateV1.idToOwnerMap[__tokenId] == msg.sender,
            "AssetIntroducerData: INVALID_NFT_OWNER"
        );

        _;
    }

    modifier requireCanWithdrawFunds(uint __tokenId) {
        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isAllowedToWithdrawFunds,
            "AssetIntroducerData: NFT_NOT_ACTIVATED"
        );

        _;
    }

    modifier requireIsStakingPurchaser() {
        require(
            _assetIntroducerStateV1.stakingPurchaser != address(0),
            "AssetIntroducerData: STAKING_PURCHASER_NOT_SETUP"
        );

        require(
            _assetIntroducerStateV1.stakingPurchaser == msg.sender,
            "AssetIntroducerData: INVALID_SENDER_FOR_STAKING"
        );
        _;
    }

}

// File: contracts/external/asset_introducers/impl/AssetIntroducerVotingLib.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;



library AssetIntroducerVotingLib {

    // *************************
    // ***** Events
    // *************************

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    // *************************
    // ***** Functions
    // *************************

    function getCurrentVotes(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __owner
    ) public view returns (uint) {
        uint64 checkpointCount = __state.ownerToCheckpointCountMap[__owner];
        return checkpointCount > 0 ? __state.ownerToCheckpointIndexToCheckpointMap[__owner][checkpointCount - 1].votes : 0;
    }

    function getPriorVotes(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __owner,
        uint __blockNumber
    ) public view returns (uint128) {
        require(
            __blockNumber < block.number,
            "AssetIntroducerVotingLib::getPriorVotes: not yet determined"
        );

        uint64 checkpointCount = __state.ownerToCheckpointCountMap[__owner];
        if (checkpointCount == 0) {
            return 0;
        }

        // First check most recent balance
        if (__state.ownerToCheckpointIndexToCheckpointMap[__owner][checkpointCount - 1].fromBlock <= __blockNumber) {
            return __state.ownerToCheckpointIndexToCheckpointMap[__owner][checkpointCount - 1].votes;
        }

        // Next check implicit zero balance
        if (__state.ownerToCheckpointIndexToCheckpointMap[__owner][0].fromBlock > __blockNumber) {
            return 0;
        }

        uint64 lower = 0;
        uint64 upper = checkpointCount - 1;
        while (upper > lower) {
            // ceil, avoiding overflow
            uint64 center = upper - (upper - lower) / 2;
            AssetIntroducerData.Checkpoint memory checkpoint = __state.ownerToCheckpointIndexToCheckpointMap[__owner][center];
            if (checkpoint.fromBlock == __blockNumber) {
                return checkpoint.votes;
            } else if (checkpoint.fromBlock < __blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return __state.ownerToCheckpointIndexToCheckpointMap[__owner][lower].votes;
    }

    function moveDelegates(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __fromOwner,
        address __toOwner,
        uint128 __amount
    ) public {
        if (__fromOwner != __toOwner && __amount > 0) {
            if (__fromOwner != address(0)) {
                uint64 fromCheckpointCount = __state.ownerToCheckpointCountMap[__fromOwner];
                uint128 fromVotesOld = fromCheckpointCount > 0 ? __state.ownerToCheckpointIndexToCheckpointMap[__fromOwner][fromCheckpointCount - 1].votes : 0;
                uint128 fromVotesNew = SafeBitMath.sub128(
                    fromVotesOld,
                    __amount,
                    "AssetIntroducerVotingLib::moveDelegates: VOTE_UNDERFLOW"
                );
                _writeCheckpoint(__state, __fromOwner, fromCheckpointCount, fromVotesOld, fromVotesNew);
            }

            if (__toOwner != address(0)) {
                uint64 toCheckpointCount = __state.ownerToCheckpointCountMap[__toOwner];
                uint128 toVotesOld = toCheckpointCount > 0 ? __state.ownerToCheckpointIndexToCheckpointMap[__toOwner][toCheckpointCount - 1].votes : 0;
                uint128 toVotesNew = SafeBitMath.add128(
                    toVotesOld,
                    __amount,
                    "AssetIntroducerVotingLib::moveDelegates: VOTE_OVERFLOW"
                );
                _writeCheckpoint(__state, __toOwner, toCheckpointCount, toVotesOld, toVotesNew);
            }
        }
    }


    function _writeCheckpoint(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __owner,
        uint64 __checkpointCount,
        uint128 __oldVotes,
        uint128 __newVotes
    ) internal {
        uint64 blockNumber = SafeBitMath.safe64(
            block.number,
            "AssetIntroducerVotingLib::_writeCheckpoint: INVALID_BLOCK_NUMBER"
        );

        if (__checkpointCount > 0 && __state.ownerToCheckpointIndexToCheckpointMap[__owner][__checkpointCount - 1].fromBlock == blockNumber) {
            __state.ownerToCheckpointIndexToCheckpointMap[__owner][__checkpointCount - 1].votes = __newVotes;
        } else {
            __state.ownerToCheckpointIndexToCheckpointMap[__owner][__checkpointCount] = AssetIntroducerData.Checkpoint(blockNumber, __newVotes);
            __state.ownerToCheckpointCountMap[__owner] = __checkpointCount + 1;
        }

        emit DelegateVotesChanged(__owner, __oldVotes, __newVotes);
    }

}