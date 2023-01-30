/**
 *Submitted for verification at Etherscan.io on 2019-06-14
*/

pragma solidity ^0.5.8;

contract ERC20_Coin{
    
    string public name;//����
    string public symbol;//��д
    uint8 public decimals = 18;//��ȷ��С��λ��
    uint256 public totalSupply;//�ܷ�����
    address internal admin;//����Ա
    mapping (address => uint256) public balanceOf;//�ͻ�Ⱥ��
    bool public isAct = true;//��Լ����
    bool public openRaise = false;//����ļ���ʽ���
    uint256 public raisePrice = 0;//ļ���һ�����
    address payable internal finance;//�������
    
    //ת��֪ͨ
	event Transfer(address indexed from, address indexed to, uint256 value);
	//��̫ת��֪ͨ
	event SendEth(address indexed to, uint256 value);
    
    constructor(
        uint256 initialSupply,//������
        string memory tokenName,//����
        string memory tokenSymbol//��д
     ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        finance = msg.sender;
        admin = msg.sender;
    }

    // ֻ�й���Ա�ܵ��õ�
    modifier onlyAdmin() { 
        require(msg.sender == admin);
        _;
    }

    // �жϺ�Լ�Ƿ���ͣ����
    modifier isActivity() { 
        require(isAct);
        _;
    }

    // �Ƿ���ļ���ʽ�״̬
    modifier isOpenRaise() { 
        require(openRaise);
        _;
    }

    //ֻ���ڻ�в��ҿ�����ļ����ǲŻ����ETH
    function () external payable isActivity isOpenRaise{
		require(raisePrice >= 0);
		uint256 buyNum = msg.value /10000 * raisePrice;
		require(buyNum <= balanceOf[finance]);
		balanceOf[finance] -= buyNum;
		balanceOf[msg.sender] += buyNum;
        finance.transfer(msg.value);
        emit SendEth(finance, msg.value);
        emit Transfer(finance, msg.sender, buyNum);
	}
    
    //��ͨ��ת�˹��ܣ�ֻ�жϻ״̬
    //�����ڸ��ֵ�����Ǯ�����ã��磺imtoken��MetaMask
    function transfer(address _to, uint256 _value) public isActivity{
	    _transfer(msg.sender, _to, _value);
    }
    
    //����ת�ˣ���������
    function transferList(address[] memory _tos, uint[] memory _values) public isActivity {
        require(_tos.length == _values.length);
        uint256 _total = 0;
        for(uint256 i;i<_values.length;i++){
            _total += _values[i];
	    }
        require(balanceOf[msg.sender]>=_total);
        for(uint256 i;i<_tos.length;i++){
            _transfer(msg.sender,_tos[i],_values[i]);
	    }
    }
    
    //�ڲ�ת�˷�װ
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	
    //����ļ���ʽ�Ķһ�����
	function setRaisePrice(uint256 _price)public onlyAdmin{
		raisePrice = _price;
	}
	
    //����ļ��ͨ������Ԥ����Ĭ�϶��ǹرյ�
	function setOpenRaise(bool _open) public onlyAdmin{
	    openRaise = _open;
	}
	
    //���û״̬������Ӧ��״��
	function setActivity(bool _isAct) public onlyAdmin{
		isAct = _isAct;
	}
	
    //ת�ù���ԱȨ��
	function setAdmin(address _address) public onlyAdmin{
       admin = _address;
    }
    
    //�����ʽ����Ա
    function setMagage(address payable _address) public onlyAdmin{
       finance = _address;
    }
	
    //���ٺ�Լ
	function killYourself()public onlyAdmin{
		selfdestruct(finance);
	}
	
}