/**

 *Submitted for verification at Etherscan.io on 2019-01-16

*/



pragma solidity 0.4.25;





/**

 * Math operations with safety checks

 */

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

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

     address private _owner;



     event OwnershipTransferred(

          address indexed previousOwner,

          address indexed newOwner

     );



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor() internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns(address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns(bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract ERC20 {

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

}



contract ARXLocker {

    function loose(uint256 amount) public;

}



/**

 * @title ARXCrowdsale

 */

 contract ARXCrowdsale is Ownable {

     using SafeMath for uint256;



     address private _wallet;

     ERC20 private _token;

     ARXLocker private _locker;

     address private _exchange;

     address private _escrow;



     uint256 private _rate = 25 * 10**6;



     bool public paused;

     uint256 private _guardCounter;



     event Purchased(address indexed addr, uint256 amount);

     event Paused();

     event Unpaused();



     /**

      * @dev Prevents a contract from calling itself, directly or indirectly.

      * Calling a `nonReentrant` function from another `nonReentrant`

      * function is not supported. It is possible to prevent this from happening

      * by making the `nonReentrant` function external, and make it call a

      * `private` function that does the actual work.

      */

     modifier nonReentrant() {

         _guardCounter += 1;

         uint256 localCounter = _guardCounter;

         _;

         require(localCounter == _guardCounter);

     }



     /**

      * @dev Throws if called by any account when crowdsale is paused.

      */

     modifier whenNotPaused() {

         require(!paused);

         _;

     }



     /**

      * @dev Constructor sets:

      * 1) the original `owner` of the contract to the sender,

      * 2) the ARXToken address,

      * 3) the ARXExchange address,

      * 4) the ARXLocker address,

      * 5) the wallet address,

      * 6) the escrow address.

      */

     constructor(address ARXToken_, address ARXExchange_, address ARXLocker_, address wallet, address escrow) public {

         _token = ERC20(ARXToken_);

         _exchange = ARXExchange_;

         _locker = ARXLocker(ARXLocker_);

         _wallet = wallet;

         _escrow = escrow;

     }



     /**

      * @dev Allows the current owner to change wallet.

      * @param newWallet Address of the new wallet.

      */

     function changeWallet(address newWallet) external onlyOwner {

         require(newWallet != address(0));

         _wallet = newWallet;

     }



     /**

      * @dev Allows the current owner to change escrow.

      * @param newEscrow Address of the new escrow.

      */

     function changeEscrow(address newEscrow) external onlyOwner {

         require(newEscrow != address(0));

         _escrow = newEscrow;

     }



     /**

      * @dev Allows the current owner to change locker contract.

      * @param ARXLocker_ Address of the new locker contract.

      */

     function changeLocker(address ARXLocker_) external onlyOwner {

         require(ARXLocker_ != address(0));

         _locker = ARXLocker(ARXLocker_);

     }



     /**

      * @dev Allows the current owner to change exchange contract.

      * @param ARXExchange_ Address of the new exchange contract.

      */

     function changeExchange(address ARXExchange_) external onlyOwner {

         require(ARXExchange_ != address(0));

         _exchange = ARXExchange_;

     }



     /**

      * @dev Allows the current owner to change rate.

      * @param newRate New rate (1 token to 1 ETH exchange would be 1 * 10^8 rate)

      */

     function setRate(uint256 newRate) external onlyOwner {

         require(newRate != 0);

         _rate = newRate;

     }



     /**

      * @dev Allows the current owner to pause crowdsale.

      */

     function pause() external onlyOwner {

         _pause();

     }



     /**

      * @dev Internal function for pausing crowdsale.

      */

     function _pause() internal {

         paused = true;

         emit Paused();

     }



     /**

      * @dev Allows the current owner to pause crowdsale.

      */

     function unpause() external onlyOwner {

         paused = false;

         emit Unpaused();

     }



     /**

      * @dev Payable fallback function, if sender is not owner of the contract it calls buyTokens function.

      */

     function() external payable {

         if (msg.sender != owner()) {

             buyTokens(msg.sender);

         }

     }



     /**

      * @dev Purchasing tokens.

      * @param beneficiary Recipient of the token purchase.

      */

     function buyTokens(address beneficiary) public nonReentrant whenNotPaused payable {

         require(msg.value >= 0.01 ether);



         uint256 weiAmount = msg.value;

         uint256 amount = msg.value.mul(_rate).div(1 ether);

         uint256 balance = _token.balanceOf(this);



         require(amount > 0);



         if (amount >= balance) {

             _pause();

             amount = balance;

             weiAmount = amount.mul(1 ether).div(_rate);

             uint256 change = msg.value.sub(weiAmount);

             beneficiary.transfer(change);

         }



         uint256 gas = gasleft();

         _forwardFunds(weiAmount);

         _locker.loose(amount);

         beneficiary.transfer(tx.gasprice.mul(gas.sub(gasleft())));



         _token.transfer(beneficiary, amount);



         emit Purchased(beneficiary, amount);

     }



     /**

      * @dev Internal function for distributing funds (20% to ARXExchange, 30% to the wallet, 50% to the escrow address)

      * @param weiAmount Amount of ETH.

      */

     function _forwardFunds(uint256 weiAmount) internal {

         _exchange.transfer(weiAmount.div(5));

         _wallet.transfer(weiAmount.mul(3).div(10));

         _escrow.transfer(weiAmount.div(2));

     }



     /**

      * @dev Allows the current owner to finalize crowdsale (withdraw remaining tokens and pause crowdsale).

      * @param beneficiary Address to recieve tokens.

      */

     function finalizeICO(address beneficiary) external onlyOwner {

         require(beneficiary != address(0));

         uint256 balance = _token.balanceOf(this);

         _token.transfer(beneficiary, balance);

         _pause();

     }



     /**

      * @return token balance of given address

      * @param owner Address of token holder.

      */

     function balanceOf(address owner) external view returns(uint256) {

         return _token.balanceOf(owner);

     }

 }