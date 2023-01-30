/**
 *Submitted for verification at Etherscan.io on 2020-07-27
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


/**
 * A standard, simple transferrable contract ownership.
 */
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


/**
 * A contract that can be stopped/restarted by its owner.
 */
contract Stoppable is Ownable {

    bool public isActive = true;

    event IsActiveChanged(bool _isActive);

    modifier onlyActive() {
        require(isActive, "contract is stopped");
        _;
    }

    function setIsActive(bool _isActive) external onlyOwner {
        if (_isActive == isActive) return;
        isActive = _isActive;
        emit IsActiveChanged(_isActive);
    }

}

/**
 * A simple interface used by the escrows contract (precisely AssetAdapters) to interact
 * with the liquidity pools.
 */
contract RampInstantPoolInterface {

    uint16 public ASSET_TYPE;

    function sendFundsToSwap(uint256 _amount)
        public /*onlyActive onlySwapsContract isWithinLimits*/ returns(bool success);

}

contract RampInstantTokenPoolInterface is RampInstantPoolInterface {

    address public token;

}

/**
 * An interface of the RampInstantEscrows functions that are used by the liquidity pool contracts.
 * See RampInstantEscrows.sol for more comments.
 */
contract RampInstantEscrowsPoolInterface {

    uint16 public ASSET_TYPE;

    function release(
        address _pool,
        address payable _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    )
        external; /*statusAtLeast(Status.FINALIZE_ONLY) onlyOracleOrPool(_pool, _oracle)*/

    function returnFunds(
        address payable _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    )
        external; /*statusAtLeast(Status.RETURN_ONLY) onlyOracleOrPool(_pool, _oracle)*/

}

/**
 * An abstract Ramp Instant Liquidity Pool. A liquidity provider deploys an instance of this
 * contract, and sends his funds to it. The escrows contract later withdraws portions of these
 * funds to be locked. The owner can withdraw any part of the funds at any time, or temporarily
 * block creating new escrows by stopping the contract.
 *
 * The pool owner can set and update min/max swap amounts, with an upper limit of 2^240 wei/units
 * (see `AssetAdapterWithFees` for more info).
 *
 * The paymentDetailsHash parameters works the same as in the `RampInstantEscrows` contract, only
 * with 0 value and empty transfer title. It describes the bank account where the pool owner expects
 * to be paid, and can be used to validate that a created swap indeed uses the same account.
 *
 * @author Ramp Network sp. z o.o.
 */
