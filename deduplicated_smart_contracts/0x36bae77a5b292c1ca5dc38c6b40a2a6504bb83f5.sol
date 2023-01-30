/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

pragma solidity 0.5.10;

/**
 * Copyright © 2017-2019 Ramp Network sp. z o.o. All rights reserved (MIT License).
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
 * is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
 * AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


interface Erc20Token {

    /**
     * Send `_value` of tokens from `msg.sender` to `_to`
     *
     * @param _to The recipient address
     * @param _value The amount of tokens to be transferred
     * @return Indication if the transfer was successful
     */
    function transfer(address _to, uint256 _value) external returns (bool success);

    /**
     * Approve `_spender` to withdraw from sender's account multiple times, up to `_value`
     * amount. If this function is called again it overwrites the current allowance with _value.
     *
     * @param _spender The address allowed to operate on sender's tokens
     * @param _value The amount of tokens allowed to be transferred
     * @return Indication if the approval was successful
     */
    function approve(address _spender, uint256 _value) external returns (bool success);

    /**
     * Transfer tokens on behalf of `_from`, provided it was previously approved.
     *
     * @param _from The transfer source address (tokens owner)
     * @param _to The transfer destination address
     * @param _value The amount of tokens to be transferred
     * @return Indication if the approval was successful
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * Returns the account balance of another account with address `_owner`.
     */
    function balanceOf(address _owner) external view returns (uint256);

}

contract AssetAdapter {

    uint16 public ASSET_TYPE;

    constructor(
        uint16 assetType
    ) internal {
        ASSET_TYPE = assetType;
    }

    /**
     * Ensure the described asset is sent to the given address.
     * Should revert if the transfer failed, but callers must also handle `false` being returned,
     * much like ERC-20's `transfer`.
     */
    function rawSendAsset(
        bytes memory assetData,
        uint256 _amount,
        address payable _to
    ) internal returns (bool success);  // solium-disable-line indentation
    // indentation rule bug ^ https://github.com/duaraghav8/Ethlint/issues/268

    /**
     * Ensure the described asset is sent to this contract.
     * Should revert if the transfer failed, but callers must also handle `false` being returned,
     * much like ERC-20's `transfer`.
     */
    function rawLockAsset(
        uint256 amount,
        address payable _from
    ) internal returns (bool success) {
        return RampInstantPoolInterface(_from).sendFundsToSwap(amount);
    }

    function getAmount(bytes memory assetData) internal pure returns (uint256);

    /**
     * Verify that the passed asset data can be handled by this adapter and given pool.
     *
     * @dev it's sufficient to use this only when creating a new swap -- all the other swap
     * functions first check if the swap hash is valid, while a swap hash with invalid
     * asset type wouldn't be created at all.
     *
     * @dev asset type is 2 bytes long, and it's at offset 32 in `assetData`'s memory (the first 32
     * bytes are the data length). We load the word at offset 2 (it ends with the asset type bytes),
     * and retrieve its last 2 bytes into a `uint16` variable.
     */
    modifier checkAssetTypeAndData(bytes memory assetData, address _pool) {
        uint16 assetType;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            assetType := and(
                mload(add(assetData, 2)),
                0xffff
            )
        }
        require(assetType == ASSET_TYPE, "invalid asset type");
        checkAssetData(assetData, _pool);
        _;
    }

    function checkAssetData(bytes memory assetData, address _pool) internal view;

    function () external payable {
        revert("this contract cannot receive ether");
    }

}

contract RampInstantPoolInterface {

    uint16 public ASSET_TYPE;

    function sendFundsToSwap(uint256 _amount)
        public /*onlyActive onlySwapsContract isWithinLimits*/ returns(bool success);

}

contract RampInstantTokenPoolInterface is RampInstantPoolInterface {

    address public token;

}

contract Ownable {

    address public owner;

    event OwnerChanged(address oldOwner, address newOwner);

    constructor() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can call this");
        _;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit OwnerChanged(msg.sender, _newOwner);
    }

}

