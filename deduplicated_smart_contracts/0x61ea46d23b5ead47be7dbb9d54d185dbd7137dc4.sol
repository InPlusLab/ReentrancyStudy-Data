/*
file:   1mdb.sol
ver:    0.1.3
author: Chris Kwan
date:   21-April-2018
email:  ecorpnu AT gmail.com

A collated contract set for a token sale specific to the requirments of
1mdb (1mdb) token product.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

*/


pragma solidity ^0.4.18;

/*-----------------------------------------------------------------------------\

 1mdb token sale configuration

\*----------------------------------------------------------------------------*/

// Contains token sale parameters
contract mdbTokenConfig
{
    // ERC20 trade name and symbol
    string public           name            = "USPAT7493279 loansyndicate";
    string public           symbol          = "1mdb";

    // Owner has power to abort, discount addresses, sweep successful funds,
    // change owner, sweep alien tokens.
    address public          owner           = 0xB353cF41A0CAa38D6597A7a1337debf0b09dd8ae; // Primary address checksummed
    
    // Fund wallet should also be audited prior to deployment
    // NOTE: Must be checksummed address!
    //address public          fundWallet      = 0xE4Be3157DBD71Acd7Ad5667db00AA111C0088195; // multiSig address checksummed
     address public           fundWallet      = 0xb6cEC5dd8c3A7E1892752a5724496c22ef6d0A37; //multiSig address main
    //address public          fundWallet = 0x29c92dbf73a6cb9d7e87b2ac9099765da9a2e7d3; //ropster test
    
    //you cannot use regular address, you need to create a contract wallet and need to make it checkedsummed search net  
    
    // Tokens awarded per USD contributed
    uint public constant    TOKENS_PER_USD  = 2;

    // Ether market price in USD
    uint public constant    USD_PER_ETH     = 500; // approx 7 day average High Low as at 21th APRIL 2018
    
    // Minimum and maximum target in USD
    uint public constant    MIN_USD_FUND    = 100000;  // $100K
    uint public constant    MAX_USD_FUND    = 5000000; // $5 mio
    
    // Non-KYC contribution limit in USD
    uint public constant    KYC_USD_LMT     = 15000;
    
    // There will be exactly 4000000 tokens regardless of number sold
    // Unsold tokens are put given to the Founder on Trust to fund operations of the Project
    uint public constant    MAX_TOKENS      = 10000000; // 10 mio
    
    // Funding begins on 30th OCT 2017
    
    //uint public constant    START_DATE      = 1509318001; // 30.10.2017 10 AM and 1 Sec Sydney Time
      uint public constant    START_DATE      = 1523465678; // April 11, 2018 16.54 GMT 
      
    // Period for fundraising
    uint public constant    FUNDING_PERIOD  = 180 days;
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract ReentryProtected
{
    // The reentry protection state mutex.
    bool __reMutex;

    // Sets and resets mutex in order to block functin reentry
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
    }

    // Blocks function entry if mutex is set
    modifier noReentry() {
        require(!__reMutex);
        _;
    }
}

contract ERC20Token
{
    using SafeMath for uint;

/* Constants */

    // none
    
/* State variable */

    /// @return The Total supply of tokens
    uint public totalSupply;
    
    /// @return Token symbol
    string public symbol;
    
    // Token ownership mapping
    mapping (address => uint) balances;
    
    // Allowances mapping
    mapping (address => mapping (address => uint)) allowed;

/* Events */

    // Triggered when tokens are transferred.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount);

    // Triggered whenever approve(address _spender, uint256 _amount) is called.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount);

/* Modifiers */

    // none
    
/* Functions */

    // Using an explicit getter allows for function overloading    
    function balanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        return balances[_addr];
    }
    
    // Using an explicit getter allows for function overloading    
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint)
    {
        return allowed[_owner][_spender];
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _amount)
        public
        returns (bool)
    {
        return xfer(msg.sender, _to, _amount);
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        returns (bool)
    {
        require(_amount <= allowed[_from][msg.sender]);
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        return xfer(_from, _to, _amount);
    }

    // Process a transfer internally.
    function xfer(address _from, address _to, uint _amount)
        internal
        returns (bool)
    {
        require(_amount <= balances[_from]);

        Transfer(_from, _to, _amount);
        
        // avoid wasting gas on 0 token transfers
        if(_amount == 0) return true;
        
        balances[_from] = balances[_from].sub(_amount);
        balances[_to]   = balances[_to].add(_amount);
        
        return true;
    }

    // Approves a third-party spender
    function approve(address _spender, uint256 _amount)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
}



