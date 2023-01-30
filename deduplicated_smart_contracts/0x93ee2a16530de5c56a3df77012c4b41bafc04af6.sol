pragma solidity ^0.5.8;
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./ReentrancyGuard.sol";
contract WeFairPlayInvestment is ReentrancyGuard{
    using SafeMath for uint;
    using IterableMapping for IterableMapping.itmap;
    modifier onlyBagholders() {
        require(myTokens() > 0,'msg.sender should have tokens.');
        _;
    }
    modifier onlyOwner()
    {
        require(owner == msg.sender,'msg.sender is not owner.');
        _;
    }
    modifier onlyAdministrator(){
        require(owner == msg.sender || administrators[keccak256(abi.encodePacked(msg.sender))]
            ,'msg.sender is not owner or admin.');
        _;
    }
    modifier onlyOperators(){
        require(mapOperatorStocks_.contains(uint(msg.sender))
        && mapOperatorStocks_.data[uint(msg.sender)].value > 0,'msg.sender should have stocks.');
        _;
    }
    modifier notEarlyWhale(){
        require(!onlyAmbassadors,'now should not early whale stage.');
        _;
    }
    modifier notEndStage(){
        require(!isEndStage,'now should not end stage.');
        _;
    }
    modifier antiEarlyWhale(uint256 _amountOfEthereum){
        if(!onlyAmbassadors)
        {
            _;
            return;
        }
        address _customerAddress = msg.sender;
        if( onlyAmbassadors && ((address(this).balance - originalBalance) < ambassadorQuota_ )){
            require(
                ambassadors_[_customerAddress] == true &&
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
                ,'msg.sender is not a ambassador or has reach buy limit.'
            );
            ambassadorAccumulatedQuota_[_customerAddress] = ambassadorAccumulatedQuota_[_customerAddress].add(_amountOfEthereum);
            _;
        } else {
            onlyAmbassadors = false;
            _;
        }
    }
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted
    );
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    string public name = "WeFairPlayCoin";
    string public symbol = "WFP";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 20;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 1 ether;
    uint256 constant internal ambassadorQuota_ = 10 ether;
    uint originalBalance;
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;
    IterableMapping.itmap mapOperatorRewards_;
    IterableMapping.itmap mapOperatorStocks_;
    uint totalOperatorRewards;
    uint256 constant public totalStocks_ = 10000;
    uint constant internal stockLockTime = 1 days;
    struct StockTransInfo { uint stocks; uint price; uint endTime;}
    mapping(address => mapping(address => StockTransInfo)) mapStockTrans;
    mapping(address => uint) mapLockStocks;
    uint lastActiveTime;
    uint constant internal ENTER_END_DURATION = 2 * 4 weeks;//2 * 4 weeks;
    bool public isEndStage;
    uint public enterEndTime;
    uint constant internal END_STAGE_DURATION = 4 weeks;//4 weeks;
    address owner;
    mapping(bytes32 => bool) public administrators;
    bool public onlyAmbassadors = true;
    constructor()
    public
    {
        owner = msg.sender;
        administrators[0x6e87e5c3130679f898089256718f36b117cb685debd8d2511298b3f0dabadf1e] = true;
        ambassadors_[0x1Fd11576EAbe588115aA47E52904C3221E4c0a95] = true;
        ambassadors_[0x1DC93b1bE8b97959f5B07d6113A909F9C89D3361] = true;
        ambassadors_[0x135de610Bd907e9B6aB3d93753d6E59De6ef886B] = true;
        ambassadors_[0x5f5B2BB60EBDa86C9efc9a4cA01a7756554c2Fe5] = true;
        ambassadors_[0x89EE32611CcFa44044cc1F0d0ECC53E53Aa3C634] = true;
        ambassadors_[0x16B0e5F320Cd30028caFf791aC08dF830B52e61d] = true;
        ambassadors_[0xA9d47178067568A5C84c0849A7e1b47139DA6a7c] = true;
        ambassadors_[0x0d7e1a43e666714A1B7B8F4e5eD9Ac86597078A0] = true;
        ambassadors_[0xc33F6Ca865D8Ec8fE00037f64B8dbe6cBD751555] = true;
        ambassadors_[0x324bC683445fa86CFc85b49c1eD4d2bdDc6409aE] = true;
        mapOperatorStocks_.add_or_insert(uint(owner),totalStocks_);
        originalBalance = address(this).balance;
    }
    function ambassadorLeftLimit()
    view
    public
    returns(uint)
    {
        require(ambassadors_[msg.sender] == true,'msg.sender is not a ambassador.');
        return ambassadorMaxPurchase_.sub(ambassadorAccumulatedQuota_[msg.sender]);
    }
    function isAmbassador()
    view
    public
    returns(bool)
    {
        return ambassadors_[msg.sender];
    }
    function buy()
    public
    payable
    {
        purchaseTokens(msg.value);
    }
    function()
    payable
    external
    {
        purchaseTokens(msg.value);
    }
    function exit()
    public
    {
        uint256 _tokens = tokenBalanceLedger_[msg.sender];
        if(_tokens > 0) sell(_tokens);
    }
    function sell(uint256 _amountOfTokens)
    nonReentrant()
    notEarlyWhale()
    onlyBagholders()
    public
    {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress],'seller have not enough tokens.');
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = _ethereum.div(dividendFee_);
        uint256 _taxedEthereum = _ethereum.sub(_dividends);
        sendOperatorRewards_(_dividends);
        tokenSupply_ = tokenSupply_.sub( _tokens);
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].sub( _tokens);
        lastActiveTime = now;
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
        msg.sender.transfer(_taxedEthereum);
    }
    function _transfer(address _from, address _toAddress, uint _amountOfTokens)
    notEarlyWhale()
    notEndStage()
    internal
    {
        address _customerAddress = _from;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress],'seller have not enough tokens.');
        uint256 _tokenFee = _amountOfTokens.div(dividendFee_);
        uint256 _taxedTokens = _amountOfTokens.sub(_tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);
        tokenSupply_ = tokenSupply_.sub(_tokenFee);
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].sub( _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = tokenBalanceLedger_[_toAddress].add( _taxedTokens);
        sendOperatorRewards_(_dividends);
        lastActiveTime = now;
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
    }
    function transfer(address _toAddress, uint256 _amountOfTokens)
    onlyBagholders()
    public
    returns(bool)
    {
        _transfer(msg.sender, _toAddress, _amountOfTokens);
        return true;
    }
    function isAdministrator()
    view
    public
    returns(bool)
    {
        return (owner == msg.sender || administrators[keccak256(abi.encodePacked(msg.sender))]);
    }
    function disableInitialStage()
    onlyOwner()
    public
    {
        onlyAmbassadors = false;
    }
    function setAdministrator(bytes32 _identifier, bool _status)
    onlyAdministrator()
    public
    {
        administrators[_identifier] = _status;
    }
    function setOwner(address payable newOwner) onlyOwner public
    {
        owner = newOwner;
    }
    function canEnterEndStage() view public returns(bool)
    {
        return (lastActiveTime > 0 && now - lastActiveTime > ENTER_END_DURATION);
    }
    function enterEndStage() onlyOwner public
    {
        require(lastActiveTime > 0 && now - lastActiveTime > ENTER_END_DURATION,"Last transaction should be 8 weeks ago.");
        isEndStage = true;
        enterEndTime = now;
    }
    function restEndTime() view public returns(int)
    {
        if(isEndStage && enterEndTime > 0)
        {
            uint endTimestamp = enterEndTime.add(END_STAGE_DURATION);
            if(now < endTimestamp)
            {
                return int(endTimestamp.sub(now));
            }
            else
            {
                return 0;
            }
        }
        return -1;
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function kill() onlyOwner public
    {
        require(isEndStage && enterEndTime > 0 && now - enterEndTime > END_STAGE_DURATION
            ,'now is not end stage or not enter end stage or now is not reach end stage duration.');
        selfdestruct(toPayable(owner));
    }
    function setName(string memory _name)
    onlyAdministrator()
    public
    {
        name = _name;
    }
    function setSymbol(string memory _symbol)
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
        return address(this).balance.sub(totalOperatorRewards);
    }
    function totalSupply()
    public
    view
    returns(uint256)
    {
        return tokenSupply_;
    }
    function myTokens()
    public
    view
    returns(uint256)
    {
        return balanceOf(msg.sender);
    }
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
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = _ethereum.div( dividendFee_  );
            uint256 _taxedEthereum = _ethereum.sub( _dividends);
            return _taxedEthereum;
        }
    }
    function buyPrice()
    public
    view
    returns(uint256)
    {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _taxedEthereum = _ethereum.mul(dividendFee_).div(dividendFee_-1);
            return _taxedEthereum;
        }
    }
    function calculateTokensReceived(uint256 _ethereumToSpend)
    public
    view
    returns(uint256)
    {
        uint256 _dividends = _ethereumToSpend.div( dividendFee_);
        uint256 _taxedEthereum = _ethereumToSpend.sub( _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }
    function calculateEthereumReceived(uint256 _tokensToSell)
    public
    view
    returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_,'token to sell should less than total tokens.');
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = _ethereum.div( dividendFee_);
        uint256 _taxedEthereum = _ethereum.sub( _dividends);
        return _taxedEthereum;
    }
    function purchaseTokens(uint256 _incomingEthereum)
    antiEarlyWhale(_incomingEthereum)
    notEndStage()
    internal
    returns(uint256)
    {
        address _customerAddress = msg.sender;
        uint256 _dividends = _incomingEthereum.div( dividendFee_);
        uint256 _taxedEthereum = _incomingEthereum.sub( _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        require(_amountOfTokens > 0 && (_amountOfTokens.add(tokenSupply_) > tokenSupply_)
            ,'to buy tokens should >0 and not cause total token overflow max uint.');
        sendOperatorRewards_(_dividends);
        if(tokenSupply_ > 0){
            tokenSupply_ = tokenSupply_.add( _amountOfTokens);
        } else {
            tokenSupply_ = _amountOfTokens;
        }
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].add( _amountOfTokens);
        lastActiveTime = now;
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens);
        return _amountOfTokens;
    }
    function sendOperatorRewards_(uint256 _ethereum)
    internal
    {
        uint restRewards = _ethereum;
        for(uint i = mapOperatorStocks_.iterate_start(); mapOperatorStocks_.iterate_valid(i) && restRewards>0; i = mapOperatorStocks_.iterate_next(i))
        {
            (uint addrOperator,uint stocks) = mapOperatorStocks_.iterate_get(i);
            if(stocks == 0)
            {
                continue;
            }
            uint256 rewards = _ethereum.mul(stocks).div(totalStocks_);
            if(rewards > restRewards)
            {
                rewards = restRewards;
            }
            restRewards = restRewards.sub(rewards);
            mapOperatorRewards_.add_or_insert(addrOperator,rewards);
            totalOperatorRewards = totalOperatorRewards.add(rewards);
        }
    }
    function getOperatorStocks_()
    view
    public
    returns(uint)
    {
        return mapOperatorStocks_.data[uint(msg.sender)].value;
    }
    function getOperatorRewards_()
    view
    public
    returns(uint)
    {
        return mapOperatorRewards_.data[uint(msg.sender)].value;
    }
    function withDrawRewards_()
    nonReentrant()
    notEarlyWhale()
    onlyOperators()
    public
    {
        uint player = uint(msg.sender);
        require(mapOperatorRewards_.contains(player),'stock holder should has rewards.');
        uint totalRewards = mapOperatorRewards_.data[player].value;
        require(totalRewards>0 && totalRewards <= totalOperatorRewards && totalRewards <= address(this).balance
            ,'rewards should >0 and less than total rewards and less than contract balance.');
        mapOperatorRewards_.sub(player,totalRewards);
        totalOperatorRewards = totalOperatorRewards.sub(totalRewards);
        msg.sender.transfer(totalRewards);
    }
    function transferStocks_(address receiver,uint amountStock)
    nonReentrant()
    onlyOperators()
    notEarlyWhale()
    notEndStage()
    public
    {
        uint sender = uint(msg.sender);
        uint restStocks = uint(mapOperatorStocks_.data[sender].value).sub(mapLockStocks[msg.sender]);
        require(amountStock <= restStocks
            ,'to transfer stock amount should less than player stocks except locked stocks.');
        mapOperatorStocks_.add_or_insert(uint(receiver),amountStock);
        mapOperatorStocks_.sub(sender,amountStock);
        if(mapOperatorStocks_.data[sender].value == 0)
        {
            uint totalRewards = mapOperatorRewards_.data[sender].value;
            mapOperatorStocks_.remove(sender);
            mapOperatorRewards_.remove(sender);
            if(totalRewards > 0)
            {
                if(totalRewards > totalOperatorRewards)
                {
                    totalRewards = totalOperatorRewards;
                }
                totalOperatorRewards = totalOperatorRewards.sub(totalRewards);
                address(sender).transfer(totalRewards);
            }
        }
    }
    function createStockTransaction(address _receiver, uint _stocks, uint _price)
    notEarlyWhale()
    notEndStage()
    public
    {
        uint restStocks = uint(mapOperatorStocks_.data[uint(msg.sender)].value).sub(mapLockStocks[msg.sender]);
        require(_stocks > 0 && _stocks <= restStocks
            ,'stock to transact should >0 and less than player stocks except locked stocks.');
        require(_price > 0,'price should >0.');
        StockTransInfo storage info = mapStockTrans[msg.sender][_receiver];
        require(info.stocks == 0,'transaction to receiver has exist.');
        mapLockStocks[msg.sender] = mapLockStocks[msg.sender].add(_stocks);
        info.stocks = _stocks;
        info.price = _price;
        info.endTime = now + stockLockTime;
    }
    function getMyLockStocks()
    public
    view
    returns(uint)
    {
        return mapLockStocks[msg.sender];
    }
    function queryStocksTransactionTo(address receiver)
    public
    view
    returns(uint _stocks, uint _price, uint _endTime)
    {
        StockTransInfo storage info = mapStockTrans[msg.sender][receiver];
        _stocks = info.stocks;
        _price = info.price;
        _endTime = info.endTime;
    }
    function queryStocksTransactionFrom(address seller)
    public
    view
    returns(uint _stocks, uint _price, uint _endTime)
    {
        StockTransInfo storage info = mapStockTrans[seller][msg.sender];
        _stocks = info.stocks;
        _price = info.price;
        _endTime = info.endTime;
    }
    function confirmStocksTransaction(address payable seller, bool agreed)
    nonReentrant()
    notEarlyWhale()
    payable
    public
    {
        StockTransInfo storage info = mapStockTrans[seller][msg.sender];
        require(info.stocks > 0 && now < info.endTime,'transact stocks is not >0 or now has reached end time.');
        if(agreed)
        {
            require(msg.value == info.price,'msg.sender paid ether is not equal to the price.');
            mapOperatorStocks_.add_or_insert(uint(msg.sender),info.stocks);
            mapOperatorStocks_.sub(uint(seller),info.stocks);
        }
        mapLockStocks[seller] = mapLockStocks[seller].sub(info.stocks);
        if(mapLockStocks[seller] == 0)
        {
            delete mapLockStocks[seller];
        }
        delete mapStockTrans[seller][msg.sender];
        if(agreed)
        {
            uint sender = uint(seller);
            uint transValue = msg.value;
            if(mapOperatorStocks_.data[sender].value == 0)
            {
                uint totalRewards = mapOperatorRewards_.data[sender].value;
                mapOperatorStocks_.remove(sender);
                mapOperatorRewards_.remove(sender);
                if(totalRewards > 0)
                {
                    if(totalRewards > totalOperatorRewards)
                    {
                        totalRewards = totalOperatorRewards;
                    }
                    totalOperatorRewards = totalOperatorRewards.sub(totalRewards);
                    transValue = transValue.add(totalRewards);
                }
            }
            seller.transfer(transValue);
        }
    }
    function retrieveStocksBack(address receiver)
    notEarlyWhale()
    public
    {
        address seller = msg.sender;
        StockTransInfo storage info = mapStockTrans[seller][receiver];
        require(info.stocks > 0 && now > info.endTime,'transact stocks is not >0 or now has not reach end time.');
        mapLockStocks[seller] = mapLockStocks[seller].sub(info.stocks);
        if(mapLockStocks[seller] == 0)
        {
            delete mapLockStocks[seller];
        }
        delete mapStockTrans[seller][msg.sender];
    }
    function ethereumToTokens_(uint256 _ethereum)
    internal
    view
    returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
        (
        (sqrt
        (
            (_tokenPriceInitial**2)
            +
            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
            +
            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
            +
            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
        )
        ).sub( _tokenPriceInitial
        )
        /(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
        return _tokensReceived;
    }
    function tokensToEthereum_(uint256 _tokens)
    internal
    view
    returns(uint256)
    {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
        (
        (
        (
        tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
        )-tokenPriceIncremental_
        )*(tokens_ - 1e18)
        ).sub((tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
        )
        /1e18);
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
