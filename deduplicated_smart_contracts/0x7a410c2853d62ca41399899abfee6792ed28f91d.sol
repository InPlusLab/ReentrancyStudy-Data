/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.4.22;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



contract LLL {

	address public admin; // ����Ա

    string public name;

    string public symbol;

    uint8 public decimals = 3;  // decimals �����е�С�����������С�Ĵ��ҵ�λ

    uint256 public totalSupply;



    mapping (address => uint256) public balanceOf; // ��mapping����ÿ����ַ��Ӧ�����

    mapping (address => mapping (address => uint256)) public allowance; // �洢���˺ŵĿ���

	mapping (address => uint256) public frozenTimestamp; // �����ڶ�����˻�



    event Transfer(address indexed from, address indexed to, uint256 value); // �¼�������֪ͨ�ͻ��˽��׷���

    event Burn(address indexed from, uint256 value); // �¼�������֪ͨ�ͻ��˴��ұ�����



    /**

     * ��ʼ������

     */

    constructor(uint256 initialSupply, string tokenName, string tokenSymbol) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  // ��Ӧ�ķݶ�ݶ����С�Ĵ��ҵ�λ�йأ��ݶ� = ���� * 10 ** decimals��

        balanceOf[msg.sender] = totalSupply;                // ������ӵ�����еĴ���

        name = tokenName;                                   // ��������

        symbol = tokenSymbol;                               // ���ҷ���

		admin = msg.sender;

    }



    /**

     * ���ҽ���ת�Ƶ��ڲ�ʵ��

     */

    function _transfer(address _from, address _to, uint _value) internal {

        // ȷ��Ŀ���ַ��Ϊ0x0����Ϊ0x0��ַ��������

        require(_to != 0x0);

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

	    require(now > frozenTimestamp[msg.sender]);

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

    function approve(address _spender, uint256 _value) public returns (bool success) {

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

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

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

    * ͨ��ʱ��������˻�

    */

    function freezeWithTimestamp(address _target,uint256 _timestamp) public returns (bool) {

        require(msg.sender == admin);

        require(_target != address(0));

        frozenTimestamp[_target] = _timestamp;

        return true;

    }

}