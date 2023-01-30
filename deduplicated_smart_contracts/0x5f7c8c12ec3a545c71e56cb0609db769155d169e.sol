/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

/**
 * @authors: [@nix1g]
 * @reviewers: [@clesaege, @ferittuncer, @fnanni-0, @mtsalenc, @unknownunknown1]
 * @auditors: []
 * @bounties: []
 * @deployments: []
 *
 * SPDX-License-Identifier: MIT
 */

pragma solidity ^0.6.5;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ITokenController {
    function proxyPayment(address _owner) external payable returns (bool);
    function onTransfer(address _from, address _to, uint256 _amount) external returns (bool);
    function onApprove(address _owner, address _spender, uint256 _amount) external returns (bool);
}

interface IMiniMeToken is IERC20 {
    function changeController(address _governor) external;
    function controller() external view returns (address); // Getter
}

interface IBPool is IERC20 {
    function getBalance(address token) external view returns (uint256);
    function getSwapFee() external view returns (uint256);
    function gulp(address token) external;
    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);
    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;
}

/** @title BalancerPoolRecoverer
  * @dev The contract used to recover funds locked in a Balancer Pool.
  */
contract BalancerPoolRecoverer is ITokenController {
    /* *** Variables *** */

    uint256 constant public ITERATION_COUNT = 32; // The number of swaps to make.

    // Contracts and addresses to act on (immutable)
    IMiniMeToken immutable public pnkToken;
    IERC20 immutable public wethToken;
    IBPool immutable public bpool;
    address immutable public controller;
    address immutable public beneficiary;

    // Storage
    bool recoveryOngoing; // Control TokenController functionality (block transfers by default).
    uint256 initiateRestoreControllerTimestamp;


    /* *** Functions *** */

    /** @dev Constructs the recoverer.
     *  @param _pnkToken The PNK token, at 0x93ED3FBe21207Ec2E8f2d3c3de6e058Cb73Bc04d. TRUSTED.
     *  @param _wethToken The WETH token, at 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2. TRUSTED.
     *  @param _bpool The BPool to recover the liquidity from, at 0xC81d50c17754B379F1088574CF723Be4fb00307D. TRUSTED.
     *  @param _controller The controller of the PNK token, at 0x988b3A538b618C7A603e1c11Ab82Cd16dbE28069. TRUSTED.
     *  @param _beneficiary The address to send the equivalent of locked liquidity to, at 0x67a57535b11445506a9e340662CD0c9755E5b1b4. TRUSTED.
     */
    constructor(
        IMiniMeToken _pnkToken,
        IERC20 _wethToken,
        IBPool _bpool,
        address _controller,
        address _beneficiary
    ) public {
        pnkToken = _pnkToken;
        wethToken = _wethToken;
        bpool = _bpool;
        controller = _controller;
        beneficiary = _beneficiary;
    }

    /** @dev Ask for PNK token's controller to be restored.
     *  Safeguard if the recovery does not work.
     *  Note that this gives one hour for the recovery to be executed.
     */
    function initiateRestoreController() external {
        require(initiateRestoreControllerTimestamp == 0);
        require(pnkToken.controller() == address(this));
        initiateRestoreControllerTimestamp = block.timestamp;
    }

    /** @dev Restore the PNK token's controller.
     *  In case the recovery cannot be executed.
     *  Can be called by the governor, or by anyone one hour after initiateRestoreController.
     */
    function restoreController() external {
        require(initiateRestoreControllerTimestamp != 0);
        require(initiateRestoreControllerTimestamp + 1 hours < block.timestamp);
        pnkToken.changeController(address(controller));
    }

    /** @dev Recover the locked funds.
     *  This function ensures everything happens in the same transaction.
     *  Note that this function requires a high gas limit.
     *  Note that all contracts are trusted.
     */
    function recover() external {
        recoveryOngoing = true;

        /* QUERY POOL STATE */
        uint256 poolBalancePNK = pnkToken.balanceOf(address(bpool));
        uint256 balancePNK = poolBalancePNK;
        uint256 balanceWETH;

        /* PULL PNK */
        pnkToken.transferFrom(address(bpool), address(this), poolBalancePNK - 2); // Need to be the controller.
        bpool.gulp(address(pnkToken));
        pnkToken.approve(address(bpool), poolBalancePNK - 2);
        poolBalancePNK = 2;

        /* PULL WETH (A.K.A ARBITRAGE) */

        for (uint256 i = 0; i < ITERATION_COUNT; i++) {
            uint256 tokenAmountIn = poolBalancePNK / 2;
            (uint256 tokenAmoutOut, ) = bpool.swapExactAmountIn(
                address(pnkToken), // tokenIn
                tokenAmountIn, // tokenAmountIn
                address(wethToken), // tokenOut
                0, // minAmountOut
                uint256(-1) // maxPrice
            );

            balanceWETH += tokenAmoutOut;
            poolBalancePNK += tokenAmountIn;
        }

        // Recover swapped PNK.
        pnkToken.transferFrom(address(bpool), address(this), poolBalancePNK); // Need to be the controller.

        /* SEND FUNDS TO BENEFICIARY */
        wethToken.transfer(beneficiary, balanceWETH);
        pnkToken.transfer(beneficiary, balancePNK);

        /* RESTORE CONTROLLER */
        pnkToken.changeController(address(controller));
    }

    // Since the recovery contract is PNK's controller, it has to allow transfers and approvals during the recovery only.
    function proxyPayment(address _owner) override public payable returns (bool) {
        return false;
    }
    function onTransfer(address _from, address _to, uint256 _amount) override public returns (bool) {
        return recoveryOngoing;
    }
    function onApprove(address _owner, address _spender, uint256 _amount) override public returns (bool) {
        return true;
    }
}