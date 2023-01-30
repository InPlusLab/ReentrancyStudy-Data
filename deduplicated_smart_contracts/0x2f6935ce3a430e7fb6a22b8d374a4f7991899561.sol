/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



pragma solidity ^ 0.4.25;

contract owned {

    address public owner;

    constructor() public{

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



contract BTCC is owned{

    // ���ң�token���Ĺ�������

    string public name;             //��������

    string public symbol;           //���ҷ���

    uint8 public decimals = 18;     //����С����λ���� 18��Ĭ�ϣ� ������Ҫ����



    uint256 public totalSupply;     //��������

    uint256 public sellPrice = 1 ether;

    uint256 public buyPrice = 1 ether;



    /* �����˻� */

    mapping (address => bool) public frozenAccount;

    // ��¼�����˻��Ĵ�����Ŀ

    mapping (address => uint256) public balanceOf;



    // A�˻�����B�˻��ʽ�

    mapping (address => mapping (address => uint256)) public allowance;



    // ת��֪ͨ�¼�

    event Transfer(address indexed from, address indexed to, uint256 value);



    // ���ٽ��֪ͨ�¼�

    event Burn(address indexed from, uint256 value);

    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);

    /* ���캯�� */

    constructor() public {

        totalSupply = 1000000000 ether;  // ����decimals������ҵ�����

        balanceOf[msg.sender] = totalSupply;                    // �����������еĴ�������

        name = 'BTCC';                                       // ���ô��ҵ�����

        symbol = 'btcc';                                   // ���ô��ҵķ���

        emit Transfer(this, msg.sender, totalSupply);

    }



    /* ˽�еĽ��׺��� */

    function _transfer(address _from, address _to, uint _value) internal {

        // ��ֹת�Ƶ�0x0�� ��burn�����������

        require(_to != 0x0);

        require(!frozenAccount[_from]);                     // Check if sender is frozen

        require(!frozenAccount[_to]);                       // Check if recipient is frozen

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

        emit Transfer(_from, _to, _value);

        // ���Լ�⣬ ��Ӧ��Ϊ��

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /* ����tokens */

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    /* �������˻�ת���ʲ� */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(!frozenAccount[_from]);                     // Check if sender is frozen

        require(!frozenAccount[_to]);                       // Check if recipient is frozen

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



    /**

    * ���ٴ���

    */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] -= _value;            // Subtract from the sender

        totalSupply -= _value;                      // Updates totalSupply

        emit Burn(msg.sender, _value);

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

        emit Burn(_from, _value);

        return true;

    }

    // ���� or �ⶳ�˻�

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {

        sellPrice = newSellPrice;

        buyPrice = newBuyPrice;

    }



    /// @notice Buy tokens from contract by sending ether

    function buy() payable public {

        uint amount = msg.value / buyPrice;               // calculates the amount

        require(totalSupply >= amount);

        totalSupply -= amount;

        _transfer(this, msg.sender, amount);              // makes the transfers

    }



    function sell(uint256 amount) public {

        require(address(this).balance >= amount * sellPrice);      // checks if the contract has enough ether to buy

        _transfer(msg.sender, this, amount);              // makes the transfers

        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks

    }

    // ��ָ���˻������ʽ�

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        require(totalSupply >= mintedAmount);

        balanceOf[target] += mintedAmount;

        totalSupply -= mintedAmount;

        emit Transfer(this, target, mintedAmount);

    }

}