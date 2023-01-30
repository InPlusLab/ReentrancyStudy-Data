/**
 *Submitted for verification at Etherscan.io on 2020-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ICurveFi_4 {
    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount) external;
}

interface IVault {
    function deposit(uint256) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract ToolTBTCMixed {
    using SafeMath for uint256;

    address public constant curve = 0xaa82ca713D94bBA7A89CEAB55314F9EfFEdDc78c;
    // tbtcCrv
    address public constant want = 0x64eda51d3Ad40D56b9dFc5554E06F94e1Dd786Fd;
    // bTbtcCRV
    address public constant bToken = 0xFEd46586379577AD7E3295aE19B1b4F64aC5D363;

    // BTC
    address public constant tBTC = 0x8dAEBADE922dF735c38C80C7eBD708Af50815fAa;
    address public constant renBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address public constant wBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant sBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;

    event Recycled(address indexed user, uint256 sentTBTC, uint256 sentRenBtc, uint256 sentWBTC,
        uint256 sentSBTC, uint256 sentWant, uint256 receivedBToken);

    constructor() public {
        IERC20(tBTC).approve(curve, uint256(- 1));
        IERC20(renBTC).approve(curve, uint256(- 1));
        IERC20(wBTC).approve(curve, uint256(- 1));
        IERC20(sBTC).approve(curve, uint256(- 1));
        IERC20(want).approve(bToken, uint256(- 1));
    }

    function recycleExactAmounts(address sender, uint256 _tBTC, uint256 _renBTC, uint256 _wBTC, uint256 _sBTC, uint256 _want) internal {
        if (_tBTC > 0) {
            IERC20(tBTC).transferFrom(sender, address(this), _tBTC);
        }
        if (_renBTC > 0) {
            IERC20(renBTC).transferFrom(sender, address(this), _renBTC);
        }
        if (_wBTC > 0) {
            IERC20(wBTC).transferFrom(sender, address(this), _wBTC);
        }
        if (_sBTC > 0) {
            IERC20(sBTC).transferFrom(sender, address(this), _sBTC);
        }
        if (_want > 0) {
            IERC20(want).transferFrom(sender, address(this), _want);
        }

        uint256[4] memory depositAmounts = [_tBTC, _renBTC, _wBTC, _sBTC];
        if (_renBTC.add(_wBTC).add(_sBTC).add(_tBTC) > 0) {
            ICurveFi_4(curve).add_liquidity(depositAmounts, 0);
        }

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IVault(bToken).deposit(wantBalance);
        }

        uint256 _bToken = IERC20(bToken).balanceOf(address(this));
        if (_bToken > 0) {
            IERC20(bToken).transfer(sender, _bToken);
        }

        assert(IERC20(bToken).balanceOf(address(this)) == 0);

        emit Recycled(sender, _tBTC, _renBTC, _wBTC, _sBTC, _want, _bToken);
    }

    function recycle() external {
        uint256 _tBTC = Math.min(IERC20(tBTC).balanceOf(msg.sender), IERC20(tBTC).allowance(msg.sender, address(this)));
        uint256 _renBTC = Math.min(IERC20(renBTC).balanceOf(msg.sender), IERC20(renBTC).allowance(msg.sender, address(this)));
        uint256 _wBTC = Math.min(IERC20(wBTC).balanceOf(msg.sender), IERC20(wBTC).allowance(msg.sender, address(this)));
        uint256 _sBTC = Math.min(IERC20(sBTC).balanceOf(msg.sender), IERC20(sBTC).allowance(msg.sender, address(this)));
        uint256 _want = Math.min(IERC20(want).balanceOf(msg.sender), IERC20(want).allowance(msg.sender, address(this)));

        recycleExactAmounts(msg.sender, _tBTC, _renBTC, _wBTC, _sBTC, _want);
    }


    function recycleExact(uint256 _tBTC, uint256 _renBTC, uint256 _wBTC, uint256 _sBTC, uint256 _want) external {
        recycleExactAmounts(msg.sender, _tBTC, _renBTC, _wBTC, _sBTC, _want);
    }
}