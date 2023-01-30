/**
 *Submitted for verification at Etherscan.io on 2019-11-19
*/

pragma solidity >=0.4.22 <0.7.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 4;  // decimals �����е�С�����������С�Ĵ��ҵ�λ��18 �ǽ����Ĭ��ֵ
    uint256 public totalSupply;

    // ��mapping����ÿ����ַ��Ӧ�����
    mapping (address => uint256) public balanceOf;
    // �洢���˺ŵĿ���
    mapping (address => mapping (address => uint256)) public allowance;

    // �¼�������֪ͨ�ͻ��˽��׷���
    event Transfer(address indexed from, address indexed to, uint256 value);

    // �¼�������֪ͨ�ͻ��˴��ұ�����
    event Burn(address indexed from, uint256 value);

    /**
     * ��ʼ������
     */
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // ��Ӧ�ķݶ�ݶ����С�Ĵ��ҵ�λ�йأ��ݶ� = ���� * 10 ** decimals��
        balanceOf[msg.sender] = totalSupply;                // ������ӵ�����еĴ���
        name = tokenName;                                   // ��������
        symbol = tokenSymbol;                               // ���ҷ���
    }

    /**
     * ���ҽ���ת�Ƶ��ڲ�ʵ��
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // ȷ��Ŀ���ַ��Ϊ0x0����Ϊ0x0��ַ��������
        require(_to != address(0x0));
        // ��鷢�������
        require(balanceOf[_from] >= _value);
        // ȷ��ת��Ϊ������
        require(balanceOf[_to] + _value > balanceOf[_to]);

        // ����������齻�ף�
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        // ��assert���������߼���
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     *  ���ҽ���ת��
     * �Ӵ����������˺ŷ���`_value`�����ҵ� `_to`�˺�
     *
     * @param _to �����ߵ�ַ
     * @param _value ת������
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * �˺�֮����ҽ���ת��
     * @param _from �����ߵ�ַ
     * @param _to �����ߵ�ַ
     * @param _value ת������
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * ����ĳ����ַ����Լ�����Խ��������廨�ѵĴ�������
     *
     * ��������`_spender` ���Ѳ����� `_value` ������
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * ��������һ����ַ����Լ���Խ������������໨�ѵĴ�������
     *
     * @param _spender ����Ȩ�ĵ�ַ����Լ��
     * @param _value ���ɻ��Ѵ�����
     * @param _extraData ���͸���Լ�ĸ�������
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * ���ٴ������˻���ָ��������
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * �����û��˻���ָ��������
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}