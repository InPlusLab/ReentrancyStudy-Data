/**

 *Submitted for verification at Etherscan.io on 2018-09-05

*/



pragma solidity ^0.4.24;

contract ERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf( address _owner ) public view returns (uint balance);

    function allowance( address _owner, address _spender ) public view returns (uint allowance_);



    function transfer( address _to, uint _value)public returns (bool success);

    function transferFrom( address _from, address _to, uint _value)public returns (bool success);

    function approve( address _spender, uint _value )public returns (bool success);



    event Transfer( address indexed from, address indexed to, uint value);

    event Approval( address indexed _owner, address indexed _spender, uint value);

}





contract UTEMIS is ERC20{            



        uint8 public constant TOKEN_DECIMAL     = 18;        

        uint256 public constant TOKEN_ESCALE    = 1 * 10 ** uint256(TOKEN_DECIMAL); 

                                              

        uint256 public constant INITIAL_SUPPLY  = 1000000000 * TOKEN_ESCALE; // 1000000000000000000000 Smart contract UNITS | 1.000.000.000,000000000000 Ethereum representation

        uint256 public constant TGE_SUPPLY      = 1000000000 * TOKEN_ESCALE;  // 1000000000000000000000 Smart contract UNITS  |  1.000.000.000,000000000000 Ethereum representation



        uint public constant MIN_ACCEPTED_VALUE = 250000000000000000 wei;

        uint public constant VALUE_OF_UTS       = 25000000000000 wei;        // 0.000025 ETH = 1 UTS



        uint public constant START_TGE          = 1537110000; // 16 SEPT 2018 15:00:00 GMT | 16 SEPT 2018 17:00:00 GMT+2



        string public constant TOKEN_NAME       = "UTEMIS";

        string public constant TOKEN_SYMBOL     = "UTS";



    /*------------------- Finish public constants -------------------*/





    /******************** Start private NO-Constants variables ********************/

    

        uint[4]  private bonusTime             = [7 days     , 14 days     , 21 days   , 28 days];        

        uint8[4] private bonusBenefit          = [uint8(25)  , uint8(15)   , uint8(10) , uint8(5)];

        uint8[4] private bonusPerInvestion_10  = [uint8(2)   , uint8(2)    , uint8(2)  , uint8(2)];

        uint8[4] private bonusPerInvestion_20  = [uint8(4)   , uint8(4)    , uint8(4)  , uint8(4)];

    

    /*------------------- Finish private NO-Constants variables -------------------*/





    /******************** Start public NO-Constants variables ********************/        

       

        address public owner;

        address public beneficiary;            

        uint public ethersCollecteds;

        uint public tokensSold;

        uint256 public totalSupply = INITIAL_SUPPLY;

        bool public tgeStarted;            

        mapping(address => uint256) public balances;    

        mapping(address => Investors) public investorsList;

        mapping(address => mapping (address => uint256)) public allowed;

        address[] public investorsAddress;    

        string public name     = TOKEN_NAME;

        uint8 public decimals  = TOKEN_DECIMAL;

        string public symbol   = TOKEN_SYMBOL;

   

    /*------------------- Finish public NO-Constants variables -------------------*/    



    struct Investors{

        uint256 amount;

        uint when;

    }



    event Transfer(address indexed from , address indexed to , uint256 value);

    event Approval(address indexed _owner , address indexed _spender , uint256 _value);

    event Burn(address indexed from, uint256 value);

    event FundTransfer(address backer , uint amount , address investor);



    //Safe math

    function safeSub(uint a , uint b) internal pure returns (uint){assert(b <= a);return a - b;}  

    function safeAdd(uint a , uint b) internal pure returns (uint){uint c = a + b;assert(c>=a && c>=b);return c;}

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    modifier tgeIsStarted(){

        require(tgeStarted == true);        

        require(now >= START_TGE);      

        _;

    }



    modifier tgeIsStopped(){

        require(tgeStarted == false); 

        _;

    }



    modifier minValue(){

        require(msg.value >= MIN_ACCEPTED_VALUE);

        _;

    }



    constructor() public{

        balances[msg.sender] = totalSupply;

        owner                = msg.sender;        

        tgeStarted           = true;

        beneficiary          = 0x1F3fd98152f978f74349Fe2a25730Fe73e431BD8;

    }





    /**

     * ERC20

     */

    function balanceOf(address _owner) public view returns(uint256 balance){

        return balances[_owner];

    }



    /**

     * ERC20

     */

    function totalSupply() constant public returns(uint256 supply){

        return totalSupply;

    }







    /**

     * For transfer tokens. Internal use, only can executed by this contract ERC20

     * ERC20

     * @param  _from         Source address

     * @param  _to           Destination address

     * @param  _value        Amount of tokens to send

     */

    function _transfer(address _from , address _to , uint _value) internal{        

        require(_to != 0x0);                                                          //Prevent send tokens to 0x0 address        

        require(balances[_from] >= _value);                                           //Check if the sender have enough tokens        

        require(balances[_to] + _value > balances[_to]);                              //Check for overflows        

        balances[_from]         = safeSub(balances[_from] , _value);                  //Subtract from the source ( sender )        

        balances[_to]           = safeAdd(balances[_to]   , _value);                  //Add tokens to destination        

        uint previousBalance    = balances[_from] + balances[_to];                    //To make assert        

        emit Transfer(_from , _to , _value);                                               //Fire event for clients        

        assert(balances[_from] + balances[_to] == previousBalance);                   //Check the assert

    }





    /**

     * Commonly transfer tokens 

     * ERC20

     * @param  _to           Destination address

     * @param  _value        Amount of tokens to send

     */

    function transfer(address _to , uint _value) public returns (bool success){        

        _transfer(msg.sender , _to , _value);

        return true;

    }





    /**

     * Transfer token from address to another address that's allowed to. 

     * ERC20

     * @param _from          Source address

     * @param _to            Destination address

     * @param _value         Amount of tokens to send

     */   

    function transferFrom(address _from , address _to , uint256 _value) public returns (bool success){

        if(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

            _transfer(_from , _to , _value);

            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender] , _value);

            return true;

        }else{

            return false;

        }

    }



    /**

     * Approve spender to transfer amount of tokens from your address ERC20

     * ERC20

     * @param _spender       Address that can transfer tokens from your address

     * @param _value         Amount of tokens that can be sended by spender

     */   

    function approve(address _spender , uint256 _value) public returns (bool success){

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender , _spender , _value);

        return true;

    }



    /**

     * Returns the amount of tokens allowed by owner to spender ERC20

     * ERC20

     * @param _owner         Source address that allow's spend tokens

     * @param _spender       Address that can transfer tokens form allowed     

     */   

    function allowance(address _owner , address _spender) public view returns(uint256 allowance_){

        return allowed[_owner][_spender];

    }





    /**

     * Get investors info

     *

     * @return []                Returns an array with address of investors, amount invested and when invested

     */

    function getInvestors() constant public returns(address[] , uint[] , uint[]){

        uint length = investorsAddress.length;                                             //Length of array

        address[] memory addr = new address[](length);

        uint[] memory amount  = new uint[](length);

        uint[] memory when    = new uint[](length);

        for(uint i = 0; i < length; i++){

            address key = investorsAddress[i];

            addr[i]     = key;

            amount[i]   = investorsList[key].amount;

            when[i]     = investorsList[key].when;

        }

        return (addr , amount , when);        

    }





    /**

     * Get amount of bonus to apply

     *

     * @param _ethers              Amount of ethers invested, for calculation the bonus     

     * @return uint                Returns a % of bonification to apply

     */

    function getBonus(uint _ethers) public view returns(uint8){        

        uint8 _bonus  = 0;                                                          //Assign bonus to 

        uint8 _bonusPerInvestion = 0;

        uint  starter = now - START_TGE;                                            //To control end time of bonus

        for(uint i = 0; i < bonusTime.length; i++){                                 //For loop

            if(starter <= bonusTime[i]){                                            //If the starter are greater than bonusTime, the bonus will be 0                

                if(_ethers > 10 ether && _ethers <= 20 ether){

                    _bonusPerInvestion = bonusPerInvestion_10[i];

                }

                if(_ethers > 20 ether){

                    _bonusPerInvestion = bonusPerInvestion_20[i];

                }

                _bonus = bonusBenefit[i];                                           //Asign amount of bonus to bonus_ variable                                

                break;                                                              //Break the loop



            }

        }        

        return _bonus + _bonusPerInvestion;

    }



    /**

     * Calculate the amount of tokens to sends depeding on the amount of ethers received

     *

     * @param  _ethers              Amount of ethers for convert to tokens

     * @return uint                 Returns the amount of tokens to send

     */

    function getTokensToSend(uint _ethers) public view returns (uint){

        uint tokensToSend  = 0;                                                     //Assign tokens to send to 0                                            

        uint8 bonus        = getBonus(_ethers);                                     //Get amount of bonification                                    

        uint ethToTokens   = (_ethers * 10 ** uint256(TOKEN_DECIMAL)) / VALUE_OF_UTS;                                //Make the conversion, divide amount of ethers by value of each UTS                

        uint amountBonus   = ethToTokens / 100 * bonus;

             tokensToSend  = ethToTokens + amountBonus;

        return tokensToSend;

    }

    

    /**

     * Increase the total supply of tokens

     *

     * @param amount                Amount of tokens to add

     */

    function inflateSupply(uint amount) public onlyOwner returns (bool success){

        require(amount > 0);        

        totalSupply+= amount;        

        balances[owner] = safeAdd(balances[owner]   , amount);                  //Add tokens to destination               

        emit Transfer(0x0 , owner , amount);                                    //Fire event for clients        

        return true;

    }



    /**

     * Destroy amount of tokens

     *

     * @param amount                Amount of tokens to destroy

     */

    function burn(uint amount) public onlyOwner returns (bool success){

        require(balances[owner] >= amount);

        totalSupply-= amount;

        balances[owner] = safeSub(balances[owner] , amount);

        emit Burn(owner , amount);

        emit Transfer(owner , 0x0 , amount);

        return true;

    }



    /**

     * Fallback when the contract receives ethers

     *

     */

    function () payable public tgeIsStarted minValue{                              

        uint amount_actually_invested = investorsList[msg.sender].amount;           //Get the actually amount invested

        

        if(amount_actually_invested == 0){                                          //If amount invested are equal to 0, will add like new investor

            uint index                = investorsAddress.length++;

            investorsAddress[index]   = msg.sender;

            investorsList[msg.sender] = Investors(msg.value , now);                 //Store investors info        

        }

        

        if(amount_actually_invested > 0){                                           //If amount invested are greater than 0

            investorsList[msg.sender].amount += msg.value;                          //Increase the amount invested

            investorsList[msg.sender].when    = now;                                //Change the last time invested

        }

        

        uint tokensToSend = getTokensToSend(msg.value);                             //Calc the tokens to send depending on ethers received

        tokensSold += tokensToSend;             



        require(balances[owner] >= tokensToSend);

        _transfer(owner , msg.sender , tokensToSend);        

        ethersCollecteds   += msg.value;

        if(beneficiary == address(0)){

            beneficiary = owner;

        }

        beneficiary.transfer(msg.value);            

        emit FundTransfer(owner , msg.value , msg.sender);                          //Fire events for clients

    }





    /**

     * Start the TGE manually

     *     

     */

    function startTge() public onlyOwner{

        tgeStarted = true;                                                         //Set the TGE started

    }



    /**

     * Stop the TGE manually

     *

     */

    function stopTge() public onlyOwner{

        tgeStarted = false;                                                        //Set the TGE stopped

    }





    function setBeneficiary(address _beneficiary) public onlyOwner{

        beneficiary = _beneficiary;

    }

    

    function destroyContract()external onlyOwner{

        selfdestruct(owner);

    }

    

}