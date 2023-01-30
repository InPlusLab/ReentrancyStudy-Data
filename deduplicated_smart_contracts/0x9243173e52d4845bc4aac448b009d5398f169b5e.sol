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

// �ڳ�Ĺ������£�
// һ��	Token��ʼ����Ϊ1650��������۵�Token���ﵽ80%���ڳ￪ʼʱ��Ϊ��Լ�����󣨹�����2019��9��1�գ�������ʱ��Ϊ2019��12��31��24�㣬�����ĸ��¡�
// ����	��ʼToken����̫�ҵı�ֵΪ300:1,�����½�0.1%������2019��11��1��ǰ�û�Ͷ�����̫�Ұ���1.1��ϵ����ó���Token����2019��11��1��ǰ�û����������˻��Լ�Ͷ���ڳ����̫�ң���2019��11��1�պ��û������˻��Լ�Ͷ���ڳ����̫�ҡ�
// ����	������Ϊ�ڳ�ʧ��ʱ������ֹ�ڳ���˻�ȫ�������ߵ���̫�ҡ�ԭ�����ڳ����̫����������������ڳ��ʽ������������Ԫ�������߻��������ش�ԭ���ܼ������Ϳ�����Ϊ�ڳ�ʧ�ܡ�
// �ġ�	��2019��12��31��ǰ������ֹ�ڳ����2019��11��1�պ�2019��12��31��֮���ڳ����̫�������ˣ�Token���չ��򷢷���ϣ������Զ������ڳ
// �塢	�ƻ�����������Ŀ���ߺ󣬳���Token���û�����ȡ��Щ��Ŀ����������ԭ������Щ����������ܺ�Լ�Զ����䣬�򲻵��ѵ�ʱ��Ų����˹����䡣
// ����	����ڳ�ɹ�����2020��1��7�պ�Token�������ɽ��ס�
// �ߡ�	Tokenÿ��ͨ�ͣ���һ��ͨ����3%��ͨ�������꽵��10%��ͨ�͵�Token��Ŀǰ����ĿͶ���˳��С�
// �ˡ�	���Token�����˳���20��û��ת�ˡ�����ֺ죬�Ȳ����������˺ű���Ϊ20���Ĭ�˺ţ�ӵ���ߣ�Owner�����԰Ѵ��˺ŵ�Token����̫���ᵽ�Լ��ʺš�


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
        require(crowdFinishTime < now);         //�ڳ������
        require(!isTerminated);                 //û����ֹ�ڳ�
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

    uint constant public crowdMaxEther = 40000 * (10 ** 18);    //�ڳ������̫�������������

    uint public crowdedEther = 0;                               //�Ѿ��ڳ����̫������

    //  uint constant public crowdStartTime  = 1561910400;          //2019��7��1��, �ڳ￪ʼʱ��           //����Ҫ�����ʼʱ�䣡

    uint constant public crowdBackTime   = 1572537600;          //2019��11��1�գ��ڳ�����˿����ʱ��    //TODO

    uint constant public crowdFinishTime = 1577808000;          //2020��1��1�գ��ڳ����ʱ��            //TODO
    
    uint constant public iniTokenPerEth = 300;                  //Token���ڳ�۸񣬳�ʼ��һ��eth��300����Ȼ��Խ��Խ�٣��껯����30%��ÿ����� 0.1%����������20%

    uint constant public tokenReduce1000 = 1;                   //Token���ڳ�۸�ÿ����� 0.1%����������20%

    uint constant public backMultiple100 = 110;                 //�ڿ����˿�ǰ�ı�����1.1��

    bool public isTerminated = false;                           //�Ƿ��˹���ֹ
   
    event OnTerminate(address _exeUser, uint _eventId);

    function terminate() external onlyOwner
    {
        require(now < crowdFinishTime);
        require(!isTerminated);
        isTerminated = true;
        emit OnTerminate(msg.sender, getEventId());
    }

    mapping (address => uint256) public userInvEtherOf;         //�û����ڹ���Token�Ŀ��� �� �� crowdBackTime ֮ǰ����Ҫ��¼Ͷ���ether����Ϊ�����˻���

    function getPrice() public view returns(uint _result)       //һ����̫��������ٸ�Token
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
        _result = (!isTerminated) && (crowdFinishTime.add(7 days) < now);       //�ڳ������������ת�ˣ�
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


interface IWithholdToken{                                                   //���ۣ�����ʡ�� approve �ⲽ����
    function withhold(address _user,  uint256 _amount) external returns (bool _result);
    function setTransferFlag(address _address, bool _canTransfer) external  returns (bool _result);
}