contract RampInstantPool is Ownable, Stoppable, RampInstantPoolInterface {

    uint256 constant private MAX_SWAP_AMOUNT_LIMIT = 1 << 240;
    uint16 public ASSET_TYPE;

    address payable public swapsContract;
    uint256 public minSwapAmount;
    uint256 public maxSwapAmount;
    bytes32 public paymentDetailsHash;

    /**
     * Triggered when the pool receives new funds, either a topup, or a returned escrow from an old
     * swaps contract if it was changed. Avilable for ETH, ERC-223 and ERC-777 token pools.
     * Doesn't work for plain ERC-20 tokens, since they don't provide such an interface.
     */
    event ReceivedFunds(address _from, uint256 _amount);
    event LimitsChanged(uint256 _minAmount, uint256 _maxAmount);
    event SwapsContractChanged(address _oldAddress, address _newAddress);

    constructor(
        address payable _swapsContract,
        uint256 _minSwapAmount,
        uint256 _maxSwapAmount,
        bytes32 _paymentDetailsHash,
        uint16 _assetType
    )
        public
        validateLimits(_minSwapAmount, _maxSwapAmount)
        validateSwapsContract(_swapsContract, _assetType)
    {
        swapsContract = _swapsContract;
        paymentDetailsHash = _paymentDetailsHash;
        minSwapAmount = _minSwapAmount;
        maxSwapAmount = _maxSwapAmount;
        ASSET_TYPE = _assetType;
    }

    function availableFunds() public view returns (uint256);

    function withdrawFunds(address payable _to, uint256 _amount)
        public /*onlyOwner*/ returns (bool success);

    function withdrawAllFunds(address payable _to) public onlyOwner returns (bool success) {
        return withdrawFunds(_to, availableFunds());
    }

    function setLimits(
        uint256 _minAmount,
        uint256 _maxAmount
    ) public onlyOwner validateLimits(_minAmount, _maxAmount) {
        minSwapAmount = _minAmount;
        maxSwapAmount = _maxAmount;
        emit LimitsChanged(_minAmount, _maxAmount);
    }

    function setSwapsContract(
        address payable _swapsContract
    ) public onlyOwner validateSwapsContract(_swapsContract, ASSET_TYPE) {
        address oldSwapsContract = swapsContract;
        swapsContract = _swapsContract;
        emit SwapsContractChanged(oldSwapsContract, _swapsContract);
    }

    function sendFundsToSwap(uint256 _amount)
        public /*onlyActive onlySwapsContract isWithinLimits*/ returns(bool success);

    function releaseSwap(
        address payable _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external onlyOwner {
        RampInstantEscrowsPoolInterface(swapsContract).release(
            address(this),
            _receiver,
            _oracle,
            _assetData,
            _paymentDetailsHash
        );
    }

    function returnSwap(
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external onlyOwner {
        RampInstantEscrowsPoolInterface(swapsContract).returnFunds(
            address(this),
            _receiver,
            _oracle,
            _assetData,
            _paymentDetailsHash
        );
    }

    /**
     * Needed for address(this) to be payable in call to returnFunds.
     * The Eth pool overrides this to not throw.
     */
    function () external payable {
        revert("this pool cannot receive ether");
    }

    modifier onlySwapsContract() {
        require(msg.sender == swapsContract, "only the swaps contract can call this");
        _;
    }

    modifier isWithinLimits(uint256 _amount) {
        require(_amount >= minSwapAmount && _amount <= maxSwapAmount, "amount outside swap limits");
        _;
    }

    modifier validateLimits(uint256 _minAmount, uint256 _maxAmount) {
        require(_minAmount <= _maxAmount, "min limit over max limit");
        require(_maxAmount <= MAX_SWAP_AMOUNT_LIMIT, "maxAmount too high");
        _;
    }

    modifier validateSwapsContract(address payable _swapsContract, uint16 _assetType) {
        require(_swapsContract != address(0), "null swaps contract address");
        require(
            RampInstantEscrowsPoolInterface(_swapsContract).ASSET_TYPE() == _assetType,
            "pool asset type doesn't match swap contract"
        );
        _;
    }

}

/**
 * @title partial ERC-20 Token interface according to official documentation:
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
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

/**
 * Partial ERC-1820 registry
 * https://github.com/0xjac/ERC1820/blob/master/contracts/ERC1820Client.sol
 */
contract ERC1820Registry {
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;
}


/**
 * https://github.com/0xjac/ERC777/blob/devel/contracts/examples/ExampleTokensRecipient.sol
 */
contract ERC777TokenRecipient {

    ERC1820Registry internal constant ERC1820REGISTRY = ERC1820Registry(
        0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    );
    bytes32 internal constant ERC777TokenRecipientERC1820Hash = keccak256(
        abi.encodePacked("ERC777TokensRecipient")
    );
    bytes32 constant internal ERC1820_ACCEPT_MAGIC = keccak256(
        abi.encodePacked("ERC1820_ACCEPT_MAGIC")
    );

    constructor(bool _doSetErc1820Registry) internal {
        if (_doSetErc1820Registry) {
            ERC1820REGISTRY.setInterfaceImplementer(
                address(this),
                ERC777TokenRecipientERC1820Hash,
                address(this)
            );
        }
    }

    function canImplementInterfaceForAddress(
        bytes32 _interfaceHash,
        address _addr
    ) external view returns(bytes32) {
        if (_interfaceHash == ERC777TokenRecipientERC1820Hash && _addr == address(this)) {
            return ERC1820_ACCEPT_MAGIC;
        }
        return 0;
    }

    function tokensReceived(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data,
        bytes calldata _operatorData) external;

}

/**
 * A pool that implements handling of ERC-20-compatible token assets. See `RampInstantPool`.
 *
 * For ERC-777 tokens, enable `_doSetErc1820Registry` on deployment, if you want to receive the
 * `ReceivedFunds` events. For ERC-223 tokens no actions are needed. For plain ERC-20 tokens, that
 * event is not available.
 *
 * @author Ramp Network sp. z o.o.
 */
contract RampInstantTokenPool is RampInstantPool, ERC777TokenRecipient {

    uint16 internal constant TOKEN_TYPE_ID = 2;
    Erc20Token public token;

    constructor(
        address payable _swapsContract,
        uint256 _minSwapAmount,
        uint256 _maxSwapAmount,
        bytes32 _paymentDetailsHash,
        address _tokenAddress,
        bool _doSetErc1820Registry
    )
        public
        RampInstantPool(
            _swapsContract, _minSwapAmount, _maxSwapAmount, _paymentDetailsHash, TOKEN_TYPE_ID
        )
        ERC777TokenRecipient(_doSetErc1820Registry)
    {
        token = Erc20Token(_tokenAddress);
    }

    function availableFunds() public view returns(uint256) {
        return token.balanceOf(address(this));
    }

    function withdrawFunds(
        address payable _to,
        uint256 _amount
    ) public onlyOwner returns (bool success) {
        return token.transfer(_to, _amount);
    }

    function sendFundsToSwap(
        uint256 _amount
    ) public onlyActive onlySwapsContract isWithinLimits(_amount) returns(bool success) {
        return token.transfer(swapsContract, _amount);
    }

    /** ERC-223 token fallback function */
    function tokenFallback(address _from, uint _value, bytes memory _data) public {
        require(_data.length == 0, "tokens with data not supported");
        if (_from != swapsContract) {
            emit ReceivedFunds(_from, _value);
        }
    }

    /** ERC-777 token received hook */
    function tokensReceived(
        address /*_operator*/,
        address _from,
        address /*_to*/,
        uint256 _amount,
        bytes calldata _data,
        bytes calldata /*_operatorData*/
    ) external {
        require(_data.length == 0, "tokens with data not supported");
        if (_from != swapsContract) {
            emit ReceivedFunds(_from, _amount);
        }
    }

}