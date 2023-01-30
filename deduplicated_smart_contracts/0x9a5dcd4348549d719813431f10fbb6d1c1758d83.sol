pragma solidity ^0.4.24;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
   ��ֹ�����������
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract StandardToken {
	//ʹ��SafeMath
    using SafeMath for uint256;
   
    //��������
    string public name;
    //������д
    string public symbol;
	//����С��λ��(һ�����ҿ��Է�Ϊ���ٷ�)
    uint8 public  decimals;
	//��������
	uint256 public totalSupply;
   
	//���׵ķ���(˭�������������˭���ǽ��׵ķ���)��_value�����Ĵ��ҷ��͵�_to�˻�
    function transfer(address _to, uint256 _value) public returns (bool success);

    //��_from�˻���ת��_value�����Ĵ��ҵ�_to�˻�
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

	//���׵ķ��𷽰�_value�����Ĵ��ҵ�ʹ��Ȩ����_spender��Ȼ��_spender���ܵ���transferFrom���������˻����Ǯת������һ����
    function approve(address _spender, uint256 _value) public returns (bool success);

	//��ѯ_spenderĿǰ���ж���_owner�˻����ҵ�ʹ��Ȩ
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

	//ת�˳ɹ����¼�
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	//ʹ��Ȩί�гɹ����¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

//���ô��ҿ��ƺ�Լ�Ĺ���Ա
contract Owned {

    // modifier(����)����ʾ������Ȩ�������߲���do something������administrator����˼
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;//do something 
    }

	//Ȩ��������
    address public owner;

	//��Լ������ʱ��ִ�У�ִ�к�Լ�����ǵ�һ��owner
    constructor() public {
        owner = msg.sender;
    }
	//�µ�owner,��ʼΪ�յ�ַ������null
    address newOwner=0x0;

	//����owner�ɹ����¼�
    event OwnerUpdate(address _prevOwner, address _newOwner);

    //����owner������Ȩ�����µ�owner(��Ҫ�µ�owner����acceptOwnership�����Ż���Ч)
    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    //�µ�owner��������Ȩ,Ȩ��������ʽ��Ч
    function acceptOwnership() public{
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

//���ҵĿ��ƺ�Լ
contract Controlled is Owned{

	//����vip
    constructor() public {
       setExclude(msg.sender,true);
    }

    // ���ƴ����Ƿ���Խ��ף�true�������(exclude����˻����ܴ����ƣ�����ʵ���������transferAllowed��)
    bool public transferEnabled = true;

    // �Ƿ������˻��������ܣ�true��������
    bool lockFlag=true;
	// �������˻����ϣ�address�˻���bool�Ƿ�����true:����������lockFlag=trueʱ����ϲ����ת�������ˣ�����
    mapping(address => bool) locked;
	// ӵ����Ȩ�û�������transferEnabled��lockFlag�����ƣ�vip����boolΪtrue����vip��Ч
    mapping(address => bool) exclude;

	//����transferEnabledֵ
    function enableTransfer(bool _enable) public onlyOwner returns (bool success){
        transferEnabled=_enable;
		return true;
    }

	//����lockFlagֵ
    function disableLock(bool _enable) public onlyOwner returns (bool success){
        lockFlag=_enable;
        return true;
    }

	// ��_addr�ӵ������˻����������������
    function addLock(address _addr) public onlyOwner returns (bool success){
        require(_addr!=msg.sender);
        locked[_addr]=true;
        return true;
    }

	//����vip�û�
    function setExclude(address _addr,bool _enable) public onlyOwner returns (bool success){
        exclude[_addr]=_enable;
        return true;
    }

	//����_addr�û�
    function removeLock(address _addr) public onlyOwner returns (bool success){
        locked[_addr]=false;
        return true;
    }
	//���ƺ�Լ ����ʵ��
    modifier transferAllowed(address _addr) {
        if (!exclude[_addr]) {
            require(transferEnabled,"transfer is not enabeled now!");
            if(lockFlag){
                require(!locked[_addr],"you are locked!");
            }
        }
        _;
    }

}

//����ڣ�������ɧ
contract LiSaoToken is StandardToken,Controlled {

	//�˻�����
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) internal allowed;
	
	constructor() public {
        totalSupply = 1000000000;//10��
        name = "LiSao Token";
        symbol = "LS";
        decimals = 0;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool success) {
		require(_to != address(0));
		require(_value <= balanceOf[msg.sender]);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public transferAllowed(_from) returns (bool success) {
		require(_to != address(0));
        require(_value <= balanceOf[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}