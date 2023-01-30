/**

 *Submitted for verification at Etherscan.io on 2019-01-29

*/



pragma solidity ^0.4.25;



// ----------------------------------------------------------------------------------------------

// Sample fixed supply token contract

// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.

// ----------------------------------------------------------------------------------------------



// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/issues/20

contract ERC20Interface {



    uint256 public totalSupply;

    // ��ȡ������ַ�����

    function balanceOf(address _owner) public view returns (uint256 balance);



    // ��������ַ����token

    function transfer(address _to, uint256 _value) public returns (bool success);



    // ��һ����ַ����һ����ַ�������

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    //����_spender������˻�ת��_value�������ö�λḲ�ǿ�������ĳЩDEX������Ҫ�˹���

    function approve(address _spender, uint256 _value) public returns (bool success);



    // ����_spender��Ȼ�����_owner�˳����������

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    // tokenת����ɺ����

    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    // approve(address _spender, uint256 _value)���ú󴥷�

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



//�̳нӿں��ʵ��

contract PDAToken is ERC20Interface {



    string public name = "Parking Digital Alliance Token";                   //���ƣ�����"My test token"

    uint8 public decimals = 18;               //����tokenʹ�õ�С�����λ�������������Ϊ3������֧��0.001��ʾ.

    string public symbol = "PDAT";               //token���,like MTT

    //������

    uint private initAmount = 134000000;



    // ���ܺ�Լ��������

    address public owner;



    // ÿ���˻������

    mapping(address => uint256) balances;



    // �ʻ�����������׼�����ת����һ���ʻ����������˵�����ǿ��Ե�֪allowed[��ת�Ƶ��˻�][ת��Ǯ���˻�]

    mapping(address => mapping(address => uint256)) allowed;







    // ���캯��

    constructor() public {



        totalSupply = initAmount * 10 ** uint256(decimals);

        // ���ó�ʼ����

        balances[msg.sender] = totalSupply;



    }





    // �ض��˻������

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    // ת���������˻�

    function transfer(address _to, uint256 _value) public returns (bool success) {

        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).

        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(_to != address (0x0));

        balances[msg.sender] -= _value;

        //����Ϣ�������˻��м�ȥtoken����_value

        balances[_to] += _value;

        //�������˻�����token����_value

        emit Transfer(msg.sender, _to, _value);

        //����ת�ҽ����¼�

        return true;

    }





    //��һ���˻�ת�Ƶ���һ���˻���ǰ������Ҫ������ת�Ƶ����

    function transferFrom(address _from, address _to, uint256 _value) public returns

    (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;

        //�����˻�����token����_value

        balances[_from] -= _value;

        //֧���˻�_from��ȥtoken����_value

        allowed[_from][msg.sender] -= _value;

        //��Ϣ�����߿��Դ��˻�_from��ת������������_value

        emit Transfer(_from, _to, _value);

        //����ת�ҽ����¼�

        return true;

    }





    //�����˻��ӵ�ǰ�û�ת�����Ǹ��˻�����ε��ûḲ��

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        allowed[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);

        return true;

    }





    //���ر�����ת�Ƶ��������

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

}