/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.5.8;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
        return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

// 众筹的规则如下：
// 一、	Token初始总量为1650万个，出售的Token最多达到80%。众筹开始时间为合约发布后（估计在2019年9月1日），结束时间为2019年12月31日24点，共计四个月。
// 二、	初始Token和以太币的比值为300:1,逐日下降0.1%。但在2019年11月1日前用户投入的以太币按照1.1倍系数获得超额Token。在2019年11月1日前用户可以主动退还自己投入众筹的以太币；在2019年11月1日后用户不能退还自己投入众筹的以太币。
// 三、	我们认为众筹失败时可以终止众筹，并退还全部参与者的以太币。原则上众筹的以太币少于两万个（或众筹资金少于五百万美元），或者基于其他重大原因不能继续，就可以认为众筹失败。
// 四、	在2019年12月31日前可以终止众筹。如在2019年11月1日和2019年12月31日之间众筹的以太币满额了（Token按照规则发放完毕），则自动结束众筹。
// 五、	计划的区块链项目上线后，持有Token的用户将获取这些项目产生的利润。原则上这些利润采用智能合约自动分配，万不得已的时候才采用人工分配。
// 六、	如果众筹成功，在2020年1月7日后Token可以自由交易。
// 七、	Token每年通胀，第一年通胀率3%，通胀率逐年降低10%，通胀的Token由目前的项目投资人持有。
// 八、	如果Token持有人超过20年没有转账、计算分红，等操作，这种账号被称为20年沉默账号，拥有者（Owner）可以把此账号的Token和以太币提到自己帐号。


contract Base {
    using SafeMath for uint256;

    uint64 public currentEventId = 1;
    function getEventId() internal returns(uint64 _result) {
        _result = currentEventId;
        currentEventId ++;
    }

    uint public createTime = now;
    
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner)  external  onlyOwner {
        require(_newOwner != address(0x0));
        require(crowdFinishTime < now);         //众筹结束后
        require(!isTerminated);                 //没有终止众筹
        owner = _newOwner;
    }
    
    address public boss;

    modifier onlyBoss {
        require(msg.sender == boss);
        _;
    }

    function setBoss(address _newBoss)  external  onlyBoss {
        require(_newBoss != address(0x0));
        owner = _newBoss;
    }

    uint8 public decimals = 6;

    uint constant public crowdMaxEther = 40000 * (10 ** 18);    //众筹最大以太币数量，四万个

    uint public crowdedEther = 0;                               //已经众筹的以太币数量

    //  uint constant public crowdStartTime  = 1561910400;          //2019年7月1日, 众筹开始时间           //不需要这个开始时间！

    uint constant public crowdBackTime   = 1572537600;          //2019年11月1日，众筹可以退款截至时间    //TODO

    uint constant public crowdFinishTime = 1577808000;          //2020年1月1日，众筹结束时间            //TODO
    
    uint constant public iniTokenPerEth = 300;                  //Token的众筹价格，初始是一个eth换300个，然后越来越少，年化减少30%，每天减少 0.1%，半年后减少20%

    uint constant public tokenReduce1000 = 1;                   //Token的众筹价格，每天减少 0.1%，半年后减少20%

    uint constant public backMultiple100 = 110;                 //在可以退款前的倍数，1.1倍

    bool public isTerminated = false;                           //是否人工终止
   
    event OnTerminate(address _exeUser, uint _eventId);

    function terminate() external onlyOwner
    {
        require(now < crowdFinishTime);
        require(!isTerminated);
        isTerminated = true;
        emit OnTerminate(msg.sender, getEventId());
    }

    mapping (address => uint256) public userInvEtherOf;         //用户用于购买Token的开销 。 在 crowdBackTime 之前，需要记录投入的ether，因为可以退还！

    function getPrice() public view returns(uint _result)       //一个以太币能买多少个Token
    {
        uint d = (now - createTime) / (1 days);
        //_result = iniTokenPerEth * (1000 -tokenReduce1000) ** d / 1000**d;
        _result = iniTokenPerEth;
        for(uint i = 0; i < d; i++){
            _result = _result * (1000 - tokenReduce1000) / 1000;
        }

        if(now < crowdBackTime)
        {
            _result = _result * backMultiple100 / 100;
        }
    }


    function canTransfer() public view returns (bool _result)
    {
        //_result = (!isTerminated) && (crowdFinishTime < now);
        _result = (!isTerminated) && (crowdFinishTime.add(7 days) < now);       //众筹结束七天后可以转账！
    }

    function canBuyToken() public view returns (uint _result)
    {
        if (crowdFinishTime <= now)
        {
            _result = 0;
        }
        else if (isTerminated)
        {
            _result = 0;
        }
        else
        {
            _result = (crowdMaxEther - crowdedEther) * getPrice() * (10 ** uint(decimals)) / (10 ** 18);
        }
    }


    event OnDeposit(address indexed _user, uint _amount, uint _balance, uint64 _eventId);
    event OnWithdraw(address indexed _user, uint _amount, uint _balance, uint64 _eventId);

    mapping (address => uint256) public userEtherOf;

    function deposit() payable external {
        _deposit();
    }

    function _deposit() internal {
        userEtherOf[msg.sender] = userEtherOf[msg.sender].add(msg.value);
        emit OnDeposit(msg.sender, msg.value, userEtherOf[msg.sender], getEventId());
    }

    function withdraw(uint _amount) external {
        if(msg.sender == owner)
        {
            //require(crowdBackTime < now);
            require(crowdFinishTime < now);
        }
    
        _withdraw(_amount);
    }

    function _withdraw(uint _amount) internal {
        require(userEtherOf[msg.sender] >= _amount);
        userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(_amount);
        msg.sender.transfer(_amount);
        emit OnWithdraw(msg.sender, _amount, userEtherOf[msg.sender], getEventId());
    }

}

