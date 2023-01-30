// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "./helpers.sol";

contract IAbacusOracle{
    uint public callFee;
    function getJobResponse(uint64 _jobId) public view returns(uint64[] memory _values){    }
    function scheduleFunc(address to ,uint callTime, bytes memory data , uint fee , uint gaslimit ,uint gasprice)public payable{}
}

contract EcoceliumInit is Initializable {

    address payable owner;
    address payable public MONEYMANAGER;
    address payable public DATAMANAGER;
    address payable public ECOCELIUM;
    address payable public ABACUS;
    string public WRAP_ECO_SYMBOL;
    string public ECO;
    string public ETH_SYMBOL;
    string public WRAP_ETH_SYMBOL;
    uint public swapFee;
    uint public rewardFee;
    uint public tradeFee;
    uint public CDSpercent;
    string [] rtokenlist;
    string [] wtokenlist;
    mapping (string => uint) public rcurrencyID;
    mapping (string => uint) public wcurrencyID;
    mapping (address => bool)  public isRegistrar;
    mapping (address => bool) public isUserLocked;
    mapping (string => uint ) public ownerFeeVault;
    mapping (string => uint) public slabRateDeposit;
    mapping (address => bool) public friendlyaddress;
    mapping (address => address) public SponsorAddress;
    mapping (address => uint) public usertreasuryearnings;
    
    event OrderCreated(
        address userAddress,
        uint duration,
        uint yield,
        uint amount,
        string token
        );
        
    event Swap(
        address userAddress,
        string from,
        string to,
        uint amount
        );
        
    event Borrowed(
        uint64 orderId,
        address borrower,
        uint amount,
        uint duration
        );
        
    event Deposit(
         address userAddress,
         string token,
         uint tokenAmount,
         uint collateralValue
         );
         
    event DuePaid(
        uint64 orderId,
        address borrower,
        uint amount
        );
        
    event WrapTokenCreated(
        address TokenAddress,
        string  TokenName,
        string  TokenSymbol,
        uint    Decimals
        );
        
    receive() payable external {     }    
        
    function initializeAddress(address payable _owner) public initializer {
        friendlyaddress[_owner] = true;
        owner = _owner;
    }
       
    function addRealCurrency(string memory rtoken) public{
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        if(rcurrencyID[rtoken] == 0) {
            rtokenlist.push(rtoken);
            rcurrencyID[rtoken] = rtokenlist.length; }
    }
    
    function addWrapCurrency (string memory wtoken) public{
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        if(wcurrencyID[wtoken] == 0) {
            wtokenlist.push(wtoken);
            wcurrencyID[wtoken] = wtokenlist.length; }
    }
    
    function setSlabRate(string memory WToken, uint rate) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        slabRateDeposit[WToken] = rate;
    }
    
    function setUserLocked(address userAddress, bool value) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        isUserLocked[userAddress] = value;
    }
    
    function setFriendlyAddress(address Address) public {
        (msg.sender == owner,"not owner");
        friendlyaddress[Address] = true;
    }
    
    function addRegistrar(address _registrar) public{
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        isRegistrar[_registrar] = true;
    }
    
    function setOwnerFeeVault(string memory add,uint value) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        ownerFeeVault[add] += value; 
    }
       
    function emitOrderCreated(address userAddress, uint _duration, uint _yield, uint newAmount,string  memory _tokenSymbol) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        emit OrderCreated(userAddress,_duration,_yield,newAmount,_tokenSymbol);        
    }
    
    function emitSwap(address msgSender, string memory from, string memory to,uint _amount) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        emit Swap(msgSender,from,to,_amount);
    }
    
    function emitBorrowed(uint64 _orderId, address msgSender, uint _amount,uint _duration) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        emit Borrowed(_orderId,msgSender,_amount,_duration);
    }
    
    function emitWrappedCreated(address tokenAddress,string memory name, string memory symbol,uint8 decimals) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        emit WrapTokenCreated(tokenAddress,name,symbol,decimals);   
    }
    
    function emitDeposit(address msgSender, string memory _tokenSymbol, uint amount, uint tokenUsdValue) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        emit Deposit(msgSender,_tokenSymbol,amount,tokenUsdValue);
    }
    
    function emitDuePaid(uint64 _orderId, address msgSender, uint due) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        emit DuePaid(_orderId,msgSender,due);
    }
    
    function setCONSTSYMBOLS(string[4] memory _symbolCONST) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        WRAP_ECO_SYMBOL = _symbolCONST[0];
        ECO = _symbolCONST[1];
        ETH_SYMBOL = _symbolCONST[2];
        WRAP_ETH_SYMBOL = _symbolCONST[3];
    }
    
    function updateFees(uint _swapFee,uint _tradeFee,uint _rewardFee) public{
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        (swapFee,tradeFee,rewardFee) = (_swapFee,_tradeFee,_rewardFee);
    }
    
    function setCSDpercent(uint percent) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        CDSpercent = percent;
    }
    
    function changeAbacusaddress(address payable Abacusaddress) public{
        require(msg.sender == owner,"not owner");
        ABACUS = Abacusaddress;
    } 
    
    function changeEcoceliumaddress(address payable Ecocelium) public{
        require(msg.sender == owner,"not owner");
        ECOCELIUM = Ecocelium;
    } 
    
    function changeDMaddress(address payable DMAddress) public{
        require(msg.sender == owner,"not owner");
        DATAMANAGER = DMAddress;
    }
    
     function changeMMaddress(address payable MMaddress) public{
        require(msg.sender == owner,"not owner");
        MONEYMANAGER = MMaddress;
    }
    
    function changeOwner(address payable _owner) public{
        require(msg.sender==owner);
        owner = _owner;
    }
    
    function setSponsor(address userAddress, address _sponsorAddress) external {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        SponsorAddress[userAddress] = _sponsorAddress;
    }
    
    function updateTreasuryEarnings(address userAddress, uint _amount) public {
        require(friendlyaddress[msg.sender],"Not Friendly Address");
        usertreasuryearnings[userAddress] = _amount;
    }
}


