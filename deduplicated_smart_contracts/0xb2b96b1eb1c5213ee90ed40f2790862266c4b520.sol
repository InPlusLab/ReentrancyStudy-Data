pragma solidity ^ 0.4 .16;
/* ����һ�����࣬�˻�����Ա */
contract owned {

	address public owner;

	constructor() public {
		owner = msg.sender;
	}

	/* �޸ı�־ */
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	/* �޸Ĺ���Ա�˻��� onlyOwner����ֻ�����û�����Ա���޸� */
	function transferOwnership(address newOwner) onlyOwner public {
		owner = newOwner;
	}
}

/* receiveApproval�����Լָʾ���Һ�Լ�����Ҵӷ����ߵ��˻�ת�Ƶ������Լ���˻���ͨ�����÷����Լ�� */
contract tokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract TokenERC20 {
	// ��������
	string public name; //��������
	string public symbol; //���ҷ���
	uint8 public decimals = 18; //����С����λ���� 18��Ĭ�ϣ� ������Ҫ����

	uint256 public totalSupply; //��������

	// ��¼�����˻��Ĵ�����Ŀ
	mapping(address => uint256) public balanceOf;

	// A�˻�����B�˻��ʽ�
	mapping(address => mapping(address => uint256)) public allowance;

	// ת��֪ͨ�¼�
	event Transfer(address indexed from, address indexed to, uint256 value);

	// ���ٽ��֪ͨ�¼�
	event Burn(address indexed from, uint256 value);

	/* ���캯�� */
	constructor(
		uint256 initialSupply,
		string tokenName,
		string tokenSymbol
	) public {
		totalSupply = initialSupply * 10 ** uint256(decimals); // ����decimals������ҵ�����
		balanceOf[msg.sender] = totalSupply; // �����������еĴ�������
		name = tokenName; // ���ô��ҵ�����
		symbol = tokenSymbol; // ���ô��ҵķ���
	}

	/* ˽�еĽ��׺��� */
	function _transfer(address _from, address _to, uint _value) internal {
		// ��ֹת�Ƶ�0x0�� ��burn�����������
		require(_to != 0x0);
		// ��ⷢ�����Ƿ����㹻���ʽ�
		//require(canOf[_from] >= _value);

		require(balanceOf[_from] >= _value);

		// ����Ƿ�������������͵������
		require(balanceOf[_to] + _value > balanceOf[_to]);
		// ���˱���Ϊ�����Ķ��ԣ� ����������һ������
		uint previousBalances = balanceOf[_from] + balanceOf[_to];

		// ���ٷ������ʲ�
		balanceOf[_from] -= _value;

		// ���ӽ����ߵ��ʲ�
		balanceOf[_to] += _value;

		emit Transfer(_from, _to, _value);
		// ���Լ�⣬ ��Ӧ��Ϊ��
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

	}

	/* ����tokens */
	function transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);
	}

	/* �������˻�ת���ʲ� */
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
		require(_value <= allowance[_from][msg.sender]); // Check allowance
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

	/*  ��Ȩ�������ӷ������˻�ת�ƴ��ң�Ȼ��ͨ��transferFrom()������ִ�е�������ת�Ʋ��� */
	function approve(address _spender, uint256 _value) public
	returns(bool success) {
		allowance[msg.sender][_spender] = _value;
		return true;
	}

	/*
	Ϊ������ַ���ý����� ��֪ͨ
	������֪ͨ���Һ�Լ, ���Һ�Լ֪ͨ�����ԼreceiveApproval, �����Լָʾ���Һ�Լ�����Ҵӷ����ߵ��˻�ת�Ƶ������Լ���˻���ͨ�����÷����Լ��transferFrom)
	*/

	function approveAndCall(address _spender, uint256 _value, bytes _extraData)
	public
	returns(bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if(approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}

	/**
	 * ���ٴ���
	 */
	function burn(uint256 _value) public returns(bool success) {
		require(balanceOf[msg.sender] >= _value); // Check if the sender has enough
		balanceOf[msg.sender] -= _value; // Subtract from the sender
		totalSupply -= _value; // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	/**
	 * �������˻����ٴ���
	 */
	function burnFrom(address _from, uint256 _value) public returns(bool success) {
		require(balanceOf[_from] >= _value); // Check if the targeted balance is enough
		require(_value <= allowance[_from][msg.sender]); // Check allowance
		balanceOf[_from] -= _value; // Subtract from the targeted balance
		allowance[_from][msg.sender] -= _value; // Subtract from the sender's allowance
		totalSupply -= _value; // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract BTYCT is owned, TokenERC20 {

	uint256 public totalSupply; //��������
	uint256 public decimals = 18; //����С����λ��
	uint256 public sellPrice = 510; //���ۼ۸� 1ö���һ�������̫ /1000
	uint256 public buyPrice =  526; //����۸� ������̫�ɹ���1ö���� /1000
	uint256 public sysPrice = 766 * 10 ** uint256(decimals); //�ڿ�ĺ���ֵ
	uint256 public sysPer = 225; //�ڿ�������ٷֱ� /100
	
	//uint256 public onceOuttime = 86400; //������ʱ�� ��ʽ 
	//uint256 public onceAddTime = 864000; //�ڿ��ʱ�� ��ʽ
	//uint256 public onceoutTimePer = 8640000; //�����İٷֱ� ��ʽ
	
	uint256 public onceOuttime = 120; //������ʱ�� ����  
	uint256 public onceAddTime = 600; //�ڿ��ʱ�� ����
	uint256 public onceoutTimePer = 12000; //�����İٷֱ� ����

	/* �����˻� */
	mapping(address => bool) public frozenAccount;
	// ��¼�����˻��Ķ�����Ŀ
	mapping(address => uint256) public freezeOf;
	// ��¼�����˻��Ŀ�����Ŀ
	mapping(address => uint256) public canOf;
	// ��¼�����˻����ͷ�ʱ��
	mapping(address => uint) public cronoutOf;
	// ��¼�����˻�������ʱ��
	mapping(address => uint) public cronaddOf;

	/* ֪ͨ */
	event FrozenFunds(address target, bool frozen);
	//event Logs (string);
	/* ���캯�� */

	function BTYCT(
		uint256 initialSupply,
		string tokenName,
		string tokenSymbol
	) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

	/* ת�ˣ� �ȸ���������˻����� */
	function _transfer(address _from, address _to, uint _value) internal {
		require(_to != 0x0); // Prevent transfer to 0x0 address. Use burn() instead
		require(canOf[_from] >= _value);
		require(balanceOf[_from] >= _value); // Check if the sender has enough

		require(balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
		require(!frozenAccount[_from]); // Check if sender is frozen
		require(!frozenAccount[_to]); // Check if recipient is frozen

		//�ڿ� 
		if(cronaddOf[_from] < 1) {
			cronaddOf[_from] = now + onceAddTime;
		}
		if(cronaddOf[_to] < 1) {
			cronaddOf[_to] = now + onceAddTime;
		}
		//�ͷ� 
		if(cronoutOf[_to] < 1) {
			cronoutOf[_to] = now + onceOuttime;
		}
		if(cronoutOf[_to] < 1) {
			cronoutOf[_to] = now + onceOuttime;
		}
		//if(freezeOf[_from] > 0) {
		uint lefttime = now - cronoutOf[_from];
		if(lefttime > onceOuttime) {
			uint leftper = lefttime / onceoutTimePer;
			if(leftper > 1) {
				leftper = 1;
			}
			canOf[_from] = balanceOf[_from] * leftper;
			freezeOf[_from] = balanceOf[_from] - canOf[_from];
			cronoutOf[_from] = now + onceOuttime;
		}

		
		uint lefttimes = now - cronoutOf[_to];
		if(lefttimes >= onceOuttime) {
			uint leftpers = lefttime / onceoutTimePer;
			if(leftpers > 1) {
				leftpers = 1;
			}
			canOf[_to] = balanceOf[_to] * leftpers;
			freezeOf[_to] = balanceOf[_to] - canOf[_to];
			cronoutOf[_to] = now + onceOuttime;
		}
	

		balanceOf[_from] -= _value; // Subtract from the sender
		balanceOf[_to] += _value;
		//���ٿ���

		canOf[_from] -= _value;
		freezeOf[_from] = balanceOf[_from] - canOf[_from];

		//���Ӷ��� 
		freezeOf[_to] += _value;
		canOf[_to] = balanceOf[_to] - freezeOf[_to];

		emit Transfer(_from, _to, _value);
	}

	//��ȡ������Ŀ
	function getcan(address target) public returns (uint256 _value) {
	    if(cronoutOf[target] < 1) {
	        _value = 0;
	    }else{
	        uint lefttime = now - cronoutOf[target];
	        uint leftnum = lefttime/onceoutTimePer;
	        if(leftnum > 1){
	            leftnum = 1;
	        }
	        _value = balanceOf[target]*leftnum;
	    }
	}
	
	/// ��ָ���˻������ʽ�
	function mintToken(address target, uint256 mintedAmount) onlyOwner public {
		require(!frozenAccount[target]);
		balanceOf[target] += mintedAmount;
		balanceOf[this] -= mintedAmount;
		
		cronoutOf[target] = now + onceOuttime;
		cronaddOf[target] = now + onceAddTime;
		freezeOf[target] = balanceOf[target] + mintedAmount;
		
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);

	}
	//�û�ÿ��10���ڿ�һ��
	function mint() public {
		require(!frozenAccount[msg.sender]);
		require(cronaddOf[msg.sender] > 0 && now > cronaddOf[msg.sender] && balanceOf[msg.sender] >= sysPrice);
		uint256 mintAmount = balanceOf[msg.sender] * sysPer / 10000;
		balanceOf[msg.sender] += mintAmount;
		balanceOf[this] -= mintAmount;
		
		freezeOf[msg.sender] = balanceOf[msg.sender] + mintAmount;
		cronaddOf[msg.sender] = now + onceAddTime;
		
		emit Transfer(0, this, mintAmount);
		emit Transfer(this, msg.sender, mintAmount);

	}

	/// ���� or �ⶳ�˻�
	function freezeAccount(address target, bool freeze) onlyOwner public {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	// �������۹���۸�
	function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
		sellPrice = newSellPrice;
		buyPrice = newBuyPrice;

	}
	//�����ڿ����
	function setmyPrice(uint256 systyPrice, uint256 sysPermit) onlyOwner public {
		sysPrice = systyPrice;
		sysPer = sysPermit;
	}
	// ����
	function buy() payable public returns(uint256 amount) {
	    require(!frozenAccount[msg.sender]);
		require(buyPrice > 0 && msg.value > buyPrice); // Avoid dividing 0, sending small amounts and spam
		amount = msg.value / (buyPrice/1000); // Calculate the amount of Dentacoins
		require(balanceOf[this] >= amount); // checks if it has enough to sell
		balanceOf[msg.sender] += amount; // adds the amount to buyer's balance
		balanceOf[this] -= amount; // subtracts amount from seller's balance
		emit Transfer(this, msg.sender, amount); // execute an event reflecting the change
		return amount; // ends function and returns
	}
	function getprice() constant public returns (uint256 bprice,uint256 spice) {
          bprice = buyPrice;
          spice = sellPrice;
    }
    function getset() constant public returns (uint256 sprice,uint256 sper) {
          sprice = sysPrice;
          sper = sysPer;
    }

	// ����
	function sell(uint256 amount) public returns(uint revenue) {
	    require(!frozenAccount[msg.sender]);
		require(sellPrice > 0); // Avoid selling and spam
		require(balanceOf[msg.sender] >= amount); // checks if the sender has enough to sell
		if(cronoutOf[msg.sender] < 1) {
			cronoutOf[msg.sender] = now + onceOuttime;
		}
		uint lefttime = now - cronoutOf[msg.sender];
		if(lefttime > onceOuttime) {
			uint leftper = lefttime / onceoutTimePer;
			if(leftper > 1) {
				leftper = 1;
			}
			canOf[msg.sender] = balanceOf[msg.sender] * leftper;
			freezeOf[msg.sender] = balanceOf[msg.sender] - canOf[msg.sender];
			cronoutOf[msg.sender] = now + onceOuttime;
		}
		require(canOf[msg.sender] >= amount);
		balanceOf[this] += amount; // adds the amount to owner's balance
		balanceOf[msg.sender] -= amount; // subtracts the amount from seller's balance
		revenue = amount * sellPrice/1000;
		require(msg.sender.send(revenue)); // sends ether to the seller: it's important to do this last to prevent recursion attacks
		emit Transfer(msg.sender, this, amount); // executes an event reflecting on the change
		return revenue;

	}

}