contract TokenERC20 is Base {
    string public name;
    string public symbol;
    // uint8 public decimals = 6;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);

    // constructor(
    //     //uint256 initialSupply,
    //     //string memory tokenName,
    //     //string memory tokenSymbol
    // ) public {
    //     totalSupply = 1000000000 * 10 ** uint256(decimals);  // Update total supply with the decimal amount
    //     //balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
    //     balanceOf[address(this)] = totalSupply;                // Give the creator all initial tokens
    //     name = "";                                   // Set the name for display purposes
    //     symbol = "";                               // Set the symbol for display purposes
    // }


    function _callDividend(address _user) internal returns (bool _result);      

    function _transfer(address _from, address _to, uint _value) internal returns (bool success) {
        require(_from != address(0x0));
        require(_to != address( 0x0));
        require(_from != _to);
        require(_value > 0);
        require(balanceOf[_from] >= _value);
        
        require(canTransfer());                         //new add
        _callDividend(_from);   
        _callDividend(_to);     

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_transfer(msg.sender, _to, _value));
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        require(_transfer(_from, _to, _value));
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) 
    {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(1 == 2);
        
        // require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        // require(_value <= allowance[_from][msg.sender]);    // Check allowance
        // balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        // allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        // totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return false;
    }
}


interface IWithholdToken{                                                   //代扣，可以省略 approve 这步操作
    function withhold(address _user,  uint256 _amount) external returns (bool _result);
    function setTransferFlag(address _address, bool _canTransfer) external  returns (bool _result);
}

contract WithholdToken is TokenERC20, IWithholdToken{                       //代扣，主要是省略 approve 这步操作
    mapping (address => mapping(address => bool)) public transferFlagOf;    //user->game->flag    2018-07-10 默认不允许，必需自己主动加上去！
 
    function setTransferFlag(address _address, bool _canTransfer) external  returns (bool _result){    //设置自己是否允许代扣
        require(_address != address(0x0));
        transferFlagOf[msg.sender][_address] = _canTransfer;
        _result = true;
    }

    mapping(address => bool) public whiteListOf;                            //代扣合约白名单列表

    event OnWhiteListChange(address indexed _addr, address _operator, bool _result,  uint _eventId);

    function addWhiteList(address _addr) public onlyOwner {
        require (_addr != address(0x0));
        whiteListOf[_addr] = true;
        emit OnWhiteListChange(_addr, msg.sender, true, getEventId());
    }

    function delWhiteList(address _addr) public onlyOwner {
        require (_addr != address(0x0));
        whiteListOf[_addr] = false;
        emit OnWhiteListChange(_addr, msg.sender, false, getEventId());
    }

    function isWhiteList(address _addr) public view returns(bool _result) {                         //白名单检查
        require (_addr != address(0x0));
        _result = whiteListOf[_addr];
    }

    function canWithhold(address _address,  address _user) public view returns(bool _result) {      //能否代扣
        require (_user != address(0x0));
        require (_address != address(0x0));
        _result = isWhiteList(_address) && transferFlagOf[_user][_address];    
    }

    //代扣，把玩家的钱打入游戏账号 这里需要token的特殊授权：游戏白名单，改变某address的token数量（balanceOf）,调用者是game,接口函数
    function withhold(address _user,  uint256 _amount) external returns (bool _result) {
        require(_user != address(0x0));
        require(_amount > 0);
        require(msg.sender != tx.origin);                   //只能智能合约才可以执行
        require(msg.sender != _user);                       //不能自己转给自己
        // require(isWhiteList(msg.sender));
        // require(transferFlagOf[_user][msg.sender]);         
        require(canWithhold(msg.sender, _user));            //等同上面两句话，判断代扣权限
        require(balanceOf[_user] >= _amount);

        _transfer(_user, msg.sender, _amount);
        return true;
    }

}


