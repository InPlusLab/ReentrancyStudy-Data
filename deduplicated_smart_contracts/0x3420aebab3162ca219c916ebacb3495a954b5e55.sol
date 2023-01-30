/**

 *Submitted for verification at Etherscan.io on 2018-09-22

*/



pragma solidity ^0.4.24;





/**

 *

 * LEPRECHAUN - ETH CRYPTOCURRENCY DISTRIBUTION PROJECT

 *

 * Telegram bot - t.me/LeprechaunContractBot

 *

 *  - GAIN 4% PER 24 HOURS

 *  - Life-long payments

 *  - Contribution allocation schemes:

 *    -- 95% payments

 *    -- 5% commission/marketing

 *

 * HOW TO USE:

 *  1. Send of ether to make an investment (minimum 0.0001 ETH for the first investment)

 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)

 *  OR

 *  2b. Send more ether to reinvest AND get your profit at the same time

 *

 * PARTNER PROGRAM:

 * At the moment of making the first deposit, the referral indicates in the DATA field the ETH address of the referrer's wallet,

 * and the referrer then receives 12% of the first attachment of the referral,

 * and the referral also immediately gets back 13% of his deposit

 *

 * NOTES:

 * All ETHs that you've sent will be added to your deposit.

 * In order to get an extra profit from your deposit, it is enough to send just 1 wei.

 * It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you

 * have private keys.

 *

 * RECOMMENDED GAS LIMIT: 150000

 * RECOMMENDED GAS PRICE: https://ethgasstation.info/

 *

 */

library SafeMath {



    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {



        if (_a == 0) {

            return 0;

        }



        c = _a * _b;

        assert(c / _a == _b);

        return c;

    }



    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a / _b;

    }





    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        assert(_b <= _a);

        return _a - _b;

    }





    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        c = _a + _b;

        assert(c >= _a);

        return c;

    }

}



library Addr {



    function toAddr(uint source) internal pure returns(address) {

        return address(source);

    }



    function toAddr(bytes source) internal pure returns(address addr) {

        assembly { addr := mload(add(source,0x14)) }

        return addr;

    }



    function isZero(address addr) internal pure returns(bool) {

        return addr == address(0);

    }



    function notZero(address addr) internal pure returns(bool) {

        return !isZero(addr);

    }



}



contract Storage  {



    using SafeMath for uint;

    address public addrCommission = msg.sender;



    uint public constant minimalDeposit = 0.0001 ether;

    uint public constant minimalPayout = 0.000001 ether;

    uint public constant profit = 4;

    uint public constant projectCommission = 5;

    uint public constant cashbackInvestor = 13;

    uint public constant cashbackPartner = 12;

    uint public countInvestors = 0;

    uint public totalInvest = 0;

    uint public totalPaid = 0;



    mapping (address => uint256) internal balances;

    mapping (address => uint256) internal timestamps;

    mapping (address => uint256) internal referrals;

    mapping (address => uint256) internal referralsProfit;



    function getUserInvestBalance(address addr) public view returns(uint) {

        return balances[addr];

    }



    function getUserPayoutBalance(address addr) public view returns(uint) {

        if (timestamps[addr] > 0) {

            uint time = now.sub(timestamps[addr]);

            return getUserInvestBalance(addr).mul(profit).div(100).mul(time).div(1 days);

        } else {

            return 0;

        }

    }



    function getUserReferrals(address addr) public view returns(uint) {

        return referrals[addr];

    }



    function getUserReferralsProfit(address addr) public view returns(uint) {

        return referralsProfit[addr];

    }





}



contract Leprechaun is Storage {



    using Addr for *;



    modifier onlyHuman() {

        address addr = msg.sender;

        uint size;

        assembly { size := extcodesize(addr) }

        require(size == 0, "You're not a human!");

        _;

    }



    modifier checkFirstDeposit() {

        require(

            !(getUserInvestBalance(msg.sender) == 0 && msg.value > 0 && msg.value < minimalDeposit),

            "The first deposit is less than the minimum amount"

        );

        _;

    }



    modifier fromPartner() {

        if (getUserInvestBalance(msg.sender) == 0 && msg.value > 0) {

            address ref = msg.data.toAddr();

            if (ref.notZero() && ref != msg.sender && balances[ref] > 0) {

                _;

            }

        }

    }



    constructor() public payable {}



    function() public payable onlyHuman checkFirstDeposit {

        cashback();

        sendCommission();

        sendPayout();

        updateUserInvestBalance();

    }



    function cashback() internal fromPartner {



        address partnerAddr = msg.data.toAddr();

        uint amountPartner = msg.value.mul(cashbackPartner).div(100);

        referrals[partnerAddr] = referrals[partnerAddr].add(1);

        referralsProfit[partnerAddr] = referralsProfit[partnerAddr].add(amountPartner);

        transfer(partnerAddr, amountPartner);



        uint amountInvestor = msg.value.mul(cashbackInvestor).div(100);

        transfer(msg.sender, amountInvestor);



        totalPaid = totalPaid.add(amountPartner).add(amountInvestor);



    }



    function sendCommission() internal {

        if (msg.value > 0) {

            uint commission = msg.value.mul(projectCommission).div(100);

            if (commission > 0) {

                transfer(addrCommission, commission);

            }

        }

    }



    function sendPayout() internal {



        if (getUserInvestBalance(msg.sender) > 0) {



            uint profit = getUserPayoutBalance(msg.sender);



            if (profit >= minimalPayout) {

                transfer(msg.sender, profit);

                timestamps[msg.sender] = now;

                totalPaid = totalPaid.add(profit);

            }



        } else if (msg.value > 0) {

            // new user with first deposit

            timestamps[msg.sender] = now;

            countInvestors++;

        }



    }



    function updateUserInvestBalance() internal {

        balances[msg.sender] = balances[msg.sender].add(msg.value);

        totalInvest = totalInvest.add(msg.value);

    }



    function transfer(address addr, uint amount) internal {



        if (amount <= 0 || addr.isZero()) { return; }



        require(gasleft() >= 3000, "Need more gas for transaction");



        if (!addr.send(amount)) {

            // The contract does not have more money and it will be destroyed

            destroy();

        }



    }



    function destroy() internal {

        selfdestruct(addrCommission);

    }



}