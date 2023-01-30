/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        return add(a, b, "add: +");
    }
    function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "sub: -");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
}

interface ILock3rV1 {
    function isMinLocker(address locker, uint minBond, uint earned, uint age) external returns (bool);
    function receipt(address credit, address locker, uint amount) external;
    function unbond(address bonding, uint amount) external;
    function withdraw(address bonding) external;
    function bonds(address locker, address credit) external view returns (uint);
    function unbondings(address locker, address credit) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function jobs(address job) external view returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface WETH9 {
    function withdraw(uint wad) external;
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface ILock3rJob {
    function work() external;
}

contract MetaLock3r {
    using SafeMath for uint;

    modifier upkeep() {
        require(LK3R.isMinLocker(msg.sender, 400e18, 0, 0), "MetaLock3r::isLocker: locker is not registered");
        uint _before = LK3R.bonds(address(this), address(LK3R));
        _;
        uint _after = LK3R.bonds(address(this), address(LK3R));
        uint _received = _after.sub(_before);
        uint _balance = LK3R.balanceOf(address(this));
        if (_balance < _received) {
            LK3R.receipt(address(LK3R), address(this), _received.sub(_balance));
        }
        _received = _swap(_received);
        msg.sender.transfer(_received);
    }

    function task(address job, bytes calldata data) external upkeep {
        require(LK3R.jobs(job), "MetaLock3r::work: invalid job");
        (bool success,) = job.call.value(0)(data);
        require(success, "MetaLock3r::work: job failure");
    }

    function work(address job) external upkeep {
        require(LK3R.jobs(job), "MetaLock3r::work: invalid job");
        ILock3rJob(job).work();
    }

    ILock3rV1 public constant LK3R = ILock3rV1(0xe3f3869dDD41C23Eff3630F58E5bFA584C770D67);
    WETH9 public constant WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUniswapV2Router public constant UNI = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function unbond() external {
        require(LK3R.unbondings(address(this), address(LK3R)) < now, "MetaLock3r::unbond: unbonding");
        LK3R.unbond(address(LK3R), LK3R.bonds(address(this), address(LK3R)));
    }

    function withdraw() external {
        LK3R.withdraw(address(LK3R));
        LK3R.unbond(address(LK3R), LK3R.bonds(address(this), address(LK3R)));
    }

    function() external payable {}

    function _swap(uint _amount) internal returns (uint) {
        LK3R.approve(address(UNI), _amount);

        address[] memory path = new address[](2);
        path[0] = address(LK3R);
        path[1] = address(WETH);

        uint[] memory amounts = UNI.swapExactTokensForTokens(_amount, uint256(0), path, address(this), now.add(1800));
        WETH.withdraw(amounts[1]);
        return amounts[1];
    }
}