contract WithStatus is Ownable {

    enum Status {
        STOPPED,
        RETURN_ONLY,
        FINALIZE_ONLY,
        ACTIVE
    }

    event StatusChanged(Status oldStatus, Status newStatus);

    Status public status = Status.ACTIVE;

    function setStatus(Status _status) external onlyOwner {
        emit StatusChanged(status, _status);
        status = _status;
    }

    modifier statusAtLeast(Status _status) {
        require(status >= _status, "invalid contract status");
        _;
    }

}

contract WithOracles is Ownable {

    mapping (address => bool) oracles;

    constructor() internal {
        oracles[msg.sender] = true;
    }

    function approveOracle(address _oracle) external onlyOwner {
        oracles[_oracle] = true;
    }

    function revokeOracle(address _oracle) external onlyOwner {
        oracles[_oracle] = false;
    }

    modifier isOracle(address _oracle) {
        require(oracles[_oracle], "invalid oracle address");
        _;
    }

    modifier onlyOracleOrPool(address _pool, address _oracle) {
        require(
            msg.sender == _pool || (msg.sender == _oracle && oracles[msg.sender]),
            "only the oracle or the pool can call this"
        );
        _;
    }

}

contract WithSwapsCreator is Ownable {

    address internal swapCreator;

    event SwapCreatorChanged(address _oldCreator, address _newCreator);

    constructor() internal {
        swapCreator = msg.sender;
    }

    function changeSwapCreator(address _newCreator) public onlyOwner {
        swapCreator = _newCreator;
        emit SwapCreatorChanged(msg.sender, _newCreator);
    }

    modifier onlySwapCreator() {
        require(msg.sender == swapCreator, "only the swap creator can call this");
        _;
    }

}

contract AssetAdapterWithFees is Ownable, AssetAdapter {

    uint16 public feeThousandthsPercent;
    uint256 public minFeeAmount;

    constructor(uint16 _feeThousandthsPercent, uint256 _minFeeAmount) public {
        require(_feeThousandthsPercent < (1 << 16), "fee % too high");
        require(_minFeeAmount <= (1 << 255), "minFeeAmount too high");
        feeThousandthsPercent = _feeThousandthsPercent;
        minFeeAmount = _minFeeAmount;
    }

    function rawAccumulateFee(bytes memory assetData, uint256 _amount) internal;

    function accumulateFee(bytes memory assetData) internal {
        rawAccumulateFee(assetData, getFee(getAmount(assetData)));
    }

    function withdrawFees(
        bytes calldata assetData,
        address payable _to
    ) external /*onlyOwner*/ returns (bool success);  // solium-disable-line indentation

    function getFee(uint256 _amount) internal view returns (uint256) {
        uint256 fee = _amount * feeThousandthsPercent / 100000;
        return fee < minFeeAmount
            ? minFeeAmount
            : fee;
    }

    function getAmountWithFee(bytes memory assetData) internal view returns (uint256) {
        uint256 baseAmount = getAmount(assetData);
        return baseAmount + getFee(baseAmount);
    }

    function lockAssetWithFee(
        bytes memory assetData,
        address payable _from
    ) internal returns (bool success) {
        return rawLockAsset(getAmountWithFee(assetData), _from);
    }

    function sendAssetWithFee(
        bytes memory assetData,
        address payable _to
    ) internal returns (bool success) {
        return rawSendAsset(assetData, getAmountWithFee(assetData), _to);
    }

    function sendAssetKeepingFee(
        bytes memory assetData,
        address payable _to
    ) internal returns (bool success) {
        bool result = rawSendAsset(assetData, getAmount(assetData), _to);
        if (result) accumulateFee(assetData);
        return result;
    }

}

/**
 * The main contract managing Ramp Swaps escrows lifecycle: create, release or return.
 * Uses an abstract AssetAdapter to carry out the transfers and handle the particular asset data.
 * With a corresponding off-chain oracle protocol allows for atomic-swap-like transfer between
 * fiat currencies and crypto assets.
 *
 * @dev an active swap is represented by a hash of its details, mapped to its escrow expiration
 * timestamp. When the swap is created, its end time is set a given amount of time in the future
 * (but within {MIN,MAX}_SWAP_LOCK_TIME_S).
 * The hashed swap details are:
 *  * address pool: the `RampInstantPool` contract that sells the crypto asset;
 *  * address receiver: the user that buys the crypto asset;
 *  * address oracle: address of the oracle that handles this particular swap;
 *  * bytes assetData: description of the crypto asset, handled by an AssetAdapter;
 *  * bytes32 paymentDetailsHash: hash of the fiat payment details: account numbers, fiat value
 *    and currency, and the transfer reference (title), that can be verified off-chain.
 *
 * @author Ramp Network sp. z o.o.
 */
