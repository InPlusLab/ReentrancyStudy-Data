/**

 *Submitted for verification at Etherscan.io on 2019-03-07

*/



pragma solidity 0.4.24;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }





/**

 * @title meili���Һ�Լ

 */

contract MEILI {

    /* �������� */

    string public name; //��������

    string public symbol; //���ҷ��ű���'$'

    uint8 public decimals = 18;  //���ҵ�λ��չʾ��С���������ٸ�0,����̫��һ����������18��0

    uint256 public totalSupply; //��������



    /*��¼��������ӳ��*/

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    /* ���������ϴ���һ���¼�������֪ͨ�ͻ���*/

    event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�

    event Burn(address indexed from, uint256 value);  //��ȥ�û�����¼�



    /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����

     * @param initialSupply ���ҵ�����

     * @param tokenName ��������

     * @param tokenSymbol ���ҷ���

     */

    function MEILI(uint256 initialSupply, string tokenName, string tokenSymbol) public {



        //��ʼ������

        totalSupply = initialSupply * 10 ** uint256(decimals);    //��̫����10^18������18��0������Ĭ��decimals��18



        //��ָ���ʻ���ʼ��������������ʼ�����ڽ�����Լ������

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



      //����ת�ʵĵ�ַ��0x0

      require(_to != 0x0);



      //��鷢�����Ƿ�ӵ���㹻���

      require(balanceOf[_from] >= _value);



      //����Ƿ����

      require(balanceOf[_to] + _value > balanceOf[_to]);



      //�����������ں�����ж�

      uint previousBalances = balanceOf[_from] + balanceOf[_to];



      //�ӷ����߼������Ͷ�

      balanceOf[_from] -= _value;



      //�������߼�����ͬ����

      balanceOf[_to] += _value;



      //֪ͨ�κμ����ý��׵Ŀͻ���

      Transfer(_from, _to, _value);



      //�ж�����˫���������Ƿ��ת��ǰһ��

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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        //��鷢�����Ƿ�ӵ���㹻���

        require(_value <= allowance[_from][msg.sender]);   // Check allowance



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

        //����ʻ�����Ƿ����Ҫ��ȥ��ֵ

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough



        //��ָ���ʻ���ȥ���

        balanceOf[msg.sender] -= _value;



        //������������Ӧ�۳�

        totalSupply -= _value;



        Burn(msg.sender, _value);

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



        //����ʻ�����Ƿ����Ҫ��ȥ��ֵ

        require(balanceOf[_from] >= _value);



        //��� �����ʻ� ������Ƿ�ʹ��

        require(_value <= allowance[_from][msg.sender]);



        //��������

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;



        //��������

        totalSupply -= _value;

        Burn(_from, _value);

        return true;

    }

}