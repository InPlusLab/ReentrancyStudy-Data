/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    // ���ƵĹ��б���
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals �����Ƽ�ʹ��Ĭ��ֵ���������
    uint256 public totalSupply;

    // ���������˻��������
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // ���������ϴ���һ�������¼����������ͻ�֪ͨ���пͻ���
    event Transfer(address indexed from, address indexed to, uint256 value);

    // ֪ͨ�ͻ�����������
    event Burn(address indexed from, uint256 value);

    /**
     * ��Լ����
     *
     * ��ʼ����Լ������������ƴ��봴���ߵ��˻���
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // �����ܷ�����
        balanceOf[msg.sender] = totalSupply;                // �����������г�ʼ����
        name = tokenName;                                   // ������ʾ����
        symbol = tokenSymbol;                               // ������ʾ��д��������ر���BTC
    }

    /**
     * �ڲ�ת�ˣ�ֻ�ܱ��ú�Լ����
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // ���ת�˵� 0x0 ��ַ. ʹ�� burn() ���
        require(_to != 0x0);
        // ��鷢�����Ƿ�ӵ���㹻�ı�
        require(balanceOf[_from] >= _value);
        // ���Խ��
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // ������Ϣ�������ڽ���ȷ��
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // �ӷ����߿۱�
        balanceOf[_from] -= _value;
        // �������߼���ͬ������
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // ʹ��assert��Ϊ��ʹ�þ�̬�����ҵ�����bug. ����Զ����ʧ��
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * ��������
     *
     * ������˻����͸�`_value` ���Ƶ� `_to` 
     *
     * @param _to ���յ�ַ
     * @param _value ��������
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * ��������ַ��������
     *
     * ��`_from` ���� `_value` �����Ƶ� `_to` 
     *
     * @param _from ���͵�ַ
     * @param _to ���յ�ַ
     * @param _value ��������
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * ����������ַ�޶�
     *
     * ���� `_spender` ���������ʹ�ò����� `_value`���� 
     *
     * @param _spender ��Ȩʹ�õĵ�ַ
     * @param _value ����ʹ������
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * ����������ַ�޶��֪ͨ
     *
     * ���� `_spender`���������ʹ����� `_value`������, Ȼ��֪ͨ��Լ
     *
     * @param _spender ��Ȩʹ�õĵ�ַ
     * @param _value  ���ʹ�ö��
     * @param _extraData ���͸��Ѿ�֤���ĺ�Լ������Ϣ
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * ��������
     *
     * ���ó�ȥ `_value` �����ƣ����ɻָ�
     *
     * @param _value ����
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * �������˻���������
     *
     * �ԡ�_from�������壬�Ƴ��� `_value`�����ƣ����ɻָ�.
     *
     * @param _from ��ַ
     * @param _value ��������
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}