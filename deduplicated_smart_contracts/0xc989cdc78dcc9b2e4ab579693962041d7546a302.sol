/**

 *Submitted for verification at Etherscan.io on 2018-10-31

*/



pragma solidity ^0.4.25;



/**

*

* Web              - https://rocket.cash

* todo GitHub           - https://github.com/Revolution333/

* todo Twitter          - https://twitter.com/333eth_io

* todo Youtube          - https://www.youtube.com/c/333eth

* todo Discord          - https://discord.gg/P87buwT

* todo Telegram_channel - https://t.me/Ethereum333

* todo EN  Telegram_chat: https://t.me/Ethereum333_chat_en

* todo RU  Telegram_chat: https://t.me/Ethereum333_chat_ru

* todo KOR Telegram_chat: https://t.me/Ethereum333_chat_kor

* todo CN  Telegram_chat: https://t.me/Ethereum333_chat_cn

* todo Email:             mailto:support(at sign)333eth.io

*

*

* todo - GAIN 3,33% - 1% PER 24 HOURS (interest is charges in equal parts every 10 min)

* todo - Life-long payments

* todo - The revolutionary reliability

* todo - Minimal contribution 0.01 eth

* todo - Currency and payment - ETH

* todo - Contribution allocation schemes:

* todo   -- 87,5% payments

* todo   --  7,5% marketing

* todo   --  5,0% technical support

*

* todo  ---About the Project

* todo Blockchain-enabled smart contracts have opened a new era of trustless relationships without

* todo intermediaries. This technology opens incredible financial possibilities. Our automated investment

* todo distribution model is written into a smart contract, uploaded to the Ethereum blockchain and can be

* todo freely accessed online. In order to insure our investors' complete security, full control over the

* todo project has been transferred from the organizers to the smart contract: nobody can influence the

* todo system's permanent autonomous functioning.

*

* todo ---How to use:

* todo  1. Send from ETH wallet to the smart contract address 0x311f71389e3DE68f7B2097Ad02c6aD7B2dDE4C71

* todo     any amount from 0.01 ETH.

* todo  2. Verify your transaction in the history of your application or etherscan.io, specifying the address

* todo     of your wallet.

* todo  3a. Claim your profit by sending 0 ether transaction (every 10 min, every day, every week, i don't care unless you're

* todo      spending too much on GAS)

* todo  OR

* todo  3b. For reinvest, you need to deposit the amount that you want to reinvest and the

* todo      accrued interest automatically summed to your new contribution.

*

* RECOMMENDED GAS LIMIT: 350000

* RECOMMENDED GAS PRICE: https://ethgasstation.info/

* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.

*

* todo ---Referral system:

* todo     from 0 to 10.000 ethers in the fund - remuneration to each contributor is 3.33%,

* todo     from 10.000 to 100.000 ethers in the fund - remuneration will be 2%,

* todo     from 100.000 ethers in the fund - each contributor will get 1%.

*

* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you

* have private keys.

*

* todo Contracts reviewed and approved by pros!

*/

contract RocketCash

