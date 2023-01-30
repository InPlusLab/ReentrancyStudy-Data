/**
 *Submitted for verification at Etherscan.io on 2020-07-15
*/

/**
 *Submitted for verification at Etherscan.io on 2020-05-26
*/

pragma solidity ^0.5.4;

interface IDToken {
	function mint(address _dst, uint _pie) external;
    function burn(address _src, uint _wad) external;
    function redeem(address _src, uint _pie) external;

    function getTokenRealBalance(address _src) external view returns (uint);
    function getLiquidity() external view returns (uint);
    function token() external view returns (address);
}

interface IPriceOracle {
	function assetPrices(address _asset) external view returns (uint);
}

library DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-overflow");
        z = x / y;
    }
}

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
    event OwnerUpdate     (address indexed owner, address indexed newOwner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;
    address      public  newOwner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    // Warning: you should absolutely sure you want to give up authority!!!
    function disableOwnership() public onlyOwner {
        owner = address(0);
        emit OwnerUpdate(msg.sender, owner);
    }

    function transferOwnership(address newOwner_) public onlyOwner {
        require(newOwner_ != owner, "TransferOwnership: the same owner.");
        newOwner = newOwner_;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner, "AcceptOwnership: only new owner do this.");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0x0);
    }

    ///[snow] guard is Authority who inherit DSAuth.
    function setAuthority(DSAuthority authority_)
        public
        onlyOwner
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier onlyOwner {
        require(isOwner(msg.sender), "ds-auth-non-owner");
        _;
    }

    function isOwner(address src) internal view returns (bool) {
        return bool(src == owner);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

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
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    bool internal notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, notEntered will be true
        require(notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        notEntered = true;
    }
}

interface IERC20 {
    function transfer(address _to, uint _value) external;
    function transferFrom(address _from, address _to, uint _value) external;
    function approve(address _spender, uint _value) external;
    function balanceOf(address account) external view returns (uint);
	function allowance(address _owner, address _spender) external view returns (uint);
    function decimals() external view returns (uint);
}

