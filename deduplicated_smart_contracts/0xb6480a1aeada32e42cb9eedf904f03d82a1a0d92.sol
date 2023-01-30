/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

pragma solidity ^0.5.11;


// via https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

interface IERC1155 {
  // Events

  /**
   * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
   *   Operator MUST be msg.sender
   *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
   *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
   *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
   *   To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the TransferSingle event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
   */
  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  /**
   * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
   *   Operator MUST be msg.sender
   *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
   *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
   *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
   *   To broadcast the existence of multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
   */
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  /**
   * @dev MUST emit when an approval is updated
   */
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /**
   * @dev MUST emit when the URI is updated for a token ID
   *   URIs are defined in RFC 3986
   *   The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata JSON Schema"
   */
  event URI(string _amount, uint256 indexed _id);

  /**
   * @notice Transfers amount of an _id from the _from address to the _to address specified
   * @dev MUST emit TransferSingle event on success
   * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
   * MUST throw if `_to` is the zero address
   * MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
   * MUST throw on any other error
   * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
   * @param _from    Source address
   * @param _to      Target address
   * @param _id      ID of the token type
   * @param _amount  Transfered amount
   * @param _data    Additional data with no specified format, sent in call to `_to`
   */
  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

  /**
   * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
   * @dev MUST emit TransferBatch event on success
   * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
   * MUST throw if `_to` is the zero address
   * MUST throw if length of `_ids` is not the same as length of `_amounts`
   * MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
   * MUST throw on any other error
   * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
   * Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
   * @param _from     Source addresses
   * @param _to       Target addresses
   * @param _ids      IDs of each token type
   * @param _amounts  Transfer amounts per token type
   * @param _data     Additional data with no specified format, sent in call to `_to`
  */
  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;
  
  /**
   * @notice Get the balance of an account's Tokens
   * @param _owner  The address of the token holder
   * @param _id     ID of the Token
   * @return        The _owner's balance of the Token type requested
   */
  function balanceOf(address _owner, uint256 _id) external view returns (uint256);

  /**
   * @notice Get the balance of multiple account/token pairs
   * @param _owners The addresses of the token holders
   * @param _ids    ID of the Tokens
   * @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
   */
  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

  /**
   * @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
   * @dev MUST emit the ApprovalForAll event on success
   * @param _operator  Address to add to the set of authorized operators
   * @param _approved  True if the operator is approved, false to revoke approval
   */
  function setApprovalForAll(address _operator, bool _approved) external;

  /**
   * @notice Queries the approval status of an operator for a given owner
   * @param _owner     The owner of the Tokens
   * @param _operator  Address of authorized operator
   * @return           True if the operator is approved, false if not
   */
  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}

contract SaleTokens is Ownable {
    using SafeMath for uint256;

    IERC1155 public erc1155Collection;

    // Address where funds are collected
    address payable private walletStoredFunds;
    address private walletStoredNFT;

    // prices in MANA by token id
    mapping(uint256 => uint256) public priceByTokenId;

    uint256 public rateMANAETH;

    uint256 public referralPercent = 25;

    address[] public referralList;

    event SoldNFT(
        address indexed _caller,
        uint256 indexed _tokenId,
        uint256 indexed _count
    );

    /**
     * @dev Constructor of the contract.
     * @param _walletStoredFunds - Address of the recipient of the funds
     * @param _walletStoredNFT - Address stored NFTs
     * @param _erc1155Collection - Address of the collection
     * @param _tokenIds - List token ids for prices
     * @param _prices - prices in MANA
     * @param _rateMANAETH - rate of MANA in WEI (1e18 = 1eth)
     */
    constructor(
        address payable _walletStoredFunds,
        address payable _walletStoredNFT,
        IERC1155 _erc1155Collection,
        uint256[] memory _tokenIds,
        uint256[] memory _prices,
        uint256 _rateMANAETH
    )
    public {
        require(_tokenIds.length == _prices.length, "length for tokenIds and prices arrays must equals");
        walletStoredFunds = _walletStoredFunds;
        walletStoredNFT = _walletStoredNFT;
        erc1155Collection = _erc1155Collection;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 id = _tokenIds[i];
            uint256 price = _prices[i];
            priceByTokenId[id] = price;
        }
        rateMANAETH = _rateMANAETH;
    }

    /**
* @dev Buy NFT for ETH
* @param _nftId - nft id
* @param _count - count
* @param _data - Data to pass if receiver is contract
* @param _referral -referral address
*/
    function buyNFTForETHWithReferral(uint256 _nftId, uint256 _count, bytes memory _data, address payable _referral) public payable {
        require(_count >= 1, "Count must more or equal 1");

        uint256 currentBalance = erc1155Collection.balanceOf(walletStoredNFT, _nftId);
        require(_count <= currentBalance, "Not enough NFTs");

        uint256 price = SafeMath.mul(priceByTokenId[_nftId], rateMANAETH);
        require(price > 0, "Price not correct");
        require(msg.value == SafeMath.mul(price, _count), "Received ETH value not correct");

        if (_referral == address(0)) {
            walletStoredFunds.transfer(msg.value);
        } else {
            bool referralRegistered = false;

            for (uint256 i = 0; i < referralList.length; i++) {
                if (_referral == referralList[i]) {
                    referralRegistered = true;
                    break;
                }
            }
            if (referralRegistered) {
                require(referralPercent < 50 || referralPercent >= 1, "referral Percent not correct");
                uint256 referralFee = SafeMath.div(SafeMath.mul(msg.value, referralPercent), 100);
                require(referralFee < msg.value, "referral Percent not correct");
                _referral.transfer(referralFee);
                walletStoredFunds.transfer(msg.value - referralFee);
            } else {
                walletStoredFunds.transfer(msg.value);
            }
        }

        erc1155Collection.safeTransferFrom(walletStoredNFT, msg.sender, _nftId, _count, _data);

        emit SoldNFT(msg.sender, _nftId, _count);
    }

    /**
    * @dev Buy NFT for ETH
    * @param _nftId - nft id
    * @param _count - count
    * @param _data -Data to pass if receiver is contract
    */
    function buyNFTForETH(uint256 _nftId, uint256 _count, bytes calldata _data) external payable {
        return buyNFTForETHWithReferral(_nftId, _count, _data, address(0));
    }

    function setPrices(
        uint256[] memory _tokenIds,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 id = _tokenIds[i];
            uint256 price = _prices[i];
            priceByTokenId[id] = price;
        }
    }

    function getPrices(uint256[] memory _tokenIds)
    public view returns (uint256[] memory prices)
    {
        prices = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            prices[i] = priceByTokenId[_tokenIds[i]] * rateMANAETH;
        }
        return prices;
    }

    function setRate(
        uint256 _rateMANAETH
    ) public onlyOwner {
        rateMANAETH = _rateMANAETH;
    }

    function setReferralPercent(
        uint256 _val
    ) public onlyOwner {
        require(referralPercent < 50, "referral Percent not correct");
        require(referralPercent >= 1, "referral Percent not correct");
        referralPercent = _val;
    }

    function setWallet(
        address payable _wallet
    ) public onlyOwner {
        walletStoredFunds = _wallet;
    }

    function setWalletStoredNFT(
        address payable _wallet
    ) public onlyOwner {
        walletStoredNFT = _wallet;
    }

    function addReferrals(
        address[] memory _referralList
    ) public onlyOwner {
        for (uint256 i = 0; i < _referralList.length; i++) {
            referralList.push(_referralList[i]);
        }
    }
}