/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.4.24;



/*







 __          __            _     _____                            _         _   _           __          __        _     _ 

 \ \        / /           | |   |  __ \                          (_)       | | | |          \ \        / /       | |   | |

  \ \  /\  / /__  _ __ ___| |_  | |__) |__ _ __ ___  ___  _ __    _ _ __   | |_| |__   ___   \ \  /\  / /__  _ __| | __| |

   \ \/  \/ / _ \| '__/ __| __| |  ___/ _ \ '__/ __|/ _ \| '_ \  | | '_ \  | __| '_ \ / _ \   \ \/  \/ / _ \| '__| |/ _` |

    \  /\  / (_) | |  \__ \ |_  | |  |  __/ |  \__ \ (_) | | | | | | | | | | |_| | | |  __/    \  /\  / (_) | |  | | (_| |

     \/  \/ \___/|_|  |___/\__| |_|   \___|_|  |___/\___/|_| |_| |_|_| |_|  \__|_| |_|\___|     \/  \/ \___/|_|  |_|\__,_|

                                                                                                                          

                                                                                                                          



website:    https://worstperson.ga



discord:    https://discord.gg/8AFP9gS



Worst Person let's YOU choose the worst person in the world AND profit from them!



Worst Person in the World is a Trading game using the Ethereum network

with earning opportunities avaliable for players actively engaged in the game.   Buy a bad person and reap the rewards from other players as they trade.



The price of your person automatically increases 25% once you buy it.   You earn yield until someone else buys your scumbag.   Then you collect 50% of the gain.



45% of the gain is distributed to the other owners.  5% goes to the Head Asshole.



The yields are based on the relative price of your jerkoff.  If your shithead is priced higher than the average of the other shitheads, you will get proportionally more

yield.  The current yield rate will be listed on your jerk at any time along with the price.



Only the owner can choose to reduce the price of the person if you feel like it's priced too high.



When you own the person you will see a REDUCE 10% button.   When you activate this button it will reduce the price of the person by 10%.



A bonus referral program is available.   Using your Masternode you will collect 5% of any net gains made during a purchase by the user of your masternode.



*/



