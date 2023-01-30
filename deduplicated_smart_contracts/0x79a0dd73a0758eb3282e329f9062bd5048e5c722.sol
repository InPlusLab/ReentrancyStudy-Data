/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.15;

/*

    Utilities & Common Modifiers

*/

contract Utils {

    /**

        constructor

    */

    function Utils() {

    }



    // validates an address - currently only checks that it isn't null

    modifier validAddress(address _address) {

        require(_address != 0x0);

        _;

    }



    // verifies that the address is different than this contract address

    modifier notThis(address _address) {

        require(_address != address(this));

        _;

    }



    // Overflow protected math functions



    /**

        @dev returns the sum of _x and _y, asserts if the calculation overflows



        @param _x   value 1

        @param _y   value 2



        @return sum

    */

    function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {

        uint256 z = _x + _y;

        assert(z >= _x);

        return z;

    }



    /**

        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number



        @param _x   minuend

        @param _y   subtrahend



        @return difference

    */

    function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {

        assert(_x >= _y);

        return _x - _y;

    }



    /**

        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows



        @param _x   factor 1

        @param _y   factor 2



        @return product

    */

    function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {

        uint256 z = _x * _y;

        assert(_x == 0 || z / _x == _y);

        return z;

    }

}



/*

    ERC20 Standard Token interface

*/

contract IERC20Token {

    // these functions aren't abstract since the compiler emits automatically generated getter functions as external

    function name() public constant returns (string) { name; }

    function symbol() public constant returns (string) { symbol; }

    function decimals() public constant returns (uint8) { decimals; }

    function totalSupply() public constant returns (uint256) { totalSupply; }

    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }



    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}





/**

    ERC20 Standard Token implementation

*/

contract ERC20Token is IERC20Token, Utils {

    string public standard = "Token 0.1";

    string public name = "";

    string public symbol = "";

    uint8 public decimals = 0;

    uint256 public totalSupply = 0;

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    /**

        @dev constructor



        @param _name        token name

        @param _symbol      token symbol

        @param _decimals    decimal points, for display purposes

    */

    function ERC20Token(string _name, string _symbol, uint8 _decimals) {

        require(bytes(_name).length > 0 && bytes(_symbol).length > 0); // validate input



        name = _name;

        symbol = _symbol;

        decimals = _decimals;

    }



    /**

        @dev send coins

        throws on any error rather then return a false flag to minimize user errors



        @param _to      target address

        @param _value   transfer amount



        @return true if the transfer was successful, false if it wasn't

    */

    function transfer(address _to, uint256 _value)

        public

        validAddress(_to)

        returns (bool success)

    {

        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);

        balanceOf[_to] = safeAdd(balanceOf[_to], _value);

        Transfer(msg.sender, _to, _value);

        return true;

    }



    /**

        @dev an account/contract attempts to get the coins

        throws on any error rather then return a false flag to minimize user errors



        @param _from    source address

        @param _to      target address

        @param _value   transfer amount



        @return true if the transfer was successful, false if it wasn't

    */

    function transferFrom(address _from, address _to, uint256 _value)

        public

        validAddress(_from)

        validAddress(_to)

        returns (bool success)

    {

        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);

        balanceOf[_from] = safeSub(balanceOf[_from], _value);

        balanceOf[_to] = safeAdd(balanceOf[_to], _value);

        Transfer(_from, _to, _value);

        return true;

    }









    /**

        @dev allow another account/contract to spend some tokens on your behalf

        throws on any error rather then return a false flag to minimize user errors



        also, to minimize the risk of the approve/transferFrom attack vector

        (see https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/), approve has to be called twice

        in 2 separate transactions - once to change the allowance to 0 and secondly to change it to the new allowance value



        @param _spender approved address

        @param _value   allowance amount



        @return true if the approval was successful, false if it wasn't

    */

    function approve(address _spender, uint256 _value)

        public

        validAddress(_spender)

        returns (bool success)

    {

        // if the allowance isn't 0, it can only be updated to 0 to prevent an allowance change immediately after withdrawal

        require(_value == 0 || allowance[msg.sender][_spender] == 0);



        allowance[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

}



/*

    Owned contract interface

*/

contract IOwned {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function owner() public constant returns (address) { owner; }



    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}



/*

    Provides support and utilities for contract ownership

*/

contract Owned is IOwned {

    address public owner;

    address public newOwner;



    event OwnerUpdate(address _prevOwner, address _newOwner);



    /**

        @dev constructor

    */

    function Owned() {

        owner = msg.sender;

    }



    // allows execution by the owner only

    modifier ownerOnly {

        assert(msg.sender == owner);

        _;

    }



    /**

        @dev allows transferring the contract ownership

        the new owner still needs to accept the transfer

        can only be called by the contract owner



        @param _newOwner    new contract owner

    */

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);

        newOwner = _newOwner;

    }



    /**

        @dev used by a new owner to accept an ownership transfer

    */

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        OwnerUpdate(owner, newOwner);

        owner = newOwner;

        newOwner = 0x0;

    }

}