interface IDividendToken{
    function profit() payable external returns(bool _result);   //执行分红，由盈利合约调用此方法
}

contract DividendToken is WithholdToken, IDividendToken
{    
    struct DividendPeriod
    {
        uint StartBlock;
        uint EndBlock;
        uint256 TotalEtherAmount;
        uint256 ShareEtherAmount;
    }

    mapping (uint => DividendPeriod) public dividendPeriodOf;   //分红记录
    uint256 public currentDividendPeriodNo = 0;

    // uint256 public shareAddEtherValue = 0;
    // uint256 public addTotalEtherValue = 0;

    uint public lastDividendBlock = block.number;

    mapping (address => uint) public balanceBlockOf;            //User计算分红记录

    uint256 public minDividendEtherAmount = 10 ether;           //最小分红金额
    function setMinDividendEtherAmount(uint256 _newMinDividendEtherAmount) public onlyOwner{
        minDividendEtherAmount = _newMinDividendEtherAmount;
    }

    function callDividend() public returns (uint256 _etherAmount) {             //计算分红
        _callDividend(msg.sender);
        _etherAmount = userEtherOf[msg.sender];        
    }

    event OnCallDividend(address indexed _user, uint256 _tokenAmount, uint _lastCalBlock, uint _currentBlock, uint _etherAmount, uint _eventId);

    function _callDividend(address _user) internal returns (bool _result) {     //计算分红
        uint _amount = 0;
        uint lastBlock = balanceBlockOf[_user];
        uint256 tokenNumber = balanceOf[_user];
        if(tokenNumber <= 0)
        {
            balanceBlockOf[_user] = block.number;
            _result = false;
            return _result;
        }
        if(currentDividendPeriodNo == 0){ 
        	_result = false;
            return _result;
        }
        for(uint256 i = currentDividendPeriodNo - 1; i >= 0; i--){
            DividendPeriod memory dp = dividendPeriodOf[i];
            if(lastBlock < dp.EndBlock){                            //不包含结束区块
                _amount = _amount.add(dp.ShareEtherAmount.mul(tokenNumber));
            }
            else if (lastBlock >= dp.EndBlock){
                break;
            }
        }
        balanceBlockOf[_user] = block.number;
        if(_amount > 0){
            userEtherOf[_user] = userEtherOf[_user].add(_amount);
        }

        emit OnCallDividend(_user, tokenNumber, lastBlock,  block.number,  _amount, getEventId());
        _result = true;
    }

    function saveDividendPeriod(uint256 _ShareEtherAmount, uint256 _TotalEtherAmount) internal {
        DividendPeriod storage dp = dividendPeriodOf[currentDividendPeriodNo];
        dp.ShareEtherAmount = _ShareEtherAmount;
        dp.TotalEtherAmount = _TotalEtherAmount;
        dp.EndBlock = block.number;
        dividendPeriodOf[currentDividendPeriodNo] = dp;
    }

    function newDividendPeriod(uint _StartBlock) internal {
        DividendPeriod storage lastD = dividendPeriodOf[currentDividendPeriodNo];
        require(lastD.StartBlock < _StartBlock);

        DividendPeriod memory newdp = DividendPeriod({
                StartBlock :  _StartBlock,
                EndBlock : 0,
                TotalEtherAmount : 0,
                ShareEtherAmount : 0
        });

        currentDividendPeriodNo++;
        dividendPeriodOf[currentDividendPeriodNo] = newdp;
    }

    function callDividendAndWithdraw() public {   
        callDividend();
        _withdraw(userEtherOf[msg.sender]);
    }
    
    // function getProfit(address _profitOrg) public {     
    //     lock();
    //     IProfitOrg pt = IProfitOrg(_profitOrg);
    //     address sh = pt.shareholder();
    //     if(sh == address(this))     
    //     {
    //         pt.userRefund();       
    //     }
    //     unLock();
    // }

    event OnProfit(address _profitOrg, uint256 _sendAmount, uint256 _divAmount, uint256 _shareAmount, uint _eventId);

    uint public divIntervalBlocks = 6400;   //分红的时间间隔,6400个区块大概是1天。可以修改

    function  setDivIntervalBlocks(uint _Blocks) public onlyOwner {
        require(_Blocks > 0);           //for test
        divIntervalBlocks = _Blocks;
    }

    function profit() payable external  returns(bool _result)
    {
        require(crowdFinishTime < now);
        if (msg.value > 0){
            userEtherOf[address(this)] += msg.value;
        }

        uint256 canValue = userEtherOf[address(this)];
        if(canValue < minDividendEtherAmount || block.number  < divIntervalBlocks +  lastDividendBlock)   
        {
            emit OnProfit(msg.sender, msg.value, 0, 0,  getEventId());
            return false;
        }

        uint256 sa = canValue.div(totalSupply);             //金额太小了，不够分 ether 10**18 token 10**6  decimals 是有讲究的！
        if(sa <= 0){
            emit OnProfit(msg.sender, msg.value, 0, 0, getEventId());
            return false;
        }

        uint256 totalEtherAmount = sa.mul(totalSupply);
        saveDividendPeriod(sa, totalEtherAmount);
        newDividendPeriod(block.number);
        userEtherOf[address(this)] = userEtherOf[address(this)].sub(totalEtherAmount);
        emit OnProfit(msg.sender, msg.value, totalEtherAmount, sa,  getEventId());
        lastDividendBlock = block.number;
        return true;
    }
    
    event OnAddYearToken(uint256 _lastTotalSupply, uint256 _currentTotalSupply, uint _years, uint _eventId);

    mapping(uint => uint256) yearTotalSupplyOf;     //每年的Token记录
    uint yearInflation1000000 = 30000;              //表示3%。

    function addYearToken() external {              //通胀，初始值是3，每年递减10%，也就是第二年就是3*0.9了。大概可以领取100年。
        uint y = (now - createTime) / (365 days);
        //require(y <= 30);
        require(yearInflation1000000 > 0);
        
        if (y > 0 && yearTotalSupplyOf[y] == 0){
            _callDividend(boss);

            uint256 _lastTotalSupply = totalSupply;

            //totalSupply = totalSupply.mul(10156).div(10000);
            totalSupply = totalSupply.mul(yearInflation1000000 + 1000000).div(1000000);
            yearInflation1000000 = yearInflation1000000 * 9 / 10;

            uint256 _add = totalSupply.sub(_lastTotalSupply);
            balanceOf[boss] = balanceOf[boss].add(_add);
            yearTotalSupplyOf[y] = totalSupply;

            emit OnAddYearToken(_lastTotalSupply, totalSupply, y, getEventId());
        }
    }

    event OnFreeLostToken(address _lostUser, uint256 _tokenNum, uint256 _etherNum, address _to, uint _eventId);

    function freeLostToken(address _user) public onlyOwner {
        require(_user != address( 0x0) );
        uint addTime = 20 * (365 days);   
            
        require(balanceOf[_user] > 0 && createTime.add(addTime) < now  && balanceBlockOf[_user].add(addTime) < now);     
	    require(_user != msg.sender);

        uint256 ba = balanceOf[_user];
        require(ba > 0);
        _callDividend(_user);
        _callDividend(msg.sender);       

        balanceOf[_user] -= ba;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(ba);
      
        uint256 amount = userEtherOf[_user];       
        if (amount > 0){
            userEtherOf[_user] = userEtherOf[_user].sub(amount);
            userEtherOf[msg.sender] = userEtherOf[msg.sender].add(amount);
        }

        emit OnFreeLostToken(_user, ba, amount, msg.sender, getEventId());
    }

}

