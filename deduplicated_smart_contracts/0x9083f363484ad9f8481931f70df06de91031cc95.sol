/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

/*
 * Copyright ©️ 2018-2020 Galt•Project Society Construction and Terraforming Company
 * (Founded by [Nikolai Popeka](https://github.com/npopeka)
 *
 * Copyright ©️ 2018-2020 Galt•Core Blockchain Company
 * (Founded by [Nikolai Popeka](https://github.com/npopeka) by
 * [Basic Agreement](ipfs/QmaCiXUmSrP16Gz8Jdzq6AJESY1EAANmmwha15uR3c1bsS)).
 * 
 * 🌎 Galt Project is an international decentralized land and real estate property registry
 * governed by DAO (Decentralized autonomous organization) and self-governance platform for communities
 * of homeowners on Ethereum.
 * 
 * 🏡 https://galtproject.io
 */

pragma solidity ^0.5.13;

interface IPPTokenController {
  event Mint(address indexed to, uint256 indexed tokenId);
  event SetGeoDataManager(address indexed geoDataManager);
  event SetContourVerificationManager(address indexed contourVerificationManager);
  event SetFeeManager(address indexed feeManager);
  event SetFeeCollector(address indexed feeCollector);
  event ReportCVMisbehaviour(uint256 tokenId);
  event NewProposal(
    uint256 indexed proposalId,
    uint256 indexed tokenId,
    address indexed creator
  );
  event ProposalExecuted(uint256 indexed proposalId);
  event ProposalExecutionFailed(uint256 indexed proposalId);
  event ProposalApproval(
    uint256 indexed proposalId,
    uint256 indexed tokenId
  );
  event ProposalRejection(
    uint256 indexed proposalId,
    uint256 indexed tokenId
  );
  event ProposalCancellation(
    uint256 indexed proposalId,
    uint256 indexed tokenId
  );
  event SetMinter(address indexed minter);
  event SetBurner(address indexed burner);
  event SetBurnTimeout(uint256 indexed tokenId, uint256 timeout);
  event InitiateTokenBurn(uint256 indexed tokenId, uint256 timeoutAt);
  event BurnTokenByTimeout(uint256 indexed tokenId);
  event CancelTokenBurn(uint256 indexed tokenId);
  event SetFee(bytes32 indexed key, uint256 value);
  event WithdrawEth(address indexed to, uint256 amount);
  event WithdrawErc20(address indexed to, address indexed tokenAddress, uint256 amount);
  event UpdateContourUpdatedAt(uint256 indexed tokenId, uint256 timestamp);
  event UpdateDetailsUpdatedAt(uint256 indexed tokenId, uint256 timestamp);

  enum PropertyInitialSetupStage {
    PENDING,
    DETAILS,
    DONE
  }

  function contourVerificationManager() external view returns (address);
  function fees(bytes32) external view returns (uint256);
  function setBurner(address _burner) external;
  function setGeoDataManager(address _geoDataManager) external;
  function setFeeManager(address _feeManager) external;
  function setFeeCollector(address _feeCollector) external;
  function setBurnTimeoutDuration(uint256 _tokenId, uint256 _duration) external;
  function setFee(bytes32 _key, uint256 _value) external;
  function withdrawErc20(address _tokenAddress, address _to) external;
  function withdrawEth(address payable _to) external;
  function initiateTokenBurn(uint256 _tokenId) external;
  function cancelTokenBurn(uint256 _tokenId) external;
  function burnTokenByTimeout(uint256 _tokenId) external;
  function reportCVMisbehaviour(uint256 _tokenId) external;
  function propose(bytes calldata _data, string calldata _dataLink) external payable;
  function approve(uint256 _proposalId) external;
  function execute(uint256 _proposalId) external;
  function fetchTokenId(bytes calldata _data) external pure returns (uint256 tokenId);
  function() external payable;
}

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

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

