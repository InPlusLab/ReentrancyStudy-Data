/**
 *Submitted for verification at Etherscan.io on 2020-12-20
*/

pragma solidity ^0.4.16;
 
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
/**
 * owned�Ǻ�Լ�Ĺ�����
 */
contract owned {
    address public owner;
 
    /**
     * ��̨�����캯��
     */
    function owned () public {
        owner = msg.sender;
    }
 
    /**
     * �жϵ�ǰ��Լ�������Ƿ��Ǻ�Լ��������
     */
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    /**
     * ��Լ��������ָ��һ���µĹ���Ա
     * @param  newOwner address �µĹ���Ա�ʻ���ַ
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}
 
/**
 * �������Һ�Լ
 */
contract TokenERC20 {
    string public name; //���еĴ�������
    string public symbol; //���еĴ��ҷ���
    uint8 public decimals = 18;  //���ҵ�λ��չʾ��С���������ٸ�0��
    uint256 public totalSupply; //���еĴ�������
 
    /*��¼��������ӳ��*/
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
 
    /* ���������ϴ���һ���¼�������֪ͨ�ͻ���*/
    //ת��֪ͨ�¼�
    event Transfer(address indexed from, address indexed to, uint256 value);  
    event Burn(address indexed from, uint256 value);  //��ȥ�û�����¼�
 
    /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����
     * @param initialSupply ���ҵ�����
     * @param tokenName ��������
     * @param tokenSymbol ���ҷ���
     */
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        //��ʼ������
        totalSupply = initialSupply * 10 ** uint256(decimals);   
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
     * ���ù��̣��������õ���������׶�
     * @param  _from address �����ߵ�ַ
     * @param  _to address �����ߵ�ַ
     * @param  _value uint256 Ҫת�ƵĴ�������
     * @return success        �Ƿ��׳ɹ�
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //��鷢�����Ƿ�ӵ���㹻���
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
 
    /**
     * �����ʻ�����֧���������
     * һ�������ܺ�Լ��ʱ�򣬱���֧�����࣬��ɷ���
     * @param _spender �ʻ���ַ
     * @param _value ���
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
 
    /**
     * �����ʻ�����֧���������
     * һ�������ܺ�Լ��ʱ�򣬱���֧�����࣬��ɷ��գ�����ʱ������������� tokenRecipient ������������
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
     * �����Ժ��ǲ������
     * @param _value Ҫɾ��������
     */
    function burn(uint256 _value) public returns (bool success) {
        //����ʻ�����Ƿ����Ҫ��ȥ��ֵ
        require(balanceOf[msg.sender] >= _value);
        //��ָ���ʻ���ȥ���
        balanceOf[msg.sender] -= _value;
        //������������Ӧ�۳�
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
 
    /**
     * ɾ���ʻ������������ʻ���
     * ɾ���Ժ��ǲ������
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
 
/**
 * ���Ҷ��ᡢ
 * �����Զ����ۺ͹���
 * �߼����ҹ���
 */
contract MyAdvancedToken is owned, TokenERC20 {
 
    //�����Ļ���,һ�����ң������������ٸ���̫�ң���λ��wei
    uint256 public sellPrice;
 
    //����Ļ���,1����̫�ң������򼸸�����
    uint256 public buyPrice;
 
    //�Ƿ񶳽��ʻ����б�
    mapping (address => bool) public frozenAccount;
 
    //����һ���¼��������ʲ��������ʱ��֪ͨ���ڼ����¼��Ŀͻ���
    event FrozenFunds(address target, bool frozen);
 
 
    /*��ʼ����Լ�����Ұѳ�ʼ�����е����ƶ������Լ�Ĵ�����
     * @param initialSupply ���бҵ�����
     * @param tokenName ��������
     * @param tokenSymbol ���ҷ���
     */
        function MyAdvancedToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
 
 
    /**
     * ˽�з�������ָ���ʻ�ת�����
     * @param  _from address ���ʹ��ҵĵ�ַ
     * @param  _to address ���ܴ��ҵĵ�ַ
     * @param  _value uint256 ���ܴ��ҵ�����
     */
    function _transfer(address _from, address _to, uint _value) internal {
 
        //����ת�ʵĵ�ַ��0x0
        require (_to != 0x0);
 
        //��鷢�����Ƿ�ӵ���㹻���
        require (balanceOf[_from] > _value);
 
        //����Ƿ����
        require (balanceOf[_to] + _value > balanceOf[_to]);
 
        //��� �����ʻ�
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
 
        //�ӷ����߼������Ͷ�
        balanceOf[_from] -= _value;
 
        //�������߼�����ͬ����
        balanceOf[_to] += _value;
 
        //֪ͨ�κμ����ý��׵Ŀͻ���
        Transfer(_from, _to, _value);
 
    }

    /**
     * ���Ӷ����ʻ�����
     *
     * �������Ҫ��ܹ����Ա����ܿ���˭����/˭������ʹ���㴴���Ĵ��Һ�Լ
     *
     * @param  target address �ʻ���ַ
     * @param  freeze bool    �Ƿ񶳽�
     */
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
 
    /**
     * ���������۸�
     *
     * ���������ether(����������)Ϊ��Ĵ��ҽ��б���,�Ա�����г����Զ�����������,���ǿ�����ô�������Ҫʹ�ø����ļ۸�Ҳ��������������
     *
     * @param newSellPrice �µ������۸�
     * @param newBuyPrice �µ�����۸�
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
 
    /**
     * ʹ����̫�ҹ������
     */
    function buy() payable public {
      uint amount = msg.value / buyPrice;
 
      _transfer(this, msg.sender, amount);
    }
 
    /**
     * @dev ��������
     * @return Ҫ����������(��λ��wei)
     */
    function sell(uint256 amount) public {
 
        //����Լ������Ƿ����
        require(this.balance >= amount * sellPrice);
 
        _transfer(msg.sender, this, amount);
 
        msg.sender.transfer(amount * sellPrice);
    }
}