contract EcoMoneyManager is Initializable {
    

    
    
    EcoceliumInit Init;
    address public owner;
    address [] public TokenAddresses;
    address [] public wTokenAddresses;
    mapping (string => address) rTokens;    
    mapping (string => string)  rTokensTowToken;
    mapping (string => TokenConfig)  wTokens;
    mapping (address => uint) public ecoWithdrawls;
    mapping (string => uint) public WGains;
    mapping (string => uint) public WLoss;
    
    receive() payable external {     }
    
    struct TokenConfig{
        address tokenAddress;
        uint64 fetchId;
    }
    
    function initialize(address _owner, address payable _Init) public initializer{
        owner = _owner;
        Init = EcoceliumInit(_Init);
    }
    
    function updateAdminAddress(address adminAddress) public {
        require(msg.sender == owner);
        for(uint i = 0;i<wTokenAddresses.length;i++){
            wERC20(wTokenAddresses[i]).changeAdmin(adminAddress);
        }
    }
    
    function addTokenWithAddress(address tokenAddress) public {
        require(msg.sender == owner);
        ERC20Basic token = ERC20Basic(tokenAddress);
        require(getrTokenAddress(token.symbol())== address(0),"token exist");
        rTokens[token.symbol()] = tokenAddress;  
        TokenAddresses.push(tokenAddress);
    } 

    function createWrapToken(string memory name,string memory symbol,uint64 _fetchId, uint8 decimal, string memory wrapOf) public  returns(address TokenAddress){
        require(msg.sender == owner);
        wERC20  token = new wERC20(name,symbol,decimal, address(this), address(this));        
        rTokensTowToken[wrapOf] = symbol;
        TokenAddresses.push(address(token));
        wTokenAddresses.push(address(token));
        wTokens[symbol] = TokenConfig({
                                        tokenAddress:address(token),
                                        fetchId : _fetchId
                                    });
        Init.emitWrappedCreated(address(token),name,symbol,token.decimals());                 
        return address(token);
    } 
    
    function changeOwner(address _owner) public{
        require(owner == msg.sender);
        owner =_owner;
    }    
    function getwTokenAddress(string memory symbol) public view returns(address){
        return wTokens[symbol].tokenAddress;
    }
    
    function getFetchId(string memory symbol ) public view returns(uint64){
        return wTokens[symbol].fetchId;
    }
    
    function getrTokenAddress(string memory symbol) public view returns(address){
        return rTokens[symbol];
    }
    
    function getTokenAddresses() public view returns(address[] memory){
        return TokenAddresses;
    }
    
    function getWrapped(string memory symbol) public view returns(string memory){
        return rTokensTowToken[symbol];
    }
    
    function getTokenID(string memory symbol) public view returns(uint){
        for(uint i=0; i< TokenAddresses.length; i++) {
            if(TokenAddresses[i] == wTokens[symbol].tokenAddress) {
                return i;
            }
        }
    }
    
    function releaseWrappedToken (address _userAddress, uint amount, string memory WToken) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(WToken)).release(_userAddress,amount);
    }
    
    function mintWrappedToken (address _userAddress, uint amount, string memory WToken) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(WToken)).mint(_userAddress,amount);
    }
    
    function lockWrappedToken (address _userAddress, uint amount, string memory WToken) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(WToken)).lock(_userAddress,amount);
    }
    
    function burnWrappedFrom(address userAddress, uint amount, string memory WToken) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(WToken)).burnFrom(userAddress,amount);
    }
     
    function mintECO(address userAddress, uint amount) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(Init.WRAP_ECO_SYMBOL())).mint(userAddress,amount);
    }
    
    function lockECO(address userAddress, uint amount) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(Init.WRAP_ECO_SYMBOL())).lock(userAddress,amount);
    }
    
    function releaseECO(address userAddress, uint amount) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(Init.WRAP_ECO_SYMBOL())).release(userAddress,amount);
    }
    
    function burnECOFrom(address userAddress, uint amount) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        wERC20(getwTokenAddress(Init.WRAP_ECO_SYMBOL())).burnFrom(userAddress,amount);
    }
    
    function DepositManager(string memory _rtoken, uint amount, address userAddress) public payable {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        if(Init.rcurrencyID(_rtoken) == Init.rcurrencyID(Init.ETH_SYMBOL()))
        {   require(msg.value >= amount,"Invalid Amount");  }
        else {ERC20Basic rtoken = ERC20Basic(getrTokenAddress(_rtoken));
        require(rtoken.allowance(userAddress, address(this)) >= amount,"set allowance");
        rtoken.transferFrom(userAddress,address(this),amount);}
    }
    
    function WithdrawManager(string memory _rtoken, uint amount, address payable userAddress) public payable {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        if(Init.rcurrencyID(_rtoken) == Init.rcurrencyID(Init.ETH_SYMBOL()))
        {   userAddress.transfer(amount);        }
        else {
        ERC20Basic rtoken = ERC20Basic(getrTokenAddress(_rtoken));
        rtoken.approve(userAddress, amount);
        rtoken.transferFrom(address(this),userAddress,amount);}
    }
    
    function redeemEcoEarning(address userAddress, uint amount) public {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        ecoWithdrawls[userAddress] += amount;
        wERC20(getwTokenAddress(Init.WRAP_ECO_SYMBOL())).transferFrom(address(this),userAddress,amount);
    }
    
    function updateFetchID (string memory wtoken, uint64 _fetchID) external {
        require(owner == msg.sender);
        wTokens[wtoken].fetchId = _fetchID;
    }
    
    function w2wswap (address msgSender, string memory token1, uint token1amount, uint token2amount, string memory token2) external {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        releaseWrappedToken(msgSender, token1amount, token1);
        burnWrappedFrom(msgSender,token1amount,token1);
        WGains[token1]=token1amount;
        mintWrappedToken(msgSender,token2amount, token2);
        lockWrappedToken(msgSender, token2amount, token2);
        WLoss[token2]=token2amount;
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "./Ecocelium_Initializer.sol";

/*

███████╗░█████╗░░█████╗░░█████╗░███████╗██╗░░░░░██╗██╗░░░██╗███╗░░░███╗
██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██║░░░░░██║██║░░░██║████╗░████║
█████╗░░██║░░╚═╝██║░░██║██║░░╚═╝█████╗░░██║░░░░░██║██║░░░██║██╔████╔██║
██╔══╝░░██║░░██╗██║░░██║██║░░██╗██╔══╝░░██║░░░░░██║██║░░░██║██║╚██╔╝██║
███████╗╚█████╔╝╚█████╔╝╚█████╔╝███████╗███████╗██║╚██████╔╝██║░╚═╝░██║
╚══════╝░╚════╝░░╚════╝░░╚════╝░╚══════╝╚══════╝╚═╝░╚═════╝░╚═╝░░░░░╚═╝

Brought to you by Kryptual Team */

contract EcoceliumDataManager is Initializable {
    
    IAbacusOracle abacus;
    EcoMoneyManager EMM;
    EcoceliumInit Init;
    enum Status {OPENCREATOR, OPENBORROW, MATCHED, CLOSED} 

    /*============Mappings=============
    ----------------------------------*/
    mapping (string => uint64[]) public orderpool;  //is an always sorted array based on Yield Rate of Pending Orders for all currencies
    mapping (string => uint) public poolindex;  //Index of First Investor Bid for all currencies
    
    mapping (address => User) public users;
    //mapping (address => address) public sponsorAddress; //FOR TREASURY PLAN
    mapping (uint64 => Status) public orderStatus;
    mapping (uint64 => matchedOrder) public matchOrderMap;
    mapping (uint64 => Order) public openOrderMap;
    
    /*=========Structs and Initializer================
    --------------------------------*/    
    
    struct freeStorage{     //USER DEPOSIT / BORROW STRUCTURE
        uint amount;
        uint time;
        string wtoken;
        uint usdvalue;
    }
    
    struct matchedOrder{            //RUNNING OR MATCHED ORDERS IN THIS FORM
        address supplier;
        address borrower;
        uint time;
        uint expiryDate;
        uint duration;
        uint amount;
        uint usdvalue;
        uint yield;
        string wtoken;
        uint duesPaid;
    }

    struct Order{       // PENDING ORDERS IN THIS FORMAT
        address creator;
        uint duration;
        uint amount;
        uint yield;
        string wtoken;
    }    
    
    struct User{
        uint totalDeposit;  //USD VALUE OF TOTAL DEPOSIT AT DEPOSIT TIME
        uint totalBorrowed; //USD VALUE OF TOTAL DEPOSIT AT BORROW TIME
        freeStorage [] myDeposits; //DEPOSIT DATA
        freeStorage [] myBorrows; //BORROW DATA
        mapping(string => uint) deposits; //CURRENCY-WISE TOTAL DEPOSIT COUNT FULL VALUE 
        mapping(string => uint) borrows; //CURRENCY-WISE TOTAL BORROW COUNT FULL VALUE
        uint64 [] borrowedOrders; //BORROWED ORDER - ORDER ID
        uint64 [] createdOrders; //CREATED ORDER - ORDER ID
        uint64 [] myOrders; //MATCHED ORDR - ORDER ID
    }
    
    function initializeAddress(address payable EMMaddress,address AbacusAddress, address payable Initaddress) external initializer{
            EMM = EcoMoneyManager(EMMaddress);
            abacus = IAbacusOracle(AbacusAddress); 
            Init = EcoceliumInit(Initaddress);
    }

    /*============Main Functions===============
    Key Notes - 
    1) Always call main functions of Data Manager with Wrapped Token
    2) _status signifies (status == Status.OPENCREATOR) operation - Returns True for Deposit Functions and False for Borrow Function
    3) require(Init.friendlyaddress(msg.sender) ,"Not Friendly Address"); - This is mentioned in the EcoceliumInit Contract
    4) FreePusher/Popper are for Liquidity Pools and push/pop order and matchOrder is the Order Matching Engine
    5) Fetch Token Price Returns Values in 10**8
    6) Amounts are with setting off Token Decimals
    ---------------------------------*/
    
    function freePusher(address userAddress, string memory token, uint _amount, bool _status) external {  //_status signifies (status == Status.OPENCREATOR) operation
        require(Init.friendlyaddress(msg.sender) ,"Not Friendly Address");
        uint _usdValue = USDValue(_amount, token);
        freeStorage memory newStorage = freeStorage({  amount: _amount,
                                                    time: now,
                                                    wtoken: token,
                                                    usdvalue: _usdValue   });
        if(_status){
            users[userAddress].myDeposits.push(newStorage);
            users[userAddress].totalDeposit += _usdValue;
            users[userAddress].deposits[token] += _amount;
        }   else {
            users[userAddress].myBorrows.push(newStorage);
            users[userAddress].totalBorrowed += _usdValue;
            users[userAddress].borrows[token] += _amount;
        }
    }
    
    function freePopper(address userAddress, string memory _tokenSymbol, uint _amount, bool _status) public returns (uint dues) {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        if(_status) { 
            require(users[userAddress].deposits[_tokenSymbol]>_amount, "Insufficient Deposits");
            users[userAddress].deposits[_tokenSymbol] -= _amount;
            users[userAddress].totalDeposit -= USDValue(_amount, _tokenSymbol); 
        } else {
            require(users[userAddress].borrows[_tokenSymbol]>_amount,"Insufficient Borrowings");
            users[userAddress].borrows[_tokenSymbol] -= _amount;
            users[userAddress].totalBorrowed -= USDValue(_amount, _tokenSymbol);
        }
        uint amountLeft= _amount;
        freeStorage [] storage mystorage = _status ?  users[userAddress].myDeposits : users[userAddress].myBorrows;
        for( uint i= mystorage.length-1; amountLeft >0 ; i--){
            if(keccak256(abi.encodePacked(mystorage[i].wtoken)) != keccak256(abi.encodePacked(_tokenSymbol))) { continue; }
            if (mystorage[i].amount <= amountLeft){
                amountLeft -= mystorage[i].amount;
                dues+= calculateECOEarning(USDValue(mystorage[i].amount,_tokenSymbol), _tokenSymbol, mystorage[i].time);
                mystorage.pop(); 
            } else {
                mystorage[i].amount -= amountLeft;
                dues += calculateECOEarning(USDValue(amountLeft,_tokenSymbol), _tokenSymbol, mystorage[i].time);
                amountLeft = 0;
            }
        } 
        _status ? users[userAddress].myDeposits = mystorage :   users[userAddress].myBorrows = mystorage;
        Init.setOwnerFeeVault(_tokenSymbol, (dues*Init.rewardFee()/100));
    }
    
    function pushOrder(address userAddress,string memory _tokenSymbol ,uint _amount,uint _duration, uint _yield, bool _status) internal returns (uint){
        (uint64 _orderId,uint newAmount,uint fee) = _ordersub(_amount,userAddress,_duration,_tokenSymbol);
        openOrderMap[_orderId] = Order({       
                                            creator : userAddress,
                                            duration : _duration,
                                            amount : newAmount,
                                            yield : _yield,
                                            wtoken : _tokenSymbol
                                 });
        if(_status) {
            orderStatus[_orderId] = Status.OPENCREATOR;
            users[userAddress].createdOrders.push(_orderId);
        } else  {
            orderStatus[_orderId] = Status.OPENBORROW;
            users[userAddress].borrowedOrders.push(_orderId);  }
        poolSorter(_orderId, _tokenSymbol, true);
        return fee;
    }
    
    function poolSorter(uint64 _orderId, string memory _tokenSymbol, bool _status) internal {        //Status here signifies Insertion if True, and Deletion if false
        uint64 [] memory temp;
        bool task;
        poolindex[_tokenSymbol]=0;
        for((uint i, uint j)=(0,0);i<orderpool[_tokenSymbol].length;(i++,j++)) {
            temp[j]=orderpool[_tokenSymbol][i];
            if(!task && _status && openOrderMap[temp[j]].yield > openOrderMap[_orderId].yield) {    //Insertion Case
                    temp[j]=_orderId; temp[++j]=orderpool[_tokenSymbol][i]; task = true;
            }else if(!task && !_status && _orderId == temp[j]){     //Deletion Case
                temp[j]=orderpool[_tokenSymbol][++i]; task = true;
            }
            if(orderStatus[orderpool[_tokenSymbol][i-1]]==Status.OPENBORROW && orderStatus[orderpool[_tokenSymbol][i]]==Status.OPENCREATOR) {       //Assigns updatePoolIndex
                poolindex[_tokenSymbol] = i;
                break;
            }
        }
        orderpool[_tokenSymbol] = temp;
    }
    
    function matchOrder(address userAddress, string memory _tokenSymbol ,uint _amount,uint _duration,uint _yield, uint64 _orderId, bool _status) internal    {
        matchOrderMap[_orderId] = matchedOrder({       
                                            supplier : (orderStatus[_orderId] == Status.OPENBORROW) ? userAddress : openOrderMap[_orderId].creator,
                                            borrower : (orderStatus[_orderId] == Status.OPENCREATOR) ? userAddress : openOrderMap[_orderId].creator,
                                            time    : now,
                                            expiryDate : now + _duration*(30 days),
                                            duration : _duration,
                                            amount : _amount,
                                            usdvalue : USDValue(_amount,_tokenSymbol),
                                            yield : _yield,
                                            wtoken : _tokenSymbol,
                                            duesPaid : 0
                                            });
        _status ? delete users[openOrderMap[_orderId].creator].borrowedOrders[_orderId] : delete users[userAddress].createdOrders[_orderId];
        delete openOrderMap[_orderId];
        orderStatus[_orderId]=Status.MATCHED;
        users[matchOrderMap[_orderId].supplier].myOrders.push(_orderId);
        users[matchOrderMap[_orderId].borrower].myOrders.push(_orderId);
        scheduleExpiry(_orderId);
        scheduleCheck(_orderId,matchOrderMap[_orderId].borrower,1);
        EMM.mintWrappedToken(matchOrderMap[_orderId].borrower, _amount, _tokenSymbol);
        Init.emitOrderCreated(userAddress,_duration,_yield,_amount,_tokenSymbol); 
    }
    
    function newOrder(address userAddress,string memory _tokenSymbol ,uint _amount,uint _duration, uint _yield, bool _status) external {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        uint amountLeft= _amount;
        uint index;
        if(_status){
           index = poolindex[_tokenSymbol]-1;
           users[userAddress].deposits[_tokenSymbol] +=_amount;
           users[userAddress].totalDeposit += USDValue(_amount, _tokenSymbol);
        }   else {
           index = poolindex[_tokenSymbol];
            users[userAddress].borrows[_tokenSymbol] +=_amount;
           users[userAddress].totalBorrowed += USDValue(_amount, _tokenSymbol);
        }
        while(amountLeft>0){
            if(poolindex[_tokenSymbol] == 0) { pushOrder(userAddress, _tokenSymbol, _amount, _duration, _yield, _status);  break; }
            Order memory iOrder = openOrderMap[orderpool[_tokenSymbol][index]];
            if((_status && _yield>iOrder.yield) || (!_status && _yield<iOrder.yield) || (_status)?(orderStatus[orderpool[_tokenSymbol][index]] == Status.OPENCREATOR):(orderStatus[orderpool[_tokenSymbol][index]] == Status.OPENBORROW)){
                pushOrder(userAddress, _tokenSymbol, _amount, _duration, _yield, _status);
                break;
            } else   {
                uint tduration = _duration > iOrder.duration ? iOrder.duration : _duration;
                uint tyield = _yield > iOrder.yield ? iOrder.yield : _yield;
                uint64 tID = orderpool[_tokenSymbol][index];
                if(iOrder.amount>=amountLeft) { 
                    if(iOrder.amount != amountLeft) {
                        pushOrder(iOrder.creator, _tokenSymbol, iOrder.amount-amountLeft, iOrder.duration, iOrder.yield, !_status);     }
                    matchOrder(userAddress, _tokenSymbol, amountLeft, tduration, tyield, tID, _status);
                    amountLeft=0;
                } else {
                    pushOrder(userAddress, _tokenSymbol, amountLeft- iOrder.amount, _duration, _yield, _status);
                    matchOrder(userAddress, _tokenSymbol, amountLeft, tduration, tyield, tID , _status);
                    amountLeft -= openOrderMap[orderpool[_tokenSymbol][index]].amount;    }
            }
        }
    }
    
    function orderExpired  (uint64 _orderId) external {
        require(Init.friendlyaddress(msg.sender),"Not Friendly Address");
        require (matchOrderMap[_orderId].expiryDate <= now);
        EMM.releaseWrappedToken(matchOrderMap[_orderId].supplier,matchOrderMap[_orderId].amount, matchOrderMap[_orderId].wtoken);    
        users[matchOrderMap[_orderId].supplier].totalDeposit -= matchOrderMap[_orderId].usdvalue;
        users[matchOrderMap[_orderId].borrower].totalBorrowed -= matchOrderMap[_orderId].usdvalue;
        orderStatus[_orderId] = Status.CLOSED;
        delete matchOrderMap[_orderId];
        delete users[matchOrderMap[_orderId].supplier].myOrders[_orderId];
        delete users[matchOrderMap[_orderId].borrower].myOrders[_orderId];
        //Init.OrderExpired(_orderId,msgSender,orderMonthlyDue(_orderId,msgSender,_duration));
    } 

    function payDue(uint64 _orderId,uint _duration,address msgSender) external returns (uint due){
        due = orderMonthlyDue(_orderId,_duration);
        uint fee = (due*Init.rewardFee())/100;
        EMM.burnECOFrom(msgSender,due+fee);
        Init.setOwnerFeeVault(Init.WRAP_ECO_SYMBOL(), fee);
        matchOrderMap[_orderId].duesPaid += 1;
        matchOrderMap[_orderId].duesPaid >= matchOrderMap[_orderId].duration  ? Init.setUserLocked(msgSender,false) :  Init.setUserLocked(msgSender,true);
        Init.emitDuePaid(_orderId,msgSender,orderMonthlyDue(_orderId,_duration));
    }

    function dueCheck(uint64 _orderId,address borrower,uint month) external returns(uint) {
        require (Init.friendlyaddress(msg.sender) && now >= matchOrderMap[_orderId].time + matchOrderMap[_orderId].duesPaid * 30 days);
        if(matchOrderMap[_orderId].duesPaid < month && !Init.isRegistrar(borrower) && !Init.isUserLocked(borrower)){
            uint due = orderMonthlyDue(_orderId,1);
            matchOrderMap[_orderId].duesPaid >= matchOrderMap[_orderId].duration  ? Init.setUserLocked(borrower,false) :  Init.setUserLocked(borrower,true);
            EMM.mintECO(matchOrderMap[_orderId].supplier,due*(100-Init.rewardFee())/100);
            Init.emitDuePaid(_orderId,borrower,orderMonthlyDue(_orderId,1));
        }
        if(matchOrderMap[_orderId].duesPaid >= matchOrderMap[_orderId].duration){
            scheduleCheck(_orderId,borrower,1);
        }
    }

    function scheduleExpiry(uint64 _orderId) internal{
        uint time = matchOrderMap[_orderId].expiryDate - matchOrderMap[_orderId].time;
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256('orderExpired(uint256)')),_orderId);
        uint callCost = 300000*1e9 + abacus.callFee();
        abacus.scheduleFunc{value:callCost}(address(this), time ,data , abacus.callFee() ,300000 , 1e9 );
    }    
    
    function scheduleCheck(uint _orderId,address borrower,uint month) internal{
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256('dueCheck(uint256,address,uint256)')),_orderId,borrower,month);
        uint callCost = 300000*1e9 + abacus.callFee();
        abacus.scheduleFunc{value:callCost}(address(this), 30 days ,data , abacus.callFee() ,300000 , 1e9 );
    } 
    
    function cancelOrder(uint64 _orderId) external{
        require(Init.friendlyaddress(msg.sender));
        if(orderStatus[_orderId]==Status.OPENCREATOR) {
            EMM.releaseWrappedToken(openOrderMap[_orderId].creator,openOrderMap[_orderId].amount, openOrderMap[_orderId].wtoken);
            delete users[openOrderMap[_orderId].creator].borrowedOrders[_orderId];  
        }   else {
            delete users[openOrderMap[_orderId].creator].createdOrders[_orderId];   
        }
        poolSorter(_orderId, openOrderMap[_orderId].wtoken,false);
        delete openOrderMap[_orderId];
        orderStatus[_orderId] = Status.CLOSED;
    }
    
     /*==============Helpers============
    ---------------------------------*/   
    
    function USDValue(uint amount, string memory _token) internal view returns (uint usdvalue) {
        usdvalue = amount*fetchTokenPrice(_token)/(10**8);
    }
    
    function orderMonthlyDue(uint64 _orderId, uint _duration) public view returns(uint due){
        orderStatus[_orderId] == Status.MATCHED ?  due = USDValue (matchOrderMap[_orderId].amount, matchOrderMap[_orderId].wtoken) * matchOrderMap[_orderId].yield * _duration*30 days*fetchTokenPrice(Init.WRAP_ECO_SYMBOL())/ 3155695200 : due = 0;
    }
    
    function fetchTokenPrice(string memory _tokenSymbol) public view returns(uint64){ //Put any Token Wrapped or Direct
            return abacus.getJobResponse(EMM.getFetchId(_tokenSymbol))[0];
    }
    
    /*function issueReward(address userAddress, string memory _tokenSymbol, uint time, uint tokenUsdValue) internal {
        uint reward = calculateECOEarning(tokenUsdValue, _tokenSymbol, time);
        EMM.mintECO(userAddress, reward);
    }*/
    
    function calculateECOEarning(uint usdvalue, string memory _tokenSymbol, uint time) private view returns (uint){
        uint _amount = usdvalue*fetchTokenPrice(Init.WRAP_ECO_SYMBOL())/(10**8);
        uint reward = (_amount * Init.slabRateDeposit(_tokenSymbol) * (time - now))/3155695200; //decimal from Abacus is setoff by decimal from Eco
        return reward;
    }
    
    function getECOEarnings(address userAddress) public view returns (uint){
        uint ecobalance;
        for(uint i=0; i<users[userAddress].myDeposits.length || i<users[userAddress].myBorrows.length; i++) {
            ecobalance += calculateECOEarning(users[userAddress].myDeposits[i].usdvalue, users[userAddress].myDeposits[i].wtoken, users[userAddress].myDeposits[i].time);
            ecobalance -= calculateECOEarning(users[userAddress].myBorrows[i].usdvalue, users[userAddress].myBorrows[i].wtoken, users[userAddress].myBorrows[i].time);
        }
        return ecobalance - EMM.ecoWithdrawls(userAddress);
    }
    
    function _ordersub(uint amount,address userAddress,uint _duration,string memory _tokenSymbol) internal view returns (uint64, uint, uint){
        uint newAmount = amount - (amount*Init.tradeFee())/100;
        uint fee = (amount*Init.tradeFee())/100;
        uint64 _orderId = uint64(uint(keccak256(abi.encodePacked(userAddress,_tokenSymbol,_duration,now))));
        return (_orderId,newAmount,fee);
    }
    
    function getUserDepositsbyToken(address userAddress, string memory wtoken) public view returns(uint) {
        return users[userAddress].deposits[wtoken];
    }
    
    function getUserBorrowedOrderbyToken(address userAddress, string memory wtoken) public view returns(uint) {
        return users[userAddress].borrows[wtoken];
    }
    
    function getUserBorrowedOrder(address userAddress) public view returns (uint64 [] memory) {
        return users[userAddress].borrowedOrders;
    }
    
    function getUserDepositOrder(address userAddress) public view returns (uint64 [] memory) {
        return users[userAddress].createdOrders;
    }
    
    function getUserMatchOrder(address userAddress) public view returns (uint64 [] memory) {
        return users[userAddress].myOrders;
    }
    
    function getbuyPower(address userAddress) public view returns (uint){
        if(!Init.isRegistrar(userAddress)) { return (10**30);   }
        if(Init.isUserLocked(userAddress)) { return 0; }
        uint buyPower;
        buyPower += users[userAddress].totalDeposit - ((users[userAddress].totalDeposit*Init.CDSpercent())/100);
        buyPower -= users[userAddress].totalBorrowed;
        return buyPower;
    }
    
    function getOrderIds(string memory wtoken) public view returns (uint64 [] memory orderIds) {
        return orderpool[wtoken];
    }
}

