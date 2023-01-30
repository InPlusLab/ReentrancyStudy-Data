/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

pragma solidity ^0.4.4;
contract SafeMath {
    
    // �˷���internal���εĺ���ֻ�ܹ��ڵ�ǰ��Լ���Ӻ�Լ��ʹ�ã�
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) { 
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
  
    // ����
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
 
    // ����
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        assert(b >=0);
        return a - b;
    }
 
    // �ӷ�
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}
 
contract Test is SafeMath{
    // ���ҵ�����
    string public name; 
    // ���ҵķ���
    string public symbol;
    // ����֧�ֵ�С��λ
    uint8 public decimals;
    // �����е�����
    uint256 public totalSupply;
    // ������
    address public owner;
 
    // ��mapping�����˻���Key��ʾ�˻���ַ��Value��ʾtoken����
    mapping (address => uint256) public balanceOf;
    // ��mappin����ָ���ʺű���Ȩ��token����
    // key1��ʾ��Ȩ�ˣ�key2��ʾ����Ȩ�ˣ�value2��ʾ����Ȩtoken�ĸ���
    mapping (address => mapping (address => uint256)) public allowance;
    // ����ָ���ʺ�token�ĸ���
    mapping (address => uint256) public freezeOf;
 
    // �����¼�
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
 
    // ���캯����1000000, "ZhongB", 18, "ZB"��
    constructor( 
        uint256 initialSupply,  // ��������
        string tokenName,       // token������ BinanceToken
        uint8 decimalUnits,     // ��С�ָС��������β�� 1ether = 10** 18wei
        string tokenSymbol      // ZB
    ) public {
        decimals = decimalUnits;                           
        balanceOf[msg.sender] = initialSupply * 10 ** 18;    
        totalSupply = initialSupply * 10 ** 18;   
        name = tokenName;      
        symbol = tokenSymbol;
        owner = msg.sender;
    }
    
    //����
    function mintToken(address _to, uint256 _value) public returns (bool success){
        // ��ֹ_to��Ч
        assert(_to != 0x0);
        // ��ֹ_value��Ч                       
        assert(_value > 0);
        balanceOf[_to] += _value;
        totalSupply += _value;
        emit Transfer(0, msg.sender, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
 
    // ת�ˣ�ĳ���˻����Լ��ı�
    function transfer(address _to, uint256 _value) public {
        // ��ֹ_to��Ч
        assert(_to != 0x0);
        // ��ֹ_value��Ч                       
        assert(_value > 0);
        // ��ֹת���˵�����
        assert(balanceOf[msg.sender] >= _value);
        // ��ֹ�������
        assert(balanceOf[_to] + _value >= balanceOf[_to]);
        // ��ת���˵��˻��м�ȥһ����token�ĸ���
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     
        // �������ʺ�����һ����token����
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value); 
        // ת�˳ɹ��󴥷�Transfer�¼���֪ͨ��������ת�˽��׷���
        emit Transfer(msg.sender, _to, _value);// Notify anyone listening that this transfer took place
    }
 
    // ��Ȩ����Ȩĳ�˻����Լ��˻���һ��������token
    function approve(address _spender, uint256 _value) public returns (bool success) {
        assert(_value > 0);
        allowance[msg.sender][_spender] = _value;
        return true;
    }
 
 
    // ��Ȩת�ˣ�����Ȩ�˴�_from�ʺ��и�_to�ʺ�ת��_value��token
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // ��ֹ��ַ��Ч
        assert(_to != 0x0);
        // ��ֹת�˽����Ч
        assert(_value > 0);
        // �����Ȩ���˻�������Ƿ��㹻
        assert(balanceOf[_from] >= _value);
        // ��������Ƿ����
        assert(balanceOf[_to] + _value >= balanceOf[_to]);
        // ��鱻��Ȩ����allowance�п���ʹ�õ�token�����Ƿ��㹻
        assert(_value <= allowance[_from][msg.sender]);
        // ����Ȩ���ʺ��м�ȥһ��������token
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value); 
        // ���������ʺ�������һ��������token
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value); 
        // ��allowance�м�ȥ����Ȩ�˿�ʹ��token������
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        // ���׳ɹ��󴥷�Transfer�¼���������true
        emit Transfer(_from, _to, _value);
        return true;
    }
 
    // ���ٱ�
    function burn(uint256 _value) public returns (bool success) {
        // ��鵱ǰ�ʺ�����Ƿ��㹻
        assert(balanceOf[msg.sender] >= _value);
        // ���_value�Ƿ���Ч
        assert(_value > 0);
        // ��sender�˻����м�ȥһ��������token
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
        // ���·��бҵ�����
        totalSupply = SafeMath.safeSub(totalSupply,_value);
        // ���ҳɹ��󴥷�Burn�¼���������true
        emit Burn(msg.sender, _value);
        return true;
    }
 
    // ����
    function freeze(uint256 _value) public returns (bool success) {
        // ���sender�˻�����Ƿ��㹻
        assert(balanceOf[msg.sender] >= _value);
        // ���_value�Ƿ���Ч
        assert(_value > 0);
        // ��sender�˻��м�ȥһ��������token
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); 
        // ��freezeOf�и�sender�˻�����ָ��������token
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value); 
        // freeze�ɹ��󴥷�Freeze�¼���������true
        emit Freeze(msg.sender, _value);
        return true;
    }
 
    // �ⶳ
    function unfreeze(uint256 _value) public returns (bool success) {
        // ���ⶳ����Ƿ���Ч
        assert(freezeOf[msg.sender] >= _value);
        // ���_value�Ƿ���Ч
        assert(_value > 0); 
        // ��freezeOf�м�ȥָ��sender�˻�һ��������token
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value); 
        // ��sender�˻�������һ��������token
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);    
        // �ⶳ�ɹ��󴥷��¼�
        emit Unfreeze(msg.sender, _value);
        return true;
    }
 
    // �������Լ�ȡǮ
    function withdrawEther(uint256 amount) public {
        // ���sender�Ƿ��ǵ�ǰ��Լ�Ĺ�����
        assert(msg.sender == owner);
        // sender��owner����token
        owner.transfer(amount);
    }
}