/**

 *Submitted for verification at Etherscan.io on 2019-01-16

*/



pragma solidity 0.4.25;



contract IERC20 {

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

}



library SafeMath {



    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {

            return 0;

        }



        uint256 c = _a * _b;

        require(c / _a == _b);



        return c;

    }



    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0);

        uint256 c = _a / _b;



        return c;

    }



    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a);

        uint256 c = _a - _b;



        return c;

    }



    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;

        require(c >= _a);



        return c;

    }



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



/**

 * @title ARXExchange

 */

contract ARXExchange {

    using SafeMath for uint256;



    IERC20 public token;



    address private _owner;



    uint256 private _priceETH;



    event Exchanged(address indexed addr, uint256 tokens, uint256 value);

    event ChangePriceETH(uint256 oldValue, uint256 newValue);



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == _owner);

        _;

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0));



        _owner = newOwner;

    }



    /**

     * @dev Constructor sets the original `owner` of the contract to the sender

     * account, address of the token contract and initial price of the token in WEI

     */

    constructor(uint256 priceETH, address ARXToken) public {

        _owner = msg.sender;

        token = IERC20(ARXToken);

        setPriceETH(priceETH);

    }



    /**

     * @dev Allows the current owner to change current price of the token in WEI

     * @param newPriceETH New price of 1 token in WEI

     */

    function setPriceETH(uint256 newPriceETH) public onlyOwner {

        require(newPriceETH != 0);

        emit ChangePriceETH(_priceETH, newPriceETH);

        _priceETH = newPriceETH;

    }



    /**

     * @dev Allows the current owner to withdraw current token balance of the contract

     * @param recipient Address to recieve tokens

     */

    function withdrawCoinBalance(address recipient) external onlyOwner {

        uint256 balanceARX = token.balanceOf(address(this));

        token.transfer(recipient, balanceARX);

    }



    /**

     * @return 

     * 1) Current price of 1 token in WEI

     * 2) ERC20 balance of the contract

     * 3) ERC20 allowance from given address to this contract

     * 4) Calculated WEI amount for approved tokens

     * @param addr needed address

     */

    function getInfo(address addr) external view returns(uint256, uint256, uint256, uint256) {

        return(_priceETH, token.balanceOf(addr), token.allowance(addr, address(this)), token.allowance(addr, address(this)) * _priceETH);

    }



    /**

     * @return true if given address has approved any amount of tokens to this contract

     * @param addr needed address

     */

    function amIReadyToExchange(address addr) public view returns(bool) {

        uint256 approved = token.allowance(addr, address(this));

        if (approved > 0) {

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Payable fallback function to recieve Ether (even 0), it also calls toETH function if sender has some approved tokens

     */

    function() external payable {

        if (amIReadyToExchange(msg.sender)) {

            toETH();

        }

    }



    /**

     * @dev Exchanges approved tokens to ethereum

     */

    function toETH() public {

        uint256 amount = token.allowance(msg.sender, address(this));

        require(amount > 0);

        token.transferFrom(msg.sender, address(this), amount);

        msg.sender.transfer(amount.mul(_priceETH));

        emit Exchanged(msg.sender, amount, amount.mul(_priceETH));

    }

}