/*-----------------------------------------------------------------------------\

## Conditional Entry Table

Functions must throw on F conditions

Conditional Entry Table (functions must throw on F conditions)

renetry prevention on all public mutating functions
Reentry mutex set in moveFundsToWallet(), refund()

|function                |<START_DATE|<END_DATE |fundFailed  |fundSucceeded|icoSucceeded
|------------------------|:---------:|:--------:|:----------:|:-----------:|:---------:|
|()                      |KYC        |T         |F           |T            |F          |
|abort()                 |T          |T         |T           |T            |F          |
|proxyPurchase()         |KYC        |T         |F           |T            |F          |
|addKycAddress()         |T          |T         |F           |T            |T          |
|finaliseICO()           |F          |F         |F           |T            |T          |
|refund()                |F          |F         |T           |F            |F          |
|transfer()              |F          |F         |F           |F            |T          |
|transferFrom()          |F          |F         |F           |F            |T          |
|approve()               |F          |F         |F           |F            |T          |
|changeOwner()           |T          |T         |T           |T            |T          |
|acceptOwnership()       |T          |T         |T           |T            |T          |
|changedeposito()          |T          |T         |T           |T            |T          |
|destroy()               |F          |F         |!__abortFuse|F            |F          |
|transferAnyERC20Tokens()|T          |T         |T           |T            |T          |

\*----------------------------------------------------------------------------*/

contract mdbTokenAbstract
{
// TODO comment events

// Logged when funder exceeds the KYC limit
    event KYCAddress(address indexed _addr, bool indexed _kyc);

// Logged upon refund
    event Refunded(address indexed _addr, uint indexed _value);

// Logged when new owner accepts ownership
    event ChangedOwner(address indexed _from, address indexed _to);
    
// Logged when owner initiates a change of ownership
    event ChangeOwnerTo(address indexed _to);

// Logged when ICO ether funds are transferred to an address
    event FundsTransferred(address indexed _wallet, uint indexed _value);


    // This fuse blows upon calling abort() which forces a fail state
    bool public __abortFuse = true;
    
    // Set to true after the fund is swept to the fund wallet, allows token
    // transfers and prevents abort()
    bool public icoSuccessful;

    // Token conversion factors are calculated with decimal places at parity with ether
    uint8 public constant decimals = 18;

    // An address authorised to take ownership
    address public newOwner;
    
    // The deposito smart contract address
    address public deposito;
    
    // Total ether raised during funding
    uint public etherRaised;
    
    // Preauthorized tranch discount addresses
    // holder => discount
    mapping (address => bool) public kycAddresses;
    
    // Record of ether paid per address
    mapping (address => uint) public etherContributed;

    // Return `true` if MIN_FUNDS were raised
    function fundSucceeded() public constant returns (bool);
    
    // Return `true` if MIN_FUNDS were not raised before END_DATE
    function fundFailed() public constant returns (bool);

    // Returns USD raised for set ETH/USD rate
    function usdRaised() public constant returns (uint);

    // Returns an amount in eth equivilent to USD at the set rate
    function usdToEth(uint) public constant returns(uint);
    
    // Returns the USD value of ether at the set USD/ETH rate
    function ethToUsd(uint _wei) public constant returns (uint);

    // Returns token/ether conversion given ether value and address. 
    function ethToTokens(uint _eth)
        public constant returns (uint);

    // Processes a token purchase for a given address
    function proxyPurchase(address _addr) payable returns (bool);

    // Owner can move funds of successful fund to fundWallet 
    function finaliseICO() public returns (bool);
    
    // Registers a discounted address
    function addKycAddress(address _addr, bool _kyc)
        public returns (bool);

    // Refund on failed or aborted sale 
    function refund(address _addr) public returns (bool);

    // To cancel token sale prior to START_DATE
    function abort() public returns (bool);
    
    // Change the deposito backend contract address
    function changedeposito(address _addr) public returns (bool);
    
    // For owner to salvage tokens sent to contract
    function transferAnyERC20Token(address tokenAddress, uint amount)
        returns (bool);
}


/*-----------------------------------------------------------------------------\

 1mdb token implimentation

\*----------------------------------------------------------------------------*/