contract WORSTPERSON{

    /*=================================

    =        MODIFIERS        =

    =================================*/

   





    modifier onlyOwner(){

        

        require(msg.sender == dev);

        _;

    }



    

    modifier onlyActive(){

        

        require(boolContractActive);

        _;

    }



    /*==============================

    =            EVENTS            =

    ==============================*/

    event onBondBuy(

        address customerAddress,

        uint256 incomingEthereum,

        uint256 bond,

        uint256 newPrice

    );

    

    event onWithdrawETH(

        address customerAddress,

        uint256 ethereumWithdrawn

    );



      event onWithdrawTokens(

        address customerAddress,

        uint256 ethereumWithdrawn

    );

    

    // ERC20

    event transferBondEvent(

        address from,

        address to,

        uint256 bond

    );



     // Reduce

    event Reduce(

        uint bond,

        uint price

    );





    

    /*=====================================

    =            CONFIGURABLES            =

    =====================================*/

    string public name = "WORSTPERSON";

    string public symbol = "JERK";



    



    uint8 constant public referralRate = 5; 



    uint8 constant public decimals = 6;

  

    uint public totalBondValue;



    uint public totalOwnerAccounts = 0;



    uint constant dayBlockFactor = 21600;



    uint contractETH = 0;



    

   /*================================

    =            DATASETS            =

    ================================*/

    

    mapping(uint => address) internal bondOwner;

    mapping(uint => uint) public bondPrice;

    mapping(uint => uint) public basePrice;

    mapping(uint => uint) internal bondPreviousPrice;

    mapping(address => uint) internal ownerAccounts;

    mapping(uint => uint) internal totalBondDivs;

    mapping(uint => uint) internal totalBondDivsETH;

    mapping(uint => string) internal bondName;



    mapping(uint => uint) internal bondBlockNumber;



    mapping(address => uint) internal ownerAccountsETH;



    uint bondPriceIncrement = 125;   //25% Price Increases

    uint totalDivsProduced = 0;



    uint public maxBonds = 200;

    

    uint public initialPrice = 0.1 ether;  



    uint public nextAvailableBond;



    bool allowReferral = false;



    bool allowAutoNewBond = false;



    uint8 devDivRate = 5;

    uint8 ownerDivRate = 50;

    uint8 distDivRate = 45;



    uint contractBalance = 0;



    address dev;



    uint256 internal tokenSupply_ = 0;



    bool public allowLocalBuy = true;

    bool public allowPriceLower = false;



    bool public boolContractActive = true;



    /*=======================================

    =            PUBLIC FUNCTIONS            =

    =======================================*/

    /*

    * -- APPLICATION ENTRY POINTS --  

    */

    constructor()

        public

    {



        dev = msg.sender;

        nextAvailableBond = 13;



        bondOwner[1] = dev;

        bondPrice[1] = 1 ether;  

        basePrice[1] = bondPrice[1];

        bondPreviousPrice[1] = 0;



        bondOwner[2] = dev;

        bondPrice[2] = 0.75 ether;  

        basePrice[2] = bondPrice[2];

        bondPreviousPrice[2] = 0;



        bondOwner[3] = dev;

        bondPrice[3] = 0.5 ether;  

        basePrice[3] = bondPrice[3];

        bondPreviousPrice[3] = 0;



        bondOwner[4] = dev;

        bondPrice[4] = 0.4 ether;  

        basePrice[4] = bondPrice[4];

        bondPreviousPrice[4] = 0;



        bondOwner[5] = dev;

        bondPrice[5] = 0.3 ether;   

        basePrice[5] = bondPrice[5];

        bondPreviousPrice[5] = 0;



        bondOwner[6] = dev;

        bondPrice[6] = 0.25 ether;  

        basePrice[6] = bondPrice[6];

        bondPreviousPrice[6] = 0;



        bondOwner[7] = dev;

        bondPrice[7] = 0.2 ether;   

        basePrice[7] = bondPrice[7];

        bondPreviousPrice[7] = 0;



        bondOwner[8] = dev;

        bondPrice[8] = 0.15 ether;  

        basePrice[8] = bondPrice[8];

        bondPreviousPrice[8] = 0;



        bondOwner[9] = dev;

        bondPrice[9] = 0.1 ether; 

        basePrice[9] = bondPrice[9];

        bondPreviousPrice[9] = 0;



        bondOwner[10] = dev;

        bondPrice[10] = 0.1 ether;  

        basePrice[10] = bondPrice[10];

        bondPreviousPrice[10] = 0;



        bondOwner[11] = dev;

        bondPrice[11] = 0.05 ether;   

        basePrice[11] = bondPrice[11];

        bondPreviousPrice[11] = 0;



        bondOwner[12] = dev;

        bondPrice[12] = 0.05 ether;  

        basePrice[12] = bondPrice[12];

        bondPreviousPrice[12] = 0;



        getTotalBondValue();

       



    }







        // Fallback function: add funds to the addional distibution amount.   This is what will be contributed from the exchange 

     // and other contracts



    function()

        payable

        public

    {

        dev.transfer(msg.value);

    }

    

    function buy(uint _bond, address _referrer)

        public 

        payable

        onlyActive()

    {

        uint _value = msg.value;

        address _sender = msg.sender;

        require(_bond <= nextAvailableBond);

        require(_value >= bondPrice[_bond]);

 

         //Determine the total dividends

        uint _baseDividends = _value - bondPreviousPrice[_bond];

        totalDivsProduced = SafeMath.add(totalDivsProduced, _baseDividends);



        //uint _devDividends = SafeMath.div(SafeMath.mul(_baseDividends,devDivRate),100);

        uint _ownerDividends = SafeMath.div(SafeMath.mul(_baseDividends,ownerDivRate),100);



        totalBondDivs[_bond] = SafeMath.add(totalBondDivs[_bond],_ownerDividends);

        _ownerDividends = SafeMath.add(_ownerDividends,bondPreviousPrice[_bond]);

            

        uint _distDividends = SafeMath.div(SafeMath.mul(_baseDividends,distDivRate),100);



        if (allowReferral && (_referrer != _sender) && (_referrer != 0x0000000000000000000000000000000000000000)) {

                

            uint _referralDividends = SafeMath.div(SafeMath.mul(_baseDividends,referralRate),100);

            _distDividends = SafeMath.sub(_distDividends,_referralDividends);

            //ownerAccounts[_referrer] = SafeMath.add(ownerAccounts[_referrer],_referralDividends);

            _referrer.transfer(_referralDividends);

        }

            





        //distribute dividends to accounts

        address _previousOwner = bondOwner[_bond];

        address _newOwner = _sender;



        //ownerAccounts[_previousOwner] = SafeMath.add(ownerAccounts[_previousOwner],_ownerDividends);

        //ownerAccounts[dev] = SafeMath.add(ownerAccounts[dev],SafeMath.div(SafeMath.mul(_baseDividends,devDivRate),100));



        _previousOwner.transfer(_ownerDividends);

        dev.transfer(SafeMath.div(SafeMath.mul(_baseDividends,devDivRate),100));





        bondOwner[_bond] = _newOwner;



        distributeYield(_distDividends);

        //distributeBondFund();

        //Increment the bond Price

        bondPreviousPrice[_bond] = _value;

        bondPrice[_bond] = SafeMath.div(SafeMath.mul(_value,bondPriceIncrement),100);

        //addTotalBondValue(SafeMath.div(SafeMath.mul(_value,bondPriceIncrement),100), bondPreviousPrice[_bond]);

        

        getTotalBondValue();

        //getTotalOwnerAccounts();

        //emit onBondBuy(_sender, _value, _bond, SafeMath.div(SafeMath.mul(_value,bondPriceIncrement),100), halfLifeTime);

     

    }



    function distributeYield(uint _distDividends) internal

    //tokens

    {

        uint counter = 1;

        uint currentBlock = block.number;



        while (counter < nextAvailableBond) { 



            uint _distAmountLocal = SafeMath.div(SafeMath.mul(_distDividends, bondPrice[counter]),totalBondValue);

            //ownerAccounts[bondOwner[counter]] = SafeMath.add(ownerAccounts[bondOwner[counter]],_distAmountLocal);



            bondOwner[counter].transfer(_distAmountLocal);



            totalBondDivs[counter] = SafeMath.add(totalBondDivs[counter],_distAmountLocal);

            

            counter = counter + 1;

        } 

        getTotalBondValue();

        //getTotalOwnerAccounts();



    }





    function reduce(uint _bond) public

    

    {

        require(msg.sender == bondOwner[_bond]);

        require(bondPrice[_bond] > 0.1 ether);

        bondPrice[_bond] = SafeMath.div(SafeMath.mul(bondPrice[_bond], 90),100);  

        bondPreviousPrice[_bond] = SafeMath.div(SafeMath.mul(bondPrice[_bond],75),100);



    }



    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/

    /**



    /**

     * If we want to rebrand, we can.

     */

    function setName(string _name)

        onlyOwner()

        public

    {

        name = _name;

    }

    

    /**

     * If we want to rebrand, we can.

     */

    function setSymbol(string _symbol)

        onlyOwner()

        public

    {

        symbol = _symbol;

    }



    function setInitialPrice(uint _price)

        onlyOwner()

        public

    {

        initialPrice = _price;

    }



    function setMaxbonds(uint _bond)  

        onlyOwner()

        public

    {

        maxBonds = _bond;

    }



    function setBondPrice(uint _bond, uint _price)   //Allow the changing of a bond price owner if the dev owns it and only lower it

        onlyOwner()

        public

    {

        require(bondOwner[_bond] == dev);



        bondPreviousPrice[_bond] = 0;  //SafeMath.div(SafeMath.mul(_price,75),100);



        bondPrice[_bond] = _price;



        getTotalBondValue();

        //getTotalOwnerAccounts();

    }

    

    function addNewbond(uint _price) 

        onlyOwner()

        public

    {

        require(nextAvailableBond < maxBonds);

        bondPrice[nextAvailableBond] = _price;

        bondOwner[nextAvailableBond] = dev;

        totalBondDivs[nextAvailableBond] = 0;

        bondPreviousPrice[nextAvailableBond] = 0;

        nextAvailableBond = nextAvailableBond + 1;

        //addTotalBondValue(_price, 0);

        getTotalBondValue();

        //getTotalOwnerAccounts();

        

    }



    function setAllowLocalBuy(bool _allow)   

        onlyOwner()

        public

    {

        allowLocalBuy = _allow;

    }



    function setAllowReferral(bool _allowReferral)   

        onlyOwner()

        public

    {

        allowReferral = _allowReferral;

    }



    function setAutoNewbond(bool _autoNewBond)   

        onlyOwner()

        public

    {

        allowAutoNewBond = _autoNewBond;

    }



    function setRates(uint8 _newDistRate, uint8 _newDevRate,  uint8 _newOwnerRate)   

        onlyOwner()

        public

    {

        require((_newDistRate + _newDevRate + _newOwnerRate) == 100);

        require(_newDevRate <= 10);

        devDivRate = _newDevRate;

        ownerDivRate = _newOwnerRate;

        distDivRate = _newDistRate;

    }



    function setLowerBondPrice(uint _bond, uint _newPrice)   //Allow a bond owner to lower the price if they want to dump it. They cannont raise the price

    

    {

        require(allowPriceLower);

        require(bondOwner[_bond] == msg.sender);

        require(_newPrice < bondPrice[_bond]);

        require(_newPrice >= initialPrice);



        //totalBondValue = SafeMath.sub(totalBondValue,SafeMath.sub(bondPrice[_bond],_newPrice));



        bondPreviousPrice[_bond] = SafeMath.div(SafeMath.mul(_newPrice,75),100);



        bondPrice[_bond] = _newPrice;

        getTotalBondValue();

        //getTotalOwnerAccounts();

    }



 

    

    /*----------  HELPERS AND CALCULATORS  ----------*/

    /**

     * Method to view the current Ethereum stored in the contract

     * Example: totalEthereumBalance()

     */



 /**

     * Retrieve the total token supply.

     */

    function totalSupply()

        public

        view

        returns(uint256)

    {

        return tokenSupply_;

    }





    function getMyBalance()

        public

        view

        returns(uint)

    {

        return ownerAccounts[msg.sender];

    }



    function getOwnerBalance(address _bondOwner)

        public

        view

        returns(uint)

    {

        require(msg.sender == dev);

        return ownerAccounts[_bondOwner];

    }

    

    function getBondPrice(uint _bond)

        public

        view

        returns(uint)

    {

        require(_bond <= nextAvailableBond);

        return bondPrice[_bond];

    }



    function getBondOwner(uint _bond)

        public

        view

        returns(address)

    {

        require(_bond <= nextAvailableBond);

        return bondOwner[_bond];

    }



    function gettotalBondDivs(uint _bond)

        public

        view

        returns(uint)

    {

        require(_bond <= nextAvailableBond);

        return totalBondDivs[_bond];

    }



    function getTotalDivsProduced()

        public

        view

        returns(uint)

    {

     

        return totalDivsProduced;

    }



    function totalEthereumBalance()

        public

        view

        returns(uint)

    {

        return address (this).balance;

    }



    function getNextAvailableBond()

        public

        view

        returns(uint)

    {

        return nextAvailableBond;

    }



    function getTotalBondValue()

        internal

        view

        {

            uint counter = 1;

            uint _totalVal = 0;



            while (counter < nextAvailableBond) { 



                _totalVal = SafeMath.add(_totalVal,bondPrice[counter]);

                

                counter = counter + 1;

            } 

            totalBondValue = _totalVal;

            

        }



}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}