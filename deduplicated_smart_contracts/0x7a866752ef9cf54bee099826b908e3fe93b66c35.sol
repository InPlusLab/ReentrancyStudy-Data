/**

 *Submitted for verification at Etherscan.io on 2019-04-22

*/



pragma solidity ^0.4.16;



contract Token{

    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns   (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



/**

�Զ����MaryCash����

 */

contract MaryCash is Token {

 

    /**

    �������ƣ�����"MaryCash"

     */

    string public name;  

    /**

    ����tokenʹ�õ�С�����λ�������������Ϊ3������֧��0.001��ʾ.

    */                 

    uint8 public decimals; 

    /**

    token���, GAVC

    */              

    string public symbol;               

 

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    

    /**

    ���췽��

     */

    function MaryCash(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) public {

        // ���ó�ʼ����

        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits); 

        /**

        ��ʼtoken����������Ϣ�����ߣ���Ϊ�ǹ��캯������������Ҳ�Ǻ�Լ�Ĵ�����        

        */

        balances[msg.sender] = totalSupply; 

        name = _tokenName;                   

        decimals = _decimalUnits;          

        symbol = _tokenSymbol;

    }

 

    function transfer(address _to, uint256 _value) public returns (bool success) {

        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).

        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(_to != 0x0);

        //����Ϣ�������˻��м�ȥtoken����_value

        balances[msg.sender] -= _value;

        //�������˻�����token����_value

        balances[_to] += _value;

        //����ת�ҽ����¼�

        Transfer(msg.sender, _to, _value);

        return true;

    }

 

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        //�����˻�����token����_value

        balances[_to] += _value;

        //֧���˻�_from��ȥtoken����_value

        balances[_from] -= _value; 

        //��Ϣ�����߿��Դ��˻�_from��ת������������_value

        allowed[_from][msg.sender] -= _value;

        //����ת�ҽ����¼�

        Transfer(_from, _to, _value);

        return true;

    }

 

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];

    }

 

    function approve(address _spender, uint256 _value) public returns (bool success) { 

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

 

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        //����_spender��_owner��ת����token��

        return allowed[_owner][_spender];

    }   

}