contract Ecocelium is Initializable{

    address public owner;
    address payable EMMAddress;
    IAbacusOracle abacus;
    EcoMoneyManager EMM;
    EcoceliumDataManager EDM;
    EcoceliumInit Init;
    
    function initialize(address _owner,address payable EMMaddress,address payable AbacusAddress,address EDMaddress, address payable Initaddress)public payable initializer {
        owner = _owner;
        EMM = EcoMoneyManager(EMMaddress);
        EMMAddress = EMMaddress;
        abacus = IAbacusOracle(AbacusAddress);//0x323f81D9F57d2c3d5555b14d90651aCDc03F9d52
        EDM = EcoceliumDataManager(EDMaddress);
        Init = EcoceliumInit(Initaddress);
    }
    
    function changeOwner(address _owner) public{
        require(msg.sender==owner);
        owner = _owner;
    }
    
    function updateContracts() public{
        require(msg.sender==owner);
        EMM = EcoMoneyManager(Init.MONEYMANAGER());
        abacus = IAbacusOracle(Init.ABACUS());
        EDM = EcoceliumDataManager(Init.DATAMANAGER());
    }
    
     /*===========Main functions============
    -------------------------------------*/   

    function Deposit(string memory rtoken, uint _amount) external payable {
        address _msgSender = msg.sender;
        string memory wtoken = EMM.getWrapped(rtoken);
        _deposit(rtoken, _amount, _msgSender, wtoken);
        EDM.freePusher(_msgSender, wtoken, _amount, true);
        EMM.mintWrappedToken(_msgSender, _amount, wtoken);
        EMM.lockWrappedToken(_msgSender, _amount,wtoken);
    }
    
    function _deposit(string memory rtoken,uint _amount, address msgSender, string memory wtoken) internal {
        require(EMM.getwTokenAddress(wtoken) != address(0),"not supported");
        if(keccak256(abi.encodePacked(rtoken)) == keccak256(abi.encodePacked(Init.ETH_SYMBOL()))) { 
            require(msg.value >= _amount);
            EMM.DepositManager{value:msg.value}(rtoken, _amount, msgSender);
        }else {
        EMM.DepositManager(rtoken, _amount, msgSender); }
        Init.emitSwap(msgSender,rtoken,wtoken,_amount);
    }
    
    function depositAndOrder(address userAddress,string memory rtoken ,uint _amount,uint _duration,uint _yield) external payable {
        require(msg.sender == userAddress);
        _deposit(rtoken, _amount, userAddress, EMM.getWrapped(rtoken));
        EDM.newOrder(userAddress, EMM.getWrapped(rtoken), _amount, _duration, _yield, true);
    }
    
    function createOrder(address userAddress,string memory _tokenSymbol ,uint _amount,uint _duration,uint _yield) external payable {
        require(msg.sender == userAddress);
        string memory wtoken = EMM.getWrapped(_tokenSymbol);
        require(EDM.getUserDepositsbyToken(userAddress, wtoken) >= _amount, "Insufficient Balance"); 
        uint ecoEarnings = EDM.freePopper(userAddress, wtoken , _amount, true);
        EMM.mintECO(userAddress,ecoEarnings);
        EDM.newOrder(userAddress, wtoken, _amount, _duration, _yield, true); 
    }
    
    function getAggEcoBalance(address userAddress) public view returns(uint) {
        return wERC20(EMM.getwTokenAddress(Init.WRAP_ECO_SYMBOL())).balanceOf(userAddress) + EDM.getECOEarnings(userAddress);
    }
    
    function borrowOrder(address userAddress, string memory rtoken, uint amount, uint duration, uint yield) public {//Rewrite this part
        require(isWithdrawEligible(userAddress, rtoken, amount));
        EDM.newOrder(msg.sender,rtoken, amount,duration,yield,false);
    }
    
    function payDueOrder(uint64 _orderId,uint _duration) external {
        EDM.payDue(_orderId,_duration,msg.sender);
    }
    
    function clearBorrow(string memory rtoken, uint _amount) external payable{
        address msgSender = msg.sender;
        string memory wtoken = EMM.getWrapped(rtoken);
        uint dues = EDM.freePopper(msgSender, wtoken, _amount, false);
        if(keccak256(abi.encodePacked(rtoken)) == keccak256(abi.encodePacked(Init.ETH_SYMBOL()))) { 
            require(msg.value == _amount);
            EMM.DepositManager{value:_amount}(rtoken, _amount, msgSender);
        }else {
        EMM.DepositManager(rtoken, dues, msgSender);    }
    }
    
    function Borrow(address payable userAddress, uint _amount, string memory _tokenSymbol) public {
        require(userAddress == msg.sender);
        require(isWithdrawEligible(userAddress, _tokenSymbol, _amount));
        EDM.freePusher(msg.sender, EMM.getWrapped(_tokenSymbol), _amount,false);
        EMM.WithdrawManager(_tokenSymbol, _amount, userAddress);
    }
    
    function SwapWrapToWrap(string memory token1,string memory token2, uint token1amount)  external returns(uint) {
        address msgSender = msg.sender;
        (uint token1price,uint token2price) = (fetchTokenPrice(token1),fetchTokenPrice(token2));
        uint token2amount = (token1amount*token1price*(100-Init.swapFee()))/token2price/100;
        EMM.w2wswap(msgSender, token1, token1amount, token2amount, token2);
        EDM.freePopper(msgSender,token1,token1amount,true);
        Init.setOwnerFeeVault(token1, token1price*Init.swapFee()/100);
        EDM.freePusher(msgSender, token2,token2amount,true);
        Init.emitSwap(msgSender,token1,token2,token2amount);
        return token2amount;
    }
    
    function cancelOrder(uint64 _orderId) public{
        (address creator,,,,) = EDM.openOrderMap(_orderId);
        require(msg.sender==creator);
        EDM.cancelOrder(_orderId);
    }
    
    receive() external payable {  }

    /*==============Helpers============
    ---------------------------------*/    
    
    function orderMonthlyDue(uint64 _orderId,uint _duration) public view returns(uint){
        return EDM.orderMonthlyDue(_orderId,_duration);
    }
    
    function updateFees(uint _swapFee,uint _tradeFee,uint _rewardFee) public{
        require(msg.sender == owner);
        Init.updateFees(_swapFee,_tradeFee,_rewardFee);
    }
    
    function getOrderIds(string memory wtoken) public view returns(uint64 [] memory){
        return EDM.getOrderIds(wtoken);
    }
    
    function fetchTokenPrice(string memory _tokenSymbol) public view returns(uint64){
        return EDM.fetchTokenPrice(_tokenSymbol);
    }
    
    function Withdraw(string memory to, uint _amount) external payable{
        address payable msgSender = msg.sender;
        string memory from = EMM.getWrapped(to);
        require(EMM.getwTokenAddress(from) != address(0),"not supported");
        require(!Init.isUserLocked(msgSender), "Your Address is Locked Pay Dues");
        require(isWithdrawEligible(msgSender, to, _amount) , "Not Eligible for Withdraw");
        wERC20 wToken = wERC20(EMM.getwTokenAddress(to));
        uint amountLeft;
        uint availableBalance = wToken.balanceOf(msgSender) - EDM.getUserDepositsbyToken(msgSender, from) - EDM.getUserBorrowedOrderbyToken(msgSender, from);
        if(keccak256(abi.encodePacked(to)) == keccak256(abi.encodePacked(Init.ECO()))) {
            require( wToken.balanceOf(msgSender) + EDM.getECOEarnings(msgSender) >= _amount,"Insufficient Balance");
            if(availableBalance >= _amount) {
                EMM.WithdrawManager(to,_amount, msgSender);
            } else {
                if(wToken.balanceOf(msgSender) >=_amount)   { 
                _withdraw(msgSender, from, _amount, to);        }  else {
                amountLeft =  _amount - wToken.balanceOf(msgSender);
                _withdraw(msgSender, from, wToken.balanceOf(msgSender), to);
                EMM.redeemEcoEarning(msgSender,amountLeft); }
            }
        }
        else  {  require(wToken.balanceOf(msgSender)>=_amount,"Insufficient balance");
                _withdraw(msgSender, from, wToken.balanceOf(msgSender), to);
        }
        Init.emitSwap(msgSender,from,to,_amount);
    }
    
    function _withdraw(address payable msgSender, string memory from, uint amount, string memory to) internal {
        EMM.releaseWrappedToken(msgSender,amount, from);
        EMM.burnWrappedFrom(msgSender, amount, from);
        Init.setOwnerFeeVault(to,(amount*Init.swapFee())/100);
        EDM.freePopper(msgSender,from,amount, true);
        uint newAmount = amount - (amount*Init.swapFee())/100;
        EMM.WithdrawManager(to,newAmount, msgSender);
    }
    
    function isWithdrawEligible(address userAddress, string memory to, uint amount) internal view returns (bool Eligible){
        return (EDM.getbuyPower(userAddress)*(Init.CDSpercent())/100) > (amount*fetchTokenPrice(to)/(10**8));
    }    
}

    

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }


    
  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
    
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