/*

    Token Holder interface

*/

contract ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

}





contract TokenHolder is ITokenHolder, Owned, Utils {

    /**

        @dev constructor

    */

    function TokenHolder() {

    }



    /**

        @dev withdraws tokens held by the contract and sends them to an account

        can only be called by the owner



        @param _token   ERC20 token contract address

        @param _to      account to receive the new amount

        @param _amount  amount to withdraw

    */

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)

        public

        ownerOnly

        validAddress(_token)

        validAddress(_to)

        notThis(_to)

    {

        assert(_token.transfer(_to, _amount));

    }

}





contract CLRSToken is ERC20Token, TokenHolder {



///////////////////////////////////////// VARIABLE INITIALIZATION /////////////////////////////////////////



    uint256 constant public CLRS_UNIT = 10 ** 18;

    uint256 public totalSupply = 86374977 * CLRS_UNIT;



    //  Constants

    uint256 constant public maxIcoSupply = 48369987 * CLRS_UNIT;           // ICO pool allocation

    uint256 constant public Company = 7773748 * CLRS_UNIT;     //  Company pool allocation

    uint256 constant public Bonus = 16411245 * CLRS_UNIT;  // Bonus Allocation

    uint256 constant public Bounty = 1727500 * CLRS_UNIT;  // Bounty Allocation

    uint256 constant public advisorsAllocation = 4318748 * CLRS_UNIT;          // Advisors Allocation

    uint256 constant public CLRSinTeamAllocation = 7773748 * CLRS_UNIT;    // CLRSin Team allocation



   // Addresses of Patrons

   address public constant ICOSTAKE = 0xd82896Ea0B5848dc3b75bbECc747947F64077b7c;

   address public constant COMPANY_STAKE_1 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant COMPANY_STAKE_2 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

     address public constant COMPANY_STAKE_3 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

      address public constant COMPANY_STAKE_4 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

       address public constant COMPANY_STAKE_5 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant ADVISOR_1 = 0xf0eB71d3b31fEe5D15220A2ac418A784c962Eb53;

    address public constant ADVISOR_2 = 0xFd6b0691Cd486B4124fFD9FBe9e013463868E2B4;

    address public constant ADVISOR_3 = 0xCFb32aFA7752170043aaC32794397C8673778765;

    address public constant ADVISOR_4 = 0x08441513c0Fc653a739F34A97eF6B2B05609a4E4;

    address public constant ADVISOR_5 = 0xFd6b0691Cd486B4124fFD9FBe9e013463868E2B4;

    address public constant TEAM_1 = 0xc4896CB7486ed8821B525D858c85D4321e8e5685;

    address public constant TEAM_2 = 0x304765b9c3072E54b7397E2F55D1463BD62802C3;

    address public constant TEAM_3 = 0x46abC1d38573E8726c6C0568CC01f35fE5FF4765;

    address public constant TEAM_4 = 0x36Bf4b1DDd796eaf1f962cB0E0327C15096fae41;

    address public constant TEAM_5 = 0xc4896CB7486ed8821B525D858c85D4321e8e5685;

    address public constant BONUS_1 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BONUS_2 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BONUS_3 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BONUS_4 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BONUS_5 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BOUNTY_1 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BOUNTY_2 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BOUNTY_3 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BOUNTY_4 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;

    address public constant BOUNTY_5 = 0x19333A742dcd220683C2231c0FAaCcb9c810C0B5;













    // Stakes of COMPANY

uint256 constant public COMPANY_1 = 7773744 * CLRS_UNIT; //token allocated to  company1

uint256 constant public COMPANY_2 = 1 * CLRS_UNIT; //token allocated to  company1

uint256 constant public COMPANY_3 = 1 * CLRS_UNIT; //token allocated to  company1

uint256 constant public COMPANY_4 = 1 * CLRS_UNIT; //token allocated to  company1

uint256 constant public COMPANY_5 = 1 * CLRS_UNIT; //token allocated to  company1



// Stakes of ADVISORS

uint256 constant public ADVISOR1 = 863750 * CLRS_UNIT; //token allocated to adv1

uint256 constant public ADVISOR2 = 863750 * CLRS_UNIT; //token allocated to  adv2

uint256 constant public ADVISOR3 = 431875 * CLRS_UNIT; //token allocated to  adv3

uint256 constant public ADVISOR4 = 431875 * CLRS_UNIT; //token allocated to  adv4

uint256 constant public ADVISOR5 = 863750 * CLRS_UNIT; //token allocated to adv5





// Stakes of TEAM

uint256 constant public TEAM1 = 3876873 * CLRS_UNIT; //token allocated to  team1

uint256 constant public TEAM2 = 3876874 * CLRS_UNIT; //token allocated to  team2

uint256 constant public TEAM3 = 10000 * CLRS_UNIT; //token allocated to  team3

uint256 constant public TEAM4 = 10000 * CLRS_UNIT; //token allocated to  team4

uint256 constant public TEAM5 = 1 * CLRS_UNIT; //token allocated to  team5





// Stakes of BONUS

uint256 constant public BONUS1 = 16411241 * CLRS_UNIT; //token allocated to bonus1

uint256 constant public BONUS2 = 1 * CLRS_UNIT; //token allocated to bonus2

uint256 constant public BONUS3 = 1 * CLRS_UNIT; //token allocated to bonus3

uint256 constant public BONUS4 = 1 * CLRS_UNIT; //token allocated to bonus4

uint256 constant public BONUS5 = 1 * CLRS_UNIT; //token allocated to bonus5



// Stakes of BOUNTY

uint256 constant public BOUNTY1 = 1727400 * CLRS_UNIT; //token allocated to bounty1

uint256 constant public BOUNTY2 = 1 * CLRS_UNIT; //token allocated to bounty2

uint256 constant public BOUNTY3 = 1 * CLRS_UNIT; //token allocated bounty3

uint256 constant public BOUNTY4 = 1 * CLRS_UNIT; //token allocated bounty4

uint256 constant public BOUNTY5 = 1 * CLRS_UNIT; //token allocated bounty5





















    //  Variables



uint256 public totalAllocatedToCompany = 0;     // Counter to keep track of comapny token allocation

uint256 public totalAllocatedToAdvisor = 0;        // Counter to keep track of advisor token allocation

uint256 public totalAllocatedToTEAM = 0;     // Counter to keep track of team token allocation

uint256 public totalAllocatedToBONUS = 0;        // Counter to keep track of bonus token allocation

uint256 public totalAllocatedToBOUNTY = 0;      // Counter to keep track of bounty token allocation



uint256 public remaintokensteam=0;

uint256 public remaintokensadvisors=0;

uint256 public remaintokensbounty=0;

uint256 public remaintokensbonus=0;

uint256 public remaintokenscompany=0;

uint256 public totremains=0;





uint256 public totalAllocated = 0;             // Counter to keep track of overall token allocation

    uint256 public endTime;                                     // timestamp



    bool internal isReleasedToPublic = false; // Flag to allow transfer/transferFrom



    bool public isReleasedToadv = false;

    bool public isReleasedToteam = false;

///////////////////////////////////////// MODIFIERS /////////////////////////////////////////



    // CLRSin Team timelock

   /* modifier safeTimelock() {

        require(now >= endTime + 52 weeks);

        _;

    }



    // Advisor Team timelock

    modifier advisorTimelock() {

        require(now >= endTime + 26 weeks);

        _;

    }*/







    ///////////////////////////////////////// CONSTRUCTOR /////////////////////////////////////////





    function CLRSToken()

    ERC20Token("CLRS", "CLRS", 18)

     {





        balanceOf[ICOSTAKE] = maxIcoSupply; // ico CLRS tokens

        balanceOf[COMPANY_STAKE_1] = COMPANY_1; // Company1 CLRS tokens

         balanceOf[COMPANY_STAKE_2] = COMPANY_2; // Company2 CLRS tokens

          balanceOf[COMPANY_STAKE_3] = COMPANY_3; // Company3 CLRS tokens

           balanceOf[COMPANY_STAKE_4] = COMPANY_4; // Company4 CLRS tokens

            balanceOf[COMPANY_STAKE_5] = COMPANY_5; // Company5 CLRS tokens

            totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_1);

totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_2);

totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_3);

totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_4);

totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_5);



remaintokenscompany=safeSub(Company,totalAllocatedToCompany);



balanceOf[ICOSTAKE]=safeAdd(balanceOf[ICOSTAKE],remaintokenscompany);



        balanceOf[BONUS_1] = BONUS1;       // bonus1 CLRS tokens

        balanceOf[BONUS_2] = BONUS2;       // bonus2 CLRS tokens

        balanceOf[BONUS_3] = BONUS3;       // bonus3 CLRS tokens

        balanceOf[BONUS_4] = BONUS4;       // bonus4 CLRS tokens

        balanceOf[BONUS_5] = BONUS5;       // bonus5 CLRS tokens

        totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS1);

totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS2);

totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS3);

totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS4);

totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS5);



remaintokensbonus=safeSub(Bonus,totalAllocatedToBONUS);



balanceOf[ICOSTAKE]=safeAdd(balanceOf[ICOSTAKE],remaintokensbonus);



        balanceOf[BOUNTY_1] = BOUNTY1;       // BOUNTY1 CLRS tokens

        balanceOf[BOUNTY_2] = BOUNTY2;       // BOUNTY2 CLRS tokens

        balanceOf[BOUNTY_3] = BOUNTY3;       // BOUNTY3 CLRS tokens

        balanceOf[BOUNTY_4] = BOUNTY4;       // BOUNTY4 CLRS tokens

        balanceOf[BOUNTY_5] = BOUNTY5;       // BOUNTY5 CLRS tokens



totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY1);

totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY2);

totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY3);

totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY4);

totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY5);



remaintokensbounty=safeSub(Bounty,totalAllocatedToBOUNTY);

balanceOf[ICOSTAKE]=safeAdd(balanceOf[ICOSTAKE],remaintokensbounty);





        allocateAdvisorTokens() ;

        allocateCLRSinTeamTokens();





        totremains=safeAdd(totremains,remaintokenscompany);

        totremains=safeAdd(totremains,remaintokensbounty);

        totremains=safeAdd(totremains,remaintokensbonus);

        totremains=safeAdd(totremains,remaintokensteam);

        totremains=safeAdd(totremains,remaintokensadvisors);







  burnTokens(totremains);



totalAllocated += maxIcoSupply+ totalAllocatedToCompany+ totalAllocatedToBONUS + totalAllocatedToBOUNTY;  // Add to total Allocated funds

    }



///////////////////////////////////////// ERC20 OVERRIDE /////////////////////////////////////////



    /**

        @dev send coins

        throws on any error rather then return a false flag to minimize user errors

        in addition to the standard checks, the function throws if transfers are disabled



        @param _to      target address

        @param _value   transfer amount



        @return true if the transfer was successful, throws if it wasn't

    */

    /*function transfer(address _to, uint256 _value) public returns (bool success) {

        if (isTransferAllowed() == true) {

            assert(super.transfer(_to, _value));

            return true;

        }

        revert();

    }



    /**

        @dev an account/contract attempts to get the coins

        throws on any error rather then return a false flag to minimize user errors

        in addition to the standard checks, the function throws if transfers are disabled



        @param _from    source address

        @param _to      target address

        @param _value   transfer amount



        @return true if the transfer was successful, throws if it wasn't

    */

   /* function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (isTransferAllowed() == true ) {

            assert(super.transferFrom(_from, _to, _value));

            return true;

        }



        revert();

    }*/





     /**

     * Allow transfer only after finished

     */

        //allows to dissable transfers while minting and in case of emergency







    modifier canTransfer() {

        require( isTransferAllowedteam()==true );

        _;

    }



   modifier canTransferadv() {

        require( isTransferAllowedadv()==true );

        _;

    }





    function transfer(address _to, uint256 _value) canTransfer canTransferadv public returns (bool) {

        return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) canTransfer canTransferadv public returns (bool) {

        return super.transferFrom(_from, _to, _value);

    }











