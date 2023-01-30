// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import './AccessControl.sol';
import './SafeMath.sol';
import './IERC20.sol';
import './Constants.sol';
import './IUserWallet.sol';
import './IBuyBurner.sol';
import './ParamsLib.sol';
import './SafeERC20.sol';

library ExtraMath {
    using SafeMath for uint;

    function divCeil(uint _a, uint _b) internal pure returns(uint) {
        if (_a.mod(_b) > 0) {
            return (_a / _b).add(1);
        }
        return _a / _b;
    }
}

contract Wallet2Wallet is AccessControl, Constants {
    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using ExtraMath for uint;
    using ParamsLib for *;

    bytes32 constant public EXECUTOR_ROLE = bytes32('Executor');
    uint constant public EXTRA_GAS = 15000; // SLOAD * 2, Event, CALL, CALL with value, calc.
    uint constant public GAS_SAVE = 30000;
    uint constant public HUNDRED_PERCENT = 10000; // 100.00%
    uint constant public MAX_FEE_PERCENT = 50; // 0.50%
    IBuyBurner immutable public TOKEN_BURNER;

    address payable public gasFeeCollector;
    mapping(IERC20 => uint) public fees;

    struct Request {
        IUserWallet user;
        IERC20 tokenFrom;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint fee;
        bool copyToWalletOwner;
        uint txGasLimit;
        address target;
        address approveTarget;
        bytes callData;
    }

    struct RequestETHForTokens {
        IUserWallet user;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint fee;
        bool copyToWalletOwner;
        uint txGasLimit;
        address payable target;
        bytes callData;
    }

    struct RequestTokensForETH {
        IUserWallet user;
        IERC20 tokenFrom;
        uint amountFrom;
        uint minAmountTo;
        uint fee;
        bool copyToWalletOwner;
        uint txGasLimit;
        address target;
        address approveTarget;
        bytes callData;
    }

    event Error(bytes _error);

    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only owner');
        _;
    }

    modifier onlyExecutor() {
        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        _;
    }

    modifier onlyThis() {
        require(_msgSender() == address(this), 'Only this contract');
        _;
    }

    modifier checkFee(uint _feePercent) {
        require(_feePercent <= MAX_FEE_PERCENT, 'Fee is too high');
        _;
    }

    constructor(IBuyBurner _tokenBurner) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(EXECUTOR_ROLE, _msgSender());
        gasFeeCollector = payable(_msgSender());
        TOKEN_BURNER = _tokenBurner;
    }

    function updateGasFeeCollector(address payable _address) external onlyOwner() {
        require(_address != address(0), 'Not zero address required');
        gasFeeCollector = _address;
    }

    receive() payable external {}

    function makeSwap(Request memory _request)
    external onlyExecutor() checkFee(_request.fee) returns(bool, bytes memory _reason) {
        require(address(_request.user).balance >= (_request.txGasLimit * tx.gasprice),
            'Not enough ETH in UserWallet');

        bool _result = false;
        try this._execute{gas: gasleft().sub(GAS_SAVE)}(_request) {
            _result = true;
        } catch (bytes memory _error) { _reason = _error; }
        if (!_result) {
            emit Error(_reason);
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return (_result, _reason);
    }

    function makeSwapETHForTokens(RequestETHForTokens memory _request)
    external onlyExecutor() checkFee(_request.fee) returns(bool, bytes memory _reason) {
        require(address(_request.user).balance >= ((_request.txGasLimit * tx.gasprice) + _request.amountFrom),
            'Not enough ETH in UserWallet');

        bool _result = false;
        try this._executeETHForTokens{gas: gasleft().sub(GAS_SAVE)}(_request) {
            _result = true;
        } catch (bytes memory _error) { _reason = _error; }
        if (!_result) {
            emit Error(_reason);
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return (_result, _reason);
    }

    function makeSwapTokensForETH(RequestTokensForETH memory _request)
    external onlyExecutor() checkFee(_request.fee) returns(bool, bytes memory _reason) {
        require(address(_request.user).balance >= (_request.txGasLimit * tx.gasprice),
            'Not enough ETH in UserWallet');

        bool _result = false;
        try this._executeTokensForETH{gas: gasleft().sub(GAS_SAVE)}(_request) {
            _result = true;
        } catch (bytes memory _error) { _reason = _error; }
        if (!_result) {
            emit Error(_reason);
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return (_result, _reason);
    }

    function _require(bool _success, bytes memory _reason) internal pure {
        if (_success) {
            return;
        }
        assembly {
            revert(add(_reason, 32), mload(_reason))
        }
    }

    function _execute(Request memory _request) external onlyThis() {
        _request.user.demandERC20(_request.tokenFrom, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.approveTarget, _request.amountFrom);

        (bool _success, bytes memory _reason) = _request.target.call(_request.callData);
        _require(_success, _reason);
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        require(_balanceThis >= _request.minAmountTo, 'Less than minimum received');
        uint _userGetsAmount = _saveFee(_request.tokenTo, _balanceThis, _request.fee);
        address _userGetsTo = _swapTo(_request.user, _request.copyToWalletOwner);
        _request.tokenTo.safeTransfer(_userGetsTo, _userGetsAmount);
    }

    function _executeETHForTokens(RequestETHForTokens memory _request) external onlyThis() {
        _request.user.demandETH(address(this), _request.amountFrom);

        (bool _success, bytes memory _reason) = _request.target.call{value: _request.amountFrom}(_request.callData);
        _require(_success, _reason);
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        require(_balanceThis >= _request.minAmountTo, 'Less than minimum received');
        uint _userGetsAmount = _saveFee(_request.tokenTo, _balanceThis, _request.fee);
        address _userGetsTo = _swapTo(_request.user, _request.copyToWalletOwner);
        _request.tokenTo.safeTransfer(_userGetsTo, _userGetsAmount);
    }

    function _executeTokensForETH(RequestTokensForETH memory _request) external onlyThis() {
        _request.user.demandERC20(_request.tokenFrom, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.approveTarget, _request.amountFrom);

        (bool _success, bytes memory _reason) = _request.target.call(_request.callData);
        _require(_success, _reason);
        uint _balanceThis = address(this).balance;
        require(_balanceThis >= _request.minAmountTo, 'Less than minimum received');
        uint _userGetsAmount = _saveFee(ETH, _balanceThis, _request.fee);
        address payable _userGetsTo = _swapTo(_request.user, _request.copyToWalletOwner);
        _userGetsTo.transfer(_userGetsAmount);
    }

    function _saveFee(IERC20 _token, uint _amount, uint _feePercent) internal returns(uint) {
        if (_feePercent == 0) {
            return _amount;
        }
        uint _fee = _amount.mul(_feePercent).divCeil(HUNDRED_PERCENT);
        fees[_token] = fees[_token].add(_fee);
        return _amount.sub(_fee);
    }

    function _chargeFee(IUserWallet _user, uint _txGasLimit) internal {
        uint _txCost = (_txGasLimit - gasleft() + EXTRA_GAS) * tx.gasprice;
        _user.demandETH(gasFeeCollector, _txCost);
    }

    function _swapTo(IUserWallet _user, bool _copyToWalletOwner) internal view returns(address payable) {
        if (_copyToWalletOwner) {
           return _user.owner();
        }
        return payable(address(_user));
    }

    function sendFeeForBurning(IERC20[] calldata _tokens) external {
        for (uint _i = 0; _i < _tokens.length; _i++) {
            IERC20 _token = _tokens[_i];
            uint _fee = fees[_token];
            fees[_token] = 0;
            if (_token == ETH) {
                payable(TOKEN_BURNER).transfer(_fee);
            } else {
                _token.safeTransfer(address(TOKEN_BURNER), _fee);
            }
        }
    }

    function collectTokens(IERC20 _token, uint _amount, address _to)
    external onlyOwner() {
        uint _fees = fees[_token];
        if (_token == ETH) {
            require(address(this).balance.sub(_fees) >= _amount, 'Insufficient extra ETH');
            payable(_to).transfer(_amount);
        } else {
            require(_token.balanceOf(address(this)).sub(_fees) >= _amount, 'Insufficient extra tokens');
            _token.safeTransfer(_to, _amount);
        }
    }
}
