/**
 *Submitted for verification at Etherscan.io on 2020-02-22
*/

pragma solidity >=0.4.22 <0.6.0;

contract JUSToken {
/*********Token������˵��************/
    address public owner = 0xBf8216Cdf1a4892d480BEAEDAC81c98D78979283;
    string public name = "JUS Token";
    string public symbol = "JUS";
    uint8 public decimals = 18;  // 18 �ǽ����Ĭ��ֵ
    uint256 public totalSupply; // ������

    // ����ӳ�� ��ַ��Ӧ�� uint' �����������
    mapping (address => uint256) public balanceOf;   
    // ��ַ��Ӧ���
    mapping (address => mapping (address => uint256)) public allowance;

     // �¼�������֪ͨ�ͻ���Token���׷���
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // �����ǹ��캯��, ʵ������ʱ��ִ��
    constructor (uint256 initialSupply) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // ����ȷ�����ܷ�����
        
        balanceOf[owner] = totalSupply;    // ����ͱȽ���Ҫ, �����൱��ʵ����, ��token ȫ������Լ��Creator
    }

    // token�ķ��ͺ���
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {

        require(_to != address(0x0));    // �������ַ
        require(balanceOf[_from] >= _value);        // ���㹻�����������
        require(balanceOf[_to] + _value > balanceOf[_to]);  // ����Ҳ����˼, ���ܷ��͸�����ֵ(hhhh)

        balanceOf[_from] -= _value; //��Ǯ ����˵
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);   // ���ﴥ����ת�˵��¼� , ����event
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value); // �����Ѿ������� ��Լ�����ߵ���Ϣ, ���������ֻ�ܱ���Լ������ʹ��
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // ������Ҫ, ��ַ��Ӧ�ĺ�Լ��ַ(Ҳ����token���)
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;   // �����ǿɻ�������
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

}