/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.24;





contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);

    event LogSetOwner     (address indexed owner);

}



contract DSAuth is DSAuthEvents {

    mapping(address => bool)  public  authority;

    address      public  owner;



    constructor() public {

        owner = msg.sender;

        emit LogSetOwner(msg.sender);

    }



    function setOwner(address owner_)

        public

        auth

    {

        owner = owner_;

        emit LogSetOwner(owner);

    }



    function setAuthority(address authority_)

        public

        auth

    {

        authority[authority_] = true;

        emit LogSetAuthority(authority_);

    }



    modifier auth {

        require(isAuthorized(msg.sender));

        _;

    }



    function isAuthorized(address src) internal view returns (bool) {

        if (src == address(this)) {

            return true;

        } else if (src == owner) {

            return true;

        } else if (authority[src] == true) {

            return true;

        } else {

            return false;

        }

    }

}



contract KYCVerification is DSAuth{

    

    mapping(address => bool) public kycAddress;

    

    event LogKYCVerification(address _kycAddress,bool _status);

    

    function addVerified(address[] _kycAddress,bool _status) auth public

    {

        for(uint tmpIndex = 0; tmpIndex <= _kycAddress.length; tmpIndex++)

        {

            kycAddress[_kycAddress[tmpIndex]] = _status;

        }

    }

    

    function updateVerifcation(address _kycAddress,bool _status) auth public

    {

        kycAddress[_kycAddress] = _status;

        

        emit LogKYCVerification(_kycAddress,_status);

    }

    

    function isVerified(address _user) view public returns(bool)

    {

        return kycAddress[_user] == true; 

    }

}



contract DSNote {

    event LogNote(

        bytes4   indexed  sig,

        address  indexed  guy,

        bytes32  indexed  foo,

        bytes32  indexed  bar,

        uint              wad,

        bytes             fax

    ) anonymous;



    modifier note {

        bytes32 foo;

        bytes32 bar;



        assembly {

            foo := calldataload(4)

            bar := calldataload(36)

        }



        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);



        _;

    }

}



contract ERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf( address who ) public view returns (uint value);

    function allowance( address owner, address spender ) public view returns (uint _allowance);



    function transfer( address to, uint value) public returns (bool ok);

    function transferFrom( address from, address to, uint value) public returns (bool ok);

    function approve( address spender, uint value ) public returns (bool ok);



    event Transfer( address indexed from, address indexed to, uint value);

    event Approval( address indexed owner, address indexed spender, uint value);

}



contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);

    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);

    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);

    }



    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;

    }

    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;

    }

    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;

    }

    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;

    }



    uint constant WAD = 10 ** 18;

    uint constant RAY = 10 ** 27;



    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;

    }

    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;

    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;

    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;

    }



    // This famous algorithm is called "exponentiation by squaring"

    // and calculates x^n with x as fixed-point and n as regular unsigned.

    //

    // It's O(log n), instead of O(n) for naive repeated multiplication.

    //

    // These facts are why it works:

    //

    //  If n is even, then x^n = (x^2)^(n/2).

    //  If n is odd,  then x^n = x * x^(n-1),

    //   and applying the equation for even x gives

    //    x^n = x * (x^2)^((n-1) / 2).

    //

    //  Also, EVM division is flooring and

    //    floor[(n-1) / 2] = floor[n / 2].

    //

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;



        for (n /= 2; n != 0; n /= 2) {

            x = rmul(x, x);



            if (n % 2 != 0) {

                z = rmul(z, x);

            }

        }

    }

}



contract DSStop is DSNote, DSAuth {



    bool public stopped;



    modifier stoppable {

        require(!stopped);

        _;

    }

    function stop() public auth note {

        stopped = true;

    }

    function start() public auth note {

        stopped = false;

    }



}