contract ERC20Basic {
    uint public _totalSupply;
    string public name;
    string public symbol;
    uint public decimals;
    function totalSupply() public view  returns (uint){}
    function balanceOf(address who) public view returns (uint){}
    function transfer(address to, uint value) public {}
    function transferFrom(address _from, address _to, uint _value) public{}
    function approve(address spender, uint amount) public {}
    function allowance(address _owner, address _spender) public view returns (uint remaining) {}
    
    event Transfer(address indexed from, address indexed to, uint value);
}


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => uint256) public  lockedAmount;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol,uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function availableAmount(address owner) public view returns(uint256){
        return balanceOf(owner).sub(lockedAmount[owner]);
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= availableAmount(sender),"ERC20 : amount exceeds available amount");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount <= availableAmount(account),"ERC20 : burn exceeds available amount");
        
        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(amount <= availableAmount(owner),"ERC20 : approve amount exceeds available amount");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _lock(address owner,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: lock for zero address");
        require(amount <= availableAmount(owner),"ERC20: lock value more tha available amount");
        
        lockedAmount[owner] = lockedAmount[owner].add(amount);
    }
    function _release(address owner,uint256 amount) internal virtual{
        require(owner != address(0), "ERC20: release for zero address");
        require(amount <= lockedAmount[owner],"ERC20 : release value more then locked value");
        
        lockedAmount[owner] = lockedAmount[owner].sub(amount);
    }
    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}


contract wERC20 is Context, AccessControl, ERC20, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ETMOWNER_ROLE = keccak256("ETM_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor(string memory name, string memory symbol,uint8 decimals,address admin,address etmOwner) public ERC20(name, symbol,decimals) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(ETMOWNER_ROLE, etmOwner);
        _setupRole(MINTER_ROLE, admin);
        _setupRole(PAUSER_ROLE, admin);
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }
    
    function burnFrom(address _from,uint256 amount) public virtual{
     require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have admin role to burn");
     _burn(_from,amount);
    }
    
    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }
    function changeAdmin(address admin) public virtual{
        require(hasRole(ETMOWNER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have admin role");
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MINTER_ROLE, admin);
        _setupRole(PAUSER_ROLE, admin);        
    }
    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }
    
    function lock(address account , uint256 amount) public virtual{
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have admin role to lock");
        _lock(account,amount);
    }
    
    function release(address account , uint256 amount) public virtual{
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have admin role to release");
        _release(account,amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}