//OK: 把规矩改了，总量恒定，最高出售80%，按照5万个以太币来设定总量（市值约为一千五百万美金），出售4万个以太坊(约一千二百万美金)。
contract TokenPhiWallet is DividendToken {
    
    //function TokenPhiWallet(address _owner, address _boss) public {
    constructor(address _owner, address _boss) public {
        require(_owner != address(0x0));
        require(_boss != address(0x0));
        owner = _owner;
        boss = _boss;

        name = "PhiWalletToken";
        symbol = "PWT";
        decimals = 6;
        createTime = now;

        // totalSupply = 0;
        totalSupply = 55000 * 300 * (10 ** uint(decimals));     //总量一千五百万个。owner最低只能保留20%，因为有1.1倍的。
        balanceOf[_owner] = totalSupply * 97 / 100;
        balanceOf[_boss] = totalSupply  -  balanceOf[_owner];

        //uint y = (now - createTime) / (365 days);
        uint y = 0;
        yearTotalSupplyOf[y] = totalSupply;
    }

    // event OnBuyToken(address _buyer, uint _etherAmount, uint _tokenAmount, uint _ownerTokenAmount, uint _eventId);
    event OnBuyToken(address _buyer, uint _etherAmount, uint _tokenAmount, uint _eventId);

    function buyToken(uint _tokenAmount) payable external
    {        
        if(msg.value > 0){
            _deposit();
        }

        require(canBuyToken() > 0);

        uint CanEtherAmount = crowdMaxEther - crowdedEther;
        if (CanEtherAmount > userEtherOf[msg.sender])
        {
            CanEtherAmount = userEtherOf[msg.sender];
        }
        require(CanEtherAmount > 0);

        uint price =  getPrice();
        uint CanTokenAmount = CanEtherAmount.mul(price).mul(10 ** uint(decimals)).div(10 ** 18);
        if(CanTokenAmount > _tokenAmount)
        {
            CanTokenAmount = _tokenAmount;
        }

        CanEtherAmount = CanTokenAmount.mul(10 ** 18) / price / (10 ** uint(decimals));      //chong suan   

        userInvEtherOf[msg.sender] = userInvEtherOf[msg.sender] + CanEtherAmount;
        // uint OwnerTokenAmount = CanTokenAmount / 4;                             //owner 20%
        balanceOf[msg.sender] =   balanceOf[msg.sender].add(CanTokenAmount);
        balanceOf[owner] =   balanceOf[owner].sub(CanTokenAmount);
        // balanceOf[owner] =   balanceOf[owner] + OwnerTokenAmount;
        // totalSupply = totalSupply.add(CanTokenAmount).add(OwnerTokenAmount);
        
        userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(CanEtherAmount);     //这个有问题的，众筹期间 Owner 可以提币！
        userEtherOf[owner] = userEtherOf[owner].add( CanEtherAmount);              //这个有问题的，众筹期间 Owner 可以提币！

        crowdedEther = crowdedEther.add(CanEtherAmount);                           //记账

        emit OnBuyToken(msg.sender, CanEtherAmount, CanTokenAmount, getEventId());
    }

    event OnCrowdBack(address _user, uint _etherAmount, uint _tokenAmount, uint eventId);

    function crowdBack() external                       //退回众筹款
    {
        require(now < crowdBackTime || isTerminated);   //在退回事件前，或者终止了

        uint etherAmount = userInvEtherOf[msg.sender];
        uint tokenAmount = balanceOf[msg.sender];

        require(etherAmount > 0 && tokenAmount > 0);
        
        balanceOf[msg.sender] = 0;
        balanceOf[owner] = balanceOf[owner].add(tokenAmount);
        // balanceOf[owner] = balanceOf[owner] .sub (tokenAmount / 4);
        // totalSupply = totalSupply.sub(tokenAmount).sub(tokenAmount / 4);

        userInvEtherOf[msg.sender] = 0;
        userEtherOf[msg.sender] = userEtherOf[msg.sender].add(etherAmount);
        userEtherOf[owner] = userEtherOf[owner].sub(etherAmount);

        emit OnCrowdBack(msg.sender, etherAmount, tokenAmount, getEventId());

        msg.sender.transfer(etherAmount);
    }

    function batchTransfer1(address[] calldata _tos, uint256 _amount) external  {
        require(_batchTransfer1(msg.sender, _tos, _amount));
    }

    function _batchTransfer1(address _from, address[] memory _tos, uint256 _amount) internal returns (bool _result) {
        require(_amount > 0);
        require(_tos.length > 0);
        for(uint i = 0; i < _tos.length; i++){
            address to = _tos[i];
            require(to != address(0x0));
            require(_transfer(_from, to, _amount));
        }
        _result = true;
    }

    function batchTransfer2(address[] calldata _tos, uint256[] calldata _amounts) external  {
        require(_batchTransfer2(msg.sender, _tos, _amounts));
    }

    function _batchTransfer2(address _from, address[] memory _tos, uint256[] memory _amounts) internal returns (bool _result)  {
        require(_amounts.length > 0);
        require(_tos.length > 0);
        require(_amounts.length == _tos.length );
        for(uint i = 0; i < _tos.length; i++){
            require(_tos[i] != address(0x0) && _amounts[i] > 0);
            require(_transfer(_from, _tos[i], _amounts[i]));
        }
        _result = true;
    }


    function() payable external {
        // if(canBuyToken() > 0)
        // {
        //     buyToken(totalSupply);
        // }
        // else 
        if(msg.value > 0){
           _deposit();
       }
    }

}