/**

 *Submitted for verification at Etherscan.io on 2019-02-15

*/



/*  

    Subscrypto

    Copyright (C) 2019 Subscrypto Team



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <https://www.gnu.org/licenses/>.

*/



pragma solidity 0.5.2;





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

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







contract ERC20 {

    mapping(address => mapping(address => uint)) public allowance;

    mapping(address => uint) public balanceOf;



    function transferFrom(address src, address dst, uint wad) public returns (bool);

}





/// @author The Subscrypto Team

/// @title Subscrypto recurring payments

contract SubscryptoERC20 {

    using SafeMath for uint;

    ERC20 public erc20Contract;

    // Minimum payment for a subscription

    uint _minSubscriptionAmountWad;

    // If this many intervals pass without being collected, mark as inactive

    uint _staleIntervalThreshold;



    /**

     * Constructor

     * @param erc20ContractAddress address

     */

    constructor(address erc20ContractAddress, uint minSubscriptionAmountWad, uint staleIntervalThreshold) public {

        require(staleIntervalThreshold > 1, "staleIntervalThreshold must be > 1");

        require(minSubscriptionAmountWad > 0, "minSubscriptionAmountWad must be > 0");

        erc20Contract = ERC20(erc20ContractAddress);

        _minSubscriptionAmountWad = minSubscriptionAmountWad;

        _staleIntervalThreshold = staleIntervalThreshold;

    }



    event NewSubscription(

        address indexed subscriber,

        address indexed receiver,

        uint amountWad,

        uint32 interval

    );



    event Unsubscribe(

        address indexed subscriber, 

        address indexed receiver

    );



    event ReceiverPaymentsCollected(

        address indexed receiver,

        uint amountWad,

        uint startIndex,

        uint endIndex

    );



    event PaymentCollected(

        address indexed subscriber,

        address indexed receiver,

        uint amountWad,

        uint48 effectiveTimestamp

    );



    event UnfundedPayment(

        address indexed subscriber,

        address indexed receiver,

        uint amountWad

    );



    event StaleSubscription(

        address indexed subscriber,

        address indexed receiver

    );



    event SubscriptionDeactivated(

        address indexed subscriber,

        address indexed receiver

    );



    event SubscriptionReactivated(

        address indexed subscriber,

        address indexed receiver

    );



    // Conservative amount of gas used per loop in collectPayments()

    uint constant MIN_GAS_PER_COLLECT_PAYMENT = 45000;

    // Force subscribers to use multiple accounts when this limit is reached.

    uint constant MAX_SUBSCRIPTION_PER_SUBSCRIBER = 10000;



    struct Subscription {

        bool    isActive;        //  1 byte

        uint48  nextPaymentTime; //  6 bytes

        uint32  interval;        //  4 bytes

        address subscriber;      // 20 bytes

        address receiver;        // 20 bytes

        uint    amountWad;       // 32 bytes

    }



    // global counter for suscriptions

    uint64 nextIndex = 1;



    // source of truth for subscriptions

    mapping(uint64 => Subscription) public subscriptions;



    // subscriber => receiver => subsciptionIndex

    mapping(address => mapping(address => uint64)) public subscriberReceiver;



    // receiver => subs array

    mapping(address => uint64[]) public receiverSubs;



    // subscriber => subs array

    mapping(address => uint64[]) public subscriberSubs;



    /**

     * Create a new subscription. Must be called by the subscriber's account.

     * First payment of `amountWad` is paid on creation.

     * @param receiver address

     * @param amountWad subscription amount in wad format

     * @param interval seconds between payments

     */

    function subscribe(address receiver, uint amountWad, uint32 interval) external {

        uint64 existingIndex = subscriberReceiver[msg.sender][receiver];

        require(subscriptions[existingIndex].amountWad == 0, "Subscription exists");

        require(amountWad >= _minSubscriptionAmountWad, "Subsciption amount too low");

        require(interval >= 86400, "Interval must be at least 1 day");

        require(interval <= 31557600, "Interval must be at most 1 year");

        require(subscriberSubs[msg.sender].length < MAX_SUBSCRIPTION_PER_SUBSCRIBER,"Subscription count limit reached");



        // first payment

        require(erc20Contract.transferFrom(msg.sender, receiver, amountWad), "ERC20 transferFrom() failed");



        // add to subscription mappings

        subscriptions[nextIndex] = Subscription(

            true,

            uint48(now.add(interval)),

            interval,

            msg.sender,

            receiver,

            amountWad

        );

        subscriberReceiver[msg.sender][receiver] = nextIndex;

        receiverSubs[receiver].push(nextIndex);

        subscriberSubs[msg.sender].push(nextIndex);



        emit NewSubscription(msg.sender, receiver, amountWad, interval);

        emit PaymentCollected(msg.sender, receiver, amountWad, uint48(now));



        nextIndex++;

    }

    

    /**

     * Deactivate a subscription. Must be called by the subscriber's account.

     * Payments cannot be collected from deactivated subscriptons.

     * @param receiver address used to identify the unique subscriber-receiver pair.

     * @return success

     */

    function deactivateSubscription(address receiver) external returns (bool) {

        uint64 index = subscriberReceiver[msg.sender][receiver];

        require(index != 0, "Subscription does not exist");



        Subscription storage sub = subscriptions[index];

        require(sub.isActive, "Subscription is already disabled");

        require(sub.amountWad > 0, "Subscription does not exist");



        sub.isActive = false;

        emit SubscriptionDeactivated(msg.sender, receiver);



        return true;

    }



    /**

     * Reactivate a subscription. Must be called by the subscriber's account.

     * If less than one interval has passed since the last payment, no payment is collected now.

     * Otherwise it is treated as a new subscription starting now, and the first payment is collected.

     * No back-payments are collected.

     * @param receiver addres used to identify the unique subscriber-receiver pair.

     * @return success

     */

    function reactivateSubscription(address receiver) external returns (bool) {

        uint64 index = subscriberReceiver[msg.sender][receiver];

        require(index != 0, "Subscription does not exist");



        Subscription storage sub = subscriptions[index];

        require(!sub.isActive, "Subscription is already active");



        sub.isActive = true;

        emit SubscriptionReactivated(msg.sender, receiver);



        if (calculateUnpaidIntervalsUntil(sub, now) > 0) {

            // only make a payment if at least one interval has lapsed since the last payment

            require(erc20Contract.transferFrom(msg.sender, receiver, sub.amountWad), "Insufficient funds to reactivate subscription");

            emit PaymentCollected(msg.sender, receiver, sub.amountWad, uint48(now));

        }



        sub.nextPaymentTime = uint48(now.add(sub.interval));



        return true;

    }



    /**

     * Delete a subscription. Must be called by the subscriber's account.

     * @param receiver address used to identify the unique subscriber-receiver pair.

     */

    function unsubscribe(address receiver) external {

        uint64 index = subscriberReceiver[msg.sender][receiver];

        require(index != 0, "Subscription does not exist");

        delete subscriptions[index];

        delete subscriberReceiver[msg.sender][receiver];

        deleteElement(subscriberSubs[msg.sender], index);

        emit Unsubscribe(msg.sender, receiver);

    }



    /**

     * Delete a subscription. Must be called by the receiver's account.

     * @param subscriber address used to identify the unique subscriber-receiver pair.

     */

    function unsubscribeByReceiver(address subscriber) external {

        uint64 index = subscriberReceiver[subscriber][msg.sender];

        require(index != 0, "Subscription does not exist");

        delete subscriptions[index];

        delete subscriberReceiver[subscriber][msg.sender];

        deleteElement(subscriberSubs[subscriber], index);

        emit Unsubscribe(subscriber, msg.sender);

    }



    /**

     * Collect all available *funded* payments for a receiver's account.

     * Helper function that calls collectPaymentsRange() with the full range.

     * Will process as many payments as possible with the gas provided and exit gracefully.

     * 

     * @param receiver address

     */

    function collectPayments(address receiver) external {

        collectPaymentsRange(receiver, 0, receiverSubs[receiver].length);

    }



    /**

     * A read-only version of collectPayments()

     * Calculates uncollected *funded* payments for a receiver.

     * @param receiver address

     * @return total unclaimed value in wad format

     */

    function getTotalUnclaimedPayments(address receiver) external view returns (uint) {

        uint totalPayment = 0;



        for (uint i = 0; i < receiverSubs[receiver].length; i++) {

            Subscription storage sub = subscriptions[receiverSubs[receiver][i]];



            if (sub.isActive && sub.amountWad != 0) {

                uint wholeUnpaidIntervals = calculateUnpaidIntervalsUntil(sub, now);

                if (wholeUnpaidIntervals > 0 && wholeUnpaidIntervals < _staleIntervalThreshold) {

                    uint authorizedBalance = allowedBalance(sub.subscriber);



                    do {

                        if (authorizedBalance >= sub.amountWad) {

                            totalPayment = totalPayment.add(sub.amountWad);

                            authorizedBalance = authorizedBalance.sub(sub.amountWad);

                        }

                        wholeUnpaidIntervals = wholeUnpaidIntervals.sub(1);

                    } while (wholeUnpaidIntervals > 0);

                }

            }

        }



        return totalPayment;

    }



    /**

     * Calculates a subscriber's total outstanding payments in wad format

     * @param subscriber address

     * @param time in seconds. If `time` < `now`, then we simply use `now`

     * @return total amount owed at `time` in wad format

     */

    function outstandingBalanceUntil(address subscriber, uint time) external view returns (uint) {

        uint until = time <= now ? now : time;



        uint64[] memory subs = subscriberSubs[subscriber];



        uint totalAmountWad = 0;

        for (uint64 i = 0; i < subs.length; i++) {

            Subscription memory sub = subscriptions[subs[i]];

            if (sub.isActive) {

                totalAmountWad = totalAmountWad.add(sub.amountWad.mul(calculateUnpaidIntervalsUntil(sub, until)));

            }

        }



        return totalAmountWad;

    }



    /**

     * Collect available *funded* payments for a receiver's account within a certain range of receiverSubs[receiver].

     * Will process as many payments as possible with the gas provided and exit gracefully.

     * 

     * @param receiver address

     * @param start starting index of receiverSubs[receiver]

     * @param end ending index of receiverSubs[receiver]

     * @return last processed index

     */

    function collectPaymentsRange(address receiver, uint start, uint end) public returns (uint) {

        uint64[] storage subs = receiverSubs[receiver];

        require(subs.length > 0, "receiver has no subscriptions");

        require(start < end && end <= subs.length, "wrong arguments for range");

        uint totalPayment = 0;



        uint last = end;

        uint i = start;

        while (i < last) {

            if (gasleft() < MIN_GAS_PER_COLLECT_PAYMENT) {

                break;

            }

            Subscription storage sub = subscriptions[subs[i]];



            // delete empty subs

            while (sub.amountWad == 0 && subs.length > 0) {

                uint lastIndex = subs.length.sub(1);

                subs[i] = subs[lastIndex];

                delete(subs[lastIndex]);

                subs.length = lastIndex;

                if (last > lastIndex) {

                    last = lastIndex;

                }

                if (lastIndex > 0) {

                    sub = subscriptions[subs[i]];

                }

            }



            if (sub.isActive && sub.amountWad != 0) {

                uint wholeUnpaidIntervals = calculateUnpaidIntervalsUntil(sub, now);

                if (wholeUnpaidIntervals > 0) {



                    if (wholeUnpaidIntervals >= _staleIntervalThreshold) {

                        sub.isActive = false;

                        emit SubscriptionDeactivated(sub.subscriber, receiver);

                        emit StaleSubscription(sub.subscriber, receiver);

                    } else {

                        uint authorizedBalance = allowedBalance(sub.subscriber);

                        uint subscriberPayment = 0;



                        do {

                            if (authorizedBalance >= sub.amountWad) {

                                totalPayment = totalPayment.add(sub.amountWad);

                                subscriberPayment = subscriberPayment.add(sub.amountWad);

                                authorizedBalance = authorizedBalance.sub(sub.amountWad);

                                emit PaymentCollected(sub.subscriber, receiver, sub.amountWad, sub.nextPaymentTime);

                                sub.nextPaymentTime = calculateNextPaymentTime(sub);

                            } else {

                                emit UnfundedPayment(sub.subscriber, receiver, sub.amountWad);

                            }

                            wholeUnpaidIntervals = wholeUnpaidIntervals.sub(1);

                        } while (wholeUnpaidIntervals > 0);



                        if (subscriberPayment > 0) {

                            assert(erc20Contract.transferFrom(sub.subscriber, receiver, subscriberPayment));

                        }

                    }

                }

            }



            i++;

        }



        emit ReceiverPaymentsCollected(receiver, totalPayment, start, i);

        return i;

    }



    /**

     * Calculates how much ERC20 balance Subscrypto is authorized to use on bealf of `subscriber`.

     * Returns the minimum(subscriber's ERC20 balance, amount authorized to Subscrypto).

     * @param subscriber address

     * @return wad amount of ERC20 available for Subscrypto payments

     */

    function allowedBalance(address subscriber) public view returns (uint) {

        uint balance = erc20Contract.balanceOf(subscriber);

        uint allowance = erc20Contract.allowance(subscriber, address(this));



        return balance > allowance ? allowance : balance;

    }



    /**

     * Helper function to search for and delete an array element without leaving a gap.

     * Array size is also decremented.

     * DO NOT USE if ordering is important.

     * @param array array to be modified

     * @param element value to be removed

     */

    function deleteElement(uint64[] storage array, uint64 element) internal {

        uint lastIndex = array.length.sub(1);

        for (uint i = 0; i < array.length; i++) {

            if (array[i] == element) {

                array[i] = array[lastIndex];

                delete(array[lastIndex]);

                array.length = lastIndex;

                break;

            }

        }

    }



    /**

     * Calculates how many whole unpaid intervals (will) have elapsed since the last payment at a specific `time`.

     * DOES NOT check if subscriber account is funded.

     * @param sub Subscription object

     * @param time timestamp in seconds

     * @return number of unpaid intervals

     */

    function calculateUnpaidIntervalsUntil(Subscription memory sub, uint time) internal view returns (uint) {

        require(time >= now, "don't use a time before now");



        if (time > sub.nextPaymentTime) {

            return ((time.sub(sub.nextPaymentTime)).div(sub.interval)).add(1);

        }



        return 0;

    }



    /**

     * Safely calculate the next payment timestamp for a Subscription

     * @param sub Subscription object

     * @return uint48 timestamp in seconds of the next payment

     */

    function calculateNextPaymentTime(Subscription memory sub) internal pure returns (uint48) {

        uint48 nextPaymentTime = sub.nextPaymentTime + sub.interval;

        assert(nextPaymentTime > sub.nextPaymentTime);

        return nextPaymentTime;

    }

}