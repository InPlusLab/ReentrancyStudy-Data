pragma solidity ^0.5.0;



import "./SafeERC20.sol";



/**

 * @title ForTokenTimelock

 * @dev ForTokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time.



 * 1, 取回时间从合约部署当天开始计算

 * 2, 第一次解锁时间为55天之后，第二次解锁时间为145天之后。

 * 3, 第一解锁时间为全部锁定token的一半。

 * 4, 只能取回The Force Token (FOR)合约 0x1FCdcE58959f536621d76f5b7FfB955baa5A672F

 * 5, 只能取回到指定的地址 0xb7A6Fc901ea7Af2B2A25F972958CF92cAfB236Da

 */

contract ForTokenTimelock {

    using SafeERC20 for IERC20;



    // ERC20 basic token contract being held

    IERC20 private _token = IERC20(0x1FCdcE58959f536621d76f5b7FfB955baa5A672F);



    // beneficiary of tokens after they are released

    address private _beneficiary = 0xb7A6Fc901ea7Af2B2A25F972958CF92cAfB236Da;



    // Date when token release is enabled

    uint256 private _firstReleaseDate = now + 55 days;

    uint256 private _secondReleaseDate = now + 145 days;

    bool _isFirstClaimAlready = false;



    /**

     * @notice Transfers tokens held by Date to beneficiary.

     */

    function release() public {

        uint256 amount = _token.balanceOf(address(this));

        require(amount > 0, "ForTokenTimelock: no tokens to release");



        if (now >= _firstReleaseDate && _isFirstClaimAlready == false) {

            _token.safeTransfer(_beneficiary, amount/2);

            _isFirstClaimAlready = true;

        } else if (now >= _secondReleaseDate){

            _token.safeTransfer(_beneficiary, amount);

        }

    }

}

