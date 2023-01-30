// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./Context.sol";

/**
 * @dev Interface of the Nuggets.
 */
interface Nuggets is IERC20 {
    /**
     * @dev Creates `_value` tokens to `_to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function mint(address _to, uint256 _value) external returns (bool);
}

contract Nuggets_Stake is Context, Ownable {

    using SafeMath for uint256;

    Nuggets public token;

    struct poolStruct {
        bool isExist;
        uint startsAt;
        uint endsAt;
        uint lockperiod;
        uint ROI;
        uint stakerCount;
        address token;
    }
    uint public noOfPool = 0;
    mapping (uint => poolStruct) public pool;

    ///_________________ Stack Start
    struct stakeUserStruct {
        bool isExist;
        uint256 stake;
        uint256 stakeTime;
        uint256 harvested;
    }

    //_________________  POOL Start
    mapping (uint => mapping (address => stakeUserStruct)) public staker;
    
    event Staked(address _staker, uint256 _amount, uint256 _pool);
    event UnStaked(address _staker, uint256 _amount, uint256 _pool);
    event Harvested(address _staker, uint256 _amount, uint256 _pool);

    constructor(address _token) {
        token = Nuggets(_token);
    }

    function getEndTime(uint _pool) public view returns (uint) {
        require (pool[_pool].isExist, "Pool not Exist");
        if(pool[_pool].startsAt < block.timestamp && pool[_pool].endsAt > block.timestamp){
            return uint(pool[_pool].endsAt).sub(block.timestamp);
        }else{
            return 0;
        }
    }

    function stake (uint _pool, uint _amount) public payable returns (bool) {
        require (pool[_pool].isExist, "Pool not Exist");
        require(getEndTime(_pool) > 0, "Time Out");
        require (!staker[_pool][_msgSender()].isExist, "You already staked");
        
        if(pool[_pool].token == address(0)){
            require (msg.value > 0, "Zero ETH Sent");
            _amount = msg.value;
        }else{
            require (IERC20(pool[_pool].token).balanceOf(_msgSender()) >= _amount, "You don't have enough tokens");
            IERC20(pool[_pool].token).transferFrom(_msgSender(), address(this), _amount);
        }

        stakeUserStruct memory stakerinfo;
        pool[_pool].stakerCount++;

        stakerinfo = stakeUserStruct({
            isExist: true,
            stake: _amount,
            stakeTime: block.timestamp,
            harvested: 0
        });

        staker[_pool][_msgSender()] = stakerinfo;
        emit Staked(_msgSender(), _amount, _pool);
        return true;
    }

    function unstake (uint _pool) public returns (bool) {
        require (pool[_pool].isExist, "Pool not Exist");
        require (staker[_pool][_msgSender()].isExist, "You are not staked");
        require (staker[_pool][_msgSender()].stakeTime < uint256(block.timestamp).sub(pool[_pool].lockperiod), "Amount is in lock period");

        if(_getCurrentReward(_pool, _msgSender()) > 0){
            _harvest(_pool, _msgSender());
        }

        if(pool[_pool].token == address(0)){
            _msgSender().transfer(staker[_pool][_msgSender()].stake);
        }else{
            IERC20(pool[_pool].token).transfer(_msgSender(), staker[_pool][_msgSender()].stake);
        }

        emit UnStaked(_msgSender(), staker[_pool][_msgSender()].stake, _pool);

        pool[_pool].stakerCount--;
        staker[_pool][_msgSender()].isExist = false;
        staker[_pool][_msgSender()].stake = 0;
        staker[_pool][_msgSender()].stakeTime = 0;
        staker[_pool][_msgSender()].harvested = 0;

        return true;
    }

    function harvest(uint _pool) public returns (bool) {
        require (pool[_pool].isExist, "Pool not Exist");
        _harvest(_pool, _msgSender());
        return true;
    }

    function _harvest(uint _pool, address _user) internal {
        require(_getCurrentReward(_pool, _user) > 0, "Nothing to harvest");
        uint256 harvestAmount = _getCurrentReward(_pool, _user);
        staker[_pool][_user].harvested += harvestAmount;
        // 2% harvert tax
        token.mint(_user, harvestAmount.mul(98).div(100));
        emit Harvested(_user, harvestAmount, _pool);
    }

    function getTotalReward (uint _pool, address _user) public view returns (uint256) {
        require (pool[_pool].isExist, "Pool not Exist");
        return _getTotalReward(_pool, _user);
    }

    function _getTotalReward (uint _pool, address _user) internal view returns (uint256) {
        if(staker[_pool][_user].isExist){
            return uint256(block.timestamp).sub(staker[_pool][_user].stakeTime).mul(staker[_pool][_user].stake).mul(pool[_pool].ROI).div(10000).div(1 days);
        }else{
            return 0;
        }
    }

    function getCurrentReward (uint _pool, address _user) public view returns (uint256) {
        require (pool[_pool].isExist, "Pool not Exist");
        return _getCurrentReward(_pool, _user);
    }

    function _getCurrentReward (uint _pool, address _user) internal view returns (uint256) {
        if(staker[_pool][_msgSender()].isExist){
            return uint256(getTotalReward(_pool, _user)).sub(staker[_pool][_user].harvested);
        }else{
            return 0;
        }
        
    }
    ///_________________ POOL End

    function addPool(uint _startsAt, uint _endsAt, uint _lockperiod, uint _ROI, address _token) onlyOwner public returns (bool) {
        require (_endsAt > block.timestamp, "Wrong End Time");
        require (_ROI > 0, "Wrong ROI");

        poolStruct memory poolinfo;
        noOfPool++;

        poolinfo = poolStruct({
            isExist: true,
            startsAt: _startsAt,
            endsAt: _endsAt,
            lockperiod: _lockperiod,
            ROI: _ROI,
            stakerCount: 0,
            token: _token
        });

        pool[noOfPool] = poolinfo;
        return true;
    }
} 