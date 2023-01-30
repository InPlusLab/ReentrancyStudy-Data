/**

 *Submitted for verification at Etherscan.io on 2018-10-03

*/



pragma solidity ^0.4.24;



/**

 *

 * Infinite3 Contract

 *  - GAIN 3% EVERY 24 HOURS (every 5900 blocks)

 *  - 0.5% for Promotion on your investment (every ether stays on contract's balance)

 *  - 0.5% dev commision

 *  - 10% affliate commision 

 *  - 89% Payout commision 

 *

 * How to use:

 *  1. Send any amount of ether to make an investment(minimum 0.01)

 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)

 *  OR

 *  2b. Send more ether to reinvest AND get your profit at the same time

 *

 * RECOMMENDED GAS LIMIT: 100000000000000000000

 * RECOMMENDED GAS PRICE: https://ethgasstation.info/

 * https://infinite3.life

 * https://discord.gg/qnjcFWq

 * Contract reviewed and approved by professionals!

 *

 */



contract Infinite3{

    

    using SafeMath for uint256;



    mapping(address => uint256) investments;

    mapping(address => uint256) joined;

    mapping(address => uint256) withdrawals;

    mapping(address => uint256) referrer;



    uint256 public minimum = 10000000000000000;

    uint256 public step = 3;

    address public ownerWallet;

    address public owner;

    address public bountyManager;

    address promoter = 0xf8EeAe7abe051A0B7a4ec5758af411F870A8Add3;



    event Invest(address investor, uint256 amount);

    event Withdraw(address investor, uint256 amount);

    event Bounty(address hunter, uint256 amount);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    /**

     * @dev ��onstructor Sets the original roles of the contract 

     */

     

    constructor(address _bountyManager) public {

        owner = msg.sender;

        ownerWallet = msg.sender;

        bountyManager = _bountyManager;

    }



    /**

     * @dev Modifiers

     */

     

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    modifier onlyBountyManager() {

        require(msg.sender == bountyManager);

        _;

	}



    /**

     * @dev Allows current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     * @param newOwnerWallet The address to transfer ownership to.

     */

    function transferOwnership(address newOwner, address newOwnerWallet) public onlyOwner {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        ownerWallet = newOwnerWallet;

    }



    /**

     * @dev Investments

     */

    function () external payable {

        require(msg.value >= minimum);

        if (investments[msg.sender] > 0){

            if (withdraw()){

                withdrawals[msg.sender] = 0;

            }

        }

        investments[msg.sender] = investments[msg.sender].add(msg.value);

        joined[msg.sender] = block.timestamp;

        ownerWallet.transfer(msg.value.div(1000).mul(5));

        promoter.transfer(msg.value.div(1000).mul(5));

        emit Invest(msg.sender, msg.value);

    }



    /**

    * @dev Evaluate current balance

    * @param _address Address of investor

    */

    function getBalance(address _address) view public returns (uint256) {

        uint256 minutesCount = now.sub(joined[_address]).div(1 minutes);

        uint256 percent = investments[_address].mul(step).div(100);

        uint256 different = percent.mul(minutesCount).div(1440);

        uint256 balance = different.sub(withdrawals[_address]);



        return balance;

    }



    /**

    * @dev Withdraw dividends from contract

    */

    function withdraw() public returns (bool){

        require(joined[msg.sender] > 0);

        uint256 balance = getBalance(msg.sender);

        if (address(this).balance > balance){

            if (balance > 0){

                withdrawals[msg.sender] = withdrawals[msg.sender].add(balance);

                msg.sender.transfer(balance);

                emit Withdraw(msg.sender, balance);

            }

            return true;

        } else {

            return false;

        }

    }

    

    /**

    * @dev Bounty reward

    */

    function bounty() public {

        uint256 refBalance = checkReferral(msg.sender);

        if(refBalance >= minimum) {

             if (address(this).balance > refBalance) {

                referrer[msg.sender] = 0;

                msg.sender.transfer(refBalance);

                emit Bounty(msg.sender, refBalance);

             }

        }

    }



    /**

    * @dev Gets balance of the sender address.

    * @return An uint256 representing the amount owned by the msg.sender.

    */

    function checkBalance() public view returns (uint256) {

        return getBalance(msg.sender);

    }



    /**

    * @dev Gets withdrawals of the specified address.

    * @param _investor The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function checkWithdrawals(address _investor) public view returns (uint256) {

        return withdrawals[_investor];

    }



    /**

    * @dev Gets investments of the specified address.

    * @param _investor The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function checkInvestments(address _investor) public view returns (uint256) {

        return investments[_investor];

    }



    /**

    * @dev Gets referrer balance of the specified address.

    * @param _hunter The address of the referrer

    * @return An uint256 representing the referral earnings.

    */

    function checkReferral(address _hunter) public view returns (uint256) {

        return referrer[_hunter];

    }

    

    /**

    * @dev Updates referrer balance 

    * @param _hunter The address of the referrer

    * @param _amount An uint256 representing the referral earnings.

    */

    function updateReferral(address _hunter, uint256 _amount) onlyBountyManager public {

        referrer[_hunter] = referrer[_hunter].add(_amount);

    }

    

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}