interface IPPToken {
  event SetBaseURI(string baseURI);
  event SetContractDataLink(string indexed dataLink);
  event SetLegalAgreementIpfsHash(bytes32 legalAgreementIpfsHash);
  event SetController(address indexed controller);
  event SetDetails(
    address indexed geoDataManager,
    uint256 indexed privatePropertyId
  );
  event SetContour(
    address indexed geoDataManager,
    uint256 indexed privatePropertyId
  );
  event SetHumanAddress(uint256 indexed tokenId, string humanAddress);
  event SetDataLink(uint256 indexed tokenId, string dataLink);
  event SetLedgerIdentifier(uint256 indexed tokenId, bytes32 ledgerIdentifier);
  event SetVertexRootHash(uint256 indexed tokenId, bytes32 ledgerIdentifier);
  event SetVertexStorageLink(uint256 indexed tokenId, string vertexStorageLink);
  event SetArea(uint256 indexed tokenId, uint256 area, AreaSource areaSource);
  event SetExtraData(bytes32 indexed key, bytes32 value);
  event SetPropertyExtraData(uint256 indexed propertyId, bytes32 indexed key, bytes32 value);
  event Mint(address indexed to, uint256 indexed privatePropertyId);
  event Burn(address indexed from, uint256 indexed privatePropertyId);

  enum AreaSource {
    USER_INPUT,
    CONTRACT
  }

  enum TokenType {
    NULL,
    LAND_PLOT,
    BUILDING,
    ROOM,
    PACKAGE
  }

  struct Property {
    uint256 setupStage;

    // (LAND_PLOT,BUILDING,ROOM) Type cannot be changed after token creation
    TokenType tokenType;
    // Geohash5z (x,y,z)
    uint256[] contour;
    // Meters above the sea
    int256 highestPoint;

    // USER_INPUT or CONTRACT
    AreaSource areaSource;
    // Calculated either by contract (for land plots and buildings) or by manual input
    // in sq. meters (1 sq. meter == 1 eth)
    uint256 area;

    bytes32 ledgerIdentifier;
    string humanAddress;
    string dataLink;

    // Reserved for future use
    bytes32 vertexRootHash;
    string vertexStorageLink;
  }

  // PERMISSIONED METHODS

  function setContractDataLink(string calldata _dataLink) external;
  function setLegalAgreementIpfsHash(bytes32 _legalAgreementIpfsHash) external;
  function setController(address payable _controller) external;
  function setDetails(
    uint256 _tokenId,
    TokenType _tokenType,
    AreaSource _areaSource,
    uint256 _area,
    bytes32 _ledgerIdentifier,
    string calldata _humanAddress,
    string calldata _dataLink
  )
    external;

  function setContour(
    uint256 _tokenId,
    uint256[] calldata _contour,
    int256 _highestPoint
  )
    external;

  function setArea(uint256 _tokenId, uint256 _area, AreaSource _areaSource) external;
  function setLedgerIdentifier(uint256 _tokenId, bytes32 _ledgerIdentifier) external;
  function setDataLink(uint256 _tokenId, string calldata _dataLink) external;
  function setVertexRootHash(uint256 _tokenId, bytes32 _vertexRootHash) external;
  function setVertexStorageLink(uint256 _tokenId, string calldata _vertexStorageLink) external;
  function setExtraData(bytes32 _key, bytes32 _value) external;
  function setPropertyExtraData(uint256 _tokenId, bytes32 _key, bytes32 _value) external;

  function incrementSetupStage(uint256 _tokenId) external;

  function mint(address _to) external returns (uint256);
  function burn(uint256 _tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;

  // GETTERS
  function controller() external view returns (address payable);
  function extraData(bytes32 _key) external view returns (bytes32);
  function propertyExtraData(uint256 _tokenId, bytes32 _key) external view returns (bytes32);
  function propertyCreatedAt(uint256 _tokenId) external view returns (uint256);
  function tokensOfOwner(address _owner) external view returns (uint256[] memory);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function exists(uint256 _tokenId) external view returns (bool);
  function getType(uint256 _tokenId) external view returns (TokenType);
  function getContour(uint256 _tokenId) external view returns (uint256[] memory);
  function getContourLength(uint256 _tokenId) external view returns (uint256);
  function getHighestPoint(uint256 _tokenId) external view returns (int256);
  function getHumanAddress(uint256 _tokenId) external view returns (string memory);
  function getArea(uint256 _tokenId) external view returns (uint256);
  function getAreaSource(uint256 _tokenId) external view returns (AreaSource);
  function getLedgerIdentifier(uint256 _tokenId) external view returns (bytes32);
  function getDataLink(uint256 _tokenId) external view returns (string memory);
  function getVertexRootHash(uint256 _tokenId) external view returns (bytes32);
  function getVertexStorageLink(uint256 _tokenId) external view returns (string memory);
  function getSetupStage(uint256 _tokenId) external view returns (uint256);
  function getDetails(uint256 _tokenId)
    external
    view
    returns (
      TokenType tokenType,
      uint256[] memory contour,
      int256 highestPoint,
      AreaSource areaSource,
      uint256 area,
      bytes32 ledgerIdentifier,
      string memory humanAddress,
      string memory dataLink,
      uint256 setupStage,
      bytes32 vertexRootHash,
      string memory vertexStorageLink
    );
}

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IACL {
  function setRole(bytes32 _role, address _candidate, bool _allow) external;
  function hasRole(address _candidate, bytes32 _role) external view returns (bool);
}

interface IPPGlobalRegistry {
  function setContract(bytes32 _key, address _value) external;

