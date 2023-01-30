/**
 *Submitted for verification at Etherscan.io on 2019-10-06
*/

pragma solidity ^0.4.21;

/*

Red Street presents........

�������������[ ���������������[�������������[     ���������������[�����������������[�������������[ ���������������[���������������[�����������������[    �������������[  �������������[ �������[   �����[�������������[ ���������������[
�����X�T�T�����[�����X�T�T�T�T�a�����X�T�T�����[    �����X�T�T�T�T�a�^�T�T�����X�T�T�a�����X�T�T�����[�����X�T�T�T�T�a�����X�T�T�T�T�a�^�T�T�����X�T�T�a    �����X�T�T�����[�����X�T�T�T�����[���������[  �����U�����X�T�T�����[�����X�T�T�T�T�a
�������������X�a�����������[  �����U  �����U    ���������������[   �����U   �������������X�a�����������[  �����������[     �����U       �������������X�a�����U   �����U�����X�����[ �����U�����U  �����U���������������[
�����X�T�T�����[�����X�T�T�a  �����U  �����U    �^�T�T�T�T�����U   �����U   �����X�T�T�����[�����X�T�T�a  �����X�T�T�a     �����U       �����X�T�T�����[�����U   �����U�����U�^�����[�����U�����U  �����U�^�T�T�T�T�����U
�����U  �����U���������������[�������������X�a    ���������������U   �����U   �����U  �����U���������������[���������������[   �����U       �������������X�a�^�������������X�a�����U �^���������U�������������X�a���������������U
�^�T�a  �^�T�a�^�T�T�T�T�T�T�a�^�T�T�T�T�T�a     �^�T�T�T�T�T�T�a   �^�T�a   �^�T�a  �^�T�a�^�T�T�T�T�T�T�a�^�T�T�T�T�T�T�a   �^�T�a       �^�T�T�T�T�T�a  �^�T�T�T�T�T�a �^�T�a  �^�T�T�T�a�^�T�T�T�T�T�a �^�T�T�T�T�T�T�a
                                                                                                                             
                                                            
website:    https://redstreetmarket.com

discord:    https://discord.gg/Nmcax6V


Red Street Bonds is a game with earning opportunities avaliable for players actively engaged in the game.   Buy a bond and reap the rewards from other players as they buy in.

Bonds also distribute 5% yield from buys and sell of the Stock Exchange which is also available on the Red Street Market.

The price of your bond automatically increases once you buy it.   You earn yield until someone else buys your bond.   Then you collect 50% of the gain.

40% of the gain is distributed to the other bond owners.  5% goes to Red Street Marketing.

The yields are based on the relative price of your bond.  If your bond is priced higher than the average of the other bonds, you will get proportionally more
yield.  The current yield rate will be listed on your bond at any time along with the price.

A bonus referral program is available.   Using your Masternode you will collect 5% of any net gains made during a purcchase by the user of your masternode.

*/

