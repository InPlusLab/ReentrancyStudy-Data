// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./BaseStrategy.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/uniswap/Uni.sol";
import "./interfaces/basiscash/IReward.sol";

contract BACDAILPRewardStrategy is BaseStrategy {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address internal constant UNIROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    //want is the BAC/DAI UNI LP token
    address internal constant BAS = 0xa7ED29B253D8B4E3109ce07c80fc570f81B63696;
    address internal constant BAC = 0x3449FC1Cd036255BA1EB19d65fF4BA2b8903A69a;
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IReward private rewardEmitter;

    IUniswap private uniswap;

    IERC20 private reward;

    constructor(
        address _vault,
        address _rewardPool
    ) public BaseStrategy(_vault) {
        rewardEmitter = IReward(_rewardPool);

        reward = IERC20(BAS);

        uniswap = IUniswap(UNIROUTER);

        //approve uniswap for bas, bac and dai
        reward.safeApprove(address(uniswap), uint256(-1));
        IERC20(BAC).safeApprove(address(uniswap), uint256(-1));
        IERC20(DAI).safeApprove(address(uniswap), uint256(-1));
        want.safeApprove(address(rewardEmitter), uint256(-1));
    }

    function ethToWant(uint256 _callCost) public view returns (uint256) {
        if (_callCost == 0) {
            return 0;
        }

        uint256 half = _callCost.div(2);

        uint256 swapAmount = Math.min(half, _callCost);

        address[] memory pathTokenA = new address[](3);
        pathTokenA[0] = WETH;
        pathTokenA[1] = DAI;
        pathTokenA[2] = BAC;

        address[] memory pathTokenB = new address[](2);
        pathTokenB[0] = WETH;
        pathTokenB[1] = DAI;

        uint256[] memory amountsTokenA = uniswap.getAmountsOut(half, pathTokenA);
        uint256[] memory amountsTokenB = uniswap.getAmountsOut(swapAmount, pathTokenB);

        uint256 daiLPBalance = IERC20(DAI).balanceOf(address(want));
        uint256 lpTotalSupply = want.totalSupply();

        uint256 newDAIPosition = amountsTokenB[amountsTokenB.length - 1];

        uint256 newDAIRatio = newDAIPosition.div(daiLPBalance);

        //unsure if this calculation is correct
        return lpTotalSupply.mul(newDAIRatio).div(1e18);
    }

    function _swapRewardForDAI(uint256 _swapAmount) internal {
        address[] memory path = new address[](2);

        path[0] = BAS;
        path[1] = DAI;

        uint256[] memory amounts = uniswap.getAmountsOut(_swapAmount, path);

        uniswap.swapExactTokensForTokens(
            _swapAmount,
            amounts[amounts.length - 1],
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapRewardForBAC(uint256 _swapAmount) internal {
        address[] memory path = new address[](3);

        path[0] = address(reward);
        path[1] = DAI;
        path[2] = BAC;
        uint256[] memory amounts = uniswap.getAmountsOut(_swapAmount, path);

        uniswap.swapExactTokensForTokens(
            _swapAmount,
            amounts[amounts.length - 1],
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapAndAddLiquidity() internal returns (uint256 liquidity) {

        uint256 amount = reward.balanceOf(address(this));

        uint256 half = amount.div(2);
        uint256 swapAmount = Math.min(half, amount);
        _swapRewardForDAI(swapAmount);

        _swapRewardForBAC(balanceReward());
        liquidity = _addLiquidity();
    }

    function _addLiquidity() internal returns (uint256 liquidity) {
        (,, liquidity) = uniswap.addLiquidity(
            BAC,
            DAI,
            balanceBAC(),
            balanceDAI(),
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function name() external pure override returns (string memory) {
        return "BACDAILPStrategy";
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        return balanceWant().add(balanceUnclaimedWant()).add(balanceReward()).add(balanceDAI());
    }

    function harvestTrigger(uint256 _callCost) public view override returns (bool) {
        return super.harvestTrigger(ethToWant(_callCost));
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


        if (!emergencyExit) {
            rewardEmitter.getReward();
        }
        // if we have any basis cash, sell it for basis shares
        // This is done in a separate step since there might have been
        // a migration or an exitPosition
        uint256 rewardBalance = balanceReward();

        if (rewardBalance > 0) {
            // This might be > 0 because of a strategy migration
            uint256 totalWantIncludingSharesBeforeSwap = balanceWant().add(balanceUnclaimedWant());
            //turn half of the reward into dai
            _swapAndAddLiquidity();
            _profit = balanceWant().add(balanceUnclaimedWant()).sub(totalWantIncludingSharesBeforeSwap);
        }

    }


    function adjustPosition(uint256 _debtOutstanding) internal override {
        //emergency exit is dealt with in prepareReturn
        if (emergencyExit) {
            return;
        }

        if (balanceWant() > 0) {
            _stakeWant(balanceWant());
        }
    }

    function exitPosition(uint256 _debtOutstanding)
    internal
    override
    returns (
        uint256 _profit,
        uint256 _loss,
        uint256 _debtPayment
    )
    {
        rewardEmitter.exit();
        return prepareReturn(_debtOutstanding);
    }

    function _withdrawStakedWant(uint256 _amount) internal {
        rewardEmitter.withdraw(_amount);
    }

    function _stakeWant(uint256 _amount) internal {
        rewardEmitter.stake(_amount);
    }

    //the boardroom only allows one withdraw or one stake per block per user/including contract
    function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _amountFreed) {
        if (balanceWant() < _amountNeeded) {
            _withdrawStakedWant(_amountNeeded.sub(balanceWant()));
        }

        _amountFreed = balanceWant();
    }

    function prepareMigration(address _newStrategy) internal override {
        //ensure we leave with nothing left in the boardroom.
        rewardEmitter.exit();
        want.safeTransfer(_newStrategy, balanceWant());
        IERC20(DAI).safeTransfer(_newStrategy, balanceDAI());
        IERC20(BAC).safeTransfer(_newStrategy, balanceBAC());
        reward.safeTransfer(_newStrategy, balanceReward());
    }


    function protectedTokens() internal view override returns (address[] memory) {
        address[] memory protected = new address[](2);
        protected[0] = DAI;
        protected[1] = BAC;
        protected[2] = BAS;

        return protected;
    }

    function balanceReward() public view returns (uint256) {
        return reward.balanceOf(address(this));
    }

    function balanceWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function balanceBAC() public view returns (uint256) {
        return IERC20(BAC).balanceOf(address(this));
    }

    function balanceDAI() public view returns (uint256) {
        return IERC20(DAI).balanceOf(address(this));
    }

    function balanceUnclaimedWant() public view returns (uint256) {
        return rewardEmitter.balanceOf(address(this));
    }
}