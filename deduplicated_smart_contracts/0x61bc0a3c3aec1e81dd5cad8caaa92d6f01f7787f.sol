pragma solidity ^0.4.18;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }  // token�� ������ ���������ӿ�, ���������ǵ�ABI��

contract TokenERC20 {
/*********Token������˵��************/
    string public name ;
    string public symbol ;
    uint8 public decimals = 18;  // 18 �ǽ����Ĭ��ֵ
    uint256 public totalSupply; // ������

    // ����ӳ�� ��ַ��Ӧ�� uint' �����������
    mapping (address => uint256) public balanceOf;   
    // ��ַ��Ӧ���
    mapping (address => mapping (address => uint256)) public allowance;

     // �¼�������֪ͨ�ͻ���Token���׷���
    event Transfer(address indexed from, address indexed to, uint256 value);

     // �¼�������֪ͨ�ͻ��˴��ұ�����(����Ͳ���ת��, ��token���˾�û��)
    event Burn(address indexed from, uint256 value);

    // �����ǹ��캯��, ʵ������ʱ��ִ��
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // ����ȷ�����ܷ�����

        balanceOf[msg.sender] = totalSupply;    // ����ͱȽ���Ҫ, �����൱��ʵ����, ��token ȫ������Լ��Creator

        name = tokenName;
        symbol = tokenSymbol;
    }

    // token�ķ��ͺ���
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);    // �������ַ
        require(balanceOf[_from] >= _value);        // ���㹻�����������
        require(balanceOf[_to] + _value > balanceOf[_to]);  // ����Ҳ����˼, ���ܷ��͸�����ֵ(hhhh)

        uint previousBalances = balanceOf[_from] + balanceOf[_to];  // �����Ϊ��У��, ������̳���, ��������԰�?
        balanceOf[_from] -= _value; //��Ǯ ����˵
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);   // ���ﴥ����ת�˵��¼� , ����event
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  // �ж��ܶ��Ƿ�һ��, ������̳���
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value); 
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // ������Ҫ, ��ַ��Ӧ�ĺ�Լ��ַ(Ҳ����token���)
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;   // �����ǿɻ�������
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    // ��������, ������ձҵ�.. ,���ڰѴ����ߵ� token �յ�
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // ����Ҫ����ô��
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
    // ������û�����token.....
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);        // һ��Ҫ����ô��
        require(_value <= allowance[_from][msg.sender]);    // 
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}