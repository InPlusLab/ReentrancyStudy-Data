/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.4.24;

/*
*    ___ _                ___ _     _           
*   / __\ |_   _  ___    / __\ |__ (_)_ __  ___ 
*  /__\// | | | |/ _ \  / /  | '_ \| | '_ \/ __|
* / \/  \ | |_| |  __/ / /___| | | | | |_) \__ \
* \_____/_|\__,_|\___| \____/|_| |_|_| .__/|___/
*                                    |_|        
*                                            
* https://bluechip.fund/
* https://bluechip.fund/bluechips
* https://bluechip.fund/exchange
* 
* https://discord.gg/aee8BjR
* https://t.me/bluechipfund
*
*/

contract BlueChips {
    /*=================================
    =        MODIFIERS        =
    =================================*/
    modifier onlyOwner(){
        require(msg.sender == dev);
        _;
    }

    /*==============================
    =            EVENTS            =
    ==============================*/
    event oncardPurchase(
        address customerAddress,
        uint256 incomingEthereum,
        uint256 card,
        uint256 newPrice
    );

    event onWithdraw(
        address customerAddress,
        uint256 ethereumWithdrawn
    );

    // ERC20
    event Transfer(
        address from,
        address to,
        uint256 card
    );


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Blue Chips";
    string public symbol = "CHIP";

    uint8 constant public blueDivRate = 20;
    uint8 constant public ownerDivRate = 40;
    uint8 constant public distDivRate = 40;
    uint8 constant public referralRate = 5;
    uint8 constant public decimals = 18;
    uint public totalCardValue = 3.8 ether; // Make sure this is sum of constructor values
    uint public precisionFactor = 9;


   /*================================
    =            DATASETS            =
    ================================*/

    mapping(uint => address) internal cardOwner;
    mapping(uint => uint) public cardPrice;
    mapping(uint => uint) internal cardPreviousPrice;
    mapping(address => uint) internal ownerAccounts;
    mapping(uint => uint) internal totalCardDivs;

    uint cardPriceIncrement = 110;
    uint totalDivsProduced = 0;

    uint public totalCards;

    uint ACTIVATION_TIME = 1570572000;

    address dev;
    address blueDividendAddr;

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
        blueDividendAddr = 0xB40b8e3C726155FF1c6EEBD22067436D0e2669dd;

        totalCards = 12;

        cardOwner[0] = dev;
        cardPrice[0] = 1 ether;
        cardPreviousPrice[0] = cardPrice[0];

        cardOwner[1] = dev;
        cardPrice[1] = 0.75 ether;
        cardPreviousPrice[1] = cardPrice[1];

        cardOwner[2] = dev;
        cardPrice[2] = 0.5 ether;
        cardPreviousPrice[2] = cardPrice[2];

        cardOwner[3] = dev;
        cardPrice[3] = 0.4 ether;
        cardPreviousPrice[3] = cardPrice[3];

        cardOwner[4] = dev;
        cardPrice[4] = 0.3 ether;
        cardPreviousPrice[4] = cardPrice[4];

        cardOwner[5] = dev;
        cardPrice[5] = 0.25 ether;
        cardPreviousPrice[5] = cardPrice[5];

        cardOwner[6] = dev;
        cardPrice[6] = 0.2 ether;
        cardPreviousPrice[6] = cardPrice[6];

        cardOwner[7] = dev;
        cardPrice[7] = 0.15 ether;
        cardPreviousPrice[7] = cardPrice[7];

        cardOwner[8] = dev;
        cardPrice[8] = 0.1 ether;
        cardPreviousPrice[8] = cardPrice[8];

        cardOwner[9] = dev;
        cardPrice[9] = 0.08 ether;
        cardPreviousPrice[9] = cardPrice[9];

        cardOwner[10] = dev;
        cardPrice[10] = 0.05 ether;
        cardPreviousPrice[10] = cardPrice[10];

        cardOwner[11] = dev;
        cardPrice[11] = 0.02 ether;
        cardPreviousPrice[11] = cardPrice[11];

    }

    function addtotalCardValue(uint _new, uint _old)
    internal
    {
        uint newPrice = SafeMath.div(SafeMath.mul(_new,cardPriceIncrement),100);
        totalCardValue = SafeMath.add(totalCardValue, SafeMath.sub(newPrice,_old));
    }

    function buy(uint _card, address _referrer)
        public
        payable

    {
        require(_card < totalCards);
        require(now >= ACTIVATION_TIME);
        require(msg.value >= cardPrice[_card]);
        require(msg.sender != cardOwner[_card]);

        // Return excess ether if buyer overpays
        if (msg.value > cardPrice[_card]){
            uint _excess = SafeMath.sub(msg.value, cardPrice[_card]);
            ownerAccounts[msg.sender] += _excess;
        }

        addtotalCardValue(cardPrice[_card], cardPreviousPrice[_card]);

        uint _newPrice = SafeMath.div(SafeMath.mul(cardPrice[_card], cardPriceIncrement), 100);

         //Determine the total dividends
        uint _baseDividends = SafeMath.sub(cardPrice[_card], cardPreviousPrice[_card]);

        totalDivsProduced = SafeMath.add(totalDivsProduced, _baseDividends);

        uint _blueDividends = SafeMath.div(SafeMath.mul(_baseDividends, blueDivRate),100);

        uint _ownerDividends = SafeMath.div(SafeMath.mul(_baseDividends, ownerDivRate), 100);

        totalCardDivs[_card] = SafeMath.add(totalCardDivs[_card], _ownerDividends);

        _ownerDividends = SafeMath.add(_ownerDividends, cardPreviousPrice[_card]);

        uint _distDividends = SafeMath.div(SafeMath.mul(_baseDividends, distDivRate), 100);

        // If referrer is left blank,send to BLUE address
        if (_referrer != msg.sender) {

            uint _referralDividends = SafeMath.div(SafeMath.mul(_baseDividends, referralRate), 100);

            _distDividends = SafeMath.sub(_distDividends, _referralDividends);

            if (_referrer == 0x0) {
                blueDividendAddr.transfer(_referralDividends);
            }

            else {
                ownerAccounts[_referrer] = SafeMath.add(ownerAccounts[_referrer], _referralDividends);
            }
        }

        //distribute dividends to accounts
        address _previousOwner = cardOwner[_card];
        address _newOwner = msg.sender;

        ownerAccounts[_previousOwner] = SafeMath.add(ownerAccounts[_previousOwner], _ownerDividends);

        blueDividendAddr.transfer(_blueDividends);

        distributeDivs(_distDividends);

        //Increment the card Price
        cardPreviousPrice[_card] = cardPrice[_card];
        cardPrice[_card] = _newPrice;
        cardOwner[_card] = _newOwner;

        emit oncardPurchase(msg.sender, cardPreviousPrice[_card], _card, _newPrice);
    }


    function distributeDivs(uint _distDividends) internal{

            for (uint _card=0; _card < totalCards; _card++){

                uint _divShare = SafeMath.div(SafeMath.div(SafeMath.mul(cardPreviousPrice[_card], 10 ** (precisionFactor + 1)), totalCardValue) + 5, 10);
                uint _cardDivs = SafeMath.div(SafeMath.mul(_distDividends, _divShare), 10 ** precisionFactor);

                ownerAccounts[cardOwner[_card]] += _cardDivs;

                totalCardDivs[_card] = SafeMath.add(totalCardDivs[_card], _cardDivs);
            }
        }


    function withdraw()
        public
    {
        address _customerAddress = msg.sender;
        require(ownerAccounts[_customerAddress] >= 0.001 ether);

        uint _dividends = ownerAccounts[_customerAddress];
        ownerAccounts[_customerAddress] = 0;

        _customerAddress.transfer(_dividends);

        emit onWithdraw(_customerAddress, _dividends);
    }



    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    function setName(string _name)
        onlyOwner()
        public
    {
        name = _name;
    }


    function setSymbol(string _symbol)
        onlyOwner()
        public
    {
        symbol = _symbol;
    }

    function setcardPrice(uint _card, uint _price)   //Allow the changing of a card price owner if the dev owns it
        onlyOwner()
        public
    {
        require(cardOwner[_card] == dev);
        cardPrice[_card] = _price;
    }

    function addNewcard(uint _price)
        onlyOwner()
        public
    {
        cardPrice[totalCards-1] = _price;
        cardOwner[totalCards-1] = dev;
        totalCardDivs[totalCards-1] = 0;
        totalCards = totalCards + 1;
    }


    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */


    function getMyBalance()
        public
        view
        returns(uint)
    {
        return ownerAccounts[msg.sender];
    }

    function getOwnerBalance(address _cardOwner)
        public
        view
        returns(uint)
    {
        return ownerAccounts[_cardOwner];
    }

    function getcardPrice(uint _card)
        public
        view
        returns(uint)
    {
        require(_card < totalCards);
        return cardPrice[_card];
    }

    function getcardOwner(uint _card)
        public
        view
        returns(address)
    {
        require(_card < totalCards);
        return cardOwner[_card];
    }

    function gettotalCardDivs(uint _card)
        public
        view
        returns(uint)
    {
        require(_card < totalCards);
        return totalCardDivs[_card];
    }

    function getTotalDivsProduced()
        public
        view
        returns(uint)
    {
        return totalDivsProduced;
    }

    function getCardDivShare(uint _card)
        public
        view
        returns(uint)
    {
        require(_card < totalCards);
        return SafeMath.div(SafeMath.div(SafeMath.mul(cardPreviousPrice[_card], 10 ** (precisionFactor + 1)), totalCardValue) + 5, 10);
    }

    function getCardDivs(uint  _card, uint _amt)
        public
        view
        returns(uint)
    {
        uint _share = getCardDivShare(_card);
        return SafeMath.div(SafeMath.mul( _share, _amt), 10 ** precisionFactor);
    }

    function gettotalCardValue()
        public
        view
        returns(uint)
    {

        return totalCardValue;
    }

    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address (this).balance;
    }

    function gettotalCards()
        public
        view
        returns(uint)
    {
        return totalCards;
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