contract mdbToken is 
    ReentryProtected,
    ERC20Token,
    mdbTokenAbstract,
    mdbTokenConfig
{
    using SafeMath for uint;

//
// Constants
//

    // USD to ether conversion factors calculated from `depositofferTokenConfig` constants 
    uint public constant TOKENS_PER_ETH = TOKENS_PER_USD * USD_PER_ETH;
    uint public constant MIN_ETH_FUND   = 1 ether * MIN_USD_FUND / USD_PER_ETH;
    uint public constant MAX_ETH_FUND   = 1 ether * MAX_USD_FUND / USD_PER_ETH;
    uint public constant KYC_ETH_LMT    = 1 ether * KYC_USD_LMT  / USD_PER_ETH;

    // General funding opens LEAD_IN_PERIOD after deployment (timestamps can't be constant)
    uint public END_DATE  = START_DATE + FUNDING_PERIOD;

//
// Modifiers
//

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

//
// Functions
//

    // Constructor
    function mdbToken()
    {
        // ICO parameters are set in 1mdbTSConfig
        // Invalid configuration catching here
        require(bytes(symbol).length > 0);
        require(bytes(name).length > 0);
        require(owner != 0x0);
        require(fundWallet != 0x0);
        require(TOKENS_PER_USD > 0);
        require(USD_PER_ETH > 0);
        require(MIN_USD_FUND > 0);
        require(MAX_USD_FUND > MIN_USD_FUND);
        require(START_DATE > 0);
        require(FUNDING_PERIOD > 0);
        
        // Setup and allocate token supply to 18 decimal places
        totalSupply = MAX_TOKENS * 1e18;
        balances[fundWallet] = totalSupply;
        Transfer(0x0, fundWallet, totalSupply);
    }
    
    // Default function
    function ()
        payable
    {
        // Pass through to purchasing function. Will throw on failed or
        // successful ICO
        proxyPurchase(msg.sender);
    }

//
// Getters
//

    // ICO fails if aborted or minimum funds are not raised by the end date
    function fundFailed() public constant returns (bool)
    {
        return !__abortFuse
            || (now > END_DATE && etherRaised < MIN_ETH_FUND);
    }
    
    // Funding succeeds if not aborted, minimum funds are raised before end date
    function fundSucceeded() public constant returns (bool)
    {
        return !fundFailed()
            && etherRaised >= MIN_ETH_FUND;
    }

    // Returns the USD value of ether at the set USD/ETH rate
    function ethToUsd(uint _wei) public constant returns (uint)
    {
        return USD_PER_ETH.mul(_wei).div(1 ether);
    }
    
    // Returns the ether value of USD at the set USD/ETH rate
    function usdToEth(uint _usd) public constant returns (uint)
    {
        return _usd.mul(1 ether).div(USD_PER_ETH);
    }
    
    // Returns the USD value of ether raised at the set USD/ETH rate
    function usdRaised() public constant returns (uint)
    {
        return ethToUsd(etherRaised);
    }
    
    // Returns the number of tokens for given amount of ether for an address 
    function ethToTokens(uint _wei) public constant returns (uint)
    {
        uint usd = ethToUsd(_wei);
        
        // Percent bonus funding tiers for USD funding
                 uint bonus = 
             usd >= 2000000 ? 35 :
             usd >= 500000  ? 30 :
             usd >= 100000  ? 20 :
             usd >= 25000   ? 15 :
             usd >= 10000   ? 10 :
             usd >= 5000    ? 5  :
             usd >= 1000    ? 1  :                    
                                0;
        // using n.2 fixed point decimal for whole number percentage.
        return _wei.mul(TOKENS_PER_ETH).mul(bonus + 100).div(100);
    }

//
// ICO functions
//

    // The fundraising can be aborted any time before funds are swept to the
    // fundWallet.
    // This will force a fail state and allow refunds to be collected.
    function abort()
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        require(!icoSuccessful);
        delete __abortFuse;
        return true;
    }
    
    // General addresses can purchase tokens during funding
    function proxyPurchase(address _addr)
        payable
        noReentry
        returns (bool)
    {
        require(!fundFailed());
        require(!icoSuccessful);
        require(now <= END_DATE);
        require(msg.value > 0);
        
        // Non-KYC'ed funders can only contribute up to $10000 after prefund period
        if(!kycAddresses[_addr])
        {
            require(now >= START_DATE);
            require((etherContributed[_addr].add(msg.value)) <= KYC_ETH_LMT);
        }

        // Get ether to token conversion
        uint tokens = ethToTokens(msg.value);
        
        // transfer tokens from fund wallet
        
        xfer(fundWallet, _addr, tokens);
        
        // Update holder payments
        etherContributed[_addr] = etherContributed[_addr].add(msg.value);
        
        // Update funds raised
        etherRaised = etherRaised.add(msg.value);
        
        // Bail if this pushes the fund over the USD cap or Token cap
        require(etherRaised <= MAX_ETH_FUND);

        return true;
    }
    
    // Owner can KYC (or revoke) addresses until close of funding
    function addKycAddress(address _addr, bool _kyc)
    public
        noReentry
        onlyOwner
        returns (bool)
    {
       require(!fundFailed());

        kycAddresses[_addr] = _kyc;
        KYCAddress(_addr, _kyc);
      return true;
    }
    
    // Owner can sweep a successful funding to the fundWallet
    // Contract can be aborted up until this action.
    // Effective once but can be called multiple time to withdraw edge case
    // funds recieved by contract which can selfdestruct to this address
 
    
    function finaliseICO()
        public
        onlyOwner
        preventReentry()
        returns (bool)
    {
        require(fundSucceeded());

        icoSuccessful = true;

        FundsTransferred(fundWallet, this.balance);
        fundWallet.transfer(this.balance);
        return true;
    }
    
    // Refunds can be claimed from a failed ICO
    function refund(address _addr)
        public
        preventReentry()
        returns (bool)
    {
        require(fundFailed());
        
        uint value = etherContributed[_addr];

        // Transfer tokens back to origin
        // (Not really necessary but looking for graceful exit)
        xfer(_addr, fundWallet, balances[_addr]);

        // garbage collect
        delete etherContributed[_addr];
        delete kycAddresses[_addr];
        
        Refunded(_addr, value);
        if (value > 0) {
            _addr.transfer(value);
        }
        return true;
    }

