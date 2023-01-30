/**

 *Submitted for verification at Etherscan.io on 2019-02-13

*/



pragma solidity ^0.5.2;



contract EdosTokenTimeLock {

    using SafeERC20 for IERC20;

    IERC20 private _token;

    address private _beneficiary;

    uint256 private _releaseTime;



    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {

        require(releaseTime > block.timestamp);

        _token = token;

        _beneficiary = beneficiary;

        _releaseTime = releaseTime;

    }



    function token() public view returns (IERC20) {

        return _token;

    }



    function beneficiary() public view returns (address) {

        return _beneficiary;

    }



    function releaseTime() public view returns (uint256) {

        return _releaseTime;

    }



    function release() public {

        require(block.timestamp >= _releaseTime, "The funds can not be withdrawn before the release time!");

        uint256 amount = _token.balanceOf(address(this));

        require(amount > 0);

        _token.safeTransfer(_beneficiary, amount);

    }

}



interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



library SafeERC20 {

    using SafeMath for uint256;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));

        require(token.approve(spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        require(token.approve(spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);

        require(token.approve(spender, newAllowance));

    }

}



library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}