  // GETTERS
  function getContract(bytes32 _key) external view returns (address);
  function getACL() external view returns (IACL);
  function getGaltTokenAddress() external view returns (address);
  function getPPTokenRegistryAddress() external view returns (address);
  function getPPLockerRegistryAddress() external view returns (address);
  function getPPMarketAddress() external view returns (address);
}

contract PPTokenController is IPPTokenController, Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public constant VERSION = 3;

  bytes32 public constant PROPOSAL_GALT_FEE_KEY = bytes32("CONTROLLER_PROPOSAL_GALT");
  bytes32 public constant PROPOSAL_ETH_FEE_KEY = bytes32("CONTROLLER_PROPOSAL_ETH");
  bytes32 public constant DETAILS_UPDATED_EXTRA_KEY = bytes32("DETAILS_UPDATED_AT");
  bytes32 public constant CONTOUR_UPDATED_EXTRA_KEY = bytes32("CONTOUR_UPDATED_AT");
  bytes32 public constant CLAIM_UNIQUENESS_KEY = bytes32("CLAIM_UNIQUENESS");

  // setDetails(uint256,uint8,uint8,uint256,bytes32,string,string)
  bytes32 internal constant TOKEN_SET_DETAILS_SIGNATURE = 0x18212fc600000000000000000000000000000000000000000000000000000000;
  // setContour(uint256,uint256[],int256)
  bytes32 internal constant TOKEN_SET_CONTOUR_SIGNATURE = 0x89e8915f00000000000000000000000000000000000000000000000000000000;

  enum ProposalStatus {
    NULL,
    PENDING,
    APPROVED,
    EXECUTED,
    REJECTED,
    CANCELLED
  }

  struct Proposal {
    address creator;
    ProposalStatus status;
    bool tokenOwnerApproved;
    bool geoDataManagerApproved;
    bytes data;
    string dataLink;
  }

  IPPGlobalRegistry public globalRegistry;
  IPPToken public tokenContract;
  address public contourVerificationManager;
  address public geoDataManager;
  address public feeManager;
  address public feeCollector;
  address public minter;
  address public burner;
  uint256 public defaultBurnTimeoutDuration;
  uint256 internal idCounter;

  mapping(uint256 => Proposal) public proposals;
  // tokenId => timeoutDuration (in seconds)
  mapping(uint256 => uint256) public burnTimeoutDuration;
  // tokenId => burnTimeoutAt
  mapping(uint256 => uint256) public burnTimeoutAt;
  // key => fee
  mapping(bytes32 => uint256) public fees;

  modifier onlyMinter() {
    require(msg.sender == minter, "Only minter allowed");

    _;
  }

  modifier onlyContourVerifier() {
    require(msg.sender == contourVerificationManager, "Only contourVerifier allowed");

    _;
  }

  constructor(IPPGlobalRegistry _globalRegistry, IPPToken _tokenContract, uint256 _defaultBurnTimeoutDuration) public {
    require(_defaultBurnTimeoutDuration > 0, "Invalid burn timeout duration");

    defaultBurnTimeoutDuration = _defaultBurnTimeoutDuration;
    tokenContract = _tokenContract;
    globalRegistry = _globalRegistry;
  }

  function() external payable {
  }

  // CONTRACT OWNER INTERFACE

  function setContourVerificationManager(address _contourVerificationManager) external onlyOwner {
    contourVerificationManager = _contourVerificationManager;

    emit SetContourVerificationManager(_contourVerificationManager);
  }

