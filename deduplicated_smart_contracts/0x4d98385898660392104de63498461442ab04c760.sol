/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

// File: contracts/interfaces/IERC20Token.sol

pragma solidity ^0.5.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20Token {
    /**
     * @dev Returns the amount of tokens decimals
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/interfaces/ICurve.sol

pragma solidity ^0.5.0;

interface ICurve {
    // solium-disable-next-line mixedcase
    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 dy);

    // solium-disable-next-line mixedcase
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 dy);

    // solium-disable-next-line mixedcase
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minDy
    ) external;

    // solium-disable-next-line mixedcase
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minDy
    ) external;
}

// File: contracts/logics/Curve.sol

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



contract Curve {
    // Curve Contracts
    ICurve internal constant curveCompound = ICurve(
        0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56
    );
    ICurve internal constant curveUSDT = ICurve(
        0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C
    );
    ICurve internal constant curveY = ICurve(
        0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51
    );
    ICurve internal constant curveBinance = ICurve(
        0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27
    );
    ICurve internal constant curveSynth = ICurve(
        0xA5407eAE9Ba41422680e2e00537571bcC53efBfD
    );
    ICurve internal constant curvePAX = ICurve(
        0x06364f10B501e868329afBc005b3492902d6C763
    );

    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant TUSD_ADDRESS = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address constant BUSD_ADDRESS = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address constant SUSD_ADDRESS = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address constant PAX_ADDRESS = 0x8E870D67F660D95d5be530380D0eC0bd388289E1;

    function getBalance(address token) public view returns (uint256) {
        return IERC20Token(token).balanceOf(address(this));
    }

    function swapOnCurveCompound(
        address src,
        address dest,
        uint256 srcAmt
    ) public returns (uint256) {
        uint256 realSrcAmt = srcAmt == 0 ? getBalance(src) : srcAmt;

        int128 i = (src == DAI_ADDRESS ? 1 : 0) + (src == USDC_ADDRESS ? 2 : 0);
        int128 j = (dest == DAI_ADDRESS ? 1 : 0) +
            (dest == USDC_ADDRESS ? 2 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        IERC20Token(src).approve(address(curveCompound), realSrcAmt);
        curveCompound.exchange_underlying(i - 1, j - 1, realSrcAmt, 0);
    }

    function swapOnCurveUSDT(
        address src,
        address dest,
        uint256 srcAmt
    ) public returns (uint256) {
        uint256 realSrcAmt = srcAmt == 0 ? getBalance(src) : srcAmt;

        int128 i = (src == DAI_ADDRESS ? 1 : 0) +
            (src == USDC_ADDRESS ? 2 : 0) +
            (src == USDT_ADDRESS ? 3 : 0);
        int128 j = (dest == DAI_ADDRESS ? 1 : 0) +
            (dest == USDC_ADDRESS ? 2 : 0) +
            (dest == USDT_ADDRESS ? 3 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        IERC20Token(src).approve(address(curveUSDT), realSrcAmt);

        curveUSDT.exchange_underlying(i - 1, j - 1, realSrcAmt, 0);
    }

    function swapOnCurveY(
        address src,
        address dest,
        uint256 srcAmt
    ) public returns (uint256) {
        uint256 realSrcAmt = srcAmt == 0 ? getBalance(src) : srcAmt;

        int128 i = (src == DAI_ADDRESS ? 1 : 0) +
            (src == USDC_ADDRESS ? 2 : 0) +
            (src == USDT_ADDRESS ? 3 : 0) +
            (src == TUSD_ADDRESS ? 4 : 0);
        int128 j = (dest == DAI_ADDRESS ? 1 : 0) +
            (dest == USDC_ADDRESS ? 2 : 0) +
            (dest == USDT_ADDRESS ? 3 : 0) +
            (dest == TUSD_ADDRESS ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        IERC20Token(src).approve(address(curveY), realSrcAmt);
        curveY.exchange_underlying(i - 1, j - 1, realSrcAmt, 0);
    }

    function swapOnCurveBinance(
        address src,
        address dest,
        uint256 srcAmt
    ) public returns (uint256) {
        uint256 realSrcAmt = srcAmt == 0 ? getBalance(src) : srcAmt;

        int128 i = (src == DAI_ADDRESS ? 1 : 0) +
            (src == USDC_ADDRESS ? 2 : 0) +
            (src == USDT_ADDRESS ? 3 : 0) +
            (src == BUSD_ADDRESS ? 4 : 0);
        int128 j = (dest == DAI_ADDRESS ? 1 : 0) +
            (dest == USDC_ADDRESS ? 2 : 0) +
            (dest == USDT_ADDRESS ? 3 : 0) +
            (dest == BUSD_ADDRESS ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        IERC20Token(src).approve(address(curveBinance), realSrcAmt);

        curveBinance.exchange_underlying(i - 1, j - 1, realSrcAmt, 0);
    }

    function swapOnCurveSynth(
        address src,
        address dest,
        uint256 srcAmt
    ) public returns (uint256) {
        uint256 realSrcAmt = srcAmt == 0 ? getBalance(src) : srcAmt;

        int128 i = (src == DAI_ADDRESS ? 1 : 0) +
            (src == USDC_ADDRESS ? 2 : 0) +
            (src == USDT_ADDRESS ? 3 : 0) +
            (src == SUSD_ADDRESS ? 4 : 0);
        int128 j = (dest == DAI_ADDRESS ? 1 : 0) +
            (dest == USDC_ADDRESS ? 2 : 0) +
            (dest == USDT_ADDRESS ? 3 : 0) +
            (dest == SUSD_ADDRESS ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        IERC20Token(src).approve(address(curveSynth), realSrcAmt);
        curveSynth.exchange_underlying(i - 1, j - 1, realSrcAmt, 0);
    }

    function swapOnCurvePAX(
        address src,
        address dest,
        uint256 srcAmt
    ) public returns (uint256) {
        uint256 realSrcAmt = srcAmt == 0 ? getBalance(src) : srcAmt;

        int128 i = (src == DAI_ADDRESS ? 1 : 0) +
            (src == USDC_ADDRESS ? 2 : 0) +
            (src == USDT_ADDRESS ? 3 : 0) +
            (src == PAX_ADDRESS ? 4 : 0);
        int128 j = (dest == DAI_ADDRESS ? 1 : 0) +
            (dest == USDC_ADDRESS ? 2 : 0) +
            (dest == USDT_ADDRESS ? 3 : 0) +
            (dest == PAX_ADDRESS ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        IERC20Token(src).approve(address(curvePAX), realSrcAmt);
        curvePAX.exchange_underlying(i - 1, j - 1, realSrcAmt, 0);
    }
}