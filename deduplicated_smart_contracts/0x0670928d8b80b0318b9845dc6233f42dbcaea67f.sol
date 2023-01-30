/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



/* һ����ԱȽ����ƵĴ��Һ�Լ */

pragma solidity ^0.4.24;

/* ����һ�����࣬ �˻�����Ա */

contract owned {



    address public owner;



    function owned() public {

    owner = msg.sender;

    }



    /* modifier���޸ı�־ */

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    /* �޸Ĺ���Ա�˻��� onlyOwner����ֻ�����û�����Ա���޸� */

    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }   

}



/* receiveApproval�����Լָʾ���Һ�Լ�����Ҵӷ����ߵ��˻�ת�Ƶ������Լ���˻���ͨ�����÷����Լ�� */

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }



contract TokenERC20 {

    // ���ң�token���Ĺ�������

    string public name;             //��������

    string public symbol;           //���ҷ���

    uint8 public decimals = 18;     //����С����λ���� 18��Ĭ�ϣ� ������Ҫ����



    uint256 public totalSupply;     //��������



    // ��¼�����˻��Ĵ�����Ŀ

    mapping (address => uint256) public balanceOf;



    // A�˻�����B�˻��ʽ�

    mapping (address => mapping (address => uint256)) public allowance;



    // ת��֪ͨ�¼�

    event Transfer(address indexed from, address indexed to, uint256 value);



    // ���ٽ��֪ͨ�¼�

    event Burn(address indexed from, uint256 value);



    /* ���캯�� */

    function TokenERC20(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  // ����decimals������ҵ�����

        balanceOf[msg.sender] = totalSupply;                    // �����������еĴ�������

        name = tokenName;                                       // ���ô��ҵ�����

        symbol = tokenSymbol;                                   // ���ô��ҵķ���

    }



    /* ˽�еĽ��׺��� */

    function _transfer(address _from, address _to, uint _value) internal {

        // ��ֹת�Ƶ�0x0�� ��burn�����������

        require(_to != 0x0);

        // ��ⷢ�����Ƿ����㹻���ʽ�

        require(balanceOf[_from] >= _value);

        // ����Ƿ�������������͵������

        require(balanceOf[_to] + _value > balanceOf[_to]);

        // ���˱���Ϊ�����Ķ��ԣ� ����������һ������

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // ���ٷ������ʲ�

        balanceOf[_from] -= _value;

        // ���ӽ����ߵ��ʲ�

        balanceOf[_to] += _value;

        Transfer(_from, _to, _value);

        // ���Լ�⣬ ��Ӧ��Ϊ��

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /* ����tokens */

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    /* �������˻�ת���ʲ� */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /*  ��Ȩ�������ӷ������˻�ת�ƴ��ң�Ȼ��ͨ��transferFrom()������ִ�е�������ת�Ʋ��� */

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    /*

    Ϊ������ַ���ý����� ��֪ͨ

    ������֪ͨ���Һ�Լ, ���Һ�Լ֪ͨ�����ԼreceiveApproval, �����Լָʾ���Һ�Լ�����Ҵӷ����ߵ��˻�ת�Ƶ������Լ���˻���ͨ�����÷����Լ��transferFrom)

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

    * ���ٴ���

    */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] -= _value;            // Subtract from the sender

        totalSupply -= _value;                      // Updates totalSupply

        Burn(msg.sender, _value);

        return true;

    }



    /**

    * �������˻����ٴ���

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



/******************************************/

/*       ADVANCED TOKEN STARTS HERE       */

/******************************************/



contract IEVC is owned, TokenERC20 {



    uint256 public sellPrice;

    uint256 public buyPrice;



    /* �����˻� */

    mapping (address => bool) public frozenAccount;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);



    /* ���캯�� */

    function IEVC(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}



    /* ת�ˣ� �ȸ���������˻����� */

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



/// ��ָ���˻������ʽ�

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        balanceOf[target] += mintedAmount;

        totalSupply += mintedAmount;

        Transfer(0, this, mintedAmount);

        Transfer(this, target, mintedAmount);



    }





    /// ���� or �ⶳ�˻�

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        FrozenFunds(target, freeze);

    }



    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {

        sellPrice = newSellPrice;

        buyPrice = newBuyPrice;

    }



    /// @notice Buy tokens from contract by sending ether

    function buy() payable public {

        uint amount = msg.value / buyPrice;               // calculates the amount

        _transfer(this, msg.sender, amount);              // makes the transfers

    }



    function sell(uint256 amount) public {

        require(this.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy

        _transfer(msg.sender, this, amount);              // makes the transfers

        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks

    }

}