  function setGeoDataManager(address _geoDataManager) external onlyOwner {
    geoDataManager = _geoDataManager;

    emit SetGeoDataManager(_geoDataManager);
  }

  function setFeeManager(address _feeManager) external onlyOwner {
    feeManager = _feeManager;

    emit SetFeeManager(_feeManager);
  }

  function setFeeCollector(address _feeCollector) external onlyOwner {
    feeCollector = _feeCollector;

    emit SetFeeCollector(_feeCollector);
  }

  function setMinter(address _minter) external onlyOwner {
    minter = _minter;

    emit SetMinter(_minter);
  }

  function setBurner(address _burner) external onlyOwner {
    burner = _burner;

    emit SetBurner(_burner);
  }

  function withdrawErc20(address _tokenAddress, address _to) external {
    require(msg.sender == feeCollector, "Missing permissions");

    uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));

    IERC20(_tokenAddress).transfer(_to, balance);

    emit WithdrawErc20(_to, _tokenAddress, balance);
  }

  function withdrawEth(address payable _to) external {
    require(msg.sender == feeCollector, "Missing permissions");

    uint256 balance = address(this).balance;

    _to.transfer(balance);

    emit WithdrawEth(_to, balance);
  }

  function setFee(bytes32 _key, uint256 _value) external {
    require(msg.sender == feeManager, "Missing permissions");

    fees[_key] = _value;
    emit SetFee(_key, _value);
  }

  // BURNER INTERFACE

  function initiateTokenBurn(uint256 _tokenId) external {
    require(msg.sender == burner, "Only burner allowed");
    require(burnTimeoutAt[_tokenId] == 0, "Burn already initiated");
    require(tokenContract.ownerOf(_tokenId) != address(0), "Token doesn't exists");

    uint256 duration = burnTimeoutDuration[_tokenId];
    if (duration == 0) {
      duration = defaultBurnTimeoutDuration;
    }

    uint256 timeoutAt = block.timestamp.add(duration);
    burnTimeoutAt[_tokenId] = timeoutAt;

    emit InitiateTokenBurn(_tokenId, timeoutAt);
  }

  // MINTER INTERFACE
  function mint(address _to) external onlyMinter {
    uint256 _tokenId = tokenContract.mint(_to);

    emit Mint(_to, _tokenId);
  }

  // CONTOUR VERIFICATION INTERFACE

  function reportCVMisbehaviour(uint256 _tokenId) external onlyContourVerifier {
    tokenContract.burn(_tokenId);

    emit ReportCVMisbehaviour(_tokenId);
  }

  // CONTROLLER INTERFACE

  function setInitialDetails(
    uint256 _privatePropertyId,
    IPPToken.TokenType _tokenType,
    IPPToken.AreaSource _areaSource,
    uint256 _area,
    bytes32 _ledgerIdentifier,
    string calldata _humanAddress,
    string calldata _dataLink,
    bool _claimUniqueness
  )
    external
    onlyMinter
  {
    // Will REVERT if there is no owner assigned to the token
    tokenContract.ownerOf(_privatePropertyId);

    uint256 setupStage = tokenContract.getSetupStage(_privatePropertyId);
    require(setupStage == uint256(PropertyInitialSetupStage.PENDING), "Requires PENDING setup stage");

    tokenContract.setDetails(_privatePropertyId, _tokenType, _areaSource, _area, _ledgerIdentifier, _humanAddress, _dataLink);

    tokenContract.incrementSetupStage(_privatePropertyId);

    _updateDetailsUpdatedAt(_privatePropertyId);

    tokenContract.setPropertyExtraData(_privatePropertyId, CLAIM_UNIQUENESS_KEY, bytes32(uint256(_claimUniqueness ? 1 : 0)));
  }

  function setInitialContour(
    uint256 _privatePropertyId,
    uint256[] calldata _contour,
    int256 _highestPoint
  )
    external
    onlyMinter
  {
    uint256 setupStage = tokenContract.getSetupStage(_privatePropertyId);

    require(setupStage == uint256(PropertyInitialSetupStage.DETAILS), "Requires DETAILS setup stage");

    tokenContract.setContour(_privatePropertyId, _contour, _highestPoint);

    tokenContract.incrementSetupStage(_privatePropertyId);

    _updateContourUpdatedAt(_privatePropertyId);
  }

  // TOKEN OWNER INTERFACE

  function setBurnTimeoutDuration(uint256 _tokenId, uint256 _duration) external {
    require(tokenContract.ownerOf(_tokenId) == msg.sender, "Only token owner allowed");
    require(_duration > 0, "Invalid timeout duration");

    burnTimeoutDuration[_tokenId] = _duration;

    emit SetBurnTimeout(_tokenId, _duration);
  }

  function cancelTokenBurn(uint256 _tokenId) external {
    require(burnTimeoutAt[_tokenId] != 0, "Burn not initiated");
    require(tokenContract.ownerOf(_tokenId) == msg.sender, "Only token owner allowed");

    burnTimeoutAt[_tokenId] = 0;

    emit CancelTokenBurn(_tokenId);
  }

  // COMMON INTERFACE

  function propose(
    bytes calldata _data,
    string calldata _dataLink
  )
    external
    payable
  {
    address msgSender = msg.sender;
    uint256 tokenId = fetchTokenId(_data);
    uint256 proposalId = _nextId();

    Proposal storage p = proposals[proposalId];

    if (msgSender == geoDataManager) {
      p.geoDataManagerApproved = true;
    } else if (msgSender == tokenContract.ownerOf(tokenId)) {
      _acceptProposalFee();
      p.tokenOwnerApproved = true;
    } else {
      revert("Missing permissions");
    }

    p.creator = msgSender;
    p.data = _data;
    p.dataLink = _dataLink;
    p.status = ProposalStatus.PENDING;

    emit NewProposal(proposalId, tokenId, msg.sender);
  }

  function approve(uint256 _proposalId) external {
    Proposal storage p = proposals[_proposalId];
    uint256 tokenId = fetchTokenId(p.data);

    require(p.status == ProposalStatus.PENDING, "Expect PENDING status");

    if (p.geoDataManagerApproved == true) {
      require(msg.sender == tokenContract.ownerOf(tokenId), "Missing permissions");
      p.tokenOwnerApproved = true;
    } else if (p.tokenOwnerApproved == true) {
      require(msg.sender == geoDataManager, "Missing permissions");
      p.geoDataManagerApproved = true;
    } else {
      revert("Missing permissions");
    }

    emit ProposalApproval(_proposalId, tokenId);

    p.status = ProposalStatus.APPROVED;

    execute(_proposalId);
  }

  function reject(uint256 _proposalId) external {
    Proposal storage p = proposals[_proposalId];
    uint256 tokenId = fetchTokenId(p.data);

    require(p.status == ProposalStatus.PENDING, "Expect PENDING status");

    if (p.geoDataManagerApproved == true) {
      require(msg.sender == tokenContract.ownerOf(tokenId), "Missing permissions");
    } else if (p.tokenOwnerApproved == true) {
      require(msg.sender == geoDataManager, "Missing permissions");
    } else {
      revert("Missing permissions");
    }

    p.status = ProposalStatus.REJECTED;

    emit ProposalRejection(_proposalId, tokenId);
  }

  function cancel(uint256 _proposalId) external {
    Proposal storage p = proposals[_proposalId];
    uint256 tokenId = fetchTokenId(p.data);

    require(p.status == ProposalStatus.PENDING, "Expect PENDING status");

    if (msg.sender == geoDataManager) {
      require(p.geoDataManagerApproved == true, "Only own proposals can be cancelled");
    } else if (msg.sender == tokenContract.ownerOf(tokenId)) {
      require(p.tokenOwnerApproved == true, "Only own proposals can be cancelled");
    } else {
      revert("Missing permissions");
    }

    p.status = ProposalStatus.CANCELLED;

    emit ProposalCancellation(_proposalId, tokenId);
  }

  // PERMISSIONLESS INTERFACE

  function execute(uint256 _proposalId) public {
    Proposal storage p = proposals[_proposalId];

    require(p.tokenOwnerApproved == true, "Token owner approval required");
    require(p.geoDataManagerApproved == true, "GeoDataManager approval required");
    require(p.status == ProposalStatus.APPROVED, "Expect APPROVED status");

    _preExecuteHook(p.data);

    p.status = ProposalStatus.EXECUTED;

    (bool ok,) = address(tokenContract)
      .call
      .gas(gasleft().sub(50000))(p.data);

    if (ok == false) {
      emit ProposalExecutionFailed(_proposalId);
      p.status = ProposalStatus.APPROVED;
    } else {
      emit ProposalExecuted(_proposalId);
    }
  }

  function _preExecuteHook(bytes memory data) internal {
    bytes32 signature = fetchSignature(data);
    uint256 tokenId = fetchTokenId(data);

    if (signature == TOKEN_SET_DETAILS_SIGNATURE) {
      _updateDetailsUpdatedAt(tokenId);
    } else if (signature == TOKEN_SET_CONTOUR_SIGNATURE) {
      _updateContourUpdatedAt(tokenId);
    }
  }

  function burnTokenByTimeout(uint256 _tokenId) external {
    require(burnTimeoutAt[_tokenId] != 0, "Timeout not set");
    require(block.timestamp > burnTimeoutAt[_tokenId], "Timeout has not passed yet");
    require(tokenContract.ownerOf(_tokenId) != address(0), "Token already burned");

    tokenContract.burn(_tokenId);

    emit BurnTokenByTimeout(_tokenId);
  }

  // @dev Assuming that a tokenId is always the first argument in a method
  function fetchTokenId(bytes memory _data) public pure returns (uint256 tokenId) {
    assembly {
      tokenId := mload(add(_data, 0x24))
    }

    require(tokenId > 0, "Failed fetching tokenId from encoded data");
  }

  function fetchSignature(bytes memory _data) public pure returns (bytes32 signature) {
    assembly {
      signature := and(mload(add(_data, 0x20)), 0xffffffff00000000000000000000000000000000000000000000000000000000)
    }
  }

  // INTERNAL

  function _nextId() internal returns (uint256) {
    idCounter += 1;
    return idCounter;
  }

  function _galtToken() internal view returns (IERC20) {
    return IERC20(globalRegistry.getGaltTokenAddress());
  }

  function _acceptProposalFee() internal {
    if (msg.value == 0) {
      _galtToken().transferFrom(msg.sender, address(this), fees[PROPOSAL_GALT_FEE_KEY]);
    } else {
      require(msg.value == fees[PROPOSAL_ETH_FEE_KEY], "Invalid fee");
    }
  }

  function _updateDetailsUpdatedAt(uint256 _tokenId) internal {
    bytes32 value = bytes32(now);

    tokenContract.setPropertyExtraData(_tokenId, DETAILS_UPDATED_EXTRA_KEY, value);

    emit UpdateDetailsUpdatedAt(_tokenId, now);
  }

  function _updateContourUpdatedAt(uint256 _tokenId) internal {
    bytes32 value = bytes32(now);

    tokenContract.setPropertyExtraData(_tokenId, CONTOUR_UPDATED_EXTRA_KEY, value);

    emit UpdateDetailsUpdatedAt(_tokenId, now);
  }

  // GETTERS

  function getDetailsUpdatedAt(uint256 _tokenId) public view returns (uint256) {
    return uint256(tokenContract.propertyExtraData(_tokenId, DETAILS_UPDATED_EXTRA_KEY));
  }

  function getContourUpdatedAt(uint256 _tokenId) public view returns (uint256) {
    return uint256(tokenContract.propertyExtraData(_tokenId, CONTOUR_UPDATED_EXTRA_KEY));
  }

  function getClaimUniquenessFlag(uint256 _tokenId) public view returns (bool) {
    return tokenContract.propertyExtraData(_tokenId, CLAIM_UNIQUENESS_KEY) != 0x0;
  }
}

contract PPTokenControllerFactory {
  event NewPPTokenController(address indexed token, address controller);

  // USER INTERFACE

  function build(
    IPPGlobalRegistry _globalRegistry,
    IPPToken _tokenContract,
    uint256 _defaultBurnTimeoutDuration
  )
    external
    returns (PPTokenController)
  {
    PPTokenController ppTokenController = new PPTokenController(
      _globalRegistry,
      _tokenContract,
      _defaultBurnTimeoutDuration
    );

    ppTokenController.transferOwnership(msg.sender);

    emit NewPPTokenController(address(_tokenContract), address(ppTokenController));

    return ppTokenController;
  }
}