contract WithholdToken is TokenERC20, IWithholdToken{                       //���ۣ���Ҫ��ʡ�� approve �ⲽ����
    mapping (address => mapping(address => bool)) public transferFlagOf;    //user->game->flag    2018-07-10 Ĭ�ϲ����������Լ���������ȥ��
 
    function setTransferFlag(address _address, bool _canTransfer) external  returns (bool _result){    //�����Լ��Ƿ��������
        require(_address != address(0x0));
        transferFlagOf[msg.sender][_address] = _canTransfer;
        _result = true;
    }

    mapping(address => bool) public whiteListOf;                            //���ۺ�Լ�������б�

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

    function isWhiteList(address _addr) public view returns(bool _result) {                         //���������
        require (_addr != address(0x0));
        _result = whiteListOf[_addr];
    }

    function canWithhold(address _address,  address _user) public view returns(bool _result) {      //�ܷ����
        require (_user != address(0x0));
        require (_address != address(0x0));
        _result = isWhiteList(_address) && transferFlagOf[_user][_address];    
    }

    //���ۣ�����ҵ�Ǯ������Ϸ�˺� ������Ҫtoken��������Ȩ����Ϸ���������ı�ĳaddress��token������balanceOf��,��������game,�ӿں���
    function withhold(address _user,  uint256 _amount) external returns (bool _result) {
        require(_user != address(0x0));
        require(_amount > 0);
        require(msg.sender != tx.origin);                   //ֻ�����ܺ�Լ�ſ���ִ��
        require(msg.sender != _user);                       //�����Լ�ת���Լ�
        // require(isWhiteList(msg.sender));
        // require(transferFlagOf[_user][msg.sender]);         
        require(canWithhold(msg.sender, _user));            //��ͬ�������仰���жϴ���Ȩ��
        require(balanceOf[_user] >= _amount);

        _transfer(_user, msg.sender, _amount);
        return true;
    }

}


interface IDividendToken{
    function profit() payable external returns(bool _result);   //ִ�зֺ죬��ӯ����Լ���ô˷���
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

    mapping (uint => DividendPeriod) public dividendPeriodOf;   //�ֺ��¼
    uint256 public currentDividendPeriodNo = 0;

    // uint256 public shareAddEtherValue = 0;
    // uint256 public addTotalEtherValue = 0;

    uint public lastDividendBlock = block.number;

    mapping (address => uint) public balanceBlockOf;            //User����ֺ��¼

    uint256 public minDividendEtherAmount = 10 ether;           //��С�ֺ���
    function setMinDividendEtherAmount(uint256 _newMinDividendEtherAmount) public onlyOwner{
        minDividendEtherAmount = _newMinDividendEtherAmount;
    }

    function callDividend() public returns (uint256 _etherAmount) {             //����ֺ�
        _callDividend(msg.sender);
        _etherAmount = userEtherOf[msg.sender];        
    }

    event OnCallDividend(address indexed _user, uint256 _tokenAmount, uint _lastCalBlock, uint _currentBlock, uint _etherAmount, uint _eventId);

    function _callDividend(address _user) internal returns (bool _result) {     //����ֺ�
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
            if(lastBlock < dp.EndBlock){                            //��������������
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

    uint public divIntervalBlocks = 6400;   //�ֺ��ʱ����,6400����������1�졣�����޸�

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

        uint256 sa = canValue.div(totalSupply);             //���̫С�ˣ������� ether 10**18 token 10**6  decimals ���н����ģ�
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

    mapping(uint => uint256) yearTotalSupplyOf;     //ÿ���Token��¼
    uint yearInflation1000000 = 30000;              //��ʾ3%��

    function addYearToken() external {              //ͨ�ͣ���ʼֵ��3��ÿ��ݼ�10%��Ҳ���ǵڶ������3*0.9�ˡ���ſ�����ȡ100�ꡣ
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

//OK: �ѹ�ظ��ˣ������㶨����߳���80%������5�����̫�����趨��������ֵԼΪһǧ��������𣩣�����4�����̫��(Լһǧ����������)��
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
        totalSupply = 55000 * 300 * (10 ** uint(decimals));     //����һǧ��������owner���ֻ�ܱ���20%����Ϊ��1.1���ġ�
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
        
        userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(CanEtherAmount);     //���������ģ��ڳ��ڼ� Owner ������ң�
        userEtherOf[owner] = userEtherOf[owner].add( CanEtherAmount);              //���������ģ��ڳ��ڼ� Owner ������ң�

        crowdedEther = crowdedEther.add(CanEtherAmount);                           //����

        emit OnBuyToken(msg.sender, CanEtherAmount, CanTokenAmount, getEventId());
    }

    event OnCrowdBack(address _user, uint _etherAmount, uint _tokenAmount, uint eventId);

    function crowdBack() external                       //�˻��ڳ��
    {
        require(now < crowdBackTime || isTerminated);   //���˻��¼�ǰ��������ֹ��

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