//
// ERC20 overloaded functions
//

    function transfer(address _to, uint _amount)
        public
        preventReentry
        returns (bool)
    {
        // ICO must be successful
        require(icoSuccessful);
        super.transfer(_to, _amount);

        if (_to == deposito)
            // Notify the deposito contract it has been sent tokens
            require(Notify(deposito).notify(msg.sender, _amount));
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount)
        public
        preventReentry
        returns (bool)
    {
        // ICO must be successful
        require(icoSuccessful);
        super.transferFrom(_from, _to, _amount);

        if (_to == deposito)
            // Notify the deposito contract it has been sent tokens
            require(Notify(deposito).notify(msg.sender, _amount));
        return true;
    }
    
    function approve(address _spender, uint _amount)
        public
        noReentry
        returns (bool)
    {
        // ICO must be successful
        require(icoSuccessful);
        super.approve(_spender, _amount);
        return true;
    }

//
// Contract managment functions
//

    // To initiate an ownership change
    function changeOwner(address _newOwner)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        ChangeOwnerTo(_newOwner);
        newOwner = _newOwner;
        return true;
    }

    // To accept ownership. Required to prove new address can call the contract.
    function acceptOwnership()
        public
        noReentry
        returns (bool)
    {
        require(msg.sender == newOwner);
        ChangedOwner(owner, newOwner);
        owner = newOwner;
        return true;
    }

    // Change the address of the deposito contract address. The contract
    // must impliment the `Notify` interface.
    function changedeposito(address _addr)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        deposito = _addr;
        return true;
    }
    
    // The contract can be selfdestructed after abort and ether balance is 0.
    function destroy()
        public
        noReentry
        onlyOwner
    {
        require(!__abortFuse);
        require(this.balance == 0);
        selfdestruct(owner);
    }
    
    // Owner can salvage ANYTYPE ERC20 tokens that may have been sent to the account by accident 
    function transferAnyERC20Token(address tokenAddress, uint amount)
        public
        onlyOwner
        preventReentry
        returns (bool) 
    {
        require(ERC20Token(tokenAddress).transfer(owner, amount));
        return true;
    }
}


interface Notify
{
    event Notified(address indexed _from, uint indexed _amount);
    
    function notify(address _from, uint _amount) public returns (bool);
}


contract depositoTest is Notify
{
    address public dot;
    
    function setdot(address _addr) { dot = _addr; }
    
    function notify(address _from, uint _amount) public returns (bool)
    {
        require(msg.sender == dot);
        Notified(_from, _amount);
        return true;
    }
}