contract DSTokenBase is ERC20, DSMath {

    uint256                                            _supply;

    mapping (address => uint256)                       _balances;

    mapping (address => mapping (address => uint256))  _approvals;



    constructor (uint supply) public {

        _balances[msg.sender] = supply;

        _supply = supply;

    }



    function totalSupply() public view returns (uint) {

        return _supply;

    }

    function balanceOf(address src) public view returns (uint) {

        return _balances[src];

    }

    function allowance(address src, address guy) public view returns (uint) {

        return _approvals[src][guy];

    }



    function transfer(address dst, uint wad) public returns (bool) {

        return transferFrom(msg.sender, dst, wad);

    }



    function transferFrom(address src, address dst, uint wad)

        public

        returns (bool)

    {

        if (src != msg.sender) {

            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);

        }



        _balances[src] = sub(_balances[src], wad);

        _balances[dst] = add(_balances[dst], wad);



        emit Transfer(src, dst, wad);



        return true;

    }



    function approve(address guy, uint wad) public returns (bool) {

        _approvals[msg.sender][guy] = wad;



        emit Approval(msg.sender, guy, wad);



        return true;

    }

}



contract DSToken is DSTokenBase(0), DSStop {



    mapping (address => mapping (address => bool)) _trusted;



    // Optional token name

    string  public  name = "";

    string  public  symbol;

    uint256  public  decimals = 18; // standard token precision. override to customize

    bool public kycEnabled = true;



    KYCVerification public kycVerification;

    

    constructor (string name_,string symbol_,KYCVerification _kycAddress) public {

        name = name_;

        symbol = symbol_;

        

        kycVerification = _kycAddress;

    }



    event Trust(address indexed src, address indexed guy, bool wat);

    event Burn(address indexed guy, uint wad);

    event KYCMandateUpdate(bool _kycEnabled);

    

    modifier kycVerified(address _guy) {



        if(kycEnabled == true)

        {

            if(kycVerification.isVerified(_guy) == false)

            {

                revert("KYC Not Verified");

            }

        }

        _;

    }

    

    function updateKycMandate(bool _kycEnabled) public auth

    {

        kycEnabled = _kycEnabled;

        emit KYCMandateUpdate(_kycEnabled);

    }



    function trusted(address src, address guy) public view returns (bool) {

        return _trusted[src][guy];

    }

    function trust(address guy, bool wat) public stoppable {

        _trusted[msg.sender][guy] = wat;

        emit Trust(msg.sender, guy, wat);

    }



    function approve(address guy, uint wad) public stoppable returns (bool) {

        return super.approve(guy, wad);

    }

    

    function transfer(address dst, uint wad) public stoppable kycVerified(msg.sender) returns (bool) {

        

        return super.transfer(dst,wad);

    }

    

    

    function transferFrom(address src, address dst, uint wad)

        public

        stoppable

        returns (bool)

    {

        if (src != msg.sender && !_trusted[src][msg.sender]) {

            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);

        }



        _balances[src] = sub(_balances[src], wad);

        _balances[dst] = add(_balances[dst], wad);



        emit Transfer(src, dst, wad);



        return true;

    }



    function mint(uint wad) public {

        mint(msg.sender, wad);

    }

    function burn(uint wad) public {

        burn(msg.sender, wad);

    }

    function mint(address guy, uint wad) public auth stoppable {

        _balances[guy] = add(_balances[guy], wad);

        _supply = add(_supply, wad);

        

        emit Transfer(address(0),address(this),wad);

        emit Transfer(address(this),guy,wad);

    }

    function burn(address guy, uint wad) public auth stoppable {

        if (guy != msg.sender && !_trusted[guy][msg.sender]) {

            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);

        }



        _balances[guy] = sub(_balances[guy], wad);

        _supply = sub(_supply, wad);

        emit Burn(guy, wad);

    }



    



    function setName(string name_) public auth {

        name = name_;

    }

}



