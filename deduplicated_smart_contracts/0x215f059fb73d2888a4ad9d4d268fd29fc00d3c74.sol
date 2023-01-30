pragma solidity ^0.4.16;
contract moduleTokenInterface{
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed a_owner, address indexed _spender, uint256 _value);
    event OwnerChang(address indexed _old,address indexed _new,uint256 _coin_change);
	event adminUsrChange(address usrAddr,address changeBy,bool isAdded);
	event onAdminTransfer(address to,uint256 value);
}

contract moduleToken is moduleTokenInterface {
    
    struct transferPlanInfo{
        uint256 transferValidValue;
        bool isInfoValid;
    }
    
    struct ethPlanInfo{
	    uint256 ethNum;
	    uint256 coinNum;
	    bool isValid;
	}
	
	//����Ա֮һ����һ��ת�˲�������Ҫ������׼ʱ����������ݽṹ
	struct transferEthAgreement{
		//Ҫ��Щ��ǩ��
	    mapping(address=>bool) signUsrList;		
		
		//�Ѿ�ǩ�������
		uint32 signedUsrCount;
		
		//Ҫ��ת����eth����
	    uint256 transferEthInWei;
		
		//ת������
		address to;
		
		//��ǰת��Ҫ��ķ�����
		address infoOwner;
		
		//��ǰ��¼�Ƿ���Ч(����123456789)
	    uint32 magic;
	    
	    //�Ƿ���Ч��
	    bool isValid;
	}
	
	

    string public name;                   //���ƣ�����"My test token"
    uint8 public decimals;               //����tokenʹ�õ�С�����λ�������������Ϊ3������֧��0.001��ʾ.
    string public symbol;               //token���,like MTT
    address public owner;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
	
	//�Ƿ�����ֱ�ӽ���eth��������cot
	bool public canRecvEthDirect=false;
    
    
    //����Ϊ������Э�������߼��������ر�
    //
    
    //�ҵļ۸�Ϊ0ʱ��Ǯ���۸�����߼�����Ч   
	uint256 public coinPriceInWei;
	
	//���б������ת�����ұ������ع涨��ʱ�䡢��������(����ʵ�ִ��Ҷ�ʱ�ⶳ)
	mapping(address=>transferPlanInfo) public transferPlanList;
	
	//ָ�����˰�ָ������̫����������������������ң������۸��߼����򣨱�����ʹ��ļ�ʣ�
	//���򰴼۸�����߼���������ҵ�����
	mapping(address => ethPlanInfo) public ethPlanList;
	
	uint public blockTime=block.timestamp;
    
    bool public isTransPaused=true;//Ϊtrueʱ��ֹת�� 
    
     //ʵ�ֶ����Ա��صı���  
    struct adminUsrInfo{
        bool isValid;
	    string userName;
		string descInfo;
    }
    mapping(address=>adminUsrInfo) public adminOwners; //����Ա��
    bool public isAdminOwnersValid;
    uint32 public adminUsrCount;//��Ч�Ĺ���Ա�û���
    mapping(uint256=>transferEthAgreement) public transferEthAgreementList;

    function moduleToken(
        uint256 _initialAmount,
        uint8 _decimalUnits) public 
    {
        owner=msg.sender;//��¼��Լ��owner
		if(_initialAmount<=0){
		    totalSupply = 100000000000;   // ���ó�ʼ����
		    balances[owner]=100000000000;
		}else{
		    totalSupply = _initialAmount;   // ���ó�ʼ����
		    balances[owner]=_initialAmount;
		}
		if(_decimalUnits<=0){
		    decimals=2;
		}else{
		    decimals = _decimalUnits;
		}
        name = "CareerOn Token"; 
        symbol = "COT";
    }
    
    function changeContractName(string _newName,string _newSymbol) public {
        require(msg.sender==owner || adminOwners[msg.sender].isValid);
        name=_newName;
        symbol=_newSymbol;
    }
    
    
    function transfer(
        address _to, 
        uint256 _value) public returns (bool success) 
    {
        if(isTransPaused){
            emit Transfer(msg.sender, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
        }
        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).
        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣
		if(_to==address(this)){
			emit Transfer(msg.sender, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
		}
		if(balances[msg.sender] < _value || 
			balances[_to] + _value <= balances[_to])
		{
			emit Transfer(msg.sender, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
		}
        if(transferPlanList[msg.sender].isInfoValid && transferPlanList[msg.sender].transferValidValue<_value)
		{
			emit Transfer(msg.sender, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
		}
        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value
        balances[_to] += _value;//�������˻�����token����_value
        if(transferPlanList[msg.sender].isInfoValid){
            transferPlanList[msg.sender].transferValidValue -=_value;
        }
        emit Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�
        return true;
    }


    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value) public returns (bool success) 
    {
        if(isTransPaused){
            emit Transfer(_from, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
        }
		if(_to==address(this)){
			emit Transfer(_from, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
		}
        if(balances[_from] < _value ||
			allowed[_from][msg.sender] < _value)
		{
			emit Transfer(_from, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
		}
        if(transferPlanList[_from].isInfoValid && transferPlanList[_from].transferValidValue<_value)
		{
			emit Transfer(_from, _to, 0);//����ת�ҽ����¼�
            revert();
            return;
		}
        balances[_to] += _value;//�����˻�����token����_value
        balances[_from] -= _value; //֧���˻�_from��ȥtoken����_value
        allowed[_from][msg.sender] -= _value;//��Ϣ�����߿��Դ��˻�_from��ת������������_value
        if(transferPlanList[_from].isInfoValid){
            transferPlanList[_from].transferValidValue -=_value;
        }
        emit Transfer(_from, _to, _value);//����ת�ҽ����¼�
        return true;
    }
    
    function balanceOf(address accountAddr) public constant returns (uint256 balance) {
        return balances[accountAddr];
    }


    function approve(address _spender, uint256 _value) public returns (bool success) 
    { 
        require(msg.sender!=_spender && _value>0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner, 
        address _spender) public constant returns (uint256 remaining) 
    {
        return allowed[_owner][_spender];//����_spender��_owner��ת����token��
    }
	
	//����Ϊ������Э��������߼�
	
	//ת��Э������Ȩ���������Ĵ���һ��ת�ƹ�ȥ
	function changeOwner(address newOwner) public{
        require(msg.sender==owner && msg.sender!=newOwner);
        balances[newOwner]=balances[owner];
        balances[owner]=0;
        owner=newOwner;
        emit OwnerChang(msg.sender,newOwner,balances[owner]);//������Լ����Ȩ��ת���¼�
    }
    
    function setPauseStatus(bool isPaused)public{
        if(msg.sender!=owner && !adminOwners[msg.sender].isValid){
            revert();
            return;
        }
        isTransPaused=isPaused;
    }
    
    //����ת�����ƣ����綳��ʲô��
	function setTransferPlan(address addr,
	                        uint256 allowedMaxValue,
	                        bool isValid) public
	{
	    if(msg.sender!=owner && !adminOwners[msg.sender].isValid){
	        revert();
	        return ;
	    }
	    transferPlanList[addr].isInfoValid=isValid;
	    if(transferPlanList[addr].isInfoValid){
	        transferPlanList[addr].transferValidValue=allowedMaxValue;
	    }
	}
    
    //�ѱ�����Э���˻��µ�ethת��ָ���˻�
	function TransferEthToAddr(address _to,uint256 _value)public payable{
        require(msg.sender==owner && !isAdminOwnersValid);
        _to.transfer(_value);
    }
    
    function createTransferAgreement(uint256 agreeMentId,
                                      uint256 transferEthInWei,
                                      address to) public {
        require(adminOwners[msg.sender].isValid && 
        transferEthAgreementList[agreeMentId].magic!=123456789 && 
        transferEthAgreementList[agreeMentId].magic!=987654321);
        transferEthAgreementList[agreeMentId].magic=123456789;
        transferEthAgreementList[agreeMentId].infoOwner=msg.sender;
        transferEthAgreementList[agreeMentId].transferEthInWei=transferEthInWei;
        transferEthAgreementList[agreeMentId].to=to;
        transferEthAgreementList[agreeMentId].isValid=true;
        transferEthAgreementList[agreeMentId].signUsrList[msg.sender]=true;
        transferEthAgreementList[agreeMentId].signedUsrCount=1;
        
    }
	
	function disableTransferAgreement(uint256 agreeMentId) public {
		require(transferEthAgreementList[agreeMentId].infoOwner==msg.sender &&
			    transferEthAgreementList[agreeMentId].magic==123456789);
		transferEthAgreementList[agreeMentId].isValid=false;
		transferEthAgreementList[agreeMentId].magic=987654321;
	}
	
	function sign(uint256 agreeMentId,address to,uint256 transferEthInWei) public payable{
		require(transferEthAgreementList[agreeMentId].magic==123456789 &&
		transferEthAgreementList[agreeMentId].isValid &&
		transferEthAgreementList[agreeMentId].transferEthInWei==transferEthInWei &&
		transferEthAgreementList[agreeMentId].to==to &&
		adminOwners[msg.sender].isValid &&
		!transferEthAgreementList[agreeMentId].signUsrList[msg.sender]&&
		adminUsrCount>=2
		);
		transferEthAgreementList[agreeMentId].signUsrList[msg.sender]=true;
		transferEthAgreementList[agreeMentId].signedUsrCount++;
		
		if(transferEthAgreementList[agreeMentId].signedUsrCount<=adminUsrCount/2)
		{
			return;
		}
		to.transfer(transferEthInWei);
		transferEthAgreementList[agreeMentId].isValid=false;
		transferEthAgreementList[agreeMentId].magic=987654321;
		emit onAdminTransfer(to,transferEthInWei);
		return;
	}
	
	struct needToAddAdminInfo{
		uint256 magic;
		mapping(address=>uint256) postedPeople;
		uint32 postedCount;
	}
	mapping(address=>needToAddAdminInfo) public needToAddAdminInfoList;
	function addAdminOwners(address usrAddr,
					  string userName,
					  string descInfo)public 
	{
		needToAddAdminInfo memory info;
		//���ǹ���ԱҲ����owner�����ֹ�κβ���
		if(!adminOwners[msg.sender].isValid && owner!=msg.sender){
			revert();
			return;
		}
		//�κ����,owner��ַ�����Ա���ӵ�����Ա��
		if(usrAddr==owner){
			revert();
			return;
		}
		//�Ѿ��ڹ���Ա��Ĳ����Ա����
		if(adminOwners[usrAddr].isValid){
			revert();
			return;
		}
		//����������Լ�������Ա��
		if(usrAddr==msg.sender){
			revert();
			return;
		}
		//����Ա����2��ʱ��owner�����������2�˵�����Ա
		if(adminUsrCount<2){
			if(msg.sender!=owner){
				revert();
				return;
			}
			adminOwners[usrAddr].isValid=true;
			adminOwners[usrAddr].userName=userName;
			adminOwners[usrAddr].descInfo=descInfo;
			adminUsrCount++;
			if(adminUsrCount>=2) isAdminOwnersValid=true;
			emit adminUsrChange(usrAddr,msg.sender,true);
			return;
		}
		//����Ա���ڵ���2��ʱ��owner��ӹ���Ա��Ҫ�õ�����������Ա��ͬ�⣬�������ٱ�����2
		if(msg.sender==owner){
			//ĳ���û��Ѿ���Ҫ����ӵ�����Ա�飬owner��ʱ��û��ͶƱȨ��
			if(needToAddAdminInfoList[usrAddr].magic==123456789){
				revert();
				return;
			}
			//����owner��ĳ������ӵ�Ҫ��������Ա����б����������������ԱͶƱ
			info.magic=123456789;
			info.postedCount=0;
			needToAddAdminInfoList[usrAddr]=info;
			return;
			
		}//����Ա���ڵ���2��ʱ��owner����µĹ���Ա���������������Աͬ����������2
		else if(adminOwners[msg.sender].isValid)
		{
			//����Աֻ��ͶƱȷ����ӹ���Ա������ֱ����ӹ���Ա
			if(needToAddAdminInfoList[usrAddr].magic!=123456789){
				revert();
				return;
			}
			//�Ѿ�Ͷ��Ʊ�Ĺ���Ա��������Ͷ			
			if(needToAddAdminInfoList[usrAddr].postedPeople[msg.sender]==123456789){
				revert();
				return;
			}
			needToAddAdminInfoList[usrAddr].postedCount++;
			needToAddAdminInfoList[usrAddr].postedPeople[msg.sender]=123456789;
			if(adminUsrCount>=2 && 
			   needToAddAdminInfoList[usrAddr].postedCount>adminUsrCount/2){
				adminOwners[usrAddr].userName=userName;
				adminOwners[usrAddr].descInfo=descInfo;
				adminOwners[usrAddr].isValid=true;
				needToAddAdminInfoList[usrAddr]=info;
				adminUsrCount++;
				emit adminUsrChange(usrAddr,msg.sender,true);
				return;
			}
			
		}else{
			return revert();//�������һ�ɲ�������ӹ���Ա
		}		
	}
	struct needDelFromAdminInfo{
		uint256 magic;
		mapping(address=>uint256) postedPeople;
		uint32 postedCount;
	}
	mapping(address=>needDelFromAdminInfo) public needDelFromAdminInfoList;
	function delAdminUsrs(address usrAddr) public {
		needDelFromAdminInfo memory info;
		//�в��ǹ���Ա������ɾ��
		if(!adminOwners[usrAddr].isValid){
			revert();
			return;
		}
		//��ǰ����Ա��С��4�Ļ�������ɾ�û�
		if(adminUsrCount<4){
			revert();
			return;
		}
		//��ǰ����Ա��������ʱ����ɾ�û�
		if(adminUsrCount%2!=0){
			revert();
			return;
		}
		//��������Լ��˳�����Ա
		if(usrAddr==msg.sender){
			revert();
			return;
		}
		if(msg.sender==owner){
			//ownerû��Ȩ��ȷ��ɾ������Ա
			if(needDelFromAdminInfoList[usrAddr].magic==123456789){
				revert();
				return;
			}
			//owner��������ɾ������Ա��������Ҫ����Ա������ͬ��
			info.magic=123456789;
			info.postedCount=0;
			needDelFromAdminInfoList[usrAddr]=info;
			return;
		}
		//����Աȷ��ɾ���û�
		
		//����Աֻ��Ȩ��ȷ��ɾ��
		if(needDelFromAdminInfoList[usrAddr].magic!=123456789){
			revert();
			return;
		}
		//�Ѿ�Ͷ��Ʊ�Ĳ�������Ͷ
		if(needDelFromAdminInfoList[usrAddr].postedPeople[msg.sender]==123456789){
			revert();
			return;
		}
		needDelFromAdminInfoList[usrAddr].postedCount++;
		needDelFromAdminInfoList[usrAddr].postedPeople[msg.sender]=123456789;
		//ͬ���������δ����һ����ֱ�ӷ���
		if(needDelFromAdminInfoList[usrAddr].postedCount<=adminUsrCount/2){
			return;
		}
		//ͬ�����������һ��
		adminOwners[usrAddr].isValid=false;
		if(adminUsrCount>=1) adminUsrCount--;
		if(adminUsrCount<=1) isAdminOwnersValid=false;
		needDelFromAdminInfoList[usrAddr]=info;
		emit adminUsrChange(usrAddr,msg.sender,false);
	}
	
	//����ָ���˰��̶�eth�����̶�������������ң�������ʹ��ļ��
	function setEthPlan(address addr,uint256 _ethNum,uint256 _coinNum,bool _isValid) public {
	    require(msg.sender==owner &&
	        _ethNum>=0 &&
	        _coinNum>=0 &&
	        (_ethNum + _coinNum)>0 &&
	        _coinNum<=balances[owner]);
	    ethPlanList[addr].isValid=_isValid;
	    if(ethPlanList[addr].isValid){
	        ethPlanList[addr].ethNum=_ethNum;
	        ethPlanList[addr].coinNum=_coinNum;
	    }
	}
	
	//���ô��Ҽ۸�(Wei)
	function setCoinPrice(uint256 newPriceInWei) public returns(uint256 oldPriceInWei){
	    require(msg.sender==owner);
	    uint256 _old=coinPriceInWei;
	    coinPriceInWei=newPriceInWei;
	    return _old;
	}
	
	function balanceInWei() public constant returns(uint256 nowBalanceInWei){
	    return address(this).balance;
	}
	
	function changeRecvEthStatus(bool _canRecvEthDirect) public{
		if(msg.sender!=owner){
			revert();
			return;
		}
		canRecvEthDirect=_canRecvEthDirect;
	}
	
	//���˺���
    //��Լ�˻��յ�ethʱ�ᱻ����
    //�κ��쳣ʱ���������Ҳ�ᱻ����
	//������ͷ�����㣬���ⱻDDOS����
    function () public payable {
		if(canRecvEthDirect){
			return;
		}
        if(ethPlanList[msg.sender].isValid==true &&
            msg.value>=ethPlanList[msg.sender].ethNum &&
            ethPlanList[msg.sender].coinNum>=0 &&
            ethPlanList[msg.sender].coinNum<=balances[owner]){
                ethPlanList[msg.sender].isValid=false;
                balances[owner] -= ethPlanList[msg.sender].coinNum;//����Ϣ�������˻��м�ȥtoken����_value
                balances[msg.sender] += ethPlanList[msg.sender].coinNum;//�������˻�����token����_value
		        emit Transfer(this, msg.sender, ethPlanList[msg.sender].coinNum);//����ת�ҽ����¼�
        }else if(!ethPlanList[msg.sender].isValid &&
            coinPriceInWei>0 &&
            msg.value/coinPriceInWei<=balances[owner] &&
            msg.value/coinPriceInWei+balances[msg.sender]>balances[msg.sender]){
            uint256 buyCount=msg.value/coinPriceInWei;
            balances[owner] -=buyCount;
            balances[msg.sender] +=buyCount;
            emit Transfer(this, msg.sender, buyCount);//����ת�ҽ����¼�
               
        }else{
            revert();
        }
    }
}