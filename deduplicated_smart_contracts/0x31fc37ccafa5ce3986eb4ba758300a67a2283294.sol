pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  // decimals �����е�С�����������С�Ĵ��ҵ�λ��18 �ǽ����Ĭ��ֵ
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
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
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
        Transfer(_from, _to, _value);

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
     * ���ٴ������˻���ָ��������
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
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
        Burn(_from, _value);
        return true;
    }
}

contract EncryptedToken is owned, TokenERC20 {
  uint256 INITIAL_SUPPLY = 10000;
  uint256 public sellPrice = 1000000000000000000;
  uint256 public buyPrice = 1000000000000000000;
  mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
	
	function EncryptedToken() TokenERC20(INITIAL_SUPPLY, 'THQ', '18') payable public {
    		
    		
    }
    
	/* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
        
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value / buyPrice;               // calculates the amount
        _transfer(this, msg.sender, amount);              // makes the transfers
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);              // makes the transfers
        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
    
    function () payable public {
    		uint amount = msg.value / buyPrice;               // calculates the amount
    		_transfer(owner, msg.sender, amount);
    }
    
    //���ٺ�ͬ������ȫ��ת��������
    function selfdestructs() payable public {
    		selfdestruct(owner);
    }
    

    
    //�鿴ָ����ַ�����
  function balanceOfa(address _owner) public constant returns (uint256) {
    return balanceOf[_owner];
  }
}