///////////////////////////////////////// ALLOCATION FUNCTIONS /////////////////////////////////////////





    function allocateCLRSinTeamTokens() public returns(bool success) {

        require(totalAllocatedToTEAM < CLRSinTeamAllocation);



        balanceOf[TEAM_1] = safeAdd(balanceOf[TEAM_1], TEAM1);       // TEAM1 CLRS tokens

        balanceOf[TEAM_2] = safeAdd(balanceOf[TEAM_2], TEAM2);       // TEAM2 CLRS tokens

        balanceOf[TEAM_3] = safeAdd(balanceOf[TEAM_3], TEAM3);        // TEAM3 CLRS tokens

        balanceOf[TEAM_4] = safeAdd(balanceOf[TEAM_4], TEAM4);        // TEAM4 CLRS tokens

        balanceOf[TEAM_5] = safeAdd(balanceOf[TEAM_5], TEAM5);       // TEAM5 CLRS tokens

       /*Transfer(0x0, TEAM_1, TEAM1);

       Transfer(0x0, TEAM_2, TEAM2);

       Transfer(0x0, TEAM_3, TEAM3);

       Transfer(0x0, TEAM_4, TEAM4);

       Transfer(0x0, TEAM_5, TEAM5);*/



       totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM1);

totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM2);

totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM3);

totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM4);

totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM5);



totalAllocated +=  totalAllocatedToTEAM;





 remaintokensteam=safeSub(CLRSinTeamAllocation,totalAllocatedToTEAM);



balanceOf[ICOSTAKE]=safeAdd(balanceOf[ICOSTAKE],remaintokensteam);



            return true;





    }





    function allocateAdvisorTokens() public returns(bool success) {

        require(totalAllocatedToAdvisor < advisorsAllocation);



        balanceOf[ADVISOR_1] = safeAdd(balanceOf[ADVISOR_1], ADVISOR1);

        balanceOf[ADVISOR_2] = safeAdd(balanceOf[ADVISOR_2], ADVISOR2);

        balanceOf[ADVISOR_3] = safeAdd(balanceOf[ADVISOR_3], ADVISOR3);

        balanceOf[ADVISOR_4] = safeAdd(balanceOf[ADVISOR_4], ADVISOR4);

        balanceOf[ADVISOR_5] = safeAdd(balanceOf[ADVISOR_5], ADVISOR5);

       /*Transfer(0x0, ADVISOR_1, ADVISOR1);

       Transfer(0x0, ADVISOR_2, ADVISOR2);

       Transfer(0x0, ADVISOR_3, ADVISOR3);

       Transfer(0x0, ADVISOR_4, ADVISOR4);

       Transfer(0x0, ADVISOR_5, ADVISOR5);*/



       totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR1);

totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR2);

totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR3);

totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR4);

totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR5);



totalAllocated +=  totalAllocatedToAdvisor;





remaintokensadvisors=safeSub(advisorsAllocation,totalAllocatedToAdvisor);



balanceOf[ICOSTAKE]=safeAdd(balanceOf[ICOSTAKE],remaintokensadvisors);



        return true;

    }







    function releaseAdvisorTokens() ownerOnly {



         isReleasedToadv = true;





    }



     function releaseCLRSinTeamTokens() ownerOnly  {



         isReleasedToteam = true;











    }







    function burnTokens(uint256 _value) ownerOnly returns(bool success) {

        uint256 amountOfTokens = _value;



        balanceOf[msg.sender]=safeSub(balanceOf[msg.sender], amountOfTokens);

        totalSupply=safeSub(totalSupply, amountOfTokens);

        Transfer(msg.sender, 0x0, amountOfTokens);

        return true;

    }







    /**

        @dev Function to allow transfers

        can only be called by the owner of the contract

        Transfers will be allowed regardless after the crowdfund end time.

    */

    function allowTransfers() ownerOnly {

        isReleasedToPublic = true;



    }



    function starttime() ownerOnly {

endTime =  now;

	}





    /**

        @dev User transfers are allowed/rejected

        Transfers are forbidden before the end of the crowdfund

    */

    function isTransferAllowedteam() public returns(bool)

    {



        if (isReleasedToteam==true)

        return true;



        if(now < endTime + 52 weeks)



{

if(msg.sender==TEAM_1 || msg.sender==TEAM_2 || msg.sender==TEAM_3 || msg.sender==TEAM_4 || msg.sender==TEAM_5)



return false;





}





return true;

    }





 function isTransferAllowedadv() public returns(bool)

    {

        if (isReleasedToadv==true)

        return true;









        if(now < endTime + 26 weeks)



{

if(msg.sender==ADVISOR_1 || msg.sender==ADVISOR_2 || msg.sender==ADVISOR_3 || msg.sender==ADVISOR_4 || msg.sender==ADVISOR_5)



return false;





}



return true;

    }









}