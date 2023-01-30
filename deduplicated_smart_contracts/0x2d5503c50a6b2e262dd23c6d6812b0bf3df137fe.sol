/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

pragma solidity ^0.4.25;

contract ERC20ext
{
    // stand
    function totalSupply() public constant returns (uint supply);
    function balanceOf(address who) public constant returns (uint value);
    function allowance(address owner, address spender) public constant returns (uint _allowance);

    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // extand
    //function setCtrlToken(address newToken) public returns (bool ok);
    //function approveAuto(address spender, uint value ) public returns (bool ok);

    function appointNewCFO(address newCFO) public returns (bool ok);
    function melt(address dst, uint256 wad) public returns (bool ok);
    function mint(address dst, uint256 wad) public returns (bool ok);
    function freeze(address dst, bool flag) public returns (bool ok);

    event MeltEvent(address indexed dst, uint256 wad);
    event MintEvent(address indexed dst, uint256 wad);
    event FreezeEvent(address indexed dst, bool flag);
}

//---------------------------------------------------------
// SafeMath ��һ����ȫ��������ĺ�Լ
//---------------------------------------------------------
contract SafeMath
{
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c)
    {
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
    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

//---------------------------------------------------------
// atToken ��һ����ǿ��ERC20��Լ
//---------------------------------------------------------
contract atToken is ERC20ext,SafeMath
{
    string public name;
    string public symbol;
    uint8  public decimals = 18;

    // ����������׼��TOKEN��ַ
    address _token;

    address _cfo;
    uint256 _supply;

    //�ʻ�������б�
    mapping (address => uint256) _balances;

    //�ʻ���ת���޶�
    mapping (address => mapping (address => uint256)) _allowance;

    //�ʻ����ʽ𶳽�
    mapping (address => bool) public _frozen;

    //-----------------------------------------------
    // ��ʼ����Լ���������д��Ҷ���CFO
    //-----------------------------------------------
    //   @param initialSupply ��������
    //   @param tokenName     ��������
    //   @param tokenSymbol   ���ҷ���
    //-----------------------------------------------
    constructor() public
    {
        // validate input
        //require(bytes(tokenName).length > 0 && bytes(tokenSymbol).length > 0);

        _token  = msg.sender;
        _cfo    = msg.sender;

		uint256 initialSupply = 2000000000;
        _supply = initialSupply * 10 ** uint256(decimals);
        _balances[_cfo] = _supply;

        name   = "CNHT";
        symbol = "CNHT";
    }

    //-----------------------------------------------
    // �жϺ�Լ�������Ƿ� CFO
    //-----------------------------------------------
    modifier onlyCFO()
    {
        require(msg.sender == _cfo);
        _;
    }

    //-----------------------------------------------
    // �жϺ�Լ�������Ƿ� Ctrl Token
    //-----------------------------------------------
    //modifier onlyCtrlToken()
    //{
      //  require(msg.sender == _token);
       // _;
    //}

    //-----------------------------------------------
    // ��ȡ���ҹ�Ӧ��
    //-----------------------------------------------
    function totalSupply() public constant returns (uint256)
    {
        return _supply;
    }

    //-----------------------------------------------
    // ��ѯ�˻����
    //-----------------------------------------------
    // @param  src �ʻ���ַ
    //-----------------------------------------------
    function balanceOf(address src) public constant returns (uint256)
    {
        return _balances[src];
    }

    //-----------------------------------------------
    // ��ѯ�˻�ת���޶�
    //-----------------------------------------------
    // @param  src ��Դ�ʻ���ַ
    // @param  dst Ŀ���ʻ���ַ
    //-----------------------------------------------
    function allowance(address src, address dst) public constant returns (uint256)
    {
        return _allowance[src][dst];
    }

    //-----------------------------------------------
    // �˻�ת��
    //-----------------------------------------------
    // @param  dst Ŀ���ʻ���ַ
    // @param  wad ת�˽��
    //-----------------------------------------------
    function transfer(address dst, uint wad) public returns (bool)
    {
        //��鶳���ʻ�
        require(!_frozen[msg.sender]);
        require(!_frozen[dst]);

        //����ʻ����
        require(_balances[msg.sender] >= wad);

        _balances[msg.sender] = sub(_balances[msg.sender],wad);
        _balances[dst]        = add(_balances[dst], wad);

        emit Transfer(msg.sender, dst, wad);

        return true;
    }


    //-----------------------------------------------
    // �˻�ת�˴�����޶�
    //-----------------------------------------------
    // @param  src ��Դ�ʻ���ַ
    // @param  dst Ŀ���ʻ���ַ
    // @param  wad ת�˽��
    //-----------------------------------------------
    function transferFrom(address src, address dst, uint wad) public returns (bool)
    {
        //��鶳���ʻ�
        require(!_frozen[msg.sender]);
        require(!_frozen[dst]);

        //����ʻ����
        require(_balances[src] >= wad);

        //����ʻ��޶�
        require(_allowance[src][msg.sender] >= wad);

        _allowance[src][msg.sender] = sub(_allowance[src][msg.sender],wad);

        _balances[src] = sub(_balances[src],wad);
        _balances[dst] = add(_balances[dst],wad);

        //ת���¼�
        emit Transfer(src, dst, wad);

        return true;
    }

    //-----------------------------------------------
    // ����ת���޶�
    //-----------------------------------------------
    // @param  dst Ŀ���ʻ���ַ
    // @param  wad ���ƽ��
    //-----------------------------------------------
    function approve(address dst, uint256 wad) public returns (bool)
    {
        _allowance[msg.sender][dst] = wad;

        //�����¼�
        emit Approval(msg.sender, dst, wad);
        return true;
    }

    //-----------------------------------------------
    // �����Զ��ۼ�ת���޶�,�˴���ӽӿ����transferFrom��setCtrlTOken��Ϊ������ⲿ��Լ���ñ�ERC20��Լ���ṩ�ɲ�����
    //-----------------------------------------------
    // @param  dst Ŀ���ʻ���ַ
    // @param  wad ���ƽ��
    //-----------------------------------------------
    //function approveAuto(address src, uint256 wad) onlyCtrlToken public returns (bool)
    //{
      //  _allowance[src][msg.sender] = wad;
       // return true;
    //}

    //-----------------------------------------------
    // ���� CTRL TOKEN ��ַ
    //-----------------------------------------------
    // @param  token �µ�CTRL TOKEN��ַ
    //-----------------------------------------------
    //function setCtrlToken(address NewToken) onlyCFO public returns (bool)
    //{
        //if (NewToken != _token)
        //{
          //  _token = NewToken;
          //  return true;
        //}
        //else
        //{
        //    return false;
        //}
    //}

    //-----------------------------------------------
    // �����µ�CFO
    //-----------------------------------------------
    // @param  newCFO �µ�CFO�ʻ���ַ
    //-----------------------------------------------
    function appointNewCFO(address newCFO) onlyCFO public returns (bool)
    {
        if (newCFO != _cfo)
        {
            _cfo = newCFO;
            return true;
        }
        else
        {
            return false;
        }
    }

    //-----------------------------------------------
    // �����ʻ�
    //-----------------------------------------------
    // @param  dst  Ŀ���ʻ���ַ
    // @param  flag ����
    //-----------------------------------------------
    function freeze(address dst, bool flag) onlyCFO public returns (bool)
    {
        _frozen[dst] = flag;

        //�����ʻ��¼�
        emit FreezeEvent(dst, flag);
        return true;
    }

    //-----------------------------------------------
    // �������
    //-----------------------------------------------
    // @param  dst  Ŀ���ʻ���ַ
    // @param  wad  ������
    //-----------------------------------------------
    function mint(address dst, uint256 wad) onlyCFO public returns (bool)
    {
        //Ŀ���ʻ���ַ�������,ͬʱ��������
        _balances[dst] = add(_balances[dst],wad);
        _supply        = add(_supply,wad);

        //��������¼�
        emit MintEvent(dst, wad);
        return true;
    }

    //-----------------------------------------------
    // ���ٴ���
    //-----------------------------------------------
    // @param  dst  Ŀ���ʻ���ַ
    // @param  wad  ���ٽ��
    //-----------------------------------------------
    function melt(address dst, uint256 wad) onlyCFO public returns (bool)
    {
        //����ʻ����
        require(_balances[dst] >= wad);

        //����Ŀ���ʻ���ַ����,ͬʱ��������
        _balances[dst] = sub(_balances[dst],wad);
        _supply        = sub(_supply,wad);

        //���ٴ����¼�
        emit MeltEvent(dst, wad);
        return true;
    }


    //������ҽӿ�
    //function batchTransfer(address _tokenAddress, address[] _receivers, uint256[] _values) {

        //require(_receivers.length == _values.length && _receivers.length >= 1);
        //bytes4 methodId = bytes4(keccak256("transferFrom(address,address,uint256)"));
       // for(uint256 i = 0 ; i < _receivers.length; i++){
            //if(!_tokenAddress.call(methodId, msg.sender, _receivers[i], _values[i])) {
             //   revert();
            //}
       // }
    //}

}