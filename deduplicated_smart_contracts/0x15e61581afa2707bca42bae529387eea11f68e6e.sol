/**
 *Submitted for verification at Etherscan.io on 2021-08-07
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

interface erc20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ve {
    
    struct Point {
        int128 bias;
        int128 slope;
        uint ts;
        uint blk;
    }
    
    function balanceOf(address, uint) external view returns (uint);
    function totalSupply() external view returns (uint);
    function user_point_epoch(address) external view returns (uint);
    function user_point_history(address, uint) external view returns (Point memory);
}

contract distribution {
    address constant _ibff = 0xb347132eFf18a3f63426f4988ef626d2CbE274F5;
    address constant _veibff = 0x4D0518C9136025903751209dDDdf6C67067357b1;
    
    uint constant PRECISION = 10 ** 18;
    uint constant WEEK = 86400 * 7;
    
    uint _active_period;
    uint _reward_per;
    
    mapping(address => uint) _last_claim;
    
    uint public totalSupply;
    
    function _update_period() internal returns (uint) {
        uint _period = _active_period;
        if (block.timestamp >= _period + WEEK) {
            _period = block.timestamp / WEEK * WEEK;
            uint _amount = erc20(_ibff).balanceOf(address(this));
            uint _totalSupply = ve(_veibff).totalSupply();
            _reward_per = _amount * PRECISION / _totalSupply;
            totalSupply = _totalSupply;
            _active_period = _period;
        }
        return _period;
    }
    
    function add_reward(uint amount) external returns (bool) {
        _safeTransferFrom(_ibff, amount);
        _update_period();
        return true;
    }
    
    function ve_balance_at(address account, uint timestamp) public view returns (uint) {
        uint _epoch = ve(_veibff).user_point_epoch(account);
        uint _balance_at = 0;
        for (uint i = _epoch; i > 0; i--) {
            ve.Point memory _point = ve(_veibff).user_point_history(account, i);
            if (_point.ts <= timestamp) {
                int128 _bias = _point.bias - (_point.slope * int128(int(timestamp - _point.ts)));
                if (_bias > 0) {
                    _balance_at = uint(int(_bias));
                }
                break;
            }
        }
        return _balance_at;
    }
    
    function claimable(address account) external view returns (uint) {
        uint _period = _active_period;
        uint _last = Math.max(_period, _last_claim[account]);
        uint _reward = ve_balance_at(account, _period) * _reward_per / PRECISION;
        return _reward * (block.timestamp - _last) / WEEK;
    }

    function claim() external returns (uint) {
        uint _period = _update_period();
        uint _last = Math.max(_period, _last_claim[msg.sender]);
        uint _reward = ve_balance_at(msg.sender, _period) * _reward_per / PRECISION;
        uint _accrued = _reward * (block.timestamp - _last) / WEEK;
        if (_accrued > 0) {
            _last_claim[msg.sender] = block.timestamp;
            _safeTransfer(_ibff, msg.sender, _accrued);
        }
        return _accrued;
    }
    
    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(erc20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
    
    function _safeTransferFrom(address token, uint256 value) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(erc20.transferFrom.selector, msg.sender, address(this), value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
}