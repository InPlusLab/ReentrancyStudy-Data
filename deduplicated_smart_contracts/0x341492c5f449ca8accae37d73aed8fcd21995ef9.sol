/**

 *Submitted for verification at Etherscan.io on 2019-06-05

*/



pragma solidity ^0.4.18;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



contract WEIPAY {

    /* �������� */

    string public name;

    string public symbol;

    uint8 public decimals = 4;

    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);



    /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����

     * @param initialSupply ���ҵ�����

     * @param tokenName ��������

     * @param tokenSymbol ���ҷ���

     */

    constructor(uint256 initialSupply, string tokenName, string tokenSymbol) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        name = tokenName;

        symbol = tokenSymbol;

    }





    /**

     * ˽�з�����һ���ʻ����͸���һ���ʻ�����

     * @param  _from address ���ʹ��ҵĵ�ַ

     * @param  _to address ���ܴ��ҵĵ�ַ

     * @param  _value uint256 ���ܴ��ҵ�����

     */

    function _transfer(address _from, address _to, uint256 _value) internal {

      require(_to != 0x0);

      require(balanceOf[_from] >= _value);

      require(balanceOf[_to] + _value > balanceOf[_to]);

      uint previousBalances = balanceOf[_from] + balanceOf[_to];

      balanceOf[_from] -= _value;

      balanceOf[_to] += _value;

      emit Transfer(_from, _to, _value);

      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /**

     * �����ʻ���Լ�����߷��͸����˴���

     * @param  _to address ���ܴ��ҵĵ�ַ

     * @param  _value uint256 ���ܴ��ҵ�����

     */

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    /**

     * ��ĳ��ָ�����ʻ��У�����һ���ʻ����ʹ���

     *

     * ���ù��̣��������õ���������׶�

     *

     * @param  _from address �����ߵ�ַ

     * @param  _to address �����ߵ�ַ

     * @param  _value uint256 Ҫת�ƵĴ�������

     * @return success        �Ƿ��׳ɹ�

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /**

     * �����ʻ�����֧���������

     *

     * һ�������ܺ�Լ��ʱ�򣬱���֧�����࣬��ɷ���

     *

     * @param _spender �ʻ���ַ

     * @param _value ���

     */

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    /**

     * �����ʻ�����֧���������

     *

     * һ�������ܺ�Լ��ʱ�򣬱���֧�����࣬��ɷ��գ�����ʱ������������� tokenRecipient ������������

     *

     * @param _spender �ʻ���ַ

     * @param _value ���

     * @param _extraData ������ʱ��

     */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    /**

     * ���ٴ��ҵ����ߵ����

     *

     * �����Ժ��ǲ������

     *

     * @param _value Ҫɾ��������

     */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;

        totalSupply -= _value;

        emit Burn(msg.sender, _value);

        return true;

    }

    /**

     * ɾ���ʻ������������ʻ���

     *

     * ɾ���Ժ��ǲ������

     *

     * @param _from Ҫ�������ʻ���ַ

     * @param _value Ҫ��ȥ������

     */

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);

        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;

        totalSupply -= _value;

        emit Burn(_from, _value);

        return true;

    }



}