pragma solidity ^0.4.17;

/*
    Utilities & Common Modifiers
*/
contract Utils {
    /**
        constructor
    */
    function Utils() public {
    }

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

    // Overflow protected math functions

    /**
        @dev returns the sum of _x and _y, asserts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public pure returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}


/*
    owned ��һ��������
*/
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address _prevOwner, address _newOwner);

    /**
     * ��ʼ�����캯��
     */
    function Owned() public {
        owner = msg.sender;
    }

    /**
     * �жϵ�ǰ��Լ�������Ƿ��ǹ���Ա
     */
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    /**
     * ָ��һ���µĹ���Ա
     * @param  _newOwner address �µĹ���Ա�ʻ���ַ
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract IToken {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public pure returns (string) {}
    function symbol() public pure returns (string) {}
    function decimals() public pure returns (uint8) {}
    function totalSupply() public pure returns (uint256) {}
    function balanceOf(address _owner) public pure returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public pure returns (uint256) { _owner; _spender; }

    function _transfer(address _from, address _to, uint256 _value) internal;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);

}


contract Token is IToken, Owned, Utils {
    /* �������� */
    string public standard = '';
    string public name = ''; //��������
    string public symbol = ''; //���ҷ��ű���'$'
    uint8 public decimals = 0;  //���ҵ�λ
    uint256 public totalSupply = 0; //��������

    /*��¼��������ӳ��*/
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* ���������ϴ���һ���¼�������֪ͨ�ͻ���*/
    event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); //���������û�֧�������֪ͨ

    function Token() public 
    {
        name = 'YaoDun Chain';
        symbol = 'YAODUN';
        decimals = 8;
        totalSupply = 2000000000 * 10 ** uint256(decimals);

        balanceOf[owner] = totalSupply;
    }


    /**
     * ˽�з�����һ���ʻ����͸���һ���ʻ�����
     * @param  _from address ���ʹ��ҵĵ�ַ
     * @param  _to address ���ܴ��ҵĵ�ַ
     * @param  _value uint256 ���ܴ��ҵ�����
     */
    function _transfer(address _from, address _to, uint256 _value)
      internal
      validAddress(_from)
      validAddress(_to)
    {


      //��鷢�����Ƿ�ӵ���㹻���
      require(balanceOf[_from] >= _value);

      //����Ƿ����
      require(balanceOf[_to] + _value > balanceOf[_to]);

      //�����������ں�����ж�
      uint previousBalances = safeAdd(balanceOf[_from], balanceOf[_to]);

      //�ӷ����߼������Ͷ�
      balanceOf[_from] = safeSub(balanceOf[_from], _value);

      //�������߼�����ͬ����
      balanceOf[_to] += safeAdd(balanceOf[_to], _value);

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
    function transfer(address _to, uint256 _value)
      public
      validAddress(_to)
      returns (bool)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * ��ĳ��ָ�����ʻ��У�����һ���ʻ����ʹ���
     *
     * ���ù��̣��������õ���������׶�
     *
     * @param  _from address �����ߵ�ַ
     * @param  _to address �����ߵ�ַ
     * @param  _value uint256 Ҫת�ƵĴ�������
     * @return        �Ƿ��׳ɹ�
     */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool)
    {
        //��鷢�����Ƿ�ӵ���㹻���֧��������
        require(_value <= allowance[_from][msg.sender]);   // Check allowance

        allowance[_from][msg.sender] -= safeSub(allowance[_from][msg.sender], _value);

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
    function approve(address _spender, uint256 _value)
        public
        validAddress(_spender)
        returns (bool success)
    {

        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract IYaoDun {

    function _transfer(address _from, address _to, uint256 _value) internal;
    function mintToken(address target, uint256 mintedAmount) public;
    function freezeAccount(address target, bool freeze) public;
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public;
    function buy() payable public;
    function sell(uint256 amount) public;
}


contract SmartToken is Owned, Token {

    string public version = '0.1';

    // triggered when a smart token is deployed - the _token address is defined for forward compatibility, in case we want to trigger the event from a factory
    event NewSmartToken(address _token);

    /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����
     * @param tokenName ��������
     * @param tokenSymbol ���ҷ���
     * @param tokenTotal ��������
     * @param decimalsUnits ���Һ���ĵ�λ��С���������ٸ�0����̫��һ����������18��0
     */
    function SmartToken()
        public
        Token ()
    {
        emit NewSmartToken(address(this));
    }

}


contract YaoDun is IYaoDun, Token {

    //�����Ļ���,һ�����ң������������ٸ���̫�ң���λ��wei
    uint256 public sellPrice;

    //����Ļ���,1����̫�ң������򼸸�����
    uint256 public buyPrice;

    //�Ƿ񶳽��ʻ����б�
    mapping (address => bool) public frozenAccount;

    //����һ���¼��������ʲ��������ʱ��֪ͨ���ڼ����¼��Ŀͻ���
    event FrozenFunds(address target, bool frozen);

    // triggered when a smart token is deployed - the _token address is defined for forward compatibility, in case we want to trigger the event from a factory
    event NewSmartToken(address _token);


    function YaoDun()
      public
      Token ()
    {
        sellPrice = 2;     //����1����λ�Ĵ���(��λ��wei)���ܹ�����2����̫��
        buyPrice = 4;      //����1����̫�ң�������0.25������
        emit NewSmartToken(address(this));
    }


    function _transfer(address _from, address _to, uint _value)
        validAddress(_from)
        validAddress(_to)
        internal
    {
        //��鷢�����Ƿ�ӵ���㹻���
        require (balanceOf[_from] > _value);

        //����Ƿ����
        require (balanceOf[_to] + _value > balanceOf[_to]);

        //��� �����ʻ�
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);



        //�ӷ����߼������Ͷ�
        balanceOf[_from] = safeSub(balanceOf[_from], _value);

        //�������߼�����ͬ����
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);

        //֪ͨ�κμ����ý��׵Ŀͻ���
        emit Transfer(_from, _to, _value);

    }

    /**
     * �˻��ڿ�
     * @param  target address �ʻ���ַ
     * @param  mintedAmount uint256 ���ӵĽ��(��λ��wei)
     */
    function mintToken(address target, uint256 mintedAmount)
        validAddress(target)
        public
        onlyOwner
    {

        //��ָ����ַ���Ӵ��ң�ͬʱ����Ҳ���
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;


        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    /**
     * ���Ӷ����ʻ�����
     *
     * �������Ҫ��ܹ����Ա����ܿ���˭����/˭������ʹ���㴴���Ĵ��Һ�Լ
     *
     * @param  target address �ʻ���ַ
     * @param  freeze bool    �Ƿ񶳽�
     */
    function freezeAccount(address target, bool freeze)
        validAddress(target)
        public
        onlyOwner
    {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /**
     * ���������۸�
     *
     * ���������ether(����������)Ϊ��Ĵ��ҽ��б���,�Ա�����г����Զ�����������,���ǿ�����ô�������Ҫʹ�ø����ļ۸�Ҳ��������������
     *
     * @param newSellPrice �µ������۸�
     * @param newBuyPrice �µ�����۸�
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
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
        require(balanceOf[address(this)] >= amount * sellPrice);

        _transfer(msg.sender, this, amount);

        msg.sender.transfer(amount * sellPrice);
    }
}