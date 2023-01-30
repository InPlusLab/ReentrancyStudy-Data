/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

pragma solidity 0.7.4;

// SPDX-License-Identifier: GPL-3.0

//interface���Ǹ��ⲿ��Լ������˵�ַ���ܵ����ķ���
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

/**
 * owned ��һ��������
 */
contract owned {
    address public owner;


    //һ���жϵ�ǰ��Լ�������Ƿ��Ǵ����ߵ� modifier, ʲô�� modifier?��������� python ��װ����,�����뿴:
    //http://solidity.readthedocs.io/en/develop/structure-of-a-contract.html?highlight=modifiersolidity
 
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    /**
     * ָ��һ���µĹ���Ա
     * @param  newOwner address �µĹ���Ա�ʻ���ַ
     */
    function transferOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract token is owned {
    /* �������� */
    string public name; //��������
    string public symbol; //���ҷ��ű���'$'
    uint8 public decimals = 8;  //���ҵ�λ����̫����18��0
    uint256 public totalSupply; //��������

    /*��¼��ַ����mapping*/
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* ���������ϴ���һ��event������֪ͨ�ͻ���,event �����������־*/
    event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�
    event Burn(address indexed from, uint256 value);  //��ȥ�û�����¼�

    /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����
     * @param initialSupply ���ҵ�����
     * @param tokenName ��������
     * @param tokenSymbol ���ҷ���
     */
     //��ע��,����Լ������ͬ�ĺ����ǳ�ʼ����,���� init ��������
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {

        //��ʼ������
        totalSupply = initialSupply * 10 ** uint256(decimals);    //��̫����10^18������18��0������Ĭ��decimals��18

        //��ָ���ʻ���ʼ��������������ʼ�����ڽ�����Լ������
        // balanceOf[msg.sender] = totalSupply;
        balanceOf[address(this)] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;

    }

    /**
    * ��Լӵ���ߣ�����Ϊָ���ʻ�����һЩ����,����ν������
    * @param  target address �ʻ���ַ
    * @param  mintedAmount uint256 ���ӵĽ��(��λ��wei)
    */
    function mintToken(address target, uint256 mintedAmount) onlyOwner public virtual {

        //��ָ����ַ���Ӵ��ң�ͬʱ����Ҳ���
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
    }
    /**
     * ˽�з�����һ���ʻ����͸���һ���ʻ�����
     * @param  _from address ���ʹ��ҵĵ�ַ
     * @param  _to address ���ܴ��ҵĵ�ַ
     * @param  _value uint256 ���ܴ��ҵ�����
     */
    function _transfer(address _from, address _to, uint256 _value) internal virtual {

      //����ת�ʵĵ�ַ��0x0,��Ϊ0x0��ַ��������
      require(_to != 0x0000000000000000000000000000000000000000);

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
      emit Transfer(_from, _to, _value);

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
    function transferFrom(address _from, address _to, uint256 _value)  public returns (bool success){
        //��鷢�����Ƿ�ӵ���㹻���
        require(_value <= allowance[_from][msg.sender]);   // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }

    /**
     * �����ʻ�����֧���������
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
     * һ�������ܺ�Լ��ʱ�򣬱���֧�����࣬��ɷ��գ������� tokenRecipient ������������
     *
     * @param _spender �ʻ���ַ
     * @param _value ���
     * @param _extraData ���͸���Լ�ĸ�������
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        //���Կ���,tokenRecipient����Ҫ����һ����ַ
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
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

        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * ɾ���ʻ������������ʻ���
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
        emit Burn(_from, _value);
        return true;
    }
}


 // ���Ӷ����û����ڿ󡢸���ָ�����ʹ���(�۳�)���Ҽ۸�Ĺ���

contract MyAdvancedToken is owned, token {

    //�����Ļ���,һ�����ң����Ի����ٸ���̫�ң���λ��wei
    uint256 public sellPrice;

    //����Ļ���,1����̫�ң������򼸸�����
    uint256 public buyPrice;
    
    //�۸�λ
    uint8 public priceDecimals = 3;

    //�Ƿ񶳽��ʻ����б�
    mapping (address => bool) public frozenAccount;

    //����һ���¼��������ʲ��������ʱ��֪ͨ���ڼ����¼��Ŀͻ���
    event FrozenFunds(address target, bool frozen);


    /*��ʼ����Լ�����Ұѳ�ʼ�����е����ƶ������Լ�Ĵ�����
     * @param initialSupply ���бҵ�����
     * @param tokenName ��������
     * @param tokenSymbol ���ҷ���
     * @param centralMinter �Ƿ�ָ�������ʻ�Ϊ��Լ������,Ϊ0��ȥ���Ļ�
     */
    constructor(
      uint256 initialSupply,
      string memory tokenName,
      string memory tokenSymbol,
      address centralMinter
    ) token (initialSupply, tokenName, tokenSymbol)  {

        //���ú�Լ�Ĺ�����
        if(centralMinter != 0x0000000000000000000000000000000000000000 ) owner = centralMinter;

        sellPrice = 1;     //����1����λ�Ĵ���(��λ��wei)���ܹ�����0.001����̫��
        buyPrice = 1;      //����1����̫�ң�������1000������
    }


    /**
     * ˽�з�������ָ���ʻ�ת�����
     * @param  _from address ���ʹ��ҵĵ�ַ
     * @param  _to address ���ܴ��ҵĵ�ַ
     * @param  _value uint256 ���ܴ��ҵ�����
     */
    function _transfer(address _from, address _to, uint _value) internal override{

        //����ת�ʵĵ�ַ��0x0
        require (_to != 0x0000000000000000000000000000000000000000);

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
        emit Transfer(_from, _to, _value);

    }

    /**
     * ��Լӵ���ߣ�����Ϊָ���ʻ�����һЩ����
     * @param  target address �ʻ���ַ
     * @param  mintedAmount uint256 ���ӵĽ��(��λ��wei)
     */
    function mintToken(address target, uint256 mintedAmount) onlyOwner public override {
        //��ָ����ַ���Ӵ��ң�ͬʱ����Ҳ���
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0x0000000000000000000000000000000000000000, address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }

    /**
     * ���Ӷ����ʻ�����
     *
     * �������Ҫ��ܹ����Ա����ܿ���˭����/˭������ʹ���㴴���Ĵ��Һ�Լ
     *
     * @param  target address �ʻ���ַ
     * @param  freeze bool    �Ƿ񶳽�
     */
    function freezeAccount(address target, bool freeze) onlyOwner public{
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /**
     * ���������۸�
     *
     * ���������ether(����������)Ϊ��Ĵ��ҽ��б���,�Ա�����г����Զ�����������,���ǿ�����ô�������Ҫʹ�ø����ļ۸�Ҳ��������������,��������Ѿ�ʵ���˴��ҵ��г���,��Ȼ�Ƚϳ���
     *
     * @param newSellPrice �µ������۸�
     * @param newBuyPrice �µ�����۸�
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice, uint8 newPriceDecimals) onlyOwner  public{
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
        priceDecimals = newPriceDecimals;
    }

    //ע��,��Щ���׺�����������Ӧ����̫��,Ŀǰ,������̫�ҵĺ�����Ҫ���� payable �ؼ���
    /**
     * ʹ����̫�ҹ������
    function buy() payable public {
      uint amount = msg.value / buyPrice * (10 ** uint256(priceDecimals));
      _transfer(address(this), msg.sender, amount);
    }
    function sell(uint256 amount) public {

        //����Լ������Ƿ��㹻
        require(balanceOf[address(this)] >= amount * sellPrice / (10 ** uint256(priceDecimals)) );

        _transfer(msg.sender, address(this), amount);

        msg.sender.transfer(amount * sellPrice/(10 ** uint256(priceDecimals)) );
    }
    */
}