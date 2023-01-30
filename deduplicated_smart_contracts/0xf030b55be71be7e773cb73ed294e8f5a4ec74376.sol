// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import './IERC20.sol';
import './Constants.sol';
import './IUserWallet.sol';
import './ParamsLib.sol';
import './SafeERC20.sol';

contract UserWallet is IUserWallet, Constants {
    using SafeERC20 for IERC20;
    using ParamsLib for *;
    bytes32 constant W2W = 'W2W';
    bytes32 constant OWNER = 'OWNER';
    bytes32 constant REFERRER = 'REFERRER';

    mapping (bytes32 => bytes32) public override params;

    event ParamUpdated(bytes32 _key, bytes32 _value);

    modifier onlyW2wOrOwner () {
        require(msg.sender == params[W2W].toAddress() || msg.sender == owner(), 'Only W2W or owner');
        _;
    }

    modifier onlyOwner () {
        require(msg.sender == owner(), 'Only owner');
        _;
    }

    function init(address _w2w, address _owner, address _referrer) external payable {
        require(owner() == address(0), 'Already initialized');
        params[OWNER] = _owner.toBytes32();
        params[W2W] = _w2w.toBytes32();
        if (_referrer != address(0)) {
            params[REFERRER] = _referrer.toBytes32();
        }
    }

    function demandETH(address payable _recepient, uint _amount) external override onlyW2wOrOwner() {
        _recepient.transfer(_amount);
    }

    function demandERC20(IERC20 _token, address _recepient, uint _amount) external override onlyW2wOrOwner() {
        uint _thisBalance = _token.balanceOf(address(this));
        if (_thisBalance < _amount) {
            _token.safeTransferFrom(owner(), address(this), (_amount - _thisBalance));
        }
        _token.safeTransfer(_recepient, _amount);
    }

    function demandAll(IERC20[] calldata _tokens, address payable _recepient) external override onlyW2wOrOwner() {
        for (uint _i = 0; _i < _tokens.length; _i++) {
            IERC20 _token = _tokens[_i];
            if (_token == ETH) {
                _recepient.transfer(address(this).balance);
            } else {
                _token.safeTransfer(_recepient, _token.balanceOf(address(this)));
            }
        }
    }

    function demand(address payable _target, uint _value, bytes memory _data) 
    external override onlyW2wOrOwner() returns(bool, bytes memory) {
        return _target.call{value: _value}(_data);
    }

    function owner() public view override returns(address payable) {
        return params[OWNER].toAddress();
    }

    function changeParam(bytes32 _key, bytes32 _value) public onlyOwner() {
        require(_key != REFERRER, 'Cannot update referrer');
        params[_key] = _value;
        emit ParamUpdated(_key, _value);
    }
    
    function changeOwner(address _newOwner) public {
        changeParam(OWNER, _newOwner.toBytes32());
    }

    receive() payable external {}
}