{

    uint constant public start = 1541678400;// The time Rocket.cash will start working (Thu Nov 08 2018 12:00:00 UTC)

    // Notice: you can make an investment, but you will not get your dividends until the project has started

    address constant public administrationFund = 0x4A04A4E5A15db1e57ADd4E93F3024DF214eC2f2F;// For advertising (13%) and support (2%)

    mapping (address => uint) public invested;// Investors and their investments

    mapping (address => uint) private lastInvestmentTime;// Last investment time for each investor

    mapping (address => uint) private collected;// Collected amounts for each investor

    mapping (address => Refer[]) public referrers;// Referrers for each investor (for statistics)

    mapping (address => Refer[]) public referrals;// Referrals for each investor (for statistics)

    uint public investedTotal;// Invested sum (for statistics)

    uint public investorsCount;// Investors count (for statistics)



    struct Refer// Structure for referrals (for statistics)

    {

        address investor;// Address of an investor of the project (referral)

        uint time;// Time of a transaction

        uint amount;// Amount of the transaction

        uint percent;// Percent given to a referrer

    }



    event investment(address addr, uint amount, uint invested, address referrer);// Investment event (for statistics)

    event withdraw(address addr, uint amount, uint invested);// Withdraw event (for statistics)



    function () external payable// This function has called every time someone makes a transaction to the Rocket.cash

    {

        if (msg.value > 0 ether)// If the sent value of ether is more than 0 - this is an investment

        {

            address referrer = _bytesToAddress(msg.data);// Get referrer from the "Data" field



            if (invested[referrer] > 0 && referrer != msg.sender)// If the referrer is an investor of the Rocket.cash and the referrer is not the current investor (you can't be the referrer for yourself)

            {

                uint referrerBonus = msg.value * 10 / 100;// Calculate bonus for the referrer (10%)

                uint referralBonus = msg.value * 3 / 100;// Calculate cash back bonus for the investor (3%)



                collected[referrer]   += referrerBonus;// Add bonus to the referrer

                collected[msg.sender] += referralBonus;// Add cash back bonus to the investor



                referrers[msg.sender].push(Refer(referrer, now, msg.value, referralBonus));// Save the referrer for the referral (for statistics)

                referrals[referrer].push(Refer(msg.sender, now, msg.value, referrerBonus));// Save the referral for the referrer (for statistics)

            }

            //else// If the referrer is not an investor of the Rocket.cash or the referrer is the current investor (you can't be the referrer for yourself) - do nothing



            if (start < now)// If the project has started

            {

                if (invested[msg.sender] != 0) // If the investor has already invested to the Rocket.cash

                {

                    collected[msg.sender] = availableDividends(msg.sender);// Calculate dividends of the investor and remember it

                    // Notice: you can rise up your daily percentage by making an additional investment

                }

                //else// If the investor hasn't ever invested to the Rocket.cash - he has no percent to collect yet



                lastInvestmentTime[msg.sender] = now;// Save the last investment time for the investor

            }

            else// If the project hasn't started yet

            {

                lastInvestmentTime[msg.sender] = start;// Save the last investment time for the investor as the time of the project start

            }



            if (invested[msg.sender] == 0) investorsCount++;// Increase the investors counter (for statistics)

            investedTotal += msg.value;// Increase the invested value (for statistics)



            invested[msg.sender] += msg.value;// Increase the invested value for the investor



            administrationFund.transfer(msg.value * 15 / 100);// Transfer the Rocket.cash commission (15% - for advertising (13%) and support (2%))



            emit investment(msg.sender, msg.value, invested[msg.sender], referrer);// Emit the Investment event (for statistics)

        }

        else// If the sent value of ether is 0 - this is an ask to get dividends or money back

        // WARNING! Any investor can only ask to get dividends or money back ONCE! Once the investor has got his dividends or money he would be excluded from the project!

        {

            uint withdrawalAmount = availableWithdraw(msg.sender);



            if (withdrawalAmount != 0)// If withdrawal amount is not 0

            {

                emit withdraw(msg.sender, withdrawalAmount, invested[msg.sender]);// Emit the Withdraw event (for statistics)



                msg.sender.transfer(withdrawalAmount);// Transfer the investor's money back minus the Rocket.cash commission or his dividends and bonuses



                lastInvestmentTime[msg.sender] = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project

                invested[msg.sender]           = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project

                collected[msg.sender]          = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project

            }

            //else// If withdrawal amount is 0 - do nothing

        }

    }



    function _bytesToAddress (bytes bys) private pure returns (address _address)// This function returns an address of the referrer from the "Data" field

    {

        assembly

        {

            _address := mload(add(bys, 20))

        }

    }



    function availableWithdraw (address investor) public view returns (uint)// This function calculate an available amount for withdrawal

    {

        if (start < now)// If the project has started

        {

            if (invested[investor] != 0)// If the investor of the Rocket.cash hasn't been excluded from the project and ever have been in it

            {

                uint dividends = availableDividends(investor);// Calculate dividends of the investor

                uint canReturn = invested[investor] - invested[investor] * 15 / 100;// The investor can get his money back minus the Rocket.cash commission



                if (canReturn < dividends)// If the investor has dividends more than he has invested minus the Rocket.cash commission

                {

                    return dividends;

                }

                else// If the investor has dividends less than he has invested minus the Rocket.cash commission

                {

                    return canReturn;

                }

            }

            else// If the investor of the Rocket.cash have been excluded from the project or never have been in it - available amount for withdraw = 0

            {

                return 0;

            }

        }

        else// If the project hasn't started yet - available amount for withdraw = 0

        {

            return 0;

        }

    }



    function availableDividends (address investor) private view returns (uint)// This function calculate available for withdraw amount

    {

        return collected[investor] + dailyDividends(investor) * (now - lastInvestmentTime[investor]) / 1 days;// Already collected amount plus Calculated daily dividends (depends on the invested amount) are multiplied by the count of spent days from the last investment

    }



    function dailyDividends (address investor) public view returns (uint)// This function calculate daily dividends (depends on the invested amount)

    {

        if (invested[investor] < 1 ether)// If the invested amount is lower than 1 ether

        {

            return invested[investor] * 222 / 10000;// The interest would be 2.22% (payback in 45 days)

        }

        else if (1 ether <= invested[investor] && invested[investor] < 5 ether)// If the invested amount is higher than 1 ether but lower than 5 ether

        {

            return invested[investor] * 255 / 10000;// The interest would be 2.55% (payback in 40 days)

        }

        else// If the invested amount is higher than 5 ether

        {

            return invested[investor] * 288 / 10000;// The interest would be 2.88% (payback in 35 days)

        }

    }

}