contract ZeosXPrivatePreSale is DSAuth, DSMath {



    uint public MAX_FUNDING =  1000 ether;  // contribution hard-cap 1000 ether;

    uint public BONUS = 50;   /* Bonus in % */

    uint public MIN_CONTRIBUTION = 0.1 ether;

    

    DSToken public zeosXToken;         // zeosXToken token contract

    address public beneficiary;       // destination to collect eth deposits

    uint public startTime;           // start time of sale

    uint public endTime;             // end time of sale



    uint public totalEthDeposited;    // sums of ether raised

    uint public totalTokensBought;    // total tokens issued on sale

    uint public totalEthCollected;    // total eth collected from sale

    uint public totalEthRefunded;     // total eth refunded after a failed sale



    mapping (bytes32 => uint) public totalEthDepositsViaOtherCurrency; //Deposits via BTC, LTC etc

    

    mapping(address => bool) public whiteListedBuyers;

    // buyers ether deposits

    mapping (address => uint) public ethDeposits;

    mapping (address => uint) public ethDepositsViaOtherCurrency;



    // ether refunds after a failed sale

    mapping (address => uint) public ethRefunds;



    enum State {Pending,Running,Succeeded,Failed}

    State public state = State.Pending;



    uint public tokensPerEth ;

    



    /*******************************  Events *************************************/

    event LogBuy(address indexed buyer,uint ethDeposit,uint tokensBought,uint bonusToken);

    event LogBuyViaOtherCurrency(address indexed buyer,uint ethDeposit,bytes32 viaCurrency, bytes32 viaCurrencyAmt, bytes32 gatewayTxId, uint tokensBought,uint bonusToken);



    event LogRefund(address indexed buyer,uint ethRefund);

    event LogStartSale(uint startTime,uint endTime);

    event LogEndSale(bool success,uint totalEthDeposited,uint totalTokensBought);

    event LogExtendSale(uint endTime);

    event LogCollectEth(uint ethCollected,uint totalEthDeposited);

    event LogWhitelistAddresses(address[] buyer,bool status);

    event LogUpdateWhitelisting(address indexed buyer,bool status);

    event LogBonusUpdate(uint _percent);

    event LogHardcapUpdate(uint _MAX_FUNDING);

    event LogExchangeRateUpdate(uint _tokensPerEth);



    /*******************************  Modifiers ***********************************/



    // check given state of sale

    

    modifier saleIn(State state_) { require(state_ == state); _; }



    // check current block is inside closed interval [startBlock, endBlock]

    modifier inRunningBlock() {

        require(now >= startTime);

        require(now <= endTime);

        _;

    }



    // check sender has sent some ethers

    modifier ethSent() { require(msg.value > 0); _; }



    modifier isWhiteListedBuyer {

        require(whiteListedBuyers[msg.sender] == true);

        _;

    }



    /*******************************  Public Methods *********************************/



    constructor (DSToken zeosXToken_, address beneficiary_,uint _tokensPerEth) public

    {

        zeosXToken = zeosXToken_;

        beneficiary = beneficiary_;

        tokensPerEth = _tokensPerEth;

        

        /* Contract in State Pending */

        state = State.Pending;

    }



    function() public payable 

    {

        buyTokens();

    }



    function buyTokens() saleIn(State.Running) inRunningBlock ethSent isWhiteListedBuyer public payable 

    {

        require(msg.value >= MIN_CONTRIBUTION);

        uint tokensBought = calcTokensForPurchase(msg.value);

        

        /* Add Bonus */

        uint _bonusToken = wdiv(wmul(tokensBought, BONUS), 100);

        tokensBought += _bonusToken;

        

        

        ethDeposits[msg.sender] = add(msg.value, ethDeposits[msg.sender]);

        totalEthDeposited = add(msg.value, totalEthDeposited);

        totalTokensBought = add(tokensBought, totalTokensBought);



        require(totalEthDeposited <= MAX_FUNDING);



        zeosXToken.mint(msg.sender, tokensBought);



        emit LogBuy(msg.sender, msg.value, tokensBought,_bonusToken);

    }





  

    /********************** Authentication required ******************************/



    function buyTokensWithOtherCurrency(address reciever, uint ethInWei, bytes32 viaCurrency,bytes32 viaCurrencyAmt,bytes32 gatewayTxId) 

            saleIn(State.Running) inRunningBlock auth public

    {

        require(ethInWei >= MIN_CONTRIBUTION);

        uint tokensBought = calcTokensForPurchase(ethInWei);



        /* Add Bonus */

        uint _bonusToken = wdiv(wmul(tokensBought, BONUS), 100);

        tokensBought += _bonusToken;



        /*  Log User Deposits  */

        ethDepositsViaOtherCurrency[reciever] = add(ethInWei, ethDepositsViaOtherCurrency[reciever]);

        

        /*  Log in Other Deposits */

        totalEthDepositsViaOtherCurrency[viaCurrency] = add(ethInWei, totalEthDepositsViaOtherCurrency[viaCurrency]);



        /*  Log Tokens Bought  */

        totalTokensBought = add(tokensBought, totalTokensBought);



        require(totalEthDeposited <= MAX_FUNDING);



        /*  Mint Tokens  */

        zeosXToken.mint(reciever, tokensBought);



        emit LogBuy(reciever, ethInWei, tokensBought,_bonusToken);

        emit LogBuyViaOtherCurrency(reciever, ethInWei, viaCurrency, viaCurrencyAmt, gatewayTxId, tokensBought,_bonusToken);

    } 



    function startSale(uint _startTime, uint _endTime) auth saleIn(State.Pending) public

    {

        // require(_startTime >= now);

        require(startTime < _endTime);



        startTime = _startTime;

        endTime = _endTime;

    

        state      = State.Running;



        emit LogStartSale(startTime, endTime);

    }



    function endSale() auth saleIn(State.Running) public

    {

        state = State.Succeeded;

        

        emit LogEndSale(state == State.Succeeded, totalEthDeposited, totalTokensBought);

    }



    function extendSale(uint _endTime) auth saleIn(State.Running) public

    {

        require(_endTime > endTime);



        endTime = _endTime;

        emit LogExtendSale(endTime);

    }



    function collectEth() auth public

    {

        require(address(this).balance > 0);



        uint ethToCollect = address(this).balance;

        totalEthCollected = add(totalEthCollected, ethToCollect);

        address(beneficiary).transfer(ethToCollect);

        

        emit LogCollectEth(ethToCollect, totalEthDeposited);

    }

    

    function whiteListAddresses(address[] _buyer,bool _status) auth public 

    {

        for(uint tmp = 0; tmp < _buyer.length; tmp++)

        {

            whiteListedBuyers[_buyer[tmp]] = _status;    

        }



        emit LogWhitelistAddresses(_buyer,_status);

    }



    function updateWhiteListing(address _buyer,bool _status) auth public 

    {

        require(_buyer != address(0));

        

        whiteListedBuyers[_buyer] = _status;

        

        emit LogUpdateWhitelisting(_buyer,_status);

    }

    

    function updateBonusPercent(uint _percent) auth saleIn(State.Running) public

    {

        BONUS = _percent;

        

        emit LogBonusUpdate(_percent);

    }

    

    function updateHardcap(uint _MAX_FUNDING) auth saleIn(State.Running) public

    {

        MAX_FUNDING = _MAX_FUNDING;

        

        emit LogHardcapUpdate(MAX_FUNDING);

    }

    

    function updateExchangeRate(uint _tokensPerEth) auth saleIn(State.Running) public

    {

        tokensPerEth = _tokensPerEth;

        

        emit LogExchangeRateUpdate(tokensPerEth);

    }



    /********************** Private Methods ******************************/



    



    // calculate number of tokens buyer get when sending 'ethSent' ethers

    // after 'ethDepostiedSoFar` already reeived in the sale

    function calcTokensForPurchase(uint ethSentByUser) private view returns (uint tokens)

    {

        return wmul(ethSentByUser, tokensPerEth);

    }



    

}