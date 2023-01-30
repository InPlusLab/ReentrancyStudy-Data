/**
 *Submitted for verification at Etherscan.io on 2020-10-09
*/

/**
 * Source Code first verified at https://etherscan.io on Wednesday, June 6, 2018
 (UTC) */

pragma solidity ^0.4.16;
//pragma solidity ^0.5.1;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    // Public variables of the token
    string public name;							/* name �������� */
    string public symbol;						/* symbol ����ͼ�� */
    uint8  public decimals = 18;			/* decimals ����С����λ�� */ 
    uint256 public totalSupply;			//��������

    
    /* ����һ������洢ÿ���˻��Ĵ�����Ϣ�����������˻�������� */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    /* event�¼����������������ѿͻ��˷���������¼������ע�⵽Ǯ����ʱ��������½ǵ�����Ϣ */
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
     /*��ʼ����Լ������������ƴ��봴���ߵ��˻���*/
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  //��̫����10^18������18��0������Ĭ��decimals��18,����������18λС���ĳ���
        balanceOf[msg.sender] = totalSupply;                		// �����������г�ʼ����
        name = tokenName;                                   		// ���ô��ң�token������
        symbol = tokenSymbol;                               		// ���ô��ң�token������
    }

    /**
     * Internal transfer, only can be called by this contract
     */
     /**
     * ˽�з�����һ���ʻ����͸���һ���ʻ�����
     * @param  _from address ���ʹ��ҵĵ�ַ
     * @param  _to address ���ܴ��ҵĵ�ַ
     * @param  _value uint256 ���ܴ��ҵ�����
     */
    function _transfer(address _from, address _to, uint _value) internal {
    
        // Prevent transfer to 0x0 address. Use burn() instead
        //����ת�ʵĵ�ַ��0x0
        require(_to != 0x0);
        
        // Check if the sender has enough
        //��鷢�����Ƿ�ӵ���㹻���
        require(balanceOf[_from] >= _value);
        
        // Check for overflows
        //����Ƿ����
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        // Save this for an assertion in the future
        //�����������ں�����ж�
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        // Subtract from the sender
        //�ӷ����߼������Ͷ�
        balanceOf[_from] -= _value;
        
        // Add the same to the recipient
        //�������߼�����ͬ����
        balanceOf[_to] += _value;
        
        //֪ͨ�κμ����ý��׵Ŀͻ���
        Transfer(_from, _to, _value);
        
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
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
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
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
     * ���ٴ��ҵ����ߵ����
     * �����Ժ��ǲ������
     * @param _value Ҫɾ��������
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
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
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}