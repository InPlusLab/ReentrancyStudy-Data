// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "../interfaces/IControllable.sol";

abstract contract Controllable is IControllable {
    mapping(address => bool) _controllers;

    /**
     * @dev Throws if called by any account not in authorized list
     */
    modifier onlyController() {
        require(
            _controllers[msg.sender] == true || address(this) == msg.sender,
            "Controllable: caller is not a controller"
        );
        _;
    }

    /**
     * @dev Add an address allowed to control this contract
     */
    function _addController(address _controller) internal {
        _controllers[_controller] = true;
    }

    /**
     * @dev Add an address allowed to control this contract
     */
    function addController(address _controller) external override onlyController {
        _controllers[_controller] = true;
    }

    /**
     * @dev Check if this address is a controller
     */
    function isController(address _address) external view override returns (bool allowed) {
        allowed = _controllers[_address];
    }

    /**
     * @dev Check if this address is a controller
     */
    function relinquishControl() external view override onlyController {
        _controllers[msg.sender];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "../access/Controllable.sol";
import "../pool/NFTGemPool.sol";
import "../libs/Create2.sol";
import "../interfaces/INFTGemPoolFactory.sol";

contract NFTGemPoolFactory is Controllable, INFTGemPoolFactory {
    address private operator;

    mapping(uint256 => address) private _getNFTGemPool;
    address[] private _allNFTGemPools;

    constructor() {
        _addController(msg.sender);
    }

    /**
     * @dev get the quantized token for this
     */
    function getNFTGemPool(uint256 _symbolHash) external view override returns (address gemPool) {
        gemPool = _getNFTGemPool[_symbolHash];
    }

    /**
     * @dev get the quantized token for this
     */
    function allNFTGemPools(uint256 idx) external view override returns (address gemPool) {
        gemPool = _allNFTGemPools[idx];
    }

    /**
     * @dev number of quantized addresses
     */
    function allNFTGemPoolsLength() external view override returns (uint256) {
        return _allNFTGemPools.length;
    }

    /**
     * @dev deploy a new erc20 token using create2
     */
    function createNFTGemPool(
        string memory gemSymbol,
        string memory gemName,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxMint,
        address allowedToken
    ) external override onlyController returns (address payable gemPool) {
        bytes32 salt = keccak256(abi.encodePacked(gemSymbol));
        require(_getNFTGemPool[uint256(salt)] == address(0), "GEMPOOL_EXISTS"); // single check is sufficient

        // validation checks to make sure values are sane
        require(ethPrice != 0, "INVALID_PRICE");
        require(minTime != 0, "INVALID_MIN_TIME");
        require(diffstep != 0, "INVALID_DIFFICULTY_STEP");

        // create the quantized erc20 token using create2, which lets us determine the
        // quantized erc20 address of a token without interacting with the contract itself
        bytes memory bytecode = type(NFTGemPool).creationCode;

        // use create2 to deploy the quantized erc20 contract
        gemPool = payable(Create2.deploy(0, salt, bytecode));

        // initialize the erc20 contract with the relevant addresses which it proxies
        NFTGemPool(gemPool).initialize(gemSymbol, gemName, ethPrice, minTime, maxTime, diffstep, maxMint, allowedToken);

        // insert the erc20 contract address into lists - one that maps source to quantized,
        _getNFTGemPool[uint256(salt)] = gemPool;
        _allNFTGemPools.push(gemPool);

        // emit an event about the new pool being created
        emit NFTGemPoolCreated(gemSymbol, gemName, ethPrice, minTime, maxTime, diffstep, maxMint, allowedToken);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface IControllable {
    event ControllerAdded(address indexed contractAddress, address indexed controllerAddress);
    event ControllerRemoved(address indexed contractAddress, address indexed controllerAddress);

    function addController(address controller) external;

    function isController(address controller) external view returns (bool);

    function relinquishControl() external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface INFTGemFeeManager {

    event DefaultFeeDivisorChanged(address indexed operator, uint256 oldValue, uint256 value);
    event FeeDivisorChanged(address indexed operator, address indexed token, uint256 oldValue, uint256 value);
    event ETHReceived(address indexed manager, address sender, uint256 value);
    event LiquidityChanged(address indexed manager, uint256 oldValue, uint256 value);

    function liquidity(address token) external view returns (uint256);

    function defaultLiquidity() external view returns (uint256);

    function setDefaultLiquidity(uint256 _liquidityMult) external returns (uint256);

    function feeDivisor(address token) external view returns (uint256);

    function defaultFeeDivisor() external view returns (uint256);

    function setFeeDivisor(address token, uint256 _feeDivisor) external returns (uint256);

    function setDefaultFeeDivisor(uint256 _feeDivisor) external returns (uint256);

    function ethBalanceOf() external view returns (uint256);

    function balanceOF(address token) external view returns (uint256);

    function transferEth(address payable recipient, uint256 amount) external;

    function transferToken(
        address token,
        address recipient,
        uint256 amount
    ) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface INFTGemGovernor {
    event GovernanceTokenIssued(address indexed receiver, uint256 amount);
    event FeeUpdated(address indexed proposal, address indexed token, uint256 newFee);
    event AllowList(address indexed proposal, address indexed token, bool isBanned);
    event ProjectFunded(address indexed proposal, address indexed receiver, uint256 received);
    event StakingPoolCreated(
        address indexed proposal,
        address indexed pool,
        string symbol,
        string name,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffStep,
        uint256 maxClaims,
        address alllowedToken
    );

    function initialize(
        address _multitoken,
        address _factory,
        address _feeTracker,
        address _proposalFactory,
        address _swapHelper
    ) external;

    function createProposalVoteTokens(uint256 proposalHash) external;

    function destroyProposalVoteTokens(uint256 proposalHash) external;

    function executeProposal(address propAddress) external;

    function issueInitialGovernanceTokens(address receiver) external returns (uint256);

    function maybeIssueGovernanceToken(address receiver) external returns (uint256);

    function issueFuelToken(address receiver, uint256 amount) external returns (uint256);

    function createPool(
        string memory symbol,
        string memory name,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxClaims,
        address allowedToken
    ) external returns (address);

    function createSystemPool(
        string memory symbol,
        string memory name,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxClaims,
        address allowedToken
    ) external returns (address);

    function createNewPoolProposal(
        address,
        string memory,
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address
    ) external returns (address);

    function createChangeFeeProposal(
        address,
        string memory,
        address,
        address,
        uint256
    ) external returns (address);

    function createFundProjectProposal(
        address,
        string memory,
        address,
        string memory,
        uint256
    ) external returns (address);

    function createUpdateAllowlistProposal(
        address,
        string memory,
        address,
        address,
        bool
    ) external returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface INFTGemMultiToken {
    // called by controller to mint a claim or a gem
    function mint(
        address account,
        uint256 tokenHash,
        uint256 amount
    ) external;

    // called by controller to burn a claim
    function burn(
        address account,
        uint256 tokenHash,
        uint256 amount
    ) external;

    function allHeldTokens(address holder, uint256 _idx) external view returns (uint256);

    function allHeldTokensLength(address holder) external view returns (uint256);

    function allTokenHolders(uint256 _token, uint256 _idx) external view returns (address);

    function allTokenHoldersLength(uint256 _token) external view returns (uint256);

    function totalBalances(uint256 _id) external view returns (uint256);

    function allProxyRegistries(uint256 _idx) external view returns (address);

    function allProxyRegistriesLength() external view returns (uint256);

    function addProxyRegistry(address registry) external;

    function removeProxyRegistryAt(uint256 index) external;

    function getRegistryManager() external view returns (address);

    function setRegistryManager(address newManager) external;

    function lock(uint256 token, uint256 timeframe) external;

    function unlockTime(address account, uint256 token) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface for a Bitgem staking pool
 */
interface INFTGemPool {

    /**
     * @dev Event generated when an NFT claim is created using ETH
     */
    event NFTGemClaimCreated(address account, address pool, uint256 claimHash, uint256 length, uint256 quantity, uint256 amountPaid);

    /**
     * @dev Event generated when an NFT claim is created using ERC20 tokens
     */
    event NFTGemERC20ClaimCreated(
        address account,
        address pool,
        uint256 claimHash,
        uint256 length,
        address token,
        uint256 quantity,
        uint256 conversionRate
    );

    /**
     * @dev Event generated when an NFT claim is redeemed
     */
    event NFTGemClaimRedeemed(
        address account,
        address pool,
        uint256 claimHash,
        uint256 amountPaid,
        uint256 feeAssessed
    );

    /**
     * @dev Event generated when an NFT claim is redeemed
     */
    event NFTGemERC20ClaimRedeemed(
        address account,
        address pool,
        uint256 claimHash,
        address token,
        uint256 ethPrice,
        uint256 tokenAmount,
        uint256 feeAssessed
    );

    /**
     * @dev Event generated when a gem is created
     */
    event NFTGemCreated(address account, address pool, uint256 claimHash, uint256 gemHash, uint256 quantity);

    function setMultiToken(address token) external;

    function setGovernor(address addr) external;

    function setFeeTracker(address addr) external;

    function setSwapHelper(address addr) external;

    function mintGenesisGems(address creator, address funder) external;

    function createClaim(uint256 timeframe) external payable;

    function createClaims(uint256 timeframe, uint256 count) external payable;

    function createERC20Claim(address erc20token, uint256 tokenAmount) external;

    function createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) external;

    function collectClaim(uint256 claimHash) external;

    function initialize(
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface INFTGemPoolData {

    // pool is inited with these parameters. Once inited, all
    // but ethPrice are immutable. ethPrice only increases. ONLY UP
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function ethPrice() external view returns (uint256);
    function minTime() external view returns (uint256);
    function maxTime() external view returns (uint256);
    function difficultyStep() external view returns (uint256);
    function maxClaims() external view returns (uint256);

    // these describe the pools created contents over time. This is where
    // you query to get information about a token that a pool created
    function claimedCount() external view returns (uint256);
    function claimAmount(uint256 claimId) external view returns (uint256);
    function claimQuantity(uint256 claimId) external view returns (uint256);
    function mintedCount() external view returns (uint256);
    function totalStakedEth() external view returns (uint256);
    function tokenId(uint256 tokenHash) external view returns (uint256);
    function tokenType(uint256 tokenHash) external view returns (uint8);
    function allTokenHashesLength() external view returns (uint256);
    function allTokenHashes(uint256 ndx) external view returns (uint256);
    function nextClaimHash() external view returns (uint256);
    function nextGemHash() external view returns (uint256);
    function nextGemId() external view returns (uint256);
    function nextClaimId() external view returns (uint256);

    function claimUnlockTime(uint256 claimId) external view returns (uint256);
    function claimTokenAmount(uint256 claimId) external view returns (uint256);
    function stakedToken(uint256 claimId) external view returns (address);

    function allowedTokensLength() external view returns (uint256);
    function allowedTokens(uint256 idx) external view returns (address);
    function isTokenAllowed(address token) external view returns (bool);
    function addAllowedToken(address token) external;
    function removeAllowedToken(address token) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface for a Bitgem staking pool
 */
interface INFTGemPoolFactory {
    /**
     * @dev emitted when a new gem pool has been added to the system
     */
    event NFTGemPoolCreated(
        string gemSymbol,
        string gemName,
        uint256 ethPrice,
        uint256 mintTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxMint,
        address allowedToken
    );

    function getNFTGemPool(uint256 _symbolHash) external view returns (address);

    function allNFTGemPools(uint256 idx) external view returns (address);

    function allNFTGemPoolsLength() external view returns (uint256);

    function createNFTGemPool(
        string memory gemSymbol,
        string memory gemName,
        uint256 ethPrice,
        uint256 minTime,
        uint256 maxTime,
        uint256 diffstep,
        uint256 maxMint,
        address allowedToken
    ) external returns (address payable);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface ISwapQueryHelper {

    function coinQuote(address token, uint256 tokenAmount)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function factory() external pure returns (address);

    function COIN() external pure returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function hasPool(address token) external view returns (bool);

    function getReserves(
        address pair
    ) external view returns (uint256, uint256);

    function pairFor(
        address tokenA,
        address tokenB
    ) external pure returns (address);

    function getPathForCoinToToken(address token) external pure returns (address[] memory);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        // solhint-disable-next-line no-inline-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "../utils/Initializable.sol";
import "../interfaces/INFTGemMultiToken.sol";
import "../interfaces/INFTGemFeeManager.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC1155.sol";
import "../interfaces/INFTGemPool.sol";
import "../interfaces/INFTGemGovernor.sol";
import "../interfaces/ISwapQueryHelper.sol";

import "../libs/SafeMath.sol";
import "./NFTGemPoolData.sol";

contract NFTGemPool is Initializable, NFTGemPoolData, INFTGemPool {
    using SafeMath for uint256;

    // governor and multitoken target
    address private _multitoken;
    address private _governor;
    address private _feeTracker;
    address private _swapHelper;

    /**
     * @dev initializer called when contract is deployed
     */
    function initialize (
        string memory __symbol,
        string memory __name,
        uint256 __ethPrice,
        uint256 __minTime,
        uint256 __maxTime,
        uint256 __diffstep,
        uint256 __maxClaims,
        address __allowedToken
    ) external override initializer {
        _symbol = __symbol;
        _name = __name;
        _ethPrice = __ethPrice;
        _minTime = __minTime;
        _maxTime = __maxTime;
        _diffstep = __diffstep;
        _maxClaims = __maxClaims;

        if(__allowedToken != address(0)) {
            _allowedTokens.push(__allowedToken);
            _isAllowedMap[__allowedToken] = true;
        }
    }

    /**
     * @dev set the governor. pool uses the governor to issue gov token issuance requests
     */
    function setGovernor(address addr) external override {
        require(_governor == address(0), "IMMUTABLE");
        _governor = addr;
    }

    /**
     * @dev set the governor. pool uses the governor to issue gov token issuance requests
     */
    function setFeeTracker(address addr) external override {
        require(_feeTracker == address(0), "IMMUTABLE");
        _feeTracker = addr;
    }

    /**
     * @dev set the multitoken that this pool will mint new tokens on. Must be a controller of the multitoken
     */
    function setMultiToken(address token) external override {
        require(_multitoken == address(0), "IMMUTABLE");
        _multitoken = token;
    }

    /**
     * @dev set the multitoken that this pool will mint new tokens on. Must be a controller of the multitoken
     */
    function setSwapHelper(address helper) external override {
        require(_swapHelper == address(0), "IMMUTABLE");
        _swapHelper = helper;
    }

    /**
     * @dev mint the genesis gems earned by the pools creator and funder
     */
    function mintGenesisGems(address creator, address funder) external override {
        require(_multitoken != address(0), "NO_MULTITOKEN");
        require(creator != address(0) && funder != address(0), "ZERO_DESTINATION");
        require(_nextGemId == 0, "ALREADY_MINTED");

        uint256 gemHash = _nextGemHash();
        INFTGemMultiToken(_multitoken).mint(creator, gemHash, 1);
        _addToken(gemHash, 2);

        gemHash = _nextGemHash();
        INFTGemMultiToken(_multitoken).mint(creator, gemHash, 1);
        _addToken(gemHash, 2);
    }

    /**
     * @dev the external version of the above
     */
    function createClaim(uint256 timeframe) external payable override {
        _createClaim(timeframe);
    }

    /**
     * @dev the external version of the above
     */
    function createClaims(uint256 timeframe, uint256 count) external payable override {
        _createClaims(timeframe, count);
    }

    /**
     * @dev create a claim using a erc20 token
     */
    function createERC20Claim(address erc20token, uint256 tokenAmount) external override {
        _createERC20Claim(erc20token, tokenAmount);
    }

    /**
     * @dev create a claim using a erc20 token
     */
    function createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) external override {
        _createERC20Claims(erc20token, tokenAmount, count);
    }


    /**
     * @dev default receive. tries to issue a claim given the received ETH or
     */
    receive() external payable {
        uint256 incomingEth = msg.value;

        // compute the mimimum cost of a claim and revert if not enough sent
        uint256 minClaimCost = _ethPrice.div(_maxTime).mul(_minTime);
        require(incomingEth >= minClaimCost, "INSUFFICIENT_ETH");

        // compute the minimum actual claim time
        uint256 actualClaimTime = _minTime;

        // refund ETH above max claim cost
        if (incomingEth <= _ethPrice)  {
            actualClaimTime = _ethPrice.div(incomingEth).mul(_minTime);
        }

        // create the claim using minimum possible claim time
        _createClaim(actualClaimTime);
    }

    /**
     * @dev attempt to create a claim using the given timeframe
     */
    function _createClaim(uint256 timeframe) internal {
        // minimum timeframe
        require(timeframe >= _minTime, "TIMEFRAME_TOO_SHORT");

        // maximum timeframe
        require((_maxTime != 0 && timeframe <= _maxTime) || _maxTime == 0, "TIMEFRAME_TOO_LONG");

        // cost given this timeframe
        uint256 cost = _ethPrice.mul(_minTime).div(timeframe);
        require(msg.value > cost, "INSUFFICIENT_ETH");

        // get the nest claim hash, revert if no more claims
        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        // mint the new claim to the caller's address
        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        // record the claim unlock time and cost paid for this claim
        uint256 _claimUnlockTime = block.timestamp.add(timeframe);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = cost;
        claimQuant[claimHash] = 1;

        // increase the staked eth balance
        _totalStakedEth = _totalStakedEth.add(cost);

        // maybe mint a governance token for the claimant
        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, cost);

        emit NFTGemClaimCreated(msg.sender, address(this), claimHash, timeframe, 1, cost);

        if (msg.value > cost) {
            (bool success, ) = payable(msg.sender).call{value: msg.value.sub(cost)}("");
            require(success, "REFUND_FAILED");
        }
    }

    /**
     * @dev attempt to create a claim using the given timeframe
     */
    function _createClaims(uint256 timeframe, uint256 count) internal {
        // minimum timeframe
        require(timeframe >= _minTime, "TIMEFRAME_TOO_SHORT");
        // no ETH
        require(msg.value != 0, "ZERO_BALANCE");
        // zero qty
        require(count != 0, "ZERO_QUANTITY");
        // maximum timeframe
        require((_maxTime != 0 && timeframe <= _maxTime) || _maxTime == 0, "TIMEFRAME_TOO_LONG");

        uint256 adjustedBalance = msg.value.div(count);
        // cost given this timeframe

        uint256 cost = _ethPrice.mul(_minTime).div(timeframe);
        require(adjustedBalance >= cost, "INSUFFICIENT_ETH");

        // get the nest claim hash, revert if no more claims
        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        // mint the new claim to the caller's address
        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        // record the claim unlock time and cost paid for this claim
        uint256 _claimUnlockTime = block.timestamp.add(timeframe);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = cost.mul(count);
        claimQuant[claimHash] = count;

        // maybe mint a governance token for the claimant
        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, cost);

        emit NFTGemClaimCreated(msg.sender, address(this), claimHash, timeframe, count, cost);

        // increase the staked eth balance
        _totalStakedEth = _totalStakedEth.add(cost.mul(count));

        if (msg.value > cost.mul(count)) {
            (bool success, ) = payable(msg.sender).call{value: msg.value.sub(cost.mul(count))}("");
            require(success, "REFUND_FAILED");
        }
    }

    /**
     * @dev crate a gem claim using an erc20 token. this token must be tradeable in Uniswap or this call will fail
     */
    function _createERC20Claim(address erc20token, uint256 tokenAmount) internal {
        // must be a valid address
        require(erc20token != address(0), "INVALID_ERC20_TOKEN");

        // token is allowed
        require((_allowedTokens.length > 0 && _isAllowedMap[erc20token]) || _allowedTokens.length == 0, "TOKEN_DISALLOWED");

        // Uniswap pool must exist
        require(ISwapQueryHelper(_swapHelper).hasPool(erc20token) == true, "NO_UNISWAP_POOL");

        // must have an amount specified
        require(tokenAmount >= 0, "NO_PAYMENT_INCLUDED");

        // get a quote in ETH for the given token.
        (uint256 ethereum, uint256 tokenReserve, uint256 ethReserve) = ISwapQueryHelper(_swapHelper).coinQuote(erc20token, tokenAmount);

        // get the min liquidity from fee tracker
        uint256 liquidity = INFTGemFeeManager(_feeTracker).liquidity(erc20token);

        // make sure the convertible amount is has reserves > 100x the token
        require(ethReserve >= ethereum.mul(liquidity), "INSUFFICIENT_ETH_LIQUIDITY");

        // make sure the convertible amount is has reserves > 100x the token
        require(tokenReserve >= tokenAmount.mul(liquidity), "INSUFFICIENT_TOKEN_LIQUIDITY");

        // make sure the convertible amount is less than max price
        require(ethereum <= _ethPrice, "OVERPAYMENT");

        // calculate the maturity time given the converted eth
        uint256 maturityTime = _ethPrice.mul(_minTime).div(ethereum);

        // make sure the convertible amount is less than max price
        require(maturityTime >= _minTime, "INSUFFICIENT_TIME");

        // get the next claim hash, revert if no more claims
        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        // transfer the caller's ERC20 tokens into the pool
        IERC20(erc20token).transferFrom(msg.sender, address(this), tokenAmount);

        // mint the new claim to the caller's address
        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        // record the claim unlock time and cost paid for this claim
        uint256 _claimUnlockTime = block.timestamp.add(maturityTime);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = ethereum;
        claimLockToken[claimHash] = erc20token;
        claimTokenAmountPaid[claimHash] = tokenAmount;
        claimQuant[claimHash] = 1;

        _totalStakedEth = _totalStakedEth.add(ethereum);

        // maybe mint a governance token for the claimant
        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, ethereum);

        // emit a message indicating that an erc20 claim has been created
        emit NFTGemERC20ClaimCreated(msg.sender, address(this), claimHash, maturityTime, erc20token, 1, ethereum);
    }

    /**
     * @dev crate multiple gem claim using an erc20 token. this token must be tradeable in Uniswap or this call will fail
     */
    function _createERC20Claims(address erc20token, uint256 tokenAmount, uint256 count) internal {
        // must be a valid address
        require(erc20token != address(0), "INVALID_ERC20_TOKEN");

        // token is allowed
        require((_allowedTokens.length > 0 && _isAllowedMap[erc20token]) || _allowedTokens.length == 0, "TOKEN_DISALLOWED");

        // zero qty
        require(count != 0, "ZERO_QUANTITY");

        // Uniswap pool must exist
        require(ISwapQueryHelper(_swapHelper).hasPool(erc20token) == true, "NO_UNISWAP_POOL");

        // must have an amount specified
        require(tokenAmount >= 0, "NO_PAYMENT_INCLUDED");

        // get a quote in ETH for the given token.
        (uint256 ethereum, uint256 tokenReserve, uint256 ethReserve) = ISwapQueryHelper(_swapHelper).coinQuote(
            erc20token,
            tokenAmount.div(count)
        );

        // make sure the convertible amount is has reserves > 100x the token
        require(ethReserve >= ethereum.mul(100).mul(count), "INSUFFICIENT_ETH_LIQUIDITY");

        // make sure the convertible amount is has reserves > 100x the token
        require(tokenReserve >= tokenAmount.mul(100).mul(count), "INSUFFICIENT_TOKEN_LIQUIDITY");

        // make sure the convertible amount is less than max price
        require(ethereum <= _ethPrice, "OVERPAYMENT");

        // calculate the maturity time given the converted eth
        uint256 maturityTime = _ethPrice.mul(_minTime).div(ethereum);

        // make sure the convertible amount is less than max price
        require(maturityTime >= _minTime, "INSUFFICIENT_TIME");

        // get the next claim hash, revert if no more claims
        uint256 claimHash = _nextClaimHash();
        require(claimHash != 0, "NO_MORE_CLAIMABLE");

        // mint the new claim to the caller's address
        INFTGemMultiToken(_multitoken).mint(msg.sender, claimHash, 1);
        _addToken(claimHash, 1);

        // record the claim unlock time and cost paid for this claim
        uint256 _claimUnlockTime = block.timestamp.add(maturityTime);
        claimLockTimestamps[claimHash] = _claimUnlockTime;
        claimAmountPaid[claimHash] = ethereum;
        claimLockToken[claimHash] = erc20token;
        claimTokenAmountPaid[claimHash] = tokenAmount;
        claimQuant[claimHash] = count;

        // increase staked eth amount
        _totalStakedEth = _totalStakedEth.add(ethereum);

        // maybe mint a governance token for the claimant
        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, ethereum);

        // emit a message indicating that an erc20 claim has been created
        emit NFTGemERC20ClaimCreated(msg.sender, address(this), claimHash, maturityTime, erc20token, count, ethereum);

        // transfer the caller's ERC20 tokens into the pool
        IERC20(erc20token).transferFrom(msg.sender, address(this), tokenAmount);
    }

    /**
     * @dev collect an open claim (take custody of the funds the claim is redeeemable for and maybe a gem too)
     */
    function collectClaim(uint256 claimHash) external override {
        // validation checks - disallow if not owner (holds coin with claimHash)
        // or if the unlockTime amd unlockPaid data is in an invalid state
        require(IERC1155(_multitoken).balanceOf(msg.sender, claimHash) == 1, "NOT_CLAIM_OWNER");
        uint256 unlockTime = claimLockTimestamps[claimHash];
        uint256 unlockPaid = claimAmountPaid[claimHash];
        require(unlockTime != 0 && unlockPaid > 0, "INVALID_CLAIM");

        // grab the erc20 token info if there is any
        address tokenUsed = claimLockToken[claimHash];
        uint256 unlockTokenPaid = claimTokenAmountPaid[claimHash];

        // check the maturity of the claim - only issue gem if mature
        bool isMature = unlockTime < block.timestamp;

        //  burn claim and transfer money back to user
        INFTGemMultiToken(_multitoken).burn(msg.sender, claimHash, 1);

        // if they used erc20 tokens stake their claim, return their tokens
        if (tokenUsed != address(0)) {
            // calculate fee portion using fee tracker
            uint256 feePortion = 0;
            if (isMature == true) {
                uint256 poolDiv = INFTGemFeeManager(_feeTracker).feeDivisor(address(this));
                uint256 divisor = INFTGemFeeManager(_feeTracker).feeDivisor(tokenUsed);
                uint256 feeNum = poolDiv != divisor ? divisor : poolDiv;
                feePortion = unlockTokenPaid.div(feeNum);
            }
            // assess a fee for minting the NFT. Fee is collectec in fee tracker
            IERC20(tokenUsed).transferFrom(address(this), _feeTracker, feePortion);
            // send the principal minus fees to the caller
            IERC20(tokenUsed).transferFrom(address(this), msg.sender, unlockTokenPaid.sub(feePortion));

            // emit an event that the claim was redeemed for ERC20
            emit NFTGemERC20ClaimRedeemed(
                msg.sender,
                address(this),
                claimHash,
                tokenUsed,
                unlockPaid,
                unlockTokenPaid,
                feePortion
            );
        } else {
            // calculate fee portion using fee tracker
            uint256 feePortion = 0;
            if (isMature == true) {
                uint256 divisor = INFTGemFeeManager(_feeTracker).feeDivisor(address(0));
                feePortion = unlockPaid.div(divisor);
            }
            // transfer the ETH fee to fee tracker
            payable(_feeTracker).transfer(feePortion);
            // transfer the ETH back to user
            payable(msg.sender).transfer(unlockPaid.sub(feePortion));

            // emit an event that the claim was redeemed for ETH
            emit NFTGemClaimRedeemed(msg.sender, address(this), claimHash, unlockPaid, feePortion);
        }

        // deduct the total staked ETH balance of the pool
        _totalStakedEth = _totalStakedEth.sub(unlockPaid);

        // if all this is happening before the unlocktime then we exit
        // without minting a gem because the user is withdrawing early
        if (!isMature) {
            return;
        }

        // get the next gem hash, increase the staking sifficulty
        // for the pool, and mint a gem token back to account
        uint256 nextHash = this.nextGemHash();

        // mint the gem
        INFTGemMultiToken(_multitoken).mint(msg.sender, nextHash, claimQuant[claimHash]);
        _addToken(nextHash, 2);

        // maybe mint a governance token
        INFTGemGovernor(_governor).maybeIssueGovernanceToken(msg.sender);
        INFTGemGovernor(_governor).issueFuelToken(msg.sender, unlockPaid);

        // emit an event about a gem getting created
        emit NFTGemCreated(msg.sender, address(this), claimHash, nextHash, claimQuant[claimHash]);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "../libs/SafeMath.sol";
import "../utils/Initializable.sol";
import "../interfaces/INFTGemPoolData.sol";


contract NFTGemPoolData is INFTGemPoolData, Initializable {
    using SafeMath for uint256;

    // it all starts with a symbol and a nams
    string internal _symbol;
    string internal _name;

    // magic economy numbers
    uint256 internal _ethPrice;
    uint256 internal _minTime;
    uint256 internal _maxTime;
    uint256 internal _diffstep;
    uint256 internal _maxClaims;

    mapping(uint256 => uint8) internal _tokenTypes;
    mapping(uint256 => uint256) internal _tokenIds;
    uint256[] internal _tokenHashes;

    // next ids of things
    uint256 internal _nextGemId;
    uint256 internal _nextClaimId;
    uint256 internal _totalStakedEth;

    // records claim timestamp / ETH value / ERC token and amount sent
    mapping(uint256 => uint256) internal claimLockTimestamps;
    mapping(uint256 => address) internal claimLockToken;
    mapping(uint256 => uint256) internal claimAmountPaid;
    mapping(uint256 => uint256) internal claimQuant;
    mapping(uint256 => uint256) internal claimTokenAmountPaid;

    address[] internal _allowedTokens;
    mapping(address => bool) internal _isAllowedMap;

    constructor() {}

    /**
     * @dev The symbol for this pool / NFT
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev The name for this pool / NFT
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev The ether price for this pool / NFT
     */
    function ethPrice() external view override returns (uint256) {
        return _ethPrice;
    }

    /**
     * @dev min time to stake in this pool to earn an NFT
     */
    function minTime() external view override returns (uint256) {
        return _minTime;
    }

    /**
     * @dev max time to stake in this pool to earn an NFT
     */
    function maxTime() external view override returns (uint256) {
        return _maxTime;
    }

    /**
     * @dev difficulty step increase for this pool.
     */
    function difficultyStep() external view override returns (uint256) {
        return _diffstep;
    }

    /**
     * @dev max claims that can be made on this NFT
     */
    function maxClaims() external view override returns (uint256) {
        return _maxClaims;
    }

    /**
     * @dev number of claims made thus far
     */
    function claimedCount() external view override returns (uint256) {
        return _nextClaimId;
    }

    /**
     * @dev the number of gems minted in this
     */
    function mintedCount() external view override returns (uint256) {
        return _nextGemId;
    }

    /**
     * @dev the number of gems minted in this
     */
    function totalStakedEth() external view override returns (uint256) {
        return _totalStakedEth;
    }

    /**
     * @dev get token type of hash - 1 is for claim, 2 is for gem
     */
    function tokenType(uint256 tokenHash) external view override returns (uint8) {
        return _tokenTypes[tokenHash];
    }

    /**
     * @dev get token id (serial #) of the given token hash. 0 if not a token, 1 if claim, 2 if gem
     */
    function tokenId(uint256 tokenHash) external view override returns (uint256) {
        return _tokenIds[tokenHash];
    }

    /**
     * @dev get token id (serial #) of the given token hash. 0 if not a token, 1 if claim, 2 if gem
     */
    function allTokenHashesLength() external view override returns (uint256) {
        return _tokenHashes.length;
    }

    /**
     * @dev get token id (serial #) of the given token hash. 0 if not a token, 1 if claim, 2 if gem
     */
    function allTokenHashes(uint256 ndx) external view override returns (uint256) {
        return _tokenHashes[ndx];
    }

    /**
     * @dev the external version of the above
     */
    function nextClaimHash() external view override returns (uint256) {
        return _nextClaimHash();
    }

    /**
     * @dev the external version of the above
     */
    function nextGemHash() external view override returns (uint256) {
        return _nextGemHash();
    }

    /**
     * @dev the external version of the above
     */
    function nextClaimId() external view override returns (uint256) {
        return _nextClaimId;
    }

    /**
     * @dev the external version of the above
     */
    function nextGemId() external view override returns (uint256) {
        return _nextGemId;
    }

    /**
     * @dev the external version of the above
     */
    function allowedTokensLength() external view override returns (uint256) {
        return _allowedTokens.length;
    }

    /**
     * @dev the external version of the above
     */
    function allowedTokens(uint256 idx) external view override returns (address) {
        return _allowedTokens[idx];
    }

    /**
     * @dev the external version of the above
     */
    function isTokenAllowed(address token) external view override returns (bool) {
        return _isAllowedMap[token];
    }

    /**
     * @dev the external version of the above
     */
    function addAllowedToken(address token) external override {
        if(!_isAllowedMap[token]) {
            _allowedTokens.push(token);
            _isAllowedMap[token] = true;
        }
    }

    /**
     * @dev the external version of the above
     */
    function removeAllowedToken(address token) external override {
        if(_isAllowedMap[token]) {
            for(uint256 i = 0; i < _allowedTokens.length; i++) {
                if(_allowedTokens[i] == token) {
                   _allowedTokens[i] = _allowedTokens[_allowedTokens.length - 1];
                    delete _allowedTokens[_allowedTokens.length - 1];
                    _isAllowedMap[token] = false;
                    return;
                }
            }
        }
    }

    /**
     * @dev the claim amount for the given claim id
     */
    function claimAmount(uint256 claimHash) external view override returns (uint256) {
        return claimAmountPaid[claimHash];
    }

    /**
     * @dev the claim quantity (count of gems staked) for the given claim id
     */
    function claimQuantity(uint256 claimHash) external view override returns (uint256) {
        return claimQuant[claimHash];
    }

    /**
     * @dev the lock time for this claim. once past lock time a gema is minted
     */
    function claimUnlockTime(uint256 claimHash) external view override returns (uint256) {
        return claimLockTimestamps[claimHash];
    }

    /**
     * @dev claim token amount if paid using erc20
     */
    function claimTokenAmount(uint256 claimHash) external view override returns (uint256) {
        return claimTokenAmountPaid[claimHash];
    }

    /**
     * @dev the staked token if staking with erc20
     */
    function stakedToken(uint256 claimHash) external view override returns (address) {
        return claimLockToken[claimHash];
    }

    /**
     * @dev get token id (serial #) of the given token hash. 0 if not a token, 1 if claim, 2 if gem
     */
    function _addToken(uint256 tokenHash, uint8 tt) internal {
        require(tt == 1 || tt == 2, "INVALID_TOKENTYPE");
        _tokenHashes.push(tokenHash);
        _tokenTypes[tokenHash] = tt;
        _tokenIds[tokenHash] = tt == 1 ? __nextClaimId() : __nextGemId();
        if(tt == 2) {
            _increaseDifficulty();
        }
    }

    /**
     * @dev get the next claim id
     */
    function __nextClaimId() private returns (uint256) {
        uint256 ncId = _nextClaimId;
        _nextClaimId = _nextClaimId.add(1);
        return ncId;
    }

    /**
     * @dev get the next gem id
     */
    function __nextGemId() private returns (uint256) {
        uint256 ncId = _nextGemId;
        _nextGemId = _nextGemId.add(1);
        return ncId;
    }

    /**
     * @dev increase the pool's difficulty by calculating the step increase portion and adding it to the eth price of the market
     */
    function _increaseDifficulty() private {
        uint256 diffIncrease = _ethPrice.div(_diffstep);
        _ethPrice = _ethPrice.add(diffIncrease);
    }

    /**
     * @dev the hash of the next gem to be minted
     */
    function _nextGemHash() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked("gem", address(this), _nextGemId)));
    }

    /**
     * @dev the hash of the next claim to be minted
     */
    function _nextClaimHash() internal view returns (uint256) {
        return
            (_maxClaims != 0 && _nextClaimId <= _maxClaims) || _maxClaims == 0
                ? uint256(keccak256(abi.encodePacked("claim", address(this), _nextClaimId)))
                : 0;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24;

import "../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

{
  "evmVersion": "istanbul",
  "libraries": {
    "src/factories/NFTGemPoolFactory.sol:NFTGemPoolFactory": {
      "GovernanceLib": "0x8B4207A13a5a13bDb2bBf15c137820e61e3c4AAc",
      "Strings": "0x98ccd9cb27398a6595f15cbc4b63ac525b942aad",
      "SafeMath": "0xD34a551B4a262230a373D376dDf8aADb2B0D49FD",
      "ProposalsLib": "0x54812b41409912bd065e9d3920ce196ff9bfc995",
      "Create2": "0xa511e209a01e27d134b4f564263f7db8fcbdeba6"
    }
  },
  "metadata": {
    "bytecodeHash": "ipfs",
    "useLiteralContent": true
  },
  "optimizer": {
    "enabled": true,
    "runs": 9999
  },
  "remappings": [],
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}