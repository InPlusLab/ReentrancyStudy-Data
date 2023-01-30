// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {BaseStrategy, StrategyParams} from "./BaseStrategy.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../interfaces/zlot/IzGovernance.sol";
import "../interfaces/uniswap/Uni.sol";

contract StrategySushi is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public zGov;
    address public zLot;
    address public zHegic;
    address public unirouter;

    constructor(
        address _vault,
        address _zGov,
        address _zLot,
        address _zHegic,
        address _unirouter
    ) public BaseStrategy(_vault) {
        zGov = _zGov;
        zLot = _zLot;
        zHegic = _zHegic;
        unirouter = _unirouter;

        IERC20(zLot).safeApprove(zGov, uint256(-1));
        IERC20(zHegic).safeApprove(unirouter, uint256(-1));
    }

    function name() external pure override returns (string memory) {
        return "StrategyzLotSushi";
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        return balanceOfWant().add(balanceOfStake()).add(zLotFutureProfit());
    }

    function harvestTrigger(uint256 callCost) public view override returns (bool) {
        return super.harvestTrigger(ethToWant(callCost));
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
        // Try to pay debt asap
        if (_debtOutstanding > 0) {
            uint256 _amountFreed = liquidatePosition(_debtOutstanding);
            // Using Math.min() since we might free more than needed
            _debtPayment = Math.min(_amountFreed, _debtOutstanding);
        }

        // Convert reward to want
        if (zLotFutureProfit() > 0) {
            IzGovernance(zGov).getReward();
        }

        // If we have zHegic, let's convert them!
        // This is done in a separate step since there might have been
        // a migration or an exitPosition
        uint256 zHegicBalance = IERC20(zHegic).balanceOf(address(this));
        if (zHegicBalance > 0) {
            // This might be > 0 because of a strategy migration
            uint256 balanceOfWantBeforeSwap = balanceOfWant();
            _swap(zHegicBalance);
            _profit = balanceOfWant().sub(balanceOfWantBeforeSwap);
        }
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
        //emergency exit is dealt with in prepareReturn
        if (emergencyExit) {
            return;
        }

        uint256 _wantAvailable = balanceOfWant().sub(_debtOutstanding);
        if (_wantAvailable > 0) {
            IzGovernance(zGov).stake(_wantAvailable);
        }
    }

    function exitPosition() internal override returns (uint256 _loss, uint256 _debtPayment) {
        IzGovernance(zGov).getReward();
        IzGovernance(zGov).withdraw(balanceOfStake());
    }

    function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _amountFreed) {
        if (balanceOfWant() < _amountNeeded) {
            IzGovernance(zGov).withdraw(_amountNeeded.sub(balanceOfWant()));
        }

        _amountFreed = balanceOfWant();
    }

    function prepareMigration(address _newStrategy) internal override {
        exitPosition();
        IERC20(zLot).transfer(_newStrategy, balanceOfWant());
        IERC20(zHegic).transfer(_newStrategy, IERC20(zHegic).balanceOf(address(this)));
    }

    function protectedTokens() internal view override returns (address[] memory) {
        address[] memory protected = new address[](3);
        protected[0] = address(want);
        protected[1] = zHegic;

        return protected;
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfStake() public view returns (uint256) {
        return IERC20(zGov).balanceOf(address(this));
    }

    function ethToWant(uint256 _amount) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }

        address[] memory path = new address[](2);
        path[0] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth
        path[1] = address(want);
        uint256[] memory amounts = Uni(unirouter).getAmountsOut(_amount, path);

        return amounts[amounts.length - 1];
    }

    function zLotFutureProfit() public view returns (uint256) {
        uint256 zHegicRewardBalance = IzGovernance(zGov).earned(address(this));
        if (zHegicRewardBalance == 0) {
            return 0;
        }

        address[] memory path = new address[](3);
        path[0] = address(0x837010619aeb2AE24141605aFC8f66577f6fb2e7); // zHegic
        path[1] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth
        path[2] = address(want);
        uint256[] memory amounts = Uni(unirouter).getAmountsOut(zHegicRewardBalance, path);

        return amounts[amounts.length - 1];
    }

    function _swap(uint256 _amountIn) internal returns (uint256[] memory amounts) {
        address[] memory path = new address[](3);
        path[0] = address(0x837010619aeb2AE24141605aFC8f66577f6fb2e7); // zHegic
        path[1] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth
        path[2] = address(want);

        Uni(unirouter).swapExactTokensForTokens(_amountIn, uint256(0), path, address(this), now.add(1 days));
    }
}