contract BONDS {
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
    event onBondPurchase(
        address customerAddress,
        uint256 incomingEthereum,
        uint256 bond,
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
        uint256 bond
    );

    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "REDSTREETBONDS";
    string public symbol = "REDBOND";

    

    uint8 constant public referralRate = 5; 

    uint8 constant public decimals = 18;
  
    uint public totalBondValue = 0;

    bool public contractActive = false;


    
   /*================================
    =            DATASETS            =
    ================================*/
    
    mapping(uint => address) internal bondOwner;
    mapping(uint => uint) public bondPrice;
    mapping(uint => uint) internal bondPreviousPrice;
    mapping(address => uint) internal ownerAccounts;
    mapping(uint => uint) internal totalBondDivs;
    mapping(uint => string) internal bondName;

    uint bondPriceIncrement = 125;   //25% Price Increases
    uint totalDivsProduced = 0;

    uint public maxBonds = 200;
    
    uint public initialPrice = 5e17;   //0.5 ETH

    uint public nextAvailableBond;

    bool allowReferral = false;

    bool allowAutoNewBond = false;

    uint8 public devDivRate = 10;
    uint8 public ownerDivRate = 50;
    uint8 public distDivRate = 40;

    uint public bondFund = 0;
   
    address dev;

    
    


    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    function BONDS()
        public
    {
        dev = msg.sender;
        nextAvailableBond = 11;

        bondOwner[1] = dev;
        bondPrice[1] = 5e18;//initialPrice;
        bondPreviousPrice[1] = 0;

        bondOwner[2] = dev;
        bondPrice[2] = 3e18;//initialPrice;
        bondPreviousPrice[2] = 0;

        bondOwner[3] = dev;
        bondPrice[3] = 2e18;//initialPrice;
        bondPreviousPrice[3] = 0;

        bondOwner[4] = dev;
        bondPrice[4] = 1e18;//initialPrice;
        bondPreviousPrice[4] = 0;

        bondOwner[5] = dev;
        bondPrice[5] = 8e17;//initialPrice;
        bondPreviousPrice[5] = 0;

        bondOwner[6] = dev;
        bondPrice[6] = 6e17;//initialPrice;
        bondPreviousPrice[6] = 0;

        bondOwner[7] = dev;
        bondPrice[7] = 5e17;//initialPrice;
        bondPreviousPrice[7] = 0;

        bondOwner[8] = dev;
        bondPrice[8] = 3e17;//initialPrice;
        bondPreviousPrice[8] = 0;

        bondOwner[9] = dev;
        bondPrice[9] = 2e17;//initialPrice;
        bondPreviousPrice[9] = 0;

        bondOwner[10] = dev;
        bondPrice[10] = 1e17;//initialPrice;
        bondPreviousPrice[10] = 0;

        getTotalBondValue();


    }


    function addTotalBondValue(uint _new, uint _old)
    internal
    {
        //uint newPrice = SafeMath.div(SafeMath.mul(_new,bondPriceIncrement),100);
        totalBondValue = SafeMath.add(totalBondValue, SafeMath.sub(_new,_old));
    }
    
    function buy(uint _bond, address _referrer)
        public
        payable
       
    {
        require(contractActive);
        require(_bond <= nextAvailableBond);
        require(msg.value >= bondPrice[_bond]);
        require(msg.sender != bondOwner[_bond]);

        
  

        uint _newPrice = SafeMath.div(SafeMath.mul(msg.value,bondPriceIncrement),100);

         //Determine the total dividends
        uint _baseDividends = msg.value - bondPreviousPrice[_bond];
        totalDivsProduced = SafeMath.add(totalDivsProduced, _baseDividends);

        uint _devDividends = SafeMath.div(SafeMath.mul(_baseDividends,devDivRate),100);
        uint _ownerDividends = SafeMath.div(SafeMath.mul(_baseDividends,ownerDivRate),100);

        totalBondDivs[_bond] = SafeMath.add(totalBondDivs[_bond],_ownerDividends);
        _ownerDividends = SafeMath.add(_ownerDividends,bondPreviousPrice[_bond]);
            
        uint _distDividends = SafeMath.div(SafeMath.mul(_baseDividends,distDivRate),100);

        if (allowReferral && (_referrer != msg.sender) && (_referrer != 0x0000000000000000000000000000000000000000)) {
                
            uint _referralDividends = SafeMath.div(SafeMath.mul(_baseDividends,referralRate),100);
            _distDividends = SafeMath.sub(_distDividends,_referralDividends);
            ownerAccounts[_referrer] = SafeMath.add(ownerAccounts[_referrer],_referralDividends);
        }
            


        //distribute dividends to accounts
        address _previousOwner = bondOwner[_bond];
        address _newOwner = msg.sender;

        ownerAccounts[_previousOwner] = SafeMath.add(ownerAccounts[_previousOwner],_ownerDividends);
        ownerAccounts[dev] = SafeMath.add(ownerAccounts[dev],_devDividends);

        bondOwner[_bond] = _newOwner;

        distributeYield(_distDividends);
        distributeBondFund();
        //Increment the bond Price
        bondPreviousPrice[_bond] = msg.value;
        bondPrice[_bond] = _newPrice;
        //addTotalBondValue(_newPrice, bondPreviousPrice[_bond]);
        getTotalBondValue();
       
        emit onBondPurchase(msg.sender, msg.value, _bond, SafeMath.div(SafeMath.mul(msg.value,bondPriceIncrement),100));
     
    }

    function distributeYield(uint _distDividends) internal
    
    {
        uint counter = 1;

        while (counter < nextAvailableBond) { 

            uint _distAmountLocal = SafeMath.div(SafeMath.mul(_distDividends, bondPrice[counter]),totalBondValue);
            ownerAccounts[bondOwner[counter]] = SafeMath.add(ownerAccounts[bondOwner[counter]],_distAmountLocal);
            totalBondDivs[counter] = SafeMath.add(totalBondDivs[counter],_distAmountLocal);
            counter = counter + 1;
        } 

    }
    
    function distributeBondFund() internal
    
    {
        if(bondFund > 0){
            uint counter = 1;

            while (counter < nextAvailableBond) { 

                uint _distAmountLocal = SafeMath.div(SafeMath.mul(bondFund, bondPrice[counter]),totalBondValue);
                ownerAccounts[bondOwner[counter]] = SafeMath.add(ownerAccounts[bondOwner[counter]],_distAmountLocal);
                totalBondDivs[counter] = SafeMath.add(totalBondDivs[counter],_distAmountLocal);
                counter = counter + 1;
            } 
            bondFund = 0;
        }
    }

    function extDistributeBondFund() public
    onlyOwner()
    {
        if(bondFund > 0){
            uint counter = 1;

            while (counter < nextAvailableBond) { 

                uint _distAmountLocal = SafeMath.div(SafeMath.mul(bondFund, bondPrice[counter]),totalBondValue);
                ownerAccounts[bondOwner[counter]] = SafeMath.add(ownerAccounts[bondOwner[counter]],_distAmountLocal);
                totalBondDivs[counter] = SafeMath.add(totalBondDivs[counter],_distAmountLocal);
                counter = counter + 1;
            } 
            bondFund = 0;
        }
    }


    function withdraw()
    
        public
    {
        address _customerAddress = msg.sender;
        require(ownerAccounts[_customerAddress] > 0);
        uint _dividends = ownerAccounts[_customerAddress];
        ownerAccounts[_customerAddress] = 0;
        _customerAddress.transfer(_dividends);
        // fire event
        onWithdraw(_customerAddress, _dividends);
    }

    function withdrawPart(uint _amount)
    
        public
        onlyOwner()
    {
        address _customerAddress = msg.sender;
        require(ownerAccounts[_customerAddress] > 0);
        require(_amount <= ownerAccounts[_customerAddress]);
        ownerAccounts[_customerAddress] = SafeMath.sub(ownerAccounts[_customerAddress],_amount);
        _customerAddress.transfer(_amount);
        // fire event
        onWithdraw(_customerAddress, _amount);
    }


    

     // Fallback function: add funds to the addional distibution amount.   This is what will be contributed from the exchange 
     // and other contracts

    function()
        payable
        public
    {
        uint devAmount = SafeMath.div(SafeMath.mul(devDivRate,msg.value),100);
        uint bondAmount = msg.value - devAmount;
        bondFund = SafeMath.add(bondFund, bondAmount);
        ownerAccounts[dev] = SafeMath.add(ownerAccounts[dev], devAmount);
    }
    
    /**
     * Transfer bond to another address
     */
    function transfer(address _to, uint _bond )
       
        public
    {
        require(bondOwner[_bond] == msg.sender);

        bondOwner[_bond] = _to;

        emit Transfer(msg.sender, _to, _bond);

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

    function setBondPrice(uint _bond, uint _price)   //Allow the changing of a bond price owner if the dev owns it
        onlyOwner()
        public
    {
        require(bondOwner[_bond] == dev);
        bondPrice[_bond] = _price;
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
        devDivRate = _newDevRate;
        ownerDivRate = _newOwnerRate;
        distDivRate = _newDistRate;
    }

    function setActive(bool _Active)
        onlyOwner()
        public
    {
        contractActive = _Active;
    }

    function setLowerBondPrice(uint _bond, uint _newPrice)   //Allow a bond owner to lower the price if they want to dump it. They cannont raise the price
    
    {
        require(bondOwner[_bond] == msg.sender);
        require(_newPrice < bondPrice[_bond]);
        require(_newPrice >= initialPrice);

        //totalBondValue = SafeMath.sub(totalBondValue,SafeMath.sub(bondPrice[_bond],_newPrice));

        bondPrice[_bond] = _newPrice;
        getTotalBondValue();

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