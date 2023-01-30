pragma solidity ^0.4.16;

library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //���캯�����Զ�ִ��
    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //ת�ƺ�Լ���µĺ�Լӵ����
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface tokenRecipient {function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;}

contract TokenERC20 {
    using SafeMath for uint256;

    // Public variables of the token
    string public name;    // ���ҷ��ϣ�һ���ô������Ƶ���д���� LBJ
    string public symbol;  // token ��־
    uint8 public decimals = 18;  // ÿ�����ҿ�ϸ�ֵĵ�����λ������С���ҵ�λ
    // �����ܹ�Ӧ��������ָ����һ���ж��ٸ�����С��λ�������Ĵ���
    uint256 public totalSupply;

    // ��mapping����ÿ����ַ��Ӧ�����
    mapping(address => uint256) public balanceOf;
    // ����_owner��_spender��Ȩtoken��ʣ����
    mapping(address => mapping(address => uint256)) public allowance;

    // �¼�������֪ͨ�ͻ��˽��׷���
    event Transfer(address indexed from, address indexed to, uint256 value);

    // �¼�������֪ͨ�ͻ��˴��ұ�����
    event Burn(address indexed from, uint256 value);

    /**
     * ���캯�����Զ�ִ��
     *
     */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        // ��Ӧ�ķݶ�ݶ����С�Ĵ��ҵ�λ�йأ��ݶ� = ���� * 10 ** decimals
        balanceOf[msg.sender] = totalSupply;
        // ������ӵ�����еĴ���
        name = tokenName;
        // ��������
        symbol = tokenSymbol;
        // ���ҷ���
    }

    /**
     * @dev ���ҽ���ת�Ƶ��ڲ�ʵ��,ֻ�ܱ�����Լ����
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // ȷ��Ŀ�ص�ַ��Ϊ0x0����Ϊ0x0��ַ�����������
        require(_to != 0x0);
        // ȷ���������˻����㹻�����
        require(balanceOf[_from] >= _value && _value > 0);
        // ȷ��_valueΪ���������Ϊ���������൱�ڸ������˻�ǮԽ��Խ�࡫������
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // ����ǰ��˫���˻�����ܺ�
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // �����ͷ��˻�����value
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // �����շ��˻�����value
        balanceOf[_to] = balanceOf[_to].add(_value);
        //֪ͨ�ͻ��˽��׷��� Transfer(_from, _to, _value);
        emit Transfer(_from, _to, _value);
        // ��assert���������߼�,������ǰ��˫���˻����ĺ�Ӧ������ͬ��
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * @dev �Ӻ�Լ�����������˺ŷ���`_value`�����ҵ� `_to`�˺�
     *
     * @param _to �����ߵ�ַ
     * @param _value ת������
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //_fromʼ���Ǻ�Լ�����ߵĵ�ַ _transfer(msg.sender, _to, _value); }
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * ����ת�˹̶����
     */
    function batchTransfer(address[] _to, uint _value) public returns (bool success) {
        require(_to.length > 0 && _to.length <= 20);
        for (uint i = 0; i < _to.length; i++) {
            _transfer(msg.sender, _to[i], _value);
        }
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * ��Ȩ_spender��ַ���Բ���msg.sender�˻����������Ϊ_value��token��
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
     * ��������һ����ַ����Լ�����ң����������ߣ����������໨�ѵĴ�����
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
            // ֪ͨ��Լ
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * ���ٺ�Լ�˻���ָ�������Ĵ���
     *
     * @param _value ���ٵ�����
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        // ����Լ�˻��Ƿ����㹻�Ĵ���
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        // ����Լ�˻�������
        totalSupply = totalSupply.sub(_value);
        // �����ܱ���
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * �����û��˻���ָ��������
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);
        // Check allowance
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);
        // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract HYZToken is Ownable, TokenERC20 {

    //���������۸�
    uint256 public sellPrice;
    uint256 public buyPrice;

    uint minBalanceForAccounts;

    mapping(address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);
        // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Check for overflows
        require(!frozenAccount[_from]);
        // ��鷢�����˺��Ƿ񱻶���
        require(!frozenAccount[_to]);
        // ���������˺��Ƿ񱻶���

        if (msg.sender.balance < minBalanceForAccounts)
            sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);
        // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// ��ָ�����˻����Ӵ��ң�ͬʱ�����ܹ�Ӧ����ֻ�к�Լ�����߿ɵ���
    /// @notice ����`mintedAmount`��ǲ����䷢�͵�`target`
    /// @param target Ŀ���ַ�����յ�������token��ͬʱ������������
    /// @param mintedAmount ���������� ��λΪwei
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    /// �ʲ�����
    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Ŀ�궳����˻���ַ
    /// @param freeze �Ƿ񶳽� true|false
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// �����������һ���ֻ�к�Լ�����߿ɵ���
    /// ע�������ļ۸�λ��wei����С�Ļ��ҵ�λ�� 1 eth = 1000000000000000000 wei)
    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    /**
    ������������ô��ҵĻ��ʡ������������buyPrice�����ۻ���sellPrice��������ʵ��ʱ��Ϊ�˼򵥣�����buyPrice=sellPrice=0.01ETH����Ȼ��������������趨�ġ���ʵ���У����������������buyPrice�ļ۸���1ETH����������sellPrice�ļ۸���0.8ETH������ζ��ÿ�����ҵ������������������ȡ0.2ETH�Ľ��׷ѡ��ǲ��Ǻܼ�����ǰ������Ҫ���ƴ������Ĵ��ҡ�0.01eth = 10**16
    */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// �Ӻ�Լ������ҵĺ���
    // ���value���û�����Ĺ������֧������̫����Ŀ��amount�Ǹ��ݻ���������Ĵ�����Ŀ
    function buy() payable public {
        uint amount = msg.value.div(buyPrice);
        // ��������
        _transfer(this, msg.sender, amount);
        // makes the transfers
    }

    /// ���Լ���ۻ��ҵĺ���
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        address myAddress = this;
        require(myAddress.balance >= amount * sellPrice);
        // ����Լ�Ƿ����㹻����̫��ȥ����
        _transfer(msg.sender, this, amount);
        // makes the transfers
        msg.sender.transfer(amount.mul(sellPrice));
        // ������̫�Ҹ�����. ���������º���Ҫ���Ա���ݹ鹥��
    }

    /* �����Զ�����gas����ֵ��Ϣ */
    function setMinBalance(uint minimumBalanceInFinney) onlyOwner public {
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }
}