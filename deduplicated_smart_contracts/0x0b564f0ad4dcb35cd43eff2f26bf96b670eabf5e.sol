/**

 *Submitted for verification at Etherscan.io on 2019-04-19

*/



pragma solidity ^0.5.7;



/**

 * Copy right (c) Donex UG (haftungsbeschraenkt)

 * All rights reserved

 * Version 0.2.1 (BETA)

 */



contract Withdraw {



    function amountCreator

    (

        bool makerLong,

        uint256 stakeMemory,

        uint256 settlementPrice,

        uint256 strikePrice,

        uint256 totalStakeCounterparties

    )

        public

        pure

        returns (uint256)

    {

        uint256 profit;

        // Long wins:

        if (settlementPrice > strikePrice)

        {

            profit = ((settlementPrice * totalStakeCounterparties * 2) / strikePrice) - (totalStakeCounterparties * 2);

            if (profit > totalStakeCounterparties)

                profit = totalStakeCounterparties;

            if (makerLong)

            {

                if (profit > (totalStakeCounterparties * 995) / 1000)

                    profit = (totalStakeCounterparties * 995) / 1000;

                return stakeMemory + profit;

            }

            else

            {

                return stakeMemory - profit;

            }

        }

        // Short wins:

        else

        {

            profit = (totalStakeCounterparties * 2) - ((settlementPrice * totalStakeCounterparties * 2) / strikePrice);

            if (profit > totalStakeCounterparties)

                profit = totalStakeCounterparties;

            if (makerLong)

            {

                return stakeMemory - profit;

            }

            else

            {

                if (profit > (totalStakeCounterparties * 995) / 1000)

                    profit = (totalStakeCounterparties * 995) / 1000;

                return stakeMemory + profit;

            }

        }

    }



    function amountCounterparty

    (

        bool makerLong,

        uint256 stakeMemory,

        uint256 settlementPrice,

        uint256 strikePrice

    )

        public

        pure

        returns (uint256)

    {

        uint256 profit;

        // Long wins:

        if (settlementPrice > strikePrice)

        {

            profit = ((settlementPrice * stakeMemory * 2) / strikePrice) - (stakeMemory * 2);

            if (profit > stakeMemory)

                profit = stakeMemory;

            if (!makerLong)

            {

                return (stakeMemory + profit) - (stakeMemory / 200);

            }

            else

            {

                if (profit < (stakeMemory * 995) / 1000)

                {

                    if ((stakeMemory - profit) - (stakeMemory / 200) > 0)

                        return (stakeMemory - profit) - (stakeMemory / 200) - 1;  // Compensate possible rounding errors

                }

            }

        }

        // Short wins:

        else

        {

            profit = (stakeMemory * 2) - ((settlementPrice * stakeMemory * 2) / strikePrice);

            if (profit > stakeMemory)

                profit = stakeMemory;

            if (!makerLong)

            {

                if (profit < (stakeMemory * 995) / 1000)

                {

                    if ((stakeMemory - profit) - (stakeMemory / 200) > 0)

                        return (stakeMemory - profit) - (stakeMemory / 200) - 1;  // Compensate possible rounding errors

                }

            }

            else

            {

                return (stakeMemory + profit) - (stakeMemory / 200);

            }

        }

        return 0;

    }



}