contract ERC20SafeTransfer {
    function doTransferOut(address _token, address _to, uint _amount) internal returns (bool) {
        IERC20 token = IERC20(_token);
        bool result;

        token.transfer(_to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }

    function doTransferFrom(address _token, address _from, address _to, uint _amount) internal returns (bool) {
        IERC20 token = IERC20(_token);
        bool result;

        token.transferFrom(_from, _to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }

    function doApprove(address _token, address _to, uint _amount) internal returns (bool) {
        IERC20 token = IERC20(_token);
        bool result;

        token.approve(_to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }
}

contract XSwap is DSAuth, ReentrancyGuard, ERC20SafeTransfer {
    using DSMath for uint;

    uint constant internal OFFSET = 10 ** 18;
    bool private actived;
    uint public maxSwing;

    address public oracle;
    mapping(address => mapping(address => uint)) public fee;  // Fee for exchange from tokenA to tokenB

    bool public isOpen;  // The state of contract
    mapping(address => bool) public tokensEnable;  // Support this token or not
    // Trade pair supports or not
    mapping(address => mapping(address => bool)) public tradesDisable;

    mapping(address => address) public supportDToken;
    mapping(address => address) public remainingDToken;

    bool public paused;

    event Swap(
        address from,
        address to,
        address input,
        uint inputAmount,
        uint inputPrice,
        address output,
        uint outputAmount,
        uint outputPrice
    );

    event SetOracle(address oracle);
    event SetMaxSwing(uint maxSwing);
    event SetFee(address input, address output, uint fee);
    event Paused(address admin);
    event Unpaused(address admin);
    event EmergencyStop(bool isOpen);
    event DisableToken(address token);
    event EnableToken(address token);
    event DisableTrade(address input, address output);
    event EnableTrade(address input, address output);
    event DisableDToken(address DToken, address token, uint DTokenBalance);
    event EnableDToken(address DToken, address token, uint DTokenBalance);
    event TransferIn(address token, uint amount, uint balance);
    event TransferOut(address token, address receiver, uint amount, uint balance);

    constructor() public {
    }

    // --- Init ---
    // This function is used with contract proxy, do not modify this function.
    function active(address _oracle) external {
        require(actived == false, "active: Already actived!");
        owner = msg.sender;
        isOpen = true;
        oracle = _oracle;
        maxSwing = 15 * 10 ** 17;
        notEntered = true;
        actived = true;
    }

    // ****************************
    // *** Authorized functions ***
    // ****************************

    /**
     * @notice Only authorized users can call this function.
     * @dev Sets a new oracle contract address.
     * @param _oracle New oracle contract.
     */
    function setOracle(address _oracle) external auth {
        oracle = _oracle;
        emit SetOracle(_oracle);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Set a new maxSwing value.
     * @param _maxSwing New maxSwing value.
     */
    function setMaxSwing(uint _maxSwing) external auth {
        require(_maxSwing >= OFFSET && _maxSwing <= OFFSET.mul(2), "setMaxSwing: New maxSwing non-compliant");
        maxSwing = _maxSwing;
        emit SetMaxSwing(_maxSwing);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Sets trading fee for specified trade pair.
     * @param _input One asset in the trade pair.
     * @param _output The other asset in the trade pair.
     * @param _fee Trading fee when swaps these two tokens.
     */
    function setFee(address _input, address _output, uint _fee) public auth {
        fee[_input][_output] = _fee;
        fee[_output][_input] = _fee;
        emit SetFee(_input, _output, _fee);
    }

    function setFeeBatch(address[] calldata _input, address[] calldata _output, uint[] calldata _fee) external auth {
        require(_input.length == _output.length && _input.length == _fee.length, "setFeeBatch: ");
        for (uint i = 0; i < _input.length; i++) {
            require(_input[i] != _output[i], "setFeeBatch: ");
            setFee(_input[i], _output[i], _fee[i]);
        }
    }

    /**
     * @dev Called by the authorized users to pause, triggers stopped state.
     */
    function pause() public auth {
        require(!paused, "pause: paused");
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by the authorized users to unpause, returns to normal state.
     */
    function unpause() public auth {
        require(paused, "unpause: not paused");
        paused = false;
        emit Unpaused(msg.sender);
        
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Changes the contract state.
     * @param _changeStateTo True means unpause contract, and false means pause conntract.
     */
    function emergencyStop(bool _changeStateTo) external auth {
        isOpen = _changeStateTo;
        emit EmergencyStop(_changeStateTo);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Suspends a given asset.
     * @param _token Asset to suspend.
     */
    function disableToken(address _token) external auth {
        tokensEnable[_token] = false;
        emit DisableToken(_token);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Supports a given asset.
     * @param _token Asset to support.
     */
    function enableToken(address _token) external auth {
        tokensEnable[_token] = true;
        emit EnableToken(_token);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Suspends a given trade pair.
     * @param _input One asset in the trade pair.
     * @param _output The other asset in the trade pair.
     */
    function disableTrade(address _input, address _output) external auth {
        tradesDisable[_input][_output] = true;
        tradesDisable[_output][_input] = true;
        emit DisableTrade(_input, _output);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Supports a given trade pair.
     * @param _input One asset in the trade pair.
     * @param _output The other asset in the trade pair.
     */
    function enableTrade(address _input, address _output) external auth {
        tradesDisable[_input][_output] = false;
        tradesDisable[_output][_input] = false;
        emit EnableTrade(_input, _output);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Suspends a given dToken.
     * @param _dToken dToken to suspend.
     */
    function disableDToken(address _dToken) external auth {
        address _token = IDToken(_dToken).token();
        require(supportDToken[_token] == _dToken, "disableDToken: Does not support!");

        (uint _tokenBalance, bool flag) = getRedeemAmount(_dToken);

        if (_tokenBalance > 0)
            IDToken(_dToken).redeem(address(this), _tokenBalance);

        if (!flag)
            remainingDToken[_token] = _dToken;

        supportDToken[_token] = address(0);
        emit DisableDToken(_dToken, _token, IERC20(_dToken).balanceOf(address(this)));
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Supports a given dToken.
     * @param _dToken dToken to support.
     */
    function enableDToken(address _dToken) external auth {
        address _token = IDToken(_dToken).token();
        supportDToken[_token] = _dToken;
        remainingDToken[_token] = address(0);

        if (IERC20(_token).allowance(address(this), _dToken) != uint(-1))
            require(doApprove(_token, _dToken, uint(-1)), "enableDToken: Approve failed!");

        uint _balance = IERC20(_token).balanceOf(address(this));
        if (_balance > 0)
            IDToken(_dToken).mint(address(this), _balance);

        emit EnableDToken(_dToken, _token, IERC20(_dToken).balanceOf(address(this)));
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Transfer `_amount` asset`_token` to the contract.
     * @param _token Asset will be transfered into the contract.
     * @param _amount Amount will be transfered into the contract.
     */
    function transferIn(address _token, uint _amount) external auth {
        require(doTransferFrom(_token, msg.sender, address(this), _amount), "transferIn: TransferFrom failed!");
        uint _balance = IERC20(_token).balanceOf(address(this));

        address _dToken = supportDToken[_token];
        if (_dToken != address(0) && _balance > 0)
            IDToken(_dToken).mint(address(this), _balance);
        emit TransferIn(_token, _amount, _balance);
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Transfer out `_amount` asset`_token` from the contract.
     * @param _token Asset will be transfered out from the contract.
     * @param _receiver Account who will receive asset.
     * @param _amount Specificed amount will be transfered out from the contract.
     */
    function transferOut(address _token, address _receiver, uint _amount) external auth {
        address _dToken = supportDToken[_token] == address(0) ? remainingDToken[_token] : supportDToken[_token];
        if (_dToken != address(0)) {

            (uint _tokenBalance, bool flag) = getRedeemAmount(_dToken);
            IDToken(_dToken).redeem(address(this), remainingDToken[_token] == _dToken ? _tokenBalance : _amount);
            if (flag)
                remainingDToken[_token] = address(0);
        }

        uint _balance = IERC20(_token).balanceOf(address(this));
        if (_balance >= _amount)
            require(doTransferOut(_token, _receiver, _amount), "transferOut: Transfer out failed!");

        emit TransferOut(_token, _receiver, _amount, IERC20(_token).balanceOf(address(this)));
    }

    /**
     * @notice Only authorized users can call this function.
     * @dev Transfer out all asset`_token` from the contract.
     * @param _token Asset will be transfered out from the contract.
     * @param _receiver Account who will receive asset.
     */
    function transferOutALL(address _token, address _receiver) external auth {
        address _dToken = supportDToken[_token] == address(0) ? remainingDToken[_token] : supportDToken[_token];
        if (_dToken != address(0)) {

            (uint _tokenBalance, bool flag) = getRedeemAmount(_dToken);
            require(flag, "transferOutALL: Lack of liquidity!");
            if (_tokenBalance > 0)
                IDToken(_dToken).redeem(address(this), _tokenBalance);
            remainingDToken[_token] = address(0);
        }
        uint _balance = IERC20(_token).balanceOf(address(this));
        if (_balance > 0)
            require(doTransferOut(_token, _receiver, _balance), "transferOutALL: Transfer out all failed!");

        emit TransferOut(_token, _receiver, _balance, IERC20(_token).balanceOf(address(this)));
    }

    // **************************
    // *** Internal functions ***
    // **************************

    /**
     * @dev Calculates valid amount can redeem from dToken.
     * @param _dToken dToken which will be redeemed.
     */
    function getRedeemAmount(address _dToken) internal view returns (uint, bool) {
        uint _tokenBalance = IDToken(_dToken).getTokenRealBalance(address(this));
        uint _balance = IDToken(_dToken).getLiquidity();
        if (_balance < _tokenBalance)
            return (_balance, false);

        return (_tokenBalance, true);
    }

    /**
     * @dev Calculates the exchange rate between two assets.
     * @param _input One asset in the trade pair.
     * @param _inputAmount Amount of input asset`input`.
     * @param _output The other asset in the trade pair.
     * @param _outputAmount Amount of output asset`_output`.
     */
    function getExchangeRate(address _input, uint _inputAmount, address _output, uint _outputAmount) internal view returns (uint) {
        uint _decimals = IERC20(_input).decimals();
        _inputAmount = _decimals < 18 ? _inputAmount.mul(10 ** (18 - _decimals)) : _inputAmount / (10 ** (_decimals - 18));
        _decimals = IERC20(_output).decimals();
        _outputAmount = _decimals < 18 ? _outputAmount.mul(10 ** (18 - _decimals)) : _outputAmount / (10 ** (_decimals - 18));
        return _inputAmount.mul(OFFSET).div(_outputAmount);
    }

    // ************************
    // *** Public functions ***
    // ************************

    /**
     * @dev Swaps `_inputAmount`asset to get another asset`_output`.
     * @param _input Asset that user wants to consume.
     * @param _output Asset that user wants to get.
     * @param _inputAmount Amount of asset consumed.
     */
    function swap(address _input, address _output, uint _inputAmount) external {
        swap(_input, _output, _inputAmount, msg.sender);
    }

    function swap(address _input, address _output, uint _inputAmount, address _receiver) public nonReentrant {
        require(isOpen && !paused, "swap: Contract paused!");

        uint _amountToUser = getAmountByInput(_input, _output, _inputAmount);
        require(_amountToUser > 0, "swap: Invalid amount!");

        // uint _exchangeRate = getExchangeRate(_input, _inputAmount, _output, _amountToUser);
        // require(_exchangeRate < maxSwing && _exchangeRate > 10 ** 36 / maxSwing, "swap: Abnormal exchange rate!");

        require(doTransferFrom(_input, msg.sender, address(this), _inputAmount), "swap: TransferFrom failed!");
        if (supportDToken[_input] != address(0))
            IDToken(supportDToken[_input]).mint(address(this), _inputAmount);

        if (supportDToken[_output] != address(0))
            IDToken(supportDToken[_output]).redeem(address(this), _amountToUser);
        else if (remainingDToken[_output] != address(0)) {

            (uint _tokenBalance, bool flag) = getRedeemAmount(remainingDToken[_output]);
            if (_tokenBalance > 0)
                IDToken(remainingDToken[_output]).redeem(address(this), _tokenBalance);

            if (flag)
                remainingDToken[_output] = address(0);
        }

        require(doTransferOut(_output, _receiver, _amountToUser), "swap: Transfer out failed!");
        emit Swap(
            msg.sender,
            _receiver,
            _input,
            _inputAmount,
            IPriceOracle(oracle).assetPrices(_input),
            _output,
            _amountToUser,
            IPriceOracle(oracle).assetPrices(_output)
        );
    }

    /**
     * @dev Swaps  `_outputAmount`asset to get another asset`_input`.
     * @param _input Asset that user wants to get.
     * @param _output Asset that user wants to consume.
     * @param _outputAmount Amount of asset consumed.
     */
    function swapTo(address _input, address _output, uint _outputAmount) external {
        swapTo(_input, _output, _outputAmount, msg.sender);
    }

    function swapTo(address _input, address _output, uint _outputAmount, address _receiver) public nonReentrant {
        require(isOpen && !paused, "swapTo: Contract paused!");

        uint _inputAmount = getAmountByOutput(_input, _output, _outputAmount);
        require(_inputAmount > 0, "swapTo: Invalid amount!");

        // uint _exchangeRate = getExchangeRate(_input, _inputAmount, _output, _outputAmount);
        // require(_exchangeRate < maxSwing && _exchangeRate > 10 ** 36 / maxSwing, "swapTo: Abnormal exchange rate!");

        require(doTransferFrom(_input, msg.sender, address(this), _inputAmount), "swapTo: TransferFrom failed!");
        if (supportDToken[_input] != address(0))
            IDToken(supportDToken[_input]).mint(address(this), _inputAmount);

        if (supportDToken[_output] != address(0))
            IDToken(supportDToken[_output]).redeem(address(this), _outputAmount);
        else if (remainingDToken[_output] != address(0)) {

            (uint _tokenBalance, bool flag) = getRedeemAmount(remainingDToken[_output]);
            if (_tokenBalance > 0)
                IDToken(remainingDToken[_output]).redeem(address(this), _tokenBalance);

            if (flag)
                remainingDToken[_output] = address(0);
        }

        require(doTransferOut(_output, _receiver, _outputAmount), "swapTo: Transfer out failed!");
        emit Swap(
            msg.sender,
            _receiver,
            _input,
            _inputAmount,
            IPriceOracle(oracle).assetPrices(_input),
            _output,
            _outputAmount,
            IPriceOracle(oracle).assetPrices(_output)
        );
    }

    /**
     * @dev Calculates the amount of `output` based on the amount`_inputAmount` of `input`.
     * @param _input Asset that user wants to consume.
     * @param _output Asset that user wants to get.
     * @param _inputAmount Amount of asset consumed.
     */
    function getAmountByInput(address _input, address _output, uint _inputAmount) public view returns (uint) {

        if (!tokensEnable[_input] || !tokensEnable[_output] || tradesDisable[_input][_output])
            return 0;

        IPriceOracle _oracle = IPriceOracle(oracle);
        if (_oracle.assetPrices(_output) == 0)
            return 0;

        return _inputAmount
            .mul(_oracle.assetPrices(_input))
            .div(_oracle.assetPrices(_output))
            .mul(OFFSET.sub(fee[_input][_output])) / OFFSET;
    }

    /**
     * @dev Calculates the amount of `_input` based on the amount`_outputAmount` of `_output`.
     * @param _input Asset that user wants to get.
     * @param _output Asset that user wants to consume.
     * @param _outputAmount Amount of asset consumed.
     */
    function getAmountByOutput(address _input, address _output, uint _outputAmount) public view returns (uint) {

        if (!tokensEnable[_input] || !tokensEnable[_output] || tradesDisable[_input][_output] || _outputAmount == 0)
            return 0;

        IPriceOracle _oracle = IPriceOracle(oracle);
        if (_oracle.assetPrices(_input) == 0 || _oracle.assetPrices(_output) == 0)
            return 0;

        return _outputAmount
            .mul(_oracle.assetPrices(_output))
            .div(_oracle.assetPrices(_input))
            .mul(OFFSET)
            .div(OFFSET.sub(fee[_input][_output]))
            .add(1);
    }

    /**
     * @dev Gets the valid amount of `_token` to redeem.
     * @param _token Asset which will be redeemed.
     */
    function getLiquidity(address _token) public view returns (uint) {

        address _dToken = supportDToken[_token] == address(0) ? remainingDToken[_token] : supportDToken[_token];
        uint _tokenBalance;
        if (_dToken != address(0))
            (_tokenBalance, ) = getRedeemAmount(_dToken);

        if (supportDToken[_token] != address(0))
            return _tokenBalance;

        return _tokenBalance.add(IERC20(_token).balanceOf(address(this)));
    }

    /**
     * @dev Gets the exchange rate between the two assets.
     * @param _input Asset that will be consumed.
     * @param _output Asset that will be got.
     */
    function exchangeRate(address _input, address _output) external view returns (uint) {
        uint _amount = getAmountByInput(_input, _output, 10 ** IERC20(_input).decimals());
        if (_amount == 0)
            return 0;

        uint _decimals = IERC20(_output).decimals();
        if (_decimals < 18)
            return _amount.mul(10 ** (18 - _decimals));

        return _amount / (10 ** (_decimals - 18));
    }

    /**
     * @dev Calculates the best amount of `output` based on the amount`_inputAmount` of `input`.
     * @param _input Asset that user wants to swap.
     * @param _output Asset that user wants to get.
     * @param _inputAmount Amount of asset to swap.
     */
	function getBestOutputByInput(address _input, address _output, uint _inputAmount) external view returns (uint) {
        if (!isOpen || paused)
            return 0;
		uint _outputAmount = getAmountByInput(_input, _output, _inputAmount);
		uint _liquidity = getLiquidity(_output);
		return _outputAmount > _liquidity ? 0 : _outputAmount;
	}
}