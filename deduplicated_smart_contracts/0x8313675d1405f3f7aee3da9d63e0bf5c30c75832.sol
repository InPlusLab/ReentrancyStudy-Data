/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

/*
* ETHEREUM SMARTCONTRACT - ALTES FINANCE GROUP PTY LTD
*
* - Plans with daily payments! Receive from 1.5% to 2% of the amount of your deposit within 24 hours (every 86400 seconds)
* - Plans with capitalization, the body of the contribution and the profit returned at the end of the term. Receive from 1.5% to 2% of the amount of your deposit, for a period of 1 month to 3
* - reliable and unique project
* - minimum deposit 0.6 ETH
* - minimum payout 0.01 ETH
* - Currency and payment - ETH
* - !!! You cannot transfer from exchanges, only from your personal ETH wallet !!!
* - Distribution schemes for contributions:
* - 90% on payments on deposits
* - 10% for advertising and contract support + Operating expenses
*
*
* You can check payments on the etherscan.io website, on the ¡°Internal Txns¡± tab of your wallet.
*
*
* The contract has been reviewed and approved by professionals!
*
* Contracts reviewed and approved by pros!
*/

pragma solidity ^0.4.25;

contract ALTESFINANCEGROUP {

    struct Investor
    {
        uint amount; //amount of deposit
        uint dateUpdate; //date of deposit
        uint dateEnd;
        address refer; //address of referrer
        bool active; //he has deposit
        bool typePlan;
    }

    uint256 constant private MINIMUM_INVEST = 0.6 ether; //minimal amount for deposit
    uint256 constant private MINIMUM_PAYMENT = 0.01 ether; //minimal amount for withdrawal
    uint constant private PERCENT_FOR_ADMIN = 10; //fee for admin
    uint constant private PERCENT_FOR_REFER = 5; //fee for refer
    uint constant private PROFIT_PERIOD = 86400; //time of create profit, every 1 dey
    address constant private ADMIN_ADDRESS = 0x2803Ef1dFF52D6bEDE1B2714A8Dd4EA82B8aE733; //fee for refer

    mapping(address => Investor) investors; //investors list

    event Transfer (address indexed _to, uint256 indexed _amount);

    constructor () public {
    }

    /**
     * This function calculated percent
     */
    function getPercent(Investor investor) private pure returns (uint256) {
        uint256 amount = investor.amount;

        if (amount >= 0.60 ether && amount <= 5.99 ether) {
            return 150;
        } else if (amount >= 29 ether && amount <= 58.99 ether) {
            return 175;
        } else if (amount >= 119 ether && amount <= 298.99 ether) {
            return 200;
        } else if (amount >= 6 ether && amount <= 28.99 ether) {
            return 38189;
        } else if (amount >= 59.99 ether && amount <= 118.99 ether) {
            return 28318;
        } else if (amount >=  299.99 ether && amount <= 600 ether) {
            return 18113;
        }
        return 0;
    }

    function getDate(Investor investor) private view returns (uint256) {
        uint256 amount = investor.amount;
        if (amount >= 0.60 ether && amount <= 5.99 ether) {
            return PROFIT_PERIOD * 120 + now;
        } else if (amount >= 29 ether && amount <= 58.99 ether) {
            return PROFIT_PERIOD * 150 + now;
        } else if (amount >= 119 ether && amount <= 298.99 ether) {
            return PROFIT_PERIOD * 180 + now;
        } else if (amount >= 6 ether && amount <= 28.99 ether) {
            return PROFIT_PERIOD * 90 + now;
        } else if (amount >= 59.99 ether && amount <= 118.99 ether) {
            return PROFIT_PERIOD * 60 + now;
        } else if (amount >=  299.99 ether && amount <= 600 ether) {
            return PROFIT_PERIOD * 30 + now;
        }
        return 0;
    }

    function getTypePlan(Investor investor) private pure returns (bool) {
        uint256 amount = investor.amount;
        if (amount >= 0.60 ether && amount <= 5.99 ether) {
            return false;
        } else if (amount >= 29 ether && amount <= 58.99 ether) {
            return false;
        } else if (amount >= 119 ether && amount <= 298.99 ether) {
            return false;
        } else if (amount >= 6 ether && amount <= 28.99 ether) {
            return true;
        } else if (amount >= 59.99 ether && amount <= 118.99 ether) {
            return true;
        } else if (amount >=  299.99 ether && amount <= 600 ether) {
            return true;
        }
        return false;
    }

    /**
     * This function calculated the remuneration for the administrator
     */
    function getFeeForAdmin(uint256 amount) private pure returns (uint256) {
        return amount * PERCENT_FOR_ADMIN / 100;
    }

    /**
     * This function calculated the remuneration for the refer
     */
    function getFeeForRefer(uint256 amount) private pure returns (uint256) {
        return amount * PERCENT_FOR_REFER / 100;
    }

    /**
     * This function calculated the remuneration for the administrator
     */
    function getRefer(bytes bys) public pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function getProfit(Investor investor) private view returns (uint256) {
        uint256 amountProfit = 0;
        if (!investor.typePlan) {
            if (now >= investor.dateEnd) {
                amountProfit = investor.amount * getPercent(investor) * (investor.dateEnd - investor.dateUpdate) / (PROFIT_PERIOD * 10000);
            } else {
                amountProfit = investor.amount * getPercent(investor) * (now - investor.dateUpdate) / (PROFIT_PERIOD * 10000);
            }
        } else {
            amountProfit = investor.amount / 10000 * getPercent(investor);
        }
        return amountProfit;
    }


    /**
     * Main function
     */
    function() external payable {
        uint256 amount = msg.value;
        //amount to deposit
        address userAddress = msg.sender;
        //address of sender
        address referAddress = getRefer(msg.data);
        //refer or empty

        require(amount == 0 || amount >= MINIMUM_INVEST, "Min Amount for investing is MINIMUM_INVEST.");

        //check Profit
        if (amount == 0 && investors[userAddress].active) {
            //profit
            require(!investors[userAddress].typePlan && now <= investors[userAddress].dateEnd, 'the Deposit is not finished');

            uint256 amountProfit = getProfit(investors[userAddress]);
            require(amountProfit > MINIMUM_PAYMENT, 'amountProfit must be > MINIMUM_PAYMENT');

            if (now >= investors[userAddress].dateEnd) {
                investors[userAddress].active = false;
            }

            investors[userAddress].dateUpdate = now;

            userAddress.transfer(amountProfit);
            emit Transfer(userAddress, amountProfit);

        } else if (amount >= MINIMUM_INVEST && !investors[userAddress].active) {//if this deposit request
            //fee admin
            ADMIN_ADDRESS.transfer(getFeeForAdmin(amount));
            emit Transfer(ADMIN_ADDRESS, getFeeForAdmin(amount));

            investors[userAddress].active = true;
            investors[userAddress].dateUpdate = now;
            investors[userAddress].amount = amount;
            investors[userAddress].dateEnd = getDate(investors[userAddress]);
            investors[userAddress].typePlan = getTypePlan(investors[userAddress]);


            //if refer exist
            if (investors[referAddress].active && referAddress != address(0)) {
                investors[userAddress].refer = referAddress;
            }

            //send refer fee
            if (investors[userAddress].refer != address(0)) {
                investors[userAddress].refer.transfer(getFeeForRefer(amount));
                emit Transfer(investors[userAddress].refer, getFeeForRefer(amount));
            }
        }
    }

    /**
     * This function show deposit
     */
    function showDeposit(address _deposit) public view returns (uint256) {
        return investors[_deposit].amount;
    }

    /**
     * This function show block of last change
     */
    function showLastChange(address _deposit) public view returns (uint256) {
        return investors[_deposit].dateUpdate;
    }

    /**
     * This function show unpayed percent of deposit
     */
    function showUnpayedPercent(address _deposit) public view returns (uint256) {
        uint256 amount = getProfit(investors[_deposit]);
        return amount;
    }


}