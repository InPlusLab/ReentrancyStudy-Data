/**

 *Submitted for verification at Etherscan.io on 2018-08-11

*/



pragma solidity ^0.4.24;



contract Token {



    /// ����٧ӧ�ѧ�ѧ֧� ��ҧ�֧� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ��

    function totalSupply() constant returns (uint256 supply) {}



    /// ���ѧ�ѧާ֧��� �ӧݧѧէ֧ݧ���. ���է�֧�, �� �ܧ�����ԧ� �ҧ�է�� �ڧ٧ӧݧ֧ܧѧ���� ���ܧ֧ߧ�.

    /// ����٧ӧ�ѧ�ѧ֧� ��֧ܧ��ڧ� �ҧѧݧѧߧ�.

    function balanceOf(address _owner) constant returns (uint256 balance) {}



    /// ���ӧ֧է�ާݧ�֧� ��� �����ѧӧܧ� `_value` ���ܧ֧ߧ�� �ߧ� �ѧէ�֧� `_to` �ڧ� `msg.sender`

    /// ���ѧ�ѧާ֧�� _to ��٧ߧѧ�ѧ֧� �ѧէ�֧� ���ݧ��ѧ�֧ݧ�

    /// ���ѧ�ѧާ֧�� _value ��٧ߧѧ�ѧ֧� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ��, �ܧ������ �ҧ�է�� �����ѧӧݧ֧ߧ�

    /// ����٧ӧ�ѧ�ѧ֧� �ڧߧ���ާѧ�ڧ�, �ҧ�ݧ� �ݧ� ���ѧߧ٧ѧܧ�ڧ� ����֧�ߧ�� �ڧݧ� �ߧ֧�

    function transfer(address _to, uint256 _value) returns (bool success) {}



    /// ���ӧ֧է�ާݧ�֧� ��� �����ѧӧܧ� `_value` ���ܧ֧ߧ�� �ߧ� �ѧէ�֧� `_to` �ڧ� `_from` ���� ���ݧ�ӧڧ�, ���� ���է�ӧ֧�اէ֧ߧ� `_from`

    /// ���ѧ�ѧާ֧�� _from ��٧ߧѧ�ѧ֧� �ѧէ�֧� �����ѧӧڧ�֧ݧ�

    /// ���ѧ�ѧާ֧�� _to ��٧ߧѧ�ѧ֧� �ѧէ�֧� ���ݧ��ѧ�֧ݧ�

    /// ���ѧ�ѧާ֧�� _value ��٧ߧѧ�ѧ֧� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ��, �ܧ������ �ҧ�է�� �����ѧӧݧ֧ߧ�

    /// ����٧ӧ�ѧ�ѧ֧� �ڧߧ���ާѧ�ڧ�, �ҧ�ݧ� �ݧ� ���ѧߧ٧ѧܧ�ڧ� ����֧�ߧ�� �ڧݧ� �ߧ֧�

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}



    /// ���ӧ֧է�ާݧ�֧� `msg.sender` ���է�ӧ֧�էڧ�� `_addr` �էݧ� �����ѧӧܧ� `_value` ���ܧ֧ߧ��

    /// ���ѧ�ѧާ֧�� _spender ��٧ߧѧ�ѧ֧� �ѧէ�֧� ���֧��, �� �ܧ�����ԧ� �ާ�اߧ� �����ѧӧݧ��� ���ܧ֧ߧ�

    /// ���ѧ�ѧާ֧�� _value ��٧ߧѧ�ѧ֧� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ��, �ܧ������ ��ѧ٧�֧�֧ߧ� �����ѧӧڧ��

    /// ����٧ӧ�ѧ�ѧ֧� �ڧߧ���ާѧ�ڧ�, �ҧ�ݧ� �ݧ� ���ѧߧ٧ѧܧ�ڧ� ����֧�ߧ�� �ڧݧ� �ߧ֧�

    function approve(address _spender, uint256 _value) returns (bool success) {}

    

    /// ���ѧ�ѧާ֧�� _owner ��٧ߧѧ�ѧ֧� �ѧէ�֧� �ӧݧѧէ֧ݧ��� ���ܧ֧ߧ��

    /// ���ѧ�ѧާ֧�� _spender ��٧ߧѧ�ѧ֧� �ѧէ�֧� ���֧��, �� �ܧ�����ԧ� �ާ�اߧ� �����ѧӧݧ��� ���ܧ֧ߧ�

    /// ����٧ӧ�ѧ�ѧ֧� �ڧߧ���ާѧ�ڧ� ��� ����ѧӧ�֧ާ�� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ��, �ܧ������ �ާ�اߧ� �����ѧ�ڧ��

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {



        //���� ��ާ�ݧ�ѧߧڧ� ���֧է��ݧѧԧѧ֧���, ���� totalSupply �ߧ� �ާ�ا֧� �ҧ��� �ҧ�ݧ��� (2^256 - 1).

        //����ݧ� ���ܧ֧� �ߧ� ���է֧�اڧ� totalSupply �� �ާ�اߧ� �ߧ֧�ԧ�ѧߧڧ�֧ߧߧ� �ӧ����ܧѧ�� ���ܧ֧ߧ�, �ߧ֧�ҧ��էڧާ� ��ݧ֧էڧ�� �٧� ��֧�֧ܧ�ߧӧ֧��ѧ�ڧ֧� ���ܧ֧ߧ�.

        //���ѧާ֧ߧڧ�� ���֧�ѧ��� if �ߧ� this one.

        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

        

                if (balances[msg.sender] >= _value && _value > 0) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else { return false; }

    }



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        //���ѧ� �� ��ܧѧ٧ѧߧ� ��ӧ���, �٧ѧާ֧ߧڧ�� ���� �����ܧ� �ߧڧا֧ߧѧ�ڧ�ѧߧߧ��, �֧�ݧ� �ا֧ݧѧ֧�� �٧ѧ�ڧ�ڧ�� �ܧ�ߧ��ѧܧ� ��� ��֧�֧ܧ�ߧӧ֧��ڧ��ӧѧߧߧ�� ���ܧ֧ߧ��.  

        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } else { return false; }

    }



    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;

}