contract RampInstantEscrows
is Ownable, WithStatus, WithOracles, WithSwapsCreator, AssetAdapterWithFees {

    /// @dev contract version, defined in semver
    string public constant VERSION = "0.5.1";

    uint32 internal constant MIN_ACTUAL_TIMESTAMP = 1000000000;

    /// @notice lock time limits for pool's assets, after which unreleased escrows can be returned
    uint32 internal constant MIN_SWAP_LOCK_TIME_S = 24 hours;
    uint32 internal constant MAX_SWAP_LOCK_TIME_S = 30 days;

    event Created(bytes32 indexed swapHash);
    event Released(bytes32 indexed swapHash);
    event PoolReleased(bytes32 indexed swapHash);
    event Returned(bytes32 indexed swapHash);
    event PoolReturned(bytes32 indexed swapHash);

    /**
     * @notice Mapping from swap details hash to its end time (as a unix timestamp).
     * After the end time the swap can be cancelled, and the funds will be returned to the pool.
     */
    mapping (bytes32 => uint32) internal swaps;

    /**
     * Swap creation, called by the Ramp Network. Checks swap parameters and ensures the crypto
     * asset is locked on this contract.
     *
     * Emits a `Created` event with the swap hash.
     */
    function create(
        address payable _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash,
        uint32 lockTimeS
    )
        external
        statusAtLeast(Status.ACTIVE)
        onlySwapCreator()
        isOracle(_oracle)
        checkAssetTypeAndData(_assetData, _pool)
        returns
        (bool success)
    {
        require(
            lockTimeS >= MIN_SWAP_LOCK_TIME_S && lockTimeS <= MAX_SWAP_LOCK_TIME_S,
            "lock time outside limits"
        );
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        requireSwapNotExists(swapHash);
        // Set up swap status before transfer, to avoid reentrancy attacks.
        // Even if a malicious token is somehow passed to this function (despite the oracle
        // signature of its details), the state of this contract is already fully updated,
        // so it will behave correctly (as it would be a separate call).
        // solium-disable-next-line security/no-block-members
        swaps[swapHash] = uint32(block.timestamp) + lockTimeS;
        require(
            lockAssetWithFee(_assetData, _pool),
            "escrow lock failed"
        );
        emit Created(swapHash);
        return true;
    }

    /**
     * Swap release, which transfers the crypto asset to the receiver and removes the swap from
     * the active swap mapping. Normally called by the swap's oracle after it confirms a matching
     * wire transfer on pool's bank account. Can be also called by the pool, for example in case
     * of a dispute, when the parties reach an agreement off-chain.
     *
     * Emits a `Released` or `PoolReleased` event with the swap's hash.
     */
    function release(
        address _pool,
        address payable _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external statusAtLeast(Status.FINALIZE_ONLY) onlyOracleOrPool(_pool, _oracle) {
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        requireSwapCreated(swapHash);
        // Delete the swap status before transfer, to avoid reentrancy attacks.
        swaps[swapHash] = 0;
        require(
            sendAssetKeepingFee(_assetData, _receiver),
            "asset release failed"
        );
        if (msg.sender == _pool) {
            emit PoolReleased(swapHash);
        } else {
            emit Released(swapHash);
        }
    }

    /**
     * Swap return, which transfers the crypto asset back to the pool and removes the swap from
     * the active swap mapping. Can be called by the pool or the swap's oracle, but only if the
     * escrow lock time expired.
     *
     * Emits a `Returned` or `PoolReturned` event with the swap's hash.
     */
    function returnFunds(
        address payable _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external statusAtLeast(Status.RETURN_ONLY) onlyOracleOrPool(_pool, _oracle) {
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        requireSwapExpired(swapHash);
        // Delete the swap status before transfer, to avoid reentrancy attacks.
        swaps[swapHash] = 0;
        require(
            sendAssetWithFee(_assetData, _pool),
            "asset return failed"
        );
        if (msg.sender == _pool) {
            emit PoolReturned(swapHash);
        } else {
            emit Returned(swapHash);
        }
    }

    /**
     * Given all valid swap details, returns its status. The return can be:
     * 0: the swap details are invalid, swap doesn't exist, or was already released/returned.
     * >1: the swap was created, and the value is a timestamp indicating end of its lock time.
     */
    function getSwapStatus(
        address _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external view returns (uint32 status) {
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        return swaps[swapHash];
    }

    /**
     * Calculates the swap hash used to reference the swap in this contract's storage.
     */
    function getSwapHash(
        address _pool,
        address _receiver,
        address _oracle,
        bytes32 assetHash,
        bytes32 _paymentDetailsHash
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                _pool, _receiver, _oracle, assetHash, _paymentDetailsHash
            )
        );
    }

    function requireSwapNotExists(bytes32 swapHash) internal view {
        require(
            swaps[swapHash] == 0,
            "swap already exists"
        );
    }

    function requireSwapCreated(bytes32 swapHash) internal view {
        require(
            swaps[swapHash] > MIN_ACTUAL_TIMESTAMP,
            "swap invalid"
        );
    }

    function requireSwapExpired(bytes32 swapHash) internal view {
        require(
            // solium-disable-next-line security/no-block-members
            swaps[swapHash] > MIN_ACTUAL_TIMESTAMP && block.timestamp > swaps[swapHash],
            "swap not expired or invalid"
        );
    }

}

contract TokenAdapter is AssetAdapterWithFees {

    uint16 internal constant TOKEN_TYPE_ID = 2;
    uint16 internal constant TOKEN_ASSET_DATA_LENGTH = 54;
    mapping (address => uint256) internal accumulatedFees;

    constructor() internal AssetAdapter(TOKEN_TYPE_ID) {}

    /**
    * @dev token assetData bytes contents:
    * offset length type     contents
    * +00    32     uint256  data length (== 0x36 == 54 bytes)
    * +32     2     uint16   asset type  (== TOKEN_TYPE_ID == 2)
    * +34    32     uint256  token amount in units
    * +66    20     address  token contract address
    */
    function getAmount(bytes memory assetData) internal pure returns (uint256 amount) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            amount := mload(add(assetData, 34))
        }
    }

    /**
     * @dev To retrieve the address at offset 66, get the word at offset 54 and return its last
     * 20 bytes. See `getAmount` for byte offsets table.
     */
    function getTokenAddress(bytes memory assetData) internal pure returns (address tokenAddress) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            tokenAddress := and(
                mload(add(assetData, 54)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }

    function rawSendAsset(
        bytes memory assetData,
        uint256 _amount,
        address payable _to
    ) internal returns (bool success) {
        Erc20Token token = Erc20Token(getTokenAddress(assetData));
        return token.transfer(_to, _amount);
    }

    function rawAccumulateFee(bytes memory assetData, uint256 _amount) internal {
        accumulatedFees[getTokenAddress(assetData)] += _amount;
    }

    function withdrawFees(
        bytes calldata assetData,
        address payable _to
    ) external onlyOwner returns (bool success) {
        address token = getTokenAddress(assetData);
        uint256 fees = accumulatedFees[token];
        accumulatedFees[token] = 0;
        require(Erc20Token(token).transfer(_to, fees), "fees transfer failed");
        return true;
    }

    function checkAssetData(bytes memory assetData, address _pool) internal view {
        require(assetData.length == TOKEN_ASSET_DATA_LENGTH, "invalid asset data length");
        require(
            RampInstantTokenPoolInterface(_pool).token() == getTokenAddress(assetData),
            "invalid pool token address"
        );
    }

}

contract RampInstantTokenEscrows is RampInstantEscrows, TokenAdapter {

    constructor(
        uint16 _feeThousandthsPercent,
        uint256 _minFeeAmount
    ) public AssetAdapterWithFees(_feeThousandthsPercent, _minFeeAmount) {}

}