contract RussianCash is StandardToken { // ���������������� ������������������. ���ҧߧ�ӧڧ�� �ߧѧ٧ӧѧߧڧ� �ܧ�ߧ��ѧܧ��.



    /* ����ҧݧڧ�ߧ�� ��֧�֧ާ֧ߧߧ�� ���ܧ֧ߧ� */



    /*

    ����������������:

    ���ڧا֧ڧ٧ݧ�ا֧ߧߧ�� ��֧�֧ާ֧ߧߧ�� ����������������������. ���֧� �����ԧ�� �ߧ֧�ҧ��էڧާ���� �ڧ� �ӧܧݧ��ѧ��.

    

      ���ߧ� ���٧ӧ�ݧ��� �ܧѧ���ާڧ٧ڧ��ӧѧ�� �ܧ�ߧ��ѧܧ� ���ܧ֧ߧ� �� �ߧ� �ӧݧڧ��� �ߧ� ���ߧ�ӧߧ�� ���ߧܧ�ڧ�.

    ���֧ܧ������ ��ڧ���ӧ��-�ܧ��֧ݧ�ܧ�/�ڧߧ�֧��֧ۧ�� �ާ�ԧ�� �ߧ� ���էէ֧�اڧӧѧ�� ���� ���ߧܧ�ڧ�.

    */

    string public name;                   // ���ѧ٧ӧѧߧڧ� ���ܧ֧ߧ�

    uint8 public decimals;                // ���ѧ� �ާߧ�ԧ� ���ܧѧ٧�ӧѧ�� �է֧���ڧ�ߧ��. ���� ��ާ�ݧ�ѧߧڧ� ����ѧߧѧӧݧڧӧѧ֧� �٧ߧѧ�֧ߧڧ�, ��ѧӧߧ�� 18

    string public symbol;                 // ���է֧ߧ�ڧ�ڧܧѧ���: �ߧѧ��ڧާ֧� SBX, XPR �� ��.��...

    string public version = 'H1.0'; 

    uint256 public unitsOneEthCanBuy;     // ���ѧ� �ާߧ�ԧ� �֧էڧߧڧ� �ӧѧ�֧ԧ� ���ܧ֧ߧ� �ާ�اߧ� �ܧ��ڧ�� �٧� 1 ETH?

    uint256 public totalEthInWei;         // WEI ��ѧӧߧ�֧��� �ާڧߧڧާѧݧ�ߧ�ާ� �٧ߧѧ�֧ߧڧ� ETH (��ܧӧڧӧѧݧ֧ߧ�ߧ� ��֧ߧ�� �� USD �ڧݧ� ��ѧ���� �� BTC). ���է֧�� �ާ� �ҧ�է֧� ���ѧߧڧ�� �ӧ�� ���ڧӧݧ֧�֧ߧߧ�� ETH ��֧�֧� ICO

    address public fundsWallet;           // ����է� �է�ݧاߧ� ��֧�֧ߧѧ��ѧӧݧ����� ���ڧӧݧ֧�֧ߧߧ�� ETH?



    // ����� �ܧ�ߧ����ܧ���-���ߧܧ�ڧ�, �֧� �ڧާ� �է�ݧاߧ� �����ӧ֧���ӧ�ӧѧ�� �ӧ��֧ߧѧ�ڧ�ѧߧߧ�ާ� �ߧѧ٧ӧѧߧڧ�

    function RussianCash() {

        balances[msg.sender] = 1000000000000000000000000000;               // ����֧է���ѧӧڧ�� ���٧էѧ�֧ݧ� �ܧ�ߧ��ѧܧ�� �ӧ�� �ߧѧ�ѧݧ�ߧ�� ���ܧ֧ߧ�. �� �ߧѧ�֧� ��ݧ��ѧ� �ܧ�ݧڧ�֧��ӧ� ��ѧӧߧ� 1000000000. ����ݧ� �ӧ� ����ڧ��, ����ҧ� �ܧ�ݧڧ�֧��ӧ� ��ѧӧߧ�ݧ��� ��ڧ�ݧ� X, �� �է֧���ڧ�ߧ�� ��ѧӧߧ�ݧڧ�� 5, ����ѧߧ�ӧڧ�� ��ݧ֧է���֧� �٧ߧѧ�֧ߧڧ� X * 100000. (���������������� ������������������)

        totalSupply = 1000000000000000000000000000;                        // ���ҧߧ�ӧڧ�� ��ҧ�ڧ� �ӧ����� (1000000000 �էݧ� ���ڧާ֧��) (���������������� ������������������)

        name = "Russian Cash";                                   // �����ѧߧ�ӧڧ�� �ߧѧ٧ӧѧߧڧ� ���ܧ֧ߧ� �էݧ� ����ҧ�ѧا֧ߧڧ� �ߧ� �էڧ��ݧ֧� (���������������� ������������������)

        decimals = 18;                                               // ����ݧڧ�֧��ӧ� �է֧���ڧ�ߧ�� �٧ߧѧܧ�� ����ݧ� �٧ѧ����� �էݧ� ����ҧ�ѧا֧ߧڧ� �ߧ� �էڧ��ݧ֧� (���������������� ������������������)

        symbol = "RUS";                                             // ���է֧ߧ�ڧ�ڧܧѧ��� ���ܧ֧ߧ� �էݧ� ����ҧ�ѧا֧ߧڧ� �ߧ� �էڧ��ݧ֧� (���������������� ������������������)

        unitsOneEthCanBuy = 2500;                                      // �����ѧߧ�ӧڧ�� ��֧ߧ� �٧� �֧էڧߧڧ�� �ӧѧ�֧ԧ� ���ܧ֧ߧ� �էݧ� ICO (���������������� ������������������)

        fundsWallet = msg.sender;                                    // ���ݧѧէ֧ݧ֧� �ܧ�ߧ��ѧܧ�� ���ݧ��ѧ֧� ETH

    }



    function() payable{

        totalEthInWei = totalEthInWei + msg.value;

        uint256 amount = msg.value * unitsOneEthCanBuy;

        require(balances[fundsWallet] >= amount);



        balances[fundsWallet] = balances[fundsWallet] - amount;

        balances[msg.sender] = balances[msg.sender] + amount;



        Transfer(fundsWallet, msg.sender, amount); // ���֧�֧էѧ�� ����ҧ�֧ߧڧ� �ҧݧ�ܧ�֧ۧ�-��֧��



        //������ѧӧڧ�� Ether �� fundsWallet

        fundsWallet.transfer(msg.value);                               

    }



    /* ���֧�ڧ�ڧܧѧ�ڧ� �� �٧ѧ�֧� �ӧ�٧�� �ܧ�ߧ��ѧܧ�� */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

       Approval(msg.sender, _spender, _value);



        //�ӧ�٧�� ���ߧܧ�ڧ� receiveApproval �� �ܧ�ߧ��ѧܧ��, �ܧ������ �ӧ� ����ڧ�� ��ӧ֧է�ާڧ��. ������ �����֧�� ��� ��ާ�ݧ�ѧߧڧ� ���٧էѧ֧� ���է�ڧ�� ���ߧܧ�ڧ�, �ߧ� �� �ߧѧ�֧� ��ݧ��ѧ� ���� �ߧ� �ߧ�اߧ� �ӧܧݧ��ѧ�� �� �ܧ�ߧ��ѧܧ�.

        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)

        //�� ����ާ� �ާ�ާ֧ߧ��, �ӧ�٧�� �� ���ߧܧ�ڧ� �է�ݧا֧� ����ۧ�� ����֧�ߧ�. 

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }

        return true;

    }

}